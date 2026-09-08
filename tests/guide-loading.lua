-- Exercise the real source parser and embedded cache, isolated from the other
-- mocked runtime tests. Quest/UI handlers are inert: this tests which authored
-- instructions survive class/race filtering, not gameplay automation.
return function(root)
    local function newLoader(class, race, character, faction, level)
        local env = setmetatable({}, {__index = _G})
        env._G = env
        env.strlower, env.strupper = string.lower, string.upper
        env.tinsert, env.tremove = table.insert, table.remove
        env.UnitLevel = function() return level or 10 end
        env.UnitSex = function() return 2 end
        env.bit = {band = function(value) return value % 4294967296 end}
        env.LibStub = function() return {} end
        env.RXPCData = character or {
            guideMetaData = {}, guideDisabled = {}, guideProgress = {},
        }
        local addon = {
            player = {class = class, race = race, faction = faction or "Horde"},
            game = "WOTLK", gameVersion = 30300, RXPGuides = {},
            locale = {Get = function(text) return text end},
            settings = {profile = {}, ReplaceColors = function(text) return text end},
            separators = {}, guideCache = {}, db = {},
            RXPFrame = {GenerateMenuTable = function() end}, error = error,
        }
        addon.functions = setmetatable({}, {__index = function(_, tag)
            return function(raw, text, first, second)
                return {text = text, first = first, second = second, tag = tag}
            end
        end})
        env.RXPGuides = {}
        local chunk = assert(loadfile(root .. "/Guide/Loader.lua"))
        setfenv(chunk, env)("RXPGuides", addon)
        return addon, env
    end

    local file = assert(io.open(root .. "/Guides/RestedXP Horde 1-13 Troll-Orc.lua", "rb"))
    local source = file:read("*a")
    file:close()
    local durotar
    for block in source:gmatch("RXPGuides%.RegisterGuide%(%[%[(.-)%]%]%)") do
        if block:match("#name 6%-10 Durotar[\r\n]") then durotar = block end
    end
    assert(durotar, "Validated 6-10 Durotar source is missing")

    local function visibleAtRate(step, rate)
        local expression = step.xprate
        if not expression then return true end
        local op, lower, upper = expression:match("^([<>]?)%s*(%d+%.?%d*)%-?(%d*%.?%d*)")
        lower, upper = tonumber(lower), tonumber(upper)
        assert(lower, "Unexpected fixture XP condition")
        if op == "<" then return rate <= lower - 1e-4 end
        if op == ">" then return rate >= lower + 1e-4 end
        return rate >= lower and rate <= (upper or 0xfff)
    end

    for _, race in ipairs({"Orc", "Troll"}) do
        for _, class in ipairs({"HUNTER", "WARRIOR", "SHAMAN", "ROGUE", "WARLOCK"}) do
            local addon = newLoader(class, race)
            local guide, parseError = addon.ParseGuide(durotar)
            assert(guide and not parseError, "Durotar failed to parse")
            local barrens = class == "HUNTER" or class == "WARRIOR" or class == "SHAMAN"
            assert(guide.next == (barrens and "10-13 Durotar" or "10-12 Eversong Woods"),
                   race .. " " .. class .. " has the wrong Durotar continuation")
            local undercity = false
            for _, step in ipairs(guide.steps) do
                for _, element in ipairs(step.elements) do
                    if element.first == "Undercity" or element.first == "Tirisfal Glades" or
                        element.first == "Silvermoon City" then undercity = true end
                end
            end
            assert(undercity ~= barrens, race .. " " .. class .. " has mismatched travel steps")
            for _, rate in ipairs({1, 1.1, 1.49, 1.5, 2.5}) do
                local accepted, worked, rewarded = {}, {}, {}
                for _, step in ipairs(guide.steps) do
                    if visibleAtRate(step, rate) then
                        for _, element in ipairs(step.elements) do
                            local quest = tonumber(element.first)
                            if element.tag == "accept" then accepted[quest] = true end
                            if element.tag == "complete" then worked[quest] = true end
                            if element.tag == "turnin" and (quest == 825 or quest == 831) then
                                assert(accepted[quest], race .. " " .. class .. " turns in an unaccepted quest")
                                if quest == 825 then assert(worked[825], "Wreckage hand-in precedes collection") end
                                rewarded[quest] = true
                            end
                        end
                    end
                end
                assert(rewarded[825], "From The Wreckage is never rewarded")
                if class == "HUNTER" or class == "WARLOCK" then
                    assert(rewarded[831], "The Admiral's Orders is never rewarded")
                end
            end
        end
    end

    local function loadGuide(path, name, class, race, faction)
        local input = assert(io.open(root .. "/" .. path, "rb"))
        local text = input:read("*a")
        input:close()
        for block in text:gmatch("RXPGuides%.RegisterGuide%(%[%[(.-)%]%]%)") do
            if block:find("#name " .. name .. "\n", 1, true) or
               block:find("#name " .. name .. "\r\n", 1, true) then
                local addon = newLoader(class, race, nil, faction)
                local guide, failure = addon.ParseGuide(block)
                assert(guide and not failure, "Failed to parse " .. name)
                return guide
            end
        end
        error("Missing guide fixture " .. name)
    end

    -- Run only the selected quest chain, retaining unrelated route actions.
    -- These are source-order tests, not a simulation of NPC dialogs or loot.
    local function checkChain(guide, chain, rate, dungeonDone,
                              initialAccepted, initialRewarded)
        local tracked, accepted, rewarded = {}, {}, {}
        for id, value in pairs(initialAccepted or {}) do accepted[id] = value end
        for id, value in pairs(initialRewarded or {}) do rewarded[id] = value end
        local prerequisites = {
            [6087] = 6061, [6088] = 6087, [6089] = 6088,
            [831] = 830, [9428] = 9627,
            [1250] = 1249, [1264] = 1250,
            [2991] = 2990, [5098] = 5092, [8425] = 8424,
            [11297] = 11311, [11298] = 11297, [11317] = 11286,
            [9746] = 9748, [9740] = 9746, [9753] = 9740,
            [9756] = 9753, [9760] = 9756, [9728] = 9778,
            [12638] = 12633, [12637] = 12631, [12643] = 12638,
            [12629] = 12637, [12649] = 12643, [12648] = 12629,
            [12664] = 12648, [12661] = dungeonDone and 12649 or 12648,
            [9143] = 9145, [10870] = 10866, [10944] = 10708,
            [13329] = {13307, 13312},
        }
        for _, id in ipairs(chain) do tracked[id] = true end
        for _, step in ipairs(guide.steps) do
            local visible = visibleAtRate(step, rate or 1)
            for _, element in ipairs(step.elements) do
                if element.tag == "isQuestTurnedIn" then
                    local guard = tonumber(element.first)
                    if guard == 12238 then visible = visible and dungeonDone end
                    if guard == -12238 then visible = visible and not dungeonDone end
                end
            end
            if visible then
                for _, element in ipairs(step.elements) do
                    local id = tonumber(element.first)
                    if tracked[id] then
                        if element.tag == "accept" then
                            local previous = prerequisites[id]
                            if type(previous) ~= "table" then previous = {previous} end
                            for _, required in ipairs(previous) do
                                assert(not tracked[required] or rewarded[required],
                                       guide.name .. " accepts " .. id .. " before rewarding " .. required)
                            end
                            accepted[id] = true
                        elseif element.tag == "complete" or element.tag == "turnin" then
                            assert(accepted[id] or rewarded[id], guide.name .. " works on unaccepted quest " .. id)
                            if element.tag == "turnin" then rewarded[id] = true end
                        end
                    end
                end
            end
        end
        return accepted, rewarded
    end

    local function stepHas(step, tag, first)
        for _, element in ipairs(step and step.elements or {}) do
            if element.tag == tag and
                (first == nil or tonumber(element.first) == tonumber(first) or
                    element.first == first) then
                return true
            end
        end
        return false
    end


    local function directiveIndex(step, tag, first)
        for index, element in ipairs(step and step.elements or {}) do
            if element.tag == tag and
                (first == nil or tonumber(element.first) == tonumber(first) or
                    element.first == first) then
                return index
            end
        end
    end

    local function findStep(guide, tag, first)
        for index, step in ipairs(guide.steps) do
            if stepHas(step, tag, first) then return step, index end
        end
    end

    local function findVisibleStep(guide, tag, first, rate)
        for index, step in ipairs(guide.steps) do
            if visibleAtRate(step, rate or 1) and stepHas(step, tag, first) then
                return step, index
            end
        end
    end

    local humanPath = "Guides/RestedXP Alliance 1-14 Human.lua"
    local starter = loadGuide("Guides/RestedXP Horde 1-13 Troll-Orc.lua",
        "1-6 Durotar", "HUNTER", "Orc", "Horde")
    assert(starter.next == "6-10 Durotar", "Starter route lost its Durotar continuation")
    local first = starter.steps[1]
    local introAccepted, introTarget
    local wrongClassTargets = {
        ["Ruzan"] = true, ["Hraug"] = true, ["Nartok"] = true,
        ["Rwag"] = true, ["Ken'jai"] = true, ["Shikrik"] = true,
        ["Canaga Earthcaller"] = true, ["Frang"] = true,
    }
    for _, step in ipairs(starter.steps) do
        for _, element in ipairs(step.elements) do
            if step == first and element.tag == "accept" and
                tonumber(element.first) == 4641 then introAccepted = true end
            if step == first and element.tag == "target" and
                element.first == "Kaltunk" then introTarget = true end
            if element.tag == "goto" then
                assert(element.first == "Durotar", "Starter guide leaves Durotar")
            elseif element.tag == "target" then
                assert(not wrongClassTargets[element.first],
                       "Orc Hunter received another class's target: " .. tostring(element.first))
            end
        end
    end
    assert(introAccepted and introTarget,
           "Orc Hunter starter no longer begins with Kaltunk's intro quest")
    local barrens = loadGuide("Guides/RestedXP Horde 13-23 Barrens.lua",
        "13-22 The Barrens", "HUNTER", "Orc", "Horde")
    assert(barrens.next ==
               "22-25 Hillsbrad / South Barrens;22-25 Hillsbrad Foothills JJ",
           "Orc Hunter Barrens route lost its 22-25 continuation")
    local barrensFinal = barrens.steps[#barrens.steps]
    assert(barrensFinal and barrensFinal.completewith ~= "next",
           "Orc Hunter Barrens route ends on an impossible #completewith next")
    local finalTrainer
    for _, element in ipairs(barrensFinal and barrensFinal.elements or {}) do
        if element.tag == "trainer" then finalTrainer = true end
    end
    assert(finalTrainer,
           "Orc Hunter Barrens route no longer ends at the Orgrimmar trainer")
    local barrensProfiles = {
        {"HUNTER", "Orc", "trainer"},
        {"HUNTER", "Troll", "trainer"},
        {"WARRIOR", "Orc", "train", 197},
        {"WARRIOR", "Tauren", "train", 197},
        {"WARRIOR", "Troll", "train", 197},
        {"WARRIOR", "Scourge", "train", 197},
        {"SHAMAN", "Orc", "train", 196},
        {"SHAMAN", "Tauren", "train", 196},
        {"SHAMAN", "Troll", "train", 196},
    }
    for _, profile in ipairs(barrensProfiles) do
        local profileGuide = loadGuide("Guides/RestedXP Horde 13-23 Barrens.lua",
            "13-22 The Barrens", profile[1], profile[2], "Horde")
        assert(profileGuide.next ==
                   "22-25 Hillsbrad / South Barrens;22-25 Hillsbrad Foothills JJ",
               profile[2] .. " " .. profile[1] ..
                   " lost the post-Barrens continuation")
        local profileFinal = profileGuide.steps[#profileGuide.steps]
        assert(profileFinal and profileFinal.completewith ~= "next" and
                   stepHas(profileFinal, profile[3], profile[4]),
               profile[2] .. " " .. profile[1] ..
                   " has a non-completing Barrens terminal step")
    end
    local priest = loadGuide("Guides/RestedXP Horde 1-13 Troll-Orc.lua",
        "6-10 Durotar", "PRIEST", "Troll", "Horde")
    for _, rate in ipairs({1, 1.5, 2.5}) do
        local _, rewarded = checkChain(priest, {5648}, rate)
        assert(rewarded[5648], "Accelerated Troll Priest route lost its class quest")
    end

    local taurenHunter = loadGuide("Guides/RestedXP Horde 1-10 Tauren.lua",
        "6-10 Mulgore", "HUNTER", "Tauren", "Horde")
    local _, taurenHunterRewards = checkChain(taurenHunter,
        {6061, 6087, 6088, 6089})
    assert(taurenHunterRewards[6089],
           "Tauren Hunter route leaves Training the Beast unfinished")
    assert(findStep(taurenHunter, "train", 24547),
           "Tauren Hunter route omits the post-quest pet trainer")

    local undeadWarrior = loadGuide("Guides/RestedXP Horde 1-13 Troll-Orc.lua",
        "10-13 Durotar", "WARRIOR", "Scourge", "Horde")
    local _, undeadWarriorRewards = checkChain(undeadWarrior,
        {784, 791, 830, 831})
    assert(undeadWarriorRewards[784] and undeadWarriorRewards[791] and
               undeadWarriorRewards[830] and undeadWarriorRewards[831],
           "Undead Warrior detour leaves Durotar quests unfinished")

    local bloodElfStonetalon = loadGuide("Guides/RestedXP Horde 20-30.lua",
        "20-23 Stonetalon / The Barrens", "HUNTER", "BloodElf", "Horde")
    local bloodElfAccepted, bloodElfRewards =
        checkChain(bloodElfStonetalon, {9627, 9428})
    assert(bloodElfRewards[9627] and bloodElfAccepted[9428],
           "Blood Elf Horde-allegiance handoff is incomplete")

    local bloodElfAshenvaleJJ = loadGuide("Guides/RestedXP Horde 20-30.lua",
        "25-27 Ashenvale JJ", "HUNTER", "BloodElf", "Horde")
    local allegianceBranches = 0
    for _, step in ipairs(bloodElfAshenvaleJJ.steps) do
        local reportIndex = directiveIndex(step, "accept", 9428)
        if reportIndex then
            allegianceBranches = allegianceBranches + 1
            local acceptIndex = directiveIndex(step, "accept", 9627)
            local turninIndex = directiveIndex(step, "turnin", 9627)
            assert(acceptIndex and turninIndex and acceptIndex < turninIndex and
                       turninIndex < reportIndex,
                   "Blood Elf JJ route offers Report to Splintertree too early")
            if stepHas(step, "isOnQuest", 9626) then
                local meetingIndex = directiveIndex(step, "turnin", 9626)
                assert(meetingIndex and meetingIndex < acceptIndex,
                       "Blood Elf JJ active-quest branch skips Meeting the Warchief")
            else
                assert(stepHas(step, "isQuestTurnedIn", 9626),
                       "Blood Elf JJ fallback branch lacks a Meeting the Warchief guard")
            end
        end
    end
    assert(allegianceBranches == 2,
           "Blood Elf JJ route lost one of its Horde-allegiance branches")

    local rogueAshenvale = loadGuide("Guides/RestedXP Horde 20-30.lua",
        "26-30 Ashenvale / Thousand Needles", "ROGUE", "Orc", "Horde")
    local _, rogueRewards = checkChain(rogueAshenvale,
        {6563, 6564, 6921, 6922})
    assert(rogueRewards[6563] and rogueRewards[6564] and
               rogueRewards[6921] and rogueRewards[6922],
           "Rogue Blackfathom Deeps detour leaves quests unfinished")
    local aquanisStep = findStep(rogueAshenvale, "accept", 6922)
    assert(stepHas(aquanisStep, "complete", 6921) and
               stepHas(aquanisStep, "collect", 16782) and
               stepHas(aquanisStep, "use", 16782),
           "Baron Aquanis is not started from the correct Fathom Core item")

    local thousandNeedles = loadGuide("Guides/RestedXP Horde 20-30.lua",
        "28-30 Thousand Needles JJ", "HUNTER", "Orc", "Horde")
    local _, thousandNeedlesRewards =
        checkChain(thousandNeedles, {1150, 4767}, 1.5)
    assert(thousandNeedlesRewards[1150] and thousandNeedlesRewards[4767],
           "Accelerated Thousand Needles route leaves completed quests behind")
    local windRiderStep, windRiderIndex = findStep(thousandNeedles, "turnin", 4767)
    local enduranceStep, enduranceIndex = findStep(thousandNeedles, "turnin", 1150)
    assert(windRiderStep and not windRiderStep.completewith and
               enduranceStep and windRiderIndex < enduranceIndex,
           "Wind Rider can be discarded as a parallel step before its turn-in")

    local normalThousandNeedles = loadGuide("Guides/RestedXP Horde 20-30.lua",
        "26-30 Ashenvale / Thousand Needles", "HUNTER", "Orc", "Horde")
    local _, normalNeedlesRewards =
        checkChain(normalThousandNeedles, {1150, 4767}, 1)
    assert(normalNeedlesRewards[1150] and normalNeedlesRewards[4767],
           "Normal Thousand Needles route leaves completed quests behind")

    local missingDiplomat = loadGuide("Guides/RestedXP Alliance 23-30.lua",
        "30-32 Duskwood/STV", "WARRIOR", "Human", "Alliance")
    local diplomatAccepted, diplomatRewards =
        checkChain(missingDiplomat, {1249, 1250, 1264})
    assert(diplomatRewards[1249] and diplomatRewards[1250],
           "Missing Diplomat handoff no longer rewards its prerequisites")
    assert(diplomatAccepted[1264],
           "Missing Diplomat continuation is absent")
    local diplomatHandoff = findStep(missingDiplomat, "accept", 1250)
    assert(stepHas(diplomatHandoff, "isQuestTurnedIn", 1249) and
               not stepHas(diplomatHandoff, "isOnQuest", 1250),
           "Missing Diplomat pickup retains an impossible active-quest guard")

    local oldHistory = loadGuide("Guides/RestedXP Alliance 23-30.lua",
        "28-30 Duskwood", "WARRIOR", "Human", "Alliance")
    local oldHistoryAccepted, oldHistoryRewarded = checkChain(oldHistory, {337})
    assert(oldHistoryAccepted[337] and oldHistoryRewarded[337],
           "Old History Book can no longer be started from its item")
    local oldHistoryStep = findStep(oldHistory, "accept", 337)
    assert(stepHas(oldHistoryStep, "itemcount", 2794) and
               stepHas(oldHistoryStep, "use", 2794),
           "Old History Book pickup is not guarded and activated by item 2794")

    local zulfarrak = loadGuide("Guides/TBC/Alliance-Dungeons.lua",
        "10. Zul'Farrak", "WARRIOR", "Human", "Alliance")
    local _, zulfarrakRewards = checkChain(zulfarrak, {2990, 2991})
    assert(zulfarrakRewards[2990] and zulfarrakRewards[2991],
           "Alliance Zul'Farrak prerequisite handoff is incomplete")
    local zulfarrakHandoff = findStep(zulfarrak, "accept", 2991)
    assert(stepHas(zulfarrakHandoff, "isOnQuest", 2990) and
               not stepHas(zulfarrakHandoff, "isQuestTurnedIn", 2990),
           "Alliance Zul'Farrak handoff has an impossible turn-in guard")

    local sunkenTemple = loadGuide("Guides/TBC/Horde-Dungeons.lua",
        "112 Sunken Temple", "WARRIOR", "Orc", "Horde")
    local _, sunkenTempleRewards = checkChain(sunkenTemple, {8424, 8425})
    assert(sunkenTempleRewards[8424] and sunkenTempleRewards[8425],
           "Horde Warrior Sunken Temple class chain is incomplete")
    local templeHandoff = findStep(sunkenTemple, "turnin", 8424)
    assert(stepHas(templeHandoff, "isQuestComplete", 8424) and
               not stepHas(templeHandoff, "isQuestComplete", 8425),
           "Sunken Temple handoff is guarded by its unavailable follow-up")

    local blackfathom = loadGuide("Guides/TBC/Horde-Dungeons.lua",
        "104 Blackfathom Deeps", "WARRIOR", "Orc", "Horde")
    local ruinsTurnin = findStep(blackfathom, "turnin", 6921)
    assert(stepHas(ruinsTurnin, "isQuestComplete", 6921) and
               not stepHas(ruinsTurnin, "isQuestComplete", 6521),
           "Blackfathom Deeps still checks the misspelled quest ID 6521")

    local scholomanceKey = loadGuide("Guides/Classic-Endgame335.lua",
        "Scholomance Key (A)", "WARRIOR", "Human", "Alliance")
    local _, scholomanceRewards = checkChain(scholomanceKey, {5092, 5098})
    assert(scholomanceRewards[5092] and scholomanceRewards[5098],
           "Alliance Scholomance key chain skips Clear the Way turn-in")

    local hordeFjord = loadGuide("Guides/WotLK/Horde-Leveling.lua",
        "72-74 Northrend", "HUNTER", "Orc", "Horde")
    local _, hordeFjordRewards = checkChain(hordeFjord,
        {11286, 11317, 11311, 11297, 11298})
    assert(hordeFjordRewards[11286] and hordeFjordRewards[11317] and
               hordeFjordRewards[11311] and hordeFjordRewards[11297] and
               hordeFjordRewards[11298],
           "Howling Fjord prerequisite chains are incomplete")

    local teldrassil = loadGuide("Guides/RestedXP Alliance 1-11 NightElf.lua",
        "6-11 Teldrassil", "ROGUE", "NightElf", "Alliance")
    local groveAccepted, groveRewarded = checkChain(teldrassil, {952}, 1)
    assert(groveAccepted[952] and not groveRewarded[952],
           "Teldrassil no longer preserves the Grove of the Ancients breadcrumb")
    local darkshore = loadGuide("Guides/RestedXP Alliance 11-23.lua",
        "20-21 Darkshore", "ROGUE", "NightElf", "Alliance")
    _, groveRewarded = checkChain(darkshore, {952}, 1, nil,
                                  groveAccepted, groveRewarded)
    assert(groveRewarded[952],
           "Darkshore never delivers Grove of the Ancients")

    local elwynnWarlock = loadGuide(humanPath, "1-11 Elwynn Forest",
        "WARLOCK", "Human", "Alliance")
    local lewisAccepted, lewisRewarded =
        checkChain(elwynnWarlock, {6285}, 1.5)
    assert(lewisAccepted[6285] and not lewisRewarded[6285],
           "Elwynn no longer preserves Return to Lewis")
    local redridgeDuskwood = loadGuide("Guides/RestedXP Alliance 23-30.lua",
        "24-27 Redridge/Duskwood", "WARLOCK", "Human", "Alliance")
    _, lewisRewarded = checkChain(redridgeDuskwood, {6285}, 1.5, nil,
                                  lewisAccepted, lewisRewarded)
    assert(lewisRewarded[6285],
           "The later Westfall visit never delivers Return to Lewis")
    for _, class in ipairs({"WARLOCK", "MAGE"}) do
        local guide = loadGuide(humanPath, "1-11 Elwynn Forest", class, "Human", "Alliance")
        for _, rate in ipairs({1, 1.119, 1.12, 1.3, 1.31, 1.5, 1.7, 2.5}) do
            local accepted, rewarded = checkChain(guide, {12, 153}, rate)
            local expected = rate > (class == "WARLOCK" and 1.119 or 1.3)
            assert(not not accepted[12] == expected and not not accepted[153] == expected,
                   "Westfall accept threshold changed for " .. class)
            assert(not not rewarded[12] == expected and not not rewarded[153] == expected,
                   "Westfall work and reward thresholds disagree for " .. class)
        end
    end
    for _, class in ipairs({"HUNTER", "MAGE", "SHAMAN"}) do
        local guide = loadGuide("Guides/RestedXP Alliance 1-23 Draenei.lua",
            "11-20 Bloodmyst (Draenei)", class, "Draenei", "Alliance")
        local _, rewarded = checkChain(guide, {9748, 9746, 9740, 9753, 9756, 9760})
        assert(rewarded[9760], "Bloodmyst never delivers Vindicator's Rest")
    end
    for _, faction in ipairs({"Alliance", "Horde"}) do
        local race = faction == "Alliance" and "Human" or "Orc"
        local guide = loadGuide("Guides/TBC/" .. faction .. "-Leveling.lua",
            "61-63 Zangarmarsh", "WARRIOR", race, faction)
        local _, rewarded = checkChain(guide, {9778, 9728})
        assert(rewarded[9778] and rewarded[9728], "Zangarmarsh handoff is incomplete")
        local northrend = loadGuide("Guides/WotLK/" .. faction .. "-Leveling.lua",
            "76-78 Northrend", "WARRIOR", race, faction)
        for _, done in ipairs({false, true}) do
            local chain = done and {12633, 12638, 12643, 12649, 12663, 12661}
                or {12631, 12637, 12629, 12648, 12664, 12661}
            local other = done and {12631, 12637, 12629, 12648, 12664}
                or {12633, 12638, 12643, 12649, 12663}
            local _, rewards = checkChain(northrend, chain, 1, done)
            for _, id in ipairs(chain) do assert(rewards[id], "Missing Drakuru reward " .. id) end
            local acceptedOther = checkChain(northrend, other, 1, done)
            assert(next(acceptedOther) == nil, "Opposite Drakuru branch leaked into the route")
        end
    end

    local ghostlands = loadGuide("Guides/RestedXP Horde 1-20 BloodElf.lua",
        "12-16 Ghostlands", "HUNTER", "BloodElf", "Horde")
    local _, ghostRewards = checkChain(ghostlands, {9145, 9143})
    assert(ghostRewards[9145] and ghostRewards[9143], "Ghostlands ranger handoff is incomplete")
    local icecrown = loadGuide("Guides/Dailies/Icecrown Gunship Pre Quests.lua",
        "Icecrown Gunship Unlock Daily Quests", "HUNTER", "Orc", "Horde")
    local _, iceRewards = checkChain(icecrown, {13307, 13312, 13329})
    assert(iceRewards[13329], "Volatility prerequisite is not finished")
    for _, faction in ipairs({"Alliance", "Horde"}) do
        local race = faction == "Alliance" and "Human" or "Orc"
        local netherwing = loadGuide("Guides/TBC/Reputation.lua",
            "Netherwing", "WARRIOR", race, faction)
        local _, netherRewards = checkChain(netherwing, {10866, 10870})
        assert(netherRewards[10866] and netherRewards[10870], "Wrong Zuluhed quest variant")
        local temple = loadGuide("Guides/TBC/Attunements.lua",
            "5. Black Temple", "WARRIOR", race, faction)
        local _, templeRewards = checkChain(temple, {10708, 10944})
        assert(templeRewards[10708] and templeRewards[10944], "Akama handoff is incomplete")
    end

    -- Accepted/completed quests must either be handed in on their routed NPC
    -- pass or be suppressed when the route deliberately omits their work.
    local dwarfPriest = loadGuide("Guides/RestedXP Alliance 1-14 Dwarf-Gnome.lua",
        "6-11 Dun Morogh", "PRIEST", "Dwarf", "Alliance")
    assert(findStep(dwarfPriest, "turnin", 2160),
           "Dwarf Priest never delivers Supplies to Tannok")

    local dwarfDarkshore = loadGuide("Guides/RestedXP Alliance 11-23.lua",
        "11-14 Darkshore", "HUNTER", "Dwarf", "Alliance")
    local plaguedTurnin = findStep(dwarfDarkshore, "turnin", -2118)
    assert(plaguedTurnin and visibleAtRate(plaguedTurnin, 2.5),
           "Accelerated Dwarf Hunter never delivers Plagued Lands")
    local redCrystalGuide = loadGuide("Guides/RestedXP Alliance 11-23.lua",
        "11-14 Darkshore", "WARRIOR", "Human", "Alliance")
    local redCrystalPickup = findStep(redCrystalGuide, "accept", 4811)
    assert(redCrystalPickup and visibleAtRate(redCrystalPickup, 1.69) and
               not visibleAtRate(redCrystalPickup, 1.7),
           "Red Crystal pickup no longer matches its routed work")

    local druidTeldrassil = loadGuide(
        "Guides/RestedXP Alliance 1-11 NightElf.lua", "6-11 Teldrassil",
        "DRUID", "NightElf", "Alliance")
    local crownPickup = findStep(druidTeldrassil, "accept", 933)
    assert(crownPickup and visibleAtRate(crownPickup, 1.49) and
               not visibleAtRate(crownPickup, 1.5),
           "Druid Crown of the Earth pickup escaped its complete route")
    assert(findVisibleStep(druidTeldrassil, "turnin", 940, 2.5),
           "Accelerated Druid never delivers Teldrassil")

    local humanMage = loadGuide(humanPath, "1-11 Elwynn Forest",
        "MAGE", "Human", "Alliance")
    local collectorTurnin = findStep(humanMage, "turnin", -123)
    assert(collectorTurnin and stepHas(collectorTurnin, "turnin", 176) and
               directiveIndex(collectorTurnin, "turnin", 176) <
                   directiveIndex(collectorTurnin, "turnin", -123),
           "Mage Hogger stop never safely delivers The Collector")

    for _, guideName in ipairs({"24-27 Redridge/Duskwood", "28-30 Duskwood"}) do
        local hunterDuskwood = loadGuide("Guides/RestedXP Alliance 23-30.lua",
            guideName, "HUNTER", "Human", "Alliance")
        assert(findStep(hunterDuskwood, "turnin", 229),
               guideName .. " strands The Daughter Who Lived for Hunters")
    end
    local acceleratedDuskwood = loadGuide("Guides/RestedXP Alliance 23-30.lua",
        "28-30 Duskwood", "HUNTER", "Human", "Alliance")
    assert(not findStep(acceleratedDuskwood, "accept", 253),
           "Accelerated Duskwood accepts Bride without routing its objective")

    local allianceHillsbrad = loadGuide("Guides/RestedXP Alliance 23-30.lua",
        "30-32 Hillsbrad", "WARRIOR", "Human", "Alliance")
    assert(findStep(allianceHillsbrad, "turnin", 286),
           "Return the Statuette is not delivered before leaving Menethil")
    assert(findStep(allianceHillsbrad, "accept", 322),
           "Blessed Arm pickup fixture disappeared")
    local allianceSTV = loadGuide("Guides/TBC/Alliance-Leveling.lua",
        "35-37 STV", "WARRIOR", "Human", "Alliance")
    local blessedArm = findStep(allianceSTV, "turnin", 322)
    assert(blessedArm and stepHas(blessedArm, "isOnQuest", 322),
           "Later Stormwind route never delivers Blessed Arm safely")

    local allianceBoosted = loadGuide(
        "Guides/RestedXP Alliance Boosted 58-60.lua",
        "Boosted Character 58-60", "WARRIOR", "Human", "Alliance")
    assert(not findStep(allianceBoosted, "accept", 5282),
           "Boosted route still accepts the unrouted Stratholme follow-up")

    local setPartFour = loadGuide("Guides/Classic-Endgame335.lua",
        "Part 4: Helm & Chest", "WARRIOR", "Human", "Alliance")
    local medallionHandoff = findStep(setPartFour, "turnin", 8332)
    assert(medallionHandoff and stepHas(medallionHandoff, "accept", 8333),
           "Medallion of Station is handed in without being accepted")
    for _, keyFixture in ipairs({
        {"Scholomance Key (A)", "WARRIOR", "Human", "Alliance", 5803, 5505},
        {"Scholomance Key (H)", "WARRIOR", "Orc", "Horde", 5804, 5511},
    }) do
        local keyGuide = loadGuide("Guides/Classic-Endgame335.lua",
            keyFixture[1], keyFixture[2], keyFixture[3], keyFixture[4])
        local handoff = findStep(keyGuide, "turnin", keyFixture[5])
        assert(handoff and stepHas(handoff, "accept", keyFixture[6]),
               keyFixture[1] .. " omits its same-NPC follow-up pickup")
    end

    local hordeHillsbrad = loadGuide("Guides/RestedXP Horde 20-30.lua",
        "22-25 Hillsbrad / South Barrens", "HUNTER", "Orc", "Horde")
    assert(findStep(hordeHillsbrad, "turnin", 529),
           "Normal Horde route never delivers Battle of Hillsbrad")
    local undeadBarrens = loadGuide("Guides/RestedXP Horde 13-23 Barrens.lua",
        "13-22 The Barrens", "WARRIOR", "Scourge", "Horde")
    assert(findStep(undeadBarrens, "turnin", 924),
           "Undead Warrior never delivers The Demon Seed")
    local undeadEversong = loadGuide("Guides/RestedXP Horde 1-20 BloodElf.lua",
        "6-10 Eversong Woods", "WARRIOR", "Scourge", "Horde")
    local fairbreeze = findStep(undeadEversong, "turnin", 9252)
    assert(fairbreeze and stepHas(fairbreeze, "isQuestComplete", 9252),
           "Undead Warrior leaves Eversong with Defending Fairbreeze complete")
    local orcDurotar = loadGuide("Guides/RestedXP Horde 1-13 Troll-Orc.lua",
        "6-10 Durotar", "HUNTER", "Orc", "Horde")
    assert(findStep(orcDurotar, "turnin", -791),
           "Accelerated Durotar route strands Carry Your Weight")

    local orcAshenvaleJJ = loadGuide("Guides/RestedXP Horde 20-30.lua",
        "25-27 Ashenvale JJ", "HUNTER", "Orc", "Horde")
    local orcWeaponsPickup = findStep(orcAshenvaleJJ, "accept", 893)
    assert(orcWeaponsPickup and visibleAtRate(orcWeaponsPickup, 1.69) and
               not visibleAtRate(orcWeaponsPickup, 1.7),
           "High-rate non-Tauren JJ route still accepts unrouted Weapons of Choice")
    local taurenAshenvaleJJ = loadGuide("Guides/RestedXP Horde 20-30.lua",
        "25-27 Ashenvale JJ", "HUNTER", "Tauren", "Horde")
    assert(findVisibleStep(taurenAshenvaleJJ, "accept", 893, 2.5),
           "High-rate Tauren lost its routed Weapons of Choice pickup")
    local orcSouthernJJ = loadGuide("Guides/RestedXP Horde 20-30.lua",
        "27-28 Southern Barrens JJ", "HUNTER", "Orc", "Horde")
    for _, step in ipairs(orcSouthernJJ.steps) do
        if stepHas(step, "complete", 893) then
            assert(stepHas(step, "isOnQuest", 893),
                   "Weapons of Choice objective lacks its active-quest guard")
        end
    end
    assert(not findStep(orcSouthernJJ, "accept", 1153),
           "Non-Tauren JJ route still accepts the unrouted ore sample")
    local taurenSouthernJJ = loadGuide("Guides/RestedXP Horde 20-30.lua",
        "27-28 Southern Barrens JJ", "HUNTER", "Tauren", "Horde")
    assert(findVisibleStep(taurenSouthernJJ, "accept", 1153, 1.5) and
               not findVisibleStep(taurenSouthernJJ, "accept", 1153, 2.0),
           "Tauren ore-sample pickup no longer matches its objective branch")
    local taurenNeedlesJJ = loadGuide("Guides/RestedXP Horde 20-30.lua",
        "28-30 Thousand Needles JJ", "HUNTER", "Tauren", "Horde")
    for _, step in ipairs(taurenNeedlesJJ.steps) do
        if stepHas(step, "complete", 1153) then
            assert(stepHas(step, "isOnQuest", 1153),
                   "Ore Sample objective lacks its active-quest guard")
        end
    end
    local orcNeedlesJJ = loadGuide("Guides/RestedXP Horde 20-30.lua",
        "28-30 Thousand Needles JJ", "HUNTER", "Orc", "Horde")
    assert(not findStep(orcNeedlesJJ, "complete", 1153),
           "Non-Tauren JJ route still works an unavailable ore sample")

    local hordeThirty = loadGuide("Guides/TBC/Horde-Leveling.lua",
        "30-33 Hillsbrad/Arathi part 1", "DRUID", "Tauren", "Horde")
    assert(not findStep(hordeThirty, "accept", 31),
           "WotLK route still accepts the obsolete Aquatic Form handoff")

    local hordeBorean = loadGuide("Guides/WotLK/Horde-Leveling.lua",
        "70-72 Northrend", "HUNTER", "Orc", "Horde")
    local drakeObjective = findStep(hordeBorean, "complete", 11919)
    assert(drakeObjective and stepHas(drakeObjective, "turnin", 11919) and
               not findStep(hordeBorean, "complete", 11940),
           "Drake Hunt objective uses a different quest than its hand-in")

    local lowerBlackrock = loadGuide("Guides/TBC/Alliance-Dungeons.lua",
        "14. Lower Blackrock Spire", "WARRIOR", "Human", "Alliance")
    assert(findStep(lowerBlackrock, "turnin", 5002) and
               not findStep(lowerBlackrock, "turnin", 6402),
           "Message to Maxwell uses the Stormwind Rendezvous ID")

    for _, dungeonFixture in ipairs({
        {"Guides/TBC/Alliance-Dungeons.lua", "16. Scholomance", "Human", 5343},
        {"Guides/TBC/Horde-Dungeons.lua", "116 Scholomance", "Orc", 5341},
    }) do
        local dungeon = loadGuide(dungeonFixture[1], dungeonFixture[2],
            "WARRIOR", dungeonFixture[3],
            dungeonFixture[3] == "Human" and "Alliance" or "Horde")
        local scalePickup = findStep(dungeon, "accept", 5582)
        local scaleTurnin = findStep(dungeon, "turnin", 5582)
        assert(scalePickup and stepHas(scalePickup, "use", 13920) and
                   stepHas(scalePickup, "isQuestTurnedIn", 5529),
               dungeonFixture[2] .. " does not gate/start Healthy Dragon Scale")
        assert(scaleTurnin and stepHas(scaleTurnin, "isQuestComplete", 5582),
               dungeonFixture[2] .. " never delivers Healthy Dragon Scale")
        for _, step in ipairs(dungeon.steps) do
            if stepHas(step, "complete", 5529) then
                assert(not stepHas(step, "accept", 5582),
                       "First-run Plagued Hatchlings still starts its repeat-run quest")
            end
        end
        if dungeonFixture[4] == 5343 then
            assert(findStep(dungeon, "complete", 5343) and
                       findStep(dungeon, "turnin", 5343) and
                       not findStep(dungeon, "complete", 5341),
                   "Alliance Barov Family Fortune still uses Horde quest IDs")
        end
    end

    local sunreavers = loadGuide(
        "Guides/Dailies/Argent Tournament Grounds.lua",
        "J_3.2AT_Sunreavers_Daily_Quests", "HUNTER", "Orc", "Horde")
    local mercyObjective = findStep(sunreavers, "complete", 14140)
    assert(mercyObjective and stepHas(mercyObjective, "isOnQuest", 14140) and
               not findStep(sunreavers, "complete", 14080),
           "Sunreaver Light's Mercy objective uses the Alliance quest ID")

    local scryerShadowmoon = loadGuide("Guides/TBC/Horde-Leveling.lua",
        "69-70 Shadowmoon Valley (Scryer)", "HUNTER", "Orc", "Horde")
    for _, directive in ipairs({"accept", "complete", "turnin"}) do
        local step = findStep(scryerShadowmoon, directive, 10687)
        assert(step and stepHas(step, "skill", "riding"),
               "Karabor Training Grounds " .. directive .. " lacks its flying guard")
    end

    local warriorAshenvale = loadGuide("Guides/RestedXP Horde 20-30.lua",
        "26-30 Ashenvale / Thousand Needles", "WARRIOR", "Orc", "Horde")
    assert(findVisibleStep(warriorAshenvale, "turnin", 1719, 1),
           "WotLK Warrior route leaves The Affray complete at normal XP rates")

    local allianceAlterac = loadGuide("Guides/TBC/Alliance-Leveling.lua",
        "33-35 Hillsbrad/Arathi/Alterac", "WARRIOR", "Human", "Alliance")
    local cyclonianPickup = findStep(allianceAlterac, "accept", 1712)
    assert(cyclonianPickup and visibleAtRate(cyclonianPickup, 1.3) and
               not visibleAtRate(cyclonianPickup, 1.301),
           "Cyclonian pickup is not confined to the route that completes it")

    local allianceDustwallow = loadGuide("Guides/TBC/Alliance-Leveling.lua",
        "37-39 Dustwallow", "HUNTER", "Human", "Alliance")
    local razzericPickup = findStep(allianceDustwallow, "accept", 1187)
    assert(razzericPickup and visibleAtRate(razzericPickup, 1.3) and
               not visibleAtRate(razzericPickup, 1.301),
           "Razzeric's Tweaking pickup is not confined to its return route")

    -- Direct parsing alone cannot catch a startup filter that discards valid
    -- guides first. Exercise the registration queue and old disabled cache.
    do
        local fixtures = {
            {"Generic", "", true},
            {"Legacy client", "<< ac335\n", true},
            {"Wrong client condition", "<< !ac335\n", false},
            {"Wrath", "#wotlk\n", true},
            {"Classic only", "#classic\n", false},
            {"TBC only", "#tbc\n", false},
            {"Mists only", "#mop\n", false},
            {"Dragonflight only", "#df\n", false},
            {"Multiple expansions", "#classic\n#wotlk\n", true},
            {"Wrong faction", "<< ac335 Alliance\n", false},
            {"Wrong class", "<< ac335 Mage\n", false},
            {"Conditional expansion", "#wotlk << Hunter\n#classic << !Hunter\n", true},
            {"Filtered expansion", "#classic\n#wotlk << Mage\n", false},
            {"Prose is not a header", "#classic\n#description Mentions #wotlk\n", false},
        }
        local addon, env = newLoader("HUNTER", "Orc", nil, "Horde", 1)
        local character = env.RXPCData
        character.guideDisabled = {[0] = #fixtures}
        local checkpoint = {currentStep = 17, stepSkip = {[2] = true},
                            completedWaypoints = {[3] = true}}
        character.guideProgress.saved = checkpoint
        character.currentGuideName = "Saved guide"
        character.currentStep = 17
        local oldMetadata = character.guideMetaData
        for index, fixture in ipairs(fixtures) do
            local source = fixture[2] .. "#group Startup\n#subgroup Test\n" ..
                "#name " .. fixture[1] .. "\nstep\n+Fixture\n"
            local parsed, failure = addon.ParseGuide(source)
            fixture.directEligible = parsed ~= nil and not failure
            fixture.source = source
            character.guideDisabled[index] = addon.A32(source)
            addon.RegisterGuide(source)
        end
        addon.LoadEmbeddedGuides()
        for _, fixture in ipairs(fixtures) do
            assert((addon.guides["Startup||" .. fixture[1]] ~= nil) == fixture[3],
                   "Startup eligibility differs for " .. fixture[1])
            assert(fixture.directEligible == fixture[3],
                   "Unexpected direct-parse eligibility for " .. fixture[1])
        end
        assert(character.guideProgress.saved == checkpoint and
                   checkpoint.currentStep == 17 and checkpoint.stepSkip[2] and
                   checkpoint.completedWaypoints[3] and
                   character.currentGuideName == "Saved guide" and
                   character.currentStep == 17 and
                   character.guideMetaData == oldMetadata,
               "Disabled-cache migration changed progress or metadata")
        -- Subsequent logins retain the new cache and still reject other clients.
        local currentCache = character.guideDisabled
        local reloaded = newLoader("HUNTER", "Orc", character, "Horde", 1)
        for _, fixture in ipairs(fixtures) do reloaded.RegisterGuide(fixture.source) end
        reloaded.LoadEmbeddedGuides()
        assert(character.guideDisabled == currentCache,
               "Disabled-cache migration repeats on every login")
        for _, fixture in ipairs(fixtures) do
            assert((reloaded.guides["Startup||" .. fixture[1]] ~= nil) == fixture[3],
                   "Reload eligibility differs for " .. fixture[1])
        end
    end

    -- Audit the actual 30300 manifest, including Original guides, rather than
    -- maintaining a second hand-picked list that can miss new content.
    do
        local function readFile(path)
            local input = assert(io.open(root .. "/" .. path, "rb"))
            local text = input:read("*a")
            input:close()
            return text
        end
        local sources, fileCount = {}, 0
        for path in readFile("GuideList_335.xml"):gmatch('<Script%s+file="([^"]+)"') do
            fileCount = fileCount + 1
            for block in readFile(path:gsub("\\", "/")):gmatch(
                "RXPGuides%.RegisterGuide%(%[%[(.-)%]%]%)") do
                sources[#sources + 1] = block
            end
        end
        assert(#sources > 0, "Startup audit found no manifest guides")
        local profiles = {
            {"HUNTER", "Orc", "Horde", 1},
            {"WARRIOR", "Human", "Alliance", 1},
            {"DRUID", "Tauren", "Horde", 80},
            {"MAGE", "Gnome", "Alliance", 80},
        }
        for _, profile in ipairs(profiles) do
            local reference = newLoader(profile[1], profile[2], nil, profile[3], profile[4])
            local startup, env = newLoader(profile[1], profile[2], nil, profile[3], profile[4])
            local expected = {}
            -- Same block count AND signature reproduces the former persistent
            -- exclusion; merely adding a guide would not exercise recovery.
            env.RXPCData.guideDisabled = {[0] = #sources}
            for index, source in ipairs(sources) do
                local guide, failure = reference.ParseGuide(source)
                if guide and not failure then
                    expected[guide.group .. "||" .. guide.name] = guide
                end
                env.RXPCData.guideDisabled[index] = startup.A32(source)
                startup.RegisterGuide(source)
            end
            startup.LoadEmbeddedGuides()
            local endgameCount = 0
            for key, parsed in pairs(expected) do
                local loaded = assert(startup.guides[key],
                    "Startup lost applicable guide: " .. key .. " for " .. profile[2])
                assert(loaded.key == parsed.key and #loaded.steps == #parsed.steps,
                       "Startup changed identity or step count: " .. key)
                for index, step in ipairs(parsed.steps) do
                    -- Embedded keys omit subgroups before ParseGuide assigns
                    -- guideId. Compare the source-line portion of step IDs.
                    assert(loaded.steps[index].stepId - loaded.guideId ==
                               step.stepId - parsed.guideId,
                           "Startup changed step source position: " .. key)
                end
                if parsed.group == "RestedXP Endgame Guides" then
                    endgameCount = endgameCount + 1
                end
            end
            for key in pairs(startup.guides) do
                assert(expected[key], "Startup admitted an incompatible guide: " .. key)
            end
            assert(endgameCount == 10,
                   "Missing Endgame chapters for " .. profile[2] .. " at level " .. profile[4])
            local group = assert(startup.guideList["RestedXP Endgame Guides"])
            assert(#group.names_ == 10, "Endgame chapters did not reach the picker registry")
        end
        print(string.format("Manifest startup coverage passed: %d files, %d guides, %d profiles.",
                            fileCount, #sources, #profiles))
    end

    local oldSource = "#wotlk\n#group Fixture\n#name Fixture\n#next Old Route\nstep\n+Fixture\n"
    local newSource = oldSource:gsub("Old Route", "New Route")
    assert(#oldSource == #newSource, "Cache test must exercise a same-length edit")
    for _, cacheKind in ipairs({"legacy", "changed", "unchanged", "disabled"}) do
        local addon, env = newLoader("HUNTER", "Orc")
        local _, _, metadata = addon.ParseGuide(oldSource, nil, nil, true)
        local key = metadata.key
        if cacheKind == "changed" then metadata.sourceSignature = addon.A32(oldSource) end
        if cacheKind == "unchanged" then
            _, _, metadata = addon.ParseGuide(newSource, nil, nil, true)
            metadata.sourceSignature = addon.A32(newSource)
        end
        env.RXPCData.guideMetaData[key] = metadata
        env.RXPCData.guideDisabled = {[0] = 1}
        if cacheKind == "disabled" then env.RXPCData.guideDisabled[1] = #newSource end
        local progress = {currentStep = 17, stepSkip = {[2] = true}}
        env.RXPCData.guideProgress[key] = progress
        addon.guideCache[key] = function() error("Stale imported parser survived") end
        addon.RegisterGuide(newSource)
        addon.LoadEmbeddedGuides()
        local guide = assert(addon.guides["Fixture||Fixture"])
        assert(guide.next == "New Route", cacheKind .. " cache retained the old route")
        if not guide.steps then
            guide = assert(addon.guideCache[key]())
        else
            assert(addon.guideCache[key] == nil, "Parsed guide retained an unrelated lazy parser")
        end
        assert(guide.next == "New Route", "Lazy parse returned stale source")
        local refreshed = assert(env.RXPCData.guideMetaData[key], "Lazy parse erased metadata")
        assert(refreshed.sourceSignature == addon.A32(newSource), "Source identity was not saved")
        assert(env.RXPCData.guideProgress[key] == progress and progress.currentStep == 17,
               "Metadata rebuild changed character progress")
    end
    do
        local addon = newLoader("HUNTER", "Orc")
        local stale = assert(addon.ParseGuide(oldSource))
        stale.imported = true
        assert(addon.AddGuide(stale), "Failed to seed stale imported guide")
        addon.RegisterGuide(newSource)
        addon.LoadEmbeddedGuides()
        local replacement = assert(addon.guides["Fixture||Fixture"])
        assert(replacement.next == "New Route" and replacement.bundled,
               "Bundled guide did not replace its same-key imported copy")
        assert(addon.bundledGuideReplacements[replacement.key],
               "Same-key layout replacement was not recorded")
        assert(addon.guideCache[replacement.key] == nil,
               "Stale imported parser survived bundled replacement")
    end
    print("Alliance/Horde quest-chain, source filtering and embedded-cache regression tests passed.")
end
