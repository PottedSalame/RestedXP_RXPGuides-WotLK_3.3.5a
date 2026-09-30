-- Run with tests/run.lua. Fixtures execute production handlers, not replicas.
return function(root)
    local factory = assert(loadfile(root .. "/tests/quest-automation-audit.lua"))
    setfenv(factory, setmetatable({arg = {root, "--fixtures"}}, {__index = _G}))
    local fixture = factory()
    local function noop() end
    local function read(path)
        local f = assert(io.open(root .. "/" .. path, "rb"))
        local text = f:read("*a"); f:close()
        return text:gsub("\r\n", "\n")
    end
    local function setup()
        local s = fixture()
        s.env.GetNumQuestLogEntries = function() return not s.hidden and s.log[788] and 1 or 0 end
        s.env.ExpandQuestHeader = noop
        s.env.RXPCompatGetQuestLogTitle = function()
            return "Cutting Teeth", 4, nil, false, false, s.rowComplete, nil, 788
        end
        s.env.GetNumQuestLeaderBoards = function() return s.delayed and 0 or 1 end
        s.env.GetQuestLogLeaderBoard = function()
            return "Mottled Boar slain: " .. (s.kills or 0) .. "/10", "monster", s.kills == 10
        end
        s.env.GetInventoryItemID = noop
        s.env.INVSLOT_LAST_EQUIPPED = 19
        s:loadDirectives()
        s.env.GetItemCount = function() return s.items or 0 end
        s.env.bit.rshift = function(n, bits) return math.floor(n / 2^bits) end
        s.load("Guide/Directives/Handlers.lua") -- retain REAL completion helpers
        s.load("Guide/State.lua")
        local a = s.addon
        a.lastStepUpdate = s.now
        a.questCompleteItems = {}
        a.UpdateStepText, a.QueueMessage = noop, noop
        a.GetQuestName = function() return "Cutting Teeth" end
        a.comms.AnnounceStepEvent = noop
        a.GetItemName = function() return "Fixture item" end
        s.env.RXPCData.questObjectivesCache = {[0] = 0}
        s.env.RXPCData.stepSkip, s.env.RXPCData.completedWaypoints = {}, {}
        return s, a
    end
    local function objective(s, max)
        local e = s:element("complete", 788, "Cutting Teeth")
        e.flags, e.obj, e.objMax = 0, 1, max
        return e, {element = e, step = s.step}
    end
    do
        local s, a = setup()
        local e, frame = objective(s)
        local cached = {{text = "Mottled Boar slain: 10/10", type = "monster",
            numRequired = 10, numFulfilled = 10, finished = true}}
        s.env.RXPCData.questObjectivesCache[788] = cached
        a.UpdateQuestCompletionData(frame)
        assert(not e.completed and not e.skip, "cached absent quest completed")
        assert(cached[1].numFulfilled == 10, "display sanitation mutated cache")
        s.log[788], s.kills = true, 0
        s.done[788] = true -- deliberately stale ready-to-turn-in cache
        a.UpdateQuestCompletionData(frame)
        assert(not e.completed and e.text:find("0/10", 1, true), "reaccepted quest retained old progress")
        s.kills = 10
        a.UpdateQuestCompletionData(frame)
        assert(e.completed, "live complete objective failed")
        s.kills = 4
        a.UpdateQuestCompletionData(frame)
        assert(not e.completed and not e.skip, "live objective regression did not revoke completion")
        s.turnedIn = {[788] = true}; s.log[788] = nil
        a.UpdateQuestCompletionData(frame)
        assert(e.completed, "confirmed turn-in should satisfy objective")
    end
    do
        local s, a = setup()
        s.log[788], s.kills = true, 4
        local first, f1 = objective(s, 4)
        local second, f2 = objective(s, 8)
        a.UpdateQuestCompletionData(f1)
        local cached = s.env.RXPCData.questObjectivesCache[788]
        assert(first.completed and cached[1].numRequired == 10, "partial threshold mutated shared requirement")
        a.UpdateQuestCompletionData(f2)
        assert(not second.completed, "4 kills satisfied a target of 8")
        s.kills = 8
        a.UpdateQuestCompletionData(f2)
        assert(second.completed, "partial target did not update live")
        s.hidden = true
        a.UpdateQuestCompletionData(f2)
        assert(not second.completed, "hidden/missing live objective trusted cached progress")
    end
    do
        local s, a = setup()
        local e = s:element("accept", 788, "Cutting Teeth"); e.flags = 0
        local frame = {element = e, step = s.step}
        s.log[788] = true
        a.functions.accept(frame, "QUEST_LOG_UPDATE")
        assert(e.completed and e.autoSkip)
        s.log[788] = nil
        a.GetQuestLogPresence335 = function() return nil end
        a.functions.accept(frame, "QUEST_LOG_UPDATE")
        assert(e.completed, "unknown presence revoked acceptance")
        a.GetQuestLogPresence335 = function() return false end
        a.recentAccept[788] = s.now
        a.functions.accept(frame, "QUEST_LOG_UPDATE")
        assert(e.completed, "acceptance grace was lost")
        s.now = s.now + 6
        a.functions.accept(frame, "QUEST_LOG_UPDATE")
        assert(not e.completed and not e.skip, "abandoned acceptance stayed complete")
        e.manualSkip, e.skip = true, true
        a.functions.accept(frame, "QUEST_LOG_UPDATE")
        assert(e.skip and e.manualSkip, "manual skip was lost")
        s.turnedIn = {[788] = true}
        a.functions.accept(frame, "QUEST_LOG_UPDATE")
        assert(e.completed, "turn-in history was ignored")
    end
    do
        local s, a = setup()
        s.env.RXPCData.questObjectivesCache[788] = {{text = "Item: 10/10",
            type = "item", numRequired = 10, numFulfilled = 10, finished = true}}
        local e = a.functions.collect(".collect", "", "159", "10", "788", "1", "2")
        e.tag, e.step = "collect", s.step
        local frame = {element = e, step = s.step}
        a.functions.collect(frame)
        assert(not e.completed, "cached objective subtraction completed collection")
        s.items = 10
        a.functions.collect(frame)
        assert(e.completed, "real inventory did not complete collection")
        s.items = 0
        a.functions.collect(frame)
        assert(not e.completed and not e.skip, "item loss did not revoke collection")
        s.log[788], s.kills = true, 10
        a.functions.collect(frame)
        assert(e.completed and e.textOnly, "live subtraction failed")
        s.kills = 0
        a.functions.collect(frame)
        assert(not e.completed and not e.textOnly, "zero-quantity presentation survived objective reset")
    end
    do
        local s, a = setup()
        local gate = {questIds = {788}, step = s.step}
        a.GetQuestLogPresence335 = function() return nil end
        a.functions.isOnQuest({element = gate}, "QUEST_LOG_UPDATE")
        assert(not s.step.completed, "unknown log caused explicit gate skip")
        a.GetQuestLogPresence335 = function() return false end
        a.functions.isOnQuest({element = gate}, "QUEST_LOG_UPDATE")
        assert(s.step.completed, "explicit absent-quest gate stopped working")
        s.step.completed = nil
        local e, frame = objective(s)
        e.skipIfMissing = true
        a.functions.complete(frame)
        assert(e.completed, "optional missing quest stopped completing")
        a.SetElementIncomplete(frame)
        a.GetQuestLogPresence335 = function() return nil end
        a.functions.complete(frame)
        assert(not e.completed, "optional quest confused unknown with absent")
    end
    do
        local s, a = setup()
        local source = read("UI/GuideWindow.lua")
        local body = assert(source:match("function addon%.UpdateStepCompletion%(%)\n.-\nend"))
        a.currentGuide.labels = {}
        a.ScheduleTask = noop
        a.SetStep = noop -- sticky layout rebuild is a presentation sink here
        local notices = 0
        a.lastStepUpdate = 0
        a.QueueMessage = function(_, event)
            if event == "RXP_STEP_COMPLETE" then notices = notices + 1 end
        end
        a.RXPFrame.BottomFrame = {UpdateFrame = noop}
        local chunk = assert(loadstring("local addon,activeSteps,RXPFrame=...\nlocal CheckStepCompletion\n" .. body))
        setfenv(chunk, s.env); chunk(a, {s.step}, a.RXPFrame)
        local e = s:element("collect", 159, "Required item")
        a.SetElementComplete({element = e})
        a.UpdateStepCompletion()
        assert(a.loadNextStep and a.guideState.pendingAdvance.step == s.step)
        a.SetElementIncomplete({element = e})
        assert(not a.loadNextStep and not s.step.completed, "item loss retained queued advancement")
        a.UpdateStepCompletion()
        assert(not a.loadNextStep)
        e.manualSkip, e.skip = true, true
        a.UpdateStepCompletion()
        assert(a.guideState:ConsumeAdvance(), "manual skip no longer advances")
        assert(notices == 1, "cancel/re-evaluation duplicated the completion notification")
        s.step.completed, s.step.completionFromElements = true, nil
        e.skip, e.completed = nil, nil
        a.guideState:QueueAdvance(s.step)
        assert(a.guideState:ConsumeAdvance(), "explicit guide gate no longer advances")
        a.guideState:QueueAdvance(s.step)
        a.currentGuide = {steps = {s.step}}
        assert(not a.guideState:ConsumeAdvance(), "stale guide request advanced")
        a.currentGuide.steps[1] = {}
        a.guideState:QueueAdvance(s.step)
        assert(not a.guideState:ConsumeAdvance(), "stale step request advanced")
        a.currentGuide.steps[1] = s.step
        s.step.completed, s.step.sticky, s.step.completewith = nil, true, "destination"
        a.currentGuide.labels = {destination = 2}
        s.env.RXPCData.currentStep = 3
        a.UpdateStepCompletion()
        assert(s.env.RXPCData.stepSkip[1], "authored completewith expiry changed")
    end
    do
        local s, a = setup()
        -- Execute the real update-loop dispatch through the advance branch.
        -- Remaining layout/map work is unrelated to this ordering assertion.
        local body = assert(read("Core/Addon.lua"):match(
            "(    if not holdForReward then\n.-)    elseif activeQuestUpdate == 0 then"))
        local chunk = assert(loadstring("local addon,holdForReward=...\nlocal event,skip,activeQuestUpdate='',0,0\n" .. body .. "\nend"))
        setfenv(chunk, s.env)
        local moved = 0
        a.Call = function(_, callback, frame) callback(frame) end
        a.SetStep = function() moved = moved + 1 end
        local e = s:element("collect", 159, "Required item")
        a.SetElementComplete({element = e})
        s.step.completed, s.step.completionFromElements = true, true
        a.guideState:QueueAdvance(s.step)
        a.updateActiveQuest = {[{}] = function() a.SetElementIncomplete({element = e}) end}
        chunk(a, false)
        assert(moved == 0 and not a.loadNextStep, "queued refresh was processed after advancement")
        a.SetElementComplete({element = e})
        a.guideState:QueueAdvance(s.step)
        chunk(a, true)
        assert(moved == 0 and a.loadNextStep, "reward barrier did not hold advancement")
        a.partySync = {ShouldHoldAdvance = function() return true end}
        chunk(a, false)
        assert(moved == 0 and a.loadNextStep, "party hold was bypassed")
        a.partySync = nil
        a.browseMode = true
        chunk(a, false)
        assert(moved == 0, "browse mode advanced")
        a.browseMode = false
        a.guideState:QueueAdvance(s.step)
        chunk(a, false)
        assert(moved == 1, "eligible step failed to advance")
        e.completed, e.skip = nil, nil
        a.guideState:QueueAdvance(s.step, true)
        chunk(a, false)
        assert(moved == 2, "explicit party override was lost")
        s.step.waitForHearth = true
        e.tag, e.hearthPending = "hs", true
        s.step.completed, s.step.completionFromElements = nil, nil
        a.guideState:QueueAdvance(s.step)
        assert(not a.guideState:ConsumeAdvance(), "pending hearth allowed advancement")
    end
    do
        local s, a = setup()
        s.env.time = function() return 100 end
        s.load("Features/Roadmap.lua")
        local function step(id)
            return {stepId = id, progressIdentity = "source|" .. id, elements = {}}
        end
        local guide = {key = "audit||checkpoint", group = "Audit", name = "Audit",
            steps = {step("A"), step("B"), step("C"), step("D")}}
        local waypoint = {wpHash = 123, zone = 1, x = 0.2, y = 0.3}
        guide.steps[3].elements = {waypoint}
        a.currentGuide = guide
        s.env.RXPCData.currentStep = 4
        s.env.RXPCData.stepSkip = {[2] = true}
        s.env.RXPCData.completedWaypoints = {[3] = {[123] = true}}
        s.env.RXPCData.guideProgress = {}
        a.guideState:SaveCurrent()
        local saved = s.env.RXPCData.guideProgress[guide.key]
        assert(a.guideState:ValidateFlags(saved.progress))
        local updated = {key = guide.key, steps = {step("A"), step("NEW"), step("B"), step("C"), step("D")}}
        local pin = {wpHash = 456, zone = 1, x = 0.2, y = 0.3}
        updated.steps[4].elements, updated.steps[4].index, updated.steps[4].active = {pin}, 4, true
        a.guideState:RestoreFlags(updated, saved)
        assert(not s.env.RXPCData.stepSkip[2] and s.env.RXPCData.stepSkip[3], "skip did not follow identity")
        assert(not s.env.RXPCData.completedWaypoints[4], "waypoint applied before hash verification")
        a.guideState:RestoreWaypoint(updated.steps[4], pin)
        assert(s.env.RXPCData.completedWaypoints[4][456], "waypoint did not follow verified pin")
        assert(not s.env.RXPCData.completedWaypoints[3], "waypoint attached to old numeric position")
        a.guideState:RestoreFlags(updated, saved)
        pin.x = 0.9
        a.guideState:RestoreWaypoint(updated.steps[4], pin)
        assert(not s.env.RXPCData.completedWaypoints[4], "changed waypoint geometry reused a completion")
        pin.x = 0.2
        updated.steps[3].progressIdentity = "new source|B"
        a.guideState:RestoreFlags(updated, saved)
        assert(not next(s.env.RXPCData.stepSkip), "changed source reused line-derived ID")
        updated.steps[3].progressIdentity = guide.steps[2].progressIdentity
        updated.steps[2].progressIdentity = updated.steps[3].progressIdentity
        a.guideState:RestoreFlags(updated, saved)
        assert(not next(s.env.RXPCData.stepSkip), "ambiguous identity was applied")
        local legacy = {stepSkip = {[2] = true}, completedWaypoints = {[3] = {[123] = true}}}
        a.guideState:RestoreFlags(guide, legacy)
        assert(not next(s.env.RXPCData.stepSkip) and not next(s.env.RXPCData.completedWaypoints))
        assert(legacy.progress.recovery.stepSkip[2], "old flags were not retained")
        local recovery = legacy.progress.recovery
        a.guideState:RestoreFlags(guide, legacy)
        assert(legacy.progress.recovery == recovery, "migration overwrote recovery")
        assert(not a.guideState:ValidateFlags({version = 1, skipped = {bad = "yes"}, waypoints = {}}))
        assert(a.guideState:ValidateFlags(legacy.progress))
        local retained = a.guideState:CaptureFlags(updated, saved.progress)
        assert(retained.skipped[guide.steps[2].progressIdentity], "ambiguous identity was lost on save")
        -- A second character must never inherit pending flags from reused steps.
        a.guideState:RestoreFlags(updated, nil)
        assert(not next(s.env.RXPCData.stepSkip) and not updated.steps[4].pendingCheckpointWaypoints)
        local huge = {version = 1, skipped = {}, waypoints = {}}
        for i = 1, 2049 do huge.skipped["id" .. i] = true end
        assert(not a.guideState:ValidateFlags(huge), "unbounded progress accepted")

        -- Real bundled serialization/compression and production import paths.
        local libenv = setmetatable({LibStub = false}, {__index = _G})
        libenv._G = libenv
        for _, path in ipairs({"libs/LibStub/LibStub.lua",
            "libs/Legacy335/AceSerializer-3.0/AceSerializer-3.0.lua",
            "libs/LibDeflate/LibDeflate.lua"}) do
            local chunk = assert(loadstring(read(path), "@" .. path))
            setfenv(chunk, libenv); chunk()
        end
        s.env.LibStub = libenv.LibStub
        s.env.RXPData.guideHub = {favorites = {}}
        s.env.RXPCData.recentGuides = {}
        a.currentGuide = guide
        a.RestoreCharacterGuideProgress = noop
        s.env.RXPCData.guideProgress[guide.key] = saved
        a.guideState:RestoreFlags(guide, saved)
        local encoded = a.roadmap:BuildBackup()
        local decoded, why = a.roadmap:DecodeBackup(encoded)
        assert(decoded, why)
        local backupProgress = decoded.character.guideProgress[guide.key].progress
        assert(a.guideState:ValidateFlags(backupProgress), "progress failed backup round trip")
        s.env.RXPCData.guideProgress.other = {group = "Other", name = "Other"}
        s.env.RXPCData.guideProgress[guide.key].obsolete = true
        assert(a.roadmap:ApplyBackup(decoded, false))
        assert(s.env.RXPCData.guideProgress.other, "merge removed another guide")
        assert(not s.env.RXPCData.guideProgress[guide.key].obsolete, "merge mixed checkpoint layouts")
        assert(a.roadmap:ApplyBackup(decoded, true))
        assert(not s.env.RXPCData.guideProgress.other, "replace retained unrelated checkpoint")
        backupProgress.version = 999
        local before = s.env.RXPCData.guideProgress
        assert(not a.roadmap:ApplyBackup(decoded, false), "invalid progress was imported")
        assert(s.env.RXPCData.guideProgress == before, "invalid import mutated state")
        a.guideState:RestoreFlags(guide, {progress = false, stepSkip = "corrupt"})
        assert(not next(s.env.RXPCData.stepSkip), "corrupt legacy checkpoint applied")
        s.env.RXPCData.stepSkip, s.env.RXPCData.completedWaypoints = "corrupt", false
        assert(a.guideState:ValidateFlags(a.guideState:CaptureFlags(guide, false)))
        s.env.RXPCData.stepSkip, s.env.RXPCData.completedWaypoints = {}, {}
        local reads = 0
        local large = {steps = {}}
        for i = 1, 4000 do
            local id = "large|" .. i
            large.steps[i] = setmetatable({elements = {}}, {__index = function(_, key)
                if key == "progressIdentity" then reads = reads + 1; return id end
            end})
        end
        a.guideState:CaptureFlags(large)
        assert(reads == 4000)
        reads = 0
        for i = 1, 100 do a.guideState:CaptureFlags(large) end
        assert(reads == 0, "unchanged saves rescanned the entire guide")
    end
    print("Skipped-step regressions passed: evidence, partial targets, abandonment, advancement, checkpoint identity.")
end
