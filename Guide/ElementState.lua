local _, addon = ...

local elementState = addon.elementState or {}
addon.elementState = elementState

local states = {
    ACTIVE = "active",
    WAITING = "waiting",
    COMPLETE = "complete",
    SKIPPED = "skipped",
    BLOCKED = "blocked",
    INVALID = "invalid",
    UNKNOWN = "unknown"
}
elementState.states = states

local validStates = {}
for _, state in pairs(states) do validStates[state] = true end

-- Existing guide objects still store completion through their historical
-- boolean fields. This adapter gives diagnostics and new services one stable
-- state model without changing guide serialization or handler behavior.
function elementState:Get(subject)
    if type(subject) ~= "table" then return states.UNKNOWN end
    local explicit = subject.rxpState
    if validStates[explicit] then return explicit end
    if subject.invalid then return states.INVALID end
    if subject.blocked then return states.BLOCKED end
    if subject.completed then return states.COMPLETE end
    if subject.skip then return states.SKIPPED end
    local step = subject.step
    if subject.active or type(step) == "table" and step.active then
        return states.ACTIVE
    end
    return states.WAITING
end

function elementState:Set(subject, state)
    if type(subject) ~= "table" then return false end
    if not validStates[state] then
        error("RXPGuides invalid element state '" .. tostring(state) .. "'", 2)
    end
    subject.rxpState = state
    if state == states.COMPLETE then
        subject.completed = true
    elseif state == states.SKIPPED then
        subject.skip = true
    elseif state == states.ACTIVE then
        subject.active = true
    elseif state == states.WAITING then
        subject.active = nil
    elseif state == states.BLOCKED then
        subject.blocked = true
    elseif state == states.INVALID then
        subject.invalid = true
    end
    return true
end

function elementState:Sync(subject)
    if type(subject) ~= "table" then return states.UNKNOWN end
    subject.rxpState = nil
    return self:Get(subject)
end

addon.GetElementState = function(subject) return elementState:Get(subject) end
addon.services:Register("element-state", elementState, "elementState")

