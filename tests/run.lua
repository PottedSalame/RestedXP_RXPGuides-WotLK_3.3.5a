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
loadAddonFile("Core/Services.lua", addon)
loadAddonFile("Core/Scheduler.lua", addon)
loadAddonFile("Core/Storage.lua", addon)
loadAddonFile("Core/Runtime.lua", addon)
loadAddonFile("Core/Facade.lua", addon)
loadAddonFile("Guide/QuestAcceptState.lua", addon)

addon.functions = {events = {fixtureDirective = {"FIXTURE_EVENT"}}}
addon.functions.fixtureDirective = function() return "directive" end
loadAddonFile("Guide/ElementState.lua", addon)
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
addon.questAutomation:ResetTransient()
check(not addon.questAutomation:GetPendingAccept() and
          addon.questAutomation.state.turnInTimer == 0,
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

if failures > 0 then os.exit(1) end
print("Core Lua 5.1 tests passed.")
