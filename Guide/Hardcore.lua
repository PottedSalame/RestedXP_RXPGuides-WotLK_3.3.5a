-- Family identity is operational data; labels and picker order are display only.
local _, addon = ...
local L = addon.locale.Get
local hardcore = {}
addon.hardcoreGuides = hardcore

hardcore.families = {
    {id = "tbc", group = "Original Guides - RestedXP Hardcore TBC Guides",
        label = L("Upstream TBC (Experimental, 3.3.5-adapted)")},
    {id = "classic", group = "Original Guides - RestedXP Hardcore Classic Guides",
        label = L("Upstream Classic (Experimental, 3.3.5-adapted)")},
    {id = "curated", group = "RestedXP Hardcore Guides",
        label = L("Curated Experimental (3.3.5-adapted)")},
}

function hardcore:GetFamily(guide)
    if type(guide) ~= "table" then return end
    for _, family in ipairs(self.families) do
        for _, faction in ipairs({"A", "H"}) do
            if guide.group == family.group .. " (" .. faction .. ")" then
                return family, faction
            end
        end
    end
end

function hardcore:IsFamily(guide)
    return self:GetFamily(guide) ~= nil
end

function hardcore:IsEnabled()
    return addon.gameVersion == 30300 and addon.settings.profile.hardcore == true
end

function hardcore:IsToggleLocked()
    return self:IsEnabled() and addon.currentGuide and
        not not addon.currentGuide.hardcore
end

function hardcore:AllowsTransition(source, destination)
    local from, faction = self:GetFamily(source)
    local to, targetFaction = self:GetFamily(destination)
    if not from then return not to end
    return from == to and faction == targetFaction and
        not not destination.hardcore and not destination.softcore
end

function hardcore:OpenGuides()
    if addon.guideHub and addon.guideHub.OpenHardcoreGuides then
        return addon.guideHub:OpenHardcoreGuides()
    end
end

function hardcore:CancelPendingSelection()
    self.selectionSerial = (self.selectionSerial or 0) + 1
    if addon.comms.CancelChoice then addon.comms:CancelChoice("RXP_HARDCORE_GUIDE_CONFIRM") end
end

function hardcore:Apply(enabled)
    addon.settings.profile.hardcore = enabled == true
    self:CancelPendingSelection()
    if addon.guideState then addon.guideState:CancelAdvance() end
    if addon.questAutomation and addon.questAutomation.ResetForGuideChange then
        addon.questAutomation:ResetForGuideChange()
    end
    if addon.speedrunDeathwarp then addon.speedrunDeathwarp:Scan() end
    if addon.RXPFrame and addon.RXPFrame.GenerateMenuTable then
        addon.RXPFrame:GenerateMenuTable()
    end
    if addon.RenderFrame and addon.enabledFrames then addon.RenderFrame(true, true) end
end

function hardcore:SetEnabled(enabled)
    enabled = enabled == true
    if enabled == self:IsEnabled() then return true end
    if not enabled and self:IsToggleLocked() then
        addon.comms:PopupNotification("RXP_HARDCORE_MODE_LOCKED", L(
            "Choose a non-Hardcore guide before disabling Hardcore mode. Your Hardcore checkpoint will be retained."))
        return false
    end
    if enabled then
        local available = false
        for _, guide in pairs(addon.guides or {}) do
            if self:IsFamily(guide) and guide.hardcore and not guide.disabled and
                (not addon.IsGuideActive or addon.IsGuideActive(guide)) then
                available = true
                break
            end
        end
        if not available then
            addon.comms:PopupNotification("RXP_HARDCORE_UNAVAILABLE", L(
                "No experimental Hardcore routes are loaded for this character. Your guide and mode have not changed."))
            return false
        end
    end
    self:Apply(enabled)
    if enabled then self:OpenGuides() end
    return true
end

-- Consent precedes checkpoint changes and quest-settlement cancellation.
-- A newer selection invalidates an older prompt, even if it needs no prompt.
function hardcore:BeforeLoad(guide, restoring, source, redirectTrail, continuation, canLoad)
    self:CancelPendingSelection()
    if addon.gameVersion ~= 30300 or type(guide) ~= "table" or guide.empty then return true end
    if guide.disabled or guide.internal or
        (addon.IsGuideActive and not addon.IsGuideActive(guide)) then return true end
    local desired = self:IsEnabled()
    if guide.hardcore then desired = true elseif guide.softcore then desired = false end
    if desired == self:IsEnabled() then return true end
    if restoring then self:Apply(desired); return true end
    local serial, current = self.selectionSerial, addon.currentGuide
    local step = RXPCData and RXPCData.currentStep
    local stepId = RXPCData and RXPCData.currentStepId
    local currentSource = current and current.sourceSignature
    local sourceSignature, key = guide.sourceSignature, guide.key
    local prompt = desired and L(
        "Enable Hardcore mode and open this experimental guide? Deathless guidance does not enforce server rules or guarantee survival.") or L(
        "This guide is explicitly softcore. Disable Hardcore mode and open it? Your Hardcore checkpoint will be retained.")
    addon.comms:ConfirmChoice("RXP_HARDCORE_GUIDE_CONFIRM", prompt, function()
        if self.selectionSerial ~= serial or addon.currentGuide ~= current or
            (RXPCData and RXPCData.currentStep ~= step) or
            (RXPCData and RXPCData.currentStepId ~= stepId) or
            (current and current.sourceSignature ~= currentSource) or
            guide.sourceSignature ~= sourceSignature or guide.key ~= key or
            guide.disabled or guide.internal then return end
        if addon.IsGuideActive and not addon.IsGuideActive(guide) then return end
        if canLoad and not canLoad() then return end
        if addon.PrepareGuideLoad335 then
            local prepared = addon:PrepareGuideLoad335(guide)
            if not prepared or prepared.hardcore ~= guide.hardcore or
                prepared.softcore ~= guide.softcore or
                prepared.sourceSignature ~= guide.sourceSignature then return end
        end
        self:Apply(desired)
        if continuation then continuation()
        else
            if addon.guideState then addon.guideState:SaveCurrent() end
            addon:LoadGuide(guide, nil, source, redirectTrail)
        end
    end, nil, guide)
    return false
end

addon.services:Register("hardcore-guides", hardcore)
