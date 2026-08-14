local _, addon = ...

addon.xpAssistant = addon.xpAssistant or {}
local assistant = addon.xpAssistant

local _G = _G
local format = string.format
local floor, max, min = math.floor, math.max, math.min
local tinsert, tremove = table.insert, table.remove
local L = addon.locale.Get
local OWNER = "xp-assistant"
local MAX_SAMPLES = 20
local REQUIRED_SAMPLES = 3
local CORRELATION_SECONDS = 1.5
local SNAPSHOT_SECONDS = 45
local MAX_SNAPSHOTS = 50
local XP_MODIFIER_SLOTS = {[3] = true, [5] = true, [11] = true, [12] = true}
local ADAPTIVE_EVENTS = {
    "CHAT_MSG_COMBAT_XP_GAIN", "COMBAT_LOG_EVENT_UNFILTERED",
    "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT",
    "PLAYER_EQUIPMENT_CHANGED",
}

local CLASSIC_INSTANCES = {
    [33] = true, [34] = true, [36] = true, [43] = true,
    [47] = true, [48] = true, [70] = true, [90] = true,
    [109] = true, [129] = true, [189] = true, [209] = true,
    [229] = true, [230] = true, [249] = true, [289] = true,
    [309] = true, [329] = true, [349] = true, [389] = true,
    [409] = true, [429] = true, [469] = true, [509] = true,
    [531] = true,
}
local TBC_INSTANCES = {
    [269] = true, [532] = true, [534] = true, [540] = true,
    [542] = true, [543] = true, [544] = true, [545] = true,
    [546] = true, [547] = true, [548] = true, [550] = true,
    [552] = true, [553] = true, [554] = true, [555] = true,
    [556] = true, [557] = true, [558] = true, [560] = true,
    [564] = true, [565] = true, [568] = true, [580] = true,
    [585] = true,
}
local WOTLK_INSTANCES = {
    [533] = true, [574] = true, [575] = true, [576] = true,
    [578] = true, [595] = true, [599] = true, [600] = true,
    [601] = true, [602] = true, [603] = true, [604] = true,
    [608] = true, [615] = true, [616] = true, [619] = true,
    [624] = true, [631] = true, [632] = true, [649] = true,
    [650] = true, [658] = true, [668] = true, [724] = true,
}
local OUTLAND_WORLD_MAPS = {
    [1944] = true, [1945] = true, [1946] = true, [1948] = true,
    [1949] = true, [1951] = true, [1952] = true, [1953] = true,
    [1955] = true, [1957] = true,
}
-- These zones live in expansion map files but their WorldMapArea virtual map
-- is Azeroth, which is also what AzerothCore uses for ContentLevels.
local CLASSIC_EXPANSION_WORLD_MAPS = {
    [1941] = true, [1942] = true, [1943] = true,
    [1947] = true, [1950] = true, [1954] = true,
}
local NORTHREND_WORLD_MAPS = {
    [113] = true, [114] = true, [115] = true, [116] = true,
    [117] = true, [118] = true, [119] = true, [120] = true,
    [121] = true, [123] = true, [124] = true, [125] = true,
    [127] = true, [170] = true,
}

local function IsFinite(value)
    return type(value) == "number" and value == value and
               value > -math.huge and value < math.huge
end

local function ShortNumber(value)
    value = max(0, tonumber(value) or 0)
    if value >= 1000000 then return format("%.2fm", value / 1000000) end
    if value >= 1000 then return format("%.1fk", value / 1000) end
    return format("%d", floor(value + 0.5))
end

local function ExactNumber(value)
    return format("%d", max(0, floor(tonumber(value) or 0)))
end

local function ClearTable(target)
    for key in pairs(target or {}) do target[key] = nil end
end

local function GetEquipmentToken(slot)
    local link = type(_G.GetInventoryItemLink) == "function" and
                     _G.GetInventoryItemLink("player", slot)
    if link then return link end
    local texture = type(_G.GetInventoryItemTexture) == "function" and
                        _G.GetInventoryItemTexture("player", slot)
    return texture and tostring(texture) or ""
end

function assistant:GetProgress()
    local level = tonumber(_G.UnitLevel("player")) or 0
    local maximum = tonumber(_G.UnitXPMax("player")) or 0
    local current = tonumber(_G.UnitXP("player")) or 0
    local cap = type(_G.GetMaxPlayerLevel) == "function" and
                    tonumber(_G.GetMaxPlayerLevel()) or 80
    local rested = type(_G.GetXPExhaustion) == "function" and
                       tonumber(_G.GetXPExhaustion()) or 0
    return addon.xpFormula:GetProgress(level, current, maximum, rested, cap)
end

function assistant:GetContent()
    local inInstance = type(_G.IsInInstance) == "function" and
                           _G.IsInInstance()
    if inInstance then
        local instanceMapID = type(_G.GetInstanceInfo) == "function" and
                                  select(8, _G.GetInstanceInfo())
        instanceMapID = tonumber(instanceMapID)
        if TBC_INSTANCES[instanceMapID] then
            return "outland", L("Outland"), instanceMapID, true
        elseif WOTLK_INSTANCES[instanceMapID] then
            return "northrend", L("Northrend"), instanceMapID, true
        elseif CLASSIC_INSTANCES[instanceMapID] then
            return "classic", L("Azeroth"), instanceMapID, true
        end
        return nil, L("Unknown content"), nil, true
    end

    local HBD = self.HBD
    local zoneMapID, continent
    if HBD then
        zoneMapID = HBD:GetPlayerZone()
        local worldX, worldY
        worldX, worldY, continent = HBD:GetPlayerWorldPosition()
    end
    if OUTLAND_WORLD_MAPS[zoneMapID] then
        return "outland", L("Outland"), zoneMapID, false
    end
    if NORTHREND_WORLD_MAPS[zoneMapID] then
        return "northrend", L("Northrend"), zoneMapID, false
    end
    -- Only the stock Azeroth world-map range is accepted by continent.  A
    -- custom map attached to a familiar continent remains explicitly unknown.
    if CLASSIC_EXPANSION_WORLD_MAPS[zoneMapID] or
        (zoneMapID and zoneMapID >= 1411 and zoneMapID <= 1458 and
         (continent == 1 or continent == 2)) then
        return "classic", L("Azeroth"), zoneMapID, false
    end
    return nil, L("Unknown content"), zoneMapID or continent, false
end

function assistant:EnsureCalibration()
    RXPCData.mobXPCalibration = type(RXPCData.mobXPCalibration) == "table" and
                                    RXPCData.mobXPCalibration or {}
    if not self.calibrationSanitized then
        local sanitized = {}
        for rawLevel, levelData in pairs(RXPCData.mobXPCalibration) do
            local level = tonumber(rawLevel)
            if level and level >= 1 and level <= 80 and
                type(levelData) == "table" then
                local cleanLevel = {}
                for _, content in ipairs({"classic", "outland", "northrend"}) do
                    local source = levelData[content]
                    local samples = type(source) == "table" and source.samples
                    if type(samples) == "table" then
                        local clean = {}
                        local first = max(1, #samples - MAX_SAMPLES + 1)
                        for index = first, #samples do
                            local value = tonumber(samples[index])
                            if IsFinite(value) and value >= 0.01 and value <= 1000 then
                                clean[#clean + 1] = value
                            end
                        end
                        if #clean > 0 then
                            cleanLevel[content] = {samples = clean}
                        end
                    end
                end
                if next(cleanLevel) then sanitized[level] = cleanLevel end
            end
        end
        RXPCData.mobXPCalibration = sanitized
        self.calibrationSanitized = true
    end
    return RXPCData.mobXPCalibration
end

function assistant:PruneCalibration(level)
    level = tonumber(level) or _G.UnitLevel("player")
    local data = self:EnsureCalibration()
    for rawLevel in pairs(data) do
        local sampleLevel = tonumber(rawLevel)
        if not sampleLevel or math.abs(sampleLevel - level) > 3 then
            data[rawLevel] = nil
        end
    end
end

function assistant:ResetCalibration(allLevels, silent)
    local data = self:EnsureCalibration()
    if allLevels then
        ClearTable(data)
    else
        data[_G.UnitLevel("player")] = nil
    end
    if not silent and addon.comms and addon.comms.PrettyPrint then
        addon.comms.PrettyPrint(L("Learned XP samples cleared."))
    end
    self:ScheduleRefresh(0)
end

function assistant:GetSampleBucket(level, content, create)
    if not content then return end
    local data = self:EnsureCalibration()
    local levelData = data[level]
    if type(levelData) ~= "table" then
        if not create then return end
        levelData = {}
        data[level] = levelData
    end
    local bucket = levelData[content]
    if type(bucket) ~= "table" then
        if not create then return end
        bucket = {samples = {}}
        levelData[content] = bucket
    end
    bucket.samples = type(bucket.samples) == "table" and bucket.samples or {}
    return bucket
end

function assistant:GetCalibration(level, content)
    if not addon.settings or addon.settings.profile.adaptiveMobXP == false then
        return nil, 0, false
    end
    if not content then return nil, 0, false end
    local bucket = self:GetSampleBucket(level, content, false)
    local samples = bucket and bucket.samples or {}
    local valid = {}
    for _, value in ipairs(samples) do
        value = tonumber(value)
        if IsFinite(value) and value >= 0.01 and value <= 1000 then
            valid[#valid + 1] = value
        end
    end
    return addon.xpFormula:GetCalibration(valid, REQUIRED_SAMPLES)
end

function assistant:AddCalibrationSample(snapshot, award)
    if not (snapshot and award and award.named) then return end
    if not self:IsLearningEnabled() then return end
    if snapshot.grouped or snapshot.inInstance then return end
    if snapshot.rested > 0 and not award.restedBonus then return end

    local observed = tonumber(award.total)
    local restedBonus = tonumber(award.restedBonus) or 0
    observed = observed and observed - restedBonus
    local base = addon.xpFormula:GetBaseMobXP(snapshot.playerLevel,
                                               snapshot.mobLevel,
                                               snapshot.content)
    if not observed or observed <= 0 or not base or base <= 0 then return end
    local ratio = observed / base
    if not IsFinite(ratio) or ratio < 0.01 or ratio > 1000 then return end

    local bucket = self:GetSampleBucket(snapshot.playerLevel,
                                        snapshot.content, true)
    tinsert(bucket.samples, ratio)
    while #bucket.samples > MAX_SAMPLES do tremove(bucket.samples, 1) end
    self:ScheduleRefresh(0.05)
end

function assistant:GetRows()
    local progress = self:GetProgress()
    local content, contentLabel, _, inInstance = self:GetContent()
    local multiplier, samples, lowConfidence =
        self:GetCalibration(progress.level, content)
    local rows = {}
    for _, mobLevel in ipairs(addon.xpFormula:GetYellowLevels(progress.level)) do
        local base = content and addon.xpFormula:GetBaseMobXP(
            progress.level, mobLevel, content) or nil
        local adaptive = base and multiplier and
                             max(1, floor(base * multiplier)) or nil
        rows[#rows + 1] = {
            level = mobLevel,
            offset = mobLevel - progress.level,
            baseXP = base,
            baseKills = base and addon.xpFormula:GetKillsRemaining(
                progress.remaining, base, 0) or nil,
            baseRestedKills = base and addon.xpFormula:GetKillsRemaining(
                progress.remaining, base, progress.rested) or nil,
            adaptiveXP = adaptive,
            adaptiveKills = adaptive and addon.xpFormula:GetKillsRemaining(
                progress.remaining, adaptive, 0) or nil,
            adaptiveRestedKills = adaptive and addon.xpFormula:GetKillsRemaining(
                progress.remaining, adaptive, progress.rested) or nil,
        }
    end
    return rows, {
        progress = progress,
        content = content,
        contentLabel = contentLabel,
        multiplier = multiplier,
        samples = samples,
        lowConfidence = lowConfidence,
        grouped = type(_G.IsInGroup) == "function" and _G.IsInGroup() or false,
        inInstance = inInstance,
    }
end

function assistant:CaptureUnit(unit)
    if not self:IsLearningEnabled() then return end
    if type(_G.IsInGroup) == "function" and _G.IsInGroup() then return end
    local now = _G.GetTime()
    self:CleanTransient(now)
    if not (_G.UnitExists(unit) and _G.UnitGUID(unit)) then return end
    if _G.UnitIsPlayer(unit) or
        (type(_G.UnitPlayerControlled) == "function" and
         _G.UnitPlayerControlled(unit)) or
        not _G.UnitCanAttack("player", unit) then return end
    if _G.UnitIsDead(unit) then return end
    if type(_G.UnitIsTrivial) == "function" and
        _G.UnitIsTrivial(unit) then return end
    local level = tonumber(_G.UnitLevel(unit))
    local playerLevel = tonumber(_G.UnitLevel("player"))
    if not level or level < 1 or not playerLevel or
        level < playerLevel - 2 or level > playerLevel + 2 then return end
    if _G.UnitClassification(unit) ~= "normal" then return end
    if type(_G.UnitIsTapped) == "function" and _G.UnitIsTapped(unit) then
        if type(_G.UnitIsTappedByPlayer) ~= "function" or
            not _G.UnitIsTappedByPlayer(unit) then return end
    end

    local content, _, _, inInstance = self:GetContent()
    if not content then return end
    local guid = _G.UnitGUID(unit)
    local previous = self.unitSnapshots[guid]
    self.unitSnapshots[guid] = {
        guid = guid,
        name = _G.UnitName(unit),
        mobLevel = level,
        playerLevel = playerLevel,
        content = content,
        inInstance = inInstance,
        grouped = type(_G.IsInGroup) == "function" and _G.IsInGroup() or false,
        rested = type(_G.GetXPExhaustion) == "function" and
                     max(0, tonumber(_G.GetXPExhaustion()) or 0) or 0,
        captured = now,
        contaminated = previous and previous.contaminated or false,
    }
    local count, oldestGUID, oldestTime = 0
    for snapshotGUID, snapshot in pairs(self.unitSnapshots) do
        count = count + 1
        if not oldestTime or (snapshot.captured or 0) < oldestTime then
            oldestGUID, oldestTime = snapshotGUID, snapshot.captured or 0
        end
    end
    if count > MAX_SNAPSHOTS and oldestGUID then
        self.unitSnapshots[oldestGUID] = nil
    end
    addon.scheduler:After(OWNER, "snapshot-cleanup", SNAPSHOT_SECONDS + 0.1,
                          function()
        assistant:CleanTransient()
    end)
end

function assistant:CleanTransient(now)
    now = now or _G.GetTime()
    for guid, snapshot in pairs(self.unitSnapshots) do
        if now - (snapshot.captured or 0) > SNAPSHOT_SECONDS then
            self.unitSnapshots[guid] = nil
        end
    end
    for index = #self.pendingKills, 1, -1 do
        if now - self.pendingKills[index].time > CORRELATION_SECONDS then
            tremove(self.pendingKills, index)
        end
    end
    for index = #self.pendingAwards, 1, -1 do
        if now - self.pendingAwards[index].time > CORRELATION_SECONDS then
            tremove(self.pendingAwards, index)
        end
    end
    if self.lastXPDelta and
        now - self.lastXPDelta.time > CORRELATION_SECONDS then
        self.lastXPDelta = nil
    end
end

function assistant:MatchPending()
    local now = _G.GetTime()
    self:CleanTransient(now)
    for killIndex = 1, #self.pendingKills do
        local kill = self.pendingKills[killIndex]
        for awardIndex = 1, #self.pendingAwards do
            local award = self.pendingAwards[awardIndex]
            local namesMatch = not award.sourceName or not kill.snapshot.name or
                                   award.sourceName == kill.snapshot.name
            if namesMatch and math.abs(kill.time - award.time) <=
                CORRELATION_SECONDS then
                tremove(self.pendingKills, killIndex)
                tremove(self.pendingAwards, awardIndex)
                self:AddCalibrationSample(kill.snapshot, award)
                return self:MatchPending()
            end
        end
    end
    addon.scheduler:After(OWNER, "transient-cleanup", CORRELATION_SECONDS,
                          function() assistant:CleanTransient() end)
end

function assistant:QueueKilledUnit(guid)
    self:CleanTransient()
    local snapshot = guid and self.unitSnapshots[guid]
    if not snapshot or snapshot.contaminated then return end
    self.unitSnapshots[guid] = nil
    tinsert(self.pendingKills, {time = _G.GetTime(), snapshot = snapshot})
    while #self.pendingKills > 10 do tremove(self.pendingKills, 1) end
    self:MatchPending()
end

function assistant:QueueAward(parsed)
    if not (parsed and parsed.total and parsed.named) then return end
    parsed.time = _G.GetTime()
    tinsert(self.pendingAwards, parsed)
    while #self.pendingAwards > 10 do tremove(self.pendingAwards, 1) end
    self:MatchPending()
end

function assistant:COMBAT_LOG_EVENT_UNFILTERED(...)
    local eventType = select(2, ...)
    local sourceGUID, sourceFlags = select(3, ...), select(5, ...)
    local destinationGUID = select(6, ...)
    local playerGUID = _G.UnitGUID("player")
    local petGUID = _G.UnitExists("pet") and _G.UnitGUID("pet")
    local mine = sourceGUID == playerGUID or sourceGUID == petGUID
    if not mine and _G.bit and _G.bit.band and
        _G.COMBATLOG_OBJECT_AFFILIATION_MINE then
        mine = _G.bit.band(tonumber(sourceFlags) or 0,
                           _G.COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0
    end
    if eventType == "SWING_DAMAGE" or eventType == "RANGE_DAMAGE" or
        eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" or
        eventType == "DAMAGE_SHIELD" then
        local snapshot = destinationGUID and self.unitSnapshots[destinationGUID]
        if snapshot and not mine then
            snapshot.contaminated = true
        end
        return
    end
    if eventType ~= "PARTY_KILL" then return end
    if not mine then return end
    self:QueueKilledUnit(destinationGUID)
end

function assistant:CHAT_MSG_COMBAT_XP_GAIN(text)
    local parsed = addon.ParseCombatXPMessage and
                       addon.ParseCombatXPMessage(text)
    if parsed and parsed.exact then
        self:QueueAward(parsed)
    else
        local now = _G.GetTime()
        if self.lastXPDelta and #self.pendingKills > 0 and
            now - self.lastXPDelta.time <= CORRELATION_SECONDS and
            (not parsed or parsed.named ~= false) then
            self:QueueAward({
                total = self.lastXPDelta.total,
                named = true,
                exact = false,
            })
            self.lastXPDelta = nil
            return
        end
        self.unparsedAwardAt = now
        self.unparsedAwardNamed = #self.pendingKills > 0 and
            (not parsed or parsed.named ~= false)
    end
end

function assistant:PLAYER_XP_UPDATE()
    local current = tonumber(_G.UnitXP("player")) or 0
    local level = tonumber(_G.UnitLevel("player")) or 0
    local now = _G.GetTime()
    if self.lastXPLevel == level and current > (self.lastXP or current) then
        local delta = current - self.lastXP
        self.lastXPDelta = {total = delta, time = now}
        if self.unparsedAwardAt and self.unparsedAwardNamed and
            now - self.unparsedAwardAt <= CORRELATION_SECONDS and
            #self.pendingKills > 0 then
            self:QueueAward({
                total = delta,
                named = true,
                exact = false,
            })
            self.lastXPDelta = nil
        end
    end
    self.lastXP, self.lastXPLevel = current, level
    self.unparsedAwardAt = nil
    self.unparsedAwardNamed = nil
    self:ScheduleRefresh(0.05)
end

function assistant:PLAYER_LEVEL_UP(level)
    level = tonumber(level) or _G.UnitLevel("player")
    self.lastXP, self.lastXPLevel = 0, level
    self.lastXPDelta = nil
    self.unparsedAwardAt = nil
    self.unparsedAwardNamed = nil
    ClearTable(self.pendingKills)
    ClearTable(self.pendingAwards)
    self:PruneCalibration(level)
    self:ScheduleRefresh(0.05)
end

function assistant:PLAYER_EQUIPMENT_CHANGED(slot)
    slot = tonumber(slot)
    if not XP_MODIFIER_SLOTS[slot] then return end
    local current = GetEquipmentToken(slot)
    local previous = self.xpEquipment and self.xpEquipment[slot]
    self.xpEquipment = self.xpEquipment or {}
    self.xpEquipment[slot] = current
    -- Some clients emit equipment events while the initial inventory cache is
    -- settling.  Establish a baseline first and invalidate only a real change.
    if previous == nil or previous == current then return end
    self:ResetCalibration(false, true)
end

function assistant:ScheduleRefresh(delay)
    addon.scheduler:After(OWNER, "refresh", delay or 0.05, function()
        assistant:Refresh()
    end)
end

function assistant:GetReleaseText()
    if addon.GetGuideFooterReleaseText then
        return addon.GetGuideFooterReleaseText()
    end
    return format("%s %s", addon.title or "RXP", addon.release or "")
end

function assistant:SetFooterSuppressed(suppressed)
    self.footerSuppressed = suppressed == true
    if self.footerButton then
        self.footerButton:EnableMouse(not self.footerSuppressed)
        self.footerButton:SetAlpha(self.footerSuppressed and 0 or 1)
    end
    if not self.footerSuppressed then self:RefreshFooter() end
end

function assistant:RefreshFooter()
    local footer = addon.RXPFrame and addon.RXPFrame.Footer
    if not (footer and footer.text) then return end
    local enabled = addon.gameVersion == 30300 and addon.settings and
                        addon.settings.profile.showXPRemaining ~= false
    if not enabled then
        footer.text:SetText(self:GetReleaseText())
        if self.footerButton then self.footerButton:Hide() end
        return
    end
    local progress = self:GetProgress()
    footer.text:SetText(progress.atMax and L("Max level") or
                            format(L("XP %s left"),
                                   ShortNumber(progress.remaining)))
    if self.footerButton then
        self.footerButton:SetShown(not self.footerSuppressed)
        self.footerButton:EnableMouse(not self.footerSuppressed)
    end
end

function assistant:ShowFooterTooltip(button)
    local progress = self:GetProgress()
    local content, contentLabel = self:GetContent()
    local multiplier, samples, lowConfidence =
        self:GetCalibration(progress.level, content)
    _G.GameTooltip:SetOwner(button, "ANCHOR_TOP")
    _G.GameTooltip:AddLine(L("XP Progress and Yellow-Mob Estimator"))
    if progress.atMax then
        _G.GameTooltip:AddLine(L("Max level"), 1, 0.82, 0)
    else
        _G.GameTooltip:AddLine(format(L("Current XP: %s / %s (%d%%)"),
            ExactNumber(progress.current), ExactNumber(progress.maximum),
            floor(progress.percent + 0.5)), 1, 1, 1)
        _G.GameTooltip:AddLine(format(L("XP remaining: %s"),
            ExactNumber(progress.remaining)), 1, 1, 1)
        if progress.rested > 0 then
            _G.GameTooltip:AddLine(format(L("Rested XP: %s"),
                ExactNumber(progress.rested)), 0.35, 0.65, 1)
        end
        _G.GameTooltip:AddLine(format(L("Content curve: %s"),
                                      contentLabel), 0.85, 0.85, 0.85)
        if not content then
            -- The content line above is the actionable status; do not imply
            -- that calibration can progress on an unsupported custom map.
        elseif addon.settings.profile.adaptiveMobXP == false then
            _G.GameTooltip:AddLine(L("Adaptive estimate: disabled"),
                                   0.7, 0.7, 0.7)
        elseif multiplier then
            _G.GameTooltip:AddLine(format(L("Adaptive multiplier: %.2fx (%d samples)"),
                multiplier, samples), lowConfidence and 1 or 0.4,
                lowConfidence and 0.55 or 1, 0.4)
        else
            _G.GameTooltip:AddLine(format(L("Learning valid kills: %d/%d"),
                                          samples, REQUIRED_SAMPLES),
                                   1, 0.82, 0)
        end
    end
    if addon.settings.profile.enableMobXPEstimator == false then
        _G.GameTooltip:AddLine(L("The detailed mob estimator is disabled in settings."),
                               1, 0.4, 0.4, true)
    else
        _G.GameTooltip:AddLine(L("Click for the detailed yellow-mob table."),
                               0.65, 0.78, 1, true)
    end
    _G.GameTooltip:AddLine(self:GetReleaseText(), 0.5, 0.5, 0.5)
    _G.GameTooltip:Show()
end

function assistant:CreateFooterButton()
    if self.footerButton then return end
    local footer = addon.RXPFrame and addon.RXPFrame.Footer
    if not footer then return end
    local button = _G.CreateFrame("Button", nil, footer)
    button:SetFrameLevel(footer:GetFrameLevel() + 2)
    -- Cover exactly the status text, not the Browse/Preflight buttons to its
    -- left or the resize grip to its right.  Anchoring from Footer's RIGHT here
    -- would produce a negative-width hit region on narrow guide windows.
    button:SetPoint("LEFT", footer.preflight, "RIGHT", 1, 0)
    button:SetPoint("RIGHT", footer, "RIGHT", -16, 0)
    button:SetPoint("TOP", footer, "TOP", 0, 0)
    button:SetPoint("BOTTOM", footer, "BOTTOM", 0, 0)
    button:SetScript("OnClick", function()
        if addon.settings.profile.enableMobXPEstimator ~= false then
            assistant:Toggle()
        end
    end)
    button:SetScript("OnEnter", function(self)
        assistant:ShowFooterTooltip(self)
    end)
    button:SetScript("OnLeave", function() _G.GameTooltip:Hide() end)
    footer.xpStatus = button
    self.footerButton = button
end

local function SetCellFont(cell, size)
    if addon.SetFontSafely then
        addon.SetFontSafely(cell, addon.font, size, "")
    end
end

local displayOptions = {
    {
        name = "RXPXPProgressStockCheck",
        key = "xpEstimatorShowStockXP",
        label = "Show Stock XP",
        description = "Shows the canonical WotLK XP awarded by each mob level.",
    },
    {
        name = "RXPXPProgressKillsCheck",
        key = "xpEstimatorShowKills",
        label = "Show Kill Counts",
        description = "Shows how many kills remain at the current XP progress.",
    },
    {
        name = "RXPXPProgressAdaptiveCheck",
        key = "xpEstimatorShowAdaptive",
        label = "Show Adaptive XP",
        description = "Shows estimates learned from verified kills on this server.",
    },
    {
        name = "RXPXPProgressRestedCheck",
        key = "xpEstimatorShowRested",
        label = "Show Rested Projections",
        description = "Shows normal / rested values using the finite rested-XP pool.",
    },
}

function assistant:IsDisplayOptionEnabled(key)
    local profile = addon.settings and addon.settings.profile
    return not profile or profile[key] ~= false
end

function assistant:SetDisplayOption(key, value)
    if addon.settings and addon.settings.profile then
        addon.settings.profile[key] = value == true
    end
    self:ResizeForVisibleColumns()
    self:RefreshWindow()
end

function assistant:GetVisibleColumnCount()
    local count = 1
    if self:IsDisplayOptionEnabled("xpEstimatorShowStockXP") then
        count = count + 1
    end
    if self:IsDisplayOptionEnabled("xpEstimatorShowKills") then
        count = count + 1
    end
    if self:IsDisplayOptionEnabled("xpEstimatorShowAdaptive") then
        count = count + 1
        if self:IsDisplayOptionEnabled("xpEstimatorShowKills") then
            count = count + 1
        end
    end
    return count
end

function assistant:ResizeForVisibleColumns(force)
    local frame = self.frame
    local profile = addon.settings and addon.settings.profile
    if not (frame and profile) then return end
    profile.toolWindowAppearance = type(profile.toolWindowAppearance) == "table" and
                                       profile.toolWindowAppearance or {}
    local appearance = profile.toolWindowAppearance.RXPXPProgressWindow
    appearance = type(appearance) == "table" and appearance or {}
    profile.toolWindowAppearance.RXPXPProgressWindow = appearance

    local count = self:GetVisibleColumnCount()
    if not force and tonumber(appearance.xpColumnCount) == count then return end
    local widths = {340, 410, 490, 570, 650}
    local width = widths[count] or 650
    local height = count <= 2 and 440 or 390
    appearance.xpColumnCount = count
    if frame.SetMinResize then
        frame:SetMinResize(340, count <= 2 and 425 or 375)
    end
    frame:SetSize(width, height)
    if addon.toolWindows and addon.toolWindows.SavePlacement then
        addon.toolWindows:SavePlacement(frame)
    end
end

function assistant:RefreshColumnLayout()
    local frame = self.frame
    if not frame then return end
    local visible = {
        true,
        self:IsDisplayOptionEnabled("xpEstimatorShowStockXP"),
        self:IsDisplayOptionEnabled("xpEstimatorShowKills"),
        self:IsDisplayOptionEnabled("xpEstimatorShowAdaptive"),
        self:IsDisplayOptionEnabled("xpEstimatorShowAdaptive") and
            self:IsDisplayOptionEnabled("xpEstimatorShowKills"),
    }
    local count = self:GetVisibleColumnCount()
    local frameWidth = frame:GetWidth() or 650
    local compact = frameWidth < 470
    local checkColumns = compact and 1 or 2
    local checkWidth = max(120, (frameWidth - 55) / checkColumns)
    for index, check in ipairs(frame.displayChecks or {}) do
        local column = (index - 1) % checkColumns
        local row = floor((index - 1) / checkColumns)
        check:ClearAllPoints()
        check:SetPoint("TOPLEFT", frame, "TOPLEFT", 22 + column * checkWidth,
                       -94 - row * 25)
        check:SetHitRectInsets(0, -max(0, checkWidth - 25), 0, 0)
        check.label:SetWidth(max(90, checkWidth - 29))
    end
    local headerTop = compact and -208 or -158
    local rowTop = compact and -227 or -177
    local available = max(260, frameWidth - 44)
    local mobWidth = min(110, available)
    local otherWidth = count > 1 and (available - mobWidth) / (count - 1) or 0
    local x = 22
    for column, shown in ipairs(visible) do
        local width = column == 1 and (count == 1 and available or mobWidth) or
                          otherWidth
        local header = frame.headers[column]
        header:ClearAllPoints()
        header:SetPoint("TOPLEFT", frame, "TOPLEFT", x, headerTop)
        header:SetWidth(max(40, width - 6))
        header:SetShown(shown)
        for _, row in ipairs(frame.rows) do
            local cell = row.cells[column]
            cell:ClearAllPoints()
            cell:SetPoint("LEFT", row, "LEFT", x - 16, 0)
            cell:SetWidth(max(40, width - 6))
            cell:SetShown(shown)
        end
        if shown then x = x + width end
    end
    for rowIndex, row in ipairs(frame.rows) do
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", 16,
                     rowTop - (rowIndex - 1) * 25)
        row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16,
                     rowTop - (rowIndex - 1) * 25)
    end
end

local function CreateDisplayCheck(frame, definition, index)
    local check = _G.CreateFrame("CheckButton", definition.name, frame,
                                 "UICheckButtonTemplate")
    check:SetSize(22, 22)
    local label = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    label:SetPoint("LEFT", check, "RIGHT", 1, 0)
    label:SetWidth(245)
    label:SetHeight(22)
    label:SetJustifyH("LEFT")
    label:SetText(L(definition.label))
    check.label = label
    check.optionKey = definition.key
    check.description = definition.description
    check:SetScript("OnClick", function(self)
        assistant:SetDisplayOption(self.optionKey,
                                   self:GetChecked() and true or false)
    end)
    check:SetScript("OnEnter", function(self)
        _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        _G.GameTooltip:AddLine(L(definition.label))
        _G.GameTooltip:AddLine(L(self.description), 1, 1, 1, true)
        _G.GameTooltip:Show()
    end)
    check:SetScript("OnLeave", function() _G.GameTooltip:Hide() end)
    return check
end

function assistant:CreateWindow()
    if self.frame then return self.frame end
    local tools = addon.toolWindows
    local frame = tools:Create({
        name = "RXPXPProgressWindow",
        title = L("XP Progress and Yellow-Mob Estimator"),
        width = 650,
        height = 390,
        minWidth = 340,
        minHeight = 375,
        relativeTo = "RXPFrame",
        point = "TOPLEFT",
        relativePoint = "TOPRIGHT",
        x = 8,
        y = 0,
    })

    local summary = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    summary:SetPoint("TOPLEFT", 22, -48)
    summary:SetPoint("TOPRIGHT", -22, -48)
    summary:SetJustifyH("LEFT")
    summary:SetJustifyV("TOP")
    summary:SetHeight(48)
    frame.summary = summary

    frame.displayChecks = {}
    for index, definition in ipairs(displayOptions) do
        frame.displayChecks[index] = CreateDisplayCheck(frame, definition,
                                                         index)
    end

    local headers = {L("Mob level"), L("Stock XP"), L("Stock kills"),
                     L("Adaptive XP"), L("Adaptive kills")}
    frame.headers = {}
    for index, label in ipairs(headers) do
        local cell = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        cell:SetText(label)
        cell:SetTextColor(1, 0.82, 0)
        cell:SetJustifyH("LEFT")
        frame.headers[index] = cell
    end

    frame.rows = {}
    for rowIndex = 1, 5 do
        local row = _G.CreateFrame("Frame", nil, frame)
        row:SetPoint("TOPLEFT", 16, -177 - (rowIndex - 1) * 25)
        row:SetPoint("TOPRIGHT", -16, -177 - (rowIndex - 1) * 25)
        row:SetHeight(23)
        row.cells = {}
        for column = 1, 5 do
            local cell = row:CreateFontString(nil, "ARTWORK",
                                               "GameFontHighlightSmall")
            cell:SetJustifyH("LEFT")
            row.cells[column] = cell
        end
        frame.rows[rowIndex] = row
    end

    local note = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    note:SetPoint("BOTTOMLEFT", 22, 20)
    note:SetPoint("BOTTOMRIGHT", -22, 20)
    note:SetJustifyH("LEFT")
    note:SetJustifyV("BOTTOM")
    if note.SetWordWrap then note:SetWordWrap(true) end
    note:SetHeight(48)
    frame.note = note

    frame.OnToolVisuals = function(_, fontSize)
        SetCellFont(summary, fontSize)
        SetCellFont(note, fontSize)
        for _, check in ipairs(frame.displayChecks) do
            SetCellFont(check.label, fontSize)
        end
        for _, cell in ipairs(frame.headers) do SetCellFont(cell, fontSize) end
        for _, row in ipairs(frame.rows) do
            for _, cell in ipairs(row.cells) do SetCellFont(cell, fontSize) end
        end
        assistant:RefreshColumnLayout()
    end
    frame:HookScript("OnShow", function() assistant:RefreshWindow() end)
    frame:HookScript("OnSizeChanged", function()
        assistant:RefreshColumnLayout()
    end)
    self.frame = frame
    frame.OnToolReset = function()
        assistant:ResizeForVisibleColumns(true)
        assistant:RefreshColumnLayout()
    end
    self:ResizeForVisibleColumns()
    self:RefreshColumnLayout()
    return frame
end

function assistant:RefreshWindow()
    local frame = self.frame
    if not (frame and frame:IsShown()) then return end
    local rows, state = self:GetRows()
    local progress = state.progress
    for _, check in ipairs(frame.displayChecks) do
        check:SetChecked(self:IsDisplayOptionEnabled(check.optionKey))
    end
    self:RefreshColumnLayout()
    if progress.atMax then
        frame.summary:SetText(L("You have reached the current level cap."))
    else
        frame.summary:SetText(format(
            L("Level %d: %s / %s XP (%d%%) - %s remaining\nContent curve: %s"),
            progress.level, ExactNumber(progress.current),
            ExactNumber(progress.maximum), floor(progress.percent + 0.5),
            ExactNumber(progress.remaining), state.contentLabel))
    end

    for index, rowFrame in ipairs(frame.rows) do
        local row = rows[index]
        if not row or progress.atMax then
            rowFrame:Hide()
        else
            rowFrame:Show()
            local offset = row.offset == 0 and "=" or
                               format("%+d", row.offset)
            rowFrame.cells[1]:SetText(format("[=] %d (%s)", row.level, offset))
            local hasRested = progress.rested > 0 and
                self:IsDisplayOptionEnabled("xpEstimatorShowRested")
            rowFrame.cells[2]:SetText(row.baseXP and
                (hasRested and format("%d / %d", row.baseXP,
                                      row.baseXP + min(row.baseXP,
                                                       progress.rested)) or
                    tostring(row.baseXP)) or "-")
            rowFrame.cells[3]:SetText(row.baseKills and
                (hasRested and format("%d / %d", row.baseKills,
                                      row.baseRestedKills) or
                    tostring(row.baseKills)) or "-")
            if row.adaptiveXP then
                local adaptiveText = hasRested and
                    format("%d / %d", row.adaptiveXP,
                           row.adaptiveXP + min(row.adaptiveXP,
                                                progress.rested)) or
                    tostring(row.adaptiveXP)
                rowFrame.cells[4]:SetText(adaptiveText)
                rowFrame.cells[5]:SetText(hasRested and
                    format("%d / %d", row.adaptiveKills,
                           row.adaptiveRestedKills) or
                    tostring(row.adaptiveKills or "-"))
            elseif not state.content then
                rowFrame.cells[4]:SetText("-")
                rowFrame.cells[5]:SetText("-")
            elseif addon.settings.profile.adaptiveMobXP == false then
                rowFrame.cells[4]:SetText(L("Off"))
                rowFrame.cells[5]:SetText("-")
            else
                rowFrame.cells[4]:SetText(format(L("Learning %d/%d"),
                                                 state.samples,
                                                 REQUIRED_SAMPLES))
                rowFrame.cells[5]:SetText("-")
            end
            for _, cell in ipairs(rowFrame.cells) do
                cell:SetTextColor(1, 0.86, 0.22)
            end
        end
    end

    local notes = {}
    if progress.atMax then
        notes[#notes + 1] = L("Mob estimates are unavailable at max level.")
    elseif not state.content then
        notes[#notes + 1] = L("The current map could not be assigned to a WotLK content curve.")
    elseif state.grouped then
        notes[#notes + 1] = L("Solo estimate; adaptive learning is paused while grouped.")
    elseif state.inInstance then
        notes[#notes + 1] = L("Solo baseline; adaptive learning is paused inside instances with possible special modifiers.")
    end
    local showAdaptive = self:IsDisplayOptionEnabled(
                             "xpEstimatorShowAdaptive")
    if showAdaptive and state.lowConfidence then
        notes[#notes + 1] = L("Adaptive estimate has low confidence because recent awards vary.")
    elseif showAdaptive and state.multiplier then
        notes[#notes + 1] = format(L("Adaptive estimate: %.2fx from %d valid kills."),
                                  state.multiplier, state.samples)
    elseif showAdaptive and state.content and
        addon.settings.profile.adaptiveMobXP ~= false and
        not progress.atMax then
        notes[#notes + 1] = format(L("Learning valid solo kills: %d/%d."),
                                  state.samples, REQUIRED_SAMPLES)
    end
    if self:IsDisplayOptionEnabled("xpEstimatorShowRested") and
        progress.rested > 0 and not progress.atMax then
        notes[#notes + 1] = L("XP and kills show normal / rested projections; rested kills use the finite rested-XP pool.")
    end
    frame.note:SetText(table.concat(notes, " "))
end

function assistant:Refresh()
    self:RefreshFooter()
    self:RefreshWindow()
end

function assistant:Toggle()
    if addon.settings.profile.enableMobXPEstimator == false then return end
    local frame = self:CreateWindow()
    if frame:IsShown() then frame:Hide() else frame:Show() end
end

function assistant:OnEvent(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:COMBAT_LOG_EVENT_UNFILTERED(...)
    elseif event == "CHAT_MSG_COMBAT_XP_GAIN" then
        self:CHAT_MSG_COMBAT_XP_GAIN(...)
    elseif event == "PLAYER_XP_UPDATE" then
        self:PLAYER_XP_UPDATE(...)
    elseif event == "PLAYER_LEVEL_UP" then
        self:PLAYER_LEVEL_UP(...)
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        self:PLAYER_EQUIPMENT_CHANGED(...)
    elseif event == "PLAYER_TARGET_CHANGED" then
        self:CaptureUnit("target")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        self:CaptureUnit("mouseover")
    elseif event == "PLAYER_ENTERING_WORLD" then
        addon.xpFormula:RefreshCombatXPFormats()
        self:UpdateEventRegistrations()
        self.lastXP = tonumber(_G.UnitXP("player")) or 0
        self.lastXPLevel = tonumber(_G.UnitLevel("player")) or 0
        self.lastXPDelta = nil
        self:PruneCalibration(self.lastXPLevel)
        self:ScheduleRefresh(0.2)
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        ClearTable(self.unitSnapshots)
        ClearTable(self.pendingKills)
        ClearTable(self.pendingAwards)
        self.lastXPDelta = nil
        self.unparsedAwardAt = nil
        self.unparsedAwardNamed = nil
        self:ScheduleRefresh(0.2)
    elseif event == "PARTY_MEMBERS_CHANGED" or
        event == "RAID_ROSTER_UPDATE" then
        -- Never let a snapshot captured while solo leak into a newly formed
        -- group, where the award depends on composition and level spread.
        ClearTable(self.unitSnapshots)
        ClearTable(self.pendingKills)
        ClearTable(self.pendingAwards)
        self.lastXPDelta = nil
        self.unparsedAwardAt = nil
        self.unparsedAwardNamed = nil
        self:ScheduleRefresh(0.05)
    else
        self:ScheduleRefresh(0.05)
    end
end

function assistant:IsLearningEnabled()
    local profile = addon.settings and addon.settings.profile
    return profile and profile.enableMobXPEstimator ~= false and
               profile.adaptiveMobXP ~= false
end

function assistant:UpdateEventRegistrations()
    local frame = self.eventFrame
    if not frame then return end
    local enabled = self:IsLearningEnabled()
    for _, event in ipairs(ADAPTIVE_EVENTS) do
        if enabled then
            pcall(frame.RegisterEvent, frame, event)
        else
            frame:UnregisterEvent(event)
        end
    end
    if not enabled then
        ClearTable(self.unitSnapshots)
        ClearTable(self.pendingKills)
        ClearTable(self.pendingAwards)
        self.lastXPDelta = nil
        self.unparsedAwardAt = nil
        self.unparsedAwardNamed = nil
    else
        self:CaptureUnit("target")
        self:CaptureUnit("mouseover")
    end
end

function assistant:ApplySettings()
    self:UpdateEventRegistrations()
    if self.frame then self:ResizeForVisibleColumns() end
    if addon.settings.profile.enableMobXPEstimator == false and self.frame then
        self.frame:Hide()
    end
    self:Refresh()
end

function assistant:Setup()
    if self.setup then
        self:UpdateEventRegistrations()
        self:Refresh()
        return
    end
    self.setup = true
    self.HBD = _G.LibStub and _G.LibStub("HereBeDragons-2.0", true)
    self.unitSnapshots = {}
    self.pendingKills = {}
    self.pendingAwards = {}
    self.xpEquipment = {}
    for slot in pairs(XP_MODIFIER_SLOTS) do
        self.xpEquipment[slot] = GetEquipmentToken(slot)
    end
    self.lastXP = tonumber(_G.UnitXP("player")) or 0
    self.lastXPLevel = tonumber(_G.UnitLevel("player")) or 0
    self:EnsureCalibration()
    self:PruneCalibration(self.lastXPLevel)
    self:CreateFooterButton()

    local frame = self.eventFrame or _G.CreateFrame("Frame")
    local events = {
        "PLAYER_ENTERING_WORLD", "PLAYER_XP_UPDATE", "PLAYER_LEVEL_UP",
        "UPDATE_EXHAUSTION", "ZONE_CHANGED_NEW_AREA",
        "PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE",
    }
    for _, event in ipairs(events) do pcall(frame.RegisterEvent, frame, event) end
    frame:SetScript("OnEvent", function(_, event, ...)
        assistant:OnEvent(event, ...)
    end)
    self.eventFrame = frame
    self:UpdateEventRegistrations()
    self:Refresh()
end

function assistant:Shutdown()
    addon.scheduler:CancelOwner(OWNER)
    if self.eventFrame then self.eventFrame:UnregisterAllEvents() end
    if self.frame then self.frame:Hide() end
    if self.footerButton then self.footerButton:Hide() end
    local footer = addon.RXPFrame and addon.RXPFrame.Footer
    if footer and footer.text then footer.text:SetText(self:GetReleaseText()) end
    self.setup = false
end
