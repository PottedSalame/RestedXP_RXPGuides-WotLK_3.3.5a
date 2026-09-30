-- Legacy AceGUI deliberately has no widget-level HighlightText method.
return function(root)
    local env = setmetatable({}, {__index = _G})
    env._G = env
    env.max, env.tinsert = math.max, table.insert
    env.UISpecialFrames = {}
    local edit, window
    local function noop() end
    local ace = {}
    function ace:Create(kind)
        if kind == "MultiLineEditBox" then
            local native = {scripts = {}, highlights = 0}
            function native:SetScript(event, callback) self.scripts[event] = callback end
            function native:SetFocus() self.focused = true end
            function native:HighlightText() self.highlights = self.highlights + 1 end
            edit = {
                editBox = native, callbacks = {}, label = {GetStringWidth = function() return 80 end},
                SetLabel = noop, SetFullWidth = noop, SetFullHeight = noop,
                SetMaxLetters = noop, DisableButton = noop,
            }
            function edit:SetText(text) self.text = text end
            function edit:SetCallback(event, callback) self.callbacks[event] = callback end
            return edit
        end
        assert(kind == "Frame")
        window = {
            frame = {SetBackdrop = noop, SetBackdropColor = noop},
            statustext = {GetParent = function() return {Hide = noop} end},
            titletext = {GetWidth = function() return 120 end},
            Hide = noop, Show = noop, SetLayout = noop, EnableResize = noop,
            SetTitle = noop, AddChild = noop, SetWidth = noop, SetHeight = noop,
            DoLayout = noop, callbacks = {},
        }
        function window:SetCallback(event, callback) self.callbacks[event] = callback end
        function window:Release() self.released = true end
        return window
    end
    env.LibStub = function(name) assert(name == "AceGUI-3.0"); return ace end
    local addon = {
        locale = {Get = function(text) return text end},
        RXPFrame = {backdrop = {edge = {}}}, colors = {background = {0, 0, 0, 1}},
        SetResizeBounds = noop,
    }
    function addon:NewModule() return {} end
    local chunk = assert(loadfile(root .. "/Features/Communications.lua"))
    setfenv(chunk, env)("RXPGuides", addon)
    addon.comms.OpenBrandedExport("Performance Report", "Fixture", "Report text", 620, 420)
    assert(edit.HighlightText == nil)
    edit.editBox.scripts.OnMouseUp(edit.editBox)
    assert(edit.editBox.focused and edit.editBox.highlights == 1)
    assert(not edit.editBox.scripts.OnMouseUp, "selection handler was not one-shot")
    edit.editBox:HighlightText() -- native Ctrl+A selection path
    assert(edit.editBox.highlights == 2)
    edit.text = "accidental edit"
    edit.callbacks.OnTextChanged(edit, "OnTextChanged", edit.text)
    assert(edit.text == "Report text", "read-only export text was not restored")
    window.callbacks.OnClose()
    assert(window.released)
    local received
    addon.comms.OpenBrandedExport("Import", "Fixture", "", 620, 420,
        function(text) received = text end)
    assert(not edit.editBox.scripts.OnMouseUp, "import window gained export-only selection")
    edit.callbacks.OnEnterPressed(edit, "OnEnterPressed", "input")
    assert(received == "input" and edit.text == "")
    print("Legacy export selection and editable import regressions passed.")
end
