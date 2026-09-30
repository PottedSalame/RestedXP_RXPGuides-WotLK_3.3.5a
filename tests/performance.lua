-- Deterministic work counts, not a claim about in-game frame-time improvement.
return function(root)
    local env = setmetatable({}, {__index = _G})
    env._G = env
    local now, clock, memoryCalls = 0, 0, 0
    local frames = {}
    env.GetTime = function() return now end
    env.debugprofilestop = function() return clock end
    env.GetBuildInfo = function() return "3.3.5", "test", "", 30300 end
    env.GetFramerate = function() return 60 end
    env.UpdateAddOnMemoryUsage = function() memoryCalls = memoryCalls + 1 end
    env.GetAddOnMemoryUsage = function() return 10 end
    env.CreateFrame = function()
        local frame = {scripts = {}}
        function frame:SetScript(event, callback) self.scripts[event] = callback end
        function frame:Show() self.shown = true end
        function frame:Hide() self.shown = false end
        function frame:IsShown() return self.shown end
        frames[#frames + 1] = frame
        return frame
    end
    env.geterrorhandler = function() return function() end end
    local exported
    local addon = {
        locale = {Get = function(text) return text end},
        settings = {profile = {enableAdaptivePerformance = false,
            enableItemReservations = true, enableRoutePreflight = false,
            enableXPShortfallPredictor = false}},
        comms = {PrettyPrint = function() end,
            OpenBrandedExport = function(_, _, text) exported = text end},
        toolWindows = {SetText = function() end},
    }
    local function load(path)
        local chunk = assert(loadfile(root .. "/" .. path))
        setfenv(chunk, env)("RXPGuides", addon)
    end
    load("Features/PerformanceInspector.lua")
    load("UI/GuideLayout.lua")
    local inspector = addon.performanceInspector
    inspector:StartCapture(5)
    local parent = addon.PerfBegin("main update")
    clock = 2
    now = 0.001 -- time can advance within a single synchronous callback
    local child = addon.PerfBegin("guide localization")
    clock = 5
    addon.PerfEnd("guide localization", child)
    clock = 10
    now = 0.002
    addon.PerfEnd("main update", parent)
    assert(inspector.captureMetrics["main update"].total == 10)
    assert(inspector.captureMetrics["main update"].exclusive == 7)
    assert(inspector.captureMetrics["guide localization"].exclusive == 3)
    assert(#inspector.spans == 0)
    assert(not addon.PerfBegin("untrusted unit name"))
    addon.PerfCount("untrusted unit name")
    assert(not next(inspector.counters))

    local calls = 0
    local fixture = {run = function(...)
        calls = calls + 1
        assert(select("#", ...) == 3)
        return nil, false, 7, nil
    end}
    inspector:Wrap(fixture, "run", "guide parsing")
    inspector:Wrap(fixture, "run", "guide parsing")
    local function checkReturns(...)
        assert(select("#", ...) == 4)
        local a, b, c, d = ...
        assert(a == nil and b == false and c == 7 and d == nil)
    end
    checkReturns(fixture.run(nil, false, nil))
    assert(calls == 1 and inspector.captureMetrics["guide parsing"].calls == 1)
    local ok, err = pcall(addon.PerfInvoke, "bag frame", function()
        addon.PerfBegin("row layout") -- simulate an interrupted explicit scope
        error("fixture error", 0)
    end)
    assert(not ok and err == "fixture error" and #inspector.spans == 0)

    now = 4.99
    local batch = addon.PerfBegin("timer batch")
    local callback = addon.PerfBegin("timer callback")
    now, clock = 5.01, 14
    addon.PerfEnd("timer callback", callback)
    clock = 15
    addon.PerfEnd("timer batch", batch)
    assert(inspector.captureMetrics["timer batch"].total == 5 and
        inspector.captureMetrics["timer callback"].total == 4,
        "a scope crossing the capture deadline lost its parent")

    -- A completed capture must not grow while its UI is open or callbacks run.
    now = 6
    inspector.captureFrame.scripts.OnUpdate(inspector.captureFrame, 0.02)
    assert(not inspector.captureFrame.scripts.OnUpdate)
    addon.PerfInvoke("main update", function() clock = clock + 1 end)
    assert(inspector.captureMetrics["main update"].calls == 1)
    inspector:Export()
    assert(exported:find("self=7.000ms", 1, true))
    assert(exported:find("p95<=", 1, true))
    assert(not exported:find("untrusted", 1, true))
    inspector:ResetMetrics()
    assert(not inspector.captureMetrics and not inspector.captureUntil)
    assert(not addon.PerfBegin("row layout"))

    inspector:StartCapture(5)
    inspector:Sample()
    assert(memoryCalls == 0, "capture called global memory accounting")
    for _ = 1, 1000 do
        inspector.captureFrame.scripts.OnUpdate(inspector.captureFrame, 0.017)
    end
    local histogram = inspector.captureMetrics["observed frame interval"].histogram
    assert(#histogram <= 13, "histogram grew with frame count")
    assert(inspector.captureMetrics["observed frame interval"].calls == 1000)
    for _ = 1, 1000 do
        addon.PerfInvoke("guide parsing", function() end)
    end
    assert(#inspector.spanPool == 1, "capture allocated a span for every call")

    local writes, measures = 0, 0
    local text = {width = 220, font = "fixture", size = 12, flags = "",
                  scale = 1, spacing = 0, height = 20}
    function text:GetFont() return self.font, self.size, self.flags end
    function text:GetWidth() return self.width end
    function text:GetEffectiveScale() return self.scale end
    function text:GetSpacing() return self.spacing end
    function text:GetText() return self.value end
    function text:SetText(value) self.value = value; writes = writes + 1 end
    function text:GetStringHeight() measures = measures + 1; return self.height end
    local layout = addon.guideLayout
    for _ = 1, 500 do assert(layout:MeasureText(text, "Objective 0/5") == 28) end
    assert(writes == 1 and measures == 1, "unchanged rows were remeasured")
    layout:MeasureText(text, "Objective 1/5")
    assert(writes == 2 and measures == 2, "live objective count was frozen")
    assert(layout:MeasureText(text, "Hidden", false, true) == 1)
    assert(measures == 2, "hidden row was unnecessarily measured")
    layout:MeasureText(text, "Objective 1/5")
    for key, value in pairs({width = 100, font = "other", size = 14,
                            flags = "OUTLINE", scale = 1.5, spacing = 2}) do
        local before = measures
        text[key] = value
        layout:MeasureText(text, "Objective 1/5")
        assert(measures == before + 1, "layout did not invalidate " .. key)
    end
    local before = measures
    layout:Invalidate() -- theme or font-object change
    layout:MeasureText(text, "Objective 1/5")
    layout:MeasureText(text, "Objective 1/5", true) -- language/full refresh
    assert(measures == before + 2)
    text.value = "Changed externally"
    layout:MeasureText(text, "Objective 1/5")
    assert(text.value == "Objective 1/5")
    text.GetEffectiveScale = nil
    text.GetParent = function() return {GetEffectiveScale = function() return 2 end} end
    local prior = measures
    layout:MeasureText(text, "Objective 1/5")
    assert(measures == prior + 1, "legacy parent-scale fallback did not invalidate")
    text.height = 0
    assert(layout:MeasureText(text, nil) == 8, "empty text handling changed")

    local row = {height = 28, writes = 0}
    function row:GetHeight() return self.height end
    function row:SetHeight(value) self.height = value; self.writes = self.writes + 1 end
    local positions = {[0] = 84, 28, 56, 84}
    for _ = 1, 500 do layout:UpdateHeight(row, 28, positions, 1) end
    assert(row.writes == 0 and positions[0] == 84 and positions[3] == 84)
    row.height = 28.0000019
    for _ = 1, 500 do layout:UpdateHeight(row, 28, positions, 1) end
    assert(row.writes == 0 and positions[0] == 84 and positions[3] == 84,
        "single-precision client heights caused offset drift")
    layout:UpdateHeight(row, 38, positions, 1)
    assert(row.writes == 1 and positions[0] == 94 and positions[2] == 66)
    layout:UpdateHeight(row, 1, positions, 1)
    assert(positions[0] == 57 and positions[3] == 57, "hidden row offsets changed")

    -- Exercise the real scan, including quantity updates and empty guides.
    env.RXPCData = {currentStep = 1, stepSkip = {}}
    env.GetNumQuestLogEntries = function() return 0 end
    env.GetItemInfo = function() return "Fixture item" end
    local refreshes = 0
    addon.inventoryManager = {RefreshJunkIcons = function() refreshes = refreshes + 1 end}
    load("Features/GuideAnalysis.lua")
    local preflight = addon.routePreflight
    preflight.UpdateBadge, preflight.RefreshWindow = function() end, function() end
    local element = {tag = "collect", id = 100, qty = 3}
    addon.currentGuide = {key = "fixture", steps = {{index = 1, elements = {element}}}}
    preflight:Scan()
    for _ = 1, 100 do preflight:Scan() end
    assert(refreshes == 1, "unchanged reservation scans refreshed overlays")
    element.qty = 5
    preflight:Scan()
    local reserved, quantity = preflight:IsItemReserved(100)
    assert(reserved and quantity == 5 and refreshes == 1, "reservation quantity was frozen")
    element.id = 101
    preflight:Scan()
    assert(refreshes == 2 and not preflight:IsItemReserved(100))
    addon.settings.profile.enableItemReservations = false
    preflight:Scan()
    assert(refreshes == 3 and not preflight:IsItemReserved(101))
    addon.settings.profile.enableItemReservations = true
    preflight:Scan()
    assert(refreshes == 4 and preflight:IsItemReserved(101))
    addon.currentGuide = {empty = true}
    preflight:Scan()
    preflight:Scan()
    assert(refreshes == 5 and not preflight:IsItemReserved(101))

    -- Capture must not change the private timer's next-dispatch barrier.
    load("Compat/TimerFacade335.lua")
    local driver = frames[#frames]
    local first, nested, afterError = 0, 0, 0
    addon.timerAPI335.After(0, function()
        first = first + 1
        addon.timerAPI335.After(0, function() nested = nested + 1 end)
    end)
    driver.scripts.OnUpdate(driver)
    assert(first == 1 and nested == 0)
    driver.scripts.OnUpdate(driver)
    assert(nested == 1)
    addon.timerAPI335.After(0, function() error("timer fixture", 0) end)
    addon.timerAPI335.After(0, function() afterError = afterError + 1 end)
    driver.scripts.OnUpdate(driver)
    assert(afterError == 1 and #inspector.spans == 0)
    assert(inspector.captureMetrics["timer batch"].calls == 3)
    inspector:ResetMetrics()
    assert(not inspector.captureFrame.scripts.OnUpdate)
    print("Performance regressions passed: 500 unchanged row refreshes -> 1 measurement; 101 unchanged reservation scans -> 1 overlay refresh.")
end
