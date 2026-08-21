local _, addon = ...

-- Guide steps are authored in a deliberate order, but every active element has
-- its own event frame.  WoW does not guarantee which frame receives an event
-- first, so automated interactions need an explicit ordering service rather
-- than relying on frame registration order.
local automationOrder = addon.automationOrder or {}
addon.automationOrder = automationOrder
local QUEST_SELECTION_LIFETIME = 5

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

local function IsInteractionStepActive(element, kind)
    local step = type(element) == "table" and element.step
    if type(step) ~= "table" or step.completed then return false end
    if step.active then return true end
    if kind ~= "accept" then return false end

    -- Accept directives from the immediately following step are intentionally
    -- registered so same-NPC and cross-guide follow-ups can be taken before a
    -- delayed quest-log update advances the visible guide.
    local index = tonumber(step.index)
    local steps = addon.currentGuide and addon.currentGuide.steps
    local previous = index and index > 1 and type(steps) == "table" and
                         steps[index - 1]
    return type(previous) == "table" and previous.active and true or false
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

-- Quest-giver panels are already a filtered list of interactions which the
-- server says are available at this NPC.  Do not let an unrelated navigation,
-- target, or text element earlier in the step block those interactions.  Pick
-- the earliest authored quest from the visible candidates, then reserve that
-- exact element while the legacy client changes from gossip to quest panels.
function automationOrder:SelectQuest(candidates)
    if type(candidates) ~= "table" then return end

    -- Selecting a quest changes the legacy gossip panel asynchronously.  Some
    -- 3.3.5 servers send the refreshed GOSSIP_SHOW before the authoritative
    -- QUEST_ACCEPTED/QUEST_TURNED_IN event.  Do not replace the in-flight
    -- reservation in that window: doing so can attribute the confirmation for
    -- quest A to quest B and leave one interaction at a multi-quest NPC behind.
    local _, reservation = self:GetQuestReservation(nil)
    if reservation then return end

    local selected
    for _, candidate in ipairs(candidates) do
        local element = type(candidate) == "table" and candidate.element
        if IsInteractionStepActive(element, candidate.kind) and
            not element.completed and not element.skip and not element.invalid and
            (not selected or self:IsBefore(element, selected.element)) then
            selected = candidate
        end
    end
    return selected
end

function automationOrder:ReserveQuest(candidate, now)
    if type(candidate) ~= "table" or type(candidate.element) ~= "table" then
        return false
    end

    now = tonumber(now) or (GetTime and GetTime()) or 0
    local reservedElement, reservation = self:GetQuestReservation(nil, now)
    if reservation and reservedElement ~= candidate.element then
        return false
    end
    self.questReservation = {
        element = candidate.element,
        kind = candidate.kind,
        questId = tonumber(candidate.questId or candidate.element.questId),
        time = now,
    }
    return true
end

function automationOrder:GetQuestReservation(kind, now)
    local reservation = self.questReservation
    if not reservation then return end
    now = tonumber(now) or (GetTime and GetTime()) or 0
    if now - (tonumber(reservation.time) or 0) > QUEST_SELECTION_LIFETIME then
        self.questReservation = nil
        return
    end
    if kind and reservation.kind and reservation.kind ~= kind then return end
    return reservation.element, reservation
end

function automationOrder:IsQuestReady(element, kind, now)
    if type(element) ~= "table" then return false end
    if not IsInteractionStepActive(element, kind) or
        element.completed or element.skip or element.invalid then
        return false
    end

    -- A turn-in and an accept are still competing uses of the same NPC panel.
    -- Inspect the reservation without filtering by kind so an in-flight
    -- turn-in cannot be bypassed by a newly opened accept detail page.
    local reservationElement, reservation = self:GetQuestReservation(nil, now)
    if not reservation then return true end
    if kind and reservation.kind and reservation.kind ~= kind then return false end
    return reservationElement == element
end

function automationOrder:MarkQuestSubmitted(kind, questId, now)
    local element, reservation = self:GetQuestReservation(kind, now)
    if not reservation then return false end

    questId = tonumber(questId)
    local reservedId = tonumber(reservation.questId or
                                    (element and element.questId))
    if questId and reservedId and questId ~= reservedId then return false end

    now = tonumber(now) or (GetTime and GetTime()) or 0
    reservation.questId = questId or reservedId
    reservation.submitted = true
    reservation.submittedAt = now
    reservation.time = now
    return true, reservation
end

-- Return an in-flight selection only when it can represent the confirmation
-- being processed.  QUEST_TURNED_IN normally supplies a numeric ID, while a
-- few private-server builds omit it; the latter safely falls back to the one
-- reservation which is prevented from being overwritten above.
function automationOrder:GetQuestConfirmation(kind, questId, now)
    local element, reservation = self:GetQuestReservation(kind, now)
    if not reservation then return end
    questId = tonumber(questId)
    local reservedId = tonumber(reservation.questId or
                                    (element and element.questId))
    if questId and reservedId and questId ~= reservedId then return end
    return element, reservation
end

function automationOrder:ClearQuestReservation(element, kind)
    local reservation = self.questReservation
    if not reservation then return end
    if element and reservation.element ~= element then return end
    if kind and reservation.kind and reservation.kind ~= kind then return end
    self.questReservation = nil
end

function addon.IsAutomationElementReady(element)
    return automationOrder:IsReady(element)
end

function addon.IsQuestAutomationElementReady(element, kind)
    return automationOrder:IsQuestReady(element, kind)
end

addon.services:Register("automation-order", automationOrder, "automationOrder")
