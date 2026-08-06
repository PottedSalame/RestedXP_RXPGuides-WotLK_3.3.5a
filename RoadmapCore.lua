local _, addon = ...

local _G = _G
local format = string.format
local time = _G.time
local SCHEMA_VERSION = 1
local BACKUP_PREFIX = "RXPBACKUP1"
local MAX_BACKUP_SIZE = 1024 * 1024

addon.roadmap = addon.roadmap or {}
addon.guideState = addon.guideState or {}
local roadmap = addon.roadmap
local guideState = addon.guideState

local moduleSettingKeys = {
    ["communications"] = {"enableGroupQuests", "shareQuests"},
    ["targeting"] = {"enableTargeting", "hideTargetingFrame"},
    ["talents"] = {"enableTalentGuides"},
    ["leveling tracker"] = {"enableTracker"},
    ["tips"] = {"enableTips"},
    ["vendor treasures"] = {"enableVendorTreasure", "vendorTreasurePinScale"},
    ["item upgrades"] = {"enableItemUpgrades", "itemUpgradeSpec",
                           "itemUpgradeSpecManual"},
    ["party synchronization"] = {"partyGuideSync", "partyGuideWait"},
    ["accessibility"] = {"colorBlindMode"}
}

local function CopySafe(value, depth, seen)
    local valueType = type(value)
    if valueType == "nil" or valueType == "boolean" or
        valueType == "number" or valueType == "string" then
        return value
    end
    if valueType ~= "table" or depth > 12 then return nil end
    seen = seen or {}
    if seen[value] then return nil end
    seen[value] = true
    local result = {}
    for key, child in pairs(value) do
        local keyType = type(key)
        if keyType == "string" or keyType == "number" then
            local copied = CopySafe(child, depth + 1, seen)
            if copied ~= nil then result[key] = copied end
        end
    end
    seen[value] = nil
    return result
end

local function ValidateTree(value, depth, count)
    local valueType = type(value)
    if valueType == "string" then
        return #value <= 65535, count + 1
    elseif valueType == "number" then
        return value == value and value > -math.huge and value < math.huge,
               count + 1
    elseif valueType == "boolean" or valueType == "nil" then
        return true, count + 1
    elseif valueType ~= "table" or depth > 12 then
        return false, count
    end
    for key, child in pairs(value) do
        if type(key) ~= "string" and type(key) ~= "number" then
            return false, count
        end
        count = count + 1
        if count > 30000 then return false, count end
        local valid
        valid, count = ValidateTree(child, depth + 1, count)
        if not valid then return false, count end
    end
    return true, count
end

local function ValidateBackupPayload(payload)
    if type(payload) ~= "table" or payload.schema ~= 1 or
        type(payload.settings) ~= "table" or
        type(payload.character) ~= "table" or
        type(payload.favorites) ~= "table" then return false end
    local rootFields = {
        schema = true, addon = true, created = true, settings = true,
        character = true, favorites = true
    }
    for key in pairs(payload) do if not rootFields[key] then return false end end
    local characterFields = {
        guideProgress = true, recentGuides = true, currentGuideGroup = true,
        currentGuideName = true, currentStep = true, currentStepId = true,
        stepSkip = true, completedWaypoints = true, discardPile = true,
        manualJunkOverrides = true, activeTalentGuide = true
    }
    for key in pairs(payload.character) do
        if not characterFields[key] then return false end
    end
    for _, key in ipairs({"guideProgress", "recentGuides", "stepSkip",
                           "completedWaypoints", "discardPile",
                           "manualJunkOverrides"}) do
        if payload.character[key] ~= nil and
            type(payload.character[key]) ~= "table" then return false end
    end
    if payload.character.currentStep ~= nil and
        type(payload.character.currentStep) ~= "number" then return false end
    if payload.character.currentStepId ~= nil and
        type(payload.character.currentStepId) ~= "number" and
        type(payload.character.currentStepId) ~= "string" then return false end
    for _, checkpoint in pairs(payload.character.guideProgress or {}) do
        if type(checkpoint) ~= "table" or type(checkpoint.group) ~= "string" or
            type(checkpoint.name) ~= "string" or
            (checkpoint.step ~= nil and type(checkpoint.step) ~= "number") then
            return false
        end
    end
    return true
end

local function GuideKey(guide)
    if type(guide) ~= "table" or guide.empty then return end
    return guide.key or addon.BuildGuideKey(guide)
end

function roadmap:InitializeSavedData()
    RXPData.featureSchemaVersion = tonumber(RXPData.featureSchemaVersion) or 0
    RXPData.guideHub = type(RXPData.guideHub) == "table" and
                           RXPData.guideHub or {}
    RXPData.guideHub.favorites =
        type(RXPData.guideHub.favorites) == "table" and
            RXPData.guideHub.favorites or {}
    RXPCData.guideProgress = type(RXPCData.guideProgress) == "table" and
                                RXPCData.guideProgress or {}
    RXPCData.recentGuides = type(RXPCData.recentGuides) == "table" and
                               RXPCData.recentGuides or {}
    RXPData.safeMode = type(RXPData.safeMode) == "table" and
                           RXPData.safeMode or {modules = {}}
    RXPData.safeMode.modules = type(RXPData.safeMode.modules) == "table" and
                                   RXPData.safeMode.modules or {}
    RXPData.diagnosticState = type(RXPData.diagnosticState) == "table" and
                                  RXPData.diagnosticState or {}
    RXPData.seenQuests = type(RXPData.seenQuests) == "table" and
                             RXPData.seenQuests or {}
    RXPData.compatibilityPacks =
        type(RXPData.compatibilityPacks) == "table" and
            RXPData.compatibilityPacks or {}

    -- Seed the sparse checkpoint store from the legacy active-guide fields.
    if RXPData.featureSchemaVersion < 1 and
        type(RXPCData.currentGuideGroup) == "string" and
        RXPCData.currentGuideGroup ~= "" and
        type(RXPCData.currentGuideName) == "string" and
        RXPCData.currentGuideName ~= "" then
        local key = addon.BuildGuideKey(RXPCData.currentGuideGroup, "",
                                        RXPCData.currentGuideName)
        RXPCData.guideProgress[key] = {
            group = RXPCData.currentGuideGroup,
            name = RXPCData.currentGuideName,
            step = tonumber(RXPCData.currentStep) or 1,
            stepId = RXPCData.currentStepId,
            stepSkip = CopySafe(RXPCData.stepSkip or {}, 0),
            completedWaypoints = CopySafe(RXPCData.completedWaypoints or {}, 0),
            lastOpened = time()
        }
    end
    if RXPData.featureSchemaVersion < SCHEMA_VERSION then
        RXPData.featureSchemaVersion = SCHEMA_VERSION
    end
end

local function ErrorFingerprint(errorText)
    errorText = tostring(errorText or "Unknown error")
    errorText = errorText:gsub("Interface[/\\].-AddOns[/\\]", "AddOns/")
    errorText = errorText:gsub(":%d+:", ":#:")
    return errorText:sub(1, 500)
end

function roadmap:RunOptional(name, callback, resetCallback)
    local modules = RXPData.safeMode.modules
    local state = type(modules[name]) == "table" and modules[name] or {}
    modules[name] = state
    self.optionalCallbacks = self.optionalCallbacks or {}
    self.optionalCallbacks[name] = {run = callback, reset = resetCallback}
    if state.disabled then return false, "disabled by safe mode" end
    local ok, result = pcall(callback)
    if ok then
        state.failures = 0
        state.fingerprint = nil
        state.lastError = nil
        return true, result
    end
    local fingerprint = ErrorFingerprint(result)
    if state.fingerprint == fingerprint then
        state.failures = (tonumber(state.failures) or 0) + 1
    else
        state.fingerprint = fingerprint
        state.failures = 1
    end
    state.lastError = tostring(result):sub(1, 2000)
    state.lastFailure = time()
    if state.failures >= 2 then state.disabled = true end
    if _G.geterrorhandler then _G.geterrorhandler()(result) end
    return false, result
end

function roadmap:RetryOptional(name, reset)
    local callbacks = self.optionalCallbacks and self.optionalCallbacks[name]
    local state = RXPData.safeMode.modules[name]
    if not callbacks or not state then return end
    if reset then
        if callbacks.reset then
            pcall(callbacks.reset)
        else
            local defaults = addon.settings and addon.settings.defaults and
                                 addon.settings.defaults.profile
            local profile = addon.settings and addon.settings.profile
            for _, key in ipairs(moduleSettingKeys[name] or {}) do
                if profile then
                    profile[key] = defaults and CopySafe(defaults[key], 0) or nil
                end
            end
        end
    end
    state.disabled = nil
    state.failures = 0
    state.fingerprint = nil
    local ok = self:RunOptional(name, callbacks.run, callbacks.reset)
    if ok and self.safeModeFrame then self.safeModeFrame:Hide() end
end

function roadmap:BuildSafeModeReport()
    local lines = {"RXPGuides safe-mode report", "Addon: " ..
                       tostring(addon.release), "Client: " ..
                       tostring(select(1, GetBuildInfo())), ""}
    for name, state in pairs(RXPData.safeMode.modules or {}) do
        if state.disabled or (state.failures or 0) > 0 then
            table.insert(lines, format("%s: failures=%d disabled=%s", name,
                tonumber(state.failures) or 0, tostring(state.disabled == true)))
            if state.lastError then table.insert(lines, state.lastError) end
        end
    end
    return table.concat(lines, "\n")
end

function roadmap:ShowSafeModeRecovery()
    local failedName
    for name, state in pairs(RXPData.safeMode.modules or {}) do
        if state.disabled then failedName = name break end
    end
    if not failedName then return end
    if self.safeModeFrame then
        self.safeModeFrame.failedName = failedName
        self.safeModeFrame:Show()
        return
    end
    local frame = CreateFrame("Frame", "RXPSafeModeRecovery", UIParent)
    frame:SetSize(470, 190)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                       edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                       tile = true, tileSize = 32, edgeSize = 32,
                       insets = {left = 8, right = 8, top = 8, bottom = 8}})
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -18)
    title:SetText("RXPGuides Safe Mode")
    frame.message = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.message:SetPoint("TOPLEFT", 24, -50)
    frame.message:SetPoint("TOPRIGHT", -24, -50)
    frame.message:SetJustifyH("LEFT")
    frame.message:SetText("An optional feature failed repeatedly. The guide window remains available.")
    local function Button(text, x, callback)
        local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        button:SetSize(100, 24)
        button:SetPoint("BOTTOMLEFT", x, 24)
        button:SetText(text)
        button:SetScript("OnClick", callback)
    end
    Button("Retry Once", 22, function()
        roadmap:RetryOptional(frame.failedName, false)
    end)
    Button("Keep Disabled", 132, function() frame:Hide() end)
    Button("Reset Settings", 242, function()
        roadmap:RetryOptional(frame.failedName, true)
    end)
    Button("Copy Report", 352, function()
        addon.comms.OpenBrandedExport("Safe-mode report",
            "Copy this sanitized report.", roadmap:BuildSafeModeReport(), 620,
            360)
    end)
    frame:SetScript("OnShow", function(self)
        local state = RXPData.safeMode.modules[self.failedName]
        self.message:SetText(format(
            "The optional '%s' subsystem failed repeatedly and was disabled.\n%s",
            tostring(self.failedName), tostring(state and state.lastError or "")))
    end)
    frame.failedName = failedName
    self.safeModeFrame = frame
    table.insert(_G.UISpecialFrames, "RXPSafeModeRecovery")
end

function guideState:SaveCurrent()
    local guide = addon.currentGuide
    local key = GuideKey(guide)
    if not key or not RXPCData or type(RXPCData.guideProgress) ~= "table" then
        return
    end
    local step = tonumber(RXPCData.currentStep) or 1
    if not guide.steps or step < 1 or step > #guide.steps then step = 1 end
    local stepData = guide.steps and guide.steps[step]
    RXPCData.guideProgress[key] = {
        group = guide.group,
        subgroup = guide.subgroup,
        name = guide.name,
        step = step,
        stepId = stepData and stepData.stepId or RXPCData.currentStepId,
        stepSkip = CopySafe(RXPCData.stepSkip or {}, 0),
        completedWaypoints = CopySafe(RXPCData.completedWaypoints or {}, 0),
        lastOpened = time()
    }
end

function guideState:Get(guide)
    local key = GuideKey(guide)
    local progress = key and RXPCData.guideProgress
    local checkpoint = progress and progress[key]
    if checkpoint then return checkpoint, key end

    -- Schema-0 saves did not retain the subgroup. Find that one legacy entry
    -- by its stable group/name pair, then move it to the current key. This is
    -- deliberately lazy so loading the save never requires parsing every guide.
    if progress and guide then
        for oldKey, candidate in pairs(progress) do
            if type(candidate) == "table" and candidate.group == guide.group and
                candidate.name == guide.name then
                progress[key] = candidate
                if oldKey ~= key then progress[oldKey] = nil end
                candidate.subgroup = guide.subgroup
                return candidate, key
            end
        end
    end
    return nil, key
end

function guideState:Apply(guide, restart)
    local checkpoint = not restart and self:Get(guide)
    if checkpoint then
        RXPCData.currentStep = tonumber(checkpoint.step) or 1
        RXPCData.currentStepId = checkpoint.stepId
        RXPCData.stepSkip = CopySafe(checkpoint.stepSkip or {}, 0)
        RXPCData.completedWaypoints =
            CopySafe(checkpoint.completedWaypoints or {}, 0)
    else
        RXPCData.currentStep = 1
        RXPCData.currentStepId = nil
        RXPCData.stepSkip = {}
        RXPCData.completedWaypoints = {}
    end
    RXPCData.currentGuideGroup = guide.group
    RXPCData.currentGuideName = guide.name
    return checkpoint ~= nil
end

function guideState:Load(guide, restart, source)
    if type(guide) ~= "table" or guide.empty then return end
    self:SaveCurrent()
    local hasCheckpoint = self:Apply(guide, restart)
    return addon:LoadGuide(guide, hasCheckpoint, source or "manual")
end

function guideState:RecordLoaded(guide)
    local key = GuideKey(guide)
    if not key then return end
    local recent = RXPCData.recentGuides
    for index = #recent, 1, -1 do
        if recent[index] == key then table.remove(recent, index) end
    end
    table.insert(recent, 1, key)
    while #recent > 20 do table.remove(recent) end
    self:SaveCurrent()
    if addon.guideHub and addon.guideHub.Refresh then
        addon.guideHub:Refresh()
    end
end

function roadmap:BuildBackup()
    guideState:SaveCurrent()
    local payload = {
        schema = 1,
        addon = addon.release,
        created = time(),
        settings = CopySafe(addon.settings and addon.settings.profile or {}, 0),
        character = {
            guideProgress = CopySafe(RXPCData.guideProgress or {}, 0),
            recentGuides = CopySafe(RXPCData.recentGuides or {}, 0),
            currentGuideGroup = RXPCData.currentGuideGroup,
            currentGuideName = RXPCData.currentGuideName,
            currentStep = RXPCData.currentStep,
            currentStepId = RXPCData.currentStepId,
            stepSkip = CopySafe(RXPCData.stepSkip or {}, 0),
            completedWaypoints = CopySafe(RXPCData.completedWaypoints or {}, 0),
            discardPile = CopySafe(RXPCData.discardPile or {}, 0),
            manualJunkOverrides =
                CopySafe(RXPCData.manualJunkOverrides or {}, 0),
            activeTalentGuide = RXPCData.activeTalentGuide
        },
        favorites = CopySafe(RXPData.guideHub.favorites or {}, 0)
    }
    local serializer = LibStub("AceSerializer-3.0")
    local deflate = LibStub("LibDeflate")
    local serialized = serializer:Serialize(payload)
    local checksum = deflate:Adler32(serialized)
    local compressed = deflate:CompressDeflate(serialized)
    return format("%s:%u:%s", BACKUP_PREFIX, checksum,
                  deflate:EncodeForPrint(compressed))
end

function roadmap:DecodeBackup(text)
    if type(text) ~= "string" then return nil, "Backup is not text." end
    if #text > MAX_BACKUP_SIZE * 2 then return nil, "Backup text is too large." end
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    local checksumText, encoded = text:match("^" .. BACKUP_PREFIX ..
                                                 ":(%d+):(.+)$")
    if not checksumText or not encoded then return nil, "Unknown backup format." end
    local deflate = LibStub("LibDeflate")
    local decoded = deflate:DecodeForPrint(encoded)
    if not decoded then return nil, "Backup encoding is damaged." end
    local serialized = deflate:DecompressDeflate(decoded)
    if not serialized or #serialized > MAX_BACKUP_SIZE then
        return nil, "Backup is damaged or too large."
    end
    if deflate:Adler32(serialized) ~= tonumber(checksumText) then
        return nil, "Backup checksum does not match."
    end
    local ok, payload = LibStub("AceSerializer-3.0"):Deserialize(serialized)
    if not ok or not ValidateBackupPayload(payload) then
        return nil, "Unsupported backup schema."
    end
    local valid = ValidateTree(payload, 0, 0)
    if not valid then return nil, "Backup contains invalid data." end
    return payload
end

local function MergeInto(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then return end
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then target[key] = {} end
            MergeInto(target[key], value)
        else
            target[key] = value
        end
    end
end

function roadmap:ApplyBackup(payload, replace)
    if type(payload) ~= "table" or type(payload.character) ~= "table" then
        return false, "Backup has no character data."
    end
    self.backupRollback = {
        settings = CopySafe(addon.settings.profile, 0),
        character = CopySafe(RXPCData, 0),
        guideHub = CopySafe(RXPData.guideHub, 0)
    }
    if replace then
        for key in pairs(addon.settings.profile) do addon.settings.profile[key] = nil end
        MergeInto(addon.settings.profile, payload.settings or {})
        RXPCData.guideProgress = CopySafe(payload.character.guideProgress or {}, 0)
        RXPCData.recentGuides = CopySafe(payload.character.recentGuides or {}, 0)
    else
        MergeInto(addon.settings.profile, payload.settings or {})
        MergeInto(RXPCData.guideProgress,
                  payload.character.guideProgress or {})
        RXPCData.recentGuides = CopySafe(payload.character.recentGuides or
                                            RXPCData.recentGuides, 0)
    end
    local replaceFields = {"currentGuideGroup", "currentGuideName",
                           "currentStep", "currentStepId", "stepSkip",
                           "completedWaypoints", "discardPile",
                           "manualJunkOverrides", "activeTalentGuide"}
    if replace then
        for _, key in ipairs(replaceFields) do RXPCData[key] = nil end
    end
    for _, key in ipairs(replaceFields) do
        local value = payload.character[key]
        if value ~= nil then RXPCData[key] = CopySafe(value, 0) end
    end
    if replace then RXPData.guideHub.favorites = {} end
    MergeInto(RXPData.guideHub.favorites, payload.favorites or {})
    addon:RestoreCharacterGuideProgress()
    if addon.guideHub then addon.guideHub:Refresh() end
    return true
end

function roadmap:OpenBackupExport()
    addon.comms.OpenBrandedExport("Backup Export",
        "Copy this text and store it somewhere safe.", self:BuildBackup(),
        620, 420)
end

function roadmap:RollbackBackup()
    local rollback = self.backupRollback
    if type(rollback) ~= "table" then return false end
    for key in pairs(addon.settings.profile) do addon.settings.profile[key] = nil end
    MergeInto(addon.settings.profile, rollback.settings or {})
    for key in pairs(RXPCData) do RXPCData[key] = nil end
    MergeInto(RXPCData, rollback.character or {})
    RXPData.guideHub = CopySafe(rollback.guideHub or {}, 0)
    self.backupRollback = nil
    addon:RestoreCharacterGuideProgress()
    if addon.guideHub then addon.guideHub:Refresh() end
    return true
end

function roadmap:OpenBackupImport(replace)
    addon.comms.OpenBrandedExport("Backup Import",
        replace and
            "Paste an RXPGuides backup and press Enter. Replacement requires one final confirmation." or
            "Paste an RXPGuides backup and press Enter to merge it into this character.",
        "", 620, 420, function(text)
            local payload, errorText = self:DecodeBackup(text)
            if not payload then
                addon.comms:PopupNotification("RXP_BACKUP_ERROR", errorText)
                return
            end
            local function Apply()
                local ok, applyError = roadmap:ApplyBackup(payload, replace)
                addon.comms:PopupNotification("RXP_BACKUP_RESULT",
                    ok and "Backup imported successfully. An Undo button remains available until reload." or applyError)
            end
            if replace then
                addon.comms:ConfirmChoice("RXP_BACKUP_REPLACE",
                    "Replace this character's backed-up RXPGuides data? A temporary rollback is retained until reload.",
                    Apply)
            else
                Apply()
            end
        end)
end

function roadmap:OpenBackupWindow()
    if self.backupFrame then
        self.backupFrame:SetShown(not self.backupFrame:IsShown())
        return
    end
    local frame = CreateFrame("Frame", "RXPBackupWindow", UIParent)
    frame:SetSize(440, 132)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                       edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                       tile = true, tileSize = 32, edgeSize = 32,
                       insets = {left = 8, right = 8, top = 8, bottom = 8}})
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -18)
    title:SetText("RXPGuides Backup")
    local export = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    export:SetSize(92, 24)
    export:SetPoint("BOTTOMLEFT", 18, 22)
    export:SetText("Export")
    export:SetScript("OnClick", function() roadmap:OpenBackupExport() end)
    local import = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    import:SetSize(102, 24)
    import:SetPoint("LEFT", export, "RIGHT", 7, 0)
    import:SetText("Merge")
    import:SetScript("OnClick", function() roadmap:OpenBackupImport(false) end)
    local replace = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    replace:SetSize(102, 24)
    replace:SetPoint("LEFT", import, "RIGHT", 7, 0)
    replace:SetText("Replace")
    replace:SetScript("OnClick", function() roadmap:OpenBackupImport(true) end)
    local undo = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    undo:SetSize(92, 24)
    undo:SetPoint("LEFT", replace, "RIGHT", 7, 0)
    undo:SetText("Undo Import")
    undo:SetScript("OnClick", function()
        if not roadmap:RollbackBackup() then
            addon.comms:PopupNotification("RXP_BACKUP_NO_ROLLBACK",
                "There is no import to undo in this session.")
        end
    end)
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    self.backupFrame = frame
end

function roadmap:Setup()
    self:InitializeSavedData()
    -- The Hub is part of the recovery surface and is intentionally initialized
    -- outside optional-module state. A caught failure is still reported, but it
    -- never prevents the existing guide window from finishing initialization.
    if addon.guideHub and addon.guideHub.Setup then
        local ok, errorText = pcall(addon.guideHub.Setup, addon.guideHub)
        if not ok and _G.geterrorhandler then _G.geterrorhandler()(errorText) end
    end
    if addon.goldAssistant and addon.goldAssistant.Setup then
        self:RunOptional("gold assistant",
            function() addon.goldAssistant:Setup() end,
            function() RXPCData.goldAssistant = nil end)
    end
    if addon.diagnostics and addon.diagnostics.Setup then
        self:RunOptional("step doctor",
            function() addon.diagnostics:Setup() end)
    end
    if addon.partySync and addon.partySync.Setup then
        self:RunOptional("party synchronization",
            function() addon.partySync:Setup() end)
    end
    if addon.supplies and addon.supplies.Setup then
        self:RunOptional("class supplies",
            function() addon.supplies:Setup() end,
            function() RXPCData.supplyTargets = {} end)
    end
    if addon.gearAdvisor and addon.gearAdvisor.Setup then
        self:RunOptional("gear advisor",
            function() addon.gearAdvisor:Setup() end)
    end
    if addon.activityPlanner and addon.activityPlanner.Setup then
        self:RunOptional("activity planner",
            function() addon.activityPlanner:Setup() end,
            function() RXPCData.activityPlanner = nil end)
    end
    if addon.accessibility and addon.accessibility.Setup then
        self:RunOptional("accessibility",
            function() addon.accessibility:Setup() end)
    end
    if addon.guideRecorder and addon.guideRecorder.Setup then
        self:RunOptional("guide recorder",
            function() addon.guideRecorder:Setup() end,
            function() RXPCData.recorderDraft = nil end)
    end
    self:ShowSafeModeRecovery()
end
