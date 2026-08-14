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
local tinsert = table.insert

manager.frames = manager.frames or {}
manager.knownNames = manager.knownNames or {
    "RXPRoutePreflightWindow",
    "RXPPerformanceInspector",
    "RXPHunterPetAssistant",
    "RXPLevelingArchives",
    "RXPXPProgressWindow"
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

local function RegisterEscapeFrame(name)
    if type(name) ~= "string" or not _G.UISpecialFrames then return end
    for _, existing in ipairs(_G.UISpecialFrames) do
        if existing == name then return end
    end
    tinsert(_G.UISpecialFrames, name)
end

local function GetProfile()
    return addon.settings and addon.settings.profile
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
    frame:SetBackdropColor(background[1] or 0.035, background[2] or 0.035,
                           background[3] or 0.07, max(0.94,
                           tonumber(background[4]) or 1))
    frame:SetBackdropBorderColor(0.72, 0.72, 0.72, 1)

    local fontSize = max(10, tonumber(GetProfile() and
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
    if existing then return existing end

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
    frame:HookScript("OnShow", function(self) manager:ApplyVisuals(self) end)
    frame:HookScript("OnHide", function(self) manager:SavePlacement(self) end)
    manager.frames[name] = frame
    RegisterEscapeFrame(name)
    self:RestorePlacement(frame, spec)
    self:ApplyVisuals(frame)
    frame:Hide()
    return frame
end

function manager:AddScrollingText(frame, spec)
    spec = spec or {}
    local scroll = CreateFrame("ScrollFrame", spec.name, frame,
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
    scroll:SetScript("OnMouseWheel", function(self, delta)
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
