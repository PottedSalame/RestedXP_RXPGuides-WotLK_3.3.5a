local addonName, addon = ...

local _G = _G
local C_Timer = addon.timer
local format = string.format
local L = addon.locale.Get
local floor, max, min = math.floor, math.max, math.min
local tinsert = table.insert
local toolWindows = addon.toolWindows
local HISTOGRAM = {0.1, 0.5, 1, 2, 4, 8, 16, 33, 50, 100, 250, 1000, 60000}
local MAX_METRICS = 64
-- Code-owned labels only: never quest, item, unit or player data.
local COUNTERS = {
    ["bag buttons"] = true, ["item cache misses"] = true,
    ["row text writes"] = true, ["row measurements"] = true,
    ["row measurement hits"] = true, ["row positions shifted"] = true,
    ["row height changes"] = true, ["map rebuilds"] = true,
    ["world map pins"] = true, ["world map lines"] = true,
    ["minimap pins"] = true,
    ["line tile redraws"] = true, ["line tile placements"] = true,
    ["line tiles created"] = true,
    ["reservation refreshes"] = true, ["reservation refreshes avoided"] = true,
    ["nameplate children"] = true, ["timer callbacks due"] = true,
}
local LABELS = {
    ["main update"] = true, ["map refresh"] = true, ["guide parsing"] = true,
    ["map reset"] = true, ["map lines"] = true, ["map world pins"] = true,
    ["map minimap pins"] = true, ["map arrow"] = true, ["map visibility"] = true,
    ["directive evaluation"] = true, ["guide rows"] = true,
    ["current step text"] = true, ["guide localization"] = true,
    ["row layout"] = true, ["bag overlays"] = true, ["bag frame"] = true,
    ["item data"] = true, ["equipment comparison"] = true,
    ["upgrade scan"] = true, ["route preflight"] = true,
    ["nameplate scan"] = true, ["nameplate discovery"] = true,
    ["timer batch"] = true, ["timer callback"] = true, ["speedrun grind scan"] = true,
    ["speedrun pit-stop scan"] = true, ["speedrun route scan"] = true,
    ["speedrun deathwarp scan"] = true,
}
local COARSE = {
    ["main update"] = true, ["map refresh"] = true,
    ["nameplate scan"] = true, ["bag overlays"] = true,
    ["upgrade scan"] = true, ["route preflight"] = true,
    ["speedrun grind scan"] = true, ["speedrun pit-stop scan"] = true,
    ["speedrun route scan"] = true, ["speedrun deathwarp scan"] = true,
}

addon.performanceInspector = addon.performanceInspector or {}
local inspector = addon.performanceInspector

local function Clock()
    return type(_G.debugprofilestop) == "function" and _G.debugprofilestop() or
               _G.GetTime() * 1000
end

function addon.PerfBegin(name)
    local service = addon.performanceInspector
    if not LABELS[name] then return end
    if not (service and service:IsMeasuring()) then return end
    if not COARSE[name] and not service:IsCapturing() then return end
    if service:IsCapturing() then
        local stack = service.spans
        if #stack >= 64 then return end
        local depth = #stack + 1
        local span = service.spanPool[depth]
        if not span then
            span = {}
            service.spanPool[depth] = span
        end
        span.started, span.child = Clock(), 0
        span.generation = service.captureGeneration
        stack[depth] = span
        return span
    end
    return Clock()
end

function addon.PerfEnd(name, started)
    if not started then return end
    local service = addon.performanceInspector
    if not service then return end
    if type(started) == "table" then
        if started.generation ~= service.captureGeneration then return end
        local stack = service.spans
        -- Unwind an explicitly instrumented child whose error bypassed End.
        while #stack > 0 and stack[#stack] ~= started do stack[#stack] = nil end
        if #stack == 0 then return end
        stack[#stack] = nil
        local elapsed = max(0, Clock() - started.started)
        if stack[#stack] then stack[#stack].child = stack[#stack].child + elapsed end
        service:Record(name, elapsed, max(0, elapsed - started.child), true)
    else
        service:Record(name, max(0, Clock() - started))
    end
end

function inspector:IsCapturing()
    return self.captureUntil and _G.GetTime() < self.captureUntil
end

function addon.PerfCount(name, amount)
    if not COUNTERS[name] or not inspector:IsCapturing() then return end
    inspector.counters[name] = (inspector.counters[name] or 0) + (amount or 1)
end

-- Use this at local call sites which a public function wrapper cannot reach.
-- Preserve nil/multiple returns and unwind capture scopes before rethrowing.
local function FinishCall(label, started, ok, ...)
    addon.PerfEnd(label, started)
    if not ok then error((...), 0) end
    return ...
end

function addon.PerfInvoke(label, callback, ...)
    local started = addon.PerfBegin(label)
    if not started then return callback(...) end
    return FinishCall(label, started, pcall(callback, ...))
end

function inspector:IsMeasuring()
    return self.captureUntil ~= nil or self.adaptiveActive or
        (self.frame and self.frame:IsShown()) or
        (addon.settings and addon.settings.profile.enableAdaptivePerformance)
end

local function RecordMetric(metrics, name, milliseconds, exclusive, detailed)
    local metric = metrics[name]
    if not metric then
        local count = 0
        for _ in pairs(metrics) do count = count + 1 end
        if count >= MAX_METRICS then return end
        metric = {calls = 0, total = 0, maximum = 0, last = 0,
                  exclusive = 0, histogram = detailed and {} or nil}
        metrics[name] = metric
    end
    metric.calls = metric.calls + 1
    metric.total = metric.total + milliseconds
    metric.exclusive = metric.exclusive + (exclusive or milliseconds)
    metric.maximum = max(metric.maximum, milliseconds)
    metric.last = milliseconds
    metric.updated = _G.GetTime()
    if metric.histogram then
        for index, bound in ipairs(HISTOGRAM) do
            if milliseconds <= bound then
                metric.histogram[index] = (metric.histogram[index] or 0) + 1
                break
            end
        end
    end
end

function inspector:Record(name, milliseconds, exclusive, detailed)
    if not LABELS[name] then return end
    milliseconds = tonumber(milliseconds)
    if not milliseconds or milliseconds < 0 or milliseconds > 60000 then return end
    self.metrics = self.metrics or {}
    RecordMetric(self.metrics, name, milliseconds, exclusive)
    -- Include a scope that began inside the capture but finished just past its
    -- deadline. Dropping its parent would make child totals exceed the batch.
    if detailed and self.captureMetrics then
        RecordMetric(self.captureMetrics, name, milliseconds, exclusive, true)
    end
end

local function Percentile95(metric)
    local count = 0
    for index, bound in ipairs(HISTOGRAM) do
        count = count + ((metric.histogram or {})[index] or 0)
        if count >= metric.calls * 0.95 then return bound end
    end
    return metric.maximum
end

function inspector:ResetMetrics()
    self.metrics = {}
    self.captureMetrics, self.captureUntil, self.captureStarted = nil, nil, nil
    self.spans, self.spanPool, self.counters = {}, {}, {}
    self.captureGeneration = (self.captureGeneration or 0) + 1
    if self.captureFrame then self.captureFrame:SetScript("OnUpdate", nil) end
    self.fpsSamples = {}
    self:Refresh()
end

function inspector:StartCapture(seconds)
    seconds = max(5, min(120, floor(tonumber(seconds) or 30)))
    self:ResetMetrics()
    self.captureStarted = _G.GetTime()
    self.captureMetrics = {}
    self.captureUntil = _G.GetTime() + seconds
    self.captureDuration = seconds
    self.captureLastFPS = type(_G.GetFramerate) == "function" and _G.GetFramerate() or 0
    self.captureMemoryKB = self.memoryKB
    self.captureAdaptationChanged = false
    self.captureAdaptive = addon.settings and
        addon.settings.profile.enableAdaptivePerformance == true or false
    self.captureAdapted = self.adaptiveActive == true
    if not self.captureFrame then self.captureFrame = CreateFrame("Frame") end
    self.captureFrame:SetScript("OnUpdate", function(_, elapsed)
        -- A clock tick is not a call-stack boundary: GetTime can change inside
        -- a long synchronous callback. Only discard orphaned scopes once the
        -- client returns here between dispatches, never inside PerfBegin.
        for i = #inspector.spans, 1, -1 do inspector.spans[i] = nil end
        if not inspector:IsCapturing() then
            inspector.captureFrame:SetScript("OnUpdate", nil)
            return
        end
        -- Whole-client frame duration, not time attributed to RXPGuides.
        RecordMetric(inspector.captureMetrics, "observed frame interval",
                     max(0, elapsed * 1000), 0, true)
    end)
    addon.comms.PrettyPrint("Performance capture started for %d seconds.", seconds)
end

local function CountTickers()
    local count = 0
    for _, ticker in pairs(addon.tickers or {}) do
        if type(ticker) == "table" and ticker.Cancel then count = count + 1 end
    end
    if addon.targeting then
        if addon.targeting.legacyTicker then count = count + 1 end
        if addon.targeting.ticker then count = count + 1 end
    end
    return count
end

function inspector:GetEffectiveUpdateFrequency(baseMilliseconds)
    baseMilliseconds = tonumber(baseMilliseconds) or 75
    if not self.adaptiveActive then return baseMilliseconds end
    return min(150, max(baseMilliseconds, floor(baseMilliseconds * 1.75 + 0.5)))
end

function addon.GetEffectiveUpdateFrequency(baseMilliseconds)
    return inspector:GetEffectiveUpdateFrequency(baseMilliseconds)
end

function inspector:SetAdapted(enabled, reason)
    enabled = enabled == true
    if (self.adaptiveActive == true) == enabled then return end
    if self:IsCapturing() then self.captureAdaptationChanged = true end
    self.adaptiveActive = enabled
    self.adaptiveReason = enabled and (reason or "sustained load") or nil
    if addon.tickers and addon.tickers.RestartTickerLoops then
        addon.tickers:RestartTickerLoops()
    end
    if addon.targeting and addon.targeting.RefreshScanTicker then
        addon.targeting:RefreshScanTicker()
    end
    if addon.routePreflight then addon.routePreflight:ScheduleScan(0.2) end
    addon.comms.PrettyPrint(enabled and
        "Adaptive performance mode engaged temporarily (%s)." or
        "Adaptive performance mode restored normal update rates.",
        reason or "performance recovered")
    self:Refresh()
end

function inspector:Sample()
    local fps = type(_G.GetFramerate) == "function" and _G.GetFramerate() or 0
    self.lastFPS = fps
    if self:IsCapturing() then self.captureLastFPS = fps end
    -- Global memory accounting can stall a frame. Keep the last-known reading
    -- during captures rather than introducing this cost into the measurement.
    local wantsMemory = not self.captureUntil and (self.frame and self.frame:IsShown())
    if wantsMemory and
        _G.GetTime() - (self.lastMemorySample or 0) >= 5 and
        type(_G.UpdateAddOnMemoryUsage) == "function" and
        type(_G.GetAddOnMemoryUsage) == "function" then
        self.lastMemorySample = _G.GetTime()
        pcall(_G.UpdateAddOnMemoryUsage)
        local ok, memory = pcall(_G.GetAddOnMemoryUsage,
                                 self.addonIndex or addonName)
        if ok then self.memoryKB = tonumber(memory) end
    end
    self.fpsSamples = self.fpsSamples or {}
    tinsert(self.fpsSamples, fps)
    while #self.fpsSamples > 60 do table.remove(self.fpsSamples, 1) end

    if self.captureUntil and _G.GetTime() >= self.captureUntil then
        self.captureUntil = nil
        addon.comms.PrettyPrint("Performance capture complete. Use /rxp perf to review it.")
    end

    local profile = addon.settings and addon.settings.profile
    if profile and profile.enableAdaptivePerformance then
        local threshold = max(15, min(60,
            tonumber(profile.adaptivePerformanceFPSThreshold) or 25))
        local highWork
        for name, metric in pairs(self.metrics or {}) do
            if COARSE[name] and _G.GetTime() - (tonumber(metric.updated) or 0) < 2 and
                (tonumber(metric.last) or 0) > 12 then highWork = true break end
        end
        if (fps > 0 and fps < threshold) or highWork then
            self.lowSamples = (self.lowSamples or 0) + 1
            self.healthySamples = 0
        else
            self.healthySamples = (self.healthySamples or 0) + 1
            self.lowSamples = 0
        end
        if not self.adaptiveActive and (self.lowSamples or 0) >= 5 then
            self:SetAdapted(true, highWork and "RXP work above 12 ms" or
                                format("FPS below %d", threshold))
        elseif self.adaptiveActive and (self.healthySamples or 0) >= 10 then
            self:SetAdapted(false, "performance recovered")
        end
    elseif self.adaptiveActive then
        self:SetAdapted(false, "adaptation disabled")
    end
    self:Refresh()
end

function inspector:Wrap(container, key, label)
    if type(container) ~= "table" or type(container[key]) ~= "function" then return end
    inspector.wrapped = inspector.wrapped or {}
    local token = tostring(container) .. ":" .. key
    if inspector.wrapped[token] then return end
    local original = container[key]
    container[key] = function(...)
        return addon.PerfInvoke(label, original, ...)
    end
    inspector.wrapped[token] = true
end

function inspector:InstallInstrumentation()
    self:Wrap(addon, "UpdateMap", "map refresh")
    self:Wrap(addon, "LegacyUpdateLoop", "main update")
    self:Wrap(addon, "ParseGuide", "guide parsing")
    self:Wrap(addon, "Call", "directive evaluation")
    self:Wrap(addon.targeting, "LegacyScanTick", "nameplate scan")
    self:Wrap(addon.targeting, "DiscoverLegacyNameplates", "nameplate discovery")
    self:Wrap(addon.itemUpgrades, "ScanBagUpgrades", "upgrade scan")
    self:Wrap(addon.itemUpgrades, "GetItemData", "item data")
    self:Wrap(addon.itemUpgrades, "GetBestUpgradeComparison", "equipment comparison")
    self:Wrap(addon.guideLocalization, "Render", "guide localization")
    self:Wrap(addon.guideLayout, "MeasureText", "row layout")
    local frame = addon.RXPFrame
    if frame then
        self:Wrap(frame.BottomFrame, "UpdateFrame", "guide rows")
        self:Wrap(frame.CurrentStepFrame, "UpdateText", "current step text")
    end
end

function inspector:AppendMeasurements(lines, localized)
    local metrics = self.captureMetrics or self.metrics or {}
    local names = {}
    for name in pairs(metrics) do tinsert(names, name) end
    table.sort(names)
    if self.captureMetrics then
        tinsert(lines, format("Capture: %ds; adaptive configured=%s active-at-start=%s",
            self.captureDuration or 0, tostring(self.captureAdaptive),
            tostring(self.captureAdapted)))
        tinsert(lines, "Adaptation changed during capture: " .. tostring(self.captureAdaptationChanged))
        tinsert(lines, localized and L("Self time excludes measured child calls. Do not add inclusive totals together. Frame intervals measure the whole client, not just RXPGuides.") or
            "Self excludes measured children; inclusive totals overlap. Frame intervals are whole-client time.")
    end
    for _, name in ipairs(names) do
        local metric = metrics[name]
        tinsert(lines, format("%s calls=%d avg=%.3fms max=%.3fms last=%.3fms",
            name, metric.calls, metric.total / max(1, metric.calls),
            metric.maximum, metric.last))
        if metric.histogram then
            tinsert(lines, format("  inclusive=%.3fms self=%.3fms p95<=%.1fms",
                metric.total, metric.exclusive, Percentile95(metric)))
        end
    end
    local counters = {}
    for name in pairs(self.counters or {}) do tinsert(counters, name) end
    table.sort(counters)
    for _, name in ipairs(counters) do
        tinsert(lines, format("%s: %d", name, self.counters[name]))
    end
end

function inspector:BuildText()
    local profile = addon.settings and addon.settings.profile or {}
    local effective = self:GetEffectiveUpdateFrequency(profile.updateFrequency or 75)
    local lines = {
        L("Current status"),
        format(L("FPS: %.1f"), tonumber(self.lastFPS) or 0),
        format(L("Main update: %d ms configured / %d ms effective"),
               tonumber(profile.updateFrequency) or 75, effective),
        format(L("Known active ticker loops: %d"), CountTickers()),
        format(L("Addon memory: %.1f MB"), (tonumber(self.memoryKB) or 0) / 1024),
        format(L("Adaptive mode: %s%s"),
            profile.enableAdaptivePerformance and L("enabled") or L("disabled"),
            self.adaptiveActive and (" (active: " .. tostring(self.adaptiveReason) .. ")") or ""),
        self.captureUntil and format(L("Capture: %.0f seconds remaining"),
                                     max(0, self.captureUntil - _G.GetTime())) or
            L("Capture: idle"),
        "",
        L("Measured RXPGuides work:")
    }
    if not next(self.captureMetrics or self.metrics or {}) then
        tinsert(lines, "  " .. L("Open this window or start a capture to collect measurements."))
    end
    self:AppendMeasurements(lines, true)
    tinsert(lines, L("Captures are frozen when complete. Memory is last-known and is not sampled during captures. For comparisons, disable adaptive performance and repeat the same actions."))
    tinsert(lines, "")
    tinsert(lines, L("Adaptation never changes saved preferences. It only slows bounded RXP scan/update loops while sustained low FPS is observed, then restores them automatically."))
    return table.concat(lines, "\n")
end

function inspector:Refresh()
    local frame = self.frame
    if not (frame and frame:IsShown()) then return end
    toolWindows:SetText(frame, self:BuildText())
    if frame.captureButton then
        frame.captureButton:SetText(self.captureUntil and L("Capturing...") or
                                        L("Capture 30s"))
        toolWindows:SizeButton(frame.captureButton, 105, 150)
        if self.captureUntil then frame.captureButton:Disable()
        else frame.captureButton:Enable() end
    end
end

function inspector:Export()
    local fps = self.captureMetrics and self.captureLastFPS or self.lastFPS
    local memory = self.memoryKB
    if self.captureMetrics then memory = self.captureMemoryKB end
    local lines = {
        "RXPGuides sanitized performance report",
        "Addon: " .. tostring(addon.release),
        "Client: " .. tostring(select(1, GetBuildInfo())),
        "FPS: " .. format("%.1f", tonumber(fps) or 0),
        "LastKnownMemoryKB: " .. (memory and format("%.1f", memory) or "not sampled"),
        "Tickers: " .. tostring(CountTickers()), ""
    }
    self:AppendMeasurements(lines, false)
    addon.comms.OpenBrandedExport(L("Performance Report"),
        L("No player, realm, chat, account, or GUID data is included."),
        table.concat(lines, "\n"), 620, 420)
end

function inspector:CreateWindow()
    local frame = toolWindows:Create({
        name = "RXPPerformanceInspector",
        title = L("RXPGuides Performance Inspector"),
        width = 690,
        height = 450,
        minWidth = 520,
        minHeight = 340
    })
    toolWindows:AddScrollingText(frame, {
        name = "RXPPerformanceInspectorScroll",
        top = 48,
        bottom = 56
    })
    local capture = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    capture:SetHeight(24)
    capture:SetPoint("BOTTOMLEFT", 20, 18)
    capture:SetText(L("Capture 30s"))
    toolWindows:SizeButton(capture, 105, 150)
    capture:SetScript("OnClick", function() inspector:StartCapture(30) end)
    frame.captureButton = capture
    local reset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    reset:SetHeight(24)
    reset:SetPoint("LEFT", capture, "RIGHT", 8, 0)
    reset:SetText(L("Reset"))
    toolWindows:SizeButton(reset, 92, 140)
    reset:SetScript("OnClick", function() inspector:ResetMetrics() end)
    local export = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    export:SetHeight(24)
    export:SetPoint("LEFT", reset, "RIGHT", 8, 0)
    export:SetText(L("Export"))
    toolWindows:SizeButton(export, 92, 140)
    export:SetScript("OnClick", function() inspector:Export() end)
    frame:SetScript("OnShow", function() inspector:Refresh() end)
    self.frame = frame
    self:Refresh()
end

function inspector:Toggle()
    if not self.frame then self:CreateWindow() end
    if self.frame:IsShown() then self.frame:Hide() else self.frame:Show() end
end

function inspector:Setup()
    if self.setup then return end
    self.setup = true
    self.metrics = {}
    if type(_G.GetNumAddOns) == "function" and type(_G.GetAddOnInfo) == "function" then
        for index = 1, _G.GetNumAddOns() do
            if _G.GetAddOnInfo(index) == addonName then
                self.addonIndex = index
                break
            end
        end
    end
    self:InstallInstrumentation()
    self.sampleTicker = C_Timer.NewTicker(1, function() inspector:Sample() end)
end
