local _, addon = ...
local L = addon.locale.Get

local _G = _G
local GetTime = _G.GetTime
local format = string.format
local PROTOCOL = 1
local STATE_INTERVAL = 1
local MEMBER_TIMEOUT = 10
local VISIBLE_ROWS = 8

addon.partySync = addon.partySync or {}
local sync = addon.partySync

local commands = {
    RXP_PARTY_HELLO = true,
    RXP_PARTY_STATE = true,
    RXP_PARTY_SUGGEST = true,
    RXP_PARTY_ACK = true,
    RXP_PARTY_LEAVE = true
}

local function IsGrouped()
    return _G.IsInGroup and _G.IsInGroup() and
               (not _G.UnitInBattleground or
                   _G.UnitInBattleground("player") == nil)
end

local function IsLeader()
    if _G.IsInRaid and _G.IsInRaid() then
        return (_G.UnitIsRaidOfficer and _G.UnitIsRaidOfficer("player")) or
                   (_G.UnitIsRaidLeader and _G.UnitIsRaidLeader("player"))
    end
    return _G.UnitIsPartyLeader and _G.UnitIsPartyLeader("player")
end

local function SenderUnit(sender)
    local count = _G.GetNumRaidMembers and _G.GetNumRaidMembers() or 0
    if count > 0 then
        for index = 1, count do
            local unit = "raid" .. index
            if _G.UnitName(unit) == sender then return unit end
        end
    else
        for index = 1, 4 do
            local unit = "party" .. index
            if _G.UnitName(unit) == sender then return unit end
        end
    end
end

local function IsSenderLeader(sender)
    local unit = SenderUnit(sender)
    if not unit then return false end
    if _G.IsInRaid and _G.IsInRaid() then
        return (_G.UnitIsRaidOfficer and _G.UnitIsRaidOfficer(unit)) or
                   (_G.UnitIsRaidLeader and _G.UnitIsRaidLeader(unit))
    end
    return _G.UnitIsPartyLeader and _G.UnitIsPartyLeader(unit)
end

function sync:IsEnabled()
    return addon.settings.profile.partyGuideSync == true
end

function sync:GetState()
    local guide = addon.currentGuide
    local step = guide and guide.steps and
                     guide.steps[RXPCData.currentStep or 1]
    local completed = step and step.completed == true or
                          addon.loadNextStep == true
    return {
        command = "RXP_PARTY_STATE",
        protocol = PROTOCOL,
        class = addon.player.class,
        level = UnitLevel("player"),
        guideKey = guide and guide.key,
        guideVersion = guide and guide.version,
        step = RXPCData.currentStep,
        stepId = step and step.stepId,
        complete = completed
    }
end

function sync:Broadcast(data, immediate, force)
    if (not force and not self:IsEnabled()) or not IsGrouped() or
        not addon.comms then return end
    local now = GetTime()
    if not immediate and self.lastBroadcast and
        now - self.lastBroadcast < STATE_INTERVAL then
        self.pendingBroadcast = true
        return
    end
    self.lastBroadcast = now
    self.pendingBroadcast = nil
    addon.comms:Broadcast(data)
end

function sync:SendState(immediate)
    local state = self:GetState()
    self.lastStateSignature = table.concat({tostring(state.guideKey or ""),
        tostring(state.stepId or state.step or ""),
        tostring(state.complete == true)}, ":")
    self.lastStateSent = GetTime()
    self:Broadcast(state, immediate)
end

function sync:RefreshPanel()
    if not self.frame then return end
    self.frame:SetShown(self:IsEnabled() and IsGrouped())
    if not self.frame:IsShown() then return end
    local members, seen = {}, {}
    local function AddUnit(unit)
        if not UnitExists(unit) then return end
        local name = UnitName(unit)
        if not name or seen[name] then return end
        seen[name] = true
        local data
        if unit == "player" or (_G.UnitIsUnit and _G.UnitIsUnit(unit, "player")) then
            data = self:GetState()
            data.lastSeen = GetTime()
            data.self = true
        else
            data = self.members[name]
            if data and GetTime() - (data.lastSeen or 0) > MEMBER_TIMEOUT then
                data = nil
            end
        end
        table.insert(members, {sender = name, data = data})
    end
    local raidCount = _G.GetNumRaidMembers and _G.GetNumRaidMembers() or 0
    if raidCount > 0 then
        for index = 1, raidCount do AddUnit("raid" .. index) end
    else
        AddUnit("player")
        for index = 1, 4 do AddUnit("party" .. index) end
    end
    table.sort(members, function(a, b) return a.sender < b.sender end)
    self.panelEntries = members
    local offset = self.frame.scroll and
                       FauxScrollFrame_GetOffset(self.frame.scroll) or 0
    if self.frame.scroll then
        FauxScrollFrame_Update(self.frame.scroll, #members, VISIBLE_ROWS, 20)
    end
    for index, row in ipairs(self.frame.rows) do
        local member = members[offset + index]
        if member then
            row:Show()
            local data = member.data
            local state = not data and "|cff999999[?] Unknown|r" or
                (data.complete and "|cff40ff40[+] Ready|r" or
                    "|cffffd100[~] Working|r")
        row:SetText(format(L("%s  %s  step %s"), member.sender, state,
                               tostring(data and data.step or "?")))
        else
            row:Hide()
        end
    end
    self.frame.title:SetText(format(L("Party Guide Sync (%d)"), #members))
end

function sync:HandleMessage(obj, sender)
    if not commands[obj.command] then return false end
    if not self:IsEnabled() or obj.protocol ~= PROTOCOL or not IsGrouped() then
        return true
    end
    if obj.command == "RXP_PARTY_HELLO" then
        self:SendState(true)
    elseif obj.command == "RXP_PARTY_STATE" then
        self.members[sender] = {
            class = type(obj.class) == "string" and obj.class or nil,
            level = tonumber(obj.level),
            guideKey = type(obj.guideKey) == "string" and obj.guideKey or nil,
            guideVersion = tonumber(obj.guideVersion),
            step = tonumber(obj.step),
            stepId = tonumber(obj.stepId) or obj.stepId,
            complete = obj.complete == true,
            lastSeen = GetTime()
        }
    elseif obj.command == "RXP_PARTY_SUGGEST" then
        if not IsSenderLeader(sender) or type(obj.guideKey) ~= "string" or
            not tonumber(obj.step) then return true end
        self:ShowSuggestion(sender, obj)
    elseif obj.command == "RXP_PARTY_ACK" then
        local member = self.members[sender] or {}
        self.members[sender] = member
        member.lastAck = obj.accepted == true
        member.lastSeen = GetTime()
    elseif obj.command == "RXP_PARTY_LEAVE" then
        self.members[sender] = nil
    end
    self:RefreshPanel()
    return true
end

local function FindGuideByKey(key)
    for group, list in pairs(addon.guideList or {}) do
        local realGroup = group:gsub("^[*+]", "")
        for _, name in ipairs(list.names_ or {}) do
            local guide = addon.GetGuideTable(realGroup, name) or
                              addon.GetGuideTable(group, name)
            if guide and guide.key == key then return guide end
        end
    end
end

function sync:ShowSuggestion(sender, suggestion)
    self.pendingSuggestion = {
        sender = sender,
        guideKey = suggestion.guideKey,
        guideVersion = tonumber(suggestion.guideVersion),
        step = math.floor(tonumber(suggestion.step)),
        expires = GetTime() + 30
    }
    StaticPopupDialogs.RXP_PARTY_SUGGESTION = {
        text = format(L("%s suggests guide %s%s at step %d. Apply it?"), sender,
                      suggestion.guideKey,
                      suggestion.guideVersion and
                          (" (v" .. suggestion.guideVersion .. ")") or "",
                      suggestion.step),
        button1 = _G.YES,
        button2 = _G.NO,
        timeout = 30,
        whileDead = 1,
        hideOnEscape = 1,
        OnAccept = function(_, data)
            if GetTime() > data.expires or not IsSenderLeader(data.sender) then
                return
            end
            local guide = FindGuideByKey(data.guideKey)
            if not guide then return end
            addon.guideState:Load(guide, true, "manual")
            addon.GoToStep(data.step)
            sync:Broadcast({command = "RXP_PARTY_ACK", protocol = PROTOCOL,
                            accepted = true}, true)
        end,
        OnCancel = function(_, data)
            if data then
                sync:Broadcast({command = "RXP_PARTY_ACK", protocol = PROTOCOL,
                                accepted = false}, true)
            end
        end
    }
    StaticPopup_Show("RXP_PARTY_SUGGESTION", nil, nil,
                     self.pendingSuggestion)
end

function sync:SuggestCurrent()
    if not self:IsEnabled() or not IsLeader() or not addon.currentGuide or
        addon.currentGuide.empty then return false end
    local step = addon.currentGuide.steps and
                     addon.currentGuide.steps[RXPCData.currentStep or 1]
    if not step then return false end
    self:Broadcast({
        command = "RXP_PARTY_SUGGEST",
        protocol = PROTOCOL,
        guideKey = addon.currentGuide.key,
        guideVersion = addon.currentGuide.version,
        step = RXPCData.currentStep,
        stepId = step.stepId
    }, true)
    return true
end

function sync:ShouldHoldAdvance()
    if not self:IsEnabled() or not addon.settings.profile.partyGuideWait then
        return false
    end
    local guide = addon.currentGuide
    local token = guide and guide.key .. ":" .. tostring(RXPCData.currentStep)
    if token and self.overrideStepToken == token then
        self.overrideStepToken = nil
        return false
    end
    local now, participants = GetTime(), 0
    for _, data in pairs(self.members or {}) do
        if now - (data.lastSeen or 0) <= MEMBER_TIMEOUT and guide and
            data.guideKey == guide.key and data.step == RXPCData.currentStep then
            participants = participants + 1
            if not data.complete then return true end
        end
    end
    return false
end

function sync:OverrideWaitOnce()
    local guide = addon.currentGuide
    if guide and not guide.empty then
        self.overrideStepToken = guide.key .. ":" .. tostring(RXPCData.currentStep)
    end
end

function sync:HandleCommand(input)
    local argument = input:match("^party%s+(%S+)")
    if argument == "on" then
        addon.settings.profile.partyGuideSync = true
        self:Broadcast({command = "RXP_PARTY_HELLO", protocol = PROTOCOL}, true)
        self:SendState(true)
    elseif argument == "off" then
        self:Broadcast({command = "RXP_PARTY_LEAVE", protocol = PROTOCOL}, true,
                       true)
        addon.settings.profile.partyGuideSync = false
        self.members = {}
    elseif argument == "wait" then
        addon.settings.profile.partyGuideWait =
            not addon.settings.profile.partyGuideWait
    elseif argument == "suggest" then
        if not self:SuggestCurrent() then
            addon.comms.PrettyPrint("Only the party or raid leader can suggest the current step.")
        end
    else
        addon.comms.PrettyPrint(
            "Party sync: %s; wait: %s. Use /rxp party on|off|wait|suggest.",
            tostring(self:IsEnabled()),
            tostring(addon.settings.profile.partyGuideWait == true))
    end
    self:RefreshPanel()
end

function sync:CreatePanel()
    local frame = CreateFrame("Frame", "RXPPartySyncFrame", UIParent)
    frame:SetSize(330, 238)
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, -220)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                       edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                       tile = true, tileSize = 16, edgeSize = 16,
                       insets = {left = 4, right = 4, top = 4, bottom = 4}})
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOP", 0, -12)
    frame.rows = {}
    for index = 1, VISIBLE_ROWS do
        local row = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row:SetPoint("TOPLEFT", 14, -30 - (index - 1) * 20)
        row:SetPoint("RIGHT", -14, 0)
        row:SetJustifyH("LEFT")
        frame.rows[index] = row
    end
    frame.scroll = CreateFrame("ScrollFrame", "RXPPartySyncScroll", frame,
                               "FauxScrollFrameTemplate")
    frame.scroll:SetPoint("TOPLEFT", 8, -28)
    frame.scroll:SetPoint("BOTTOMRIGHT", -28, 47)
    frame.scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, 20,
                                         function() sync:RefreshPanel() end)
    end)
    local suggest = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    suggest:SetSize(110, 22)
    suggest:SetPoint("BOTTOMLEFT", 12, 10)
    suggest:SetText(L("Suggest Step"))
    suggest:SetScript("OnClick", function() sync:SuggestCurrent() end)
    local wait = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    wait:SetSize(110, 22)
    wait:SetPoint("BOTTOMRIGHT", -12, 10)
    wait:SetText(L("Toggle Wait"))
    wait:SetScript("OnClick", function()
        addon.settings.profile.partyGuideWait =
            not addon.settings.profile.partyGuideWait
    end)
    local advance = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    advance:SetSize(84, 22)
    advance:SetPoint("BOTTOM", 0, 10)
    advance:SetText(L("Advance Once"))
    advance:SetScript("OnClick", function()
        sync:OverrideWaitOnce()
        addon.loadNextStep = true
    end)
    frame:Hide()
    self.frame = frame
end

function sync:Setup()
    if self.setup then return end
    self.setup = true
    self.members = {}
    self:CreatePanel()
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
    self.eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:SetScript("OnEvent", function()
        sync.pendingSuggestion = nil
        if _G.StaticPopup_Hide then _G.StaticPopup_Hide("RXP_PARTY_SUGGESTION") end
        if sync:IsEnabled() and IsGrouped() then
            sync:Broadcast({command = "RXP_PARTY_HELLO", protocol = PROTOCOL},
                           true)
            sync:SendState(true)
        elseif not IsGrouped() then
            sync.members = {}
        end
        sync:RefreshPanel()
    end)
    self.stepCallback = function() sync:SendState(true) end
    addon:RegisterMessage("RXP_STEP_ACTIVATED", self.stepCallback)
    self.ticker = C_Timer.NewTicker(1, function()
        if sync:IsEnabled() and IsGrouped() then
            local state = sync:GetState()
            local signature = table.concat({tostring(state.guideKey or ""),
                tostring(state.stepId or state.step or ""),
                tostring(state.complete == true)}, ":")
            if signature ~= sync.lastStateSignature then
                sync:SendState(true)
            elseif sync.pendingBroadcast or
                GetTime() - (sync.lastStateSent or 0) >= 5 then
                sync:SendState(false)
            end
        end
        sync:RefreshPanel()
    end)
    self:RefreshPanel()
end
