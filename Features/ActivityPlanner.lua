local _, addon = ...

local _G = _G
local format = string.format
local time = _G.time
local L = addon.locale.Get

addon.activityPlanner = addon.activityPlanner or {}
local planner = addon.activityPlanner

local weeklyQuestIds = {
    24579, 24580, 24581, 24582, 24583, 24584,
    24585, 24586, 24587, 24588, 24589, 24590
}

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

local function SecondsUntilDailyReset()
    if type(_G.GetQuestResetTime) == "function" then
        local ok, seconds = pcall(_G.GetQuestResetTime)
        seconds = ok and tonumber(seconds)
        if seconds and seconds > 0 and seconds <= 172800 then return seconds end
    end
    local activePack = addon.compatibilityPacks and
                           addon.compatibilityPacks:GetActive()
    local seconds = activePack and activePack.resetPolicy and
                        tonumber(activePack.resetPolicy.dailyResetSeconds)
    if seconds and seconds > 0 and seconds <= 172800 then return seconds end
    return nil
end

local function ObservedWeeklyReset()
    local activePack = addon.compatibilityPacks and
                           addon.compatibilityPacks:GetActive()
    local policy = activePack and activePack.resetPolicy
    if policy and tonumber(policy.weeklyResetAt) and
        policy.weeklyResetAt > time() then
        return policy.weeklyResetAt
    end
    local seconds = policy and tonumber(policy.weeklyResetSeconds)
    if seconds and seconds > 0 and seconds <= 1209600 then
        return time() + seconds
    end
    if type(_G.GetNumSavedInstances) == "function" and
        type(_G.GetSavedInstanceInfo) == "function" then
        local best
        for index = 1, _G.GetNumSavedInstances() do
            local _, _, reset, difficulty, locked, extended, _, isRaid =
                _G.GetSavedInstanceInfo(index)
            reset = tonumber(reset)
            if isRaid and reset and reset > 86400 and
                (not best or reset < best) then best = reset end
        end
        if best then return time() + best end
    end
end

function planner:ResetIfNeeded()
    local data = RXPCData.activityPlanner
    local now = time()
    local seconds = SecondsUntilDailyReset()
    if not data.nextDailyReset and seconds then
        data.nextDailyReset = now + seconds
    elseif data.nextDailyReset and now >= data.nextDailyReset then
        data.dailyCompleted = {}
        data.nextDailyReset = seconds and now + seconds or nil
    end
    local weekly = ObservedWeeklyReset()
    if not data.nextWeeklyReset and weekly then
        data.nextWeeklyReset = weekly
    elseif data.nextWeeklyReset and now >= data.nextWeeklyReset then
        data.weeklyCompleted = {}
        data.nextWeeklyReset = weekly and weekly > now and weekly or nil
    end
end

function planner:BuildCatalog()
    if self.catalogBuilt then return end
    self.catalogBuilt = true
    self.catalog, self.dailyQuestLookup, self.weeklyQuestLookup = {}, {}, {}
    local cataloguedGuides = {}
    for group, list in pairs(addon.guideList or {}) do
        -- Daily content is identified by its directives, not by an English
        -- display-group name.  This also discovers Argent Tournament and any
        -- future validated daily guides while keeping the archived originals
        -- out of the live planner.
        if type(group) == "string" and
            not group:find("Original Guides", 1, true) then
            local realGroup = group:gsub("^[*+]", "")
            for _, name in ipairs(list.names_ or {}) do
                local guide = addon.GetGuideTable(realGroup, name) or
                                  addon.GetGuideTable(group, name)
                local guideIdentity = guide and (guide.key or
                    (realGroup .. "\031" .. tostring(name)))
                if guide and not cataloguedGuides[guideIdentity] and
                    not guide.internal and not guide.chapter then
                    guide = addon:FetchGuide(guide)
                    if guide and guide.steps then
                        local questIds, seen, reputationGated = {}, {}, false
                        for _, step in ipairs(guide.steps) do
                            for _, element in ipairs(step.elements or {}) do
                                if element.tag == "reputation" then
                                    reputationGated = true
                                end
                                local ids = element.ids or
                                                {element.questId or element.id}
                                if element.tag == "daily" or
                                    element.tag == "dailyturnin" then
                                    for _, rawId in ipairs(ids) do
                                        local id = tonumber(rawId)
                                        if id and not seen[id] then
                                            seen[id] = true
                                            table.insert(questIds, id)
                                            self.dailyQuestLookup[id] = true
                                        end
                                    end
                                end
                            end
                        end
                        if #questIds > 0 then
                            cataloguedGuides[guideIdentity] = true
                            table.insert(self.catalog, {
                                kind = "daily", guideKey = guide.key,
                                guide = guide,
                                name = addon.GetGuideName(guide) or guide.name,
                                questIds = questIds,
                                active = addon.IsGuideActive(guide),
                                reputationGated = reputationGated
                            })
                        end
                    end
                end
            end
        end
    end
    for _, id in ipairs(weeklyQuestIds) do self.weeklyQuestLookup[id] = true end
    table.insert(self.catalog, {
        kind = "weekly", name = L("Dalaran Weekly Raid Quest"),
        questIds = weeklyQuestIds, active = UnitLevel("player") >= 80
    })
    table.sort(self.catalog, function(a, b)
        if a.kind ~= b.kind then return a.kind == "daily" end
        return a.name < b.name
    end)
end

function planner:QuestTurnedIn(questId)
    questId = tonumber(questId)
    if not questId then return end
    self:BuildCatalog()
    if self.dailyQuestLookup[questId] then
        RXPCData.activityPlanner.dailyCompleted[questId] = time()
    elseif self.weeklyQuestLookup[questId] then
        RXPCData.activityPlanner.weeklyCompleted[questId] = time()
    end
    self:Refresh()
end

function planner:GetEntryState(entry)
    local completedTable = entry.kind == "weekly" and
        RXPCData.activityPlanner.weeklyCompleted or
        RXPCData.activityPlanner.dailyCompleted
    local completed, activeQuest = 0, 0
    for _, id in ipairs(entry.questIds) do
        if completedTable[id] or addon.IsQuestTurnedIn(id) then
            completed = completed + 1
        elseif addon.IsOnQuest(id) then
            activeQuest = activeQuest + 1
        end
    end
    -- The Dalaran weekly raid quests are alternatives: the server offers one
    -- from the pool, so completing any one finishes that week's activity.
    if entry.kind == "weekly" and completed > 0 then
        return "completed", completed
    end
    if completed == #entry.questIds then return "completed", completed end
    if activeQuest > 0 then return "active", activeQuest end
    if entry.kind == "weekly" then
        entry.active = UnitLevel("player") >= 80
    else
        entry.active = entry.guide and addon.IsGuideActive(entry.guide)
    end
    if not entry.active then
        return entry.reputationGated and "reputation" or "locked", 0
    end
    return "available", completed
end

local stateText = {
    completed = "|cff40ff40" .. L("Completed") .. "|r",
    active = "|cffffd100" .. L("Active") .. "|r",
    available = "|cff80c0ff" .. L("Available") .. "|r",
    reputation = "|cffcc79a7[REP] " .. L("Reputation gated") .. "|r",
    locked = "|cff888888" .. L("Locked") .. "|r"
}

function planner:Refresh()
    if not self.frame or not self.frame:IsShown() then return end
    self:ResetIfNeeded()
    self:BuildCatalog()
    local offset = FauxScrollFrame_GetOffset(self.frame.scroll)
    FauxScrollFrame_Update(self.frame.scroll, #self.catalog, 14, 27)
    for index, row in ipairs(self.frame.rows) do
        local entry = self.catalog[offset + index]
        row.entry = entry
        if entry then
            row:Show()
            local status = self:GetEntryState(entry)
            row.name:SetText(entry.name)
            row.state:SetText(stateText[status])
            if entry.guide and entry.active then row.open:Enable()
            else row.open:Disable() end
        else
            row:Hide()
        end
    end
    local daily = RXPCData.activityPlanner.nextDailyReset
    local weekly = RXPCData.activityPlanner.nextWeeklyReset
    self.frame.resetText:SetText(format(
        L("Daily reset: %s   Weekly reset: %s"),
        daily and date("%c", daily) or L("unknown"),
        weekly and date("%c", weekly) or L("unknown")))
end

function planner:OpenEntry(entry)
    if not entry or not entry.guide then return end
    addon.guideState:Load(entry.guide, false, "manual")
end

function planner:CreateFrame()
    local frame = CreateFrame("Frame", "RXPActivityPlanner", UIParent)
    frame:SetSize(650, 475)
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
    title:SetText(L("WotLK Daily & Weekly Planner"))
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)
    frame.rows = {}
    for index = 1, 14 do
        local row = CreateFrame("Frame", nil, frame)
        row:SetSize(600, 26)
        row:SetPoint("TOPLEFT", 26, -54 - (index - 1) * 27)
        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.name:SetPoint("LEFT", 2, 0)
        row.name:SetPoint("RIGHT", -190, 0)
        row.name:SetJustifyH("LEFT")
        row.state = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.state:SetPoint("LEFT", 420, 0)
        row.open = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.open:SetSize(82, 22)
        row.open:SetPoint("RIGHT", -1, 0)
        row.open:SetText(L("Continue"))
        row.open:SetScript("OnClick", function()
            planner:OpenEntry(row.entry)
        end)
        frame.rows[index] = row
    end
    frame.scroll = CreateFrame("ScrollFrame", "RXPActivityPlannerScroll", frame,
                               "FauxScrollFrameTemplate")
    frame.scroll:SetPoint("TOPLEFT", 20, -50)
    frame.scroll:SetPoint("BOTTOMRIGHT", -25, 52)
    frame.scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, 27,
                                         function() planner:Refresh() end)
    end)
    frame.resetText = frame:CreateFontString(nil, "OVERLAY",
                                              "GameFontHighlightSmall")
    frame.resetText:SetPoint("BOTTOMLEFT", 24, 24)
    local reset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    reset:SetSize(105, 22)
    reset:SetPoint("BOTTOMRIGHT", -24, 18)
    reset:SetText(L("Reset Weekly"))
    reset:SetScript("OnClick", function()
        addon.comms:ConfirmChoice("RXP_WEEKLY_RESET",
            L("Clear the locally tracked weekly completions?"), function()
                RXPCData.activityPlanner.weeklyCompleted = {}
                RXPCData.activityPlanner.nextWeeklyReset = ObservedWeeklyReset()
                planner:Refresh()
            end)
    end)
    frame:SetScript("OnShow", function() planner:Refresh() end)
    frame:Hide()
    self.frame = frame
    table.insert(_G.UISpecialFrames, "RXPActivityPlanner")
end

function planner:Toggle()
    if not self.frame then self:CreateFrame() end
    self.frame:SetShown(not self.frame:IsShown())
end

function planner:OnGuidesReady()
    self.catalogBuilt = nil
    self:BuildCatalog()
end

function planner:Setup()
    if self.setup then return end
    self.setup = true
    RXPCData.activityPlanner = type(RXPCData.activityPlanner) == "table" and
                                  RXPCData.activityPlanner or {}
    RXPCData.activityPlanner.dailyCompleted =
        type(RXPCData.activityPlanner.dailyCompleted) == "table" and
            RXPCData.activityPlanner.dailyCompleted or {}
    RXPCData.activityPlanner.weeklyCompleted =
        type(RXPCData.activityPlanner.weeklyCompleted) == "table" and
            RXPCData.activityPlanner.weeklyCompleted or {}
    self:ResetIfNeeded()
    self:CreateFrame()
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("QUEST_TURNED_IN")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:SetScript("OnEvent", function(_, event, questId)
        if event == "QUEST_TURNED_IN" then planner:QuestTurnedIn(questId)
        else planner:ResetIfNeeded() end
    end)
end
