-- Real settings registration and the bundled AceConfig/AceGUI renderer. Only
-- the client frame/API boundary is mocked; no option tree is copied here.
return function(root, baseObject, style)
    style = style or "modern"
    local env = setmetatable({}, {__index = function(_, key)
        if _G[key] ~= nil then return _G[key] end
        if key:match("^[A-Z][A-Z_0-9]+$") then return key end
    end})
    env._G = env
    local queue, errors, frames = {}, {}, {}
    local function object(name, parent)
        local f = baseObject(name)
        f.parent, f.children = parent, {}
        f.actualWidth, f.actualHeight = f.width, f.height
        function f:GetWidth() return self.actualWidth end
        function f:GetHeight() return self.actualHeight end
        function f:SetWidth(value) self.actualWidth = value end
        function f:SetHeight(value) self.actualHeight = value end
        function f:SetSize(width, height) self:SetWidth(width); self:SetHeight(height) end
        if parent then parent.children[#parent.children + 1] = f end
        function f:GetChildren() return unpack(self.children) end
        function f:GetObjectType() return self.kind or "Frame" end
        function f:GetTexture() return self.texture end
        function f:SetTexture(texture) self.texture = texture end
        function f:SetVertexColor(...) self.vertexColor = {...} end
        function f:GetEffectiveScale() return 1 end
        function f:GetLeft() return 0 end
        function f:GetRight() return self:GetWidth() end
        function f:GetCenter() return 400, 300 end
        function f:GetNumLetters() return #self:GetText() end
        function f:GetTextInsets() return 0, 0, 0, 0 end
        function f:GetFontObject() return env.GameFontNormal end
        function f:GetTextWidth() return self:GetStringWidth() end
        function f:SetFrameLevel(level) self.level = level end
        function f:SetFrameStrata(strata) self.strata = strata end
        function f:GetVerticalScroll() return self.scroll or 0 end
        function f:SetVerticalScroll(n) self.scroll = n end
        function f:GetVerticalScrollRange() return 0 end
        function f:GetMinMaxValues() return self.low or 0, self.high or 100 end
        function f:SetMinMaxValues(low, high) self.low, self.high = low, high end
        function f:IsMouseOver() return false end
        function f:HasFocus() return self.focus end
        function f:SetFocus() self.focus = true; if self.scripts.OnEditFocusGained then self.scripts.OnEditFocusGained(self) end end
        function f:ClearFocus() self.focus = nil; if self.scripts.OnEditFocusLost then self.scripts.OnEditFocusLost(self) end end
        function f:HighlightText() end
        function f:SetMaxBytes(value) self.maxBytes = value end
        function f:EnableKeyboard() end
        function f:LockHighlight() end
        function f:UnlockHighlight() end
        function f:ClearAllPoints() self.points = {} end
        function f:CreateTexture() local r = object(); r.parent = self; return r end
        function f:CreateFontString() local r = object(); r.parent = self; return r end
        function f:GetHighlightFontObject() return env.GameFontNormal end
        function f:SetAllPoints(other) other = other or self.parent; self:SetSize(other:GetWidth(), other:GetHeight()) end
        local setText = f.SetText
        function f:SetText(text)
            setText(self, text)
            if self.scripts.OnTextSet then self.scripts.OnTextSet(self) end
        end
        if name then env[name] = f end
        frames[#frames + 1] = f
        return f
    end
    env.CreateFrame = function(kind, name, parent, template)
        local f = object(name, parent); f.kind = kind; if kind == "Slider" then f.value = 0 end
        -- Legacy EditBoxes are not Buttons: the client has no Enable,
        -- Disable or IsEnabled methods on them. Do not mask API mistakes.
        if kind == "EditBox" then f.Enable, f.Disable, f.IsEnabled = nil, nil, nil end
        if template == "UIPanelScrollFrameTemplate" and name then
            f.ScrollBar = object(name .. "ScrollBar", f)
            object(name .. "ScrollBarScrollUpButton", f.ScrollBar)
            object(name .. "ScrollBarScrollDownButton", f.ScrollBar)
        end
        if template == "OptionsFrameTabButtonTemplate" then
            object(name .. "Text"); object(name .. "HighlightTexture")
        end
        if template == "OptionsListButtonTemplate" then
            f.toggle = object(name .. "Toggle", f); f.highlight = object(name .. "Highlight", f)
            f.text = object(name .. "Text", f)
        end
        if template == "UIDropDownMenuTemplate" then
            for _, suffix in ipairs({"Left", "Middle", "Right", "Text", "Button"}) do object(name .. suffix, f) end
        end
        return f
    end
    env.UIParent = object("UIParent")
    for _, name in ipairs({"GameFontNormal", "GameFontNormalSmall", "GameFontHighlight", "GameFontHighlightSmall",
        "GameFontHighlightLarge", "GameFontDisable", "GameFontDisableSmall", "GameFontNormalLarge", "ChatFontNormal"}) do env[name] = object(name) end
    env.GameTooltip = object("GameTooltip")
    env.geterrorhandler = function() return function(err) errors[#errors + 1] = err end end
    env.loadstring = function(code, name) local chunk, err = loadstring(code, name); if chunk then setfenv(chunk, env) end; return chunk, err end
    env.wipe = function(t) for key in pairs(t) do t[key] = nil end; return t end
    env.CopyTable = function(t) local out = {}; for key, value in pairs(t) do out[key] = type(value) == "table" and env.CopyTable(value) or value end; return out end
    env.tinsert, env.tremove, env.sort, env.format, env.strsplit = table.insert, table.remove, table.sort, string.format,
        function(sep, text) local t = {}; for s in text:gmatch("[^" .. sep .. "]+") do t[#t + 1] = s end; return unpack(t) end
    env.strmatch, env.strlen, env.strsub, env.floor, env.ceil, env.max, env.min = string.match, string.len, string.sub, math.floor, math.ceil, math.max, math.min
    local oldSplit = string.split
    string.split = env.strsplit
    env.GetLocale = function() return "enUS" end
    env.GetCVar = function() return "enUS" end
    env.strlower = string.lower
    local now = 0
    env.GetTime = function() return now end
    env.GetBuildInfo = function() return "3.3.5", "12340", "2010", 30300 end
    env.UnitName = function() return "Fixture" end
    env.GetRealmName = function() return "Fixture" end
    env.UnitClass = function() return "Warrior", "WARRIOR" end
    env.UnitRace = function() return "Orc", "Orc" end
    env.UnitFactionGroup = function() return "Horde" end
    env.UnitLevel = function() return 1 end
    env.GetMaxPlayerLevel = function() return 80 end
    env.InCombatLockdown = function() return false end
    env.IsLoggedIn = function() return true end
    env.IsAddOnLoaded = function() return false end
    env.GetNumAddOns = function() return 0 end
    env.BNGetInfo = function() end
    env.GetScreenWidth, env.GetScreenHeight = function() return 1024 end, function() return 768 end
    env.PlaySound, env.InterfaceOptions_AddCategory = function() end, function() end
    env.SetDesaturation = function() end
    env.CloseSpecialWindows = function() end
    env.PanelTemplates_TabResize, env.PanelTemplates_SetDisabledTabState = function() end, function() end
    env.PanelTemplates_SelectTab, env.PanelTemplates_DeselectTab = function() end, function() end
    env.ChatEdit_InsertLink = function() end
    env.hooksecurefunc = function(target, key, callback)
        if type(target) == "string" then callback, key, target = key, target, env end
        local original = assert(target[key], key)
        target[key] = function(...) local result = original(...); callback(...); return result end
    end
    env.Enum = {ItemQuality = {Heirloom = 7}}
    env.NORMAL_FONT_COLOR = {r = 1, g = 0.82, b = 0}
    env.RAID_CLASS_COLORS = setmetatable({}, {__index = function() return {r = 0.8, g = 0.6, b = 0.4, colorStr = "ffc09060"} end})
    env.StaticPopupDialogs, env.UISpecialFrames = {}, {}
    local popup
    env.StaticPopup_Show = function(key) popup = key; return object() end
    env.RXPData = {cache = true, guideHub = {filters = {}, favorites = {}}}
    env.RXPCData = {currentStep = 7, guideProgress = {}, recentGuides = {},
        guideMetaData = {enabledDungeons = {Horde = {}}, professions = {}, skills = {}, enableGroupQuests = {}}}
    env.FauxScrollFrame_GetOffset = function(f) return f.offset or 0 end
    env.FauxScrollFrame_SetOffset = function(f, n) f.offset = n end
    env.FauxScrollFrame_Update = function(frame, total, visible, height)
        frame.scrollMetrics = {total, visible, height}
    end
    env.FauxScrollFrame_OnVerticalScroll = function(frame, pixels, height, refresh)
        frame.offset = math.floor(pixels / height); refresh()
    end
    local addon = {title = "RestedXP Guides", versionText = "fixture", gameVersion = 30300,
        locale = {Get = function(s) return s end}, player = {class = "WARRIOR", race = "Orc", faction = "Horde"},
        font = "font", help = {}, compatibility = {}, colors = {}, enabledFrames = {},
        comms = {SendPing = function() end, OpenBugReport = function() end},
        targeting = {CanCreateMacro = function() return true end},
        classColor = {r = 0.8, g = 0.6, b = 0.4},
        scheduler = {After = function(_, _, key, _, fn) queue[key] = fn end},
        timer = {After = function(_, fn) queue.timer = fn end},
        db = {profile = {guides = {}}}, guideList = {}, guides = {}, settings = {}, RXPFrame = object(),
        GetTexture = function(s) return "Textures/" .. s end,
        GetOrphanedQuests = function() return {} end,
        SetFontSafely = function(f, path, size) f:SetFont(path, size) end,
        IsQuestRewardSettlementActive = function() return false end}
    function addon:NewModule() return self.settings end
    addon.RXPFrame.BottomFrame = object()
    local function load(path)
        local chunk = assert(loadfile(root .. "/" .. path)); setfenv(chunk, env)("RXPGuides", addon)
    end
    load("libs/LibStub/LibStub.lua")
    load("libs/Legacy335/CallbackHandler-1.0/CallbackHandler-1.0.lua")
    load("libs/Legacy335/AceGUI-3.0/AceGUI-3.0.lua")
    local xml = assert(io.open(root .. "/libs/Legacy335/AceGUI-3.0/AceGUI-3.0.xml")); local body = xml:read("*a"); xml:close()
    for path in body:gmatch('<Script file="([^"]+)"') do
        if path ~= "AceGUI-3.0.lua" then load("libs/Legacy335/AceGUI-3.0/" .. path:gsub("\\", "/")) end
    end
    load("libs/Legacy335/AceConfig-3.0/AceConfigRegistry-3.0/AceConfigRegistry-3.0.lua")
    load("libs/Legacy335/AceConfig-3.0/AceConfigDialog-3.0/AceConfigDialog-3.0.lua")
    load("libs/Legacy335/AceDB-3.0/AceDB-3.0.lua")
    load("libs/Legacy335/AceDBOptions-3.0/AceDBOptions-3.0.lua")
    -- AceConfig's command-line and broker collaborators are not used by the
    -- renderer. Registration still goes through the real registry validator.
    local config = env.LibStub:NewLibrary("AceConfig-3.0", 1)
    function config:RegisterOptionsTable(...) return env.LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(...) end
    for _, name in ipairs({"LibDBIcon-1.0", "LibDataBroker-1.1"}) do env.LibStub:NewLibrary(name, 1) end
    load("UI/Themes.lua")
    load("UI/Settings.lua")
    addon.settings:InitializeDatabase()
    addon.settings.profile.uiStyle = style
    load("UI/Presentation.lua"); addon.presentation:Initialize()
    load("UI/ToolWindow.lua"); load("UI/SettingsAdapter.lua"); load("UI/FeatureTools.lua")
    -- Startup must not depend on the separately added manifest entry. Run the
    -- real renderer in both styles with that entry absent, then load the inert
    -- compatibility entry late and require it to preserve the running session.
    load("UI/GuideHub.lua"); load("UI/ModernLibrary.lua")
    assert(type(addon.libraryTabs) == "table", "hub must initialize its tab controller")
    addon.settings:CreateAceOptionsPanel()
    addon.settings:CreateImportOptionsPanel()
    local forbidden = function() error("presentation invoked gameplay/progression") end
    addon.LoadGuide, addon.ReloadGuide, addon.GoToStep, addon.SetStep, addon.UpdateMap = forbidden, forbidden, forbidden, forbidden, forbidden
    local before = {}
    for key, value in pairs(addon.settings.profile) do if type(value) ~= "table" then before[key] = value end end
    addon.guideHub:Setup()
    addon.libraryTabs:Open("Settings")
    local controller, pages = addon.libraryTabs, addon.libraryTabs.pages
    load("UI/LibraryTabs.lua")
    assert(addon.libraryTabs == controller and controller.pages == pages and
        controller.selected == "Settings", "compatibility chunk cannot replace a running controller")
    assert(#errors == 0, table.concat(errors, "\n"))
    local function find(widget, key)
        local path = widget.GetUserData and widget:GetUserData("path")
        if path and path[#path] == key then return widget end
        for _, child in ipairs(widget.children or {}) do local found = find(child, key); if found then return found end end
    end
    local function clean(label)
        assert(#errors == 0, label .. ":\n" .. table.concat(errors, "\n"))
    end
    local function groups(option, path)
        for key, child in pairs(option.args or {}) do
            if child.type == "group" and not child.inline then
                local nextPath = {}; for i, value in ipairs(path) do nextPath[i] = value end; nextPath[#nextPath + 1] = key
                addon.libraryTabs:Open("Settings", nextPath)
                clean(table.concat(nextPath, "/"))
                groups(child, nextPath)
            end
        end
    end
    groups(addon.settings.optionTree, {})
    addon.libraryTabs:Open("Import")
    clean("Import")
    local import = assert(find(addon.libraryTabs.pages.Import.widget, "importBox"))
    assert(import.editBox.rxpImportHooked, "registered Import owns its paste hook")
    addon.libraryTabs.pages.Import.dirty = true
    addon.libraryTabs:RefreshVisible()
    clean("Import rerender with legacy EditBox APIs")
    import = assert(find(addon.libraryTabs.pages.Import.widget, "importBox"))
    addon.libraryTabs:Open("Guides")
    addon.libraryTabs:Open("Feature Tools", "routePreflight")
    clean("Feature Tools")
    addon.libraryTabs:Open("Import")
    assert(find(addon.libraryTabs.pages.Import.widget, "importBox") == import, "tab switch retains import widgets")
    assert(env.RXPCData.currentStep == 7, "tabs never change guide progress")
    for key, value in pairs(before) do assert(addon.settings.profile[key] == value, "initialization changed " .. key) end
    -- Registered callbacks are exercised through the native rendered widget.
    -- Discover the actual category containing the control instead of relying
    -- on translated captions or an assumed profile key.
    local function pathTo(option, wanted, path)
        for key, child in pairs(option.args or {}) do
            if key == wanted then return path end
            if child.type == "group" then
                local nextPath = env.CopyTable(path); nextPath[#nextPath + 1] = key
                local found = pathTo(child, wanted, nextPath); if found then return found end
            end
        end
    end
    addon.libraryTabs:Open("Settings", assert(pathTo(addon.settings.optionTree, "enableQuestAutomation", {})))
    clean("Automation deep link")
    local qa = assert(find(addon.libraryTabs.pages.Settings.widget, "enableQuestAutomation"))
    local conflicts = 0
    addon.CheckQuestieAutomationConflict = function() conflicts = conflicts + 1 end
    addon.questAutomation = {ResetTransient = function() conflicts = conflicts + 1 end}
    qa:Fire("OnValueChanged", false)
    assert(addon.settings.profile.enableQuestAutomation == false and conflicts == 1, "native setter executes once")
    clean("Native setter")
    addon.settings.profile.enableQuestAutomation = true
    addon.presentation:SettingsChanged()
    assert(queue.settings); queue.settings(); queue.settings = nil
    qa = assert(find(addon.libraryTabs.pages.Settings.widget, "enableQuestAutomation"))
    assert(qa.checked and conflicts == 1, "external changes refresh without setters")
    local dialog = env.LibStub("AceConfigDialog-3.0")
    dialog:Open(addon.title, addon.RXPOptions.obj)
    addon.RXPOptions.obj.frame:Show()
    local fallbackQA = assert(find(addon.RXPOptions.obj, "enableQuestAutomation"))
    fallbackQA:Fire("OnValueChanged", false)
    assert(conflicts == 2 and queue.settings, "fallback changes schedule the visible hub refresh")
    local refresh = queue.settings; queue.settings = nil; refresh()
    qa = assert(find(addon.libraryTabs.pages.Settings.widget, "enableQuestAutomation"))
    assert(not qa.checked and conflicts == 2, "native fallback and hub agree without replaying setters")
    qa:Fire("OnValueChanged", true)
    assert(conflicts == 3 and queue["fallback-Settings"])
    refresh = queue["fallback-Settings"]; queue["fallback-Settings"] = nil; refresh()
    assert(find(addon.RXPOptions.obj, "enableQuestAutomation").checked and conflicts == 3,
        "hub callback refreshes the visible original panel once")
    clean("Bidirectional native refresh")
    addon.libraryTabs:Open("Import")
    import = assert(find(addon.libraryTabs.pages.Import.widget, "importBox"))
    import.editBox:SetFocus()
    now = 1
    for char in ("invalid fixture"):gmatch(".") do
        import.editBox.scripts.OnChar(import.editBox, char)
    end
    assert(import.editBox.maxBytes == 1 and import.editBox:HasFocus(),
        "paste retains input focus and caps displayed bytes until processing")
    import.editBox.scripts.OnUpdate(import.editBox)
    assert(import.editBox.maxBytes == 0 and not import.editBox:GetScript("OnUpdate"),
        "processing releases the display cap and temporary update script")
    local imports = 0
    addon.ImportString = function(text) imports = imports + 1; assert(text == "invalid fixture"); return nil, "Fixture rejection" end
    addon.comms.PrettyPrint = function() end
    import.button:GetScript("OnClick")(import.button)
    assert(imports == 1 and #addon.settings.gui.importStatusHistory > 0, "import validator and status remain live")
    assert(addon.libraryTabs.pages.Import.status:GetText() == "Fixture rejection", "native validation message remains visible")
    clean("Import validation")
    local purge = assert(find(addon.libraryTabs.pages.Import.widget, "purgeAll"))
    local purges = 0
    addon.CreateMetaDataTable = function() purges = purges + 1 end
    purge:Fire("OnClick")
    assert(popup == "ACECONFIGDIALOG30_CONFIRM_DIALOG" and purges == 0)
    env.StaticPopupDialogs[popup].OnCancel()
    assert(purges == 0, "cancelled native confirmation invokes no action")
    purge = assert(find(addon.libraryTabs.pages.Import.widget, "purgeAll"))
    purge:Fire("OnClick"); env.StaticPopupDialogs[popup].OnAccept()
    assert(purges == 1, "confirmed native action executes once")
    clean("Native confirmations")
    import = assert(find(addon.libraryTabs.pages.Import.widget, "importBox"))
    import.editBox:SetFocus(); now = 2
    import.editBox.scripts.OnChar(import.editBox, "pending buffer")
    dialog:Open(addon.RXPOptions.name .. "/Import", addon.settings.gui.import.obj)
    addon.settings.textboxHook(addon.settings.gui.import.obj)
    addon.settings.gui.import.obj:ReleaseChildren()
    assert(import.editBox:GetScript("OnUpdate") and import.editBox.maxBytes == 1,
        "releasing the other import pane cannot consume the active paste")
    addon.libraryTabs.pages.Import.widget:ReleaseChildren()
    assert(import.editBox.maxBytes == 0 and not import.editBox:GetScript("OnUpdate"), "release clears paste restrictions and queued work")
    local borrowed = env.LibStub("AceGUI-3.0"):Create("MultiLineEditBox")
    borrowed.editBox:SetText("unrelated editor")
    if borrowed.editBox:GetScript("OnEditFocusGained") then borrowed.editBox:GetScript("OnEditFocusGained")(borrowed.editBox) end
    if borrowed.editBox:GetScript("OnChar") then borrowed.editBox:GetScript("OnChar")(borrowed.editBox, "x") end
    assert(borrowed.editBox:GetText() == "unrelated editor" and not borrowed.editBox:GetScript("OnUpdate"), "pooled editors do not inherit active import hooks")
    env.LibStub("AceGUI-3.0"):Release(borrowed)
    addon.libraryTabs.pages.Import.dirty = true
    addon.libraryTabs:RefreshVisible()
    clean("Pooled import refresh")
    assert(not addon.libraryTabs.pages.Import.widget.frame.rxpToolLayerHook, "native pooled controls avoid persistent tool hooks")
    -- Tab switching must leave pooled draft controls and independent gameplay
    -- windows alone; Escape targets only the registered hub root.
    local persistent = object(); persistent:Show()
    addon.guideHub.window:Hide()
    assert(persistent:IsShown() and env.RXPCData.currentStep == 7)
    addon.settings.OpenSettings()
    assert(addon.libraryTabs.selected == "Settings" and addon.guideHub.window:IsShown())
    addon.settings.OpenFeatureToolSettings("routePreflight")
    assert(addon.libraryTabs.selected == "Feature Tools")
    addon.guideHub.window:Hide()
    local oldTrim = string.trim
    string.trim = function(s) return s:match("^%s*(.-)%s*$") end
    addon.settings.ChatCommand("")
    string.trim = oldTrim
    assert(addon.libraryTabs.selected == "Feature Tools" and addon.guideHub.window:IsShown(), "bare command restores session tab")
    addon.guideHub:Toggle()
    assert(addon.libraryTabs.selected == "Guides")

    -- Execute the installed production icon callbacks, not a duplicate click
    -- dispatcher. Opening the library must not toggle it shut or load a guide.
    local shift, menus, closed, toggled, dragged = false, 0, 0, 0, 0
    env.IsShiftKeyDown = function() return shift end
    env.CloseDropDownMenus = function() closed = closed + 1 end
    env.EasyMenu = function() menus = menus + 1 end
    local function source(path)
        local file = assert(io.open(root .. "/" .. path, "rb"))
        local text = file:read("*a"); file:close(); return (text:gsub("\r\n", "\n"))
    end
    local function install(text, first, last)
        local from = assert(text:find(first, 1, true))
        local to = assert(text:find(last, from, true))
        setfenv(assert(loadstring(text:sub(from, to - 1))), env)()
    end
    env.addon, env.RXPFrame = addon, addon.RXPFrame
    env.Footer, env.GuideName = {cog = object()}, object()
    addon.RXPFrame.DropDownMenu = function() menus = menus + 1 end
    addon.RXPFrame.OnMouseDown = function() dragged = dragged + 1 end
    local clicks
    env.Footer.cog.RegisterForClicks = function(_, ...) clicks = {...} end
    local hudSource = source("UI/GuideWindow.lua")
    install(hudSource, 'Footer.cog:RegisterForClicks(', '\nFooter.browse =')
    assert(clicks[1] == "LeftButtonUp" and clicks[2] == "RightButtonUp")
    install(hudSource, 'GuideName.OnMouseDown = function', '\nGuideName.OnMouseUp =')
    local broker = env.LibStub("LibDataBroker-1.1")
    broker.NewDataObject = function(_, _, data) return data end
    local icon = env.LibStub("LibDBIcon-1.0")
    icon.IsRegistered, icon.Register, icon.Show, icon.Hide = function() return true end, function() end, function() end, function() end
    addon.RXPFrame.GenerateMenuTable = function(_, menu) menu[1] = {text = "existing menu"} end
    local oldToggle = addon.settings.ToggleActive
    addon.settings.ToggleActive = function() toggled = toggled + 1 end
    addon.settings:UpdateMinimapButton()
    addon.settings.worldMapButton = object()
    addon.settings.worldMapButton.menuFrame = object()
    addon.settings.worldMapButton.menuFrame.Refresh = function() menus = menus + 1 end
    env.WorldMapFrame = object()
    env.HideUIPanel = function(frame) assert(frame == env.WorldMapFrame); frame:Hide() end
    env.self = addon.settings
    install(source("UI/Settings.lua"), '    self.worldMapButton:SetScript("OnClick",', '\n    if addon.gameVersion == 30300 then\n        if self.worldMapButton.SetToplevel')
    local callbacks = {
        function(button) env.Footer.cog.scripts.OnClick(env.Footer.cog, button) end,
        function(button) env.GuideName.OnMouseDown(env.GuideName, button) end,
        function(button) addon.settings.minimapButton.OnClick(nil, button) end,
        function(button) addon.settings.worldMapButton.scripts.OnClick(addon.settings.worldMapButton, button) end
    }
    for _, click in ipairs(callbacks) do
        addon.libraryTabs:Open("Settings")
        local beforeMenus, beforeClosed = menus, closed
        shift = false
        env.WorldMapFrame:Show()
        click("RightButton"); click("RightButton")
        assert(addon.libraryTabs.selected == "Guides" and addon.guideHub.window:IsShown())
        assert(menus == beforeMenus and closed == beforeClosed + 2, "plain right-click only opens library")
        addon.guideHub.window:Hide()
        addon.settings.worldMapButton.menuFrame:Hide()
        shift = true
        click("RightButton")
        assert(menus == beforeMenus + 1 and not addon.guideHub.window:IsShown(), "shift-right-click preserves menu")
    end
    shift = false
    callbacks[1]("LeftButton"); callbacks[2]("LeftButton"); callbacks[3]("LeftButton")
    assert(dragged == 1 and toggled == 1, "left-click dragging and minimap visibility are unchanged")
    addon.settings.worldMapButton.menuFrame:Hide()
    callbacks[4]("LeftButton")
    assert(addon.settings.worldMapButton.menuFrame:IsShown(), "left-click map menu is unchanged")
    callbacks[4]("RightButton")
    assert(not env.WorldMapFrame:IsShown(), "full-screen map cannot cover the opened hub")
    addon.settings.ToggleActive = oldToggle
    assert(env.RXPCData.currentStep == 7, "options shortcuts cannot change progress")
    local fallback = 0
    env.InterfaceOptionsFrame_OpenToCategory = function(panel) assert(panel == addon.RXPOptions); fallback = fallback + 1 end
    addon.settings.OpenLegacySettings()
    assert(fallback == 2, "stock Interface Options remains independently reachable")
    clean("Fallback")

    -- Actual Escape registration survives repeated shows and factory reuse.
    local hub = addon.guideHub
    addon.libraryTabs:Open("Guides")
    if style == "modern" then
        assert(addon.toolWindows:Create({name = "RXPGuideHub"}) == hub.window)
    end
    local escapeCount = 0
    for _, name in ipairs(env.UISpecialFrames) do
        if name == "RXPGuideHub" then escapeCount = escapeCount + 1; env[name]:Hide() end
    end
    assert(escapeCount == 1 and not hub.window:IsShown(), "Escape closes the registered root, once")
    addon.libraryTabs:Open("Guides")
    hub.frame.search.scripts.OnEscapePressed(hub.frame.search)
    assert(not hub.window:IsShown(), "focused search cannot swallow library Escape")
    addon.libraryTabs:Open("Settings")
    local editor = object(nil, hub.window)
    local editorWidget = {editbox = editor}
    addon.libraryTabs:HookEditorEscape(editorWidget)
    local escapeScript = editor.scripts.OnEscapePressed
    addon.libraryTabs:HookEditorEscape(editorWidget)
    assert(editor.scripts.OnEscapePressed == escapeScript, "editor Escape hook is installed once")
    escapeScript(editor)
    assert(not hub.window:IsShown())
    addon.libraryTabs:Open("Guides")
    editor:SetParent(env.UIParent)
    escapeScript(editor)
    assert(hub.window:IsShown(), "pooled editor cannot close its previous owner's hub")
    local multiline = object(nil, hub.window)
    addon.libraryTabs:HookEditorEscape({editBox = multiline})
    multiline.scripts.OnEscapePressed(multiline)
    assert(not hub.window:IsShown(), "legacy multiline editBox receives the Escape hook too")
    addon.libraryTabs:Open("Guides")
    local timer = addon.toolWindows:Create({name = "RXPFixturePersistent"})
    timer:Show()
    for _, name in ipairs(env.UISpecialFrames) do assert(name ~= "RXPFixturePersistent") end

    -- Exercise the Choose Step and shared Find Start confirmation definitions.
    -- RXP modal strata must survive hovering the library and be restored when
    -- the stock popup frame is returned to its shared pool.
    install(source("Features/Communications.lua"), 'local pendingChoices335', '\naddon.comms.grouping =')
    hub.selected = {key = "fixture", name = "fixture", active = true, guide = {}}
    hub:ChooseStep()
    addon.comms:ConfirmChoice("RXP_CATCHUP_CONFIRM", "fixture", forbidden)
    addon.comms:PopupNotification("RXP_CATCHUP_ERROR", "fixture")
    for _, key in ipairs({"RXP_GUIDE_HUB_STEP", "RXP_CATCHUP_CONFIRM", "RXP_CATCHUP_ERROR"}) do
        local dialog = object()
        dialog.editBox = object()
        dialog:SetFrameStrata("DIALOG")
        dialog:SetFrameLevel(17)
        env.StaticPopupDialogs[key].OnShow(dialog)
        addon.toolWindows:BringToFront(hub.window)
        assert(dialog:GetFrameStrata() == "FULLSCREEN_DIALOG" and hub.window:GetFrameStrata() == "DIALOG")
        dialog:Hide()
        assert(dialog:GetFrameStrata() == "DIALOG" and dialog:GetFrameLevel() == 17 and not dialog.rxpPopupStrata, "pooled popup layering restored")
    end

    -- Canonical metadata, not translated names or incidental zone text,
    -- determines purpose. Filtering must not load, advance or rename a guide.
    local fixture = {
        {"RestedXP Horde 1-30", "", "xp"},
        {"Original Guides - RXP Dungeon Quest Guides (A)", "15-30", "dungeon"},
        {"RestedXP Endgame Guides", "Heroism Set Guide", "loot"},
        {"+Profession Leveling", "", "profession"},
        {"+RestedXP Northrend Daily Quests", "Profession Daily Quests", "profession"},
        {"RXP TBC Reputation Guide", "The Aldor", "reputation"},
        {"+RestedXP Northrend Daily Quests", "Icecrown", "daily"},
        {"RestedXP Endgame Guides", "Attunements", "attunement"},
        {"Imported custom route", "", "other"}
    }
    local oldGuides = hub.guides
    hub.guides = {}
    hub.collection, hub.category, hub.purposeFilter = nil, "all", nil
    hub.factionFilter, hub.classFilter, hub.levelFilter, hub.availabilityFilter = "all", "all", "all", "all"
    for i, row in ipairs(fixture) do
        local guide = {group = row[1], subgroup = row[2], name = "Localized display", key = "type" .. i}
        assert(hub:GetGuidePurpose(guide) == row[3], "canonical guide type " .. row[1])
        hub.guides[i] = {guide = guide, key = guide.key, canonicalGroup = guide.group, canonicalName = guide.name, active = true}
    end
    hub.category = "leveling"
    assert(#hub:GetFilteredGuides() == 1, "Leveling cannot include professions or dungeon quest guides")
    local purposeMenu, menuOpens, menuCloses = nil, 0, 0
    env.DropDownList1 = object(); env.DropDownList1:Hide()
    env.EasyMenu = function(menu, owner)
        purposeMenu = menu; menuOpens = menuOpens + 1
        env.UIDROPDOWNMENU_OPEN_MENU = owner; env.DropDownList1:Show()
    end
    env.CloseDropDownMenus = function()
        menuCloses = menuCloses + 1; env.DropDownList1:Hide()
    end
    hub.frame.purpose.scripts.OnClick()
    assert(menuOpens == 1 and env.DropDownList1:IsShown())
    hub.frame.purpose.scripts.OnClick()
    assert(menuOpens == 1 and menuCloses == 1 and not env.DropDownList1:IsShown(),
        "second header click closes its menu without rebuilding or changing filters")
    assert(hub.category == "leveling" and not hub.purposeFilter)
    hub.frame.purpose.scripts.OnClick()
    assert(menuOpens == 2 and env.DropDownList1:IsShown(), "hidden dropdown reopens despite retained owner")
    env.UIDROPDOWNMENU_OPEN_MENU = object()
    hub.frame.purpose.scripts.OnClick()
    assert(menuOpens == 3 and menuCloses == 1, "another visible menu does not block opening Type")
    purposeMenu[5].func() -- Professions, from inside the Leveling category
    assert(hub.purposeFilter == "profession" and #hub.filtered == 2)
    assert(env.RXPCData.currentStep == 7)
    for _, child in ipairs(hub.frame.children) do
        local text = child:GetText()
        assert(text ~= "Leveling" and text ~= "Hardcore" and text ~= "Endgame" and text ~= "Farming",
            "redundant category buttons are absent in both styles")
    end
    hub.guides, hub.purposeFilter, hub.category = oldGuides, nil, nil
    if style == "legacy" then
        local frame = hub.frame
        local width, height, filtered = frame:GetWidth(), frame:GetHeight(), hub.filtered
        local measure = frame.status.GetStringHeight
        frame.status.GetStringHeight = function(self)
            return math.max(16, math.ceil(#self:GetText() * 7 / self:GetWidth()) * 16)
        end
        hub.filtered = {}
        for i = 1, 30 do
            hub.filtered[i] = {key = "layout" .. i, name = "A long guide title " .. i,
                group = "An explanatory family description", active = true}
        end
        for _, size in ipairs({{680, 500, 12}, {680, 500, 20}, {640, 420, 16}, {680, 500, 12}}) do
            frame:SetSize(size[1], size[2])
            frame.rows[1].name:SetFont("font", size[3])
            frame.rows[1].group:SetFont("font", size[3])
            frame.status:SetText(string.rep("Long preview and availability explanation. ", 12))
            frame.scroll.offset = 100
            hub:RefreshRows()
            local _, _, _, _, bottom = frame.scroll:GetPoint(2)
            assert(frame.visibleRows > 0 and frame.visibleRows < 12)
            assert(142 + frame.visibleRows * frame.rowHeight <= frame:GetHeight() - bottom,
                "Legacy visible rows stay above measured preview and footer")
            assert(bottom >= 68 + frame.status:GetHeight() + 10)
            assert(frame.scroll.scrollMetrics[2] == frame.visibleRows)
            assert(frame.scroll.offset == 30 - frame.visibleRows, "offset clamps after list geometry changes")
            for i, row in ipairs(frame.rows) do
                assert(row:IsShown() == (i <= frame.visibleRows), "overflow rows and their children are hidden")
                if i > frame.visibleRows then assert(not row.entry, "hidden rows retain no clickable guide") end
            end
            frame.scroll:GetScript("OnVerticalScroll")(frame.scroll, frame.rowHeight * 2)
            assert(frame.rows[1].entry == hub.filtered[3], "scrolling uses current row height")
        end
        frame.status.GetStringHeight = measure
        frame.rows[1].name:SetFont("font", 12); frame.rows[1].group:SetFont("font", 12)
        frame:SetSize(width, height); hub.filtered = filtered
        hub:RefreshRows()
        assert(env.RXPCData.currentStep == 7, "Legacy layout does not change progress")
    end
    local tooltipLines = {}
    env.GameTooltip.ClearLines = function() tooltipLines = {} end
    env.GameTooltip.AddLine = function(_, line) tooltipLines[#tooltipLines + 1] = line end
    -- Classification must use the production registration rewrite, not only
    -- authored group headers (the previous fixture missed Speedrun groups).
    install(source("Guide/Loader.lua"), 'function addon.GroupOverride(', '\nif not _G.RXPGuides.RegisterGuide')
    addon.services = {Register = function() end}
    load("Guide/Hardcore.lua")
    for _, faction in ipairs({"Alliance", "Horde"}) do
        local guide = {group = "RestedXP " .. faction .. " 1-30", name = "1-6 Starter", key = faction}
        addon.GroupOverride(guide)
        assert(guide.group:find("Speedrun", 1, true) and hub:GetGuidePurpose(guide) == "xp")
        assert(hub:GetGuideIdentifier(guide) == "Speedrun")
        local entry = {guide = guide, canonicalGroup = guide.group, group = guide.group,
            key = guide.key, name = guide.name, canonicalName = guide.name, active = true}
        hub:Select(entry)
        assert(hub.frame.status:GetText():find("Speedrun", 1, true))
        guide.group = "Original Guides - " .. guide.group
        assert(hub:GetGuidePurpose(guide) == "xp")
        assert(hub:GetPreviewIdentity(entry):find("Speedrun", 1, true))
    end
    for _, family in ipairs(addon.hardcoreGuides.families) do
        for _, faction in ipairs({"A", "H"}) do
            local guide = {group = family.group .. " (" .. faction .. ")", name = "1-6 Starter", key = family.id .. faction}
            assert(hub:GetGuidePurpose(guide) == "other" and hub:GetGuideIdentifier(guide) == "Hardcore")
            local entry = {guide = guide, canonicalGroup = guide.group, group = family.label,
                key = guide.key, name = guide.name, canonicalName = guide.name, active = true}
            hub:Select(entry)
            local description = hub.frame.status:GetText()
            assert(description:find("Hardcore", 1, true) and description:find(family.label, 1, true))
            hub.guides = {entry}; hub.category, hub.purposeFilter = "all", "other"
            assert(#hub:GetFilteredGuides() == 1)
            hub.purposeFilter = "xp"; assert(#hub:GetFilteredGuides() == 0)
        end
    end
    hub.guides, hub.category, hub.purposeFilter = oldGuides, nil, nil
    local helpControls = {hub.frame.continue, hub.frame.restart, hub.frame.chooseStep, hub.frame.findStart,
        hub.frame.purpose, hub.frame.factionFilter, hub.frame.classFilter, hub.frame.levelFilter, hub.frame.availabilityFilter}
    for _, button in pairs(addon.libraryTabs.buttons) do helpControls[#helpControls + 1] = button end
    for _, button in ipairs(hub.frame.navigation or {}) do helpControls[#helpControls + 1] = button end
    for _, button in ipairs(helpControls) do
        assert(button.rxpLibraryHelp and button.scripts.OnEnter and button.scripts.OnLeave)
        local click, enter = button.scripts.OnClick, button.scripts.OnEnter
        hub:AttachTooltip(button, button.rxpLibraryHelp)
        assert(button.scripts.OnEnter == enter and button.scripts.OnClick == click, "help hooks preserve callbacks and do not stack")
        enter(button)
        assert(#tooltipLines >= 2 and tooltipLines[2] ~= tooltipLines[1], "button has explanatory help")
        button.scripts.OnLeave(button)
    end
    for _, child in ipairs(hub.frame:GetChildren()) do
        assert(child:GetText() ~= "Feature Tools", "Guides page has no duplicate tools shortcut")
    end
    assert(env.RXPCData.currentStep == 7, "preview identities and help cannot change progress")
    local favoriteEntry = {key = "favorite-fixture"}
    hub:FavoriteTooltip(object(), favoriteEntry)
    assert(tooltipLines[1] == "Add to Favorites")
    hub:ToggleFavorite(favoriteEntry)
    hub:FavoriteTooltip(object(), favoriteEntry)
    assert(tooltipLines[1] == "Remove from Favorites" and env.RXPCData.currentStep == 7)
    hub:ToggleFavorite(favoriteEntry)
    assert(not env.RXPData.guideHub.favorites[favoriteEntry.key])
    local star = object()
    hub:UpdateFavoriteIcon(star, false)
    local iconTexture = star.favoriteIcon
    assert(star:GetText() == "" and iconTexture:GetTexture() ==
        "Interface\\AddOns\\RXPGuides\\Textures\\Tabler\\favorite-outline.tga")
    assert(iconTexture:GetWidth() == 18 and iconTexture:GetHeight() == 18)
    assert(iconTexture.vertexColor[1] == 0.7)
    hub:UpdateFavoriteIcon(star, true)
    assert(star.favoriteIcon == iconTexture and iconTexture:GetTexture():find("favorite-filled.tga", 1, true))
    assert(iconTexture.vertexColor[1] == 1 and iconTexture.vertexColor[2] == 0.82)
    local textureWrites, setTexture = 0, iconTexture.SetTexture
    iconTexture.SetTexture = function(self, path) textureWrites = textureWrites + 1; setTexture(self, path) end
    hub:UpdateFavoriteIcon(star, true)
    assert(textureWrites == 0, "unchanged favorite state does not rewrite the texture")
    hub:UpdateFavoriteIcon(star, nil)
    assert(textureWrites == 1 and iconTexture:GetTexture():find("favorite-outline.tga", 1, true), "pooled button resets its previous favorite")

    -- CI can validate the committed legacy-client assets without a renderer.
    local function readBinary(path)
        local file = assert(io.open(root .. "/" .. path, "rb"))
        local bytes = file:read("*a"); file:close(); return bytes
    end
    local masses = {}
    for _, variant in ipairs({"outline", "filled"}) do
        local bytes = readBinary("Textures/Tabler/favorite-" .. variant .. ".tga")
        assert(#bytes == 18 + 32 * 32 * 4 and bytes:byte(1) == 0 and bytes:byte(2) == 0 and bytes:byte(3) == 2)
        assert(bytes:byte(13) == 32 and bytes:byte(14) == 0 and bytes:byte(15) == 32 and bytes:byte(16) == 0)
        assert(bytes:byte(17) == 32 and bytes:byte(18) == 8, "uncompressed 32-bit bottom-origin TGA")
        local transparent, solid, blended, mass = 0, 0, 0, 0
        for offset = 19, #bytes, 4 do
            assert(bytes:byte(offset) == 255 and bytes:byte(offset + 1) == 255 and bytes:byte(offset + 2) == 255)
            local alpha = bytes:byte(offset + 3)
            if alpha == 0 then transparent = transparent + 1 elseif alpha == 255 then solid = solid + 1 else blended = blended + 1 end
            mass = mass + alpha
        end
        assert(transparent > 0 and solid > 0 and blended > 0, "transparent antialiased icon")
        masses[variant] = mass
    end
    assert(masses.filled > masses.outline, "distinct outline and filled shapes")
    assert(readBinary("Textures/Tabler/LICENSE.txt"):find("MIT License", 1, true))
    assert(readBinary("Textures/Tabler/NOTICE.txt"):find("a4ce1404bc6d24d3c365afe7b258d6bf6f48d62d", 1, true))
    local redraws, levels = 0, 0
    local redraw, unitLevel = hub.RefreshRows, env.UnitLevel
    hub.RefreshRows = function(self, ...) redraws = redraws + 1; return redraw(self, ...) end
    env.UnitLevel = function(...) levels = levels + 1; return unitLevel(...) end
    hub:RefreshFilter()
    assert(redraws == 1 and levels == 1, "one redraw and player-level read per filter pass in " .. style)
    hub.RefreshRows, env.UnitLevel = redraw, unitLevel
    local manager = addon.toolWindows
    local top = manager.layerOrder[#manager.layerOrder]
    assert(top)
    local writes, traversals = 0, 0
    local setLevel, getChildren = top.SetFrameLevel, top.GetChildren
    top.SetFrameLevel = function(self, ...) writes = writes + 1; return setLevel(self, ...) end
    top.GetChildren = function(self, ...) traversals = traversals + 1; return getChildren(self, ...) end
    for i = 1, 100 do manager:BringToFront(top) end
    assert(writes == 0 and traversals == 0, "front-window requests cannot traverse descendants")
    local late = object(nil, top)
    manager:BringToFront(top, true)
    assert(writes > 0 and traversals > 0 and late.rxpToolLayerHook, "forced refresh layers late controls")
    top.SetFrameLevel, top.GetChildren = setLevel, getChildren
    local scroll, scrollChild = manager:AddScrollingText(top)
    assert(scroll.rxpToolLayerHook and scrollChild.rxpToolLayerHook, "new shared scroll content is layered immediately")
    local onShowChild = object(nil, top)
    top:Hide(); top:Show()
    assert(onShowChild.rxpToolLayerHook, "opening an already-front window refreshes its new controls")
    local pooled = object(nil, top); pooled.rxpPooledContent = true
    local borrowed = object(nil, pooled)
    manager:RefreshLayering()
    assert(not borrowed.rxpToolLayerHook, "borrowed AceGUI descendants remain excluded")
    if style == "modern" then
        addon.libraryTabs:Open("Guides")
        local rowCount, priorHeight = #hub.frame.rows, hub.frame.viewport:GetHeight()
        hub.frame.viewport:SetHeight((rowCount + 3) * hub.frame.rowHeight)
        addon.modernLibrary:Rows(hub)
        assert(#hub.frame.rows > rowCount and hub.frame.rows[#hub.frame.rows].rxpToolLayerHook,
            "growing the modern row pool layers new rows immediately")
        hub.frame.viewport:SetHeight(priorHeight)
    end
    print("Unified library: production options and bundled renderer passed")
    string.split = oldSplit
    if style == "modern" then assert(loadfile(root .. "/tests/library-tabs.lua"))()(root, baseObject, "legacy") end
end
