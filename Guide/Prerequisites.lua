local _, addon = ...

local prerequisites = addon.prerequisites or {}
addon.prerequisites = prerequisites

-- A negative quest ID is the guide syntax for "not turned in". Normalize
-- the sign before quest conversion so the 3.3.5 completion APIs never see an
-- invalid negative ID. Mixing positive and negative IDs in one condition is
-- ambiguous because the legacy handler combines IDs with OR semantics.
function prerequisites:NormalizeTurnInConditionIds(values)
    if type(values) ~= "table" then return nil, nil, "invalid quest list" end

    local ids = {}
    local reverse
    for _, value in ipairs(values) do
        local id = tonumber(value)
        if id then
            local valueIsReverse = id < 0
            if reverse ~= nil and reverse ~= valueIsReverse then
                return nil, nil, "mixed positive and negative quest IDs"
            end
            reverse = valueIsReverse
            ids[#ids + 1] = math.abs(id)
        end
    end
    return ids, reverse or false
end

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
