local root = assert(arg[1], "repository root argument is required")
root = root:gsub("\\", "/")

local failures = 0
local function check(value, message)
    if value then return end
    failures = failures + 1
    io.stderr:write("FAIL: " .. message .. "\n")
end

local function loadAddonFile(path, addon)
    local chunk, errorText = loadfile(root .. "/" .. path)
    check(chunk ~= nil, path .. " did not compile: " .. tostring(errorText))
    if not chunk then return end
    local ok, result = pcall(chunk, "RXPGuides", addon)
    check(ok, path .. " failed to load: " .. tostring(result))
end

local timers, tickers = {}, {}
local combat = false
local eventFrame
local function newHandle(callback)
    local handle = {callback = callback, cancelled = false}
    function handle:Cancel() self.cancelled = true end
    function handle:IsCancelled() return self.cancelled end
    return handle
end

_G.C_Timer = {
    NewTimer = function(_, callback)
        local handle = newHandle(callback)
        timers[#timers + 1] = handle
        return handle
    end,
    NewTicker = function(_, callback)
        local handle = newHandle(callback)
        tickers[#tickers + 1] = handle
        return handle
    end
}
_G.InCombatLockdown = function() return combat end
_G.CreateFrame = function()
    local frame = {events = {}}
    function frame:SetScript(_, callback) self.callback = callback end
    function frame:RegisterEvent(event) self.events[event] = true end
    function frame:UnregisterEvent(event) self.events[event] = nil end
    eventFrame = frame
    return frame
end
_G.geterrorhandler = function() return function() end end

local addon = {}

-- The XP Assistant shares these pure calculations and Blizzard-format
-- parsers with the tracker and communications modules.
_G.COMBATLOG_XPGAIN_EXHAUSTION1 =
    "%s dies, you gain %d experience. (%s exp %s bonus)"
_G.COMBATLOG_XPGAIN_EXHAUSTION2 = _G.COMBATLOG_XPGAIN_EXHAUSTION1
_G.COMBATLOG_XPGAIN_FIRSTPERSON = "%s dies, you gain %d experience."
_G.COMBATLOG_XPGAIN_FIRSTPERSON_GROUP =
    "%s dies, you gain %d experience. (+%d group bonus)"
_G.COMBATLOG_XPGAIN_FIRSTPERSON_RAID =
    "%s dies, you gain %d experience. (-%d raid penalty)"
_G.COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED = "You gain %d experience."
_G.COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED_GROUP =
    "You gain %d experience. (+%d group bonus)"
_G.COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED_RAID =
    "You gain %d experience. (-%d raid penalty)"
_G.COMBATLOG_XPGAIN_QUEST = "You gain %d experience."
loadAddonFile("Core/XP.lua", addon)

local fixtureChunk = assert(loadfile(
    root .. "/tests/fixtures/player_xp_for_level_335.lua"))
local levelXPFixture = fixtureChunk()
check(levelXPFixture[1] == 400 and levelXPFixture[10] == 7600 and
          levelXPFixture[60] == 290000 and
          levelXPFixture[70] == 1523800 and
          levelXPFixture[79] == 1670800,
      "AzerothCore player-XP offline fixture changed")
local progress = addon.xpFormula:GetProgress(79, 123400,
                                              levelXPFixture[79], 50000, 80)
check(progress.remaining == levelXPFixture[79] - 123400 and
          progress.rested == 50000 and not progress.atMax,
      "exact player XP remaining calculation changed")
local cappedProgress = addon.xpFormula:GetProgress(80, 0, 1, 0, 80)
check(cappedProgress.atMax and cappedProgress.remaining == 0,
      "max-level XP progress was not capped")

local expectedLevelTen = {67, 81, 95, 100, 105}
for offset = -2, 2 do
    check(addon.xpFormula:GetBaseMobXP(10, 10 + offset, "classic") ==
              expectedLevelTen[offset + 3],
          "level-10 Classic XP rounding changed at offset " .. offset)
end
local firstLevelRows = addon.xpFormula:GetYellowLevels(1)
check(#firstLevelRows == 3 and firstLevelRows[1] == 1 and
          firstLevelRows[3] == 3,
      "yellow-level rows did not clamp at the lower level boundary")
local zeroDifferenceBands = {
    [1] = 5, [7] = 5, [8] = 6, [9] = 6, [10] = 7, [11] = 7,
    [12] = 8, [15] = 8, [16] = 9, [19] = 9, [20] = 11,
    [29] = 11, [30] = 12, [39] = 12, [40] = 13, [44] = 13,
    [45] = 14, [49] = 14, [50] = 15, [54] = 15, [55] = 16,
    [59] = 16, [60] = 17, [80] = 17,
}
for level, expected in pairs(zeroDifferenceBands) do
    check(addon.xpFormula:GetZeroDifference(level) == expected,
          "zero-difference band changed at level " .. level)
end
check(addon.xpFormula:GetGrayLevel(10) == 4 and
          addon.xpFormula:GetGrayLevel(40) == 31 and
          addon.xpFormula:GetGrayLevel(60) == 51,
      "gray-level boundaries changed")
check(addon.xpFormula:GetBaseMobXP(60, 60, "classic") == 345 and
          addon.xpFormula:GetBaseMobXP(60, 60, "outland") == 535 and
          addon.xpFormula:GetBaseMobXP(70, 70, "outland") == 585 and
          addon.xpFormula:GetBaseMobXP(70, 70, "northrend") == 930,
      "expansion content constants changed")
local boundaryCurves = {
    {58, 335, 525, 870}, {59, 340, 530, 875},
    {60, 345, 535, 880}, {61, 350, 540, 885},
    {70, 395, 585, 930}, {71, 400, 590, 935},
}
for _, values in ipairs(boundaryCurves) do
    check(addon.xpFormula:GetBaseMobXP(values[1], values[1], "classic") ==
              values[2] and
          addon.xpFormula:GetBaseMobXP(values[1], values[1], "outland") ==
              values[3] and
          addon.xpFormula:GetBaseMobXP(values[1], values[1], "northrend") ==
              values[4],
          "content curve changed at boundary level " .. values[1])
end
check(addon.xpFormula:GetKillsRemaining(1000, 100, 0) == 10 and
          addon.xpFormula:GetKillsRemaining(1000, 100, 250) == 8,
      "finite rested-XP projection changed")
local learnedMultiplier, learnedCount, lowConfidence =
    addon.xpFormula:GetCalibration({1, 1, 1.02, 9}, 3)
check(math.abs(learnedMultiplier - 1.01) < 0.0001 and
          learnedCount == 4 and lowConfidence,
      "median calibration or outlier confidence changed")

local parsedXP = addon.ParseCombatXPMessage(
    "Wolf dies, you gain 1,234 experience.")
check(parsedXP and parsedXP.total == 1234 and parsedXP.named and
          parsedXP.exact,
      "localized-format XP parser lost digit separators or attribution")
local parsedRested = addon.ParseCombatXPMessage(
    "Wolf dies, you gain 190 experience. (95 exp Rested bonus)")
check(parsedRested and parsedRested.total == 190 and
          parsedRested.restedBonus == 95,
      "rested XP bonus was not separated from the total award")
local parsedQuest = addon.ParseCombatXPMessage("You gain 450 experience.")
check(parsedQuest and parsedQuest.total == 450 and not parsedQuest.named,
      "unnamed quest XP was attributed to a killed creature")

local localizedXPFixtures = {
    {"deDE", "%s stirbt. Ihr bekommt %d Erfahrung.",
        "Wolf stirbt. Ihr bekommt 1.234 Erfahrung.", "Wolf"},
    {"esES", "%s muere, recibes %d puntos de experiencia.",
        "Lobo muere, recibes 1.234 puntos de experiencia.", "Lobo"},
    {"frFR", "%s meurt, vous gagnez %d points d'expérience.",
        "Loup meurt, vous gagnez 1 234 points d'expérience.", "Loup"},
    {"ruRU", "%s погибает. Вы получаете %d опыта.",
        "Волк погибает. Вы получаете 1 234 опыта.", "Волк"},
    {"koKR", "%1$s|1이;가; 죽었습니다. %2$d의 경험치를 획득했습니다.",
        "늑대|1이;가; 죽었습니다. 1,234의 경험치를 획득했습니다.", "늑대"},
    {"zhCN", "%s死亡，你获得了%d点经验值。",
        "狼死亡，你获得了1,234点经验值。", "狼"},
    {"zhTW", "%s死亡，你獲得了%d點經驗值。",
        "狼死亡，你獲得了1,234點經驗值。", "狼"},
}
for _, fixture in ipairs(localizedXPFixtures) do
    _G.COMBATLOG_XPGAIN_FIRSTPERSON = fixture[2]
    addon.xpFormula:RefreshCombatXPFormats()
    local localized = addon.ParseCombatXPMessage(fixture[3])
    check(localized and localized.total == 1234 and
              localized.sourceName == fixture[4],
          fixture[1] .. " combat XP format was not parsed")
end

loadAddonFile("Core/Services.lua", addon)
loadAddonFile("Core/Scheduler.lua", addon)
loadAddonFile("Core/Storage.lua", addon)
loadAddonFile("Core/Runtime.lua", addon)
loadAddonFile("Core/Facade.lua", addon)
loadAddonFile("Guide/QuestAcceptState.lua", addon)

addon.functions = {events = {fixtureDirective = {"FIXTURE_EVENT"}}}
addon.functions.fixtureDirective = function() return "directive" end
loadAddonFile("Guide/ElementState.lua", addon)
loadAddonFile("Guide/AutomationOrder.lua", addon)
loadAddonFile("Guide/Prerequisites.lua", addon)
loadAddonFile("Guide/Directives/Registry.lua", addon)
addon.directives:RegisterDomain("fixture-domain", {"fixtureDirective"})

check(addon.directives:GetHandler("fixtureDirective")() == "directive" and
          addon.directives:GetDomain("fixtureDirective") == "fixture-domain",
      "directive registry did not retain its handler and domain")
check(addon.directives:GetEvents("fixtureDirective")[1] == "FIXTURE_EVENT",
      "directive registry did not adopt legacy event metadata")

local stateFixture = {step = {active = true}}
check(addon.elementState:Get(stateFixture) == "active",
      "legacy active element was not normalized")
stateFixture.completed = true
check(addon.elementState:Sync(stateFixture) == "complete",
      "legacy complete element was not normalized")
check(addon.elementState:Set(stateFixture, "blocked") and
          addon.elementState:Get(stateFixture) == "blocked",
      "explicit blocked element state was not retained")

local orderStep = {active = true, index = 7, elements = {}}
local firstAction = {step = orderStep, tag = "turnin"}
local secondAction = {step = orderStep, tag = "accept"}
local thirdAction = {step = orderStep, tag = "fly"}
orderStep.elements = {firstAction, secondAction, thirdAction}
check(addon.automationOrder:IsReady(firstAction) and
          not addon.automationOrder:IsReady(secondAction) and
          not addon.automationOrder:IsReady(thirdAction),
      "automation did not wait for preceding authored elements")
firstAction.completed = true
check(addon.automationOrder:IsReady(secondAction) and
          not addon.automationOrder:IsReady(thirdAction),
      "automation did not advance to the next authored element")
secondAction.completed = true
check(addon.automationOrder:IsReady(thirdAction),
      "travel automation remained blocked after quest confirmation")
local earlierStep = {active = true, index = 6, elements = {}}
local earlierAction = {step = earlierStep, tag = "accept"}
earlierStep.elements[1] = earlierAction
local selectedAction = addon.automationOrder:Select({
    {element = thirdAction, selector = 3},
    {element = earlierAction, selector = 1}
})
check(selectedAction and selectedAction.selector == 1,
      "automation candidate selection ignored guide order")

-- Quest-giver menus contain only interactions which are actually available at
-- the current NPC.  A navigation note before them must not suppress the first
-- authored quest, and the selection must stay pinned while the quest panel
-- opens so a later element cannot win an event-dispatch race.
local questStep = {active = true, index = 8, elements = {}}
local navigation = {step = questStep, tag = "goto"}
local wordFromSpire = {step = questStep, tag = "turnin", questId = 8890}
local abandonedInvestigations = {
    step = questStep,
    tag = "turnin",
    questId = 8891,
}
questStep.elements = {navigation, wordFromSpire, abandonedInvestigations}
local selectedQuest = addon.automationOrder:SelectQuest({
    {kind = "turnin", element = abandonedInvestigations, selector = 2},
    {kind = "turnin", element = wordFromSpire, selector = 1},
})
check(selectedQuest and selectedQuest.element == wordFromSpire and
          selectedQuest.selector == 1,
      "quest menu did not select the earliest authored turn-in")
addon.automationOrder:ReserveQuest(selectedQuest, 100)
check(addon.automationOrder:GetQuestReservation("turnin", 101) ==
          wordFromSpire and
          addon.automationOrder:IsQuestReady(wordFromSpire, "turnin", 101) and
          not addon.automationOrder:IsQuestReady(abandonedInvestigations,
                                                 "turnin", 101),
      "quest selection reservation did not prevent a same-NPC turn-in race")
check(addon.automationOrder:IsQuestReady(abandonedInvestigations,
                                        "turnin", 106) and
          not addon.automationOrder:GetQuestReservation("turnin", 106),
      "expired quest selection reservation blocked later interactions")
addon.automationOrder:ReserveQuest(selectedQuest, 107)
wordFromSpire.completed = true
local acceptWhileTurningIn = {
    step = questStep,
    tag = "accept",
    questId = 9001,
}
local submitted, submittedReservation =
    addon.automationOrder:MarkQuestSubmitted("turnin", 8890, 107.5)
check(addon.automationOrder:GetQuestReservation("turnin", 108) ==
          wordFromSpire and submitted and submittedReservation.submitted and
          not addon.automationOrder:IsQuestReady(acceptWhileTurningIn,
                                                  "accept", 108),
      "submitted turn-in reservation was lost or bypassed by an accept")
check(not addon.automationOrder:GetQuestConfirmation("turnin", 8891, 108) and
          addon.automationOrder:GetQuestConfirmation("turnin", 8890, 108) ==
              wordFromSpire,
      "quest confirmation was attributed to a different reserved quest")
local selectionWhilePending = addon.automationOrder:SelectQuest({
    {kind = "turnin", element = abandonedInvestigations, selector = 1},
})
check(not selectionWhilePending and
          addon.automationOrder:ReserveQuest({
              kind = "turnin",
              element = abandonedInvestigations,
          }, 108) == false and
          addon.automationOrder:GetQuestReservation("turnin", 108) ==
              wordFromSpire,
      "refreshed gossip replaced an in-flight quest reservation")
addon.automationOrder:ClearQuestReservation()
check(addon.automationOrder:SelectQuest({
          {kind = "turnin", element = abandonedInvestigations, selector = 1},
      }).element == abandonedInvestigations,
      "next same-NPC quest did not unlock after confirmation")

-- Follow-up accepts from the immediately following step are registered before
-- the delayed 3.3.5 quest-log update advances the visible guide.
local savedCurrentGuide = addon.currentGuide
local acceptStep = {index = 9, elements = {}}
local followupAccept = {step = acceptStep, tag = "accept", questId = 9000}
acceptStep.elements[1] = followupAccept
addon.currentGuide = {steps = {[8] = questStep, [9] = acceptStep}}
local selectedFollowup = addon.automationOrder:SelectQuest({
    {kind = "accept", element = followupAccept, selector = 1},
})
check(selectedFollowup and
          addon.automationOrder:IsQuestReady(followupAccept, "accept", 110),
      "immediate next-step quest accept was not eligible")
addon.currentGuide = savedCurrentGuide

local laterTurnIn = {questId = "42"}
addon.questTurnIn = {NamedQuest = laterTurnIn}
check(addon.prerequisites:IsTurnedInLater(42),
      "name-keyed quest turn-in was not recognized")

addon.guides = {}
addon.RegisterGuide = function(value) return "registered:" .. value end
addon.AddGuide = function(value) addon.guides[value.key] = value return true end
addon.RemoveGuide = function(key) addon.guides[key] = nil return true end
_G.RXPGuides = {}
loadAddonFile("Guide/Registry.lua", addon)
check(addon.RegisterGuide("fixture") == "registered:fixture",
      "guide registry did not preserve registration behavior")

addon.ParseGuide = function(value) return "guide:" .. value end
addon.ParseLine = function(value) return "line:" .. value end
addon.applies = function(value) return value == "yes" end
loadAddonFile("Guide/Parser.lua", addon)
check(addon.guideParser:ParseGuide("fixture") == "guide:fixture" and
          addon.guideParser:Applies("yes"),
      "guide parser facade changed legacy behavior")

addon.stepLogic = {fixture = function() return true end}
addon.IsStepShown = function() return true end
loadAddonFile("Guide/Conditions.lua", addon)
check(addon.guideConditions:IsStepShown({}) and
          addon.guideConditions:List()[1] == "fixture",
      "guide condition service did not preserve predicates")

loadAddonFile("Guide/State.lua", addon)
local position, restored = addon.guideState:ResolvePosition({steps = {
    {stepId = 10}, {stepId = 20}
}}, "20", 1)
check(position == 2 and restored,
      "stable step ID did not take priority during restoration")

addon.GetQuestName = function(id) return "Quest " .. id end
addon.GetQuestObjectives = function(id) return {{questId = id}} end
loadAddonFile("Guide/QuestCache.lua", addon)
check(addon.questCache:GetName(42) == "Quest 42" and
          addon.questCache:GetObjectives(42)[1].questId == 42,
      "quest cache facade changed legacy lookup behavior")

local pendingElement = {questId = 42}
addon.questAcceptState:Begin(42, "Fixture Quest", pendingElement, 10)
addon.questAcceptState:MarkTurnIn(10)
addon.QuestAutoAccept = function(id) return id == 42 end
_G.GetTime = function() return 11 end
loadAddonFile("Guide/QuestAutomation.lua", addon)
check(addon.questAutomation:IsAcceptEligible(42) and
          addon.questAutomation:GetPendingAccept().questId == 42,
      "quest automation facade lost eligibility or pending state")
local committedAccept = addon.questAcceptState:Commit(42, 11, 5)
check(committedAccept.element == pendingElement and
          not committedAccept.alreadyCommitted and
          not addon.questAcceptState:GetPending(11, 5),
      "confirmed quest acceptance did not reconcile its pending element")
local duplicateAccept = addon.questAcceptState:Commit(42, 12, 5)
check(duplicateAccept.alreadyCommitted,
      "duplicate quest acceptance was not suppressed")
addon.questAcceptState:Begin(nil, "Delayed Quest", pendingElement, 20)
local delayedAccept = addon.questAcceptState:Commit(43, 21, 5)
check(delayedAccept.element == pendingElement and delayedAccept.questId == 43,
      "quest acceptance without an initial log index was not reconciled")
addon.questAcceptState:Begin(44, "Expired Quest", pendingElement, 20)
check(not addon.questAcceptState:GetPending(26, 5),
      "expired pending quest acceptance was retained")
check(addon.questAcceptState:WasRecentTurnIn(10.4, 0.5),
      "same-NPC turn-in window was lost")
addon.automationOrder:ReserveQuest({
    kind = "turnin",
    element = abandonedInvestigations,
}, 10)
addon.questAutomation:ResetTransient()
check(not addon.questAutomation:GetPendingAccept() and
          addon.questAutomation.state.turnInTimer == 0 and
          not addon.automationOrder:GetQuestReservation(nil, 10),
      "quest automation transient state did not reset")

local service = {}
check(addon.services:Register("fixture", service) == service,
      "service registration did not return the instance")
check(addon.services:Require("fixture") == service,
      "required service was not returned")
check(not pcall(function() addon.services:Register("fixture", {}) end),
      "duplicate services were accepted")

local owner, calls = {}, 0
local first = addon.scheduler:After(owner, "refresh", 1, function()
    calls = calls + 1
end)
local second = addon.scheduler:After(owner, "refresh", 1, function()
    calls = calls + 1
end)
check(first.cancelled, "replaced timer was not cancelled")
check(addon.scheduler:Has(owner, "refresh"), "active timer was not indexed")
second.callback(second)
check(calls == 1 and not addon.scheduler:Has(owner, "refresh"),
      "one-shot timer did not clear itself")

combat = true
addon.scheduler:AfterCombat(owner, "secure", function() calls = calls + 1 end)
check(addon.scheduler:Has(owner, "secure"), "combat callback was not queued")
combat = false
eventFrame.callback(eventFrame, "PLAYER_REGEN_ENABLED")
local combatTimer = timers[#timers]
combatTimer.callback(combatTimer)
check(calls == 2 and not addon.scheduler:Has(owner, "secure"),
      "combat callback did not flush once")

addon.scheduler:Ticker(owner, "scan", 1, function() end)
addon.scheduler:After(owner, "refresh-all", 1, function() end)
addon.scheduler:CancelOwner(owner)
check(not addon.scheduler:Has(owner, "scan") and
          not addon.scheduler:Has(owner, "refresh-all"),
      "owner cancellation left scheduled work behind")

local account = {preserved = true}
local character = {step = 12}
local profile = {enabled = true}
addon.storage:Bind(account, character, profile)
local migrated, migrationError = addon.storage:Migrate()
check(migrated, "storage migration failed: " .. tostring(migrationError))
check(account.runtimeSchemaVersion == 1 and account.preserved,
      "storage migration changed existing account data")
check(addon.storage:Character().step == 12 and addon.storage:Profile().enabled,
      "storage accessors returned the wrong tables")
check(addon.storage:Migrate(), "storage migration was not idempotent")

local sequence = {}
addon.runtime:Register({id = "fixture-a", initialize = function()
    sequence[#sequence + 1] = "a"
end})
addon.runtime:Register({id = "fixture-b", depends = {"fixture-a"},
    initialize = function() sequence[#sequence + 1] = "b" end})
addon.runtime:InitializePhase("initialize")
check(table.concat(sequence, "") == "ab", "subsystem order was not deterministic")
check(addon.runtime:GetState("fixture-b").status == "initialized",
      "subsystem state was not committed")

addon.runtime:Register({id = "cycle-a", phase = "cycle", depends = {"cycle-b"}})
addon.runtime:Register({id = "cycle-b", phase = "cycle", depends = {"cycle-a"}})
check(not pcall(function() addon.runtime:InitializePhase("cycle") end),
      "subsystem dependency cycle was not rejected")
addon.runtime:Register({id = "missing-dependency", phase = "missing",
    depends = {"not-registered"}})
check(not pcall(function() addon.runtime:InitializePhase("missing") end),
      "missing subsystem dependency was not rejected")
check(not pcall(function()
    addon.runtime:Register({id = "fixture-a"})
end), "duplicate subsystem registration was accepted")

local facadeValue = {}
addon.facade:ExposeAddon("fixtureFacade", facadeValue)
check(addon.fixtureFacade == facadeValue and
          addon.facade:IsAddonExport("fixtureFacade"),
      "addon compatibility facade did not expose its value")

-- Guide localization must remain presentation-only while preserving named
-- tokens, status precedence, official names, and changing live counters.
_G.GetLocale = function() return "zhCN" end
addon.locale = {}
addon.settings = {profile = {guideLanguage = "localized"}}
function addon:SendMessage() end
loadAddonFile("Guide/Localization.lua", addon)
addon.guideLocalization:RegisterCatalog("zhCN", {
    ui = {
        ["This instruction has not yet been reviewed in your language."] =
            "fallback explanation",
        ["This text was machine translated and has not yet been reviewed."] =
            "machine explanation",
    },
    actions = {
        {pattern = "^Accept%s+(.+)$", template = "接受 {value}"},
        {pattern = "^Collect%s+(.+)$", template = "收集 {value}"},
    },
    translations = {reviewed = {}, machine = {}, contextualReviewed = {},
        contextualMachine = {}, uiReviewed = {}, uiMachine = {}},
})
local machineSource = "|cRXP_WARN_Use %d potions|r"
local machineMessage = addon.guideLocalization:Tokenize(machineSource)
machineMessage = machineMessage:gsub("Use ", "使用 ")
addon.guideLocalization:RegisterTranslationPack("zhCN", {
    schema = 1,
    revision = "test-pack",
    source = "unit test",
    machine = {
        [machineSource] = {
            text = machineMessage,
            status = "machine",
            tokenized = true,
            sourceSignature = addon.guideLocalization.HashSource(machineSource),
        },
    },
    uiMachine = {
        ["Compact label"] = {
            text = "紧凑标签", status = "machine",
            sourceSignature = addon.guideLocalization.HashSource("Compact label"),
        },
    },
})
local machineOutput, machineMetadata =
    addon.guideLocalization:Render(machineSource)
check(machineMetadata.machine and machineOutput:find("%%d") and
          machineOutput:find("[MT]", 1, true),
      "machine guide text lost its format token or status badge")
local semanticOutput, semanticMetadata =
    addon.guideLocalization:Render("Accept Quest Name")
check(semanticOutput == "接受 Quest Name" and semanticMetadata.reviewed,
      "reviewed semantic grammar did not outrank machine entries")
local questElement = {tag = "accept", sourceAuthored = true,
    sourceText = "Accept Quest Name", title = "本地任务"}
local questOutput = addon.guideLocalization:Render(
    "Accept Quest Name", questElement)
check(questOutput == "接受 本地任务",
      "official quest name was inserted before canonical translation")
local collectElement = {tag = "collect", sourceAuthored = true,
    sourceText = "Collect Relic"}
local collectOutput = addon.guideLocalization:Render(
    "Collect Relic\n2/5", collectElement)
check(collectOutput == "收集 Relic\n2/5",
      "live objective progress was frozen into the translation lookup")
addon.guideLocalization:IndexEnglishGuideSource(
    ".complete 834,1 --Sack of Supplies (5)")
local uiOutput, uiMetadata =
    addon.guideLocalization:UIWithMetadata("Compact label")
check(uiOutput == "紧凑标签" and uiMetadata.machine,
      "UI translation metadata was not retained")
addon.guideLocalization:SetMode("english")
local englishOutput = addon.guideLocalization:Render(machineSource)
check(englishOutput == machineSource and
          not englishOutput:find("[MT]", 1, true),
      "Original English mode retained a translation status badge")

local englishObjective = addon.guideLocalization:Render(
    "Localized objective: 2/5", {
        tag = "complete", questId = 834, obj = 1,
        sourceAuthored = false,
    })
check(englishObjective == "Sack of Supplies\n2/5",
      "Original English mode discarded the indexed objective name")

-- English clients must retain the exact live quest-log objective instead of
-- replacing it with a synthetic "Complete objective N" sentence.
_G.GetLocale = function() return "enUS" end
addon.locale = {}
addon.settings = {profile = {guideLanguage = "localized"}}
loadAddonFile("Guide/Localization.lua", addon)
local liveEnglishObjective = "Sack of Supplies: 2/5"
local preservedObjective = addon.guideLocalization:Render(
    liveEnglishObjective, {
        tag = "complete", questId = 834, obj = 1,
        sourceAuthored = false,
    })
check(preservedObjective == liveEnglishObjective,
      "English client objective text was replaced with generated prose")

-- Every supported non-English locale shares the same safe objective path:
-- localized mode keeps the client's authoritative text, while Original
-- English uses the pre-parser objective catalog and retains the live count.
for _, localeCode in ipairs({
    "deDE", "esES", "frFR", "koKR", "ruRU", "zhCN", "zhTW",
}) do
    _G.GetLocale = function() return localeCode end
    addon.locale = {}
    addon.settings = {profile = {guideLanguage = "localized"}}
    loadAddonFile("Guide/Localization.lua", addon)
    addon.guideLocalization:IndexEnglishGuideSource(
        ".complete 834,1 --Sack of Supplies (5)")
    local objective = {
        tag = "complete", questId = 834, obj = 1,
        sourceAuthored = false,
    }
    local localizedObjective = "Localized " .. localeCode .. ": 2/5"
    local localizedOutput, localizedMeta = addon.guideLocalization:Render(
        localizedObjective, objective)
    check(localizedOutput == localizedObjective and localizedMeta.official,
          localeCode .. " client objective text was replaced")
    addon.guideLocalization:SetMode("english")
    local originalEnglish = addon.guideLocalization:Render(
        localizedObjective, objective)
    check(originalEnglish == "Sack of Supplies\n2/5",
          localeCode .. " Original English objective was generated incorrectly")
end

if failures > 0 then os.exit(1) end
print("Core Lua 5.1 tests passed.")
