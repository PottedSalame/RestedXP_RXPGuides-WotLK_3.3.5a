local addonName, addon = ...

local _G = _G

local AceConfig = LibStub("AceConfig-3.0")
local LibDBIcon = LibStub("LibDBIcon-1.0")
local LibDataBroker = LibStub("LibDataBroker-1.1")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0", true)
local EasyMenu = function(...)
    if _G.EasyMenu then
        _G.EasyMenu(...)
    else
        LibDD:EasyMenu(...)
    end
end

local IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or _G.IsAddOnLoaded
local GetNumAddOns =  C_AddOns and C_AddOns.GetNumAddOns or _G.GetNumAddOns
local GetAddOnInfo = C_AddOns and C_AddOns.GetAddOnInfo or _G.GetAddOnInfo

local GetItemInfo = C_Item and C_Item.GetItemInfo or _G.GetItemInfo

local fmt, tostr, next, GetTime = string.format, tostring, next, GetTime

local INV_HEIRLOOM = _G.Enum.ItemQuality.Heirloom
-- local gameVersion = select(4, GetBuildInfo())

-- Unitscan functionality broken on mop, retail, and classic
local unitscanEnabled = false -- gameVersion >= 11508 and gameVersion < 50000

--Backward compatibility
if _G.ShouldShowTargetFrame then
    unitscanEnabled = false
elseif (tonumber(select(3,_G.GetBuildInfo()):match("%d+$")) or 0) < 2025 then
    unitscanEnabled = true
end

local importCache = {
    bufferString = "",
    displayString = "",
    bufferData = {},
    lastBuffer = 0,
    widget = nil,
    workerFrame = addon.RXPFrame,
    lastBNetQuery = GetTime()
}
local incompatibleAddons = {}
local settingsDB
local loadedProfileKey
local ProcessBuffer
local updateFrequencyTimer

-- Alias addon.locale.Get
local L = addon.locale.Get

-- Some 3.3.5 private-server UI packs (or addons loaded before RXP) install an
-- incomplete retail-style Settings global. Newer AceConfigDialog revisions
-- then select their retail registration branch, even though the stub returns
-- no category, and fail while indexing category.ID. Force AceConfig's proven
-- InterfaceOptions fallback for this synchronous registration call. This also
-- makes load order irrelevant when another addon publishes a newer AceConfig.
local function AddToBlizzardOptions(appName, name, parent, ...)
    if addon.gameVersion ~= 30300 then
        return AceConfigDialog:AddToBlizOptions(appName, name, parent, ...)
    end

    local clientSettings = rawget(_G, "Settings")
    _G.Settings = nil
    local ok, panel, categoryID = pcall(AceConfigDialog.AddToBlizOptions,
                                        AceConfigDialog, appName, name, parent,
                                        ...)
    _G.Settings = clientSettings
    if not ok then error(panel, 2) end
    return panel, categoryID
end

addon.settings = addon:NewModule("Settings", "AceConsole-3.0")
addon.settings.enabledBetaFeatures = {}
-- All first-party option panels must pass through this adapter. On interface
-- 30300, a partial retail Settings API supplied by another addon can otherwise
-- make newer AceConfigDialog revisions choose an incompatible registration
-- path and return a nil category.
addon.settings.AddToBlizzardOptions = AddToBlizzardOptions

local function RunOnNextFrame(callback)
    if _G.RunNextFrame then
        _G.RunNextFrame(callback)
    elseif _G.C_Timer and _G.C_Timer.After then
        _G.C_Timer.After(0, callback)
    else
        callback()
    end
end

-- Numeric SoundKit IDs and sound-channel routing were added after 3.3.5a.
-- Keep the profile option portable by translating the existing modern IDs to
-- the legacy sound names accepted by the Wrath client.
local legacyTargetSoundMap = {
    [3175] = "MapPing",
    [11773] = "WarDrums",
    [8959] = "RaidWarning",
    [5274] = "AuctionWindowOpen",
    [17318] = "ReadyCheck",
    [9378] = "PVPFlagTaken",
    [8960] = "ReadyCheck",
    [9374] = "PVPFlagCaptured",
    [9375] = "PVPWarning",
    [180461] = "RaidWarning",
}

local legacyTargetSoundValues = {
    none = "none",
    MapPing = "Map Ping",
    WarDrums = "War Drums",
    RaidWarning = "Raid Warning",
    AuctionWindowOpen = "Auction Window Open",
    ReadyCheck = _G.QUEUED_STATUS_READY_CHECK_IN_PROGRESS,
    PVPFlagTaken = "PVP Flag Taken",
    PVPFlagCaptured = "PVP Flag Captured",
    PVPWarning = "PVP Warning",
}

function addon.settings:NormalizeTargetingSound(sound)
    if addon.gameVersion ~= 30300 then return sound end
    if sound == nil then return "MapPing" end
    return legacyTargetSoundMap[sound] or
               legacyTargetSoundMap[tonumber(sound)] or sound
end

function addon.settings:PlayTargetingSound(sound, channel)
    sound = self:NormalizeTargetingSound(sound)
    if not sound or sound == "none" then return end
    if addon.gameVersion == 30300 then
        return pcall(_G.PlaySound, sound)
    else
        return pcall(_G.PlaySound, sound, channel)
    end
end

local function NormalizeCustomThemeTooltip(profile)
    local customTheme = profile and profile.customTheme
    if type(customTheme) == "table" and
        type(customTheme.tooltip) == "string" and
        customTheme.tooltip:match("^|c%x%x%x%x%x%xFF$") and
        customTheme.tooltip:sub(3, 4):upper() ~= "FF" then
        customTheme.tooltip = "|cFF" .. customTheme.tooltip:sub(3, 8)
    end
end

-- The standalone 3.3.5 AceConfigRegistry revision accepts only the historical
-- "half", "normal", "double", and "full" width strings. Upstream's options
-- use modern numeric relative widths throughout, which happened to work only
-- when another addon loaded a newer AceConfig first. Normalize the complete
-- tree at the integration boundary instead of maintaining a separate legacy
-- copy of every option.
local localizedAceConfigOptions = setmetatable({}, {__mode = "k"})
local function NormalizeLegacyAceConfigOptions(option)
    if addon.gameVersion ~= 30300 or type(option) ~= "table" then return end

    -- AceConfig option tables are a strict public schema. Keep translation
    -- provenance in a side table: attaching a private field to the option made
    -- older registries (and Duowan's bundled revision) reject the entire panel
    -- with "unknown parameter" on localized clients.
    for key in pairs(option) do
        if type(key) == "string" and key:match("^_rxp") then
            option[key] = nil
        end
    end
    if not localizedAceConfigOptions[option] and
        addon.locale.GetMetadataForText then
        local metadata = type(option.name) == "string" and
                             addon.locale.GetMetadataForText(option.name) or nil
        if (not metadata or not metadata.machine) and
           type(option.desc) == "string" then
            metadata = addon.locale.GetMetadataForText(option.desc)
        end
        if metadata and metadata.machine and addon.guideLocalization then
            local notice = addon.guideLocalization:GetMachineExplanation()
            local description = option.desc
            if type(description) == "string" then
                option.desc = description .. "\n\n|cff70a0ff" .. notice .. "|r"
            elseif type(description) == "function" then
                option.desc = function(...)
                    local value = description(...)
                    return tostring(value or "") .. "\n\n|cff70a0ff" ..
                               notice .. "|r"
                end
            else
                option.desc = "|cff70a0ff" .. notice .. "|r"
            end
            localizedAceConfigOptions[option] = "machine"
        end
    end

    if type(option.width) == "number" then
        if option.width <= 0.75 then
            option.width = "half"
        elseif option.width >= 2.5 then
            option.width = "full"
        elseif option.width >= 1.5 then
            option.width = "double"
        else
            option.width = "normal"
        end
    end

    -- Explicit select ordering was added after this AceConfig revision. The
    -- legacy dialog already sorts the values deterministically, so omit the
    -- unsupported hint instead of letting validation blank the whole panel.
    option.sorting = nil

    if type(option.args) == "table" then
        for _, child in pairs(option.args) do
            NormalizeLegacyAceConfigOptions(child)
        end
    end
end

function addon.settings.OpenFeatureToolSettings(toolPage)
    addon.settings.OpenSettings()
    RunOnNextFrame(function()
        if not (AceConfigDialog and AceConfigDialog.SelectGroup) then return end
        local selected = type(toolPage) == "string" and toolPage ~= "" and
                             toolPage or "routePreflight"
        pcall(AceConfigDialog.SelectGroup, AceConfigDialog, addon.title,
              "featureToolsSettings", selected)
    end)
end

if not addon.settings.gui then
    addon.settings.gui = {
        selectedDeleteGuide = "",
        importStatusHistory = {},
        panels = {}
    }
end
addon.settings.gui.panels = addon.settings.gui.panels or {}

function addon.settings.RegisterOptionsPanel(panelName, panel)
    if type(panelName) == "string" and panel then
        addon.settings.gui.panels[panelName] = panel
    end
    return panel
end

function addon.settings.OpenSettings(panelName)
    -- Interface 30300 always uses the stock Interface Options frame. Partial
    -- Settings backports supplied by private-server UI packs must not route us
    -- into AceConfig's retail category API after legacy registration.
    if addon.gameVersion == 30300 or
        not (_G.Settings and _G.Settings.GetCategory) then
        local panel = panelName and addon.settings.gui.panels[panelName]
        if not panel and panelName == "Import" then
            panel = addon.settings.gui.import
        end
        panel = panel or addon.RXPOptions
        if panel and _G.InterfaceOptionsFrame_OpenToCategory then
            _G.InterfaceOptionsFrame_OpenToCategory(panel)
            _G.InterfaceOptionsFrame_OpenToCategory(panel)
        end
        return
    end

    -- panelName only provided for Import currently
    if panelName then
        local optionsName = fmt("%s/%s", addon.RXPOptions.name, panelName)

        -- If sub category, open dedicated standalone window
        AceConfigDialog:Open(optionsName)

        local acdFrame = AceConfigDialog.OpenFrames and
                             AceConfigDialog.OpenFrames[optionsName]

        if acdFrame and acdFrame:IsShown() then
            if not acdFrame.isHooked then
                addon.settings.textboxHook()
                acdFrame.isHooked = true
            end

            -- Successfully opened sub menu
            return
        end -- else, fall through to generic handling
    end

    local category = _G.Settings.GetCategory(addon.RXPOptions.name)

    if category:HasSubcategories() then category.expanded = true end

    _G.Settings.OpenToCategory(category.ID)
end

function addon.settings.ChatCommand(input)
    if not input then addon.settings.OpenSettings() end

    input = input:trim()
    if input == "import" then
        addon.settings.OpenSettings('Import')
    elseif input == "debug" then
        addon.settings.profile.debug = not addon.settings.profile.debug
    elseif input == "splits" then
        addon.tracker:ToggleLevelSplits()
    elseif input == "split" then
        addon.tracker:ManualLevelSplit()
    elseif input == "show" or input == "hide" or input == "toggle" then
        addon.settings.ToggleActive()
    elseif input == "bug" or input == "feedback" then
        addon.comms.OpenBugReport()
    elseif input == "guides" or input == "hub" then
        if addon.guideHub then addon.guideHub:Toggle() end
    elseif input == "backup" then
        if addon.roadmap then addon.roadmap:OpenBackupWindow() end
    elseif input == "diagnose" or input == "doctor" then
        if addon.diagnostics then addon.diagnostics:Open() end
    elseif input == "preflight" or input == "reservations" then
        if addon.routePreflight then addon.routePreflight:Toggle() end
    elseif input == "watch" then
        if addon.routePreflight then addon.routePreflight:ToggleWatch() end
    elseif input == "archives" or input == "best" or input == "pb" then
        if addon.runArchive then addon.runArchive:Toggle() end
    elseif input == "pet" then
        if addon.petAssistant then addon.petAssistant:Toggle() end
    elseif input == "perf" or input == "performance" then
        if addon.performanceInspector then addon.performanceInspector:Toggle() end
    elseif input == "coach" then
        if addon.speedrunCoach then addon.speedrunCoach:Toggle() end
    elseif input == "grind" then
        if addon.speedrunGrind then addon.speedrunGrind:Toggle() end
    elseif input == "pitstop" or input == "pit" then
        if addon.speedrunPitStop then addon.speedrunPitStop:Toggle() end
    elseif input == "deathwarp" then
        if addon.speedrunDeathwarp then addon.speedrunDeathwarp:Toggle() end
    elseif input == "practice" then
        if addon.speedrunPractice then addon.speedrunPractice:Toggle() end
    elseif input == "audio" then
        if addon.speedrunAudio then addon.speedrunAudio:Toggle() end
    elseif input == "rules" then
        if addon.speedrunRules then addon.speedrunRules:Toggle() end
    elseif input == "catchup" then
        if addon.catchUp then addon.catchUp:Preview() end
    elseif input == "route" then
        if addon.speedrunRoute and self.profile.enableSpeedrunSuite ~= false and
            self.profile.enableSpeedrunRoute then
            addon.speedrunRoute:Toggle()
        elseif addon.travel then
            addon.travel:OpenCurrentRoute()
        end
    elseif input == "recover" then
        if addon.travel then addon.travel:OpenCurrentRoute() end
    elseif input:match("^lore%s") then
        local mode = input:match("^lore%s+(%S+)")
        if addon.lore and addon.lore:SetMode(mode) then
            addon.comms.PrettyPrint("Lore mode: %s", mode)
        else
            addon.comms.PrettyPrint("Use /rxp lore off, /rxp lore first, or /rxp lore always")
        end
    elseif input == "pack" or input:match("^pack%s") then
        if addon.compatibilityPacks then
            addon.compatibilityPacks:HandleCommand(input)
        end
    elseif input == "party" or input:match("^party%s") then
        if addon.partySync then addon.partySync:HandleCommand(input) end
    elseif input == "supplies" then
        if addon.supplies then addon.supplies:Toggle() end
    elseif input == "gear" then
        if addon.gearAdvisor then addon.gearAdvisor:Toggle() end
    elseif input == "gold" or input == "farming" then
        if addon.goldAssistant then addon.goldAssistant:ToggleReport() end
    elseif input == "dailies" or input == "daily" then
        if addon.activityPlanner then addon.activityPlanner:Toggle() end
    elseif input == "colorblind" or input:match("^colorblind%s") then
        local mode = input:match("^colorblind%s+(%S+)") or "off"
        if not addon.accessibility or not addon.accessibility:SetMode(mode) then
            addon.comms.PrettyPrint(
                "Use /rxp colorblind off|deuteranopia|protanopia|tritanopia|contrast")
        end
    elseif input == "record" or input:match("^record%s") then
        if addon.guideRecorder then addon.guideRecorder:HandleCommand(input) end
    elseif input == "preview" then
        addon.settings:EnableFramePreviews()
    elseif input == "next" then
        -- Manual step navigation (handy on 3.3.5a where right-click "Go to step"
        -- may be flaky): /rxp next | /rxp prev | /rxp step <n>. GoToStep clears the
        -- target's completion so going back lands on it instead of bouncing forward.
        if addon.partySync then addon.partySync:OverrideWaitOnce() end
        if addon.GoToStep then addon.GoToStep((RXPCData.currentStep or 1) + 1) end
    elseif input == "prev" or input == "previous" or input == "back" then
        if addon.GoToStep then addon.GoToStep((RXPCData.currentStep or 1) - 1) end
    elseif input:match("^step%s") or input:match("^goto%s") then
        local n = tonumber(input:match("(%d+)"))
        if n and addon.GoToStep then addon.GoToStep(n) end
    elseif input == "browse" or input == "resume" then
        -- Freeze/unfreeze automatic step progression, so the guide can be walked
        -- back through (e.g. to review or test) without it jumping to the real
        -- current step. Turning it off lets completed steps auto-advance again.
        addon.ToggleBrowseMode()
    elseif input == "help" then
        addon.comms.PrettyPrint(_G.HELP .. "\n" ..
                                    addon.help["What are command the line options?"])
    else
        addon.settings.OpenSettings()
    end
end

local settingsDBDefaults = {
    profile = {
        enableTracker = true,
        enableLevelUpAnnounceSolo = true,
        enableLevelUpAnnounceGroup = true,
        enableFlyStepAnnouncements = true,
        alwaysSendBranded = true,
        checkVersions = true,
        enableLevelingReportInspections = false,
        levelingInspectionConsent = false,
        levelSplitsHistory = 10,
        levelSplitsFontSize = 11,
        levelSplitsOpacity = 0.9,
        compareTotalTimeSplit = true,
        enableMinimapButton = true,
        enableWorldMapButton = true,
        minimap = {minimapPos = 146},

        --
        enableQuestAutomation = true,
        enableFPAutomation = true,
        enableBindAutomation = true,
        enableGossipAutomation = true,
        showUnusedGuides = true,
        anchorOrientation = "top",
        chromieTime = "auto",
        enableXpStepSkipping = true,
        enableAutomaticXpRate = true,
        showFlightTimers = true,
        showJunkIcon = true,
        enableMouseoverCorpseLoot = false,

        -- Sliders
        arrowScale = 1,
        arrowText = 9,
        windowScale = 1,
        numMapPins = 7,
        worldMapPinScale = 1,
        vendorTreasurePinScale = 0.8,
        distanceBetweenPins = 1,
        worldMapPinBackgroundOpacity = 0.35,
        batchSize = 6,
        updateFrequency = 75,
        phase = 6,
        xprate = 1,
        guideFontSize = 9,
        guideScrollSteps = 1,
        guideLanguage = "localized",
        activeItemsScale = 1,
        maxSoulShards = 100,
        preflightLookahead = 20,
        reservationLookahead = 20,
        stuckWatchdogTimeout = 120,
        adaptivePerformanceFPSThreshold = 25,

        showEnabled = true,

        -- Targeting
        enableTargetMacro = true,
        notifyOnTargetUpdates = true,
        enableTargetAutomation = true,
        enableMaxNameplateDistance = true,
        enableFriendlyTargeting = true,
        enableTargetMarking = true,
        enableEnemyTargeting = true,
        enableEnemyMarking = true,
        enableMobMarking = true,
        showTargetingOnProximity = addon.gameVersion ~= 30300 and
                                       unitscanEnabled or false,
        showDangerousMobsMap = false,
        showDangerousUnitscan = false,
        showDangerousMobWarning = false,
        soundOnFind = addon.gameVersion == 30300 and "MapPing" or 3175,
        soundOnFindChannel = 'Master',
        scanForRares = true,
        notifyOnRares = true,
        activeTargetScale = 1,

        enableAddonIncompatibilityCheck = true,
        enableVendorTreasure = true,

        -- Themes
        activeTheme = 'Default',
        customTheme = CopyTable(addon.customThemeBase),
        enableThemeLiveReload = true,

        -- Text colors
        textEnemyColor = addon.guideTextColors.default['RXP_ENEMY_'],
        textFriendlyColor = addon.guideTextColors.default['RXP_FRIENDLY_'],
        textLootColor = addon.guideTextColors.default['RXP_LOOT_'],
        textWarnColor = addon.guideTextColors.default['RXP_WARN_'],
        textPickColor = addon.guideTextColors.default['RXP_PICK_'],
        textBuyColor = addon.guideTextColors.default['RXP_BUY_'],

        -- Talents
        enableTalentGuides = true,
        previewTalents = true,
        hightlightTalentPlan = true,
        upcomingTalentCount = 5,

        enableTips = true,
        enableTipsFrame = true,
        enableItemUpgrades = true,
        enableItemUpgradesAH = true,
        disableUpgradeTooltip = false,
        showUpgradeDetailsOnHover = true,
        upgradeTooltipModifier = 1,
        enableDrowningWarning = true,
        enableDrowningWarningSound = true,
        drowningThreshold = 0.2,
        enableDrowningScreenFlash = true,
        enableQuestChoiceRecommendation = true,
        enableQuestChoiceGoldRecommendation = true,

        enableEmergencyActions = true,
        emergencyThreshold = 0.2,
        enableEmergencyIconAnimations = true,

        preLoadData = false,
        skipMissingPreReqs = false,

        dungeons = {},

        framePositions = {},
        frameSizes = {},
        toolWindowAppearance = {},

        -- Grouping
        shareQuests = false,

        loreMode = "off",
        partyGuideSync = false,
        partyGuideWait = false,
        colorBlindMode = "off",
        enableRoutePreflight = true,
        enableXPShortfallPredictor = true,
        enableItemReservations = true,
        enablePetAssistant = true,
        enableAdaptivePerformance = false,
        showXPRemaining = true,
        enableMobXPEstimator = true,
        adaptiveMobXP = true,
        xpEstimatorShowStockXP = true,
        xpEstimatorShowKills = true,
        xpEstimatorShowAdaptive = true,
        xpEstimatorShowAdaptiveKills = true,
        xpEstimatorShowRested = true,

        -- Speedrunning Suite. The coach records lightweight step splits by
        -- default, while every advisor and active cue remains opt-in.
        enableSpeedrunSuite = true,
        enableSpeedrunCoach = true,
        enableSpeedrunGrind = false,
        enableSpeedrunPitStop = false,
        enableSpeedrunRoute = false,
        enableSpeedrunDeathwarp = false,
        enableSpeedrunPractice = false,
        enableSpeedrunAudio = false,
        enableSpeedrunRules = false,
        speedrunDisplayClock = "active",
        speedrunComparison = "pb",
        speedrunPaceThreshold = 15,
        speedrunGrindLookahead = 20,
        speedrunPitStopLookahead = 20,
        speedrunRuleset = "solo-any",
        speedrunCustomRules = {
            allowDeaths = false,
            allowGrouping = false,
            allowRestedXP = false,
            allowHeirlooms = false,
            allowXPRateChanges = false,
            allowGuideChanges = false,
            allowManualSkips = false,
        },
        speedrunAudioMuteCombat = true,
        speedrunAudioLeadSteps = 1,
        speedrunAudioCategories = {},
    }
}

function addon.settings:InitializeDatabase()
    -- New character settings format
    -- Only set defaults for enabled = true
    if type(RXPData.defaultProfile) ~= "table" or not RXPData.defaultProfile.profile then
        RXPData.defaultProfile = false
    end

    settingsDB = LibStub("AceDB-3.0"):New("RXPSettings", RXPData.defaultProfile or settingsDBDefaults)

    settingsDB.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
    settingsDB.RegisterCallback(self, "OnProfileCopied", "CopyProfile")
    settingsDB.RegisterCallback(self, "OnProfileReset", "ResetProfile")
    self.profile = settingsDB.profile
    self.profile.soundOnFind = self:NormalizeTargetingSound(
                                   self.profile.soundOnFind)
    self.profile.guideScrollSteps = math.max(1, math.min(10,
        math.floor(tonumber(self.profile.guideScrollSteps) or 1)))
    self.profile.preflightLookahead = math.max(1, math.min(100,
        math.floor(tonumber(self.profile.preflightLookahead) or 20)))
    self.profile.reservationLookahead = math.max(1, math.min(100,
        math.floor(tonumber(self.profile.reservationLookahead) or 20)))
    self.profile.stuckWatchdogTimeout = math.max(30, math.min(600,
        math.floor(tonumber(self.profile.stuckWatchdogTimeout) or 120)))
    self.profile.adaptivePerformanceFPSThreshold = math.max(15, math.min(60,
        math.floor(tonumber(self.profile.adaptivePerformanceFPSThreshold) or 25)))
    self.profile.speedrunGrindLookahead = math.max(1, math.min(100,
        math.floor(tonumber(self.profile.speedrunGrindLookahead) or 20)))
    self.profile.speedrunPitStopLookahead = math.max(1, math.min(100,
        math.floor(tonumber(self.profile.speedrunPitStopLookahead) or 20)))
    NormalizeCustomThemeTooltip(self.profile)
    loadedProfileKey = settingsDB.keys.profile
end

function addon.settings:InitializeSettings()
    self:CreateAceOptionsPanel()
    self:CreateImportOptionsPanel()
    self:MigrateLegacySettings()
    self:MigrateProfile()
    self:LoadTextColors()

    self:RegisterChatCommand("rxp", self.ChatCommand)
    self:RegisterChatCommand("rxpg", self.ChatCommand)
    self:RegisterChatCommand("rxpguides", self.ChatCommand)
end

function addon.settings:MigrateLegacySettings()
    if not RXPData or not RXPCData then return end

    local d = addon.settings.profile.debug
    local db = addon.settings.profile
    local pp = addon.comms.PrettyPrint
    local function n(t, v)
        if d then pp(fmt("Migrating %s = %s", t, tostr(v))) end
    end

    db.minimap.show = nil

    if RXPData.disableQuestAutomation ~= nil then
        n("disableQuestAutomation", RXPData.disableQuestAutomation)
        db.enableQuestAutomation = not RXPData.disableQuestAutomation
        RXPData.disableQuestAutomation = nil
    end

    if RXPData.disableTrainerAutomation ~= nil then
        n("disableTrainerAutomation", RXPData.disableTrainerAutomation)
        db.enableTrainerAutomation = not RXPData.disableTrainerAutomation
        RXPData.disableTrainerAutomation = nil
    end

    if RXPData.disableFPAutomation ~= nil then
        n("disableFPAutomation", RXPData.disableFPAutomation)
        db.enableFPAutomation = not RXPData.disableFPAutomation
        RXPData.disableFPAutomation = nil
    end

    if RXPData.hideMiniMapPins ~= nil then
        n("hideMiniMapPins", RXPData.hideMiniMapPins)
        db.hideMiniMapPins = RXPData.hideMiniMapPins
        RXPData.hideMiniMapPins = nil
    end

    if RXPData.hideUnusedGuides ~= nil then
        n("hideUnusedGuides", RXPData.hideUnusedGuides)
        db.showUnusedGuides = not RXPData.hideUnusedGuides
        RXPData.hideUnusedGuides = nil
    end


    if RXPCData.disableArrow ~= nil then
        n("disableArrow", RXPCData.disableArrow)
        db.disableArrow = RXPCData.disableArrow
        RXPCData.disableArrow = nil
    end

    if RXPCData.disableItemWindow ~= nil then
        n("disableItemWindow", RXPCData.disableItemWindow)
        db.disableItemWindow = RXPCData.disableItemWindow
        RXPCData.disableItemWindow = nil
    end

    if RXPCData.hideWindow ~= nil then
        n("hideWindow", RXPCData.hideWindow)
        db.hideGuideWindow = RXPCData.hideWindow
        RXPCData.hideWindow = nil
    end

    if RXPData.lockFrames ~= nil then
        n("lockFrames", RXPData.lockFrames)
        db.lockFrames = RXPData.lockFrames
        RXPData.lockFrames = nil
    end

    if RXPCData.frameHeight ~= nil then
        n("frameHeight", RXPCData.frameHeight)
        db.frameHeight = RXPCData.frameHeight
        RXPCData.frameHeight = nil
    end

    if RXPData.mapCircle ~= nil then
        n("mapCircle", RXPData.mapCircle)
        db.mapCircle = RXPData.mapCircle
        RXPData.mapCircle = nil
    end

    if RXPCData.hardcore ~= nil then
        n("hardcore", RXPCData.hardcore)
        db.hardcore = RXPCData.hardcore
        RXPCData.hardcore = nil
    end

    if RXPCData.northrendLM ~= nil then
        n("northrendLM", RXPCData.northrendLM)
        db.northrendLM = RXPCData.northrendLM
        RXPCData.northrendLM = nil
    end

    if RXPData.arrowSize ~= nil then
        n("arrowSize", RXPData.arrowSize)
        db.arrowScale = RXPData.arrowSize
        RXPData.arrowSize = nil
    end

    if RXPData.arrowText ~= nil then
        n("arrowText", RXPData.arrowText)
        db.arrowText = RXPData.arrowText
        RXPData.arrowText = nil
    end

    if RXPData.windowSize ~= nil then
        n("windowSize", RXPData.windowSize)
        db.windowScale = RXPData.windowSize
        RXPData.windowSize = nil
    end

    if RXPData.numMapPins ~= nil then
        n("numMapPins", RXPData.numMapPins)
        db.numMapPins = RXPData.numMapPins
        RXPData.numMapPins = nil
    end

    if RXPData.worldMapPinScale ~= nil then
        n("worldMapPinScale", RXPData.worldMapPinScale)
        db.worldMapPinScale = RXPData.worldMapPinScale
        RXPData.worldMapPinScale = nil
    end

    if RXPData.distanceBetweenPins ~= nil then
        n("distanceBetweenPins", RXPData.distanceBetweenPins)
        db.distanceBetweenPins = RXPData.distanceBetweenPins
        RXPData.distanceBetweenPins = nil
    end

    if RXPData.worldMapPinBackgroundOpacity ~= nil then
        n("worldMapPinBackgroundOpacity", RXPData.worldMapPinBackgroundOpacity)
        db.worldMapPinBackgroundOpacity = RXPData.worldMapPinBackgroundOpacity
        RXPData.worldMapPinBackgroundOpacity = nil
    end

    if RXPData.anchorOrientation ~= nil then
        n("anchorOrientation", RXPData.anchorOrientation)
        db.anchorOrientation = RXPData.anchorOrientation == 1 and "top" or
                                   "bottom"
        RXPData.anchorOrientation = nil
    end

    if RXPCData.xprate ~= nil then
        n("xprate", RXPCData.xprate)
        db.xprate = RXPCData.xprate
        RXPCData.xprate = nil
    end

    -- As of 11.1.5 TargetUnit now fires ADDON_ACTION_FORBIDDEN at execution, rather than target matches
    -- Also applies to > 1.15.8
    -- Force disable setting, rather than gameVersion everywhere
    if db.showTargetingOnProximity and not unitscanEnabled and
        addon.gameVersion ~= 30300 then
        db.showTargetingOnProximity = false
    end

    if db.showDangerousUnitscan and not unitscanEnabled and
        addon.gameVersion ~= 30300 then
        db.showDangerousUnitscan = false
    end
end

-- Pre 4.5.10 , settings were in RXPCSettings per character
-- Leave RXPCSettings alone for downgrade options
function addon.settings:MigrateProfile()
    -- Fresh install
    if not _G.RXPCSettings or not _G.RXPCSettings.profiles then return end

    local p = _G.RXPSettings.profiles

    -- Lazy copy all character profiles to account
    for profileKey, _ in pairs(_G.RXPCSettings.profileKeys or {}) do
        -- Already migrated a character with current profile name
        if p[profileKey] and p[profileKey].migrated then
            addon.comms.PrettyDebug(
                "Character profile (%s) already migrated", profileKey)
        else
            p[profileKey] = _G.RXPCSettings.profiles[profileKey]
            p[profileKey].migrated = true
        end
    end
end

local function GetProfileOption(info) return addon.settings.profile[info[#info]] end

local SPEEDRUN_SETTINGS_OWNER = "settings-speedrun"

function addon.settings:ApplySpeedrunSettings()
    local function ApplyNow()
        if not (addon.speedrun and addon.speedrun.ApplySuiteSettings) then
            return
        end
        local ok, errorText = pcall(addon.speedrun.ApplySuiteSettings,
                                    addon.speedrun)
        if not ok and _G.geterrorhandler then
            _G.geterrorhandler()(errorText)
        end
    end

    -- Apply once immediately for responsive toggles, then reconcile after
    -- AceConfig has completed its OnValueChanged refresh. Some legacy/private-
    -- server AceGUI revisions rebuild the option tree inside that callback and
    -- otherwise leave feature lifecycle changes deferred until the next login.
    ApplyNow()
    local function DeferredApply()
        ApplyNow()
        if AceConfigRegistry and AceConfigRegistry.NotifyChange then
            pcall(AceConfigRegistry.NotifyChange, AceConfigRegistry, addon.title)
        end
    end
    if addon.scheduler and addon.scheduler.After then
        addon.scheduler:After(SPEEDRUN_SETTINGS_OWNER, "apply", 0.05,
                              DeferredApply)
    else
        RunOnNextFrame(DeferredApply)
    end
end

local targetingRefreshOptions = {
    enableFriendlyTargeting = true,
    enableTargetMarking = true,
    enableEnemyTargeting = true,
    enableEnemyMarking = true,
    enableMobMarking = true,
    scanForRares = true
}

local function SetProfileOption(info, value)
    local key = info[#info]
    addon.settings.profile[key] = value
    if addon.gameVersion == 30300 and targetingRefreshOptions[key] and
        addon.targeting and addon.targeting.RefreshLegacyTargets then
        addon.targeting:RefreshLegacyTargets()
    end
    if type(key) == "string" and key:match("^enableSpeedrun") then
        addon.settings:ApplySpeedrunSettings()
    end
end

local function CaptureProfileOptions(profile, keys)
    local snapshot = {}
    for _, key in ipairs(keys) do
        local value = profile[key]
        -- The preset-controlled options are booleans or numeric values. Store
        -- an absent boolean as false so it survives SavedVariables serialization.
        if value == nil then value = false end
        snapshot[key] = value
    end
    return snapshot
end

local function RestoreProfileOptions(profile, snapshot)
    if type(snapshot) ~= "table" then return end
    for key, value in pairs(snapshot) do profile[key] = value end
end

function addon.settings.ProcessImportBox()
    if not importCache.workerFrame:IsShown() then
        importCache.workerFrame:Show()
    end

    if not addon.settings.profile.showEnabled then addon.settings.ToggleActive() end

    local guidesLoaded, errorMsg = addon.ImportString(importCache.bufferString,
                                                      importCache.workerFrame)
    if guidesLoaded and not errorMsg then
        if addon.settings.gui then
            addon.settings.gui.selectedDeleteGuide = ""
        end
        return true
    else
        local relog = ""
        if not RXPData.cache then
            relog = "\n" .. L("Please restart your game client and try again")
        end

        return false, errorMsg or
                   (L("Failed to Import Guides: Invalid Import String") .. relog)
    end
end

function addon.settings.GetImportedGuides()
    local display = {[""] = ""}
    local importedGuidesFound = false

    for _, guide in pairs(addon.guides) do
        if (guide.imported or guide.cache) and (guide.group ~= "RXPGuides" or addon.settings.profile.debug) then
            importedGuidesFound = true
            local group, subgroup, name = guide.key:match("^(.*)|(.*)|(.*)")
            if subgroup ~= "" then group = group .. "/" .. subgroup end
            display[guide.key] = string.format("%s/%s - version %s", group,
                                               name, guide.version)
        end
    end

    table.sort(display)

    if importedGuidesFound then
        return display
    else
        addon.settings.gui.selectedDeleteGuide = "none"
        return {none = "none"}
    end

end

function addon.settings:UpdateImportStatusHistory(data, ...)
    if type(data) == "table" then
        self.gui.importStatusHistory = data
    elseif type(data) == "string" then
        tinsert(self.gui.importStatusHistory, 1, fmt(data, ...))
    end

    AceConfigRegistry:NotifyChange(addon.title .. "/Import")
end

--importCache.widget.obj.button:GetScript("OnClick")
function importCache.validate(self)
    local status, errorMsg = addon.settings.ProcessImportBox(self)
    importCache.bufferString = ""
    importCache.bufferData = {}
    -- Gets disabled on paste, re-enable after processing completes
    importCache.widget.obj.editBox:Enable()
    if errorMsg then
        addon.settings:UpdateImportStatusHistory(errorMsg)
        return errorMsg
    end
    return status
end

--/run StaticPopup_Show("RXP_Import")
function addon.settings.ImportSplicedString()
    return StaticPopup_Show("RXP_Import")
end
local strbuffer = {}
_G.StaticPopupDialogs["RXP_Import"] = {
    text = "",
    hasEditBox = 1,
    button1 = _G.OKAY,
    OnShow = function(self)
        local text = getglobal(self:GetName() .. "Text")
        local n = #strbuffer
        text:SetText(fmt("Press Ctrl+V to paste a piece of the string (%d)\nPress ESC to cancel\n\nThis process is slow and should only be used if your operating system have clipboard length restrictions",n))
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
        importCache.bufferString = ""
        strbuffer = {}
        importCache.bufferData = {}
        addon.settings.OpenSettings('Import')
    end,
    OnAccept = function(self,...)
        local text = getglobal(self:GetName() .. "EditBox"):GetText()
        --text = text:gsub("||","|")
        local n = #strbuffer
        local header = text:find("^%d+[|]+%d+:")
        if n > 0 or header then
            table.insert(strbuffer,text)
        else
            addon.comms.PrettyPrint('Import Error - Invalid String Header')
            addon.settings.OpenSettings('Import')
            return
        end
        if text:find("%%[|]+%d+$") then
            addon.settings.OpenSettings('Import')
            --[[
            local status, errorMsg = addon.settings.ProcessImportBox()
            print(status, errorMsg, importCache.bufferString:len())
            ]]
            RunOnNextFrame(function()
                importCache.bufferData = strbuffer
                ProcessBuffer(importCache.widget.obj.editBox)
                local button = importCache.widget.obj.button
                button:Enable()
                importCache.widget.obj.editBox:SetText(importCache.bufferString:sub(1, 500))
                button:GetScript("OnClick")(button)
                strbuffer = {}
                importCache.bufferData = {}
                importCache.bufferString = ""
            end)
        else
            RunOnNextFrame(function() StaticPopup_Show("RXP_Import") end)
        end
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1
}


function addon.settings:CreateImportOptionsPanel()
    local function notOnline()
        if not RXPData.cache and GetTime() - importCache.lastBNetQuery > 5 then
            addon.comms.PrettyDebug("Battle.net not cached, querying")
            importCache.lastBNetQuery = GetTime()
            _, RXPData.cache = _G[addon.DeserializeTable(addon.base)]()
        end

        return not RXPData.cache
    end

    local importOptionsTable = {
        type = "group",
        name = fmt("RestedXP %s - %s", L("Guide Import"), addon.versionText),
        handler = self,
        args = {
            buffer = {
                order = 1,
                name = L("Paste encoded strings"),
                type = "description",
                width = "full",
                fontSize = "medium"
            },
            importBox = {
                order = 10,
                type = 'input',
                name = L('Guides to import'),
                width = "full",
                multiline = 5,
                get = function()
                    -- Prevent auto clearing on NotifyChange
                    return importCache.bufferString:sub(1, 500)
                end,
                validate = importCache.validate,
                disabled = function() return notOnline() end
            },
            currentGuides = {
                order = 11,
                type = 'select',
                style = 'dropdown',
                name = L("Currently loaded imported guides"),
                width = 'full',
                values = function()
                    return self.GetImportedGuides()
                end,
                disabled = function()
                    return next(addon.db.profile.guides) == nil or
                               not self.gui.selectedDeleteGuide
                end,
                get = function()
                    return self.gui.selectedDeleteGuide
                end,
                set = function(_, value)
                    self.gui.selectedDeleteGuide = value
                end
            },
            deleteSelectedGuide = {
                order = 12,
                type = 'execute',
                name = L("Delete imported guide"),
                confirm = function()
                    if next(addon.db.profile.guides) == nil or
                        not self.gui.selectedDeleteGuide then
                        return false
                    end
                    return string.format(L("Remove") .. " %s?",
                                         self.gui.selectedDeleteGuide)
                end,
                disabled = function()
                    return next(addon.db.profile.guides) == nil or
                               not self.gui.selectedDeleteGuide or
                               self.gui.selectedDeleteGuide == "" or
                               self.gui.selectedDeleteGuide == "none"
                end,
                func = function()
                    if addon.RemoveGuide(self.gui.selectedDeleteGuide) then
                        addon.db.profile.guides[self.gui.selectedDeleteGuide] =
                            nil
                    end
                end
            },
            purgeAll = {
                order = 13,
                type = 'execute',
                name = L("Purge All Data"),
                confirm = function()
                    return L(
                               "This action will remove ALL guides from the database\nAre you sure?")
                end,
                --[[disabled = function()
                    return next(addon.db.profile.guides) == nil
                end,]]
                --Let people purge the data even without any installed guides in case they experience caching issues
                func = function()
                    addon.db.profile.guides = {}
                    addon:CreateMetaDataTable(true)
                end
            },
            reloadUi = {
                order = 14,
                name = L("Reload guides and UI"),
                type = 'execute',
                func = function() _G.ReloadUI() end
            },
            ImportSplicedString = {
                order = 15,
                name = L("Import Spliced String"),
                type = 'execute',
                func = function()
                    RunOnNextFrame(function()
                        if _G.SettingsPanel then
                            _G.SettingsPanel:Hide()
                        elseif _G.InterfaceOptionsFrame then
                            _G.InterfaceOptionsFrame:Hide()
                        end
                        AceConfigDialog:CloseAll()
                        addon.settings.ImportSplicedString()
                    end)
                end,
                hidden = not self.profile.enableBetaFeatures,
            },

            loadStatusBox = {
                order = 90,
                name = _G.HISTORY,
                type = 'group',
                inline = true,
                hidden = function()
                    return next(self.gui.importStatusHistory) == nil
                end,
                args = {
                    loadHistory = {
                        order = 1,
                        name = function()
                            return table.concat(self.gui.importStatusHistory,
                                                '\n')
                        end,
                        type = "description",
                        width = "full",
                        fontSize = "medium"
                    }
                }
            },
            debugData = {
                order = 91,
                name = _G.BINDING_HEADER_DEBUG,
                type = "header",
                width = "full",
                hidden = function()
                    return not addon.settings.profile.debug
                end
            },
            battleNetID = {
                order = 91.1,
                name = function()
                    local _, bt = BNGetInfo()
                    return fmt("Battle.net ID: %s", bt or 'Offline')
                end,
                type = "description",
                width = "full",
                fontSize = "small",
                hidden = function()
                    return not addon.settings.profile.debug
                end
            }
        }
    }

    AceConfig:RegisterOptionsTable(addon.RXPOptions.name .. "/Import",
                                   importOptionsTable)

    self.gui.import = self.RegisterOptionsPanel(
                          "Import", self.AddToBlizzardOptions(
                              addon.RXPOptions.name .. "/Import", L("Import"),
                              addon.RXPOptions.name))

    -- Ace3 ConfigDialog doesn't support embedding icons in header
    -- Directly references Ace3 built frame object

    local iconFrameParent = self.gui.import.obj.frame
    iconFrameParent.icon = iconFrameParent:CreateTexture()
    -- Theme load order, leave default settings branding unthemed
    iconFrameParent.icon:SetTexture("Interface/AddOns/" .. addonName ..
                                        "/Textures/rxp_logo-64")
    iconFrameParent.icon:SetPoint("TOPRIGHT", -5, -5)

    if notOnline() then
        self:UpdateImportStatusHistory(L(
                                           "Battle.net unreachable, please exit your client, restart Battle.net, and try again"))
    end

    local function EditBoxHook(this)
        if this:IsShown() then
            -- Prevent double paste input lag
            this:SetText("")
            this.isMaxBytesSet = true
            this:SetMaxBytes(1)
        elseif this.isMaxBytesSet then
            this.isMaxBytesSet = false
            this:SetMaxBytes(0)
        end
    end

    function ProcessBuffer(this)
        importCache.bufferString = table.concat(importCache.bufferData)
        if #importCache.bufferString > 500 then
            addon.settings:UpdateImportStatusHistory(L(
                                                         "Loaded %d characters into import buffer, %d shown"),
                                                     #importCache.bufferString,
                                                     500)
        else
            addon.settings:UpdateImportStatusHistory(L(
                                                         "Loaded %d characters into import buffer"),
                                                     #importCache.bufferString)
        end
        if this then
            this:SetMaxBytes(0)
            this:SetScript('OnUpdate', nil)
            this:ClearFocus()
        end
        importCache.bufferData = {}
    end

    local function PasteHook(this, char)
        local time = GetTime()
        if this:IsEnabled() then
            -- Disable input while processing paste
            this:Disable()
        end
        if importCache.lastBuffer ~= time then
            importCache.lastBuffer = time
            this:SetScript('OnUpdate', ProcessBuffer)
        end

        tinsert(importCache.bufferData, char)
    end

    local function textboxHook()
        -- Prevent hooking multiple times on show
        if importCache.widget then return end

        local n = 1
        local inputWidget = true

        while inputWidget do
            inputWidget = _G["MultiLineEditBox" .. n .. "ScrollFrame"]

            if inputWidget and inputWidget.obj.label:GetText() ==
                L('Guides to import') then
                importCache.widget = inputWidget
                inputWidget.obj.button:SetText(L("Import")) -- TODO locale
                local editBox = inputWidget.obj.editBox

                editBox:HookScript("OnEditFocusGained", EditBoxHook)
                editBox:HookScript("OnChar", PasteHook)
                -- Prevent Accept button from being disabled by programatic text update
                editBox:SetScript("OnTextSet", nil)
                break
            end
            n = n + 1
        end
    end

    self.textboxHook = textboxHook

    -- Hook embedded settings
    self.gui.import.obj.frame:HookScript("OnShow", textboxHook)
end

function addon.settings:CreateAceOptionsPanel()
    local function isNotAdvanced() return not self.profile.enableBetaFeatures end

    local function requiresReload()
        return L("This requires a reload to take effect, continue?")
    end

    local function showStepList(value)
        if addon.currentGuide and addon.currentGuide.hidewindow then
            return
        end

        if value then
            addon.RXPFrame:SetHeight(addon.height)
            addon.settings.profile.frameHeight = addon.height
        else
            addon.RXPFrame:SetHeight(10)
            addon.settings.profile.frameHeight = 10
        end
        addon.updateBottomFrame = true
    end

    local function listBetaFeatures(first)
        if next(addon.settings.enabledBetaFeatures) == nil then
            return first
        end

        local features = fmt('%s\n\n%s:', first , _G.FEATURES_LABEL)

        for feature, desc in pairs(addon.settings.enabledBetaFeatures) do
            features = fmt('%s\n%s\n - %s', features, feature, desc)
        end

        return features
    end

    local optionsWidth = 1.08
    local settingsCache = {invertedOrphans = {}}

    local function ToolAppearancePage(label, frameName, openFunction,
                                      unavailable)
        local function GetAppearance(key)
            if addon.toolWindows and addon.toolWindows.GetAppearanceValue then
                return addon.toolWindows:GetAppearanceValue(frameName, key)
            end
            if key == "fontSize" then
                return math.max(10, tonumber(self.profile.guideFontSize) or 9)
            end
            return 1
        end
        local function SetAppearance(key, value)
            if addon.toolWindows and addon.toolWindows.SetAppearanceValue then
                addon.toolWindows:SetAppearanceValue(frameName, key, value)
            end
        end
        return {
            type = "group",
            name = label,
            args = {
                open = {
                    name = L("Open Tool"),
                    desc = fmt(L("Open the %s window."), label),
                    type = "execute",
                    width = optionsWidth,
                    order = 1,
                    disabled = unavailable,
                    func = openFunction,
                },
                appearanceHeader = {
                    name = L("Window Appearance"),
                    type = "header",
                    width = "full",
                    order = 10,
                },
                fontSize = {
                    name = L("Window Font Size"),
                    desc = L("Changes the text size for this tool without changing the main guide window."),
                    type = "range",
                    width = optionsWidth,
                    order = 11,
                    min = 6,
                    max = 22,
                    step = 1,
                    get = function() return GetAppearance("fontSize") end,
                    set = function(_, value)
                        SetAppearance("fontSize", math.floor(value + 0.5))
                    end,
                },
                opacity = {
                    name = L("Window Opacity"),
                    desc = L("Changes the opacity of this tool window and its contents."),
                    type = "range",
                    width = optionsWidth,
                    order = 12,
                    min = 0.05,
                    max = 1,
                    step = 0.05,
                    isPercent = true,
                    get = function() return GetAppearance("opacity") end,
                    set = function(_, value) SetAppearance("opacity", value) end,
                },
                backgroundOpacity = {
                    name = L("Window Background Opacity"),
                    desc = L("Changes only the background transparency while keeping text and controls fully visible."),
                    type = "range",
                    width = optionsWidth,
                    order = 13,
                    min = 0,
                    max = 1,
                    step = 0.05,
                    isPercent = true,
                    get = function()
                        return GetAppearance("backgroundOpacity")
                    end,
                    set = function(_, value)
                        SetAppearance("backgroundOpacity", value)
                    end,
                },
                scale = {
                    name = L("Window Scale"),
                    desc = L("Scales this tool independently from the main guide window."),
                    type = "range",
                    width = optionsWidth,
                    order = 14,
                    min = 0.50,
                    max = 2,
                    step = 0.05,
                    isPercent = true,
                    get = function() return GetAppearance("scale") end,
                    set = function(_, value) SetAppearance("scale", value) end,
                },
                reset = {
                    name = L("Reset This Tool Window"),
                    desc = L("Restores this tool's default font, opacity, scale, size, and position."),
                    type = "execute",
                    width = optionsWidth,
                    order = 20,
                    func = function()
                        if addon.toolWindows and addon.toolWindows.ResetWindow then
                            addon.toolWindows:ResetWindow(frameName)
                        end
                        if AceConfigRegistry and AceConfigRegistry.NotifyChange then
                            AceConfigRegistry:NotifyChange(addon.title)
                        end
                    end,
                },
            },
        }
    end

    local preflightToolPage = ToolAppearancePage(
        L("Route Preflight"), "RXPRoutePreflightWindow", function()
            if addon.routePreflight then addon.routePreflight:Toggle() end
        end, function() return not addon.routePreflight end)
    preflightToolPage.order = 1
    local archiveToolPage = ToolAppearancePage(
        L("Personal-Best Archives"), "RXPLevelingArchives", function()
            if addon.runArchive then addon.runArchive:Toggle() end
        end, function() return not addon.runArchive end)
    archiveToolPage.order = 2
    local petToolPage = ToolAppearancePage(
        L("Hunter Pet Assistant"), "RXPHunterPetAssistant", function()
            if addon.petAssistant then addon.petAssistant:Toggle() end
        end, function()
            return not addon.petAssistant or not addon.player or
                       addon.player.class ~= "HUNTER"
        end)
    petToolPage.order = 3
    local performanceToolPage = ToolAppearancePage(
        L("Performance Inspector"), "RXPPerformanceInspector", function()
            if addon.performanceInspector then
                addon.performanceInspector:Toggle()
            end
        end, function() return not addon.performanceInspector end)
    performanceToolPage.order = 4
    local xpToolPage = ToolAppearancePage(
        L("XP & Yellow-Mob Estimator"), "RXPXPProgressWindow", function()
            if addon.xpAssistant then addon.xpAssistant:Toggle() end
        end, function()
            return not addon.xpAssistant or
                       self.profile.enableMobXPEstimator == false
        end)
    xpToolPage.order = 5
    xpToolPage.args.displayHeader = {
        name = L("Displayed Information"), type = "header", width = "full",
        order = 2,
    }
    local xpDisplaySettings = {
        {"xpEstimatorShowStockXP", "Show Stock XP",
         "Shows the canonical WotLK XP awarded by each mob level."},
        {"xpEstimatorShowKills", "Show Stock Kills",
         "Shows how many kills remain at the current XP progress."},
        {"xpEstimatorShowAdaptive", "Show Adaptive XP",
         "Shows estimates learned from verified kills on this server."},
        {"xpEstimatorShowAdaptiveKills", "Show Adaptive Kills",
         "Shows kill counts calculated from the adaptive XP learned on this server."},
        {"xpEstimatorShowRested", "Show Rested Projections",
         "Shows normal / rested values using the finite rested-XP pool."},
    }
    local function AddXPDisplaySetting(definition, index)
        local key, name, description = definition[1], definition[2], definition[3]
        xpToolPage.args[key] = {
            name = L(name),
            desc = L(description),
            type = "toggle",
            width = optionsWidth,
            order = 2 + index / 10,
            get = function() return self.profile[key] ~= false end,
            set = function(_, value)
                if addon.xpAssistant and addon.xpAssistant.SetDisplayOption then
                    addon.xpAssistant:SetDisplayOption(key, value)
                else
                    self.profile[key] = value == true
                end
            end,
        }
    end
    for index, definition in ipairs(xpDisplaySettings) do
        -- Give each Lua 5.1 closure its own key.  Capturing the loop local
        -- directly is implementation-sensitive on older embedded runtimes.
        AddXPDisplaySetting(definition, index)
    end

    local function ApplySpeedrunSettings()
        addon.settings:ApplySpeedrunSettings()
    end

    local function SpeedrunToolPage(label, frameName, setting, service, order)
        local page = ToolAppearancePage(label, frameName, function()
            if service and service.Toggle then service:Toggle() end
        end, function()
            return not service or self.profile.enableSpeedrunSuite == false or
                       self.profile[setting] ~= true
        end)
        page.order = order
        page.args.enable = {
            name = fmt(L("Enable %s"), label),
            desc = L("Applies immediately. Disabling preserves settings and history while cancelling this tool's owned work."),
            type = "toggle", width = optionsWidth, order = 0.1,
            get = function() return self.profile[setting] == true end,
            set = function(_, value)
                self.profile[setting] = value and true or false
                ApplySpeedrunSettings()
            end,
            disabled = function() return self.profile.enableSpeedrunSuite == false end,
        }
        return page
    end

    local coachToolPage = SpeedrunToolPage(L("Live Speedrun Coach"),
        "RXPSpeedrunCoachWindow", "enableSpeedrunCoach", addon.speedrunCoach, 2)
    coachToolPage.args.clock = {
        name = L("Displayed clock"), type = "select", style = "radio",
        values = {active = L("Active in-game time"), wall = L("Wall-clock time")},
        width = optionsWidth, order = 2.1,
        get = function() return self.profile.speedrunDisplayClock or "active" end,
        set = function(_, value)
            self.profile.speedrunDisplayClock = value == "wall" and "wall" or "active"
            ApplySpeedrunSettings()
        end,
    }
    coachToolPage.args.comparison = {
        name = L("Automatic comparison"), type = "select", style = "radio",
        values = {pb = L("Fastest compatible personal best"),
                  median = L("Recent compatible median"),
                  best = L("Best compatible segments"),
                  manual = L("Selected archive")},
        width = optionsWidth, order = 2.2,
        get = function() return self.profile.speedrunComparison or "pb" end,
        set = function(_, value)
            self.profile.speedrunComparison = value
            ApplySpeedrunSettings()
        end,
    }
    coachToolPage.args.paceThreshold = {
        name = L("Meaningful pace threshold"),
        desc = L("Seconds gained or lost before the Coach and Audio Director surface a pace change."),
        type = "range", min = 1, max = 120, step = 1,
        width = optionsWidth, order = 2.3,
        get = function() return self.profile.speedrunPaceThreshold or 15 end,
        set = function(_, value)
            self.profile.speedrunPaceThreshold = math.floor(value + 0.5)
        end,
    }

    local grindToolPage = SpeedrunToolPage(L("Dynamic Grind Optimizer"),
        "RXPSpeedrunGrindWindow", "enableSpeedrunGrind", addon.speedrunGrind, 3)
    grindToolPage.args.lookahead = {
        name = L("Guide steps considered"), type = "range", min = 1, max = 100,
        step = 1, width = optionsWidth, order = 2.1,
        get = function() return self.profile.speedrunGrindLookahead or 20 end,
        set = function(_, value)
            self.profile.speedrunGrindLookahead = math.floor(value + 0.5)
            if addon.speedrunGrind then addon.speedrunGrind:ScheduleRefresh() end
        end,
    }
    local pitToolPage = SpeedrunToolPage(L("Pit Stop Planner"),
        "RXPSpeedrunPitStopWindow", "enableSpeedrunPitStop", addon.speedrunPitStop, 4)
    pitToolPage.args.lookahead = {
        name = L("Guide steps considered"), type = "range", min = 1, max = 100,
        step = 1, width = optionsWidth, order = 2.1,
        get = function() return self.profile.speedrunPitStopLookahead or 20 end,
        set = function(_, value)
            self.profile.speedrunPitStopLookahead = math.floor(value + 0.5)
            if addon.speedrunPitStop then addon.speedrunPitStop:ScheduleRefresh() end
        end,
    }
    local routeToolPage = SpeedrunToolPage(L("Adaptive Route Strategist"),
        "RXPSpeedrunRouteWindow", "enableSpeedrunRoute", addon.speedrunRoute, 5)
    local deathwarpToolPage = SpeedrunToolPage(L("Deathwarp Decision Assistant"),
        "RXPSpeedrunDeathwarpWindow", "enableSpeedrunDeathwarp", addon.speedrunDeathwarp, 6)
    local practiceToolPage = SpeedrunToolPage(L("Segment Practice Lab"),
        "RXPSpeedrunPracticeWindow", "enableSpeedrunPractice", addon.speedrunPractice, 7)
    local audioToolPage = SpeedrunToolPage(L("Speedrun Audio Director"),
        "RXPSpeedrunAudioWindow", "enableSpeedrunAudio", addon.speedrunAudio, 8)
    audioToolPage.args.muteCombat = {
        name = L("Mute ordinary cues in combat"), type = "toggle",
        width = optionsWidth, order = 2.1,
        get = function() return self.profile.speedrunAudioMuteCombat ~= false end,
        set = function(_, value) self.profile.speedrunAudioMuteCombat = value == true end,
    }
    audioToolPage.args.leadSteps = {
        name = L("Audio lead steps"), type = "range", min = 0, max = 10,
        step = 1, width = optionsWidth, order = 2.2,
        get = function() return self.profile.speedrunAudioLeadSteps or 1 end,
        set = function(_, value) self.profile.speedrunAudioLeadSteps = math.floor(value + 0.5) end,
    }
    audioToolPage.args.categoryHeader = {
        name = L("Cue Categories"), type = "header", width = "full", order = 3,
    }
    local audioCategories = {"quest", "turnin", "loot", "travel", "hearth",
        "vendor", "trainer", "danger", "deathskip", "grind", "inventory", "pace"}
    local function AddAudioCategory(category, index)
        audioToolPage.args["category_" .. category] = {
            name = L(category:gsub("^%l", string.upper)), type = "toggle",
            width = optionsWidth, order = 3 + index / 20,
            get = function()
                local values = self.profile.speedrunAudioCategories
                return type(values) ~= "table" or values[category] ~= false
            end,
            set = function(_, value)
                self.profile.speedrunAudioCategories =
                    type(self.profile.speedrunAudioCategories) == "table" and
                        self.profile.speedrunAudioCategories or {}
                self.profile.speedrunAudioCategories[category] = value == true
                if addon.speedrunAudio then addon.speedrunAudio:Refresh() end
            end,
        }
    end
    for index, category in ipairs(audioCategories) do AddAudioCategory(category, index) end
    local rulesToolPage = SpeedrunToolPage(L("Run Ruleset and Integrity"),
        "RXPSpeedrunRulesWindow", "enableSpeedrunRules", addon.speedrunRules, 9)
    rulesToolPage.args.ruleset = {
        name = L("Run ruleset"), type = "select", style = "radio",
        values = { ["solo-any"] = L("Solo Any%"),
                   ["solo-deathless"] = L("Solo Deathless"),
                   custom = L("Custom")},
        width = optionsWidth, order = 2.1,
        get = function() return self.profile.speedrunRuleset or "solo-any" end,
        set = function(_, value)
            self.profile.speedrunRuleset = value
            ApplySpeedrunSettings()
        end,
    }
    rulesToolPage.args.customHeader = {
        name = L("Custom Rules"), type = "header", width = "full", order = 3,
    }
    local customRules = {
        {"allowDeaths", L("Allow deaths")},
        {"allowGrouping", L("Allow grouping")},
        {"allowRestedXP", L("Allow rested XP")},
        {"allowHeirlooms", L("Allow heirlooms")},
        {"allowXPRateChanges", L("Allow XP-rate changes")},
        {"allowGuideChanges", L("Allow guide changes")},
        {"allowManualSkips", L("Allow manual skips")},
    }
    local function AddCustomRule(spec, index)
        local key, label = spec[1], spec[2]
        rulesToolPage.args["custom_" .. key] = {
            name = label, type = "toggle", width = optionsWidth,
            order = 3 + index / 10,
            disabled = function() return self.profile.speedrunRuleset ~= "custom" end,
            get = function()
                local values = self.profile.speedrunCustomRules
                return type(values) == "table" and values[key] == true
            end,
            set = function(_, value)
                self.profile.speedrunCustomRules =
                    type(self.profile.speedrunCustomRules) == "table" and
                        self.profile.speedrunCustomRules or {}
                self.profile.speedrunCustomRules[key] = value == true
                ApplySpeedrunSettings()
            end,
        }
    end
    for index, spec in ipairs(customRules) do AddCustomRule(spec, index) end

    local speedrunningToolPage = {
        type = "group", name = L("Speedrunning"), order = 6,
        childGroups = "tree", args = {
            overview = {type = "group", name = L("Overview"), order = 1, args = {
                enableSpeedrunSuite = {
                    name = L("Enable Speedrunning Suite"),
                    desc = L("Master runtime pause. Individual choices and history are preserved."),
                    type = "toggle", width = optionsWidth, order = 1,
                    get = function() return self.profile.enableSpeedrunSuite ~= false end,
                    set = function(_, value)
                        self.profile.enableSpeedrunSuite = value and true or false
                        ApplySpeedrunSettings()
                    end,
                },
                explanation = {
                    name = L("The coach is lightweight and enabled by default. Advisors, practice, audio, and integrity tracking remain opt-in and never automate protected gameplay actions."),
                    type = "description", width = "full", order = 2,
                },
            }},
            coach = coachToolPage, grind = grindToolPage,
            pitstop = pitToolPage, route = routeToolPage,
            deathwarp = deathwarpToolPage, practice = practiceToolPage,
            audio = audioToolPage, rules = rulesToolPage,
        },
    }

    local optionsTable = {
        type = "group",
        name = fmt("%s - %s", addon.title, addon.versionText),
        get = GetProfileOption,
        set = SetProfileOption,
        childGroups = "tab",
        args = {
            discordButton = {
                order = 1.0,
                name = L("Join Discord"), -- TODO locale
                type = "execute",
                width = "normal",
                func = function()
                    addon.url = "https://discord.gg/restedxp"
                    _G.StaticPopup_Show("RXP_Link")
                    addon.url = nil
                end
            },
            feedbackButton = {
                order = 1.1,
                name = L("Open Feedback Form"),
                type = "execute",
                width = "normal",
                func = addon.comms.OpenBugReport
            },
            splashUI = {
                order = 1.1,
                name = L("Run Guide Configurator"),
                type = "execute",
                width = 1.2,
                func = addon.startHardcoreIntroUI,
                hidden = addon.game ~= "CLASSIC"
            },

            generalSettings = {
                type = "group",
                name = _G.GENERAL,
                order = 2,
                args = {
                    showEnabled = {
                        name = L("Show all Enabled Frames"),
                        desc = L("Toggles all addon frames on or off"), -- TODO locale
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.1,
                        set = function(info, value)
                            self.ToggleActive()
                            SetProfileOption(info, value)
                            addon.RXPFrame.GenerateMenuTable()
                        end
                    },
                    lockFrames = {
                        name = L("Lock Frames"),
                        desc = L(
                            "Disable dragging/resizing, use alt+left click on the main window to resize it"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.2
                    },
                    hideInRaid = {
                        name = L("Autohide in Raids"), -- TODO locale
                        desc = L(
                            "Automatically hide when in a raid, and unhide when you leave a raid"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.3,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if value then
                                addon:RegisterHideInRaidEvents()

                                -- Check if reloading in raid
                                addon.UpdateRaidVisibility()
                            else
                                addon:UnregisterHideInRaidEvents()
                                addon:GROUP_LEFT(nil, true)
                            end
                        end
                    },
                    featuresHeader = {
                        name = _G.FEATURES_LABEL,
                        type = "header",
                        width = "full",
                        order = 2.0
                    },
                    enableMinimapButton = {
                        name = L("Enable Minimap Button"),
                        desc = L("Add main options menu to minimap"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            self:UpdateMinimapButton()
                        end
                    },
                    enableWorldMapButton = {
                        name = L("Enable World Map Button"),
                        desc = L("Add options menu to map"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.11,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            self:SetupMapButton()
                        end
                    },
                    hideGuideWindow = {
                        name = L("Hide Window"),
                        desc = L("Hides the main window"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.2,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.RXPFrame:SetShown(not value)
                        end
                    },
                    disableArrow = {
                        name = L("Hide waypoint arrow"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.3,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if value then
                                addon.arrowFrame:Hide()
                            else
                                addon.hideArrow = false
                                addon.UpdateMap(true)
                            end
                        end
                    },
                    disableItemWindow = {
                        name = L("Hide Active Item window"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.4,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.UpdateItemFrame()
                        end
                    },
                    enableVendorTreasure = {
                        name = fmt('%s %s', _G.ENABLE, L("Vendor Treasures")),
                        desc = L(
                            "Enable embedded Cpt. Stadics' Vendor Treasures"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.5,
                        hidden = function()
                            return not addon.VendorTreasures
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.VendorTreasures then
                                addon.VendorTreasures:Setup()
                                addon.VendorTreasures.UpdatePins()
                            end
                        end
                    },
                    showFlightTimers = {
                        name = L("Show Flight Timers"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.6,
                        hidden = not addon.FPDB,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if not value then
                                addon.HideTimers()
                            end
                        end
                    },
                    groupMode = {
                        name = fmt("%s %s", _G.ENABLE, _G.COMMUNITIES_SETTINGS_LABEL),
                        desc = L("Enables the group-oriented preset. Turning it off restores the settings that were active before the preset was enabled."),
                        order = 2.7,
                        type = "toggle", -- type = "execute",
                        width = optionsWidth,
                        -- confirm = requiresReload,
                        set = function(_, value)
                            local p = self.profile
                            local keys = {
                                "checkVersions", "alwaysSendBranded",
                                "showUnusedGuides", "shareQuests",
                                "enableLevelUpAnnounceGroup",
                                "enableFlyStepAnnouncements",
                                "enableCollectStepAnnouncements",
                                "enableCompleteStepAnnouncements",
                                "enableQuestAutomation", "autoSellJunk",
                                "autoDiscardItems", "enableGroupQuests",
                                "soloSelfFound"
                            }
                            if value then
                                if type(p.groupModeBackup) ~= "table" then
                                    p.groupModeBackup =
                                        CaptureProfileOptions(p, keys)
                                end
                                p.groupMode = true
                                p.checkVersions = true
                                p.alwaysSendBranded = true
                                p.showUnusedGuides = true
                                p.shareQuests = true
                                p.enableLevelUpAnnounceGroup = true
                                p.enableFlyStepAnnouncements = true
                                p.enableCollectStepAnnouncements = true
                                p.enableCompleteStepAnnouncements = true
                                p.enableQuestAutomation = true
                                p.autoSellJunk = true
                                p.autoDiscardItems = true
                                p.enableGroupQuests = true
                                p.soloSelfFound = false
                            else
                                p.groupMode = false
                                RestoreProfileOptions(p, p.groupModeBackup)
                                p.groupModeBackup = nil
                            end
                            addon.ReloadGuide()
                            addon.RXPFrame.GenerateMenuTable()
                        end,
                        hidden = isNotAdvanced
                    },
                    automationHeader = {
                        name = L("Automation"), -- TODO locale
                        type = "header",
                        width = "full",
                        order = 4.0
                    },
                    enableQuestAutomation = {
                        name = L("Quest auto accept/turn in"),
                        desc = L(
                            "Holding the Control key modifier also toggles the quest auto accept feature on and off"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 4.1
                    },
                    enableQuestRewardAutomation = { -- Hard-coded .turnin reward choices
                        name = L("Quest auto rewards"), -- TODO locale
                        desc = L(
                            "Allows guides to choose quest rewards automatically"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 4.2
                    },
                    enableTrainerAutomation = {
                        name = L("Trainer automation"),
                        desc = L(
                            "Allows the guide to buy useful leveling spells automatically"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 4.4
                    },
                    enableFPAutomation = {
                        name = L("Flight Path automation"),
                        desc = L(
                            "Allows the guide to automatically fly you to your destination"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 4.5
                    },
                    enableBindAutomation = {
                        name = L("Innkeeper Bind automation"), -- TODO locale
                        desc = L(
                            "Allows the guide to automatically set your home at an Innkeeper"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 4.6
                    },
                    enableGossipAutomation = {
                        name = L("Skip Gossip"), -- TODO locale
                        desc = L(
                            "Allows the guide to automatically skip gossip for NPCs"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 4.7
                    },
                    inventoryHeader = {
                        name = _G.INVENTORY_TOOLTIP,
                        type = "header",
                        width = "full",
                        order = 4.8,
                        hidden = not (addon.inventoryManager and addon.inventoryManager.bagHook),
                    },
                    showJunkIcon = {
                        name = L("Show junk item indicator"), -- TODO locale
                        desc = L("Any items marked as junk will display a gold coin icon on the top left corner of the item icon within your bags"),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 4.81,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.inventoryManager and
                                addon.inventoryManager.RefreshJunkIcons then
                                addon.inventoryManager.RefreshJunkIcons(0)
                            end
                        end,
                        hidden = not (addon.inventoryManager and addon.inventoryManager.bagHook),
                    },
                    autoDiscardItems = {
                        name = L("Discard junk items if bag is full"), -- TODO locale
                        desc = L("Automatically attempts to discard the cheapest junk item from your bags if your inventory is full"),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 4.83,
                        hidden = not (addon.inventoryManager and addon.inventoryManager.bagHook),
                    },
                    rightClickJunk = {
                        name = L("Toggle junk with modified right click"), -- TODO locale
                        desc = L("Allows you to toggle items as junk by clicking on it with CTRL+RightClick or ALT+RightClick"),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 4.84,
                        hidden = not (addon.inventoryManager and addon.inventoryManager.bagHook),
                    },
                    rightClickMod = {
                        name = L("Right Click Modifier"), -- TODO locale
                        type = "select",
                        width = optionsWidth*0.6,
                        order = 4.85,
                        get = function()
                            return
                                self.profile.rightClickMod or 1
                        end,
                        disabled = function ()
                            return not self.profile.rightClickJunk
                        end,
                        values = {
                            [1] = "CTRL",
                            [2] = "ALT",
                            [3] = "CTRL+ALT",
                        },
                        hidden = not (addon.inventoryManager and addon.inventoryManager.bagHook),
                    },
                    autoSellJunk = {
                        name = L("Auto Sell Junk"), -- TODO locale
                        desc = L("Automatically sell all gray items and all other items that you set as junk"),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 4.86,
                        hidden = not (addon.inventoryManager and addon.inventoryManager.bagHook),
                    },
                    maxSoulShards = {
                        name = L("Soul Shard Maximum"),
                        desc = L("Automatically mark surplus Soul Shards in ordinary bags as junk"),
                        type = "input",
                        width = optionsWidth * 0.8,
                        order = 4.865,
                        get = function()
                            return tostring(self.profile.maxSoulShards or 100)
                        end,
                        set = function(_, value)
                            local cap = math.max(0, math.floor(tonumber(value) or 100))
                            self.profile.maxSoulShards = cap
                            addon.inventoryManager.RefreshJunkIcons(0)
                        end,
                        pattern = "^%d+$",
                        usage = L("You must input a non-negative integer"),
                        hidden = function()
                            return not (addon.inventoryManager and
                                addon.inventoryManager.bagHook and
                                addon.player.class == "WARLOCK" and
                                addon.gameVersion == 30300)
                        end
                    },
                    enableMouseoverCorpseLoot = {
                        name = L("Enable Mouseover Corpse Loot"),
                        desc = L("While hovering a dead non-player creature, press the assigned key to interact and auto-loot it. WoW requires a key press; hovering alone cannot perform this protected action. Enabling this also enables the client's standard Auto Loot setting."),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 4.866,
                        hidden = addon.gameVersion ~= 30300,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if value and _G.GetCVar and _G.SetCVar and
                                tostring(_G.GetCVar("autoLootDefault")) ~= "1" then
                                pcall(_G.SetCVar, "autoLootDefault", 1)
                            end
                            if addon.inventoryManager and
                                addon.inventoryManager.RefreshMouseoverCorpseLootBinding then
                                addon.inventoryManager.RefreshMouseoverCorpseLootBinding()
                            end
                        end
                    },
                    mouseoverCorpseLootKeybind = {
                        name = L("Mouseover Corpse Loot Keybind"),
                        desc = L("Bind a key or mouse-wheel action, hover a lootable corpse, and press it. Avoid using the client's Auto Loot modifier key for this binding."),
                        type = "keybinding",
                        width = optionsWidth * 1.25,
                        order = 4.867,
                        hidden = addon.gameVersion ~= 30300,
                        disabled = function()
                            return not self.profile.enableMouseoverCorpseLoot
                        end,
                        get = function()
                            return self.profile.mouseoverCorpseLootKey
                        end,
                        set = function(_, key)
                            self.profile.mouseoverCorpseLootKey =
                                key and key ~= "" and key or nil
                            if addon.inventoryManager and
                                addon.inventoryManager.RefreshMouseoverCorpseLootBinding then
                                addon.inventoryManager.RefreshMouseoverCorpseLootBinding()
                            end
                        end
                    },
                    sellKeybind = {
                        name = L("Delete Cheapest Junk Item Keybind"), -- TODO locale
                        desc = L("Click to set a keybind"),
                        type = "keybinding",
                        width = optionsWidth * 1.25,
                        order = 4.87,
                        hidden = not (addon.inventoryManager and addon.inventoryManager.bagHook),
                        get = function()
                            local commandName = "CLICK RXPInventory_DeleteJunk:LeftButton"
                            local i = addon.inventoryManager.bindingIndex
                            local c,_,key = GetBinding(i or 1)
                            if c == commandName then
                                return key
                            else
                                for index = 1, GetNumBindings() do
                                    local command,_,key1 = GetBinding(index)
                                    if command == commandName then
                                        addon.inventoryManager.bindingIndex = index
                                        return key1
                                    end
                                end
                            end
                        end,
                        set = function(info, key)
                            local c = "CLICK RXPInventory_DeleteJunk:LeftButton"
                            for index = 1, GetNumBindings() do
                                local command, _, key1, key2 = GetBinding(index)
                                if command == c then
                                    if key1 then SetBinding(key1) end
                                    if key2 then SetBinding(key2) end
                                end
                            end
                            if key and key ~= "" then SetBinding(key, c) end
                            addon.inventoryManager.bindingIndex = nil
                            if _G.SaveBindings and _G.GetCurrentBindingSet then
                                _G.SaveBindings(_G.GetCurrentBindingSet())
                            end
                        end
                    },
                    resetJunk = {
                        name = L("Reset Junk List"),
                        desc = L("Unmark every manually assigned junk or useful item for this character"),
                        order = 4.88,
                        type = "execute",
                        width = optionsWidth,
                        func = function()
                            addon.inventoryManager.ResetJunk()
                        end,
                        confirm = function()
                            return L("This action will reset every manual junk assignment. Are you sure?")
                        end,
                        hidden = function()
                            return not (addon.inventoryManager and
                                addon.inventoryManager.bagHook)
                        end
                    },
                    talentsHeader = {
                        name = function()
                            if addon.talents and addon.talents:IsSupported() then
                                return _G.TALENTS
                            else
                                return fmt("%s - %s", _G.TALENTS,
                                           _G.ADDON_NOT_AVAILABLE)
                            end
                        end,
                        type = "header",
                        width = "full",
                        order = 5.0,
                        hidden = addon.gameVersion >= 50000,
                    },
                    enableTalentGuides = {
                        name = L("Enable Talents Guides"), -- TODO locale
                        desc = L("Enable Talents Guides"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 5.2,
                        disabled = function()
                            return not (addon.talents and
                                       addon.talents:IsSupported())
                        end,
                        hidden = addon.gameVersion >= 50000,
                        confirm = requiresReload,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            _G.ReloadUI()
                        end
                    },
                    previewTalents = {
                        name = L("Enable Talent Previews"), -- TODO locale
                        desc = L("Enable Talent Previews"),
                        type = "toggle",
                        width = optionsWidth * 2,
                        order = 5.3,
                        disabled = function()
                            return not (addon.talents and
                                       addon.settings.profile.enableTalentGuides and
                                       addon.talents:IsSupported())
                        end,
                        hidden = addon.gameVersion < 30000 or addon.gameVersion >= 50000
                    },
                    hightlightTalentPlan = {
                        name = L("Enable Talent Plan"), -- TODO locale
                        desc = L("Highlight or list levels for each talent"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 5.5,
                        disabled = function()
                            return not (addon.talents and
                                       addon.settings.profile.enableTalentGuides and
                                       addon.talents:IsSupported())
                        end,
                        hidden = addon.gameVersion >= 50000
                    },
                    upcomingTalentCount = {
                        name = L("Talent Plan Number"), -- TODO locale
                        desc = L("Sets maximum number of talents to layout"),
                        type = "range",
                        width = optionsWidth,
                        order = 5.6,
                        min = 1,
                        max = addon.talents and addon.talents.maxLevel or 1,
                        step = 1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                        end,
                        disabled = function()
                            return not (addon.talents and
                                       addon.settings.profile.enableTalentGuides and
                                       addon.settings.profile
                                           .hightlightTalentPlan and
                                       addon.talents:IsSupported())
                        end,
                        hidden = addon.gameVersion >= 50000
                    }
                }
            },
            guideRoutingSettings = {
                type = "group",
                name = L("Guide Routing"),
                order = 3,
                args = {
                    experienceHeader = {
                        name = _G.POWER_TYPE_EXPERIENCE,
                        type = "header",
                        width = "full",
                        order = 1.0
                    },
                    enableAutomaticXpRate = {
                        name = function()
                            if addon.game == "CLASSIC" then
                                return L("Detect Season")
                            else
                                return L("Detect Rate")
                            end
                        end,
                        desc = function()
                            if addon.game == "CLASSIC" then
                                return L("Auto detects seasonal buffs and adjust the routes accordingly")
                            else
                                return L("Checks for heirlooms and experience buffs")
                            end
                        end,
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if value and self.profile.enableAutomaticXpRate then
                                self:DetectXPRate(true)
                            end
                            addon.ReloadGuide()
                            addon.RXPFrame.GenerateMenuTable()
                        end
                    },
                    xprate = {
                        name = L("Experience rates"),
                        desc = L(
                            "Adjusts the guide routes to match increased xp rate bonuses"),
                        type = "range",
                        width = optionsWidth,
                        order = 1.2,
                        min = 1,
                        max = addon.game == "RETAIL" and 5 or 2,
                        step = 0.05,
                        isPercent = true,
                        confirm = function()
                            return L(
                                       "Notice: Changing experience rates beyond 1x may cause some chapters to become hidden and certain steps may automatically skip as you out level them") -- TODO locale
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.ReloadGuide()
                            addon.RXPFrame.GenerateMenuTable()
                        end,
                        hidden = addon.game == "CLASSIC",
                        disabled = function()
                            return addon.settings.profile.enableAutomaticXpRate
                        end
                    },
                    enableXpStepSkipping = {
                        name = L("Skip overleveled steps"),
                        desc = L("Skip steps you're overleveled for"),
                        type = "toggle",
                        width = optionsWidth * 2,
                        order = 1.3,
                        confirm = function()
                            return L(
                                       "Warning: Changing this setting mid-guide may cause quest pre-requisite failures.\nGuides were optimized for experience, disabling this option will result in a disjointed guide steps.") -- TODO locale
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if value and self.profile.enableAutomaticXpRate then
                                self:DetectXPRate(true)
                            end
                            addon.ReloadGuide()
                            addon.RXPFrame.GenerateMenuTable()
                        end
                    },
                    enableGroupQuests = {
                        name = L("Show Group Quests"),
                        desc = function()
                            local out = L "Guides that support this feature:\n"
                            for guide in pairs(
                                             RXPCData.guideMetaData
                                                 .enableGroupQuests) do
                                out = fmt("%s\n%s", out, guide)
                            end
                            return out
                        end,
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.4,
                        hidden = function()
                            return not next(
                                       RXPCData.guideMetaData.enableGroupQuests)
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.ReloadGuide()
                            addon.RXPFrame.GenerateMenuTable()
                        end
                    },
                    soloSelfFound = {
                        name = L("Solo Self Found Mode"),
                        desc = L(
                            "If this option is enabled, it disables all steps involving trading or Auction House"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.5,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.ReloadGuide()
                            addon.RXPFrame.GenerateMenuTable()
                        end
                    },
                    expansionHeader = {
                        name = _G.EXPANSION_FILTER_TEXT,
                        type = "header",
                        width = "full",
                        order = 2
                    },
                    northrendLM = {
                        name = L("Northrend Loremaster"),
                        desc = L(
                            "Adjust the routes to include almost every quest in the Northrend zones"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.ReloadGuide()
                        end,
                        hidden = addon.game ~= "WOTLK"
                    },
                    loremasterMode = {
                        name = L("Loremaster Mode"),
                        desc = L(
                            "Adjust the routes to include more quests"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.11,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.ReloadGuide()
                        end,
                        hidden = addon.game ~= "CATA" and addon.game ~= "MOP"
                    },
                    chromieTime = {
                        name = L("Show Chromie Time Guides"),
                        desc = L(
                            "Enables or disables the chromie time guides. Note that freshly created accounts without a level 60 character cannot access chromie time"),
                        type = "select",
                        values = {
                            auto = "Automatic",
                            enabled = "Enabled",
                            disabled = "Disabled"
                        },
                        sorting = {"auto", "enabled", "disabled"},
                        width = optionsWidth,
                        order = 2.2,
                        hidden = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
                    },
                    phase = {
                        name = L("Content phase"),
                        desc = L(
                            "Adjusts the guide routes to match the content phase\nPhase 2: Dire Maul quests\nPhase 3: 100% quest XP (SoM)\nPhase 4: ZG/Silithus quests\nPhase 5: AQ quests\nPhase 6: Eastern Plaguelands quests"),
                        type = "range",
                        width = optionsWidth,
                        order = 2.3,
                        min = 1,
                        max = 6,
                        step = 1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.ReloadGuide()
                            addon.RXPFrame.GenerateMenuTable()
                        end,
                        hidden = addon.game ~= "CLASSIC" or addon.settings.profile.season == 2,
                        disabled = function ()
                            return addon.settings.profile.enableAutomaticXpRate
                        end,
                    },
                    hardcore = {
                        name = L("Hardcore mode"),
                        desc = L(
                            "Adjust the leveling routes to the deathless ruleset"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.4,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.RenderFrame()
                        end,
                        hidden = addon.game ~= "CLASSIC"
                    },
                    season = {
                        hidden = addon.game ~= "CLASSIC",
                        --[[disabled = function()
                            return addon.settings.profile.enableAutomaticXpRate
                        end,]]
                        name = L("Season"),
                        desc = L(
                            "Adjust the leveling routes to the current season"),
                        type = "select",
                        values = {[0] = L"None", [1] = L"Season of Mastery", [2] = L"Season of Discovery"},
                        --sorting = {0, 1, 2},
                        width = optionsWidth,
                        order = 2.5,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.ReloadGuide()
                            addon.RXPFrame.GenerateMenuTable()
                        end
                    },
                    dungeonsHeader = {
                        name = _G.DUNGEONS or L("Dungeons"),
                        type = "header",
                        width = "full",
                        order = 2.8,
                        hidden = function()
                            return not next(addon.settings.dungeons:GetDungeons())
                        end
                    },
                    dungeonsSetRecommended = {
                        name = L("Select Recommended Dungeons"),
                        desc = L("Factor only the high-impact dungeons into the route"),
                        order = 2.81,
                        type = "execute",
                        width = optionsWidth * 1.5,
                        func = function()
                            addon.settings.dungeons:SetRecommended()
                            AceConfigRegistry:NotifyChange(addon.title)
                        end,
                        hidden = function()
                            return not addon.dungeonStats or
                                not next(addon.settings.dungeons:GetDungeons())
                        end
                    },
                    dungeonsSetAll = {
                        name = L("Select All Dungeons"),
                        order = 2.82,
                        type = "execute",
                        width = optionsWidth,
                        func = function()
                            addon.settings.dungeons:SetAll()
                            AceConfigRegistry:NotifyChange(addon.title)
                        end,
                        hidden = function()
                            return not next(addon.settings.dungeons:GetDungeons())
                        end
                    },
                    dungeons = {
                        name = L("Dungeons"), -- TODO locale
                        desc = function()
                            local out =
                                L "Routes in quests for the selected dungeon\nGuides that support this feature:\n"
                            for guide in pairs(
                                             RXPCData.guideMetaData.dungeonGuides) do
                                out = fmt("%s\n%s", out, guide)
                            end
                            return out
                        end,
                        type = "multiselect",
                        width = optionsWidth,
                        order = 2.9,
                        values = function()
                            return addon.settings.dungeons:GetDungeons()
                        end,
                        get = function(_, key)
                            return addon.settings.profile.dungeons[key]
                        end,
                        set = function(_, key, state)
                            addon.settings.profile.dungeons[key] = state
                            addon.ReloadGuide()
                        end,
                        hidden = function()
                            return not next(addon.settings.dungeons:GetDungeons())
                        end
                    },
                    professions = {
                        hidden = function()
                            return addon.game ~= "CLASSIC" or not next(addon.professions)
                        end,
                        --[[disabled = function()
                            return addon.settings.profile.enableAutomaticXpRate
                        end,]]
                        name = L("Professions"),
                        desc = function()
                            local out =
                                L "Level professions along with the guide\nGuides that support this feature:\n"
                            for guide in pairs(
                                             RXPCData.guideMetaData.professionGuides) do
                                out = fmt("%s\n%s", out, guide)
                            end
                            return out
                        end,
                        type = "select",
                        values = addon.GenerateProfessionTable or {},
                        --sorting = {0, 1, 2},
                        width = optionsWidth,
                        order = 2.91,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.ReloadGuide()
                            addon.RXPFrame.GenerateMenuTable()
                        end,
                    },
                    preflightHeader = {
                        name = L("Route Planning"),
                        type = "header",
                        width = "full",
                        order = 3.0,
                        hidden = addon.gameVersion ~= 30300
                    },
                    enableRoutePreflight = {
                        name = L("Enable Route Preflight"),
                        desc = L("Checks upcoming processed guide steps for proven prerequisite, quest-log, flight, map, item, and XP risks."),
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.1,
                        hidden = addon.gameVersion ~= 30300,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.routePreflight then addon.routePreflight:ScheduleScan(0.05) end
                        end
                    },
                    preflightLookahead = {
                        name = L("Preflight steps ahead"),
                        desc = L("Number of current and upcoming steps checked by Route Preflight and the XP predictor."),
                        type = "range",
                        width = optionsWidth,
                        order = 3.2,
                        min = 1,
                        max = 100,
                        step = 1,
                        hidden = addon.gameVersion ~= 30300,
                        set = function(info, value)
                            SetProfileOption(info, math.floor(value + 0.5))
                            if addon.routePreflight then addon.routePreflight:ScheduleScan(0.05) end
                        end,
                        disabled = function() return not self.profile.enableRoutePreflight end
                    },
                    enableXPShortfallPredictor = {
                        name = L("XP Shortfall Predictor"),
                        desc = L("Uses explicit XP gates, current XP, live rewards, and anonymous observed quest rewards. Unknown rewards remain clearly marked as unknown."),
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.3,
                        hidden = addon.gameVersion ~= 30300,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.routePreflight then addon.routePreflight:ScheduleScan(0.05) end
                        end
                    },
                    enableItemReservations = {
                        name = L("Enable Item Reservations"),
                        desc = L("Protects items required by upcoming guide steps from automatic junk handling and marks them in bags."),
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.4,
                        hidden = addon.gameVersion ~= 30300,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.routePreflight then addon.routePreflight:ScheduleScan(0.05) end
                            if addon.inventoryManager then addon.inventoryManager.RefreshJunkIcons(0.05) end
                        end
                    },
                    reservationLookahead = {
                        name = L("Reservation steps ahead"),
                        desc = L("Number of current and upcoming steps searched for item requirements."),
                        type = "range",
                        width = optionsWidth,
                        order = 3.5,
                        min = 1,
                        max = 100,
                        step = 1,
                        hidden = addon.gameVersion ~= 30300,
                        set = function(info, value)
                            SetProfileOption(info, math.floor(value + 0.5))
                            if addon.routePreflight then addon.routePreflight:ScheduleScan(0.05) end
                        end,
                        disabled = function() return not self.profile.enableItemReservations end
                    },
                    stuckWatchdogTimeout = {
                        name = L("Manual watchdog timeout"),
                        desc = L("Seconds without measurable progress before an explicitly armed step watchdog warns. The watchdog never starts automatically."),
                        type = "range",
                        width = optionsWidth,
                        order = 3.6,
                        min = 30,
                        max = 600,
                        step = 10,
                        hidden = addon.gameVersion ~= 30300
                    },
                    openRoutePreflight = {
                        name = L("Open Route Preflight"),
                        type = "execute",
                        width = optionsWidth,
                        order = 3.7,
                        hidden = addon.gameVersion ~= 30300,
                        func = function()
                            if addon.routePreflight then addon.routePreflight:Toggle() end
                        end
                    },
                    xpAssistantHeader = {
                        name = L("XP Progress and Mob Estimates"),
                        type = "header",
                        width = "full",
                        order = 3.71,
                        hidden = addon.gameVersion ~= 30300
                    },
                    showXPRemaining = {
                        name = L("Show XP remaining in the guide footer"),
                        desc = L("Shows the exact XP still needed for the next level. Click the footer value to open the yellow-mob estimator."),
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.72,
                        hidden = addon.gameVersion ~= 30300,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.xpAssistant then
                                addon.xpAssistant:RefreshFooter()
                            end
                        end
                    },
                    enableMobXPEstimator = {
                        name = L("Enable Yellow-Mob Estimator"),
                        desc = L("Shows stock WotLK XP and kill estimates for ordinary solo mobs from two levels below to two levels above you."),
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.73,
                        hidden = addon.gameVersion ~= 30300,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.xpAssistant then
                                addon.xpAssistant:ApplySettings()
                            end
                        end
                    },
                    adaptiveMobXP = {
                        name = L("Learn private-server mob XP"),
                        desc = L("Learns a safe median XP multiplier from verified ordinary solo yellow-mob kills. Grouped, rested-uncertain, elite, rare, and instance kills are ignored."),
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.74,
                        hidden = addon.gameVersion ~= 30300,
                        disabled = function()
                            return not self.profile.enableMobXPEstimator
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.xpAssistant then
                                addon.xpAssistant:ApplySettings()
                            end
                        end
                    },
                    openMobXPEstimator = {
                        name = L("Open XP & Yellow-Mob Estimator"),
                        type = "execute",
                        width = optionsWidth,
                        order = 3.75,
                        hidden = addon.gameVersion ~= 30300,
                        disabled = function()
                            return not self.profile.enableMobXPEstimator
                        end,
                        func = function()
                            if addon.xpAssistant then addon.xpAssistant:Toggle() end
                        end
                    },
                    resetMobXPSamples = {
                        name = L("Reset learned XP samples"),
                        desc = L("Clears the anonymous per-character calibration samples used by the adaptive estimate."),
                        type = "execute",
                        width = optionsWidth,
                        order = 3.76,
                        hidden = addon.gameVersion ~= 30300,
                        confirm = L("Clear all learned mob XP samples for this character?"),
                        func = function()
                            if addon.xpAssistant then
                                addon.xpAssistant:ResetCalibration(true)
                            end
                        end
                    },
                    enablePetAssistant = {
                        name = L("Enable Hunter Pet Assistant"),
                        desc = L("Tracks pet happiness, compatible food, talents, known skills, supplies, and guide-linked stable/tame preparation."),
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.8,
                        hidden = function()
                            return addon.gameVersion ~= 30300 or
                                not (addon.player and addon.player.class == "HUNTER")
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if value and addon.petAssistant then
                                if addon.roadmap then
                                    addon.roadmap:RunOptional("hunter pet assistant",
                                        function() addon.petAssistant:Setup() end)
                                else
                                    addon.petAssistant:Setup()
                                end
                            end
                            if not value and addon.petAssistant and addon.petAssistant.frame then
                                addon.petAssistant.frame:Hide()
                            end
                        end
                    },
                    openPetAssistant = {
                        name = L("Open Hunter Pet Assistant"),
                        type = "execute",
                        width = optionsWidth,
                        order = 3.9,
                        hidden = function()
                            return addon.gameVersion ~= 30300 or
                                not (addon.player and addon.player.class == "HUNTER")
                        end,
                        disabled = function() return not self.profile.enablePetAssistant end,
                        func = function()
                            if addon.petAssistant then addon.petAssistant:Toggle() end
                        end
                    },
                    resetToolWindows = {
                        name = L("Reset Tool Window Positions"),
                        desc = L("Restores the Route Preflight, Personal-Best Archives, Hunter Pet Assistant, Performance Inspector, and XP Estimator windows to their default size and position."),
                        type = "execute",
                        width = optionsWidth,
                        order = 3.95,
                        hidden = addon.gameVersion ~= 30300,
                        func = function()
                            if addon.toolWindows then
                                addon.toolWindows:ResetPlacements()
                            end
                        end
                    },
                    questCleanupHeader = {
                        name = L("Quest Cleanup"),
                        type = "header",
                        width = "full",
                        order = 10.0
                    },
                    abandonOrphanedQuests = {
                        name = L("Cleanup Orphaned Quests"), -- TODO locale
                        desc = L("Cleanup obsolete or leftover quests"),
                        order = 10.1,
                        type = "execute",
                        width = optionsWidth,
                        func = function()
                            addon.AbandonOrphanedQuests(settingsCache.invertedOrphans)
                            wipe(settingsCache.invertedOrphans)
                        end,
                        confirm = function()
                            local result = L("Abandon the following quests?")

                            for _, d in ipairs(settingsCache.invertedOrphans) do
                                result =
                                    fmt("%s\n%s (level %d)", result,
                                        d.questLogTitleText, d.level)
                            end

                            return result
                        end,
                        disabled = function()
                            return #settingsCache.invertedOrphans == 0
                        end
                    },
                    orphanedQuestBox = {
                        order = 10.2,
                        type = 'description',
                        name = function()
                            -- TODO prevent double call on settings frame load, optimization
                            -- Explicity not using addon.orphanedList to reduce chance of outdated results
                            local result = ""
                            local invertedOrphans = addon.GetOrphanedQuests()
                            for _, d in ipairs(invertedOrphans) do
                                result =
                                    fmt("%s\n%s (level %d)", result,
                                        d.questLogTitleText, d.level)
                            end

                            settingsCache.invertedOrphans = invertedOrphans

                            return result
                        end,
                        width = optionsWidth
                    }
                }
            },
            featureToolsSettings = {
                type = "group",
                name = L("Feature Tools"),
                desc = L("Open and customize each optional feature window independently."),
                order = 8,
                childGroups = "tree",
                hidden = addon.gameVersion ~= 30300,
                args = {
                    routePreflight = preflightToolPage,
                    archives = archiveToolPage,
                    petAssistant = petToolPage,
                    performance = performanceToolPage,
                    xpEstimator = xpToolPage,
                    speedrunning = speedrunningToolPage,
                },
            },
            targeting = {
                type = "group",
                name = _G.BINDING_HEADER_TARGETING,
                order = 4,
                args = {
                    macroHeader = {
                        name = fmt("%s%s", L("Targeting Macro"),
                                   addon.targeting:CanCreateMacro() and '' or
                                       ' - ' .. L("Macro capacity reached")), -- TODO locale
                        type = "header",
                        width = "full",
                        order = 1
                    },
                    enableTargetMacro = {
                        name = L("Create Targeting Macro"), -- TODO locale
                        desc = L("Automatically create a targeting macro"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.targeting:Setup()
                            addon.targeting:UpdateMacro()
                        end,
                        disabled = function()
                            return not self.profile.enableTargetMacro and
                                       not addon.targeting:CanCreateMacro()
                        end
                    },
                    notifyOnTargetUpdates = {
                        name = L("Notify on new target"), -- TODO locale
                        desc = L("Notify when a new target is loaded"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.2,
                        disabled = function()
                            return not self.profile.enableTargetMacro or
                                       not addon.targeting:CanCreateMacro()
                        end
                    },
                    activeTargetsHeader = {
                        name = L("Active Targets"),
                        type = "header",
                        width = "full",
                        order = 2
                    },
                    enableTargetAutomation = {
                        name = L("Enable Active Targets"), -- TODO locale
                        desc = L("Automatically scan nearby targets"),
                        type = "toggle",
                        width = unitscanEnabled and optionsWidth or optionsWidth * 3,
                        order = 2.1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.targeting.activeTargetFrame and
                                not InCombatLockdown() then
                                addon.targeting.activeTargetFrame:Hide()
                            end
                            addon.targeting:Setup()
                        end
                    },
                    enableMaxNameplateDistance = {
                        name = addon.gameVersion == 30300 and
                                   L("Maximize Targeting Distance") or
                                   L("Maximize Nameplate Distance"),
                        desc = addon.gameVersion == 30300 and
                                   L("Maximize supported target-acquisition and nameplate distance settings without forcing nameplates on") or
                                   L("Maximize nameplate visibility distance for target detection"),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 2.105,
                        disabled = function()
                            return not self.profile.enableTargetAutomation
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.gameVersion == 30300 then
                                addon.targeting:ApplyLegacyTargetRange()
                                addon.targeting:RefreshScanTicker()
                            else
                                addon.targeting:Setup()
                            end
                        end
                    },
                    showTargetingOnProximity = {
                        name = L("Only show when in range"), -- TODO locale
                        desc = addon.gameVersion == 30300 and
                                   "Show targets detected on visible nameplates, or by target/mouseover. Nameplates must be enabled for background scanning." or
                                   L("Check if targets are nearby\nWarning: This relies on ADDON_ACTION_FORBIDDEN errors from TargetUnit() to function."),
                        type = "toggle",
                        width = optionsWidth * 2,
                        order = 2.11,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.targeting:Setup()
                            if addon.targeting.UpdateTargetFrame then
                                addon.targeting:UpdateTargetFrame()
                            end
                        end,
                        disabled = function()
                            return not self.profile.enableTargetAutomation
                        end,
                        hidden = addon.gameVersion ~= 30300 and not unitscanEnabled
                    },
                    enableFriendlyTargeting = {
                        name = L("Scan Friendly Targets"), -- TODO locale
                        desc = L("Scan for friendly targets"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.2,
                        disabled = function()
                            return not self.profile.enableTargetAutomation
                        end
                    },
                    enableTargetMarking = {
                        name = L("Mark Friendly Targets"), -- TODO locale
                        desc = L(
                            "Mark friendly targets with star, circle, diamond, and triangle"),
                        type = "toggle",
                        width = optionsWidth * 2,
                        order = 2.21,
                        disabled = function()
                            return not self.profile.enableTargetAutomation
                        end
                    },
                    enableEnemyTargeting = {
                        name = L("Scan Enemy Targets"), -- TODO locale
                        desc = L("Scan for enemy targets"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.3,
                        disabled = function()
                            return not self.profile.enableTargetAutomation
                        end
                    },
                    enableEnemyMarking = {
                        name = L("Mark Enemy Targets"), -- TODO locale
                        desc = L("Mark special enemy targets with moon"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.31,
                        disabled = function()
                            return not self.profile.enableTargetAutomation
                        end
                    },
                    enableMobMarking = {
                        name = L("Mark Enemy Mobs"), -- TODO locale
                        desc = L("Mark enemy mobs with skull, cross, and square"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.32,
                        disabled = function()
                            return not self.profile.enableTargetAutomation
                        end
                    },
                    scanForRares = {
                        name = L("Scan for Nearby Rares"), -- TODO locale
                        desc = L("Checks for nearby rare spawns"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.4,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.targeting.RefreshRareScanning then
                                addon.targeting:RefreshRareScanning()
                            else
                                addon.targeting:RefreshLegacyTargets()
                            end
                        end,
                        disabled = function()
                            return not self.profile.enableTargetAutomation or
                                       not self.profile.showTargetingOnProximity
                        end,
                        hidden = not unitscanEnabled
                    },
                    notifyOnRares = {
                        name = L("Notify on Rares"), -- TODO locale
                        desc = L("Notify when a new rare is found"),
                        type = "toggle",
                        width = optionsWidth * 2,
                        order = 2.41,
                        disabled = function()
                            return not self.profile.enableTargetAutomation or
                                       not self.profile.showTargetingOnProximity or
                                       not self.profile.scanForRares
                        end,
                        hidden = not unitscanEnabled
                    },
                    hideActiveTargetsBackground = {
                        name = L("Hide Targets Background"),
                        desc = L("Make background transparent"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.5,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.targeting:RenderTargetFrameBackground()
                        end,
                        disabled = function()
                            return not self.profile.enableTargetAutomation
                        end
                    },
                    activeTargetScale = {
                        name = L("Active Targets Scale"), -- TODO locale
                        desc = L("Scale of the Active Targets frame"),
                        type = "range",
                        width = optionsWidth,
                        order = 2.51,
                        min = 0.8,
                        max = 3,
                        step = 0.05,
                        isPercent = true,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.targeting.activeTargetFrame:SetScale(value)
                        end
                    },
                    resetTargetPosition = {
                        name = L("Reset Window Position"), -- TODO locale
                        order = 2.52,
                        type = "execute",
                        width = optionsWidth,
                        func = function()
                            addon.ResetTargetPosition()
                        end
                    },
                    alertHeader = {
                        name = _G.COMMUNITIES_NOTIFICATION_SETTINGS,
                        type = "header",
                        width = "full",
                        order = 3
                    },
                    flashOnFind = {
                        name = L("Flash Client Icon"), -- TODO locale
                        desc = L(
                            "Flashes the game icon on taskbar when enemy target found"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.1,
                        disabled = function()
                            return not self.profile.enableTargetAutomation or
                                       not self.profile.showTargetingOnProximity
                        end
                    },
                    enableTargetingFlash = {
                        name = _G.SHOW_FULLSCREEN_STATUS_TEXT,
                        desc = L(
                            "Flashes the screen corners when enemy target found"),
                        type = "toggle",
                        width = optionsWidth * 2,
                        order = 3.2,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if not value and addon.tips and
                                addon.tips.DisableDangerWarning then
                                addon.tips:DisableDangerWarning()
                            end
                        end,
                        disabled = function()
                            return not self.profile.enableTips or
                                       not self.profile.enableTargetAutomation or
                                       not self.profile.showTargetingOnProximity
                        end
                    },
                    soundOnFind = {
                        name = L("Play Sound"), -- TODO locale
                        desc = L("Sends sound on enemy target found"),
                        type = "select",
                        width = optionsWidth,
                        order = 3.3,
                        values = function()
                            if addon.gameVersion == 30300 then
                                return legacyTargetSoundValues
                            end
                            return {
                                ["none"] = "none",
                                [3175] = "Map Ping",
                                [11773] = "War Drums",
                                [8959] = "Raid Warning",
                                [5274] = "Auction Window Open",
                                [17318] = "LFG Dungeon Ready",
                                [9378] = "PVP Flag Taken",
                                [8960] = _G.QUEUED_STATUS_READY_CHECK_IN_PROGRESS,
                                [9374] = "PVP Flag Captured",
                                [9375] = "PVP Warning",
                                [180461] = "Fel Reaver"
                            }
                        end,
                        disabled = function()
                            return not self.profile.enableTargetAutomation or
                                       not self.profile.showTargetingOnProximity
                        end
                    },
                    soundOnFindChannel = {
                        name = L("Sound Channel"), -- TODO locale
                        type = "select",
                        width = optionsWidth,
                        order = 3.4,
                        values = {
                            ["Master"] = _G.MASTER,
                            ["Music"] = _G.MUSIC_VOLUME,
                            ["Ambience"] = _G.AMBIENCE_VOLUME,
                            ["Dialog"] = _G.DIALOG_VOLUME
                        },
                        hidden = addon.gameVersion == 30300,
                        disabled = function()
                            return not self.profile.enableTargetAutomation or
                                       not self.profile.showTargetingOnProximity or
                                       self.profile.soundOnFind == "none"
                        end
                    },
                    testSoundOnFind = {
                        name = _G.EVENTTRACE_BUTTON_PLAY,
                        order = 3.5,
                        type = 'execute',
                        disabled = function()
                            return self.profile.soundOnFind == "none"
                        end,
                        func = function()
                            self:PlayTargetingSound(
                                self.profile.soundOnFind,
                                self.profile.soundOnFindChannel)
                        end
                    }
                }
            },
            levelTrackerFeatures = {
                type = "group",
                name = L("Leveling Tracker"),
                order = 5,
                args = {
                    enableTracker = {
                        name = L("Enable Leveling Tracker"),
                        type = "toggle",
                        width = "full",
                        order = 1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if value then
                                addon.roadmap:RunOptional("leveling tracker",
                                    function()
                                        addon.tracker:SetupTracker()
                                    end)
                            else
                                addon.tracker:ShutdownTracker()
                            end
                        end
                    },
                    openTrackerReportOnCharOpen = {
                        name = L(
                            "Always Open Leveling Report With Character Panel"),
                        desc = L(
                            "Enables the RestedXP Leveling Report when you open your character panel"),
                        type = "toggle",
                        width = "full",
                        order = 1.1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            local ui = addon.tracker.ui and
                                           addon.tracker.ui.CharacterFrame
                            if not value and ui then ui:Hide() end
                        end
                    },
                    enableLevelingReportInspections = {
                        name = L("Enable Leveling Report Inspections") ..
                            " (Beta)",
                        desc = L(
                            "Send or receive inspection requests for other Leveling Reports"),
                        type = "toggle",
                        width = "full",
                        order = 1.2,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            self.profile.levelingInspectionConsent = true
                            addon.tracker:SetupInspections()
                        end,
                        disabled = function()
                            return not addon.settings.profile.enableTracker
                        end,
                        hidden = isNotAdvanced
                    },
                    splitsOptionsHeader = {
                        name = L("Level Splits"),
                        type = "header",
                        width = "full",
                        order = 2
                    },
                    enablelevelSplits = {
                        name = L("Enable Level Splits"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if value then
                                addon.tracker:CreateLevelSplits()
                                addon.tracker.levelSplits:Show()
                            else
                                if addon.tracker.levelSplits and
                                    addon.tracker.levelSplits:IsShown() then
                                    addon.tracker.levelSplits:Hide()
                                end
                            end
                        end,
                        disabled = function()
                            return not self.profile.enableTracker
                        end
                    },
                    compareNextLevelSplit = {
                        name = L("Compare Next Level"),
                        desc = L("When comparing, show next level's time"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.2,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.tracker:UpdateLevelSplits("full")
                        end,
                        disabled = function()
                            return not self.profile.enableTracker or
                                       not self.profile.enablelevelSplits
                        end
                    },
                    compareTotalTimeSplit = {
                        name = L("Show Total Time Split"),
                        desc = L("When comparing, show total time difference"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.3,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.tracker:UpdateLevelSplits("full")
                        end,
                        disabled = function()
                            return not addon.settings.profile.enableTracker or
                                       not self.profile.enablelevelSplits
                        end
                    },
                    hideSplitsBackground = {
                        name = L("Hide Splits Background"),
                        desc = L("Make background transparent"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.4,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.tracker:RenderSplitsBackground()
                        end,
                        disabled = function()
                            return not self.profile.enableTracker or
                                       not self.profile.enablelevelSplits
                        end
                    },
                    levelSplitsHistory = {
                        name = L("Level Splits History"),
                        desc = L("Historical levels to show"),
                        type = "range",
                        width = optionsWidth,
                        order = 2.5,
                        min = 1,
                        max = GetMaxPlayerLevel(),
                        step = 1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.tracker:UpdateLevelSplits("full")
                        end,
                        disabled = function()
                            return not self.profile.enableTracker or
                                       not self.profile.enablelevelSplits
                        end
                    },
                    levelSplitsFontSize = {
                        name = L("Level Splits Font Size"),
                        type = "range",
                        width = optionsWidth,
                        order = 2.6,
                        min = 9,
                        max = 17, -- Formatting gets wonky >=18
                        step = 1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.tracker:UpdateLevelSplits("full")
                        end,
                        disabled = function()
                            return not self.profile.enableTracker or
                                       not self.profile.enablelevelSplits
                        end
                    },
                    levelSplitsOpacity = {
                        name = L("Level Splits Opacity"),
                        desc = L(
                            "Lower number to make Level Splits more transparent"),
                        type = "range",
                        width = optionsWidth,
                        order = 2.7,
                        min = 0.1,
                        max = 1,
                        step = 0.1,
                        isPercent = true,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.tracker:UpdateLevelSplits("full")
                        end,
                        disabled = function()
                            return not self.profile.enableTracker or
                                       not self.profile.enablelevelSplits
                        end
                    },
                    personalBestArchives = {
                        name = L("Personal-Best Archives"),
                        desc = L("Open anonymous account-wide leveling runs and select a split comparison."),
                        type = "execute",
                        width = optionsWidth,
                        order = 2.8,
                        hidden = addon.gameVersion ~= 30300,
                        func = function()
                            if addon.runArchive then addon.runArchive:Toggle() end
                        end
                    }
                }
            },
            communications = {
                type = "group",
                name = L("Communications"),
                order = 6,
                args = {
                    checkVersions = {
                        name = L("Enable Addon Version Checks"),
                        desc = L("Advertises and compares addon versions with all RXP users in party"),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 1
                    },
                    commsLevelUpOptionsHeader = {
                        name = L("Announcements"),
                        type = "header",
                        width = "full",
                        order = 2.0
                    },
                    enableLevelUpAnnounceSolo = {
                        name = L("Announce Level Ups (Emote)"),
                        desc = L("Make a public emote when you level up"),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 2.1
                    },
                    enableLevelUpAnnounceGroup = {
                        name = L("Announce Level Ups (Party Chat)"),
                        desc = L("Announce in party chat when you level up"),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 2.2
                    },
                    enableLevelUpAnnounceGuild = {
                        name = L("Announce Level Ups (Guild Chat)"),
                        desc = L("Announce in guild chat when you level up"),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 2.3
                    },
                    groupCoordinationHeader = {
                        name = _G.TUTORIAL_TITLE18,
                        type = "header",
                        width = "full",
                        order = 3.0
                    },
                    shareQuests = {
                        name = L("Automatic quest sharing"), -- TODO: Localize this setting
                        desc = L("Whenever you accept a quest in the guide, the addon tries to share it with your group"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.2
                    },
                    alwaysSendBranded = {
                        name = L("Send announcements without another RXP user in group"),
                        desc = L("Without this checked we will only send announcements if another RestedXP User is in your group"),
                        type = "toggle",
                        width = "full",
                        order = 3.3
                    },
                    enableCompleteStepAnnouncements = {
                        name = L("Announce when Quest Step is completed"),
                        desc = L("Announce in party chat when you complete certain quests (.complete)"),
                        type = "toggle",
                        width = "full",
                        order = 3.4
                    },
                    enableCollectStepAnnouncements = {
                        name = L("Announce when all Step items are collected"),
                        desc = L("Announce in party chat when you collect all the items relevant to a quest (.collect)"),
                        type = "toggle",
                        width = "full",
                        order = 3.5
                    },
                    enableFlyStepAnnouncements = {
                        name = L("Announce Flying Step timers"),
                        desc = L("Announce in party chat where you're flying and how long until you arrive"),
                        type = "toggle",
                        width = "full",
                        order = 3.6
                    },
                    ignoreQuestieConflicts = {
                        name = L("Ignore Questie announcements"),
                        desc = L("Send quest and collect step announcements even if Questie is enabled"),
                        type = "toggle",
                        width = "full",
                        order = 3.7,
                        hidden = not _G.Questie
                    }
                }
            },
            tipsPanel = {
                type = "group",
                name = L("Tips"), -- TODO locale
                order = 7,
                args = {
                    enableTips = {
                        name = L("Enable Tips"), -- TODO locale
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.1,
                        set = function(info, value) -- Address initialization issues during toggle
                            SetProfileOption(info, value)
                            if addon.itemUpgrades then
                                addon.itemUpgrades:Setup()
                            end
                            if addon.tips then addon.tips:ApplySettings() end
                        end,
                    },
                    enableTipsFrame = {
                        name = L("Enable Tips Frame"), -- TODO locale
                        desc = L("Show available emergency items and spells when your health is low"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.2,
                        disabled = function()
                            return not self.profile.enableTips
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.tips then addon.tips:ApplySettings() end
                        end
                    },
                    enableQuestChoiceGoldRecommendation = {
                        name = L("Quest Sellable Recommendation"), -- TODO locale
                        desc = L("Displays the best sellable quest reward"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.3,
                        hidden = addon.gameVersion > 40000
                    },
                    drowningHeader = {
                        name = _G.STRING_ENVIRONMENTAL_DAMAGE_DROWNING,
                        type = "header",
                        width = "full",
                        order = 2.0
                    },
                    enableDrowningWarning = {
                        name = L("Enable Warning"), -- TODO locale
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.tips and
                                addon.tips.SetDrowningWarningEnabled then
                                addon.tips:SetDrowningWarningEnabled(value)
                            end
                        end,
                        disabled = function()
                            return not self.profile.enableTips
                        end
                    },
                    enableDrowningWarningSound = {
                        name = L("Enable Warning Sound"), -- TODO locale
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.2,
                        disabled = function()
                            return not self.profile.enableTips or
                                       not self.profile.enableDrowningWarning
                        end
                    },
                    drowningThreshold = {
                        name = L("Threshold"), -- TODO locale
                        type = "range",
                        width = optionsWidth,
                        order = 2.3,
                        min = 0.05,
                        max = 0.5,
                        step = 0.05,
                        isPercent = true,
                        disabled = function()
                            return not self.profile.enableTips or
                                       not self.profile.enableDrowningWarning
                        end
                    },
                    enableDrowningScreenFlash = {
                        name = _G.SHOW_FULLSCREEN_STATUS_TEXT,
                        desc = L(
                            "Flashes the screen corners when in danger of drowning"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 2.4,
                        disabled = function()
                            return not self.profile.enableTips or
                                       not self.profile.enableDrowningWarning
                        end
                    },
                    emergencyHeader = {
                        name = L("Emergency Actions"), -- TODO locale
                        type = "header",
                        width = "full",
                        order = 3.0
                    },
                    enableEmergencyActions = {
                        name = L("Enable Warning"), -- TODO locale
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.tips and
                                addon.tips.SetEmergencyActionsEnabled then
                                addon.tips:SetEmergencyActionsEnabled(value)
                            end
                        end,
                        disabled = function()
                            return not self.profile.enableTips
                        end
                    },
                    emergencyThreshold = {
                        name = L("Threshold"), -- TODO locale
                        type = "range",
                        width = optionsWidth,
                        order = 3.2,
                        min = 0.05,
                        max = 0.40,
                        step = 0.05,
                        isPercent = true,
                        disabled = function()
                            return not self.profile.enableTips or
                                       not self.profile.enableEmergencyActions
                        end
                    },
                    enableEmergencyIconAnimations = {
                        name = L("Enable Animations"), -- TODO locale
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.3,
                        disabled = function()
                            return not self.profile.enableTips or
                                       not self.profile.enableEmergencyActions
                        end
                    },
                    enableEmergencyScreenFlash = {
                        name = _G.SHOW_FULLSCREEN_STATUS_TEXT,
                        desc = L(
                            "Flashes the screen corners when an emergency action is recommended"), -- TODO locale
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.4,
                        disabled = function()
                            return not self.profile.enableTips or
                                       not self.profile.enableEmergencyActions
                        end
                    },
                    dangerousMobsHeader = {
                        name = (addon.gameVersion < 20000 or
                                    addon.gameVersion == 30300) and
                                   L("Dangerous Mobs Tracking") or
                                   L("Rare Tracker"),
                        type = "header",
                        width = "full",
                        order = 4.0,
                        hidden = function()
                            return not addon.dangerousMobs
                        end
                    },
                    showDangerousMobsMap = {
                        name = L("Track Mobs on Map"), -- TODO locale
                        desc = L(
                            "Displays dangerous mobs and patrols on your map (WIP)"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 4.1,
                        set = function(info, value)
                            -- addon.settings.profile.showDangerousMobsMap = value
                            SetProfileOption(info, value)
                            addon.tips:LoadDangerousMobs(true)
                        end,
                        disabled = function()
                            return not self.profile.enableTips
                        end,
                        hidden = function()
                            return not addon.dangerousMobs or
                                       (addon.gameVersion > 20000 and
                                           addon.gameVersion ~= 30300)
                        end
                    },
                    showDangerousUnitscan = {
                        name = L("Scan for dangerous mobs"), -- TODO locale
                        desc = L(
                            "Displays dangerous mobs and patrols on the targeting window (WIP)"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 4.2,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.settings.profile.showDangerousUnitscan = value
                            addon.tips:LoadDangerousMobs(true)
                        end,
                        disabled = function()
                            return not self.profile.enableTips
                        end,
                        hidden = function()
                            return not addon.dangerousMobs or
                                       (not unitscanEnabled and
                                           addon.gameVersion ~= 30300) or
                                       (addon.gameVersion > 20000 and
                                           addon.gameVersion ~= 30300)
                        end
                    },
                    showDangerousMobWarning = {
                        name = L("Dangerous mob screen flash"),
                        desc = L("Briefly flashes the screen edges when a detected dangerous mob appears"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 4.21,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if not value and addon.tips then
                                addon.tips:DisableDangerWarning()
                            end
                        end,
                        disabled = function()
                            return not self.profile.enableTips or
                                       not self.profile.showDangerousUnitscan
                        end,
                        hidden = function()
                            return addon.gameVersion ~= 30300 or
                                       not addon.dangerousMobs
                        end
                    },
                    showRares = {
                        name = L("Track Rare Mobs"), -- TODO locale
                        desc = addon.rareDesc,
                        type = "toggle",
                        width = optionsWidth,
                        order = 4.3,
                        set = function(info, value)
                            -- addon.settings.profile.showDangerousMobsMap = value
                            SetProfileOption(info, value)
                            addon.tips:LoadDangerousMobs(true)
                        end,
                        disabled = function()
                            return not self.profile.enableTips
                        end,
                        hidden = function()
                            return not addon.dangerousMobs or addon.gameVersion < 20000
                        end
                    },
                    ignoreDuplicateRares = {
                        name = L("Skip mobs already killed"), -- TODO locale
                        desc = L("Don't show on the map rare mobs you already killed for their respective achievement"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 4.31,
                        set = function(info, value)
                            -- addon.settings.profile.showDangerousMobsMap = value
                            SetProfileOption(info, value)
                            addon.tips:LoadDangerousMobs(true)
                            addon:ReloadGuide(true)
                        end,
                        disabled = function()
                            return not self.profile.enableTips
                        end,
                        hidden = function()
                            return not addon.dangerousMobs or addon.gameVersion < 20000
                        end
                    },
                    showTreasures = {
                        name = L("Track Treasures"), -- TODO locale
                        desc = addon.treasureDesc,
                        type = "toggle",
                        width = optionsWidth,
                        order = 4.32,
                        set = function(info, value)
                            -- addon.settings.profile.showDangerousMobsMap = value
                            SetProfileOption(info, value)
                            addon.tips:LoadDangerousMobs(true)
                        end,
                        disabled = function()
                            return not self.profile.enableTips
                        end,
                        hidden = function()
                            return not addon.dangerousMobs or addon.gameVersion < 20000
                        end
                    },
                    itemUpgradesHeader = {
                        name = _G.ITEM_UPGRADE,
                        type = "header",
                        width = "full",
                        order = 5.0,
                        hidden = function()
                            return not addon.itemUpgrades
                        end
                    },
                    enableItemUpgrades = {
                        name = fmt("%s %s", _G.ENABLE, _G.ITEM_UPGRADE),
                        desc = L(
                            "Calculates item upgrades with Tactics' effective power weights"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 5.1,
                        hidden = function()
                            return not addon.itemUpgrades
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.itemUpgrades:Setup()
                        end,
                        disabled = function()
                            return not self.profile.enableTips
                        end
                    },
                    itemUpgradeSpec = {
                        name = _G.TALENTS,
                        -- desc = L("Choose active theme"),
                        type = "select",
                        width = optionsWidth,
                        order = 5.2,
                        get = function()
                            return self.profile.itemUpgradeSpec or
                                       addon.player.localeClass
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            self.profile.itemUpgradeSpecManual = true
                            addon.itemUpgrades:Setup()
                        end,
                        values = function()
                            return addon.itemUpgrades:GetSpecWeights() or {}
                        end,
                        hidden = function()
                            return not addon.itemUpgrades
                        end,
                        disabled = function()
                            return not (self.profile.enableTips and
                                       self.profile.enableItemUpgrades) or
                                       addon.itemUpgrades:GetSpecWeights() ==
                                       nil
                        end
                    },
                    enableTotalEP = {
                        name = L("Always Show Total EP"), -- TODO locale
                        type = "toggle",
                        width = optionsWidth,
                        order = 5.3,
                        hidden = function()
                            return not addon.itemUpgrades
                        end,
                        disabled = function()
                            return not (self.profile.enableTips and
                                       self.profile.enableItemUpgrades)
                        end
                    },
                    enableQuestChoiceRecommendation = {
                        name = L("Quest Reward Recommendation"), -- TODO locale
                        desc = L("Displays the best calculated item upgrade"),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 5.4,
                        hidden = function()
                            return not addon.itemUpgrades
                        end,
                        disabled = function()
                            return not (self.profile.enableTips and
                                       self.profile.enableItemUpgrades)
                        end
                    },
                    enableQuestChoiceAutomation = {
                        name = L("Quest Reward Automation"), -- TODO locale
                        desc = L(
                            "Automatically chooses the best calculated quest reward"),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 5.5,
                        hidden = function()
                            return not addon.itemUpgrades
                        end,
                        disabled = function()
                            return not (self.profile.enableTips and
                                       self.profile.enableItemUpgrades and
                                       self.profile.enableQuestChoiceRecommendation)
                        end
                    },
                    disableUpgradeTooltip = {
                        name = L("Disable Upgrade Tooltips"),
                        desc = L("Hide item-upgrade comparison lines without disabling recommendations or calculations"),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 5.6,
                        hidden = function()
                            return not addon.itemUpgrades
                        end,
                        disabled = function()
                            return not (self.profile.enableTips and
                                       self.profile.enableItemUpgrades)
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if value and _G.GameTooltip then
                                _G.GameTooltip:Hide()
                            end
                        end
                    },
                    showUpgradeDetailsOnHover = {
                        name = L("Show upgrade details on hover"),
                        desc = L("Shows an expanded EP breakdown while you hold the selected key over an equippable item. Upgrade prompts also provide a hoverable item icon when supported by the client."),
                        type = "toggle",
                        width = optionsWidth * 1.5,
                        order = 5.65,
                        hidden = function()
                            return not addon.itemUpgrades
                        end,
                        disabled = function()
                            return not (self.profile.enableTips and
                                       self.profile.enableItemUpgrades)
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.itemUpgrades and
                                addon.itemUpgrades.RefreshUpgradePromptHover then
                                addon.itemUpgrades:RefreshUpgradePromptHover()
                            end
                        end
                    },
                    upgradeTooltipModifier = {
                        name = L("Upgrade detail modifier"),
                        desc = L("Hold this key while an item tooltip is visible to show its detailed EP calculation."),
                        type = "select",
                        width = optionsWidth * 0.75,
                        order = 5.66,
                        values = {
                            [1] = "CTRL",
                            [2] = "ALT",
                            [3] = "SHIFT"
                        },
                        get = function()
                            return self.profile.upgradeTooltipModifier or 1
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.itemUpgrades and
                                addon.itemUpgrades.RefreshUpgradePromptHover then
                                addon.itemUpgrades:RefreshUpgradePromptHover()
                            end
                        end,
                        hidden = function()
                            return not addon.itemUpgrades
                        end,
                        disabled = function()
                            return not (self.profile.enableTips and
                                       self.profile.enableItemUpgrades and
                                       self.profile.showUpgradeDetailsOnHover ~=
                                           false)
                        end
                    },
                    enableItemUpgradesAH = {
                        name = fmt("%s %s", _G.ENABLE,
                                   _G.MINIMAP_TRACKING_AUCTIONEER),
                        desc = fmt("%s %s", _G.AUCTION_ITEM, _G.SEARCH),
                        type = "toggle",
                        width = optionsWidth,
                        order = 5.7,
                        hidden = function()
                            return not addon.itemUpgrades or addon.game == "CATA" or
                                       (addon.game == "WOTLK" and addon.gameVersion ~= 30300)
                        end,
                        disabled = function()
                            return not (self.profile.enableTips and
                                       self.profile.enableItemUpgrades)
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.itemUpgrades.AH:Setup()
                        end
                    }
                }
            },
            helpPanel = {
                type = "group",
                name = _G.HELP_LABEL,
                order = 9,
                args = {}
            },
            lookAndFeel = {
                type = "group",
                name = L("Look and Feel"), -- TODO
                order = 10,
                args = {
                    activeTheme = {
                        name = L("Choose Theme"), -- TODO locale
                        desc = L("Choose active theme"),
                        type = "select",
                        width = optionsWidth,
                        order = 1.1,
                        get = function()
                            return
                                self.profile.activeTheme == "Default" and "" or
                                    self.profile.activeTheme
                        end,
                        set = function(info, value)
                            if value == "" then
                                value = "Default"
                            end
                            SetProfileOption(info, value)
                            if self.profile.enableThemeLiveReload then
                                addon.RenderFrame('themeReload')
                            end
                            AceConfigRegistry:NotifyChange(addon.title)
                        end,
                        values = function()
                            return addon:GetThemeOptions()
                        end
                        --[[disabled = function()
                            -- Disable selector if GA/Hardcore as they're special and branded
                            return RXPCData.GA or self.profile.hardcore
                        end]]
                    },
                    customThemeBackground = {
                        name = _G.BACKGROUND,
                        desc = L("Set primary background"),
                        type = "color",
                        width = optionsWidth,
                        order = 1.2,
                        hasAlpha = true,
                        get = function()
                            return unpack(self.profile.customTheme.background)
                        end,
                        set = function(_, r, g, b, a)
                            self.profile.customTheme.background = {
                                r, g, b, a or 1
                            }
                            addon:RegisterTheme(self.profile.customTheme)
                            if self.profile.enableThemeLiveReload then
                                addon.RenderFrame('themeReload')
                            end
                        end,
                        hidden = function()
                            return self.profile.activeTheme ~= 'Custom'
                        end
                    },
                    customThemeBottomFrameBG = {
                        name = L("Step List Background"), -- TODO locale
                        desc = L("Step List Background"),
                        type = "color",
                        width = optionsWidth,
                        order = 1.3,
                        hasAlpha = true,
                        get = function()
                            return
                                unpack(self.profile.customTheme.bottomFrameBG)
                        end,
                        set = function(_, r, g, b, a)
                            self.profile.customTheme.bottomFrameBG = {
                                r, g, b, a or 1
                            }
                            addon:RegisterTheme(self.profile.customTheme)
                            if self.profile.enableThemeLiveReload then
                                addon.RenderFrame('themeReload')
                            end
                        end,
                        hidden = function()
                            return self.profile.activeTheme ~= 'Custom'
                        end
                    },
                    customThemeBottomFrameHighlight = {
                        name = L("Step Highlight"), -- TODO locale
                        desc = L("Step mouseover highlight color"),
                        type = "color",
                        width = optionsWidth,
                        order = 1.4,
                        hasAlpha = true,
                        get = function()
                            return unpack(
                                       self.profile.customTheme
                                           .bottomFrameHighlight)
                        end,
                        set = function(_, r, g, b, a)
                            self.profile.customTheme.bottomFrameHighlight = {
                                r, g, b, a or 1
                            }
                            addon:RegisterTheme(self.profile.customTheme)
                            if self.profile.enableThemeLiveReload then
                                addon.RenderFrame('themeReload')
                            end
                        end,
                        hidden = function()
                            return self.profile.activeTheme ~= 'Custom'
                        end
                    },
                    customThemeMapPins = {
                        name = L("Map Pins"), -- TODO locale
                        desc = L("Map Pin color"),
                        type = "color",
                        width = optionsWidth,
                        order = 1.5,
                        hasAlpha = true,
                        get = function()
                            return unpack(self.profile.customTheme.mapPins)
                        end,
                        set = function(_, r, g, b, a)
                            self.profile.customTheme.mapPins = {r, g, b, a or 1}
                            addon:RegisterTheme(self.profile.customTheme)
                            if self.profile.enableThemeLiveReload then
                                addon.RenderFrame('themeReload')
                            end
                        end,
                        hidden = function()
                            return self.profile.activeTheme ~= 'Custom'
                        end
                    },
                    customThemeTooltip = {
                        name = L("Tooltip"), -- TODO locale
                        desc = L("RGB hex color code"),
                        type = "input", -- TODO color then convert
                        width = optionsWidth,
                        order = 1.6,
                        get = function()
                            local tooltip = self.profile.customTheme.tooltip or
                                                "|cFFCE7BFF"
                            return tooltip:match("^|c%x%x(%x%x%x%x%x%x)$") or
                                       "CE7BFF"
                        end,
                        set = function(_, value)
                            value = value:gsub("^#", ""):upper()
                            self.profile.customTheme.tooltip =
                                fmt('|cFF%s', value)
                            addon:RegisterTheme(self.profile.customTheme)
                            if self.profile.enableThemeLiveReload then
                                addon.RenderFrame('themeReload')
                            end
                            AceConfigRegistry:NotifyChange(addon.title)
                        end,
                        validate = function(_, value)
                            if value and value:match("^#?%x%x%x%x%x%x$") then
                                return true
                            end
                            return "Enter a six-digit RGB hex color (for example CE7BFF)"
                        end,
                        hidden = function()
                            return self.profile.activeTheme ~= 'Custom'
                        end
                    },
                    customThemeFont = {
                        name = L("Font"), -- TODO locale
                        desc = L("Font Path"),
                        type = "input",
                        width = optionsWidth,
                        order = 1.7,
                        get = function()
                            return self.profile.customTheme.font
                        end,
                        validate = function(_, fontPath)
                            local fontString = addon.RXPFrame.GuideName.text
                            local currentPath, currentSize, currentFlags =
                                fontString:GetFont()
                            local isValid =
                                fontString:SetFont(fontPath, currentSize or 9,
                                                   currentFlags or "")
                            if currentPath then
                                fontString:SetFont(currentPath,
                                                   currentSize or 9,
                                                   currentFlags or "")
                            end

                            return isValid
                        end,
                        set = function(_, value)
                            self.profile.customTheme.font = value
                            -- TODO replace \ with \\

                            addon:RegisterTheme(self.profile.customTheme)

                            if self.profile.enableThemeLiveReload then
                                addon.RenderFrame('themeReload')
                            end
                        end,
                        hidden = function()
                            return self.profile.activeTheme ~= 'Custom'
                        end
                    },
                    customThemeTextColor = {
                        name = L("Text Color"), -- TODO locale
                        desc = L("Requires Reload to take effect"),
                        type = "color",
                        width = optionsWidth,
                        order = 1.8,
                        get = function()
                            return unpack(self.profile.customTheme.textColor)
                        end,
                        set = function(_, r, g, b, a)
                            self.profile.customTheme.textColor = {
                                r, g, b, a or 1
                            }
                            addon:RegisterTheme(self.profile.customTheme)
                            if self.profile.enableThemeLiveReload then
                                addon.RenderFrame('themeReload')
                            end
                        end,
                        hidden = function()
                            return self.profile.activeTheme ~= 'Custom'
                        end
                    },
                    customThemeApply = {
                        name = _G.APPLY,
                        type = 'execute',
                        width = optionsWidth,
                        order = 1.9,
                        confirm = requiresReload,
                        func = function() _G.ReloadUI() end
                    },
                    customThemeReset = {
                        name = _G.RESET,
                        type = 'execute',
                        width = optionsWidth,
                        order = 1.91,
                        func = function()
                            self.profile.customTheme =
                                CopyTable(addon.customThemeBase)
                            addon:RegisterTheme(self.profile.customTheme)
                            if self.profile.enableThemeLiveReload then
                                addon.RenderFrame('themeReload')
                            end
                            AceConfigRegistry:NotifyChange(addon.title)
                        end,
                        hidden = function()
                            return self.profile.activeTheme ~= 'Custom'
                        end
                    },
                    enableThemeLiveReload = {
                        name = L("Preview Changes"),
                        desc = L("Preview theme changes"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.92
                    },
                    previewFramePositions = {
                        name = fmt("%s Frame Positions", _G.PREVIEW),
                        desc = fmt("%s Frame Positions", _G.PREVIEW),
                        type = 'execute',
                        width = optionsWidth,
                        order = 1.93,
                        confirm = function()
                            return L("This action will reload your current guide when toggled off.\nAre you sure?")
                        end,
                        func = function()
                            addon.settings:EnableFramePreviews()
                        end
                    },
                    textColorsHeader = {
                        name = _G.LOCALE_TEXT_LABEL,
                        type = "header",
                        width = "full",
                        order = 2.0
                    },
                    textEnemyColor = {
                        name = _G.COMBATLOG_HIGHLIGHT_KILL,
                        desc = L("Requires Reload to take effect"),
                        type = "color",
                        width = optionsWidth,
                        order = 2.1,
                        get = function()
                            return self:HexToRGB(self.profile.textEnemyColor)
                        end,
                        set = function(_, r, g, b, a)
                            self.profile.textEnemyColor =
                                self:RGBToString(r, g, b, a)
                        end
                    },
                    textFriendlyColor = {
                        name = _G.FRIENDLY,
                        desc = L("Requires Reload to take effect"),
                        type = "color",
                        width = optionsWidth,
                        order = 2.2,
                        get = function()
                            return self:HexToRGB(self.profile.textFriendlyColor)
                        end,
                        set = function(_, r, g, b, a)
                            self.profile.textFriendlyColor = self:RGBToString(r,
                                                                              g,
                                                                              b,
                                                                              a)
                        end
                    },
                    textLootColor = {
                        name = _G.LOOT,
                        desc = L("Requires Reload to take effect"),
                        type = "color",
                        width = optionsWidth,
                        order = 2.3,
                        get = function()
                            return self:HexToRGB(self.profile.textLootColor)
                        end,
                        set = function(_, r, g, b, a)
                            self.profile.textLootColor =
                                self:RGBToString(r, g, b, a)
                        end
                    },
                    textWarnColor = {
                        name = L("Warning"),
                        desc = L("Requires Reload to take effect"),
                        type = "color",
                        width = optionsWidth,
                        order = 2.4,
                        get = function()
                            return self:HexToRGB(self.profile.textWarnColor)
                        end,
                        set = function(_, r, g, b, a)
                            self.profile.textWarnColor =
                                self:RGBToString(r, g, b, a)
                        end
                    },
                    textPickColor = {
                        name = L("Pick Up"),
                        desc = L("Requires Reload to take effect"),
                        type = "color",
                        width = optionsWidth,
                        order = 2.5,
                        get = function()
                            return self:HexToRGB(self.profile.textPickColor)
                        end,
                        set = function(_, r, g, b, a)
                            self.profile.textPickColor =
                                self:RGBToString(r, g, b, a)
                        end
                    },
                    textBuyColor = {
                        name = L("Buy"),
                        desc = L("Requires Reload to take effect"),
                        type = "color",
                        width = optionsWidth,
                        order = 2.6,
                        get = function()
                            return self:HexToRGB(self.profile.textBuyColor)
                        end,
                        set = function(_, r, g, b, a)
                            self.profile.textBuyColor =
                                self:RGBToString(r, g, b, a)
                        end
                    },
                    customTextColorApply = {
                        name = _G.APPLY,
                        type = 'execute',
                        width = optionsWidth,
                        order = 2.9,
                        confirm = requiresReload,
                        func = function() _G.ReloadUI() end -- TODO easier redraw?
                    },
                    customTextColorReset = {
                        name = _G.RESET,
                        type = 'execute',
                        width = optionsWidth,
                        order = 2.91,
                        func = function()
                            self:ResetTextColors()
                        end
                    },
                    disableColorText = {
                        name = L("Disable Colors"),
                        type = 'execute',
                        width = optionsWidth,
                        order = 2.92,
                        func = function()
                            self:DisableTextColors()
                        end
                    },
                    guideWindowHeader = {
                        name = L("Guide Window"),
                        type = "header",
                        width = "full",
                        order = 3.0
                    },
                    windowScale = {
                        name = L("Window Scale"),
                        desc = L(
                            "Scale of the Main Window, use alt+left click on the main window to resize it"),
                        type = "range",
                        width = optionsWidth,
                        order = 3.1,
                        min = 0.2,
                        max = 2,
                        step = 0.05,
                        isPercent = true,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.RXPFrame:SetScale(value)
                        end
                    },
                    guideFontSize = {
                        name = L("Guide Font Size"), -- TODO locale
                        desc = L("Change font size of the Guide Window"),
                        type = "range",
                        width = optionsWidth,
                        order = 3.2,
                        min = 9,
                        max = 18,
                        step = 1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.UpdateGuideFontSize()
                        end
                    },
                    guideScrollSteps = {
                        name = L("Steps Per Mouse-Wheel Scroll"),
                        desc = L("How many visible guide steps one mouse-wheel tick moves through."),
                        type = "range",
                        width = optionsWidth,
                        order = 3.3,
                        min = 1,
                        max = 10,
                        step = 1,
                        set = function(info, value)
                            SetProfileOption(info,
                                math.floor(tonumber(value) or 1))
                        end
                    },
                    guideLanguage = {
                        name = addon.guideLocalization and
                            addon.guideLocalization:UI("Guide Language") or
                            "Guide Language",
                        desc = addon.guideLocalization and
                            addon.guideLocalization:UI(
                                "Translated (client language)") or
                            "Translated (client language)",
                        type = "select",
                        style = "radio",
                        width = optionsWidth,
                        order = 3.35,
                        values = function()
                            local localization = addon.guideLocalization
                            return {
                                localized = localization and localization:UI(
                                    "Translated (client language)") or
                                    "Translated (client language)",
                                english = localization and localization:UI(
                                    "Original English") or "Original English",
                            }
                        end,
                        sorting = {"localized", "english"},
                        get = function()
                            return self.profile.guideLanguage or "localized"
                        end,
                        set = function(_, value)
                            self.profile.guideLanguage = value == "english" and
                                                             "english" or
                                                             "localized"
                            if addon.guideLocalization then
                                addon.guideLocalization:SetMode(
                                    self.profile.guideLanguage)
                            end
                        end,
                    },
                    anchorOrientation = {
                        name = L("Current step frame anchor"),
                        desc = L(
                            "Sets the current step frame to grow from bottom to top or top to bottom"),
                        type = "select",
                        values = {top = L("Top"), bottom = L("Bottom")},
                        sorting = {"top", "bottom"},
                        width = optionsWidth,
                        order = 3.4,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.RXPFrame.SetStepFrameAnchor()
                        end
                    },
                    showStepList = { -- Not actually a direct setting, indirectly frameHeight
                        name = L("Show step list"),
                        desc = L(
                            "Show/Hide the bottom frame listing all the steps of the current guide"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.5,
                        get = function()
                            return addon.RXPFrame.BottomFrame:GetHeight() >= 35
                        end,
                        set = function(_, value)
                            showStepList(value)
                        end
                    },
                    hideCompletedSteps = {
                        name = L("Hide completed steps"),
                        desc = L(
                            "Only shows current and future steps on the step list window"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.6,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.RXPFrame.ScrollFrame.ScrollBar:SetValue(0)
                        end
                    },
                    showUnusedGuides = {
                        name = L("Show unused guides"),
                        desc = L(
                            "Displays guides that are not applicable for your class/race such as starting zones for other races"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 3.7,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.RXPFrame.GenerateMenuTable()
                        end
                    },
                    arrowHeader = {
                        name = L("Waypoint Arrow"), -- TODO locale
                        type = "header",
                        width = "full",
                        order = 3.9
                    },
                    arrowScale = {
                        name = L("Arrow Scale"),
                        desc = L("Scale of the Waypoint Arrow"),
                        type = "range",
                        width = optionsWidth,
                        order = 3.92,
                        min = 0.2,
                        max = 2,
                        step = 0.05,
                        isPercent = true,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.arrowFrame:SetSize(32 * value, 32 * value)
                        end
                    },
                    arrowText = {
                        name = L("Arrow Text Size"),
                        desc = L("Size of the waypoint arrow text"),
                        type = "range",
                        width = optionsWidth,
                        order = 3.93,
                        min = 5,
                        max = 20,
                        step = 1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.arrowFrame.text:SetFont(addon.font, value,
                                                          "OUTLINE")
                        end
                    },
                    resetArrowPosition = {
                        name = L("Reset Arrow Position"), -- TODO locale
                        order = 3.94,
                        type = "execute",
                        width = optionsWidth,
                        func = function()
                            addon.ResetArrowPosition()
                        end
                    },
                    activeItemsHeader = {
                        name = L("Active Items"),
                        type = "header",
                        width = "full",
                        order = 4.0
                    },
                    activeItemsScale = {
                        name = L("Active Item Scale"), -- TODO locale
                        desc = L("Scale of the Active Item frame"),
                        type = "range",
                        width = optionsWidth,
                        order = 4.1,
                        min = 0.8,
                        max = 3,
                        step = 0.05,
                        isPercent = true,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.activeItemFrame:SetScale(value)
                        end
                    },
                    activeItemHideBG = {
                        name = L("Hide Background"),
                        desc = L("Make background transparent"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 4.2,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.activeItemFrame then
                                addon.activeItemFrame:UpdateVisuals()
                            end
                        end
                    },
                    resetItemPosition = {
                        name = L("Reset Window Position"), -- TODO locale
                        order = 4.21,
                        type = "execute",
                        width = optionsWidth,
                        func = function()
                            addon.ResetItemPosition()
                        end
                    },
                    mapHeader = {
                        name = _G.MAP_OPTIONS_TEXT,
                        type = "header",
                        width = "full",
                        order = 5.1
                    },
                    hideMiniMapPins = {
                        name = L("Hide Mini Map Pins"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 5.2,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.UpdateMap()
                        end
                    },
                    mapCircle = {
                        name = L("Highlight active map pins"),
                        desc = L(
                            "Show a targeting circle around active map pins"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 5.3,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.UpdateMap()
                        end
                    },
                    numMapPins = {
                        name = L("Number of Map Pins"),
                        desc = L("Number of map pins shown on the world map"),
                        type = "range",
                        width = optionsWidth,
                        order = 5.4,
                        min = 0,
                        max = 20,
                        step = 1,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.UpdateMap()
                        end
                    },
                    worldMapPinScale = {
                        name = L("Map Pin Scale"),
                        desc = L("Adjusts the size of the world map pins"),
                        type = "range",
                        width = optionsWidth,
                        order = 5.5,
                        min = 0.05,
                        max = 1,
                        step = 0.05,
                        isPercent = true,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.UpdateMap()
                        end
                    },
                    vendorTreasurePinScale = {
                        name = fmt('%s %s', L("Vendor Treasures"),
                                   L("Map Pin Scale")),
                        desc = L("Adjusts the size of the world map pins"),
                        type = "range",
                        width = optionsWidth,
                        order = 5.6,
                        min = 0.05,
                        max = 1,
                        step = 0.05,
                        isPercent = true,
                        hidden = function()
                            return not addon.VendorTreasures
                        end,
                        disabled = function()
                            return not self.profile.enableVendorTreasure
                        end,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if addon.VendorTreasures then
                                addon.VendorTreasures.UpdatePins()
                            end
                            addon.UpdateMap()
                        end
                    },
                    distanceBetweenPins = {
                        name = L("Distance Between Pins"),
                        desc = L(
                            "If two or more steps are very close together, this addon will group them into a single pin on the map. Adjust this range to determine how close together two steps must be to form a group."),
                        type = "range",
                        width = optionsWidth,
                        order = 5.7,
                        min = 0.05,
                        max = 2,
                        step = 0.05,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.UpdateMap()
                        end
                    },
                    worldMapPinBackgroundOpacity = {
                        name = L("Map Pin Background Opacity"),
                        desc = L(
                            "The opacity of the black circles on the map and mini map"),
                        type = "range",
                        width = optionsWidth,
                        order = 5.8,
                        min = 0,
                        max = 1,
                        step = 0.05,
                        isPercent = true,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            addon.UpdateMap()
                        end
                    }
                }
            },
            advancedSettings = {
                type = "group",
                name = L("Advanced Settings"),
                order = 20,
                args = {
                    enableBetaFeatures = {
                        name = L("Enable Beta Features"),
                        desc = function ()
                            return listBetaFeatures(L("Enables new features, forces reload to take effect"))
                        end,
                        type = "toggle",
                        width = optionsWidth,
                        order = 1,
                        confirm = requiresReload,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            _G.ReloadUI()
                        end
                    },
                    debug = {
                        name = L("Enable Debug"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.1
                    },
                    luaErrors = {
                        name = tostring(_G.SHOW_LUA_ERRORS or
                                            L("Show Lua Errors") or
                                            "Show Lua Errors"),
                        desc = L("Toggles the stock client display of Lua errors."),
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.2,
                        hidden = type(_G.SetCVar) ~= "function" or
                                     (type(_G.GetCVarBool) ~= "function" and
                                         type(_G.GetCVar) ~= "function"),
                        get = function()
                            if type(_G.GetCVarBool) == "function" then
                                local ok, value = pcall(_G.GetCVarBool,
                                                        "scriptErrors")
                                if ok then return value and true or false end
                            end
                            if type(_G.GetCVar) == "function" then
                                local ok, value = pcall(_G.GetCVar,
                                                        "scriptErrors")
                                if ok then return tostring(value) == "1" end
                            end
                            return false
                        end,
                        set = function(_, value)
                            if type(_G.SetCVar) == "function" then
                                pcall(_G.SetCVar, "scriptErrors",
                                      value and "1" or "0")
                            end
                        end
                    },
                    enableHSbatch = {
                        name = L("Hearthstone batching"),
                        desc = L(
                            "Enables the automation of the innkeeper prompt, where you can set your home location in the same server tick you're teleporting away"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.4,
                        hidden = addon.gameVersion > 50000,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if not value and addon.StopHearthBatching then
                                addon.StopHearthBatching()
                            end
                        end
                    },
                    batchSize = {
                        name = L("Batching window size (ms)"),
                        desc = L(
                            "Adjusts the batching window tolerance, used for hearthstone batching. Increase this value if you're experiencing framerate drops when using your Hearthstone"),
                        type = "range",
                        width = optionsWidth,
                        order = 1.5,
                        min = 1,
                        max = 50,
                        step = 0.500001,
                        hidden = addon.gameVersion > 50000,
                        disabled = function()
                            return not addon.settings.profile.enableHSbatch
                        end
                    },
                    updateFrequency = {
                        name = L("Update Frequency (ms)"),
                        desc = L(
                            "Defines how often the addon updates in milliseconds, increase this if you're having performance issues"),
                        type = "range",
                        width = optionsWidth,
                        order = 1.6,
                        min = 5,
                        max = 150,
                        step = 5,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if updateFrequencyTimer and
                                updateFrequencyTimer.Cancel then
                                updateFrequencyTimer:Cancel()
                            end
                            updateFrequencyTimer = C_Timer.NewTimer(0.125,
                                function()
                                    updateFrequencyTimer = nil
                                    if addon.tickers and
                                        addon.tickers.RestartTickerLoops then
                                        addon.tickers:RestartTickerLoops()
                                    end
                                    if addon.targeting and
                                        addon.targeting.RefreshScanTicker then
                                        addon.targeting:RefreshScanTicker()
                                    end
                            end)
                        end
                    },
                    performanceInspector = {
                        name = L("Open Performance Inspector"),
                        desc = L("Measures bounded RXPGuides work and exports a sanitized report."),
                        type = "execute",
                        width = optionsWidth,
                        order = 1.61,
                        hidden = addon.gameVersion ~= 30300,
                        func = function()
                            if addon.performanceInspector then
                                addon.performanceInspector:Toggle()
                            end
                        end
                    },
                    enableAdaptivePerformance = {
                        name = L("Adaptive performance throttling"),
                        desc = L("Opt in to temporary RXP-only scan/update slowing after sustained low FPS. Saved preferences are not changed and normal rates return automatically."),
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.62,
                        hidden = addon.gameVersion ~= 30300,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if not value and addon.performanceInspector then
                                addon.performanceInspector:SetAdapted(false,
                                    "adaptation disabled")
                            end
                        end
                    },
                    adaptivePerformanceFPSThreshold = {
                        name = L("Adaptive FPS threshold"),
                        desc = L("Temporary adaptation begins only after FPS remains below this value for five samples."),
                        type = "range",
                        width = optionsWidth,
                        order = 1.63,
                        min = 15,
                        max = 60,
                        step = 1,
                        hidden = addon.gameVersion ~= 30300,
                        disabled = function()
                            return not self.profile.enableAdaptivePerformance
                        end
                    },
                    preLoadData = {
                        name = L("Pre load all data"),
                        desc = L(
                            "Loads all addon data upfront, instead of loading the data slowly over time. This increases loading screen times, only enable this option if you are experiencing frame rate drops"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 1.65,
                        confirm = requiresReload,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            _G.ReloadUI()
                        end,
                    },
                    enableAddonIncompatibilityCheck = {
                        name = L("Check for Addon Incompatibility"), -- TODO locale
                        desc = L("Check loaded addons for known compatibility issues with RXP"),
                        type = "toggle",
                        width = "full",
                        order = 1.66,
                        set = function(info, value)
                            SetProfileOption(info, value)
                            if value then
                                self:CheckAddonCompatibility()
                            end
                        end
                    },
                    optimizePerformance = {
                        name = fmt("%s %s %s", _G.LOW, _G.QUALITY, _G.SETTINGS),
                        desc = L("Temporarily disables supplemental features and uses slower update settings. Turning this off restores your previous configuration."),
                        order = 1.3,
                        type = "toggle", -- type = "execute",
                        width = optionsWidth,
                        confirm = requiresReload,
                        get = function()
                            local p = self.profile
                            return type(p.performancePresetBackup) == "table" or
                                not (p.enableTargetAutomation or p.enableTips or
                                    p.enableTracker or p.checkVersions or
                                    p.enableLevelUpAnnounceSolo or
                                    p.enableLevelUpAnnounceGroup or
                                    p.enableFlyStepAnnouncements or
                                    p.alwaysSendBranded or p.checkVersions or
                                    p.enableLevelingReportInspections or
                                    p.enableVendorTreasure or
                                    p.enableItemUpgrades or
                                    p.enableItemUpgradesAH or
                                    p.hideCompletedSteps or
                                    p.showUnusedGuides or
                                    not p.preLoadData or
                                    p.updateFrequency < 150)
                                    --or addon.RXPFrame.BottomFrame:GetHeight() < 35
                        end,
                        set = function(_, value)
                            local p = self.profile
                            local keys = {
                                "enableTargetAutomation", "enableTips",
                                "enableTracker", "checkVersions",
                                "enableLevelUpAnnounceSolo",
                                "enableLevelUpAnnounceGroup",
                                "enableFlyStepAnnouncements",
                                "alwaysSendBranded",
                                "enableLevelingReportInspections",
                                "enableVendorTreasure", "enableItemUpgrades",
                                "enableItemUpgradesAH", "hideCompletedSteps",
                                "showUnusedGuides", "preLoadData",
                                "updateFrequency", "frameHeight"
                            }
                            if value then
                                if type(p.performancePresetBackup) ~= "table" then
                                    p.performancePresetBackup =
                                        CaptureProfileOptions(p, keys)
                                    p.performancePresetBackup.frameHeight =
                                        addon.RXPFrame:GetHeight()
                                end
                                p.enableTargetAutomation = false
                                p.enableTips = false
                                p.enableTracker = false
                                p.checkVersions = false
                                p.enableLevelUpAnnounceSolo = false
                                p.enableLevelUpAnnounceGroup = false
                                p.enableFlyStepAnnouncements = false
                                p.alwaysSendBranded = false
                                p.enableLevelingReportInspections = false
                                p.enableVendorTreasure = false
                                p.enableItemUpgrades = false
                                p.enableItemUpgradesAH = false
                                p.hideCompletedSteps = false
                                p.showUnusedGuides = false
                                p.updateFrequency = 150
                                p.preLoadData = true
                                showStepList(false)
                            else
                                local snapshot = p.performancePresetBackup
                                if type(snapshot) ~= "table" then
                                    snapshot = CaptureProfileOptions(
                                        settingsDBDefaults.profile, keys)
                                    snapshot.frameHeight = addon.height
                                end
                                RestoreProfileOptions(p, snapshot)
                                p.performancePresetBackup = nil
                            end

                            _G.ReloadUI()
                        end
                    },
                    skipMissingPreReqs = {
                        name = L("Skip quests with missing pre-requisites"),
                        desc = L(
                            "Automatically skip quest tasks whose required quests were not completed"),
                        type = "toggle",
                        width = optionsWidth,
                        order = 10
                    }
                }
            }
        }
    }

    -- Build FAQ items
    local helpBatch = 2
    for q, a in pairs(addon.help) do
        optionsTable.args.helpPanel.args[helpBatch .. "q"] = {
            order = helpBatch + 0.1,
            name = q,
            type = "header",
            width = "full"
        }

        optionsTable.args.helpPanel.args[helpBatch .. "a"] = {
            order = helpBatch + 0.2,
            name = a,
            type = "description",
            width = "full",
            fontSize = "medium"
        }
        helpBatch = helpBatch + 1
    end

    for title, data in pairs(addon.compatibility) do
        optionsTable.args.helpPanel.args[helpBatch .. "a"] = {
            order = helpBatch + 0.1,
            name = title,
            type = "header",
            width = "full",
            hidden = function() return not incompatibleAddons[title] end
        }

        optionsTable.args.helpPanel.args[helpBatch .. "d"] = {
            order = helpBatch + 0.2,
            name = fmt("%s %s\n\n%s", title, data.Reason, data.Recommendation),
            type = "description",
            width = "full",
            fontSize = "medium",
            hidden = function() return not incompatibleAddons[title] end
        }
        helpBatch = helpBatch + 1
    end

    addon.settings.routingOptions = {}
    for entry in pairs(optionsTable.args.guideRoutingSettings.args) do
        table.insert(addon.settings.routingOptions, entry)
    end

    NormalizeLegacyAceConfigOptions(optionsTable)
    AceConfig:RegisterOptionsTable(addon.title, optionsTable)

    optionsTable.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(
                                     settingsDB)
    optionsTable.args.profiles.order = 20

    -- Add in reload prompt to Ace default pane
    optionsTable.args.profiles.args["reloadUI"] = {
        order = 0,
        name = L("Reload guides and UI"),
        type = 'execute',
        func = function() _G.ReloadUI() end,
        disabled = function()
            return loadedProfileKey == settingsDB.keys.profile and not settingsDB.isResetting
        end
    }

    optionsTable.args.profiles.args.defaultProfileHeader = {
        name = "",
        type = "header",
        width = "full",
        order = 900
    }

    optionsTable.args.profiles.args["setDefaultProfile"] = {
        order = 910,
        name = L("Set current profile as default"),
        type = 'execute',
        width = 1.5,
        func = function()
            addon.settings.defaultProfileKey = settingsDB:GetCurrentProfile()
            local function copy(t)
                local out = {}
                for i,v in pairs(t) do
                    if type(v) == "table" then
                        out[i] = copy(v)
                    else
                        out[i] = v
                    end
                end
                return out
            end
            RXPData.defaultProfile = {profile = copy(addon.settings.profile)}
        end,
        disabled = function()
            return addon.settings.defaultProfileKey == settingsDB:GetCurrentProfile()
        end
    }

    -- AceDBOptions is attached after the root table is registered. Normalize
    -- that late subtree as well before AceConfigDialog validates it on open.
    NormalizeLegacyAceConfigOptions(optionsTable.args.profiles)

    addon.RXPOptions = self.AddToBlizzardOptions(addon.title)

    -- Ace3 ConfigDialog doesn't support embedding icons in header
    -- Directly references Ace3 built frame object
    -- Hackery ahead

    local f = addon.RXPOptions.obj.frame
    f.icon = f:CreateTexture()
    -- Theme load order, leave default settings branding unthemed
    f.icon:SetTexture("Interface/AddOns/" .. addonName ..
                          "/Textures/rxp_logo-64")
    f.icon:SetPoint("TOPRIGHT", -5, -5)

end

local function buildMinimapMenu()
    local menu = {}
    addon.RXPFrame:GenerateMenuTable(menu)

    table.insert(menu, #menu, {
        text = addon.settings.profile.showEnabled and _G.HIDE or _G.SHOW,
        notCheckable = 1,
        func = addon.settings.ToggleActive
    })

    return menu
end

function addon.settings:UpdateMinimapButton()
    if not addon.settings.minimapFrame then
        addon.settings.minimapFrame = CreateFrame("Frame", "RXP_MMMenuFrame",
                                                  UIParent,
                                                  "UIDropDownMenuTemplate")
    end

    if not self.minimapButton then
        self.minimapButton = LibDataBroker:NewDataObject(addonName, {
            type = "data source",
            label = addonName,
            icon = addon.GetTexture("rxp_logo-64"),
            tocname = addonName,
            OnClick = function(_, button)
                if button == "RightButton" then
                    EasyMenu(buildMinimapMenu(), addon.settings.minimapFrame,
                             "cursor", 0, 0, "MENU")
                else
                    addon.settings.ToggleActive()
                end
            end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine(addon.title)
                tooltip:AddLine("|cff909090Left Click: |cffffcc00Toggle Guide|r")
                tooltip:AddLine("|cff909090Right Click: |cffffcc00Show Menu|r")
            end
        })
    end

    self.profile.minimap.hide = not self.profile.enableMinimapButton
    if not LibDBIcon:IsRegistered(addonName) then
        LibDBIcon:Register(addonName, self.minimapButton, self.profile.minimap)
    end
    if self.profile.enableMinimapButton then
        LibDBIcon:Show(addonName)
    else
        LibDBIcon:Hide(addonName)
    end
end

function addon.settings.ToggleActive()
    addon.settings.profile.showEnabled = not addon.settings.profile.showEnabled

    for _, frame in pairs(addon.enabledFrames) do
        local shown, isSecure = frame.IsFeatureEnabled()
        if not (isSecure and InCombatLockdown()) and shown then
            frame:SetShown(addon.settings.profile.showEnabled)
        end
    end

end

local function CheckBuff(buffId)
    local UnitBuff = _G.UnitBuff or addon.UnitBuff
    local id = 0
    local i = 1
    while id do
        id = select(10, UnitBuff("player", i))
        if id == buffId then return true end
        i = i + 1
    end
end

local ITEM_RANGE = ITEM_LEVEL_RANGE_CURRENT:gsub("([%(%)])","%%%1")
ITEM_RANGE = ITEM_RANGE:gsub("%%d","%(%%d+%)")
local XPTEXT = strlower(POWER_TYPE_EXPERIENCE)

addon.settings.heirloomSlots = {}
local tooltipTimer = 0
local playerLevelCheck = 0

function addon.GetXPBonuses(ignoreBuffs,playerLevel)
    local calculatedRate = not ignoreBuffs and CheckBuff(377749) and 1.5 or 1.0 -- Joyous Journeys

    local GetInventoryItemLink = GetInventoryItemLink

    --Fast track guild perk
    if addon.IsPlayerSpell(78632) then
        calculatedRate = calculatedRate + 0.1
    end

    if addon.game == "MOP" and UnitLevel('player') >= 85 then
        --5.4 xp rates
        calculatedRate = calculatedRate + 0.55
    end

    if addon.game == "RETAIL" then
        local cloakBonus = C_CurrencyInfo.GetCurrencyInfo(3001).quantity
        local warModeBonus = (C_PvP.IsWarModeActive() or CheckBuff(282559) or CheckBuff(269083) or CheckBuff(289954)) and C_PvP.GetWarModeRewardBonus() or 0
        local warbandBuff = C_UnitAuras.GetPlayerAuraBySpellID(430191)
        --1,2: xp buff, 3: max level
        local warbandBonus = warbandBuff and warbandBuff.points[1] or 0
        local legionRemix = C_UnitAuras.GetPlayerAuraBySpellID(1232454)
        legionRemix = legionRemix and legionRemix.points[10] or 0
        calculatedRate = calculatedRate + (cloakBonus + warModeBonus + warbandBonus + legionRemix)/100
        return calculatedRate
    elseif addon.game == "WOTLK" then
        local itemQuality
        local itemLink = GetInventoryItemLink("player", 3) -- Shoulder

        if itemLink then
            itemQuality = select(3, GetItemInfo(itemLink))

            if itemQuality == INV_HEIRLOOM then
                calculatedRate = calculatedRate + 0.1

                addon.comms.PrettyDebug("Heirloom detected in Shoulder slot")
            end
        end

        itemLink = GetInventoryItemLink("player", 5) -- Chest

        if itemLink then
            itemQuality = select(3, GetItemInfo(itemLink))

            if itemQuality == INV_HEIRLOOM then
                calculatedRate = calculatedRate + 0.1

                addon.comms.PrettyDebug("Heirloom detected in Chest slot")
            end
        end
    else
        --Parses tooltips to figure out heirloom xp bonuses
        local tooltipShown
        local heirloomSlots = {}
        local lastScan = addon.settings.heirloomSlots
        for i = 1, _G.INVSLOT_LAST_EQUIPPED do
            local itemLink = GetInventoryItemLink("player", i)
            local itemQuality
            if itemLink then
                itemQuality = select(3, GetItemInfo(itemLink))
            end
            if itemQuality == INV_HEIRLOOM then
                heirloomSlots[i] = 0
            end
        end
        --Disable trinket parsing:
        heirloomSlots[13] = nil
        heirloomSlots[14] = nil
        local currentLevel = UnitLevel('player')
        local t = GetTime()
        for i in pairs(heirloomSlots) do
            if (not lastScan[i] or t - tooltipTimer > 30 or playerLevelCheck ~=  currentLevel) then
                --print(i)
                GameTooltip:SetOwner(addon.RXPFrame, "ANCHOR_RIGHT")
                tooltipShown = true
                local minilvl,maxilvl
                GameTooltip:SetInventoryItem("player",i)
                for n = 2,GameTooltip:NumLines() do
                    local text = getglobal("GameTooltipTextLeft"..n):GetText() or ""
                    --print(text)
                    if not (minilvl and maxilvl) then
                        local tminlvl,tmaxlvl = text:match(ITEM_RANGE)
                        minilvl = tonumber(tminlvl)
                        maxilvl = tonumber(tmaxlvl)
                    else
                        local lower = strlower(text)
                        local xp = lower:match("(%d%d?)%%")
                        if xp and lower:find(XPTEXT) then
                            xp = tonumber(xp)/100
                            if maxilvl > (playerLevel or currentLevel) then
                                heirloomSlots[i] = xp
                                calculatedRate = calculatedRate + xp
                            end
                            break
                        end
                    end
                end
            else
                calculatedRate = calculatedRate + (lastScan[i] or 0)
            end
        end
        playerLevelCheck = playerLevel
        addon.settings.heirloomSlots = heirloomSlots
        if tooltipShown then
            tooltipTimer = t
            GameTooltip:Hide()
        end
    end
    return calculatedRate
end

function addon.settings:DetectXPRate(softUpdate)
    if not addon.settings.profile.enableAutomaticXpRate then
        return
    elseif addon.gameVersion < 20000 then
        local season = addon.GetSeason() or CheckBuff(362859) and 1

        --Anniversary realms
        local realm = C_Seasons and C_Seasons.HasActiveSeason() and C_Seasons.GetActiveSeason() or 0
        if realm == 11 or realm == 12 then
            addon.settings.profile.phase = 1
        else
            addon.settings.profile.phase = 6
        end
        if season == addon.settings.profile.season then return end


        addon.settings.profile.season = season

        if addon.currentGuide and addon.currentGuide.name then
            addon:LoadGuide(addon.currentGuide, 'onLoad')
        else
            addon.ReloadGuide()
        end

        addon.RXPFrame.GenerateMenuTable()

        return
    end

    local calculatedRate = addon.GetXPBonuses()
    addon:ScheduleTask(addon.RXPFrame.GenerateMenuTable)

    -- Bypass floating point comparison issues
    local increment = "%.2f"
    if addon.game == "RETAIL" then
        increment = "%.1f"
    end

    if fmt(increment, addon.settings.profile.xprate) == fmt(increment, calculatedRate) then
        return
    end

    addon.settings.profile.xprate = calculatedRate
    if addon.xpAssistant then
        addon.xpAssistant:ResetCalibration(false, true)
    end

    -- Gold assistant, ignore reloads, silently update
    if (RXPCData and RXPCData.GA) or (addon.guide and addon.guide.farm) or softUpdate then
        return
    end

    addon.comms.PrettyPrint(L(
                                "Experience rate change detected, reloading guide for %.2fx"),
                            calculatedRate)

    if addon.currentGuide and addon.currentGuide.name then
        addon:LoadGuide(addon.currentGuide, 'onLoad')
    else
        addon.ReloadGuide()
    end
end

function addon.settings:RefreshProfile()
    -- Save Frame positions to previous profile before swapping to new
    addon.settings:SaveFramePositions()

    self.profile = settingsDB.profile
    self.profile.soundOnFind = self:NormalizeTargetingSound(
                                   self.profile.soundOnFind)
    NormalizeCustomThemeTooltip(self.profile)
    addon.settings.defaultProfileKey = false

    if loadedProfileKey ~= settingsDB.keys.profile then
        addon.comms.PrettyPrint(L(
                                    "Profile changed, Reload UI for settings to take effect"))
    end

    if addon.currentGuide and addon.currentGuide.name then
        addon:LoadGuide(addon.currentGuide)
    else
        addon.ReloadGuide()
    end
    addon.UpdateMap()
    addon.RXPFrame.GenerateMenuTable()
    addon.RXPFrame.SetStepFrameAnchor()

    -- Restore frame positions on profile change
    addon.settings:LoadFramePositions()
    if addon.toolWindows then addon.toolWindows:RestoreAll() end
    if addon.xpAssistant then addon.xpAssistant:ApplySettings() end
    if addon.speedrun then addon.speedrun:ApplySuiteSettings() end
end

function addon.settings:CopyProfile()
    self.profile.soundOnFind = self:NormalizeTargetingSound(
                                   self.profile.soundOnFind)
    NormalizeCustomThemeTooltip(self.profile)
    addon.comms.PrettyPrint(L(
                                "Profile changed, Reload UI for settings to take effect"))

    if addon.currentGuide and addon.currentGuide.name then
        addon:LoadGuide(addon.currentGuide)
    else
        addon.ReloadGuide()
    end
    addon.UpdateMap()
    addon.RXPFrame.GenerateMenuTable()
    addon.RXPFrame.SetStepFrameAnchor()

    -- Restore frame positions on profile change
    addon.settings:LoadFramePositions()
    if addon.toolWindows then addon.toolWindows:RestoreAll() end
    if addon.xpAssistant then addon.xpAssistant:ApplySettings() end
    if addon.speedrun then addon.speedrun:ApplySuiteSettings() end
end

function addon.settings:ResetProfile()
    settingsDB.isResetting = true
    addon.comms.PrettyPrint(L(
                                "Profile changed, Reload UI for settings to take effect"))

    --resets to the actual defaults, in case the profile is bricked or frames are offscreen
    settingsDBDefaults.profile.framePositions = {
        arrowFrame = {{"TOP","UIParent","TOP",0,0}},
        RXPFrame = {{"LEFT",nil,"LEFT",0,35}},
        activeItemFrame = {{"CENTER","UIParent","CENTER",0,0}},
        activeTargetFrame = {{"CENTER","UIParent","CENTER",0,-50}},
        tipsFrame = {{"CENTER","UIParent","CENTER",0,-145}}
    }
    settingsDBDefaults.profile.frameSizes = {}
    settingsDBDefaults.profile.minimap.minimapPos = 146
    settingsDB.defaults.profile = settingsDBDefaults.profile
    settingsDB:ResetProfile(false, true)
end

function addon.settings:CheckAddonCompatibility()
    if not addon.compatibility or
        not self.profile.enableAddonIncompatibilityCheck then return end

    local a, name

    for i = 1, GetNumAddOns() do
        if IsAddOnLoaded(i) then
            name = GetAddOnInfo(i)

            if addon.compatibility[name] then
                incompatibleAddons[name] = true
                a = addon.compatibility[name]
                addon.comms.PrettyPrint("%s %s %s", name, a.Reason,
                                        a.Recommendation)
            end
        end
    end
end

-- https://wowwiki-archive.fandom.com/wiki/USERAPI_RGBToHex
function addon.settings:RGBToString(r, g, b, a)
    a = a or 1

    return string.format("%02x%02x%02x%02x", a * 255, r * 255, g * 255, b * 255)
end

-- https://wowwiki-archive.fandom.com/wiki/USERAPI_HexToRGB
function addon.settings:HexToRGB(hexString)
    if not hexString then
        return unpack(addon.activeTheme.textColor) -- , 1
    end

    local ahex, rhex, ghex, bhex = hexString:sub(1, 2), hexString:sub(3, 4),
                                   hexString:sub(5, 6), hexString:sub(7, 8)

    if ahex and rhex and ghex and bhex then
        return tonumber(rhex, 16) / 255, tonumber(ghex, 16) / 255,
               tonumber(bhex, 16) / 255 -- , tonumber(ahex or 1, 16) / 255
    else
        return unpack(addon.activeTheme.textColor) -- , 1
    end
end

function addon.settings:LoadTextColors()
    local gtc = addon.guideTextColors
    local p = self.profile
    gtc["RXP_FRIENDLY_"] = p.textFriendlyColor
    gtc["RXP_ENEMY_"] = p.textEnemyColor
    gtc["RXP_LOOT_"] = p.textLootColor
    gtc["RXP_WARN_"] = p.textWarnColor
    gtc["RXP_PICK_"] = p.textPickColor
    gtc["RXP_BUY_"] = p.textBuyColor

    -- Setup reverse lookup
    gtc[gtc.default["RXP_FRIENDLY_"]] = p.textFriendlyColor
    gtc[gtc.default['RXP_ENEMY_']] = p.textEnemyColor
    gtc[gtc.default["RXP_LOOT_"]] = p.textLootColor
    gtc[gtc.default["RXP_WARN_"]] = p.textWarnColor
    gtc[gtc.default["RXP_PICK_"]] = p.textPickColor
    gtc[gtc.default["RXP_BUY_"]] = p.textBuyColor

    -- TODO default to theme, but load order
    -- self:RGBToString(unpack(addon.activeTheme.textColor))
    gtc.default["error"] = {1, 1, 1}
end

function addon.settings:ResetTextColors()
    self.profile.textEnemyColor = addon.guideTextColors.default['RXP_ENEMY_']
    self.profile.textFriendlyColor =
        addon.guideTextColors.default['RXP_FRIENDLY_']
    self.profile.textLootColor = addon.guideTextColors.default['RXP_LOOT_']
    self.profile.textWarnColor = addon.guideTextColors.default['RXP_WARN_']
    self.profile.textPickColor = addon.guideTextColors.default['RXP_PICK_']
    self.profile.textBuyColor = addon.guideTextColors.default['RXP_BUY_']
    self:LoadTextColors()
    addon.RenderFrame()
    addon.UpdateMap()
    AceConfigRegistry:NotifyChange(addon.title)
end

function addon.settings:DisableTextColors()
    local default = self:RGBToString(unpack(addon.activeTheme.textColor))

    self.profile.textEnemyColor = default
    self.profile.textFriendlyColor = default
    self.profile.textLootColor = default
    self.profile.textWarnColor = default
    self.profile.textPickColor = default
    self.profile.textBuyColor = default
    self:LoadTextColors()
    addon.RenderFrame()
    addon.UpdateMap()
    AceConfigRegistry:NotifyChange(addon.title)
end

function addon.settings.ReplaceColors(element)
    -- Replace text placeholders
    local function replace(textLine)
        if type(textLine) ~= "string" then return textLine end
        for RXP_ in string.gmatch(textLine, "RXP_[A-Z]+_") do
            local prefix = addon.accessibility and
                               addon.accessibility:GetTokenPrefix(RXP_) or ""
            textLine = textLine:gsub(RXP_,
                (addon.guideTextColors[RXP_] or
                    addon.guideTextColors.default["error"]) .. prefix)
        end

        -- Replace raw hex values
        for hex in string.gmatch(textLine, "|c(%x%x%x%x%x%x%x%x)") do
            textLine = textLine:gsub(hex, addon.guideTextColors[hex] or
                                         addon.guideTextColors.default["error"])
        end

        textLine = textLine:gsub("\\n","\n")
        return textLine
    end

    local fieldString
    if type(element) == "table" or element and element.textReplaced then
        element.textReplaced = element.textReplaced or {}
        for i, field in pairs({"text", "rawtext", "tooltipText", "mapTooltip","title","arrowtext"}) do
            if element.textReplaced[i] then
                element[field] = replace(element.textReplaced[i])
            else
                fieldString = element[field]
                element.textReplaced[i] = fieldString
                element[field] = replace(fieldString)
            end
        end
    else
        return replace(element)
    end

end

local function buildWorldMapMenu()
    local menu = {}

    if addon.VendorTreasures then
        tinsert(menu, {
            text = fmt('%s %s', _G.ENABLE, L("Vendor Treasures")),
            tooltipTitle = L("Enable embedded Cpt. Stadics' Vendor Treasures"),
            icon = "Interface/GossipFrame/VendorGossipIcon.blp",
            arg1 = "toggle",
            checked = function()
                return addon.settings.profile.enableVendorTreasure
            end,
            func = function()
                addon.settings.profile.enableVendorTreasure = not addon.settings
                                                                  .profile
                                                                  .enableVendorTreasure

                addon.VendorTreasures:Setup()
                addon.VendorTreasures.UpdatePins()
            end
        })
    end

    -- Only add padding if specific features added already
    if next(menu) ~= nil then
        tinsert(menu, {text = "", notCheckable = 1, isTitle = 1})
    end

    tinsert(menu, {
        text = _G.GAMEOPTIONS_MENU .. "...",
        notCheckable = 1,
        func = function() addon.settings.OpenSettings() end
    })

    tinsert(menu, {
        text = L("Open Feedback Form"),
        notCheckable = 1,
        func = function() addon.comms.OpenBugReport() end
    })

    tinsert(menu, {
        text = addon.settings.profile.showEnabled and _G.HIDE or _G.SHOW,
        notCheckable = 1,
        func = addon.settings.ToggleActive
    })

    tinsert(menu, {
        text = _G.CLOSE,
        notCheckable = 1,
        func = function(self) self:Hide() end
    })

    return menu
end

local function CreateLegacyWorldMapMenu(owner)
    local frame = CreateFrame("Frame", "RXP_WMLegacyMenuFrame",
                              _G.WorldMapFrame,
                              BackdropTemplateMixin and "BackdropTemplate" or nil)
    frame:SetWidth(238)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(100)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    frame:SetBackdropColor(0, 0, 0, 0.96)
    frame:ClearAllPoints()
    frame:SetPoint("TOPRIGHT", owner, "BOTTOMRIGHT", 0, -3)
    frame.rows = {}
    frame:Hide()
    _G.WorldMapFrame:HookScript("OnHide", function() frame:Hide() end)

    function frame:Refresh()
        local entries = buildWorldMapMenu()
        local rowIndex = 0
        local topOffset = -7

        for _, entry in ipairs(entries) do
            if entry.text and entry.text ~= "" then
                rowIndex = rowIndex + 1
                local row = self.rows[rowIndex]
                if not row then
                    row = CreateFrame("Button", nil, self)
                    row:SetHeight(22)
                    row:RegisterForClicks("LeftButtonUp")
                    row.text = row:CreateFontString(nil, "OVERLAY",
                                                    "GameFontHighlightSmall")
                    row.text:SetPoint("LEFT", row, "LEFT", 5, 0)
                    row.text:SetJustifyH("LEFT")
                    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
                    highlight:SetAllPoints(true)
                    highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
                    highlight:SetBlendMode("ADD")
                    row:SetHighlightTexture(highlight)
                    row:SetScript("OnClick", function(button)
                        local data = button.entry
                        if not data then return end
                        if data.text == _G.CLOSE then
                            frame:Hide()
                            return
                        end
                        if type(data.func) == "function" then
                            data.func(button, data.arg1, data.arg2,
                                      type(data.checked) == "function" and
                                          data.checked() or data.checked)
                        end
                        if frame:IsShown() then frame:Refresh() end
                    end)
                    self.rows[rowIndex] = row
                end

                row.entry = entry
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", self, "TOPLEFT", 7, topOffset)
                row:SetPoint("TOPRIGHT", self, "TOPRIGHT", -7, topOffset)

                local prefix = ""
                local checked = type(entry.checked) == "function" and
                                    entry.checked() or entry.checked
                if checked then
                    prefix = "|TInterface\\Buttons\\UI-CheckBox-Check:14:14|t "
                elseif entry.checked ~= nil then
                    prefix = "   "
                end
                if entry.icon then
                    prefix = prefix .. "|T" .. entry.icon .. ":14:14|t "
                end
                row.text:SetText(prefix .. entry.text)
                row:Show()
                topOffset = topOffset - 22
            elseif entry.isTitle then
                topOffset = topOffset - 5
            end
        end

        for index = rowIndex + 1, #self.rows do
            self.rows[index]:Hide()
            self.rows[index].entry = nil
        end
        self:SetHeight(-topOffset + 7)
    end

    return frame
end

function addon.settings:SetupMapButton()
    if addon.game ~= "CLASSIC" and addon.gameVersion ~= 30300 then return end

    if self.profile.enableWorldMapButton then
        if self.worldMapButton then
            self.worldMapButton:Show()
            return
        end
    else
        if self.worldMapButton then self.worldMapButton:Hide() end
        return
    end

    if self.worldMapButton then return end

    self.worldMapButton = CreateFrame("Button", "RXP_WMMenuFrame",
                                      _G.WorldMapFrame)

    self.worldMapButton:SetSize(36, 36)
    self.worldMapButton:SetNormalTexture(addon.GetTexture("rxp_logo-64"))
    self.worldMapButton:SetHighlightTexture(
        "Interface/MINIMAP/UI-Minimap-ZoomButton-Highlight", "ADD")

    if addon.gameVersion == 30300 then
        self.worldMapButton.menuFrame = CreateLegacyWorldMapMenu(
                                            self.worldMapButton)
    else
        self.worldMapButton.menuFrame = CreateFrame(
                                            "Frame",
                                            "RXP_WMMenuFrame_MenuFrame",
                                            self.worldMapButton,
                                            "UIDropDownMenuTemplate")
    end
    self.worldMapButton:SetScript("OnClick", function(button)
        if addon.gameVersion == 30300 then
            local menuFrame = button.menuFrame
            if menuFrame:IsShown() then
                menuFrame:Hide()
            else
                menuFrame:Refresh()
                menuFrame:Show()
            end
        else
            EasyMenu(buildWorldMapMenu(), button.menuFrame, button, 0, 0,
                     "MENU")
        end
    end)

    if addon.gameVersion == 30300 then
        self.worldMapButton:RegisterForClicks("LeftButtonUp")
        if self.worldMapButton.SetToplevel then
            self.worldMapButton:SetToplevel(true)
        end
    end

    local ref = WorldMapFrame.MaximizeMinimizeFrame and WorldMapFrame.MaximizeMinimizeFrame.MaximizeButton

    local function recalculateMapButton()
        if addon.gameVersion == 30300 then
            -- WorldMapFrame fills the entire screen on 3.3.5, so anchoring to
            -- its top-right corner puts this button underneath the minimap.
            -- WorldMapDetailFrame is the actual bordered 1002x668 map surface.
            local mapBorder = _G.WorldMapDetailFrame or _G.WorldMapButton or
                                  _G.WorldMapFrame
            self.worldMapButton:ClearAllPoints()
            self.worldMapButton:SetSize(28, 28)
            self.worldMapButton:SetPoint("TOPRIGHT", mapBorder, "TOPRIGHT", -6,
                                         -42)
            self.worldMapButton:SetFrameStrata(_G.WorldMapFrame:GetFrameStrata())
            local mapLevel = _G.WorldMapButton and
                                 _G.WorldMapButton:GetFrameLevel() or
                                 mapBorder:GetFrameLevel()
            self.worldMapButton:SetFrameLevel((mapLevel or 0) + 10)
        elseif WorldMapFrame.isMaximized then
            self.worldMapButton:ClearAllPoints()
            self.worldMapButton:SetSize(36, 36)
            self.worldMapButton:SetPoint("TOPRIGHT", _G.WorldMapFrame,
                                         "TOPRIGHT", -10, -26)
        else
            self.worldMapButton:ClearAllPoints()
            self.worldMapButton:SetSize(20, 20)
            self.worldMapButton:SetPoint("TOPRIGHT", ref or _G.WorldMapFrameCloseButton, "TOPLEFT", 0, -5.5)
        end
    end

    self.worldMapButton:SetScript("OnShow", recalculateMapButton)
    recalculateMapButton()
    if ref then
        hooksecurefunc(ref, "Show", recalculateMapButton)
        hooksecurefunc(WorldMapFrame.MaximizeMinimizeFrame.MinimizeButton, "Show",
                    recalculateMapButton)
    end

end

function addon.settings:EnableFramePreviews()

    local currentGuide = addon.currentGuide

    -- Prevent overwriting actual guide if activating multiple times
    if currentGuide.name == fmt("%s Frame Positions", _G.PREVIEW) then
        return
    end

    local nextLine = nil
    if currentGuide.name ~= '' and currentGuide.group ~= '' then
        nextLine = fmt("%s\\%s", currentGuide.group, currentGuide.name)
    end

    local previewsGuideContent = fmt([[
#name %s
step
    #sticky
    #completewith next
    +This is a temporary guide to allow frame positioning, skip all steps to reload the current guide
step
    >> Position Active Targets and Arrow
    .target %s
    .hs >> Position Active Items
    .goto %s,0.0,0.0
step
    +%s
    >>|cRXP_WARN_Skip this step to return%s|r
    ]],
    fmt("%s Frame Positions", _G.PREVIEW),
    addon.player.name,
    GetRealZoneText(),
    fmt(_G.ERR_QUEST_COMPLETE_S, _G.PREVIEW),
    currentGuide.name == "" and '' or fmt(" to %s", nextLine or _G.MAINMENU)
    )

    addon.RegisterGuide(_G.PREVIEW or L("Preview"), previewsGuideContent)

    local guideToLoad = addon.GetGuideTable(_G.PREVIEW, fmt("%s Frame Positions", _G.PREVIEW))

    guideToLoad.next = nextLine

    local loadPreviewGuide = function ()
        addon:LoadGuide(guideToLoad)
    end

    addon:ScheduleTask(loadPreviewGuide)
end

function addon.settings:SaveFramePositions()
    -- If resetting DB, don't save frames on reload
    if settingsDB and settingsDB.isResetting then return end

    if not addon.settings.profile.framePositions then
        addon.settings.profile.framePositions = {}
    end

    if not addon.settings.profile.frameSizes then
        addon.settings.profile.frameSizes = {}
    end

    local point, relativeToFrameOrPoint, relativePointOrX, offsetXOrY,
          offsetYOrNil

    for frameName, frame in pairs(addon.enabledFrames) do
        addon.settings.profile.frameSizes[frameName] = {
            frame:GetWidth(), frame:GetHeight()
        }

        addon.settings.profile.framePositions[frameName] = {}

        for i = 1, frame:GetNumPoints() or 0 do
            point, relativeToFrameOrPoint, relativePointOrX, offsetXOrY, offsetYOrNil =
                frame:GetPoint(i)

            if type(relativeToFrameOrPoint) == "table" then
                relativeToFrameOrPoint = relativeToFrameOrPoint:GetName()
            end

            addon.settings.profile.framePositions[frameName][i] = {
                point, relativeToFrameOrPoint, relativePointOrX, offsetXOrY,
                offsetYOrNil
            }
        end
    end

end

function addon.settings:LoadFramePositions()
    local point, relativeToName, relativePoint, offsetX, offsetYOrNil
    local result, reason
    local p = addon.settings.profile

    for frameName, frame in pairs(addon.enabledFrames) do
        -- Wipe alpha frame data
        -- Alpha frame restoration only tracked one point, to [1] would be "TOPLEFT" or similar
        if p.framePositions[frameName] and p.framePositions[frameName][1] and
            type(p.framePositions[frameName][1]) ~= "table" then
            p.framePositions[frameName] = nil
        end

        if p.framePositions[frameName] then
            for i = 1, frame:GetNumPoints() or 0 do
                point, relativeToName, relativePoint, offsetX, offsetYOrNil =
                    unpack(p.framePositions[frameName][i])

                frame:ClearAllPoints()
                result, reason = pcall(frame.SetPoint, frame, point,
                                       relativeToName, relativePoint, offsetX,
                                       offsetYOrNil)
            end
        end

        if p.frameSizes[frameName] then
            frame:SetSize(unpack(p.frameSizes[frameName]))
        end
    end

    addon.settings:LoadScales()
end

function addon.settings:LoadScales()
    addon.RXPFrame:SetScale(self.profile.windowScale)

    if addon.arrowFrame then
        addon.arrowFrame:SetSize(32 * self.profile.arrowScale,
                                 32 * self.profile.arrowScale)
    end

    if addon.activeItemFrame then
        addon.activeItemFrame:SetScale(self.profile.activeItemsScale)
    end

    if addon.targeting and addon.targeting.activeTargetFrame then
        addon.targeting.activeTargetFrame:SetScale(self.profile
                                                       .activeTargetScale)
    end
end

function addon.settings:IsEnabled(...)
    for _, settingName in ipairs({...}) do
        if not self.profile[settingName] then return false end
    end

    return true
end

addon.settings.dungeons = addon.settings.dungeons or {}

function addon.settings.dungeons:GetDungeons()
    local metadata = RXPCData and RXPCData.guideMetaData
    local enabled = metadata and metadata.enabledDungeons
    return enabled and enabled[addon.player.faction] or {}
end

function addon.settings.dungeons:ScoreDungeons()
    local factionStats = addon.dungeonStats and
                             addon.dungeonStats[addon.player.faction]
    if not factionStats then
        self.dungeonScore = nil
        return
    end

    local scores = {}
    for tag, dungeon in pairs(factionStats) do
        scores[tag] = (dungeon.travel or 0) * 0.7 +
                          (dungeon.quest or 0) * 1.2 +
                          (dungeon[addon.player.class] or 0) * 1.4
    end

    if addon.player.faction == "Alliance" then
        scores.STOCKS = 9
        scores.ULDA = 9
        if addon.player.class == "PALADIN" or
            addon.player.class == "WARRIOR" then
            scores.SM = 9
        end
    end
    self.dungeonScore = scores
    return scores
end

function addon.settings.dungeons:SetRecommended()
    local scores = self:ScoreDungeons()
    if not scores then return false end
    for tag in pairs(self:GetDungeons()) do
        addon.settings.profile.dungeons[tag] = (scores[tag] or 0) > 7
    end
    addon.ReloadGuide()
    return true
end

function addon.settings.dungeons:SetAll()
    for tag in pairs(self:GetDungeons()) do
        addon.settings.profile.dungeons[tag] = true
    end
    addon.ReloadGuide()
    return true
end
