local _, addon = ...

local _G = _G
local lower = string.lower
local format = string.format
local L = addon.locale.Get

addon.guideHub = addon.guideHub or {}
local hub = addon.guideHub
local ROW_HEIGHT = 28
local VISIBLE_ROWS = 12

local classes = {
    WARRIOR = true, PALADIN = true, HUNTER = true, ROGUE = true,
    PRIEST = true, DEATHKNIGHT = true, SHAMAN = true, MAGE = true,
    WARLOCK = true, DRUID = true, DK = true
}
local factions = {ALLIANCE = true, HORDE = true}

local function ConditionAllows(condition, own, universe)
    if type(condition) ~= "string" or condition == "" then return true, false end
    own = tostring(own or ""):upper()
    local ownTokens = {[own] = true}
    if own == "DEATHKNIGHT" then ownTokens.DK = true end
    local mentioned = false
    for branch in condition:gmatch("[^/]+") do
        local allowed = true
        for token in branch:gmatch("!?[%w%d]+") do
            local denied = token:sub(1, 1) == "!"
            local value = (denied and token:sub(2) or token):upper()
            if universe[value] then
                mentioned = true
                local matches = ownTokens[value] == true
                if matches and denied or not matches and not denied then
                    allowed = false
                    break
                end
            end
        end
        if allowed then return true, mentioned end
    end
    return false, mentioned
end

local function GuideKey(guide)
    return guide and (guide.key or addon.BuildGuideKey(guide))
end

local function DisplayName(guide)
    return addon.GetGuideName(guide) or guide.displayname or guide.name or
               L("Unnamed guide")
end

local function Availability(guide)
    if not guide or guide.empty then return false, L("Guide data unavailable") end
    if guide.disabled then return false, L("Disabled by this guide version") end
    if guide.internal then return false, L("Internal chapter") end
    if guide.farm and addon.goldAssistant and
        addon.goldAssistant.IsGuideCompatible then
        local compatible, reason = addon.goldAssistant:IsGuideCompatible(guide)
        if not compatible then return false, reason end
    end
    if addon.IsGuideActive and not addon.IsGuideActive(guide) then
        local condition = type(guide.enabledFor) == "string" and
                              guide.enabledFor or ""
        local factionAllowed, factionMentioned = ConditionAllows(condition,
            addon.player.faction, factions)
        if factionMentioned and not factionAllowed then
            return false, L("Unavailable to the current faction")
        end
        local classAllowed, classMentioned = ConditionAllows(condition,
            addon.player.class, classes)
        if classMentioned and not classAllowed then
            return false, L("Unavailable to the current class")
        end
        return false, L("Current level, XP rate, mode, race, or guide condition is not met")
    end
    return true
end

local function BuildGuideList()
    local output, seen = {}, {}
    for group, list in pairs(addon.guideList or {}) do
        local realGroup = group:gsub("^[*+]", "")
        for _, name in ipairs(list.names_ or {}) do
            local guide = addon.GetGuideTable(realGroup, name) or
                              addon.GetGuideTable(group, name)
            local key = GuideKey(guide)
            local modeMatches = guide and
                ((RXPCData and RXPCData.GA and guide.farm) or
                    (not (RXPCData and RXPCData.GA) and not guide.farm))
            if key and modeMatches and not seen[key] then
                seen[key] = true
                local active, reason = Availability(guide)
                table.insert(output, {
                    guide = guide,
                    key = key,
                    group = group,
                    name = DisplayName(guide),
                    active = active,
                    reason = reason
                })
            end
        end
    end
    table.sort(output, function(a, b)
        if a.group ~= b.group then return a.group < b.group end
        local amin = tonumber((a.guide.name or ""):match("^(%d+)")) or 999
        local bmin = tonumber((b.guide.name or ""):match("^(%d+)")) or 999
        if amin ~= bmin then return amin < bmin end
        return a.name < b.name
    end)
    return output
end

function hub:GetFilteredGuides()
    local search = self.searchText and lower(self.searchText) or ""
    local favoritesOnly = self.favoritesOnly
    local recentOnly = self.recentOnly
    local recent = {}
    for index, key in ipairs(RXPCData.recentGuides or {}) do recent[key] = index end
    local result = {}
    for _, entry in ipairs(self.guides or {}) do
        local favorite = RXPData.guideHub.favorites[entry.key]
        local textMatch = search == "" or
            lower(entry.name):find(search, 1, true) or
            lower(entry.group):find(search, 1, true)
        local guide = entry.guide
        local condition = type(guide.enabledFor) == "string" and
                              guide.enabledFor or ""
        local factionAllowed = ConditionAllows(condition, addon.player.faction,
                                                 factions)
        local factionMatch = self.factionFilter == "all" or factionAllowed
        local classAllowed = ConditionAllows(condition, addon.player.class,
                                               classes)
        local classMatch = self.classFilter == "all" or classAllowed
        local low, high = tostring(guide.name or entry.name):match("(%d+)%s*%-%s*(%d+)")
        low, high = tonumber(low), tonumber(high)
        local level = UnitLevel("player") or 1
        local levelMatch = self.levelFilter == "all" or not low or
                               (level >= low and level <= high)
        local availabilityMatch = self.availabilityFilter == "all" or
            (self.availabilityFilter == "available" and entry.active) or
            (self.availabilityFilter == "unavailable" and not entry.active)
        if textMatch and factionMatch and classMatch and levelMatch and
            availabilityMatch and (not favoritesOnly or favorite) and
            (not recentOnly or recent[entry.key]) then
            entry.favorite = favorite
            entry.recentIndex = recent[entry.key]
            table.insert(result, entry)
        end
    end
    if recentOnly then
        table.sort(result, function(a, b)
            return (a.recentIndex or 99) < (b.recentIndex or 99)
        end)
    end
    return result
end

function hub:Select(entry)
    self.selected = entry
    if self.frame then
        local enabled = entry and entry.active
        if enabled then
            self.frame.continue:Enable()
            self.frame.restart:Enable()
            self.frame.chooseStep:Enable()
            self.frame.findStart:Enable()
        else
            self.frame.continue:Disable()
            self.frame.restart:Disable()
            self.frame.chooseStep:Disable()
            self.frame.findStart:Disable()
        end
        self.frame.status:SetText(entry and
            (entry.reason or format("%s / %s", entry.group, entry.name)) or
            "Select a guide")
    end
    self:RefreshRows()
end

function hub:LoadSelected(restart)
    if not self.selected or not self.selected.active then return end
    addon.guideState:Load(self.selected.guide, restart, "manual")
end

function hub:ChooseStep()
    if not self.selected or not self.selected.active then return end
    StaticPopupDialogs.RXP_GUIDE_HUB_STEP = {
        text = L("Enter a step number for %s"),
        button1 = _G.ACCEPT,
        button2 = _G.CANCEL,
        hasEditBox = 1,
        maxLetters = 5,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        OnShow = function(frame)
            frame.editBox:SetText("1")
            frame.editBox:SetFocus()
        end,
        OnAccept = function(frame, data)
            local requested = tonumber(frame.editBox:GetText())
            local guide = data and data.guide
            if not requested or not guide then return end
            guide = addon:FetchGuide(guide)
            if not guide or not guide.steps then return end
            requested = math.max(1, math.min(#guide.steps,
                                             math.floor(requested)))
            addon.guideState:Load(guide, true, "manual")
            addon.GoToStep(requested)
        end
    }
    StaticPopup_Show("RXP_GUIDE_HUB_STEP", self.selected.name, nil,
                     self.selected)
end

function hub:ToggleFavorite(entry)
    if not entry then return end
    local favorites = RXPData.guideHub.favorites
    favorites[entry.key] = not favorites[entry.key] or nil
    self:Refresh()
end

function hub:RefreshRows()
    if not self.frame or not self.frame:IsShown() then return end
    local filtered = self.filtered or {}
    local offset = FauxScrollFrame_GetOffset(self.frame.scroll)
    FauxScrollFrame_Update(self.frame.scroll, #filtered, VISIBLE_ROWS,
                           ROW_HEIGHT)
    for index, row in ipairs(self.frame.rows) do
        local entry = filtered[offset + index]
        row.entry = entry
        if entry then
            row:Show()
            row.name:SetText(entry.name)
            row.group:SetText(entry.group:gsub("^[*+]", ""))
            row.favorite:SetText(entry.favorite and "|cffffd100*|r" or "+")
            if entry.active then
                row.name:SetTextColor(1, 0.82, 0)
                row.group:SetTextColor(0.7, 0.7, 0.7)
            else
                row.name:SetTextColor(0.45, 0.45, 0.45)
                row.group:SetTextColor(0.35, 0.35, 0.35)
            end
            row.selected:SetShown(self.selected and
                                      self.selected.key == entry.key)
        else
            row:Hide()
        end
    end
end

function hub:Refresh()
    if not RXPData or not RXPCData then return end
    self.guides = BuildGuideList()
    self.filtered = self:GetFilteredGuides()
    if self.frame then
        self.frame.count:SetText(format(L("%d guides"), #self.filtered))
        self:RefreshRows()
    end
end

local function CreateButton(parent, text, width)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 24)
    button:SetText(text)
    return button
end

function hub:CreateFrame()
    if self.frame then return self.frame end
    local frame = CreateFrame("Frame", "RXPGuideHub", UIParent)
    frame:SetSize(680, 500)
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
    title:SetPoint("TOP", 0, -17)
    title:SetText(L("RXPGuides Guide Hub"))
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)

    local search = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    search:SetSize(260, 24)
    search:SetPoint("TOPLEFT", 24, -50)
    search:SetAutoFocus(false)
    search:SetTextInsets(6, 6, 0, 0)
    search:SetScript("OnTextChanged", function(box)
        hub.searchText = box:GetText()
        hub.filtered = hub:GetFilteredGuides()
        FauxScrollFrame_SetOffset(frame.scroll, 0)
        hub:RefreshRows()
        frame.count:SetText(format(L("%d guides"), #hub.filtered))
    end)

    local favorites = CreateButton(frame, L("Favorites"), 105)
    favorites:SetPoint("LEFT", search, "RIGHT", 12, 0)
    favorites:SetScript("OnClick", function()
        hub.favoritesOnly = not hub.favoritesOnly
        favorites:SetText(hub.favoritesOnly and L("All guides") or L("Favorites"))
        hub:Refresh()
    end)
    local recent = CreateButton(frame, L("Recent"), 90)
    recent:SetPoint("LEFT", favorites, "RIGHT", 8, 0)
    recent:SetScript("OnClick", function()
        hub.recentOnly = not hub.recentOnly
        recent:SetText(hub.recentOnly and L("All") or L("Recent"))
        hub:Refresh()
    end)

    local function FilterButton(text, width, relative, update)
        local button = CreateButton(frame, text, width)
        button:SetPoint("TOPLEFT", relative, "BOTTOMLEFT", 0, -7)
        button:SetScript("OnClick", function()
            update(button)
            local prefs = RXPData.guideHub.filters
            prefs.faction = hub.factionFilter
            prefs.class = hub.classFilter
            prefs.level = hub.levelFilter
            prefs.availability = hub.availabilityFilter
            hub:Refresh()
        end)
        return button
    end
    local factionFilter = FilterButton(hub.factionFilter == "all" and
        L("Faction: All") or L("Faction: Current"), 130, search,
        function(button)
            hub.factionFilter = hub.factionFilter == "all" and "current" or "all"
            button:SetText(hub.factionFilter == "all" and L("Faction: All") or L("Faction: Current"))
        end)
    local classFilter = FilterButton(hub.classFilter == "all" and
        L("Class: All") or L("Class: Current"), 120, factionFilter,
        function(button)
            hub.classFilter = hub.classFilter == "all" and "current" or "all"
            button:SetText(hub.classFilter == "all" and L("Class: All") or L("Class: Current"))
        end)
    classFilter:ClearAllPoints()
    classFilter:SetPoint("LEFT", factionFilter, "RIGHT", 7, 0)
    local levelFilter = FilterButton(hub.levelFilter == "all" and
        L("Level: All") or L("Level: Current"), 120, classFilter,
        function(button)
            hub.levelFilter = hub.levelFilter == "all" and "current" or "all"
            button:SetText(hub.levelFilter == "all" and L("Level: All") or L("Level: Current"))
        end)
    levelFilter:ClearAllPoints()
    levelFilter:SetPoint("LEFT", classFilter, "RIGHT", 7, 0)
    local availabilityLabel = hub.availabilityFilter == "available" and
                                  L("Available") or
                                  (hub.availabilityFilter == "unavailable" and
                                      L("Unavailable") or L("All"))
    local availabilityFilter = FilterButton(L("Availability: ") ..
        availabilityLabel, 145, levelFilter,
        function(button)
            local current = hub.availabilityFilter
            hub.availabilityFilter = current == "all" and "available" or
                                         (current == "available" and "unavailable" or "all")
            local label = hub.availabilityFilter == "all" and L("All") or
                              (hub.availabilityFilter == "available" and L("Available") or L("Unavailable"))
            button:SetText(L("Availability: ") .. label)
        end)
    availabilityFilter:ClearAllPoints()
    availabilityFilter:SetPoint("LEFT", levelFilter, "RIGHT", 7, 0)

    frame.count = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.count:SetPoint("TOPRIGHT", -26, -113)
    local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", 28, -114)
    header:SetText(L("Guide"))

    local scroll = CreateFrame("ScrollFrame", "RXPGuideHubScroll", frame,
                               "FauxScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 24, -132)
    scroll:SetPoint("BOTTOMRIGHT", -47, 92)
    scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT,
                                         function() hub:RefreshRows() end)
    end)
    frame.scroll = scroll
    frame.rows = {}
    for index = 1, VISIBLE_ROWS do
        local row = CreateFrame("Button", nil, frame)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", 26, -134 - (index - 1) * ROW_HEIGHT)
        row:SetPoint("RIGHT", -50, 0)
        row.selected = row:CreateTexture(nil, "BACKGROUND")
        row.selected:SetAllPoints()
        row.selected:SetTexture(0.2, 0.35, 0.55, 0.55)
        row.selected:Hide()
        row.favorite = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        row.favorite:SetPoint("LEFT", 4, 0)
        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.name:SetPoint("LEFT", 28, 6)
        row.name:SetPoint("RIGHT", -8, 6)
        row.name:SetJustifyH("LEFT")
        row.group = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.group:SetPoint("LEFT", 28, -7)
        row.group:SetPoint("RIGHT", -8, -7)
        row.group:SetJustifyH("LEFT")
        row:SetScript("OnClick", function(self, button)
            if button == "RightButton" then
                hub:ToggleFavorite(self.entry)
            else
                hub:Select(self.entry)
            end
        end)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        frame.rows[index] = row
    end

    frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.status:SetPoint("BOTTOMLEFT", 25, 68)
    frame.status:SetPoint("BOTTOMRIGHT", -25, 68)
    frame.status:SetJustifyH("LEFT")
    frame.status:SetText(L("Select a guide"))
    frame.continue = CreateButton(frame, "Continue", 110)
    frame.continue:SetPoint("BOTTOMLEFT", 24, 26)
    frame.continue:SetScript("OnClick", function() hub:LoadSelected(false) end)
    frame.restart = CreateButton(frame, "Restart", 100)
    frame.restart:SetPoint("LEFT", frame.continue, "RIGHT", 8, 0)
    frame.restart:SetScript("OnClick", function()
        if not hub.selected then return end
        addon.comms:ConfirmChoice("RXP_GUIDE_HUB_RESTART",
            "Restart " .. hub.selected.name .. " from step 1?",
            function() hub:LoadSelected(true) end)
    end)
    frame.chooseStep = CreateButton(frame, "Choose Step", 115)
    frame.chooseStep:SetPoint("LEFT", frame.restart, "RIGHT", 8, 0)
    frame.chooseStep:SetScript("OnClick", function() hub:ChooseStep() end)
    frame.findStart = CreateButton(frame, "Find Start", 105)
    frame.findStart:SetPoint("LEFT", frame.chooseStep, "RIGHT", 8, 0)
    frame.findStart:SetScript("OnClick", function()
        if not hub.selected or not hub.selected.active or not addon.catchUp then
            return
        end
        local guide = addon:FetchGuide(hub.selected.guide)
        addon.catchUp:Preview(guide)
    end)
    local backup = CreateButton(frame, "Backup", 95)
    backup:SetPoint("BOTTOMRIGHT", -24, 26)
    backup:SetScript("OnClick", function() addon.roadmap:OpenBackupWindow() end)
    frame.continue:Disable()
    frame.restart:Disable()
    frame.chooseStep:Disable()
    frame.findStart:Disable()
    frame:SetScript("OnShow", function() hub:Refresh() end)
    frame:Hide()
    self.frame = frame
    table.insert(_G.UISpecialFrames, "RXPGuideHub")
    return frame
end

function hub:Setup()
    RXPData.guideHub.filters = type(RXPData.guideHub.filters) == "table" and
                                   RXPData.guideHub.filters or {}
    local filters = RXPData.guideHub.filters
    self.factionFilter = filters.faction == "all" and "all" or "current"
    self.classFilter = filters.class == "all" and "all" or "current"
    self.levelFilter = filters.level == "current" and "current" or "all"
    self.availabilityFilter = filters.availability == "available" and
                                  "available" or
                                  (filters.availability == "unavailable" and
                                      "unavailable" or "all")
    self:CreateFrame()
    self.setup = true
end

function hub:OnGuidesReady()
    self:Refresh()
end

function hub:Toggle()
    local frame = self:CreateFrame()
    frame:SetShown(not frame:IsShown())
end
