-- Exercise the production HUD drag bindings and list click handlers. No polling
-- or client input simulation is used to decide whether a gesture is a drag.
return function(root)
    local file = assert(io.open(root .. "/UI/GuideWindow.lua", "rb"))
    local source = file:read("*a"):gsub("\r\n", "\n"); file:close()
    local function section(first, last)
        local start = assert(source:find(first, 1, true))
        return source:sub(start, assert(source:find(last, start + #first, true)) - 1)
    end
    for _, modern in ipairs({false, true}) do
        local counts = {moves = 0, stops = 0, saves = 0, jumps = 0, menus = 0, sizes = 0, reflows = 0}
        local function frame()
            local f = {scripts = {}, visible = true, alpha = 1}
            function f:SetScript(event, callback) self.scripts[event] = callback end
            function f:GetScript(event) return self.scripts[event] end
            function f:HookScript(event, callback)
                local old = self.scripts[event]
                self.scripts[event] = function(...) if old then old(...) end; callback(...) end
            end
            function f:EnableMouse(value) self.mouse = value end
            function f:RegisterForDrag(button) self.dragButton = button end
            function f:IsVisible() return self.visible end
            function f:GetAlpha() return self.alpha end
            function f:GetHeight() return 200 end
            function f:StartMoving() counts.moves = counts.moves + 1 end
            function f:StopMovingOrSizing() counts.stops = counts.stops + 1 end
            function f:StartSizing() counts.sizes = counts.sizes + 1 end
            return f
        end
        local env = setmetatable({}, {__index = _G}); env._G = env
        local hud, bottom, scroll, child, row = frame(), frame(), frame(), frame(), frame()
        local guide = {steps = {}}; local step = {index = 3}; guide.steps[3] = step
        row.step, row.guide = step, guide
        local profile = {lockFrames = false}
        env.addon = {
            settings = {profile = profile, SaveFramePositions = function() counts.saves = counts.saves + 1 end},
            presentation = {IsModern = function() return modern end, GetHUD = function() return {} end,
                SetHeight = function() end, Invalidate = function() end},
            currentGuide = guide, UpdateItemFrame = function() end,
            SetStep = function() counts.reflows = counts.reflows + 1 end,
            GoToStep = function(index) assert(index == 3); counts.jumps = counts.jumps + 1 end,
        }
        env.RXPFrame, env.BottomFrame, env.ScrollFrame, env.ScrollChild = hud, bottom, scroll, child
        env.RXPCData = {currentStep = 3}
        env.SetStepFrameAnchor = function() end
        env.IsAltKeyDown = function() return env.alt end
        env.IsFrameShown = function() return not env.filtered end
        env.MouseIsOver = function() return not env.outside end
        env.EasyMenu = function() counts.menus = counts.menus + 1 end
        env.MenuFrame, env.feedbackMenuIndex, env.L = {}, 2, function(text) return text end
        env.frame = row
        hud.BottomFrame, hud.bottomMenu = {UpdateFrame = function() end}, {{}, {}}
        local code = section("local isResizing\n", "local stepPos = {}") .. "\nlocal function InstallRow()\n" ..
            section('        frame:SetScript("OnMouseDown", function(self, button)\n', '        if not frame.text then') ..
            "\nend\nInstallRow()\nreturn BindGuideDragSurface, InstallRow"
        local bind, installRow = setfenv(assert(loadstring(code)), env)()
        local function fire(f, event, button) if f.scripts[event] then f.scripts[event](f, button or "LeftButton") end end
        local function drag(f)
            fire(f, "OnMouseDown"); fire(f, "OnDragStart"); fire(f, "OnDragStop"); fire(f, "OnMouseUp")
        end
        for _, surface in ipairs({bottom, scroll, child}) do
            assert(surface.mouse and surface.dragButton == "LeftButton")
            drag(surface)
        end
        assert(counts.moves == 3 and counts.saves == 3 and counts.jumps == 0)
        fire(row, "OnMouseDown"); assert(counts.jumps == 0)
        fire(row, "OnMouseUp"); assert(counts.jumps == 1)
        drag(row); assert(counts.jumps == 1 and counts.moves == 4 and counts.saves == 4)
        -- Either native release order stops/saves exactly once, never navigates.
        fire(row, "OnMouseDown"); fire(row, "OnDragStart"); fire(row, "OnMouseUp"); fire(row, "OnDragStop")
        assert(counts.moves == 5 and counts.stops == 5 and counts.saves == 5 and counts.jumps == 1)
        fire(row, "OnMouseDown", "RightButton"); fire(row, "OnMouseUp", "RightButton")
        assert(counts.menus == 1 and counts.jumps == 1 and counts.moves == 5)
        profile.lockFrames = true; drag(row)
        assert(counts.moves == 5 and counts.jumps == 1)
        profile.lockFrames = false
        fire(row, "OnMouseDown"); env.addon.currentGuide = {}; fire(row, "OnMouseUp")
        env.addon.currentGuide = guide
        fire(row, "OnMouseDown"); row.step = {}; fire(row, "OnMouseUp"); row.step = step
        fire(row, "OnMouseDown"); env.outside = true; fire(row, "OnMouseUp"); env.outside = false
        fire(row, "OnMouseDown"); env.filtered = true; fire(row, "OnMouseUp"); env.filtered = false
        assert(counts.jumps == 1, "stale/filtered/outside release navigated")
        row.alpha = 0; drag(row); row.alpha = 1
        row.visible = false; drag(row); row.visible = true
        assert(counts.moves == 5 and counts.jumps == 1)
        local objective = frame(); objective.element = {}; objective.step = step
        local enter = function() end; objective:SetScript("OnEnter", enter)
        bind(objective); bind(objective); drag(objective)
        assert(counts.moves == 6 and counts.saves == 6 and objective:GetScript("OnEnter") == enter)
        objective.element.tooltip = "Information"; drag(objective)
        objective.element.tooltip = nil; objective.element.guideTranslationFallback = true; drag(objective)
        objective.element.guideTranslationFallback = nil
        local promptCalls = 0
        local prompt = function() promptCalls = promptCalls + 1 end
        objective:SetScript("OnMouseDown", prompt); drag(objective)
        assert(promptCalls == 1 and objective:GetScript("OnMouseDown") == prompt and counts.moves == 6)
        objective:SetScript("OnMouseDown", nil); objective.step = {tip = true}; drag(objective)
        assert(counts.moves == 6, "independent tip moved the main HUD")
        objective.step = step
        fire(objective, "OnDragStart"); fire(objective, "OnHide"); fire(objective, "OnMouseUp")
        assert(counts.moves == 7 and counts.saves == 7)
        fire(objective, "OnDragStart"); fire(hud, "OnHide"); fire(objective, "OnDragStop")
        assert(counts.moves == 8 and counts.saves == 8)
        assert(not bottom.scripts.OnUpdate and not scroll.scripts.OnUpdate and not row.scripts.OnUpdate)
        assert(counts.reflows == 0, "ordinary dragging activated steps")
        env.alt = true; drag(objective)
        assert(counts.sizes == 1 and counts.saves == 9)
        assert(counts.reflows == (modern and 0 or 1), "existing Alt-resize behavior changed")
        assert(profile.framePositions == nil and guide.steps[3] == step)
        env.alt = false
        installRow(); installRow() -- reused rows replace click handlers, not drag hooks
        drag(row)
        assert(counts.moves == 9 and counts.saves == 10 and counts.jumps == 1)
        fire(row, "OnMouseDown"); fire(row, "OnMouseUp")
        assert(counts.jumps == 2 and counts.saves == 10)
    end
    print("HUD drag passed: both styles, native gestures, click/menu preservation, locks, prompts, pooling and cancellation.")
end
