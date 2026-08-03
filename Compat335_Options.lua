--[[ ------------------------------------------------------------------------
    Compat335_Options.lua

    Adds a "3.3.5a" sub-panel under RestedXP Guides in Interface -> AddOns,
    holding adjustments specific to the 3.3.5a backport:
      * Optionally hide the "Active Targets" frame
      * Give waypoint pins a solid dark background so the numbers are readable
      * Optionally swap the navigation arrow for a plain Blizzard arrow texture
      * Automatically repair at merchants with personal or guild-bank funds

    Settings live in the RXP335 saved variable (declared in the TOC). The pin
    background is read when a pin frame is first created, so a /reload applies a
    change to that one; the others apply immediately.
------------------------------------------------------------------------------ ]]

local addonName, addon = ...
local _G = _G

-- Only meaningful on the 3.3.5a build.
if _G.C_Timer and _G.C_Map and _G.C_QuestLog and (select(4, GetBuildInfo()) or 0) > 30300 then
    return
end

RXP335 = RXP335 or {}
local defaults = {
    hideTargetingFrame = false,
    pinBackground = true,
    plainArrow = false,
    autoRepairPersonal = false,
    autoRepairGuild = false,
}
for k, v in pairs(defaults) do
    if RXP335[k] == nil then RXP335[k] = v end
end

-- Earlier backport builds wrote `true` as the default, so merely changing the
-- defaults table would leave every existing installation hidden forever.  Do
-- a single migration; subsequent user choices are preserved normally.
if not RXP335.activeTargetsDefaultExposed then
    RXP335.hideTargetingFrame = false
    RXP335.activeTargetsDefaultExposed = true
end

-- Backfill AceGUI widget methods that the pack's (older) AceGUI-3.0 lacks but
-- RXP's leveling tracker uses: EnableResize (Frame) and SetJustifyH (Label).
-- Only adds them when missing, so newer AceGUI versions are untouched.
do
    local AceGUI = _G.LibStub and _G.LibStub("AceGUI-3.0", true)
    if AceGUI and not AceGUI.__rxp335patched then
        AceGUI.__rxp335patched = true
        local origCreate = AceGUI.Create
        AceGUI.Create = function(self, widgetType)
            local widget = origCreate(self, widgetType)
            if widget then
                if widget.EnableResize == nil then
                    widget.EnableResize = function() end
                end
                if widget.SetJustifyH == nil then
                    widget.SetJustifyH = function(w, justify)
                        local fs = w.label or w.text
                        if fs and fs.SetJustifyH then fs:SetJustifyH(justify) end
                    end
                end
            end
            return widget
        end
    end
end

--=========================================================================
-- Apply functions
--=========================================================================
local PLAIN_ARROW = "Interface\\Minimap\\MinimapArrow"

local function ApplyTargetingFrame()
    local t = addon.targeting
    local tf = t and t.activeTargetFrame
    if not tf then return end
    if RXP335.hideTargetingFrame then
        tf:Hide()
        if not tf.__c335ShowHook then
            tf.__c335ShowHook = true
            hooksecurefunc(tf, "Show", function(self)
                if RXP335.hideTargetingFrame then self:Hide() end
            end)
        end
    elseif t.UpdateTargetFrame then
        pcall(t.UpdateTargetFrame, t)
    end
end

local function ApplyArrow()
    local af = addon.arrowFrame
    if not af or not af.texture then return end
    if RXP335.plainArrow then
        af.texture:SetTexture(PLAIN_ARROW)
        if not af.__c335ArrowHook then
            af.__c335ArrowHook = true
            -- UpdateVisuals is re-run on theme changes and would restore the
            -- RXP arrow texture; re-apply ours after it.
            hooksecurefunc(af, "UpdateVisuals", function(self)
                if RXP335.plainArrow and self.texture then
                    self.texture:SetTexture(PLAIN_ARROW)
                end
            end)
        end
    elseif af.UpdateVisuals then
        pcall(af.UpdateVisuals, af)
    end
end

-- Exposed so map.lua can query the pin-background preference at pin creation.
function addon.Compat335_PinBackground()
    return RXP335 and RXP335.pinBackground
end

local function ApplyAll()
    pcall(ApplyTargetingFrame)
    pcall(ApplyArrow)
end

--=========================================================================
-- Automatic merchant repairs
--=========================================================================
local repairFrame = CreateFrame("Frame")
local repairSerial = 0

local function MerchantIsOpen()
    return _G.MerchantFrame and _G.MerchantFrame:IsShown()
end

local function GetOutstandingRepairCost()
    if type(_G.CanMerchantRepair) ~= "function" or
        not _G.CanMerchantRepair() or
        type(_G.GetRepairAllCost) ~= "function" then return 0 end
    local cost = tonumber((_G.GetRepairAllCost())) or 0
    return math.max(cost, 0)
end

local function RepairWithPersonalMoney(serial)
    if serial ~= repairSerial or not RXP335.autoRepairPersonal or
        not MerchantIsOpen() or type(_G.RepairAllItems) ~= "function" then
        return
    end
    local cost = GetOutstandingRepairCost()
    if cost > 0 and (_G.GetMoney and (_G.GetMoney() or 0) >= cost) then
        pcall(_G.RepairAllItems)
    end
end

local function TryAutomaticRepair()
    repairSerial = repairSerial + 1
    local serial = repairSerial
    if not (RXP335.autoRepairPersonal or RXP335.autoRepairGuild) or
        type(_G.RepairAllItems) ~= "function" then return end

    -- Let the stock merchant frame finish updating its repair state first.
    C_Timer.After(0, function()
        if serial ~= repairSerial or not MerchantIsOpen() or
            GetOutstandingRepairCost() <= 0 then return end

        local canUseGuild = RXP335.autoRepairGuild and
                                type(_G.CanGuildBankRepair) == "function" and
                                _G.CanGuildBankRepair()
        if canUseGuild then
            -- The server remains authoritative for the guild withdrawal limit.
            -- Recheck shortly afterward: if guild funds were insufficient, the
            -- personal toggle may safely cover only the outstanding remainder.
            pcall(_G.RepairAllItems, 1)
            C_Timer.After(0.25, function()
                RepairWithPersonalMoney(serial)
            end)
        else
            RepairWithPersonalMoney(serial)
        end
    end)
end

repairFrame:RegisterEvent("MERCHANT_SHOW")
repairFrame:RegisterEvent("MERCHANT_CLOSED")
repairFrame:SetScript("OnEvent", function(_, event)
    if event == "MERCHANT_SHOW" then
        TryAutomaticRepair()
    else
        repairSerial = repairSerial + 1
    end
end)

--=========================================================================
-- Options panel (nested under the RXP interface options)
--=========================================================================
local function BuildOptions()
    return {
        type = "group",
        name = "3.3.5a",
        args = {
            header = {
                type = "description",
                order = 0,
                fontSize = "medium",
                name = "Compatibility and quality-of-life options for the 3.3.5a (Wrath) backport.\n",
            },
            hideTargetingFrame = {
                type = "toggle",
                order = 1,
                width = "full",
                name = "Hide the Active Targets frame",
                desc = "Hides the working Active Targets window if you prefer to use only the targeting macro and nameplate markers.",
                get = function() return RXP335.hideTargetingFrame end,
                set = function(_, v) RXP335.hideTargetingFrame = v; ApplyTargetingFrame() end,
            },
            pinBackground = {
                type = "toggle",
                order = 2,
                width = "full",
                name = "Readable waypoint pins",
                desc = "Draws a solid dark background behind waypoint pin numbers so they are readable. Takes effect after a /reload.",
                get = function() return RXP335.pinBackground end,
                set = function(_, v) RXP335.pinBackground = v end,
            },
            plainArrow = {
                type = "toggle",
                order = 3,
                width = "full",
                name = "Use a plain navigation arrow",
                desc = "Replaces the RXP navigation arrow texture (which can render with white edge artifacts on 3.3.5a) with a plain Blizzard arrow.",
                get = function() return RXP335.plainArrow end,
                set = function(_, v) RXP335.plainArrow = v; ApplyArrow() end,
            },
            repairHeader = {
                type = "header",
                order = 4,
                name = "Automatic repairs",
            },
            autoRepairPersonal = {
                type = "toggle",
                order = 5,
                width = "full",
                name = "Automatically repair using my money",
                desc = "Repairs all damaged equipment when you open a repair merchant. If guild repair is also enabled, your money is used only for costs the guild repair did not cover.",
                get = function() return RXP335.autoRepairPersonal end,
                set = function(_, v)
                    RXP335.autoRepairPersonal = v
                    if v and MerchantIsOpen() then TryAutomaticRepair() end
                end,
            },
            autoRepairGuild = {
                type = "toggle",
                order = 6,
                width = "full",
                name = "Automatically repair using guild money",
                desc = "Attempts to repair from the guild bank when you have permission. This option never spends your own money unless the personal-money option is also enabled.",
                get = function() return RXP335.autoRepairGuild end,
                set = function(_, v)
                    RXP335.autoRepairGuild = v
                    if v and MerchantIsOpen() then TryAutomaticRepair() end
                end,
            },
            reloadNote = {
                type = "description",
                order = 10,
                name = "\n|cff909090Tip: after toggling 'Readable waypoint pins', use /reload for it to take effect.|r",
            },
        },
    }
end

--=========================================================================
-- Register once RXP's own options panel exists.
--=========================================================================
local function Register()
    if not (addon.RXPOptions and addon.RXPOptions.name and _G.LibStub) then return false end
    local AceConfig = _G.LibStub("AceConfig-3.0", true)
    local AceConfigDialog = _G.LibStub("AceConfigDialog-3.0", true)
    if not (AceConfig and AceConfigDialog) then return false end

    local key = addon.RXPOptions.name .. "/Compat335"
    AceConfig:RegisterOptionsTable(key, BuildOptions())
    AceConfigDialog:AddToBlizOptions(key, "3.3.5a", addon.RXPOptions.name)
    ApplyAll()
    return true
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self)
    -- Retry a few times in case RXP initialises slightly later.
    if Register() then self:UnregisterAllEvents() end
end)
