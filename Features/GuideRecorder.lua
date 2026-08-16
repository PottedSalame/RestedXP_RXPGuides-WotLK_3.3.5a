local _, addon = ...
local L = addon.locale.Get

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

local function KnownSpellIDByName(wantedName)
    if type(wantedName) ~= "string" or wantedName == "" or
        type(_G.GetNumSpellTabs) ~= "function" or
        type(_G.GetSpellTabInfo) ~= "function" or
        type(_G.GetSpellBookItemName) ~= "function" or
        type(_G.GetSpellBookItemInfo) ~= "function" then return end

    local found
    for tab = 1, _G.GetNumSpellTabs() do
        local _, _, offset, count = _G.GetSpellTabInfo(tab)
        offset, count = tonumber(offset) or 0, tonumber(count) or 0
        for slot = offset + 1, offset + count do
            local name = _G.GetSpellBookItemName(slot,
                                                 _G.BOOKTYPE_SPELL or "spell")
            if name == wantedName then
                local actionType, spellId = _G.GetSpellBookItemInfo(
                                                slot,
                                                _G.BOOKTYPE_SPELL or "spell")
                spellId = tonumber(spellId)
                if actionType == "SPELL" and spellId then
                    if found and found ~= spellId then return end
                    found = spellId
                end
            end
        end
    end
    return found
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
    return event
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
        text = L("Enter a guide note"),
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
        L("Clear the current recorder draft?"), function()
            RXPCData.recorderDraft = {steps = {}, events = {},
                                      name = "Recorded Draft", recording = false}
            recorder:Refresh()
        end)
end

local function SanitizedComment(text)
    return "-- VERIFY: " .. tostring(text or "event"):gsub("[\r\n]+", " ")
end

function recorder:BuildSuggestion(event)
    if type(event) ~= "table" then return end
    if (event.kind == "unit-seen" or event.kind == "target-added") and
        tonumber(event.id) and not event.suggestionComment then
        event.suggestionComment = SanitizedComment(
                                      "NPC entry ID " .. tostring(event.id))
    end
    if type(event.suggestion) == "string" and event.suggestion ~= "" then
        return event.suggestion, event.suggestionUncertain == true
    end

    local line, uncertain
    if event.kind == "quest-accepted" and tonumber(event.id) then
        line = format(".accept %d", event.id)
    elseif event.kind == "quest-turned-in" and tonumber(event.id) then
        line = format(".turnin %d", event.id)
    elseif event.kind == "objective-changed" and
        tonumber(event.id) and tonumber(event.objective) then
        line = format(".complete %d,%d", event.id, event.objective)
    elseif (event.kind == "item-used" or
            event.kind == "inventory-item-used") and tonumber(event.id) then
        line = tonumber(event.id) == 6948 and ".hs" or
                   format(".use %d", event.id)
    elseif event.kind == "hearth-used" then
        line = ".hs"
    elseif event.kind == "spell-or-item-used" and tonumber(event.id) then
        line = format(".cast %d", event.id)
    elseif event.kind == "spell-or-item-used" then
        line = SanitizedComment("spell used: " .. tostring(event.spell or "unknown"))
        uncertain = true
    elseif event.kind == "taxi-used" and
        type(event.destination) == "string" then
        local resolved, ambiguous = addon.ResolveLegacyFlightPath and
            addon.ResolveLegacyFlightPath(event.destination)
        if resolved and not ambiguous and
            (not tonumber(event.id) or resolved == tonumber(event.id)) then
            local faction = addon.player and addon.player.faction
            local node = faction and addon.FPDB and addon.FPDB[faction] and
                             addon.FPDB[faction][resolved]
            line = ".fly " .. tostring(node and node.name or event.destination)
        else
            line = SanitizedComment("verify taxi destination: " .. event.destination)
            uncertain = true
        end
    elseif event.kind == "hearth-bound" then
        line = ".home >> Set your Hearthstone to " ..
                   tostring(event.location or "the recorded inn")
    elseif (event.kind == "item-acquired" or event.kind == "item-push") and
        tonumber(event.id) then
        line = format(".collect %d,%d", event.id,
                      math.max(1, tonumber(event.count) or 1))
        uncertain = true
    elseif (event.kind == "unit-seen" or event.kind == "target-added") and
        tonumber(event.id) and type(event.name) == "string" and
        event.name ~= "" then
        line = ".target " .. event.name
        uncertain = true
    elseif event.kind == "zone-changed" then
        if tonumber(event.map) and tonumber(event.x) and tonumber(event.y) then
            line = SanitizedComment(format("zone transition near %d,%.2f,%.2f",
                                            event.map, event.x, event.y))
        else
            line = SanitizedComment("zone transition")
        end
        uncertain = true
    elseif event.kind == "gossip-opened" then
        line = SanitizedComment("gossip options: " ..
                                    tostring(event.labels or event.options or "unknown"))
        uncertain = true
    end

    if line then
        event.suggestion = line
        event.suggestionUncertain = uncertain == true
        event.reviewed = true
    end
    return line, uncertain
end

function recorder:PromoteEvent(event)
    if type(event) ~= "table" or event.promoted or event.ignored then return end
    local line, uncertain = self:BuildSuggestion(event)
    if not line then return end
    local draft = self:GetDraft()
    local function ContainsLine(wanted)
        if type(wanted) ~= "string" then return false end
        for _, step in ipairs(draft.steps) do
            for _, existing in ipairs(step.lines or {}) do
                if existing.text == wanted then return true end
            end
        end
        return false
    end
    if event.suggestionComment and not ContainsLine(event.suggestionComment) then
        self:AddLine(event.suggestionComment, false)
    end
    if ContainsLine(line) then
        event.promoted = true
        event.selected = false
        return true
    end
    self:AddLine(line, uncertain)
    event.promoted = true
    event.selected = false
    return true
end

function recorder:AddSelected()
    local changed
    for _, event in ipairs(self:GetDraft().events) do
        if event.selected and self:PromoteEvent(event) then changed = true end
    end
    if changed then self:Refresh() end
end

function recorder:AddAllReviewed()
    local changed
    for _, event in ipairs(self:GetDraft().events) do
        if self:BuildSuggestion(event) and self:PromoteEvent(event) then
            changed = true
        end
    end
    if changed then self:Refresh() end
end

function recorder:IgnoreSelected()
    for _, event in ipairs(self:GetDraft().events) do
        if event.selected and not event.promoted then
            event.ignored = true
            event.selected = false
        end
    end
    self:Refresh()
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
                if line.uncertain and line.text:sub(1, 2) ~= "--" then
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
    addon.comms.OpenBrandedExport(L("Recorded Guide Preview"),
        L("This is a draft. Validate it offline before publishing."),
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
            L("The runtime parser accepted this draft. The offline guide and quest-flow validators are still required before publishing.") or
            (L("Draft parser check failed: ") .. tostring(parseError or guide)))
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
        end
    elseif event == "QUEST_TURNED_IN" then
        local id = tonumber(arg1)
        if id then
            self:Record("quest-turned-in", {id = id})
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
        local hearthName = GetSpellInfo(8690)
        self:Record(spellName and hearthName and spellName == hearthName and
                        "hearth-used" or "spell-or-item-used",
                    {spell = spellName,
                     id = tonumber(arg3) or KnownSpellIDByName(spellName)})
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
        "|cff40ff40" .. L("Recording") .. "|r" or
        "|cffaaaaaa" .. L("Stopped") .. "|r")
    self.frame.count:SetText(format(L("%d steps / %d captured events"),
                                    #draft.steps, #draft.events))
    local preview = self:BuildGuide()
    if #preview > 3200 then preview = preview:sub(#preview - 3200) end
    self.frame.preview:SetText(preview)
    self.frame.start:SetText(self:IsRecording() and L("Stop") or L("Start"))
    if self.frame.reviewScroll and self.frame.reviewRows then
        local events = draft.events
        local visible = #self.frame.reviewRows
        FauxScrollFrame_Update(self.frame.reviewScroll, #events, visible, 22)
        local offset = FauxScrollFrame_GetOffset(self.frame.reviewScroll)
        for rowIndex, row in ipairs(self.frame.reviewRows) do
            -- Most recent captures appear first without changing persisted
            -- event ordering.
            local eventIndex = #events - (offset + rowIndex) + 1
            local event = events[eventIndex]
            row.event = event
            if event then
                local suggestion = self:BuildSuggestion(event)
                local state = event.promoted and "|cff40ff40+|r" or
                                  (event.ignored and "|cff888888-|r" or
                                      (suggestion and "|cffffd100?|r" or " "))
                row.check:SetChecked(event.selected == true)
                if event.promoted or event.ignored then
                    row.check:Disable()
                else
                    row.check:Enable()
                end
                row.text:SetText(format("%s %-20s %s", state,
                    tostring(event.kind or "event"),
                    tostring(suggestion or L("No safe directive inferred"))))
                row:Show()
            else
                row:Hide()
            end
        end
    end
end

local function Button(frame, text, width, callback)
    local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button:SetSize(width, 23)
    button:SetText(text)
    if addon.locale and addon.locale.AttachStatusTooltip then
        addon.locale.AttachStatusTooltip(button, text)
    end
    button:SetScript("OnClick", callback)
    return button
end

function recorder:CreateFrame()
    local frame = CreateFrame("Frame", "RXPGuideRecorder", UIParent)
    frame:SetSize(760, 600)
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
    title:SetText(L("Guide Author Recorder"))
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)
    frame.state = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.state:SetPoint("TOPLEFT", 24, -48)
    frame.count = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.count:SetPoint("TOPRIGHT", -24, -48)

    frame.start = Button(frame, L("Start"), 70, function()
        if recorder:IsRecording() then recorder:Stop() else recorder:Start() end
    end)
    frame.start:SetPoint("TOPLEFT", 24, -70)
    local newStep = Button(frame, L("New Step"), 82, function() recorder:NewStep() end)
    newStep:SetPoint("LEFT", frame.start, "RIGHT", 5, 0)
    local note = Button(frame, L("Add Note"), 82, function() recorder:PromptNote() end)
    note:SetPoint("LEFT", newStep, "RIGHT", 5, 0)
    local target = Button(frame, L("Add Target"), 88, function() recorder:AddTarget() end)
    target:SetPoint("LEFT", note, "RIGHT", 5, 0)
    local waypoint = Button(frame, L("Waypoint"), 82, function() recorder:AddWaypoint() end)
    waypoint:SetPoint("LEFT", target, "RIGHT", 5, 0)
    local undo = Button(frame, L("Undo"), 60, function() recorder:Undo() end)
    undo:SetPoint("LEFT", waypoint, "RIGHT", 5, 0)
    local validate = Button(frame, L("Validate"), 72, function() recorder:ValidateDraft() end)
    validate:SetPoint("LEFT", undo, "RIGHT", 5, 0)
    local export = Button(frame, L("Export"), 68, function() recorder:Preview() end)
    export:SetPoint("LEFT", validate, "RIGHT", 5, 0)
    local clear = Button(frame, L("Clear"), 58, function() recorder:Clear() end)
    clear:SetPoint("LEFT", export, "RIGHT", 5, 0)

    local reviewLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    reviewLabel:SetPoint("TOPLEFT", 28, -108)
    reviewLabel:SetText(L("Captured event review"))

    local reviewBox = CreateFrame("Frame", nil, frame)
    reviewBox:SetPoint("TOPLEFT", 24, -126)
    reviewBox:SetPoint("TOPRIGHT", -24, -126)
    reviewBox:SetHeight(184)
    reviewBox:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8",
                           edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                           tile = true, tileSize = 16, edgeSize = 12,
                           insets = {left = 3, right = 3, top = 3, bottom = 3}})
    reviewBox:SetBackdropColor(0.02, 0.02, 0.02, 0.92)
    local reviewScroll = CreateFrame("ScrollFrame", "RXPGuideRecorderReviewScroll",
                                     reviewBox, "FauxScrollFrameTemplate")
    reviewScroll:SetPoint("TOPLEFT", 8, -8)
    reviewScroll:SetPoint("BOTTOMRIGHT", -28, 38)
    reviewScroll:SetScript("OnVerticalScroll", function(this, offset)
        FauxScrollFrame_OnVerticalScroll(this, offset, 22,
                                          function() recorder:Refresh() end)
    end)
    frame.reviewScroll = reviewScroll
    frame.reviewRows = {}
    for index = 1, 6 do
        local row = CreateFrame("Button", nil, reviewBox)
        row:SetHeight(22)
        row:SetPoint("TOPLEFT", 10, -8 - (index - 1) * 22)
        row:SetPoint("RIGHT", -30, 0)
        row.check = CreateFrame("CheckButton", nil, row,
                                "UICheckButtonTemplate")
        row.check:SetSize(20, 20)
        row.check:SetPoint("LEFT")
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", row.check, "RIGHT", 2, 0)
        row.text:SetPoint("RIGHT", -2, 0)
        row.text:SetJustifyH("LEFT")
        row.check:SetScript("OnClick", function(button)
            if row.event and not row.event.promoted and
                not row.event.ignored then
                row.event.selected = button:GetChecked() == 1
            end
        end)
        row:SetScript("OnClick", function()
            if row.event and not row.event.promoted and
                not row.event.ignored then
                row.event.selected = not row.event.selected
                row.check:SetChecked(row.event.selected)
            end
        end)
        frame.reviewRows[index] = row
    end
    local addSelected = Button(reviewBox, L("Add Selected"), 105,
                               function() recorder:AddSelected() end)
    addSelected:SetPoint("BOTTOMLEFT", 10, 9)
    local addReviewed = Button(reviewBox, L("Add All Reviewed"), 125,
                               function() recorder:AddAllReviewed() end)
    addReviewed:SetPoint("LEFT", addSelected, "RIGHT", 6, 0)
    local ignore = Button(reviewBox, L("Ignore"), 75,
                          function() recorder:IgnoreSelected() end)
    ignore:SetPoint("LEFT", addReviewed, "RIGHT", 6, 0)
    local reviewPreview = Button(reviewBox, L("Preview"), 75,
                                 function() recorder:Preview() end)
    reviewPreview:SetPoint("LEFT", ignore, "RIGHT", 6, 0)

    local previewBox = CreateFrame("Frame", nil, frame)
    previewBox:SetPoint("TOPLEFT", 24, -322)
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
