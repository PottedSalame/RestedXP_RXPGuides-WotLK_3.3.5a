-- Regression coverage for manual reward completion on stock 3.3.5 and
-- quest-log reads while the player operates collapsed headers.
return function(root)
    local fixtureChunk = assert(loadfile(root .. "/tests/quest-automation-audit.lua"))
    setfenv(fixtureChunk, setmetatable({arg = {root, "--fixtures"}}, {__index = _G}))
    local fixture = fixtureChunk()

    local function read(path)
        local f = assert(io.open(root .. "/" .. path, "rb"))
        local text = f:read("*a")
        f:close()
        return text:gsub("\r\n", "\n")
    end

    -- Execute the complete legacy quest namespace block, not a copy of its
    -- cache logic. Other compatibility APIs are outside this focused fixture.
    local function legacyCache(s)
        local env = s.env
        local source = read("Compat/Bootstrap.lua")
        local first = assert(source:find('do\n    local C_QuestLog = ns("C_QuestLog")', 1, true))
        local last = assert(source:find('\n-- C_GossipInfo ', first, true))
        local body = source:sub(first, last - 1)
        local prelude = [[
local addon = ...
local function ns(name) _G[name] = _G[name] or {}; return _G[name] end
local function def(t, k, value) if t[k] == nil then t[k] = value end end
local function legacyTrue(value) return value == true or value == 1 end
local function wipe(t) for k in pairs(t) do t[k] = nil end end
]]
        env.C_QuestLog = env.C_QuestLog or {}
        env.GetNumQuestLogEntries = function() return #s.rows end
        env.GetQuestLogTitle = function(index)
            local row = s.rows[index]
            if not row then return end
            return row.title, 4, nil, 0, row.header, row.collapsed, row.complete, 0, row.id
        end
        env.GetQuestLogIndexByID = function(id)
            for i, row in ipairs(s.rows) do if row.id == id then return i end end
            return 0
        end
        env.GetQuestsCompleted = function(target)
            target = target or {}
            for id in pairs(s.serverCompleted or {}) do target[id] = true end
            return target
        end
        local chunk = assert(loadstring(prelude .. body, "@production-legacy-quest-cache"))
        setfenv(chunk, env)(s.addon)
    end

    local function prepare(options)
        local s = fixture()
        if options and options.legacy then
            s.rows = {{title = "Valley of Trials", header = 1},
                {title = s.title, id = 788, complete = 1}}
            legacyCache(s)
        end
        s:loadDirectives()
        s:loadDispatcher()
        local e = s:reward(2)
        e.flags = 0
        e.frame = {element = e, step = s.step, callback = s.addon.functions.turnin}
        s.addon.addonLoaded = true
        s.env.QuestInfoFrame.itemChoice = 2
        s.addon.settings.profile.enableQuestChoiceAutomation = false
        s.env.QueryQuestsCompleted = function() s.queries = (s.queries or 0) + 1 end
        s.addon.InstallManualQuestRewardObserver335()
        s.addon.InstallManualQuestRewardObserver335() -- idempotent setup
        function s:preClick()
            local button = self.env.QuestFrameCompleteQuestButton
            button.scripts.PreClick(button)
        end
        return s, e
    end

    for _, enabled in ipairs({true, false}) do
        for _, hookOrder in ipairs({"before", "after"}) do
            local s, e = prepare()
            s.addon.settings.profile.enableQuestAutomation = enabled
            local seen
            local function postHook()
                seen = s.env.GetTitleText()
                assert(not e.completed and s:count("progress") == 0,
                    "manual quest progressed inside a reward post-hook")
            end
            if hookOrder == "after" then s.env.hooksecurefunc("GetQuestReward", postHook)
            else
                -- Put a companion post-hook below the already-installed observer.
                s.rewardHook = postHook
            end
            s:emit("QUEST_COMPLETE")
            assert(s:count("reward") == 0, "manual choice automated unexpectedly")
            s:preClick()
            assert(s.addon.IsQuestRewardSettlementActive(), "manual click did not arm barrier")
            local previousHook = s.rewardHook
            s.rewardHook = function()
                s.log[788] = false
                for _, event in ipairs({"GOSSIP_SHOW", "QUEST_LOG_UPDATE", "QUEST_FINISHED"}) do
                    s:emit(event)
                    s.dispatch(e.frame, event)
                end
                if previousHook then previousHook() end
            end
            s.env.GetQuestReward(2) -- ONLY the user's stock OnClick invokes this
            assert(not e.completed and seen == s.title, "manual reward lost original context")
            s:tick(0.06)
            assert(e.completed and s:count("reward") == 1, "manual reward not confirmed without modern event")
            assert(s.addon.IsQuestRewardSettlementActive(), "manual release was not deferred")
            s:tick(0.06)
            assert(not s.addon.IsQuestRewardSettlementActive(), "manual barrier did not release")
            assert(not next(s.addon.errors), "directive callback failed")
        end
    end

    -- Real compatibility cache + manual transaction with a collapsed header.
    -- No modern QUEST_TURNED_IN is supplied. Only a server completion query
    -- can confirm the turn-in while row disappearance is ambiguous.
    do
        local s, e = prepare({legacy = true})
        s.env.C_QuestLog.RefreshLegacyCache()
        s:preClick()
        s.rows = {{title = "Valley of Trials", header = 1, collapsed = 1}}
        s.env.GetQuestReward(2)
        s:emit("QUEST_FINISHED")
        s:tick(0.21)
        assert(not e.completed, "collapsed header falsely confirmed reward")
        assert(s.queries == 1, "manual completion query missing or duplicated")
        assert(s.env.C_QuestLog.IsOnQuest(788), "collapsed header erased known quest membership")
        assert(s.addon.GetQuestLogPresence335(788) == nil, "collapsed absence was not unknown")
        s.serverCompleted = {[788] = true}
        local compat = s.frames.RXPCompat335QuestFrame
        -- Central event first deliberately tests unspecified frame ordering.
        s:emit("QUEST_QUERY_COMPLETE")
        compat.scripts.OnEvent(compat, "QUEST_QUERY_COMPLETE")
        s:tick(0.06)
        assert(e.completed, "server completion query did not settle manual turn-in")
    end

    -- Failure, cancellation and click-without-a-reward are not successes.
    do
        local s, e = prepare({legacy = true})
        s.env.C_QuestLog.RefreshLegacyCache()
        s.addon.RXPFrame.RefreshQuestState = function(event) s.dispatch(e.frame, event) end
        -- Custom/expensive confirmation path with no stock PreClick callback.
        s.env.GetQuestReward(2)
        s.rows = {{title = "Valley of Trials", header = 1}}
        s:tick(0.15)
        assert(s.queries == 1 and not e.completed, "query fallback guessed completion")
        s.serverCompleted = {[788] = true}
        local compat = s.frames.RXPCompat335QuestFrame
        compat.scripts.OnEvent(compat, "QUEST_QUERY_COMPLETE")
        s:emit("QUEST_QUERY_COMPLETE")
        s:tick(0.06)
        assert(e.completed and not next(s.addon.errors), "unobserved manual reward missed authoritative query")
    end
    do
        local s = prepare()
        s.addon.runtime = {DisableAll = function() end}
        s.addon:OnDisable()
        s:preClick()
        s.env.GetQuestReward(2)
        s:tick(0.2)
        assert(not s.addon.IsQuestRewardSettlementActive() and not s.queries,
            "disabled addon retained active observer work")
    end
    do
        local s, e = prepare()
        s:preClick()
        s.env.GetQuestReward(2) -- simulate rejected request: quest stays active
        s:emit("QUEST_FINISHED")
        s:tick(0.21)
        assert(not e.completed, "failed manual reward completed on QUEST_FINISHED")
        s:tick(5)
        assert(not e.completed and not s.addon.IsQuestRewardSettlementActive(), "manual timeout failed")
    end
    do
        local s, e = prepare()
        s:preClick() -- OnClick never reached the reward API
        s:tick()
        assert(not e.completed and not s.addon.IsQuestRewardSettlementActive(), "aborted click retained barrier")
        s.env.QuestInfoFrame.itemChoice = 0
        s:preClick()
        assert(not s.addon.IsQuestRewardSettlementActive(), "unselected reward armed barrier")
        s:emit("QUEST_FINISHED") -- close without clicking complete
        s:tick(0.2)
        assert(not e.completed, "closing reward dialog completed quest")
    end
    do
        local s, e = prepare()
        s:preClick()
        s.env.GetQuestReward(2)
        s.addon.questAutomation:ResetForGuideChange()
        s.log[788] = false
        s:tick(6)
        assert(not e.completed and not s.addon.IsQuestRewardSettlementActive(), "guide reset retained manual work")
    end

    -- Headers stay entirely user-controlled while the quest log is visible.
    -- Reproduce event-driven data reads after each user collapse/expand.
    do
        local s = fixture()
        local collapsed, expands = true, 0
        s.env.GetNumQuestLogEntries = function() return 1 end
        s.addon.questLog.GetNumQuestLogEntries = s.env.GetNumQuestLogEntries
        s.env.RXPCompatGetQuestLogTitle = function()
            return "Valley of Trials", 4, 0, true, collapsed
        end
        s.env.QuestLogFrame = {IsShown = function() return true end}
        s.env.ExpandQuestHeader = function()
            expands = expands + 1
            collapsed = false
        end
        s:loadDirectives()
        for _ = 1, 5 do
            collapsed = true
            s.addon.ExpandQuestHeaders()
            assert(collapsed, "data read expanded user-collapsed header")
            collapsed = false -- user's plus click succeeds
            s.addon.ExpandQuestHeaders()
            assert(not collapsed, "data read changed expanded header")
        end
        assert(expands == 0, "visible headers were mutated")
        s.env.QuestLogFrame.IsShown = function() return false end
        collapsed = true
        s.addon.ExpandQuestHeaders()
        assert(expands == 1 and not collapsed, "hidden-log legacy scan stopped working")
    end
    do
        local s = fixture()
        s.rows = {{title = "Valley of Trials", header = 1}, {title = "Sarkoth", id = 804, complete = 1}}
        legacyCache(s)
        assert(s.env.C_QuestLog.IsOnQuest(804), "visible quest missing")
        s.rows = {{title = "Valley of Trials", header = 1, collapsed = 1}}
        s.env.C_QuestLog.RefreshLegacyCache()
        assert(s.env.C_QuestLog.IsOnQuest(804), "collapse erased known active quest")
        assert(s.addon.GetQuestLogPresence335(804) == nil, "collapse proved removal")
        s.rows = {{title = "Valley of Trials", header = 1}}
        s.env.C_QuestLog.RefreshLegacyCache()
        assert(not s.env.C_QuestLog.IsOnQuest(804), "complete scan retained removed quest")
        assert(s.addon.GetQuestLogPresence335(804) == false, "complete scan could not prove absence")
        s.rows = {{title = "Other", id = 789}, {title = "Sarkoth", id = 804}}
        assert(s.env.C_QuestLog.GetLogIndexForQuestID(804) == 2, "reindexed quest resolved incorrectly")
    end
    -- A manual reward must release into the next authored accept, not the
    -- other available turn-in or the first item in a reversed gossip list.
    do
        local s, first = prepare()
        local followup = s:element("accept", 789, "Sting of the Scorpid")
        s:element("accept", 2383, "Simple Parchment")
        s:element("turnin", 804, "Sarkoth")
        s.active = {{questID = 804, title = "Sarkoth", isComplete = true}}
        s.available = {{questID = 2383, title = "Simple Parchment"},
            {questID = 789, title = "Sting of the Scorpid"}}
        s:preClick()
        s.rewardHook = function()
            s.log[788] = false
            s.env.QuestFrameRewardPanel:SetShown(false)
            s.env.GossipFrame:SetShown(true)
            s:emit("GOSSIP_SHOW")
            s:emit("QUEST_LOG_UPDATE")
        end
        s.env.GetQuestReward(2)
        assert(s:count("select-accept") == 0, "manual turn-in nested a follow-up selection")
        s:tick(0.06)
        s:tick(0.06)
        assert(first.completed, "manual first turn-in did not finish")
        s:tick(0.11)
        local selected = s.calls[#s.calls]
        assert(selected.kind == "select-accept" and selected.id == 789,
            "manual turn-in bypassed the next authored accept")
        s.qid, s.title = 789, "Sting of the Scorpid"
        s:emit("QUEST_DETAIL")
        s.log[789] = true
        s:emit("QUEST_ACCEPTED", 1, 789)
        assert(followup.completed, "same-NPC follow-up failed after manual reward")
    end
    for _, boundary in ipairs({"disable", "zoning", "guide-change"}) do
        local s = fixture()
        s:reward(2)
        s.cached = false
        s:emit("QUEST_COMPLETE")
        if boundary == "disable" then
            s.addon.settings.profile.enableQuestAutomation = false
            s.addon.questAutomation:ResetTransient()
        elseif boundary == "zoning" then s.addon:ZONE_CHANGED()
        else s.addon.questAutomation:ResetForGuideChange() end
        s.cached = true
        s:tick(0.21)
        s:tick()
        assert(s:count("reward") == 0, "uncached reward retry survived " .. boundary)
    end
    for _, gate in ipairs({"ctrl", "hidden", "practice"}) do
        local s = fixture()
        s:reward()
        s:emit("QUEST_COMPLETE")
        if gate == "ctrl" then s.ctrl = true
        elseif gate == "hidden" then s.addon.isHidden = true
        else s.addon.speedrunPracticeActive = true end
        s:tick()
        assert(s:count("reward") == 0, "queued automatic reward ignored " .. gate)
    end
    print("Manual reward, legacy completion cache, event-barrier and visible-header regressions passed.")
end
