local _, addon = ...

-- Own the short-lived state used to reconcile 3.3.5 quest acceptance events.
-- The client normally reports QUEST_ACCEPTED(logIndex), but some private-server
-- cores omit or delay that index. Keeping this policy independent from the UI
-- automation makes the same-NPC turn-in/accept race deterministic and testable.
local acceptState = addon.questAcceptState or {}
addon.questAcceptState = acceptState

local data = addon.questAutomationState or {
    turnInTimer = 0,
    retrySerial = 0,
    confirmedAccepts = {}
}
addon.questAutomationState = data
acceptState.data = data

local function Timestamp(value)
    value = tonumber(value)
    return value or 0
end

function acceptState:Begin(questId, title, element, now)
    questId = tonumber(questId)
    self.data.pendingAccept = {
        questId = questId and questId > 0 and questId or nil,
        title = type(title) == "string" and title or nil,
        element = type(element) == "table" and element or nil,
        started = Timestamp(now)
    }
    return self.data.pendingAccept
end

function acceptState:GetPending(now, lifetime)
    local pending = self.data.pendingAccept
    if not pending then return end
    lifetime = math.max(tonumber(lifetime) or 5, 0)
    if Timestamp(now) - Timestamp(pending.started) > lifetime then
        self.data.pendingAccept = nil
        return
    end
    return pending
end

function acceptState:ClearPending()
    self.data.pendingAccept = nil
end

function acceptState:Commit(questId, now, lifetime)
    questId = tonumber(questId)
    if not questId or questId <= 0 then return end

    now = Timestamp(now)
    local pending = self:GetPending(now, lifetime)
    local confirmed = self.data.confirmedAccepts
    if type(confirmed) ~= "table" then
        confirmed = {}
        self.data.confirmedAccepts = confirmed
    end

    local alreadyCommitted = confirmed[questId] and
                                 now - Timestamp(confirmed[questId]) < 5
    confirmed[questId] = now

    -- Confirmation history only suppresses duplicate events. Prune it so a
    -- long leveling session cannot retain every accepted quest ID.
    for confirmedId, confirmedAt in pairs(confirmed) do
        if now - Timestamp(confirmedAt) > 30 then
            confirmed[confirmedId] = nil
        end
    end

    local element
    if pending and (not pending.questId or pending.questId == questId) then
        element = pending.element
        self.data.pendingAccept = nil
    end
    return {
        questId = questId,
        element = element,
        alreadyCommitted = alreadyCommitted and true or false
    }
end

function acceptState:MarkTurnIn(now)
    self.data.turnInTimer = Timestamp(now)
end

function acceptState:WasRecentTurnIn(now, window)
    local turnInTimer = Timestamp(self.data.turnInTimer)
    return turnInTimer > 0 and Timestamp(now) - turnInTimer <
               (tonumber(window) or 0.5)
end

function acceptState:ClearTurnIn()
    self.data.turnInTimer = 0
end

function acceptState:NextRetrySerial()
    self.data.retrySerial = (tonumber(self.data.retrySerial) or 0) + 1
    return self.data.retrySerial
end

function acceptState:IsRetryCurrent(serial)
    return tonumber(serial) == tonumber(self.data.retrySerial)
end

function acceptState:Reset()
    self.data.pendingAccept = nil
    self.data.turnInTimer = 0
    self:NextRetrySerial()
end

addon.services:Register("quest-accept-state", acceptState, "questAcceptState")
