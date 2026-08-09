local _, addon = ...

-- Guide steps are authored in a deliberate order, but every active element has
-- its own event frame.  WoW does not guarantee which frame receives an event
-- first, so automated interactions need an explicit ordering service rather
-- than relying on frame registration order.
local automationOrder = addon.automationOrder or {}
addon.automationOrder = automationOrder

local function IsPending(element)
    if type(element) ~= "table" then return false end
    if element.completed or element.skip or element.textOnly or element.invalid then
        return false
    end
    return not (type(element.step) == "table" and element.step.completed)
end

local function GetPosition(element)
    if type(element) ~= "table" then return math.huge, math.huge end
    local step = element.step
    local stepIndex = type(step) == "table" and tonumber(step.index) or nil
    local elementIndex = math.huge
    if type(step) == "table" and type(step.elements) == "table" then
        for index, candidate in ipairs(step.elements) do
            if candidate == element then
                elementIndex = index
                break
            end
        end
    end
    return stepIndex or math.huge, elementIndex
end

function automationOrder:IsBefore(left, right)
    local leftStep, leftElement = GetPosition(left)
    local rightStep, rightElement = GetPosition(right)
    if leftStep ~= rightStep then return leftStep < rightStep end
    return leftElement < rightElement
end

-- An automated directive may run only after the preceding authored elements
-- in its own step have resolved.  This keeps quest, gossip, and travel actions
-- deterministic without imposing an unsafe global "accept before turn-in"
-- rule (many follow-up accepts require their preceding turn-in).
function automationOrder:IsReady(element)
    if type(element) ~= "table" then return false end
    if not IsPending(element) then return false end
    local step = element.step
    if type(step) ~= "table" or not step.active or step.completed then
        return false
    end
    local elements = step.elements
    if type(elements) ~= "table" then return true end

    for _, candidate in ipairs(elements) do
        if candidate == element then return true end
        if IsPending(candidate) then return false, candidate end
    end

    -- Generated compatibility elements do not always live in step.elements.
    -- Preserve their historical behavior instead of permanently blocking them.
    return true
end

function automationOrder:Select(candidates)
    if type(candidates) ~= "table" then return end
    local selected
    for _, candidate in ipairs(candidates) do
        if type(candidate) == "table" and type(candidate.element) == "table" and
            self:IsReady(candidate.element) and
            (not selected or self:IsBefore(candidate.element, selected.element)) then
            selected = candidate
        end
    end
    return selected
end

function addon.IsAutomationElementReady(element)
    return automationOrder:IsReady(element)
end

addon.services:Register("automation-order", automationOrder, "automationOrder")
