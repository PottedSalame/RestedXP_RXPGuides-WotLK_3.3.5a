-- Exercise the real source parser and embedded cache, isolated from the other
-- mocked runtime tests. Quest/UI handlers are inert: this tests which authored
-- instructions survive class/race filtering, not gameplay automation.
return function(root)
    local function newLoader(class, race, character, faction)
        local env = setmetatable({}, {__index = _G})
        env._G = env
        env.strlower, env.strupper = string.lower, string.upper
        env.tinsert, env.tremove = table.insert, table.remove
        env.UnitLevel = function() return 10 end
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
    local function checkChain(guide, chain, rate, dungeonDone)
        local tracked, accepted, rewarded = {}, {}, {}
        local prerequisites = {
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
    local priest = loadGuide("Guides/RestedXP Horde 1-13 Troll-Orc.lua",
        "6-10 Durotar", "PRIEST", "Troll", "Horde")
    for _, rate in ipairs({1, 1.5, 2.5}) do
        local _, rewarded = checkChain(priest, {5648}, rate)
        assert(rewarded[5648], "Accelerated Troll Priest route lost its class quest")
    end
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
