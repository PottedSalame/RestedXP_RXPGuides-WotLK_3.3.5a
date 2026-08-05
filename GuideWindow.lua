local addonName, addon = ...

local RXPGuides = addon.RXPGuides
local _, class = UnitClass("player")
local _G = _G
local fmt,tinsert = string.format, table.insert
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0", true)

-- Alias addon.locale.Get
local L = addon.locale.Get

local BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
function addon.SetResizeBounds(frame, width, height)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(width, height)
    else
        frame:SetMinResize(width, height)
    end
end

addon.width, addon.height = 235, 125 -- Default width/height

local RXPFrame = CreateFrame("Frame", "RXPFrame", UIParent, BackdropTemplate)
addon.RXPFrame = RXPFrame
addon.enabledFrames["RXPFrame"] = RXPFrame
RXPFrame.IsFeatureEnabled = function()
    return not addon.settings.profile.hideGuideWindow,false
end

local BottomFrame = CreateFrame("Frame", "$parent_bottomFrame", RXPFrame,
                                BackdropTemplate)
local GuideName = CreateFrame("Frame", "$parentGuideName", RXPFrame,
                              BackdropTemplate)
local Footer = CreateFrame("Frame", "$parentGuideName", RXPFrame,
                           BackdropTemplate)
local ScrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame",
                                BottomFrame, "UIPanelScrollFrameTemplate")
-- 3.3.5a: UIPanelScrollFrameTemplate exposes its scrollbar as a global named
-- "<frameName>ScrollBar" rather than a .ScrollBar field. Alias it (and its
-- up/down buttons) so the modern ScrollFrame.ScrollBar code path works.
if not ScrollFrame.ScrollBar then
    local sfName = ScrollFrame:GetName()
    ScrollFrame.ScrollBar = sfName and _G[sfName .. "ScrollBar"]
    if ScrollFrame.ScrollBar then
        ScrollFrame.ScrollBar.ScrollUpButton =
            ScrollFrame.ScrollBar.ScrollUpButton or _G[sfName .. "ScrollBarScrollUpButton"]
        ScrollFrame.ScrollBar.ScrollDownButton =
            ScrollFrame.ScrollBar.ScrollDownButton or _G[sfName .. "ScrollBarScrollDownButton"]
        -- 3.3.5a scroll buttons expose textures via GetNormalTexture() etc.
        -- rather than .Normal/.Pushed/.Disabled/.Highlight parentKeys, which
        -- UpdateScrollBar re-skins. Alias them (creating any that are missing).
        local function aliasTextures(btn)
            if not btn then return end
            local map = {
                Normal = { btn.GetNormalTexture, btn.SetNormalTexture },
                Pushed = { btn.GetPushedTexture, btn.SetPushedTexture },
                Disabled = { btn.GetDisabledTexture, btn.SetDisabledTexture },
                Highlight = { btn.GetHighlightTexture, btn.SetHighlightTexture },
            }
            for key, fns in pairs(map) do
                local tex = btn[key] or (fns[1] and fns[1](btn))
                if not tex then
                    tex = btn:CreateTexture(nil, "ARTWORK")
                    if fns[2] then fns[2](btn, tex) end
                end
                btn[key] = tex
            end
        end
        aliasTextures(ScrollFrame.ScrollBar.ScrollUpButton)
        aliasTextures(ScrollFrame.ScrollBar.ScrollDownButton)
    end
end
local CurrentStepFrame = CreateFrame("Frame", nil, RXPFrame)
local ScrollChild = CreateFrame("Frame", "$parent_steps", BottomFrame,
                                BackdropTemplate)
local MenuFrame = CreateFrame("Frame", "RXPG_MenuFrame", UIParent,
                              "UIDropDownMenuTemplate")
RXPFrame.BottomFrame = BottomFrame
RXPFrame.GuideName = GuideName
RXPFrame.Footer = Footer
RXPFrame.CurrentStepFrame = CurrentStepFrame
RXPFrame.ScrollFrame = ScrollFrame
RXPFrame.ScrollChild = ScrollChild
RXPFrame.MenuFrame = MenuFrame

function RXPFrame:UpdateVisuals()
    BottomFrame:ClearBackdrop()
    BottomFrame:SetBackdrop(RXPFrame.backdrop.edge)
    BottomFrame:SetBackdropColor(unpack(addon.colors.background))

    if RXPFrame.activeItemFrame then
        RXPFrame.activeItemFrame:ClearBackdrop()
        RXPFrame.activeItemFrame:SetBackdrop(RXPFrame.backdrop.edge)
        RXPFrame.activeItemFrame:SetBackdropColor(
            unpack(addon.colors.background))
    end

    GuideName:ClearBackdrop()
    GuideName:SetBackdrop(RXPFrame.backdrop.guideName)
    GuideName:SetBackdropColor(unpack(addon.colors.background))
    Footer:ClearBackdrop()
    Footer:SetBackdrop(RXPFrame.backdrop.guideName)
    Footer:SetBackdropColor(unpack(addon.colors.background))
    Footer.bg:SetTexture(addon.GetTexture("rxp-banner"))

    GuideName.bg:SetTexture(addon.GetTexture("rxp-banner"))
    GuideName.icon:SetTexture(addon.GetTexture("rxp_logo-64"))
    GuideName.classIcon:SetTexture(addon.GetTexture(class))
    Footer.cog:SetNormalTexture(addon.GetTexture("rxp_cog-32"))
    RXPFrame.UpdateScrollBar()
end

function addon.ReloadStep()
    addon.SetStep(RXPCData.currentStep)
end

function addon.RenderFrame(themeUpdate,isLoading)
    addon:LoadActiveTheme()

    -- TODO better handle themes
    addon.colors = addon.activeTheme

    --TODO: Add UpdateVisuals function to every frame under enabledFrames
    for _,frame in pairs(addon.enabledFrames) do
        if frame.UpdateVisuals then
            frame:UpdateVisuals(true)
        end
    end
    if not themeUpdate then
        RXPFrame.GenerateMenuTable()
    end
    if addon.currentGuide and not isLoading then
        addon:ReloadGuide(true)
    end
end


RXPFrame.backdrop = {}

RXPFrame.defaultBackground = {
    edge = "Interface/BUTTONS/WHITE8X8",
    bottom = "Interface/BUTTONS/WHITE8X8",
}

RXPFrame.defaultEdges = {
    edge = "Interface/AddOns/" .. addonName .. "/Textures/rxp-borders",
    guideName = "Interface/AddOns/" .. addonName .. "/Textures/rxp-borders",
}

RXPFrame.backdrop.edge = {
    bgFile = "Interface/BUTTONS/WHITE8X8",
    -- edgeFile = "Interface/BUTTONS/WHITE8X8",
    -- edgeFile = "Interface/ARENAENEMYFRAME/UI-Arena-Border",
    edgeFile = addon.GetTexture("rxp-borders"),
    tile = true,
    edgeSize = 8,
    tileSize = 8,
    insets = {left = 4, right = 2, top = 2, bottom = 4}
}

RXPFrame.backdrop.guideName = {
    edgeFile = addon.GetTexture("rxp-borders"),
    edgeSize = 8,
    insets = {left = 4, right = 2, top = 2, bottom = 4}
}

RXPFrame.backdrop.bottom = {
    bgFile = "Interface/BUTTONS/WHITE8X8",
    tile = true,
    tileSize = 16
    --edgeSize = 1,
    --insets = {left = 0, right = 0, top = -1, bottom = -1}
}

function addon.SetupGuideWindow()
    -- These were in-line, but now rely on settings

    BottomFrame:SetBackdrop(RXPFrame.backdrop.edge)
    BottomFrame:SetBackdropColor(unpack(addon.colors.background))

    GuideName:SetBackdrop(RXPFrame.backdrop.guideName)
    GuideName:SetBackdropColor(unpack(addon.colors.background))

    addon.SetFontSafely(GuideName.text, addon.font, 11, "")
    GuideName.text:SetText(L(
                               "Welcome to RestedXP Guides\nRight click to pick a guide"))
    GuideName.text:SetTextColor(unpack(addon.activeTheme.textColor))

    addon.SetFontSafely(Footer.text, addon.font, 9, "")
    if addon.player.beta then
        Footer.text:SetText(fmt("%s %s", addon.title, addon.release))
    else
        Footer.text:SetText(fmt("RXP Beta %s %d/%d", addon.release, addon.minGuideVersion ,addon.maxGuideVersion))
    end
    Footer.text:SetTextColor(unpack(addon.activeTheme.textColor))

    GuideName.bg:SetTexture(addon.GetTexture("rxp-banner"))

    Footer:SetBackdrop(RXPFrame.backdrop.guideName)
    Footer:SetBackdropColor(unpack(addon.colors.background))
    Footer.bg:SetTexture(addon.GetTexture("rxp-banner"))

    GuideName.icon:SetTexture(addon.GetTexture("rxp_logo-64"))

    GuideName.classIcon:SetTexture(addon.GetTexture(class))
    Footer.cog:SetNormalTexture(addon.GetTexture("rxp_cog-32"))

    RXPFrame.UpdateScrollBar()

end

RXPFrame:SetScript("OnShow", addon.PLAYER_ENTERING_WORLD)
RXPFrame:SetScript("OnHide", addon.PLAYER_LEAVING_WORLD)

RXPFrame:Show()

RXPFrame:SetMovable(true)
RXPFrame:SetClampedToScreen(true)
RXPFrame:SetResizable(true)
addon.SetResizeBounds(RXPFrame, 220, 20)

local IsFrameShown = function(frame,step)
    step = step or (frame and frame.step)
    if not step then
        return true
    elseif step.hidewindow or step.hidetip then
        return false
    elseif step.optional and (frame and frame.bottom) then
        return false
    end
    return true
end

local function SetStepFrameAnchor()
    local frame = CurrentStepFrame
    local scale = RXPFrame:GetScale()
    -- local bars = RXPFrame.BarContainer
    local function SetTop()
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT", GuideName, "TOPLEFT", 0, 2)
        frame:SetPoint("BOTTOMRIGHT", GuideName, "TOPRIGHT", 0, 2)
        --[[if bars then
            bars:ClearAllPoints()
            bars:SetPoint("TOPLEFT",RXPFrame,"BOTTOMLEFT",7,-5)
            bars:SetPoint("TOPRIGHT",RXPFrame,"BOTTOMRIGHT",-7,-5)
        end]]
        frame.anchor = "TOP"
    end
    local function SetBottom()
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", RXPFrame, "BOTTOMLEFT", 3, 0)
        frame:SetPoint("TOPRIGHT", RXPFrame, "BOTTOMRIGHT", -3, 0)
        --[[if bars then
            bars:ClearAllPoints()
            bars:SetPoint("TOPLEFT",CurrentStepFrame,"BOTTOMLEFT",3,0)
            bars:SetPoint("TOPRIGHT",CurrentStepFrame,"BOTTOMRIGHT",-3,0)
        end]]
        frame.anchor = "BOTTOM"
    end

    if addon.settings.profile.anchorOrientation == "top" then
        SetTop()
        if (frame:GetTop() * scale > GetScreenHeight()) then SetBottom() end
        if frame:GetBottom() * scale < 0 then SetTop() end
    else
        SetBottom()
        if frame:GetBottom() * scale < 0 then SetTop() end
        if (frame:GetTop() * scale > GetScreenHeight()) then SetBottom() end
    end
    addon:SortTimers()

end

RXPFrame.SetStepFrameAnchor = SetStepFrameAnchor

local isResizing

RXPFrame.OnMouseDown = function(self, button, resize)
    if addon.settings.profile.lockFrames then return end

    if resize or IsAltKeyDown() and
        not (addon.currentGuide and addon.currentGuide.hidewindow) then
        RXPFrame:StartSizing("BOTTOMRIGHT")
        RXPFrame:SetScript("OnUpdate", RXPFrame.BottomFrame.UpdateFrame)
        isResizing = true
    else
        RXPFrame:StartMoving()
    end
end

RXPFrame.OnMouseUp = function(self, button)
    RXPFrame:StopMovingOrSizing()
    if isResizing then
        addon.settings.profile.frameHeight = RXPFrame:GetHeight()
        addon.SetStep(RXPCData.currentStep)
        RXPFrame:SetScript("OnUpdate", nil)
    end
    SetStepFrameAnchor()
    addon.UpdateItemFrame()
    isResizing = false
    addon.settings:SaveFramePositions()
end

RXPFrame:SetScript("OnMouseDown", RXPFrame.OnMouseDown)
RXPFrame:SetScript("OnMouseUp", RXPFrame.OnMouseUp)
RXPFrame:EnableMouse(1)

local stepPos = {}

local lastScrollValue
function BottomFrame:StepScroll(n)
    local value
    local step = addon.currentGuide.steps[n]
    if not step or not IsFrameShown(nil,step) then
         return
    end
    --[[for i, v in ipairs(BottomFrame.stepList) do
        if v == n then
            n = i
            break
        end
    end]]
    if n == 1 or not stepPos[n] then
        value = 0
    else
        value = stepPos[n] / stepPos[0] * ScrollChild.f1:GetHeight() - 2
        local smax = ScrollChild.f1:GetHeight() - BottomFrame:GetHeight() + 10
        if value > smax then value = smax end
    end
    ScrollFrame.ScrollBar:SetValue(value)

    value = math.floor(value+0.5)
    if value ~= lastScrollValue then
        addon.ScheduleTask(0,BottomFrame.StepScroll,n)
    end
    lastScrollValue = value
end

RXPFrame:SetWidth(addon.width)
RXPFrame:SetHeight(addon.height)
RXPFrame:SetPoint("LEFT", 0, 35)
RXPFrame:SetFrameStrata("BACKGROUND")

-- RXPFrame.CurrentStepFrame:SetBackdrop(backdrop)
-- RXPFrame.CurrentStepFrame:SetBackdropColor(0.3,0.01,0.01)
CurrentStepFrame:SetPoint("BOTTOMLEFT", GuideName, "TOPLEFT", 0, 2)
CurrentStepFrame:SetPoint("BOTTOMRIGHT", GuideName, "TOPRIGHT", 0, 2)

CurrentStepFrame:SetHeight(25)
CurrentStepFrame:SetScript("OnMouseDown", RXPFrame.OnMouseDown)
CurrentStepFrame:SetScript("OnMouseUp", RXPFrame.OnMouseUp)
CurrentStepFrame:EnableMouse(1)

local CheckStepCompletion = function(self,initialCheck)
    local stepCompleted = true
    for _,element in pairs(self.elements) do
        if initialCheck and element.container and element.container.callback then
            --print('ok1',GetTime())
            element.container:callback()
        end
        stepCompleted = stepCompleted and element.completed
    end
    self.completed = stepCompleted
end


local hiddenFramePool = {}

function addon.RegisterGeneratedSteps()
    local i = 1
    local stepUnitscan, stepMobs, stepTargets = {}, {}, {}
    local events, container

    for generatedKind, context in pairs(addon.generatedSteps) do
        for _, step in ipairs(context) do
            for _, element in ipairs(step.elements or {}) do
                if element.tag then
                    events = element.event or addon.functions.events[element.tag]
                    container = hiddenFramePool[i] or CreateFrame("Frame", nil, addon.RXPFrame)

                    hiddenFramePool[i] = container
                    i = i + 1

                    container:Show()
                    container.callback = addon.functions[element.tag]

                    if type(events) == "string" then
                        if events == "OnUpdate" then
                            container:SetScript("OnUpdate", container.callback)
                        else
                            container:RegisterEvent(events)
                            container:SetScript("OnEvent", CurrentStepFrame.EventHandler)
                        end
                    elseif type(events) == "table" then
                        for _, event in ipairs(events) do
                            if event == "OnUpdate" then
                                container:SetScript("OnUpdate", container.callback)
                            else
                                container:RegisterEvent(event)
                                container:SetScript("OnEvent", CurrentStepFrame.EventHandler)
                            end
                        end
                    end

                    container.element = element
                    element.container = container

                    -- Crudely disable until coordinate based proxmity is implemented
                    -- Otherwise Dangerous Mobs bloat Active Targets as a visual macro for all rares/mobs in a zone
                    if generatedKind ~= "dangerousMobs" then
                        if element.unitscan then
                            for _, t in ipairs(element.unitscan) do
                                tinsert(stepUnitscan, addon.GetCreatureName(t))
                            end
                        end

                        if element.mobs then
                            for _, t in ipairs(element.mobs) do
                                tinsert(stepMobs, addon.GetCreatureName(t))
                            end
                        end

                        if element.targets then
                            for _, t in ipairs(element.targets) do
                                tinsert(stepTargets, addon.GetCreatureName(t))
                            end
                        end
                    end
                end
            end
        end
    end

    addon.targeting:UpdateEnemyList(stepUnitscan, stepMobs, true)
    addon.targeting:UpdateTargetList(stepTargets, true)
    addon.targeting:UpdateUnitList()

    -- Don't process new targets if targeting disabled
    if addon.settings.profile.enableTargetAutomation then addon.targeting:CheckNameplates() end

    for j = i, #hiddenFramePool do
        container = hiddenFramePool[j]

        container:Hide()
        container:SetScript("OnUpdate", nil)
        container:SetScript("OnEvent", nil)

        container.element = nil
        container.callback = nil
    end

    addon:ScheduleTask(addon.ProcessGeneratedSteps, CheckStepCompletion, true)
    addon.UpdateMap()
end

function addon:ProcessGeneratedSteps(func, ...)
    if type(func) ~= "function" then func = nil end

    for _, context in pairs(addon.generatedSteps) do
        for _, step in ipairs(context) do
            if step.isActive then
                step.active = step:isActive()
                -- print(step,GetTime(),step.active)
            end

            if step.active and func then func(step, ...) end
        end
    end
end

function addon:ShowTips(state)
    if state == "toggle" then
        RXPCData.hideTipWindow = not RXPCData.hideTipWindow
    else
        RXPCData.hideTipWindow = not state
    end
    addon.updateSteps = true
    addon:ScheduleTask(addon.RXPFrame.GenerateMenuTable)
end

local tipMenu = {{
        notCheckable = 1,
        text = L("Hide tips"),
        func = addon.ShowTips,
        arg1 = false
    }}
local TipWindowMouseDown = function(self,button)
    if self.step and self.step.tip then
        if (button == "RightButton") then
            if _G.EasyMenu then
                _G.EasyMenu(tipMenu, MenuFrame, "cursor", 0, 0, "MENU");
            else
                LibDD:EasyMenu(tipMenu, MenuFrame, "cursor", 0, 0, "MENU");
            end
        else
            self:StartMoving()
        end
    end
end
local TipWindowMouseUp = function(self)
    if self.step and self.step.tip then
        self:StopMovingOrSizing()
        local point = {self:GetPoint()}
        point[2] = nil
        RXPCData.tipWindow = point
        addon.settings:SaveFramePositions()
    end
end

CurrentStepFrame.framePool = {}

local function ClearFrameData()

    for i, stepframe in ipairs(CurrentStepFrame.framePool) do
        -- frame:SetHeight(0)
        stepframe:Hide()
        stepframe:SetScript("OnUpdate", nil)
        stepframe:SetScript("OnEvent", nil)
        stepframe:UnregisterAllEvents()
        stepframe.callback = nil
        if stepframe.step then
            stepframe.step.frame = nil
            stepframe.step.active = nil
            stepframe.step = nil
            stepframe.sticky = nil
            stepframe.index = nil
        end
        for j, frame in ipairs(stepframe.elements) do
            -- element:SetHeight(0)
            if frame.step then
                if not frame.step.sticky then
                    frame.element.completed = nil
                end
                frame.element.frame = nil
                frame.element.skip = nil
            end
            frame.step = nil
            frame.index = nil
            frame.element = nil
            frame.callback = nil
            frame:Hide()
            frame:UnregisterAllEvents()
            frame:SetScript("OnUpdate", nil)
            frame:SetScript("OnEvent", nil)
            frame:SetScript("OnEnter", nil)
            frame:SetScript("OnLeave", nil)
            frame:SetScript("OnMouseDown", nil)
            frame:SetMouseClickEnabled(false)
            frame.button:SetChecked(false)
            frame.highlight:Hide()
        end
    end
end

local activeSteps = {}
RXPFrame.activeSteps = activeSteps

-- Keep step progress visually readable on every guide without requiring guide
-- authors to add presentation directives.  The full guide list can infer
-- completed sequential steps from currentStep, while sticky steps remain blue
-- until their own objectives are finished.
local stepVisuals = {
    current = {
        background = {0.38, 0.29, 0.02, 0.95},
        text = {1.00, 0.91, 0.30},
    },
    completed = {
        background = {0.03, 0.27, 0.10, 0.90},
        text = {0.58, 1.00, 0.66},
    },
    sticky = {
        background = {0.03, 0.19, 0.34, 0.92},
        text = {0.55, 0.84, 1.00},
    },
    skipped = {
        text = {0.68, 0.68, 0.68},
    },
}

local function GetStepVisualState(step)
    if not step then return "upcoming" end
    local index = step.index
    local currentStep = RXPCData and RXPCData.currentStep
    local skipped = RXPCData and RXPCData.stepSkip and index and
                        RXPCData.stepSkip[index]

    if skipped then return "skipped" end
    if step.completed then return "completed" end
    if step.sticky and step.active then return "sticky" end
    if index and currentStep and index < currentStep and not step.sticky then
        return "completed"
    end
    if index and currentStep and index == currentStep then return "current" end
    return "upcoming"
end

local function ApplyStepVisualState(frame, step, bottom)
    if not frame then return end
    local state = GetStepVisualState(step)
    local visuals = addon.accessibility and
                        addon.accessibility:GetStepVisuals() or stepVisuals
    local visual = visuals[state]
    local background = visual and visual.background or
                           (bottom and addon.colors.bottomFrameBG or
                               addon.colors.background)
    local textColor = visual and visual.text or addon.activeTheme.textColor

    frame.stepVisualState = state
    frame.stepVisualBackground = background
    frame:SetBackdropColor(unpack(background))
    if frame.number and not bottom then
        frame.number:SetBackdropColor(unpack(background))
    end
    if frame.number and frame.number.text then
        frame.number.text:SetTextColor(unpack(textColor))
        if addon.accessibility then
            addon.accessibility:ApplyStepNumber(frame.number, step, state)
        end
    end
    if bottom and frame.text then
        frame.text:SetTextColor(unpack(textColor))
    end
end

local function ApplyElementVisualState(elementFrame, element, step)
    if not (elementFrame and elementFrame.text) then return end
    local color = addon.activeTheme.textColor
    if element and not element.textOnly then
        if element.completed then
            local visuals = addon.accessibility and
                                addon.accessibility:GetStepVisuals() or
                                stepVisuals
            color = visuals.completed.text
        elseif element.skip then
            local visuals = addon.accessibility and
                                addon.accessibility:GetStepVisuals() or
                                stepVisuals
            color = visuals.skipped.text
        elseif GetStepVisualState(step) == "current" then
            local visuals = addon.accessibility and
                                addon.accessibility:GetStepVisuals() or
                                stepVisuals
            color = visuals.current.text
        elseif GetStepVisualState(step) == "sticky" then
            local visuals = addon.accessibility and
                                addon.accessibility:GetStepVisuals() or
                                stepVisuals
            color = visuals.sticky.text
        end
    end
    elementFrame.text:SetTextColor(unpack(color))
end

function addon.UpdateStepCompletion()
    addon.updateSteps = false
    if addon.currentGuide.empty then return end

    addon:ScheduleTask(addon.ProcessGeneratedSteps,CheckStepCompletion)

    local update

    for i, step in ipairs(activeSteps) do
        local completed = true
        if not (step.completed or step.tip) then
            for j, element in ipairs(step.elements) do
                if not (element.completed or element.skip or element.textOnly) then
                    completed = false
                    break
                end
            end
        end

        local c
        local completewith = step.completewith
        if completewith and (not completed or step.tip) then
            local guide = addon.currentGuide
            if completewith == "next" then
                completewith = step.index and (step.index + 1)
            else
                completewith = guide.labels[completewith]
            end
            if completewith then
                if guide.steps[completewith] and
                    guide.steps[completewith].sticky then
                    if RXPCData.stepSkip[completewith] then
                        completed = true
                        c = true
                    end
                else
                    if RXPCData.currentStep > completewith then
                        completed = true
                        c = true
                    end
                end
            end
        end


        if step.tip then
            c = c or RXPCData.hideTipWindow
            if step.hidetip ~= c then
                update = true
            end
            step.hidetip = c
            step.active = not c
        elseif completed and step.index then
            if step.active and GetTime() - addon.lastStepUpdate > 1 then
                addon:QueueMessage("RXP_STEP_COMPLETE",step,addon.currentGuide)
            end
            if step.sticky then
                RXPCData.stepSkip[step.index] = true
                update = true
                step.active = nil
            elseif step.index >= RXPCData.currentStep then
                step.completed = true
                RXPFrame.BottomFrame.UpdateFrame(nil, nil, step.index)
                if step.index == RXPCData.currentStep then
                    addon.loadNextStep = true
                end
                return
            end
        end
    end

    if update then return addon.SetStep(RXPCData.currentStep) end
end

function addon.SetStep(n, n2, loopback)
    if type(n) == "table" then n = n2 end
    local guide = addon.currentGuide
    if not guide then return end
    local group = guide.group

    addon.lastStepUpdate = GetTime()

    -- print(n)
    if n > #guide.steps then
        if guide.loop then
            if loopback then
                return
            else
                return addon.SetStep(1, nil, true)
            end
        end
        local isComplete = true
        --local completedStep
        for i, step in ipairs(activeSteps) do
            if step.sticky and not RXPCData.stepSkip[i] then
                isComplete = false
            end
        end
        if isComplete then
            return addon.functions.next()
        else
            n = #guide.steps
        end
    end
    RXPCData.currentStep = n
    RXPCData.currentStepId = guide.steps[n].stepId
    if addon.guideState and addon.guideState.SaveCurrent then
        addon.guideState:SaveCurrent()
    end
    -- isUpdating = true

    if not guide.steps[n].active then
        local step = guide.steps[n]
        for _, element in ipairs(step) do
            if element.OnStepActivation then
                element:OnStepActivation()
            end
        end
        local trackId = tonumber(step.track)
        if C_SuperTrack and trackId then
            C_SuperTrack.SetSuperTrackedQuestID(trackId)
        end
        addon:SendEvent("RXP_STEP_ACTIVATED",step,guide)
    end

    RXPCData.stepSkip[n + 1] = nil

    if guide.steps[n].sticky and n < #guide.steps then
        return addon.SetStep(n + 1)
    end

    local previousSteps = {}
    for i, step in ipairs(activeSteps) do
        step.active = nil
        tinsert(previousSteps,step)
        if n < #guide.steps then step.completed = nil end
    end

    addon:ScheduleTask(addon.RegisterGeneratedSteps)
    table.wipe(activeSteps)
    table.wipe(addon.questAccept)
    table.wipe(addon.questTurnIn)
    table.wipe(addon.activeItems)
    table.wipe(addon.activeSpells)
    table.wipe(addon.activeMacros)
    table.wipe(addon.inventoryManager.itemsToOpen)
    ClearFrameData()
    local level = UnitLevel("player")
    local scrollHeight = 1
    local activeTargets = {}

    for i = 1, n - 1 do
        local step = guide.steps[i]
        if step.sticky then
            local req = guide.labels[step.requires]
            if step.requires and req then
                local requiredSteps = {}
                req = guide.steps[req]
                while req and req.requires and not RXPCData.stepSkip[req.index] and
                    not req.active do
                    if requiredSteps[req] then
                        addon.comms.PrettyPrint('ERROR: Step requirement loop at steps %d and %d',
                              step.index or 0, req.index or 0)
                        break
                    end
                    requiredSteps[req] = true
                    req = guide.steps[guide.labels[req.requires]]
                end
            end
            step.reqFulfilled = not (req and
                                    (req.active or
                                        (req.sticky and
                                            not RXPCData.stepSkip[req.index])))
            if not RXPCData.stepSkip[i] and step.reqFulfilled and level >=
                step.level then
                tinsert(activeSteps, step)
                if n > 1 then scrollHeight = n - 1 end
                -- ScrollChild.framePool[i]:SetAlpha(0.66)
                step.active = true
            end
        end
    end

    local lastTip = addon.currentTip
    local step = guide.steps[n]
    local req = step.requires and guide.labels[step.requires] and
                    guide.steps[guide.labels[step.requires]]
    if step.completed and n < #guide.steps then
        return addon.SetStep(n + 1)
    elseif step and not step.completed and
        not (req and #activeSteps > 0 and (req.active or not (req.reqFulfilled))) and
        level >= step.level then
        step.completed = false
        addon.settings.ReplaceColors(step)
        tinsert(activeSteps, step)
        ScrollChild.framePool[n]:SetAlpha(1)
        step.active = true
        scrollHeight = n
        if step.tipWindow then
            step.tipWindow.completed = false
            tinsert(activeSteps,step.tipWindow)
            step.tipWindow.active = true
        end
    end

    if #activeSteps == 0 then
        if n >= #guide.steps then
            return addon.functions.next()
        else
            return addon.SetStep(n + 1)
        end
    end

    for _,prevstep in pairs(previousSteps) do
        if not prevstep.active then
            addon:SendEvent("RXP_STEP_DEACTIVATED",prevstep,guide)
        end
    end

    --local totalHeight = 0
    local c = 0
    local anchor = 0
    --local heightDiff = RXPFrame:GetHeight() - CurrentStepFrame:GetHeight()
    local stepUnitscan = {}
    local stepMobs = {}
    local stepTargets = {}
    for i, step in ipairs(activeSteps) do

        local index = step.index
        c = c + 1
        local stepframe = CurrentStepFrame.framePool[c]
        if not stepframe then
            CurrentStepFrame.framePool[c] =
                CreateFrame("Frame", "$parent_frame" .. c, CurrentStepFrame,
                            BackdropTemplate)
            stepframe = CurrentStepFrame.framePool[c]
            -- stepframe:SetBackdropBorderColor(0.1,0.5,0.1)
            stepframe.elements = {}

            -- addon.CreateActiveItemFrame(stepframe)
        end
        if step.tip then
            --stepframe:SetParent(UIParent)
            stepframe:ClearAllPoints()
            local pos = RXPCData.tipWindow
            stepframe:SetFrameStrata("MEDIUM")
            if pos then
                stepframe:SetPoint(pos[1], UIParent, pos[3], pos[4], pos[5])
            else
                stepframe:SetPoint("BOTTOMLEFT", UIParent, 0, 0)
            end
            --TODO: Save window position
            stepframe:SetWidth(200)
            stepframe:SetMovable(true)
            stepframe:EnableMouse(true)
            stepframe:SetClampedToScreen(true)
            --stepframe:SetPoint("TOPRIGHT", CurrentStepFrame, 0, 0)
            anchor = c - 1
            stepframe:SetScript("OnMouseDown",TipWindowMouseDown)
            stepframe:SetScript("OnMouseUp",TipWindowMouseUp)
            addon.currentTip = step
        else
            stepframe:SetFrameStrata(RXPFrame:GetFrameStrata())
            stepframe:ClearAllPoints()
            stepframe:SetScript("OnMouseDown",nil)
            stepframe:SetScript("OnMouseUp",nil)
            if anchor < 1 then
                stepframe:SetPoint("TOPLEFT", CurrentStepFrame, 0, 0)
                stepframe:SetPoint("TOPRIGHT", CurrentStepFrame, 0, 0)
            else
                stepframe:SetPoint("TOPLEFT", CurrentStepFrame.framePool[anchor],
                                "BOTTOMLEFT", 0, -5)
                stepframe:SetPoint("TOPRIGHT", CurrentStepFrame.framePool[anchor],
                                "BOTTOMRIGHT", 0, -5)
            end
            anchor = c
            stepframe:SetMovable(false)
        end
        if not stepframe.number then
            stepframe.number = CreateFrame("Frame", "$parent_number", stepframe,
                                           BackdropTemplate)
            stepframe.number:SetPoint("TOPLEFT", stepframe, 7, 5)
            stepframe.number.text = stepframe.number:CreateFontString(nil,
                                                                      "OVERLAY")
            -- stepframe.number.text:SetFontObject(GameFontNormalSmall)
            stepframe.number.text:ClearAllPoints()
            stepframe.number.text:SetPoint("CENTER", stepframe.number, 2, 1)
            stepframe.number.text:SetJustifyH("CENTER")
            stepframe.number.text:SetJustifyV("MIDDLE")
            stepframe.number.text:SetTextColor(
                unpack(addon.activeTheme.textColor))
            stepframe.number.text:SetFont(addon.font, addon.settings.profile
                                              .guideFontSize, "")
        end
        if stepframe.theme ~= addon.activeTheme then
            stepframe.theme = addon.activeTheme
            stepframe:ClearBackdrop()
            stepframe:SetBackdrop(RXPFrame.backdrop.edge)
            stepframe:SetBackdropColor(unpack(addon.colors.background))
            stepframe.number:ClearBackdrop()
            stepframe.number:SetBackdrop(RXPFrame.backdrop.edge)
            stepframe.number:SetBackdropColor(unpack(addon.colors.background))
        end

        local titletext
        if step.sticky then
            titletext = step.title or ""
        else
            titletext = step.title or (fmt(L("Step %d"), index))
        end

        if titletext == "" then
            stepframe.number:SetAlpha(0)
            stepframe.number:SetSize(10, 17)
        else
            stepframe.number:SetAlpha(1)
            stepframe.number.text:SetText(titletext)
            stepframe.number:SetSize(
                stepframe.number.text:GetStringWidth() + 10,
                math.max(17, addon.settings.profile.guideFontSize + 8))
        end

        stepframe.step = step
        stepframe.index = index
        stepframe.sticky = step.sticky
        ApplyStepVisualState(stepframe, step, false)

        local e = 0
        local frameHeight = 0
        for j, element in ipairs(step.elements or {}) do
            e = j
            local elementFrame = stepframe.elements[e]
            if not stepframe.elements[e] then
                stepframe.elements[e] = CreateFrame("Frame", "$parent_" .. e,
                                                    stepframe, nil)
                elementFrame = stepframe.elements[e]
                -- elementFrame:SetHeight(0)
                -- elementFrame:SetWidth(300)
                local button = CreateFrame("CheckButton", "$parentCheck",
                                           elementFrame,
                                           "ChatConfigCheckButtonTemplate");
                elementFrame.button = button
                button:SetSize(12, 12)
                button:SetScript("PostClick", function(self)
                    local parent = self:GetParent()
                    local element = parent.element
                    if element and not element.optional then
                        local skip = self:GetChecked()
                        if element.OnComplete and skip and not element.skip then
                            element.OnComplete(element)
                        end
                        element.skip = skip

                    end
                    addon.updateSteps = true
                    addon.UpdateMap()
                end)

                --
                button:SetPushedTexture("")
                button:SetHighlightTexture(
                    "Interface/MINIMAP/UI-Minimap-ZoomButton-Highlight", "ADD")

                elementFrame.text = getglobal(
                                        elementFrame.button:GetName() .. 'Text')
                elementFrame.text:SetParent(elementFrame)

                elementFrame.text:SetJustifyH("LEFT")
                elementFrame.text:SetJustifyV("MIDDLE")
                elementFrame.text:SetTextColor(
                    unpack(addon.activeTheme.textColor))

                elementFrame.text:SetFont(addon.font, addon.settings.profile
                                              .guideFontSize + 2, "") -- 11

                elementFrame.icon =
                    elementFrame:CreateFontString(nil, "OVERLAY")
                elementFrame.icon:SetFontObject(_G.GameFontNormalSmall)

                elementFrame:SetMouseMotionEnabled(true)
                local ht = elementFrame:CreateTexture(nil, "HIGHLIGHT")
                ht:SetAllPoints(elementFrame.text)
                ht:SetTexture("Interface\\Worldmap\\UI-QuestPoi-HighlightBar")
                ht:SetBlendMode("ADD")
                ht:Hide()
                elementFrame.highlight = ht

                local function tpOnEnter(self)
                    if self:IsForbidden() or _G.GameTooltip:IsForbidden() then
                        return
                    end
                    local element = self.element or self:GetParent().element
                    if element and element.tooltip then
                        _G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
                        _G.GameTooltip:ClearLines()
                        _G.GameTooltip:AddLine(element.tooltip, 1, 1, 1)
                        _G.GameTooltip:Show()
                    end
                end

                local function tpOnLeave(self)
                    if self:IsForbidden() or _G.GameTooltip:IsForbidden() then
                        return
                    end
                    local element = self.element or self:GetParent().element
                    if element and element.tooltip then
                        _G.GameTooltip:Hide()
                    end
                end

                elementFrame:SetScript("OnEnter", tpOnEnter)
                elementFrame:SetScript("OnLeave", tpOnLeave)

                elementFrame.button:HookScript("OnEnter", tpOnEnter)
                elementFrame.button:HookScript("OnLeave", tpOnLeave)
            end
            if elementFrame.button.theme ~= addon.activeTheme then
                elementFrame.button.theme = addon.activeTheme
                elementFrame.button:SetNormalTexture(addon.GetTexture(
                                                         "rxp-btn-blank-32"))
                elementFrame.button:SetCheckedTexture(addon.GetTexture(
                                                          "rxp-checked-32"))
                elementFrame.button:SetDisabledCheckedTexture(addon.GetTexture(
                                                                  "rxp-checked-32"))
            end
            elementFrame.step = step
            elementFrame.element = element
            elementFrame.index = index
            element.frame = elementFrame
            elementFrame.button:Enable()
            if element.tag then
                local events = element.event or addon.functions.events[element.tag]
                elementFrame.callback = addon.functions[element.tag]
                addon.Call(element.tag,elementFrame.callback,elementFrame)
                if type(events) == "string" then
                    if events == "OnUpdate" then
                        elementFrame:SetScript("OnUpdate", elementFrame.callback)
                    else
                        elementFrame:RegisterEvent(events)
                        elementFrame:SetScript("OnEvent",
                                               CurrentStepFrame.EventHandler)
                    end
                elseif type(events) == "table" then
                    for _, event in ipairs(events) do
                        if event == "OnUpdate" then
                            elementFrame:SetScript("OnUpdate",
                                                   elementFrame.callback)
                        else
                            elementFrame:RegisterEvent(event)
                            elementFrame:SetScript("OnEvent",
                                                   CurrentStepFrame.EventHandler)
                        end
                    end
                end
            end

            if element.unitscan then
                for _, t in ipairs(element.unitscan) do
                    if not activeTargets[t] then
                        activeTargets[t] = true
                        tinsert(stepUnitscan, addon.GetCreatureName(t))
                    end
                end
            end
            if element.mobs then
                for _, t in ipairs(element.mobs) do
                    if not activeTargets[t] then
                        activeTargets[t] = true
                        tinsert(stepMobs, addon.GetCreatureName(t))
                    end
                end
            end
            if element.targets then
                for _, t in ipairs(element.targets) do
                    if not activeTargets[t] then
                        activeTargets[t] = true
                        tinsert(stepTargets, addon.GetCreatureName(t))
                    end
                end
            end

            --local spacing = 0

        end
        for n = e + 1, #stepframe.elements do
            stepframe.elements[n]:Hide()
        end
        if step.active then
            stepframe:Show()
            if step.activeItems then
                for k, v in pairs(step.activeItems) do
                    addon.activeItems[k] = v
                end
            end
            if step.activeSpells then
                for k, v in pairs(step.activeSpells) do
                    addon.activeSpells[k] = v
                end
            end
            if step.activeMacros then
                for k, v in pairs(step.activeMacros) do
                    addon.activeMacros[k] = v
                end
            end
        else
            stepframe:Hide()
        end
    end

    -- Update targets for macro
    addon.targeting:UpdateEnemyList(stepUnitscan, stepMobs)
    addon.targeting:UpdateTargetList(stepTargets)

    -- Don't process new targets if targeting disabled
    if addon.settings.profile.enableTargetAutomation then
        addon.targeting:CheckNameplates()
    end

    addon:QueueMessage("RXP_TARGET_LIST_UPDATE",stepUnitscan,stepMobs,stepTargets)

    for index in pairs(RXPCData.completedWaypoints) do
        local wstep
        if index == "tip" and lastTip ~= addon.currentTip then
            wstep = lastTip
        else
            wstep = guide.steps[index]
        end
        if not (wstep and wstep.active) then
            -- print('kk',index)
            RXPCData.completedWaypoints[index] = nil
        end
    end
    addon.UpdateItemFrame()
    CurrentStepFrame.UpdateText()
    addon.updateSteps = true
    addon.UpdateMap()
    BottomFrame:StepScroll(scrollHeight)
end

-- Explicit "jump to step" for manual navigation. SetStep auto-advances past any
-- step still flagged completed (so a plain SetStep to an already-done earlier step
-- bounces forward). Clearing the target's completion first makes the jump land on
-- it. Used by the /rxp step|next|prev commands and the right-click "Go to step".
function addon.GoToStep(n, n2)
    -- Dropdown-menu callbacks pass the button as the first arg (like SetStep).
    if type(n) == "table" then n = n2 end
    local guide = addon.currentGuide
    if not guide or not guide.steps or type(n) ~= "number" then return end
    if n < 1 then n = 1 elseif n > #guide.steps then n = #guide.steps end
    if guide.steps[n] then guide.steps[n].completed = nil end
    return addon.SetStep(n)
end

-- Expose step navigation on the public API table so a simple macro works, e.g.
-- /run RXPGuides.GoToStep(RXPCData.currentStep + 1). (These live on the internal
-- AceAddon object, which is not otherwise reachable from a macro.)
if _G.RXPGuides then
    _G.RXPGuides.SetStep = addon.SetStep
    _G.RXPGuides.GoToStep = addon.GoToStep
end

function CurrentStepFrame.EventHandler(self, event, ...)
    --print(event,self.index,self.element.tag)
    if addon.isHidden then
        return
    elseif self.callback and self.step and self.step.active then
        --print(self.callback,self.element.tag)
        addon.Call(self.element.tag,self.callback,self, event, ...)
        --self.callback(self, event, ...)
    else
        --[[if addon.settings.profile.debug then
            print('!!!') -- ok
        end]]
        self.callback = nil
        self:UnregisterEvent(event)
    end
end

function CurrentStepFrame.UpdateText()
    addon.updateStepText = false
    local guide = addon.currentGuide
    if not guide then return end

    -- StepScroll(n)
    local totalHeight, frameHeight = 0, 0
    local c, e, h, spacing = 0, 0, 0, 0
    local anchor = 0
    -- local heightDiff = RXPFrame:GetHeight() - CurrentStepFrame:GetHeight()
    local loopStepIndex, stepframe, elementFrame, icon

    for _, step in ipairs(activeSteps) do

        loopStepIndex = step.index
        c = c + 1
        stepframe = CurrentStepFrame.framePool[c]

        if stepframe then
            ApplyStepVisualState(stepframe, step, false)
            if not step.tip then
                stepframe:ClearAllPoints()

                if anchor < 1 then
                    stepframe:SetPoint("TOPLEFT", CurrentStepFrame, 0, 0)
                    stepframe:SetPoint("TOPRIGHT", CurrentStepFrame, 0, 0)
                else
                    stepframe:SetPoint("TOPLEFT", CurrentStepFrame.framePool[anchor],
                                    "BOTTOMLEFT", 0, -5)
                    stepframe:SetPoint("TOPRIGHT", CurrentStepFrame.framePool[anchor],
                                    "BOTTOMRIGHT", 0, -5)
                end

                stepframe:SetMovable(false)
                anchor = c
            end

            stepframe.number.text:SetText(step.title or
                                            (fmt(L("Step %d"), loopStepIndex)))
            stepframe.number:SetSize(stepframe.number.text:GetStringWidth() + 10, 17)

            e = 0
            frameHeight = 0
            for j, element in ipairs(step.elements or {}) do
                e = j
                elementFrame = stepframe.elements[e]

                if elementFrame then
                    elementFrame:Show()

                    spacing = 0
                    if not IsFrameShown(elementFrame,step) then
                        elementFrame:SetAlpha(0)
                        elementFrame.button:Hide()
                        elementFrame:SetHeight(1)
                        spacing = 1
                    elseif element.text then
                        elementFrame:SetAlpha(1)

                        elementFrame.button:ClearAllPoints()
                        elementFrame.button:SetPoint("TOPLEFT", elementFrame, 6, -1)

                        elementFrame.text:ClearAllPoints()
                        elementFrame.text:SetPoint("TOPLEFT", elementFrame.button,
                                                "TOPRIGHT", 11, -1)
                        elementFrame.text:SetPoint("RIGHT", stepframe, -5, 0)

                         -- Prevent text from overwritten with " ", could be stale text
                        if element.text ~= ' ' then
                            elementFrame.text:SetText(addon.ReplaceNpcIds(L(element.text)))
                        else
                            element.requestFromServer = true
                        end

                        h = math.ceil(elementFrame.text:GetStringHeight() *
                                                1.1) + 1
                        -- print('sh:',h)
                        elementFrame:SetHeight(h)
                        frameHeight = frameHeight + h

                        -- local diffx,diffy = elementFrame.text:GetWidth() - GuideName:GetWidth(),elementFrame.text:GetHeight() - GuideName:GetHeight()
                        if elementFrame.text:GetWidth() > GuideName:GetWidth() + 600 then
                            elementFrame:EnableMouse(false)
                            elementFrame.button:EnableMouse(false)
                        else
                            elementFrame:EnableMouse(true)
                            elementFrame.button:EnableMouse(true)
                        end

                        elementFrame.icon:ClearAllPoints()
                        elementFrame.icon:SetPoint("TOPLEFT", elementFrame.button,
                                                "TOPRIGHT", 0, -1)

                        if element.textOnly then
                            elementFrame.button:SetChecked(true)
                            elementFrame.button:Hide()
                            element.completed = true
                        else
                            elementFrame.button:Show()
                        end

                        ApplyElementVisualState(elementFrame, element, step)

                    else
                        elementFrame:SetAlpha(0)
                        elementFrame.button:Hide()
                        elementFrame:SetHeight(1)
                        element.completed = true
                        spacing = 1
                    end

                    elementFrame:ClearAllPoints()

                    if e == 1 then
                        elementFrame:SetPoint("TOPLEFT", stepframe, 0, -10 + spacing)
                        elementFrame:SetPoint("TOPRIGHT", stepframe, 0,
                                            -10 + spacing)
                    else
                        elementFrame:SetPoint("TOPLEFT", stepframe.elements[e - 1],
                                            "BOTTOMLEFT", 0, 0 + spacing)
                        elementFrame:SetPoint("TOPRIGHT", stepframe.elements[e - 1],
                                            "BOTTOMRIGHT", 0, 0 + spacing)
                    end

                    if element.tag and element.text then
                        icon = element.icon or addon.icons[element.tag] or ""
                        elementFrame.icon:SetText(icon)
                        elementFrame.icon:Show()
                    else
                        elementFrame.icon:Hide()
                    end

                end

            end

            if not IsFrameShown(stepframe,step) then
                stepframe:SetAlpha(0)
                frameHeight = 1
                stepframe:EnableMouse(false)
            else
                if stepframe:GetWidth() > GuideName:GetWidth() + 600 then
                    stepframe:EnableMouse(false)
                else
                    stepframe:EnableMouse(true)
                end
                stepframe:SetAlpha(1)
                frameHeight = math.ceil(frameHeight + 18)
            end

            stepframe:SetHeight(frameHeight)

            if step.tip then
                frameHeight = -5
            end

            totalHeight = totalHeight + frameHeight + 5
        end
    end

    -- SetStep rebuilds the compact cards immediately, but the scrollable guide
    -- list may otherwise wait for its next periodic text refresh.  Repaint its
    -- state here so the old/current rows change from yellow to green without a
    -- visible delay.
    for _, frame in ipairs(ScrollChild.framePool or {}) do
        if frame:IsShown() and frame.step then
            ApplyStepVisualState(frame, frame.step, true)
        end
    end

    CurrentStepFrame:SetHeight(totalHeight - 5)
end

BottomFrame:SetPoint("TOPLEFT", RXPFrame, 3, -3)
BottomFrame:SetPoint("BOTTOMRIGHT", RXPFrame, -3, 14)

-- GuideName:SetBackdropColor(unpack(addon.colors.background))
GuideName:SetPoint("BOTTOMLEFT", BottomFrame, "TOPLEFT", 0, -9)
GuideName:SetPoint("BOTTOMRIGHT", BottomFrame, "TOPRIGHT", 0, -9)
GuideName:SetHeight(35)
GuideName.text = GuideName:CreateFontString(nil, "OVERLAY")
-- GuideName.text:SetFontObject(GameFontNormalSmall)
GuideName.text:ClearAllPoints()
GuideName.text:SetPoint("LEFT", GuideName, 29, 0)
GuideName.text:SetPoint("RIGHT", GuideName, 0, 0)
GuideName.text:SetJustifyH("CENTER")
GuideName.text:SetJustifyV("MIDDLE")

GuideName:SetFrameLevel(6)

GuideName.bg = GuideName:CreateTexture("$parentBG", "BACKGROUND")

GuideName.bg:SetPoint("TOPLEFT", 4, -2)
GuideName.bg:SetPoint("BOTTOMRIGHT", -2, 4)

-- footer
-- Footer:SetBackdrop(RXPFrame.backdrop.edge)
Footer:SetPoint("BOTTOMLEFT", RXPFrame, "BOTTOMLEFT", 3, 0)
Footer:SetPoint("BOTTOMRIGHT", RXPFrame, "BOTTOMRIGHT", -3, 0)
Footer:SetHeight(20)
Footer.text = GuideName:CreateFontString(nil, "OVERLAY")
-- GuideName.text:SetFontObject(GameFontNormalSmall)
Footer.text:ClearAllPoints()
Footer.text:SetPoint("LEFT", Footer, 40, 1)
Footer.text:SetPoint("RIGHT", Footer, -16, 1)
Footer.text:SetJustifyH("LEFT")
Footer.text:SetJustifyV("MIDDLE")

Footer:SetFrameLevel(6)
Footer.bg = Footer:CreateTexture("$parentBG", "BACKGROUND")

Footer.bg:SetPoint("TOPLEFT", 4, -2)
Footer.bg:SetPoint("BOTTOMRIGHT", -2, 4)

Footer.icon = CreateFrame("Button", "$parentResize", Footer)
Footer.icon:SetFrameLevel(Footer:GetFrameLevel() + 1)
Footer.icon:SetSize(16, 16)
Footer.icon:SetPoint("BOTTOMRIGHT", Footer, "BOTTOMRIGHT", -1, 3)

Footer.icon:SetNormalTexture("Interface/CHATFRAME/UI-ChatIM-SizeGrabber-Up")
Footer.icon:SetHighlightTexture(
    "Interface/CHATFRAME/UI-ChatIM-SizeGrabber-Highlight", "ADD")
Footer.icon:SetScript("OnMouseDown", function(self, button)
    RXPFrame.OnMouseDown(self, button, true)
end)
Footer.icon:SetScript("OnMouseUp", RXPFrame.OnMouseUp)

-- addon.StartTimer(duration,label)

GuideName.icon = GuideName:CreateTexture("RXPIcon", "ARTWORK")

GuideName.icon:SetPoint("CENTER", GuideName, "LEFT", 16, 0)
GuideName.icon:SetSize(42, 42)

GuideName.classIcon = GuideName:CreateTexture("RXPClassIcon", "OVERLAY")

GuideName.classIcon:SetPoint("CENTER", GuideName.icon, "BOTTOMRIGHT", -4, 10)
GuideName.classIcon:SetSize(24, 24)

Footer.cog = CreateFrame("Button", "$parentCogwheel", RXPFrame)
Footer.cog:SetFrameLevel(GuideName:GetFrameLevel() + 1)
Footer.cog:SetWidth(18)
Footer.cog:SetHeight(18)
Footer.cog:SetPoint("LEFT", Footer, "LEFT", 1, 1)
-- Footer.cog:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
Footer.cog:SetHighlightTexture(
    "Interface/MINIMAP/UI-Minimap-ZoomButton-Highlight", "ADD")
Footer.cog:Show()
Footer.cog:SetScript("OnClick", function(self) RXPFrame.DropDownMenu() end)
-- local buttonToggle = 0
-- Footer.cog:HookScript("OnEnter", function(self) buttonToggle = GetTime() end)
-- Footer.cog:HookScript("OnLeave", function(self) self:Hide() end)

function RXPFrame.DropDownMenu()
    if _G.EasyMenu then
        _G.EasyMenu(RXPFrame.menuList, MenuFrame, "cursor", 0, 0, "MENU");
    else
        LibDD:EasyMenu(RXPFrame.menuList, MenuFrame, "cursor", 0, 0, "MENU");
    end
end

GuideName.OnMouseDown = function(self, button)
    if button == "RightButton" then
        RXPFrame.DropDownMenu()
    else
        RXPFrame.OnMouseDown(self, button)
    end
end
GuideName.OnMouseUp = function(self, button)
    if button ~= "RightButton" then RXPFrame.OnMouseUp(self, button) end
end
GuideName:SetScript("OnMouseDown", GuideName.OnMouseDown)
Footer:SetScript("OnMouseDown", GuideName.OnMouseDown)

GuideName:SetScript("OnMouseUp", GuideName.OnMouseUp)
Footer:SetScript("OnMouseUp", GuideName.OnMouseUp)

--[[GuideName:SetScript("OnEnter", function() Footer.cog:Show() end)
GuideName:SetScript("OnLeave", function()
    if GetTime() - buttonToggle > 0.1 then Footer.cog:Hide() end
end)]]

ScrollFrame:SetPoint("TOPLEFT", BottomFrame, 5, -5)
ScrollFrame:SetPoint("BOTTOMRIGHT", BottomFrame, -20, 7)
ScrollFrame.ScrollBar:SetPoint("TOPLEFT", ScrollFrame, "TOPRIGHT", 0, -18)

function RXPFrame.UpdateScrollBar()
    local prefix = addon.GetTexture("Scrollbar/")

    local s = ScrollFrame.ScrollBar.ScrollDownButton
    s.Normal:SetTexture(prefix .. "Down-Normal")
    s.Highlight:SetTexture(prefix .. "Down-Highlight") -- ?
    s.Pushed:SetTexture(prefix .. "Down-Pushed")
    s.Disabled:SetTexture(prefix .. "Down-Disabled")
    s = ScrollFrame.ScrollBar.ScrollUpButton
    s.Normal:SetTexture(prefix .. "Up-Normal")
    s.Highlight:SetTexture(prefix .. "Up-Highlight")
    s.Pushed:SetTexture(prefix .. "Up-Pushed")
    s.Disabled:SetTexture(prefix .. "Up-Disabled")
    ScrollFrame.ScrollBar:SetThumbTexture(prefix .. "Knob")
end

hooksecurefunc(ScrollFrame.ScrollBar, "SetValue", function(self, value)
    local h = math.floor(ScrollChild:GetHeight() + 10)
    local scroll = h - BottomFrame:GetHeight()
    local index = RXPCData.currentStep and RXPCData.currentStep > 1 and
                      stepPos[RXPCData.currentStep - 1]
    local zero = addon.settings.profile.hideCompletedSteps and index and
                     index + RXPCData.currentStep or 0
    if scroll < zero then scroll = zero end
    if scroll <= value then ScrollFrame.ScrollBar.ScrollDownButton:Disable() end
    ScrollFrame.ScrollBar:SetMinMaxValues(zero, scroll)
end)

ScrollChild.framePool = {}
ScrollChild:SetWidth(RXPFrame:GetWidth() - 35)

ScrollFrame:SetScrollChild(ScrollChild)

function addon.GetGuideName(guide)
    if not guide then guide = addon.currentGuide end
    local som = addon.settings.profile.season == 1
    --sod p2
    --[[if addon.settings.profile.season == 2 and UnitLevel("player") < 25 then
        som = true
    end]]
    if som and guide.somname then
        return guide.somname
    elseif not som and guide.eraname then
        return guide.eraname
    else
        return guide.displayname
    end
end

RXPFrame.bottomMenu = {
    {
        notCheckable = 1,
        text = L("Go to step") .. " 1",
        func = addon.GoToStep,
        arg1 = 1
    }, {
        -- Checkbox to freeze progression so the guide can be navigated freely
        -- (same as /rxp browse). keepShownOnClick lets the tick update in place.
        text = L("Browse mode (freeze)"),
        isNotRadio = true,
        keepShownOnClick = true,
        checked = function() return addon.browseMode end,
        func = function()
            addon.browseMode = not addon.browseMode
            if not addon.browseMode then addon.updateSteps = true end
            if addon.comms then
                addon.comms.PrettyPrint(addon.browseMode and
                    "Browse mode ON - progression frozen." or
                    "Browse mode OFF - progression resumed.")
            end
        end
    }, {
        notCheckable = 1,
        text = L("Select another guide"),
        func = RXPFrame.DropDownMenu
    }, {
        text = L("Reload Guide"),
        notCheckable = 1,
        func = addon.LoadGuide,
        arg1 = addon.currentGuide
    }, {
        text = "Options...",
        notCheckable = 1,
        func = function()
            addon.settings.OpenSettings()
        end
    }, { -- Give Feedback for step, updated by addon.comms:Setup()
        notCheckable = 1,
        text = L("Give Feedback for step")
    },
    {text = _G.CLOSE, notCheckable = 1, func = function(self) self:Hide() end}
}

addon.emptyGuide = {
    empty = true,
    hidewindow = true,
    name = "",
    group = "",
    displayname = L("Welcome to RestedXP Guides\nRight click to pick a guide"),
    steps = {{hidewindow = true, text = ""}}
}

function addon.BetaVersionCheck()
    if GetCurrentRegion() < 20 then--PTR Region 72?
        Footer.text:SetText(fmt("%s %s", addon.title, addon.release))
    else
        Footer.text:SetText(fmt("RXP Beta %s %d/%d", addon.release, addon.minGuideVersion ,addon.maxGuideVersion))
    end
end

function addon.ProcessGuideTable(guide)
    if type(guide) ~= "table" then
        if addon.comms and addon.comms.PrettyDebug then
            addon.comms.PrettyDebug(
                "Ignored an unavailable guide while rebuilding guide data")
        end
        return nil
    end

    local currentGuide = {}

    for k, v in pairs(guide) do
        if type(v) ~= "table" then
            currentGuide[k] = v
        elseif k ~= "steps" and k ~= "tips" then
            currentGuide[k] = CopyTable(v)
        end
    end

    currentGuide.steps = {}
    currentGuide.tips = {}
    local ProcessSteps
    local IncludeGuide
    local guideRef = {}
    function IncludeGuide(group,name)
        local startAt, stopAt
        if type(group) == "table" then
            if not group.include then
                return
            end
            local step = group
            group, name = step.include:match("(.-)%s*\\\\?%s*([^\\]+)")
            if not group then
                group = guide.group
                name = step.include
            end
            local newName
            newName, startAt, stopAt = name:match("(.-)@([^@%-]+)%-?([^@%-]*)$")
            name = newName or name
            startAt = tonumber(startAt) or startAt
            stopAt = tonumber(stopAt) or stopAt
            if startAt and startAt == "" then startAt = nil end
            if stopAt and stopAt == "" then stopAt = nil end

            --print(startAt,stopAt)
        end
        local newGuide = addon:FetchGuide(group,name)
        if not newGuide then
            if name ~= "QuestDB" then
                addon.comms.PrettyPrint(L"RXPGuides - Error trying to include guide: %s\\%s", group, name)
            end
            return
        end
        if not guideRef[newGuide] and guide ~= newGuide then
            guideRef[newGuide] = true
            ProcessSteps(newGuide,startAt,stopAt)
            guideRef[newGuide] = false
        end
    end
    local lastTip
    function ProcessSteps(guide,startAt,stopAt)
        for _, step in ipairs(guide.steps) do
            local isShown = addon.IsStepShown(step)
            if isShown and startAt and (step.label == startAt or startAt == step.stepId) then
                startAt = nil
            end
            if isShown and not startAt then
                if not(step.include and step.elements and #step.elements == 0 and not step.requires and not step.label) then
                    if step.tip then
                        tinsert(currentGuide.tips,step)
                        lastTip = step
                        step.title = step.title or "Tip"
                    else
                        tinsert(currentGuide.steps, step)
                        step.tipWindow = lastTip
                    end
                    if step.elements then
                        for _,element in pairs(step.elements) do
                            addon.settings.ReplaceColors(element)
                        end
                    end
                end
                IncludeGuide(step)
                if stopAt and (step.label == stopAt or stopAt == step.stepId) then
                    break
                end
            end
        end
    end
    IncludeGuide(guide)
    ProcessSteps(guide)
    return currentGuide
end

function addon:FetchGuide(guide,arg2)
    if type(guide) == "string" then
        return addon:FetchGuide(addon.GetGuideTable(guide,arg2))
    elseif guide and not guide.steps then
        --print('ok3',guide.key)
        local key = guide.key
        local index = fmt("%s||%s",guide.group,guide.name)
        local oldGuide = guide
        local faction = UnitFactionGroup('player')
        addon.player.faction = faction
        if faction ~= "Neutral" then
            guide.parse = nil
        end
        local parser = addon.guideCache[key]
        local grp = guide.group
        if not parser then
            grp = addon.GroupOverride(guide.group)
            key = key:gsub("^(.-)%|",grp.."|")
            guide.group = grp
            guide.key = key
            --newGuide.group = grp
            parser = addon.guideCache[key]
            --print('ok2',key,parser)
        end

        local newGuide = parser and parser(parser) or
                            guide.parse and guide.parse(guide.parse)
        if newGuide then
            newGuide.group = grp
            newGuide.menuIndex = oldGuide.menuIndex
            newGuide.submenuIndex = oldGuide.submenuIndex

            if not addon.guides[index] then
                index = index:gsub("^(.-)%|%|",grp.."||")
            end
            addon.guides[index] = newGuide
            addon.guideCache[key] = nil
            guide = newGuide
            addon:ScheduleTask(addon.UpdateQuestButton)
            addon:ScheduleTask(addon.RXPFrame.GenerateMenuTable)
        else
            --print(guide.name,guide.group)
            --GG = guide
            addon.comms.PrettyDebug('Error: Tried to load an invalid Guide: %s v%s', key, guide.version or 0)
            return
        end
    end
    if type(guide) == "table" then
        return guide
    end
end

function addon:LoadGuideTable(guideGroup,guideName)
    local guide = addon.GetGuideTable(guideGroup, guideName)
    if addon.guideState and addon.guideState.Load then
        return addon.guideState:Load(guide, false, "manual")
    end
    return addon:LoadGuide(guide, nil, "manual")
end

-- A later chapter often begins by turning in a quest picked up by the previous
-- chapter.  Loading it directly used to strand the player on a step that could
-- never complete.  The 3.3.5 picker uses this lightweight preflight to locate
-- that dependency and move back one chapter.  Normal #next transitions and
-- saved-character restoration deliberately bypass it.
local function GetMissingGuideEntryQuest(guide)
    if addon.gameVersion ~= 30300 or type(guide) ~= "table" or guide.empty then
        return
    end

    local processed = addon.ProcessGuideTable(guide)
    if not processed or type(processed.steps) ~= "table" then return end

    local accepted = {}
    local turnedIn = {}
    local function IsDone(id)
        return turnedIn[id] or addon.IsQuestTurnedIn and
                   addon.IsQuestTurnedIn(id)
    end
    local function IsOnQuest(id)
        return accepted[id] or addon.IsOnQuest and addon.IsOnQuest(id)
    end
    local function ProcessElement(element)
        if type(element) ~= "table" then return end
        local tag = element.tag
        local ids = element.ids or
                        (element.questId and {element.questId}) or nil
        if type(ids) ~= "table" then return end

        for _, rawId in ipairs(ids) do
            local id = tonumber(rawId)
            if id and id > 0 then
                if tag == "turnin" or tag == "dailyturnin" then
                    if not element.skipIfMissing and not IsDone(id) and
                        not IsOnQuest(id) then
                        return {id}
                    end
                    turnedIn[id] = true
                    accepted[id] = nil
                elseif tag == "accept" or tag == "daily" or
                    tag == "acceptmultiple" then
                    if addon.GetQuestPreReqState then
                        local complete, missing = addon.GetQuestPreReqState(
                            id, guide.group,
                            {rewarded = turnedIn, active = accepted})
                        if complete == false and type(missing) == "table" and
                            #missing > 0 then return missing end
                    end
                    accepted[id] = true
                end
            end
        end
    end

    for _, step in ipairs(processed.steps) do
        if not step.optional then
            for _, element in ipairs(step.elements or {}) do
                local missing = ProcessElement(element)
                if missing then return missing end
            end
        end
    end
end

local function GuideContainsQuest(guide, questId)
    if type(guide) ~= "table" or not tonumber(questId) then return false end
    local fetched = addon:FetchGuide(guide)
    if not fetched then return false end
    local processed = addon.ProcessGuideTable(fetched)
    if not processed or type(processed.steps) ~= "table" then return false end
    questId = tonumber(questId)
    for _, step in ipairs(processed.steps) do
        if not step.optional then
            for _, element in ipairs(step.elements or {}) do
                local tag = type(element) == "table" and element.tag
                if tag == "accept" or tag == "acceptmultiple" or
                    tag == "daily" or tag == "complete" or tag == "turnin" or
                    tag == "turninmultiple" or tag == "dailyturnin" then
                    local ids = element.ids or
                                    (element.questId and {element.questId}) or {}
                    for _, rawId in ipairs(ids) do
                        if tonumber(rawId) == questId then return true end
                    end
                end
            end
        end
    end
    return false
end

local function ResolveGuideNext(guide)
    if type(guide) ~= "table" or type(guide.next) ~= "string" then return end
    for rawName in guide.next:gmatch("%s*([^;]+)%s*") do
        local group = guide.group
        local name = rawName:gsub("^%s*(.+)\\%s*", function(nextGroup)
            group = nextGroup
            return ""
        end)
        name = name:gsub("^(%d)-(%d%d?)", addon.affix)
        local nextGuide = addon.GetGuideTable(group, name)
        if nextGuide and addon.IsGuideActive(nextGuide) then return nextGuide end
    end
end

local function FindPreviousGuide(requestedGuide)
    local matches = {}
    local seen = {}
    for _, candidate in pairs(addon.guides or {}) do
        if type(candidate) == "table" and candidate ~= requestedGuide and
            not seen[candidate] and addon.IsGuideActive(candidate) then
            seen[candidate] = true
            local nextGuide = ResolveGuideNext(candidate)
            if nextGuide and (nextGuide == requestedGuide or
                nextGuide.group == requestedGuide.group and
                    nextGuide.name == requestedGuide.name) then
                local requestedMin = tonumber((requestedGuide.name or ""):match("^(%d+)"))
                local candidateMax = tonumber((candidate.name or ""):match("^%d+%-(%d+)"))
                local score = candidate.subgroup == requestedGuide.subgroup and 100 or 0
                if requestedMin and candidateMax then
                    score = score - math.abs(requestedMin - candidateMax)
                end
                table.insert(matches, {guide = candidate, score = score})
            end
        end
    end
    table.sort(matches, function(a, b)
        if a.score == b.score then
            return (a.guide.name or "") < (b.guide.name or "")
        end
        return a.score > b.score
    end)
    return matches[1] and matches[1].guide
end

function addon:LoadGuide(guide, OnLoad, loadSource, redirectTrail)
    addon.loadNextStep = false

    local savedStep = OnLoad and RXPCData and RXPCData.currentStep
    local savedStepId = OnLoad and RXPCData and RXPCData.currentStepId
    local requestedGuide = guide

    local function LoadEmptyGuide()
        if requestedGuide ~= addon.emptyGuide and
            type(addon.emptyGuide) == "table" then
            return addon:LoadGuide(addon.emptyGuide)
        end
        addon.comms.PrettyDebug("Unable to load guide: no valid empty guide is registered")
    end

    if type(guide) ~= "table" then
        return LoadEmptyGuide()
    elseif guide.internal or guide.disabled or not guide.empty and not addon.IsGuideActive(guide) and
        (guide.farm and not RXPCData.GA or not guide.farm and RXPCData.GA) then
        return LoadEmptyGuide()
    end

    guide = addon:FetchGuide(guide)
    if not guide or not guide.steps then
        return LoadEmptyGuide()
    end
    if loadSource == "manual" and addon.gameVersion == 30300 then
        redirectTrail = redirectTrail or {}
        local guideKey = guide.key or fmt("%s|%s", guide.group or "",
                                          guide.name or "")
        local missingQuests = not redirectTrail[guideKey] and
                                  GetMissingGuideEntryQuest(guide)
        local previousGuide = missingQuests and FindPreviousGuide(guide)
        local missingQuest
        if previousGuide then
            for _, questId in ipairs(missingQuests) do
                if GuideContainsQuest(previousGuide, questId) then
                    missingQuest = questId
                    break
                end
            end
        end
        if previousGuide and missingQuest then
            redirectTrail[guideKey] = true
            local questName = addon.GetQuestName and
                                  addon.GetQuestName(missingQuest)
            addon.comms.PrettyPrint(
                "%s requires %s (%d); opening %s first.",
                addon.GetGuideName(guide) or guide.name,
                questName or (_G.QUESTS_LABEL or "Quest"), missingQuest,
                addon.GetGuideName(previousGuide) or previousGuide.name)
            return addon:LoadGuide(previousGuide, nil, "manual",
                                   redirectTrail)
        end
    end
    if addon.HideIntroUI and not guide.empty then
        addon.HideIntroUI()
    end

    if guide.hardcore then
        if not addon.settings.profile.hardcore then
            addon.settings.profile.hardcore = true
            addon.RenderFrame(true,true)
        end
        --addon.settings.profile.season = 0
    elseif guide.softcore and addon.settings.profile.hardcore then
            addon.settings.profile.hardcore = false
            addon.RenderFrame(true,true)
    end

    if addon.settings.profile.frameHeight then
        RXPFrame:SetHeight(addon.settings.profile.frameHeight)
    end
    if addon.noGuide then
        RXPFrame:SetHeight(addon.height)
        RXPFrame.BottomFrame.UpdateFrame()
        addon.noGuide = nil
    end

    _G.CloseDropDownMenus()

    if not (OnLoad and RXPCData and RXPCData.currentStep) then
        RXPCData.currentStep = 1
        RXPCData.stepSkip = {}
        RXPCData.completedWaypoints = {}
        --Detects XP rate again when switching guides, in case player equipped heirlooms in between guides
        addon.settings:DetectXPRate(true)
    end
    -- local totalHeight = 0
    local nframes = 0

    table.wipe(addon.scheduledTasks)
    table.wipe(addon.stepUpdateList)
    addon.updateTipWindow = false
    addon.currentGuide = nil
    local renderFrame

    if guide.hardcore and addon.game == "CLASSIC" and not addon.settings.profile.hardcore then
        addon.settings.profile.hardcore = true
        renderFrame = true
    end

    --TODO: add better theme handling
    if guide.theme and addon.settings.profile.activeTheme == "Default" then
        renderFrame = true
    end

    if renderFrame then
        addon.RenderFrame()
    end

    addon.currentGuide = addon.ProcessGuideTable(guide)
    guide = addon.currentGuide
    if addon.compatibilityPacks and addon.compatibilityPacks.ApplyGuide then
        addon.compatibilityPacks:ApplyGuide(guide)
    end

    local disabledQuests = {}
    if guide.disabledQuests then
        for id in pairs(guide.disabledQuests) do
            disabledQuests[id] = true
        end
    end

    if addon.disabledQuestList then
        for _,id in pairs(addon.disabledQuestList) do
            disabledQuests[id] = true
        end
    end
    addon.disabledQuests = disabledQuests

    addon.currentGuideName = guide.name
    RXPCData.currentGuideName = guide.name
    RXPCData.currentGuideGroup = guide.group
    local guidename = guide.title or addon.GetGuideName(guide)
    -- OnEnable may still be called by some AceAddon revisions after an earlier
    -- initialization error. Ensure this lazily-created FontString is usable so
    -- restoring a guide cannot produce a second, misleading cascade error.
    if not select(1, GuideName.text:GetFont()) then
        local guideFontSize = addon.settings.profile and
                                  addon.settings.profile.guideFontSize or 9
        addon.SetFontSafely(GuideName.text, addon.font,
                            guideFontSize + 2, "")
    end
    if guide.subgroup and not guide.title then
        GuideName.text:SetText(guidename .. "\n" .. guide.subgroup)
    else
        GuideName.text:SetText(guidename:gsub("\\n","\n"))
    end

    guide.labels = {}

    -- Labels may be referenced before they are declared.  Build the complete
    -- lookup first; the old single-pass setup silently lost forward #requires
    -- links.  Imported legacy guides also contain a handful of stale labels,
    -- so degrade those safely instead of leaving permanent sticky steps or
    -- hiding an otherwise usable step.
    for n, step in ipairs(guide.steps) do
        if step.label then guide.labels[step.label] = n end
    end

    local lastStep = guide.steps[#guide.steps]
    if lastStep then lastStep.lastStep = true end

    -- Lookup feedbackMenuIndex, avoid dynamic/future menu change conflicts
    local feedbackMenuIndex
    for i, m in ipairs(addon.RXPFrame.bottomMenu) do
        if m.text == L("Give Feedback for step") then
            feedbackMenuIndex = i
            break
        end
    end

    for n, step in ipairs(guide.steps) do
        step.index = n
        if step.completewith and step.completewith ~= "next" and
            not guide.labels[step.completewith] then
            addon.comms.PrettyDebug("Unknown #completewith label '%s' in %s; using next step",
                                    tostring(step.completewith),
                                    tostring(guide.name))
            step.completewith = "next"
        end
        if step.requires and not guide.labels[step.requires] then
            addon.comms.PrettyDebug("Unknown #requires label '%s' in %s; showing step",
                                    tostring(step.requires),
                                    tostring(guide.name))
            step.requires = nil
        end
        if not step.elements or #step.elements == 0 then
            step.optional = true
        end
        --BottomFrame.stepList[n] = n
        if step.completewith and not step.tip then step.sticky = true end
        if step.requires then
            local requirement = guide.labels[step.requires]
            if requirement then
                local requiredStep = guide.steps[requirement]
                if requiredStep.sticky and not requiredStep.completewith and
                    not step.sticky then
                    step.label = step.label or n
                    requiredStep.completewith = step.label
                end
            end
        end
        step.level = tonumber(step.level) or 0
        if step.label then guide.labels[step.label] = n end

        nframes = nframes + 1
        ScrollChild.framePool[n] = ScrollChild.framePool[n] or
                                       CreateFrame("Frame",
                                                   "$parent_frame_" .. n,
                                                   ScrollChild, BackdropTemplate)
        local frame = ScrollChild.framePool[n]
        -- Enable mouse so the OnEnter/OnLeave highlight and the right-click
        -- "Go to step" menu below actually receive events (a plain Frame is not
        -- mouse-interactive by default, so on 3.3.5a these did nothing).
        frame:EnableMouse(true)
        frame.bottom = true
        frame:Show()
        frame.step = step
        frame:SetAlpha(0.66)
        frame:ClearAllPoints()
        local anchor
        if n == 1 then
            anchor = ScrollChild
            frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", 2, -3)
            frame:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", 2, -3)
        elseif not IsFrameShown(frame,step) then
            anchor = ScrollChild.framePool[n - 1]
            frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, 1)
            frame:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, 1)
        else
            anchor = ScrollChild.framePool[n - 1]
            frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -3)
            frame:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -3)
        end
        frame:ClearBackdrop()
        frame:SetBackdrop(RXPFrame.backdrop.bottom)
        ApplyStepVisualState(frame, step, true)

        frame:SetScript("OnEnter", function(self)
            self.currentAlpha = self:GetAlpha()
            if IsFrameShown(frame,self.step) then
                self:SetAlpha(1)
                self:SetBackdropColor(unpack(addon.colors.bottomFrameHighlight))
            end
        end)
        frame:SetScript("OnLeave", function(self)
            self:SetBackdropColor(unpack(self.stepVisualBackground or
                                             addon.colors.bottomFrameBG))
            self:SetAlpha(self.currentAlpha)
        end)
        frame.timer = 0
        frame.index = n
        frame.guide = guide
        frame:SetScript("OnMouseDown", function(self, button)
            if not IsFrameShown(frame, self.step) then return end
            if button == "RightButton" then
                self.timer = 0
                local n = self.step.index
                local bottomMenu = RXPFrame.bottomMenu
                bottomMenu[1].text = L("Go to step") .. " " .. n
                bottomMenu[1].arg1 = n
                bottomMenu[feedbackMenuIndex].arg1 = n
                if _G.EasyMenu then
                    _G.EasyMenu(bottomMenu, MenuFrame, "cursor", 0, 0, "MENU");
                else
                    LibDD:EasyMenu(bottomMenu, MenuFrame, "cursor", 0, 0, "MENU");
                end
            elseif button == "LeftButton" and self.step and addon.GoToStep then
                -- Left-click a step to jump straight to it (right-click still opens
                -- the menu with "Go to step", browse toggle, etc.).
                addon.GoToStep(self.step.index)
            end
        end)

        if not frame.text then
            frame.text = frame:CreateFontString(nil, "OVERLAY")
        end

        if not frame.number then
            frame.number = CreateFrame("Frame", "$parent_number", frame,
                                       nil)
            frame.number:SetPoint("BOTTOMRIGHT", frame)
            frame.number.text = frame.number:CreateFontString(nil, "OVERLAY")
            frame.number.text:SetFontObject(_G.GameFontNormalSmall)
            frame.number.text:ClearAllPoints()
            frame.number.text:SetPoint("CENTER", frame.number, 0, 0)
            frame.number.text:SetJustifyH("CENTER")
            frame.number.text:SetJustifyV("MIDDLE")
            frame.number.text:SetTextColor(unpack(addon.activeTheme.textColor))
            frame.number.text:SetFont(addon.font, addon.settings.profile
                                          .guideFontSize - 1, "") -- 8
            local prefix = ""
            if n < 10 then prefix = "0" end
            frame.number.text:SetText(prefix .. tostring(n))
            frame.number:SetSize(frame.number.text:GetStringWidth() + 2, 10)
        end

        frame.text:SetFontObject(_G.GameFontNormalSmall)
        frame.text:ClearAllPoints()
        frame.text:SetPoint("TOPLEFT", frame, 0, -5)
        frame.text:SetPoint("BOTTOMRIGHT", frame.number, "BOTTOMLEFT", 0, 0)
        frame.text:SetJustifyH("LEFT")
        frame.text:SetJustifyV("TOP")
        frame.text:SetTextColor(unpack(addon.activeTheme.textColor))
        frame.text:SetFont(addon.font, addon.settings.profile.guideFontSize,
                           "")

        -- frame.text:SetHeight(1000)

        -- frame.text:SetText(text)

        frame:SetHeight(20)

    end
    if #ScrollChild.framePool > nframes then
        for i = nframes + 1, #ScrollChild.framePool do
            ScrollChild.framePool[i]:Hide()
        end
    end
    ScrollChild.f1 = ScrollChild.f1 or CreateFrame("Frame", nil, ScrollChild)
    ScrollChild.f1:ClearAllPoints()
    ScrollChild.f1:SetPoint("TOPLEFT", ScrollChild.framePool[1], 0, 10)
    ScrollChild.f1:SetPoint("BOTTOMRIGHT", ScrollChild.framePool[nframes])
    ScrollChild.f1:Hide()
    ScrollChild:SetHeight(200)
    if OnLoad then
        local restoreStep
        if savedStepId ~= nil then
            for index, step in ipairs(guide.steps) do
                if step.stepId ~= nil and
                    (step.stepId == savedStepId or
                        tostring(step.stepId) == tostring(savedStepId)) then
                    restoreStep = index
                    break
                end
            end
        end
        if not restoreStep and type(savedStep) == "number" and
            savedStep >= 1 and savedStep <= #guide.steps and
            savedStep == math.floor(savedStep) then
            restoreStep = savedStep
        end
        if not restoreStep then
            RXPCData.stepSkip = {}
            RXPCData.completedWaypoints = {}
        end
        RXPCData.currentStep = restoreStep or 1
    end

    addon.SetStep(RXPCData.currentStep)
    BottomFrame.hiddenFrames = 0
    BottomFrame.UpdateFrame()
    addon.tickTimer = 0
    addon:QueueMessage("RXP_GUIDE_LOADED",guide)
    if addon.guideState and addon.guideState.RecordLoaded then
        addon.guideState:RecordLoaded(guide)
    end
    addon:ScheduleTask(RXPFrame.GenerateMenuTable)
end

function addon:ReloadGuide(keepStep)
    local guide = addon.GetGuideTable(RXPCData.currentGuideGroup,
                                      RXPCData.currentGuideName)
    return guide and addon:LoadGuide(guide,keepStep)
end

function BottomFrame.UpdateFrame(self, stepn)
    local level = UnitLevel("player")

    if stepPos[0] and ((not self and stepn) or (self and self.step)) and IsFrameShown(self,self and self.step) then
        local stepNumber = stepn or self.step.index
        local frame = ScrollChild.framePool[stepNumber]
        local step = addon.currentGuide.steps[stepNumber]
        --[[for i, v in ipairs(BottomFrame.stepList) do
            if v == stepNumber then
                frame = ScrollChild.framePool[i]
                step = addon.currentGuide.steps[v]
                break
            end
        end]]
        if not (frame and step) then return end

        local fheight
        local hideStep = step.level > level or (not IsFrameShown(frame,step))

        local text, rawtext, icon
        local stepDiff

        for _, element in ipairs(frame.step.elements or {}) do
            stepDiff = element.step.index - RXPCData.currentStep
            element.element = element

            if element.requestFromServer then
                --addon.lastCall = element.tag
                addon.Call(element.tag,addon.functions[element.tag],element,"WindowUpdate")
                addon.updateStepText =
                    addon.updateStepText or
                        not element.requestFromServer
                addon.stepUpdateList[element.step.index] =
                    not element.requestFromServer
            elseif element.tag and
                (stepDiff <= 8 and stepDiff >= 0 or element.keepUpdating) then
                --addon.lastCall = element.tag
                --addon.functions[element.tag](element,"WindowUpdate")
                addon.Call(element.tag,addon.functions[element.tag],element,"WindowUpdate")
            end

            rawtext = element.tooltipText

            if type(element.text) ~= "string" then
                if addon.settings.profile.debug then
                    -- print('Error text at step ' .. step.index)
                end
            elseif not rawtext then
                icon = element.icon or addon.icons[element.tag] or ""
                rawtext = icon .. element.text
            end

            if rawtext and not element.hideTooltip then
                rawtext = addon.ReplaceNpcIds(rawtext,element)
                if not text then
                    text = "   " .. rawtext
                else
                    text = text .. "\n   " .. rawtext
                end
            end
        end

        if hideStep then
            step.text = ""
            step.hiddentext = text
        else
            step.text = text
        end

        if frame.text then
            frame.text:SetText(text)
        end

        if hideStep then
            fheight = 1
            frame:SetAlpha(0)
        else
            fheight = math.ceil(frame.text:GetStringHeight() + 8)
            frame:SetAlpha(GetStepVisualState(step) == "completed" and 0.78 or 1)
        end
        ApplyStepVisualState(frame, step, true)

        local hDiff = fheight - frame:GetHeight()
        frame:SetHeight(fheight)

        for n = stepNumber + 1, #stepPos do
            stepPos[n] = stepPos[n] + hDiff
        end

        stepPos[0] = stepPos[0] + hDiff

    else
        addon.updateBottomFrame = false

        local totalHeight = 0
        --local hiddenFrames = 0

        for n, frame in ipairs(ScrollChild.framePool) do
            if not frame:IsShown() then break end
            local text
            --frame.step = addon.currentGuide.steps[BottomFrame.stepList[n]]
            frame.step = addon.currentGuide.steps[n]
            local step = frame.step
            local hideStep = step.level > level or not IsFrameShown(frame,step)
            local fheight
            for _, element in ipairs(frame.step.elements or {}) do
                if not self then
                    local stepDiff = element.step.index - RXPCData.currentStep

                    element.element = element

                    if element.requestFromServer then
                        --addon.lastCall = element.tag
                        --addon.functions[element.tag](element,"WindowUpdate")
                        addon.Call(element.tag,addon.functions[element.tag],element,"WindowUpdate")
                        addon.updateStepText =
                            addon.updateStepText or
                                not element.requestFromServer
                        addon.stepUpdateList[element.step.index] =
                            not element.requestFromServer
                    elseif element.tag and
                        (stepDiff <= 8 and stepDiff >= 0 or element.keepUpdating) then

                        --addon.lastCall = element.tag
                        --addon.functions[element.tag](element,"WindowUpdate")
                        addon.Call(element.tag,addon.functions[element.tag],element,"WindowUpdate")
                    end
                end

                local rawtext = element.tooltipText

                if not rawtext and element.text then
                    local icon = element.icon or addon.icons[element.tag] or ""
                    rawtext = icon .. element.text
                end

                if rawtext and not element.hideTooltip and rawtext ~= "" then
                    rawtext = addon.ReplaceNpcIds(rawtext,element)
                    if not text then
                        text = "   " .. rawtext
                    else
                        text = text .. "\n   " .. rawtext
                    end
                end
            end

            if hideStep then
                step.hiddentext = text
                text = ""
            end
            if step.completed or
                (not step.sticky and RXPCData.currentStep > step.index) or
                RXPCData.stepSkip[step.index] then
                -- Keep completed rows readable enough for the green state to be
                -- unmistakable while still de-emphasizing them.
                frame:SetAlpha(0.78)
            else
                frame:SetAlpha(1)
            end
            ApplyStepVisualState(frame, step, true)

            if frame.text then
                if hideStep then
                    --hiddenFrames = hiddenFrames + 1
                    frame.text:SetText(text)
                    fheight = 1.00
                    frame:SetAlpha(0)
                else
                    frame.text:SetText(text)
                    fheight = math.ceil(frame.text:GetStringHeight() + 8)
                end
            end
            step.text = text

            if fheight == 1 and not IsFrameShown(frame,step) then
                frame:SetHeight(1)
                fheight = -3
            else
                frame:SetHeight(fheight)
            end

            totalHeight = totalHeight + fheight + 2
            stepPos[n] = totalHeight - 5
        end
        --[[if hiddenFrames ~= BottomFrame.hiddenFrames then
            BottomFrame.SortSteps()
        end
        BottomFrame.hiddenFrames = hiddenFrames]]
        stepPos[0] = totalHeight
        -- print(ScrollChild.framePool[#ScrollChild.framePool]:GetBottom(),totalHeight)
    end

    local guide = addon.currentGuide

    if guide then
        ScrollChild:SetHeight(ScrollChild.f1:GetHeight() -
                                  BottomFrame.hiddenFrames * 4)
    end

    local w = RXPFrame:GetWidth() - 35
    ScrollChild:SetWidth(w)
    local bottomFrameHeight = BottomFrame:GetHeight()

    if bottomFrameHeight < 30 then
        BottomFrame:Hide()
        if RXPFrame:GetHeight() < 28 then RXPFrame:SetHeight(28) end
    elseif guide and guide.hidewindow then
        if RXPFrame:GetHeight() > 50 then
            addon.settings.profile.frameHeight = RXPFrame:GetHeight()
        end

        RXPFrame:SetHeight(28)
        BottomFrame:Hide()
    elseif not BottomFrame:IsShown() then
        if addon.settings.profile.frameHeight then
            RXPFrame:SetHeight(math.max(addon.settings.profile.frameHeight,
                                        50))
        end

        BottomFrame:Show()
    end

    addon.BetaVersionCheck()

end
-- addon.hiddenFrames = 0
--[[BottomFrame.stepList = {}
function BottomFrame.SortSteps()
    table.sort(BottomFrame.stepList, function(k1, k2)
        local step1 = k1 and addon.currentGuide.steps[k1]
        local step2 = k2 and addon.currentGuide.steps[k2]
        if not (step1 and step2) then return k1 < k2 end
        step1 = step1.hidewindow
        step2 = step2.hidewindow
        if step2 and not step1 then
            return true
        elseif step1 and not step2 then
            return false
        elseif k1 < k2 then
            return true
        end
        return false
    end)

    for i = 1, #BottomFrame.stepList do
        local n = BottomFrame.stepList[i]
        local frame = ScrollChild.framePool[i]
        local prefix = ""
        if n < 10 then prefix = "0" end
        frame.number.text:SetText(prefix .. tostring(n))
    end
end]]

local function IsGuideActive(guide,includeInternal)
    if guide and addon.stepLogic.SeasonCheck(guide) and addon.stepLogic.PhaseCheck(guide) and
        addon.stepLogic.XpRateCheck(guide) and addon.stepLogic.FreshAccountCheck(guide) and
        addon.stepLogic.LevelCheck(guide) and (not guide.internal or includeInternal) and
        addon.stepLogic.LoremasterCheck(guide) then
        if (not addon.player.neutral or not guide.enabledFor) then
            return true
        else
            --Make sure only neutral guides show up if you don't have a faction assigned
            local enabledFor = guide.enabledFor
            local enabled = addon.applies(enabledFor)
            local horde = addon.applies(enabledFor,"Horde")
            local alliance = addon.applies(enabledFor,"Alliance")
            return enabled and horde and alliance
        end
    end
end

addon.IsGuideActive = IsGuideActive

function RXPFrame:GenerateMenuTable(menu)
    local menuList = menu or {}

    local groupList = {}
    local originalGroupList = {}
    local farmGuides = {}
    local originalFarmGuides = {}
    local unusedGuides = {}
    local originalUnusedGuides = {}
    local defaultGuide, defaultGuideHC
    local originalGroupPrefix = "Original Guides - "

    for group in pairs(addon.guideList) do
        local firstChar = group:sub(1, 1)
        if RXPCData and RXPCData.GA then
            if firstChar == "+" then
                if addon.gameVersion == 30300 and
                    group:sub(2, #originalGroupPrefix + 1) ==
                        originalGroupPrefix then
                    tinsert(originalFarmGuides, group)
                else
                    tinsert(farmGuides, group)
                end
            end
        elseif firstChar ~= "+" then
            if firstChar ~= "*" then
                if addon.gameVersion == 30300 and
                    group:sub(1, #originalGroupPrefix) ==
                        originalGroupPrefix then
                    tinsert(originalGroupList, group)
                else
                    tinsert(groupList, group)
                end
            else
                if addon.gameVersion == 30300 and
                    group:sub(2, #originalGroupPrefix + 1) ==
                        originalGroupPrefix then
                    tinsert(originalUnusedGuides, group)
                else
                    tinsert(unusedGuides, group)
                end
            end
        end
    end

    local sortfunc = function(g1,g2)
        local w1 = addon.guideList[g1].weight_ or 0
        local w2 = addon.guideList[g2].weight_ or 0
        if w1 == w2 then
            return g1 < g2
        else
            return w1 > w2
        end
    end

    table.sort(farmGuides,sortfunc)
    table.sort(originalFarmGuides,sortfunc)
    table.sort(groupList,sortfunc)
    table.sort(originalGroupList,sortfunc)
    table.sort(unusedGuides,sortfunc)
    table.sort(originalUnusedGuides,sortfunc)

    local menuIndex = 1
    local function ProcessChapters(guide,tbl,activeChapters)
        if guide.chapters then
            if not activeChapters then activeChapters = {} end
            for chapterName in string.gmatch(guide.chapters,"%s*([^;]+)%s*") do
                local chapter = addon.GetGuideTable(guide.group, chapterName)
                if addon.IsGuideActive(chapter,true) then
                    if not tbl.menuList then
                        tbl.menuList = {}
                        tbl.func = nil
                        tbl.arg1 = nil
                        tbl.arg2 = nil
                        tbl.hasArrow = true
                    end
                    local item = {
                        arg1 = guide.group,
                        arg2 = chapterName,
                        func = addon.LoadGuideTable,
                        text = addon.GetGuideName(chapter),
                        notCheckable = 1,
                    }
                    if not activeChapters[chapterName] then
                        ProcessChapters(chapter,item,activeChapters)
                    end
                    activeChapters[chapterName] = true
                    tinsert(tbl.menuList,item)
                end
            end
        end
    end

    local function createMenu(group, targetMenu)
        if group == "RXPGuides" then return end
        local t = addon.guideList[group]
        menuIndex = menuIndex + 1

        if t.sorted_ ~= #t.names_ then
            t.sorted_ = #t.names_
            table.sort(t.names_)
        end
        local displayGroup = addon.GroupOverride(group)
        displayGroup = displayGroup:gsub(
                           "^([+*]?)Original Guides %- ", "%1")
        local item = {
            text = displayGroup,
            notCheckable = 1,
            hasArrow = true,
            menuList = {}
        }
        item.subgroups = {}
        item.subtable = {}
        local submenuIndex = 0
        local groupName = group:gsub("^%*","")
        local flatGroupName = groupName:gsub(
                                  "^Original Guides %- ", "")
        local flattenLegacyLeveling = addon.gameVersion == 30300 and
            (flatGroupName == "RestedXP Speedrun Guide (A)" or
             flatGroupName == "RestedXP Speedrun Guide (H)" or
             flatGroupName == "RestedXP TBC Guide (A)" or
             flatGroupName == "RestedXP TBC Guide (H)" or
             flatGroupName == "RestedXP WotLK Guide (A)" or
             flatGroupName == "RestedXP WotLK Guide (H)")
        -- Stock 3.3.5 EasyMenu has no scrolling.  Keeping every imported TBC
        -- chapter on one flattened menu can make the last bracket extend
        -- underneath other UI frames (or off-screen), leaving visible rows
        -- darkened and unable to receive mouse clicks.  Keep short brackets
        -- flat, but place any bracket that would overflow a compact menu in a
        -- normal EasyMenu child page.
        local legacyFlatMenuLimit = 22
        local nActive = 0
        for j, guideName in ipairs(t.names_) do
            local guide = addon.GetGuideTable(groupName, guideName)
            --if not guide then print(guide,group,guideName) end
            if IsGuideActive(guide) and not guide.chapter then
                nActive = nActive + 1
                if guide.subgroup then
                    local subgroup = guide.subgroup
                    local subtable = item.subtable[subgroup]
                    if not subtable then
                        local subname = subgroup:gsub("^(%d)-(%d%d?)",
                                                      addon.affix)
                        subtable = {
                            text = subgroup,
                            notCheckable = 1,
                            hasArrow = true,
                            menuList = {},
                            subweight = 0
                        }
                        item.subtable[subname] = subtable
                        tinsert(item.subgroups, subname)
                    end
                    local subitem = {}
                    subitem.text = addon.GetGuideName(guide)
                    if guide.disabled then
                        subitem.isTitle = 1
                    else
                        subitem.func = addon.LoadGuideTable
                        subitem.arg1 = guide.group
                        subitem.arg2 = guideName
                    end
                    subitem.notCheckable = 1
                    if flattenLegacyLeveling then
                        subitem.legacyMinLevel, subitem.legacyMaxLevel =
                            guideName:match("^(%d+)%-(%d+)")
                        subitem.legacyMinLevel = tonumber(subitem.legacyMinLevel)
                        subitem.legacyMaxLevel = tonumber(subitem.legacyMaxLevel)
                    end
                    subtable.subweight = tonumber(guide.subweight) or subtable.subweight
                    ProcessChapters(guide,subitem)
                    tinsert(subtable.menuList, subitem)
                else
                    submenuIndex = submenuIndex + 1
                    guide.menuIndex = menuIndex
                    guide.submenuIndex = submenuIndex
                    local subitem = {}
                    subitem.text = addon.GetGuideName(guide)
                    if guide.disabled then
                        subitem.isTitle = 1
                    else
                        subitem.func = addon.LoadGuideTable
                        subitem.arg1 = guide.group
                        subitem.arg2 = guideName
                    end
                    subitem.notCheckable = 1
                    ProcessChapters(guide,subitem)
                    tinsert(item.menuList, subitem)
                end
                if not defaultGuide and guide.group == addon.defaultGroup then
                    addon.defaultGuide = guideName
                    defaultGuide = true
                end
                if not defaultGuideHC and guide.group == addon.defaultGroupHC then
                    defaultGuideHC = true
                    addon.defaultGuideHC = guideName
                end
                if nActive == 1 then
                    t.defaultGuide_ = guideName
                end
            end
        end

        if #item.subgroups > 0 then
            table.sort(item.subgroups,function(s1,s2)
                local w1 = item.subtable[s1].subweight
                local w2 = item.subtable[s2].subweight
                if w1 == w2 then
                    return s1 < s2
                else
                    return w1 > w2
                end
            end)
            for i, subgroup in ipairs(item.subgroups) do
                local subtable = item.subtable[subgroup]
                if flattenLegacyLeveling then
                    table.sort(subtable.menuList, function(a, b)
                        local amin = a.legacyMinLevel or math.huge
                        local bmin = b.legacyMinLevel or math.huge
                        if amin ~= bmin then return amin < bmin end
                        local amax = a.legacyMaxLevel or math.huge
                        local bmax = b.legacyMaxLevel or math.huge
                        if amax ~= bmax then return amax < bmax end
                        return (a.text or "") < (b.text or "")
                    end)
                    local requiredRows = #subtable.menuList + 1
                    if #item.menuList + requiredRows > legacyFlatMenuLimit then
                        tinsert(item.menuList, {
                            text = subtable.text,
                            colorCode = "|cffffd100",
                            notCheckable = 1,
                            hasArrow = true,
                            menuList = subtable.menuList,
                        })
                    else
                        tinsert(item.menuList, {
                            text = subtable.text,
                            isTitle = 1,
                            notCheckable = 1,
                        })
                        for _, subitem in ipairs(subtable.menuList) do
                            tinsert(item.menuList, subitem)
                        end
                    end
                else
                    tinsert(item.menuList, subtable)
                end
            end
        else
            item.subgroups = nil
            item.subtable = nil
        end
        if #item.menuList > 0 then
            tinsert(targetMenu or menuList, item)
            --print(#item.menuList,group)
        end
    end

    if #groupList > 0 or #originalGroupList > 0 then
        tinsert(menuList, {
            text = L("Available Guides"),
            isTitle = 1,
            notCheckable = 1
        })
        if addon.gameVersion == 30300 and #originalGroupList > 0 then
            local validatedMenu = {}
            for _, group in ipairs(groupList) do
                createMenu(group, validatedMenu)
            end
            if #validatedMenu > 0 then
                tinsert(menuList, {
                    text = "Validated & Fixed Guides",
                    notCheckable = 1,
                    hasArrow = true,
                    menuList = validatedMenu,
                })
            end
            local originalMenu = {}
            for _, group in ipairs(originalGroupList) do
                createMenu(group, originalMenu)
            end
            if #originalMenu > 0 then
                tinsert(menuList, {
                    text = "Original Upstream Guides",
                    notCheckable = 1,
                    hasArrow = true,
                    menuList = originalMenu,
                })
            end
        else
            for _, group in ipairs(groupList) do createMenu(group) end
        end
    end

    if #farmGuides > 0 or #originalFarmGuides > 0 then
        tinsert(menuList, {
            text = L("Gold Farming Guides"),
            notCheckable = 1,
            isTitle = 1
        })
        if addon.gameVersion == 30300 and #originalFarmGuides > 0 then
            local validatedFarmMenu = {}
            for _, group in ipairs(farmGuides) do
                createMenu(group, validatedFarmMenu)
            end
            if #validatedFarmMenu > 0 then
                tinsert(menuList, {
                    text = "Validated & Fixed Guides",
                    notCheckable = 1,
                    hasArrow = true,
                    menuList = validatedFarmMenu,
                })
            end
            local originalFarmMenu = {}
            for _, group in ipairs(originalFarmGuides) do
                createMenu(group, originalFarmMenu)
            end
            if #originalFarmMenu > 0 then
                tinsert(menuList, {
                    text = "Original Upstream Guides",
                    notCheckable = 1,
                    hasArrow = true,
                    menuList = originalFarmMenu,
                })
            end
        else
            for _, group in ipairs(farmGuides) do createMenu(group) end
        end
    end

    if addon.settings.profile.showUnusedGuides and
        (#unusedGuides > 0 or #originalUnusedGuides > 0) then
        tinsert(menuList,
                     {text = L("Unused Guides"), notCheckable = 1, isTitle = 1})
        if addon.gameVersion == 30300 and #originalUnusedGuides > 0 then
            local validatedUnusedMenu = {}
            for _, group in ipairs(unusedGuides) do
                createMenu(group, validatedUnusedMenu)
            end
            if #validatedUnusedMenu > 0 then
                tinsert(menuList, {
                    text = "Validated & Fixed Guides",
                    notCheckable = 1,
                    hasArrow = true,
                    menuList = validatedUnusedMenu,
                })
            end
            local originalUnusedMenu = {}
            for _, group in ipairs(originalUnusedGuides) do
                createMenu(group, originalUnusedMenu)
            end
            if #originalUnusedMenu > 0 then
                tinsert(menuList, {
                    text = "Original Upstream Guides",
                    notCheckable = 1,
                    hasArrow = true,
                    menuList = originalUnusedMenu,
                })
            end
        else
            for _, group in ipairs(unusedGuides) do createMenu(group) end
        end
    end

    tinsert(menuList, {text = "", notCheckable = 1, isTitle = 1})

    local tips = addon.currentGuide and addon.currentGuide.tips
    if tips and #tips > 0 then
        tinsert(menuList, {
            text = "Display Tips",
            func = addon.ShowTips,
            arg1 = "toggle",
            checked = function()
                return not RXPCData.hideTipWindow
            end,

        })
    end

    if addon.game == "CLASSIC" then
        local guide = addon.currentGuide
        local hc = addon.settings.profile.hardcore
        local hctext
        local disabled = guide and (guide.hardcore and hc or guide.softcore and not hc)
        if hc then
            hctext = L("Deactivate Hardcore mode")
        else
            hctext = L("Activate Hardcore mode")
        end

        tinsert(menuList, {
            text = hctext,
            notCheckable = 1,
            func = addon.HardcoreToggle,
            disabled = disabled and 1
        })
    end

    if RXPCData and RXPCData.GA then
        local text = L("Activate the Quest Guide mode")
        tinsert(menuList,
                     {text = text, notCheckable = 1, func = addon.GAToggle})
    elseif addon.farmGuides > 0 then
        local text = L("Activate the Gold Assistant mode")
        tinsert(menuList,
                     {text = text, notCheckable = 1, func = addon.GAToggle})
    end

    tinsert(menuList, {
        text = _G.GAMEOPTIONS_MENU .. "...",
        notCheckable = 1,
        func = function()
            addon.settings.OpenSettings()
        end
    })

    tinsert(menuList, {
        text = L("Import guide"),
        notCheckable = 1,
        func = function()
            addon.settings.OpenSettings('Import')
        end
    })

    if addon.settings.profile and addon.settings.profile.enableTracker then
        -- Don't show leveling report if in Gold Assistant mode
        if not (RXPCData and RXPCData.GA) then
            tinsert(menuList, {
                text = L("Leveling report"),
                notCheckable = 1,
                func = function()
                    addon.tracker:ShowReport(_G.CharacterFrame)
                end
            })
        end
    end

    tinsert(menuList, {
        text = L("Open Feedback Form"),
        notCheckable = 1,
        func = function() addon.comms.OpenBugReport() end
    })

    tinsert(menuList, {
        text = _G.CLOSE,
        notCheckable = 1,
        func = function(self) self:Hide() end
    })

    -- Only update RXPFrame.menuList by default
    if type(menu) ~= 'table' then RXPFrame.menuList = menuList end

    return menuList
end

function addon.UpdateGuideFontSize()
    local size =
        (addon.settings.profile and addon.settings.profile.guideFontSize) or 9

    addon.SetFontSafely(GuideName.text, addon.font, size + 2, "")
    addon.SetFontSafely(Footer.text, addon.font, size, "")

    for _, stepFrame in ipairs(CurrentStepFrame.framePool or {}) do
        if stepFrame.number and stepFrame.number.text then
            stepFrame.number.text:SetFont(addon.font, size, "")
            stepFrame.number:SetHeight(math.max(17, size + 8))
        end
        for _, elementFrame in ipairs(stepFrame.elements or {}) do
            if elementFrame.text then
                elementFrame.text:SetFont(addon.font, size + 2, "")
            end
        end
    end

    for _, frame in ipairs(ScrollChild.framePool or {}) do
        if frame.number and frame.number.text then
            frame.number.text:SetFont(addon.font, math.max(1, size - 1), "")
            frame.number:SetSize(frame.number.text:GetStringWidth() + 2,
                                 math.max(10, size + 2))
        end
        if frame.text then frame.text:SetFont(addon.font, size, "") end
    end

    if addon.currentGuide then
        CurrentStepFrame.UpdateText()
        BottomFrame.UpdateFrame()
        RXPFrame.SetStepFrameAnchor()
    end
end
