local _, addon = ...
local library = {}
addon.modernLibrary = library
local L = addon.locale.Get
local view = addon.presentation
local ROW = 38

local function FontSize()
    return math.max(12, tonumber(addon.settings.profile.guideFontSize) or 12)
end

function library:ResizeDetails(hub)
    local f = hub.frame
    if not (f and f.detailScroll) then return end
    local width = math.max(80, f.details:GetWidth() - 42)
    addon.SetFontSafely(f.status, addon.font, FontSize(), "")
    f.status:SetWidth(width)
    f.status:SetHeight(0)
    f.detailChild:SetSize(width, math.max(1, f.status:GetStringHeight() + 10))
end

local function Label(parent, text, size)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    addon.SetFontSafely(label, addon.font, size or 12, "")
    label:SetText(text)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("TOP")
    return label
end

function library:Details(hub)
    local frame, entry = hub.frame, hub.selected
    local key = entry and entry.key
    if frame.detailKey ~= key then frame.detailScroll:SetVerticalScroll(0) end
    frame.detailKey = key
    if not entry then
        frame.status:SetText(L("Select a guide to preview it. Nothing loads until you choose an action."))
        self:ResizeDetails(hub)
        return
    end
    local checkpoint = RXPCData.guideProgress and RXPCData.guideProgress[entry.key]
    local position = checkpoint and (checkpoint.currentStep or checkpoint.step)
    local text = entry.name .. "\n\n" .. hub:GetPreviewIdentity(entry)
    if tonumber(position) then text = text .. "\n\n" .. string.format(L("Saved step: %d"), tonumber(position)) end
    if entry.reason then text = text .. "\n\n" .. entry.reason end
    if addon.hardcoreGuides and addon.hardcoreGuides:GetFamily(entry.guide) then
        text = text .. "\n\n" .. L("Experimental deathless-oriented route. Not enforced Hardcore rules or a guarantee of survival.")
    end
    -- Read registered metadata only. Preview must never parse/load a guide or
    -- invoke checkpoint migration. Opening the chapter shows authored warnings.
    if entry.canonicalName:find("Onyxia", 1, true) then
        text = text .. "\n\n" .. L("Legacy Onyxia attunement requires server restoration such as Individual Progression; unavailable on stock AzerothCore.")
    end
    frame.status:SetText(text)
    self:ResizeDetails(hub)
end

function library:Rows(hub)
    local f = hub.frame
    if not f or not f:IsShown() then return end
    local filtered = hub.filtered or {}
    local size = FontSize()
    local rowHeight = math.max(ROW, size * 2 + 12)
    f.rowHeight = rowHeight
    local count = math.max(1, math.floor(f.viewport:GetHeight() / rowHeight))
    local offset = math.min(FauxScrollFrame_GetOffset(f.scroll), math.max(0, #filtered - count))
    FauxScrollFrame_SetOffset(f.scroll, offset)
    FauxScrollFrame_Update(f.scroll, #filtered, count, rowHeight)
    local grew = false
    for i = 1, count do
        if not f.rows[i] then
            local row = CreateFrame("Button", nil, f.rowCanvas)
            row:SetHeight(ROW - 2)
            row:SetPoint("TOPLEFT", 0, -(i - 1) * ROW)
            row:SetPoint("RIGHT", f.rowCanvas, "RIGHT", 0, 0)
            view:Skin(row, true)
            row.name = Label(row, "", 12)
            row.name:SetPoint("TOPLEFT", 30, -3)
            row.name:SetPoint("RIGHT", -6, 0)
            row.name:SetHeight(15)
            row.group = Label(row, "", 10)
            row.group:SetPoint("TOPLEFT", 30, -19)
            row.group:SetPoint("RIGHT", -6, 0)
            row.group:SetHeight(13)
            row.star = view:Button(row, "", 24, function() hub:ToggleFavorite(row.entry) end)
            row.star:SetPoint("LEFT", 2, 0)
            row.star:SetScript("OnEnter", function(button) hub:FavoriteTooltip(button, row.entry) end)
            row.star:SetScript("OnLeave", function() GameTooltip:Hide() end)
            row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            row:SetScript("OnClick", function(self, button)
                if button == "RightButton" then hub:ToggleFavorite(self.entry) else hub:Select(self.entry) end
            end)
            row:SetScript("OnEnter", function(self)
                if not self.entry then return end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(self.entry.name, 1, 0.82, 0.35, true)
                GameTooltip:AddLine(hub:GetPreviewIdentity(self.entry), 0.8, 0.84, 0.9, true)
                GameTooltip:AddLine(self.entry.reason or self.entry.group, 0.8, 0.84, 0.9, true)
                GameTooltip:AddLine(L("Left-click to preview; right-click to toggle Favorites."), 1, 1, 1, true)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function() GameTooltip:Hide() end)
            f.rows[i] = row
            grew = true
        end
    end
    if grew then addon.toolWindows:RefreshLayering() end
    for i, row in ipairs(f.rows) do
        row:SetHeight(rowHeight - 2)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -(i - 1) * rowHeight)
        row:SetPoint("RIGHT", f.rowCanvas, "RIGHT", 0, 0)
        addon.SetFontSafely(row.name, addon.font, size, "")
        addon.SetFontSafely(row.group, addon.font, size - 2, "")
        row.name:SetHeight(size + 4)
        row.group:SetPoint("TOPLEFT", 30, -(size + 8))
        row.group:SetHeight(size + 2)
        local entry = i <= count and filtered[offset + i]
        row.entry = entry
        row:SetShown(entry ~= nil)
        if entry then
            row.name:SetText(entry.name)
            row.group:SetText(entry.group)
            hub:UpdateFavoriteIcon(row.star, entry.favorite)
            row.name:SetTextColor(entry.active and 1 or 0.6, entry.active and 0.82 or 0.6, entry.active and 0.35 or 0.6)
            local selected = hub.selected and hub.selected.key == entry.key
            row:SetBackdropBorderColor(selected and 0.1 or 0.3, selected and 0.82 or 0.34, selected and 1 or 0.46, 1)
        end
    end
    for _, button in ipairs(f.navigation) do
        local selected = button.selected()
        button:SetBackdropBorderColor(selected and 0.1 or 0.3, selected and 0.82 or 0.34, selected and 1 or 0.46, 1)
    end
end

function library:Layout(hub)
    local f = hub.frame
    if not f or f.layoutBusy then return end
    f.layoutBusy = true
    local wide = f:GetWidth() >= 840
    f.viewport:ClearAllPoints()
    f.viewport:SetPoint("TOPLEFT", 166, -192)
    f.viewport:SetPoint("BOTTOMRIGHT", wide and -286 or -40, wide and 66 or 205)
    f.details:ClearAllPoints()
    if wide then
        f.details:SetPoint("TOPLEFT", f.viewport, "TOPRIGHT", 30, 0)
        f.details:SetPoint("BOTTOMRIGHT", -16, 66)
    else
        f.details:SetPoint("TOPLEFT", f.viewport, "BOTTOMLEFT", 0, -12)
        f.details:SetPoint("BOTTOMRIGHT", -16, 66)
    end
    f.rowCanvas:SetSize(math.max(100, f.viewport:GetWidth()), math.max(1, f.viewport:GetHeight()))
    self:ResizeDetails(hub)
    f.layoutBusy = nil
    self:Rows(hub)
end

function library:Create(hub)
    local window = addon.toolWindows:Create({name = "RXPGuideHub", title = L("Guide Library"),
        closeOnEscape = true,
        width = 940, height = 646, minWidth = 680, minHeight = 566, maxWidth = 1200, maxHeight = 950})
    local f = addon.libraryTabs:GuidePage(window)
    hub.window = window
    hub.frame = f
    hub:AttachTooltip(window.closeButton, "Close")
    hub:AttachTooltip(window.resizeButton, "Resize")
    f.modern, f.rows, f.navigation = true, {}, {}
    -- The library is a dialog; feature tools keep their existing no-Escape policy.
    local function Navigation(text, x, y, width, selected, action)
        local button = view:Button(f, L(text), width, function()
            action(); hub:Select(nil); hub:Refresh()
        end)
        button:SetPoint("TOPLEFT", x, y)
        button.selected = selected
        hub:AttachTooltip(button, text)
        f.navigation[#f.navigation + 1] = button
        return button
    end
    Navigation("Validated & Fixed Guides", 16, -48, 290,
        function() return hub.collection ~= "original" end,
        function() hub.collection = "validated"; hub.hardcoreFamily = nil end)
    Navigation("Original Upstream Guides", 314, -48, 290,
        function() return hub.collection == "original" end,
        function() hub.collection = "original"; hub.hardcoreFamily = nil end)
    hub.collection = "validated"
    Navigation("All guides", 16, -160, 138,
        function() return (hub.category or "all") == "all" and not hub.hardcoreFamily and
            (hub.purposeFilter or "all") == "all" end,
        function() hub.category = "all"; hub.hardcoreFamily = nil; hub.purposeFilter = nil end)
    f.favorites = Navigation("Favorites", 16, -202, 138, function() return hub.favoritesOnly end,
        function() hub.favoritesOnly = not hub.favoritesOnly end)
    f.recent = Navigation("Recent", 16, -234, 138, function() return hub.recentOnly end,
        function() hub.recentOnly = not hub.recentOnly end)
    Navigation("Clear filters", 16, -276, 138, function() return false end, function()
        hub.category, hub.hardcoreFamily, hub.favoritesOnly, hub.recentOnly = nil, nil, false, false
        hub.purposeFilter = nil
        hub.factionFilter, hub.classFilter, hub.levelFilter, hub.availabilityFilter = "current", "current", "all", "all"
        for key, value in pairs({faction = "current", class = "current", level = "all", availability = "all"}) do
            RXPData.guideHub.filters[key] = value
        end
        f.search:SetText("")
        for _, button in ipairs(f.filters) do button:RefreshLabel() end
    end)
    local backup = view:Button(f, L("Backup"), 138, function() addon.roadmap:OpenBackupWindow() end)
    hub:AttachTooltip(backup, "Backup")
    backup:SetPoint("TOPLEFT", 16, -312)
    f.search = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    f.search:SetSize(280, 24)
    f.search:SetPoint("TOPLEFT", 174, -88)
    f.search:SetAutoFocus(false)
    f.search:SetScript("OnEscapePressed", function(box) box:ClearFocus(); window:Hide() end)
    f.search:SetScript("OnTextChanged", function(box)
        hub.searchText = box:GetText()
        if f.scroll then FauxScrollFrame_SetOffset(f.scroll, 0); hub:RefreshFilter() end
    end)
    f.count = Label(f, "", 11)
    f.count:SetPoint("TOPRIGHT", -18, -94)
    f.filters = {}
    for i, spec in ipairs({{"factionFilter", "Faction", {"current", "all"}},
        {"classFilter", "Class", {"current", "all"}}, {"levelFilter", "Level", {"all", "current"}},
        {"availabilityFilter", "Availability", {"all", "available", "unavailable"}}}) do
        local field, caption, values = spec[1], spec[2], spec[3]
        local button
        button = view:Button(f, "", 118, function()
            local index = 1
            for n, value in ipairs(values) do if value == hub[field] then index = n end end
            hub[field] = values[index % #values + 1]
            RXPData.guideHub.filters[field:gsub("Filter$", "")] = hub[field]
            button:RefreshLabel(); hub:Refresh()
        end)
        function button:RefreshLabel()
            local labels = {current = L("Current"), all = L("All"), available = L("Available"), unavailable = L("Unavailable")}
            self:SetText(L(caption) .. ": " .. (labels[hub[field]] or L("All")))
        end
        button:SetPoint("TOPLEFT", 166 + (i - 1) * 122, -122)
        button:RefreshLabel()
        hub:AttachTooltip(button, caption)
        f[field], f.filters[i] = button, button
    end
    f.purpose = hub:CreatePurposeFilter(f, 166, -156)
    view:SkinControl(f.purpose)
    f.deleteImport = view:Button(f, L("Delete import"), 115, function() hub:DeleteSelected() end)
    f.deleteImport:SetPoint("LEFT", f.purpose, "RIGHT", 8, 0)
    hub:AttachTooltip(f.deleteImport, "Delete import")
    f.deleteImport:Hide()
    f.viewport = CreateFrame("ScrollFrame", nil, f)
    f.viewport:EnableMouseWheel(true)
    f.viewport:SetScript("OnMouseWheel", function(_, delta)
        local count = math.max(1, math.floor(f.viewport:GetHeight() / (f.rowHeight or ROW)))
        FauxScrollFrame_SetOffset(f.scroll, math.max(0, math.min(math.max(0, #(hub.filtered or {}) - count),
            FauxScrollFrame_GetOffset(f.scroll) - delta * 3)))
        library:Rows(hub)
    end)
    f.rowCanvas = CreateFrame("Frame", nil, f.viewport)
    f.viewport:SetScrollChild(f.rowCanvas)
    f.scroll = CreateFrame("ScrollFrame", "RXPGuideHubScroll", f, "FauxScrollFrameTemplate")
    f.scroll:SetAllPoints(f.viewport)
    hub:AttachScrollTooltips(f.scroll)
    f.scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, f.rowHeight or ROW, function() library:Rows(hub) end)
    end)
    f.details = CreateFrame("Frame", nil, f)
    view:Skin(f.details, true)
    f.detailScroll = CreateFrame("ScrollFrame", "RXPGuideHubDetails", f.details, "UIPanelScrollFrameTemplate")
    f.detailScroll:SetPoint("TOPLEFT", 10, -10)
    f.detailScroll:SetPoint("BOTTOMRIGHT", -30, 10)
    hub:AttachScrollTooltips(f.detailScroll)
    f.detailChild = CreateFrame("Frame", nil, f.detailScroll)
    f.detailChild:SetSize(200, 1)
    f.detailScroll:SetScrollChild(f.detailChild)
    f.status = Label(f.detailChild, L("Select a guide"), 12)
    f.status:SetPoint("TOPLEFT", 0, 0)
    local actions = {
        {"continue", "Continue", function() hub:LoadSelected(false) end},
        {"restart", "Restart", function()
            local entry = hub.selected
            if not entry then return end
            addon.comms:ConfirmChoice("RXP_GUIDE_HUB_RESTART", string.format(L("Restart %s from step 1?"), entry.name), function()
                if hub.selected == entry and entry.active then addon.guideState:Load(entry.guide, true, "manual") end
            end)
        end},
        {"chooseStep", "Choose Step", function() hub:ChooseStep() end},
        {"findStart", "Find Start", function()
            if hub.selected and hub.selected.active and addon.catchUp then addon.catchUp:Preview(addon:FetchGuide(hub.selected.guide)) end
        end}}
    for i, action in ipairs(actions) do
        local button = view:Button(f, L(action[2]), 110, action[3])
        button:SetPoint("BOTTOMLEFT", 16 + (i - 1) * 118, 24)
        button:Disable()
        hub:AttachTooltip(button, action[2])
        f[action[1]] = button
    end
    f:SetScript("OnSizeChanged", function() library:Layout(hub) end)
    window.OnToolVisuals = function()
        view:Skin(f.details, true)
        view:SkinControl(f.purpose)
        for _, row in ipairs(f.rows) do view:Skin(row, true); view:Skin(row.star, true) end
        for _, button in ipairs(f.navigation) do view:Skin(button, true) end
        library:Layout(hub)
    end
    f:HookScript("OnShow", function() library:Layout(hub) end)
    addon.libraryTabs:Attach(window, f)
    self:Layout(hub)
    return f
end
