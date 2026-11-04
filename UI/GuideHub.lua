local addonName, addon = ...

local _G = _G
local lower = string.lower
local format = string.format
local L = addon.locale.Get

-- The tab controller is a required part of both hub presentations. Define it
-- in this established manifest chunk so an updated hub cannot be loaded without
-- its controller (including clients retaining an older manifest file list).
do
    local tabs = {}
    addon.libraryTabs = tabs
    local L = addon.locale.Get
    local names = {"Guides", "Feature Tools", "Settings", "Import"}

    -- Shared options-icon shortcut; callers retain their existing menu and
    -- left-click behavior when this returns false. Toggle the whole hub,
    -- regardless of its selected tab; reopening starts on Guides.
    function tabs:OpenFromOptions(button)
        if button ~= "RightButton" or IsShiftKeyDown() then return false end
        if _G.CloseDropDownMenus then _G.CloseDropDownMenus() end
        if self.window and self.window:IsShown() then
            self.window:Hide()
        else
            self:Open("Guides")
        end
        return true
    end

    -- Only presentation state lives here. In particular, tab selection is never
    -- written to a profile or a guide checkpoint.
    function tabs:GuidePage(window)
        local page = CreateFrame("Frame", nil, window)
        page:SetPoint("TOPLEFT", 0, -36)
        page:SetPoint("BOTTOMRIGHT", 0, 0)
        return page
    end

    function tabs:Attach(window, guides)
        self.window, self.pages, self.buttons = window, {Guides = guides}, {}
        addon.toolWindows:SetEscapeClose(window, true)
        self.selected = self.selected or "Guides"
        for i, name in ipairs(names) do
            local button = addon.presentation:Button(window, L(name), 145, function() tabs:Open(name) end)
            addon.guideHub:AttachTooltip(button, name)
            button:SetPoint("TOPLEFT", 18 + (i - 1) * 153, -40)
            self.buttons[name] = button
        end
        window:HookScript("OnHide", function()
            tabs:ClearFocus()
            GameTooltip:Hide()
        end)
        window:HookScript("OnShow", function()
            addon.toolWindows:SetEscapeClose(window, true)
            tabs:RefreshVisible()
        end)
        window:HookScript("OnSizeChanged", function() tabs:SizeContainers() end)
        -- The library's own OnToolVisuals remains responsible for guide cards.
        local visuals = window.OnToolVisuals
        window.OnToolVisuals = function(...)
            if visuals then visuals(...) end
            for _, button in pairs(tabs.buttons) do addon.presentation:SkinControl(button) end
            if addon.featureToolsUI then addon.featureToolsUI:Refresh() end
        end
        for name, page in pairs(self.pages) do page:SetShown(name == self.selected) end
    end

    function tabs:ClearFocus()
        if addon.guideHub.frame.search then addon.guideHub.frame.search:ClearFocus() end
        local gui = LibStub("AceGUI-3.0")
        gui:ClearFocus()
    end

    function tabs:HookEditorEscape(widget)
        local editor = widget and (widget.editbox or widget.editBox)
        if editor and not editor.rxpLibraryEscapeHook then
            editor.rxpLibraryEscapeHook = true
            editor:HookScript("OnEscapePressed", function(self)
                -- AceGUI editors are pooled. Only close our hub while this
                -- editor actually belongs to it, never a later borrower.
                local parent = self
                while parent do
                    if parent == tabs.window then tabs.window:Hide(); return end
                    parent = parent:GetParent()
                end
            end)
        end
        for _, child in ipairs(widget and widget.children or {}) do self:HookEditorEscape(child) end
    end

    function tabs:SizeContainers()
        if self.sizing then return end
        self.sizing = true
        for _, page in pairs(self.pages or {}) do
            if page.widget then
                page.widget:SetWidth(math.max(100, page:GetWidth()))
                page.status:SetWidth(math.max(100, page:GetWidth() - 8))
                local statusHeight = page.status:GetText() ~= "" and page.status:GetStringHeight() + 8 or 0
                page.widget:SetHeight(math.max(100, page:GetHeight() - statusHeight))
                page.widget:DoLayout()
            end
        end
        self.sizing = nil
    end

    -- Native AceConfig callbacks rebuild their own custom container directly.
    -- Observe only our root's layout, never hook a library or replace an option
    -- setter. Synchronize the independently registered fallback when it is visible.
    function tabs:NativeRendered(name)
        if self.rendering or self.sizing then return end
        addon.scheduler:After(self, "fallback-" .. name, 0, function()
            local panel = name == "Import" and addon.settings.gui.import or addon.RXPOptions
            if not (panel and panel.obj and panel.obj.frame:IsVisible()) then return end
            self.rendering = true
            local app = name == "Import" and addon.RXPOptions.name .. "/Import" or addon.title
            local ok, err = pcall(LibStub("AceConfigDialog-3.0").Open, LibStub("AceConfigDialog-3.0"), app, panel.obj)
            self.rendering = nil
            if name == "Import" and addon.settings.textboxHook then addon.settings.textboxHook(panel.obj) end
            if not ok then geterrorhandler()(err) end
        end)
    end

    function tabs:Page(name)
        if self.pages[name] then return self.pages[name] end
        local page = CreateFrame("Frame", nil, self.window)
        page:Hide()
        page:SetPoint("TOPLEFT", 16, -78)
        page:SetPoint("BOTTOMRIGHT", -16, 18)
        self.pages[name] = page
        if name == "Feature Tools" then
            addon.featureToolsUI:Create(page)
        else
            local widget = LibStub("AceGUI-3.0"):Create("SimpleGroup")
            page.status = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            page.status:SetPoint("BOTTOMLEFT", 4, 0)
            page.status:SetJustifyH("LEFT")
            page.status:SetText("")
            widget.SetStatusText = function(_, text)
                page.status:SetText(text or "")
                tabs:SizeContainers()
            end
            widget:SetLayout("Fill")
            widget.noAutoHeight = true
            widget.frame:SetParent(page)
            -- AceGUI descendants are pooled with other addon interfaces. Never
            -- attach persistent tool-window mouse hooks to those borrowed frames.
            widget.frame.rxpPooledContent = true
            widget.frame:SetFrameStrata(self.window:GetFrameStrata())
            widget.frame:SetFrameLevel(page:GetFrameLevel() + 1)
            widget.frame:ClearAllPoints()
            widget.frame:SetPoint("TOPLEFT")
            local finished = widget.LayoutFinished
            widget.LayoutFinished = function(self, ...)
                if finished then finished(self, ...) end
                tabs:HookEditorEscape(self)
                if name == "Import" and addon.settings.textboxHook then addon.settings.textboxHook(self) end
                tabs:NativeRendered(name)
            end
            page.widget, page.dirty = widget, true
            page:SetScript("OnSizeChanged", function() tabs:SizeContainers() end)
        end
        addon.toolWindows:RefreshLayering()
        return page
    end

    function tabs:RefreshVisible()
        if not self.window or not self.window:IsShown() then return end
        local page = self.pages[self.selected]
        if not page then return end
        if self.selected == "Guides" then addon.guideHub:Refresh(); return end
        if page.widget and page.dirty and not self.rendering then
            self.rendering = true
            page.dirty = nil
            local app = self.selected == "Import" and addon.RXPOptions.name .. "/Import" or addon.title
            page.widget:SetUserData("basepath", nil)
            self:SizeContainers()
            -- Render the registered tables themselves, including Profiles and
            -- complex editors. AceConfig owns validation, confirmation and writes.
            local ok, err = pcall(LibStub("AceConfigDialog-3.0").Open,
                LibStub("AceConfigDialog-3.0"), app, page.widget)
            self.rendering = nil
            if ok and self.selected == "Import" and addon.settings.textboxHook then
                addon.settings.textboxHook(page.widget)
            end
            if not ok then page.dirty = true; geterrorhandler()(err) end
        elseif self.selected == "Feature Tools" then
            addon.featureToolsUI:Refresh()
        end
    end

    function tabs:SettingsChanged()
        for _, page in pairs(self.pages or {}) do if page.widget then page.dirty = true end end
        if self.refreshPending then return end
        self.refreshPending = true
        addon.scheduler:After(self, "settings", 0, function()
            self.refreshPending = nil
            if tabs.selected ~= "Guides" then tabs:RefreshVisible() end
        end)
    end

    function tabs:Open(name, path)
        addon.guideHub:CreateFrame()
        name = self.buttons[name] and name or self.selected or "Guides"
        self:ClearFocus()
        local page = self:Page(name)
        self.selected = name
        for key, child in pairs(self.pages) do child:SetShown(key == name) end
        for key, button in pairs(self.buttons) do
            if key == name then button:Disable() else button:Enable() end
        end
        if name == "Feature Tools" then
            addon.featureToolsUI:SetPath(path)
        elseif name == "Settings" and path then
            local selected = type(path) == "table" and path or {path}
            LibStub("AceConfigDialog-3.0"):SelectGroup(addon.title, unpack(selected))
            page.dirty = true
        end
        local wasShown = self.window:IsShown()
        self.window:Show()
        if wasShown then self:RefreshVisible() end
    end
end

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

-- Presentation taxonomy only. Use canonical metadata, never localized display
-- strings or quest contents, and never change guide identities or routing.
hub.purposes = {
    {"all", "All guide types"}, {"xp", "Leveling / XP"},
    {"dungeon", "Dungeons"}, {"loot", "Loot & gear"},
    {"profession", "Professions"}, {"reputation", "Reputation"},
    {"daily", "Daily quests"}, {"attunement", "Attunements & keys"},
    {"farming", "Farming"}, {"other", "Other guides"}, {"custom", "Custom guides"}
}

function hub:GetGuidePurpose(guide)
    local group = lower(tostring(guide.group or "")):gsub("^[*+]", ""):gsub("^original guides %- ", "")
    local subgroup = lower(tostring(guide.subgroup or ""))
    if guide.imported or guide.customSource335 or group == "rxpguides custom guides" or
        group:match("^rxpguides custom guides %- ") then return "custom" end
    if addon.hardcoreGuides and addon.hardcoreGuides:GetFamily(guide) then return "other" end
    if group:find("profession", 1, true) or subgroup:find("profession", 1, true) or
        group == "mining & herbalism" or group == "cooking & skinning" then return "profession" end
    if group:find("attunement", 1, true) or subgroup == "attunements" or subgroup == "keys" then return "attunement" end
    if subgroup:find("set guide", 1, true) then return "loot" end
    if group:find("dungeon", 1, true) then return "dungeon" end
    if group:find("reputation", 1, true) then return "reputation" end
    if group:find("daily", 1, true) or group:find("argent tournament", 1, true) then return "daily" end
    if guide.farm then return "farming" end
    if group:find("speedrun guide", 1, true) or
        group:find("wotlk guide", 1, true) or group:find("tbc guide", 1, true) or
        group:find("survival", 1, true) or group:find("mage", 1, true) or
        group:find("death knight", 1, true) or group:match("^restedxp alliance %d") or
        group:match("^restedxp horde %d") or group:find("boosted", 1, true) then return "xp" end
    return "other"
end

function hub:GetGuideIdentifier(guide)
    if addon.hardcoreGuides and addon.hardcoreGuides:GetFamily(guide) then return L("Hardcore") end
    if lower(tostring(guide.group or "")):find("speedrun guide", 1, true) then return L("Speedrun") end
    local purpose = self:GetGuidePurpose(guide)
    for _, item in ipairs(self.purposes) do if item[1] == purpose then return L(item[2]) end end
    return L("Other guides")
end

function hub:GetPreviewIdentity(entry)
    local original = tostring(entry.canonicalGroup or entry.guide.group):gsub("^[*+]", ""):find("Original Guides - ", 1, true) == 1
    return L("Type") .. ": " .. self:GetGuideIdentifier(entry.guide) .. "\n" ..
        L(self:GetGuidePurpose(entry.guide) == "custom" and "Custom guides" or
            (original and "Original Upstream Guides" or "Validated & Fixed Guides")) .. "\n" .. entry.group
end

hub.buttonHelp = {
    ["Guides"] = "Search and preview guides. Loading a guide requires an explicit action.",
    ["Feature Tools"] = "Configure optional tools and open their independent windows.",
    ["Settings"] = "Open all addon settings, including automation, appearance and profiles.",
    ["Import"] = "Paste and validate a custom guide before importing it.",
    ["Validated & Fixed Guides"] = "Browse maintained routes and curated experimental Hardcore guides.",
    ["Original Upstream Guides"] = "Browse original routes and separately adapted upstream Hardcore families.",
    ["All guides"] = "Show all categories within the selected collection and current filters.",
    ["Leveling"] = "Show normal leveling and speedrun routes. Hardcore has its own category.",
    ["Hardcore"] = "Browse experimental deathless-oriented routes. These do not enforce server rules or guarantee survival.",
    ["Endgame"] = "Browse endgame quest chains, equipment sets and attunements.",
    ["Farming"] = "Show farming routes available in the current guide mode.",
    ["Favorites"] = "Toggle the Favorites filter. Use a guide's star to add or remove it.",
    ["Recent"] = "Toggle guides you have recently loaded, keeping the other filters.",
    ["Clear filters"] = "Clear search, type, favorites and recent filters; restore current faction and class filters.",
    ["Backup"] = "Open export, merge, replace and undo actions for addon data.",
    ["Faction"] = "Click to switch between your current faction and all factions.",
    ["Class"] = "Click to switch between your current class and all classes.",
    ["Level"] = "Click to show all level ranges or only those containing your current level.",
    ["Availability"] = "Click to cycle through all, available and unavailable guides.",
    ["Type"] = "Filter guides by purpose, such as XP, dungeons, gear or professions. Hardcore is under Other. Click again to close the menu.",
    ["Continue"] = "Load the selected guide using its existing saved progress.",
    ["Restart"] = "Request confirmation to load the selected guide from step 1.",
    ["Choose Step"] = "Enter a step number, then confirm loading the selected guide at that step.",
    ["Find Start"] = "Analyze quest progress and preview a proposed starting step. Apply it only after confirmation.",
    ["Delete import"] = "Delete this saved import after confirmation. Choose another guide first if it is active. Progress is retained; bundled and companion-addon files are not deleted.",
    ["Close"] = "Close the library without disabling tools or changing guide progress.",
    ["Resize"] = "Drag to resize the library. This does not change the guide HUD size.",
    ["Scroll up"] = "Scroll upward without selecting or loading a guide.",
    ["Scroll down"] = "Scroll downward without selecting or loading a guide.",
    ["Scroll"] = "Drag the scrollbar to read more without changing guide progress."
}

function hub:AttachTooltip(button, key)
    if not button or not self.buttonHelp[key] then return end
    button.rxpLibraryHelp = key
    if button.rxpLibraryHelpHook then return end
    button.rxpLibraryHelpHook = true
    button:HookScript("OnEnter", function(self)
        local title = self.rxpLibraryHelp
        _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        _G.GameTooltip:ClearLines()
        _G.GameTooltip:AddLine(L(title), 1, 0.82, 0)
        _G.GameTooltip:AddLine(L(hub.buttonHelp[title]), 1, 1, 1, true)
        _G.GameTooltip:Show()
    end)
    button:HookScript("OnLeave", function() _G.GameTooltip:Hide() end)
end

function hub:AttachScrollTooltips(scroll)
    if not scroll then return end
    local name = scroll.GetName and scroll:GetName()
    local bar = scroll.ScrollBar or (name and _G[name .. "ScrollBar"])
    if not bar then return end
    self:AttachTooltip(bar, "Scroll")
    local barName = bar.GetName and bar:GetName()
    self:AttachTooltip(bar.ScrollUpButton or (barName and _G[barName .. "ScrollUpButton"]), "Scroll up")
    self:AttachTooltip(bar.ScrollDownButton or (barName and _G[barName .. "ScrollDownButton"]), "Scroll down")
end

function hub:FavoriteTooltip(button, entry)
    if not entry then return end
    _G.GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    _G.GameTooltip:ClearLines()
    _G.GameTooltip:AddLine(RXPData.guideHub.favorites[entry.key] and
        L("Remove from Favorites") or L("Add to Favorites"), 1, 0.82, 0)
    _G.GameTooltip:AddLine(L("Saved in the Favorites filter. This does not load or expand the guide."), 1, 1, 1, true)
    _G.GameTooltip:Show()
end

function hub:UpdateFavoriteIcon(button, favorite)
    if not button.favoriteIcon then
        button:SetText("")
        button.favoriteIcon = button:CreateTexture(nil, "OVERLAY")
        button.favoriteIcon:SetSize(18, 18)
        button.favoriteIcon:SetPoint("CENTER", button, "CENTER", 0, 0)
    end
    favorite = favorite and true or false
    if button.favoriteIconState == favorite then return end
    button.favoriteIconState = favorite
    -- Shared assets, not theme-relative: Custom/Hardcore themes do not need
    -- copies of these files. Shape as well as color indicates selection.
    button.favoriteIcon:SetTexture("Interface\\AddOns\\" .. addonName ..
        "\\Textures\\Tabler\\favorite-" .. (favorite and "filled" or "outline") .. ".tga")
    if favorite then
        button.favoriteIcon:SetVertexColor(1, 0.82, 0, 1)
    else
        button.favoriteIcon:SetVertexColor(0.7, 0.7, 0.7, 1)
    end
end

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
    local name, meta = addon.GetGuideName(guide, true)
    return name or guide.displayname or guide.name or L("Unnamed guide"), meta
end

local function DisplayGroup(group)
    local source = tostring(group or ""):gsub("^[*+]", "")
    local family = addon.hardcoreGuides and addon.hardcoreGuides:GetFamily({group = source})
    if family then return L("Hardcore") .. ": " .. family.label end
    if addon.guideLocalization then
        return addon.guideLocalization:RenderGroup(source)
    end
    return source
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
            if addon.guideBodyCache then guide = addon.guideBodyCache:Metadata(guide) end
            local key = GuideKey(guide)
            local modeMatches = guide and
                ((RXPCData and RXPCData.GA and guide.farm) or
                    (not (RXPCData and RXPCData.GA) and not guide.farm))
            if key and modeMatches and not seen[key] then
                seen[key] = true
                local active, reason = Availability(guide)
                local displayGroup, groupMeta = DisplayGroup(group)
                local displayName, nameMeta = DisplayName(guide)
                table.insert(output, {
                    guide = guide,
                    key = key,
                    group = displayGroup,
                    canonicalGroup = group,
                    name = displayName,
                    canonicalName = guide.sourceDisplayName or guide.displayname or
                                        guide.name or "",
                    translationFallback = (groupMeta and groupMeta.fallback) or
                                              (nameMeta and nameMeta.fallback) or
                                              nil,
                    translationMachine = (groupMeta and groupMeta.machine) or
                                             (nameMeta and nameMeta.machine) or
                                             nil,
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
    local level = UnitLevel("player") or 1
    local function SearchText(value)
        value = tostring(value or "")
        value = value:gsub("%s*|cff9d9d9d%[EN%]|r", "")
        value = value:gsub("%s*|cff70a0ff%[MT%]|r", "")
        return lower(value)
    end
    local favoritesOnly = self.favoritesOnly
    local recentOnly = self.recentOnly
    local recent = {}
    for index, key in ipairs(RXPCData.recentGuides or {}) do recent[key] = index end
    local result = {}
    for _, entry in ipairs(self.guides or {}) do
        local favorite = RXPData.guideHub.favorites[entry.key]
        local textMatch = search == "" or
            SearchText(entry.name):find(search, 1, true) or
            SearchText(entry.group):find(search, 1, true) or
            SearchText(entry.canonicalName):find(search, 1, true) or
            SearchText(entry.canonicalGroup):find(search, 1, true)
        local guide = entry.guide
        local purpose = self:GetGuidePurpose(guide)
        local purposeMatch = not self.purposeFilter or self.purposeFilter == "all" or self.purposeFilter == purpose
        local family = addon.hardcoreGuides and addon.hardcoreGuides:GetFamily(guide)
        local familyMatch = not self.hardcoreFamily or
            (family and family.id == self.hardcoreFamily)
        local original = tostring(entry.canonicalGroup):gsub("^[*+]", ""):find("Original Guides - ", 1, true) == 1
        local collectionMatch = self.purposeFilter == "custom" or not self.collection or (self.collection == "original") == original
        local categoryMatch = not self.category or self.category == "all" or
            (self.category == "hardcore" and family) or
            (self.category == "farming" and guide.farm) or
            (self.category == "endgame" and tostring(entry.canonicalGroup):find("Endgame", 1, true)) or
            (self.category == "leveling" and not family and purpose == "xp")
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
        local levelMatch = self.levelFilter == "all" or not low or
                               (level >= low and level <= high)
        local availabilityMatch = self.availabilityFilter == "all" or
            (self.availabilityFilter == "available" and entry.active) or
            (self.availabilityFilter == "unavailable" and not entry.active)
        if collectionMatch and categoryMatch and purposeMatch and familyMatch and textMatch and factionMatch and classMatch and levelMatch and
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

-- This is a view filter only: no mode, guide, checkpoint or saved filter changes.
function hub:OpenHardcoreGuides(familyId)
    local frame = self:CreateFrame()
    self.hardcoreFamily = familyId or "tbc"
    self.collection = self.hardcoreFamily == "curated" and "validated" or "original"
    self.category = "hardcore"
    self.purposeFilter = nil
    self.favoritesOnly, self.recentOnly = false, false
    self.factionFilter, self.classFilter = "current", "current"
    self.levelFilter, self.availabilityFilter = "all", "available"
    self:Select(nil)
    if frame.search then frame.search:SetText("") end
    if frame.favorites then frame.favorites:SetText(L("Favorites")) end
    if frame.recent then frame.recent:SetText(L("Recent")) end
    if frame.factionFilter then frame.factionFilter:SetText(L("Faction: Current")) end
    if frame.classFilter then frame.classFilter:SetText(L("Class: Current")) end
    if frame.levelFilter then frame.levelFilter:SetText(L("Level: All")) end
    if frame.availabilityFilter then frame.availabilityFilter:SetText(L("Availability: ") .. L("Available")) end
    addon.libraryTabs:Open("Guides")
    self:Refresh()
end

function hub:Select(entry)
    self.selected = entry
    if self.frame then
        if self.frame.deleteImport then
            self.frame.deleteImport:SetShown(entry and self:GetGuidePurpose(entry.guide) == "custom" or false)
        end
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
            (self:GetGuideIdentifier(entry.guide) .. " — " .. entry.name .. " / " .. entry.group ..
                (entry.reason and ("\n" .. entry.reason) or "")) or
            "Select a guide")
        if self.frame.modern then addon.modernLibrary:Details(self) end
    end
    self:RefreshRows()
end

function hub:DeleteSelected()
    local entry = self.selected
    if not entry or not addon.customImport then return end
    local function report(problem)
        hub.frame.status:SetText(problem)
        if hub.frame.modern then addon.modernLibrary:ResizeDetails(hub) else hub:RefreshRows() end
    end
    local plan, problem = addon.customImport:PlanDelete(entry.key)
    if not plan then report(problem); return end
    addon.comms:ConfirmChoice("RXP_DELETE_CUSTOM_GUIDE",
        format(L("Delete imported guide %s? Keep a source backup. Saved progress is retained."), entry.name),
        function(data)
            if not hub.selected or hub.selected.key ~= data.key then return end
            local ok, failure = addon.customImport:Delete(data)
            if not ok then report(failure) end
        end, plan)
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
            addon.toolWindows:RaisePopup(frame)
            frame.editBox:SetText("1")
            frame.editBox:SetFocus()
        end,
        OnAccept = function(frame, data)
            -- A changed preview/catalog must not apply an old step-selection
            -- dialog to a different guide. Loading retains its own mode and
            -- successful-load checks as well.
            if not data or not hub.selected or hub.selected.key ~= data.key or not hub.selected.active then return end
            local requested = tonumber(frame.editBox:GetText())
            local guide = data and data.guide
            if not requested or not guide then return end
            guide = addon:FetchGuide(guide)
            if not guide or not guide.steps then return end
            requested = math.max(1, math.min(#guide.steps,
                                             math.floor(requested)))
            addon.guideState:Load(guide, true, "manual", function()
                addon.GoToStep(requested)
            end)
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
    if self.frame.modern then return addon.modernLibrary:Rows(self) end
    local frame = self.frame
    -- The tab strip and filters reduce the Legacy list's usable height.
    -- Reserve the measured preview before deciding how many pooled rows fit.
    frame.status:SetWidth(math.max(1, frame:GetWidth() - 50))
    frame.status:SetHeight(0)
    local statusHeight = math.min(96, frame.status:GetStringHeight())
    frame.status:SetHeight(statusHeight)
    local bottom = math.max(92, 68 + statusHeight + 10)
    local _, nameSize = frame.rows[1].name:GetFont()
    local _, groupSize = frame.rows[1].group:GetFont()
    nameSize, groupSize = nameSize or 12, groupSize or 10
    local rowHeight = math.max(ROW_HEIGHT, nameSize + groupSize + 6)
    local visible = math.max(0, math.min(VISIBLE_ROWS,
        math.floor((frame:GetHeight() - 142 - bottom) / rowHeight)))
    frame.rowHeight, frame.visibleRows = rowHeight, visible
    frame.scroll:ClearAllPoints()
    frame.scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -140)
    frame.scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -47, bottom)
    local filtered = self.filtered or {}
    local offset = math.max(0, math.min(FauxScrollFrame_GetOffset(frame.scroll),
        math.max(0, #filtered - math.max(1, visible))))
    FauxScrollFrame_SetOffset(frame.scroll, offset)
    FauxScrollFrame_Update(frame.scroll, #filtered, math.max(1, visible), rowHeight)
    for index, row in ipairs(self.frame.rows) do
        local entry = index <= visible and filtered[offset + index] or nil
        row.entry = entry
        if entry then
            row:SetHeight(rowHeight)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 26, -142 - (index - 1) * rowHeight)
            row:SetPoint("RIGHT", -50, 0)
            row.name:ClearAllPoints()
            row.name:SetPoint("TOPLEFT", 28, -2)
            row.name:SetWidth(math.max(1, frame:GetWidth() - 112))
            row.name:SetHeight(nameSize + 2)
            row.group:ClearAllPoints()
            row.group:SetPoint("TOPLEFT", 28, -nameSize - 4)
            row.group:SetWidth(math.max(1, frame:GetWidth() - 112))
            row.group:SetHeight(groupSize + 2)
            row:Show()
            row.name:SetText(entry.name)
            row.group:SetText(entry.group)
            self:UpdateFavoriteIcon(row.favorite, entry.favorite)
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
    if addon.PerfCount then addon.PerfCount("guide catalogue rebuilds") end
    self.guides = BuildGuideList()
    self:RefreshFilter()
end

function hub:RefreshFilter()
    if self.frame and self.frame.purpose then self.frame.purpose:RefreshLabel() end
    local selectedKey = self.selected and self.selected.key
    self.filtered = self:GetFilteredGuides()
    if self.frame then
        self.frame.count:SetText(format(L("%d guides"), #self.filtered))
        local selected
        for _, entry in ipairs(self.filtered) do
            if entry.key == selectedKey then selected = entry; break end
        end
        self:Select(selected)
    end
end

local function CreateButton(parent, text, width, helpKey)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 24)
    button:SetText(text)
    if addon.locale and addon.locale.AttachStatusTooltip then
        addon.locale.AttachStatusTooltip(button, text)
    end
    hub:AttachTooltip(button, helpKey or text)
    return button
end

function hub:CreatePurposeFilter(parent, x, y)
    local button = CreateButton(parent, "", 240)
    self:AttachTooltip(button, "Type")
    button:SetPoint("TOPLEFT", x, y)
    local menuFrame = CreateFrame("Frame", "RXPGuideHubPurposeMenu", button, "UIDropDownMenuTemplate")
    function button:RefreshLabel()
        for _, item in ipairs(hub.purposes) do
            if item[1] == (hub.purposeFilter or "all") then self:SetText(L("Type") .. ": " .. L(item[2])); return end
        end
    end
    button:SetScript("OnClick", function()
        -- EasyMenu reinitializes the shared dropdown before toggling it on
        -- some legacy clients. Close our visible menu before rebuilding it.
        if _G.UIDROPDOWNMENU_OPEN_MENU == menuFrame and
            _G.DropDownList1 and _G.DropDownList1:IsShown() then
            _G.CloseDropDownMenus()
            return
        end
        local menu = {}
        for _, item in ipairs(hub.purposes) do
            local id = item[1]
            menu[#menu + 1] = {text = L(item[2]), checked = id == (hub.purposeFilter or "all"),
                func = function()
                    hub.purposeFilter = id
                    -- Show that type throughout the selected collection rather
                    -- than leaving e.g. Professions hidden behind Leveling.
                    hub.category, hub.hardcoreFamily = "all", nil
                    FauxScrollFrame_SetOffset(hub.frame.scroll, 0)
                    hub:RefreshFilter()
                end}
        end
        _G.EasyMenu(menu, menuFrame, button, 0, 0, "MENU")
    end)
    button:RefreshLabel()
    return button
end

function hub:CreateFrame()
    if self.frame then return self.frame end
    if addon.presentation and addon.presentation:IsModern() then
        return addon.modernLibrary:Create(self)
    end
    local frame = CreateFrame("Frame", "RXPGuideHub", UIParent)
    frame:SetSize(680, 536)
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
    self:AttachTooltip(close, "Close")
    close:SetPoint("TOPRIGHT", -5, -5)

    local window = frame
    self.window = window
    frame = addon.libraryTabs:GuidePage(window)

    local search = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    frame.search = search
    search:SetSize(260, 24)
    search:SetPoint("TOPLEFT", 24, -50)
    search:SetAutoFocus(false)
    search:SetScript("OnEscapePressed", function(box) box:ClearFocus(); window:Hide() end)
    search:SetTextInsets(6, 6, 0, 0)
    search:SetScript("OnTextChanged", function(box)
        hub.searchText = box:GetText()
        hub.filtered = hub:GetFilteredGuides()
        FauxScrollFrame_SetOffset(frame.scroll, 0)
        hub:RefreshRows()
        frame.count:SetText(format(L("%d guides"), #hub.filtered))
    end)

    local favorites = CreateButton(frame, L("Favorites"), 105, "Favorites")
    frame.favorites = favorites
    favorites:SetPoint("LEFT", search, "RIGHT", 12, 0)
    favorites:SetScript("OnClick", function()
        hub.favoritesOnly = not hub.favoritesOnly
        favorites:SetText(hub.favoritesOnly and L("All guides") or L("Favorites"))
        hub:Refresh()
    end)
    local recent = CreateButton(frame, L("Recent"), 90, "Recent")
    frame.recent = recent
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
    frame.factionFilter, frame.classFilter = factionFilter, classFilter
    frame.levelFilter, frame.availabilityFilter = levelFilter, availabilityFilter
    self:AttachTooltip(factionFilter, "Faction")
    self:AttachTooltip(classFilter, "Class")
    self:AttachTooltip(levelFilter, "Level")
    self:AttachTooltip(availabilityFilter, "Availability")

    frame.count = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.count:SetPoint("TOPRIGHT", -26, -113)
    local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", 28, -114)
    header:SetText("")
    frame.purpose = self:CreatePurposeFilter(frame, 24, -108)

    local scroll = CreateFrame("ScrollFrame", "RXPGuideHubScroll", frame,
                               "FauxScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 24, -140)
    scroll:SetPoint("BOTTOMRIGHT", -47, 92)
    scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, frame.rowHeight or ROW_HEIGHT,
                                         function() hub:RefreshRows() end)
    end)
    frame.scroll = scroll
    self:AttachScrollTooltips(scroll)
    frame.rows = {}
    for index = 1, VISIBLE_ROWS do
        local row = CreateFrame("Button", nil, frame)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", 26, -142 - (index - 1) * ROW_HEIGHT)
        row:SetPoint("RIGHT", -50, 0)
        row.selected = row:CreateTexture(nil, "BACKGROUND")
        row.selected:SetAllPoints()
        row.selected:SetTexture(0.2, 0.35, 0.55, 0.55)
        row.selected:Hide()
        row.favorite = CreateButton(row, "", 24)
        row.favorite:SetPoint("LEFT", 4, 0)
        row.favorite:SetScript("OnClick", function() hub:ToggleFavorite(row.entry) end)
        row.favorite:SetScript("OnEnter", function(button) hub:FavoriteTooltip(button, row.entry) end)
        row.favorite:SetScript("OnLeave", function() _G.GameTooltip:Hide() end)
        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.name:SetPoint("LEFT", 28, 6)
        row.name:SetPoint("RIGHT", -8, 6)
        row.name:SetJustifyH("LEFT")
        if row.name.SetWordWrap then row.name:SetWordWrap(false) end
        row.group = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.group:SetPoint("LEFT", 28, -7)
        row.group:SetPoint("RIGHT", -8, -7)
        row.group:SetJustifyH("LEFT")
        if row.group.SetWordWrap then row.group:SetWordWrap(false) end
        row:SetScript("OnClick", function(self, button)
            if button == "RightButton" then
                hub:ToggleFavorite(self.entry)
            else
                hub:Select(self.entry)
            end
        end)
        row:SetScript("OnEnter", function(self)
            if not self.entry then return end
            _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            _G.GameTooltip:ClearLines()
            _G.GameTooltip:AddLine(self.entry.name, 1, 0.82, 0, true)
            _G.GameTooltip:AddLine(hub:GetPreviewIdentity(self.entry), 1, 1, 1, true)
            _G.GameTooltip:AddLine(L("Left-click to preview; right-click to toggle Favorites."), 1, 1, 1, true)
            if self.entry.reason then _G.GameTooltip:AddLine(self.entry.reason, 1, 0.8, 0.5, true) end
            if self.entry and (self.entry.translationFallback or
               self.entry.translationMachine) and
               addon.guideLocalization then
                local machine = self.entry.translationMachine
                _G.GameTooltip:AddLine(machine and
                    addon.guideLocalization:GetMachineExplanation() or
                    addon.guideLocalization:GetFallbackExplanation(),
                    machine and 0.45 or 0.65, machine and 0.65 or 0.65,
                    machine and 1 or 0.65, true)
            end
            _G.GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function(self)
            _G.GameTooltip:Hide()
        end)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        frame.rows[index] = row
    end

    frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.status:SetPoint("BOTTOMLEFT", 25, 68)
    frame.status:SetJustifyH("LEFT")
    if frame.status.SetWordWrap then frame.status:SetWordWrap(true) end
    frame.status:SetText(L("Select a guide"))
    frame.continue = CreateButton(frame, "Continue", 110)
    frame.continue:SetPoint("BOTTOMLEFT", 24, 26)
    frame.continue:SetScript("OnClick", function() hub:LoadSelected(false) end)
    frame.restart = CreateButton(frame, "Restart", 100)
    frame.restart:SetPoint("LEFT", frame.continue, "RIGHT", 8, 0)
    frame.restart:SetScript("OnClick", function()
        if not hub.selected then return end
        local entry = hub.selected
        addon.comms:ConfirmChoice("RXP_GUIDE_HUB_RESTART",
            "Restart " .. entry.name .. " from step 1?",
            function()
                if hub.selected == entry and entry.active then
                    addon.guideState:Load(entry.guide, true, "manual")
                end
            end)
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
    frame.deleteImport = CreateButton(frame, "Delete import", 115)
    frame.deleteImport:SetPoint("LEFT", frame.purpose, "RIGHT", 8, 0)
    frame.deleteImport:SetScript("OnClick", function() hub:DeleteSelected() end)
    frame.deleteImport:Hide()
    local backup = CreateButton(frame, "Backup", 95)
    backup:SetPoint("BOTTOMRIGHT", -24, 26)
    backup:SetScript("OnClick", function() addon.roadmap:OpenBackupWindow() end)
    frame.continue:Disable()
    frame.restart:Disable()
    frame.chooseStep:Disable()
    frame.findStart:Disable()
    window:Hide()
    self.frame = frame
    frame:SetScript("OnSizeChanged", function() hub:RefreshRows() end)
    addon.libraryTabs:Attach(window, frame)
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
    self:CreateFrame()
    if self.window:IsShown() and addon.libraryTabs.selected == "Guides" then
        self.window:Hide()
    else
        addon.libraryTabs:Open("Guides")
    end
end
