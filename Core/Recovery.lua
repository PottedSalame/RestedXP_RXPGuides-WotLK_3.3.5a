local _, addon = ...

local _G = _G
local format = string.format

addon.catchUp = addon.catchUp or {}
addon.travel = addon.travel or {}
addon.lore = addon.lore or {}
local catchUp = addon.catchUp
local travel = addon.travel
local lore = addon.lore

local questTags = {
    accept = true, daily = true, complete = true, turnin = true,
    dailyturnin = true
}

local function QuestElementDone(element)
    local id = tonumber(element.questId or element.id)
    if not id or not questTags[element.tag] then return nil end
    if addon.IsQuestTurnedIn(id) then return true end
    if element.tag == "accept" or element.tag == "daily" then
        return addon.IsOnQuest(id) and true or false
    elseif element.tag == "complete" then
        return addon.IsQuestComplete(id) and true or false
    elseif element.tag == "turnin" or element.tag == "dailyturnin" then
        return false
    end
end

function catchUp:Analyze(guide)
    guide = guide or addon.currentGuide
    if not guide or guide.empty or type(guide.steps) ~= "table" then
        return nil, "No active guide is available."
    end
    local lastResolved = 0
    local evidence, uncertain = {}, {}
    local level = UnitLevel("player") or 1
    local low, high = tostring(guide.name or ""):match("(%d+)%s*%-%s*(%d+)")
    low, high = tonumber(low), tonumber(high)
    if low and level < low then
        table.insert(uncertain, format(
            "Character level %d is below this guide's nominal level %d", level,
            low))
    elseif high and level > high then
        table.insert(evidence, format(
            "Character level %d is above this guide's nominal range", level))
    end
    table.insert(evidence, format("Configured XP rate: %.2fx",
        tonumber(addon.settings.profile.xprate) or 1))
    for index, step in ipairs(guide.steps) do
        local questCount, doneCount, unresolvedCount = 0, 0, 0
        for _, element in ipairs(step.elements or {}) do
            local done = QuestElementDone(element)
            if done ~= nil then
                questCount = questCount + 1
                if done then doneCount = doneCount + 1
                else unresolvedCount = unresolvedCount + 1 end
            end
            local id = tonumber(element.questId or element.id)
            if id and (element.tag == "accept" or element.tag == "daily") then
                local prereq, missing = addon.GetQuestPreReqState and
                                            addon.GetQuestPreReqState(id)
                if prereq == false then
                    local names = {}
                    for _, missingId in ipairs(missing or {}) do
                        names[#names + 1] = tostring(missingId)
                    end
                    table.insert(uncertain, format(
                        "Step %d quest %d is missing prerequisite(s) %s", index,
                        id, #names > 0 and table.concat(names, ",") or "unknown"))
                end
            end
        end
        if questCount > 0 and doneCount == questCount then
            lastResolved = index
            table.insert(evidence, format(
                "Step %d: %d quest milestone(s) already satisfied", index,
                questCount))
        elseif index <= lastResolved + 1 and questCount == 0 then
            table.insert(uncertain, format(
                "Step %d has no authoritative quest milestone", index))
        elseif unresolvedCount > 0 and index > lastResolved then
            break
        end
    end
    local proposed = math.max(1, math.min(#guide.steps, lastResolved + 1))
    local confidence = #uncertain == 0 and "high" or
                           (#uncertain <= 2 and "medium" or "low")
    return {
        guide = guide,
        step = proposed,
        evidence = evidence,
        uncertain = uncertain,
        confidence = confidence
    }
end

function catchUp:Preview(guide)
    local proposal, errorText = self:Analyze(guide)
    if not proposal then
        addon.comms:PopupNotification("RXP_CATCHUP_ERROR", errorText)
        return
    end
    local lines = {
        format("Proposed starting step: %d", proposal.step),
        "Confidence: " .. proposal.confidence, "", "Evidence:"
    }
    if #proposal.evidence == 0 then
        table.insert(lines, "- No completed quest milestones found")
    end
    for _, line in ipairs(proposal.evidence) do
        table.insert(lines, "- " .. line)
    end
    if #proposal.uncertain > 0 then
        table.insert(lines, "")
        table.insert(lines,
            "Uncertain gates (not silently treated as complete):")
        for _, line in ipairs(proposal.uncertain) do
            table.insert(lines, "- " .. line)
        end
    end
    table.insert(lines, "")
    table.insert(lines, "Apply this proposed step?")
    addon.comms:ConfirmChoice("RXP_CATCHUP_CONFIRM",
        table.concat(lines, "\n"), function(data)
            if data.guide ~= addon.currentGuide then
                addon.guideState:Load(data.guide, true, "manual")
            end
            addon.GoToStep(data.step)
            if addon.diagnostics then
                addon.diagnostics:Record("CATCHUP_APPLIED", {
                    step = data.step, confidence = data.confidence
                })
            end
        end, proposal)
end

local function FlightDB()
    return addon.FPDB and addon.FPDB[addon.player.faction] or {}
end

-- Conservative WotLK travel graph. Edges describe player instructions; they
-- never call travel or protected APIs. Durations are deliberately rounded up.
local travelGraph = {
    [114] = {{115, 540, "Ride east into Dragonblight"},
             {119, 780, "Ride north through the Nesingwary route to Sholazar Basin"}},
    [115] = {{114, 540, "Ride west into Borean Tundra"},
             {116, 420, "Ride east into Grizzly Hills"},
             {121, 480, "Ride north into Zul'Drak"},
             {127, 480, "Ride northwest into Crystalsong Forest"}},
    [116] = {{115, 420, "Ride west into Dragonblight"},
             {117, 520, "Ride southeast into Howling Fjord"},
             {121, 420, "Ride north into Zul'Drak"}},
    [117] = {{116, 520, "Ride northwest into Grizzly Hills"}},
    [118] = {{120, 420, "Ride east into The Storm Peaks"},
             {127, 300, "Ride southeast into Crystalsong Forest"},
             {123, 420, "Ride south into Wintergrasp"}},
    [119] = {{114, 780, "Ride south into Borean Tundra"},
             {120, 600, "Ride northeast into The Storm Peaks"}},
    [120] = {{119, 600, "Ride southwest into Sholazar Basin"},
             {121, 420, "Ride southeast into Zul'Drak"},
             {118, 420, "Ride west into Icecrown"},
             {127, 360, "Ride south into Crystalsong Forest"}},
    [121] = {{116, 420, "Ride south into Grizzly Hills"},
             {115, 480, "Ride south into Dragonblight"},
             {120, 420, "Ride northwest into The Storm Peaks"},
             {127, 360, "Ride west into Crystalsong Forest"}},
    [123] = {{118, 420, "Ride north into Icecrown"},
             {127, 360, "Ride east into Crystalsong Forest"}},
    [125] = {{127, 60, "Use the violet gateway to leave Dalaran for Crystalsong Forest"}},
    [127] = {{115, 480, "Ride southeast into Dragonblight"},
             {120, 360, "Ride north into The Storm Peaks"},
             {121, 360, "Ride east into Zul'Drak"},
             {118, 300, "Ride northwest into Icecrown"},
             {123, 360, "Ride west into Wintergrasp"},
             {125, 180, "Use Krasus' Landing or the city approach to reach Dalaran"}},
    [1453] = {{114, 480, "Take the boat from Stormwind Harbor to Valiance Keep"}},
    [1437] = {{117, 480, "Take the boat from Menethil Harbor to Valgarde"}},
    [1454] = {{114, 480, "Take the zeppelin from Orgrimmar to Warsong Hold"}},
    [1420] = {{117, 480, "Take the zeppelin from Tirisfal Glades to Vengeance Landing"}}
}

local zoneNames = {
    [114] = "Borean Tundra", [115] = "Dragonblight",
    [116] = "Grizzly Hills", [117] = "Howling Fjord",
    [118] = "Icecrown", [119] = "Sholazar Basin",
    [120] = "The Storm Peaks", [121] = "Zul'Drak",
    [123] = "Wintergrasp", [125] = "Dalaran",
    [127] = "Crystalsong Forest", [1453] = "Stormwind City",
    [1437] = "Wetlands", [1454] = "Orgrimmar",
    [1420] = "Tirisfal Glades"
}

local function ResolveBindMap()
    local bind = GetBindLocation and GetBindLocation()
    if type(bind) ~= "string" or bind == "" then return end
    local wanted = bind:lower()
    for name, id in pairs(addon.mapId or {}) do
        if type(name) == "string" then
            if name:lower() == wanted then return id end
            local localized = addon.LocalizeLegacyLocationName and
                                  addon.LocalizeLegacyLocationName(name)
            if type(localized) == "string" and
                localized:lower() == wanted then
                return id
            end
        end
    end
end

function travel:FindManualRoute(source, destination)
    source, destination = tonumber(source), tonumber(destination)
    if not source or not destination then return nil, "Current or destination map is unknown." end
    if source == destination then return {}, 0 end
    local graph = {}
    for node, edges in pairs(travelGraph) do
        graph[node] = {}
        for _, edge in ipairs(edges) do graph[node][#graph[node] + 1] = edge end
    end
    if not graph[source] then
        local capital = addon.player.faction == "Alliance" and 1453 or 1454
        graph[source] = {{capital, 1800,
            "Travel safely to " .. (zoneNames[capital] or "your faction capital")}}
    end
    local bindMap = ResolveBindMap()
    local start, duration = GetItemCooldown and GetItemCooldown(6948)
    local cooldownReady = not start or not duration or duration == 0 or
                              start + duration <= GetTime()
    if bindMap and bindMap ~= source and cooldownReady then
        graph[source][#graph[source] + 1] = {bindMap, 12,
            "Use your Hearthstone to " .. (GetBindLocation() or "your inn")}
    end
    local distance, previous, previousEdge, open = {[source] = 0}, {}, {},
                                                    {[source] = true}
    while next(open) do
        local current
        for node in pairs(open) do
            if not current or distance[node] < distance[current] then current = node end
        end
        open[current] = nil
        if current == destination then break end
        for _, edge in ipairs(graph[current] or {}) do
            local candidate = distance[current] + edge[2]
            if not distance[edge[1]] or candidate < distance[edge[1]] then
                distance[edge[1]] = candidate
                previous[edge[1]], previousEdge[edge[1]] = current, edge
                open[edge[1]] = true
            end
        end
    end
    if not distance[destination] then
        return nil, "No conservative boat, zeppelin, portal, hearth, or overland route is known."
    end
    local result, node = {}, destination
    while node ~= source do
        local edge = previousEdge[node]
        if not edge then return nil, "The route graph is disconnected." end
        table.insert(result, 1, {from = previous[node], to = node,
                                 duration = edge[2], text = edge[3]})
        node = previous[node]
    end
    return result, distance[destination]
end

function travel:FindFlightRoute(source, destination)
    source, destination = tonumber(source), tonumber(destination)
    local db = FlightDB()
    if not source or not destination or not db[source] or not db[destination] then
        return nil, "The source or destination flight path is unknown."
    end
    local distances, previous, open = {[source] = 0}, {}, {[source] = true}
    while next(open) do
        local current, currentDistance
        for node in pairs(open) do
            if not currentDistance or distances[node] < currentDistance then
                current, currentDistance = node, distances[node]
            end
        end
        open[current] = nil
        if current == destination then break end
        for neighbor, duration in pairs(db[current] or {}) do
            if type(neighbor) == "number" and type(duration) == "number" and
                db[neighbor] and (RXPCData.flightPaths[neighbor] or
                    neighbor == destination) then
                local candidate = currentDistance + math.max(duration, 1)
                if not distances[neighbor] or candidate < distances[neighbor] then
                    distances[neighbor] = candidate
                    previous[neighbor] = current
                    open[neighbor] = true
                end
            end
        end
    end
    if not distances[destination] then
        return nil, "No route exists through the discovered flight paths."
    end
    local route, node = {}, destination
    while node do
        table.insert(route, 1, node)
        if node == source then break end
        node = previous[node]
    end
    return route, distances[destination]
end

function travel:OpenCurrentRoute()
    local step = addon.currentGuide and addon.currentGuide.steps and
                     addon.currentGuide.steps[RXPCData.currentStep or 1]
    local destination
    for _, element in ipairs(step and step.elements or {}) do
        if element.fpId then destination = element.fpId break end
    end
    local lines = {"Safe return-to-route plan:"}
    local duration
    if destination then
        local source = addon.GetNearestFp and addon.GetNearestFp()
        local route
        route, duration = self:FindFlightRoute(source, destination)
        if route then
            local db = FlightDB()
            for index, id in ipairs(route) do
                table.insert(lines, format("%d. Fly via %s", index,
                    db[id] and db[id].name or ("flight path " .. id)))
            end
            table.insert(lines,
                "Flights remain manual unless the taxi panel resolves one exact reachable node.")
        else
            destination = nil
        end
    end
    if not destination then
        local destinationMap
        for _, element in ipairs(step and step.elements or {}) do
            if element.zone then destinationMap = tonumber(element.zone) break end
        end
        local sourceMap = C_Map.GetBestMapForUnit("player")
        local route, errorText = self:FindManualRoute(sourceMap, destinationMap)
        if not route then
            addon.comms:PopupNotification("RXP_ROUTE_UNAVAILABLE", errorText)
            return
        end
        duration = errorText
        if #route == 0 then
            table.insert(lines, "You are already on the current step's map. Follow the guide arrow.")
        else
            for index, edge in ipairs(route) do
                table.insert(lines, format("%d. %s (%s)", index, edge.text,
                    zoneNames[edge.to] or tostring(edge.to)))
            end
        end
    end
    table.insert(lines, format("Conservative travel estimate: %d:%02d",
                               math.floor((duration or 0) / 60),
                               (duration or 0) % 60))
    addon.comms.OpenBrandedExport("Return to Route",
        "Follow these safe travel instructions.", table.concat(lines, "\n"),
        560, 360)
end

function lore:SetMode(mode)
    mode = type(mode) == "string" and mode:lower()
    if mode ~= "off" and mode ~= "first" and mode ~= "always" then
        return false
    end
    addon.settings.profile.loreMode = mode
    return true
end

function lore:MarkSeen(questId)
    questId = tonumber(questId)
    if questId and questId > 0 then RXPData.seenQuests[questId] = true end
end

function lore:ShouldPause(questId, action, element)
    questId = tonumber(questId)
    local mode = addon.settings.profile.loreMode or "off"
    if mode == "off" or not questId or IsControlKeyDown() then return false end
    local repeatable = element and (element.multiple or
        element.tag == "daily" or element.tag == "dailyturnin")
    if mode == "first" and (repeatable or RXPData.seenQuests[questId]) then
        return false
    end
    local token = tostring(action) .. ":" .. questId
    if self.pausedToken == token then return true end
    self.pausedToken = token
    if not self.questFrameHooked and _G.QuestFrame then
        self.questFrameHooked = true
        _G.QuestFrame:HookScript("OnHide", function()
            lore.pausedToken = nil
        end)
    end
    addon.comms.PrettyPrint("Lore mode paused automatic %s for quest %d.",
                            action, questId)
    return true
end
