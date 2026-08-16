local addonName, addon = ...

local fmt, tinsert, tremove, mmax, mmin, ceil = string.format, table.insert,
    table.remove, math.max, math.min, math.ceil
local GetMacroInfo, CreateMacro, EditMacro, InCombatLockdown, GetNumMacros = GetMacroInfo, CreateMacro, EditMacro,
                                                                             InCombatLockdown, GetNumMacros
local TargetUnit, UnitName, next, IsInRaid, UnitIsDead, UnitIsGroupLeader, IsInGroup, UnitOnTaxi, UnitIsPlayer,
      UnitIsUnit = TargetUnit, UnitName, next, IsInRaid, UnitIsDead, UnitIsGroupLeader, IsInGroup, UnitOnTaxi,
                   UnitIsPlayer, UnitIsUnit
local GetRaidTargetIndex, SetRaidTarget = GetRaidTargetIndex, SetRaidTarget
local GetTime, FlashClientIcon, PlaySound = GetTime, FlashClientIcon, PlaySound
local wipe = wipe
local GetRealZoneText = GetRealZoneText
local GetNamePlates = C_NamePlate.GetNamePlates

local HBD = LibStub("HereBeDragons-2.0")

local GameTooltip = _G.GameTooltip

local L = addon.locale.Get

addon.targeting = addon:NewModule("Targeting", "AceEvent-3.0")
addon.targeting.macroName = "RXPTargeting"

local TARGET_BINDING_BUTTON_NAME = "RXP_TargetBindingButton"
_G.BINDING_HEADER_RXPGUIDES = addon.title or "RestedXP Guides"
_G["BINDING_NAME_CLICK " .. TARGET_BINDING_BUTTON_NAME .. ":LeftButton"] =
    L("Target current guide target")

-- The saved macro itself is limited to 255 bytes on 3.3.5a.  Keep it as a
-- small dispatcher and put the generated /targetexact commands on secure
-- buttons instead.  Sixteen short /click lines still leave room for the dead
-- target guard and cover far more targets than a guide step can reasonably
-- contain.
local TARGET_MACRO_PAGE_PREFIX = "RXPT"
local TARGET_MACRO_MAX_PAGES = 16
local TARGET_MACRO_PAGE_BYTES = 230

local announcedTargets = {}
local macroTargets = {}
local macroUpdatePending = false
local lowPrioTargets = {}

local proxmityPolling = {
    frequency = 0.25,
    match = false,
    lastMatch = 0,
    matchTimeout = 5,
    scanData = {},
    scannedTargets = {},
    rareAnnounced = {}
}

local targetList = {}
local targetPlaceholder = "Interface\\GossipFrame\\GossipGossipIcon"

local function IsLegacyWorldMapOpen()
    return addon.gameVersion == 30300 and _G.WorldMapFrame and
               _G.WorldMapFrame:IsShown()
end

local mobList = {}
-- 3.3.5a does not support numeric fileIDs for SetTexture (only texture paths),
-- so a fileID here renders as an invalid red square. Use a guaranteed-valid path.
local mobPlaceholder = "Interface\\Icons\\INV_Misc_QuestionMark"

local unitscanList = {}

-- Targets declared by the currently active guide step are different from the
-- low-priority/generated targets which are appended to the scanner lists.  Keep
-- this membership independently so the Active Targets window can remain useful
-- for the lifetime of the step, even before a nameplate/target token has supplied
-- a real portrait. Generated targets and rares still remain proximity-driven.
local currentStepTargets = {}

local function HasVisibleCurrentStepTarget()
    local profile = addon.settings and addon.settings.profile
    if not profile then return next(currentStepTargets) ~= nil end
    for _, data in pairs(currentStepTargets) do
        if data.kind == "friendly" then
            if profile.enableFriendlyTargeting then return true end
        elseif profile.enableEnemyTargeting then
            return true
        end
    end
    return false
end

local rareTargets = {}
-- Dangerous-mob records are generated from a zone database.  Keep them out of
-- the ordinary macro/step lists: they are alerts discovered through visible
-- stock nameplates, target, or mouseover only.
local dangerousTargets = {}

local function SetPlaceholder(texture, path)
    texture:SetTexture(path)
    texture:SetTexCoord(0, 1, 0, 1)
end

local LEGACY_NAMEPLATE_OVERLAY = "Interface\\TargetingFrame\\UI-TargetingFrame-Flash"
local RAID_TARGET_TEXTURE = "Interface\\TargetingFrame\\UI-RaidTargetingIcons"
-- Nameplate skins can assign hostile health bars very high frame levels while
-- leaving friendly plates near the raw frame's level. Keep RXP's own local
-- marker above either case without modifying any stock/nameplate-addon region.
local LEGACY_MARKER_FRAME_LEVEL = 1000
local legacyScanner = {
    knownPlates = {},
    wantedByName = {},
    visibleCounts = {},
    lastChildren = -1,
    nextFullDiscovery = 0,
    discoveryInterval = 1,
    grace = 0.75,
    wantedDirty = true,
    frameDirty = false,
    alerted = {}
}
local legacyOwnedMarkers = {}

local function ClearLegacyOwnedMarker(unit)
    if addon.gameVersion ~= 30300 or InCombatLockdown() or
        type(UnitGUID) ~= "function" then return end
    local guid = UnitGUID(unit)
    local markerId = guid and legacyOwnedMarkers[guid]
    if not markerId then return end

    -- Clear only the exact marker RXP previously placed on this GUID. If the
    -- player/group changed it in the meantime, discard ownership without
    -- touching their marker.
    if GetRaidTargetIndex(unit) == markerId then SetRaidTarget(unit, 0) end
    legacyOwnedMarkers[guid] = nil
end

local function SetRaidIconTexture(texture, markerId)
    local marker = (markerId or 1) - 1
    local column = marker % 4
    local row = math.floor(marker / 4)
    texture:SetTexture(RAID_TARGET_TEXTURE)
    texture:SetTexCoord(column / 4, (column + 1) / 4,
                        row / 4, (row + 1) / 4)
end

local function LegacyMarkerEnabled(kind)
    if kind == "friendly" then
        return addon.settings.profile.enableTargetMarking
    elseif kind == "mob" then
        return addon.settings.profile.enableMobMarking
    end
    return addon.settings.profile.enableEnemyMarking
end

function addon.targeting:RebuildLegacyWanted()
    if addon.gameVersion ~= 30300 then return end

    wipe(legacyScanner.wantedByName)
    local function AddList(list, kind, enabled)
        if not enabled then return end
        for index, name in ipairs(list) do
            if name and name ~= "" and not legacyScanner.wantedByName[name] then
                legacyScanner.wantedByName[name] = {kind = kind, index = index}
            end
        end
    end

    AddList(targetList, "friendly", addon.settings.profile.enableFriendlyTargeting)
    AddList(mobList, "mob", addon.settings.profile.enableEnemyTargeting)
    AddList(unitscanList, "unitscan", addon.settings.profile.enableEnemyTargeting)
    AddList(rareTargets, "rare", addon.settings.profile.scanForRares)
    AddList(dangerousTargets, "dangerous",
            addon.settings.profile.enableTips and
            addon.settings.profile.enableEnemyTargeting and
                addon.settings.profile.showDangerousUnitscan)
    for name in pairs(legacyScanner.alerted) do
        if not legacyScanner.wantedByName[name] then
            legacyScanner.alerted[name] = nil
        end
    end
    legacyScanner.wantedDirty = false
end

local legacyRangeState = {captured = false, original = {}, supported = {}}

local function ReadLegacyCVar(name)
    if type(GetCVar) ~= "function" then return end
    local ok, value = pcall(GetCVar, name)
    if ok and value ~= nil and value ~= "" then return tostring(value) end
end

local function WriteLegacyCVar(name, value)
    if value == nil or type(SetCVar) ~= "function" then return false end
    return pcall(SetCVar, name, tostring(value))
end

local function CaptureLegacyTargetRange()
    if legacyRangeState.captured then return end
    legacyRangeState.captured = true
    for _, name in ipairs({
        "targetNearestDistance", "targetNearestDistanceRadius",
        "nameplateMaxDistance"
    }) do
        local value = ReadLegacyCVar(name)
        legacyRangeState.original[name] = value
        legacyRangeState.supported[name] = value ~= nil
    end
end

function addon.targeting:ApplyLegacyTargetRange()
    if addon.gameVersion ~= 30300 then return end
    CaptureLegacyTargetRange()
    local enabled = addon.settings.profile.enableTargetAutomation and
                        addon.settings.profile.enableMaxNameplateDistance
    local desired = {
        targetNearestDistance = "50",
        targetNearestDistanceRadius = "50",
        nameplateMaxDistance = "41"
    }
    for name, value in pairs(desired) do
        if legacyRangeState.supported[name] then
            WriteLegacyCVar(name, enabled and value or
                legacyRangeState.original[name])
        end
    end
end

local function GetLegacyPlateName(frame)
    local nameText = frame.rxpNameText
    local name = nameText and nameText.GetText and nameText:GetText()
    if name and name ~= "" then return name end
end

local function RegisterLegacyNameplate(frame, nameText)
    if not frame then return end
    if legacyScanner.knownPlates[frame] then
        if nameText then frame.rxpNameText = nameText end
        return
    end

    frame.rxpNameText = nameText
    frame.rxpTargetOverlay = CreateFrame("Frame", nil, frame)
    frame.rxpTargetOverlay:SetSize(18, 18)
    frame.rxpTargetOverlay:SetPoint("BOTTOM", frame, "TOP", 0, 2)
    frame.rxpTargetOverlay:SetFrameLevel(mmax(frame:GetFrameLevel() + 20,
                                               LEGACY_MARKER_FRAME_LEVEL))
    frame.rxpTargetOverlay.icon =
        frame.rxpTargetOverlay:CreateTexture(nil, "OVERLAY")
    frame.rxpTargetOverlay.icon:SetAllPoints(true)
    frame.rxpTargetOverlay:Hide()
    frame:HookScript("OnShow", function()
        legacyScanner.frameDirty = true
    end)
    frame:HookScript("OnHide", function(plate)
        if plate.rxpTargetOverlay then plate.rxpTargetOverlay:Hide() end
        legacyScanner.frameDirty = true
    end)
    legacyScanner.knownPlates[frame] = true
end

function addon.targeting:DiscoverLegacyNameplates()
    local count = WorldFrame:GetNumChildren()
    local now = GetTime()
    if count == legacyScanner.lastChildren and now < legacyScanner.nextFullDiscovery then return end
    legacyScanner.nextFullDiscovery = now + legacyScanner.discoveryInterval

    local children = {WorldFrame:GetChildren()}
    for index = 1, #children do
        local frame = children[index]
        if frame and not legacyScanner.knownPlates[frame] and frame.GetRegions then
            local regions = {frame:GetRegions()}
            local firstRegion = regions[1]
            local nameText = regions[7]
            local firstTexture = firstRegion and firstRegion.GetObjectType and
                                     firstRegion:GetObjectType() == "Texture" and
                                     firstRegion:GetTexture()
            local healthBar, castBar = frame:GetChildren()
            local hasStockStructure = nameText and nameText.GetObjectType and
                                          nameText:GetObjectType() == "FontString" and
                                          healthBar and healthBar.GetObjectType and
                                          healthBar:GetObjectType() == "StatusBar" and
                                          castBar and castBar.GetObjectType and
                                          castBar:GetObjectType() == "StatusBar"
            -- Stock 3.3.5 nameplates are raw WorldFrame children whose first
            -- region is UI-TargetingFrame-Flash and whose seventh region is the
            -- name FontString. A skin may clear the flash texture, but the two
            -- stock StatusBar children and original name region remain. Both
            -- signatures are base-client structures; no skin API is consulted.
            if firstTexture == LEGACY_NAMEPLATE_OVERLAY or hasStockStructure then
                RegisterLegacyNameplate(frame, nameText)
            end
        end
    end
    legacyScanner.lastChildren = count
end

function addon.targeting:RecordSeenTarget(name, wanted, now, source)
    wanted = wanted or legacyScanner.wantedByName[name]
    if not (name and wanted) then return false end
    now = now or GetTime()

    local old = proxmityPolling.scannedTargets[name]
    local changed = not old or old.kind ~= wanted.kind
    proxmityPolling.scannedTargets[name] = {
        kind = wanted.kind,
        index = wanted.index,
        lastMatch = now,
        source = source or "nameplate"
    }
    proxmityPolling.lastMatch = now
    -- Direct target/mouseover events render the Active Targets frame before the
    -- periodic scanner gets another tick. Mark the proximity state immediately
    -- so that render is not hidden again at the end of UpdateTargetFrame.
    proxmityPolling.match = true

    if changed and not legacyScanner.alerted[name] and
        (wanted.kind == "rare" or wanted.kind == "unitscan" or
            wanted.kind == "dangerous") then
        legacyScanner.alerted[name] = true
        if addon.settings.profile.flashOnFind and FlashClientIcon then
            FlashClientIcon()
        end
        -- .unitscan is also used for ordinary guide objectives (sleeping mobs,
        -- escorts, named quest mobs, etc.). Treating every unitscan match as an
        -- emergency caused the full-screen low-health vignette to fire repeatedly.
        -- Reserve the red danger flash for actual rare alerts.
        if wanted.kind == "dangerous" and
            addon.settings.profile.showDangerousMobWarning and addon.tips then
            addon.tips:EnableDangerWarning(2, "dangerous")
        elseif wanted.kind == "rare" and
            addon.settings.profile.enableTargetingFlash and addon.tips then
            addon.tips:EnableDangerWarning(1)
        end
        local sound = addon.settings.profile.soundOnFind
        if sound and sound ~= "none" then
            addon.settings:PlayTargetingSound(
                sound, addon.settings.profile.soundOnFindChannel)
        end
        if wanted.kind == "rare" and addon.settings.profile.notifyOnRares then
            addon.comms.PrettyPrint(L("Rare Found! %s is nearby."), name)
        end
    end
    return changed
end

function addon.targeting:LegacyScanTick()
    if addon.gameVersion ~= 30300 or
        not addon.settings.profile.enableTargetAutomation then return end
    if legacyScanner.wantedDirty then self:RebuildLegacyWanted() end

    self:DiscoverLegacyNameplates()
    wipe(legacyScanner.visibleCounts)
    local now = GetTime()
    local membershipChanged = false

    for frame in pairs(legacyScanner.knownPlates) do
        local overlay = frame.rxpTargetOverlay
        local name = frame:IsShown() and GetLegacyPlateName(frame)
        local wanted = name and legacyScanner.wantedByName[name]
        if wanted then
            legacyScanner.visibleCounts[name] =
                (legacyScanner.visibleCounts[name] or 0) + 1
            if self:RecordSeenTarget(name, wanted, now) then
                membershipChanged = true
            end
            if overlay and LegacyMarkerEnabled(wanted.kind) then
                -- Hostile threat/target updates can raise their health-bar frame
                -- repeatedly. Reassert ours every scan so the client-local raid
                -- icon stays visible just as it does on friendly targets.
                overlay:SetFrameLevel(mmax(frame:GetFrameLevel() + 20,
                                           LEGACY_MARKER_FRAME_LEVEL))
                SetRaidIconTexture(overlay.icon,
                                   self:GetMarkerIndex(wanted.kind,
                                                       wanted.index))
                overlay:Show()
            elseif overlay then
                overlay:Hide()
            end
        elseif overlay then
            overlay:Hide()
        end
    end

    -- Target and mouseover remain useful when nameplates are disabled and also
    -- provide real unit tokens for portraits/server markers.
    for _, unit in ipairs({"target", "mouseover"}) do
        local name = UnitName(unit)
        local wanted = name and legacyScanner.wantedByName[name]
        if wanted then
            legacyScanner.visibleCounts[name] =
                (legacyScanner.visibleCounts[name] or 0) + 1
            if self:RecordSeenTarget(name, wanted, now) then
                membershipChanged = true
            end
            if LegacyMarkerEnabled(wanted.kind) then
                self:UpdateMarker(wanted.kind, unit, wanted.index)
            else
                ClearLegacyOwnedMarker(unit)
            end
        else
            ClearLegacyOwnedMarker(unit)
        end
    end

    for name, data in pairs(proxmityPolling.scannedTargets) do
        if not legacyScanner.wantedByName[name] or
            (not legacyScanner.visibleCounts[name] and
                now - (data.lastMatch or 0) > legacyScanner.grace) then
            proxmityPolling.scannedTargets[name] = nil
            -- Keep the alert latch while this name remains part of the current
            -- guide target set. Pooled nameplates can disappear for a moment and
            -- reappear; clearing it here retriggered sounds/flashes every cycle.
            if not legacyScanner.wantedByName[name] then
                legacyScanner.alerted[name] = nil
            end
            membershipChanged = true
        end
    end

    proxmityPolling.match = next(proxmityPolling.scannedTargets) ~= nil
    if membershipChanged or legacyScanner.frameDirty then
        legacyScanner.frameDirty = false
        if InCombatLockdown() then
            legacyScanner.frameDirty = true
        else
            self:UpdateTargetFrame()
        end
    end
end

function addon.targeting:StopLegacyScanner(clearTargets)
    if self.legacyTicker then
        self.legacyTicker:Cancel()
        self.legacyTicker = nil
    end
    for frame in pairs(legacyScanner.knownPlates) do
        if frame.rxpTargetOverlay then frame.rxpTargetOverlay:Hide() end
    end
    if clearTargets then
        wipe(proxmityPolling.scannedTargets)
        wipe(legacyScanner.alerted)
        proxmityPolling.match = false
        if InCombatLockdown() then
            self.clearOwnedMarkersPending = true
        else
            ClearLegacyOwnedMarker("target")
            ClearLegacyOwnedMarker("mouseover")
            wipe(legacyOwnedMarkers)
            self.clearOwnedMarkersPending = nil
        end
        if self.activeTargetFrame and not InCombatLockdown() then
            self.activeTargetFrame:Hide()
        end
    end
end

function addon.targeting:RefreshScanTicker()
    if addon.gameVersion ~= 30300 then return end
    self:StopLegacyScanner(false)
    if not addon.settings.profile.enableTargetAutomation then
        self:StopLegacyScanner(true)
        return
    end

    legacyScanner.wantedDirty = true
    self:LegacyScanTick()
    local milliseconds = addon.settings.profile.updateFrequency or 75
    if addon.GetEffectiveUpdateFrequency then
        milliseconds = addon.GetEffectiveUpdateFrequency(milliseconds)
    end
    local frequency = mmax(milliseconds / 1000, 0.10)
    self.legacyTicker = C_Timer.NewTicker(frequency, function()
        self:LegacyScanTick()
    end)
end

function addon.targeting:RefreshLegacyTargets()
    if addon.gameVersion ~= 30300 then return end
    legacyScanner.wantedDirty = true
    self:LegacyScanTick()
end

function addon.targeting:ClearTargetButtons()
    if InCombatLockdown() then
        self.clearTargetButtonsPending = true
        return
    end

    local frame = self.activeTargetFrame
    if not frame then return end
    for _, buttons in ipairs({frame.enemyTargetButtons or {},
                              frame.friendlyTargetButtons or {}}) do
        for _, button in ipairs(buttons) do
            button:SetAttribute("macrotext", "")
            button:SetAttribute("macrotext1", "")
            button.targetData = nil
            button:Hide()
        end
    end
    frame:Hide()
    self.clearTargetButtonsPending = nil
end

function addon.targeting:CreateTargetBindingButton()
    if self.targetBindingButton then return self.targetBindingButton end
    if InCombatLockdown() then
        self.createTargetBindingPending = true
        return
    end

    local button = _G[TARGET_BINDING_BUTTON_NAME]
    if not button then
        button = CreateFrame("Button", TARGET_BINDING_BUTTON_NAME, UIParent,
                             "SecureActionButtonTemplate")
        button:SetSize(1, 1)
        button:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -10, 10)
        button:SetAlpha(0)
        if button.RegisterForClicks then button:RegisterForClicks("AnyUp") end
        button:Show()
    end
    button:SetAttribute("type", "macro")
    button:SetAttribute("type1", "macro")
    self.targetBindingButton = button
    self.createTargetBindingPending = nil
    return button
end

function addon.targeting:SetTargetBindingContent(content)
    content = content or ""
    if InCombatLockdown() then
        self.targetBindingContentPending = content
        return
    end
    local button = self:CreateTargetBindingButton()
    if not button then
        self.targetBindingContentPending = content
        return
    end
    button:SetAttribute("macrotext", content)
    button:SetAttribute("macrotext1", content)
    self.targetBindingContentPending = nil
end

function addon.targeting:Setup()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
    if addon.gameVersion == 30300 then self:StopLegacyScanner(false) end
    self:ApplyLegacyTargetRange()

    -- Setup is called for live option changes as well as login. Remove events
    -- whose applicability depends on those options before rebuilding the set;
    -- otherwise a previously enabled scanner can keep stale zone/nameplate
    -- callbacks after it has been disabled.
    self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
    self:UnregisterEvent("ADDON_ACTION_FORBIDDEN")
    self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")

    if addon.tips and addon.tips.DisableDangerWarning and
        not addon.settings.profile.enableTargetingFlash then
        addon.tips:DisableDangerWarning()
    end

    if not addon.settings.profile.enableTargetMacro then
        if InCombatLockdown() then
            self.deleteTargetMacroPending = true
        else
            DeleteMacro(self.macroName)
            self.deleteTargetMacroPending = nil
        end
    else
        self.deleteTargetMacroPending = nil
    end

    self:CreateTargetFrame()

    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:CreateTargetBindingButton()
    if addon.settings.profile.enableTargetMacro then
        -- OnEnable can populate the first guide before the stock macro cache is
        -- ready. Setup also runs on PLAYER_ENTERING_WORLD, so updating here
        -- creates/retries RXPTargeting once the clean 3.3.5 client is ready and
        -- gives it useful placeholder content even for an empty guide.
        self:UpdateMacro()
    else
        self:SetTargetBindingContent("")
    end

    -- Remove interacted target
    self:RegisterEvent("GOSSIP_SHOW")
    self:RegisterEvent("MERCHANT_SHOW")
    self:RegisterEvent("QUEST_PROGRESS")
    self:RegisterEvent("QUEST_GREETING")
    self:RegisterEvent("QUEST_COMPLETE")

    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

    if not addon.settings.profile.enableTargetAutomation then
        if addon.gameVersion == 30300 then self:StopLegacyScanner(true) end
        self:ClearTargetButtons()
        return
    end

    if addon.gameVersion ~= 30300 then
        -- Only works when nameplates are enabled
        self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    else
        self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        self:UnregisterEvent("ADDON_ACTION_FORBIDDEN")
    end

    -- Increase nameplate scanning distance to max allowed.
    -- pcall: the nameplateMaxDistance CVar does not exist on 3.3.5a and SetCVar
    -- throws on unknown CVars.
    if addon.gameVersion ~= 30300 and
        addon.settings.profile.enableMaxNameplateDistance ~= false then
        if addon.gameVersion > 40000 then
            pcall(SetCVar, "nameplateMaxDistance", "100")
        else
            pcall(SetCVar, "nameplateMaxDistance", "41")
        end
    end

    if addon.gameVersion == 30300 then
        self:RefreshScanTicker()
    elseif addon.settings.profile.showTargetingOnProximity then
        if addon.settings.profile and addon.settings.profile.updateFrequency then
            proxmityPolling.frequency = addon.settings.profile.updateFrequency / 1000
        end

        self.ticker = C_Timer.NewTicker(proxmityPolling.frequency, self.CheckTargetProximity)

        self:RegisterEvent("ADDON_ACTION_FORBIDDEN")

        -- Prevent default forbidden UI popup
        UIParent:UnregisterEvent("ADDON_ACTION_FORBIDDEN")
    end

    if addon.rares then
        self:LoadRares()
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    end
end

local function shouldTargetCheck()
    -- The modern proximity implementation used protected targeting and was
    -- deliberately disabled in raids. The 3.3.5 implementation only reads
    -- stock nameplates, so it remains safe and useful in raid groups too.
    local groupAllowed = addon.gameVersion == 30300 or not IsInRaid()
    return groupAllowed and not UnitOnTaxi("player") and not addon.isCastingHS and
               (next(unitscanList) ~= nil or next(mobList) ~= nil or next(targetList) ~= nil or next(rareTargets) ~= nil or
                   next(proxmityPolling.scannedTargets) ~= nil)

end

local currentTargets = ""
local function AnnounceTargets()
    if not addon.settings.profile.notifyOnTargetUpdates then return end

    addon.comms.PrettyPrint(L("Targeting macro updated with:%s"), currentTargets)
end

local function GetTargetMacroPage(self, index)
    self.targetMacroPages = self.targetMacroPages or {}
    local page = self.targetMacroPages[index]
    local name = TARGET_MACRO_PAGE_PREFIX .. index
    if not page then
        page = _G[name]
        if not page then
            page = CreateFrame("Button", name, UIParent,
                               "SecureActionButtonTemplate")
            page:SetSize(1, 1)
            page:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -10, 10)
            page:SetAlpha(0)
            if page.RegisterForClicks then page:RegisterForClicks("AnyUp") end
            page:Show()
        end
        self.targetMacroPages[index] = page
    end
    page:SetAttribute("type", "macro")
    page:SetAttribute("type1", "macro")
    return page, name
end

local function BuildTargetMacroDispatcher(self, targets)
    local pageTexts = {}
    local pageText = ""

    for _, target in ipairs(targets) do
        local command = "/targetexact " .. target
        -- A malformed/localized guide name must not create an overlong secure
        -- attribute or inject a second macro command.
        if target:find("[\r\n]") or #command > TARGET_MACRO_PAGE_BYTES then
            -- Skip this one target; all other step targets remain available.
        elseif pageText ~= "" and
            #pageText + #command + 1 > TARGET_MACRO_PAGE_BYTES then
            tinsert(pageTexts, pageText)
            pageText = command
        elseif pageText == "" then
            pageText = command
        else
            pageText = pageText .. "\n" .. command
        end
    end
    if pageText ~= "" then tinsert(pageTexts, pageText) end

    -- Retain the highest-priority commands if malformed guide data somehow
    -- exceeds the already-generous dispatcher capacity.
    while #pageTexts > TARGET_MACRO_MAX_PAGES do tremove(pageTexts, 1) end

    local dispatcher = {}
    for index, text in ipairs(pageTexts) do
        local page, name = GetTargetMacroPage(self, index)
        page:SetAttribute("macrotext", text)
        page:SetAttribute("macrotext1", text)
        tinsert(dispatcher, "/click " .. name)
    end

    -- A later step can need fewer pages. Clear stale secure commands so an old
    -- target can never remain reachable through a reused dispatcher line.
    for index = #pageTexts + 1, self.targetMacroPageCount or 0 do
        local page = self.targetMacroPages and self.targetMacroPages[index]
        if page then
            page:SetAttribute("macrotext", "")
            page:SetAttribute("macrotext1", "")
        end
    end
    self.targetMacroPageCount = #pageTexts

    if #dispatcher == 0 then return end
    tinsert(dispatcher, "/targetlasttarget [dead]")
    return table.concat(dispatcher, "\n")
end

function addon.targeting:UpdateMacro(queuedTargets)
    if not addon.settings.profile.enableTargetMacro then
        self:SetTargetBindingContent("")
        if not InCombatLockdown() then
            macroTargets = {}
            macroUpdatePending = false
        end
        return
    end

    if InCombatLockdown() then
        macroTargets = queuedTargets or macroTargets
        macroUpdatePending = true
        return
    end

    -- Create the saved macro independently of whether this particular guide
    -- step has targets. This makes the enabled setting deterministic on login;
    -- later step changes simply replace its placeholder body.
    if not GetMacroInfo(self.macroName) then
        if self:CanCreateMacro() then
            -- 3.3.5a CreateMacro wants a numeric icon index, not a texture name.
            pcall(CreateMacro, self.macroName, 1, "")
        end
        -- Even when the account macro table is full, continue building the
        -- secure keybinding dispatcher and Active Target buttons. Only the
        -- optional saved macro itself is unavailable in that situation.
    end

    if not shouldTargetCheck() then
        local emptyContent = fmt('//%s - %s', addon.title,
                                 L("current step has no configured targets"))
        self:SetTargetBindingContent(emptyContent)
        if GetMacroInfo(self.macroName) then
            pcall(EditMacro, self.macroName, self.macroName, nil,
                  emptyContent)
        end
        macroTargets = {}
        macroUpdatePending = false
        return
    end

    local targets = {}
    for _, target in ipairs(queuedTargets or {}) do
        tinsert(targets, target)
    end

    for _, t in ipairs(unitscanList) do if not lowPrioTargets[t] then tinsert(targets, t) end end

    for _, t in ipairs(mobList) do if not lowPrioTargets[t] then tinsert(targets, t) end end

    for _, t in ipairs(targetList) do if not lowPrioTargets[t] then tinsert(targets, t) end end

    local sortedLowPriority = {}
    for t in pairs(lowPrioTargets) do tinsert(sortedLowPriority, t) end
    table.sort(sortedLowPriority)
    for _, t in ipairs(sortedLowPriority) do tinsert(targets, t) end

    -- Remove duplicate entries while preserving the historical priority: low
    -- priority names execute first, followed by friendly, mob, and unitscan
    -- names. Because each successful /targetexact replaces the previous one,
    -- the last/highest-priority visible target wins.
    local npcNames = {}
    local executionTargets = {}
    for i = #targets, 1, -1 do
        local t = targets[i]
        if t and t ~= "" and not npcNames[t] then
            npcNames[t] = true
            tinsert(executionTargets, t)
        end
    end

    local targetText = ""
    for _, t in ipairs(executionTargets) do
        -- Prevent multiple spams
        if not (announcedTargets[t] or lowPrioTargets[t]) and
            addon.settings.profile.notifyOnTargetUpdates then
            targetText = fmt("%s %s,", targetText, t)
        end
        announcedTargets[t] = true
    end

    if #targetText > 0 then
        currentTargets = targetText:sub(1, -2)
        addon.ScheduleTask(1.5, AnnounceTargets)
    end

    local content = BuildTargetMacroDispatcher(self, executionTargets)
    if not content then
        content = fmt('//%s - %s', addon.title, L("current step has no configured targets")) -- TODO locale
    end

    self:SetTargetBindingContent(content)
    if GetMacroInfo(self.macroName) then
        pcall(EditMacro, self.macroName, self.macroName, nil, content)
    end

    if GetMacroInfo(self.macroName) and
        not addon.settings.profile.macroAnnounced and
        addon.settings.profile.notifyOnTargetUpdates and next(targets) ~= nil then
        C_Timer.After(1, function()
            addon.comms.PrettyPrint(L(
            "A macro has been automatically built to aid in leveling. Please move %s to your action bars."),
                                    self.macroName)

        end)

        addon.settings.profile.macroAnnounced = true
    end

    macroTargets = {}
    macroUpdatePending = false
end

function addon.targeting:PLAYER_REGEN_ENABLED()
    if self.deleteTargetMacroPending and
        not addon.settings.profile.enableTargetMacro then
        DeleteMacro(self.macroName)
        self.deleteTargetMacroPending = nil
    end
    if self.createTargetBindingPending then self:CreateTargetBindingButton() end
    if self.targetBindingContentPending ~= nil then
        self:SetTargetBindingContent(self.targetBindingContentPending)
    end
    if macroUpdatePending then self:UpdateMacro(macroTargets) end

    if self.clearTargetButtonsPending then self:ClearTargetButtons() end
    if self.clearOwnedMarkersPending then
        ClearLegacyOwnedMarker("target")
        ClearLegacyOwnedMarker("mouseover")
        wipe(legacyOwnedMarkers)
        self.clearOwnedMarkersPending = nil
    end

    legacyScanner.frameDirty = false
    if addon.gameVersion == 30300 then self:LegacyScanTick() end
    self:UpdateTargetFrame()
end

function addon.targeting:CheckNameplate(nameplateID)
    if not addon.settings.profile.enableTargetAutomation or not nameplateID then return end

    local unitName = UnitName(nameplateID)

    if not unitName then return end

    if addon.settings.profile.enableFriendlyTargeting then
        for i, name in ipairs(targetList) do
            if name == unitName then
                self:UpdateTargetFrame(nameplateID)

                if addon.settings.profile.enableTargetMarking then
                    self:UpdateMarker("friendly", nameplateID, i)
                end
            end
        end
    end

    if addon.settings.profile.enableEnemyTargeting then
        for i, name in ipairs(mobList) do
            if name == unitName then
                self:UpdateTargetFrame(nameplateID)

                if addon.settings.profile.enableMobMarking then self:UpdateMarker("mob", nameplateID, i) end
            end
        end

        for i, name in ipairs(unitscanList) do
            if name == unitName then
                self:UpdateTargetFrame(nameplateID)

                if addon.settings.profile.flashOnFind and FlashClientIcon then FlashClientIcon() end

                if addon.settings.profile.enableEnemyMarking then
                    self:UpdateMarker("unitscan", nameplateID, i)
                end
            end
        end
    end

    if addon.settings.profile.scanForRares then
        for _, name in ipairs(rareTargets) do
            if name == unitName then
                self:UpdateTargetFrame(nameplateID)

                if addon.settings.profile.flashOnFind and FlashClientIcon then FlashClientIcon() end

                if addon.settings.profile.enableTargetingFlash then addon.tips:EnableDangerWarning(1) end

                if addon.settings.profile.enableEnemyMarking then
                    -- Steal moon, lowest of enemies for mark
                    self:UpdateMarker("rare", nameplateID, 4)
                end
            end
        end
    end
end

function addon.targeting:CheckNameplates()
    local nameplatesArray = GetNamePlates()

    if not nameplatesArray then return end

    for _, nameplate in ipairs(nameplatesArray) do self:CheckNameplate(nameplate.namePlateUnitToken) end
end

function addon.targeting:NAME_PLATE_UNIT_ADDED(_, nameplateID)
    if not nameplateID or not shouldTargetCheck() then return end

    self:CheckNameplate(nameplateID)
end

function addon.targeting:UPDATE_MOUSEOVER_UNIT()
    if not addon.settings.profile.enableTargetAutomation or
        not shouldTargetCheck() then return end

    local kind = "mouseover"
    local unitName = UnitName(kind)

    if not unitName then return end

    if addon.settings.profile.enableFriendlyTargeting then
        for i, name in ipairs(targetList) do
            if name == unitName then
                self:UpdateTargetFrame(kind)

                if addon.settings.profile.enableTargetMarking then self:UpdateMarker("friendly", kind, i) end
            end
        end
    end

    if addon.settings.profile.enableEnemyTargeting then
        for i, name in ipairs(mobList) do
            if name == unitName then
                self:UpdateTargetFrame(kind)

                if addon.settings.profile.enableMobMarking then self:UpdateMarker("mob", kind, i) end
            end
        end

        for i, name in ipairs(unitscanList) do
            if name == unitName then
                self:UpdateTargetFrame(kind)

                if addon.settings.profile.flashOnFind and FlashClientIcon then FlashClientIcon() end

                if addon.settings.profile.enableEnemyMarking then self:UpdateMarker("unitscan", kind, i) end
            end
        end
    end

    if addon.settings.profile.scanForRares then
        for _, name in ipairs(rareTargets) do
            if name == unitName then
                self:UpdateTargetFrame(kind)

                if addon.settings.profile.flashOnFind and FlashClientIcon then FlashClientIcon() end

                if addon.settings.profile.enableTargetingFlash then addon.tips:EnableDangerWarning(1) end

                if addon.settings.profile.enableEnemyMarking then
                    -- Steal moon, lowest of enemies for mark
                    self:UpdateMarker("rare", kind, 4)
                end
            end
        end
    end
end

function addon.targeting:PLAYER_TARGET_CHANGED()
    if not addon.settings.profile.enableTargetAutomation or
        not shouldTargetCheck() then return end

    local kind = "target"
    local unitName = UnitName(kind)

    if not unitName then return end

    if addon.settings.profile.enableFriendlyTargeting then
        for i, name in ipairs(targetList) do
            if name == unitName then
                self:UpdateTargetFrame(kind)

                if addon.settings.profile.enableTargetMarking then self:UpdateMarker("friendly", kind, i) end
            end
        end
    end

    if addon.settings.profile.enableEnemyTargeting then
        for i, name in ipairs(mobList) do
            if name == unitName then
                self:UpdateTargetFrame(kind)

                if addon.settings.profile.enableMobMarking then self:UpdateMarker("mob", kind, i) end
            end
        end

        for i, name in ipairs(unitscanList) do
            if name == unitName then
                self:UpdateTargetFrame(kind)

                if addon.settings.profile.enableEnemyMarking then self:UpdateMarker("unitscan", kind, i) end
            end
        end
    end

    if addon.settings.profile.scanForRares then
        for _, name in ipairs(rareTargets) do
            if name == unitName then
                self:UpdateTargetFrame(kind)

                if addon.settings.profile.flashOnFind and FlashClientIcon then FlashClientIcon() end

                if addon.settings.profile.enableTargetingFlash then addon.tips:EnableDangerWarning(1) end

                if addon.settings.profile.enableEnemyMarking then
                    -- Steal moon, lowest of enemies for mark
                    self:UpdateMarker("rare", kind, 4)
                end
            end
        end
    end
end

function addon.targeting:GOSSIP_SHOW()
    if not addon.settings.profile.enableTargetAutomation then return end
    local targetUnit = UnitName("target")

    if not targetUnit then return end

    if not addon.settings.profile.enableFriendlyTargeting then return end

    -- Return after first match, won't be an enemy and friendly target as the same step
    for i, name in ipairs(targetList) do
        if name == targetUnit then
            -- Keep an explicit current-step NPC targetable until the guide step
            -- actually completes. A single gossip interaction can contain a
            -- turn-in followed by another accept, and removing it here made the
            -- legacy scanner/macro lose that NPC between those two actions.
            if addon.gameVersion == 30300 and currentStepTargets[targetUnit] then
                self:RecordSeenTarget(targetUnit, nil, GetTime(), "target")
                self:UpdateTargetFrame("target")
                self:UpdateMacro()
                return
            end

            tremove(targetList, i)

            if addon.gameVersion == 30300 then
                legacyScanner.wantedDirty = true
                self:LegacyScanTick()
            end

            self:UpdateTargetFrame("target")
            self:UpdateMacro()

            -- On legacy clients we cannot distinguish an RXP marker from one
            -- placed by the player/group. Never clear a server marker here.
            if addon.gameVersion ~= 30300 and
                GetRaidTargetIndex("target") ~= nil then
                SetRaidTarget("target", 0)
            elseif addon.gameVersion == 30300 then
                ClearLegacyOwnedMarker("target")
            end
            return
        end
    end
end

addon.targeting.MERCHANT_SHOW = addon.targeting.GOSSIP_SHOW
addon.targeting.QUEST_PROGRESS = addon.targeting.GOSSIP_SHOW
addon.targeting.QUEST_GREETING = addon.targeting.GOSSIP_SHOW
addon.targeting.QUEST_COMPLETE = addon.targeting.GOSSIP_SHOW

function addon.targeting.CheckTargetProximity()
    -- TargetUnit(name, exactMatch) is protected on 3.3.5a. Legacy uses the
    -- passive WorldFrame nameplate scanner and must never enter this path even
    -- if a ticker is accidentally retained by a future setup change.
    if addon.gameVersion == 30300 then return end
    if not shouldTargetCheck() or not addon.settings.profile.showTargetingOnProximity then return end

    if addon.settings.profile.enableEnemyTargeting then
        for _, name in pairs(unitscanList) do
            proxmityPolling.scanData = {name = name, kind = 'unitscan'}
            TargetUnit(name, true)
        end

        for _, name in pairs(mobList) do
            proxmityPolling.scanData = {name = name, kind = 'mob'}
            TargetUnit(name, true)
        end
    end

    if addon.settings.profile.enableFriendlyTargeting then
        for _, name in pairs(targetList) do
            proxmityPolling.scanData = {name = name, kind = 'friendly'}
            TargetUnit(name, true)
        end
    end

    if addon.settings.profile.scanForRares then
        for _, name in ipairs(rareTargets) do
            proxmityPolling.scanData = {name = name, kind = 'rare'}
            TargetUnit(name, true)
        end
    end

    local now = GetTime()

    -- Unset match if >5s without a ADDON_ACTION_FORBIDDEN
    -- No hits, reset everything
    if proxmityPolling.match and now - proxmityPolling.lastMatch > proxmityPolling.matchTimeout then

        addon.comms.PrettyDebug("All match expired, resetting targets")

        proxmityPolling.match = false
        wipe(proxmityPolling.rareAnnounced)
        wipe(proxmityPolling.scannedTargets)
        if not InCombatLockdown() then addon.targeting:UpdateTargetFrame() end

        -- Full reset, so don't handle per-mob checks below
        return
    end

    local membershipChanged = false
    for name, data in pairs(proxmityPolling.scannedTargets) do
        if now - data.lastMatch > proxmityPolling.matchTimeout then
            addon.comms.PrettyDebug("Individual match expired", name)

            proxmityPolling.scannedTargets[name] = nil
            membershipChanged = true
        end
    end
    if membershipChanged and not InCombatLockdown() then
        addon.targeting:UpdateTargetFrame()
    end
end

-- Newer clients may still use the historical protected-call proximity path.
-- Never install its popup suppression on 3.3.5: the legacy nameplate scanner is
-- entirely read-only and must not interfere with genuine forbidden-action errors.
if addon.gameVersion ~= 30300 then
    local actionForbiddenText = fmt(ADDON_ACTION_FORBIDDEN, addonName)

    local TextBoxHook = function(self)
        local text = self.text or self.Text
        if text and text:GetText() == actionForbiddenText then
            if self:IsShown() then self:Hide() end
            local _, channel = PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
            if channel then
                StopSound(channel)
                StopSound(channel - 1)
            end
            StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = nil
        end
    end

    _G.StaticPopup1:HookScript("OnShow", TextBoxHook)
    _G.StaticPopup1:HookScript("OnHide", TextBoxHook)
    _G.StaticPopup2:HookScript("OnShow", TextBoxHook)
    _G.StaticPopup2:HookScript("OnHide", TextBoxHook)
end

function addon.targeting:ADDON_ACTION_FORBIDDEN(_, forbiddenAddon, func)
    if func ~= "TargetUnit()" or forbiddenAddon ~= addonName then return end

    -- Unexpected call from (mistakenly) RXP
    if not proxmityPolling.scanData or not proxmityPolling.scanData.name then return end

    local scannedName = proxmityPolling.scanData.name
    local now = GetTime()

    proxmityPolling.scannedTargets[scannedName] = {kind = proxmityPolling.scanData.kind, lastMatch = now}
    proxmityPolling.lastMatch = now
    self:UpdateTargetFrame()

    if proxmityPolling.scanData.kind == 'rare' and addon.settings.profile.notifyOnRares and
        not proxmityPolling.rareAnnounced[scannedName] then

        proxmityPolling.rareAnnounced[scannedName] = true
        addon.comms.PrettyPrint(L("Rare Found! %s is nearby."), scannedName) -- TODO locale
    end

    -- Only notify sound once per step
    if proxmityPolling.match then return end

    proxmityPolling.match = true

    if addon.settings.profile.soundOnFind ~= "none" and
        (proxmityPolling.scanData.kind == 'rare' or proxmityPolling.scanData.kind == 'unitscan') then
        PlaySound(addon.settings.profile.soundOnFind, addon.settings.profile.soundOnFindChannel)
    end
end

function addon.targeting:UpdateUnitList()
    local stepUnitscan = {}
    local stepMobs = {}
    local stepTargets = {}

    local function AddUnits(element, stepU, stepM, stepT)
        if element.unitscan then
            for _, t in ipairs(element.unitscan) do
                local name = addon.GetCreatureName(t)
                if type(name) == "string" and name ~= "" then
                    tinsert(stepU, name)
                end
            end
        end

        if element.mobs then
            for _, t in ipairs(element.mobs) do
                local name = addon.GetCreatureName(t)
                if type(name) == "string" and name ~= "" then
                    tinsert(stepM, name)
                end
            end
        end

        if element.targets then
            for _, t in ipairs(element.targets) do
                local name = addon.GetCreatureName(t)
                if type(name) == "string" and name ~= "" then
                    tinsert(stepT, name)
                end
            end
        end
    end

    -- activeSteps/elements are dense parser arrays. ipairs keeps marker and
    -- direct-button order stable across refreshes; pairs could reshuffle the
    -- same step after a quest event or reload.
    for _, step in ipairs(addon.RXPFrame.activeSteps) do
        for _, element in ipairs(step.elements or {}) do
            AddUnits(element, stepUnitscan, stepMobs, stepTargets)
        end
    end

    local unitscanGenerated = {}
    local mobsGenerated = {}
    local targetsGenerated = {}
    local dangerousGenerated = {}
    for generatedKind, context in pairs(addon.generatedSteps) do
        for _, step in ipairs(context) do
            for _, element in ipairs(step.elements or {}) do
                if generatedKind == "dangerousMobs" then
                    AddUnits(element, dangerousGenerated, dangerousGenerated,
                             dangerousGenerated)
                else
                    AddUnits(element, unitscanGenerated, mobsGenerated,
                             targetsGenerated)
                end
            end
        end
    end

    wipe(dangerousTargets)
    local dangerousSeen = {}
    for _, name in ipairs(dangerousGenerated) do
        if type(name) == "string" and name ~= "" and
            not dangerousSeen[name] then
            dangerousSeen[name] = true
            tinsert(dangerousTargets, name)
        end
    end

    wipe(currentStepTargets)
    local function RememberCurrentTargets(list, kind)
        for index, name in ipairs(list) do
            if name and name ~= "" then
                -- A leading star only changes macro priority; it is not part of
                -- the localized creature name shown in the target frame.
                if name:sub(1, 1) == "*" then name = name:sub(2) end
                currentStepTargets[name] = {kind = kind, index = index}
            end
        end
    end
    RememberCurrentTargets(stepUnitscan, "unitscan")
    RememberCurrentTargets(stepMobs, "mob")
    RememberCurrentTargets(stepTargets, "friendly")

    -- Low-priority entries are derived exclusively from the current generated
    -- step contexts. Rebuild the set with the lists; retaining old names here
    -- left completed generated objectives reachable through RXPTargeting.
    wipe(lowPrioTargets)

    -- Update targets for macro
    addon.targeting:UpdateEnemyList(stepUnitscan, stepMobs)
    addon.targeting:UpdateTargetList(stepTargets)

    addon.targeting:UpdateEnemyList(unitscanGenerated, mobsGenerated, true)
    addon.targeting:UpdateTargetList(targetsGenerated, true)

    -- Don't process new targets if targeting disabled
    if addon.settings.profile.enableTargetAutomation then
        if addon.gameVersion == 30300 then
            addon.targeting:LegacyScanTick()
        else
            addon.targeting:CheckNameplates()
        end
    end
end

local function FilterList(list)
    local normal, lowPriority, seen = {}, {}, {}
    for _, unit in ipairs(list or {}) do
        if type(unit) == "string" then
            local low = unit:sub(1, 1) == "*"
            local name = low and unit:sub(2) or unit
            name = name:gsub("[\r\n]", " "):match("^%s*(.-)%s*$")
            if name ~= "" and not seen[name] then
                seen[name] = true
                tinsert(low and lowPriority or normal, name)
            end
        end
    end

    wipe(list)
    for _, name in ipairs(normal) do tinsert(list, name) end
    -- A leading star means low macro priority. Preserve that behavior without
    -- retaining the star in the NPC name itself.
    for _, name in ipairs(lowPriority) do tinsert(list, name) end
end

function addon.targeting:UpdateTargetList(targets, addEntries)
    FilterList(targets)

    if addEntries then
        local update, found

        for _, unit in ipairs(targets) do
            found = false

            for _, src in ipairs(targetList) do
                if src == unit then
                    found = true
                    break
                end
            end

            if not found then
                update = true
                lowPrioTargets[unit] = true

                tinsert(targetList, unit)
            end
        end

        if not update then return end
    elseif addEntries == false then
        table.wipe(lowPrioTargets)
        targetList = targets
    else
        targetList = targets
    end

    self:UpdateMacro()

    if not addon.settings.profile.enableTargetAutomation then return end

    if addon.gameVersion == 30300 then
        legacyScanner.wantedDirty = true
        self:LegacyScanTick()
        if not InCombatLockdown() then self:UpdateTargetFrame() end
        return
    end

    proxmityPolling.match = false
    proxmityPolling.lastMatch = 0
    if addon.settings.profile.showTargetingOnProximity then
        for name, data in pairs(proxmityPolling.scannedTargets) do
            if data.kind == 'friendly' then proxmityPolling.scannedTargets[name] = nil end
        end
    end

    self:UpdateTargetFrame()
end

function addon.targeting:UpdateEnemyList(unitscan, mobs, addEntries)
    FilterList(unitscan)
    FilterList(mobs)

    if addEntries then
        local update, found

        for _, unit in ipairs(unitscan) do
            found = false

            for _, src in ipairs(unitscanList) do
                if src == unit then
                    found = true
                    break
                end
            end

            if not found then
                update = true
                tinsert(unitscanList, unit)
                lowPrioTargets[unit] = true
            end
        end

        for _, unit in ipairs(mobs) do
            found = false
            for _, src in ipairs(mobList) do
                if src == unit then
                    found = true
                    break
                end
            end
            if not found then
                tinsert(mobList, unit)
                update = true
                lowPrioTargets[unit] = true
            end
        end
        if not update then return end
    elseif addEntries == false then
        table.wipe(lowPrioTargets)
        unitscanList = unitscan
        mobList = mobs
    else
        unitscanList = unitscan
        mobList = mobs
    end

    self:UpdateMacro()

    if not addon.settings.profile.enableTargetAutomation then return end

    if addon.gameVersion == 30300 then
        legacyScanner.wantedDirty = true
        self:LegacyScanTick()
        if not InCombatLockdown() then self:UpdateTargetFrame() end
        return
    end

    proxmityPolling.match = false
    proxmityPolling.lastMatch = 0
    if addon.settings.profile.showTargetingOnProximity then
        for name, data in pairs(proxmityPolling.scannedTargets) do
            if data.kind == 'unitscan' or data.kind == 'mob' then proxmityPolling.scannedTargets[name] = nil end
        end
    end

    self:UpdateTargetFrame()
end

function addon.targeting:CanCreateMacro()
    if GetMacroInfo(self.macroName) then return true end
    local accountMacros = GetNumMacros()
    local maximum = _G.MAX_ACCOUNT_MACROS or
                        (addon.gameVersion == 30300 and 36 or 120)
    return (accountMacros or 0) < maximum
end

local function UpdateIconFrameVisuals(self, updateFrame)
    self:SetScale(addon.settings.profile.activeTargetScale or 1)
    addon.targeting:RenderTargetFrameBackground()
    self.title:ClearBackdrop()
    self.title:SetBackdrop(addon.RXPFrame.backdrop.edge)
    self.title:SetBackdropColor(unpack(addon.colors.background))
    self.title.text:SetFont(addon.font, 9, "")
    self.title.text:SetTextColor(unpack(addon.activeTheme.textColor))
    self.title:SetSize(self.title.text:GetStringWidth() + 14, 19)
end

function addon.targeting:CreateTargetFrame()
    -- Still create frame even if targeting disabled, for frame location preservation
    if self.activeTargetFrame then return self.activeTargetFrame end

    self.activeTargetFrame = CreateFrame("Frame", "RXPTargetFrame", UIParent,
                                         BackdropTemplateMixin and "BackdropTemplate" or nil)
    local f = self.activeTargetFrame

    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:Hide()

    addon.enabledFrames["activeTargetFrame"] = f
    f.IsFeatureEnabled = function()
        -- The 3.3.5 world map is a fullscreen panel rather than the modern
        -- movable map canvas. Keep secure target buttons out of that panel and
        -- restore them from the current target lists when the map closes.
        if IsLegacyWorldMapOpen() then return false, true end
        if not addon.settings.profile.enableTargetAutomation then return nil, true end

        if addon.settings.profile.showTargetingOnProximity then
            local dangerousVisible =
                addon.settings.profile.enableTips and
                addon.settings.profile.showDangerousUnitscan and
                    next(dangerousTargets) ~= nil and proxmityPolling.match
            return (shouldTargetCheck() or dangerousVisible) and
                       (HasVisibleCurrentStepTarget() or
                           proxmityPolling.match), true
        end

        return shouldTargetCheck() or
                   (addon.settings.profile.enableTips and
                       addon.settings.profile.showDangerousUnitscan and
                       next(dangerousTargets) ~= nil and
                       proxmityPolling.match)
    end

    self:RenderTargetFrameBackground()

    f.onMouseDown = function()
        if addon.settings.profile.lockFrames and not IsAltKeyDown() then return end
        f:StartMoving()
    end

    function f.onMouseUp()
        f:StopMovingOrSizing()
        addon.settings:SaveFramePositions()
    end

    f:SetScript("OnMouseDown", f.onMouseDown)
    f:SetScript("OnMouseUp", f.onMouseUp)
    f.friendlyTargetButtons = {}
    f.enemyTargetButtons = {}

    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    f.title = CreateFrame("Frame", "$parent_title", f, BackdropTemplateMixin and "BackdropTemplate" or nil)
    f.title:SetPoint("TOPLEFT", f, 5, 5)
    f.title:ClearBackdrop()
    f.title:SetBackdrop(addon.RXPFrame.backdrop.edge)
    f.title:SetBackdropColor(unpack(addon.colors.background))

    f.title.text = f.title:CreateFontString(nil, "OVERLAY")
    f.title.text:ClearAllPoints()
    f.title.text:SetPoint("CENTER", f.title, 0, 2)
    f.title.text:SetJustifyH("CENTER")
    f.title.text:SetJustifyV("MIDDLE")
    f.title.text:SetTextColor(unpack(addon.activeTheme.textColor))
    f.title.text:SetFont(addon.font, 9, "")
    f.title.text:SetText(L "Active Targets")

    f.title:SetSize(f.title.text:GetStringWidth() + 14, 19)

    f.title:EnableMouse(true)
    f.title:SetScript("OnMouseDown", f.onMouseDown)
    f.title:SetScript("OnMouseUp", f.onMouseUp)

    f.UpdateVisuals = UpdateIconFrameVisuals
    f:SetHeight(40)
    f:SetScale(addon.settings.profile.activeTargetScale)

    if addon.gameVersion == 30300 and _G.WorldMapFrame and
        _G.WorldMapFrame.HookScript then
        _G.WorldMapFrame:HookScript("OnShow", function()
            if InCombatLockdown() then
                legacyScanner.frameDirty = true
            else
                f:Hide()
            end
        end)
        _G.WorldMapFrame:HookScript("OnHide", function()
            if InCombatLockdown() then
                legacyScanner.frameDirty = true
            else
                addon.targeting:UpdateTargetFrame()
            end
        end)
    end
    return f
end

-- Guide restoration can publish target lists before the optional targeting
-- subsystem has completed Setup (or after another required subsystem failed).
-- Lazily create the unprotected container, but never attempt secure frame work
-- during combat. This keeps a startup failure from cascading into a nil-frame
-- error while preserving the normal Setup path and its event ownership.
function addon.targeting:EnsureTargetFrame()
    if self.activeTargetFrame then return self.activeTargetFrame end
    if InCombatLockdown() then
        legacyScanner.frameDirty = true
        return
    end
    return self:CreateTargetFrame()
end

function addon.targeting:RenderTargetFrameBackground()
    if not self.activeTargetFrame then return end

    local f = self.activeTargetFrame
    -- print(RXP.activeTheme.texturePath)
    if addon.settings.profile.hideActiveTargetsBackground then
        f:ClearBackdrop()
    else
        f:ClearBackdrop()
        f:SetBackdrop(addon.RXPFrame.backdrop.edge)
        f:SetBackdropColor(unpack(addon.colors.background))
    end
end

local fOnEnter = function(self)
    if self:IsForbidden() or GameTooltip:IsForbidden() or not self.targetData then return end

    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)

    if self.targetData.kind == "friendly" then
        GameTooltip:AddLine(self.targetData.name, 0, 1, 0)
    else
        GameTooltip:AddLine(self.targetData.name, 1, 0, 0)
    end

    GameTooltip:Show()
end

local fOnLeave = function(self)
    if self:IsForbidden() or _G.GameTooltip:IsForbidden() then return end

    GameTooltip:Hide()
end

function addon.targeting:GetMarkerIndex(kind, kindIndex)
    local raidTargetIndex

    -- kindIndex is always >= 1, but to preserve modulus do -1
    kindIndex = kindIndex - 1

    if kind == 'friendly' then
        -- Use star 1, circle 2, diamond 3, and triangle 4
        -- 0 % 4 = 0 + 1, 3 % 4 = 3 + 1, 4 % 4 = 0 + 1, 5 % 4 = 1 + 1
        raidTargetIndex = (kindIndex % 4) + 1
    elseif kind == 'unitscan' or kind == 'rare' or kind == 'dangerous' then
         -- Use moon 5
        raidTargetIndex = 5
    elseif kind == 'mob' then
        -- Use skull 8, cross 7, square 6
        -- 0 % 3 = 8 - 0, 2 % 3 = 8 - 2
        raidTargetIndex = 8 - (kindIndex % 3)
    end

    return raidTargetIndex
end

function addon.targeting:UpdateMarker(kind, unitId, index)
    if InCombatLockdown() or not unitId or
        (UnitIsDead(unitId) and kind ~= 'friendly') or UnitIsPlayer(unitId) or
        UnitIsUnit(unitId, "pet") then return end

    if addon.gameVersion == 30300 then
        if GetNumRaidMembers() > 0 and
            not (UnitIsPartyLeader("player") or UnitIsRaidOfficer("player")) then
            return
        elseif GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0 and
            not UnitIsPartyLeader("player") then
            return
        end
    elseif IsInGroup() and not UnitIsGroupLeader('player') then
        return
    end

    local markerId = self:GetMarkerIndex(kind, index)

    -- Preserve any existing marker rather than overwriting another player's mark.
    local existingMarker = GetRaidTargetIndex(unitId)
    if markerId and (existingMarker == nil or existingMarker == 0) then
        SetRaidTarget(unitId, markerId)
        if addon.gameVersion == 30300 and type(UnitGUID) == "function" then
            local guid = UnitGUID(unitId)
            if guid then legacyOwnedMarkers[guid] = markerId end
        end
    end
end

addon.targeting.portraitCache = {}
addon.targeting.activeIcons = {}
local iconCounter = 0

local function GetIcon(unit)
    local texture = addon.targeting.portraitCache[unit]
    local time = GetTime()

    if not texture then
        if iconCounter < 30 then
            texture = addon.targeting.activeTargetFrame:CreateTexture()
            -- Default to the placeholder icon so the portrait isn't a bare red
            -- square before SetPortraitTexture provides a real portrait (3.3.5a).
            SetPlaceholder(texture, mobPlaceholder)
            texture.isDefault = true
            iconCounter = iconCounter + 1
        else
            local lastActive = time
            local oldest
            local name

            for u, f in pairs(addon.targeting.portraitCache) do
                if f.lastActive < lastActive then
                    lastActive = f.lastActive
                    oldest = f
                    name = u
                end
            end

            addon.targeting.portraitCache[name] = nil
            texture = oldest
        end
    end

    addon.targeting.portraitCache[unit] = texture

    texture.unit = unit
    texture.lastActive = time

    return texture
end

local function CacheUnitPortrait(name, unit)
    if not (name and unit and UnitName(unit) == name) then return end
    local texture = GetIcon(name)
    SetPortraitTexture(texture, unit)
    -- Pooled textures may previously have been a cropped icon or raid marker.
    -- A unit portrait must always use the complete portrait texture.
    texture:SetTexCoord(0, 1, 0, 1)
    texture:SetVertexColor(1, 1, 1, 1)
    texture.isDefault = false
    return texture
end

local function GetUnitTexture(self, name, unit)
    local f = addon.targeting.portraitCache[name]

    if f and f.anchor then f.anchor:Show() end

    -- unit = unit or 'target'
    if unit and name and UnitName(unit) == name then
        f = CacheUnitPortrait(name, unit)
    end

    if f then
        -- self.placeholder:Hide()
        f.anchor = self.placeholder

        addon.targeting.activeIcons[f] = true

        f:SetParent(self)
        f:SetAllPoints(self)
        f:Show()

        self.placeholder:Hide()
        self.icon = f

        return f
    else
        self.placeholder:Show()

        self.icon = self.placeholder

        return self.placeholder
    end
end

local buttonsPerRow = 4
local function GetTargetGridMetrics(count, rightPadding)
    if count <= 0 then return 0, 0 end
    return mmin(count, buttonsPerRow) * 27 + rightPadding,
        ceil(count / buttonsPerRow)
end

local function RowifyTargets(targetFrame, btn, buttons, kind)
    local buttonKindCount = #buttons

    btn:ClearAllPoints()

    -- isNewRow == 0 when new row
    local isNewRow = (buttonKindCount - 1) % buttonsPerRow

    if buttonKindCount == 1 then
        if kind == "enemy" then
            btn:SetPoint("TOPLEFT", targetFrame, "TOPLEFT", 6, -11)
        else -- Friendly
            btn:SetPoint("BOTTOMLEFT", targetFrame, "BOTTOMLEFT", 6, 6)
        end

        return
    end

    if kind == "enemy" then
        if isNewRow == 0 then
            btn:SetPoint("TOP", buttons[buttonKindCount - buttonsPerRow], "BOTTOM", 0, 0)
        else
            btn:SetPoint("CENTER", buttons[buttonKindCount - 1], "CENTER", 27, 0)
        end
    else -- Friendly, build from bottom up to simplify height logic
        if isNewRow == 0 then
            btn:SetPoint("BOTTOM", buttons[buttonKindCount - buttonsPerRow], "TOP", 0, 0)
        else
            btn:SetPoint("CENTER", buttons[buttonKindCount - 1], "CENTER", 27, 0)
        end
    end
end

local function ResizeTargetsFrame(targetFrame, friendlyCount, enemyCount)
    local enemyWidth, enemyRows = GetTargetGridMetrics(enemyCount, 8)
    local friendlyWidth, friendlyRows = GetTargetGridMetrics(friendlyCount, 8)

    targetFrame:SetWidth(mmax(targetFrame.title:GetWidth() + 10, friendlyWidth, enemyWidth))

    -- Header offset + rows
    targetFrame:SetHeight(18 + (enemyRows + friendlyRows) * 25)
end

function addon.targeting:UpdateTargetFrame(selector)
    if not addon.settings.profile.enableTargetAutomation then return end

    local targetFrame = self:EnsureTargetFrame()
    if not targetFrame then return end

    local selectorName = selector and UnitName(selector)
    if addon.gameVersion == 30300 and selectorName then
        if legacyScanner.wantedDirty then self:RebuildLegacyWanted() end
        self:RecordSeenTarget(selectorName, nil, GetTime(), selector)
    end

    -- Portrait textures are not protected. Capture the real target/mouseover
    -- image even if combat requires the secure target buttons to render later.
    if selectorName then CacheUnitPortrait(selectorName, selector) end

    if InCombatLockdown() then
        legacyScanner.frameDirty = true
        return
    end

    local enemyTargetButtons = targetFrame.enemyTargetButtons
    local enemyTargetButtonIndex = 0
    local enemiesList, enemyNames = {}, {}
    local function AddEnemy(name, kind)
        if type(name) == "string" and name ~= "" and not enemyNames[name] then
            enemyNames[name] = true
            tinsert(enemiesList, {name = name, kind = kind})
        end
    end
    local function AddSortedMapEntries(source, predicate, callback)
        local names = {}
        for name, data in pairs(source) do
            if predicate(name, data) then tinsert(names, name) end
        end
        table.sort(names)
        for _, name in ipairs(names) do callback(name, source[name]) end
    end

    if not addon.settings.profile.showTargetingOnProximity then
        -- If proximity disabled, show all
        if addon.settings.profile.enableEnemyTargeting then
            for _, name in ipairs(unitscanList) do AddEnemy(name, "unitscan") end
            for _, name in ipairs(mobList) do AddEnemy(name, "mob") end
        end
    end

    if addon.settings.profile.showTargetingOnProximity then
        if addon.settings.profile.enableEnemyTargeting then
            -- Start with guide order so the four directly bindable buttons do
            -- not change targets simply because Lua hashes were re-iterated.
            -- Modern clients have direct nameplate tokens; legacy proximity
            -- mode must contain observed targets only.  Seeding it from the
            -- current step made the option indistinguishable from persistent
            -- placeholder mode.
            if addon.gameVersion ~= 30300 then
                for _, name in ipairs(unitscanList) do
                    local data = currentStepTargets[name]
                    if data and data.kind ~= "friendly" then
                        AddEnemy(name, data.kind)
                    end
                end
                for _, name in ipairs(mobList) do
                    local data = currentStepTargets[name]
                    if data and data.kind ~= "friendly" then
                        AddEnemy(name, data.kind)
                    end
                end
                AddSortedMapEntries(currentStepTargets,
                    function(name, data)
                        return data.kind ~= "friendly" and not enemyNames[name]
                    end,
                    function(name, data) AddEnemy(name, data.kind) end)
            end

            for _, name in ipairs(unitscanList) do
                local data = proxmityPolling.scannedTargets[name]
                if data and data.kind ~= "friendly" then AddEnemy(name, data.kind) end
            end
            for _, name in ipairs(mobList) do
                local data = proxmityPolling.scannedTargets[name]
                if data and data.kind ~= "friendly" then AddEnemy(name, data.kind) end
            end
            for _, name in ipairs(rareTargets) do
                local data = proxmityPolling.scannedTargets[name]
                if data and data.kind ~= "friendly" then AddEnemy(name, data.kind) end
            end
            AddSortedMapEntries(proxmityPolling.scannedTargets,
                function(name, data)
                    return data.kind ~= "friendly" and not enemyNames[name]
                end,
                function(name, data) AddEnemy(name, data.kind) end)
        end
    end

    -- Zone danger records are never persistent placeholders, even when the
    -- ordinary Active Targets mode is persistent.
    if addon.settings.profile.enableEnemyTargeting and
        addon.settings.profile.enableTips and
        addon.settings.profile.showDangerousUnitscan then
        for _, name in ipairs(dangerousTargets) do
            local data = proxmityPolling.scannedTargets[name]
            if data and data.kind == "dangerous" then
                AddEnemy(name, "dangerous")
            end
        end
    end

    for frame in pairs(addon.targeting.activeIcons) do
        frame:Hide()

        if frame.anchor then
            frame.anchor:Show()
            frame.anchor = nil
        end
    end

    table.wipe(addon.targeting.activeIcons)

    local btn, icon, ht
    for _, targetData in ipairs(enemiesList) do
        local targetName, enemyKind = targetData.name, targetData.kind

        enemyTargetButtonIndex = enemyTargetButtonIndex + 1
        btn = enemyTargetButtons[enemyTargetButtonIndex]

        if not btn then
            btn = CreateFrame("Button", "RXPTargetFrame_EnemyButton" .. enemyTargetButtonIndex, targetFrame, "SecureActionButtonTemplate")

            btn:SetAttribute("type", "macro")
            btn:SetAttribute("type1", "macro")
            btn:SetSize(25, 25)

            -- A single physical click must run the secure macro once. Registering
            -- both edges cleared and reacquired the target twice, interrupting
            -- or visually restarting auto-attack on the legacy client.
            if btn.RegisterForClicks then btn:RegisterForClicks("AnyUp") end

            tinsert(enemyTargetButtons, btn)

            RowifyTargets(targetFrame, btn, enemyTargetButtons, "enemy")

            btn.icon = btn:CreateTexture(nil, "BACKGROUND")
            btn.placeholder = btn.icon
            btn.placeholder.isDefault = true
            btn.GetUnitTexture = GetUnitTexture

            icon = btn.icon

            icon.isDefault = true
            icon:SetAllPoints(true)
            SetPlaceholder(icon, mobPlaceholder)

            btn:SetScript("OnEnter", fOnEnter)
            btn:SetScript("OnLeave", fOnLeave)

            ht = btn:CreateTexture(nil, "HIGHLIGHT")

            ht:SetAllPoints(true)
            ht:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
            ht:SetBlendMode("ADD")
        end

        local targetMacro = '/targetexact ' .. targetName
        btn:SetAttribute('macrotext', targetMacro)
        btn:SetAttribute('macrotext1', targetMacro)

        if btn.targetData and btn.targetData.name ~= targetName then
            SetPlaceholder(btn.placeholder, mobPlaceholder)
            btn.placeholder.isDefault = true
        end

        btn:GetUnitTexture(targetName, selector)
        btn.targetData = {name = targetName, kind = enemyKind}

        -- If target or mouseover, set portrait
        if selector and UnitName(selector) == targetName and btn.icon.isDefault then
            SetPortraitTexture(btn.placeholder, selector)
            btn.placeholder.isDefault = false
        end

        btn:Show()
    end

    local friendlyTargetButtons = targetFrame.friendlyTargetButtons
    local friendlyTargetButtonIndex = 0
    -- If proximity disabled, show all
    local friendlyList = {}
    local friendlyNames = {}
    local function AddFriendly(name)
        if name and not friendlyNames[name] then
            friendlyNames[name] = true
            tinsert(friendlyList, name)
        end
    end

    if addon.settings.profile.enableFriendlyTargeting then
        if not addon.settings.profile.showTargetingOnProximity then
            for _, name in ipairs(targetList) do AddFriendly(name) end
        else
            if addon.gameVersion ~= 30300 then
                for _, name in ipairs(targetList) do
                    local data = currentStepTargets[name]
                    if data and data.kind == "friendly" then AddFriendly(name) end
                end
                AddSortedMapEntries(currentStepTargets,
                    function(name, data)
                        return data.kind == "friendly" and not friendlyNames[name]
                    end,
                    function(name) AddFriendly(name) end)
            end
        end
    end

    if addon.settings.profile.showTargetingOnProximity and
        addon.settings.profile.enableFriendlyTargeting then
        for _, name in ipairs(targetList) do
            local data = proxmityPolling.scannedTargets[name]
            if data and data.kind == "friendly" then AddFriendly(name) end
        end
        AddSortedMapEntries(proxmityPolling.scannedTargets,
            function(name, data)
                return data.kind == "friendly" and not friendlyNames[name]
            end,
            function(name)
                AddFriendly(name)
            end
        )
    end

    for _, targetName in ipairs(friendlyList) do
        friendlyTargetButtonIndex = friendlyTargetButtonIndex + 1
        btn = friendlyTargetButtons[friendlyTargetButtonIndex]

        if not btn then
            btn = CreateFrame("Button", "RXPTargetFrame_FriendlyButton" .. friendlyTargetButtonIndex, targetFrame, "SecureActionButtonTemplate")
            btn:SetAttribute("type", "macro")
            btn:SetAttribute("type1", "macro")
            btn:SetSize(25, 25)

            if btn.RegisterForClicks then btn:RegisterForClicks("AnyUp") end

            tinsert(friendlyTargetButtons, btn)

            RowifyTargets(targetFrame, btn, friendlyTargetButtons, "friendly")

            btn.icon = btn:CreateTexture(nil, "BACKGROUND")

            icon = btn.icon

            btn.placeholder = icon

            icon.isDefault = true
            icon:SetAllPoints(true)
            SetPlaceholder(icon, targetPlaceholder)

            btn.GetUnitTexture = GetUnitTexture
            btn:SetScript("OnEnter", fOnEnter)
            btn:SetScript("OnLeave", fOnLeave)

            ht = btn:CreateTexture(nil, "HIGHLIGHT")

            ht:SetAllPoints(true)
            ht:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
            ht:SetBlendMode("ADD")
        end

        local targetMacro = '/targetexact ' .. targetName
        btn:SetAttribute('macrotext', targetMacro)
        btn:SetAttribute('macrotext1', targetMacro)

        if btn.targetData and btn.targetData.name ~= targetName then
            SetPlaceholder(btn.placeholder, targetPlaceholder)
            btn.placeholder.isDefault = true
        end

        btn:GetUnitTexture(targetName, selector)

        btn.targetData = {name = targetName, kind = "friendly"}

        -- If target or mouseover, set portrait
        if selector and btn.placeholder.isDefault and UnitName(selector) == targetName then
            SetPortraitTexture(btn.placeholder, selector)
            btn.placeholder.isDefault = false
        end

        btn:Show()
    end

    if friendlyTargetButtonIndex > 0 or enemyTargetButtonIndex > 0 then targetFrame:SetAlpha(1) end

    for f = friendlyTargetButtonIndex + 1, #friendlyTargetButtons do
        friendlyTargetButtons[f]:Hide()
        friendlyTargetButtons[f]:SetAttribute("macrotext", "")
        friendlyTargetButtons[f]:SetAttribute("macrotext1", "")
        friendlyTargetButtons[f].targetData = nil
        SetPlaceholder(friendlyTargetButtons[f].placeholder, targetPlaceholder)
        friendlyTargetButtons[f].icon.isDefault = true
    end

    for e = enemyTargetButtonIndex + 1, #enemyTargetButtons do
        enemyTargetButtons[e]:Hide()
        enemyTargetButtons[e]:SetAttribute("macrotext", "")
        enemyTargetButtons[e]:SetAttribute("macrotext1", "")
        enemyTargetButtons[e].targetData = nil
        SetPlaceholder(enemyTargetButtons[e].placeholder, mobPlaceholder)
        enemyTargetButtons[e].icon.isDefault = true
    end

    ResizeTargetsFrame(targetFrame, friendlyTargetButtonIndex, enemyTargetButtonIndex)

    if (friendlyTargetButtonIndex == 0 and enemyTargetButtonIndex == 0) or
        not addon.settings.profile.showEnabled or IsLegacyWorldMapOpen() then
        targetFrame:Hide()
    else
        targetFrame:Show()
    end
end

function addon.targeting:ZONE_CHANGED_NEW_AREA()
    wipe(legacyOwnedMarkers)
    self:LoadRares()
end

function addon.targeting:LoadRares()
    if not addon.settings.profile.scanForRares or not addon.settings.profile.showTargetingOnProximity or
        not addon.settings.profile.enableTargetAutomation or not addon.rares then return end

    -- Reset found rares
    for name, data in pairs(proxmityPolling.scannedTargets) do
        if data.kind == 'rare' then proxmityPolling.scannedTargets[name] = nil end
    end

    local zoneID = HBD:GetPlayerZone()
    local zoneName = ""

    for name, id in pairs(addon.mapId) do
        if id == zoneID then
            zoneName = name
            break
        end
    end

    local zone = GetRealZoneText()
    local subzone = GetSubZoneText()

    if not zoneID then return end
    rareTargets = addon.rares[subzone] or addon.rares[zone] or addon.rares[zoneID] or addon.rares[zoneName] or {}

    if addon.gameVersion == 30300 then
        legacyScanner.wantedDirty = true
        self:LegacyScanTick()
    end
    self:UpdateTargetFrame()
end

function addon.targeting:RefreshRareScanning()
    if addon.settings.profile.scanForRares then
        self:LoadRares()
        return
    end

    -- rareTargets may directly reference the current zone's entry in
    -- addon.rares. Replace the view instead of wiping the shared database.
    rareTargets = {}
    for name, data in pairs(proxmityPolling.scannedTargets) do
        if data.kind == "rare" then
            proxmityPolling.scannedTargets[name] = nil
        end
    end
    if addon.gameVersion == 30300 then
        legacyScanner.wantedDirty = true
        self:LegacyScanTick()
    end
    self:UpdateTargetFrame()
end

function addon.ResetTargetPosition()
    local f = _G.RXPTargetFrame

    f:ClearAllPoints()
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end
