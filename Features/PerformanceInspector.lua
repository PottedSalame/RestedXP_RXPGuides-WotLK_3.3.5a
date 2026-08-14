local addonName, addon = ...

local _G = _G
local format = string.format
local L = addon.locale.Get
local floor, max, min = math.floor, math.max, math.min
local tinsert = table.insert
local unpack = unpack
local toolWindows = addon.toolWindows

addon.performanceInspector = addon.performanceInspector or {}
local inspector = addon.performanceInspector

local function Clock()
    return type(_G.debugprofilestop) == "function" and _G.debugprofilestop() or
               _G.GetTime() * 1000
end

function addon.PerfBegin(name)
    local service = addon.performanceInspector
    if not (service and service:IsMeasuring()) then return end
    return Clock()
end

function addon.PerfEnd(name, started)
    if not started then return end
    local service = addon.performanceInspector
    if service then service:Record(name, max(0, Clock() - started)) end
end

function inspector:IsMeasuring()
    return self.captureUntil ~= nil or self.adaptiveActive or
        (self.frame and self.frame:IsShown()) or
        (addon.settings and addon.settings.profile.enableAdaptivePerformance)
end

function inspector:Record(name, milliseconds)
    if type(name) ~= "string" then return end
    milliseconds = tonumber(milliseconds)
    if not milliseconds or milliseconds < 0 or milliseconds > 60000 then return end
    self.metrics = self.metrics or {}
    local metric = self.metrics[name]
    if not metric then
        metric = {calls = 0, total = 0, maximum = 0, last = 0}
        self.metrics[name] = metric
    end
    metric.calls = metric.calls + 1
    metric.total = metric.total + milliseconds
    metric.maximum = max(metric.maximum, milliseconds)
    metric.last = milliseconds
    metric.updated = _G.GetTime()
end

function inspector:ResetMetrics()
    self.metrics = {}
    self.captureStarted = _G.GetTime()
    self.fpsSamples = {}
    self:Refresh()
end

function inspector:StartCapture(seconds)
    seconds = max(5, min(120, floor(tonumber(seconds) or 30)))
    self:ResetMetrics()
    self.captureUntil = _G.GetTime() + seconds
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
    local wantsMemory = self.captureUntil or (self.frame and self.frame:IsShown())
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
        for _, metric in pairs(self.metrics or {}) do
            if _G.GetTime() - (tonumber(metric.updated) or 0) < 2 and
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

local function Wrap(container, key, label)
    if type(container) ~= "table" or type(container[key]) ~= "function" then return end
    inspector.wrapped = inspector.wrapped or {}
    local token = tostring(container) .. ":" .. key
    if inspector.wrapped[token] then return end
    local original = container[key]
    local function Pack(...)
        return {n = select("#", ...), ...}
    end
    container[key] = function(...)
        local started = addon.PerfBegin(label)
        if not started then return original(...) end
        local results = Pack(original(...))
        addon.PerfEnd(label, started)
        return unpack(results, 1, results.n)
    end
    inspector.wrapped[token] = true
end

function inspector:InstallInstrumentation()
    Wrap(addon, "UpdateMap", "map refresh")
    Wrap(addon, "LegacyUpdateLoop", "main update")
    Wrap(addon.targeting, "LegacyScanTick", "nameplate scan")
    Wrap(addon.inventoryManager, "UpdateAllBags", "bag overlays")
    Wrap(addon.itemUpgrades, "ScanBagUpgrades", "upgrade scan")
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
    local names = {}
    for name in pairs(self.metrics or {}) do tinsert(names, name) end
    table.sort(names)
    if #names == 0 then
        tinsert(lines, "  " .. L("Open this window or start a capture to collect measurements."))
    end
    for _, name in ipairs(names) do
        local metric = self.metrics[name]
        tinsert(lines, format("[*] %s", name))
        tinsert(lines, format(L("    Calls: %d  Average: %.3f ms  Maximum: %.3f ms  Last: %.3f ms"),
            metric.calls,
            metric.calls > 0 and metric.total / metric.calls or 0,
            metric.maximum, metric.last))
    end
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
    local lines = {
        "RXPGuides sanitized performance report",
        "Addon: " .. tostring(addon.release),
        "Client: " .. tostring(select(1, GetBuildInfo())),
        "FPS: " .. format("%.1f", tonumber(self.lastFPS) or 0),
        "MemoryKB: " .. format("%.1f", tonumber(self.memoryKB) or 0),
        "Tickers: " .. tostring(CountTickers()), ""
    }
    local names = {}
    for name in pairs(self.metrics or {}) do tinsert(names, name) end
    table.sort(names)
    for _, name in ipairs(names) do
        local metric = self.metrics[name]
        tinsert(lines, format("%s calls=%d avg=%.3fms max=%.3fms last=%.3fms",
            name, metric.calls, metric.calls > 0 and metric.total / metric.calls or 0,
            metric.maximum, metric.last))
    end
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
