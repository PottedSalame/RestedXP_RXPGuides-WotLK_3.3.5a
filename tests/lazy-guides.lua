-- Production parser, directive handlers, quest-route reader and fetch path.
-- No client memory estimate; these assertions establish retained work counts.
return function(root, fixturesOnly)
    local function read(path)
        local file = assert(io.open(root .. "/" .. path, "rb"))
        local source = file:read("*a"):gsub("\r\n", "\n"); file:close(); return source
    end
    local function slice(path, first, last)
        local source = read(path)
        local from = assert(source:find(first, 1, true), first)
        return source:sub(from, assert(source:find(last, from + #first, true), last) - 1)
    end
    local factory = assert(loadfile(root .. "/tests/quest-automation-audit.lua"))
    setfenv(factory, setmetatable({arg = {root, "--fixtures"}}, {__index = _G}))
    local fixture = factory()
    local function new()
        local f = fixture(); f:loadDirectives()
        local a, e = f.addon, f.env
        e.strlower, e.tremove, e.fmt = string.lower, table.remove, string.format
        e.coroutine = coroutine
        e.addon = a
        e.CopyTable = function(value)
            local out = {}; for k, v in pairs(value) do out[k] = type(v) == "table" and e.CopyTable(v) or v end
            return out
        end
        a.player = {class = "WARRIOR", race = "Orc", faction = "Horde", maxlevel = 80}
        a.game, a.gameVersion, a.RXPGuides, a.guideCache, a.db = "WOTLK", 30300, {}, {}, {}
        a.settings.profile = {dungeons = {}, professions = "", phase = 6, season = 0, xprate = 1}
        a.settings.ReplaceColors = function(value) return value end
        a.error = error; a.ScheduleTask = function() end
        a.comms.PrettyDebug = error; a.comms.PrettyPrint = error
        a.GetItemName = function(id) return "Item " .. id end
        a.GetFactionInfoByID = function() return nil end
        a.GetGuideName = function(g) return g.name end
        a.currentGuide = nil
        a.RXPFrame.GenerateMenuTable = function() end
        e.RXPCData.guideMetaData = {enabledDungeons = {Horde = {}}, dungeonGuides = {},
            professionGuides = {Horde = {}}, enableGroupQuests = {}}
        e.RXPCData.guideProgress = {saved = {currentStep = 7, stepSkip = {[3] = true}}}
        f.load("DB/wotlk/dungeonData_335.lua")
        e.LibStub = function() return {DecompressDeflate = function(_, text) return text end} end
        f.load("Guide/Loader.lua")
        local function execute(code) return setfenv(assert(loadstring(code)), e)() end
        execute(slice("UI/GuideWindow.lua", "function addon.ProcessGuideTable(", "function addon:LoadGuideTable("))
        execute(slice("UI/GuideWindow.lua", "local function IsGuideActive(", "function RXPFrame:GenerateMenuTable("))
        execute(slice("Guide/QuestLog.lua", "local stepIndex = 0", "local function SetItemTooltip("))
        f.execute = execute
        return f, a, e
    end
    local function source(name, body, header)
        return "<< ac335 Horde\n#group Lazy Fixture\n#subgroup Branch\n#name " .. name ..
            "\n" .. (header or "") .. "step\n" .. body .. "\n"
    end
    if fixturesOnly then return new, source, slice end
    local first = source("1-6 First", ".accept 788 >> Cutting Teeth\n.collect 4865,1,788,1\n" ..
        ".target Mottled Boar\nstep << Mage\n.accept 789\nstep\n.dungeon WC\n.turnin 788\n" ..
        "step\n.deathskip\n.accept 790", "#next 6-10 Second\n#defaultfor Orc\n")
    local second = source("6-10 Second", ".accept 804\n.target Gornek\nstep\n.turnin 804\n.turnin 790")
    local daily = source("Daily", ".daily 24579\n.dailyturnin 24579")
    local f, a, e = new()
    local checkpoint = e.RXPCData.guideProgress.saved
    for _, text in ipairs({first, second, daily}) do a.RegisterGuide(text) end
    a.LoadEmbeddedGuides()
    local g = assert(a.GetGuideTable("Lazy Fixture", "01-06 First"))
    local nextGuide = assert(a.GetGuideTable("Lazy Fixture", "06-10 Second"))
    assert(not g.steps and not nextGuide.steps and g.guideId and g.key)
    assert(not g.hasDaily and a.GetGuideTable("Lazy Fixture", "Daily").hasDaily)
    assert(a.questItemList[4865] == 788 and a.dungeons.WC and e.RXPCData.guideMetaData.dungeonGuides["Lazy Fixture"])
    assert(#a.pickUpList[788] == 1 and not a.pickUpList[789] and #a.turnInList[788] == 1)
    assert(a.turnInList[788][1].step.dungeon == "WC", "later step flags missing in shared index")
    local v = a:GetGuideQuestView(g)
    assert(v.questIndex335 and #v.steps == 3 and not g.steps)
    assert(a:GetGuideQuestView(g) == v and #a.pickUpList[788] == 1, "inspection duplicates global registrations")
    for _, step in ipairs(v.steps) do
        for _, element in ipairs(step.elements) do assert(element.tag ~= "target") end
    end
    a.settings.profile.hardcore = true
    assert(#a.ProcessGuideTable(v).steps == 1, "dungeon/deathskip filtering changed")
    a.settings.profile.hardcore = false; a.settings.profile.dungeons.WC = true
    assert(#a.ProcessGuideTable(v).steps == 3)
    local fetched = assert(a:FetchGuide(v))
    assert(not fetched.questIndex335 and #fetched.steps[1].elements == 3)
    assert(a:FetchGuide(g) == fetched, "stale preview cannot refetch a loaded guide")
    assert(#a.pickUpList[788] == 1 and a.pickUpList[788][1].guide == g,
        "full parse duplicated or replaced the lightweight catalog registration")
    assert(e.RXPCData.guideProgress.saved == checkpoint and checkpoint.currentStep == 7 and checkpoint.stepSkip[3])
    -- Actual recursive quest reader: follow metadata next links without loading
    -- later chapter artwork/directives. The current guide uses its live indices.
    a.currentGuide = a.ProcessGuideTable(fetched)
    for i, step in ipairs(a.currentGuide.steps) do step.index = i end
    a.guideList["Lazy Fixture"].defaultGuide_ = fetched.name
    a.functions.next = function(_, guide)
        return guide.group, guide.next and guide.next:gsub("^(%d)-(%d%d?)", a.affix)
    end
    e.RXPCData.currentStep = 1; f.log[790] = true
    local expected, future = a.GetExpectedQuestLog()
    assert(not next(expected) and not next(future), "Pending route inspection exposed partial results")
    for _ = 1, 30 do f:tick() end
    expected, future = a.GetExpectedQuestLog()
    assert(expected[788] and future[790] == nextGuide.key)
    assert(not nextGuide.steps and not a.GetGuideTable("Lazy Fixture", "06-10 Second").steps,
        "quest-log route analysis loaded a future body")
    -- The daily planner must only fetch guides containing daily directives.
    f.load("Features/ActivityPlanner.lua")
    a.activityPlanner:BuildCatalog()
    assert(a.activityPlanner.dailyQuestLookup[24579])
    assert(not a.GetGuideTable("Lazy Fixture", "06-10 Second").steps)
    a.LoadAllGuides()
    for _, guide in pairs(a.guides) do assert(guide.steps, "explicit preload stopped working") end
    assert(a.currentGuide.key == fetched.key and e.RXPCData.currentStep == 1)
    assert(f:count("progress") == 0 and f:count("element") == 0, "indexing executed gameplay actions")

    -- Production startup on a subsequent login re-indexes the same source but
    -- never changes saved progress or trusts old fully parsed metadata.
    local f2, b, e2 = new()
    e2.RXPCData = e.RXPCData
    for _, text in ipairs({first, second, daily}) do b.RegisterGuide(text) end
    b.LoadEmbeddedGuides()
    assert(not b.GetGuideTable("Lazy Fixture", "01-06 First").steps)
    assert(e2.RXPCData.guideProgress.saved == checkpoint and b.questItemList[4865] == 788)
    -- Explicit includes and source database extensions retain the full path.
    local _, c = new()
    c.RegisterGuide(source("Included", "+Text", "#include Another\n"))
    c.LoadEmbeddedGuides()
    assert(c.GetGuideTable("Lazy Fixture", "Included").steps)

    -- Compact route traversal must terminate even when authored next links
    -- form a cycle. Removing a guide must release its inspection/index owners.
    local _, cyclic = new()
    cyclic.RegisterGuide(source("Cycle A", ".accept 788", "#next Cycle B\n"))
    cyclic.RegisterGuide(source("Cycle B", ".turnin 788", "#next Cycle A\n"))
    cyclic.LoadEmbeddedGuides()
    cyclic.functions.next = function(_, guide) return guide.group, guide.next end
    local cycleA = cyclic.GetGuideTable("Lazy Fixture", "Cycle A")
    local cycleB = cyclic.GetGuideTable("Lazy Fixture", "Cycle B")
    local result = cyclic.GetQuestLog(nil, nil,
        cyclic.ProcessGuideTable(cyclic:GetGuideQuestView(cycleA)), true)
    assert(not result[788] and not cycleA.steps and not cycleB.steps)
    cyclic.emptyGuide = {key = "empty"}
    assert(cyclic.RemoveGuide(cycleB.key))
    assert(not cyclic:GetGuideQuestView(cycleB) and not cyclic.guideCache[cycleB.key])
    assert(#cyclic.turnInList[788] == 0 and #cyclic.pickUpList[788] == 1)

    -- Registration owns farming counts; inspecting or compiling bodies must
    -- not increment the menu's count again.
    local _, farm = new()
    local farmSource = source("Farm", ".accept 788"):gsub("#group Lazy Fixture", "#group +Farm Fixture")
    farm.RegisterGuide(farmSource)
    farm.LoadEmbeddedGuides()
    assert(farm.farmGuides == 1)
    local farmGuide
    for _, candidate in pairs(farm.guides) do farmGuide = candidate end
    farm:GetGuideQuestView(farmGuide); farm:FetchGuide(farmGuide)
    assert(farm.farmGuides == 1)

    -- On-demand parsing happens while another guide is active. Its private
    -- quest conversions must not rewrite the incoming guide's authored IDs.
    local _, isolated = new()
    isolated.RegisterGuide(source("Isolated", ".accept 788"))
    isolated.LoadEmbeddedGuides()
    isolated.currentGuide = {key = "unrelated", questConversion = {[788] = 9000}}
    local isolatedGuide = isolated.GetGuideTable("Lazy Fixture", "Isolated")
    assert(isolated:GetGuideQuestView(isolatedGuide).steps[1].elements[1].questId == 788,
        "compact parse borrowed the active guide's quest conversion")
    assert(isolated:FetchGuide(isolatedGuide).steps[1].elements[1].questId == 788,
        "full parse borrowed the active guide's quest conversion")
    assert(isolated.GetQuestId(788) == 9000, "runtime conversion stopped using the active guide")
    local converted = isolated.ParseGuide(source("Converted", ".convertquest 788,9001\n.accept 788"))
    assert(converted.steps[1].elements[2].questId == 9001,
        "parse-time conversion ignored the incoming guide's own mapping")

    -- Imported metadata must still compile custom database extensions once.
    local _, imported, ie = new()
    local importSource = "--123\n" .. source("Imported", ".addtoquestdb 788,pre:4641\n.accept 788")
    local _, _, metadata = imported.ParseGuide(importSource)
    imported.QuestDB = {}
    ie.RXPData.release = imported.release
    imported.ReadCacheData = function() return "123" end
    imported.db.profile = {guides = {[metadata.key] = {groupOrContent = importSource, metadata = metadata}}}
    imported.LoadCachedGuides()
    assert(imported.GetGuideTable("Lazy Fixture", "Imported").steps and imported.QuestDB["Lazy Fixture"][788].pre == 4641)
    assert(ie.RXPCData.guideMetaData[metadata.key], "import parser discarded metadata")

    -- The main update loop cannot silently defeat demand loading while idle.
    local _, idle, idleEnv = new()
    idle.RegisterGuide(second); idle.LoadEmbeddedGuides()
    idle.currentGuide = nil
    idle.tickers.ShouldContinue = function() return true end
    idle.updateActiveQuest = {}
    idleEnv.GetFramerate = function() return 60 end
    idleEnv.L = function(text) return text end
    setfenv(assert(loadstring(slice("Core/Addon.lua", "local stepCounter = 1", "addon.tickers = {}"))), idleEnv)()
    for _ = 1, 100 do idle.LegacyUpdateLoop() end
    assert(not idle.GetGuideTable("Lazy Fixture", "06-10 Second").steps)
    idle.settings.profile.preLoadData = true
    for _ = 1, 3 do idle.LegacyUpdateLoop() end
    assert(idle.GetGuideTable("Lazy Fixture", "06-10 Second").steps)
    print("Lazy guide regressions passed: real handlers, shared indexes, cold/warm metadata, quest views, daily planner and explicit preload.")
end
