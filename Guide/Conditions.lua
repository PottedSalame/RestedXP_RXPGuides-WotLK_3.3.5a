local _, addon = ...

local conditions = addon.guideConditions or {}
addon.guideConditions = conditions

function conditions:Register(name, predicate)
    if type(name) ~= "string" or name == "" or type(predicate) ~= "function" then
        error("RXPGuides conditions require a name and predicate", 2)
    end
    local current = addon.stepLogic[name]
    if current and current ~= predicate then
        error("RXPGuides condition '" .. name .. "' is already registered", 2)
    end
    addon.stepLogic[name] = predicate
    return predicate
end

function conditions:Applies(expression, customClass)
    return addon.applies(expression, customClass)
end

function conditions:IsStepShown(step, ...)
    return addon.IsStepShown(step, ...)
end

function conditions:List()
    local result = {}
    for name in pairs(addon.stepLogic or {}) do result[#result + 1] = name end
    table.sort(result)
    return result
end

addon.services:Register("guide-conditions", conditions, "guideConditions")

