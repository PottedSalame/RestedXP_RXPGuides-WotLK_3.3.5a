local _, addon = ...

-- Allows you to set your hearthstone as you teleport away to your previous location at the end of the hearthstone cast.
-- Only works if the binding confirmation and the HS spell cast are processed in the same batch (<10ms as of patch 1.14)
local HSframe = CreateFrame("Frame");
local currentFPS = GetCVar("maxfps")
local HSstart = 0
local barLabel = "Hearthstone"
local batchingWindow = 0.006
local bindConfirmation = string.gsub(CONFIRM_BINDER,"%%s",".-")
local IsCurrentSpell = C_Spell and C_Spell.IsCurrentSpell or _G.IsCurrentSpell
local fpsRestored = true

local ConfirmBinder
if C_PlayerInteractionManager and C_PlayerInteractionManager.ConfirmationInteraction and Enum and Enum.PlayerInteractionType and Enum.PlayerInteractionType.Binder then
    ConfirmBinder = function()
        return C_PlayerInteractionManager.ConfirmationInteraction(Enum.PlayerInteractionType.Binder)
    end
else
    ConfirmBinder = _G.ConfirmBinder
end

local function RestoreMaxFPS()
    if fpsRestored then return end
    fpsRestored = true
    if currentFPS ~= nil then pcall(SetCVar, "maxfps", currentFPS) end
end

local function StopHSTimer()
    HSframe:SetScript("OnUpdate", nil)
    RestoreMaxFPS()
    HSstart = 0
    addon.isCastingHS = false
    if addon.StopTimer then addon.StopTimer(barLabel) end
end

addon.StopHearthBatching = StopHSTimer

local function SwitchBindLocation()
    if HSstart == 0 or not addon.settings.profile.enableHSbatch then
        StopHSTimer()
        return
    end
    if GetTime() - HSstart > 10 - batchingWindow then
        if type(ConfirmBinder) == "function" then pcall(ConfirmBinder) end
        StopHSTimer()
        --print('bind-ok')
    elseif GetFramerate() < 20 then
        RestoreMaxFPS()
    end
end
--[[
hooksecurefunc("SetCVar",function(n,v)
    if n == "maxfps" then
        print(n,v)--ok
        C_Timer.After(1,function()
            print(GetCVar("maxfps"))
        end)
    end
end)
]]

local function StartHSTimer()
    if HSstart ~= 0 or not addon.settings.profile.enableHSbatch or
        type(ConfirmBinder) ~= "function" then return end

    local text = _G.StaticPopup1 and
                     (_G.StaticPopup1.text or _G.StaticPopup1.Text)
    local bind = text and text:GetText() or ""
    if bind == "" or not bind:find(bindConfirmation) then return end

    local size = tonumber(addon.settings.profile.batchSize) or 6
    batchingWindow = math.max(0.001, size / 1e3)
    currentFPS = GetCVar("maxfps")
    fpsRestored = false
    HSstart = GetTime()
    HSframe:SetScript("OnUpdate", SwitchBindLocation)
    pcall(SetCVar, "maxfps", "300")
    addon.isCastingHS = 0.5
    if addon.StartTimer then
        addon.StartTimer(10 - batchingWindow, barLabel)
    end
end

HSframe:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_ENTERING_WORLD" then
        if HSstart ~= 0 then StopHSTimer() end
    elseif unit == "player" and HSstart ~= 0 then
        -- 3.3.5 reports spell name/rank instead of a spell ID. While batching
        -- is active, any failed/interrupted player cast is the monitored hearth.
        StopHSTimer()
    end
end)
HSframe:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
HSframe:RegisterEvent("UNIT_SPELLCAST_FAILED")
HSframe:RegisterEvent("PLAYER_ENTERING_WORLD")

if _G.C_Container and _G.C_Container.UseContainerItem then -- DF+
    hooksecurefunc(C_Container, "UseContainerItem", function(...)
        if (C_Container.GetContainerItemID(...) == 6948) then
            StartHSTimer()
        end
    end)
else
    hooksecurefunc("UseContainerItem", function(...)
        if _G.GetContainerItemID(...) == 6948 then StartHSTimer() end
    end)
end

hooksecurefunc("UseAction", function(...)
    local event, id = GetActionInfo(...)
    --print(event,id,IsCurrentSpell(id))
    if (event == "item" and id == 6948) or
        (event == "macro" and (IsCurrentSpell(8690) or IsCurrentSpell(556))) or
        (event == "spell" and id == 556) then StartHSTimer() end
end)
