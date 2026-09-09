local _, addon = ...

if addon.gameVersion ~= 30300 then return end

local _G = _G
local warned

local function Enabled(value)
    return value == true or value == 1
end

local function QuestieAutomationEnabled()
    local questie = _G.Questie
    local db = type(questie) == "table" and questie.db
    local profile = type(db) == "table" and db.profile
    if type(profile) ~= "table" then return false end

    local autoAccept = profile.autoAccept
    local accepts = type(autoAccept) == "table" and
                        Enabled(autoAccept.enabled) or
                        Enabled(profile.autoaccept)
    local autoTurnIn = profile.autoTurnIn
    local turnsIn = type(autoTurnIn) == "table" and
                        Enabled(autoTurnIn.enabled) or
                        Enabled(autoTurnIn) or Enabled(profile.autocomplete) or
                        Enabled(profile.autoturnin)
    return accepts or turnsIn
end

function addon.CheckQuestieAutomationConflict()
    if warned or not addon.settings or not addon.settings.profile or
        not addon.settings.profile.enableQuestAutomation or
        not QuestieAutomationEnabled() then return false end

    warned = true
    local source =
        "Questie quest automation is enabled. Disable Questie's auto-accept and auto-turn-in so RXPGuides can control guide quest order safely."
    local text = addon.locale and addon.locale.Get and
                     addon.locale.Get(source) or source
    if addon.comms and addon.comms.PrettyPrint then
        addon.comms.PrettyPrint(text)
    elseif _G.DEFAULT_CHAT_FRAME and _G.DEFAULT_CHAT_FRAME.AddMessage then
        _G.DEFAULT_CHAT_FRAME:AddMessage("RestedXP Guides: " .. text)
    end
    return true
end

-- Questie normally loads first, but ADDON_LOADED keeps the check safe for
-- unusual load-on-demand arrangements. This module only reads public addon
-- state; it never changes Questie's profile or imports its private modules.
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name ~= "Questie" and
        name ~= "Questie-335" then return end
    if _G.C_Timer and _G.C_Timer.After then
        _G.C_Timer.After(1, addon.CheckQuestieAutomationConflict)
    else
        addon.CheckQuestieAutomationConflict()
    end
end)
