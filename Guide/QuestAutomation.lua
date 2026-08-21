local _, addon = ...

local automation = addon.questAutomation or {}
addon.questAutomation = automation
automation.acceptState = addon.questAcceptState
automation.state = automation.acceptState.data

function automation:IsAcceptEligible(titleOrId)
    return addon.QuestAutoAccept and addon.QuestAutoAccept(titleOrId) or nil
end

function automation:NormalizeAcceptedId(arg1, arg2)
    if addon.NormalizeQuestAcceptedId then
        return addon.NormalizeQuestAcceptedId(arg1, arg2)
    end
    return arg2 or arg1
end

function automation:GetRewardChoice(titleOrId)
    if addon.GetStepQuestReward then
        return addon.GetStepQuestReward(titleOrId)
    end
    return 0
end

function automation:Handle(event, ...)
    if addon.QuestAutomation then
        return addon:QuestAutomation(event, ...)
    end
end

function automation:Retry()
    if addon.QuestAutomation then return addon:QuestAutomation() end
end

function automation:GetPendingAccept()
    return self.acceptState:GetPending(GetTime(), 5)
end

function automation:ClearPendingAccept()
    self.acceptState:ClearPending()
end

function automation:ResetTransient()
    self.acceptState:Reset()
    if addon.automationOrder and addon.automationOrder.ClearQuestReservation then
        addon.automationOrder:ClearQuestReservation()
    end
    for index = 1, 3 do
        addon.scheduler:Cancel("quest-engine", "automation-retry-" .. index)
    end
    addon.scheduler:Cancel("quest-engine", "reconcile-pending-accept")
end

addon.services:Register("quest-automation", automation, "questAutomation")
