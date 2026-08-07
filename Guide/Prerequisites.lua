local _, addon = ...

local prerequisites = addon.prerequisites or {}
addon.prerequisites = prerequisites

function prerequisites:IsTurnedInLater(id)
    id = tonumber(id)
    if not id or type(addon.questTurnIn) ~= "table" then return false end
    if type(addon.questTurnIn[id]) == "table" then return true end

    -- Quest elements are also indexed by localized title. Deduplicate the
    -- values and inspect their typed quest IDs instead of assuming every key is
    -- numeric.
    local seen = {}
    for _, element in pairs(addon.questTurnIn) do
        if type(element) == "table" and not seen[element] then
            seen[element] = true
            if tonumber(element.questId) == id then return true end
        end
    end
    return false
end

function prerequisites:GetState(id, group, state)
    if not addon.GetQuestPreReqState then return nil, nil end
    return addon.GetQuestPreReqState(id, group, state)
end

function prerequisites:GetMissing(id, group, state)
    local complete, missing = self:GetState(id, group, state)
    return complete, type(missing) == "table" and missing or {}
end

addon.IsQuestTurnedInLater = function(id)
    return prerequisites:IsTurnedInLater(id)
end
addon.services:Register("prerequisites", prerequisites, "prerequisites")

