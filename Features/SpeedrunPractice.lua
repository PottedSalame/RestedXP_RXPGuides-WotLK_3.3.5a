local _, addon = ...

-- Segment Practice Lab.  Practice is a shadow timing view: it never changes
-- RXPCData.currentStep, guide checkpoints, skip flags, completed waypoints,
-- automation frames, the active arrow, or Active Targets.

local _G = _G
local format = string.format
local floor, max, min = math.floor, math.max, math.min
local tinsert, tremove = table.insert, table.remove
local L = addon.locale.Get
local toolWindows = addon.toolWindows
local OWNER = "speedrun-practice"

addon.speedrunPractice = addon.speedrunPractice or {}
local practice = addon.speedrunPractice

local function Profile()
    return addon.settings and addon.settings.profile or {}
end

local function Enabled()
    return Profile().enableSpeedrunSuite ~= false and
               Profile().enableSpeedrunPractice == true
end

local function GuideKey()
    local guide = addon.currentGuide
    if type(guide) ~= "table" or guide.empty then return end
    return guide.key or (addon.BuildGuideKey and addon.BuildGuideKey(guide))
end

local function StableStep(index)
    local guide = addon.currentGuide
    local step = guide and guide.steps and guide.steps[index]
    if not step then return end
    return {id = step.stepId, index = tonumber(step.index) or index,
            text = step.text or (step.elements and step.elements[1] and
                                      step.elements[1].text)}
end

local function Store()
    local practiceStore
    if addon.speedrun and addon.speedrun.EnsureStores then
        local store = addon.speedrun:EnsureStores()
        practiceStore = store.practice
    else
        RXPData.speedrun = type(RXPData.speedrun) == "table" and RXPData.speedrun or {}
        RXPData.speedrun.practice = type(RXPData.speedrun.practice) == "table" and
                                        RXPData.speedrun.practice or
                                        {definitions = {}, attempts = {}}
        RXPData.speedrun.practice.definitions =
            type(RXPData.speedrun.practice.definitions) == "table" and
                RXPData.speedrun.practice.definitions or {}
        RXPData.speedrun.practice.attempts =
            type(RXPData.speedrun.practice.attempts) == "table" and
                RXPData.speedrun.practice.attempts or {}
        practiceStore = RXPData.speedrun.practice
    end
    for index = #practiceStore.definitions, 1, -1 do
        if type(practiceStore.definitions[index]) ~= "table" then
            tremove(practiceStore.definitions, index)
        end
    end
    while #practiceStore.definitions > 20 do
        tremove(practiceStore.definitions)
    end
    for id, attempts in pairs(practiceStore.attempts) do
        if type(id) ~= "string" or type(attempts) ~= "table" then
            practiceStore.attempts[id] = nil
        else
            for index = #attempts, 1, -1 do
                local attempt = attempts[index]
                if type(attempt) ~= "table" or
                    type(tonumber(attempt.duration)) ~= "number" then
                    tremove(attempts, index)
                end
            end
            while #attempts > 50 do tremove(attempts, 1) end
        end
    end
    return practiceStore
end

local function CopyState(value, depth, seen)
    local kind = type(value)
    if kind == "number" or kind == "string" or kind == "boolean" then return value end
    if kind ~= "table" or (depth or 0) > 8 then return nil end
    seen = seen or {}
    if seen[value] then return nil end
    seen[value] = true
    local result = {}
    for key, child in pairs(value) do
        local cleanKey = CopyState(key, (depth or 0) + 1, seen)
        local cleanValue = CopyState(child, (depth or 0) + 1, seen)
        if cleanKey ~= nil and cleanValue ~= nil then result[cleanKey] = cleanValue end
    end
    seen[value] = nil
    return result
end

local function Session()
    if addon.speedrun and addon.speedrun.EnsureStores then
        local _, session = addon.speedrun:EnsureStores()
        return session
    end
    RXPCData.speedrunSession = type(RXPCData.speedrunSession) == "table" and
                                   RXPCData.speedrunSession or {}
    return RXPCData.speedrunSession
end

function practice:CaptureRealState()
    local guide = addon.currentGuide
    if type(guide) ~= "table" or guide.empty then return end
    Session().practiceRestore = {
        guideGroup = guide.group,
        guideName = guide.name,
        currentStep = tonumber(RXPCData.currentStep) or 1,
        currentStepId = RXPCData.currentStepId,
        stepSkip = CopyState(RXPCData.stepSkip or {}, 0),
        completedWaypoints = CopyState(RXPCData.completedWaypoints or {}, 0),
        guideProgress = CopyState(RXPCData.guideProgress or {}, 0),
        browseMode = addon.browseMode == true
    }
end

function practice:RestoreRealState()
    local session = Session()
    local snapshot = session.practiceRestore
    if type(snapshot) ~= "table" then
        if addon.SetBrowseMode then
            addon.SetBrowseMode(self.previousBrowseMode == true, true)
        end
        return
    end
    RXPCData.guideProgress = CopyState(snapshot.guideProgress or {}, 0)
    RXPCData.currentGuideGroup = snapshot.guideGroup
    RXPCData.currentGuideName = snapshot.guideName
    RXPCData.currentStep = tonumber(snapshot.currentStep) or 1
    RXPCData.currentStepId = snapshot.currentStepId
    RXPCData.stepSkip = CopyState(snapshot.stepSkip or {}, 0)
    RXPCData.completedWaypoints = CopyState(snapshot.completedWaypoints or {}, 0)
    local guide = addon.GetGuideTable and
                      addon.GetGuideTable(snapshot.guideGroup, snapshot.guideName)
    if guide and addon.LoadGuide then
        local ok, errorText = pcall(addon.LoadGuide, addon, guide, true,
                                    "practice-restore")
        if not ok and _G.geterrorhandler then _G.geterrorhandler()(errorText) end
    end
    if addon.SetBrowseMode then
        addon.SetBrowseMode(snapshot.browseMode == true, true)
    end
    session.practiceRestore = nil
end

local function DefinitionId(definition)
    return table.concat({definition.guideKey or "", tostring(definition.startId or
        definition.startIndex), tostring(definition.endId or definition.endIndex)}, "\031")
end

local function Duration(value)
    value = max(0, tonumber(value) or 0)
    local tenths = floor(value * 10 + 0.5)
    return format("%d:%02d.%d", floor(tenths / 600), floor(tenths / 10) % 60,
                  tenths % 10)
end

local function Median(values)
    if #values == 0 then return end
    table.sort(values)
    local n = #values
    if n % 2 == 1 then return values[(n + 1) / 2] end
    return (values[n / 2] + values[n / 2 + 1]) / 2
end

function practice:GetElapsed()
    local state = self.state
    if not state then return 0 end
    local elapsed = tonumber(state.elapsed) or 0
    if state.running and state.started then elapsed = elapsed + GetTime() - state.started end
    return max(0, elapsed)
end

function practice:SaveDefinition(definition)
    local store = Store()
    definition.id = DefinitionId(definition)
    definition.updatedAt = _G.time()
    local found
    for index, existing in ipairs(store.definitions) do
        if existing.id == definition.id then
            store.definitions[index] = definition
            found = true
            break
        end
    end
    if not found then tinsert(store.definitions, definition) end
    table.sort(store.definitions, function(a, b)
        return (tonumber(a.updatedAt) or 0) > (tonumber(b.updatedAt) or 0)
    end)
    while #store.definitions > 20 do tremove(store.definitions) end
    self.definition = definition
end

function practice:SelectDefinition(direction)
    if self.state then return end
    local guideKey = GuideKey()
    local definitions = {}
    for _, definition in ipairs(Store().definitions) do
        if definition.guideKey == guideKey then
            definitions[#definitions + 1] = definition
        end
    end
    if #definitions == 0 then
        self.definition = nil
        self:Refresh()
        return
    end
    local position = 0
    for index, definition in ipairs(definitions) do
        if definition.id == (self.definition and self.definition.id) then
            position = index
            break
        end
    end
    if position == 0 then
        position = direction and direction < 0 and #definitions or 1
    else
        position = ((position - 1 + (tonumber(direction) or 1)) %
                        #definitions) + 1
    end
    self.definition = definitions[position]
    self:Refresh()
end

function practice:SetBoundary(which)
    if self.state then return end
    local key = GuideKey()
    local index = tonumber(RXPCData.currentStep)
    local step = index and StableStep(index)
    if not key or not step then return end
    local definition = self.definition
    if type(definition) ~= "table" or definition.guideKey ~= key then
        definition = {guideKey = key, startIndex = index, startId = step.id,
                      endIndex = min(#addon.currentGuide.steps, index + 1)}
    end
    if which == "start" then
        definition.startIndex, definition.startId = index, step.id
        if (tonumber(definition.endIndex) or 0) <= index then
            definition.endIndex = min(#addon.currentGuide.steps, index + 1)
            local ending = StableStep(definition.endIndex)
            definition.endId = ending and ending.id
        end
    else
        definition.endIndex, definition.endId = index, step.id
        if (tonumber(definition.startIndex) or index) >= index then
            definition.startIndex = max(1, index - 1)
            local starting = StableStep(definition.startIndex)
            definition.startId = starting and starting.id
        end
    end
    self:SaveDefinition(definition)
    self:Refresh()
end

function practice:Start()
    if not Enabled() or self.state then return end
    local guideKey = GuideKey()
    if not guideKey or not addon.currentGuide or
        type(addon.currentGuide.steps) ~= "table" or
        #addon.currentGuide.steps == 0 then return end
    local definition = self.definition
    if type(definition) ~= "table" or definition.guideKey ~= guideKey then
        local index = tonumber(RXPCData.currentStep) or 1
        local ending = min(#addon.currentGuide.steps, index + 1)
        definition = {guideKey = guideKey, startIndex = index,
                      startId = StableStep(index) and StableStep(index).id,
                      endIndex = ending,
                      endId = StableStep(ending) and StableStep(ending).id}
        self:SaveDefinition(definition)
    end
    self:CaptureRealState()
    self.state = {definition = definition, running = true, started = GetTime(),
                  elapsed = 0, splits = {}, notes = {}, shadow = true}
    self.previousBrowseMode = addon.browseMode == true
    addon.speedrunPracticeActive = true
    if addon.speedrun and addon.speedrun.PauseActive then
        addon.speedrun:PauseActive(false)
    end
    if addon.SetBrowseMode then addon.SetBrowseMode(true, true) end
    addon:SendEvent("RXP_SPEEDRUN_PRACTICE_STATE", "started", definition.id)
    if addon.speedrunAudio then addon.speedrunAudio:Play("pace") end
    self:ScheduleRefresh()
    self:Refresh()
end

function practice:Pause()
    local state = self.state
    if not state then return end
    if state.running then
        state.elapsed = self:GetElapsed()
        state.started = nil
        state.running = false
    else
        state.running = true
        state.started = GetTime()
    end
    self:ScheduleRefresh()
    self:Refresh()
end

function practice:Split(label)
    local state = self.state
    if not state then return end
    local elapsed = self:GetElapsed()
    local previous = state.splits[#state.splits]
    tinsert(state.splits, {elapsed = elapsed,
        duration = elapsed - (previous and previous.elapsed or 0),
        label = type(label) == "string" and label or
                    format("Split %d", #state.splits + 1)})
    addon:SendEvent("RXP_SPEEDRUN_PRACTICE_STATE", "split", elapsed)
    if addon.speedrunAudio then addon.speedrunAudio:Play("pace") end
    self:Refresh()
end

function practice:AddNote(text)
    local state = self.state
    if not state then return end
    text = type(text) == "string" and text:gsub("[%c]", " "):sub(1, 160) or ""
    if text ~= "" then tinsert(state.notes, text) end
    self:Refresh()
end

function practice:Finish()
    local state = self.state
    if not state then return end
    local elapsed = self:GetElapsed()
    local store = Store()
    local id = state.definition.id
    store.attempts[id] = type(store.attempts[id]) == "table" and store.attempts[id] or {}
    local attempts = store.attempts[id]
    tinsert(attempts, {duration = floor(elapsed * 10 + 0.5) / 10,
        splits = state.splits, notes = state.notes, finishedAt = _G.time()})
    while #attempts > 50 do tremove(attempts, 1) end
    self.lastResult = elapsed
    self.state = nil
    self:RestoreRealState()
    addon.speedrunPracticeActive = nil
    if addon.speedrun and addon.speedrun.IsTimingEnabled and
        addon.speedrun:IsTimingEnabled() then
        addon.speedrun:ResumeActive()
        addon.speedrun:StartCurrentStep("practice-restore")
    end
    self.previousBrowseMode = nil
    addon.scheduler:Cancel(OWNER, "refresh")
    addon:SendEvent("RXP_SPEEDRUN_PRACTICE_STATE", "finished", elapsed)
    self:Refresh()
end

function practice:Abort(silent, suppressResume)
    if not self.state and not addon.speedrunPracticeActive then return end
    self.state = nil
    self:RestoreRealState()
    addon.speedrunPracticeActive = nil
    if not suppressResume and addon.speedrun and addon.speedrun.IsTimingEnabled and
        addon.speedrun:IsTimingEnabled() then
        addon.speedrun:ResumeActive()
        addon.speedrun:StartCurrentStep("practice-restore")
    end
    self.previousBrowseMode = nil
    addon.scheduler:Cancel(OWNER, "refresh")
    if not silent then addon:SendEvent("RXP_SPEEDRUN_PRACTICE_STATE", "aborted") end
    self:Refresh()
end

function practice:GetStatistics()
    local definition = self.definition
    local attempts = definition and Store().attempts[definition.id] or {}
    local values, best = {}, nil
    for _, attempt in ipairs(type(attempts) == "table" and attempts or {}) do
        local duration = tonumber(attempt.duration)
        if duration then
            tinsert(values, duration)
            best = not best and duration or min(best, duration)
        end
    end
    local median = Median(values)
    local deviations = 0
    if median and #values > 1 then
        for _, value in ipairs(values) do deviations = deviations + math.abs(value - median) end
        deviations = deviations / #values
    end
    return best, median, deviations, #values
end

function practice:BuildText()
    local definition = self.definition
    local lines = {L("Segment Practice Lab"),
        L("Practice is a shadow timer. Saved guide progression is untouched and automation is suppressed."), ""}
    if definition then
        tinsert(lines, format(L("Guide: %s"), tostring(definition.guideKey)))
        tinsert(lines, format(L("Range: step %d -> %d"), definition.startIndex,
            definition.endIndex))
        local best, median, consistency, count = self:GetStatistics()
        tinsert(lines, format(L("Attempts: %d   Best: %s   Median: %s"), count,
            best and Duration(best) or "-", median and Duration(median) or "-"))
        if count > 1 then
            tinsert(lines, format(L("Mean absolute variation: %s"), Duration(consistency)))
        end
    else
        tinsert(lines, L("Choose a guide step, then set the start and end boundaries."))
    end
    if self.state then
        tinsert(lines, "")
        tinsert(lines, format(L("CURRENT: %s%s"), Duration(self:GetElapsed()),
            self.state.running and "" or L(" (paused)")))
        for index, split in ipairs(self.state.splits) do
            tinsert(lines, format("  %d. %s - %s (%s)", index, split.label,
                Duration(split.elapsed), Duration(split.duration)))
        end
        for _, note in ipairs(self.state.notes) do
            tinsert(lines, format(L("  Note: %s"), note))
        end
    end
    tinsert(lines, "")
    tinsert(lines, L("Completed quests and world state cannot be reset by an addon."))
    return table.concat(lines, "\n")
end

function practice:Refresh()
    if self.frame and self.frame:IsShown() then toolWindows:SetText(self.frame, self:BuildText()) end
    local function SetButtonEnabled(button, enabled)
        if not button then return end
        if enabled then button:Enable() else button:Disable() end
    end
    SetButtonEnabled(self.startButton, not self.state)
    SetButtonEnabled(self.pauseButton, self.state ~= nil)
    SetButtonEnabled(self.splitButton, self.state ~= nil)
    SetButtonEnabled(self.finishButton, self.state ~= nil)
    SetButtonEnabled(self.previousDefinitionButton, self.state == nil)
    SetButtonEnabled(self.nextDefinitionButton, self.state == nil)
end

function practice:ScheduleRefresh()
    addon.scheduler:Cancel(OWNER, "refresh")
    if self.state and self.state.running and self.frame and self.frame:IsShown() then
        addon.scheduler:After(OWNER, "refresh", 0.2, function()
            practice:Refresh()
            practice:ScheduleRefresh()
        end)
    end
end

function practice:CreateWindow()
    if self.frame then return end
    local frame = toolWindows:Create({name = "RXPSpeedrunPracticeWindow",
        title = L("Segment Practice Lab"), width = 680, height = 450,
        minWidth = 480, minHeight = 320})
    toolWindows:AddScrollingText(frame, {top = 48, bottom = 122})
    local previousDefinition = CreateFrame("Button", nil, frame,
                                            "UIPanelButtonTemplate")
    previousDefinition:SetPoint("BOTTOMLEFT", 20, 82)
    previousDefinition:SetHeight(24)
    previousDefinition:SetText(L("Previous Segment"))
    toolWindows:SizeButton(previousDefinition, 115, 165)
    previousDefinition:SetScript("OnClick",
        function() practice:SelectDefinition(-1) end)
    local nextDefinition = CreateFrame("Button", nil, frame,
                                        "UIPanelButtonTemplate")
    nextDefinition:SetPoint("LEFT", previousDefinition, "RIGHT", 7, 0)
    nextDefinition:SetHeight(24)
    nextDefinition:SetText(L("Next Segment"))
    toolWindows:SizeButton(nextDefinition, 105, 155)
    nextDefinition:SetScript("OnClick",
        function() practice:SelectDefinition(1) end)
    self.previousDefinitionButton = previousDefinition
    self.nextDefinitionButton = nextDefinition
    local startBoundary = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    startBoundary:SetPoint("BOTTOMLEFT", 20, 50)
    startBoundary:SetHeight(24)
    startBoundary:SetText(L("Set Start Here"))
    toolWindows:SizeButton(startBoundary, 105, 155)
    startBoundary:SetScript("OnClick", function() practice:SetBoundary("start") end)
    local endBoundary = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    endBoundary:SetPoint("LEFT", startBoundary, "RIGHT", 7, 0)
    endBoundary:SetHeight(24)
    endBoundary:SetText(L("Set End Here"))
    toolWindows:SizeButton(endBoundary, 105, 155)
    endBoundary:SetScript("OnClick", function() practice:SetBoundary("end") end)
    local note = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    note:SetSize(230, 24)
    note:SetPoint("LEFT", endBoundary, "RIGHT", 12, 0)
    note:SetAutoFocus(false)
    note:SetMaxLetters(160)
    note:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    note:SetScript("OnEnterPressed", function(self)
        practice:AddNote(self:GetText())
        self:SetText("")
        self:ClearFocus()
    end)
    note:SetText("")
    self.noteBox = note
    self.startButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    self.startButton:SetPoint("BOTTOMLEFT", 20, 18)
    self.startButton:SetHeight(24)
    self.startButton:SetText(L("Start"))
    toolWindows:SizeButton(self.startButton, 70, 100)
    self.startButton:SetScript("OnClick", function() practice:Start() end)
    self.pauseButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    self.pauseButton:SetPoint("LEFT", self.startButton, "RIGHT", 7, 0)
    self.pauseButton:SetHeight(24)
    self.pauseButton:SetText(L("Pause / Resume"))
    toolWindows:SizeButton(self.pauseButton, 110, 150)
    self.pauseButton:SetScript("OnClick", function() practice:Pause() end)
    self.splitButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    self.splitButton:SetPoint("LEFT", self.pauseButton, "RIGHT", 7, 0)
    self.splitButton:SetHeight(24)
    self.splitButton:SetText(L("Split"))
    toolWindows:SizeButton(self.splitButton, 70, 100)
    self.splitButton:SetScript("OnClick", function() practice:Split() end)
    self.finishButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    self.finishButton:SetPoint("LEFT", self.splitButton, "RIGHT", 7, 0)
    self.finishButton:SetHeight(24)
    self.finishButton:SetText(L("Finish"))
    toolWindows:SizeButton(self.finishButton, 70, 100)
    self.finishButton:SetScript("OnClick", function() practice:Finish() end)
    local abort = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    abort:SetPoint("LEFT", self.finishButton, "RIGHT", 7, 0)
    abort:SetHeight(24)
    abort:SetText(L("Abort"))
    toolWindows:SizeButton(abort, 70, 100)
    abort:SetScript("OnClick", function() practice:Abort() end)
    frame:SetScript("OnShow", function() practice:Refresh() practice:ScheduleRefresh() end)
    frame:HookScript("OnHide", function() addon.scheduler:Cancel(OWNER, "refresh") end)
    self.frame = frame
end

function practice:Toggle()
    if not self.setup or not Enabled() then return end
    if not self.definition or self.definition.guideKey ~= GuideKey() then
        self:SelectDefinition(1)
    end
    if not self.frame then self:CreateWindow() end
    if self.frame:IsShown() then self.frame:Hide() else self.frame:Show() end
end

function practice:ApplySettings()
    if not self.setup then return end
    if not Enabled() then
        if self.frame then self.frame:Hide() end
        self:Abort(true)
    end
end

function practice:Setup()
    -- A reload cannot safely resume a shadow session because world state may
    -- have changed.  Attempts are committed only by Finish.
    self.state = nil
    if type(Session().practiceRestore) == "table" then
        addon.speedrunPracticeActive = true
        self:RestoreRealState()
        addon.speedrunPracticeActive = nil
        if addon.speedrun and addon.speedrun.IsTimingEnabled and
            addon.speedrun:IsTimingEnabled() then
            addon.speedrun:ResumeActive()
            addon.speedrun:StartCurrentStep("practice-reload-restore")
        end
    end
    self.setup = true
    self:SelectDefinition(1)
    self:ApplySettings()
end

function practice:Shutdown()
    self:Abort(true, true)
    if self.frame then self.frame:Hide() end
    self.setup = false
end

_G.BINDING_NAME_RXP_SPEEDRUN_PRACTICE_TOGGLE = L("Start or Pause Speedrun Practice")
_G.BINDING_NAME_RXP_SPEEDRUN_PRACTICE_SPLIT = L("Split Speedrun Practice")

if addon.RXPGuides then
    addon.RXPGuides.ToggleSpeedrunPractice = function()
        if practice.state then practice:Pause() else practice:Start() end
    end
    addon.RXPGuides.SplitSpeedrunPractice = function() practice:Split() end
end
