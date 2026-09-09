local _, addon = ...

-- A quest reward can emit quest-log and gossip events synchronously on 3.3.5
-- private-server clients. Keep the transaction state outside the UI and the
-- directive frames so every event consumer observes the same barrier while
-- GetQuestReward and third-party secure post-hooks are still running.
local transaction = addon.questRewardTransaction or {}
addon.questRewardTransaction = transaction

local blockedEvents = {
    GOSSIP_SHOW = true,
    QUEST_ACCEPT_CONFIRM = true,
    QUEST_ACCEPTED = true,
    QUEST_COMPLETE = true,
    QUEST_DETAIL = true,
    QUEST_FINISHED = true,
    QUEST_GREETING = true,
    QUEST_LOG_UPDATE = true,
    QUEST_PROGRESS = true,
    QUEST_TURNED_IN = true,
}

local function PositiveNumber(value)
    value = tonumber(value)
    return value and value > 0 and value or nil
end

local function SameRequest(active, request)
    return active and request and active.guide == request.guide and
               active.step == request.step and active.element == request.element and
               active.questId == PositiveNumber(request.questId) and
               active.choice == PositiveNumber(request.choice) and
               active.title == request.title
end

function transaction:Begin(request, now)
    if type(request) ~= "table" or type(request.guide) ~= "table" or
        type(request.step) ~= "table" or type(request.element) ~= "table" then
        return nil, false, "invalid-context"
    end

    local questId = PositiveNumber(request.questId)
    local choice = PositiveNumber(request.choice)
    local title = type(request.title) == "string" and request.title or nil
    if not questId or not choice or not title or title == "" then
        return nil, false, "invalid-reward"
    end

    if self.active then
        if SameRequest(self.active, request) then
            return self.active.serial, false, "duplicate"
        end
        return nil, false, "busy"
    end

    self.serial = (tonumber(self.serial) or 0) + 1
    self.active = {
        serial = self.serial,
        phase = "queued",
        guide = request.guide,
        guideKey = request.guideKey,
        step = request.step,
        stepId = request.stepId,
        stepIndex = tonumber(request.stepIndex),
        currentStep = tonumber(request.currentStep),
        element = request.element,
        questId = questId,
        title = title,
        choice = choice,
        numChoices = tonumber(request.numChoices) or 0,
        startedAt = tonumber(now) or 0,
        events = {},
    }
    return self.active.serial, true
end

function transaction:Get(serial)
    local active = self.active
    if not active or serial and tonumber(serial) ~= active.serial then return end
    return active
end

function transaction:IsActive()
    return self.active ~= nil
end

function transaction:IsSubmitting()
    return self.active and self.active.phase == "submitting" or false
end

function transaction:IsReleasing()
    return self.active and self.active.phase == "releasing" or false
end

function transaction:SetPhase(serial, phase, now)
    local active = self:Get(serial)
    if not active or type(phase) ~= "string" then return false end
    active.phase = phase
    active.phaseChangedAt = tonumber(now) or active.phaseChangedAt or 0
    return true
end

function transaction:SetReservation(serial, reservation)
    local active = self:Get(serial)
    if not active then return false end
    active.reservation = reservation
    return true
end

function transaction:ShouldDefer(event)
    return self.active ~= nil and (event == nil or blockedEvents[event]) or false
end

function transaction:Observe(event, arg1, arg2, now)
    local active = self.active
    if not active or not blockedEvents[event] then return false end

    active.events[event] = true
    active.lastEventAt = tonumber(now) or active.lastEventAt or 0
    local rewardSubmitted = active.phase == "submitting" or
                                active.phase == "settling"
    if event == "QUEST_TURNED_IN" and rewardSubmitted then
        local questId = PositiveNumber(arg1)
        if questId and questId == active.questId then
            active.turnInConfirmed = true
            active.confirmedQuestId = questId
        end
    elseif event == "QUEST_FINISHED" and rewardSubmitted then
        active.questFinished = true
    elseif event == "QUEST_LOG_UPDATE" then
        active.questLogUpdated = true
    elseif event == "QUEST_ACCEPTED" then
        active.acceptedQuestId = PositiveNumber(arg2) or PositiveNumber(arg1)
    end
    return true
end

function transaction:HasAuthoritativeConfirmation(serial)
    local active = self:Get(serial)
    return active and (active.turnInConfirmed or active.questFinished) or false
end

function transaction:Finish(serial)
    local active = self:Get(serial)
    if not active then return false end
    self.active = nil
    return active
end

function transaction:Cancel(serial, reason)
    local active = self:Get(serial)
    if not active then return false end
    active.cancelReason = reason
    self.active = nil
    return active
end

function transaction:Reset(reason)
    if self.active then return self:Cancel(self.active.serial, reason) end
end

addon.services:Register("quest-reward-transaction", transaction,
                        "questRewardTransaction")
