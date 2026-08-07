local _, addon = ...

-- Shared, bounded look-ahead used by Route Preflight, Item Reservations, the
-- XP shortfall predictor, and the manually armed stuck-step watchdog.  This
-- file intentionally consumes processed guide elements rather than guide text,
-- so class/race/server compatibility conditions have already been applied.

local _G = _G
local format = string.format
local floor, max, min = math.floor, math.max, math.min
local L = addon.locale.Get
local tinsert = table.insert
local GetTime = _G.GetTime
local GetItemCount = _G.GetItemCount

addon.routePreflight = addon.routePreflight or {}
local preflight = addon.routePreflight

local MAX_LOOKAHEAD = 100
local QUEST_LOG_CAP = _G.MAX_QUESTLOG_QUESTS or 25
local WATCH_MIN, WATCH_MAX = 30, 600

local function Clamp(value, low, high, fallback)
    value = tonumber(value) or fallback
    return max(low, min(high, floor(value + 0.5)))
end

local function GuideKey(guide)
    if type(guide) ~= "table" or guide.empty then return end
    return guide.key or (addon.BuildGuideKey and addon.BuildGuideKey(guide))
end

local function StepNumber(step, fallback)
    return tonumber(step and step.index) or fallback or 0
end

local function QuestName(id)
    local name = addon.GetQuestName and addon.GetQuestName(id)
    return name or format("Quest %d", tonumber(id) or 0)
end

local function ItemName(id)
    local name = _G.GetItemInfo(id)
    return name or format("Item %d", tonumber(id) or 0)
end

local function CountQuestLogEntries()
    local entries = _G.GetNumQuestLogEntries and _G.GetNumQuestLogEntries() or 0
    local count = 0
    for index = 1, entries do
        local _, _, _, _, isHeader = _G.GetQuestLogTitle(index)
        if not isHeader then count = count + 1 end
    end
    return count
end

local function AddIssue(report, severity, step, kind, text, id)
    local issue = {
        severity = severity,
        step = StepNumber(step),
        stepId = step and step.stepId,
        kind = kind,
        text = text,
        id = id
    }
    tinsert(report.issues, issue)
    report.counts[severity] = (report.counts[severity] or 0) + 1
    return issue
end

local function AddReservation(report, element, step, quantity, reason)
    local id = tonumber(element and element.id)
    if not id then return end
    quantity = max(1, floor(tonumber(quantity) or 1))
    local entry = report.reservations[id]
    if not entry then
        entry = {
            id = id,
            quantity = quantity,
            firstStep = StepNumber(step),
            lastStep = StepNumber(step),
            reasons = {},
            cached = _G.GetItemInfo(id) ~= nil
        }
        report.reservations[id] = entry
    else
        -- Guide quantities normally describe the desired total in bags.  Using
        -- the maximum avoids multiplying the same requirement when a guide
        -- repeats a reminder across several steps.
        entry.quantity = max(entry.quantity, quantity)
        entry.lastStep = max(entry.lastStep, StepNumber(step))
    end
    if reason and not entry.reasons[reason] then entry.reasons[reason] = true end
end

local function AddItemsReservation(report, element, step, reason)
    if type(element.items) ~= "table" then return end
    for _, id in pairs(element.items) do
        id = tonumber(id)
        if id then AddReservation(report, {id = id}, step, 1, reason) end
    end
end

local function ObserveQuestXP(questId, xpReward)
    questId, xpReward = tonumber(questId), tonumber(xpReward)
    if not questId or not xpReward or xpReward <= 0 then return end
    RXPData.questXPObservations = type(RXPData.questXPObservations) == "table" and
                                      RXPData.questXPObservations or {}
    local rate = addon.settings and addon.settings.profile and
                     tonumber(addon.settings.profile.xprate) or 1
    local rateKey = format("%.2f", rate)
    local bucket = RXPData.questXPObservations[rateKey]
    if type(bucket) ~= "table" then
        bucket = {}
        RXPData.questXPObservations[rateKey] = bucket
    end
    local entry = type(bucket[questId]) == "table" and bucket[questId] or {}
    entry.min = entry.min and min(entry.min, xpReward) or xpReward
    entry.max = entry.max and max(entry.max, xpReward) or xpReward
    entry.count = min((tonumber(entry.count) or 0) + 1, 1000)
    entry.last = xpReward
    bucket[questId] = entry
end

local function GetObservedQuestXP(questId)
    local all = RXPData.questXPObservations
    if type(all) ~= "table" then return end
    local rate = addon.settings and addon.settings.profile and
                     tonumber(addon.settings.profile.xprate) or 1
    local bucket = all[format("%.2f", rate)]
    local entry = type(bucket) == "table" and bucket[tonumber(questId)]
    if type(entry) ~= "table" then return end
    local low, high = tonumber(entry.min), tonumber(entry.max)
    if low and high and low > 0 and high >= low then
        return low, high, tonumber(entry.count) or 1
    end
end

local function GetLiveQuestRewardXP(questId)
    if type(_G.GetQuestLogRewardXP) ~= "function" or
        type(_G.SelectQuestLogEntry) ~= "function" then return end
    local index = C_QuestLog and C_QuestLog.GetLogIndexForQuestID and
                      C_QuestLog.GetLogIndexForQuestID(questId) or
                      (_G.GetQuestLogIndexByID and _G.GetQuestLogIndexByID(questId))
    if not index then return end
    local previous = _G.GetQuestLogSelection and _G.GetQuestLogSelection()
    _G.SelectQuestLogEntry(index)
    local ok, reward = pcall(_G.GetQuestLogRewardXP)
    if previous and previous ~= index then pcall(_G.SelectQuestLogEntry, previous) end
    reward = ok and tonumber(reward)
    if reward and reward > 0 then return reward, reward, "live" end
end

local function AnalyzeXP(report, xpElement, xpStep, rewardLow, rewardHigh,
                         unknownRewards)
    local result = {
        step = xpStep and StepNumber(xpStep),
        level = xpElement and tonumber(xpElement.level),
        target = xpElement and tonumber(xpElement.xp) or 0,
        rewardLow = rewardLow,
        rewardHigh = rewardHigh,
        unknownRewards = unknownRewards,
        currentLevel = UnitLevel("player"),
        currentXP = UnitXP("player"),
        currentMax = UnitXPMax("player")
    }
    report.xp = result
    if not result.level then return end

    local required
    if result.level == result.currentLevel then
        local target = result.target
        if target < 0 then
            required = 0
        elseif target > 0 and target < 1 then
            target = floor(result.currentMax * target + 0.5)
            required = max(0, target - result.currentXP)
        else
            required = max(0, target - result.currentXP)
        end
    elseif result.level == result.currentLevel + 1 then
        if result.target < 0 then
            required = max(0, result.currentMax + result.target - result.currentXP)
        elseif result.target == 0 then
            required = max(0, result.currentMax - result.currentXP)
        elseif result.target >= 1 then
            required = max(0, result.currentMax - result.currentXP + result.target)
        end
    end
    result.required = required
    if not required then
        result.confidence = "unknown"
        result.message = format(
            "XP gate at step %d targets level %d; exact cross-level XP is not exposed by this client.",
            result.step or 0, result.level)
        return
    end

    result.shortfallLow = max(0, required - rewardHigh)
    result.shortfallHigh = max(0, required - rewardLow)
    if unknownRewards > 0 then
        result.confidence = "partial"
        result.message = format(
            "Known rewards cover %d-%d of %d XP; %d reward%s still unknown.",
            rewardLow, rewardHigh, required, unknownRewards,
            unknownRewards == 1 and " is" or "s are")
    elseif result.shortfallHigh > 0 then
        result.confidence = "high"
        result.message = result.shortfallLow == result.shortfallHigh and
            format("Predicted XP shortfall: %d before step %d.",
                   result.shortfallHigh, result.step or 0) or
            format("Predicted XP shortfall: %d-%d before step %d.",
                   result.shortfallLow, result.shortfallHigh, result.step or 0)
        AddIssue(report, "warning", xpStep, "xp", result.message)
    else
        result.confidence = "high"
        result.message = format("Known quest rewards cover the next XP gate at step %d.",
                                result.step or 0)
    end
end

function preflight:Scan(force)
    local started = addon.PerfBegin and addon.PerfBegin("route preflight")
    local guide = addon.currentGuide
    local current = tonumber(RXPCData.currentStep) or 1
    if type(guide) ~= "table" or guide.empty or type(guide.steps) ~= "table" then
        self.report = {issues = {}, reservations = {}, counts = {}, empty = true}
        self:UpdateBadge()
        if started and addon.PerfEnd then addon.PerfEnd("route preflight", started) end
        return self.report
    end

    local profile = addon.settings.profile
    local routeAhead = Clamp(profile.preflightLookahead, 1, MAX_LOOKAHEAD, 20)
    local reserveAhead = Clamp(profile.reservationLookahead, 1, MAX_LOOKAHEAD, 20)
    local scanAhead = max(routeAhead, reserveAhead)
    local report = {
        guideKey = GuideKey(guide),
        currentStep = current,
        lastStep = min(#guide.steps, current + scanAhead - 1),
        generated = GetTime(),
        issues = {},
        counts = {error = 0, warning = 0, info = 0},
        reservations = {},
        questLogStart = CountQuestLogEntries()
    }

    local questCount = report.questLogStart
    local simulatedActive = {}
    local futureRewarded = {}
    local futureAccepted = {}
    local countedTurnIn = {}
    local rewardLow, rewardHigh, unknownRewards = 0, 0, 0
    local nextXPElement, nextXPStep

    for index = current, report.lastStep do
        local step = guide.steps[index]
        if type(step) == "table" and not step.completed and
            not (RXPCData.stepSkip and RXPCData.stepSkip[index]) then
            for _, element in ipairs(step.elements or {}) do
                local tag = element.tag
                local inRoute = profile.enableRoutePreflight ~= false and
                                    index < current + routeAhead
                local inXP = profile.enableXPShortfallPredictor ~= false and
                                 index < current + routeAhead
                local inReserve = index < current + reserveAhead
                if inRoute and (tag == "accept" or tag == "daily") then
                    local ids = tag == "daily" and element.ids or {element.questId}
                    for _, rawId in ipairs(ids or {}) do
                        local id = tonumber(rawId)
                        if id and not addon.IsQuestTurnedIn(id) and
                            not addon.IsOnQuest(id) and not futureAccepted[id] then
                            local complete, missing = addon.GetQuestPreReqState and
                                addon.GetQuestPreReqState(id, guide.group, {
                                    active = simulatedActive,
                                    rewarded = futureRewarded
                                })
                            if complete == false then
                                local names = {}
                                for _, missingId in ipairs(missing or {}) do
                                    tinsert(names, QuestName(missingId))
                                end
                                AddIssue(report, "error", step, "prerequisite",
                                    format("%s is missing prerequisite%s: %s.",
                                        QuestName(id), #names == 1 and "" or "s",
                                        #names > 0 and table.concat(names, ", ") or "unknown"), id)
                            elseif complete == nil then
                                AddIssue(report, "info", step, "prerequisite",
                                    format("Server prerequisite data for %s is unavailable.",
                                           QuestName(id)), id)
                            end
                            futureAccepted[id] = true
                            simulatedActive[id] = true
                            questCount = questCount + 1
                            if questCount > QUEST_LOG_CAP then
                                AddIssue(report, "error", step, "questlog",
                                    format("Quest log may be full before accepting %s (%d/%d).",
                                           QuestName(id), questCount, QUEST_LOG_CAP), id)
                            elseif questCount >= QUEST_LOG_CAP then
                                AddIssue(report, "warning", step, "questlog",
                                    format("Quest log reaches %d/%d at %s.",
                                           questCount, QUEST_LOG_CAP, QuestName(id)), id)
                            end
                        end
                    end
                elseif (inRoute or inXP) and
                    (tag == "turnin" or tag == "dailyturnin") then
                    local ids = tag == "dailyturnin" and element.ids or {element.questId}
                    for _, rawId in ipairs(ids or {}) do
                        local id = tonumber(rawId)
                        if id then
                            if not countedTurnIn[id] then
                                if simulatedActive[id] then
                                    simulatedActive[id] = nil
                                    questCount = max(0, questCount - 1)
                                elseif addon.IsOnQuest(id) then
                                    questCount = max(0, questCount - 1)
                                end
                                countedTurnIn[id] = true
                            end
                            futureRewarded[id] = true
                            local low, high = GetLiveQuestRewardXP(id)
                            if not low then low, high = GetObservedQuestXP(id) end
                            if low then
                                rewardLow, rewardHigh = rewardLow + low, rewardHigh + high
                            else
                                unknownRewards = unknownRewards + 1
                            end
                        end
                    end
                elseif inRoute and tag == "fly" then
                    if element.fpAmbiguous then
                        AddIssue(report, "warning", step, "flight",
                            format("Flight destination %s is ambiguous and will remain manual.",
                                   tostring(element.location or "unknown")))
                    elseif not element.fpId then
                        AddIssue(report, "info", step, "flight",
                            format("Flight destination %s could not be resolved yet.",
                                   tostring(element.location or "unknown")))
                    elseif RXPCData.flightPaths and not RXPCData.flightPaths[element.fpId] then
                        AddIssue(report, "warning", step, "flight",
                            format("Flight path %s is not recorded as discovered.",
                                           tostring(element.location or element.fpId)))
                    end
                elseif inRoute and addon.player and addon.player.class == "HUNTER" and
                    (tag == "stable" or tag == "tame" or tag == "petfamily") then
                    local hasPet = UnitExists("pet") and not UnitIsDead("pet")
                    if tag == "tame" and hasPet then
                        AddIssue(report, "info", step, "pet",
                            "A tame step is approaching; make stable space for the current pet.")
                    elseif tag ~= "tame" and not hasPet then
                        AddIssue(report, "warning", step, "pet",
                            "A pet-related step is approaching but no active living pet is available.")
                    end
                elseif inRoute and (tag == "goto" or tag == "waypoint" or
                                     tag == "pin" or tag == "questgoto" or
                                     tag == "questwaypoint") then
                    local x, y = tonumber(element.x), tonumber(element.y)
                    if not tonumber(element.zone) or not x or not y then
                        AddIssue(report, "error", step, "map",
                            "A route point has unresolved map coordinates.")
                    elseif x < 0 or x > 100 or y < 0 or y > 100 then
                        AddIssue(report, "error", step, "map",
                            format("Route point %.1f, %.1f is outside the zone map.",
                                   x, y))
                    end
                elseif inXP and tag == "xp" and not nextXPElement then
                    nextXPElement, nextXPStep = element, step
                end

                if inReserve and profile.enableItemReservations ~= false then
                    if tag == "buy" or tag == "collect" then
                        AddReservation(report, element, step, element.qty,
                                       tag == "buy" and "purchase" or "collect")
                    elseif tag == "use" then
                        for id in pairs(element.activeItems or {}) do
                            AddReservation(report, {id = id}, step, 1, "use")
                        end
                    elseif tag == "equip" and element.id then
                        AddReservation(report, element, step, 1, "equip")
                    elseif tag == "itemcount" and element.id and
                        (tonumber(element.operator) or 0) >= 0 then
                        AddReservation(report, element, step,
                                       tonumber(element.total) or 1, "count")
                    elseif tag == "openitem" and element.id then
                        AddReservation(report, element, step, 1, "open")
                    elseif tag == "complete" and element.questId and
                        addon.questCompleteItems then
                        local items = addon.questCompleteItems[element.questId]
                        if type(items) ~= "table" then items = items and {items} or {} end
                        for _, id in pairs(items) do
                            AddReservation(report, {id = id}, step, 1, "quest")
                        end
                    elseif tag == "bankdeposit" or tag == "bankwithdraw" then
                        AddItemsReservation(report, element, step,
                                            tag == "bankdeposit" and "bank" or "withdraw")
                    elseif tag == "destroy" and element.id then
                        local entry = report.reservations[tonumber(element.id)]
                        if entry then entry.lastStep = min(entry.lastStep, index) end
                    end
                end
            end
        end
    end

    if profile.enableXPShortfallPredictor ~= false and nextXPElement then
        AnalyzeXP(report, nextXPElement, nextXPStep, rewardLow, rewardHigh,
                  unknownRewards)
    end
    self.report = report
    self:UpdateBadge()
    self:RefreshWindow()
    if addon.inventoryManager and addon.inventoryManager.RefreshJunkIcons then
        addon.inventoryManager.RefreshJunkIcons(0.05)
    end
    if started and addon.PerfEnd then addon.PerfEnd("route preflight", started) end
    return report
end

function preflight:IsItemReserved(id)
    if not (addon.settings and addon.settings.profile.enableItemReservations) then
        return false
    end
    local report = self.report
    local entry = report and report.reservations and report.reservations[tonumber(id)]
    if not entry then return false end
    return true, entry.quantity, entry.firstStep, entry
end

function preflight:GetReservation(id)
    local report = self.report
    return report and report.reservations and report.reservations[tonumber(id)]
end

function preflight:ScheduleScan(delay)
    if addon.performanceInspector and addon.performanceInspector.adaptiveActive then
        delay = max(tonumber(delay) or 0.15, 0.35)
    end
    self.scanSerial = (self.scanSerial or 0) + 1
    local serial = self.scanSerial
    C_Timer.After(delay or 0.15, function()
        if serial == preflight.scanSerial then preflight:Scan() end
    end)
end

local function BuildProgressSignature(step)
    if type(step) ~= "table" then return "none" end
    local parts = {tostring(step.completed == true)}
    for _, element in ipairs(step.elements or {}) do
        tinsert(parts, tostring(element.tag))
        tinsert(parts, tostring(element.completed == true))
        if element.id then
            tinsert(parts, tostring(GetItemCount(element.id) or 0))
        end
        if element.questId then
            tinsert(parts, tostring(addon.IsOnQuest(element.questId) == true))
            tinsert(parts, tostring(addon.IsQuestComplete(element.questId) == true))
            tinsert(parts, tostring(addon.IsQuestTurnedIn(element.questId) == true))
        end
    end
    return table.concat(parts, ":")
end

function preflight:IsWatchPaused()
    return _G.UnitAffectingCombat("player") or _G.UnitIsDeadOrGhost("player") or
        _G.UnitOnTaxi("player") or addon.loadingScreen or addon.isLoading or
        (_G.UnitIsAFK and _G.UnitIsAFK("player"))
end

function preflight:StopWatch(silent)
    if self.watchTicker and self.watchTicker.Cancel then self.watchTicker:Cancel() end
    self.watchTicker = nil
    local watched = self.watch
    self.watch = nil
    if not silent and watched then addon.comms.PrettyPrint("Step watchdog stopped.") end
    self:RefreshWindow()
end

function preflight:ArmWatch()
    local guide = addon.currentGuide
    local index = tonumber(RXPCData.currentStep)
    local step = guide and guide.steps and guide.steps[index]
    if not step or guide.empty then
        addon.comms.PrettyPrint("Open a guide step before arming the watchdog.")
        return false
    end
    self:StopWatch(true)
    self.watch = {
        guideKey = GuideKey(guide),
        step = index,
        stepId = step.stepId,
        elapsed = 0,
        signature = BuildProgressSignature(step),
        warned = false
    }
    self.watchTicker = C_Timer.NewTicker(1, function() preflight:WatchTick() end)
    addon.comms.PrettyPrint(
        "Watching step %d. The timer resets when measurable progress occurs.", index)
    self:RefreshWindow()
    return true
end

function preflight:ToggleWatch()
    if self.watch then self:StopWatch() else self:ArmWatch() end
end

function preflight:WatchTick()
    local watched = self.watch
    local guide = addon.currentGuide
    local index = tonumber(RXPCData.currentStep)
    if not watched or watched.guideKey ~= GuideKey(guide) or watched.step ~= index then
        self:StopWatch(true)
        return
    end
    if self:IsWatchPaused() then return end
    local step = guide.steps[index]
    local signature = BuildProgressSignature(step)
    if signature ~= watched.signature then
        watched.signature = signature
        watched.elapsed = 0
        watched.warned = false
        return
    end
    watched.elapsed = watched.elapsed + 1
    local timeout = Clamp(addon.settings.profile.stuckWatchdogTimeout,
                          WATCH_MIN, WATCH_MAX, 120)
    if watched.elapsed >= timeout and not watched.warned then
        watched.warned = true
        addon.comms:PopupNotification("RXP_STEP_WATCHDOG",
            format(L("Step %d has shown no measurable progress for %d seconds. Use /rxp diagnose to inspect it, or /rxp watch to stop watching."),
                   index, timeout))
        if addon.diagnostics and addon.diagnostics.Record then
            addon.diagnostics:Record("WATCHDOG", {step = index, timeout = timeout})
        end
    end
    self:RefreshWindow()
end

local function ReasonsText(reasons)
    local list = {}
    for reason in pairs(reasons or {}) do tinsert(list, reason) end
    table.sort(list)
    return table.concat(list, ", ")
end

function preflight:BuildText()
    local report = self.report or self:Scan()
    if report.empty then return L("No guide is currently selected.") end
    local lines = {
        format(L("Guide steps %d-%d"), report.currentStep, report.lastStep), ""
    }
    if addon.settings.profile.enableRoutePreflight == false then
        tinsert(lines, L("Route Preflight: disabled (reservations and XP may remain active)."))
    else
        tinsert(lines, format(L("Route Preflight: %d blocker(s), %d warning(s), %d note(s)"),
            report.counts.error or 0, report.counts.warning or 0,
            report.counts.info or 0))
        if #report.issues == 0 then
            tinsert(lines, "  [OK] " .. L("No proven route blockers found."))
        end
    end
    for _, issue in ipairs(report.issues) do
        local symbol = issue.severity == "error" and "[X]" or
                           issue.severity == "warning" and "[!]" or "[?]"
        tinsert(lines, format(L("  %s Step %d: %s"), symbol, issue.step, issue.text))
    end

    tinsert(lines, "")
    tinsert(lines, L("Reserved Items:"))
    local ids = {}
    for id in pairs(report.reservations) do tinsert(ids, id) end
    table.sort(ids)
    if #ids == 0 then tinsert(lines, "  " .. L("None in the selected look-ahead.")) end
    for _, id in ipairs(ids) do
        local entry = report.reservations[id]
        local carried = GetItemCount(id) or 0
        tinsert(lines, format(L("  %s x%d (have %d), steps %d-%d - %s"),
            ItemName(id), entry.quantity, carried, entry.firstStep,
            entry.lastStep, ReasonsText(entry.reasons)) ..
            (entry.cached and "" or " [" .. L("item data loading") .. "]"))
    end

    tinsert(lines, "")
    tinsert(lines, L("XP Shortfall Predictor:"))
    if report.xp then
        tinsert(lines, "  " .. tostring(report.xp.message or L("Waiting for XP data.")))
    else
        tinsert(lines, "  " .. L("No XP gate appears in the selected look-ahead."))
    end
    if self.watch then
        tinsert(lines, "")
        tinsert(lines, format(L("Watchdog: armed for step %d (%d seconds without progress)."),
                              self.watch.step, self.watch.elapsed or 0))
    end
    return table.concat(lines, "\n")
end

function preflight:CreateWindow()
    local frame = CreateFrame("Frame", "RXPRoutePreflightWindow", UIParent)
    frame:SetSize(650, 460)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true,
        tileSize = 32, edgeSize = 32,
        insets = {left = 8, right = 8, top = 8, bottom = 8}})
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -17)
    title:SetText(L("Route Preflight"))
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)

    local scroll = CreateFrame("ScrollFrame", "RXPRoutePreflightScroll", frame,
                               "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 22, -48)
    scroll:SetPoint("BOTTOMRIGHT", -36, 51)
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(575, 1)
    scroll:SetScrollChild(child)
    local text = child:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT")
    text:SetWidth(570)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetTextColor(1, 1, 1)
    child.text = text
    frame.scrollChild = child

    local rescan = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    rescan:SetSize(100, 24)
    rescan:SetPoint("BOTTOMLEFT", 20, 18)
    rescan:SetText(L("Rescan"))
    rescan:SetScript("OnClick", function() preflight:Scan(true) end)
    local watch = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    watch:SetSize(145, 24)
    watch:SetPoint("LEFT", rescan, "RIGHT", 8, 0)
    watch:SetScript("OnClick", function() preflight:ToggleWatch() end)
    frame.watchButton = watch
    frame:SetScript("OnShow", function() preflight:Scan(true) end)
    -- Newly-created frames are visible by default on the legacy client.  Keep
    -- tool windows dormant until Toggle explicitly opens them; otherwise the
    -- first button press merely hides the just-created window.
    frame:Hide()
    self.frame = frame
    self:RefreshWindow()
end

function preflight:RefreshWindow()
    local frame = self.frame
    if not (frame and frame:IsShown()) then return end
    local text = self:BuildText()
    frame.scrollChild.text:SetText(text)
    local height = max(360, frame.scrollChild.text:GetStringHeight() + 12)
    frame.scrollChild:SetHeight(height)
    frame.watchButton:SetText(self.watch and L("Stop Watching") or L("Watch Current Step"))
end

function preflight:Toggle()
    if not self.frame then self:CreateWindow() end
    if self.frame:IsShown() then self.frame:Hide() else self.frame:Show() end
end

function preflight:UpdateBadge()
    if addon.UpdatePreflightBadge then addon.UpdatePreflightBadge(self.report) end
end

function preflight:OnGuideChanged()
    if self.watch then self:StopWatch(true) end
    self:ScheduleScan(0.05)
end

function preflight:OnProgressEvent(event, ...)
    if event == "QUEST_TURNED_IN" then ObserveQuestXP(...) end
    self:ScheduleScan(event == "PLAYER_XP_UPDATE" and 0.3 or 0.12)
end

function preflight:Setup()
    if self.setup then return end
    self.setup = true
    RXPData.questXPObservations = type(RXPData.questXPObservations) == "table" and
                                      RXPData.questXPObservations or {}
    addon:RegisterMessage("RXP_STEP_ACTIVATED", function()
        preflight:OnGuideChanged()
    end)
    addon:RegisterMessage("RXP_GUIDE_LOADED", function()
        preflight:OnGuideChanged()
    end)
    local watcher = CreateFrame("Frame")
    local events = {"QUEST_LOG_UPDATE", "QUEST_ACCEPTED", "QUEST_TURNED_IN",
        "BAG_UPDATE", "BAG_UPDATE_DELAYED", "GET_ITEM_INFO_RECEIVED",
        "PLAYER_LEVEL_UP", "PLAYER_XP_UPDATE", "TAXIMAP_OPENED",
        "ZONE_CHANGED_NEW_AREA", "PLAYER_EQUIPMENT_CHANGED"}
    for _, event in ipairs(events) do pcall(watcher.RegisterEvent, watcher, event) end
    watcher:SetScript("OnEvent", function(_, event, ...)
        preflight:OnProgressEvent(event, ...)
    end)
    self.eventFrame = watcher
    self:ScheduleScan(0.5)
end
