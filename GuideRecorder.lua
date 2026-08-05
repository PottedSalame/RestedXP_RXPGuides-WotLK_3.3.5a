local _, addon = ...

local _G = _G
local format = string.format
local GetTime = _G.GetTime

addon.guideRecorder = addon.guideRecorder or {}
local recorder = addon.guideRecorder

local function CurrentPosition()
    local mapID = C_Map.GetBestMapForUnit("player")
    local position = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
    if not position then return end
    return mapID, position.x * 100, position.y * 100
end

local function NpcEntry(unit)
    local guid = UnitGUID(unit)
    if type(guid) ~= "string" or guid:sub(1, 4) ~= "0xF1" then return end
    -- Legacy unit GUID layouts differ slightly between cores. Test the normal
    -- six-hex entry field first, then the older four-hex field.
    local value = tonumber(guid:sub(7, 12), 16)
    if value and value > 0 and value < 1000000 then return value end
    value = tonumber(guid:sub(7, 10), 16)
    return value and value > 0 and value or nil
end

local function ItemID(value)
    if type(value) == "number" then return value end
    return type(value) == "string" and
               tonumber(value:match("item:(%d+)")) or nil
end

function recorder:IsRecording()
    return RXPCData.recorderDraft and RXPCData.recorderDraft.recording == true
end

function recorder:GetDraft()
    RXPCData.recorderDraft = type(RXPCData.recorderDraft) == "table" and
                                RXPCData.recorderDraft or {}
    local draft = RXPCData.recorderDraft
    draft.steps = type(draft.steps) == "table" and draft.steps or {}
    draft.events = type(draft.events) == "table" and draft.events or {}
    draft.name = draft.name or "Recorded Draft"
    return draft
end

function recorder:Record(kind, data)
    if not self:IsRecording() then return end
    local draft = self:GetDraft()
    local signature = tostring(kind) .. ":" .. tostring(data and data.id or "")
    local now = GetTime()
    if self.lastSignature == signature and now - (self.lastRecord or 0) < 0.5 then
        return
    end
    self.lastSignature, self.lastRecord = signature, now
    local event = {kind = kind, elapsed = now - (draft.started or now)}
    for key, value in pairs(data or {}) do
        if type(value) == "string" then
            event[key] = value:gsub("[\r\n]+", " "):sub(1, 240)
        elseif type(value) == "number" or type(value) == "boolean" then
            event[key] = value
        end
    end
    table.insert(draft.events, event)
    while #draft.events > 500 do table.remove(draft.events, 1) end
    self:Refresh()
end

function recorder:EnsureStep()
    local draft = self:GetDraft()
    if #draft.steps == 0 then table.insert(draft.steps, {lines = {}}) end
    return draft.steps[#draft.steps]
end

function recorder:AddLine(line, uncertain)
    if type(line) ~= "string" or line == "" then return end
    local step = self:EnsureStep()
    table.insert(step.lines, {text = line, uncertain = uncertain == true})
    self:Refresh()
end

function recorder:NewStep()
    table.insert(self:GetDraft().steps, {lines = {}})
    self:Refresh()
end

function recorder:AddWaypoint()
    local mapID, x, y = CurrentPosition()
    if not mapID then return end
    self:AddLine(format(".goto %d,%.2f,%.2f", mapID, x, y), false)
end

function recorder:AddTarget()
    local unit = UnitExists("target") and "target" or
                     (UnitExists("mouseover") and "mouseover")
    if not unit then return end
    local entry = NpcEntry(unit)
    -- Do not turn player targets into draft data. NPC entry IDs are the
    -- recorder's privacy boundary: if the unit is not an NPC, it is ignored.
    if not entry then
        addon.comms.PrettyPrint("Guide Recorder only adds NPC targets.")
        return
    end
    local name = UnitName(unit)
    if name then self:AddLine(".target " .. name, false) end
    self:Record("target-added", {id = entry, name = name})
end

function recorder:AddNote(text)
    if type(text) == "string" and text ~= "" then
        self:AddLine(">>" .. text:gsub("[\r\n]+", " "), false)
    end
end

function recorder:PromptNote()
    StaticPopupDialogs.RXP_RECORDER_NOTE = {
        text = "Enter a guide note",
        button1 = _G.ACCEPT,
        button2 = _G.CANCEL,
        hasEditBox = 1,
        maxLetters = 240,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        OnShow = function(frame) frame.editBox:SetFocus() end,
        OnAccept = function(frame)
            recorder:AddNote(frame.editBox:GetText())
        end
    }
    StaticPopup_Show("RXP_RECORDER_NOTE")
end

function recorder:Undo()
    local draft = self:GetDraft()
    local step = draft.steps[#draft.steps]
    if step and #step.lines > 0 then
        table.remove(step.lines)
    elseif #draft.steps > 0 then
        table.remove(draft.steps)
    end
    self:Refresh()
end

function recorder:Clear()
    addon.comms:ConfirmChoice("RXP_RECORDER_CLEAR",
        "Clear the current recorder draft?", function()
            RXPCData.recorderDraft = {steps = {}, events = {},
                                      name = "Recorded Draft", recording = false}
            recorder:Refresh()
        end)
end

function recorder:BuildGuide()
    local draft = self:GetDraft()
    local draftName = tostring(draft.name or "Recorded Draft")
                          :gsub("[\r\n]+", " "):sub(1, 120)
    local lines = {
        "-- Draft generated by RXPGuides Guide Author Mode.",
        "-- Review every uncertain line and run Tools/Validate-Guides335.ps1 before publishing.",
        "#group RXPGuides Recorded Drafts",
        "#name " .. draftName,
        "#wotlk", ""
    }
    for _, step in ipairs(draft.steps) do
        if #step.lines > 0 then
            table.insert(lines, "step")
            for _, line in ipairs(step.lines) do
                if line.uncertain then
                    table.insert(lines, "    -- VERIFY: inferred from an event")
                end
                table.insert(lines, "    " .. line.text)
            end
            table.insert(lines, "")
        end
    end
    return table.concat(lines, "\n")
end

function recorder:SnapshotObjectives()
    local nextSnapshot = {}
    for logIndex = 1, GetNumQuestLogEntries() do
        local _, _, _, _, isHeader = GetQuestLogTitle(logIndex)
        if not isHeader then
            local questId = C_QuestLog.GetQuestIDForLogIndex(logIndex)
            if questId and questId > 0 then
                for objective = 1, GetNumQuestLeaderBoards(logIndex) do
                    local text, objectiveType, finished =
                        GetQuestLogLeaderBoard(objective, logIndex)
                    local current, required = type(text) == "string" and
                                                  text:match("(%d+)%s*/%s*(%d+)")
                    local key = questId .. ":" .. objective
                    local value = table.concat({tostring(current or "?"),
                        tostring(required or "?"), tostring(finished == true)}, ":")
                    nextSnapshot[key] = value
                    if self.objectiveSnapshot and
                        self.objectiveSnapshot[key] ~= value then
                        self:Record("objective-changed", {
                            id = questId, objective = objective,
                            current = tonumber(current), required = tonumber(required),
                            complete = finished == true,
                            kind = objectiveType
                        })
                    end
                end
            end
        end
    end
    self.objectiveSnapshot = nextSnapshot
end

function recorder:SnapshotBags()
    local nextSnapshot = {}
    for bag = _G.BACKPACK_CONTAINER or 0,
        _G.NUM_BAG_SLOTS or _G.NUM_BAG_FRAMES or 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            local id = ItemID(link)
            if id then
                local _, count = GetContainerItemInfo(bag, slot)
                nextSnapshot[id] = (nextSnapshot[id] or 0) +
                                       (tonumber(count) or 1)
            end
        end
    end
    for id, count in pairs(nextSnapshot) do
        local previous = self.bagSnapshot and self.bagSnapshot[id] or count
        if count > previous then
            self:Record("item-acquired", {id = id, count = count - previous})
        end
    end
    self.bagSnapshot = nextSnapshot
end

function recorder:Preview()
    addon.comms.OpenBrandedExport("Recorded Guide Preview",
        "This is a draft. Validate it offline before publishing.",
        self:BuildGuide(), 720, 560)
end

function recorder:ValidateDraft()
    local text = self:BuildGuide()
    local ok, guide, parseError = pcall(addon.ParseGuide, text)
    local valid = ok and type(guide) == "table" and
                      type(guide.steps) == "table" and #guide.steps > 0 and
                      not parseError
    addon.comms:PopupNotification("RXP_RECORDER_VALIDATE",
        valid and
            "The runtime parser accepted this draft. The offline guide and quest-flow validators are still required before publishing." or
            ("Draft parser check failed: " .. tostring(parseError or guide)))
    return valid
end

function recorder:Start()
    local draft = self:GetDraft()
    draft.recording = true
    draft.started = GetTime()
    self:Record("recording-started")
    self:Refresh()
end

function recorder:Stop()
    local draft = self:GetDraft()
    self:Record("recording-stopped")
    draft.recording = false
    self:Refresh()
end

function recorder:HandleEvent(event, arg1, arg2, arg3)
    if not self:IsRecording() then return end
    if event == "QUEST_ACCEPTED" then
        local id = addon.NormalizeQuestAcceptedId and
                       addon.NormalizeQuestAcceptedId(arg1, arg2) or
                       tonumber(arg2) or tonumber(arg1)
        if id then
            self:Record("quest-accepted", {id = id})
            self:AddLine(".accept " .. id, false)
        end
    elseif event == "QUEST_TURNED_IN" then
        local id = tonumber(arg1)
        if id then
            self:Record("quest-turned-in", {id = id})
            self:AddLine(".turnin " .. id, false)
        end
    elseif event == "PLAYER_TARGET_CHANGED" or event == "UPDATE_MOUSEOVER_UNIT" then
        local unit = event == "PLAYER_TARGET_CHANGED" and "target" or "mouseover"
        local entry = NpcEntry(unit)
        if entry then
            self:Record("unit-seen", {id = entry, name = UnitName(unit)})
        end
    elseif event == "TAXIMAP_OPENED" then
        self:Record("taxi-map-opened", {zone = GetRealZoneText()})
    elseif event == "HEARTHSTONE_BOUND" then
        self:Record("hearth-bound", {location = GetBindLocation()})
    elseif event == "ITEM_PUSH" then
        self:Record("item-push", {id = ItemID(arg2), count = tonumber(arg3)})
    elseif event == "BAG_UPDATE" then
        self:SnapshotBags()
    elseif event == "QUEST_LOG_UPDATE" then
        self:SnapshotObjectives()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
        local spellName = type(arg2) == "string" and arg2 or
                              (tonumber(arg3) and GetSpellInfo(arg3))
        self:Record("spell-or-item-used", {spell = spellName})
    elseif event == "GOSSIP_SHOW" then
        local options = C_GossipInfo and C_GossipInfo.GetOptions and
                            C_GossipInfo.GetOptions() or {}
        local labels = {}
        for _, option in ipairs(options) do
            labels[#labels + 1] = tostring(option.name or option.gossipText or "")
        end
        self:Record("gossip-opened", {
            options = #options, labels = table.concat(labels, " | ")
        })
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        local mapID, x, y = CurrentPosition()
        self:Record("zone-changed", {map = mapID, x = x, y = y,
                                      zone = GetRealZoneText()})
    end
end

function recorder:Refresh()
    if not self.frame or not self.frame:IsShown() then return end
    local draft = self:GetDraft()
    self.frame.state:SetText(self:IsRecording() and
        "|cff40ff40Recording|r" or "|cffaaaaaaStopped|r")
    self.frame.count:SetText(format("%d steps / %d captured events",
                                    #draft.steps, #draft.events))
    local preview = self:BuildGuide()
    if #preview > 3200 then preview = preview:sub(#preview - 3200) end
    self.frame.preview:SetText(preview)
    self.frame.start:SetText(self:IsRecording() and "Stop" or "Start")
end

local function Button(frame, text, width, callback)
    local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button:SetSize(width, 23)
    button:SetText(text)
    button:SetScript("OnClick", callback)
    return button
end

function recorder:CreateFrame()
    local frame = CreateFrame("Frame", "RXPGuideRecorder", UIParent)
    frame:SetSize(720, 520)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                       edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                       tile = true, tileSize = 32, edgeSize = 32,
                       insets = {left = 8, right = 8, top = 8, bottom = 8}})
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -18)
    title:SetText("Guide Author Recorder")
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)
    frame.state = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.state:SetPoint("TOPLEFT", 24, -48)
    frame.count = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.count:SetPoint("TOPRIGHT", -24, -48)

    frame.start = Button(frame, "Start", 70, function()
        if recorder:IsRecording() then recorder:Stop() else recorder:Start() end
    end)
    frame.start:SetPoint("TOPLEFT", 24, -70)
    local newStep = Button(frame, "New Step", 82, function() recorder:NewStep() end)
    newStep:SetPoint("LEFT", frame.start, "RIGHT", 5, 0)
    local note = Button(frame, "Add Note", 82, function() recorder:PromptNote() end)
    note:SetPoint("LEFT", newStep, "RIGHT", 5, 0)
    local target = Button(frame, "Add Target", 88, function() recorder:AddTarget() end)
    target:SetPoint("LEFT", note, "RIGHT", 5, 0)
    local waypoint = Button(frame, "Waypoint", 82, function() recorder:AddWaypoint() end)
    waypoint:SetPoint("LEFT", target, "RIGHT", 5, 0)
    local undo = Button(frame, "Undo", 60, function() recorder:Undo() end)
    undo:SetPoint("LEFT", waypoint, "RIGHT", 5, 0)
    local validate = Button(frame, "Validate", 72, function() recorder:ValidateDraft() end)
    validate:SetPoint("LEFT", undo, "RIGHT", 5, 0)
    local export = Button(frame, "Export", 68, function() recorder:Preview() end)
    export:SetPoint("LEFT", validate, "RIGHT", 5, 0)
    local clear = Button(frame, "Clear", 58, function() recorder:Clear() end)
    clear:SetPoint("LEFT", export, "RIGHT", 5, 0)

    local previewBox = CreateFrame("Frame", nil, frame)
    previewBox:SetPoint("TOPLEFT", 24, -105)
    previewBox:SetPoint("BOTTOMRIGHT", -24, 24)
    previewBox:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8",
                            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                            tile = true, tileSize = 16, edgeSize = 12,
                            insets = {left = 3, right = 3, top = 3, bottom = 3}})
    previewBox:SetBackdropColor(0.02, 0.02, 0.02, 0.95)
    frame.preview = previewBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.preview:SetPoint("TOPLEFT", 10, -10)
    frame.preview:SetPoint("BOTTOMRIGHT", -10, 10)
    frame.preview:SetJustifyH("LEFT")
    frame.preview:SetJustifyV("TOP")
    if frame.preview.SetNonSpaceWrap then frame.preview:SetNonSpaceWrap(true) end
    frame:SetScript("OnShow", function() recorder:Refresh() end)
    frame:Hide()
    self.frame = frame
    table.insert(_G.UISpecialFrames, "RXPGuideRecorder")
end

function recorder:Toggle()
    if not self.frame then self:CreateFrame() end
    self.frame:SetShown(not self.frame:IsShown())
end

function recorder:HandleCommand(input)
    local command = input:match("^record%s+(%S+)")
    if command == "start" then self:Start()
    elseif command == "stop" then self:Stop()
    elseif command == "export" then self:Preview()
    elseif command == "clear" then self:Clear()
    else self:Toggle() end
end

function recorder:Setup()
    if self.setup then return end
    self.setup = true
    self:GetDraft()
    -- Recording never resumes silently across a login or reload.
    RXPCData.recorderDraft.recording = false
    self:CreateFrame()
    self.eventFrame = CreateFrame("Frame")
    for _, event in ipairs({"QUEST_ACCEPTED", "QUEST_TURNED_IN",
                             "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT",
                             "TAXIMAP_OPENED", "HEARTHSTONE_BOUND", "ITEM_PUSH",
                             "GOSSIP_SHOW", "ZONE_CHANGED_NEW_AREA",
                             "QUEST_LOG_UPDATE", "BAG_UPDATE",
                             "UNIT_SPELLCAST_SUCCEEDED"}) do
        pcall(self.eventFrame.RegisterEvent, self.eventFrame, event)
    end
    self.eventFrame:SetScript("OnEvent", function(_, ...)
        recorder:HandleEvent(...)
    end)
    if _G.hooksecurefunc then
        if type(_G.UseContainerItem) == "function" then
            _G.hooksecurefunc("UseContainerItem", function(bag, slot)
                if recorder:IsRecording() then
                    recorder:Record("item-used", {
                        id = ItemID(GetContainerItemLink(bag, slot))
                    })
                end
            end)
        end
        if type(_G.UseInventoryItem) == "function" then
            _G.hooksecurefunc("UseInventoryItem", function(slot)
                if recorder:IsRecording() then
                    recorder:Record("inventory-item-used", {
                        id = ItemID(GetInventoryItemLink("player", slot))
                    })
                end
            end)
        end
        if type(_G.TakeTaxiNode) == "function" then
            _G.hooksecurefunc("TakeTaxiNode", function(slot)
                if recorder:IsRecording() then
                    recorder:Record("taxi-used", {
                        id = addon.flightInfo and addon.flightInfo[slot],
                        destination = _G.TaxiNodeName and _G.TaxiNodeName(slot)
                    })
                end
            end)
        end
    end
    self:SnapshotObjectives()
    self:SnapshotBags()
end
