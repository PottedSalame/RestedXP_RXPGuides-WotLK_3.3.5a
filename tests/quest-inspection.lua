-- Real parser, next handler, expected-log traversal, scheduler and cleanup.
-- Optional baselinePath is a read-only copy of the committed QuestLog chunk.
return function(root, baselinePath)
    local new, source, slice = assert(loadfile(root .. "/tests/lazy-guides.lua"))()(root, true)
    local function setup(count)
        local f, a, e = new()
        local initial = slice("Guide/QuestLog.lua", "local stepIndex = 0", "local function SetItemTooltip(")
        if baselinePath then
            local file = assert(io.open(baselinePath, "rb"))
            local text = file:read("*a"):gsub("\r\n", "\n"); file:close()
            local start = assert(text:find("local stepIndex = 0", 1, true))
            initial = text:sub(start, assert(text:find("local function SetItemTooltip(", start, true)) - 1)
            f.execute(initial)
        else
            e.GetNumQuests = function() return 3 end
            local ids = {788, 790, 9999}
            a.questLog.GetInfo = function(i)
                return ids[i] and {questID = ids[i], title = "Fixture " .. ids[i], level = 4}
            end
            a.questLog.IsComplete = function() return false end
            f.abandoned, f.messages = {}, {}
            a.questLog.SetSelectedQuest = function(id) f.selected = id end
            a.questLog.SetAbandonQuest = function() end
            a.questLog.AbandonQuest = function() f.abandoned[#f.abandoned + 1] = f.selected end
            a.comms.PrettyPrint = function(message) f.messages[#f.messages + 1] = message end
            e.StaticPopupDialogs, e.StaticPopup_Show = {}, function(_, _, _, data) f.confirmData = data end
            e.ACCEPT, e.CANCEL = "Accept", "Cancel"
            e.LibStub = function() return {NotifyChange = function() end} end
            local createFrame = e.CreateFrame
            e.CreateFrame = function(...)
                local frame = createFrame(...)
                f.inspectionEvents = frame
                return frame
            end
            f.execute("local addonName='RXPGuides'; local L=addon.locale.Get; local C_Timer=addon.timer\n" .. initial ..
                slice("Guide/QuestLog.lua", "local function getQuestData(", "-- ---------- UI creation") ..
                slice("Guide/QuestLog.lua", "-- ---------- events", "--[[ no longer necessary") ..
                "\naddon.fixtureCleanup=RXP_RunCleanupOrphanedQuests")
            e.CreateFrame = createFrame
        end
        for i = 1, count do
            local header = i < count and ("#next Chapter " .. (i + 1) .. "\n") or ""
            local body = ".accept 788\nstep\n+Checkpoint"
            if i == count then body = body .. "\n.turnin 790" end
            a.RegisterGuide(source("Chapter " .. i, body, header))
        end
        a.LoadEmbeddedGuides()
        local counts = {body = 0, quests = 0}
        local parse = a.ParseGuide
        a.ParseGuide = function(...)
            local mode = select(7, ...) or "body"
            counts[mode] = (counts[mode] or 0) + 1
            return parse(...)
        end
        a.currentGuide = a.ProcessGuideTable(a:FetchGuide(a.GetGuideTable("Lazy Fixture", "Chapter 1")))
        for i, step in ipairs(a.currentGuide.steps) do step.index = i end
        a.guideList["Lazy Fixture"].defaultGuide_ = "Chapter 1"
        e.RXPCData.currentStep = 1
        f.log[788], f.log[790], f.log[9999] = true, true, true
        return f, a, e, counts
    end
    local f, a, e, counts = setup(35)
    if not baselinePath then
        f.load("Features/PerformanceInspector.lua")
        a.performanceInspector:InstallInstrumentation()
        a.performanceInspector:StartCapture(30)
    end
    local expected, future, status = a.GetExpectedQuestLog()
    if baselinePath then
        assert(expected[788] and future[790] and counts.body == 1 and counts.quests == 34)
        print("Committed baseline: 1 full body + 34 compact quest parses in one synchronous inspection.")
        return
    end
    assert(status == "pending" and not next(expected) and not next(future) and counts.quests == 0)
    local pending, pendingStatus = a.GetOrphanedQuests()
    assert(#pending == 0 and pendingStatus == "pending" and not a.orphanedList)
    for _ = 1, 50 do a.GetExpectedQuestLog() end -- one queued job, no parse on callers' stacks
    local peak, slices = 0, 0
    while not a.questRouteInspection:IsReady() and slices < 300 do
        local before = counts.quests
        f:tick(); slices = slices + 1
        assert(#a.performanceInspector.spans == 0, "A yielded inspection retained a timing scope")
        peak = math.max(peak, counts.quests - before)
        assert(counts.quests - before <= 1, "Inspection batched cold chapter parses")
    end
    expected, future, status = a.GetExpectedQuestLog()
    assert(status == "ready" and expected[788] and future[790] == a.GetGuideTable("Lazy Fixture", "Chapter 35").key)
    assert(counts.body == 1 and counts.quests == 34 and peak == 1)
    assert(not a.scheduler:Has(a.questRouteInspection, "slice"))
    for _ = 1, 100 do a.GetExpectedQuestLog(); f:tick() end
    assert(counts.quests == 34, "Warm inspection reparsed or permanently polled")
    assert(a.performanceInspector.captureMetrics["quest index parsing"].calls == 34)
    assert(a.performanceInspector.captureMetrics["quest route inspection"].calls == slices)
    assert(not a.performanceInspector.captureMetrics["guide body parsing"])
    a:FetchGuide(a.GetGuideTable("Lazy Fixture", "Chapter 35"))
    assert(a.performanceInspector.captureMetrics["guide body parsing"].calls == 1)
    local orphans, ready = a.GetOrphanedQuests()
    assert(ready == "ready" and #orphans == 1 and orphans[1].questID == 9999)
    assert(a.orphanedList[9999] and not a.orphanedList[790])
    local function settle(s, addon)
        for _ = 1, 300 do
            s:tick()
            if addon.questRouteInspection:IsReady() then return end
        end
        error("Inspection did not settle")
    end
    a.fixtureCleanup()
    assert(f.confirmData and #f.abandoned == 0)
    -- A confirmation opened before a route/log change must not abandon using
    -- an obsolete or incomplete classification, through either entry point.
    a.questRouteInspection:Invalidate()
    e.StaticPopupDialogs.RXP_CONFIRM_ORPHANED_CLEANUP_LIST.OnAccept(nil, f.confirmData)
    a.AbandonOrphanedQuests(orphans)
    a.BeginAbandonOrphans(orphans)
    assert(#f.abandoned == 0 and not a.orphanedList)
    a.GetExpectedQuestLog(); settle(f, a)
    a.AbandonOrphanedQuests({{questID = 788}, {questID = 9999, questLogIndex = 99}})
    assert(#f.abandoned == 1 and f.abandoned[1] == 9999, "Cleanup trusted stale IDs/indexes")

    for _, change in ipairs({"guide", "step", "profile", "mode", "dungeon", "log", "source", "logout"}) do
        local s, b, env = setup(8)
        b.GetExpectedQuestLog(); s:tick(); s:tick()
        if change == "guide" then b.currentGuide = b.ProcessGuideTable(b:FetchGuide(b.GetGuideTable("Lazy Fixture", "Chapter 2")))
        elseif change == "step" then env.RXPCData.currentStep = 2
        elseif change == "profile" then b.settings.profile = env.CopyTable(b.settings.profile)
        elseif change == "mode" then b.settings.profile.hardcore = true
        elseif change == "dungeon" then b.settings.profile.dungeons.WC = true
        elseif change == "source" then b.currentGuide.sourceSignature = "changed"
        else s.inspectionEvents.scripts.OnEvent(nil, change == "log" and "QUEST_LOG_UPDATE" or "PLAYER_LOGOUT") end
        s:tick()
        assert(not b.questRouteInspection:IsReady() and not b.orphanedList, change .. " published stale results")
        b.questRouteInspection:Invalidate(false)
        assert(not b.scheduler:Has(b.questRouteInspection, "slice") and not b.questRouteInspection.worker)
    end
    -- Reward settlement and combat defer work through existing lifecycle hooks.
    local sf, safe, se, sc = setup(6)
    safe.questRewardTransaction.active = {serial = 1}
    safe.GetExpectedQuestLog(); sf:tick()
    assert(sc.quests == 0 and not safe.scheduler:Has(safe.questRouteInspection, "slice"))
    safe.questRewardTransaction:Finish(1)
    settle(sf, safe); assert(sc.quests == 5)
    safe.questRouteInspection:Invalidate(false)
    se.InCombatLockdown = function() return true end
    safe.GetExpectedQuestLog(); sf:tick()
    assert(not safe.questRouteInspection:IsReady())
    se.InCombatLockdown = function() return false end
    sf.frames.RXPCoreSchedulerFrame.scripts.OnEvent()
    settle(sf, safe)
    safe.questRouteInspection:Invalidate(false)
    safe.GetExpectedQuestLog() -- combat starts after the timer was scheduled
    se.InCombatLockdown = function() return true end
    sf:tick()
    assert(not safe.questRouteInspection:IsReady() and safe.scheduler:Has(safe.questRouteInspection, "slice"))
    se.InCombatLockdown = function() return false end
    sf.frames.RXPCoreSchedulerFrame.scripts.OnEvent()
    settle(sf, safe)
    -- Errors fail closed without an automatic retry loop or retained owners.
    safe.questRouteInspection:Invalidate(false)
    safe.GetGuideQuestView = function() error("fixture failure") end
    safe.GetExpectedQuestLog(); for _ = 1, 4 do sf:tick() end
    local _, _, failed = safe.GetExpectedQuestLog()
    assert(failed == "error" and not safe.questRouteInspection.worker and not safe.questRouteInspection.owners)
    assert(not safe.scheduler:Has(safe.questRouteInspection, "slice"))
    safe.questRouteInspection:Invalidate(false)
    safe.GetGuideQuestView = function() return nil end -- parser can report failure without throwing
    safe.GetExpectedQuestLog(); for _ = 1, 4 do sf:tick() end
    local _, _, unavailable = safe.GetExpectedQuestLog()
    assert(unavailable == "error" and not safe.orphanedList)
    -- A long already-parsed chapter also yields instead of merely spreading
    -- the cold parser calls. No incomplete future-turn-in table is published.
    local long, la = setup(1)
    for i = 3, 400 do
        la.currentGuide.steps[i] = {index = i, elements = {}}
    end
    la.currentGuide.steps[400].elements = {{tag = "turnin", questId = 790}}
    la.GetExpectedQuestLog(); long:tick(); long:tick()
    assert(not la.questRouteInspection:IsReady())
    local _, partial, waiting = la.GetExpectedQuestLog()
    assert(waiting == "pending" and not next(partial))
    settle(long, la)
    local _, complete = la.GetExpectedQuestLog()
    assert(complete[790], "Chunking lost the terminal reward")
    -- Synchronous invalidation inside a fetch must not publish the cancelled
    -- coroutine's result or accidentally continue using a replacement job.
    local cancelled, ca = setup(3)
    local fetch = ca.GetGuideQuestView
    ca.GetGuideQuestView = function(...)
        local result = fetch(...)
        ca.questRouteInspection:Invalidate(false)
        return result
    end
    ca.GetExpectedQuestLog(); cancelled:tick(); cancelled:tick()
    assert(not ca.questRouteInspection.worker and not ca.questRouteInspection:IsReady())
    assert(not ca.scheduler:Has(ca.questRouteInspection, "slice") and not ca.orphanedList)
    assert(f:count("progress") == 0 and f:count("element") == 0)
    print("Quest inspection passed: 34 cold compact parses spread across scheduler cycles (max 1/cycle), same quest results, warm reuse, stale cancellation and fail-closed cleanup.")
end
