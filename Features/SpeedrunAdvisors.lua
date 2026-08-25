local _, addon = ...

-- Advisory-only speedrunning helpers.  These services consume already parsed
-- guide elements and public 3.3.5 state.  None of them clicks, targets, moves,
-- repairs, trains, buys, releases spirit, or resurrects the player.

local _G = _G
local format = string.format
local floor, max, min, ceil = math.floor, math.max, math.min, math.ceil
local tinsert = table.insert
local L = addon.locale.Get
local HBD = LibStub("HereBeDragons-2.0")
local toolWindows = addon.toolWindows
local OWNER = "speedrun-advisors"
local MAX_MOB_OBSERVATIONS = 500

addon.speedrunGrind = addon.speedrunGrind or {}
addon.speedrunPitStop = addon.speedrunPitStop or {}
addon.speedrunRoute = addon.speedrunRoute or {}
addon.speedrunDeathwarp = addon.speedrunDeathwarp or {}
addon.speedrunAdvisors = addon.speedrunAdvisors or {}

local grind = addon.speedrunGrind
local pitstop = addon.speedrunPitStop
local strategist = addon.speedrunRoute
local deathwarp = addon.speedrunDeathwarp
local advisors = addon.speedrunAdvisors

local function Profile()
    return addon.settings and addon.settings.profile or {}
end

local function Enabled(key)
    return Profile().enableSpeedrunSuite ~= false and Profile()[key] == true
end

local function Duration(seconds)
    seconds = tonumber(seconds)
    if not seconds then return "-" end
    seconds = max(0, floor(seconds + 0.5))
    if seconds >= 3600 then
        return format("%d:%02d:%02d", floor(seconds / 3600),
                      floor(seconds % 3600 / 60), seconds % 60)
    end
    return format("%d:%02d", floor(seconds / 60), seconds % 60)
end

local function FinishPerf(label, started)
    if started and addon.PerfEnd then addon.PerfEnd(label, started) end
end

local function ClampSteps(value, fallback)
    return max(1, min(100, floor(tonumber(value) or fallback or 20)))
end

local function CurrentRange(ahead)
    local guide = addon.currentGuide
    if type(guide) ~= "table" or guide.empty or type(guide.steps) ~= "table" then
        return guide, 1, 0
    end
    local first = max(1, tonumber(RXPCData.currentStep) or 1)
    return guide, first, min(#guide.steps, first + ClampSteps(ahead) - 1)
end

local function CreatureName(value)
    local name = addon.GetCreatureName and addon.GetCreatureName(value) or value
    return type(name) == "string" and name or ""
end

local function FirstCoordinate(step)
    for _, element in ipairs(step and step.elements or {}) do
        if tonumber(element.zone) and tonumber(element.x) and tonumber(element.y) and
            tonumber(element.wx) and tonumber(element.wy) then return element end
    end
end

local function PlayerDistance(element)
    if not element then return end
    local px, py, instance = HBD:GetPlayerWorldPosition()
    if not px or not py or instance ~= element.instance then return end
    return HBD:GetWorldDistance(instance, px, py, element.wx, element.wy)
end

local function AddButton(frame, text, x, callback, minimum)
    local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button:SetHeight(24)
    button:SetPoint("BOTTOMLEFT", x, 18)
    button:SetText(text)
    toolWindows:SizeButton(button, minimum or 90, 185)
    button:SetScript("OnClick", callback)
    return button
end

local function Toggle(service, setting)
    if not advisors.setup or not Enabled(setting) then return end
    if not service.frame then service:CreateWindow() end
    if service.frame:IsShown() then service.frame:Hide() else service.frame:Show() end
end

local function ObservationStore()
    RXPData.speedrun = type(RXPData.speedrun) == "table" and RXPData.speedrun or {}
    RXPData.speedrun.mobObservations =
        type(RXPData.speedrun.mobObservations) == "table" and
            RXPData.speedrun.mobObservations or {}
    RXPData.speedrun.mobObservationOrder =
        type(RXPData.speedrun.mobObservationOrder) == "table" and
            RXPData.speedrun.mobObservationOrder or {}
    local observations = RXPData.speedrun.mobObservations
    local order = RXPData.speedrun.mobObservationOrder
    if #order == 0 and next(observations) then
        for key in pairs(observations) do order[#order + 1] = key end
        table.sort(order)
    end
    while #order > MAX_MOB_OBSERVATIONS do
        observations[table.remove(order, 1)] = nil
    end
    return observations, order
end

local function TouchObservation(observations, order, key)
    for index = #order, 1, -1 do
        if order[index] == key then table.remove(order, index) break end
    end
    order[#order + 1] = key
    while #order > MAX_MOB_OBSERVATIONS do
        observations[table.remove(order, 1)] = nil
    end
end

local function MobObservationKey(id, level, name)
    local class = addon.player and addon.player.class or select(2, UnitClass("player"))
    local rate = tonumber(Profile().xprate) or 1
    local creature = tonumber(id) and ("id:" .. tostring(id)) or
                         ("name:" .. tostring(name or "unknown"))
    return table.concat({creature, tostring(level or 0),
        tostring(class or "UNKNOWN"), format("%.3f", rate)}, ":")
end

local function CreatureEntryFromGUID(guid)
    if type(guid) ~= "string" then return end
    if guid:sub(1, 2) == "0x" and #guid >= 10 then
        return tonumber(guid:sub(7, 10), 16)
    end
    return tonumber(guid:match("^[^-]+%-%d+%-%d+%-%d+%-%d+%-(%d+)"), 10)
end

local function Median(values)
    if #values == 0 then return end
    table.sort(values)
    local middle = floor((#values + 1) / 2)
    if #values % 2 == 1 then return values[middle] end
    return (values[middle] + values[middle + 1]) / 2
end

function grind:ObserveCombat(event, ...)
    if not Enabled("enableSpeedrunGrind") then return end
    if event == "PLAYER_REGEN_DISABLED" then
        addon.scheduler:Cancel(OWNER, "combat-clear")
        local guid = UnitGUID("target")
        local level = tonumber(UnitLevel("target"))
        local id = CreatureEntryFromGUID(guid)
        local playerLevel = tonumber(UnitLevel("player")) or 1
        local tappedByPlayer = not UnitIsTapped or not UnitIsTapped("target") or
                                   (UnitIsTappedByPlayer and
                                        UnitIsTappedByPlayer("target"))
        local inInstance = IsInInstance and select(1, IsInInstance())
        if id and level and level > 0 and UnitCanAttack("player", "target") and
            math.abs(level - playerLevel) <= 2 and
            UnitClassification("target") == "normal" and tappedByPlayer and
            not inInstance and (not UnitIsPlayer or not UnitIsPlayer("target")) and
            not (UnitPlayerControlled and UnitPlayerControlled("target")) then
            self.combat = {id = id, level = level, guid = guid,
                name = UnitName("target"), started = GetTime()}
        end
    elseif event == "PLAYER_REGEN_ENABLED" and self.combat then
        -- PARTY_KILL and combat-end ordering differs between private-server
        -- cores. Retain the candidate briefly so a late authoritative kill is
        -- still correlated, then discard it without learning from ambiguity.
        addon.scheduler:After(OWNER, "combat-clear", 0.75, function()
            grind.combat = nil
        end)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and self.combat then
        local eventType = select(2, ...)
        local sourceGUID = select(3, ...)
        local destinationGUID = select(6, ...)
        if eventType ~= "PARTY_KILL" or destinationGUID ~= self.combat.guid then return end
        local playerGUID = UnitGUID("player")
        local petGUID = UnitExists("pet") and UnitGUID("pet")
        if sourceGUID ~= playerGUID and sourceGUID ~= petGUID then return end
        local elapsed = GetTime() - (tonumber(self.combat.started) or GetTime())
        if elapsed >= 1 and elapsed <= 300 and
            (GetNumPartyMembers() or 0) == 0 and (GetNumRaidMembers() or 0) == 0 then
            local store, order = ObservationStore()
            local key = MobObservationKey(self.combat.id, self.combat.level)
            local samples = type(store[key]) == "table" and store[key] or {}
            tinsert(samples, floor(elapsed * 10 + 0.5) / 10)
            while #samples > 20 do table.remove(samples, 1) end
            store[key] = samples
            TouchObservation(store, order, key)
            if type(self.combat.name) == "string" and self.combat.name ~= "" then
                local nameKey = MobObservationKey(nil, self.combat.level,
                    self.combat.name)
                local nameSamples = type(store[nameKey]) == "table" and
                                        store[nameKey] or {}
                tinsert(nameSamples, floor(elapsed * 10 + 0.5) / 10)
                while #nameSamples > 20 do table.remove(nameSamples, 1) end
                store[nameKey] = nameSamples
                TouchObservation(store, order, nameKey)
            end
        end
        self.combat = nil
        addon.scheduler:Cancel(OWNER, "combat-clear")
        self:ScheduleRefresh()
    end
end

local function MobTime(id, level, name)
    local observations = ObservationStore()
    local samples = observations[MobObservationKey(id, level, name)]
    if type(samples) == "table" and #samples > 0 then
        local copy = {}
        for _, value in ipairs(samples) do tinsert(copy, value) end
        return Median(copy), #copy >= 3 and "observed" or "learning"
    end
    return 18, "estimate"
end

local function DangerousNames()
    local names = {}
    local context = addon.generatedSteps and addon.generatedSteps.dangerousMobs
    for _, step in ipairs(type(context) == "table" and context or {}) do
        for _, element in ipairs(step.elements or {}) do
            for _, list in ipairs({element.unitscan, element.mobs, element.targets}) do
                for _, value in ipairs(type(list) == "table" and list or {}) do
                    local name = CreatureName(value)
                    if name ~= "" then names[name] = true end
                end
            end
        end
    end
    return names
end

function grind:Scan()
    local perfLabel = "speedrun grind scan"
    local perf = addon.PerfBegin and addon.PerfBegin(perfLabel)
    local guide, first, last = CurrentRange(Profile().speedrunGrindLookahead)
    local report = {generated = GetTime(), candidates = {}, status = "ready"}
    if not guide or last < first then
        report.status = "no-guide"
        self.report = report
        FinishPerf(perfLabel, perf)
        return report
    end
    if (GetNumPartyMembers() or 0) > 0 or (GetNumRaidMembers() or 0) > 0 then
        report.status = "grouped"
        self.report = report
        FinishPerf(perfLabel, perf)
        return report
    end
    local progress = addon.xpAssistant and addon.xpAssistant:GetProgress()
    if not progress or progress.atMax then
        report.status = "max-level"
        self.report = report
        FinishPerf(perfLabel, perf)
        return report
    end
    local xpRows = addon.xpAssistant:GetRows()
    local xpRow
    for _, row in ipairs(xpRows or {}) do if row.offset == 0 then xpRow = row break end end
    local xpPerKill = xpRow and (xpRow.adaptiveXP or xpRow.baseXP)
    if not xpPerKill or xpPerKill <= 0 then
        report.status = "unknown-xp"
        self.report = report
        FinishPerf(perfLabel, perf)
        return report
    end
    local shortfall
    local preflight = addon.routePreflight and addon.routePreflight.report
    if preflight and preflight.xp and tonumber(preflight.xp.shortfallHigh) and
        preflight.xp.shortfallHigh > 0 then shortfall = preflight.xp.shortfallHigh end
    if not shortfall or shortfall <= 0 then
        report.status = "no-xp-shortfall"
        self.report = report
        FinishPerf(perfLabel, perf)
        return report
    end
    local seen = {}
    local dangerousNames = DangerousNames()
    for index = first, last do
        local step = guide.steps[index]
        local coordinate = FirstCoordinate(step)
        for _, element in ipairs(step.elements or {}) do
            local values = element.mobs or element.unitscan
            for _, value in ipairs(type(values) == "table" and values or {}) do
                local id = tonumber(value)
                local name = CreatureName(value)
                local key = id or name
                if name ~= "" and not seen[key] and coordinate then
                    seen[key] = true
                    local mobLevel = UnitLevel("player")
                    local killTime, source = MobTime(id, mobLevel, name)
                    local kills = addon.xpFormula and
                        addon.xpFormula:GetKillsRemaining(shortfall, xpPerKill,
                            tonumber(progress.rested) or 0) or
                        ceil(shortfall / xpPerKill)
                    kills = max(1, tonumber(kills) or ceil(shortfall / xpPerKill))
                    local travel = (PlayerDistance(coordinate) or 0) / 7
                    local danger = dangerousNames[name] and 120 or 0
                    tinsert(report.candidates, {id = id, name = name, step = index,
                        coordinate = coordinate, kills = kills, xp = xpPerKill,
                        time = travel + kills * killTime + danger,
                        killTime = killTime, source = source,
                        danger = danger > 0})
                end
            end
        end
    end
    table.sort(report.candidates, function(a, b)
        if a.time == b.time then return a.step < b.step end
        return a.time < b.time
    end)
    report.best = report.candidates[1]
    if not report.best then report.status = "no-validated-mobs" end
    self.report = report
    advisors:RefreshBadge()
    FinishPerf(perfLabel, perf)
    return report
end

function grind:Activate()
    local candidate = self.report and self.report.best
    if not candidate then return end
    self.active = candidate
    candidate.remainingXP = max(1, candidate.kills * candidate.xp)
    candidate.lastXP = UnitXP("player") or 0
    candidate.lastMax = UnitXPMax("player") or 0
    candidate.lastLevel = UnitLevel("player") or 1
    local source = candidate.coordinate
    local step = {active = true, index = tonumber(RXPCData.currentStep) or 1,
        pinIndex = 255, speedrunTemporary = true, elements = {}}
    local element = {zone = source.zone, x = source.x, y = source.y,
        wx = source.wx, wy = source.wy, instance = source.instance,
        step = step, label = "G", arrow = true,
        text = format("Grind %s (%d kills)",
            candidate.name, candidate.kills), mapTooltip = candidate.name}
    step.elements[1] = element
    addon.speedrunTemporaryWaypointStep = step
    addon.speedrunTemporaryTarget = candidate.name
    if addon.targeting then
        addon.targeting:UpdateUnitList()
    end
    addon.UpdateMap(true)
    if addon.speedrunAudio then addon.speedrunAudio:Play("grind") end
    self:Refresh()
    addon:SendEvent("RXP_SPEEDRUN_ADVISORY_CHANGED", "grind", true)
end

function grind:ProgressXP(event)
    local active = self.active
    if not active or (event ~= "PLAYER_XP_UPDATE" and event ~= "PLAYER_LEVEL_UP") then return end
    local level = UnitLevel("player") or active.lastLevel
    local current = UnitXP("player") or 0
    local gained
    if level > (active.lastLevel or level) then
        gained = max(0, (active.lastMax or 0) - (active.lastXP or 0) + current)
    else
        gained = max(0, current - (active.lastXP or current))
    end
    active.lastLevel, active.lastXP = level, current
    active.lastMax = UnitXPMax("player") or active.lastMax
    active.remainingXP = max(0, (active.remainingXP or 0) - gained)
    active.kills = max(0, ceil(active.remainingXP / max(1, active.xp)))
    if active.remainingXP <= 0 then
        local name = active.name
        self:Cancel()
        if addon.speedrunAudio then addon.speedrunAudio:Play("grind") end
        if addon.comms then addon.comms.PrettyPrint("Temporary grind objective complete: %s.", name) end
    else
        self:Refresh()
    end
end

function grind:Cancel()
    self.active = nil
    self.combat = nil
    addon.scheduler:Cancel(OWNER, "combat-clear")
    addon.speedrunTemporaryWaypointStep = nil
    addon.speedrunTemporaryTarget = nil
    if addon.targeting and addon.targeting.UpdateUnitList then addon.targeting:UpdateUnitList() end
    addon.UpdateMap(true)
    self:Refresh()
    addon:SendEvent("RXP_SPEEDRUN_ADVISORY_CHANGED", "grind", false)
end

function grind:BuildText()
    local report = self.report or self:Scan()
    local lines = {L("Dynamic Grind Optimizer"), ""}
    if self.active then
        tinsert(lines, format("ACTIVE: %s - %d kills, about %s", self.active.name,
            self.active.kills, Duration(self.active.time)))
        local coordinate = self.active.coordinate
        if coordinate then
            tinsert(lines, format(L("Location: map %s at %.1f, %.1f"),
                tostring(coordinate.zone or "?"), tonumber(coordinate.x) or 0,
                tonumber(coordinate.y) or 0))
        end
        tinsert(lines, L("The canonical route returns automatically when this objective is cancelled."))
    elseif report.status ~= "ready" then
        tinsert(lines, format(L("Status: %s"), tostring(report.status)))
    else
        tinsert(lines, L("Validated guide mobs ranked by route proximity, XP and observed kill time:"))
        for index = 1, min(12, #report.candidates) do
            local row = report.candidates[index]
            tinsert(lines, format(L("%d. %s (step %d, %.1f/%.1f): %d kills, %d XP/kill, %s [%s]"),
                index, row.name, row.step, tonumber(row.coordinate.x) or 0,
                tonumber(row.coordinate.y) or 0, row.kills, row.xp,
                Duration(row.time), row.source))
        end
    end
    tinsert(lines, "")
    tinsert(lines, L("Recommendations are solo estimates and require explicit activation."))
    return table.concat(lines, "\n")
end

function grind:Refresh()
    if self.frame and self.frame:IsShown() then toolWindows:SetText(self.frame, self:BuildText()) end
    advisors:RefreshBadge()
end

function grind:ScheduleRefresh()
    if not advisors.setup or not Enabled("enableSpeedrunGrind") then
        addon.scheduler:Cancel(OWNER, "grind")
        return
    end
    addon.scheduler:After(OWNER, "grind", 0.2, function() grind:Scan() grind:Refresh() end)
end

function grind:CreateWindow()
    local frame = toolWindows:Create({name = "RXPSpeedrunGrindWindow",
        title = L("Dynamic Grind Optimizer"), width = 650, height = 430,
        minWidth = 460, minHeight = 300})
    toolWindows:AddScrollingText(frame, {top = 48, bottom = 58})
    self.activateButton = AddButton(frame, L("Activate Best"), 20,
        function() if grind.active then grind:Cancel() else grind:Scan() grind:Activate() end end, 110)
    AddButton(frame, L("Refresh"), 145, function() grind:Scan() grind:Refresh() end)
    frame:SetScript("OnShow", function() grind:Scan() grind:Refresh() end)
    self.frame = frame
end

function grind:Toggle() Toggle(self, "enableSpeedrunGrind") end

local stopTags = {
    buy = "Buy", buyAll = "Buy", buyUntilBroke = "Buy", vendor = "Vendor",
    train = "Train", trainer = "Train", home = "Bind hearth", stable = "Pet",
    repair = "Repair", fly = "Travel", fp = "Flight path"
}

local function MerchantItems()
    local result = {}
    if not (MerchantFrame and MerchantFrame:IsShown() and GetMerchantNumItems) then
        return result
    end
    for index = 1, GetMerchantNumItems() do
        local link = GetMerchantItemLink(index)
        local id = link and tonumber(link:match("item:(%d+)"))
        if id then
            local _, _, price, bundle, available = GetMerchantItemInfo(index)
            result[id] = {index = index, price = tonumber(price) or 0,
                          bundle = max(1, tonumber(bundle) or 1),
                          available = tonumber(available)}
        end
    end
    return result
end

function pitstop:Scan()
    local perfLabel = "speedrun pit-stop scan"
    local perf = addon.PerfBegin and addon.PerfBegin(perfLabel)
    local guide, first, last = CurrentRange(Profile().speedrunPitStopLookahead)
    local report = {stops = {}, count = 0, generated = GetTime()}
    if not guide or last < first then
        self.report = report
        FinishPerf(perfLabel, perf)
        return report
    end
    local merchantItems = MerchantItems()
    local current, lastCoordinate
    for index = first, last do
        local step = guide.steps[index]
        local coordinate = FirstCoordinate(step) or lastCoordinate
        lastCoordinate = coordinate
        for _, element in ipairs(step.elements or {}) do
            local action = stopTags[element.tag]
            if action then
                local zone = coordinate and coordinate.zone or 0
                local merge
                if current and current.coordinate and coordinate and
                    current.coordinate.instance == coordinate.instance then
                    local distance = HBD:GetWorldDistance(coordinate.instance,
                        current.coordinate.wx, current.coordinate.wy,
                        coordinate.wx, coordinate.wy)
                    merge = distance and distance <= 120
                elseif current and current.zone == zone and
                    index - (current.lastStep or current.step) <= 1 then
                    merge = true
                end
                if not merge then
                    current = {key = tostring(zone) .. ":" .. tostring(index),
                        step = index, lastStep = index, zone = zone,
                        coordinate = coordinate, actions = {}}
                    tinsert(report.stops, current)
                end
                current.lastStep = index
                local detail = element.text or element.name or element.title or action
                tinsert(current.actions, {action = action, detail = detail,
                    tag = element.tag, id = tonumber(element.id),
                    quantity = tonumber(element.qty),
                    merchant = element.id and merchantItems[tonumber(element.id)],
                    authoredOrder = #current.actions + 1})
                report.count = report.count + 1
            end
        end
    end
    if addon.supplies and addon.supplies.BuildChecklist then
        local list = addon.supplies:BuildChecklist()
        local missing = 0
        report.supplies = {}
        for _, entry in ipairs(list or {}) do
            local need = tonumber(entry.need or entry.missing) or 0
            if need > 0 then
                missing = missing + 1
                tinsert(report.supplies, {name = entry.name, need = need,
                    source = entry.source, vendor = entry.vendor})
            end
        end
        report.missingSupplies = missing
    end
    local free = 0
    if GetContainerNumFreeSlots then
        for bag = 0, 4 do
            local bagFree = GetContainerNumFreeSlots(bag)
            free = free + (tonumber(bagFree) or 0)
        end
    end
    report.freeSlots = free
    report.reservedSlots = 0
    local reservations = addon.routePreflight and addon.routePreflight.report and
                             addon.routePreflight.report.reservations
    for id, entry in pairs(type(reservations) == "table" and reservations or {}) do
        if (GetItemCount(tonumber(id)) or 0) < (tonumber(entry.quantity) or 1) then
            report.reservedSlots = report.reservedSlots + 1
        end
    end
    report.money = GetMoney and GetMoney() or 0
    report.junkTypes = 0
    for id, value in pairs(RXPCData.discardPile or {}) do
        if value == true and addon.GetItemCount and addon.GetItemCount(id) > 0 then
            report.junkTypes = report.junkTypes + 1
        end
    end
    if TrainerFrame and TrainerFrame:IsShown() and GetNumTrainerServices then
        local available = 0
        for index = 1, GetNumTrainerServices() do
            local _, status = GetTrainerServiceInfo(index)
            if status == "available" then available = available + 1 end
        end
        report.availableTraining = available
    end
    if MerchantFrame and MerchantFrame:IsShown() and CanMerchantRepair and CanMerchantRepair() then
        local repairCost = GetRepairAllCost()
        report.repairCost = tonumber(repairCost) or 0
    end
    self.report = report
    advisors:RefreshBadge()
    FinishPerf(perfLabel, perf)
    return report
end

function pitstop:BuildText()
    local report = self.report or self:Scan()
    local lines = {L("Pit Stop Planner"),
        format(L("Upcoming authored actions: %d"), report.count or 0),
        format(L("Free ordinary bag slots: %d"), report.freeSlots or 0),
        format(L("Upcoming reserved item types needing space: %d"),
            report.reservedSlots or 0),
        format(L("Missing class supplies: %d"), report.missingSupplies or 0),
        format(L("Junk item types currently in bags: %d"), report.junkTypes or 0),
        format(L("Money available: %s"), GetCoinTextureString(report.money or 0))}
    if report.repairCost then tinsert(lines, format(L("Current repair cost: %s"), GetCoinTextureString(report.repairCost))) end
    if report.availableTraining then
        tinsert(lines, format(L("Affordable/available trainer entries: %d"),
                              report.availableTraining))
    end
    for _, entry in ipairs(report.supplies or {}) do
        tinsert(lines, format(L("Supply: %s x%d missing (%s)"),
            tostring(entry.name), entry.need, tostring(entry.source or "class")))
    end
    tinsert(lines, "")
    for number, stop in ipairs(report.stops or {}) do
        tinsert(lines, format(L("Stop %d - step %d"), number, stop.step))
        for _, action in ipairs(stop.actions) do
            tinsert(lines, format("  %d. %s: %s", action.authoredOrder,
                L(action.action), tostring(action.detail)))
            if action.merchant then
                local stock = action.merchant.available == -1 and "unlimited" or
                                  tostring(action.merchant.available or "unknown")
                tinsert(lines, format(L("     Merchant: %s per bundle of %d; stock %s"),
                    GetCoinTextureString(action.merchant.price),
                    action.merchant.bundle, stock))
            end
        end
    end
    if #(report.stops or {}) == 0 then tinsert(lines, L("No authored stops in the selected look-ahead.")) end
    tinsert(lines, "")
    tinsert(lines, L("The planner preserves guide order. Transactions remain user-clicked."))
    if (report.freeSlots or 0) <= 2 and not self.inventoryWarned then
        self.inventoryWarned = true
        if addon.speedrunAudio then addon.speedrunAudio:Play("inventory") end
    elseif (report.freeSlots or 0) > 2 then
        self.inventoryWarned = nil
    end
    return table.concat(lines, "\n")
end

function pitstop:Refresh()
    if self.frame and self.frame:IsShown() then toolWindows:SetText(self.frame, self:BuildText()) end
    advisors:RefreshBadge()
end

function pitstop:ScheduleRefresh()
    if not advisors.setup or not Enabled("enableSpeedrunPitStop") then
        addon.scheduler:Cancel(OWNER, "pitstop")
        return
    end
    addon.scheduler:After(OWNER, "pitstop", 0.2, function() pitstop:Scan() pitstop:Refresh() end)
end

function pitstop:CreateWindow()
    local frame = toolWindows:Create({name = "RXPSpeedrunPitStopWindow",
        title = L("Pit Stop Planner"), width = 650, height = 430,
        minWidth = 450, minHeight = 300})
    toolWindows:AddScrollingText(frame, {top = 48, bottom = 58})
    AddButton(frame, L("Refresh"), 20, function() pitstop:Scan() pitstop:Refresh() end)
    AddButton(frame, L("Supplies"), 125, function()
        if addon.supplies then addon.supplies:Toggle() end
    end)
    frame:SetScript("OnShow", function() pitstop:Scan() pitstop:Refresh() end)
    self.frame = frame
end

function pitstop:Toggle() Toggle(self, "enableSpeedrunPitStop") end

local function CurrentMap()
    if addon.GetCurrentMapID then return tonumber(addon.GetCurrentMapID()) end
    return GetCurrentMapAreaID and tonumber(GetCurrentMapAreaID())
end

local function DestinationMap()
    for _, step in ipairs(addon.RXPFrame and addon.RXPFrame.activeSteps or {}) do
        for _, element in ipairs(step.elements or {}) do
            if tonumber(element.zone) then return tonumber(element.zone), element end
        end
    end
end

local function ObservedGuideDuration(guideKey)
    local values = {}
    local runs = RXPData.levelingArchives and RXPData.levelingArchives.runs or {}
    local current = addon.speedrun and addon.speedrun:GetRun(false)
    local fingerprint = addon.speedrun and addon.speedrun:BuildFingerprint(current)
    for _, run in pairs(runs) do
        if type(run) == "table" and run.finished and type(run.segments) == "table" and
            (not fingerprint or run.speedrunFingerprint == fingerprint) then
            local total, found = 0, false
            for _, segment in ipairs(run.segments) do
                if segment.g == guideKey then
                    total = total + (tonumber(segment.a) or 0)
                    found = true
                end
            end
            if found and total > 0 then tinsert(values, total) end
        end
    end
    return Median(values), #values
end

local function ObservedBranchDuration(fromKey, toKey)
    local observations = RXPData.speedrun and RXPData.speedrun.branchObservations
    local key = addon.speedrun and addon.speedrun.BuildBranchKey and
                    addon.speedrun:BuildBranchKey(fromKey, toKey,
                        addon.speedrun:GetRun(false)) or
                    (tostring(fromKey) .. "\031" .. tostring(toKey))
    local values = type(observations) == "table" and observations[key]
    if type(values) ~= "table" then return end
    local copy = {}
    for _, value in ipairs(values) do
        if tonumber(value) and value >= 0 then tinsert(copy, tonumber(value)) end
    end
    return Median(copy), #copy
end

strategist.branchMetadata = strategist.branchMetadata or {}

local function BranchMetadataKey(guideKey, stepId)
    if type(guideKey) ~= "string" or guideKey == "" or stepId == nil then return end
    return guideKey .. "\031" .. tostring(stepId)
end

-- Branch metadata is intentionally data-only. It may be populated by a
-- verified compatibility module, but it can never carry callbacks or execute
-- guide text. Authored #next links are exposed through the same shape below.
function strategist:RegisterBranchMetadata(guideKey, stepId, choices)
    local key = BranchMetadataKey(guideKey, stepId)
    if not key or type(choices) ~= "table" then return false end
    local clean = {}
    for _, choice in ipairs(choices) do
        if type(choice) ~= "table" or type(choice.name) ~= "string" or
            choice.name == "" or
            (choice.group ~= nil and type(choice.group) ~= "string") or
            (choice.note ~= nil and type(choice.note) ~= "string") or
            (choice.expectedSeconds ~= nil and
                (type(choice.expectedSeconds) ~= "number" or
                    choice.expectedSeconds < 0)) then return false end
        clean[#clean + 1] = {
            group = choice.group, name = choice.name,
            note = choice.note and choice.note:sub(1, 200) or nil,
            expectedSeconds = choice.expectedSeconds
        }
    end
    if #clean == 0 then return false end
    self.branchMetadata[key] = clean
    return true
end

local function AuthoredBranchChoices(guide)
    local choices = {}
    if type(guide) ~= "table" or type(guide.next) ~= "string" then return choices end
    for rawName in guide.next:gmatch("%s*([^;]+)%s*") do
        local group = guide.group
        local name = rawName:gsub("^%s*(.+)\\%s*", function(nextGroup)
            group = nextGroup
            return ""
        end)
        choices[#choices + 1] = {group = group, name = name,
            note = "authored guide transition"}
    end
    return choices
end

function strategist:GetBranchMetadata(guide)
    if type(guide) ~= "table" then return {} end
    local guideKey = guide.key or
        (addon.BuildGuideKey and addon.BuildGuideKey(guide))
    local index = tonumber(RXPCData.currentStep) or 1
    local step = guide.steps and guide.steps[index]
    local stepId = step and (step.stepId or step.index) or index
    local key = BranchMetadataKey(guideKey, stepId)
    return key and self.branchMetadata[key] or AuthoredBranchChoices(guide)
end

local function ResolveNextGuides(guide)
    local result, seen = {}, {}
    if type(guide) ~= "table" then return result end
    for _, choice in ipairs(strategist:GetBranchMetadata(guide)) do
        local group = choice.group or guide.group
        local name = choice.name
        if addon.affix then name = name:gsub("^(%d)-(%d%d?)", addon.affix) end
        local candidate = addon.GetGuideTable and addon.GetGuideTable(group, name)
        if candidate and not seen[candidate] and
            (not addon.IsGuideActive or addon.IsGuideActive(candidate)) then
            seen[candidate] = true
            tinsert(result, {guide = candidate, name = name,
                expectedSeconds = choice.expectedSeconds, note = choice.note})
        end
    end
    return result
end

function strategist:Scan()
    local perfLabel = "speedrun route scan"
    local perf = addon.PerfBegin and addon.PerfBegin(perfLabel)
    local source, destination = CurrentMap(), DestinationMap()
    local report = {source = source, destination = destination, candidates = {}}
    if not source or not destination then
        report.status = "unknown-map"
        self.report = report
        FinishPerf(perfLabel, perf)
        return report
    end
    if addon.travel and addon.travel.FindManualRoute then
        local route, duration = addon.travel:FindManualRoute(source, destination)
        if route then tinsert(report.candidates, {kind = "route", duration = duration,
            confidence = "verified graph", route = route,
            assumptions = "known travel graph, conservative movement estimates"}) end
    end
    local guide = addon.currentGuide
    local currentKey = guide and (guide.key or
        (addon.BuildGuideKey and addon.BuildGuideKey(guide)))
    for _, resolved in ipairs(ResolveNextGuides(guide)) do
        local nextGuide, name = resolved.guide, resolved.name
        local key = nextGuide.key or (addon.BuildGuideKey and addon.BuildGuideKey(nextGuide))
        local duration, samples = ObservedBranchDuration(currentKey, key)
        if not duration then duration, samples = ObservedGuideDuration(key) end
        if not duration then duration = tonumber(resolved.expectedSeconds) end
        tinsert(report.candidates, {kind = "guide", guide = nextGuide,
            name = name, duration = duration, samples = samples,
            confidence = samples >= 3 and "measured" or "authored transition",
            assumptions = samples > 0 and
                format("%d compatible anonymous route observation(s)", samples) or
                (resolved.note or "current guide conditions remain valid")})
    end
    local fastest
    for _, candidate in ipairs(report.candidates) do
        if candidate.kind == "guide" and candidate.duration then
            fastest = not fastest and candidate.duration or min(fastest, candidate.duration)
        end
    end
    for _, candidate in ipairs(report.candidates) do
        if candidate.kind == "guide" and candidate.duration and fastest then
            candidate.savings = candidate.duration - fastest
        end
    end
    report.status = #report.candidates > 0 and "ready" or "no-route"
    if not self.selectedIndex or not report.candidates[self.selectedIndex] or
        report.candidates[self.selectedIndex].kind ~= "guide" then
        self.selectedIndex = nil
        for index, candidate in ipairs(report.candidates) do
            if candidate.kind == "guide" then self.selectedIndex = index break end
        end
    end
    self.report = report
    advisors:RefreshBadge()
    FinishPerf(perfLabel, perf)
    return report
end

function strategist:Apply(index)
    local candidate = self.report and
        self.report.candidates[index or self.selectedIndex or 1]
    if not candidate or candidate.kind ~= "guide" or not candidate.guide then return end
    addon.comms:ConfirmChoice("RXP_SPEEDRUN_ROUTE_CONFIRM",
        format("Switch to %s?\n\nConfidence: %s\nAssumptions: %s",
            candidate.name, candidate.confidence, candidate.assumptions),
        function(data)
            if data and data.guide then addon.guideState:Load(data.guide, true, "manual") end
        end, {guide = candidate.guide})
end

function strategist:SelectGuide(direction)
    local candidates = self.report and self.report.candidates or {}
    local indexes = {}
    for index, candidate in ipairs(candidates) do
        if candidate.kind == "guide" then indexes[#indexes + 1] = index end
    end
    if #indexes == 0 then self.selectedIndex = nil return end
    local position = 1
    for index, candidateIndex in ipairs(indexes) do
        if candidateIndex == self.selectedIndex then position = index break end
    end
    position = ((position - 1 + (tonumber(direction) or 1)) % #indexes) + 1
    self.selectedIndex = indexes[position]
    self:Refresh()
end

function strategist:BuildText()
    local report = self.report or self:Scan()
    local lines = {L("Adaptive Route Strategist"), ""}
    if report.status ~= "ready" then
        tinsert(lines, format(L("Status: %s"), tostring(report.status)))
    end
    for index, candidate in ipairs(report.candidates or {}) do
        local prefix = index == self.selectedIndex and "> " or "  "
        if candidate.kind == "route" then
            tinsert(lines, prefix .. format("%d. Return route - %s (%s)", index,
                Duration(candidate.duration), candidate.confidence))
            for _, edge in ipairs(candidate.route or {}) do tinsert(lines, "   * " .. edge.text) end
        else
            tinsert(lines, prefix .. format("%d. Guide branch: %s (%s)%s", index,
                candidate.name, candidate.confidence,
                candidate.duration and (" - expected " .. Duration(candidate.duration) ..
                    (candidate.savings and candidate.savings > 0 and
                        (", " .. Duration(candidate.savings) .. " slower") or "")) or ""))
        end
        tinsert(lines, format(L("   Assumptions: %s"), L(candidate.assumptions)))
    end
    tinsert(lines, "")
    tinsert(lines, L("Guide changes require confirmation. Travel instructions never move the character."))
    return table.concat(lines, "\n")
end

function strategist:Refresh()
    if self.frame and self.frame:IsShown() then toolWindows:SetText(self.frame, self:BuildText()) end
    advisors:RefreshBadge()
end

function strategist:ScheduleRefresh()
    if not advisors.setup or not Enabled("enableSpeedrunRoute") then
        addon.scheduler:Cancel(OWNER, "route")
        return
    end
    addon.scheduler:After(OWNER, "route", 0.25, function() strategist:Scan() strategist:Refresh() end)
end

function strategist:CreateWindow()
    local frame = toolWindows:Create({name = "RXPSpeedrunRouteWindow",
        title = L("Adaptive Route Strategist"), width = 680, height = 450,
        minWidth = 470, minHeight = 310})
    toolWindows:AddScrollingText(frame, {top = 48, bottom = 58})
    AddButton(frame, L("Refresh"), 20, function() strategist:Scan() strategist:Refresh() end)
    AddButton(frame, L("Previous"), 125, function() strategist:SelectGuide(-1) end)
    AddButton(frame, L("Next"), 230, function() strategist:SelectGuide(1) end)
    AddButton(frame, L("Apply Selected"), 335,
        function() strategist:Apply() end, 125)
    frame:SetScript("OnShow", function() strategist:Scan() strategist:Refresh() end)
    self.frame = frame
end

function strategist:Toggle() Toggle(self, "enableSpeedrunRoute") end

local function CorpseWorld()
    if addon.GetCorpseWorldPosition then
        return addon.GetCorpseWorldPosition()
    end
end

local function NearestHealer(px, py, instance)
    if addon.FindNearestSpiritHealer then
        return addon.FindNearestSpiritHealer(px, py, instance)
    end
end

function deathwarp:Scan()
    local perfLabel = "speedrun deathwarp scan"
    local perf = addon.PerfBegin and addon.PerfBegin(perfLabel)
    local report = {generated = GetTime(), options = {}}
    if addon.speedrunRules and addon.speedrunRules.CurrentId and
        addon.speedrunRules:CurrentId() == "solo-deathless" then
        report.status = "deathless"
        self.report = report
        FinishPerf(perfLabel, perf)
        return report
    end
    if IsInInstance and select(1, IsInInstance()) then
        report.status = "instance"
        self.report = report
        FinishPerf(perfLabel, perf)
        return report
    end
    local px, py, instance = HBD:GetPlayerWorldPosition()
    local destination = addon.activeWaypoints and addon.activeWaypoints[1]
    if not px or not py or not instance or not destination or
        not destination.wx or not destination.wy or
        destination.instance ~= instance then
        report.status = "unknown-map"
        self.report = report
        FinishPerf(perfLabel, perf)
        return report
    end
    local direct = HBD:GetWorldDistance(instance, px, py,
        destination.wx, destination.wy)
    if direct then tinsert(report.options, {kind = "travel", duration = direct / 7,
        reason = "ordinary movement at a conservative unmounted pace"}) end
    local sourceMap = CurrentMap()
    local destinationMap = DestinationMap()
    if sourceMap and destinationMap and addon.travel and addon.travel.FindManualRoute then
        local route, duration = addon.travel:FindManualRoute(sourceMap, destinationMap)
        if route and duration and duration > 0 then
            local usesHearth
            for _, edge in ipairs(route) do
                if type(edge.text) == "string" and
                    edge.text:lower():find("hearthstone", 1, true) then
                    usesHearth = true
                    break
                end
            end
            tinsert(report.options, {kind = usesHearth and "hearth" or "travel-route",
                duration = duration, route = route,
                reason = usesHearth and
                    "verified bind destination and cooldown-aware travel graph" or
                    "verified conservative travel graph"})
        end
    end
    local start, cooldown = GetItemCooldown and GetItemCooldown(6948)
    local remaining = start and cooldown and max(0, start + cooldown - GetTime()) or 0
    if remaining > 0 and GetItemCount and GetItemCount(6948) > 0 and
        addon.travel and addon.travel.GetBindMap then
        local bindMap = addon.travel:GetBindMap()
        local route, duration = bindMap and destinationMap and
            addon.travel:FindManualRoute(bindMap, destinationMap)
        if route and duration then
            tinsert(report.options, {kind = "hearth-wait",
                duration = remaining + 12 + duration, route = route,
                reason = "hearth cooldown plus verified travel from the bind location"})
        end
    end
    local flightDestination
    for _, step in ipairs(addon.RXPFrame and addon.RXPFrame.activeSteps or {}) do
        for _, element in ipairs(step.elements or {}) do
            if tonumber(element.fpId) then flightDestination = tonumber(element.fpId) break end
        end
        if flightDestination then break end
    end
    if flightDestination and addon.travel and addon.travel.FindFlightRoute and addon.GetNearestFp then
        local sourceFlight = addon.GetNearestFp()
        local route, duration = addon.travel:FindFlightRoute(sourceFlight, flightDestination)
        if route and duration then
            tinsert(report.options, {kind = "flight", duration = duration,
                route = route, reason = "discovered flight paths and stored flight times"})
        end
    end
    if UnitIsGhost and UnitIsGhost("player") then
        local corpseX, corpseY, corpseInstance = CorpseWorld()
        if corpseX and corpseY and corpseInstance == instance then
            local corpseDistance = HBD:GetWorldDistance(instance, px, py,
                corpseX, corpseY)
            if corpseDistance then
                tinsert(report.options, {kind = "corpse-recovery",
                    duration = corpseDistance / 7,
                    reason = "authoritative corpse position; excludes combat recovery time"})
            end
        end
    end
    local healerX, healerY, healer, healerDistance = NearestHealer(px, py, instance)
    if healer and healerX and healerY and healerDistance then
        local fromHealer = HBD:GetWorldDistance(instance, healerX, healerY,
            destination.wx, destination.wy)
        if fromHealer then
            local sicknessMinutes = max(0, min(10, UnitLevel("player") - 10))
            tinsert(report.options, {kind = "deathwarp",
                duration = 8 + healerDistance / 7 + fromHealer / 7 +
                               sicknessMinutes * 60,
                reason = "verified nearby graveyard; excludes unknown combat/death time",
                healer = healer.name, durability = 25,
                sicknessMinutes = sicknessMinutes})
        end
    end
    table.sort(report.options, function(a, b) return a.duration < b.duration end)
    report.best = report.options[1]
    report.status = report.best and "ready" or "unknown"
    self.report = report
    advisors:RefreshBadge()
    FinishPerf(perfLabel, perf)
    return report
end

function deathwarp:BuildText()
    local report = self.report or self:Scan()
    local lines = {L("Deathwarp Decision Assistant"), ""}
    if report.status ~= "ready" then
        tinsert(lines, format(L("No recommendation: %s"), tostring(report.status)))
    else
        for index, option in ipairs(report.options) do
            tinsert(lines, format("%d. %s - %s", index, option.kind,
                Duration(option.duration)))
            tinsert(lines, "   " .. L(option.reason))
            if option.healer then
                tinsert(lines, format(L("   Spirit Healer: %s"), option.healer))
            end
            if option.durability then
                tinsert(lines, format(L("   Spirit resurrection costs %d%% durability."),
                    option.durability))
            end
            if option.sicknessMinutes and option.sicknessMinutes > 0 then
                tinsert(lines, format(L("   Resurrection sickness: %d minute(s)."),
                    option.sicknessMinutes))
            end
        end
    end
    tinsert(lines, "")
    tinsert(lines, L("The assistant never kills, releases, resurrects, or changes the active route."))
    return table.concat(lines, "\n")
end

function deathwarp:Refresh()
    if self.frame and self.frame:IsShown() then toolWindows:SetText(self.frame, self:BuildText()) end
    advisors:RefreshBadge()
end

function deathwarp:ScheduleRefresh()
    if not advisors.setup or not Enabled("enableSpeedrunDeathwarp") then
        addon.scheduler:Cancel(OWNER, "deathwarp")
        return
    end
    addon.scheduler:After(OWNER, "deathwarp", 0.25,
        function() deathwarp:Scan() deathwarp:Refresh() end)
end

function deathwarp:CreateWindow()
    local frame = toolWindows:Create({name = "RXPSpeedrunDeathwarpWindow",
        title = L("Deathwarp Decision Assistant"), width = 640, height = 420,
        minWidth = 450, minHeight = 300})
    toolWindows:AddScrollingText(frame, {top = 48, bottom = 58})
    AddButton(frame, L("Refresh"), 20, function() deathwarp:Scan() deathwarp:Refresh() end)
    frame:SetScript("OnShow", function() deathwarp:Scan() deathwarp:Refresh() end)
    self.frame = frame
end

function deathwarp:Toggle() Toggle(self, "enableSpeedrunDeathwarp") end

function advisors:AdvisoryCount()
    local count = 0
    if Enabled("enableSpeedrunGrind") and grind.report and grind.report.best then count = count + 1 end
    if Enabled("enableSpeedrunPitStop") and pitstop.report and pitstop.report.count > 0 then count = count + 1 end
    if Enabled("enableSpeedrunRoute") and strategist.report and strategist.report.status == "ready" then count = count + 1 end
    if Enabled("enableSpeedrunDeathwarp") and deathwarp.report and deathwarp.report.best and
        deathwarp.report.best.kind == "deathwarp" then count = count + 1 end
    return count
end

function advisors:RefreshBadge()
    if not self.badge then return end
    local count = self:AdvisoryCount()
    self.badge:SetShown(count > 0)
    self.badge:SetText("ADV " .. count)
    if addon.UpdateFooterStatusAnchor then addon.UpdateFooterStatusAnchor() end
end

function advisors:OpenBest()
    if Enabled("enableSpeedrunDeathwarp") and deathwarp.report and
        deathwarp.report.best and deathwarp.report.best.kind == "deathwarp" then return deathwarp:Toggle() end
    if Enabled("enableSpeedrunGrind") and grind.report and grind.report.best then return grind:Toggle() end
    if Enabled("enableSpeedrunPitStop") and pitstop.report and pitstop.report.count > 0 then return pitstop:Toggle() end
    if Enabled("enableSpeedrunRoute") then return strategist:Toggle() end
end

function advisors:CreateBadge()
    if self.badge then return end
    local footer = addon.RXPFrame and addon.RXPFrame.Footer
    if not footer or not footer.preflight then return end
    local button = CreateFrame("Button", "RXPSpeedrunAdvisorBadge", footer,
        "UIPanelButtonTemplate")
    button:SetFrameLevel(footer:GetFrameLevel() + 2)
    button:SetSize(44, 18)
    button:SetPoint("LEFT", footer.preflight, "RIGHT", 1, 0)
    button:SetScript("OnClick", function() advisors:OpenBest() end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(L("Speedrun Advisors"))
        GameTooltip:AddLine(format("%d active recommendation(s).", advisors:AdvisoryCount()),
            1, 1, 1)
        GameTooltip:AddLine(L("Click to open the highest-priority advisor."),
            0.65, 0.78, 1, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    footer.speedrunAdvisors = button
    self.badge = button
    self:RefreshBadge()
end

function advisors:RefreshAll()
    if Enabled("enableSpeedrunGrind") then grind:ScheduleRefresh() end
    if Enabled("enableSpeedrunPitStop") then pitstop:ScheduleRefresh() end
    if Enabled("enableSpeedrunRoute") then strategist:ScheduleRefresh() end
    if Enabled("enableSpeedrunDeathwarp") then deathwarp:ScheduleRefresh() end
    self:RefreshBadge()
end

function advisors:ApplySettings()
    if not self.setup then return end
    if Profile().enableSpeedrunSuite == false then
        addon.scheduler:CancelOwner(OWNER)
        for _, service in ipairs({grind, pitstop, strategist, deathwarp}) do
            if service.frame then service.frame:Hide() end
        end
        if grind.active then grind:Cancel() end
    else
        if not Enabled("enableSpeedrunGrind") and grind.active then grind:Cancel() end
        if not Enabled("enableSpeedrunGrind") then
            grind.combat = nil
            addon.scheduler:Cancel(OWNER, "combat-clear")
        end
        for _, pair in ipairs({{grind, "enableSpeedrunGrind"},
            {pitstop, "enableSpeedrunPitStop"}, {strategist, "enableSpeedrunRoute"},
            {deathwarp, "enableSpeedrunDeathwarp"}}) do
            if not Enabled(pair[2]) then
                local keys = {[grind] = "grind", [pitstop] = "pitstop",
                              [strategist] = "route", [deathwarp] = "deathwarp"}
                addon.scheduler:Cancel(OWNER, keys[pair[1]])
                if pair[1].frame then pair[1].frame:Hide() end
            end
        end
        self:RefreshAll()
    end
    self:RefreshBadge()
end

function advisors:Setup()
    if self.setup then self:ApplySettings() return end
    self:CreateBadge()
    self.messageCallbacks = self.messageCallbacks or {
        RXP_STEP_ACTIVATED = function()
            if advisors.setup then advisors:RefreshAll() end
        end,
        RXP_STEP_COMPLETE = function()
            if advisors.setup then advisors:RefreshAll() end
        end,
        RXP_GUIDE_LOADED = function()
            if advisors.setup then advisors:RefreshAll() end
        end,
    }
    for message, callback in pairs(self.messageCallbacks) do
        addon:RegisterMessage(message, callback)
    end
    local frame = self.eventFrame or CreateFrame("Frame")
    frame:UnregisterAllEvents()
    for _, event in ipairs({"PLAYER_XP_UPDATE", "PLAYER_LEVEL_UP", "MERCHANT_SHOW",
        "MERCHANT_CLOSED", "TRAINER_SHOW", "TRAINER_CLOSED", "BAG_UPDATE",
        "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_UNGHOST", "ZONE_CHANGED_NEW_AREA",
        "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
        "COMBAT_LOG_EVENT_UNFILTERED"}) do
        pcall(frame.RegisterEvent, frame, event)
    end
    frame:SetScript("OnEvent", function(_, event, ...)
        grind:ObserveCombat(event, ...)
        grind:ProgressXP(event)
        advisors:RefreshAll()
    end)
    self.eventFrame = frame
    self.setup = true
    local ok, errorText = pcall(self.ApplySettings, self)
    if not ok then
        self.setup = false
        error(errorText, 0)
    end
end

function advisors:Shutdown()
    addon.scheduler:CancelOwner(OWNER)
    if grind.active then grind:Cancel() end
    if self.eventFrame then self.eventFrame:UnregisterAllEvents() end
    for message, callback in pairs(self.messageCallbacks or {}) do
        addon:UnregisterMessage(message, callback)
    end
    for _, service in ipairs({grind, pitstop, strategist, deathwarp}) do
        if service.frame then service.frame:Hide() end
    end
    if self.badge then self.badge:Hide() end
    self.setup = false
end
