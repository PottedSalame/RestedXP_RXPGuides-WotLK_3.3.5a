local addonName, addon = ...

local _G = _G
local fmt, strsub, tinsert, srep, mmax, abs = string.format, string.sub,
                                              tinsert, string.rep, math.max,
                                              abs

local UnitLevel, GetRealZoneText, IsInGroup, tonumber, GetTime, GetServerTime, UnitXP = UnitLevel, GetRealZoneText,
                                                                                        IsInGroup, tonumber, GetTime,
                                                                                        GetServerTime, UnitXP

local AceGUI = LibStub("AceGUI-3.0")
local LibDeflate = LibStub("LibDeflate")
local L = addon.locale.Get
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0", true)
local EasyMenu = function(...)
    if _G.EasyMenu then
        _G.EasyMenu(...)
    else
        LibDD:EasyMenu(...)
    end
end

addon.tracker = addon:NewModule("LevelingTracker", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")

addon.tracker.playerLevel = UnitLevel("player")
addon.tracker.state = {
    otherReports = {},
    inspectionRequests = {},
    pendingInspectionNames = {},
    login = {sessionStartedAt = GetTime(), timePlayedThisLevel = 0, totalTimePlayed = 0},
}
addon.tracker.reportData = {}
addon.tracker.ui = {}
addon.tracker._commPrefix = "RXPLTComms"
addon.tracker.fonts = {["splits"] = "Fonts\\ARIALN.ttf"}

local playerName = _G.UnitName("player")
local COMM_VERSION = 1
local MAX_COMM_BYTES = 128 * 1024
local MAX_IMPORT_BYTES = 256 * 1024
local MAX_REPORT_LEVELS = 100

local function IsLegacyWorldMapOpen()
    return addon.gameVersion == 30300 and _G.WorldMapFrame and
               _G.WorldMapFrame:IsShown()
end

-- Silence our /played yellow text
local ReportPlayedTimeToChat = false
local hookedChatFrame_DisplayTimePlayed
local playedTimeChatWrapper

local function InstallPlayedTimeHook()
    if _G.ChatFrame_DisplayTimePlayed == playedTimeChatWrapper then return end
    hookedChatFrame_DisplayTimePlayed = _G.ChatFrame_DisplayTimePlayed
    playedTimeChatWrapper = function(...)
        if ReportPlayedTimeToChat and hookedChatFrame_DisplayTimePlayed then
            return hookedChatFrame_DisplayTimePlayed(...)
        end

        -- Delay releasing output so queued /played responses from other addons
        -- are not swallowed after RXPGuides has consumed its own response.
        C_Timer.After(3, function() ReportPlayedTimeToChat = true end)
    end
    _G.ChatFrame_DisplayTimePlayed = playedTimeChatWrapper
end

local function RestorePlayedTimeHook()
    if _G.ChatFrame_DisplayTimePlayed == playedTimeChatWrapper and
        hookedChatFrame_DisplayTimePlayed then
        _G.ChatFrame_DisplayTimePlayed = hookedChatFrame_DisplayTimePlayed
    end
    playedTimeChatWrapper = nil
    hookedChatFrame_DisplayTimePlayed = nil
    ReportPlayedTimeToChat = true
end

local function RequestTimePlayed()
    ReportPlayedTimeToChat = false
    return _G.RequestTimePlayed()
end

local MAX_LEVEL_DURATION = 30 * 24 * 60 * 60

function addon.tracker:GetElapsedTimes(now)
    now = now or GetTime()
    local login = self.state.login or {}
    local sessionStartedAt = login.sessionStartedAt or now
    local elapsed = mmax(0, now - sessionStartedAt)
    local levelTime = mmax(0, tonumber(login.timePlayedThisLevel) or 0) + elapsed
    local totalTime = mmax(0, tonumber(login.totalTimePlayed) or 0) + elapsed
    return levelTime, totalTime
end

function addon.tracker:AdoptPlayedTime(totalTime, levelTime, level)
    if type(totalTime) ~= "number" then return end
    levelTime = type(levelTime) == "number" and levelTime or 0
    self.state.login = {
        sessionStartedAt = GetTime(),
        timePlayedThisLevel = mmax(0, levelTime),
        totalTimePlayed = mmax(0, totalTime)
    }
    if self.db and self.db.profile then
        self.db.profile.playedTimeFallback = {
            level = level or self.playerLevel,
            levelTime = mmax(0, levelTime),
            totalTime = mmax(0, totalTime)
        }
    end
end

function addon.tracker:PersistPlayedTime()
    if not (self.db and self.db.profile) then return end
    local levelTime, totalTime = self:GetElapsedTimes()
    self.db.profile.playedTimeFallback = {
        level = self.playerLevel,
        levelTime = levelTime,
        totalTime = totalTime
    }
end

function addon.tracker:GetLevelDuration(level, data)
    data = data or self.reportData[level] or
               (self.db and self.db.profile.levels[level])
    local timestamp = data and data.timestamp
    if not timestamp then return end

    local duration = tonumber(timestamp.duration)
    if not duration then
        local started = tonumber(timestamp.started)
        local finished = tonumber(timestamp.finished)
        if started and finished then duration = finished - started end
    end

    if duration and duration > 0 and duration < MAX_LEVEL_DURATION then
        return duration
    end
end

function addon.tracker:SetupTracker()
    if self.enabled and self.db then
        self:SetupInspections()
        return
    end
    local trackerDefaults = {profile = {levels = {}, levelsArchive = {}}}
    self.db = self.db or
                  LibStub("AceDB-3.0"):New("RXPCTrackingData",
                                            trackerDefaults)
    self.enabled = true
    InstallPlayedTimeHook()
    self.maxLevel = GetMaxPlayerLevel()
    self.playerLevel = UnitLevel("player")

    local fallback = self.db.profile.playedTimeFallback or {}
    self.state.login = {
        sessionStartedAt = GetTime(),
        timePlayedThisLevel = fallback.level == self.playerLevel and
                                  (tonumber(fallback.levelTime) or 0) or 0,
        totalTimePlayed = tonumber(fallback.totalTime) or 0
    }

    self.reportKey = fmt("%s|%s|%s", playerName, addon.player.class, _G.GetRealmName())
    addon.db.profile.reports = type(addon.db.profile.reports) == "table" and
                                   addon.db.profile.reports or {}
    addon.db.profile.reports.splits =
        type(addon.db.profile.reports.splits) == "table" and
            addon.db.profile.reports.splits or {}

    if not self.db.profile.trackedGuid then self.db.profile.trackedGuid = addon.player.guid end

    if self.db.profile.trackedGuid ~= addon.player.guid then
        addon.comms.PrettyDebug("GUID changed, saving %s and resetting for %s", addon.player.name, addon.player.guid)

        -- 3.3.5a GUIDs are hex (e.g. "0x00000000000123AB") with no dashes, so the
        -- modern "3rd dash-segment" split returns nil, which then errors as a nil
        -- table index below and aborts SetupTracker (leaving PLAYER_LEVEL_UP
        -- unregistered, so level splits never record). Fall back to the full GUID.
        local _, _, guid = strsplit('-', addon.player.guid or "")
        guid = guid or addon.player.guid or "unknown"

        -- Not displayed nor consumed, but a safety net for data
        -- TODO add archives to splits for same-name speed splits
        if not self.db.profile["levelsArchive"] then self.db.profile["levelsArchive"] = {} end
        self.db.profile["levelsArchive"][guid] = self.db.profile["levels"]

        -- Reset splits
        if addon.db.profile.reports.splits[self.reportKey] then
            local profileAlias = fmt("%s|%s|%s", playerName .. guid, addon.player.class, _G.GetRealmName())

            -- Copy existing data to new key with GUID
            addon.db.profile.reports.splits[profileAlias] = addon.db.profile.reports.splits[self.reportKey]

            -- Delete data for old toon name
            addon.db.profile.reports.splits[self.reportKey] = nil
        end

        -- Now that data's been reset, update trackedGuid
        self.db.profile.trackedGuid = addon.player.guid
    end

    self:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
    self:RegisterEvent("TIME_PLAYED_MSG")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("QUEST_TURNED_IN")
    self:RegisterEvent("PLAYER_DEAD")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LOGOUT")

    self:SetupInspections()

    self:UpgradeDB()

    self:GenerateDBLevel(self.playerLevel)

    self:CompileData()

    self:CreateGui(_G.CharacterFrame, playerName)

    if addon.settings.profile.enablelevelSplits then self:CreateLevelSplits() end

    -- Setup can also run from the live settings toggle, after the normal
    -- PLAYER_ENTERING_WORLD request has already passed.
    self.waitingForTimePlayed = {event = "REFRESH"}
    RequestTimePlayed()
end

function addon.tracker:ShutdownTracker()
    if not self.enabled then return end
    self:PersistPlayedTime()
    self:UnregisterAllEvents()
    if self.UnregisterAllComm then
        self:UnregisterAllComm()
    elseif self.UnregisterComm then
        self:UnregisterComm(self._commPrefix)
    end
    self.enabled = false
    self.waitingForTimePlayed = nil
    for _, ui in pairs(self.ui or {}) do
        if ui and ui.Hide then ui:Hide() end
    end
    if self.levelSplits then self.levelSplits:Hide() end
    RestorePlayedTimeHook()
end

function addon.tracker:SetupInspections()
    if not self.enabled then return end
    local profile = addon.settings.profile
    if addon.gameVersion == 30300 and
        not profile.levelingInspectionConsent then
        profile.enableLevelingReportInspections = false
    end
    if profile.enableLevelingReportInspections and profile.enableBetaFeatures then

        -- TODO reduce duplication with SettingsPanel
        addon.settings.enabledBetaFeatures[L("Enable Leveling Report Inspections")] = L(
                                                                                          "Send or receive inspection requests for other Leveling Reports")
        self:RegisterEvent("INSPECT_READY")
        self:RegisterComm(self._commPrefix)

        if not self.inspectHookInstalled then
            self.inspectHookInstalled = true
            local UnitGUID, UnitIsEnemy = UnitGUID, UnitIsEnemy
            hooksecurefunc("NotifyInspect", function(unit)
                if not addon.settings.profile.enableLevelingReportInspections then return end

                -- Gearscore addons inspect on mouseover/nameplate/etc, RXP only inspects via target
                if unit ~= "target" or UnitIsEnemy("player", unit) then return end

                addon.tracker.state.inspectionRequests[UnitGUID(unit)] = true
            end)
        end
    else
        self:UnregisterEvent("INSPECT_READY")
        if self.UnregisterComm then
            self:UnregisterComm(self._commPrefix)
        end
        self.state.pendingInspectionNames = {}
        if addon.settings.enabledBetaFeatures then
            addon.settings.enabledBetaFeatures[
                L("Enable Leveling Report Inspections")] = nil
        end
    end
end

function addon.tracker:UpgradeDB()
    local profile = addon.tracker.db.profile
    profile.levels = type(profile.levels) == "table" and profile.levels or {}
    profile.levelsArchive = type(profile.levelsArchive) == "table" and
                                profile.levelsArchive or {}

    local normalized = {}
    for rawLevel, rawData in pairs(profile.levels) do
        local level = tonumber(rawLevel)
        if level and level >= 1 and level <= MAX_REPORT_LEVELS and
            type(rawData) == "table" then
            level = math.floor(level)
            local data = {
                quests = {},
                mobs = {},
                timestamp = type(rawData.timestamp) == "table" and
                                rawData.timestamp or {},
                groupExperience = mmax(0, tonumber(rawData.groupExperience) or 0),
                deaths = mmax(0, tonumber(rawData.deaths) or 0)
            }
            if type(rawData.quests) == "table" then
                for zoneName, questData in pairs(rawData.quests) do
                    if type(zoneName) == "string" and
                        type(questData) == "table" then
                        local quests = {}
                        for questId, questXP in pairs(questData) do
                            questXP = tonumber(questXP)
                            if questXP and questXP > 0 then
                                quests[questId] = questXP
                            end
                        end
                        if next(quests) then data.quests[zoneName] = quests end
                    end
                end
            end
            if type(rawData.mobs) == "table" then
                for zoneName, mobData in pairs(rawData.mobs) do
                    if type(zoneName) == "string" then
                        local xp, count
                        if type(mobData) == "table" then
                            xp = tonumber(mobData.xp)
                            count = tonumber(mobData.count)
                        else
                            xp = tonumber(mobData)
                        end
                        if xp and xp > 0 then
                            data.mobs[zoneName] = {
                                xp = xp,
                                count = mmax(0, count or 0)
                            }
                        end
                    end
                end
            end
            normalized[level] = data
        end
    end
    profile.levels = normalized
end

function addon.tracker:GenerateDBLevel(level)
    level = tonumber(level)
    if not level then return end
    level = math.floor(level)
    local profile = addon.tracker.db.profile
    if not profile["levels"] then profile["levels"] = {} end

    if type(profile["levels"][level]) ~= "table" then
        profile["levels"][level] = {
            quests = {}, -- [zone] = { questId = xpReward }
            mobs = {}, -- [zone] = xp
            timestamp = {}, -- started, finished
            groupExperience = 0,
            deaths = 0
        }
    end

    local data = profile["levels"][level]
    data.quests = type(data.quests) == "table" and data.quests or {}
    data.mobs = type(data.mobs) == "table" and data.mobs or {}
    data.timestamp = type(data.timestamp) == "table" and data.timestamp or {}
    data.groupExperience = mmax(0, tonumber(data.groupExperience) or 0)
    data.deaths = mmax(0, tonumber(data.deaths) or 0)

    if level == 1 then
        profile["levels"][level].timestamp.started = 0
    elseif level == 55 and addon.player.class == "DEATHKNIGHT" then
        profile["levels"][level].timestamp.started = 0
    end
end

function addon.tracker:CHAT_MSG_COMBAT_XP_GAIN(_, text, ...)
    -- Exclude the locale's unnamed XP message used by quest turn-ins; quest XP
    -- is recorded authoritatively by QUEST_TURNED_IN instead.
    local parsed = addon.ParseCombatXPMessage and
                       addon.ParseCombatXPMessage(text)
    if not parsed or not parsed.exact or parsed.named == false then return end
    local xpGained = parsed and tonumber(parsed.total) or nil

    if not xpGained or xpGained == 0 then return end

    local zoneName = GetRealZoneText()

    addon.tracker:GenerateDBLevel(addon.tracker.playerLevel)
    local levelData = addon.tracker.db.profile["levels"][addon.tracker.playerLevel]

    if not levelData.mobs[zoneName] then levelData.mobs[zoneName] = {xp = 0, count = 0} end

    local zoneMobData = levelData.mobs[zoneName]

    zoneMobData.xp = zoneMobData.xp + xpGained

    zoneMobData.count = zoneMobData.count + 1

    if IsInGroup() then
        levelData.groupExperience = levelData.groupExperience + xpGained
        -- else solo, total - group = solo, no need to keep track separately
    end
end

function addon.tracker:TIME_PLAYED_MSG(_, totalTimePlayed, timePlayedThisLevel)
    local data = self.waitingForTimePlayed
    self.waitingForTimePlayed = false

    if type(totalTimePlayed) == "number" then
        self:AdoptPlayedTime(totalTimePlayed, timePlayedThisLevel,
                             self.playerLevel)
    end

    if data and data.event == 'PLAYER_ENTERING_WORLD' then
        local current = self.db.profile.levels[self.playerLevel]
        if current and current.timestamp and
            not current.timestamp.dateStarted and
            type(timePlayedThisLevel) == "number" and
            timePlayedThisLevel < 60 then
            current.timestamp.dateStarted = data.date
        end
        self:CompileData()
        self:UpdateLevelSplits("full")
    end
end

function addon.tracker:PLAYER_LEVEL_UP(_, level)
    addon.tracker:GenerateDBLevel(level)

    -- Capture the completed level from one played-time clock. GetTime supplies
    -- the live-session delta while /played (or the persisted fallback) supplies
    -- the baseline, so offline time is never included.
    local levelTime, totalTime = addon.tracker:GetElapsedTimes()
    local duration = mmax(1, math.floor(levelTime + 0.5))
    totalTime = mmax(duration, math.floor(totalTime + 0.5))
    local levels = addon.tracker.db.profile.levels
    local date = C_DateAndTime.GetCurrentCalendarTime()

    local prev = levels[level - 1]
    if prev and prev.timestamp then
        prev.timestamp.duration = duration
        prev.timestamp.started = totalTime - duration
        prev.timestamp.finished = totalTime
        prev.timestamp.dateFinished = date
    end

    local cur = levels[level] -- created by GenerateDBLevel above
    cur.timestamp.started = totalTime
    cur.timestamp.finished = nil
    cur.timestamp.duration = nil
    cur.timestamp.dateStarted = date

    addon.tracker.playerLevel = level
    addon.tracker:AdoptPlayedTime(totalTime, 0, level)
    for _, ui in pairs(addon.tracker.ui or {}) do
        if ui then ui.reportLevelMenu = nil end
    end

    addon.tracker.reportData[level - 1] = addon.tracker:CompileLevelData(level - 1)
    addon.tracker.reportData[level] = addon.tracker:CompileLevelData(level)

    addon.tracker:UpdateLevelSplits("full")
    addon:SendEvent("RXP_LEVEL_TIME_RECORDED", level, duration)

    -- A response refines the new level's total/current baseline but cannot race or
    -- overwrite the completed level's explicit duration.
    addon.tracker.waitingForTimePlayed = {event = 'REFRESH'}
    RequestTimePlayed()
end

function addon.tracker:PLAYER_LOGOUT()
    self:PersistPlayedTime()
end

function addon.tracker:QUEST_TURNED_IN(_, questId, xpReward)
    xpReward = tonumber(xpReward)

    if not xpReward or xpReward <= 0 then return end

    local zoneName = GetRealZoneText()

    addon.tracker:GenerateDBLevel(addon.tracker.playerLevel)
    local levelData = addon.tracker.db.profile["levels"][addon.tracker.playerLevel]

    if not levelData.quests[zoneName] then levelData.quests[zoneName] = {} end

    levelData.quests[zoneName][questId] = xpReward

    -- Quest turnins can easily be miscategorized
    -- e.g. complete quest solo, join dungeon group, then turn in before flying or inverse
    -- However, summary report looks weird without it, calculate anyway
    if IsInGroup() then
        levelData.groupExperience = levelData.groupExperience + xpReward
        -- else solo, total - group = solo, no need to keep track separately
    end
end

function addon.tracker:PLAYER_DEAD()
    addon.tracker:GenerateDBLevel(addon.tracker.playerLevel)
    local data = addon.tracker.db.profile.levels[addon.tracker.playerLevel]
    data.deaths = mmax(0, tonumber(data.deaths) or 0) + 1
end

function addon.tracker:PLAYER_ENTERING_WORLD()
    addon.tracker.waitingForTimePlayed = {
        event = 'PLAYER_ENTERING_WORLD',
        date = C_DateAndTime.GetCurrentCalendarTime()
    }

    RequestTimePlayed()
end

function addon.tracker.UpdateReportLevels(levelData, playerLevel, target, attachment)
    if type(levelData) ~= "table" or not attachment or
        not attachment.GetName then return end
    local trackerUi = addon.tracker.ui[attachment:GetName()]
    if not trackerUi then return end

    if trackerUi.reportLevelMenu then
        EasyMenu(trackerUi.reportLevelMenu, trackerUi.levelMenuFrame, trackerUi.levelButton.frame, 0, 0,
                 "MENU")
        return
    end

    local sparse = {}
    local levels = {}
    playerLevel = tonumber(playerLevel) or 0
    for rawLevel in pairs(levelData) do
        local level = tonumber(rawLevel)
        if level and level >= 1 and level <= playerLevel then
            tinsert(levels, math.floor(level))
        end
    end
    table.sort(levels)

    for _, level in ipairs(levels) do
        local parentIndex = floor(level / 10) + 1
        local lowerLevel = mmax(floor(level / 10) * 10, 1)
        local upperLevel = floor(level / 10) * 10 + 10

        if not sparse[parentIndex] then
            sparse[parentIndex] = {text = fmt(L("%d to %d"), lowerLevel, upperLevel), hasArrow = true, menuList = {}}
        end

        local insertData = {
            notCheckable = 1,
            func = function(_, l, text)
                addon.tracker:UpdateReport(l, target, attachment)

                trackerUi.levelButton:SetText(text)
                _G.CloseDropDownMenus()
            end
        }

        if level == addon.tracker.maxLevel then
            insertData.text = fmt("%d (%s)", level, L("Max"))
        else
            insertData.text = fmt(L("%d to %d"), level, level + 1)
        end

        insertData.arg1 = level
        insertData.arg2 = insertData.text

        tinsert(sparse[parentIndex].menuList, insertData)

    end

    local menu = {}
    local bucketKeys = {}
    for key in pairs(sparse) do tinsert(bucketKeys, key) end
    table.sort(bucketKeys)
    for _, key in ipairs(bucketKeys) do tinsert(menu, sparse[key]) end

    trackerUi.reportLevelMenu = menu
    EasyMenu(menu, trackerUi.levelMenuFrame, trackerUi.levelButton.frame, 0, 0, "MENU")
end

local function buildSpacer(height)
    local spacer = AceGUI:Create("SimpleGroup")
    spacer:SetLayout("Fill")
    spacer:SetHeight(height)
    spacer:SetWidth(30)
    spacer:SetFullWidth(true)

    return spacer
end

local function SetWidgetFont(widget, size)
    if not widget then return end
    local font = addon.font or _G.STANDARD_TEXT_FONT or
                     "Fonts\\FRIZQT__.TTF"
    if widget.SetFont then pcall(widget.SetFont, widget, font, size, "") end
    if widget.label and addon.SetFontSafely then
        addon.SetFontSafely(widget.label, font, size, "")
    end
end

function addon.tracker:CreateGui(attachment, target)
    if not attachment then return end
    local attachmentName = attachment.GetName and attachment:GetName()
    if not attachmentName then return end
    if addon.tracker.ui[attachmentName] then return end

    local tab = _G.CharacterFrameTab1
    local tabsHeight = tab and tab.GetHeight and tab:GetHeight() or 32
    local offset = {x = -38, y = -32, tabsHeight = tabsHeight}
    local padding = 4
    local levelData, playerLevel

    addon.tracker.ui[attachmentName] = AceGUI:Create("Frame")
    local trackerUi = addon.tracker.ui[attachmentName]

    trackerUi:SetLayout("Fill")
    trackerUi:Hide()
    -- EnableResize was added to the AceGUI Frame widget in a later version than
    -- the one shipped with a 3.3.5a pack; guard it.
    if trackerUi.EnableResize then trackerUi:EnableResize(false) end

    if trackerUi.statustext and trackerUi.statustext.GetParent and
        trackerUi.statustext:GetParent() then
        trackerUi.statustext:GetParent():Hide()
    end
    trackerUi:SetTitle(L("RestedXP Leveling Report"))
    trackerUi.frame:ClearAllPoints()
    trackerUi.frame:SetPoint("TOPLEFT", attachment, "TOPRIGHT", offset.x, offset.y)
    trackerUi:SetWidth(attachment:GetWidth() * 0.7)
    trackerUi:SetHeight(attachment:GetHeight() + offset.y - 8 - offset.tabsHeight * 2)

    trackerUi.scrollContainer = AceGUI:Create("ScrollFrame")
    trackerUi.scrollContainer:SetLayout("Flow")
    trackerUi:AddChild(trackerUi.scrollContainer)

    trackerUi.frame:SetBackdrop(addon.RXPFrame.backdrop.edge)
    trackerUi.frame:SetBackdropColor(unpack(addon.colors.background))

    if attachmentName == 'CharacterFrame' then
        -- Firmly attach to CharacterFrame show/hide
        attachment:HookScript("OnShow", function()
            if addon.tracker.enabled and
                addon.settings.profile.openTrackerReportOnCharOpen then
                trackerUi:Show()
            end
        end)

        trackerUi:SetCallback("OnClose", function() trackerUi:Hide() end)

        trackerUi:SetCallback("OnShow", function()
            -- refresh data
            addon.tracker:CompileData()
            addon.tracker:UpdateReport(addon.tracker.playerLevel, playerName, _G.CharacterFrame)
        end)

        levelData = addon.tracker.db.profile["levels"]
        playerLevel = addon.tracker.playerLevel
    else
        local remote = self.state.otherReports[target]
        if not remote or type(remote.reportData) ~= "table" then
            AceGUI:Release(trackerUi)
            addon.tracker.ui[attachmentName] = nil
            return
        end
        levelData = remote.reportData
        playerLevel = tonumber(remote.playerLevel) or 1
    end

    attachment:HookScript("OnHide", function() trackerUi:Hide() end)

    -- Make sure the window can be closed by pressing the escape button
    local specialFrameName = attachmentName == "CharacterFrame" and
                                 "RESTEDXP_TRACKER_SUMMARY_WINDOW" or
                                 "RESTEDXP_TRACKER_INSPECTION_WINDOW"
    _G[specialFrameName] = trackerUi.frame
    tinsert(_G.UISpecialFrames, specialFrameName)

    local topContainer = AceGUI:Create("SimpleGroup")
    topContainer:SetLayout('Flow')

    trackerUi.levelButton = AceGUI:Create("Button")
    trackerUi.levelButton:SetRelativeWidth(0.45)

    trackerUi.levelButton:SetText(fmt(L("%d to %d"), playerLevel, playerLevel + 1))

    -- Stock 3.3.5 EasyMenu concatenates the dropdown's global name while
    -- creating its button regions. Anonymous frames therefore fail inside
    -- UIDropDownMenu.lua. Use one stable name per attachment so CharacterFrame
    -- and InspectFrame also cannot collide with each other.
    local levelMenuName = "RXPG_LevelMenuFrame_" ..
                              attachmentName:gsub("[^%w_]", "_")
    trackerUi.levelMenuFrame = CreateFrame("Frame", levelMenuName,
                                           trackerUi.levelButton.frame,
                                           "UIDropDownMenuTemplate")

    trackerUi.levelButton:SetCallback("OnClick", function()
        addon.tracker.UpdateReportLevels(trackerUi.levelData,
                                         trackerUi.playerLevel,
                                         trackerUi.targetName, attachment)
    end)

    topContainer:AddChild(trackerUi.levelButton)

    trackerUi.target = AceGUI:Create("Label")

    trackerUi.targetName = target
    trackerUi.levelData = levelData
    trackerUi.playerLevel = playerLevel
    trackerUi.target:SetText(target)
    trackerUi.target:SetJustifyH("CENTER")
    trackerUi.target:SetRelativeWidth(0.55)

    topContainer:AddChild(trackerUi.target)

    trackerUi.scrollContainer:AddChild(topContainer)

    -- Reached block
    trackerUi.reachedContainer = AceGUI:Create("SimpleGroup")
    trackerUi.reachedContainer:SetLayout("List")
    trackerUi.reachedContainer:SetFullWidth(true)

    trackerUi.reachedContainer.label = AceGUI:Create("Heading")
    trackerUi.reachedContainer.label:SetText(L("Reached Level") .. " " .. playerLevel)
    trackerUi.reachedContainer.label:SetFullWidth(true)

    trackerUi.reachedContainer:AddChild(trackerUi.reachedContainer.label)
    trackerUi.reachedContainer:AddChild(buildSpacer(padding))

    trackerUi.reachedContainer.data = AceGUI:Create("Label")
    trackerUi.reachedContainer.data:SetText(L("In-progress"))
    SetWidgetFont(trackerUi.reachedContainer.data, 12)
    trackerUi.reachedContainer.data:SetFullWidth(true)
    trackerUi.reachedContainer:AddChild(trackerUi.reachedContainer.data)

    trackerUi.scrollContainer:AddChild(trackerUi.reachedContainer)

    -- Speed block
    trackerUi.speedContainer = AceGUI:Create("SimpleGroup")
    trackerUi.speedContainer:SetLayout("List")
    trackerUi.speedContainer:SetFullWidth(true)

    trackerUi.speedContainer.label = AceGUI:Create("Heading")
    trackerUi.speedContainer.label:SetText(L("Time spent"))
    trackerUi.speedContainer.label:SetFullWidth(true)
    trackerUi.speedContainer:AddChild(trackerUi.speedContainer.label)
    trackerUi.speedContainer:AddChild(buildSpacer(padding))

    trackerUi.speedContainer.data = AceGUI:Create("Label")
    trackerUi.speedContainer.data:SetText(L("In-progress"))
    SetWidgetFont(trackerUi.speedContainer.data, 12)
    trackerUi.speedContainer.data:SetFullWidth(true)
    trackerUi.speedContainer:AddChild(trackerUi.speedContainer.data)

    trackerUi.scrollContainer:AddChild(trackerUi.speedContainer)

    -- Zones block
    -- Dynamic text needs to be in parent scrollframe, not a child SimpleGroup
    trackerUi.zonesContainer = {}

    trackerUi.zonesContainer.label = AceGUI:Create("Heading")
    trackerUi.zonesContainer.label:SetText(L("Zones & Dungeons"))
    trackerUi.zonesContainer.label:SetFullWidth(true)

    trackerUi.scrollContainer:AddChild(trackerUi.zonesContainer.label)

    trackerUi.zonesContainer.data = AceGUI:Create("Label")
    trackerUi.zonesContainer.data:SetText("")
    SetWidgetFont(trackerUi.zonesContainer.data, 12)
    trackerUi.zonesContainer.data:SetFullWidth(true)

    trackerUi.scrollContainer:AddChild(trackerUi.zonesContainer.data)

    -- Sources block
    trackerUi.sourcesContainer = AceGUI:Create("SimpleGroup")
    trackerUi.sourcesContainer:SetLayout("List")
    trackerUi.sourcesContainer:SetFullWidth(true)

    trackerUi.sourcesContainer.label = AceGUI:Create("Heading")
    trackerUi.sourcesContainer.label:SetText(L("Experience Sources"))
    trackerUi.sourcesContainer.label:SetFullWidth(true)

    trackerUi.sourcesContainer:AddChild(trackerUi.sourcesContainer.label)
    trackerUi.sourcesContainer:AddChild(buildSpacer(padding))

    trackerUi.sourcesContainer.data = {quests = AceGUI:Create("Label"), mobs = AceGUI:Create("Label")}

    trackerUi.sourcesContainer.data['quests']:SetText('quests')
    SetWidgetFont(trackerUi.sourcesContainer.data['quests'], 12)
    trackerUi.sourcesContainer.data['quests']:SetFullWidth(true)
    trackerUi.sourcesContainer:AddChild(trackerUi.sourcesContainer.data['quests'])
    trackerUi.sourcesContainer:AddChild(buildSpacer(padding))

    trackerUi.sourcesContainer.data['mobs']:SetText('mobs')
    SetWidgetFont(trackerUi.sourcesContainer.data['mobs'], 12)
    trackerUi.sourcesContainer.data['mobs']:SetFullWidth(true)
    trackerUi.sourcesContainer:AddChild(trackerUi.sourcesContainer.data['mobs'])

    trackerUi.scrollContainer:AddChild(trackerUi.sourcesContainer)

    -- Teamwork block
    trackerUi.teamworkContainer = AceGUI:Create("SimpleGroup")
    trackerUi.teamworkContainer:SetLayout("List")
    trackerUi.teamworkContainer:SetFullWidth(true)

    trackerUi.teamworkContainer.label = AceGUI:Create("Heading")
    trackerUi.teamworkContainer.label:SetText(L("Teamwork"))
    trackerUi.teamworkContainer.label:SetFullWidth(true)
    trackerUi.teamworkContainer:AddChild(trackerUi.teamworkContainer.label)
    trackerUi.teamworkContainer:AddChild(buildSpacer(padding))

    trackerUi.teamworkContainer.data = {}

    trackerUi.teamworkContainer.data['solo'] = AceGUI:Create("Label")
    trackerUi.teamworkContainer.data['solo']:SetText('solo')
    SetWidgetFont(trackerUi.teamworkContainer.data['solo'], 12)
    trackerUi.teamworkContainer.data['solo']:SetFullWidth(true)
    trackerUi.teamworkContainer:AddChild(trackerUi.teamworkContainer.data['solo'])
    trackerUi.teamworkContainer:AddChild(buildSpacer(padding))

    trackerUi.teamworkContainer.data['group'] = AceGUI:Create("Label")
    trackerUi.teamworkContainer.data['group']:SetText('group')
    SetWidgetFont(trackerUi.teamworkContainer.data['group'], 12)
    trackerUi.teamworkContainer.data['group']:SetFullWidth(true)
    trackerUi.teamworkContainer:AddChild(trackerUi.teamworkContainer.data['group'])

    trackerUi.scrollContainer:AddChild(trackerUi.teamworkContainer)

    -- Extras block
    trackerUi.extrasContainer = AceGUI:Create("SimpleGroup")
    trackerUi.extrasContainer:SetLayout("List")
    trackerUi.extrasContainer:SetFullWidth(true)

    trackerUi.extrasContainer.label = AceGUI:Create("Heading")
    trackerUi.extrasContainer.label:SetText(L("Extras"))
    trackerUi.extrasContainer.label:SetFullWidth(true)
    trackerUi.extrasContainer:AddChild(trackerUi.extrasContainer.label)
    trackerUi.extrasContainer:AddChild(buildSpacer(padding))

    trackerUi.extrasContainer.data = AceGUI:Create("Label")
    trackerUi.extrasContainer.data:SetText("")
    SetWidgetFont(trackerUi.extrasContainer.data, 12)
    trackerUi.extrasContainer.data:SetFullWidth(true)
    trackerUi.extrasContainer:AddChild(trackerUi.extrasContainer.data)

    trackerUi.scrollContainer:AddChild(trackerUi.extrasContainer)
end

function addon.tracker:ShowReport(attachment)
    if not attachment or not attachment.GetName then return end
    if not self.enabled or not addon.settings.profile.enableTracker then
        addon.comms.PrettyPrint("The Leveling Tracker is disabled.")
        return
    end
    local name = attachment:GetName()
    if not name then return end
    if not self.ui[name] then
        self:CreateGui(attachment, attachment == _G.CharacterFrame and
                           playerName or name)
    end
    local ui = self.ui[name]
    if not ui then
        addon.comms.PrettyPrint("Unable to open the Leveling Report.")
        return
    end
    ui:Show()
    ShowUIPanel(attachment)
end

function addon.tracker:CompileLevelData(level, d)
    local data = d or addon.tracker.db.profile["levels"][level]
    data = type(data) == "table" and data or {}
    local quests = type(data.quests) == "table" and data.quests or {}
    local mobs = type(data.mobs) == "table" and data.mobs or {}
    local timestamp = type(data.timestamp) == "table" and data.timestamp or {}

    local report = {questXP = 0, mobXP = 0, zoneXP = {}}

    local zoneXP = {}

    for zoneName, questData in pairs(quests) do
        if type(zoneName) == "string" and type(questData) == "table" then
            if not zoneXP[zoneName] then zoneXP[zoneName] = {xp = 0, name = zoneName} end
            for _, rawXP in pairs(questData) do
                local questXP = tonumber(rawXP)
                if questXP and questXP > 0 then
                    report.questXP = report.questXP + questXP
                    zoneXP[zoneName].xp = zoneXP[zoneName].xp + questXP
                end
            end
        end
    end

    for zoneName, mobData in pairs(mobs) do
        if type(zoneName) == "string" then
            local mobXP = type(mobData) == "table" and
                              tonumber(mobData.xp) or tonumber(mobData)
            if mobXP and mobXP > 0 then
                if not zoneXP[zoneName] then zoneXP[zoneName] = {xp = 0, name = zoneName} end
            report.mobXP = report.mobXP + mobXP
            zoneXP[zoneName].xp = zoneXP[zoneName].xp + mobXP
            end
        end
    end

    -- Turn dictionary into array
    for _, z in pairs(zoneXP) do tinsert(report.zoneXP, z) end

    -- Sort report.zoneXP highest to the top
    table.sort(report.zoneXP, function(a, b) return a.xp > b.xp end)

    report.groupExperience = mmax(0, tonumber(data.groupExperience) or 0)

    report.totalXP = report.mobXP + report.questXP

    report.groupExperience = math.min(report.groupExperience, report.totalXP)
    report.soloExperience = mmax(0, report.totalXP - report.groupExperience)

    report.timestamp = {
        started = tonumber(timestamp.started),
        finished = tonumber(timestamp.finished),
        duration = tonumber(timestamp.duration)
    }

    report.deaths = mmax(0, tonumber(data.deaths) or 0)

    if type(timestamp.dateStarted) == "table" then -- Level 1
        local date = timestamp.dateStarted
        local month = _G.CALENDAR_FULLDATE_MONTH_NAMES and
                          _G.CALENDAR_FULLDATE_MONTH_NAMES[tonumber(date.month)]
        if month and tonumber(date.monthDay) and tonumber(date.year) and
            tonumber(date.hour) and tonumber(date.minute) then
        report.timestamp.dateStarted = fmt("%s %d, %d at %d:%02d %s Server",
                                           month, date.monthDay, date.year,
                                           date.hour % 12, date.minute,
                                           date.hour >= 12 and "PM" or "AM")
        end
    end
    if type(timestamp.dateFinished) == "table" then
        local date = timestamp.dateFinished
        local month = _G.CALENDAR_FULLDATE_MONTH_NAMES and
                          _G.CALENDAR_FULLDATE_MONTH_NAMES[tonumber(date.month)]
        if month and tonumber(date.monthDay) and tonumber(date.year) and
            tonumber(date.hour) and tonumber(date.minute) then
        report.timestamp.dateFinished = fmt("%s %d, %d at %d:%02d %s Server",
                                            month, date.monthDay, date.year,
                                            date.hour % 12, date.minute,
                                            date.hour >= 12 and "PM" or "AM")
        end
    end

    return report
end

function addon.tracker:CompileData()
    self.reportData = {}
    local levels = self.db and self.db.profile and self.db.profile.levels
    for level, data in pairs(type(levels) == "table" and levels or {}) do
        local numericLevel = tonumber(level)
        if numericLevel then
            self.reportData[numericLevel] = self:CompileLevelData(numericLevel, data)
        end
    end

    return self.reportData
end

function addon.tracker:UpdateReport(selectedLevel, target, attachment)
    if not attachment then return end
    local trackerUi = addon.tracker.ui[attachment:GetName()]
    if not trackerUi then return end

    -- Do not support enabledFrames, large window not part of core functionality

    selectedLevel = tonumber(selectedLevel)
    if not selectedLevel then return end
    local remote = target and target ~= playerName
    local source = remote and self.state.otherReports[target] or nil
    local sourceReports = remote and source and source.reportData or
                              addon.tracker.reportData
    local report = type(sourceReports) == "table" and
                       sourceReports[selectedLevel]
    local reportPlayerLevel = remote and source and
                                  tonumber(source.playerLevel) or
                                  addon.tracker.playerLevel
    local reportClass = remote and source and source.playerClass or
                            addon.player.class
    local currentLevelTime = remote and source and
                                 tonumber(source.timePlayedThisLevel) or
                                 select(1, addon.tracker:GetElapsedTimes())

    if trackerUi.targetName ~= target then
        trackerUi.reportLevelMenu = nil
    end
    trackerUi.targetName = target
    trackerUi.levelData = sourceReports
    trackerUi.playerLevel = reportPlayerLevel
    trackerUi.target:SetText(target or playerName)

    if not report then
        addon.comms.PrettyPrint(L("Unable to retrieve report for") .. " %s", target)
        return
    end
    self.state.levelReportData = report

    if selectedLevel == reportPlayerLevel then
        if selectedLevel == addon.tracker.maxLevel then
            trackerUi.levelButton:SetText(fmt("%d (%s)", selectedLevel, L("Max")))
            trackerUi.reachedContainer.label:SetText(L("Reached max level"))
        else
            trackerUi.levelButton:SetText(fmt(L("%d to %d"), selectedLevel, selectedLevel + 1))
            trackerUi.reachedContainer.label:SetText(L("Started level ") .. selectedLevel)
        end

        trackerUi.speedContainer.data:SetText(
            type(currentLevelTime) == "number" and
                addon.comms:PrettyPrintTime(currentLevelTime) or
                "Missing data")

        if selectedLevel == 1 or (selectedLevel == 55 and reportClass == "DEATHKNIGHT") then
            trackerUi.reachedContainer.data:SetText(report.timestamp.dateStarted or
                                                        "Missing data")
        elseif sourceReports[selectedLevel - 1] then
            trackerUi.reachedContainer.data:SetText(
                sourceReports[selectedLevel - 1].timestamp.dateFinished or "Missing data")
        else
            trackerUi.reachedContainer.data:SetText(L("Missing data"))
        end
    else
        trackerUi.levelButton:SetText(fmt(L("%d to %d"), selectedLevel, selectedLevel + 1))
        trackerUi.reachedContainer.label:SetText(L("Reached Level ") .. selectedLevel + 1)

        trackerUi.reachedContainer.data:SetText(report.timestamp.dateFinished or "Missing data")

        local s = self:GetLevelDuration(selectedLevel, report)
        if s then
            trackerUi.speedContainer.data:SetText(addon.comms:PrettyPrintTime(s))
        else
            trackerUi.speedContainer.data:SetText(L("Missing data"))
        end

    end

    local ratio, percentage

    if selectedLevel == addon.tracker.maxLevel or report.totalXP <= 0 then
        trackerUi.teamworkContainer.data['solo']:SetText(fmt("* Solo: %s", 'N/A'))
        trackerUi.teamworkContainer.data['group']:SetText(fmt(L("* Group: %s"), 'N/A'))
    elseif report.groupExperience == 0 then
        trackerUi.teamworkContainer.data['solo']:SetText(fmt(L("* Solo: %.2f%%"), 100))
        trackerUi.teamworkContainer.data['group']:SetText(fmt(L("* Group: %.2f%%"), 0))
    elseif (report.soloExperience + report.groupExperience) == 0 then -- If division error
        trackerUi.teamworkContainer.data['solo']:SetText(fmt("* Solo: %d%%", 0))
        trackerUi.teamworkContainer.data['group']:SetText(fmt(L("* Group: %d%%"), 0))
    else
        ratio = report.groupExperience / (report.soloExperience + report.groupExperience)
        percentage = 100 * ratio
        trackerUi.teamworkContainer.data['solo']:SetText(fmt(L("* Solo: %.2f%%"), 100 - percentage))
        trackerUi.teamworkContainer.data['group']:SetText(fmt(L("* Group: %.2f%%"), percentage))
    end

    if selectedLevel == addon.tracker.maxLevel or report.totalXP <= 0 then
        trackerUi.sourcesContainer.data['quests']:SetText(fmt(L("* Quests: %s"), "N/A"))
        trackerUi.sourcesContainer.data['mobs']:SetText(fmt(L("* Killing: %s"), "N/A"))
    elseif report.questXP == 0 then
        trackerUi.sourcesContainer.data['quests']:SetText(fmt(L("* Quests: %.2f%%"), 0))
        trackerUi.sourcesContainer.data['mobs']:SetText(fmt(L("* Killing: %.2f%%"), 100))
    elseif (report.questXP + report.mobXP) == 0 then -- If division error
        trackerUi.sourcesContainer.data['quests']:SetText(fmt(L("* Quests: %d%%"), 0))
        trackerUi.sourcesContainer.data['mobs']:SetText(fmt(L("* Killing: %d%%"), 0))
    else
        ratio = report.mobXP / (report.questXP + report.mobXP)
        percentage = 100 * ratio
        trackerUi.sourcesContainer.data['quests']:SetText(fmt(L("* Quests: %.2f%%"), 100 - percentage))
        trackerUi.sourcesContainer.data['mobs']:SetText(fmt(L("* Killing: %.2f%%"), percentage))
    end

    local zonesBlock = ""
    if selectedLevel ~= addon.tracker.maxLevel and report.totalXP > 0 then
        for _, data in ipairs(type(report.zoneXP) == "table" and
                                  report.zoneXP or {}) do
            zonesBlock = fmt("%s* %s - %.1f%%\n", zonesBlock, data.name, data.xp * 100 / report.totalXP)
        end
    end
    trackerUi.zonesContainer.data:SetText(zonesBlock)

    local extrasBlock = ""
    extrasBlock = fmt("%s* %s: %s\n", extrasBlock, L("Deaths"), report.deaths or L("Missing data"))

    if selectedLevel ~= addon.tracker.maxLevel then
        local levelSeconds = selectedLevel == reportPlayerLevel and
                                 currentLevelTime or
                                 self:GetLevelDuration(selectedLevel, report)
        if levelSeconds and levelSeconds > 0 then
            local xpPerHour = report.totalXP / (levelSeconds / 60 / 60)

            extrasBlock = fmt("%s* %s: %d\n", extrasBlock,
                              L("Experience/hour"),
                              xpPerHour or "Missing data")
        end
    end

    trackerUi.extrasContainer.data:SetText(extrasBlock)

    trackerUi.scrollContainer:DoLayout()

end

function addon.tracker:PrintSplitsTime(s, isDelta)
    local prefix = s < 0 and '-' or ''
    if isDelta and s > 0 then prefix = '+' end

    s = abs(s)
    local hours = floor(s / 60 / 60)
    s = mod(s, 60 * 60)

    local minutes = floor(s / 60)
    s = mod(s, 60)

    local formattedString
    if hours > 0 then
        formattedString = fmt("%02d:%02d:%02d", hours, minutes, s)
    elseif minutes > 0 then
        formattedString = fmt("%02d:%02d", minutes, s)
    else
        formattedString = fmt("00:%02d", s)
    end

    return prefix .. formattedString
end

local gap = #fmt("%s 12    ", L("Level"))
function addon.tracker:BuildSplitsLevelLine(level, splitsString)
    local formattedString = fmt("%s %d%s%s%s", L("Level"), level, level < 10 and '  ' or '',
                                srep(' ', gap - #splitsString), splitsString)

    return formattedString
end

function addon.tracker:UpdateSplitsMenu(menuFrame, button)

    if addon.tracker.state.splitsMenu then
        EasyMenu(addon.tracker.state.splitsMenu, menuFrame, button, 0, 0, "MENU")
        return
    end

    local comparisonsMenu = {}

    local menu = {
        {
            text = _G.SHARE_QUEST_ABBREV,
            notCheckable = 1,
            func = function()
                addon.comms.OpenBrandedExport(fmt("%s %s", _G.SHARE_QUEST_ABBREV, L("Level Splits")), "",
                                              addon.tracker:BuildSplitsShare(), 20, 200)
            end
        }, {
            text = _G.GAMEOPTIONS_MENU,
            tooltipOnButton = true,
            notCheckable = 1,
            func = function() addon.settings.OpenSettings() end
        }, {
            text = _G.HIDE,
            tooltipTitle = L("Temporarily hide, use '/rxp splits' to show again"),
            tooltipOnButton = true,
            notCheckable = 1,
            func = function() addon.tracker.levelSplits:Hide() end
        }
    }

    tinsert(comparisonsMenu, {
        text = L("Export"),
        notCheckable = 1,
        func = function()
            addon.comms.OpenBrandedExport(L("Export Level Splits"),
                                          L("Export string for Importing into another character's comparison data"),
                                          addon.tracker:BuildSplitsExport(), 20, 200)
            _G.CloseDropDownMenus()
        end
    })

    tinsert(comparisonsMenu, {
        text = L("Import"),
        notCheckable = 1,
        func = function()
            addon.comms.OpenBrandedExport(L("Import Level Splits"), L("Import string from another character"), "", 20, 200,
                                          addon.tracker.ImportSplits)
            -- Regenerate menu on next load
            addon.tracker.state.splitsMenu = nil
            _G.CloseDropDownMenus()
        end
    })

    tinsert(comparisonsMenu, {text = _G.CHARACTER, notCheckable = 1, isTitle = true})

    local reports = addon.db.profile.reports
    local savedSplits = type(reports) == "table" and reports.splits or {}
    for k, d in pairs(savedSplits) do
        if k ~= self.reportKey and type(d) == "table" and
            type(d.title) == "string" and type(d.history) == "table" and
            type(d.history.levels) == "table" then
            tinsert(comparisonsMenu, {
                text = d.title,
                arg1 = k,
                func = function(_, key)
                    addon.tracker.state.splitsComparisonKey = key
                    _G.CloseDropDownMenus()
                    addon.tracker:UpdateLevelSplits("full")
                end,
                checked = function() return k == self.state.splitsComparisonKey end
            })
        end
    end

    tinsert(comparisonsMenu, {
        text = _G.NONE,
        func = function()
            addon.tracker.state.splitsComparisonKey = nil
            _G.CloseDropDownMenus()
            addon.tracker:UpdateLevelSplits("full")
        end,
        checked = function() return not self.state.splitsComparisonKey end
    })

    tinsert(menu, {
        text = L("Compare"), -- TODO localize
        hasArrow = true,
        menuList = comparisonsMenu,
        notCheckable = 1
    })

    tinsert(menu, {text = _G.CANCEL, notCheckable = 1, func = function() end})

    addon.tracker.state.splitsMenu = menu
    EasyMenu(menu, menuFrame, button, 0, 0, "MENU")
end

function addon.tracker:RenderSplitsBackground()
    if not addon.tracker.levelSplits then return end

    local f = addon.tracker.levelSplits

    if addon.settings.profile.hideSplitsBackground then
        f:ClearBackdrop()
    else
        f:ClearBackdrop()
        f:SetBackdrop(addon.RXPFrame.backdrop.edge)
        f:SetBackdropColor(unpack(addon.colors.background))
    end
end

function addon.tracker:CreateLevelSplits()
    if addon.tracker.levelSplits then
        self:UpdateLevelSplits("full")
        if addon.settings.profile.enableTracker and
            addon.settings.profile.enablelevelSplits and
            addon.settings.profile.showEnabled and
            not IsLegacyWorldMapOpen() then
            addon.tracker.levelSplits:Show()
        end
        return
    end
    -- AceGUI:Create("Frame") has too much magic for how simple this is
    local BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate"
    local anchor = UIParent

    local f = CreateFrame("Frame", "RXPLevelSplits", anchor, BackdropTemplate)

    addon.tracker.levelSplits = f
    addon.enabledFrames["levelSplits"] = f
    f.IsFeatureEnabled = function()
        return addon.settings.profile.enableTracker and
                   addon.settings.profile.enablelevelSplits, false
    end
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:SetMovable(true)
    function f.onMouseDown() f:StartMoving() end
    function f.onMouseUp()
        f:StopMovingOrSizing()
        addon.settings:SaveFramePositions()
    end
    f:SetScript("OnMouseDown", f.StartMoving)
    f:SetScript("OnMouseUp", f.StopMovingOrSizing)

    self:RenderSplitsBackground()

    f.parent = addon
    f:SetPoint("CENTER", anchor, "CENTER", 0, 0)
    -- Disable background texture for now, inconsistently loads
    --[[
    f.bg = f:CreateTexture("RXPLevelSplitsFrameBG", "BACKGROUND")
    f.bg:SetTexture(addon.GetTexture("rxp-banner"))
    f.bg:SetPoint("TOPLEFT", 4, -2)
    f.bg:SetPoint("BOTTOMRIGHT", -2, 4)
    ]]

    f.title = CreateFrame("Frame", "$parent_title", f, BackdropTemplate)
    f.title:ClearAllPoints()
    f.title:EnableMouse(true)
    f.title:SetScript("OnMouseDown", f.onMouseDown)
    f.title:SetScript("OnMouseUp", f.onMouseUp)

    f.title:ClearBackdrop()
    f.title:SetBackdrop(addon.RXPFrame.backdrop.edge)
    f.title:SetBackdropColor(unpack(addon.colors.background))
    -- Disable background texture for now, inconsistently loads
    --[[
    f.title.bg = f.title:CreateTexture("$parent_titleBG", "BACKGROUND")
    f.title.bg:SetTexture(addon.GetTexture("rxp-banner"))
    f.title.bg:SetPoint("TOPLEFT", 4, -2)
    f.title.bg:SetPoint("BOTTOMRIGHT", -2, 4)
    ]]

    f.title:SetPoint("TOP", f, 0, 5)
    -- Width immediately overwritten in UpdateLevelSplits on PLAYER_ENTERING_WORLD
    f.title:SetSize(80, 17)

    f.title.splitsMenuFrame = CreateFrame("Frame", "RXPG_SplitsMenuFrame", f.title, "UIDropDownMenuTemplate")

    f.title.cog = CreateFrame("Button", "$parentCogwheel", f.title)
    f.title.cog:SetFrameLevel(f.title:GetFrameLevel() + 1)
    f.title.cog:SetWidth(18)
    f.title.cog:SetHeight(18)
    f.title.cog:SetPoint("LEFT", f.title, "LEFT", -9, 0)
    f.title.cog:SetNormalTexture(addon.GetTexture("rxp_cog-32"))
    f.title.cog:SetHighlightTexture("Interface/MINIMAP/UI-Minimap-ZoomButton-Highlight", "ADD")
    f.title.cog:Show()

    f.title.cog:SetScript("OnClick", function() addon.tracker:UpdateSplitsMenu(f.title.splitsMenuFrame, f.title.cog) end)

    f.title.text = f.title:CreateFontString(nil, "OVERLAY")
    f.title.text:ClearAllPoints()
    f.title.text:SetJustifyH("CENTER")
    f.title.text:SetJustifyV("MIDDLE")
    f.title.text:SetTextColor(unpack(addon.activeTheme.textColor))
    f.title.text:SetFont(addon.font, 9, "")
    f.title.text:SetText(L("Level splits"))
    f.title.text:SetPoint("CENTER", f.title, 0, 1)

    f.history = AceGUI:Create("Label")
    f.history:SetFont(self.fonts.splits, addon.settings.profile.levelSplitsFontSize, "")
    f.history:SetFullWidth(true)
    f.history.frame:SetParent(f)
    f.history.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -(f.title:GetHeight() / 2 + 2))
    f.history.frame:Show()
    f.history:SetText("")

    f.current = AceGUI:Create("Label")
    f.current:SetFont(self.fonts.splits, addon.settings.profile.levelSplitsFontSize, "")
    f.current:SetFullWidth(true)
    f.current.frame:SetParent(f)
    f.current.frame:SetPoint("TOPLEFT", f.history.frame, "BOTTOMLEFT", 0, -8)
    f.current.frame:Show()
    f.current:SetText("")

    f.total = AceGUI:Create("Label")
    f.total:SetFont(self.fonts.splits, addon.settings.profile.levelSplitsFontSize, "")
    f.total:SetFullWidth(true)
    f.total.frame:SetParent(f)
    f.total.frame:SetPoint("TOPLEFT", f.current.frame, "BOTTOMLEFT", 0, 0)
    f.total.frame:Show()
    f.total:SetText("")

    -- Immediately overwritten in UpdateLevelSplits on PLAYER_ENTERING_WORLD
    f:SetSize(100, 48)

    f:SetAlpha(addon.settings.profile.levelSplitsOpacity)
    f.title:SetIgnoreParentAlpha(true)
    if addon.settings.profile.levelSplitsOpacity + 0.1 > 1.0 then
        f.title:SetAlpha(1)
    else
        f.title:SetAlpha(addon.settings.profile.levelSplitsOpacity + 0.1)
    end

    f:HookScript("OnUpdate", function() addon.tracker:RefreshSplitsSummary() end)

    f:SetScript("OnShow", function(frame)
        -- The 3.3.5 world map occupies nearly the whole screen. Keep the
        -- independently movable splits frame from covering it, including when
        -- another setting or restore path tries to show the frame while the map
        -- is already open.
        if IsLegacyWorldMapOpen() then
            frame.hiddenForLegacyMap = true
            frame:Hide()
            return
        end
        addon.tracker:UpdateLevelSplits("full")
    end)

    if addon.gameVersion == 30300 and _G.WorldMapFrame and
        _G.WorldMapFrame.HookScript then
        _G.WorldMapFrame:HookScript("OnShow", function()
            if f:IsShown() then
                f.hiddenForLegacyMap = true
                f:Hide()
            end
        end)
        _G.WorldMapFrame:HookScript("OnHide", function()
            if not f.hiddenForLegacyMap then return end

            f.hiddenForLegacyMap = nil
            if addon.settings.profile.enablelevelSplits and
                addon.settings.profile.showEnabled then
                f:Show()
            end
        end)

        -- CreateFrame starts shown, so OnShow will not run when this handler is
        -- installed after the map has already opened.
        if IsLegacyWorldMapOpen() then
            f.hiddenForLegacyMap = true
            f:Hide()
        end
    end

    -- Populate now: OnShow does not fire for a frame that is created already
    -- shown, so without this the splits window is blank at login until the user
    -- toggles it off and on (which finally triggers OnShow).
    self:UpdateLevelSplits("full")
end

function addon.tracker:ToggleLevelSplits()
    if InCombatLockdown() or not addon.settings.profile.enablelevelSplits then return end

    -- Already built
    if self.levelSplits then
        if IsLegacyWorldMapOpen() then
            -- Treat toggles made while the map is open as changing the desired
            -- post-map state without allowing the window to overlap the map.
            self.levelSplits.hiddenForLegacyMap =
                not self.levelSplits.hiddenForLegacyMap
            return
        end

        if self.levelSplits:IsShown() then
            self.levelSplits:Hide()
        else
            self.levelSplits:Show()
        end

        return
    end
end

function addon.tracker:RefreshSplitsSummary()
    if not self.state.lastSplitsUpdate then
        self.state.lastSplitsUpdate = GetTime()
        addon.tracker:UpdateLevelSplits("full")
        return
    end

    local now = GetTime()
    if (now - self.state.lastSplitsUpdate) > 1 then
        self.state.lastSplitsUpdate = now
        addon.tracker:UpdateLevelSplits()
    end
end

function addon.tracker:CompileLevelSplits(kind)
    local splitsReportData = {
        title = fmt("%s (%s) - %s", playerName, addon.player.class, _G.GetRealmName()),
        reportKey = fmt("%s|%s|%s", playerName, addon.player.class, _G.GetRealmName())
    }
    local s
    local currentLevelTime, currentTotalTime = self:GetElapsedTimes()

    if addon.tracker.playerLevel == addon.tracker.maxLevel then
        -- Leave creation or full placeholder on updates
        if kind == "full" then
            splitsReportData.current = {text = fmt("%s: Max", L("Level Time"))}

            s = currentTotalTime
            splitsReportData.total = {
                text = fmt("%s %d: %s", L("Time to"), addon.tracker.maxLevel,
                           addon.tracker:PrintSplitsTime(s)),
                duration = s
            }
        end
    else
        s = currentLevelTime
        splitsReportData.current = {
            text = fmt("%s: %s", L("Level Time"), addon.tracker:PrintSplitsTime(s)),
            duration = s
        }

        s = currentTotalTime
        splitsReportData.total = {text = fmt("%s: %s", L("Total Time"), addon.tracker:PrintSplitsTime(s)), duration = s}
    end

    if kind == "full" then
        local data
        local splitsData = {levels = {}}
        local totalSeconds = 0

        for l = 1, addon.tracker.playerLevel - 1 do
            data = addon.tracker.reportData[l]

            if data then
                s = self:GetLevelDuration(l, data)
                if s then
                        totalSeconds = totalSeconds + s

                        splitsData.levels[l] = {
                            text = self:BuildSplitsLevelLine(l + 1, addon.tracker:PrintSplitsTime(totalSeconds)),
                            duration = s,
                            totalDuration = totalSeconds
                        }
                else
                    splitsData.levels[l] = {text = self:BuildSplitsLevelLine(l + 1, '-')}
                end
            end
        end

        splitsReportData.history = splitsData

        addon.db.profile.reports =
            type(addon.db.profile.reports) == "table" and
                addon.db.profile.reports or {}
        addon.db.profile.reports.splits =
            type(addon.db.profile.reports.splits) == "table" and
                addon.db.profile.reports.splits or {}
        addon.db.profile.reports.splits[self.reportKey] = splitsReportData
    end

    return splitsReportData
end

local w = #"  -00:00:00"
local function printDelta(mine, theirs)
    if not mine or not theirs then return fmt("%s%s", srep(' ', w - #'-'), '-') end

    local diff = mine - theirs
    local diffString = addon.tracker:PrintSplitsTime(diff, 'delta')

    diffString = fmt("%s%s", srep(' ', w - #diffString), diffString)

    if diff < 0 then
        return fmt("|cff00aa00%s|r", diffString)
    elseif diff > 0 then
        return fmt("|cffff0000%s|r", diffString)
    end

    -- Even time, use default color
    return diffString
end

function addon.tracker:UpdateLevelSplits(kind)
    if not addon.settings.profile.enableTracker or
        not addon.settings.profile.enablelevelSplits or
        not addon.tracker.levelSplits or not addon.tracker.state.login or
        not addon.settings.profile.showEnabled then return end

    local f = addon.tracker.levelSplits
    local reportSplitsData = self:CompileLevelSplits(kind)
    local reports = addon.db.profile.reports
    local savedSplits = type(reports) == "table" and reports.splits or {}
    local compareTo = self.state.splitsComparisonKey and
                          savedSplits[self.state.splitsComparisonKey]
    if compareTo and (type(compareTo) ~= "table" or
        type(compareTo.history) ~= "table" or
        type(compareTo.history.levels) ~= "table") then
        compareTo = nil
        self.state.splitsComparisonKey = nil
        self.state.splitsMenu = nil
    end

    if self.playerLevel == self.maxLevel then
        -- Leave creation or full placeholder on updates
        if kind == "full" then
            f.current:SetText(reportSplitsData.current.text)

            -- If max level and compareTo level exists, compare total time
            if compareTo and compareTo.total and compareTo.total.duration then
                f.total:SetText(fmt("%s %s", reportSplitsData.total.text,
                                    printDelta(reportSplitsData.total.duration, compareTo.total.duration)))
            else
                f.total:SetText(reportSplitsData.total.text)
            end
        end
    else
        if compareTo and compareTo.history and compareTo.history.levels and
            compareTo.history.levels[self.playerLevel + 1] and
            compareTo.current and compareTo.current.duration and
            addon.settings.profile.compareNextLevelSplit then
            local splitsTime = self:PrintSplitsTime(compareTo.history.levels[self.playerLevel + 1].duration)
            local cTime = self:BuildSplitsLevelLine(self.playerLevel + 1, splitsTime)

            f.current:SetText(fmt("%s %s\n\n%s", cTime,
                                  printDelta(reportSplitsData.current.duration, compareTo.current.duration),
                                  reportSplitsData.current.text))
        else
            f.current:SetText(reportSplitsData.current.text)
        end

        f.total:SetText(reportSplitsData.total.text)
    end

    if kind == "full" then
        local oldestLevel = self.playerLevel - addon.settings.profile.levelSplitsHistory
        local highestLevel = self.playerLevel - 1
        local data, splitsString, cData, deltaString

        for l = oldestLevel, highestLevel do
            data = reportSplitsData.history.levels[l]
            cData = compareTo and compareTo.history and
                        compareTo.history.levels and
                        compareTo.history.levels[l]

            if data then
                if splitsString then
                    if compareTo then
                        if addon.settings.profile.compareTotalTimeSplit then
                            deltaString = printDelta(data.totalDuration, cData and cData.totalDuration or nil)
                        else
                            deltaString = printDelta(data.duration, cData and cData.duration or nil)
                        end
                        splitsString = fmt("%s\n%s %s", splitsString, data.text, deltaString)
                    else
                        splitsString = fmt("%s\n%s", splitsString, data.text)
                    end
                else
                    if compareTo then
                        if addon.settings.profile.compareTotalTimeSplit then
                            deltaString = printDelta(data.totalDuration, cData and cData.totalDuration or nil)
                        else
                            deltaString = printDelta(data.duration, cData and cData.duration or nil)
                        end
                        splitsString = fmt("%s %s", data.text, deltaString)
                    else
                        splitsString = data.text
                    end
                end
            end
        end

        f.history:SetText(splitsString or "")
    end

    local _, rawCurrentFontSize = f.current.label:GetFont()
    local currentFontSize = math.floor((tonumber(rawCurrentFontSize) or 0) +
                                           0.5)

    if currentFontSize ~= addon.settings.profile.levelSplitsFontSize then
        -- Font size changed, set new size before calculating width/height
        f.current:SetFont(self.fonts.splits, addon.settings.profile.levelSplitsFontSize, "")
        f.history:SetFont(self.fonts.splits, addon.settings.profile.levelSplitsFontSize, "")
        f.total:SetFont(self.fonts.splits, addon.settings.profile.levelSplitsFontSize, "")
    end

    local width =
        max(f.current.label:GetStringWidth(), f.history.label:GetStringWidth(), f.total.label:GetStringWidth())

    -- Frame heights plus offsets plus borders
    local height = f.current.label:GetStringHeight() + f.history.label:GetStringHeight() +
                       f.total.label:GetStringHeight() + 26

    if kind ~= "full" and currentFontSize == addon.settings.profile.levelSplitsFontSize then
        -- Font unchanged
        -- Only update width if next is wider, prevent jittering
        f.title:SetWidth(max(f.title:GetWidth(), width))
        f:SetSize(max(f:GetWidth(), width + 16), height)
    else
        f.title:SetWidth(width)
        f:SetSize(width + 16, height)
    end

    if f:GetAlpha() ~= addon.settings.profile.levelSplitsOpacity then
        f:SetAlpha(addon.settings.profile.levelSplitsOpacity)
        f.title:SetAlpha(math.min(1,
                                  addon.settings.profile.levelSplitsOpacity +
                                      0.1))
    end

    -- Remove refresh after the first full update at max level
    if self.playerLevel == self.maxLevel and kind == "full" then self.levelSplits:SetScript("OnUpdate", nil) end
end

function addon.tracker:BuildSplitsShare()
    local reportSplitsData = self:CompileLevelSplits("full")

    local splitsString = fmt("%s\n", reportSplitsData.title)

    if reportSplitsData.current.duration then
        splitsString = fmt("%s\n" .. L("Level %d time") .. ": %s\n", splitsString, addon.tracker.playerLevel,
                           addon.tracker:PrintSplitsTime(reportSplitsData.current.duration))
    end

    local data

    for l = 1, addon.tracker.playerLevel - 1 do
        data = reportSplitsData.history.levels[l]

        if data then splitsString = fmt("%s\n%s", splitsString, data.text) end
    end

    splitsString = fmt("%s\n\n%s", splitsString, reportSplitsData.total.text)

    return splitsString
end

function addon.tracker:BuildSplitsExport()
    local reportSplitsData = self:CompileLevelSplits("full")
    local portable = {
        currentLevel = self.playerLevel,
        maxLevel = self.maxLevel,
        playerClass = tostring(addon.player.class or "UNKNOWN"):sub(1, 24),
        currentDuration = reportSplitsData.current and
                              tonumber(reportSplitsData.current.duration),
        totalDuration = reportSplitsData.total and
                            tonumber(reportSplitsData.total.duration),
        levels = {}
    }
    local history = reportSplitsData.history and
                        reportSplitsData.history.levels or {}
    for level, data in pairs(history) do
        if type(data) == "table" then
            portable.levels[level] = {
                duration = tonumber(data.duration),
                totalDuration = tonumber(data.totalDuration)
            }
        end
    end
    local payload = addon.comms:Serialize(portable)
    local envelope = addon.comms:Serialize({
        kind = "RXP_LEVEL_SPLITS",
        version = 1,
        checksum = LibDeflate:Adler32(payload),
        payload = payload
    })
    return LibDeflate:EncodeForPrint(LibDeflate:CompressDeflate(envelope))
end

local function BuildImportedSplits(raw)
    if type(raw) ~= "table" then return end
    local currentLevel = tonumber(raw.currentLevel)
    local maxLevel = tonumber(raw.maxLevel) or GetMaxPlayerLevel()
    local rawLevels = raw.levels

    -- Accept historical RXP exports, but rebuild every display string and key
    -- so imported data cannot retain a player or realm identifier.
    if type(raw.history) == "table" then
        rawLevels = raw.history.levels
        local highest = 0
        for level in pairs(type(rawLevels) == "table" and rawLevels or {}) do
            highest = math.max(highest, tonumber(level) or 0)
        end
        currentLevel = currentLevel or highest + 1
        raw.currentDuration = raw.current and raw.current.duration
        raw.totalDuration = raw.total and raw.total.duration
    end

    currentLevel = math.floor(currentLevel or 0)
    maxLevel = math.floor(maxLevel or 0)
    if currentLevel < 1 or currentLevel > MAX_REPORT_LEVELS or maxLevel < 1 or
        maxLevel > MAX_REPORT_LEVELS or type(rawLevels) ~= "table" then return end

    local result = {
        title = fmt("Imported %s - Level %d",
                    tostring(raw.playerClass or "Run"):sub(1, 24),
                    currentLevel),
        current = {},
        total = {},
        history = {levels = {}}
    }
    local currentDuration = tonumber(raw.currentDuration)
    if currentDuration and currentDuration >= 0 and
        currentDuration < MAX_LEVEL_DURATION then
        result.current.duration = currentDuration
        result.current.text = fmt("%s: %s", L("Level Time"),
                                  addon.tracker:PrintSplitsTime(currentDuration))
    else
        result.current.text = fmt("%s: -", L("Level Time"))
    end
    local totalDuration = tonumber(raw.totalDuration)
    if totalDuration and totalDuration >= 0 and
        totalDuration < 365 * 24 * 60 * 60 then
        result.total.duration = totalDuration
        result.total.text = fmt("%s: %s", L("Total Time"),
                                addon.tracker:PrintSplitsTime(totalDuration))
    else
        result.total.text = fmt("%s: -", L("Total Time"))
    end

    local count = 0
    for rawLevel, rawData in pairs(rawLevels) do
        local level = tonumber(rawLevel)
        if level and level >= 1 and level <= MAX_REPORT_LEVELS and
            type(rawData) == "table" then
            level = math.floor(level)
            local duration = tonumber(rawData.duration)
            local accumulated = tonumber(rawData.totalDuration)
            if duration and duration > 0 and duration < MAX_LEVEL_DURATION then
                count = count + 1
                if count > MAX_REPORT_LEVELS then return end
                local entry = {duration = duration}
                if accumulated and accumulated > 0 and
                    accumulated < 365 * 24 * 60 * 60 then
                    entry.totalDuration = accumulated
                end
                entry.text = addon.tracker:BuildSplitsLevelLine(
                                 level + 1,
                                 addon.tracker:PrintSplitsTime(
                                     entry.totalDuration or duration))
                result.history.levels[level] = entry
            end
        end
    end
    return result
end

function addon.tracker.ImportSplits(encodedText)
    if type(encodedText) ~= "string" or #encodedText == 0 or
        #encodedText > MAX_IMPORT_BYTES then
        addon.comms.PrettyPrint("Invalid or oversized data")
        return
    end
    local decoded = LibDeflate:DecodeForPrint(encodedText)

    if not decoded or #decoded > MAX_IMPORT_BYTES then
        addon.comms.PrettyPrint("Invalid data")
        return
    end
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if type(decompressed) ~= "string" or #decompressed > MAX_IMPORT_BYTES then
        addon.comms.PrettyPrint("Invalid or oversized data")
        return
    end

    local deserializeResult, deserialized = addon.comms:Deserialize(decompressed)

    if not deserializeResult then
        addon.comms.PrettyPrint("Error Importing: " .. deserialized)
        return
    end

    local checksum
    if type(deserialized) == "table" and
        deserialized.kind == "RXP_LEVEL_SPLITS" then
        if deserialized.version ~= 1 or type(deserialized.payload) ~= "string" or
            #deserialized.payload > MAX_IMPORT_BYTES or
            tonumber(deserialized.checksum) ~=
                LibDeflate:Adler32(deserialized.payload) then
            addon.comms.PrettyPrint("Invalid level-splits checksum or version")
            return
        end
        checksum = tonumber(deserialized.checksum)
        local ok
        ok, deserialized = addon.comms:Deserialize(deserialized.payload)
        if not ok then
            addon.comms.PrettyPrint("Invalid level-splits payload")
            return
        end
    else
        checksum = LibDeflate:Adler32(decompressed)
    end

    local imported = BuildImportedSplits(deserialized)
    if not imported then
        addon.comms.PrettyPrint("Invalid level-splits structure")
        return
    end
    addon.db.profile.reports = type(addon.db.profile.reports) == "table" and
                                   addon.db.profile.reports or {}
    addon.db.profile.reports.splits =
        type(addon.db.profile.reports.splits) == "table" and
            addon.db.profile.reports.splits or {}
    local reportKey = fmt("imported:%u:%d", checksum or 0, time())
    imported.reportKey = reportKey
    addon.comms.PrettyPrint("Importing %s", imported.title)
    addon.db.profile.reports.splits[reportKey] = imported
    addon.tracker.state.splitsMenu = nil

    return true
end

local function NormalizeRemoteReports(raw)
    if type(raw) ~= "table" then return end
    local reports, count = {}, 0
    for rawLevel, data in pairs(raw) do
        local level = tonumber(rawLevel)
        if level and level >= 1 and level <= MAX_REPORT_LEVELS and
            type(data) == "table" then
            count = count + 1
            if count > MAX_REPORT_LEVELS then return end
            level = math.floor(level)
            local questXP = mmax(0, tonumber(data.questXP) or 0)
            local mobXP = mmax(0, tonumber(data.mobXP) or 0)
            local totalXP = questXP + mobXP
            local groupXP = math.min(totalXP,
                                      mmax(0, tonumber(data.groupExperience) or 0))
            local report = {
                questXP = questXP,
                mobXP = mobXP,
                totalXP = totalXP,
                groupExperience = groupXP,
                soloExperience = totalXP - groupXP,
                deaths = mmax(0, tonumber(data.deaths) or 0),
                timestamp = {},
                zoneXP = {}
            }
            local timestamp = type(data.timestamp) == "table" and
                                  data.timestamp or {}
            report.timestamp.started = tonumber(timestamp.started)
            report.timestamp.finished = tonumber(timestamp.finished)
            report.timestamp.duration = tonumber(timestamp.duration)
            if type(timestamp.dateStarted) == "string" then
                report.timestamp.dateStarted = timestamp.dateStarted:sub(1, 128)
            end
            if type(timestamp.dateFinished) == "string" then
                report.timestamp.dateFinished = timestamp.dateFinished:sub(1, 128)
            end
            local zoneCount = 0
            for _, zone in ipairs(type(data.zoneXP) == "table" and
                                      data.zoneXP or {}) do
                if type(zone) == "table" and type(zone.name) == "string" then
                    local xp = tonumber(zone.xp)
                    if xp and xp >= 0 then
                        zoneCount = zoneCount + 1
                        if zoneCount > 100 then return end
                        tinsert(report.zoneXP, {
                            name = zone.name:sub(1, 96),
                            xp = math.min(xp, totalXP)
                        })
                    end
                end
            end
            reports[level] = report
        end
    end
    return reports
end

function addon.tracker:OnCommReceived(prefix, data, distribution, sender)
    if prefix ~= self._commPrefix or distribution ~= 'WHISPER' or
        type(data) ~= "string" or #data > MAX_COMM_BYTES or
        type(sender) ~= "string" or sender == "" then return end
    if not addon.settings.profile.enableLevelingReportInspections or
        not addon.settings.profile.enableBetaFeatures then return end

    if UnitInBattleground("player") ~= nil then return end

    local status, obj = self:Deserialize(data)

    addon.comms.PrettyDebug("Deserialize:status %s", tostring(status))
    if not status or type(obj) ~= "table" or
        type(obj.command) ~= "string" or obj.version ~= COMM_VERSION then
        return
    end

    if obj.command == 'LEVEL_REPORT_REQ' then
        local currentLevelTime = self:GetElapsedTimes()

        local sz = self:Serialize({
            command = 'LEVEL_REPORT_RESP',
            version = COMM_VERSION,
            reportData = self:CompileData(),
            compileTime = GetServerTime(),
            playerLevel = addon.tracker.playerLevel,
            playerClass = addon.player.class,
            timePlayedThisLevel = currentLevelTime
        })

        addon.comms.PrettyDebug("Responding to LEVEL_REPORT_REQ, from %s", sender)
        if #sz <= MAX_COMM_BYTES then
            self:SendCommMessage(self._commPrefix, sz, "WHISPER", sender)
        else
            addon.comms.PrettyDebug("Level report is too large to transmit safely")
        end
    elseif obj.command == 'LEVEL_REPORT_RESP' then
        local requestedAt = self.state.pendingInspectionNames[sender]
        if not requestedAt or GetTime() - requestedAt > 30 then return end
        self.state.pendingInspectionNames[sender] = nil
        local reports = NormalizeRemoteReports(obj.reportData)
        local playerLevel = tonumber(obj.playerLevel)
        local compileTime = tonumber(obj.compileTime)
        if not reports or not playerLevel or playerLevel < 1 or
            playerLevel > MAX_REPORT_LEVELS or not compileTime or
            compileTime < 0 or compileTime > GetServerTime() + 300 then return end
        addon.comms.PrettyDebug("Caching LEVEL_REPORT_RESP, from %s at %s", sender, obj.compileTime)

        self.state.otherReports[sender] = {
            reportData = reports,
            compileTime = compileTime,
            playerLevel = math.floor(playerLevel),
            playerClass = type(obj.playerClass) == "string" and
                              obj.playerClass:sub(1, 24) or "UNKNOWN",
            timePlayedThisLevel = mmax(0,
                tonumber(obj.timePlayedThisLevel) or 0)
        }
        if _G.InspectFrame then
            self:CreateGui(_G.InspectFrame, sender)
            self:UpdateReport(playerLevel, sender, _G.InspectFrame)
            self:ShowReport(_G.InspectFrame)
        end
    else
        addon.comms.PrettyDebug("Unknown command (%s)", obj.command)
    end
end

function addon.tracker:INSPECT_READY(_, inspecteeGUID)
    if not addon.settings.profile.enableLevelingReportInspections then return end

    if UnitInBattleground("player") ~= nil or not self.state.inspectionRequests[inspecteeGUID] then return end

    local inspectedName = select(6, GetPlayerInfoByGUID(inspecteeGUID))
    self.state.inspectionRequests[inspecteeGUID] = nil
    if type(inspectedName) ~= "string" or inspectedName == "" then return end
    if self.state.otherReports[inspectedName] and self.state.otherReports[inspectedName].compileTime and GetServerTime() -
        self.state.otherReports[inspectedName].compileTime < 30 then

        addon.comms.PrettyDebug("Displaying cached data for %s from %.2f seconds ago", inspectedName,
                                GetServerTime() - self.state.otherReports[inspectedName].compileTime)

        if _G.InspectFrame then
            local cached = self.state.otherReports[inspectedName]
            self:CreateGui(_G.InspectFrame, inspectedName)
            self:UpdateReport(cached.playerLevel, inspectedName,
                              _G.InspectFrame)
            self:ShowReport(_G.InspectFrame)
        end
        return
    end

    self.state.pendingInspectionNames[inspectedName] = GetTime()
    local sz = self:Serialize({
        command = "LEVEL_REPORT_REQ",
        version = COMM_VERSION
    })
    self:SendCommMessage(self._commPrefix, sz, "WHISPER", inspectedName)
end
