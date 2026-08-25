local _, addon = ...

-- Shared, stock-3.3.5-safe chrome for the small feature windows.  These
-- windows intentionally remain independent from addon.enabledFrames: that
-- collection represents features which should be automatically shown/hidden
-- with the main guide.  Tool windows are user-opened dialogs and must retain
-- that explicit visibility state.
addon.toolWindows = addon.toolWindows or {}
local manager = addon.toolWindows

local _G = _G
local max, min = math.max, math.min
local tremove = table.remove

manager.frames = manager.frames or {}
manager.layerOrder = manager.layerOrder or {}
manager.knownNames = manager.knownNames or {
    "RXPRoutePreflightWindow",
    "RXPPerformanceInspector",
    "RXPHunterPetAssistant",
    "RXPLevelingArchives",
    "RXPXPProgressWindow",
    "RXPSpeedrunCoachWindow",
    "RXPSpeedrunGrindWindow",
    "RXPSpeedrunPitStopWindow",
    "RXPSpeedrunRouteWindow",
    "RXPSpeedrunDeathwarpWindow",
    "RXPSpeedrunPracticeWindow",
    "RXPSpeedrunAudioWindow",
    "RXPSpeedrunRulesWindow"
}

local backdrop = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 24,
    insets = {left = 7, right = 7, top = 7, bottom = 7}
}

local function Clamp(value, low, high)
    value = tonumber(value) or low
    return max(low, min(high, value))
end

local function SetTreeFrameLevel(frame, base, depth, root)
    if not (frame and frame.SetFrameLevel) then return end
    root = root or frame
    frame:SetFrameLevel(base + min(depth, 8))
    if frame ~= root and frame.HookScript and not frame.rxpToolLayerHook then
        frame.rxpToolLayerHook = true
        frame:HookScript("OnEnter", function() manager:BringToFront(root) end)
        frame:HookScript("OnMouseDown", function() manager:BringToFront(root) end)
    end
    if not frame.GetChildren then return end
    local children = {frame:GetChildren()}
    for _, child in ipairs(children) do
        SetTreeFrameLevel(child, base, depth + 1, root)
    end
end

function manager:RefreshLayering()
    local compact = {}
    for _, frame in ipairs(self.layerOrder) do
        if frame and frame.GetName and self.frames[frame:GetName()] == frame then
            compact[#compact + 1] = frame
        end
    end
    self.layerOrder = compact
    -- Keep each complete frame hierarchy inside its own level band.  Without
    -- this, 3.3.5 can interleave one window's scrollbar/buttons with another
    -- window's backdrop when both use the DIALOG strata.
    for index, frame in ipairs(compact) do
        SetTreeFrameLevel(frame, 40 + index * 16, 0)
    end
end

function manager:BringToFront(frame)
    if not frame then return end
    for index = #self.layerOrder, 1, -1 do
        if self.layerOrder[index] == frame then
            tremove(self.layerOrder, index)
        end
    end
    self.layerOrder[#self.layerOrder + 1] = frame
    self:RefreshLayering()
end

local function PreventEscapeClose(name)
    if type(name) ~= "string" or not _G.UISpecialFrames then return end
    for index = #_G.UISpecialFrames, 1, -1 do
        if _G.UISpecialFrames[index] == name then
            tremove(_G.UISpecialFrames, index)
        end
    end
end

local function GetProfile()
    return addon.settings and addon.settings.profile
end

local appearanceLimits = {
    fontSize = {6, 22},
    opacity = {0.05, 1},
    backgroundOpacity = {0, 1},
    scale = {0.50, 2},
}

local function AppearanceStore(create)
    local profile = GetProfile()
    if not profile then return end
    if type(profile.toolWindowAppearance) ~= "table" then
        if not create then return end
        profile.toolWindowAppearance = {}
    end
    return profile.toolWindowAppearance
end

local function DefaultAppearance(frameName, key)
    local frame = manager.frames[frameName]
    local spec = frame and frame.toolWindowSpec or {}
    if key == "fontSize" then
        return max(10, tonumber(spec.fontSize) or
                       tonumber(GetProfile() and GetProfile().guideFontSize) or 9)
    elseif key == "opacity" then
        return tonumber(spec.opacity) or 1
    elseif key == "backgroundOpacity" then
        return tonumber(spec.backgroundOpacity) or 1
    elseif key == "scale" then
        return tonumber(spec.scale) or 1
    end
end

function manager:GetAppearanceValue(frameName, key)
    local limits = appearanceLimits[key]
    if not limits then return end
    local store = AppearanceStore(false)
    local appearance = store and type(store[frameName]) == "table" and
                           store[frameName] or nil
    local value = appearance and tonumber(appearance[key]) or
                      DefaultAppearance(frameName, key)
    return Clamp(value, limits[1], limits[2])
end

function manager:SetAppearanceValue(frameName, key, value)
    local limits = appearanceLimits[key]
    if not limits or type(frameName) ~= "string" then return end
    local store = AppearanceStore(true)
    if not store then return end
    store[frameName] = type(store[frameName]) == "table" and
                           store[frameName] or {}
    store[frameName][key] = Clamp(value, limits[1], limits[2])
    local frame = self.frames[frameName]
    if frame then self:ApplyVisuals(frame) end
end

function manager:ResetWindow(frameName)
    local profile = GetProfile()
    if profile then
        if type(profile.toolWindowAppearance) == "table" then
            profile.toolWindowAppearance[frameName] = nil
        end
        if type(profile.framePositions) == "table" then
            profile.framePositions[frameName] = nil
        end
        if type(profile.frameSizes) == "table" then
            profile.frameSizes[frameName] = nil
        end
    end
    local frame = self.frames[frameName]
    if frame and frame.toolWindowSpec then
        self:ApplyVisuals(frame)
        self:RestorePlacement(frame, frame.toolWindowSpec)
        if frame.UpdateToolTextLayout then frame:UpdateToolTextLayout() end
        if frame.OnToolReset then frame:OnToolReset() end
    end
end

function manager:SavePlacement(frame)
    local profile = GetProfile()
    local name = frame and frame.GetName and frame:GetName()
    if not (profile and name) then return end
    profile.framePositions = type(profile.framePositions) == "table" and
                                 profile.framePositions or {}
    profile.frameSizes = type(profile.frameSizes) == "table" and
                             profile.frameSizes or {}

    local point, relativeTo, relativePoint, x, y = frame:GetPoint(1)
    if not point then return end
    local relativeName = relativeTo and relativeTo.GetName and
                             relativeTo:GetName() or nil
    profile.framePositions[name] = {
        {point, relativeName, relativePoint, tonumber(x) or 0, tonumber(y) or 0}
    }
    profile.frameSizes[name] = {frame:GetWidth(), frame:GetHeight()}
end

function manager:RestorePlacement(frame, spec)
    local profile = GetProfile()
    local name = frame and frame.GetName and frame:GetName()
    local width, height = spec.width, spec.height
    if profile and name then
        local savedSize = type(profile.frameSizes) == "table" and
                              profile.frameSizes[name]
        if type(savedSize) == "table" then
            width = tonumber(savedSize[1]) or width
            height = tonumber(savedSize[2]) or height
        end
    end

    local parentWidth = max(320, (_G.UIParent:GetWidth() or width) - 24)
    local parentHeight = max(240, (_G.UIParent:GetHeight() or height) - 24)
    width = Clamp(width, spec.minWidth, min(spec.maxWidth, parentWidth))
    height = Clamp(height, spec.minHeight, min(spec.maxHeight, parentHeight))
    frame:SetSize(width, height)

    local restored
    if profile and name and type(profile.framePositions) == "table" then
        local saved = profile.framePositions[name]
        saved = type(saved) == "table" and saved[1]
        if type(saved) == "table" and type(saved[1]) == "string" then
            local relative = type(saved[2]) == "string" and _G[saved[2]] or
                                 _G.UIParent
            frame:ClearAllPoints()
            restored = pcall(frame.SetPoint, frame, saved[1], relative,
                             saved[3] or saved[1], tonumber(saved[4]) or 0,
                             tonumber(saved[5]) or 0)
        end
    end
    if not restored then
        local relative = spec.relativeTo
        if type(relative) == "string" then
            relative = _G[relative]
        elseif type(relative) == "function" then
            relative = relative()
        end
        relative = relative or _G.UIParent
        frame:ClearAllPoints()
        frame:SetPoint(spec.point or "CENTER", relative,
                       spec.relativePoint or spec.point or "CENTER",
                       spec.x or 0, spec.y or 0)
    end
end

function manager:ApplyVisuals(frame)
    if not frame then return end
    local colors = addon.colors or addon.activeTheme or {}
    local background = colors.background or {0.035, 0.035, 0.07, 0.98}
    frame:SetBackdrop(backdrop)
    local frameName = frame.GetName and frame:GetName()
    local opacity = frameName and self:GetAppearanceValue(frameName, "opacity") or 1
    local backgroundOpacity = frameName and
                                  self:GetAppearanceValue(frameName,
                                                          "backgroundOpacity") or 1
    local scale = frameName and self:GetAppearanceValue(frameName, "scale") or 1
    local themeAlpha = max(0.94, tonumber(background[4]) or 1)
    frame:SetBackdropColor(background[1] or 0.035, background[2] or 0.035,
                           background[3] or 0.07,
                           themeAlpha * backgroundOpacity)
    frame:SetBackdropBorderColor(0.72, 0.72, 0.72, 1)
    frame:SetAlpha(opacity or 1)
    frame:SetScale(scale or 1)

    local fontSize = frameName and
                         self:GetAppearanceValue(frameName, "fontSize") or
                         max(10, tonumber(GetProfile() and
                                  GetProfile().guideFontSize) or 9)
    if frame.title and addon.SetFontSafely then
        addon.SetFontSafely(frame.title, addon.font, fontSize + 4, "")
    end
    if frame.bodyText and addon.SetFontSafely then
        addon.SetFontSafely(frame.bodyText, addon.font, fontSize, "")
    end
    if frame.OnToolVisuals then frame:OnToolVisuals(fontSize) end
end

function manager:RefreshVisuals()
    for _, frame in pairs(self.frames) do self:ApplyVisuals(frame) end
end

function manager:RestoreAll()
    for _, frame in pairs(self.frames) do
        if frame.toolWindowSpec then
            self:ApplyVisuals(frame)
            self:RestorePlacement(frame, frame.toolWindowSpec)
            if frame.UpdateToolTextLayout then frame:UpdateToolTextLayout() end
        end
    end
end

function manager:ResetPlacements()
    local profile = GetProfile()
    if profile then
        profile.framePositions = type(profile.framePositions) == "table" and
                                     profile.framePositions or {}
        profile.frameSizes = type(profile.frameSizes) == "table" and
                                 profile.frameSizes or {}
        for _, name in ipairs(self.knownNames) do
            profile.framePositions[name] = nil
            profile.frameSizes[name] = nil
        end
    end
    for _, frame in pairs(self.frames) do
        if frame.toolWindowSpec then
            self:RestorePlacement(frame, frame.toolWindowSpec)
            if frame.UpdateToolTextLayout then frame:UpdateToolTextLayout() end
        end
    end
end

function manager:Create(spec)
    spec = spec or {}
    local name = assert(spec.name, "tool window requires a stable name")
    local existing = _G[name]
    if existing then
        PreventEscapeClose(name)
        return existing
    end

    spec.width = tonumber(spec.width) or 600
    spec.height = tonumber(spec.height) or 430
    spec.minWidth = tonumber(spec.minWidth) or min(spec.width, 440)
    spec.minHeight = tonumber(spec.minHeight) or min(spec.height, 300)
    spec.maxWidth = tonumber(spec.maxWidth) or 980
    spec.maxHeight = tonumber(spec.maxHeight) or 760

    local frame = CreateFrame("Frame", name, _G.UIParent)
    frame.toolWindowSpec = spec
    frame:SetFrameStrata(spec.strata or "DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    if frame.SetResizable then frame:SetResizable(spec.resizable ~= false) end
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        manager:BringToFront(self)
        if not self.isResizing then self:StartMoving() end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        manager:SavePlacement(self)
    end)
    if frame.SetMinResize then frame:SetMinResize(spec.minWidth, spec.minHeight) end
    if frame.SetMaxResize then frame:SetMaxResize(spec.maxWidth, spec.maxHeight) end

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 22, -16)
    title:SetPoint("TOPRIGHT", -42, -16)
    title:SetJustifyH("LEFT")
    title:SetText(spec.title or name)
    frame.title = title

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)
    close:SetScript("OnClick", function() frame:Hide() end)
    frame.closeButton = close

    if spec.resizable ~= false then
        local resize = CreateFrame("Button", nil, frame)
        resize:SetSize(18, 18)
        resize:SetPoint("BOTTOMRIGHT", -7, 7)
        resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        resize:SetHighlightTexture(
            "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight", "ADD")
        resize:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        resize:SetScript("OnMouseDown", function(_, button)
            if button ~= "LeftButton" then return end
            manager:BringToFront(frame)
            frame.isResizing = true
            if frame.StartSizing then frame:StartSizing("BOTTOMRIGHT") end
        end)
        resize:SetScript("OnMouseUp", function()
            frame:StopMovingOrSizing()
            frame.isResizing = nil
            manager:SavePlacement(frame)
        end)
        frame.resizeButton = resize
    end

    frame.UpdateVisuals = function(self) manager:ApplyVisuals(self) end
    frame:HookScript("OnShow", function(self)
        manager:ApplyVisuals(self)
        manager:BringToFront(self)
    end)
    frame:HookScript("OnEnter", function(self) manager:BringToFront(self) end)
    frame:HookScript("OnMouseDown", function(self)
        manager:BringToFront(self)
    end)
    frame:HookScript("OnHide", function(self) manager:SavePlacement(self) end)
    manager.frames[name] = frame
    manager:BringToFront(frame)
    -- Feature tools are persistent working windows.  Keep Escape available
    -- for gameplay panels and close these only through their explicit X or
    -- toggle command.
    PreventEscapeClose(name)
    self:RestorePlacement(frame, spec)
    self:ApplyVisuals(frame)
    frame:Hide()
    return frame
end

function manager:AddScrollingText(frame, spec)
    spec = spec or {}
    if frame.scroll and frame.scrollChild and frame.bodyText then
        return frame.scroll, frame.scrollChild, frame.bodyText
    end
    -- The 3.3.5 UIPanelScrollFrameTemplate concatenates GetName() while its
    -- OnLoad script creates the scrollbar.  Unlike newer clients, an anonymous
    -- template instance therefore throws before CreateFrame returns.
    local parentName = frame.GetName and frame:GetName()
    local scrollName = spec.name or (parentName and (parentName .. "Scroll"))
    if not scrollName then
        manager.scrollSerial = (manager.scrollSerial or 0) + 1
        scrollName = "RXPToolWindowScroll" .. manager.scrollSerial
    end
    local scroll = CreateFrame("ScrollFrame", scrollName, frame,
                               "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", spec.left or 22, -(spec.top or 48))
    scroll:SetPoint("BOTTOMRIGHT", -(spec.right or 36), spec.bottom or 52)
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(max(100, scroll:GetWidth()), 1)
    scroll:SetScrollChild(child)
    local text = child:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT")
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    if text.SetWordWrap then text:SetWordWrap(true) end
    frame.scroll = scroll
    frame.scrollChild = child
    frame.bodyText = text
    frame.text = text

    local function UpdateLayout()
        local width = max(100, scroll:GetWidth() - 8)
        text:SetWidth(width)
        child:SetWidth(width)
        child:SetHeight(max(scroll:GetHeight(), text:GetStringHeight() + 14))
    end
    frame.UpdateToolTextLayout = UpdateLayout
    frame:SetScript("OnSizeChanged", UpdateLayout)
    scroll:EnableMouseWheel(true)
    scroll:HookScript("OnEnter", function() manager:BringToFront(frame) end)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        manager:BringToFront(frame)
        local maximum = self:GetVerticalScrollRange() or 0
        local current = self:GetVerticalScroll() or 0
        self:SetVerticalScroll(Clamp(current - delta * 36, 0, maximum))
    end)
    UpdateLayout()
    return scroll, child, text
end

function manager:SetText(frame, value)
    if not (frame and frame.bodyText) then return end
    frame.bodyText:SetText(value or "")
    if frame.UpdateToolTextLayout then frame:UpdateToolTextLayout() end
end

function manager:SizeButton(button, minimum, maximum)
    if not button then return end
    local text = button:GetFontString()
    local width = text and text:GetStringWidth() or 0
    button:SetWidth(Clamp(width + 28, minimum or 90, maximum or 180))
end

local logout = CreateFrame("Frame")
logout:RegisterEvent("PLAYER_LOGOUT")
logout:SetScript("OnEvent", function()
    for _, frame in pairs(manager.frames) do manager:SavePlacement(frame) end
end)
