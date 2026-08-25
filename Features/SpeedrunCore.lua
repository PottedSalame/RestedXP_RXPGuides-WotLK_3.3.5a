local _, addon = ...

-- Shared, privacy-safe timing and presentation for the 3.3.5 speedrunning
-- tools. English guide data remains authoritative; this service observes
-- stable guide events and never drives quest, movement, targeting, or combat
-- automation.

local _G = _G
local format = string.format
local floor, max, min = math.floor, math.max, math.min
local tinsert, tremove = table.insert, table.remove
local L = addon.locale.Get
local toolWindows = addon.toolWindows
local OWNER = "speedrun-core"
local MAX_SEGMENTS = 10000
local MAX_DETAILED_RUNS = 10
local TIMING_VERSION = 1

addon.speedrun = addon.speedrun or {}
addon.speedrunCoach = addon.speedrunCoach or {}
addon.speedrunAudio = addon.speedrunAudio or {}
addon.speedrunRules = addon.speedrunRules or {}

local speedrun = addon.speedrun
local coach = addon.speedrunCoach
local audio = addon.speedrunAudio
local rules = addon.speedrunRules

local function Profile()
    return addon.settings and addon.settings.profile or {}
end

local function SuiteEnabled()
    return Profile().enableSpeedrunSuite ~= false
end

local function ToolEnabled(key)
    return SuiteEnabled() and Profile()[key] == true
end

local timingToolKeys = {
    "enableSpeedrunCoach", "enableSpeedrunGrind", "enableSpeedrunPitStop",
    "enableSpeedrunRoute", "enableSpeedrunDeathwarp",
    "enableSpeedrunPractice", "enableSpeedrunAudio", "enableSpeedrunRules"
}

local function TimingEnabled()
    if not SuiteEnabled() then return false end
    for _, key in ipairs(timingToolKeys) do
        if Profile()[key] == true then return true end
    end
    return false
end

local function GuideKey(guide)
    if type(guide) ~= "table" or guide.empty then return end
    return guide.key or (addon.BuildGuideKey and addon.BuildGuideKey(guide))
end

local function StepToken(guide, step, fallback)
    local key = GuideKey(guide)
    if not key or type(step) ~= "table" then return end
    local id = step.stepId
    if id == nil or id == "" then id = tonumber(step.index) or fallback end
    if id == nil then return end
    return key .. "\031" .. tostring(id), key, id,
           tonumber(step.index) or tonumber(fallback) or 0
end

local function DurationText(seconds, signed)
    seconds = tonumber(seconds)
    if not seconds then return "-" end
    local prefix = ""
    if signed then
        prefix = seconds > 0 and "+" or seconds < 0 and "-" or ""
        seconds = math.abs(seconds)
    end
    seconds = max(0, floor(seconds + 0.5))
    local hours = floor(seconds / 3600)
    local minutes = floor((seconds % 3600) / 60)
    local secs = seconds % 60
    if hours > 0 then
        return format("%s%d:%02d:%02d", prefix, hours, minutes, secs)
    end
    return format("%s%d:%02d", prefix, minutes, secs)
end

local function ShallowCopy(source)
    local result = {}
    for key, value in pairs(type(source) == "table" and source or {}) do
        if type(value) == "number" or type(value) == "string" or
            type(value) == "boolean" then result[key] = value end
    end
    return result
end

function speedrun:EnsureStores()
    RXPData.speedrun = type(RXPData.speedrun) == "table" and
                           RXPData.speedrun or {}
    local store = RXPData.speedrun
    store.version = TIMING_VERSION
    store.practice = type(store.practice) == "table" and store.practice or {
        definitions = {}, attempts = {}
    }
    store.practice.definitions = type(store.practice.definitions) == "table" and
                                     store.practice.definitions or {}
    store.practice.attempts = type(store.practice.attempts) == "table" and
                                  store.practice.attempts or {}
    store.branchObservations = type(store.branchObservations) == "table" and
                                   store.branchObservations or {}
    store.rulesets = type(store.rulesets) == "table" and store.rulesets or {}
    store.rulesets["solo-any"] = type(store.rulesets["solo-any"]) == "table" and
        store.rulesets["solo-any"] or {id = "solo-any", solo = true,
                                        deathless = false, builtIn = true}
    store.rulesets["solo-deathless"] =
        type(store.rulesets["solo-deathless"]) == "table" and
            store.rulesets["solo-deathless"] or
            {id = "solo-deathless", solo = true, deathless = true,
             builtIn = true}
    store.rulesets.custom = type(store.rulesets.custom) == "table" and
                                store.rulesets.custom or
                                {id = "custom", solo = false,
                                 deathless = false, builtIn = false}
    RXPCData.speedrunSession =
        type(RXPCData.speedrunSession) == "table" and
            RXPCData.speedrunSession or {}
    return store, RXPCData.speedrunSession
end

function speedrun:IsEnabled(key)
    return ToolEnabled(key or "enableSpeedrunCoach")
end

function speedrun:IsTimingEnabled()
    return TimingEnabled()
end

function speedrun:GetRun(create)
    if not (addon.runArchive and addon.runArchive.GetCurrent) then return end
    return addon.runArchive:GetCurrent(create == true)
end

local function CurrentRulesetId()
    if not ToolEnabled("enableSpeedrunRules") then return "unrestricted" end
    local id = Profile().speedrunRuleset
    if id ~= "solo-any" and id ~= "solo-deathless" and id ~= "custom" then
        id = "solo-any"
    end
    return id
end

function rules:CurrentId()
    return CurrentRulesetId()
end

local customRuleKeys = {
    death = "allowDeaths", grouped = "allowGrouping",
    ["rested-xp"] = "allowRestedXP", heirloom = "allowHeirlooms",
    ["xp-rate-change"] = "allowXPRateChanges",
    ["guide-change"] = "allowGuideChanges",
    ["manual-skip"] = "allowManualSkips",
}

function rules:IsAllowed(kind)
    local id = CurrentRulesetId()
    if id == "unrestricted" then return true end
    if id == "solo-any" then return kind ~= "grouped" end
    if id == "solo-deathless" then return kind ~= "grouped" and kind ~= "death" end
    local values = Profile().speedrunCustomRules
    local key = customRuleKeys[kind]
    return key and type(values) == "table" and values[key] == true or false
end

function rules:Fingerprint()
    local id = CurrentRulesetId()
    if id ~= "custom" then return id end
    local values = Profile().speedrunCustomRules
    local parts = {id}
    for _, key in ipairs({"allowDeaths", "allowGrouping", "allowRestedXP",
        "allowHeirlooms", "allowXPRateChanges", "allowGuideChanges",
        "allowManualSkips"}) do
        parts[#parts + 1] = type(values) == "table" and values[key] == true and "1" or "0"
    end
    return table.concat(parts, ":")
end

function speedrun:BuildFingerprint(run)
    run = run or self:GetRun(false)
    local class = addon.player and addon.player.class or select(2, UnitClass("player"))
    local race = addon.player and addon.player.race or select(2, UnitRace("player"))
    local faction = UnitFactionGroup("player") or "Neutral"
    local rate = tonumber(Profile().xprate) or 1
    return table.concat({tostring(class or "UNKNOWN"), tostring(race or "UNKNOWN"),
        tostring(faction), format("%.3f", rate), rules:Fingerprint(),
        tostring(addon.release or "unknown")}, "|")
end

function speedrun:BuildBranchKey(fromKey, toKey, run)
    if not fromKey or not toKey then return end
    return tostring(fromKey) .. "\031" .. tostring(toKey) .. "\031" ..
               self:BuildFingerprint(run)
end

function speedrun:EnsureRun(run)
    if type(run) ~= "table" then return end
    run.timingVersion = TIMING_VERSION
    run.segments = type(run.segments) == "table" and run.segments or {}
    run.deviations = type(run.deviations) == "table" and run.deviations or {}
    run.speedrunFingerprint = run.speedrunFingerprint or self:BuildFingerprint(run)
    run.speedrunRuleset = run.speedrunRuleset or CurrentRulesetId()
    run.speedrunWallStartedAt = tonumber(run.speedrunWallStartedAt) or
                                   tonumber(run.startedAt) or _G.time()
    return run
end

function speedrun:PauseActive(trackAsOffline)
    local _, session = self:EnsureStores()
    local started = tonumber(session.activeStarted)
    if started then
        session.activeAccum = max(0, tonumber(session.activeAccum) or 0) +
                                  max(0, _G.GetTime() - started)
        session.activeStarted = nil
    end
    session.inWorld = false
    session.pausedWallAt = _G.time()
    session.pausedAsOffline = trackAsOffline == true
end

function speedrun:ResumeActive()
    local _, session = self:EnsureStores()
    if session.pausedWallAt and session.pausedAsOffline and session.currentToken then
        local offline = max(0, _G.time() - session.pausedWallAt)
        if offline > 0 then
            session.currentCategories = type(session.currentCategories) == "table" and
                                            session.currentCategories or {}
            session.currentCategories["loading/offline"] =
                (tonumber(session.currentCategories["loading/offline"]) or 0) + offline
        end
    end
    session.pausedWallAt = nil
    session.pausedAsOffline = nil
    if not session.activeStarted then session.activeStarted = _G.GetTime() end
    session.inWorld = true
    session.sampleAt = _G.GetTime()
end

function speedrun:GetClocks()
    local _, session = self:EnsureStores()
    local active = max(0, tonumber(session.activeAccum) or 0)
    if session.activeStarted then
        active = active + max(0, _G.GetTime() - session.activeStarted)
    end
    local run = self:EnsureRun(self:GetRun(false))
    local wallStart = tonumber(session.wallStartedAt) or
                          (run and tonumber(run.speedrunWallStartedAt))
    local wall = wallStart and max(0, _G.time() - wallStart) or 0
    return active, wall
end

function speedrun:CurrentCategory()
    if UnitIsDeadOrGhost and UnitIsDeadOrGhost("player") then return "death" end
    if self.onTaxi then return "travel" end
    local interaction, count
    if self.questOpen or self.gossipOpen then interaction, count = "quest", 1 end
    if self.merchantOpen then interaction, count = "merchant", (count or 0) + 1 end
    if self.trainerOpen then interaction, count = "trainer", (count or 0) + 1 end
    if (count or 0) > 1 then return "unknown" end
    if interaction then return interaction end
    if UnitAffectingCombat and UnitAffectingCombat("player") then return "combat" end
    local unitSpeed = type(GetUnitSpeed) == "function" and GetUnitSpeed("player")
    if (tonumber(unitSpeed) or 0) > 0.1 then
        return "travel"
    end
    return "unknown"
end

function speedrun:Sample()
    if not TimingEnabled() then return end
    local _, session = self:EnsureStores()
    local now = _G.GetTime()
    local previous = tonumber(session.sampleAt) or now
    session.sampleAt = now
    local elapsed = max(0, min(5, now - previous))
    if elapsed > 0 and session.inWorld ~= false and session.currentToken then
        session.currentCategories = type(session.currentCategories) == "table" and
                                        session.currentCategories or {}
        local category = self:CurrentCategory()
        session.currentCategories[category] =
            (tonumber(session.currentCategories[category]) or 0) + elapsed
    end
    coach:Refresh(false)
end

function speedrun:ResetSession(run)
    local _, session = self:EnsureStores()
    for key in pairs(session) do session[key] = nil end
    session.archiveId = run and run.id
    session.activeAccum = 0
    session.wallStartedAt = run and run.speedrunWallStartedAt or _G.time()
    session.inWorld = true
    session.activeStarted = _G.GetTime()
    session.sampleAt = _G.GetTime()
    session.currentCategories = {}
end

function speedrun:PruneDetailedRuns()
    local store = RXPData.levelingArchives
    local runs = store and store.runs
    if type(runs) ~= "table" then return end
    local detailed = {}
    for _, run in pairs(runs) do
        if type(run) == "table" and type(run.segments) == "table" and
            #run.segments > 0 and run.finished then tinsert(detailed, run) end
    end
    table.sort(detailed, function(a, b)
        local aReference = tonumber(a.id) == tonumber(Profile().speedrunManualReference)
        local bReference = tonumber(b.id) == tonumber(Profile().speedrunManualReference)
        if aReference ~= bReference then return aReference end
        return (tonumber(a.updatedAt) or 0) > (tonumber(b.updatedAt) or 0)
    end)
    for index = MAX_DETAILED_RUNS + 1, #detailed do
        detailed[index].segments = nil
        detailed[index].timeLossReport = nil
        detailed[index].segmentSummaryOnly = true
    end
end

function speedrun:OnArchiveStarted(run)
    run = self:EnsureRun(run)
    if not run then return end
    self:ResetSession(run)
    self:StartCurrentStep("run-start")
    addon:SendEvent("RXP_SPEEDRUN_RUN_CHANGED", run.id, "started")
end

function speedrun:OnArchiveFinished(run)
    if not run then return end
    self:CloseSegment("finish")
    local active, wall = self:GetClocks()
    self:CommitPendingBranch(active)
    run.speedrunActiveDuration = floor(active + 0.5)
    run.speedrunWallDuration = floor(wall + 0.5)
    run.speedrunRuleset = CurrentRulesetId()
    run.speedrunFingerprint = run.speedrunFingerprint or self:BuildFingerprint(run)
    run.timingVersion = TIMING_VERSION
    self.lastFinishedRun = run
    self:BuildLossReport(run)
    self:PruneDetailedRuns()
    addon:SendEvent("RXP_SPEEDRUN_RUN_CHANGED", run.id, "finished")
    coach:Refresh(true)
end

function speedrun:CommitPendingBranch(active)
    local store, session = self:EnsureStores()
    if not session.branchKey or not session.branchStartedActive then return end
    active = tonumber(active) or select(1, self:GetClocks())
    local duration = max(0, active - session.branchStartedActive)
    if duration > 0 then
        local samples = type(store.branchObservations[session.branchKey]) == "table" and
                            store.branchObservations[session.branchKey] or {}
        tinsert(samples, floor(duration + 0.5))
        while #samples > 20 do tremove(samples, 1) end
        store.branchObservations[session.branchKey] = samples
    end
    session.branchKey = nil
    session.branchStartedActive = nil
end

function speedrun:BuildLossReport(run)
    if type(run) ~= "table" or type(run.segments) ~= "table" then return end
    local candidates = self:GetCompatibleRuns()
    local reference = candidates[1]
    if not reference or reference == run then return end
    local clock = Profile().speedrunDisplayClock == "wall" and "wall" or "active"
    local byToken = {}
    for _, segment in ipairs(reference.segments or {}) do
        local value = tonumber(clock == "wall" and segment.w or segment.a)
        if value then byToken[segment.t] = value end
    end
    local losses = {}
    for _, segment in ipairs(run.segments) do
        local value = tonumber(clock == "wall" and segment.w or segment.a)
        local baseline = byToken[segment.t]
        if value and baseline then
            tinsert(losses, {t = segment.t, g = segment.g, s = segment.s,
                             n = segment.n, delta = value - baseline})
        end
    end
    table.sort(losses, function(a, b) return a.delta > b.delta end)
    while #losses > 10 do tremove(losses) end
    run.timeLossReport = losses
    return losses
end

function speedrun:AppendSegment(outcome)
    local _, session = self:EnsureStores()
    if not session.currentToken or session.segmentClosed then return end
    local run = self:EnsureRun(self:GetRun(true))
    if not run then return end
    local active, wall = self:GetClocks()
    local activeDuration = max(0, active - (tonumber(session.segmentActive) or active))
    local wallDuration = max(0, wall - (tonumber(session.segmentWall) or wall))
    local categories = {}
    for name, value in pairs(session.currentCategories or {}) do
        if tonumber(value) and value > 0 then categories[name] = floor(value + 0.5) end
    end
    local segment = {
        t = session.currentToken,
        g = session.currentGuideKey,
        s = session.currentStepId,
        n = tonumber(session.currentStep) or 0,
        a = floor(activeDuration + 0.5),
        w = floor(wallDuration + 0.5),
        c = categories,
        o = outcome or "complete"
    }
    tinsert(run.segments, segment)
    while #run.segments > MAX_SEGMENTS do tremove(run.segments, 1) end
    run.speedrunActiveDuration = floor(active + 0.5)
    run.speedrunWallDuration = floor(wall + 0.5)
    run.updatedAt = _G.time()
    session.segmentClosed = true
    session.lastClosedToken = session.currentToken
    session.lastSegment = segment
    addon:SendEvent("RXP_SPEEDRUN_SEGMENT", segment, run)
    coach:Refresh(true)
    local comparison = self:GetComparison()
    local threshold = max(1, tonumber(Profile().speedrunPaceThreshold) or 15)
    if comparison.status == "matched" and comparison.segmentDelta and
        math.abs(comparison.segmentDelta) >= threshold then audio:Play("pace") end
    return segment
end

function speedrun:CloseSegment(outcome, token)
    local _, session = self:EnsureStores()
    if token and session.currentToken ~= token then return end
    return self:AppendSegment(outcome)
end

function speedrun:StartSegment(guide, step, reason)
    if not TimingEnabled() or addon.speedrunPracticeActive then return end
    local token, key, id, index = StepToken(guide, step)
    if not token then return end
    local run = self:EnsureRun(self:GetRun(true))
    local _, session = self:EnsureStores()
    if session.archiveId ~= run.id then self:ResetSession(run) end
    if session.currentToken == token and not session.segmentClosed then return end
    -- A completion can be followed by several queued evaluations of the same
    -- stable step.  Do not turn those evaluations into duplicate zero-length
    -- splits; a different stable token must be observed first.
    if session.currentToken == token and session.segmentClosed and
        session.lastClosedToken == token then return end
    if session.currentToken and not session.segmentClosed then
        self:AppendSegment(reason == "guide" and "switch" or "advance")
    end
    local active, wall = self:GetClocks()
    session.currentToken = token
    session.currentGuideKey = key
    session.currentStepId = id
    session.currentStep = index
    session.segmentActive = active
    session.segmentWall = wall
    session.segmentClosed = nil
    session.currentCategories = {}
    session.lastClosedToken = nil
    session.sampleAt = _G.GetTime()
    run.speedrunFingerprint = run.speedrunFingerprint or self:BuildFingerprint(run)
    run.speedrunRuleset = run.speedrunRuleset or CurrentRulesetId()
    coach:Refresh(true)
end

function speedrun:StartCurrentStep(reason)
    local guide = addon.currentGuide
    local index = RXPCData and tonumber(RXPCData.currentStep)
    local step = guide and guide.steps and index and guide.steps[index]
    if step then self:StartSegment(guide, step, reason) end
end

function speedrun:RecordDeviation(kind, detail)
    if not ToolEnabled("enableSpeedrunRules") then return end
    local run = self:EnsureRun(self:GetRun(true))
    if not run or type(kind) ~= "string" then return end
    local entry = type(run.deviations[kind]) == "table" and
                      run.deviations[kind] or {count = 0}
    entry.count = min(9999, (tonumber(entry.count) or 0) + 1)
    entry.first = entry.first or floor(select(1, self:GetClocks()) + 0.5)
    entry.violation = not rules:IsAllowed(kind)
    if detail ~= nil and (type(detail) == "string" or type(detail) == "number" or
        type(detail) == "boolean") then entry.detail = tostring(detail):sub(1, 80) end
    run.deviations[kind] = entry
    local keys = {}
    for name in pairs(run.deviations) do tinsert(keys, name) end
    table.sort(keys)
    run.speedrunIntegrityFingerprint = table.concat(keys, "|")
    rules:Refresh()
end

function speedrun:RecordDeviationOnce(kind, detail)
    local run = self:EnsureRun(self:GetRun(true))
    if run and type(run.deviations) == "table" and run.deviations[kind] then return end
    self:RecordDeviation(kind, detail)
end

local function RunHasToken(run, token)
    for _, segment in ipairs(type(run) == "table" and run.segments or {}) do
        if segment.t == token then return true end
    end
    return false
end

function speedrun:IsCompatible(run, current)
    if type(run) ~= "table" or not run.finished or type(run.segments) ~= "table" then
        return false
    end
    current = current or self:GetRun(false)
    if not current then return false end
    if run.class ~= current.class or run.race ~= current.race or
        run.faction ~= current.faction or
        math.abs((tonumber(run.xpRate) or 1) - (tonumber(current.xpRate) or 1)) > 0.001 or
        tostring(run.speedrunRuleset or "unrestricted") ~=
            tostring(current.speedrunRuleset or CurrentRulesetId()) then return false end
    if run.speedrunFingerprint and current.speedrunFingerprint and
        run.speedrunFingerprint ~= current.speedrunFingerprint then return false end
    if tostring(run.speedrunIntegrityFingerprint or "") ~=
        tostring(current.speedrunIntegrityFingerprint or "") then return false end
    local _, session = self:EnsureStores()
    return not session.currentToken or RunHasToken(run, session.currentToken)
end

function speedrun:GetCompatibleRuns()
    local result = {}
    local current = self:GetRun(false)
    local runs = RXPData.levelingArchives and RXPData.levelingArchives.runs or {}
    for _, run in pairs(runs) do
        if run ~= current and self:IsCompatible(run, current) then tinsert(result, run) end
    end
    table.sort(result, function(a, b)
        return (tonumber(a.speedrunActiveDuration) or math.huge) <
                   (tonumber(b.speedrunActiveDuration) or math.huge)
    end)
    return result
end

local function Median(values)
    if #values == 0 then return end
    table.sort(values)
    local middle = floor((#values + 1) / 2)
    if #values % 2 == 1 then return values[middle] end
    return (values[middle] + values[middle + 1]) / 2
end

local function Minimum(values)
    local result
    for _, value in ipairs(values or {}) do
        value = tonumber(value)
        if value and (not result or value < result) then result = value end
    end
    return result
end

function speedrun:GetReference()
    local mode = Profile().speedrunComparison or "pb"
    local runs = self:GetCompatibleRuns()
    if mode == "manual" then
        local id = tonumber(Profile().speedrunManualReference)
        for _, run in pairs(RXPData.levelingArchives and
                                RXPData.levelingArchives.runs or {}) do
            if run.id == id and run.finished and type(run.segments) == "table" then
                return run, mode
            end
        end
    elseif mode == "median" then
        table.sort(runs, function(a, b)
            return (tonumber(a.updatedAt) or 0) > (tonumber(b.updatedAt) or 0)
        end)
        while #runs > 10 do tremove(runs) end
        return #runs > 0 and runs or nil, mode
    elseif mode == "best" then
        return #runs > 0 and runs or nil, mode
    end
    return runs[1], "pb"
end

local function SegmentValue(segment, clock)
    return tonumber(clock == "wall" and segment.w or segment.a)
end

function speedrun:GetComparison()
    local run = self:GetRun(false)
    local _, session = self:EnsureStores()
    if not run or not session.currentToken then return {status = "idle"} end
    local clock = Profile().speedrunDisplayClock == "wall" and "wall" or "active"
    local reference, mode = self:GetReference()
    local currentSegments = run.segments or {}
    local currentTotal = 0
    for _, segment in ipairs(currentSegments) do
        currentTotal = currentTotal + (SegmentValue(segment, clock) or 0)
    end
    local active, wall = self:GetClocks()
    local segmentNow = (clock == "wall" and wall or active) -
                           (tonumber(clock == "wall" and session.segmentWall or
                                                   session.segmentActive) or 0)
    local result = {mode = mode, clock = clock, currentTotal = currentTotal,
                    currentSegment = max(0, segmentNow), status = "learning"}
    local references = type(reference) == "table" and reference[1] and reference or
                           (reference and {reference} or {})
    if #references == 0 then return result end

    local cumulativeValues, segmentValues, projectedValues, finalValues = {}, {}, {}, {}
    local bestFinal, bestByToken = nil, {}
    for _, candidate in ipairs(references) do
        local cumulative, matched, currentReference, remaining = 0, true, nil, 0
        for index, segment in ipairs(candidate.segments or {}) do
            local value = SegmentValue(segment, clock) or 0
            if index <= #currentSegments then
                if currentSegments[index].t ~= segment.t then matched = false break end
                cumulative = cumulative + value
            elseif index == #currentSegments + 1 and segment.t == session.currentToken then
                currentReference = value
            else
                remaining = remaining + value
            end
            if not bestByToken[segment.t] or value < bestByToken[segment.t] then
                bestByToken[segment.t] = value
            end
        end
        if not matched or not currentReference then
            -- A deliberately chosen branch may later rejoin the reference.
            -- Resume prediction only at a stable token present in both routes;
            -- no time is fabricated while the routes remain disjoint.
            cumulative, currentReference, remaining = 0, nil, 0
            local found
            for _, segment in ipairs(candidate.segments or {}) do
                local value = SegmentValue(segment, clock) or 0
                if not bestByToken[segment.t] or value < bestByToken[segment.t] then
                    bestByToken[segment.t] = value
                end
                if segment.t == session.currentToken and not found then
                    found = true
                    currentReference = value
                elseif found then
                    remaining = remaining + value
                else
                    cumulative = cumulative + value
                end
            end
            matched = found == true
        end
        local final = tonumber(clock == "wall" and candidate.speedrunWallDuration or
                                      candidate.speedrunActiveDuration)
        if matched and currentReference then
            tinsert(cumulativeValues, cumulative)
            tinsert(segmentValues, currentReference)
            if final then
                tinsert(finalValues, final)
                tinsert(projectedValues, currentTotal + segmentNow +
                    max(0, final - cumulative - currentReference))
                bestFinal = not bestFinal and final or min(bestFinal, final)
            end
        end
    end
    local referenceCumulative = mode == "best" and
        Minimum(cumulativeValues) or Median(cumulativeValues)
    local referenceSegment = mode == "best" and
        Minimum(segmentValues) or Median(segmentValues)
    if not referenceCumulative or not referenceSegment then
        result.status = "diverged"
        return result
    end
    result.status = "matched"
    result.totalDelta = currentTotal - referenceCumulative
    result.segmentDelta = segmentNow - referenceSegment
    result.referenceSegment = referenceSegment
    result.predicted = Median(projectedValues)
    result.referenceFinish = Median(finalValues)
    local latest = currentSegments[#currentSegments]
    if latest then
        local values = {}
        for _, candidate in ipairs(references) do
            local segment = candidate.segments and candidate.segments[#currentSegments]
            if segment and segment.t == latest.t then
                local value = SegmentValue(segment, clock)
                if value then tinsert(values, value) end
            end
        end
        local baseline = mode == "best" and Minimum(values) or Median(values)
        local value = SegmentValue(latest, clock)
        local delta = baseline and value and (value - baseline)
        local threshold = max(1, tonumber(Profile().speedrunPaceThreshold) or 15)
        if delta and math.abs(delta) >= threshold then
            result.latestMeaningful = delta
        end
    end
    local bestPossible = 0
    for _, value in pairs(bestByToken) do bestPossible = bestPossible + value end
    result.bestPossible = bestPossible > 0 and bestPossible or bestFinal
    result.reference = type(reference) == "table" and reference.id or nil
    return result
end

function speedrun:SetManualReference(id)
    Profile().speedrunComparison = "manual"
    Profile().speedrunManualReference = tonumber(id)
    coach:Refresh(true)
end

function speedrun:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self.loading = false
        self.onTaxi = UnitOnTaxi and UnitOnTaxi("player") or false
        self:ResumeActive()
        self:StartCurrentStep("world")
    elseif event == "PLAYER_LEAVING_WORLD" or event == "PLAYER_LOGOUT" then
        self.loading = true
        self:PauseActive(true)
    elseif event == "PLAYER_CONTROL_LOST" then
        if (UnitOnTaxi and UnitOnTaxi("player")) or
            (addon.flightInfo and addon.flightInfo.startFlight and
            _G.GetTime() - addon.flightInfo.startFlight < 2) then
            self.onTaxi = true
        end
    elseif event == "PLAYER_CONTROL_GAINED" then
        self.onTaxi = UnitOnTaxi and UnitOnTaxi("player") or false
    elseif event == "MERCHANT_SHOW" then
        self.merchantOpen = true
        audio:Play("vendor")
    elseif event == "MERCHANT_CLOSED" then self.merchantOpen = false
    elseif event == "TRAINER_SHOW" then
        self.trainerOpen = true
        audio:Play("trainer")
    elseif event == "TRAINER_CLOSED" then self.trainerOpen = false
    elseif event == "QUEST_DETAIL" or event == "QUEST_COMPLETE" then
        self.questOpen = true
    elseif event == "QUEST_FINISHED" then self.questOpen = false
    elseif event == "GOSSIP_SHOW" then self.gossipOpen = true
    elseif event == "GOSSIP_CLOSED" then self.gossipOpen = false
    elseif event == "PLAYER_DEAD" then
        self:RecordDeviation("death")
        local deathskip
        for _, step in ipairs(addon.RXPFrame and addon.RXPFrame.activeSteps or {}) do
            for _, element in ipairs(step.elements or {}) do
                if element.tag == "deathskip" then deathskip = true break end
            end
            if deathskip then break end
        end
        if deathskip then audio:Play("deathskip") end
    elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
        local grouped = (GetNumPartyMembers and GetNumPartyMembers() or 0) > 0 or
                            (GetNumRaidMembers and GetNumRaidMembers() or 0) > 0
        if grouped then self:RecordDeviation("grouped") end
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        for slot = 1, 19 do
            local link = GetInventoryItemLink and GetInventoryItemLink("player", slot)
            local quality
            if link then
                local _, _, itemQuality = GetItemInfo(link)
                quality = itemQuality
            end
            if tonumber(quality) == 7 then
                self:RecordDeviation("heirloom")
                break
            end
        end
    elseif event == "PLAYER_XP_UPDATE" then
        local exhaustion = GetXPExhaustion and GetXPExhaustion()
        if (tonumber(exhaustion) or 0) > 0 then
            self:RecordDeviationOnce("rested-xp")
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, spellName, spellId = ...
        if unit == "player" then
            local name = type(spellName) == "string" and spellName or
                         (tonumber(spellId) and GetSpellInfo(spellId))
            local hearth = GetSpellInfo(8690)
            local recall = GetSpellInfo(556)
            if name and (name == hearth or name == recall) then audio:Play("hearth") end
        end
    elseif event == "CHAT_MSG_LOOT" then
        audio:Play("loot")
    elseif event == "BAG_UPDATE" then
        if not GetContainerNumFreeSlots then return end
        local free = 0
        for bag = 0, 4 do
            local bagFree = GetContainerNumFreeSlots(bag)
            free = free + (tonumber(bagFree) or 0)
        end
        if free <= 2 and not self.inventoryLow then
            self.inventoryLow = true
            audio:Play("inventory")
        elseif free > 2 then
            self.inventoryLow = nil
        end
    end
    local _, session = self:EnsureStores()
    local rate = tonumber(Profile().xprate) or 1
    if session.lastXPRate and math.abs(rate - session.lastXPRate) > 0.001 then
        self:RecordDeviation("xp-rate-change", format("%.3f", rate))
    end
    session.lastXPRate = rate
    self:Sample()
end

function coach:BuildText()
    local comparison = speedrun:GetComparison()
    local run = speedrun:GetRun(false) or speedrun.lastFinishedRun
    local active, wall = speedrun:GetClocks()
    local lines = {
        L("Live Speedrun Coach"),
        format(L("Active time: %s"), DurationText(active)),
        format(L("Wall time: %s"), DurationText(wall)),
        format(L("Comparison: %s"), tostring(comparison.mode or "pb")),
    }
    if comparison.status == "matched" then
        tinsert(lines, format(L("Total delta: %s"),
                              DurationText(comparison.totalDelta, true)))
        tinsert(lines, format(L("Current segment delta: %s"),
                              DurationText(comparison.segmentDelta, true)))
        if comparison.latestMeaningful then
            tinsert(lines, format(L("Latest completed segment: %s"),
                                  DurationText(comparison.latestMeaningful, true)))
        end
        tinsert(lines, format(L("Projected finish: %s"),
                              DurationText(comparison.predicted)))
        tinsert(lines, format(L("Best possible/reference finish: %s"),
                              DurationText(comparison.bestPossible or
                                               comparison.referenceFinish)))
        tinsert(lines, format(L("Pace trend: %s"),
            comparison.totalDelta <= -10 and L("gaining time") or
            comparison.totalDelta >= 10 and L("losing time") or L("steady")))
    elseif comparison.status == "diverged" then
        tinsert(lines, L("The current route has diverged from the selected reference. Prediction resumes when a compatible segment is reached."))
    else
        tinsert(lines, L("Complete a compatible archived run to unlock live deltas and predictions."))
    end
    if addon.tracker and addon.tracker.GetElapsedTimes and UnitXPMax("player") > 0 then
        local firstElapsed = addon.tracker:GetElapsedTimes()
        local elapsed = tonumber(firstElapsed)
        local current, maximum = UnitXP("player"), UnitXPMax("player")
        if elapsed and current and current > 0 and maximum and maximum > current then
            local projectedLevel = elapsed * maximum / current
            tinsert(lines, format(L("Predicted next level: %s"),
                                  DurationText(projectedLevel)))
        end
    end
    tinsert(lines, "")
    tinsert(lines, L("Recent segments:"))
    local segments = run and run.segments or {}
    local first = max(1, #segments - 11)
    for index = first, #segments do
        local segment = segments[index]
        local categories, dominant, dominantValue = segment.c or {}, nil, 0
        for name, value in pairs(categories) do
            if value > dominantValue then dominant, dominantValue = name, value end
        end
        tinsert(lines, format("%d. %s #%s  %s / %s%s", index,
            tostring(segment.g or "guide"), tostring(segment.s or segment.n),
            DurationText(segment.a), DurationText(segment.w),
            dominant and ("  [" .. dominant .. "]") or ""))
    end
    if #segments == 0 then tinsert(lines, "  " .. L("No completed step segments yet.")) end
    if type(run and run.timeLossReport) == "table" and #run.timeLossReport > 0 then
        tinsert(lines, "")
        tinsert(lines, L("Largest time losses:"))
        for index, loss in ipairs(run.timeLossReport) do
            if index > 5 then break end
            tinsert(lines, format("%d. %s #%s  %s", index,
                tostring(loss.g or "guide"), tostring(loss.s or loss.n),
                DurationText(loss.delta, true)))
        end
    end
    return table.concat(lines, "\n")
end

function coach:Refresh(force)
    if not ToolEnabled("enableSpeedrunCoach") then
        if self.frame then self.frame:Hide() end
        self:RefreshBadge()
        return
    end
    if self.frame and self.frame:IsShown() then
        toolWindows:SetText(self.frame, self:BuildText())
    end
    self:RefreshBadge(force)
end

function coach:RefreshBadge()
    local button = self.badge
    if not button then return end
    local enabled = ToolEnabled("enableSpeedrunCoach")
    button:SetShown(enabled)
    if not enabled then
        if addon.UpdateFooterStatusAnchor then addon.UpdateFooterStatusAnchor() end
        return
    end
    local comparison = speedrun:GetComparison()
    if comparison.status == "matched" then
        button:SetText("D " .. DurationText(comparison.totalDelta, true))
        local text = button:GetFontString()
        if text then
            if comparison.totalDelta <= 0 then text:SetTextColor(0.35, 1, 0.35)
            else text:SetTextColor(1, 0.4, 0.3) end
        end
    elseif comparison.status == "diverged" then
        button:SetText("D ?")
    else
        button:SetText("RUN")
    end
    if addon.UpdateFooterStatusAnchor then addon.UpdateFooterStatusAnchor() end
end

function coach:CreateBadge()
    if self.badge then return end
    local footer = addon.RXPFrame and addon.RXPFrame.Footer
    if not footer or not footer.preflight then return end
    local button = CreateFrame("Button", "RXPSpeedrunCoachBadge", footer,
                               "UIPanelButtonTemplate")
    button:SetFrameLevel(footer:GetFrameLevel() + 2)
    button:SetSize(48, 18)
    button:SetPoint("LEFT", footer.preflight, "RIGHT", 1, 0)
    button:SetScript("OnClick", function() coach:Toggle() end)
    button:SetScript("OnEnter", function(self)
        local comparison = speedrun:GetComparison()
        _G.GameTooltip:SetOwner(self, "ANCHOR_TOP")
        _G.GameTooltip:AddLine(L("Live Speedrun Coach"))
        if comparison.status == "matched" then
            _G.GameTooltip:AddLine(format(L("Total delta: %s"),
                DurationText(comparison.totalDelta, true)), 1, 1, 1)
            _G.GameTooltip:AddLine(format(L("Current segment delta: %s"),
                DurationText(comparison.segmentDelta, true)), 1, 1, 1)
            if comparison.latestMeaningful then
                _G.GameTooltip:AddLine(format(L("Latest completed segment: %s"),
                    DurationText(comparison.latestMeaningful, true)), 1, 1, 1)
            end
            _G.GameTooltip:AddLine(format(L("Projected finish: %s"),
                DurationText(comparison.predicted)), 1, 1, 1)
        else
            _G.GameTooltip:AddLine(L("No compatible reference is available yet."),
                                   0.8, 0.8, 0.8, true)
        end
        _G.GameTooltip:AddLine(L("Click to open the speedrun coach."),
                               0.65, 0.78, 1, true)
        _G.GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() _G.GameTooltip:Hide() end)
    footer.speedrun = button
    self.badge = button
    self:RefreshBadge()
end

function coach:CreateWindow()
    if self.frame then return end
    local frame = toolWindows:Create({
        name = "RXPSpeedrunCoachWindow", title = L("Live Speedrun Coach"),
        width = 650, height = 440, minWidth = 470, minHeight = 320
    })
    toolWindows:AddScrollingText(frame, {top = 48, bottom = 58})
    local cycle = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    cycle:SetHeight(24)
    cycle:SetPoint("BOTTOMLEFT", 20, 18)
    cycle:SetText(L("Change Comparison"))
    toolWindows:SizeButton(cycle, 135, 190)
    cycle:SetScript("OnClick", function()
        local order = {pb = "median", median = "best", best = "pb", manual = "pb"}
        Profile().speedrunComparison = order[Profile().speedrunComparison or "pb"] or "pb"
        coach:Refresh(true)
    end)
    local archives = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    archives:SetHeight(24)
    archives:SetPoint("LEFT", cycle, "RIGHT", 8, 0)
    archives:SetText(L("Archives"))
    toolWindows:SizeButton(archives, 95, 145)
    archives:SetScript("OnClick", function()
        if addon.runArchive then addon.runArchive:Toggle() end
    end)
    frame:SetScript("OnShow", function() coach:Refresh(true) end)
    self.frame = frame
end

function coach:Toggle()
    if not speedrun.setup or not ToolEnabled("enableSpeedrunCoach") then return end
    if not self.frame then self:CreateWindow() end
    if self.frame:IsShown() then self.frame:Hide() else self.frame:Show() end
end

local cueSounds = {
    quest = "igQuestListOpen", turnin = "igQuestListComplete",
    loot = "ITEM_REPAIR", travel = "MapPing", hearth = "igSpellBookOpen",
    vendor = "igCharacterInfoTab", trainer = "igAbilityIconDrop",
    danger = "RaidWarning", deathskip = "RaidWarning",
    grind = "igQuestListComplete", inventory = "igMainMenuOptionCheckBoxOn",
    pace = "igMainMenuOptionCheckBoxOn"
}

function audio:IsCategoryEnabled(category)
    local categories = Profile().speedrunAudioCategories
    return type(categories) ~= "table" or categories[category] ~= false
end

function audio:Play(category, force)
    if not ToolEnabled("enableSpeedrunAudio") and not force then return end
    if not self:IsCategoryEnabled(category) and not force then return end
    if Profile().speedrunAudioMuteCombat ~= false and UnitAffectingCombat and
        UnitAffectingCombat("player") and not force then return end
    local now = _G.GetTime()
    self.lastCue = self.lastCue or {}
    if not force and now - (tonumber(self.lastCue[category]) or 0) < 1.25 then return end
    self.lastCue[category] = now
    pcall(_G.PlaySound, cueSounds[category] or "MapPing")
end

function audio:BuildText()
    local lines = {L("Speedrun Audio Director"),
        ToolEnabled("enableSpeedrunAudio") and L("Enabled") or L("Disabled"), ""}
    for _, category in ipairs({"quest", "turnin", "loot", "travel", "hearth",
        "vendor", "trainer", "danger", "deathskip", "grind", "inventory", "pace"}) do
        tinsert(lines, format("%s: %s", category,
            self:IsCategoryEnabled(category) and L("On") or L("Off")))
    end
    tinsert(lines, "")
    tinsert(lines, L("Audio cues are advisory and never invoke an action."))
    return table.concat(lines, "\n")
end

function audio:Refresh()
    if self.frame and self.frame:IsShown() then
        toolWindows:SetText(self.frame, self:BuildText())
    end
end

function audio:CreateWindow()
    if self.frame then return end
    local frame = toolWindows:Create({name = "RXPSpeedrunAudioWindow",
        title = L("Speedrun Audio Director"), width = 520, height = 390,
        minWidth = 400, minHeight = 300})
    toolWindows:AddScrollingText(frame, {top = 48, bottom = 58})
    local test = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    test:SetHeight(24)
    test:SetPoint("BOTTOMLEFT", 20, 18)
    test:SetText(L("Test Cue"))
    toolWindows:SizeButton(test, 95, 140)
    test:SetScript("OnClick", function() audio:Play("pace", true) end)
    frame:SetScript("OnShow", function() audio:Refresh() end)
    self.frame = frame
end

function audio:Toggle()
    if not speedrun.setup or not ToolEnabled("enableSpeedrunAudio") then return end
    if not self.frame then self:CreateWindow() end
    if self.frame:IsShown() then self.frame:Hide() else self.frame:Show() end
end

function audio:CueUpcoming(step)
    if not ToolEnabled("enableSpeedrunAudio") or type(step) ~= "table" then return end
    local tags = {}
    local guide = addon.currentGuide
    local start = tonumber(step.index) or tonumber(RXPCData.currentStep) or 1
    local lead = max(0, min(10, floor(tonumber(Profile().speedrunAudioLeadSteps) or 1)))
    for index = start, start + lead do
        local candidate = guide and guide.steps and guide.steps[index]
        for _, element in ipairs(candidate and candidate.elements or {}) do
            tags[element.tag or ""] = true
        end
    end
    local category = tags.turnin and "turnin" or tags.accept and "quest" or
        (tags.fly or tags.fp) and "travel" or tags.hs and "hearth" or
        (tags.vendor or tags.buy) and "vendor" or
        (tags.trainer or tags.train) and "trainer" or
        (tags.deathskip and "deathskip") or
        (tags.collect or tags.complete or tags.mob) and "loot"
    if category then self:Play(category) end
end

function rules:BuildText()
    local run = speedrun:GetRun(false)
    local id = CurrentRulesetId()
    local lines = {L("Run Ruleset and Integrity"),
                   format(L("Ruleset: %s"), id), "", L("Observed deviations:")}
    local names = {}
    for name in pairs(run and run.deviations or {}) do tinsert(names, name) end
    table.sort(names)
    for _, name in ipairs(names) do
        local entry = run.deviations[name]
        tinsert(lines, format("%s: %d%s%s", name, tonumber(entry.count) or 0,
            entry.violation and " [RULE WARNING]" or " [recorded]",
            entry.detail and (" (" .. tostring(entry.detail) .. ")") or ""))
    end
    if #names == 0 then tinsert(lines, "  " .. L("None recorded.")) end
    tinsert(lines, "")
    tinsert(lines, L("Deviations never delete or invalidate an archive. They only prevent misleading automatic comparisons."))
    return table.concat(lines, "\n")
end

function rules:Refresh()
    if self.frame and self.frame:IsShown() then
        toolWindows:SetText(self.frame, self:BuildText())
    end
end

function rules:Export()
    local run = speedrun:GetRun(false)
    local active, wall = speedrun:GetClocks()
    local lines = {"RXPGuides sanitized speedrun integrity report",
        "Addon=" .. tostring(addon.release),
        "Ruleset=" .. CurrentRulesetId(),
        "Class=" .. tostring(run and run.class or "UNKNOWN"),
        "Race=" .. tostring(run and run.race or "UNKNOWN"),
        "Faction=" .. tostring(run and run.faction or "Neutral"),
        "XPRate=" .. tostring(run and run.xpRate or 1),
        "TimingVersion=" .. tostring(run and run.timingVersion or TIMING_VERSION),
        "ActiveSeconds=" .. tostring(floor(active + 0.5)),
        "WallSeconds=" .. tostring(floor(wall + 0.5)),
        "SegmentCount=" .. tostring(run and type(run.segments) == "table" and
                                         #run.segments or 0),
        "Route=" .. table.concat(run and type(run.route) == "table" and
                                      run.route or {}, " > ")}
    local names = {}
    for name in pairs(run and run.deviations or {}) do tinsert(names, name) end
    table.sort(names)
    for _, name in ipairs(names) do
        tinsert(lines, format("Deviation:%s=%d", name,
            tonumber(run.deviations[name].count) or 0))
    end
    addon.comms.OpenBrandedExport(L("Speedrun Integrity Report"),
        L("No player, realm, chat, account, guild, or GUID data is included."),
        table.concat(lines, "\n"), 620, 420)
end

function rules:CreateWindow()
    if self.frame then return end
    local frame = toolWindows:Create({name = "RXPSpeedrunRulesWindow",
        title = L("Run Ruleset and Integrity"), width = 590, height = 410,
        minWidth = 430, minHeight = 310})
    toolWindows:AddScrollingText(frame, {top = 48, bottom = 58})
    local export = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    export:SetHeight(24)
    export:SetPoint("BOTTOMLEFT", 20, 18)
    export:SetText(L("Export"))
    toolWindows:SizeButton(export, 95, 140)
    export:SetScript("OnClick", function() rules:Export() end)
    frame:SetScript("OnShow", function() rules:Refresh() end)
    self.frame = frame
end

function rules:Toggle()
    if not speedrun.setup or not ToolEnabled("enableSpeedrunRules") then return end
    if not self.frame then self:CreateWindow() end
    if self.frame:IsShown() then self.frame:Hide() else self.frame:Show() end
end

function speedrun:ApplySettings()
    local _, session = self:EnsureStores()
    if session.practiceRestore then
        addon.scheduler:CancelOwner(OWNER)
        self:PauseActive()
    elseif not TimingEnabled() then
        addon.scheduler:CancelOwner(OWNER)
        self:PauseActive()
    else
        self:ResumeActive()
        addon.scheduler:Ticker(OWNER, "sample", 1, function() speedrun:Sample() end)
        self:StartCurrentStep("settings")
    end
    if not ToolEnabled("enableSpeedrunCoach") and coach.frame then
        coach.frame:Hide()
    end
    if not ToolEnabled("enableSpeedrunAudio") and audio.frame then audio.frame:Hide() end
    if not ToolEnabled("enableSpeedrunRules") and rules.frame then rules.frame:Hide() end
    coach:Refresh(true)
    audio:Refresh()
    rules:Refresh()
end

function speedrun:ApplySuiteSettings()
    if not self.setup then return end
    self:ApplySettings()
    if addon.speedrunAdvisors and addon.speedrunAdvisors.ApplySettings then
        addon.speedrunAdvisors:ApplySettings()
    end
    if addon.speedrunPractice and addon.speedrunPractice.ApplySettings then
        addon.speedrunPractice:ApplySettings()
    end
    addon:SendEvent("RXP_SPEEDRUN_SETTINGS_CHANGED")
end

function speedrun:RegisterMessages()
    self.messageCallbacks = self.messageCallbacks or {
        RXP_STEP_ACTIVATED = function(_, step, guide)
            if not speedrun.setup or addon.speedrunPracticeActive then return end
            speedrun:StartSegment(guide, step, "advance")
            audio:CueUpcoming(step)
        end,
        RXP_STEP_COMPLETE = function(_, step, guide)
            if not speedrun.setup or addon.speedrunPracticeActive then return end
            local token = StepToken(guide, step)
            speedrun:CloseSegment("complete", token)
        end,
        RXP_GUIDE_LOADED = function(_, guide)
            if not speedrun.setup or addon.speedrunPracticeActive then return end
            speedrun:StartCurrentStep("guide")
            if guide and not guide.empty then
                local store, state = speedrun:EnsureStores()
                local key = GuideKey(guide)
                local changed = state.lastGuideKey and key and state.lastGuideKey ~= key
                if changed then
                    if ToolEnabled("enableSpeedrunRules") then
                        speedrun:RecordDeviation("guide-change", key)
                    end
                    local active = select(1, speedrun:GetClocks())
                    speedrun:CommitPendingBranch(active)
                    state.branchKey = speedrun:BuildBranchKey(state.lastGuideKey,
                        key, speedrun:GetRun(false))
                    state.branchStartedActive = active
                end
                state.lastGuideKey = key or state.lastGuideKey
                if changed or not state.guideStartedActive then
                    state.guideStartedActive = select(1, speedrun:GetClocks())
                end
            end
        end,
        RXP_QUEST_ACCEPT = function()
            if speedrun.setup then audio:Play("quest") end
        end,
        RXP_QUEST_TURNIN = function()
            if speedrun.setup then audio:Play("turnin") end
        end,
        RXP_FLIGHT_START = function()
            if speedrun.setup then
                speedrun.onTaxi = true
                audio:Play("travel")
            end
        end,
        RXP_JUNK = function()
            if speedrun.setup then audio:Play("inventory") end
        end,
        RXP_DANGEROUS_TARGET = function()
            if speedrun.setup then audio:Play("danger") end
        end,
    }
    for message, callback in pairs(self.messageCallbacks) do
        addon:RegisterMessage(message, callback)
    end
end

function speedrun:UnregisterMessages()
    for message, callback in pairs(self.messageCallbacks or {}) do
        addon:UnregisterMessage(message, callback)
    end
end

function speedrun:Setup()
    if self.setup then self:ApplySettings() return end
    self:EnsureStores()
    local run = self:EnsureRun(self:GetRun(true))
    local _, session = self:EnsureStores()
    if session.archiveId ~= run.id then self:ResetSession(run) end

    self:RegisterMessages()

    local frame = self.eventFrame or CreateFrame("Frame")
    frame:UnregisterAllEvents()
    for _, event in ipairs({
        "PLAYER_ENTERING_WORLD", "PLAYER_LEAVING_WORLD", "PLAYER_LOGOUT",
        "PLAYER_CONTROL_LOST", "PLAYER_CONTROL_GAINED", "PLAYER_DEAD",
        "PLAYER_ALIVE", "PLAYER_UNGHOST", "MERCHANT_SHOW", "MERCHANT_CLOSED",
        "TRAINER_SHOW", "TRAINER_CLOSED", "QUEST_DETAIL", "QUEST_COMPLETE",
        "QUEST_FINISHED", "GOSSIP_SHOW", "GOSSIP_CLOSED",
        "PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE",
        "PLAYER_EQUIPMENT_CHANGED", "PLAYER_LEVEL_UP", "PLAYER_XP_UPDATE",
        "CHAT_MSG_LOOT", "BAG_UPDATE", "UNIT_SPELLCAST_SUCCEEDED"
    }) do pcall(frame.RegisterEvent, frame, event) end
    frame:SetScript("OnEvent", function(_, event, ...) speedrun:OnEvent(event, ...) end)
    self.eventFrame = frame
    coach:CreateBadge()
    self.setup = true
    local ok, errorText = pcall(self.ApplySettings, self)
    if not ok then
        self.setup = false
        error(errorText, 0)
    end
end

function speedrun:Shutdown()
    addon.scheduler:CancelOwner(OWNER)
    self:PauseActive(false)
    if self.eventFrame then self.eventFrame:UnregisterAllEvents() end
    self:UnregisterMessages()
    if coach.frame then coach.frame:Hide() end
    if coach.badge then coach.badge:Hide() end
    if audio.frame then audio.frame:Hide() end
    if rules.frame then rules.frame:Hide() end
    self.setup = false
end
