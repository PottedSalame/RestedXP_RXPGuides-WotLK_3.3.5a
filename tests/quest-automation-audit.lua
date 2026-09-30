-- Offline audit: lua5.1 tests/quest-automation-audit.lua . [--strict]
-- Complete production coordinator and scheduler; no copied automation logic.
local root = (arg and arg[1] or "."):gsub("\\", "/")
local strict = arg and arg[2] == "--strict"
local passed, defects, defectIds = 0, 0, {}
local function check(value, message)
    assert(value, message)
    passed = passed + 1
end
local function finding(id, correct, evidence)
    if correct then print("NOT REPRODUCED " .. id .. ": update audit report")
    else
        defects = defects + 1
        defectIds[id:match("^[^/]+") or id] = true
        print("REPRODUCED " .. id .. ": " .. evidence)
    end
end
local function noop() end
local function fixture()
    -- No implicit fallback to host globals; APIs are explicit mocks.
    local env = {}
    for _, k in ipairs({"assert", "error", "ipairs", "pairs", "next", "pcall",
        "select", "tonumber", "tostring", "type", "unpack", "setmetatable",
        "getmetatable", "string", "math", "table"}) do env[k] = _G[k] end
    env._G = env
    local s = {now = 100, timers = {}, log = {}, done = {}, names = {}, calls = {},
        choices = 0, title = "Fixture quest", qid = 788, cached = true,
        active = {}, available = {}}
    local function call(kind, id) s.calls[#s.calls + 1] = {kind = kind, id = id} end
    local function frame(shown)
        local scripts = {}
        return {IsShown = function() return shown end, scripts = scripts,
            SetShown = function(_, v) shown = v end,
            SetScript = function(_, name, fn) scripts[name] = fn end,
            HookScript = function(_, name, fn)
                local previous = scripts[name]
                scripts[name] = function(...)
                    if previous then previous(...) end
                    fn(...)
                end
            end,
            RegisterEvent = noop, UnregisterEvent = noop}
    end
    s.frames = {}
    env.CreateFrame = function(_, name)
        local f = frame(false)
        if name then s.frames[name] = f end
        return f
    end
    env.GetTime = function() return s.now end
    env.GetAddOnMetadata = function() return "audit" end
    env.GAME_VERSION_LABEL = "Version"
    env.GetBuildInfo = function() return "3.3.5", "", "", 30300 end
    env.UnitClass = function() return "Warrior", "WARRIOR" end
    env.UnitRace = function() return "Orc", "Orc" end
    env.UnitFactionGroup = function() return "Horde" end
    env.UnitGUID, env.UnitName = noop, noop
    env.UnitLevel = function() return 4 end
    env.GetCurrentRegion = function() return 1 end
    env.GetLocale = function() return "enUS" end
    env.GetQuestID = function() return s.qid end
    env.GetTitleText = function() return s.title end
    env.GetNumQuestChoices = function() return s.choices end
    env.IsControlKeyDown = function() return s.ctrl end
    env.InCombatLockdown = function() return false end
    for _, name in ipairs({"QuestFrameRewardPanel", "QuestFrameDetailPanel",
        "QuestFrameProgressPanel", "QuestFrameGreetingPanel", "GossipFrame", "QuestFrame"}) do
        env[name] = frame(name == "QuestFrameRewardPanel" or name == "QuestFrame")
    end
    env.HideUIPanel = function() call("hide") end
    env.IsQuestCompletable = function() return s.completable ~= false end
    env.CompleteQuest = function() call("complete", s.qid) end
    env.AcceptQuest = function() call("accept", s.qid) end
    env.QuestDetailAcceptButton_OnClick, env.ConfirmAcceptQuest = env.AcceptQuest, env.AcceptQuest
    env.GetQuestReward = function(choice)
        call("reward", choice)
        if s.rewardHook then s.rewardHook() end
    end
    env.hooksecurefunc = function(name, callback)
        local original = assert(env[name])
        env[name] = function(...)
            original(...)
            callback(...)
        end
    end
    env.QuestFrameCompleteQuestButton = frame(true)
    env.QuestInfoFrame = {itemChoice = 0}
    env.GetQuestItemInfo = function() return "reward", nil, 1, 1, true end
    env.GetQuestItemLink = function(_, i) return s.cached and ("item:" .. i) or nil end
    env.GetItemInfo = function(link)
        return "reward", link, 1, 1, 1, "", "", 1, "", "", 20
    end
    env.C_GossipInfo = {
        GetActiveQuests = function() return s.active end,
        GetAvailableQuests = function() return s.available end,
        GetNumActiveQuests = function() return #s.active end,
        GetNumAvailableQuests = function() return #s.available end,
        SelectActiveQuest = function(i) call("select-turnin", s.active[i].questID) end,
        SelectAvailableQuest = function(i) call("select-accept", s.available[i].questID) end,
    }
    env.GetNumActiveQuests = function() return #s.active end
    env.GetNumAvailableQuests = function() return #s.available end
    env.GetActiveTitle = function(i) return s.active[i].title, s.active[i].isComplete end
    env.GetAvailableTitle = function(i) return s.available[i].title end
    env.SelectActiveQuest = function(i) call("greeting-turnin", i) end
    env.SelectAvailableQuest = function(i) call("greeting-accept", i) end
    env.C_QuestLog = {GetQuestIDForLogIndex = function(i) return s.logIndex and s.logIndex[i] end}
    env.RXPCData, env.RXPData = {currentStep = 1}, {}
    local timer = {}
    function timer.NewTimer(delay, callback)
        local handle = {due = s.now + delay, callback = callback}
        function handle:Cancel() self.cancelled = true end
        s.timers[#s.timers + 1] = handle
        return handle
    end
    function timer.After(delay, callback) timer.NewTimer(delay, callback) end
    local addon = {locale = {Get = function(text) return text end}, timerAPI335 = timer,
        services = {Register = noop}, facade = {ExposeGlobal = function(_, k, v) env[k] = v end,
            Register = noop}, RegisterMessage = noop, SendMessage = noop}
    local function load(path)
        local file = assert(io.open(root .. "/" .. path, "rb"))
        local source = file:read("*a")
        file:close()
        -- WoW accepts UTF-8 BOMs; stock Lua 5.1 loadstring does not.
        source = source:gsub("^\239\187\191", "")
        local chunk = assert(loadstring(source, "@" .. path))
        setfenv(chunk, env)
        chunk("RXPGuides", addon)
    end
    function s:loadDispatcher()
        local file = assert(io.open(root .. "/UI/GuideWindow.lua", "rb"))
        local source = file:read("*a")
        file:close()
        -- Isolate the exact production function, without constructing the whole UI.
        local body = assert(source:match("function CurrentStepFrame%.EventHandler.-\nend"))
        local chunk = assert(loadstring("local addon, CurrentStepFrame = ...\n" .. body ..
            "\nreturn CurrentStepFrame.EventHandler", "@production-event-dispatcher"))
        setfenv(chunk, env)
        self.dispatch = chunk(addon, {})
    end
    load("Core/Scheduler.lua")
    load("Guide/QuestAcceptState.lua")
    load("Guide/QuestRewardTransaction.lua")
    load("Guide/AutomationOrder.lua")
    load("Core/Addon.lua")
    load("Guide/QuestAutomation.lua")
    addon.settings = {profile = {enableQuestAutomation = true, enableQuestRewardAutomation = true,
        enableTips = true, enableItemUpgrades = true, enableQuestChoiceAutomation = true}}
    function addon.settings:IsEnabled(...)
        for i = 1, select("#", ...) do
            if not self.profile[select(i, ...)] then return false end
        end
        return true
    end
    addon.recentAccept = {}
    addon.IsOnQuest = function(id) return s.log[id] end
    addon.IsQuestComplete = function(id) return s.done[id] end
    addon.GetQuestName = function(id) return s.names[id] end
    addon.UpdateStepCompletion = function() call("progress") end
    addon.SetElementComplete = function(e, complete)
        e.completed = complete
        call("element", e.questId)
    end
    addon.RXPFrame = {RefreshQuestState = function() call("refresh") end}
    addon.UpdateMap = noop
    addon.MarkQuestTurnedIn335 = function(id) call("mark-turned-in", id) end
    addon.currentGuide = {key = "audit||durotar", name = "audit", steps = {}}
    local step = {active = true, index = 1, stepId = "audit-step", elements = {}}
    addon.currentGuide.steps[1] = step
    s.addon, s.env, s.load, s.step = addon, env, load, step
    function s:element(kind, id, title, reward)
        self.names[id] = title
        local e = {tag = kind, questId = id, title = title, text = title,
            step = self.step, reward = reward}
        self.step.elements[#self.step.elements + 1] = e
        local list = kind == "accept" and addon.questAccept or addon.questTurnIn
        list[id], list[title] = e, e
        return e
    end
    function s:count(kind)
        local n = 0
        for _, c in ipairs(self.calls) do if c.kind == kind then n = n + 1 end end
        return n
    end
    function s:tick(delta)
        self.now = self.now + (delta or 0)
        -- New callbacks wait until a subsequent scheduler turn, even at zero.
        local pending = self.timers
        self.timers = {}
        for _, h in ipairs(pending) do
            if not h.cancelled then
                if h.due <= self.now then h.callback()
                else self.timers[#self.timers + 1] = h end
            end
        end
    end
    function s:emit(event, ...) addon:QuestAutomation(event, ...) end
    function s:reward(choices)
        self.choices = choices or 0
        self.log[self.qid] = true
        return self:element("turnin", self.qid, self.title)
    end
    function s:loadDirectives()
        env.C_DateAndTime = {GetCurrentCalendarTime = noop}
        env.LibStub = function() return {} end
        env.GetItemCount = function() return 0 end
        env.QUEST_ITEMS_NEEDED = "%s: %d/%d"
        env.CreateVector2D = function() return {} end
        env.strupper = string.upper
        env.StaticPopupDialogs = {}
        env.GetSpellInfo = function() return "spell" end
        env.GetSpellTexture = function() return "texture" end
        env.UnitAura, env.UnitBuff, env.UnitDebuff = noop, noop, noop
        env.tinsert = table.insert
        env.bit = {band = function(a, b)
            local result, place = 0, 1
            while a > 0 and b > 0 do
                if a % 2 == 1 and b % 2 == 1 then result = result + place end
                a, b, place = math.floor(a / 2), math.floor(b / 2), place * 2
            end
            return result
        end}
        env.C_QuestLog.IsOnQuest = env.C_QuestLog.IsOnQuest or function(id) return not not s.log[id] end
        env.C_QuestLog.IsComplete = env.C_QuestLog.IsComplete or function(id) return s.done[id] end
        env.C_QuestLog.IsQuestFlaggedCompleted = env.C_QuestLog.IsQuestFlaggedCompleted or
            function(id) return s.turnedIn and s.turnedIn[id] end
        addon.colors = {tooltip = ""}
        addon.questConversion, addon.questAcceptItems, addon.questTurnInItems = {}, {}, {}
        addon.comms = {grouping = {ShareQuest = noop}}
        addon.locale.QuestAction = function(_, name) return name end
        addon.GetQuestPreReqState = function() return true end
        addon.UpdateStepText, addon.UpdateItemFrame = noop, noop
        load("Guide/Directives/Handlers.lua")
        -- Server name resolution is outside this isolated coordinator fixture.
        addon.GetQuestName = function(id) return s.names[id] end
        addon.SetElementComplete = function(value)
            local e = value.element or value
            e.completed = true
            call("element", e.questId)
        end
    end
    return s
end

if arg and arg[2] == "--fixtures" then return fixture end

local smoke = fixture()
check(type(smoke.addon.QuestAutomation) == "function", "coordinator failed to load")
print("Production coordinator loaded successfully")

-- Direct dispatch gates. These are not evidence that deferred paths are safe.
local gates = {
    disabled = function(s) s.addon.settings.profile.enableQuestAutomation = false end,
    ctrl = function(s) s.ctrl = true end,
    hidden = function(s) s.addon.isHidden = true end,
    practice = function(s) s.addon.speedrunPracticeActive = true end,
}
for name, gate in pairs(gates) do
    for _, event in ipairs({"QUEST_DETAIL", "QUEST_COMPLETE", "QUEST_PROGRESS", "GOSSIP_SHOW"}) do
        local s = fixture()
        s:reward()
        s:element("accept", 789, "Follow-up")
        s.active = {{questID = 788, title = s.title, isComplete = true}}
        gate(s)
        s:emit(event)
        s:tick(1)
        check(s:count("reward") + s:count("accept") + s:count("complete") +
            s:count("select-turnin") == 0, name .. " failed at direct " .. event)
    end
end

-- Authoritative manual acceptance must update progress even with automation off.
do
    local s = fixture()
    local e = s:element("accept", 4641, "Your Place In The World")
    s.addon.settings.profile.enableQuestAutomation = false
    s.log[4641] = true
    s:emit("QUEST_ACCEPTED", 1, 4641)
    s:emit("QUEST_ACCEPTED", 1, 4641)
    check(e.completed and s:count("element") == 1, "manual accept was lost or duplicated")
end
for _, idMode in ipairs({"index", "second", "pending"}) do
    local s = fixture()
    s.qid, s.title = 804, "Sarkoth"
    local e = s:element("accept", 804, "Sarkoth")
    s:emit("QUEST_DETAIL")
    check(s:count("accept") == 1, "Sarkoth follow-up was not accepted")
    s.log[804], s.logIndex = true, {[1] = 804}
    if idMode == "index" then s:emit("QUEST_ACCEPTED", 1)
    elseif idMode == "second" then s:emit("QUEST_ACCEPTED", 1, 804)
    else s:emit("QUEST_LOG_UPDATE") end
    check(e.completed, "accept identity/reconciliation failed: " .. idMode)
end

-- Real choice evaluator, with client item APIs mocked (no ItemUpgrades solver).
for _, count in ipairs({0, 1, 2}) do
    local s = fixture()
    s:reward(count)
    s:emit("QUEST_COMPLETE")
    check(s:count("reward") == 0, "reward submitted in the initial event dispatch")
    s:tick()
    check(s:count("reward") == 1, "reward did not submit for choice count " .. count)
end
do
    local s = fixture()
    local e = s:reward(2)
    e.reward = 2
    s.addon.settings.profile.enableTips = false
    s:emit("QUEST_COMPLETE")
    s:tick()
    check(s.calls[1].kind == "reward" and s.calls[1].id == 2, "authored choice ignored")
end
do
    local s = fixture()
    local e = s:reward(2)
    s.addon.settings.profile.enableQuestChoiceAutomation = false
    s:emit("QUEST_COMPLETE")
    s:tick()
    check(s:count("reward") == 0, "disabled calculated choice submitted")
    s.log[788] = nil
    s:emit("QUEST_TURNED_IN", 788)
    check(e.completed, "manual reward completion did not update progress")
end
do
    local s = fixture()
    s:reward(2)
    s.cached = false
    s:emit("QUEST_COMPLETE")
    for _ = 1, 10 do s:tick(0.21) end
    check(s:count("reward") == 0 and #s.timers == 0, "item cache retry was unsafe or unbounded")
end

-- Deferred submission must recheck temporary controls at execution time.
for _, name in ipairs({"ctrl", "hidden", "practice"}) do
    local s = fixture()
    s:reward()
    s:emit("QUEST_COMPLETE")
    gates[name](s)
    s:tick()
    check(s:count("reward") == 0,
        "queued GetQuestReward executed after " .. name .. " became active")
end
-- Settings callback calls ResetTransient when disabling; reproduce that contract.
do
    local s = fixture()
    s:reward()
    s:emit("QUEST_COMPLETE")
    gates.disabled(s)
    s.addon.questAutomation:ResetTransient()
    s:tick(1)
    check(s:count("reward") == 0, "disable/reset failed to cancel queued submission")
end
for _, name in ipairs({"disabled", "ctrl", "hidden", "practice"}) do
    local s = fixture()
    s:reward(2)
    s.cached = false
    s:emit("QUEST_COMPLETE") -- schedules the item-data retry, before a transaction exists
    gates[name](s)
    if name == "disabled" then s.addon.questAutomation:ResetTransient() end
    s.cached = true
    s:tick(0.21)
    s:tick()
    check(s:count("reward") == 0,
        "item-data retry submitted a reward despite " .. name)
end
for _, boundary in ipairs({"guide-reset", "zoning", "leaving", "logout"}) do
    local s = fixture()
    s:reward(2)
    s.cached = false
    s:emit("QUEST_COMPLETE")
    if boundary == "guide-reset" then s.addon.questAutomation:ResetForGuideChange()
    elseif boundary == "zoning" then s.addon:ZONE_CHANGED()
    elseif boundary == "leaving" then s.addon:PLAYER_LEAVING_WORLD()
    else
        s.addon.SaveCharacterGuideProgress = noop -- do not test persistence in this fixture
        s.addon.settings.SaveFramePositions = noop
        s.addon:PLAYER_LOGOUT()
    end
    s.cached = true
    s:tick(0.21)
    s:tick()
    check(s:count("reward") == 0,
        "item-data retry survived " .. boundary .. " with a still-visible reward panel")
end

-- A live global wrapper models the order of a secure reward post-hook.
do
    local s = fixture()
    s.qid, s.title = 4641, "Your Place In The World"
    s:element("accept", 4641, s.title)
    s:element("accept", 789, "Sting of the Scorpid")
    s.available = {{questID = 4641, title = s.title}}
    s:emit("GOSSIP_SHOW")
    s:emit("QUEST_DETAIL") -- request rejected or never confirmed
    s:tick(6)
    s:emit("QUEST_LOG_UPDATE")
    s:tick(0.6)
    check(s.addon.questAcceptState:GetPending(s.now, 5) == nil, "pending accept did not expire")
    s.available = {{questID = 789, title = "Sting of the Scorpid"}}
    local before = s:count("select-accept")
    s:emit("GOSSIP_SHOW")
    finding("QA-04", s:count("select-accept") > before,
        "expired failed acceptance retains submitted reservation and blocks another offered quest")
end
do
    local s = fixture()
    s.qid, s.title = 4641, "Your Place In The World"
    s:element("accept", 4641, s.title)
    s:emit("QUEST_DETAIL")
    s:emit("QUEST_DETAIL") -- quest log/event has not confirmed the first request
    finding("QA-05", s:count("accept") == 1,
        "duplicate QUEST_DETAIL submitted AcceptQuest twice before confirmation")
end
do
    local s = fixture()
    local e = s:reward()
    s:element("accept", 789, "Follow-up")
    s.rewardHook = function()
        for _, event in ipairs({"GOSSIP_SHOW", "QUEST_LOG_UPDATE", "QUEST_COMPLETE",
            "QUEST_PROGRESS", "QUEST_DETAIL", "QUEST_FINISHED", "QUEST_GREETING"}) do
            s:emit(event)
        end
        s:emit("QUEST_TURNED_IN", 788)
        check(s:count("progress") == 0 and s:count("accept") == 0 and
            s:count("select-turnin") == 0, "nested dispatch escaped barrier")
    end
    local original, seenTitle = s.env.GetQuestReward
    s.env.GetQuestReward = function(choice)
        original(choice)
        seenTitle = s.env.GetTitleText()
        check(not e.completed, "guide progressed before reward post-hook")
    end
    s:emit("QUEST_COMPLETE")
    s:emit("QUEST_COMPLETE")
    s:tick()
    check(seenTitle == s.title and s:count("reward") == 1, "post-hook context or dedupe failed")
    s:tick(0.06)
    check(e.completed, "exact confirmation failed to settle")
    check(s.addon.IsQuestRewardSettlementActive(), "barrier released in same cycle as commit")
    s:tick(0.06)
    check(not s.addon.IsQuestRewardSettlementActive(), "barrier failed to release")
end
for _, signal in ipairs({"mismatched", "gossip", "log-only", "timeout", "closed", "unknown-log"}) do
    local s = fixture()
    local e = s:reward()
    s:emit("QUEST_COMPLETE")
    s:tick()
    if signal == "mismatched" then s:emit("QUEST_TURNED_IN", 999)
    elseif signal == "gossip" then s:emit("GOSSIP_SHOW")
    elseif signal == "log-only" then s.log[788] = false; s:emit("QUEST_LOG_UPDATE")
    elseif signal == "closed" then
        s.env.QuestFrameRewardPanel:SetShown(false)
        s:emit("QUEST_FINISHED") -- server has not removed or rewarded the quest
    elseif signal == "unknown-log" then s.log[788] = nil; s:emit("QUEST_LOG_UPDATE") end
    s:tick(0.21)
    if signal == "closed" then
        check(not e.completed, "QUEST_FINISHED completed a quest still present in the log")
    elseif signal == "unknown-log" then
        check(not e.completed, "unknown quest-log evidence confirmed a turn-in")
    elseif signal == "log-only" then check(e.completed, "log-only settlement failed")
    else check(not e.completed, "unrelated event falsely settled " .. signal) end
    if signal == "timeout" then
        s:tick(5)
        check(not e.completed and not s.addon.IsQuestRewardSettlementActive(), "timeout did not fail safely")
    end
end

-- Exact-context checks and actual lifecycle reset paths.
for _, change in ipairs({"title", "guide", "step", "panel", "zoning", "leaving", "reset"}) do
    local s = fixture()
    s:reward()
    s:emit("QUEST_COMPLETE")
    if change == "title" then s.title = "Different quest"
    elseif change == "guide" then s.addon.currentGuide = {}
    elseif change == "step" then s.env.RXPCData.currentStep = 2
    elseif change == "panel" then s.env.QuestFrameRewardPanel:SetShown(false)
    elseif change == "zoning" then s.addon:ZONE_CHANGED()
    elseif change == "leaving" then s.addon:PLAYER_LEAVING_WORLD()
    else s.addon.questAutomation:ResetTransient() end
    s:tick(1)
    check(s:count("reward") == 0 and not s.addon.IsQuestRewardSettlementActive(),
        "stale submission survived " .. change)
end

-- Actual Durotar authored order; NPC lists deliberately reversed.
do
    local s = fixture()
    local specifications = {{"turnin", 788, "Cutting Teeth"},
        {"accept", 789, "Sting of the Scorpid"}, {"accept", 2383, "Simple Parchment"},
        {"turnin", 804, "Sarkoth"}}
    local elements = {}
    for i, row in ipairs(specifications) do elements[i] = s:element(unpack(row)) end
    for i, row in ipairs(specifications) do
        s.active, s.available = {}, {}
        for j = #specifications, i, -1 do
            local other = specifications[j]
            local list = other[1] == "turnin" and s.active or s.available
            list[#list + 1] = {questID = other[2], title = other[3], isComplete = true}
        end
        s:emit("GOSSIP_SHOW")
        local selected = s.calls[#s.calls]
        check(selected.kind == "select-" .. row[1] and selected.id == row[2],
            "Gornek order failed at " .. row[2])
        -- Model the next authoritative server event, not guessed completion.
        s:emit(row[1] == "turnin" and "QUEST_TURNED_IN" or "QUEST_ACCEPTED", row[2], row[2])
        check(elements[i].completed, "Gornek confirmation failed at " .. row[2])
    end
end
do
    local s = fixture()
    s:loadDirectives()
    local e = s:element("accept", 4641, "Your Place In The World")
    e.flags, e.frame = 0, {element = e}
    s.addon.settings.profile.enableQuestAutomation = false
    s.log[4641] = true
    s:emit("QUEST_ACCEPTED", 1, 4641)
    check(e.completed, "real accept directive did not confirm manual acceptance")
    check(not next(s.addon.errors), "real accept directive raised a swallowed error")
end
for _, first in ipairs({"central", "directive"}) do
    local s = fixture()
    s:loadDirectives()
    s:loadDispatcher()
    local e = s:reward()
    e.flags = 0
    e.frame = {element = e, step = s.step, callback = s.addon.functions.turnin}
    s.rewardHook = function()
        if first == "directive" then s.dispatch(e.frame, "QUEST_TURNED_IN", 788) end
        s:emit("QUEST_TURNED_IN", 788)
        s.dispatch(e.frame, "QUEST_TURNED_IN", 788)
        check(not e.completed and s:count("progress") == 0,
            "production directive frame escaped reward barrier: " .. first)
    end
    s:emit("QUEST_COMPLETE")
    s:tick()
    s:tick(0.06)
    check(e.completed and not next(s.addon.errors), "real turn-in directive settlement failed")
end
-- Failed API calls cancel ownership rather than leaving an immortal transaction.
do
    local s = fixture()
    local e = s:reward()
    s.env.GetQuestReward = function() error("simulated API failure") end
    s:emit("QUEST_COMPLETE")
    local ok = pcall(function() s:tick() end)
    check(not ok and not e.completed and not s.addon.IsQuestRewardSettlementActive(),
        "reward API error left a live transaction")
end
-- Explicit authored choice disabled: no fallback auto-choice when both are off.
do
    local s = fixture()
    local e = s:reward(2)
    e.reward = 2
    s.addon.settings.profile.enableQuestRewardAutomation = false
    s.addon.settings.profile.enableQuestChoiceAutomation = false
    s:emit("QUEST_COMPLETE")
    s:tick()
    check(s:count("reward") == 0, "disabled authored and calculated choices submitted")
end
-- Legacy QUEST_GREETING path, distinct from gossip selectors.
do
    local s = fixture()
    s:reward()
    s:element("accept", 789, "Follow-up")
    s.active = {{title = s.title, isComplete = true}}
    s.available = {{title = "Follow-up"}}
    s:emit("QUEST_GREETING")
    check(s.calls[1].kind == "greeting-turnin", "greeting bypassed authored turn-in")
end
do
    local count = 0
    for _ in pairs(defectIds) do count = count + 1 end
    print("Distinct baseline defects reproduced: " .. count)
end
print(string.format("Audit assertions: %d; reproduced defects: %d", passed, defects))
if strict and defects > 0 then error("Documented quest automation defects remain") end
