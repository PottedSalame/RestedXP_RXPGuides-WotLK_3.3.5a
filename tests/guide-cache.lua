-- Production cache/parser/handlers/scheduler. Forced GC is offline-only.
return function(root)
    local new, source, slice = assert(loadfile(root .. "/tests/lazy-guides.lua"))()(root, true)
    local function setup(count, extra)
        local f, a, e = new()
        for i = 1, count or 6 do
            a.RegisterGuide(source("Cache " .. i, ".accept 788\nstep\n.complete 788,1\nstep\n.turnin 788"))
        end
        if extra then a.RegisterGuide(extra) end
        a.LoadEmbeddedGuides()
        return f, a, e
    end
    local function get(a, i) return a.GetGuideTable("Lazy Fixture", "Cache " .. i) end
    local function settle(f) for _ = 1, 12 do f:tick() end end
    local function weakGraph(g)
        return setmetatable({g, g.steps, g.steps[1], g.steps[1].elements,
            g.steps[1].elements[1]}, {__mode = "v"})
    end
    local function collected(probes)
        collectgarbage("collect"); collectgarbage("collect")
        assert(next(probes) == nil, "Eviction retained a body/steps/elements graph")
    end
    local f, a, e = setup()
    local metadata = get(a, 1)
    local body = a:FetchGuide(metadata)
    local signature, key, id = body.sourceSignature, body.key, body.steps[1].stepId
    local identity = body.steps[1].progressIdentity
    local probes = weakGraph(body)
    a.currentGuide = a.ProcessGuideTable(a:FetchGuide(get(a, 2)))
    assert(a:FetchGuide(a.currentGuide) == a.currentGuide, "Fetch discarded current runtime filtering")
    body = nil
    for i = 3, 6 do a:FetchGuide(get(a, i)) end
    local before = a.guideBodyCache.evictions
    f:tick()
    assert(a.guideBodyCache.evictions == before + 1, "Cleanup exceeded one body per cycle")
    settle(f)
    assert(a.guideBodyCache:GetStats().eligibleInactive == 2)
    assert(a.currentGuide.key == get(a, 2).key and get(a, 2).steps)
    collected(probes)
    assert(get(a, 1) == metadata and not metadata.steps)
    assert(#a.pickUpList[788] == 6 and #a.turnInList[788] == 6)
    body = a:FetchGuide(metadata)
    assert(body.key == key and body.sourceSignature == signature and body.steps[1].stepId == id)
    assert(body.steps[1].progressIdentity == identity and body.steps[1].elements[1].questId == 788)
    assert(#a.pickUpList[788] == 6, "Reconstruction duplicated quest indexes")
    -- A retained obsolete object must not bypass reconstruction.
    local old = body
    for i = 3, 6 do a:FetchGuide(get(a, i)) end
    settle(f)
    local rebuilt = a:FetchGuide(old)
    assert(rebuilt ~= old and rebuilt.bodyCacheGeneration335 > old.bodyCacheGeneration335)
    assert(rebuilt.steps[1].progressIdentity == identity)
    local generation = rebuilt.bodyCacheGeneration335
    for _ = 1, 20 do a:FetchGuide(rebuilt); a:FetchGuide(get(a, 2)); settle(f) end
    assert(a:FetchGuide(rebuilt).bodyCacheGeneration335 == generation, "Warm A/B reparsed")
    assert(f:count("progress") == 0 and f:count("element") == 0)
    assert(e.RXPCData.guideProgress.saved.currentStep == 7 and e.RXPCData.guideProgress.saved.stepSkip[3])

    -- Temporary consumers and included step graphs take precedence over LRU.
    local pf, p = setup()
    local release = p.guideBodyCache:Retain(p:FetchGuide(get(p, 1)))
    p.currentGuide = p.ProcessGuideTable(p:FetchGuide(get(p, 2)))
    p.currentGuide.bodyCacheDependencies335[get(p, 3).key] = true
    for i = 3, 6 do p:FetchGuide(get(p, i)) end
    settle(pf)
    assert(get(p, 1).steps and get(p, 3).steps)
    assert(p.guideBodyCache:GetStats().protected == 3)
    release(); release(); settle(pf)
    assert(not get(p, 1).steps, "Released owner remained pinned")
    p.settings.profile.preLoadData = true
    p.LoadAllGuides(); settle(pf)
    for _, g in pairs(p.guides) do assert(g.steps) end
    p.settings.profile.preLoadData = false
    p.guideBodyCache:RequestTrim(); settle(pf)
    assert(p.guideBodyCache:GetStats().eligibleInactive == 2)

    -- Real scheduler defers combat and barriers, without permanent retry work.
    local bf, b, be = setup()
    be.InCombatLockdown = function() return true end
    for i = 1, 6 do b:FetchGuide(get(b, i)) end
    bf:tick(); assert(b.guideBodyCache.evictions == 0)
    be.InCombatLockdown = function() return false end
    b.scheduler:Cancel(b.guideBodyCache, "trim")
    b.guideBodyCache.loading = 1; b.guideBodyCache:RequestTrim(); bf:tick()
    assert(b.guideBodyCache.evictions == 0 and not b.scheduler:Has(b.guideBodyCache, "trim"))
    b.guideBodyCache.loading = 0
    local transaction = b.questRewardTransaction
    transaction.active = {serial = 1, guide = get(b, 1)}
    b.guideBodyCache:RequestTrim(); bf:tick()
    assert(b.guideBodyCache.evictions == 0)
    transaction:Finish(1); settle(bf)
    assert(b.guideBodyCache:GetStats().eligibleInactive == 2)

    -- Confirmations retain only while pending; accept/cancel/escape/replacement
    -- release captured bodies as well as payloads. Hide-before-accept is safe.
    local cf, c, ce = setup()
    ce.StaticPopupDialogs, ce.StaticPopup_Show = {}, function() end
    cf.execute(slice("Features/Communications.lua", "local pendingChoices335", "function addon.comms:PopupNotification"))
    local actions = 0
    local function prompt()
        local g = c:FetchGuide(get(c, 1))
        local probe = weakGraph(g)
        c.comms:ConfirmChoice("fixture", "confirm", function(payload)
            assert(payload.guide == g); actions = actions + 1
        end, {guide = g})
        return probe
    end
    for _, action in ipairs({"accept", "cancel", "hide", "replace", "hideAccept", "expired"}) do
        local probe = prompt()
        for i = 2, 6 do c:FetchGuide(get(c, i)) end
        settle(cf)
        assert(get(c, 1).steps, "Pending confirmation evicted")
        local dialog = ce.StaticPopupDialogs.fixture
        if action == "accept" then dialog.OnAccept(); dialog.OnAccept()
        elseif action == "cancel" then dialog.OnCancel(); dialog.OnAccept()
        elseif action == "hide" then dialog.OnHide(); cf:tick(); dialog.OnAccept()
        elseif action == "replace" then c.comms:ConfirmChoice("fixture", "new", function() end); dialog.OnAccept()
        elseif action == "hideAccept" then dialog.OnHide(); dialog.OnAccept()
        else c.comms:CancelChoice("fixture"); dialog.OnAccept() end
        settle(cf)
        collected(probe)
    end
    assert(actions == 2, "Confirmation dispatched twice or after cancellation")
    -- Explicit parse failures leave the registry/body and active graph intact.
    local failed = get(c, 1)
    local parser = c.ParseGuide
    c.ParseGuide = function() error("fixture parser failure") end
    c.comms.PrettyDebug = function() end
    local running = c.ProcessGuideTable(c:FetchGuide(get(c, 6)))
    c.currentGuide = running
    assert(not c:FetchGuide(failed) and c.currentGuide == running and not get(c, 1).steps)
    cf.execute(slice("UI/GuideWindow.lua", "function addon:PrepareGuideLoad335(", "function addon:ReloadGuide("))
    ce.time = function() return 1 end
    cf.load("Guide/State.lua"); cf.load("Features/Roadmap.lua")
    c.emptyGuide = {key = "empty", group = "Empty", name = "Empty", empty = true, steps = {}}
    local acknowledged = 0
    assert(not c:LoadGuide(failed), "Failed reconstruction loaded the empty fallback")
    assert(not c.guideState:Load(failed, false, "manual", function() acknowledged = acknowledged + 1 end))
    assert(c.currentGuide == running and acknowledged == 0 and c.guideBodyCache.loading == 0)
    assert(c.guide == false and not c.lastElement and not c.lastObjective and not c.step)
    c.ParseGuide = parser
    assert(c:FetchGuide(failed).steps)

    -- Independent canonical families with identical names and real checkpoint
    -- capture/apply. No checkpoint stores a parsed guide or shares skip tables.
    local sf, saved, se = new()
    se.time = function() return 1 end
    sf.load("Guide/State.lua"); sf.load("Features/Roadmap.lua")
    local groups = {"RestedXP Speedrun Guide (H)",
        "Original Guides - RestedXP Hardcore Classic Guides (H)",
        "Original Guides - RestedXP Hardcore TBC Guides (H)", "RestedXP Hardcore Guides (H)"}
    for _, group in ipairs(groups) do
        local text = source("Same Name", ".accept 788\nstep\n.complete 788,1\nstep\n.turnin 788")
        saved.RegisterGuide((text:gsub("#group Lazy Fixture", "#group " .. group)))
    end
    saved.LoadEmbeddedGuides()
    se.RXPCData.recentGuides = {}
    se.RXPData.guideHub = {favorites = {}}
    local signatures = {}
    for i, group in ipairs(groups) do
        local g = saved:FetchGuide(saved.GetGuideTable(group, "Same Name"))
        signatures[group] = g.steps[1].progressIdentity
        saved.currentGuide = saved.ProcessGuideTable(g)
        se.RXPCData.currentStep, se.RXPCData.stepSkip = i % 3 + 1, {[i] = true}
        se.RXPCData.completedWaypoints = {}
        se.RXPData.guideHub.favorites[g.key] = true
        saved.guideState:RecordLoaded(g)
        settle(sf)
    end
    for i, group in ipairs(groups) do
        local g = saved:FetchGuide(saved.GetGuideTable(group, "Same Name"))
        saved.currentGuide = saved.ProcessGuideTable(g)
        assert(saved.guideState:Apply(g, false))
        assert(se.RXPCData.currentStep == i % 3 + 1 and se.RXPCData.stepSkip[i])
        assert(g.steps[1].progressIdentity == signatures[group] and se.RXPData.guideHub.favorites[g.key])
        settle(sf)
    end
    assert(#se.RXPCData.recentGuides == 4)

    -- Actual include processing, queued advancement and pending map ownership.
    local inf, inc = setup(6, source("Wrapper", "+Wrapper", "#include Cache 1\n"))
    local wrapper = inc.GetGuideTable("Lazy Fixture", "Wrapper")
    assert(wrapper.steps, "Includes must keep their conservative eager path")
    inc.currentGuide = inc.ProcessGuideTable(wrapper)
    local dependency = get(inc, 1)
    assert(inc.currentGuide.bodyCacheDependencies335[dependency.key])
    for i = 2, 6 do inc:FetchGuide(get(inc, i)) end
    settle(inf); assert(get(inc, 1).steps)
    inf.load("Guide/State.lua")
    inc.guideState:QueueAdvance(inc.currentGuide.steps[1])
    inc.currentGuide = nil
    inc.guideBodyCache:RequestTrim(); settle(inf); assert(get(inc, 1).steps)
    inc.guideState:CancelAdvance(); settle(inf); assert(not get(inc, 1).steps)
    inf.execute(slice("UI/Map.lua", "local preparedWorldPins", "local function CancelMapPresentation") ..
        "\nfunction setPreparedFixture(guide) preparedWorldPins = guide and {guide = guide} end")
    local mapGuide = inc.ProcessGuideTable(inc:FetchGuide(get(inc, 1)))
    inf.env.setPreparedFixture(mapGuide)
    for i = 2, 6 do inc:FetchGuide(get(inc, i)) end
    settle(inf); assert(get(inc, 1).steps)
    inf.env.setPreparedFixture(nil); mapGuide = nil
    inc.guideBodyCache:RequestTrim(); settle(inf); assert(not get(inc, 1).steps)

    -- Daily summaries and the catalog remain useful after body reclamation.
    local df, daily = setup(6, source("Daily Cache", ".daily 24579\n.dailyturnin 24579"))
    df.load("Features/ActivityPlanner.lua")
    daily.activityPlanner:BuildCatalog()
    local summary = daily.activityPlanner.catalog[1]
    local dailyBody = daily:FetchGuide(summary.guide)
    local dailyRegistrations = #daily.pickUpList[24579]
    local dailyProbe = weakGraph(dailyBody)
    df.load("UI/GuideHub.lua")
    df.env.RXPData.guideHub = {favorites = {}}
    df.env.RXPCData.recentGuides = {}
    daily.guideHub:Refresh()
    for _, entry in ipairs(daily.guideHub.guides) do
        assert(not entry.guide.steps, "Library retained a full parsed body")
        if entry.key == dailyBody.key then daily.guideHub:Select(entry) end
    end
    assert(daily.guideHub.selected and daily.guideHub.selected.guide == summary.guide)
    dailyBody = nil
    for i = 1, 6 do daily:FetchGuide(get(daily, i)) end
    settle(df)
    assert(not summary.guide.steps and daily.activityPlanner.dailyQuestLookup[24579])
    collected(dailyProbe)
    assert(daily:FetchGuide(summary.guide).steps and #daily.pickUpList[24579] == dailyRegistrations)
    local rf, removed = new()
    removed.RegisterGuide(source("1-6 Removed", ".accept 788\nstep\n.turnin 788"))
    removed.LoadEmbeddedGuides()
    local removedBody = removed:FetchGuide(removed.GetGuideTable("Lazy Fixture", "01-06 Removed"))
    removed.emptyGuide = {key = "empty"}
    assert(removed.RemoveGuide(removedBody.key))
    assert(#removed.pickUpList[788] == 0 and #removed.turnInList[788] == 0,
        "Removing a compiled guide lost its original catalog-index ownership")
    assert(not removed:FetchGuide(removedBody), "Removed stale body bypassed the registry")

    -- Reproduce the real directive-host and hidden-row retention chains, then
    -- use their production teardown (not cache-specific mutation) to release.
    local uf, ui = setup()
    local function widget()
        local w = {scripts = {}}
        function w:SetScript(event, fn) self.scripts[event] = fn end
        function w:Hide() end
        function w:UnregisterAllEvents() end
        function w:SetMouseClickEnabled() end
        function w:SetChecked() end
        function w:EnableMouse() end
        return w
    end
    local host, elementFrame, hidden = widget(), widget(), widget()
    elementFrame.button, elementFrame.highlight = widget(), widget()
    local uiProbe
    do
        local g = ui:FetchGuide(get(ui, 1))
        uiProbe = weakGraph(g)
        hidden.guide, hidden.step = g, g.steps[1]
        host.step, host.elements = g.steps[1], {elementFrame}
        host.callback = function() return g end
        elementFrame.step, elementFrame.element = g.steps[1], g.steps[1].elements[1]
        elementFrame.callback = function() return g.steps end
        elementFrame:SetScript("OnUpdate", function() return g.steps[1] end)
    end
    for i = 2, 6 do ui:FetchGuide(get(ui, i)) end
    settle(uf)
    collectgarbage("collect"); assert(uiProbe[1], "Fixture failed to reproduce retained UI graph")
    uf.env.CurrentStepFrame = {framePool = {host}}
    uf.execute(slice("UI/GuideWindow.lua", "local function ClearFrameData()", "local activeSteps =") .. "\nClearFrameData()")
    uf.env.ScrollChild, uf.env.nframes = {framePool = {{}, hidden}}, 1
    uf.execute(slice("UI/GuideWindow.lua", "    if #ScrollChild.framePool > nframes then", "    ScrollChild.f1 ="))
    collected(uiProbe)
    print("Guide-cache regressions passed: collectible graphs, exact reconstruction, LRU work bounds, ownership, barriers and popup lifecycle.")
end
