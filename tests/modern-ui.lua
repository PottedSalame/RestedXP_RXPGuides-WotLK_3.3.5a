return function(root)
    local function check(value, message) assert(value, "Modern UI: " .. message) end
    local env = setmetatable({}, {__index = _G})
    env._G = env
    local events, queued, calls = {}, {}, {load = 0, reload = 0}
    local function object(name)
        local f = {name = name, width = 900, height = 600, shown = true, scripts = {}, points = {}}
        function f:GetName() return self.name end
        function f:SetSize(w, h) self.width, self.height = w, h end
        function f:SetWidth(w) self.width = w end
        function f:SetHeight(h) self.height = h end
        function f:GetWidth() return self.width end
        function f:GetHeight() return self.height end
        function f:SetScale(v) self.scale = v end
        function f:GetScale() return self.scale or 1 end
        function f:SetPoint(...) self.points[#self.points + 1] = {...} end
        function f:GetPoint(i) return unpack(self.points[i or 1] or {}) end
        function f:GetNumPoints() return #self.points end
        function f:ClearAllPoints() self.points = {} end
        function f:ClearBackdrop() self.backdrop = nil end
        function f:SetBackdrop(value) self.backdrop = value end
        function f:SetTextColor(...) self.color = {...} end
        function f:GetTop() return 500 end
        function f:GetBottom() return 100 end
        function f:SetText(text) self.textValue = text; if self.fontString then self.fontString:SetText(text) end end
        function f:GetFontString()
            if not self.fontString then self.fontString = object(); self.fontString:SetText(self.textValue) end
            return self.fontString
        end
        function f:GetText() return self.textValue or "" end
        function f:GetStringWidth() return #(self.textValue or "") * 7 end
        function f:GetStringHeight() return 16 end
        function f:SetFont(path, size) self.font, self.fontSize = path, size; return true end
        function f:GetFont() return self.font or "font", self.fontSize or 12, "" end
        function f:SetAlpha(a) self.alpha = a end
        function f:GetAlpha() return self.alpha or 1 end
        function f:IsMouseEnabled() return self.mouse == true end
        function f:IsEnabled() return not self.disabled end
        function f:SetChecked(value) self.checked = value end
        function f:GetChecked() return self.checked end
        function f:SetValue(value) self.value = value; if self.scripts.OnValueChanged then self.scripts.OnValueChanged(self, value) end end
        function f:GetValue() return self.value end
        function f:EnableMouse(value) self.mouse = value end
        function f:EnableMouseWheel(value) self.mouseWheel = value end
        function f:SetScript(key, fn) self.scripts[key] = fn end
        function f:GetScript(key) return self.scripts[key] end
        function f:HookScript(key, fn)
            local previous = self.scripts[key]
            self.scripts[key] = function(...) if previous then previous(...) end; fn(...) end
        end
        function f:Show() local was = self.shown; self.shown = true; if not was and self.scripts.OnShow then self.scripts.OnShow(self) end end
        function f:Hide() local was = self.shown; self.shown = false; if was and self.scripts.OnHide then self.scripts.OnHide(self) end end
        function f:SetShown(value) if value then self:Show() else self:Hide() end end
        function f:IsShown() return self.shown end
        function f:IsVisible() return self.shown and (not self.parent or self.parent:IsVisible()) end
        function f:SetParent(parent) self.parent = parent end
        function f:GetParent() return self.parent end
        function f:ClearFocus() end
        function f:GetFrameLevel() return self.level or 1 end
        function f:GetFrameStrata() return self.strata or "DIALOG" end
        function f:Enable() self.disabled = false end
        function f:Disable() self.disabled = true end
        function f:GetChildren() end
        function f:CreateTexture() return object() end
        function f:CreateFontString() return object() end
        for _, name in ipairs({"Normal", "Highlight", "Pushed", "Disabled", "Thumb"}) do
            local field = name .. "Texture"
            f["Set" .. field] = function(self, path)
                self[field] = self[field] or object()
                self[field].texturePath = path
            end
            f["Get" .. field] = function(self) return self[field] end
        end
        return setmetatable(f, {__index = function(_, key)
            if key:match("^Set") or key:match("^Register") or key:match("^Start") or key:match("^Stop") then return function() end end
        end})
    end
    env.CreateFrame = function(_, name, parent) local f = object(name); f.parent = parent; if name then env[name] = f end; return f end
    env.LibStub = function(name) assert(name == "AceGUI-3.0"); return {ClearFocus = function() end} end
    env.GameTooltip = object()
    env.UIParent, env.GameFontHighlightSmall, env.GameFontDisableSmall = object("UIParent"), object(), object()
    env.GetScreenWidth, env.GetScreenHeight = function() return 1024 end, function() return 768 end
    env.StaticPopupDialogs, env.UISpecialFrames = {}, {}
    env.StaticPopup_Show = function(key) events.popup = key end
    env.ReloadUI = function() calls.reload = calls.reload + 1 end
    env.hooksecurefunc = function(target, key, after)
        local original = target[key]
        target[key] = function(...) original(...); after(...) end
    end
    env.InCombatLockdown = function() return events.combat end
    env.UnitLevel = function() return 1 end
    env.FauxScrollFrame_GetOffset = function(f) return f.offset or 0 end
    env.FauxScrollFrame_SetOffset = function(f, n) f.offset = n end
    env.FauxScrollFrame_Update = function() end
    env.FauxScrollFrame_OnVerticalScroll = function(f, n, row, cb) f.offset = math.floor(n / row); cb() end
    env.RXPData = {guideHub = {favorites = {}, filters = {}}}
    env.RXPCData = {guideProgress = {}, recentGuides = {}, currentStep = 4, stepSkip = {}}
    local profile = {activeTheme = "Default", framePositions = {RXPFrame = {{"LEFT", "UIParent", "LEFT", 7, 8}}},
        frameSizes = {RXPFrame = {245, 120}}, windowScale = 0.9, frameHeight = 10}
    local addon = {locale = {Get = function(text) return text end}, settings = {profile = profile},
        scheduler = {After = function(_, owner, key, _, cb) queued[key] = cb end},
        player = {class = "WARRIOR", faction = "Horde"}, font = "font", colors = {},
        IsQuestRewardSettlementActive = function() return events.reward end,
        comms = {PrettyPrint = function() end}, guideState = {Load = function() calls.load = calls.load + 1 end},
        SetFontSafely = function(f, path, size) f:SetFont(path, size) end}
    addon.GetTexture = function(name) return "Textures/" .. name end
    addon.SetResizeBounds = function(f, w, h) f.minWidth, f.minHeight = w, h end
    local function load(path)
        local chunk = assert(loadfile(root .. "/" .. path))
        setfenv(chunk, env)("RXPGuides", addon)
    end
    load("UI/Presentation.lua")
    local view = addon.presentation
    check(not view:IsModern(), "must wait for profile initialization")
    view:Initialize()
    check(view:IsModern(), "absent preference defaults to modern")
    view:RequestStyle("legacy")
    check(view:IsModern() and view:IsPending() and calls.reload == 0, "style request must not apply or reload")
    events.combat = true; check(not view:Reload(), "combat reload blocked")
    events.combat = nil; events.reward = true; check(not view:Reload(), "reward reload blocked")
    events.reward = nil; view:Reload(); check(calls.reload == 1, "explicit safe reload")
    view:RequestStyle("modern"); check(not view:IsPending(), "cancel pending style")
    local data = view:GetHUD()
    check(data.height >= 60 and data.points ~= profile.framePositions.RXPFrame, "isolated expanded geometry")
    local frame = object("RXPFrame")
    view:RestoreHUD(frame)
    frame:SetSize(370, 180); view:SaveHUD(frame)
    check(profile.frameSizes.RXPFrame[1] == 245 and profile.frameHeight == 10 and profile.windowScale == 0.9, "legacy geometry preserved")
    local paints = 0
    addon.RefreshGuidePresentation = function() paints = paints + 1 end
    view:Invalidate(); view:Invalidate(); queued.paint()
    check(paints == 1, "cosmetics coalesce")
    load("UI/ToolWindow.lua")
    local guides = {
        a = {key = "validated|1-6", name = "1-6 Durotar", group = "Validated"},
        b = {key = "original|1-6", name = "1-6 Durotar", group = "Original Guides - Classic"}}
    addon.guideList = {Validated = {names_ = {"a"}}, ["Original Guides - Classic"] = {names_ = {"b"}}}
    addon.GetGuideTable = function(_, name) return guides[name] end
    addon.GetGuideName = function(g) return g.name end
    addon.IsGuideActive = function() return true end
    -- Reproduce an existing client's file list without the new optional chunk.
    -- Both views must get their controller from the shared hub itself.
    load("UI/GuideHub.lua"); load("UI/ModernLibrary.lua")
    check(type(addon.libraryTabs) == "table", "hub owns its required controller")
    local hub = addon.guideHub
    hub:Setup(); hub:Toggle()
    check(hub.frame.modern and #hub.filtered == 1, "modern library respects source collection")
    hub:Select(hub.filtered[1]); check(calls.load == 0 and env.RXPCData.currentStep == 4, "preview is read-only")
    local oldEntry = hub.selected
    hub:ChooseStep()
    hub:ToggleFavorite(hub.selected)
    check(env.RXPData.guideHub.favorites[guides.a.key], "canonical favorites")
    hub.collection = "original"; hub:Refresh()
    check(#hub.filtered == 1 and not hub.selected, "filter clears stale selection")
    env.StaticPopupDialogs.RXP_GUIDE_HUB_STEP.OnAccept({editBox = {GetText = function() return "2" end}}, oldEntry)
    check(calls.load == 0, "stale choose-step dialog cannot load")
    check(not env.RXPData.guideHub.favorites[guides.b.key], "family favorites isolated")
    hub.frame:SetSize(680, 530); addon.modernLibrary:Layout(hub)
    check(calls.load == 0, "resize cannot load guides")
    check(hub.frame.detailScroll and hub.frame.detailChild, "small-screen notices remain scrollable")
    profile.guideFontSize = 22
    addon.modernLibrary:Rows(hub)
    check(hub.frame.rowHeight >= 56, "large-font library rows grow")
    profile.guideFontSize = nil
    -- The actual settings adapter must call closures/methods with the complete
    -- Ace info path, never infer a profile key from a repeated leaf name.
    addon.title = "RestedXP Guides"
    local changes, approved = 0
    addon.comms.ConfirmChoice = function(_, _, _, callback) approved = callback end
    local handler = {}
    function handler:Read(info)
        check(info[0] == addon.title and info[1] == "featureToolsSettings" and info[3] == "enable" and
            info.options == addon.settings.optionTree and info.option.arg == "fixture", "Ace info contract")
        return addon.settings.profile.fixtureEnabled
    end
    function handler:Write(info, value)
        self:Read(info); changes = changes + 1; addon.settings.profile.fixtureEnabled = value
    end
    addon.settings.optionTree = {type = "group", handler = handler, args = {featureToolsSettings = {
        type = "group", name = "Tools", args = {routePreflight = {type = "group", name = "Preflight", args = {
            enable = {type = "toggle", name = "Enable", arg = "fixture", get = "Read", set = "Write", order = 1},
            scale = {type = "range", name = "Scale", min = 0.5, max = 2, step = 0.1, order = 2,
                get = function() return addon.settings.profile.fixtureScale or 1 end,
                set = function(_, v) changes = changes + 1; addon.settings.profile.fixtureScale = v end},
            description = {type = "description", name = "Instructions", order = 0},
            choice = {type = "select", name = "Choice", values = {a = "A", b = "B"}, order = 3,
                get = function() return "a" end, set = function() changes = changes + 1 end},
            reset = {type = "execute", name = "Reset", confirm = true, order = 4,
                disabled = function() return events.disabled end,
                func = function() changes = changes + 1 end}
        }}}}}}
    load("UI/SettingsAdapter.lua"); load("UI/FeatureTools.lua")
    check(addon.featureToolsUI:FormatValue(0.8, {isPercent = true, step = 0.05}) == "80%", "percentage format")
    check(addon.featureToolsUI:FormatValue(1, {isPercent = true, step = 0.05}) == "100%", "scale format")
    check(addon.featureToolsUI:FormatValue(12, {step = 1}) == "12", "integer format")
    check(addon.featureToolsUI:FormatValue(1.25, {step = 0.05}) == "1.25", "fraction format")
    check(addon.featureToolsUI:FormatValue(0.125, {isPercent = true, step = 0.005}) == "12.5%", "fractional percent format")
    local adapter = addon.settingsAdapter
    local enable = {"featureToolsSettings", "routePreflight", "enable"}
    adapter:Value(enable, "get")
    check(adapter:Commit(enable, true) and changes == 1 and profile.fixtureEnabled, "setter called once")
    check(not adapter:Commit({"lookAndFeel", "enable"}, true), "foreign path rejected")
    check(adapter:Commit({"featureToolsSettings", "routePreflight", "scale"}, 2.8) and profile.fixtureScale == 2, "range clamps")
    check(not adapter:Commit({"featureToolsSettings", "routePreflight", "choice"}, "missing"), "invalid select rejected")
    local reset = {"featureToolsSettings", "routePreflight", "reset"}
    adapter:Commit(reset); view:SettingsChanged(); approved()
    check(changes == 2, "stale in-place backup/profile confirmation rejected")
    adapter:Commit(reset); events.disabled = true; approved()
    check(changes == 2, "recheck disabled after confirmation")
    events.disabled = nil
    adapter:Commit(reset); approved(); check(changes == 3, "confirmed action called once")
    addon.featureToolsUI:Open("routePreflight")
    check(changes == 3, "building tool controls invokes no setters")
    addon.featureToolsUI:Refresh(); check(changes == 3, "refresh invokes no setters")
    local escapes = {}
    for _, name in ipairs(env.UISpecialFrames) do escapes[name] = true end
    check(escapes.RXPGuideHub and not escapes.RXPFeatureTools, "library and persistent-tool Escape policies differ")
    local slider = addon.featureToolsUI.controls.range[1].widget
    local setSliderValue = slider.SetValue
    slider.SetValue = function(self, value)
        if self:GetValue() ~= value then setSliderValue(self, value) end
    end
    local scaleOption = addon.settings.optionTree.args.featureToolsSettings.args.routePreflight.args.scale
    scaleOption.isPercent = true
    addon.featureToolsUI:Refresh()
    check(addon.featureToolsUI.controls.range[1].value:GetText() == "200%" and changes == 3,
        "pooled slider formats unchanged values without relying on change events or setters")
    scaleOption.isPercent = nil
    addon.featureToolsUI:Refresh()
    check(addon.featureToolsUI.controls.range[1].value:GetText() == "2.0", "pooled slider restores fractional format")
    slider.scripts.OnMouseDown()
    slider:SetValue(1.2); check(changes == 3, "slider preview does not commit")
    slider.scripts.OnMouseUp(); check(changes == 4, "slider commits once on release")
    slider.scripts.OnMouseDown(); view:SettingsChanged(); slider.scripts.OnMouseUp()
    check(changes == 4, "stale slider gestures cannot commit")
    local oldProfile = addon.settings.profile
    addon.settings.profile = {uiStyle = "legacy"}
    view:SettingsChanged()
    check(view:IsModern() and view:IsPending(), "profile switch cannot change applied style")
    adapter:Commit(enable, false)
    check(oldProfile.fixtureEnabled == true and addon.settings.profile.fixtureEnabled == false, "adapter does not retain old profile")
    addon.settings.profile = oldProfile

    -- Exercise the real cosmetic entry point. Engine callbacks deliberately
    -- throw; a future accidental call cannot silently pass this test.
    local sourceFile = assert(io.open(root .. "/UI/GuideWindow.lua", "rb"))
    local source = sourceFile:read("*a"); sourceFile:close()
    local startAt = assert(source:find("function addon.RefreshGuidePresentation()", 1, true))
    local endAt = assert(source:find("\nfunction BottomFrame.UpdateFrame", startAt, true))
    local rootFrame = object("RXPFrame")
    rootFrame.BottomFrame, rootFrame.CurrentStepFrame = object(), object()
    rootFrame.GuideName, rootFrame.Footer = object(), object()
    rootFrame.GuideName.text, rootFrame.GuideName.bg = object(), object()
    rootFrame.Footer.bg = object()
    rootFrame.Footer.text = object(); rootFrame.Footer.text:SetText("XP 360 left")
    rootFrame.Footer.cog, rootFrame.Footer.browse, rootFrame.Footer.preflight, rootFrame.Footer.icon = object(), object(), object(), object()
    rootFrame.Footer.browse:SetText("Browse"); rootFrame.Footer.preflight:SetText("OK")
    rootFrame.CurrentStepFrame.framePool = {}
    rootFrame.UpdateVisuals = function() view:ApplyHUD() end
    rootFrame.SetStepFrameAnchor = function() end
    addon.RXPFrame = rootFrame
    addon.guideLayout = {Invalidate = function() end}
    addon.UpdateGuideFontSize = function(pure) check(pure == true, "font refresh is pure") end
    rootFrame.CurrentStepFrame.UpdateText = function(pure) check(pure == true, "objective refresh is pure") end
    rootFrame.BottomFrame.UpdateFrame = function(_, _, pure) check(pure == true, "list refresh is pure") end
    addon.currentGuide = {steps = {}}
    addon.SetStep = function() error("cosmetics activated a step") end
    addon.LoadGuide, addon.ReloadGuide, addon.Call = addon.SetStep, addon.SetStep, addon.SetStep
    env.addon, env.RXPFrame, env.CurrentStepFrame, env.BottomFrame = addon, rootFrame, rootFrame.CurrentStepFrame, rootFrame.BottomFrame
    setfenv(assert(loadstring(source:sub(startAt, endAt - 1))), env)()
    addon.RefreshGuidePresentation()
    check(rootFrame.Footer.cog:GetNormalTexture().texturePath == "Textures/rxp_cog-32" and
        not rootFrame.Footer.cog.rxpGlyph and #rootFrame.Footer.icon.rxpGrip == 6,
        "Modern uses the project cog and a small code-drawn resize grip")
    -- Actual controls retain scripts and status colours. Late-created badges
    -- are laid out without enabling features or borrowing a coach dependency.
    local footer = rootFrame.Footer
    rootFrame:SetWidth(240)
    profile.guideFontSize = 9
    footer.browse:EnableMouse(true)
    local clicked = function() end
    footer.browse:SetScript("OnClick", clicked)
    footer.preflight:GetFontString():SetTextColor(1, 0.2, 0.1)
    local semanticColor = footer.preflight:GetFontString().color
    footer.preflight:Disable()
    footer.xpStatus = object(); footer.xpStatus:EnableMouse(true)
    local coach, advisors = object(), object()
    coach:SetText("D +12:34"); advisors:SetText("ADV 1")
    local function CheckFooter()
        view:LayoutFooter(); view:LayoutFooter()
        local keys, rectangles = {"cog", "browse", "preflight", "speedrun", "speedrunAdvisors"}, {}
        for _, key in ipairs(keys) do
            local button = footer[key]
            if button and button:IsShown() then
                local p = button.points[1]
                check(p and p[2] == footer, "footer control belongs to its existing footer")
                local x, y, w, h = p[4], -p[5], button:GetWidth(), button:GetHeight()
                check(x >= 8 and x + w <= rootFrame:GetWidth() - 26, "footer control fits width")
                check(y + h <= view.footerHeight, "footer control fits height")
                for _, r in ipairs(rectangles) do
                    check(x + w <= r[1] or r[1] + r[3] <= x or y + h <= r[2] or r[2] + r[4] <= y,
                        "footer controls do not overlap")
                end
                rectangles[#rectangles + 1] = {x, y, w, h}
            end
        end
        check(rootFrame.minHeight >= view.footerHeight + 60, "list retains a usable minimum viewport")
    end
    CheckFooter()
    local compactHeight = view.footerHeight
    footer.speedrunAdvisors = advisors; CheckFooter()
    check(view.footerHeight > compactHeight, "advisors alone wrap rather than vanish")
    footer.speedrun = coach; CheckFooter()
    advisors:Hide(); CheckFooter(); advisors:Show(); CheckFooter()
    coach:Hide(); CheckFooter(); coach:Show(); CheckFooter()
    rootFrame:SetWidth(700); CheckFooter()
    check(view.footerHeight == compactHeight, "wide footer returns to one row")
    profile.guideFontSize = 22
    footer.browse:SetText("A longer translated Resume label")
    rootFrame:SetWidth(240)
    check(view:LayoutFooter(), "long-label width growth requests a follow-up layout")
    CheckFooter()
    check(footer.browse:GetText() == "A longer translated Resume label", "labels never abbreviated")
    check(footer.browse:GetScript("OnClick") == clicked and footer.preflight.disabled and
        footer.preflight:GetFontString().color == semanticColor, "skin preserves callbacks, disabled state and semantic colours")
    profile.guideFontSize = 9; footer.browse:SetText("Browse"); rootFrame:SetWidth(340)
    CheckFooter()
    rootFrame.ScrollFrame = object()
    local bar = object(); rootFrame.ScrollFrame.ScrollBar = bar
    bar.ScrollUpButton, bar.ScrollDownButton = object(), object()
    bar:SetValue(17); bar.ScrollUpButton:SetScript("OnClick", clicked)
    view:SkinScrollBar()
    bar.ScrollUpButton:Disable()
    check(bar.ScrollUpButton.rxpGlyph:GetAlpha() == 0.35 and bar:GetValue() == 17 and
        bar.ScrollUpButton:GetScript("OnClick") == clicked, "scrollbar skin preserves value/clicks and marks disabled arrows")
    bar.ScrollUpButton:Enable(); check(bar.ScrollUpButton.rxpGlyph:GetAlpha() == 1, "enabled arrow feedback")
    local custom = {0.6, 0.2, 0.1}
    profile.activeTheme = "Custom"; addon.activeTheme = {textColor = custom}
    view:SkinScrollBar()
    check(bar.ScrollUpButton.rxpGlyph.color[1] == custom[1], "custom accent retained")
    -- Mutating Custom in place must not reuse an identity-only skin cache.
    addon.LoadActiveTheme = function() end
    local independent = {}
    addon.enabledFrames = {}
    for _, key in ipairs({"activeItemFrame", "activeTargetFrame", "arrowFrame"}) do
        local frame = object()
        frame.title, frame.texture = object(), object(); frame.title.text = object()
        frame.UpdateFrame = function() error("theme refresh evaluated independent window content") end
        addon.enabledFrames[key], independent[key] = frame, frame
    end
    local function Extract(path, first, last)
        local file = assert(io.open(root .. "/" .. path)); local text = file:read("*a"); file:close()
        local a = assert(text:find(first, 1, true)); local b = assert(text:find(last, a, true))
        return text:sub(a, b - 1)
    end
    rootFrame.backdrop = {edge = {}, bottom = {}}
    addon.activeTheme.background = {0.1, 0.2, 0.3}
    independent.activeItemFrame.UpdateVisuals = setfenv(assert(loadstring(
        Extract("UI/ActiveItemFrame.lua", "local function UpdateIconFrameVisuals", "function addon.CreateActiveItemFrame") ..
        "\nreturn UpdateIconFrameVisuals")), env)()
    addon.targeting = {activeTargetFrame = independent.activeTargetFrame}
    setfenv(assert(loadstring(Extract("Features/Targeting.lua", "function addon.targeting:RenderTargetFrameBackground()",
        "local fOnEnter ="))), env)()
    independent.activeTargetFrame.UpdateVisuals = setfenv(assert(loadstring(
        Extract("Features/Targeting.lua", "local function UpdateIconFrameVisuals", "function addon.targeting:CreateTargetFrame()") ..
        "\nreturn UpdateIconFrameVisuals")), env)()
    addon.arrowFrame = independent.arrowFrame
    local arrowWrites = 0
    independent.arrowFrame.texture.SetTexture = function(_, path)
        check(path == "Textures/rxp_navigation_arrow-1", "arrow uses the active project's visual path")
        arrowWrites = arrowWrites + 1
    end
    setfenv(assert(loadstring(Extract("UI/Map.lua", "function addon.arrowFrame:UpdateVisuals()", "local function IsInInstance()"))), env)()
    for _, value in ipairs({0.3, 0.9}) do
        custom[1] = value
        view:RefreshAppearance(); view:RefreshAppearance(); queued.paint()
        check(bar.ScrollUpButton.rxpGlyph.color[1] == value, "same-table custom edits invalidate accents")
        check(independent.activeItemFrame.title.text.color[1] == value and
            independent.activeTargetFrame.title.text.color[1] == value, "live theme updates independent item/target visuals")
    end
    check(arrowWrites == 2, "theme-specific independent hooks coalesce and run once per paint")
    -- Run the real row-recycling backdrop block, then the production skin.
    local pooled = object(); view:Skin(pooled, true)
    env.frame = pooled
    local reset = Extract("UI/GuideWindow.lua", "        frame:ClearBackdrop()\n        frame.rxpModernBackdrop = nil", '        frame:SetScript("OnEnter"')
    setfenv(assert(loadstring(reset)), env)()
    view:Skin(pooled, true)
    check(pooled.backdrop == view.backdrop, "recycled rows cannot retain Legacy borders")
    profile.activeTheme = "Default"; addon.activeTheme = nil
    view.appliedStyle = "legacy"
    local legacyControl = object(); legacyControl:SetNormalTexture("original")
    view:SkinControl(legacyControl, "v")
    check(legacyControl:GetNormalTexture().texturePath == "original" and not view:LayoutFooter() and
        view:GetHeight() == profile.frameHeight and view:GetScale() == profile.windowScale,
        "Legacy style, saved height and scale untouched")
    view.appliedStyle = "modern"
    local card = object(); card.step = {}; card.elements = {{EnableMouse = function(self, v) self.mouse = v end, button = object()}}
    rootFrame.CurrentStepFrame.framePool[1] = card
    view:GetHUD().collapsed = true; addon.RefreshGuidePresentation()
    check(card:IsShown() and rootFrame:IsShown() and card.alpha == 0 and not card.elements[1].mouse and not card.elements[1].button.mouse,
        "collapse leaves execution hosts shown and disables invisible input")
    check(not rootFrame.BottomFrame:IsShown(), "collapsed list hidden")
    check(footer:GetAlpha() == 0 and footer.text:GetAlpha() == 0 and not footer.browse:IsMouseEnabled() and
        not footer.cog:IsMouseEnabled() and not footer.xpStatus:IsMouseEnabled(), "collapsed footer has no visible or clickable controls")
    footer.speedrun = nil
    footer.speedrunAdvisors = object(); footer.speedrunAdvisors:SetText("ADV 2")
    view:LayoutFooter()
    check(footer.speedrunAdvisors:GetAlpha() == 0 and not footer.speedrunAdvisors:IsMouseEnabled(), "late badge stays concealed")
    view:GetHUD().collapsed = false; addon.currentGuide.hidewindow = true
    addon.RefreshGuidePresentation()
    check(rootFrame:GetHeight() == 28 and rootFrame.minHeight == 28 and
        footer:GetAlpha() == 0 and not footer.cog:IsMouseEnabled(), "authored compact window keeps footer concealed")
    addon.currentGuide.hidewindow = nil
    view:GetHUD().collapsed = true
    -- Exercise the actual formatting branches too, not only the coordinator.
    load("UI/GuideLayout.lua")
    local step = {index = 4, level = 1, elements = {}}
    local element = {tag = "complete", text = "Kill boars 0/10", step = step, keepUpdating = true}
    step.elements[1] = element
    card.step, card.number = step, object()
    card.number.text = object()
    local elementFrame = object()
    elementFrame.text, elementFrame.icon, elementFrame.button = object(), object(), object()
    card.elements = {elementFrame}
    env.activeSteps, env.GuideName = {step}, rootFrame.GuideName
    env.ScrollChild = object(); env.ScrollChild.framePool = {}; env.ScrollChild.f1 = object()
    env.ApplyStepVisualState, env.ApplyElementVisualState = function() end, function() end
    env.GetStepVisualState = function() return "current" end
    env.IsFrameShown = function() return true end
    env.L, env.fmt = addon.locale.Get, string.format
    env.stepPos = {[0] = 20}
    addon.icons, addon.functions, addon.stepUpdateList = {}, {}, {}
    addon.locale.GuideText = function(text) return text end
    addon.ReplaceNpcIds = function(text) return text end
    addon.guideLocalization = {RenderRow = function(_, text) return text end}
    addon.BetaVersionCheck = function() error("cosmetic pass ran version/gameplay work") end
    addon.currentGuide.steps[4] = step
    rootFrame.BottomFrame.hiddenFrames = 0
    local textStart = assert(source:find("function CurrentStepFrame.UpdateText(languageRefresh)", 1, true))
    local textEnd = assert(source:find('\nBottomFrame:SetPoint("TOPLEFT"', textStart, true))
    setfenv(assert(loadstring(source:sub(textStart, textEnd - 1))), env)()
    view:GetHUD().collapsed = false
    rootFrame.CurrentStepFrame.UpdateText(true)
    check(not element.completed and elementFrame.text:GetText() == "Kill boars 0/10" and elementFrame.mouse,
        "uncollapse restores input without completion")
    check(footer.browse:IsMouseEnabled() and footer.xpStatus:IsMouseEnabled() and footer:GetAlpha() == 1,
        "uncollapse restores footer input and alpha")
    check(card.number.text:GetText() == "Current objective: Step 4", "current objective has a presentation-only label")
    step.sticky = true; rootFrame.CurrentStepFrame.UpdateText(true)
    check(card.number.text:GetText() == "Ongoing: Step 4" and not step.title, "sticky labels do not rewrite authored titles")
    step.sticky = nil
    local row = object(); row.step = step; row.text = object(); row.number = object(); row.number.text = object()
    row.number:SetSize(18, 12)
    env.ScrollChild.framePool[4] = row
    local rowStart = assert(source:find("function BottomFrame.UpdateFrame(self, stepn, languageRefresh)", 1, true))
    local rowEnd = assert(source:find("\n-- addon.hiddenFrames", rowStart, true))
    setfenv(assert(loadstring(source:sub(rowStart, rowEnd - 1))), env)()
    addon.updateBottomFrame = true
    rootFrame.BottomFrame.UpdateFrame(row, nil, true)
    check(not element.completed and addon.updateBottomFrame == true and row.text:GetText():find("0/10", 1, true),
        "targeted real row refresh preserves pending correctness work")
    -- Full cosmetic pass must also skip directive dispatch, even for an
    -- uncached objective which ordinarily asks the server again.
    step.index = 1; addon.currentGuide.steps = {step}; env.ScrollChild.framePool = {row}
    element.requestFromServer = true
    rootFrame.BottomFrame.UpdateFrame(nil, nil, true)
    check(element.requestFromServer and not element.completed and addon.updateBottomFrame == true,
        "full real row refresh cannot evaluate directives or clear queued updates")
    local counters = {}
    addon.PerfCount = function(name, amount) counters[name] = (counters[name] or 0) + (amount or 1) end
    local steps, rows = {step}, {row}
    for i = 2, 3 do
        local s = {index = i, level = 1, elements = {}}
        s.elements[1] = {tag = "complete", text = "Objective " .. i, step = s, requestFromServer = true}
        local r = object(); r.step, r.text, r.number = s, object(), object()
        r.number.text = object(); r.number:SetSize(18, 12)
        steps[i], rows[i] = s, r
    end
    function row.text:GetStringHeight() return self:GetText():find("wrapped", 1, true) and 48 or 16 end
    addon.currentGuide.steps, env.ScrollChild.framePool = steps, rows
    rootFrame.BottomFrame.UpdateFrame(nil, nil, true)
    local initialTotal = env.stepPos[0]
    counters = {}
    for _ = 1, 100 do rootFrame.BottomFrame.UpdateFrame(row, nil, true) end
    check(not counters["row positions shifted"] and not counters["row measurements"] and
        counters["row measurement hits"] == 100, "unchanged targeted rows do not remeasure or walk/shift positions")
    element.text = "wrapped objective with more lines"
    rootFrame.BottomFrame.UpdateFrame(row, nil, true)
    check(env.stepPos[0] == initialTotal + 32 and counters["row positions shifted"] == 2,
        "height changes shift only following anchors")
    local targetOffsets = {env.stepPos[0], env.stepPos[1], env.stepPos[2], env.stepPos[3]}
    rootFrame.BottomFrame.UpdateFrame(nil, nil, true)
    check(env.stepPos[0] == targetOffsets[1] and env.stepPos[1] == targetOffsets[2] and
        env.stepPos[2] == targetOffsets[3] and env.stepPos[3] == targetOffsets[4], "full and targeted offsets agree")
    steps[2].level = 100
    rootFrame.BottomFrame.UpdateFrame(rows[2], nil, true)
    check(rows[2].rxpRowHeight == 0 and not rows[2]:IsMouseEnabled() and env.stepPos[2] == env.stepPos[3],
        "hidden rows consume no space or input")
    steps[2].level = 1; rootFrame.BottomFrame.UpdateFrame(rows[2], nil, true)
    check(rows[2]:IsMouseEnabled() and env.stepPos[3] > env.stepPos[2], "visible row restores geometry and input")
    env.ScrollFrame = rootFrame.ScrollFrame; env.ScrollFrame:SetHeight(20)
    local scrollStart = assert(source:find("local function GetStepScrollValue(n)", 1, true))
    local scrollEnd = assert(source:find("\nfunction BottomFrame:CancelScrollFollow", scrollStart, true))
    local getScroll = setfenv(assert(loadstring(source:sub(scrollStart, scrollEnd - 1) .. "\nreturn GetStepScrollValue")), env)()
    check(getScroll(1) == 0 and getScroll(2) == env.stepPos[2], "scroll navigation uses real row starts")
    local rangeStart = assert(source:find("local updatingScrollRange", 1, true))
    local rangeEnd = assert(source:find('\nhooksecurefunc(ScrollFrame.ScrollBar, "SetValue"', rangeStart, true))
    setfenv(assert(loadstring(source:sub(rangeStart, rangeEnd - 1))), env)()
    function bar:GetMinMaxValues() return self.minimum, self.maximum end
    function bar:SetMinMaxValues(low, high) self.minimum, self.maximum = low, high end
    env.refreshScrollRange(bar, 0)
    check(bar.minimum == 0 and bar.maximum == env.stepPos[0] - 20, "scroll limits match the actual viewport")
    profile.hideCompletedSteps = true; env.RXPCData.currentStep = 3
    env.refreshScrollRange(bar, bar.maximum)
    check(bar.minimum == math.min(env.stepPos[3], bar.maximum) and bar.ScrollDownButton.disabled,
        "completed-step scroll floor and endpoint controls remain valid")
    profile.hideCompletedSteps = false; env.RXPCData.currentStep = 1
    -- Anchor preference is the actual production function, with a mock screen
    -- that has sufficient space on both sides (no edge fallback required).
    local anchorStart = assert(source:find("local function SetStepFrameAnchor()", 1, true))
    local anchorEnd = assert(source:find("\nRXPFrame.SetStepFrameAnchor =", anchorStart, true))
    local setAnchor = setfenv(assert(loadstring(source:sub(anchorStart, anchorEnd - 1) .. "\nreturn SetStepFrameAnchor")), env)()
    addon.SortTimers = function() end
    profile.anchorOrientation = "top"; setAnchor(); check(rootFrame.CurrentStepFrame.anchor == "TOP", "top anchor retained")
    profile.anchorOrientation = "bottom"; setAnchor(); check(rootFrame.CurrentStepFrame.anchor == "BOTTOM", "bottom anchor retained")
    -- A card reused by the pool for a floating tip restores its original title
    -- anchors instead of inheriting the Modern objective header.
    rootFrame.backdrop = {edge = {}}
    step.tip = true; rootFrame.CurrentStepFrame.UpdateText(true)
    check(not card.rxpModernTitle and card.number.points[1][3] == 7, "floating tip title remains independent")
    step.tip = nil

    -- Native FontString-style constraint fixture: wrapping depends on width,
    -- and an extra vertical anchor/explicit height clips the measured result.
    local function Wrapping(region)
        function region:SetWordWrap(value) self.wordWrap = value end
        function region:GetStringHeight()
            local text = self:GetText():gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
                :gsub("|T.-|t", "XX")
            local size = self.fontSize or 12
            local columns = math.max(1, math.floor(self:GetWidth() / (size * 0.55)))
            local lines = 0
            for line in (text .. "\n"):gmatch("(.-)\n") do
                lines = lines + math.max(1, math.ceil(#line / columns))
            end
            local height = lines * (size + 2)
            if not self.wordWrap or #self.points ~= 1 then return size + 2 end
            return self.height > 0 and math.min(self.height, height) or height
        end
    end
    local sentence = "Kill Mottled Boars. Loot them until you have 10 copper worth of vendor items (including your armor)."
    env.refreshScrollRange = nil -- geometry cases isolate the native range fixture below
    for _, style in ipairs({"modern", "legacy"}) do
        view.appliedStyle = style
        local s = {index = 1, level = 1, elements = {}}
        s.elements[1] = {step = s, tag = "complete", text = sentence, requestFromServer = true}
        local r = object(); r.step, r.text, r.number = s, object(), object()
        r.number.text = object(); r.number:SetSize(24, 12)
        Wrapping(r.text)
        addon.currentGuide = {steps = {s}}
        env.ScrollChild.framePool = {r}; env.ScrollChild.f1:SetHeight(1000)
        rootFrame.BottomFrame.hiddenFrames = 0
        local narrow
        for _, width in ipairs({220, 620, 220}) do
            rootFrame:SetWidth(width + 35); r:SetWidth(width)
            rootFrame.BottomFrame.UpdateFrame(nil, nil, true)
            check(r.text:GetNumPoints() == 1 and r.text:GetHeight() == 0 and r.text.wordWrap,
                style .. " list has unconstrained wrapping height")
            check(r.text:GetText():find("including your armor", 1, true), style .. " full source retained")
            local height, total = r:GetHeight(), env.stepPos[0]
            rootFrame.BottomFrame.UpdateFrame(r, nil, true)
            check(r:GetHeight() == height and env.stepPos[0] == total, style .. " full/targeted wrapping agrees")
            if width == 220 then
                check(not narrow or narrow == height, style .. " narrow geometry restores exactly")
                narrow = height
            else check(height < narrow, style .. " wider row unwraps") end
        end
        counters = {}
        for _ = 1, 30 do rootFrame.BottomFrame.UpdateFrame(r, nil, true) end
        check(counters["row measurement hits"] == 30 and not counters["row positions shifted"],
            style .. " unchanged wrapped rows reuse measurements")
        r.text:SetFont("font", 24)
        rootFrame.BottomFrame.UpdateFrame(r, nil, true)
        check(r:GetHeight() > narrow, style .. " larger font remeasures")
        r.text:SetText("|Ticon:12|t " .. string.rep("Translated instruction ", 10))
        check(r.text:GetStringHeight() > 24, style .. " long translated/icon text wraps")
        card.step = s; card:SetWidth(220); card.number:SetSize(200, 17)
        env.activeSteps = {s}; elementFrame.button:SetSize(12, 12)
        Wrapping(elementFrame.text); Wrapping(card.number.text)
        rootFrame.CurrentStepFrame.UpdateText(true)
        check(elementFrame.text:GetNumPoints() == 1 and elementFrame.text:GetHeight() == 0 and
            elementFrame.text:GetStringHeight() > 16, style .. " active objective wraps without hiding checkbox")
        check(not s.elements[1].completed and s.elements[1].requestFromServer,
            style .. " wrapping cannot evaluate an objective")
    end

    -- Use production scheduler replacement/cancellation, not an imitation of
    -- its semantics. Deliberately invoke cancelled native timers as well.
    local timers = {}
    addon.timer = {NewTimer = function(_, callback)
        local timer = {callback = callback, Cancel = function(self) self.cancelled = true end}
        timers[#timers + 1] = timer; return timer
    end}
    addon.services = {Register = function() end}
    load("Core/Scheduler.lua")
    local followStart = assert(source:find("local scrollRequest = 0", 1, true))
    local followEnd = assert(source:find('\nRXPFrame:SetWidth(addon.width)', followStart, true))
    local manualStart = assert(source:find("local function CancelManualScroll()", 1, true))
    local manualEnd = assert(source:find("\nfunction addon.GetGuideName", manualStart, true))
    local nativeMouseDown = 0
    for _, control in ipairs({bar, bar.ScrollUpButton, bar.ScrollDownButton}) do
        control:SetScript("OnMouseDown", function() nativeMouseDown = nativeMouseDown + 1 end)
    end
    -- SetBrowseMode shares the production follow locals, so load it alongside
    -- the follow block for this combined closure fixture.
    local browseStart = assert(source:find("function addon.SetBrowseMode(enabled, silent)", 1, true))
    local browseEnd = assert(source:find("\nfunction addon.ToggleBrowseMode", browseStart, true))
    setfenv(assert(loadstring(source:sub(followStart, followEnd - 1) .. "\n" ..
        source:sub(manualStart, manualEnd - 1) .. "\n" ..
        source:sub(browseStart, browseEnd - 1))), env)()
    addon.UpdateBrowseModeButton = function() end
    for _, style in ipairs({"modern", "legacy"}) do
        view.appliedStyle = style
        addon.currentGuide = {steps = {{index = 1}, {index = 2}, {index = 3}}}
        local guide = addon.currentGuide
        env.stepPos = {[0] = 600, 0, 100, 200}
        env.ScrollChild.f1:SetHeight(600); rootFrame.BottomFrame:SetHeight(20)
        local bottom = rootFrame.BottomFrame
        bottom:CancelScrollFollow(true)
        env.RXPCData.currentStep = 2; bottom:StepScroll(2)
        local old = timers[#timers]
        env.RXPCData.currentStep = 3; bottom:StepScroll(3)
        local latest, value = timers[#timers], bar:GetValue()
        old.callback(); check(bar:GetValue() == value, style .. " superseded request cannot jump backwards")
        env.stepPos[3] = 210 -- deferred layout changed the destination's offset
        value = style == "modern" and 210 or 208
        latest.callback(); check(bar:GetValue() == value, style .. " latest request wins")
        local count = #timers
        bar:SetValue(17); bottom:StepScroll(3)
        check(bar:GetValue() == 17 and #timers == count, style .. " same-step evaluation preserves reading position")
        for _, control in ipairs({bar, bar.ScrollUpButton, bar.ScrollDownButton}) do
            bottom:StepScroll(3, false, true); local pending = timers[#timers]
            control.scripts.OnMouseDown(control); bar:SetValue(18); pending.callback()
            check(bar:GetValue() == 18, style .. " thumb/arrow input cancels follow")
        end
        bottom:StepScroll(3, false, true); local pending = timers[#timers]
        bottom:ScrollBySteps(1); bar:SetValue(19); pending.callback()
        check(bar:GetValue() == 19, style .. " wheel input cancels even without eligible rows")
        addon.browseMode = true; addon.SetBrowseMode(false, true)
        check(bar:GetValue() == value, style .. " Resume follows the engine target")
        pending = timers[#timers]; addon.currentGuide = {steps = guide.steps}
        bar:SetValue(23); pending.callback()
        check(bar:GetValue() == 23, style .. " old-guide callback cannot affect replacement guide")
        bottom:StepScroll(3); check(bar:GetValue() == value, style .. " initial replacement guide follows")
        pending = timers[#timers]; local beforeRetry = #timers; pending.callback()
        check(#timers == beforeRetry, style .. " retries are bounded, not self-rescheduling")
    end
    check(nativeMouseDown == 6, "scroll cancellation preserves native input handlers exactly once")
    assert(loadfile(root .. "/tests/library-tabs.lua"))()(root, object)
    print("Modern UI passed: library, settings, pure HUD refresh, shared wrapping and scoped scroll following")
end
