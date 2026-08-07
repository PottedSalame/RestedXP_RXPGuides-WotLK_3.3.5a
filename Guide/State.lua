local _, addon = ...

local state = addon.guideState or {}
addon.guideState = state

function state:FindStepById(guide, stepId)
    if type(guide) ~= "table" or type(guide.steps) ~= "table" or
        stepId == nil then return nil end
    for index, step in ipairs(guide.steps) do
        if step.stepId ~= nil and
            (step.stepId == stepId or tostring(step.stepId) == tostring(stepId)) then
            return index, step
        end
    end
end

function state:ResolvePosition(guide, stepId, numericStep)
    if type(guide) ~= "table" or type(guide.steps) ~= "table" or
        #guide.steps == 0 then return 1 end
    local byId = self:FindStepById(guide, stepId)
    if byId then return byId, true end
    numericStep = tonumber(numericStep)
    if numericStep and numericStep == math.floor(numericStep) and
        numericStep >= 1 and numericStep <= #guide.steps then
        return numericStep, true
    end
    return 1, false
end

function state:GoToStep(step)
    if addon.GoToStep then return addon.GoToStep(step) end
end

function state:SetStep(step)
    if addon.SetStep then return addon.SetStep(step) end
end

function state:SaveLegacyProgress()
    if addon.SaveCharacterGuideProgress then
        return addon:SaveCharacterGuideProgress()
    end
end

addon.services:Register("guide-state", state, "guideState")
