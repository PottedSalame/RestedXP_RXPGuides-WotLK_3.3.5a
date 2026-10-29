-- Deterministic allocation/work ownership checks, not client memory estimates.
return function(root)
    local function read(path)
        local f = assert(io.open(root .. "/" .. path, "rb"))
        local text = f:read("*a"):gsub("\r\n", "\n"); f:close(); return text
    end
    local function section(path, first, last)
        local text = read(path)
        local a = assert(text:find(first, 1, true), first)
        return text:sub(a, assert(text:find(last, a, true), last) - 1)
    end
    local env = setmetatable({}, {__index = _G}); env._G = env
    env.GetLocale = function() return "enUS" end
    env.GetTime = function() return 0 end
    env.tinsert = table.insert
    env.RXPCData = {currentStep = 1, stepSkip = {}}
    local addon = {locale = {Get = function(s) return s end},
        settings = {profile = {activeTheme = "Default", guideFontSize = 12,
            colorBlindMode = "off", guideLanguage = "english"}},
        activeTheme = {background = {0.1, 0.2, 0.3, 1},
            bottomFrameBG = {0.2, 0.3, 0.4, 1}, textColor = {0.8, 0.9, 1}},
        font = "font", guideTextColors = {default = {error = "ffff0000"},
            RXP_WARN_ = "ffff0000", ffff0000 = "ffff0000"}}
    addon.colors = addon.activeTheme; env.addon = addon
    local function execute(text) return setfenv(assert(loadstring(text)), env)() end
    local function load(path) setfenv(assert(loadfile(root .. "/" .. path)), env)("RXPGuides", addon) end
    load("UI/Presentation.lua"); addon.presentation:Initialize()
    load("Features/Accessibility.lua")
    local view = addon.presentation
    local a, b, c = view:Palette()
    for _ = 1, 1000 do
        local x, y, z = view:Palette(); assert(a == x and b == y and c == z)
    end
    local paint = execute(section("UI/GuideWindow.lua", "local stepVisuals = {",
        "local function ApplyElementVisualState") .. "\nreturn ApplyStepVisualState")
    local writes = 0
    local function object()
        local f = {}
        for _, key in ipairs({"SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor",
            "SetTextColor", "SetText", "SetWidth"}) do
            f[key] = function() writes = writes + 1 end
        end
        f.GetStringWidth = function() return 12 end
        return f
    end
    local row = object(); row.number = object(); row.number.text = object(); row.text = object()
    local step = {index = 5}
    paint(row, step, true)
    local first, background = writes, row.stepVisualBackground
    for _ = 1, 1000 do paint(row, step, true) end
    assert(writes == first and row.stepVisualBackground == background, "unchanged paint allocated/wrote UI")
    env.RXPCData.stepSkip[5] = true; paint(row, step, true)
    assert(writes > first and row.stepVisualState == "skipped")
    env.RXPCData.stepSkip[5] = nil
    addon.settings.profile.activeTheme = "Custom"; paint(row, step, true)
    first = writes; addon.activeTheme.bottomFrameBG[1] = 0.9; paint(row, step, true)
    assert(writes > first and row.stepVisualBackground[1] == 0.9, "in-place theme edit lost")
    first = writes; addon.activeTheme.textColor[4] = 0.7; paint(row, step, true)
    assert(writes > first, "text opacity edit lost")
    first = writes; row.rxpModernBackdrop = nil; paint(row, step, true)
    assert(writes > first, "pooled backdrop reset lost")
    first = writes; view.themeRevision = 1; paint(row, step, true); assert(writes > first)
    addon.settings.profile.colorBlindMode = "contrast"; paint(row, step, true)
    first = writes; view.appliedStyle = "legacy"; paint(row, step, true)
    assert(writes > first); first = writes; paint(row, step, true); assert(writes == first)

    -- The real pooled-row setup resets font colours. Its final paint must run
    -- AFTER that reset, not leave a cache describing colours no longer on screen.
    for _, method in ipairs({"SetFontObject", "ClearAllPoints", "SetPoint",
        "SetJustifyH", "SetJustifyV", "SetFont"}) do row.text[method] = function() end end
    row.SetHeight = function() end
    local textR, textG, textB
    row.text.SetTextColor = function(_, r, g, b) textR, textG, textB = r, g, b end
    addon.settings.profile.colorBlindMode = "off"; step.completed = true
    row.rxpStepPaint = nil
    env.frame, env.step, env.ApplyStepVisualState = row, step, paint
    execute("for _ = 1, 1 do\n" .. section("UI/GuideWindow.lua",
        "        frame.text:SetFontObject", "    if #ScrollChild.framePool > nframes then"))
    assert(textR == 0.58 and textG == 1 and textB == 0.66, "pooled font reset erased completion colour")
    addon.settings.profile.colorBlindMode = "contrast"

    execute(section("UI/Settings.lua", "local guideColorFields =", "local function buildWorldMapMenu"))
    assert(addon.settings.ReplaceColors("Plain text") == "Plain text")
    assert(addon.settings.ReplaceColors("Line one\\nLine two") == "Line one\nLine two")
    assert(addon.settings.ReplaceColors("|cffff0000Warning|r"):find("ffff0000", 1, true))
    load("Guide/Localization.lua")
    local service = addon.guideLocalization
    local element = {tag = "complete", questId = 788, obj = 1, step = {active = true}}
    local status
    for i = 1, 1000 do
        local text = "Boars slain: " .. i .. "/1000"
        local result, meta = service:RenderRow(text, element, "text")
        assert(result == text and (not status or status == meta), "compact display froze live counts or allocated metadata")
        status = meta
    end
    local result, meta = service:Render("Boars slain: 2/10", element)
    assert(result == "Boars slain: 2/10" and meta.sourceSignature and meta.mode == "english",
        "public metadata contract changed")
    local colored = {text = "|cRXP_WARN_Watch|r"}
    addon.settings.ReplaceColors(colored)
    assert(colored.text:find("[!]", 1, true))
    addon.settings.profile.colorBlindMode = "off"; addon.settings.ReplaceColors(colored)
    assert(not colored.text:find("[!]", 1, true), "original colour source was lost")
    local npcCalls, resolved = 0, nil
    addon.GetNpcName = function() npcCalls = npcCalls + 1; return resolved end
    execute(section("Guide/Directives/Handlers.lua", "function addon.ReplaceNpcIds", "function addon.GetItemName"))
    for _ = 1, 1000 do assert(addon.ReplaceNpcIds("Plain text", element) == "Plain text") end
    assert(npcCalls == 0)
    assert(addon.ReplaceNpcIds("npc:Fallback:42", element) == "Fallback")
    resolved = "Resolved"; assert(addon.ReplaceNpcIds("npc:Fallback:42", element) == "Resolved")
    element.step.active = false; assert(addon.ReplaceNpcIds("npc:Fallback:42", element) == "42")
    element.step.active = true
    assert(addon.ReplaceNpcIds("|cffffffffFallback::42|r", element):find("Resolved", 1, true))

    -- Execute the production update loop, including its normal periodic batch.
    addon.tickers = {ShouldContinue = function() return true end}
    addon.updateActiveQuest, addon.guideCache, addon.stepUpdateList = {}, {}, {}
    addon.currentGuide = {steps = {}}; env.RXPCData.currentStep = 0
    for i = 1, 100 do addon.currentGuide.steps[i] = {active = i == 1}; addon.stepUpdateList[i] = true end
    local rows, redirty = 0, true
    addon.RXPFrame = {BottomFrame = {UpdateFrame = function(_, n)
        rows = rows + 1
        if n == 1 and redirty then
            redirty = false; addon.stepUpdateList[1] = true; addon.updateStepText = true
        end
    end}, CurrentStepFrame = {UpdateText = function() addon.updateStepText = false end}}
    addon.updateStepText = true
    execute(section("Core/Addon.lua", "local stepCounter = 1", "addon.tickers = {}"))
    addon.LegacyUpdateLoop(); rows = 0; addon.LegacyUpdateLoop()
    assert(rows == 106 and addon.updateStepText and addon.stepUpdateList[1])
    local pending = 0; for _ in pairs(addon.stepUpdateList) do pending = pending + 1 end
    assert(pending == 1, "one row retained unrelated requests")
    addon.LegacyUpdateLoop(); rows = 0; addon.LegacyUpdateLoop()
    assert(rows == 7 and not next(addon.stepUpdateList), "new request was lost or replayed unrelated rows")
    -- A later row can also dirty an already-consumed earlier row.
    addon.stepUpdateList[1], addon.stepUpdateList[100] = true, true; addon.updateStepText = true
    addon.RXPFrame.BottomFrame.UpdateFrame = function(_, n)
        if n == 100 then addon.stepUpdateList[1] = true; addon.updateStepText = true end
    end
    addon.LegacyUpdateLoop(); addon.LegacyUpdateLoop()
    assert(addon.stepUpdateList[1] and not addon.stepUpdateList[100])

    local hidden = {Hide = function() end, EnableMouse = function() end}
    local weak = setmetatable({}, {__mode = "v"})
    hidden.guide = {steps = {{}}}; hidden.step = hidden.guide.steps[1]; weak[1] = hidden.guide
    env.ScrollChild, env.nframes = {framePool = {{}, hidden}}, 1
    execute(section("UI/GuideWindow.lua", "    if #ScrollChild.framePool > nframes then", "    ScrollChild.f1 ="))
    collectgarbage("collect") -- test process only
    assert(not weak[1] and not hidden.step, "hidden row retains old guide")
    print("Memory refresh regressions passed: palette/paint reuse, live compact display, dirty ownership and released rows.")
end
