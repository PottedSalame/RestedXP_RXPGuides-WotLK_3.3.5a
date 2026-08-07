local _, addon = ...

local _G = _G
local format = string.format
local GetTime = _G.GetTime
local time = _G.time

addon.diagnostics = addon.diagnostics or {}
local diagnostics = addon.diagnostics
local MAX_RECORDS = 200
local MAX_AGE = 300

local observedEvents = {
    "QUEST_ACCEPTED", "QUEST_TURNED_IN", "QUEST_LOG_UPDATE", "QUEST_DETAIL",
    "QUEST_COMPLETE", "QUEST_PROGRESS", "GOSSIP_SHOW", "BAG_UPDATE_DELAYED",
    "GET_ITEM_INFO_RECEIVED", "ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD",
    "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT", "TAXIMAP_OPENED"
}

local function SafeValue(value)
    if type(value) == "number" or type(value) == "boolean" then return value end
    if type(value) == "string" then return value:sub(1, 160) end
    return nil
end

function diagnostics:Record(kind, data)
    self.records = self.records or {}
    local record = {time = GetTime(), kind = tostring(kind):sub(1, 60)}
    if type(data) == "table" then
        record.data = {}
        for key, value in pairs(data) do
            if type(key) == "string" then
                local safe = SafeValue(value)
                if safe ~= nil then record.data[key:sub(1, 40)] = safe end
            end
        end
    end
    table.insert(self.records, record)
    if RXPData and RXPData.diagnosticState then
        RXPData.diagnosticState.lastRecord = time and time() or nil
        RXPData.diagnosticState.recordCount = #self.records
    end
    local now = GetTime()
    while #self.records > MAX_RECORDS or
        self.records[1] and now - self.records[1].time > MAX_AGE do
        table.remove(self.records, 1)
    end
end

local function QuestState(id)
    id = tonumber(id)
    if not id then return "invalid quest ID" end
    if addon.IsQuestTurnedIn and addon.IsQuestTurnedIn(id) then
        return "turned in"
    elseif addon.IsOnQuest and addon.IsOnQuest(id) then
        if addon.IsQuestComplete and addon.IsQuestComplete(id) then
            return "complete in quest log"
        end
        return "active in quest log"
    end
    return "not accepted"
end

local function TargetList(targets)
    local output = {}
    for _, target in ipairs(type(targets) == "table" and targets or {}) do
        output[#output + 1] = tostring(target):sub(1, 80)
    end
    return table.concat(output, ", ")
end

function diagnostics:AnalyzeElement(element, index)
    if type(element) ~= "table" then
        return format("%d. invalid element", index)
    end
    local tag = tostring(element.tag or "text")
    local status, detail = "WAIT", "No authoritative completion state"
    local id = tonumber(element.questId or element.id)
    if id and (tag == "accept" or tag == "daily" or tag == "complete" or
        tag == "turnin" or tag == "dailyturnin") then
        detail = "Quest " .. id .. " is " .. QuestState(id)
        if element.completed then status = "PASS"
        elseif tag == "accept" and addon.IsOnQuest(id) then status = "PASS"
        elseif (tag == "turnin" or tag == "dailyturnin") and
            addon.IsQuestTurnedIn(id) then status = "PASS"
        elseif not addon.GetQuestName or not addon.GetQuestName(id) then
            status = "UNKNOWN"
            detail = detail .. "; server quest data is not cached"
        end
        if tag == "accept" or tag == "daily" then
            local available, missing = addon.GetQuestPreReqState and
                                           addon.GetQuestPreReqState(id)
            if available == false then
                status = "BLOCK"
                local ids = {}
                for _, questId in ipairs(missing or {}) do
                    ids[#ids + 1] = tostring(questId)
                end
                detail = detail .. "; missing prerequisite(s): " ..
                             (#ids > 0 and table.concat(ids, ", ") or "unknown")
                self.lastMissingPrerequisite = missing and missing[1]
            elseif available == nil then
                detail = detail .. "; prerequisite data unavailable"
            end
            local automation = addon.settings.profile.enableQuestAutomation and
                                   not IsControlKeyDown() and not addon.isHidden
            detail = detail .. "; automation " ..
                         (automation and "eligible" or "disabled/manual")
        end
    elseif tag == "goto" or tag == "waypoint" then
        if element.zone and element.x and element.y then
            local x, y = tonumber(element.x), tonumber(element.y)
            if not x or not y or x < 0 or x > 100 or y < 0 or y > 100 then
                status, detail = "BLOCK", "Coordinates are outside 0-100"
            else
                status = element.completed and "PASS" or "WAIT"
                detail = format("Map %s at %.2f, %.2f; player map %s",
                    tostring(element.zone), x, y,
                    tostring(C_Map.GetBestMapForUnit("player") or "unknown"))
            end
        else
            status = "BLOCK"
            detail = "Missing or invalid map/coordinate data"
        end
    elseif tag == "fly" or tag == "fp" then
        if element.fpAmbiguous then
            status, detail = "BLOCK", "Flight name is ambiguous; manual selection is required"
        elseif element.fpId then
            status = element.completed and "PASS" or "WAIT"
            detail = "Resolved flight node " .. tostring(element.fpId)
        else
            status, detail = "UNKNOWN", "No exact faction flight node resolved"
        end
    elseif tag == "collect" or tag == "use" or tag == "buy" then
        status = element.completed and "PASS" or "WAIT"
        detail = id and ("Item/quest reference " .. id) or
                     "Waiting for item or inventory state"
    elseif tag == "target" or tag == "unitscan" or tag == "mob" then
        status = element.completed and "PASS" or "WAIT"
        detail = element.targets and
                     ("Targets: " .. TargetList(element.targets)) or
                     "Waiting for a matching target or visible nameplate"
    elseif element.completed then
        status, detail = "PASS", "Element reports complete"
    end
    return format("%d. [%s] .%s - %s", index, status, tag, detail)
end

function diagnostics:BuildReport(stepNumber, includeRecent)
    local guide = addon.currentGuide
    stepNumber = tonumber(type(stepNumber) == "table" and stepNumber.arg1 or
                              stepNumber) or RXPCData.currentStep or 1
    local step = guide and guide.steps and guide.steps[stepNumber]
    local mapID = C_Map.GetBestMapForUnit("player")
    local pos = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
    local lines = {
        "RXPGuides sanitized diagnostic report",
        "Addon: " .. tostring(addon.release),
        "Client: " .. tostring(select(1, GetBuildInfo())),
        "Locale: " .. tostring(GetLocale()),
        "Class/Race/Level: " .. tostring(addon.player.class) .. "/" ..
            tostring(addon.player.race) .. "/" .. tostring(UnitLevel("player")),
        "Zone: " .. tostring(GetRealZoneText()),
        format("Map position: %s / %.2f, %.2f", tostring(mapID or "unknown"),
               pos and pos.x * 100 or -1, pos and pos.y * 100 or -1),
        "Guide: " .. tostring(guide and guide.key or "inactive"),
        "Guide version: " .. tostring(guide and guide.version or "unknown"),
        "Step: " .. tostring(stepNumber) .. " (ID " ..
            tostring(step and step.stepId or "unknown") .. ")", ""
    }
    if not step then
        table.insert(lines, "[BLOCK] Current step is unavailable.")
    else
        for index, element in ipairs(step.elements or step) do
            if type(element) == "table" and element ~= step.elements then
                table.insert(lines, self:AnalyzeElement(element, index))
            end
        end
        if not step.elements or #step.elements == 0 then
            table.insert(lines, "[UNKNOWN] Step has no parsed elements.")
        end
    end
    if includeRecent then
        table.insert(lines, "")
        table.insert(lines, "Recent whitelisted events:")
        local first = math.max(1, #(self.records or {}) - 29)
        for index = first, #(self.records or {}) do
            local record = self.records[index]
            local pieces = {format("+%.2f %s", record.time, record.kind)}
            for key, value in pairs(record.data or {}) do
                table.insert(pieces, key .. "=" .. tostring(value))
            end
            table.insert(lines, table.concat(pieces, " "))
        end
    end
    return table.concat(lines, "\n")
end

function diagnostics:Open(stepNumber)
    addon.comms.OpenBrandedExport("Step Doctor",
        "The report explains the current step. Use /rxp diagnose after retrying the action.",
        self:BuildReport(stepNumber, false), 720, 520)
end

function diagnostics:OpenIssueReport(stepNumber)
    addon.comms.OpenBrandedExport("Feedback Form",
        "Describe the problem above this sanitized report when filing an issue.",
        "Describe your issue:\n\n\n--- Do not edit below this line ---\n" ..
            self:BuildReport(stepNumber, true), 720, 560)
end

function diagnostics:Rescan()
    addon.updateSteps = true
    addon.updateStepText = true
    if addon.UpdateQuestCache then pcall(addon.UpdateQuestCache) end
    if addon.targeting and addon.targeting.RefreshScanTicker then
        pcall(function() addon.targeting:RefreshScanTicker(true) end)
    end
    self:Record("MANUAL_RESCAN", {step = RXPCData.currentStep})
end

local function FindGuideForQuest(questId)
    questId = tonumber(questId)
    if not questId then return end
    for group, list in pairs(addon.guideList or {}) do
        local realGroup = group:gsub("^[*+]", "")
        for _, name in ipairs(list.names_ or {}) do
            local guide = addon.GetGuideTable(realGroup, name) or
                              addon.GetGuideTable(group, name)
            if guide and not guide.disabled and not guide.internal then
                local parsed = addon:FetchGuide(guide)
                for stepIndex, step in ipairs(parsed and parsed.steps or {}) do
                    for _, element in ipairs(step.elements or {}) do
                        if tonumber(element.questId or element.id) == questId and
                            (element.tag == "accept" or element.tag == "daily") then
                            return parsed, step.index or stepIndex
                        end
                    end
                end
            end
        end
    end
end

function diagnostics:OpenPrerequisiteGuide()
    -- Refresh the analysis first so this action never follows a stale quest ID.
    self.lastMissingPrerequisite = nil
    self:BuildReport(RXPCData.currentStep, false)
    local questId = self.lastMissingPrerequisite
    local guide, step = FindGuideForQuest(questId)
    if not guide then
        addon.comms:PopupNotification("RXP_PREREQ_GUIDE_MISSING",
            questId and ("No loaded guide accepts prerequisite quest " .. questId .. ".") or
                "The current step has no known missing prerequisite.")
        return
    end
    addon.comms:ConfirmChoice("RXP_OPEN_PREREQ_GUIDE",
        format("Open the guide containing prerequisite quest %d?", questId),
        function(data)
            addon.guideState:Load(data.guide, false, "manual")
            if data.step then addon.GoToStep(data.step) end
        end, {guide = guide, step = step})
end

function diagnostics:SkipCurrent(markComplete)
    local number = tonumber(RXPCData.currentStep)
    local step = addon.currentGuide and addon.currentGuide.steps and
                     addon.currentGuide.steps[number]
    if not number or not step then return end
    local verb = markComplete and "mark complete" or "skip"
    addon.comms:ConfirmChoice("RXP_STEP_DOCTOR_SKIP",
        format("Manually %s step %d? This changes only local guide progress.",
               verb, number), function()
            if markComplete then
                for _, element in ipairs(step.elements or {}) do
                    element.completed = true
                end
                step.completed = true
            else
                RXPCData.stepSkip[number] = true
            end
            diagnostics:Record("MANUAL_STEP_OVERRIDE", {
                step = number, complete = markComplete == true
            })
            addon.GoToStep(math.min(number + 1, #addon.currentGuide.steps))
        end)
end

function diagnostics:Setup()
    if self.setup then return end
    self.setup = true
    self.records = self.records or {}
    self.eventFrame = CreateFrame("Frame")
    for _, event in ipairs(observedEvents) do
        pcall(self.eventFrame.RegisterEvent, self.eventFrame, event)
    end
    self.eventFrame:SetScript("OnEvent", function(_, event, arg1, arg2)
        local data = {}
        if event == "QUEST_ACCEPTED" or event == "QUEST_TURNED_IN" then
            data.quest = tonumber(arg2) or tonumber(arg1)
        elseif event == "GET_ITEM_INFO_RECEIVED" then
            data.item = tonumber(arg1)
            data.success = arg2 == true
        end
        data.step = RXPCData and RXPCData.currentStep
        diagnostics:Record(event, data)
    end)
    self.stepCallback = function(_, step, guide)
        self:Record("RXP_STEP_ACTIVATED", {
            step = step and step.index,
            stepId = step and step.stepId,
            guide = guide and guide.key
        })
    end
    addon:RegisterMessage("RXP_STEP_ACTIVATED", self.stepCallback)
    local menu = addon.RXPFrame and addon.RXPFrame.bottomMenu
    if menu then
        table.insert(menu, #menu, {
            notCheckable = 1,
            text = "Diagnose this step",
            func = function(arg)
                local step = type(arg) == "table" and arg.arg1 or arg
                diagnostics:Open(step)
            end
        })
        table.insert(menu, #menu, {
            notCheckable = 1,
            text = "Open prerequisite guide",
            func = function() diagnostics:OpenPrerequisiteGuide() end
        })
        table.insert(menu, #menu, {
            notCheckable = 1,
            text = "Manually complete step...",
            func = function() diagnostics:SkipCurrent(true) end
        })
        table.insert(menu, #menu, {
            notCheckable = 1,
            text = "Manually skip step...",
            func = function() diagnostics:SkipCurrent(false) end
        })
        table.insert(menu, #menu, {
            notCheckable = 1,
            text = "Rescan current step",
            func = function() diagnostics:Rescan() end
        })
        table.insert(menu, #menu, {
            notCheckable = 1,
            text = "Watch current step for no progress",
            func = function()
                if addon.routePreflight then addon.routePreflight:ToggleWatch() end
            end
        })
        table.insert(menu, #menu, {
            notCheckable = 1,
            text = "Find a catch-up step",
            func = function()
                if addon.catchUp then addon.catchUp:Preview() end
            end
        })
        table.insert(menu, #menu, {
            notCheckable = 1,
            text = "Plan return to route",
            func = function()
                if addon.travel then addon.travel:OpenCurrentRoute() end
            end
        })
    end
end
