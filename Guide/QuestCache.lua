local _, addon = ...

local questCache = addon.questCache or {}
addon.questCache = questCache

function questCache:GetName(id)
    id = tonumber(id)
    if not id or not addon.GetQuestName then return nil end
    return addon.GetQuestName(id)
end

function questCache:GetObjectives(id, step, useCache)
    id = tonumber(id)
    if not id or not addon.GetQuestObjectives then return nil end
    return addon.GetQuestObjectives(id, step, useCache)
end

function questCache:GetNpcName(id)
    id = tonumber(id)
    if not id or not addon.GetNpcName then return nil end
    return addon.GetNpcName(id)
end

function questCache:GetItemName(id)
    id = tonumber(id)
    if not id or not addon.GetItemName then return nil end
    return addon.GetItemName(id)
end

function questCache:InvalidateTransient()
    if addon.ClearQuestCache then addon.ClearQuestCache() end
end

function questCache:InvalidateNames()
    if type(RXPCData) == "table" then RXPCData.questNameCache = {} end
    if type(RXPData) == "table" then
        RXPData.questNames = {locale = GetLocale()}
    end
end

addon.services:Register("quest-cache", questCache, "questCache")

