local _, addon = ...

-- Presentation owns no guide state. In particular, it must never activate a
-- step, evaluate a directive, or substitute an engine/secure frame.
local view = {}
addon.presentation = view
local L = addon.locale.Get
local function Profile() return addon.settings and addon.settings.profile end
local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = Copy(child) end
    return result
end
local function Number(value, default, low, high)
    value = tonumber(value)
    if not value or value ~= value then value = default end
    return math.max(low, math.min(high, value))
end

function view:GetRequestedStyle()
    return Profile() and Profile().uiStyle == "legacy" and "legacy" or "modern"
end

function view:Initialize()
    if not self.appliedStyle and Profile() then
        self.appliedStyle = self:GetRequestedStyle()
    end
end

function view:IsModern() return self.appliedStyle == "modern" end
function view:IsPending() return self.appliedStyle ~= self:GetRequestedStyle() end

function view:CanReload()
    return not (InCombatLockdown and InCombatLockdown()) and
        not (addon.IsQuestRewardSettlementActive and addon.IsQuestRewardSettlementActive())
end

function view:Reload()
    if not self:CanReload() then
        addon.comms.PrettyPrint(L("Finish combat and the quest interaction before reloading."))
        return false
    end
    ReloadUI()
    return true
end

function view:RequestStyle(style)
    if style ~= "modern" and style ~= "legacy" then return end
    Profile().uiStyle = style
    self:SettingsChanged()
    if not self:IsPending() then return end
    StaticPopupDialogs.RXP_UI_STYLE = {
        text = L("Reload to apply the interface style? Guide progress is preserved."),
        button1 = L("Reload Now"), button2 = L("Later"), timeout = 0,
        whileDead = true, hideOnEscape = true,
        OnShow = function(frame)
            if addon.toolWindows then addon.toolWindows:RaisePopup(frame) end
        end,
        OnAccept = function() view:Reload() end
    }
    StaticPopup_Show("RXP_UI_STYLE")
end

function view:GetHUD()
    local p = Profile()
    if not p then return end
    if type(p.modernHUD) ~= "table" then
        p.modernHUD = {points = Copy(p.framePositions and p.framePositions.RXPFrame),
            width = 340, height = 160, scale = p.windowScale, collapsed = false}
    end
    local data = p.modernHUD
    data.width = Number(data.width, 340, 240, 900)
    data.height = Number(data.height, 160, 60, 700)
    data.scale = Number(data.scale, 1, 0.2, 2)
    data.collapsed = data.collapsed == true
    return data
end

function view:GetHeight()
    return self:IsModern() and self:GetHUD().height or Profile().frameHeight
end
function view:SetHeight(height)
    if self:IsModern() then self:GetHUD().height = Number(height, 160, 60, 700)
    else Profile().frameHeight = height end
end
function view:GetScale()
    return self:IsModern() and self:GetHUD().scale or Profile().windowScale
end
function view:SetScale(scale)
    if self:IsModern() then self:GetHUD().scale = scale else Profile().windowScale = scale end
    addon.RXPFrame:SetScale(scale)
end

function view:SaveHUD(frame)
    local data = self:GetHUD()
    data.points = {}
    for i = 1, frame:GetNumPoints() do
        local point, relative, relativePoint, x, y = frame:GetPoint(i)
        local relativeName = type(relative) == "string" and relative or
            (relative and relative.GetName and relative:GetName())
        data.points[i] = {point, relativeName, relativePoint, x, y}
    end
    data.width, data.scale = frame:GetWidth(), frame:GetScale()
    if not data.collapsed and frame:GetHeight() >= 60 then data.height = frame:GetHeight() end
end

function view:RestoreHUD(frame)
    local data = self:GetHUD()
    frame:ClearAllPoints()
    local restored = false
    if type(data.points) == "table" then
        for _, point in ipairs(data.points) do
            if type(point) == "table" and type(point[1]) == "string" then
                restored = pcall(frame.SetPoint, frame, unpack(point)) or restored
            end
        end
    end
    if not restored then frame:SetPoint("LEFT", UIParent, "LEFT", 16, 35) end
    frame:SetSize(data.width, data.collapsed and 28 or data.height)
    frame:SetScale(data.scale)
end

view.backdrop = {bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
    insets = {left = 1, right = 1, top = 1, bottom = 1}}

-- Shared, read-only colours: repainting must not allocate new palette tables.
local defaultBackground = {0.028, 0.032, 0.065, 0.96}
local defaultSurface = {0.10, 0.11, 0.19, 0.96}
local defaultAccent = {0.10, 0.82, 1}
local fallbackBackground = {0.035, 0.04, 0.075, 1}
local fallbackSurface = {0.1, 0.11, 0.19, 1}
local fallbackText = {0.82, 0.84, 0.9}
local emptyTheme = {}

function view:Palette()
    local p, theme = Profile(), addon.activeTheme or emptyTheme
    if p and (p.activeTheme ~= "Default" or (addon.currentGuide and addon.currentGuide.theme)) then
        return theme.background or fallbackBackground,
            theme.bottomFrameBG or theme.background or fallbackSurface,
            theme.textColor or fallbackText
    end
    return defaultBackground, defaultSurface, defaultAccent
end

function view:Skin(frame, card)
    local background, surface = self:Palette()
    if frame.rxpModernBackdrop ~= self.backdrop or frame.rxpModernTheme ~= addon.activeTheme then
        frame:SetBackdrop(self.backdrop)
        frame.rxpModernBackdrop = self.backdrop
        frame.rxpModernTheme = addon.activeTheme
    end
    frame:SetBackdropColor(unpack(card and surface or background))
    frame:SetBackdropBorderColor(0.30, 0.34, 0.46, 0.85)
end

function view:Button(parent, text, width, callback)
    local button = CreateFrame("Button", nil, parent, not self:IsModern() and "UIPanelButtonTemplate" or nil)
    button:SetSize(width or 120, 26)
    if self:IsModern() then self:Skin(button, true) end
    button:SetNormalFontObject(GameFontHighlightSmall)
    button:SetDisabledFontObject(GameFontDisableSmall)
    button:SetText(text)
    if self:IsModern() then
        button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
        button:GetHighlightTexture():SetVertexColor(0.1, 0.82, 1, 0.15)
    end
    button:SetScript("OnClick", callback)
    return button
end

local white = "Interface\\Buttons\\WHITE8X8"
local footerKeys = {"cog", "browse", "preflight", "speedrun", "speedrunAdvisors"}

-- Skin existing controls, never their handlers or feature-owned label colours.
function view:SkinControl(button, glyph)
    if not self:IsModern() or not button then return end
    local size = Profile().guideFontSize or 9
    if button.rxpControlFont == addon.font and button.rxpControlSize == size and
        button.rxpControlTheme == addon.activeTheme and button.rxpControlGlyph == glyph and
        button.rxpControlRevision == self.themeRevision then return end
    self:Skin(button, true)
    local _, _, accent = self:Palette()
    if not button.rxpModernControl then
        button.rxpModernControl = true
        button:SetNormalTexture(white)
        button:GetNormalTexture():SetVertexColor(0, 0, 0, 0)
        button:SetHighlightTexture(white)
        button:SetPushedTexture(white)
        button:SetDisabledTexture(white)
        button:GetDisabledTexture():SetVertexColor(0.2, 0.2, 0.25, 0.65)
    end
    button:GetHighlightTexture():SetVertexColor(accent[1], accent[2], accent[3], 0.20)
    button:GetPushedTexture():SetVertexColor(accent[1], accent[2], accent[3], 0.35)
    local label = button.GetFontString and button:GetFontString()
    if label then addon.SetFontSafely(label, addon.font, size, "") end
    if glyph == "cog" then
        button:SetNormalTexture(addon.GetTexture("rxp_cog-32"))
        button:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
    elseif glyph == "grip" then
        if not button.rxpGrip then
            button.rxpGrip = {}
            -- Short diagonal runs of square pixels need no modern line API.
            for row = 0, 2 do
                for column = 0, 2 - row do
                    local dot = button:CreateTexture(nil, "OVERLAY")
                    dot:SetTexture(white)
                    dot:SetSize(2, 2)
                    dot:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3 - column * 4, 3 + row * 4)
                    button.rxpGrip[#button.rxpGrip + 1] = dot
                end
            end
        end
        for _, dot in ipairs(button.rxpGrip) do dot:SetVertexColor(accent[1], accent[2], accent[3], 0.85) end
    elseif glyph then
        if not button.rxpGlyph then
            button.rxpGlyph = button:CreateFontString(nil, "OVERLAY")
            button.rxpGlyph:SetPoint("CENTER", 0, 0)
        end
        addon.SetFontSafely(button.rxpGlyph, addon.font, 12, "")
        button.rxpGlyph:SetText(glyph)
        button.rxpGlyph:SetTextColor(unpack(accent))
        local function State()
            local enabled = button:IsEnabled()
            button.rxpGlyph:SetAlpha((enabled == false or enabled == 0) and 0.35 or 1)
        end
        if not button.rxpGlyphHooks and hooksecurefunc then
            button.rxpGlyphHooks = true
            hooksecurefunc(button, "Enable", State)
            hooksecurefunc(button, "Disable", State)
        end
        State()
    end
    button.rxpControlFont, button.rxpControlSize = addon.font, size
    button.rxpControlTheme, button.rxpControlGlyph = addon.activeTheme, glyph
    button.rxpControlRevision = self.themeRevision
end

function view:SkinScrollBar()
    local scroll = addon.RXPFrame and addon.RXPFrame.ScrollFrame
    local bar = scroll and scroll.ScrollBar
    if not (self:IsModern() and bar) then return end
    self:Skin(bar)
    self:SkinControl(bar.ScrollUpButton, "^")
    self:SkinControl(bar.ScrollDownButton, "v")
    if not bar.rxpModernThumb then
        bar:SetThumbTexture(white)
        bar.rxpModernThumb = true
    end
    local thumb = bar:GetThumbTexture()
    local _, _, accent = self:Palette()
    thumb:SetVertexColor(accent[1], accent[2], accent[3], 0.75)
    thumb:SetWidth(8)
end

function view:QueueFooter()
    if not self:IsModern() then return end
    self:ApplyCollapse()
    if self.pendingFooter then return end
    self.pendingFooter = true
    addon.scheduler:After(self, "footer", 0, function()
        self.pendingFooter = nil
        if self:IsModern() and self:LayoutFooter() then self:Invalidate() end
    end)
end

function view:LayoutFooter()
    local root = addon.RXPFrame
    local footer = root and root.Footer
    if not (self:IsModern() and footer and footer.text) then return false end
    local size = Profile().guideFontSize or 9
    local rowHeight, gap = math.max(22, size + 8), 4
    if not footer.rxpMeasure then
        footer.rxpMeasure = footer:CreateFontString(nil, "OVERLAY")
        footer.rxpMeasure:Hide()
        footer.rxpMeasure:SetWidth(0)
    end
    addon.SetFontSafely(footer.rxpMeasure, addon.font, size, "")
    local function TextWidth(region)
        footer.rxpMeasure:SetText(region and region:GetText() or "")
        return math.ceil(footer.rxpMeasure:GetStringWidth())
    end
    local available = math.max(40, root:GetWidth() - 38) -- padding + resize grip
    local x, y, controls = 0, 0, {}
    local signature = {root:GetWidth(), size}
    local minimumWidth = 240
    for _, key in ipairs(footerKeys) do
        local button = footer[key]
        if button then
            self:SkinControl(button, key == "cog" and "cog" or nil)
            if not button.rxpFooterHooks then
                button.rxpFooterHooks = true
                button:HookScript("OnShow", function() view:QueueFooter() end)
                button:HookScript("OnHide", function() view:QueueFooter() end)
                if hooksecurefunc then hooksecurefunc(button, "SetText", function() view:QueueFooter() end) end
            end
            if button:IsShown() then
                local text = button.GetFontString and button:GetFontString()
                local width = math.max(key == "cog" and 22 or 26,
                    text and TextWidth(text) + 16 or 22)
                minimumWidth = math.max(minimumWidth, width + 38)
                if x > 0 and x + width > available then x, y = 0, y + rowHeight + gap end
                controls[#controls + 1] = {button, x, y, width}
                signature[#signature + 1] = key .. ":" .. width
                x = x + width + gap
            end
        end
    end
    if not footer.rxpTextHook and hooksecurefunc then
        footer.rxpTextHook = true
        hooksecurefunc(footer.text, "SetText", function() view:QueueFooter() end)
    end
    local statusWidth = math.max(80, TextWidth(footer.text))
    if x > 0 and available - x < statusWidth then x, y = 0, y + rowHeight + gap end
    signature[#signature + 1] = tostring(x) .. ":" .. tostring(y)
    signature[#signature + 1] = tostring(footer.xpStatus)
    local height = y + rowHeight + 8
    local changedHeight = self.footerHeight ~= height
    self.footerHeight = height
    local minimumHeight = height + math.max(60, size * 2 + 40)
    local compact = self:GetHUD().collapsed or (addon.currentGuide and addon.currentGuide.hidewindow)
    addon.SetResizeBounds(root, minimumWidth, compact and 28 or minimumHeight)
    local changedWidth = root:GetWidth() < minimumWidth
    if changedWidth then root:SetWidth(minimumWidth) end
    local key = table.concat(signature, "|")
    if key ~= self.footerSignature then
        self.footerSignature = key
        footer:SetHeight(height)
        for _, item in ipairs(controls) do
            local button = item[1]
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", footer, "TOPLEFT", 8 + item[2], -4 - item[3])
            button:SetSize(item[4], rowHeight)
        end
        footer.text:ClearAllPoints()
        footer.text:SetPoint("TOPLEFT", footer, "TOPLEFT", 8 + x, -4 - y)
        footer.text:SetPoint("RIGHT", footer, "RIGHT", -26, 0)
        footer.text:SetHeight(rowHeight)
        if footer.xpStatus then
            footer.xpStatus:ClearAllPoints()
            footer.xpStatus:SetAllPoints(footer.text)
        end
        root.BottomFrame:SetPoint("BOTTOMRIGHT", root, -3, height + 4)
    end
    if not compact and root:GetHeight() < minimumHeight then root:SetHeight(minimumHeight) end
    self:ApplyCollapse()
    return changedHeight or changedWidth
end

function view:GetExpandedHeight()
    return math.max(self:GetHUD().height, (self.footerHeight or 20) +
        math.max(60, (Profile().guideFontSize or 9) * 2 + 40))
end

-- The list's logical offsets and actual anchors share this one calculation.
-- Hidden rows take no space; full and targeted refreshes use the same path.
function view:ReflowRows(child, positions)
    local y, count, last = 0, 0, 0
    for n, frame in ipairs(child.framePool or {}) do
        if not frame:IsShown() then break end
        last = n
        positions[n] = y
        if frame.rxpRowOffset ~= y then
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -y)
            frame:SetPoint("TOPRIGHT", child, "TOPRIGHT", 0, -y)
            frame.rxpRowOffset = y
            count = count + 1
        end
        local height = frame.rxpRowHeight or frame:GetHeight()
        if height > 0 then y = y + height + 4 end
    end
    positions[0] = math.max(0, y - 4)
    for n = last + 1, #positions do positions[n] = nil end
    child:SetHeight(math.max(1, positions[0]))
    if count > 0 and addon.PerfCount then addon.PerfCount("row positions shifted", count) end
end

function view:MeasureRow(frame, text, hidden)
    local gutter = frame.number:GetWidth()
    if frame.rxpRowGutter ~= gutter then
        frame.rxpRowGutter = gutter
        frame.number:ClearAllPoints()
        frame.number:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -6)
    end
    addon.guideLayout:PrepareText(frame.text, frame, "TOPLEFT", 8, -6,
        frame:GetWidth() - 28 - gutter)
    local height = addon.guideLayout:MeasureText(frame.text, text, false, hidden, 12)
    height = hidden and 0 or math.max(height, frame.number:GetHeight() + 12)
    local changed = frame.rxpRowHeight ~= height or frame.rxpRowOffset == nil
    if frame.rxpRowHeight ~= height then
        frame.rxpRowHeight = height
        frame:SetHeight(math.max(1, height))
        if addon.PerfCount then addon.PerfCount("row height changes") end
    end
    return height, changed
end

function view:ApplyHUD()
    if not self:IsModern() then return end
    local root = addon.RXPFrame
    if not (root and root.GuideName and root.GuideName.text) then return end
    self:Skin(root.BottomFrame)
    self:Skin(root.GuideName, true)
    self:Skin(root.Footer, true)
    root.GuideName.bg:SetTexture(nil)
    root.Footer.bg:SetTexture(nil)
    root.GuideName.text:SetTextColor(1, 0.82, 0.35)
    if Profile().activeTheme ~= "Default" and addon.activeTheme and addon.activeTheme.textColor then
        root.GuideName.text:SetTextColor(unpack(addon.activeTheme.textColor))
    end
    root.GuideName.text:SetPoint("RIGHT", root.GuideName, -28, 0)
    root.GuideName.text:SetPoint("LEFT", root.GuideName, 42, 0)
    root.GuideName:SetHeight(math.max(35, (Profile().guideFontSize or 9) * 2 + 14))
    root.GuideName:ClearAllPoints()
    root.GuideName:SetPoint("BOTTOMLEFT", root, "TOPLEFT", 3, 0)
    root.GuideName:SetPoint("BOTTOMRIGHT", root, "TOPRIGHT", -3, 0)
    if root.GuideName.icon then
        root.GuideName.icon:SetSize(28, 28)
        root.GuideName.icon:ClearAllPoints()
        root.GuideName.icon:SetPoint("LEFT", root.GuideName, "LEFT", 6, 0)
        root.GuideName.classIcon:SetSize(14, 14)
        root.GuideName.classIcon:ClearAllPoints()
        root.GuideName.classIcon:SetPoint("BOTTOMRIGHT", root.GuideName.icon, "BOTTOMRIGHT", 3, -1)
    end
    if not root.modernListLabel then
        root.modernListLabel = root.BottomFrame:CreateFontString(nil, "OVERLAY")
        root.modernListLabel:SetPoint("TOPLEFT", root.BottomFrame, "TOPLEFT", 8, -6)
        root.modernListLabel:SetPoint("RIGHT", root.BottomFrame, "RIGHT", -24, 0)
        root.modernListLabel:SetJustifyH("LEFT")
    end
    addon.SetFontSafely(root.modernListLabel, addon.font, Profile().guideFontSize or 9, "")
    root.modernListLabel:SetText(L("Guide steps"))
    local _, _, accent = self:Palette()
    root.modernListLabel:SetTextColor(unpack(accent))
    if root.ScrollFrame then
        root.ScrollFrame:SetPoint("TOPLEFT", root.BottomFrame, 5, -((Profile().guideFontSize or 9) + 16))
    end
    self:SkinControl(root.Footer.icon, "grip")
    self:SkinScrollBar()
    if not root.modernCollapse then
        root.modernCollapse = self:Button(root.GuideName, "-", 22, function()
            local data = view:GetHUD()
            if not data.collapsed then data.height = math.max(60, root:GetHeight()) end
            data.collapsed = not data.collapsed
            view:Invalidate()
        end)
        root.modernCollapse:SetPoint("RIGHT", -3, 0)
        root.modernCollapse:SetHeight(22)
    end
    root.modernCollapse:SetText(self:GetHUD().collapsed and "+" or "-")
    self:LayoutFooter()
    self:ApplyCollapse()
end

-- Alpha, rather than Hide, keeps feature-owned visibility and execution hosts
-- intact. Mouse state is restored exactly, including previously-disabled input.
local function Conceal(frame, concealed)
    if not frame then return end
    if concealed then
        if frame.rxpConcealedAlpha == nil then
            frame.rxpConcealedAlpha = frame:GetAlpha()
            frame.rxpConcealedMouse = frame.IsMouseEnabled and frame:IsMouseEnabled() or false
        end
        frame:SetAlpha(0)
        if frame.EnableMouse then frame:EnableMouse(false) end
    elseif frame.rxpConcealedAlpha ~= nil then
        frame:SetAlpha(frame.rxpConcealedAlpha)
        if frame.EnableMouse then frame:EnableMouse(frame.rxpConcealedMouse) end
        frame.rxpConcealedAlpha, frame.rxpConcealedMouse = nil, nil
    end
end

function view:ApplyCollapse()
    if not self:IsModern() then return end
    local root, data = addon.RXPFrame, self:GetHUD()
    if not root then return end
    local collapsed = data.collapsed
    local compact = collapsed or (addon.currentGuide and addon.currentGuide.hidewindow) or false
    for _, frame in ipairs(root.CurrentStepFrame.framePool or {}) do
        if frame.step and not frame.step.tip then
            if collapsed then
                frame:SetAlpha(0)
                frame:EnableMouse(false)
                for _, element in ipairs(frame.elements or {}) do
                    element:EnableMouse(false)
                    if element.button then element.button:EnableMouse(false) end
                end
            end
        end
    end
    Conceal(root.Footer, compact)
    if root.Footer then
        Conceal(root.Footer.text, compact) -- historically parented to GuideName
        Conceal(root.Footer.icon, compact)
        Conceal(root.Footer.xpStatus, compact)
        for _, key in ipairs(footerKeys) do Conceal(root.Footer[key], compact) end
    end
    if root.rxpCollapsedMouse == nil and compact then
        root.rxpCollapsedMouse = root:IsMouseEnabled() and true or false
    end
    if compact then
        root:EnableMouse(false)
        root:SetHeight(28)
        root.BottomFrame:Hide()
    elseif root.rxpCollapsedMouse ~= nil then
        root:EnableMouse(root.rxpCollapsedMouse)
        root.rxpCollapsedMouse = nil
    end
end

function view:Invalidate()
    if not self:IsModern() or self.pendingRefresh then return end
    self.pendingRefresh = true
    addon.scheduler:After(self, "paint", 0, function()
        self.pendingRefresh = nil
        if not self:IsModern() then return end
        if addon.RefreshGuidePresentation then addon.RefreshGuidePresentation() end
        if addon.toolWindows then addon.toolWindows:RefreshVisuals() end
        if self.pendingTheme then
            self.pendingTheme = nil
            for _, key in ipairs({"activeItemFrame", "activeTargetFrame", "arrowFrame"}) do
                local frame = addon.enabledFrames and addon.enabledFrames[key]
                if frame and frame.UpdateVisuals then frame:UpdateVisuals() end
            end
        end
        self:SettingsChanged()
    end)
end

function view:SettingsChanged()
    self.settingsRevision = (self.settingsRevision or 0) + 1
    if addon.featureToolsUI and addon.featureToolsUI.Refresh then addon.featureToolsUI:Refresh() end
    if addon.libraryTabs then addon.libraryTabs:SettingsChanged() end
end

-- Shared by existing cosmetic callbacks, not by gameplay-triggered RenderFrame.
function view:RefreshAppearance()
    if not self:IsModern() then return addon.RenderFrame("themeReload") end
    addon:LoadActiveTheme()
    addon.colors = addon.activeTheme
    self.themeRevision = (self.themeRevision or 0) + 1
    self.pendingTheme = true
    self:Invalidate()
end

function view:RefreshTextColors()
    addon.settings:LoadTextColors()
    if addon.guideLocalization then addon.guideLocalization:ClearCache() end
    if self:IsModern() then self:Invalidate() else addon.RenderFrame() end
end
