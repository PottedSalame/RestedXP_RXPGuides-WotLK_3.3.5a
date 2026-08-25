local addonName, addon = ...

local _G = _G
local UnitInRaid = UnitInRaid
local fmt = string.format

local RegisterMessage_OLD = addon.RegisterMessage
local rand, tinsert, select = math.random, table.insert, _G.select
local IsAddOnLoadOnDemand = C_AddOns and C_AddOns.IsAddOnLoadOnDemand or _G.IsAddOnLoadOnDemand
local GetSpellInfo
if C_Spell and C_Spell.GetSpellInfo then
    addon.GetSpellInfo = function(...)
        local id = ...
        if not id then return end
        local t = C_Spell.GetSpellInfo(...)
        --local rank = C_Spell.GetSpellSubtext(...)
        if t then
            return t.name, t.rank, t.iconID, t.castTime, t.minRange, t.maxRange, t.spellID, t.originalIconID
        end
    end
    GetSpellInfo = addon.GetSpellInfo
else
    GetSpellInfo = _G.GetSpellInfo
end
local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or _G.GetSpellTexture
local GetSpellSubtext = C_Spell and C_Spell.GetSpellSubtext or _G.GetSpellSubtext
local IsCurrentSpell = C_Spell and C_Spell.IsCurrentSpell or _G.IsCurrentSpell
local IsSpellKnown = C_Spell and C_Spell.IsSpellKnown or _G.IsSpellKnown
local IsPlayerSpell = C_Spell and C_Spell.IsPlayerSpell or _G.IsPlayerSpell
local CORE_TICKER_OWNER = "core-update-loops"
local messageList = {}

local function MessageHandler(message,...)
    for func in pairs(messageList[message]) do
        func(message,...)
    end
end

addon.RegisterMessage = function(self,message,callback,...)
    if not messageList[message] then
        messageList[message] = {}
        RegisterMessage_OLD(self,message,MessageHandler)
    end
    messageList[message][callback] = true
end

function addon:UnregisterMessage(message,callback)
    if not messageList[message] then
        return
    elseif callback then
        messageList[message][callback] = nil
    else
        table.wipe(messageList[message])
    end
end

addon.HookMessage = function(self,message,callback,...)
    if not (messageList[message] and messageList[message][callback]) then
        addon.RegisterMessage(self,message,callback,...)
    else
        local callback_old = MessageHandler
        local callback_new
        if type(callback_old) == "function" then
            callback_new = function(...)
                callback_old(...)
                callback(...)
            end
        else
            callback_new = callback
        end
        RegisterMessage_OLD(self,message,callback_new,...)
    end
end

function addon.SendEvent(self,...)
    if _G.WeakAuras and _G.WeakAuras.ScanEvents then
        _G.WeakAuras.ScanEvents(...)
    end
    return addon.SendMessage(self,...)
end

local messageQueue = {}
function addon:QueueMessage(...)
    tinsert(messageQueue,{...})
end

function addon.ProcessMessageQueue()
    local count = math.min(#messageQueue, 10)
    if count == 0 then return end
    for i = 1, count do
        addon:SendEvent(unpack(messageQueue[i]))
    end
    for i = count, 1, -1 do
        table.remove(messageQueue, i)
    end
    return true
end

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
addon.release = GetAddOnMetadata(addonName, "Version")
addon.title = GetAddOnMetadata(addonName, "Title")
local cacheVersion = 33
local L = addon.locale.Get

if string.match(addon.release, 'project') then
    addon.release = L('Development')
    addon.versionText = L('Development')
else
    addon.versionText = string.format("%s %s", _G.GAME_VERSION_LABEL,
                                      addon.release)
end

addon.version = 40000
local gameVersion = select(4, GetBuildInfo())
addon.gameVersion = gameVersion
local maxLevel

if gameVersion > 60000 then
    addon.game = "RETAIL"
    maxLevel = 70
    if gameVersion > 120000 then
        maxLevel = 80
    end
elseif gameVersion > 50000 then
    addon.game = "MOP"
    maxLevel = 90
elseif gameVersion > 40000 then
    addon.game = "CATA"
    maxLevel = 85
elseif gameVersion > 30000 then
    addon.game = "WOTLK"
    maxLevel = 80
elseif gameVersion > 20000 then
    addon.game = "TBC"
    maxLevel = 70
else
    addon.game = "CLASSIC"
    maxLevel = 60
end

function addon.GetSeason()

    local season = C_Seasons and C_Seasons.HasActiveSeason() and (not(C_GameRules and C_GameRules.IsHardcoreActive and C_GameRules.IsHardcoreActive()) and C_Seasons.GetActiveSeason()) or 0
    if season > 2 then
        return 0
    end
    return season
end

local RXPGuides = {}
addon.RXPGuides = RXPGuides
addon.facade:ExposeGlobal("RXPGuides", RXPGuides)

addon.guideCache = {}
addon.questQueryList = {}
addon.itemQueryList = {}
addon.questAccept = {}
addon.questTurnIn = {}
addon.disabledQuests = {}
addon.activeItems = {}
addon.activeSpells = {}
addon.activeMacros = {}
addon.functions = {}
addon.enabledFrames = {} -- Hold all enabled frame/features for Hide/Show
addon.player = {
    localeClass = select(1, UnitClass("player")),
    class = select(2, UnitClass("player")),
    race = select(2, UnitRace("player")),
    faction = select(1,UnitFactionGroup("player")),
    guid = UnitGUID("player"),
    name = UnitName("player"),
    level = UnitLevel("player"),
    maxlevel = maxLevel,
    season = addon.GetSeason(),
    beta = GetCurrentRegion() >= 20,
    lang = GetLocale():sub(1,2)
}
addon.player.neutral = addon.player.faction == "Neutral"

addon.generatedSteps = {}

--local class = addon.player.class
--local race = addon.player.race

BINDING_HEADER_RXPGuides = addon.title
BINDING_HEADER_RXPTargeting = addon.title

local errorTimer = 0
addon.errors = {}
function addon.Call(label,func,...)
    --if true then return true end
    label = label or ""
    addon.lastCall = label
    local pass, r1, r2, r3, r4 = pcall(func,...)
    if not pass then
        local msg = r1
        addon.errors[label] = addon.errors[label] or {}
        local count = addon.errors[label][msg] or 0
        addon.errors[label][msg] = count + 1
        if GetTime() - errorTimer > 30 then
            errorTimer = GetTime()
            error(msg)
        end
        return
    end
    return r1, r2, r3, r4
end

local questFrame = CreateFrame("Frame");

local startTime = GetTime()

local function GetQuestAutomationElement(list, key)
    if type(list) ~= "table" or key == nil then return end
    local element = list[key]
    if type(element) == "table" then return element end
end

local function TrimQuestAutomationText(text)
    if type(text) ~= "string" then return end
    -- Quest titles in guide text can be wrapped in ordinary WoW colour and
    -- texture escapes.  Strip only presentation markup; do not remove normal
    -- punctuation because it is part of several real quest titles.
    text = text:gsub("|T.-|t", "")
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then return end
    return text
end

-- 3.3.5 gossip exposes offered quests by localized title, not quest ID.  The
-- server cannot always return the name of a quest which is not in the log yet,
-- but nearly every RXP .accept directive already contains its title.  Keep a
-- conservative parser for that authored title so all loaded guides get the
-- same fallback without maintaining per-guide quest-name patches.
local function GetGuideQuestActionTitle(element, englishLabel, localizedLabel,
                                         allowBareTitle)
    if type(element) ~= "table" then return end
    local text = TrimQuestAutomationText(element.text)
    if not text or text:find("\n", 1, true) then return end

    local lowerText = string.lower(text)
    local labels = {englishLabel}
    if type(localizedLabel) == "string" and localizedLabel ~= "" and
        localizedLabel ~= englishLabel then
        table.insert(labels, 1, localizedLabel)
    end
    for _, label in ipairs(labels) do
        label = TrimQuestAutomationText(label)
        if label then
            local prefix = string.lower(label) .. " "
            if lowerText:sub(1, #prefix) == prefix then
                return TrimQuestAutomationText(text:sub(#prefix + 1))
            end
        end
    end

    -- A small number of older guides use ".accept ID >> Quest Title".  That
    -- text is still an exact, useful title and is safe to register as an alias.
    if allowBareTitle and text ~= "*quest*" then return text end
end

function addon.GetGuideAcceptTitle(element)
    return GetGuideQuestActionTitle(element, "Accept", _G.ACCEPT, true)
end

function addon.GetGuideTurnInTitle(element)
    return GetGuideQuestActionTitle(element, "Turn in", _G.TURN_IN_QUEST)
end

local function CacheQuestAcceptTitle(title, element, isClientTitle)
    title = TrimQuestAutomationText(title)
    if not title or type(element) ~= "table" then return end
    addon.questAccept[title] = element

    local questId = tonumber(element.questId)
    if not questId or not isClientTitle then return element end

    -- Cache only an actual title seen from the client. Guide-authored titles
    -- are English and must not poison localized quest-name caches.
    if type(RXPCData) == "table" then
        RXPCData.questNameCache = type(RXPCData.questNameCache) == "table" and
                                      RXPCData.questNameCache or {}
        RXPCData.questNameCache[questId] = title
    end
    if type(RXPData) == "table" and type(RXPData.questNames) == "table" then
        RXPData.questNames[questId] = title
    end
    return element
end

function addon.CacheGuideAcceptTitle(element)
    local title = addon.GetGuideAcceptTitle(element)
    if title then return CacheQuestAcceptTitle(title, element, false) end
end

local function IsQuestAutoAcceptEligible(element)
    if not element or (element.questId and addon.disabledQuests and
        addon.disabledQuests[element.questId]) then return end

    local qid = tonumber(element.questId)
    if qid and addon.IsOnQuest(qid) then return end
    local step = element.step
    if type(step) ~= "table" then return end
    local index = tonumber(step.index)
    local previous = index and index > 1 and addon.currentGuide and
                         type(addon.currentGuide.steps) == "table" and
                         addon.currentGuide.steps[index - 1]
    return step.active or type(previous) == "table" and previous.active
end

local function GetQuestAcceptAutomationElement(titleOrId)
    local element = GetQuestAutomationElement(addon.questAccept, titleOrId)
    if element or addon.gameVersion ~= 30300 or
        type(titleOrId) ~= "string" then
        return element
    end

    local offered = string.lower(TrimQuestAutomationText(titleOrId) or "")
    if offered == "" then return end

    -- Recover aliases for elements which became active before their quest name
    -- arrived from the server.  Only exact cached/authored title matches are
    -- accepted; an unrelated single quest at another NPC is never guessed.
    local seen = {}
    local matched
    for _, candidate in pairs(addon.questAccept) do
        if type(candidate) == "table" and not seen[candidate] and
            IsQuestAutoAcceptEligible(candidate) then
            seen[candidate] = true
            local names = {}
            if type(candidate.title) == "string" then
                names[#names + 1] = candidate.title
            end
            local authoredTitle = addon.GetGuideAcceptTitle(candidate)
            if authoredTitle then names[#names + 1] = authoredTitle end
            local questId = tonumber(candidate.questId)
            if questId and addon.GetQuestName then
                names[#names + 1] = addon.GetQuestName(questId)
            end
            for _, name in ipairs(names) do
                name = TrimQuestAutomationText(name)
                if name and string.lower(name) == offered then
                    if matched and matched ~= candidate then
                        return -- ambiguous identical-title candidates
                    end
                    matched = candidate
                    break
                end
            end
        end
    end
    if matched then return CacheQuestAcceptTitle(titleOrId, matched, true) end
end

function addon.QuestAutoAccept(titleOrId)
    if not titleOrId then return end

    -- questAccept contains quest and title lookups
    -- addon.questAccept[747] == addon.questAccept["The Hunt Begins"]
    if addon.CheckAvailableQuest then addon.CheckAvailableQuest(titleOrId) end
    local element = GetQuestAcceptAutomationElement(titleOrId)

    -- This function is deliberately only an eligibility check. In particular,
    -- do not arm recentAccept here: GOSSIP_SHOW calls us before the quest detail
    -- page exists, and doing so makes that subsequent detail page look as though
    -- the quest was already accepted.
    return IsQuestAutoAcceptEligible(element) and true or nil
end

function addon.NormalizeQuestAcceptedId(arg1, arg2)
    if arg2 then return arg2 end
    local quirks = addon.compatibilityPacks and
                       addon.compatibilityPacks:GetEventQuirks() or nil
    -- Most 3.3.5 cores emit QUEST_ACCEPTED(logIndex). A verified data pack may
    -- explicitly report a direct quest-ID first argument instead.
    if addon.gameVersion == 30300 and quirks and
        quirks.questAcceptedLogIndex == false then
        return tonumber(arg1)
    end
    if addon.gameVersion == 30300 and arg1 and C_QuestLog and
        C_QuestLog.GetQuestIDForLogIndex then
        return C_QuestLog.GetQuestIDForLogIndex(arg1)
    end
    return arg1
end

function addon.GetStepQuestReward(titleOrId)
    -- enableQuestRewardAutomation is setting for hard-coded .turnin step data
    if not titleOrId then return 0 end
    -- questTurnIn contains quest and title lookups
    -- addon.questTurnIn[747] == addon.questTurnIn["The Hunt Begins"]

    local element = GetQuestAutomationElement(addon.questTurnIn, titleOrId)

    if not element then return 0 end
    if not addon.settings.profile.enableQuestRewardAutomation then return 0,element end

    local reward = tonumber(element.reward) or 0
    return (reward >= 0 and reward or 0), element
end

function addon.IsPlayerSpell(id)
    if IsPlayerSpell(id) or IsSpellKnown(id, true) or IsSpellKnown(id) then
        return true
    end
    if ExtraActionButton1 then
        local action = ExtraActionButton1.action
        if action and HasAction(action) then
            local _,eabId = GetActionInfo(action)
            local eabName = GetSpellInfo(eabId)
            local name = GetSpellInfo(id)
            if name == eabName then
                return true
            end
        end
    end
    if C_ZoneAbility then
        local spellName = C_Spell.GetSpellInfo(id)
        spellName = spellName and spellName.name
        local activeAbilities = C_ZoneAbility.GetActiveAbilities()
        if activeAbilities and spellName then
            for _,ability in pairs(activeAbilities) do
                local name = C_Spell.GetSpellInfo(ability.spellID).name
                if name == spellName then
                    return true
                end
            end
        end
    end
    if addon.player.season == 2 then
        for _,slot in pairs (C_Engraving.GetRuneCategories(false,true)) do

            local runes = C_Engraving.GetRunesForCategory(slot,true)
            for _,rune in pairs(runes) do
                if rune.skillLineAbilityID == id then
                    return true
                elseif type(rune.learnedAbilitySpellIDs) == "table" then
                    for _,spell in pairs(rune.learnedAbilitySpellIDs) do
                        if spell == id then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

local currrentSkillLevel = {}
local maxSkillLevel = {}
local professionNames

function addon.GetProfessionNames()
    if not professionNames then
        professionNames = {}
        addon.professionNames = professionNames
    end

    for profession, ids in pairs(addon.professionID) do
        for i, id in ipairs(ids) do
            if IsSpellKnown(id) or addon.gameVersion > 40000 then
                if id == 2656 then
                    professionNames[profession] = GetSpellInfo(2575)
                elseif id == 2383 then
                    local hid = addon.gameVersion > 30000 and 353982 or 9134
                    professionNames[profession] = GetSpellInfo(hid)
                elseif id == 1804 then
                    professionNames[profession] = GetSpellInfo(1809)
                else
                    professionNames[profession] = GetSpellInfo(id)
                end
                if professionNames[profession] then
                    break
                end
            end
        end
    end
    if  C_TradeSkillUI and C_TradeSkillUI.GetTradeSkillDisplayName then
        professionNames.riding = C_TradeSkillUI.GetTradeSkillDisplayName(762)
    else
        professionNames.riding = GetSpellInfo(33388)
    end
    return professionNames
end

addon.currrentSkillLevel = currrentSkillLevel
function addon.GetProfessionLevel()
    local names
    if not (professionNames and professionNames.riding) then
        addon.GetProfessionNames()
    end
    names = professionNames

    if IsPlayerSpell(33388) then
        currrentSkillLevel["riding"] = 75
    elseif IsPlayerSpell(33391) then
        currrentSkillLevel["riding"] = 150
    elseif IsPlayerSpell(34090) then
        currrentSkillLevel["riding"] = 225
    elseif IsPlayerSpell(34091) then
        currrentSkillLevel["riding"] = 300
    elseif IsPlayerSpell(90265) then
        currrentSkillLevel["riding"] = 375
    end

    if addon.IsPlayerSpell(54197) then currrentSkillLevel["coldweatherflying"] = 1 end

    if not _G.GetSkillLineInfo then return end
    if not names.riding then names.riding = GetSpellInfo(33388) end
    for i = 1, _G.GetNumSkillLines() do
        local skillName, _, _, skillRank, _, _, skillMaxRank =
            _G.GetSkillLineInfo(i)
        if skillRank then
            for profession, name in pairs(names) do
                -- print(name,skillName,name == skillName)
                if name == skillName then
                    currrentSkillLevel[profession] = skillRank
                    maxSkillLevel[profession] = skillMaxRank
                end
            end
        end
    end
--[[
--Enum.Profession is just wrong, can't use that
    if _G.GetProfessionInfo then
        for name,id in pairs(Enum.Profession) do
            local _, _, current, max = _G.GetProfessionInfo(id)
            if current then
                local p = strlower(name)
                currrentSkillLevel[p] = current
                maxSkillLevel[p] = max
            end
        end
    end
]]
end

function addon.UpdateSkillData()
    addon.GetProfessionNames()
    addon.GetProfessionLevel()
end

local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or _G.GetContainerNumSlots
local GetContainerItemID = C_Container and C_Container.GetContainerItemID or _G.GetContainerItemID
local GetItemSpell = C_Item and C_Item.GetItemSpell or _G.GetItemSpell

function addon.GetSkillLevel(skill, useMaxValue)
    addon.UpdateSkillData()

    local function finditem(id)
        if type(id) == "number" then
            for level,t in pairs(addon.mountIDs) do
                if t[id] then
                    return level
                end
            end
        end
        return -1
    end

    if skill == "riding" and gameVersion < 20000 and addon.mountIDs then
        local level = -1

        for bag = BACKPACK_CONTAINER, NUM_BAG_FRAMES do
            for slot = 1,GetContainerNumSlots(bag) do
                local id = GetContainerItemID(bag, slot)
                local _,spellId = GetItemSpell(id or 0)
                level = math.max(level,finditem(spellId))
            end
        end
        return level
    elseif skill then
        if useMaxValue then
            return maxSkillLevel[skill] or -1
        else
            return currrentSkillLevel[skill] or -1
        end
    else
        if useMaxValue then
            return maxSkillLevel
        else
            return currrentSkillLevel
        end
    end
end



local function ChangeStep(srcGuide,srcStep,destGuide,destStep,func)
    local function stepindex(guide,refresh)
        if type(guide) ~= "table" then
            return false
        elseif not guide.stepIds or refresh then
            guide.stepIds = {}
            for i,step in ipairs(guide.steps) do
                if step.stepId then
                    guide.stepIds[step.stepId] = i
                end
            end
        end
        return true
    end

    srcGuide = addon:FetchGuide(addon.guideIds[srcGuide])
    destGuide = addon:FetchGuide(addon.guideIds[destGuide])

    if not (stepindex(srcGuide) and (not destGuide or stepindex(destGuide))) then
        return
    end
    srcStep = srcGuide.stepIds[srcStep]
    destStep = srcGuide.stepIds[destStep]
    if srcStep and (not destGuide or destStep) then
        func(srcGuide,srcStep,destGuide,destStep)
        stepindex(srcGuide,true)
        stepindex(destGuide,true)
        addon:ScheduleTask(addon.ReloadGuide)
        --print(srcGuide.name,destGuide.name,srcStep,destStep)
        return true
    end
end

function addon.ReplaceStep(arg1,arg2,arg3,arg4)
    local function replace(srcGuide,srcStep,destGuide,destStep)
        --local oldStep = destGuide.steps[destStep]
        destGuide.steps[destStep] = srcGuide.steps[srcStep]
        --srcGuide.steps[srcStep] = oldStep
    end
    return ChangeStep(arg1,arg2,arg3,arg4,replace)
end

function addon.RemoveStep(arg1,arg2)
    local function remove(srcGuide,srcStep)
        --print('remove',srcGuide.name,srcStep)
        table.remove(srcGuide.steps,srcStep)
    end
    return ChangeStep(arg1,arg2,"","",remove)
end

function addon.InsertStep(arg1,arg2,arg3,arg4)
    local function insert(srcGuide,srcStep,destGuide,destStep)
        table.insert(destGuide.steps,destStep,srcGuide.steps[srcStep])
    end
    return ChangeStep(arg1,arg2,arg3,arg4,insert)

end

addon.skillList = {}
local spellRequest = {}

local trainerUpdate = 0

local function ProcessSpells(names, rank)
    if gameVersion > 90000 then return end
    local _, race = UnitRace("player")
    local level = UnitLevel("player")
    local entries = {race, addon.player.class}
    for _, entry in pairs(entries) do
        if addon.defaultSpellList[entry] then
            for spellLvl, spells in pairs(addon.defaultSpellList[entry]) do
                if spellLvl <= level then
                    for i, spellId in ipairs(spells) do
                        if not (spellRequest[spellId] or
                            C_Spell.IsSpellDataCached(spellId)) then
                            C_Spell.RequestLoadSpellData(spellId)
                            spellRequest[spellId] = true
                        end
                        if names and rank and
                            not (addon.settings.profile.hardcore and
                                addon.HCSpellList and addon.HCSpellList[spellId]) then
                            spellRequest[spellId] = nil
                            local sName = GetSpellInfo(spellId)
                            local sRank = GetSpellSubtext(spellId)
                            for id, name in pairs(names) do
                                if sName == name and sRank == rank[id] then
                                    BuyTrainerService(id)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function OnTrainer()
    if not addon.settings.profile.enableTrainerAutomation then return end

    local i = GetNumTrainerServices()

    if not i or i == 0 or GetTime() - trainerUpdate > 15 then return end

    local names = {}
    local rank = {}

    for id = 1, i do
        local n, r, cat = GetTrainerServiceInfo(id)
        if cat == "available" then
            names[id] = n
            rank[id] = r
        end
    end

    ProcessSpells(names, rank)

    for spellName, spellRank in pairs(addon.skillList) do
        for id, name in pairs(names) do
            if name == spellName then
                local r = rank[id]
                r = r and tonumber(r:match("(%d+)")) or 0
                if (r <= spellRank or spellRank == 0) then
                    BuyTrainerService(id)
                    return
                end
            end
        end
    end

end

local tTimer = 0
local function trainerFrameUpdate(self, t)
    tTimer = tTimer + t
    if tTimer >= 0.2 then
        tTimer = 0
        if GetTime() - trainerUpdate > 15 then
            self:SetScript("OnUpdate", nil)
        end
        OnTrainer()
    end
end

local function GossipGetNumOptions()
    if C_GossipInfo.GetNumOptions then
        return C_GossipInfo.GetNumOptions()
    elseif C_GossipInfo.GetOptions then
        return #C_GossipInfo.GetOptions()
    else
        return _G.GetNumGossipOptions()
    end
end

addon.GossipGetNumOptions = GossipGetNumOptions

local GossipGetNumActiveQuests = C_GossipInfo.GetNumActiveQuests or
                                     _G.GetNumGossipActiveQuests
local GossipGetNumAvailableQuests = C_GossipInfo.GetNumAvailableQuests or
                                        _G.GetNumGossipAvailableQuests
local GossipSelectAvailableQuest = C_GossipInfo.SelectAvailableQuest or
                                       _G.SelectGossipAvailableQuest
local GossipGetActiveQuests = C_GossipInfo.GetActiveQuests or
                                  _G.GetGossipActiveQuests
local GossipSelectActiveQuest = C_GossipInfo.SelectActiveQuest or
                                    _G.SelectGossipActiveQuest
local GossipGetAvailableQuests = C_GossipInfo.GetAvailableQuests or
                                     _G.GetGossipAvailableQuests

-- TODO handle Pawn compatibility
local questRewardChoiceIcons = {}
local questLogRewardChoiceIcons = {}
local function GetUpgradeChoiceIcon(iconTable, owner, key)
    local icon = iconTable[key]
    if not icon then
        icon = owner:CreateTexture()
        icon:SetTexture("Interface/AddOns/" .. addonName ..
                            "/Textures/rxp_logo-64")
        icon:SetSize(20, 20)
        iconTable[key] = icon
    end
    return icon
end

local function hideRewardChoiceIcons()
    for _, f in pairs(questRewardChoiceIcons) do
        if not f:IsForbidden() then f:Hide() end
    end

    for _, f in pairs(questLogRewardChoiceIcons) do
        if not f:IsForbidden() then f:Hide() end
    end
end

local function createRewardChoiceIcons()
    if not _G.QuestInfoRewardsFrame then return end

    if not questRewardChoiceIcons["ratio"] then
        questRewardChoiceIcons["ratio"] = _G.QuestInfoRewardsFrame:CreateTexture()
        questRewardChoiceIcons["ratio"]:SetTexture("Interface/AddOns/" .. addonName .. "/Textures/rxp_logo-64")
        questRewardChoiceIcons["ratio"]:SetSize(20, 20)
    end

    if questRewardChoiceIcons["ratio"].isHooked then return end

    if not questRewardChoiceIcons["value"] then
        questRewardChoiceIcons["value"] = _G.QuestInfoRewardsFrame:CreateTexture()
        questRewardChoiceIcons["value"]:SetTexture("Interface/GossipFrame/VendorGossipIcon.blp")
        questRewardChoiceIcons["value"]:SetSize(20, 20)
    end

    _G.QuestInfoRewardsFrame:HookScript("OnHide", hideRewardChoiceIcons)

    -- "OnShow" equivalent is handled by QuestAutomation function

    questRewardChoiceIcons["ratio"].isHooked = true
end

local function createLogRewardChoiceIcons()
    if not _G.QuestLogDetailScrollFrame then return end

    if not questLogRewardChoiceIcons["ratio"] then
        questLogRewardChoiceIcons["ratio"] = _G.QuestLogDetailScrollFrame:CreateTexture()
        questLogRewardChoiceIcons["ratio"]:SetTexture("Interface/AddOns/" .. addonName .. "/Textures/rxp_logo-64")
        questLogRewardChoiceIcons["ratio"]:SetSize(20, 20)
    end

    if questLogRewardChoiceIcons["ratio"].isHooked then return end

    if not questLogRewardChoiceIcons["value"] then
        questLogRewardChoiceIcons["value"] = _G.QuestLogDetailScrollFrame:CreateTexture()
        questLogRewardChoiceIcons["value"]:SetTexture("Interface/GossipFrame/VendorGossipIcon.blp")
        questLogRewardChoiceIcons["value"]:SetSize(20, 20)
    end

    -- Triggers on open and selection in Classic
    -- Only triggers on selection in Wrath
    hooksecurefunc("SelectQuestLogEntry", function(questLogIndex)
        hideRewardChoiceIcons()
        addon.DisplayQuestLogRewards(questLogIndex)
    end)

    -- Hide icons on quest log close to avoid mislabeled rewards
    _G.QuestLogDetailScrollFrame:HookScript("OnHide", hideRewardChoiceIcons)

    if addon.gameVersion > 20000 then
        -- Inefficient, but bypasses load order issues between helper functions
        _G.QuestLogDetailScrollFrame:HookScript("OnShow", function ()
            addon.DisplayQuestLogRewards()
        end)
    end

    questLogRewardChoiceIcons["ratio"].isHooked = true
end

-- Retail has enough helpers and massive UI differences
if addon.gameVersion < 40000 then
    createRewardChoiceIcons()
    createLogRewardChoiceIcons()
end

local GetItemInfo = C_Item and C_Item.GetItemInfo or _G.GetItemInfo

local GetQuestLogSelection, GetNumQuestLogChoices = _G.GetQuestLogSelection,
                                                    _G.GetNumQuestLogChoices
local GetQuestLogChoiceInfo, GetQuestLogItemLink, GetQuestLogTitle =
    _G.GetQuestLogChoiceInfo, _G.GetQuestLogItemLink,
    (_G.RXPCompatGetQuestLogTitle or _G.GetQuestLogTitle)

-- bestSellOption, bestRatioOption, options
local function evaluateQuestChoices(questID, numChoices, GetQuestItemInfo, GetQuestItemLink, GetQuestLogChoiceInfo)
    local hardCodedReward = addon.GetStepQuestReward(questID)

    -- If explicitly hard-coded .turnin reward choice, use that and exit
    if addon.settings.profile.enableQuestRewardAutomation
        and hardCodedReward > 0 then -- Quest has an explicit reward ID for .turnin step

        return -1, hardCodedReward, {}
    end

    -- Only support hard-coded turnin values on Retail
    if addon.gameVersion > 40000 then return -1, -1, {} end

    local options = {}
    local pendingItemData
    local itemLink, isUsable, itemData

    -- Load choices data
    -- TODO retry or handle query failures
    for i = 1, numChoices do
        itemData = nil
        if GetQuestItemInfo then
            isUsable = select(5, GetQuestItemInfo("choice", i))
        else
            isUsable = select(5, GetQuestLogChoiceInfo(i))
        end

        itemLink = GetQuestItemLink("choice", i)
        if not itemLink then pendingItemData = true end

        if addon.itemUpgrades and addon.itemUpgrades.GetItemData and
            addon.settings:IsEnabled('enableTips', 'enableItemUpgrades') and
            itemLink then
            local clientUsable = isUsable == true or isUsable == 1
            local clientUnusable = isUsable == false or isUsable == 0
            itemData = addon.itemUpgrades:GetItemData(itemLink, nil,
                                                       clientUsable)

            if itemData then
                itemData.comparisons = clientUnusable and {} or
                                           addon.itemUpgrades:CompareItemWeight(
                                               itemLink, nil, false,
                                               clientUsable) or {}
                -- Some 3.3.5 cores report the reward usability hint without
                -- applying class armor proficiency (for example Hunter mail
                -- before level 40). A successfully scored item is usable when
                -- the client did not explicitly reject it, but the hint may
                -- never override ItemUpgrades' recognized class restriction.
                itemData.isUsable = not clientUnusable and
                                        not itemData.unusable
            end
        end

        -- Always keep a choice record. Non-equipment rewards and uncached item
        -- links still need to participate in the vendor-value fallback, and a
        -- hole here made ipairs stop before later quest rewards.
        if not itemData then
            local itemName, itemMinLevel, itemEquipLoc, sellPrice,
                itemSubTypeID
            if itemLink then
                itemName, _, _, _, itemMinLevel, _, _, _, itemEquipLoc, _,
                    sellPrice, _, itemSubTypeID = GetItemInfo(itemLink)
            end
            if not itemName then pendingItemData = true end

            itemData = {
                itemLink = itemLink,
                itemSubTypeID = itemSubTypeID,
                itemEquipLoc = itemEquipLoc,
                sellPrice = sellPrice or 0,
                itemMinLevel = itemMinLevel or 0,
                comparisons = {},
                isUsable = isUsable ~= false and isUsable ~= 0
            }
        end
        itemData.sellPrice = itemData.sellPrice or 0
        options[i] = itemData
    end

    local bestSellOption, bestSellValue = -1, -1
    local bestRatioOption, bestRatioValue = -1, 0
    for choice, data in ipairs(options) do
        if data.sellPrice > bestSellValue then
            bestSellValue = data.sellPrice
            bestSellOption = choice
        end

        -- Check for best compared upgrade
        for _, compareData in ipairs(data.comparisons) do
            if compareData.ComparisonState ~= "upgrade" then
                -- Equal/downgrade records are requested only by item tooltips;
                -- never let them influence automatic quest reward selection.
            elseif not compareData.Ratio then
                if compareData.ItemLink == _G.EMPTY then
                     -- An item needs to be 10x better to beat an empty slot fill
                    bestRatioValue = 10.0
                    bestRatioOption = choice
                end
            elseif compareData.Ratio > bestRatioValue then
                bestRatioValue = compareData.Ratio
                bestRatioOption = choice
            end
        end
    end

    return bestSellOption, bestRatioOption, options, pendingItemData
end

local function ShowAdditionalUpgradeChoices(iconTable, owner, options,
                                              bestChoice, getButton)
    for choice, data in ipairs(options or {}) do
        if choice ~= bestChoice then
            local isUpgrade
            for _, comparison in ipairs(data.comparisons or {}) do
                if comparison.ComparisonState == "upgrade" then
                    isUpgrade = true
                    break
                end
            end
            if isUpgrade then
                local button = getButton(choice)
                if button then
                    local icon = GetUpgradeChoiceIcon(iconTable, owner,
                                                      "ratioChoice" .. choice)
                    icon:ClearAllPoints()
                    icon:SetParent(button)
                    icon:SetPoint("TOPRIGHT", button, -1, 1)
                    icon:Show()
                end
            end
        end
    end
end

local questRewardRetrySerial = 0

local function SubmitAutomatedQuestReward(choice, questId, numChoices)
    local order = addon.automationOrder
    if order and order.MarkQuestSubmitted then
        order:MarkQuestSubmitted("turnin", questId, GetTime())
    end
    GetQuestReward(choice)
    addon:SendEvent("RXP_QUEST_TURNIN", questId, numChoices, choice)
end

local function ResolveDisplayedTurnInQuestID()
    local id = GetQuestID()
    if addon.gameVersion == 30300 then
        local title = _G.GetTitleText and _G.GetTitleText()
        local element = GetQuestAutomationElement(addon.questTurnIn, title)
        if element and type(element.questId) == "number" then
            id = element.questId
        end
    end
    return id
end

local function handleQuestComplete(retryAttempt)
    hideRewardChoiceIcons()
    local id = tonumber(ResolveDisplayedTurnInQuestID())
    if not id or id < 0 or type(addon.questTurnIn) ~= "table" or
        addon.questTurnIn[id] == false or addon.disabledQuests and
        addon.disabledQuests[id] then return end

    local numChoices = GetNumQuestChoices()

    -- Automatically complete quests with no user choice
    if numChoices <= 1 then
        SubmitAutomatedQuestReward(1, id, numChoices)
        return
    end

    -- Pull quest handling out for .turnin legacy/hard-coded choices
    local hardCodedReward = addon.GetStepQuestReward(id)

    -- If explicitly hard-coded .turnin reward choice, use that and exit
    -- Preserve simplest path for existing functionality
    if hardCodedReward > 0 and
        addon.settings.profile.enableQuestRewardAutomation then

        SubmitAutomatedQuestReward(hardCodedReward, id, numChoices)

        -- Hard-coded, so exit early to keep recommendations and QuestLog portions simpler
        return
    end

    if not addon.settings.profile.enableTips or not addon.settings.profile.enableItemUpgrades then return end

    local bestSellOption, bestRatioOption, options, pendingItemData =
        evaluateQuestChoices(id, numChoices, GetQuestItemInfo,
                             GetQuestItemLink)

    if pendingItemData then
        if (retryAttempt or 0) < 5 then
            questRewardRetrySerial = questRewardRetrySerial + 1
            local serial = questRewardRetrySerial
            C_Timer.After(0.20, function()
                if serial ~= questRewardRetrySerial then return end
                local rewardVisible = _G.QuestFrameRewardPanel and
                                          _G.QuestFrameRewardPanel:IsShown() or
                                          _G.QuestFrameCompleteButton and
                                          _G.QuestFrameCompleteButton:IsShown()
                if rewardVisible then
                    handleQuestComplete((retryAttempt or 0) + 1)
                end
            end)
        end
        -- Never auto-select from only a partial set of rewards.
        return
    end
    questRewardRetrySerial = questRewardRetrySerial + 1

    if addon.gameVersion < 40000 and addon.settings.profile.enableQuestChoiceRecommendation then
        if bestRatioOption > 0 then
            local bestRatioFrame = QuestInfo_GetRewardButton(QuestInfoFrame.rewardsFrame, bestRatioOption)

            if bestRatioFrame then
                questRewardChoiceIcons["ratio"]:ClearAllPoints()
                questRewardChoiceIcons["ratio"]:SetPoint("TOPRIGHT", bestRatioFrame , -1, 1)
                questRewardChoiceIcons["ratio"]:SetParent(bestRatioFrame)
                questRewardChoiceIcons["ratio"]:Show()
            end
        end
        ShowAdditionalUpgradeChoices(
            questRewardChoiceIcons, _G.QuestInfoRewardsFrame, options,
            bestRatioOption, function(choice)
                return QuestInfo_GetRewardButton(QuestInfoFrame.rewardsFrame,
                                                  choice)
            end)
    end

    if addon.gameVersion < 40000 and addon.settings.profile.enableQuestChoiceGoldRecommendation then
        local bestSellFrame = QuestInfo_GetRewardButton(QuestInfoFrame.rewardsFrame, bestSellOption)

        if bestSellFrame then
            if bestSellOption > 0 then
                questRewardChoiceIcons["value"]:ClearAllPoints()
                questRewardChoiceIcons["value"]:SetPoint("BOTTOMRIGHT", bestSellFrame , -1, 1)
                questRewardChoiceIcons["value"]:SetParent(bestSellFrame)
                questRewardChoiceIcons["value"]:Show()
            end

            -- No calculated best upgrade, so add recommendation to value as well, only if weights added
            if addon.itemUpgrades and bestRatioOption < 1 then
                questRewardChoiceIcons["ratio"]:ClearAllPoints()
                questRewardChoiceIcons["ratio"]:SetPoint("TOPRIGHT", bestSellFrame , -1, 1)
                questRewardChoiceIcons["ratio"]:SetParent(bestSellFrame)
                questRewardChoiceIcons["ratio"]:Show()
            end
        end
    end

    -- If auto rewards disabled, abort because not doing anything further
    -- also disables the auto picker if the quest is not in the guide
    if not (addon.settings.profile.enableQuestChoiceAutomation and
        GetQuestAutomationElement(addon.questTurnIn, id)) then return end

    -- upgrade is more useful than selling
    if bestRatioOption > 0 then
        -- if isUsable, then automatically pick
        -- If not usable but recommended then leave the window open for user decision
        if options and options[bestRatioOption] and
            options[bestRatioOption].isUsable ~= false then
            SubmitAutomatedQuestReward(bestRatioOption, id, numChoices)
        end
    elseif bestSellOption > 0 then
        SubmitAutomatedQuestReward(bestSellOption, id, numChoices)
    end
end

-- Not hooked by createLogRewardChoiceIcons so never called on Retail
function addon.DisplayQuestLogRewards(questLogIndex)
    hideRewardChoiceIcons()
    if not questLogIndex or type(questLogIndex) == "table" then
        questLogIndex = GetQuestLogSelection()
    end
    if questLogIndex < 1 then return end

    local numChoices = GetNumQuestLogChoices()

    if numChoices <= 1 then
        return
    end

    local questID = select(8, GetQuestLogTitle(questLogIndex))

    local bestSellOption, bestRatioOption, options =
        evaluateQuestChoices(questID, numChoices, nil, GetQuestLogItemLink,
                             GetQuestLogChoiceInfo)

    if addon.settings.profile.enableQuestChoiceRecommendation then
        -- Classic is QuestLogItem, Wrath+ is QuestInfoRewardsFrameQuestInfoItem
        local bestRatioFrame = _G['QuestLogItem' .. bestRatioOption] or
            QuestInfo_GetRewardButton(QuestInfoFrame.rewardsFrame, bestRatioOption)

        if bestRatioFrame then
            questLogRewardChoiceIcons["ratio"]:ClearAllPoints()
            questLogRewardChoiceIcons["ratio"]:SetPoint("TOPRIGHT", bestRatioFrame , -1, 1)
            questLogRewardChoiceIcons["ratio"]:SetParent(bestRatioFrame)
            questLogRewardChoiceIcons["ratio"]:Show()
        end
        ShowAdditionalUpgradeChoices(
            questLogRewardChoiceIcons, _G.QuestLogDetailScrollFrame, options,
            bestRatioOption, function(choice)
                return _G['QuestLogItem' .. choice] or
                           QuestInfo_GetRewardButton(QuestInfoFrame.rewardsFrame,
                                                     choice)
            end)
    end

    if addon.settings.profile.enableQuestChoiceGoldRecommendation then
        local bestSellFrame = _G['QuestLogItem' .. bestSellOption] or
            QuestInfo_GetRewardButton(QuestInfoFrame.rewardsFrame, bestSellOption)

        if bestSellFrame then
            questLogRewardChoiceIcons["value"]:ClearAllPoints()
            questLogRewardChoiceIcons["value"]:SetPoint("BOTTOMRIGHT", bestSellFrame , -1, 1)
            questLogRewardChoiceIcons["value"]:SetParent(bestSellFrame)
            questLogRewardChoiceIcons["value"]:Show()

            -- No calculated best upgrade, so add recommendation to value as well, only if weights added
            if addon.itemUpgrades and bestRatioOption < 1 then
                questLogRewardChoiceIcons["ratio"]:ClearAllPoints()
                questLogRewardChoiceIcons["ratio"]:SetParent(bestSellFrame)
                questLogRewardChoiceIcons["ratio"]:SetPoint("TOPRIGHT", bestSellFrame , -1, 1)
                questLogRewardChoiceIcons["ratio"]:Show()
            end
        end
    end
end

local questAcceptState = addon.questAcceptState
local QUEST_AUTOMATION_OWNER = "quest-engine"

local function QuestEventQuirks()
    return addon.compatibilityPacks and
               addon.compatibilityPacks:GetEventQuirks() or {}
end

local function CompleteConfirmedQuestElement(element, event, questId)
    if type(element) ~= "table" or element.completed or
        type(element.step) ~= "table" or not addon.SetElementComplete then
        return
    end

    local step = element.step
    local confirmationStepActive = step.active
    if not confirmationStepActive and event == "QUEST_ACCEPTED" then
        local index = tonumber(step.index)
        local steps = addon.currentGuide and addon.currentGuide.steps
        local previous = index and index > 1 and type(steps) == "table" and
                             steps[index - 1]
        confirmationStepActive = type(previous) == "table" and previous.active
    end
    if not confirmationStepActive then return end

    -- QUEST_ACCEPTED/QUEST_TURNED_IN are authoritative.  Committing the active
    -- element immediately avoids waiting for a second QUEST_LOG_UPDATE, which
    -- can arrive after the NPC has already opened the next quest detail page
    -- on 3.3.5 same-NPC chains.
    local frame = element.frame
    local callback = element.tag and addon.functions and
                         addon.functions[element.tag]
    if frame and type(callback) == "function" then
        if event == "QUEST_ACCEPTED" then
            addon.Call(element.tag, callback, frame, event, nil, questId)
        else
            addon.Call(element.tag, callback, frame, event, questId)
        end
    else
        addon.SetElementComplete(element, true, event ~= "QUEST_ACCEPTED")
    end
    if not element.completed then
        addon.SetElementComplete(element, true, event ~= "QUEST_ACCEPTED")
    end
    if addon.UpdateStepCompletion then addon.UpdateStepCompletion() end
end

local function ScheduleQuestAutomationRetries()
    local serial = questAcceptState:NextRetrySerial()
    local packDelay = tonumber(QuestEventQuirks().questTurnedInDelayed) or 0
    for index, delay in ipairs({0.10, 0.30, 0.60}) do
        addon.scheduler:After(QUEST_AUTOMATION_OWNER,
                              "automation-retry-" .. index,
                              delay + packDelay, function()
            if questAcceptState:IsRetryCurrent(serial) and
                not questAcceptState:GetPending(GetTime(), 5) then
                addon:QuestAutomation()
            end
        end)
    end
end

local function ClearExpiredPendingAccept()
    local packDelay = tonumber(QuestEventQuirks().questLogUpdateDelay) or 0
    local lifetime = math.max(5, packDelay + 1)
    return questAcceptState:GetPending(GetTime(), lifetime)
end

local function CommitQuestAccept(questId)
    ClearExpiredPendingAccept()
    questId = tonumber(questId)
    if not questId or questId <= 0 then return end

    local now = GetTime()
    -- recentAccept is also written by the active guide element's native event
    -- callback.  It therefore cannot be used to deduplicate this automation
    -- commit: frame dispatch order would sometimes make the first confirmation
    -- look like a duplicate and suppress the same-NPC follow-up retry.
    local committed = questAcceptState:Commit(questId, now, 5)
    if not committed then return end
    local alreadyCommitted = committed.alreadyCommitted
    addon.recentAccept[questId] = now
    if C_QuestLog and C_QuestLog.MarkQuestAccepted then
        C_QuestLog.MarkQuestAccepted(questId)
    end

    local guideAccept = GetQuestAutomationElement(addon.questAccept, questId)
    guideAccept = guideAccept or committed.element

    CompleteConfirmedQuestElement(guideAccept, "QUEST_ACCEPTED", questId)

    if guideAccept and not alreadyCommitted then
        addon:SendEvent("RXP_QUEST_ACCEPT", questId)
    end

    if guideAccept and not alreadyCommitted then
        -- The stock Accept button decides whether to close the detail panel or
        -- return to the NPC's gossip list. Forcibly hiding QuestFrame here broke
        -- same-NPC sequences such as Gadrin's 805 turn-in followed by accepting
        -- 808, 826, and 823. Retry once the stock UI has settled so the next
        -- eligible offer can be selected without requiring another NPC click.
        ScheduleQuestAutomationRetries()
    end
end

local function ReconcilePendingAccept()
    local pending = ClearExpiredPendingAccept()
    if not pending then return end
    local questId = pending.questId
    if questId and addon.IsOnQuest(questId) then
        CommitQuestAccept(questId)
    end
end

local function GetTurnInAutomationElement(titleOrId)
    local element = GetQuestAutomationElement(addon.questTurnIn, titleOrId)
    if element then return element end
    local title = GetTitleText and GetTitleText()
    if title and title ~= titleOrId then
        return GetQuestAutomationElement(addon.questTurnIn, title)
    end
end

local function SelectOrderedQuestCandidate(candidates)
    local order = addon.automationOrder
    local candidate = order and order.SelectQuest and
                          order:SelectQuest(candidates) or
                          order and order:Select(candidates) or candidates[1]
    if not candidate then return end
    if order and order.ReserveQuest then
        if order:ReserveQuest(candidate, GetTime()) == false then return end
    end
    if candidate.kind == "turnin" then
        GossipSelectActiveQuest(candidate.selector)
    else
        GossipSelectAvailableQuest(candidate.selector)
    end
    return true
end

local function SelectOrderedGreetingCandidate(candidates)
    local order = addon.automationOrder
    local candidate = order and order.SelectQuest and
                          order:SelectQuest(candidates) or
                          order and order:Select(candidates) or candidates[1]
    if not candidate then return end
    if order and order.ReserveQuest then
        if order:ReserveQuest(candidate, GetTime()) == false then return end
    end
    if candidate.kind == "turnin" then
        SelectActiveQuest(candidate.selector)
    else
        SelectAvailableQuest(candidate.selector)
    end
    return true
end

local function IsQuestInteractionReady(element, kind)
    if not element then return true end
    if addon.IsQuestAutomationElementReady then
        return addon.IsQuestAutomationElementReady(element, kind)
    end
    return not addon.IsAutomationElementReady or
               addon.IsAutomationElementReady(element)
end

local function GetReservedQuestInteraction(kind, questId)
    local order = addon.automationOrder
    if questId and order and order.GetQuestConfirmation then
        return order:GetQuestConfirmation(kind, questId, GetTime())
    elseif order and order.GetQuestReservation then
        return order:GetQuestReservation(kind, GetTime())
    end
end

local function ClearQuestInteraction(element, kind)
    local order = addon.automationOrder
    if order and order.ClearQuestReservation then
        order:ClearQuestReservation(element, kind)
    end
end

local function ReconcileSubmittedQuestInteraction(disabled, questFinished)
    local element, reservation = GetReservedQuestInteraction()
    if type(element) ~= "table" or type(reservation) ~= "table" or
        not reservation.submitted then return false end

    local kind = reservation.kind
    local questId = tonumber(reservation.questId or element.questId)
    if kind == "turnin" then
        -- QUEST_FINISHED is the stock 3.3.5 completion signal after a submitted
        -- reward. Some cores also provide QUEST_TURNED_IN; others only refresh
        -- the quest log. In the latter case, disappearance from the log after
        -- our own GetQuestReward call is the equivalent confirmation.
        local removedFromLog = questId and addon.IsOnQuest and
                                   not addon.IsOnQuest(questId)
        if not questFinished and not removedFromLog then return false end

        questAcceptState:MarkTurnIn(GetTime())
        CompleteConfirmedQuestElement(element, "QUEST_TURNED_IN", questId)
        ClearQuestInteraction(element, "turnin")
        if not disabled then
            addon.questAutoAccept = true
            ScheduleQuestAutomationRetries()
        end
        return true
    elseif kind == "accept" and questId and addon.IsOnQuest and
        addon.IsOnQuest(questId) then
        CommitQuestAccept(questId)
        ClearQuestInteraction(element, "accept")
        return true
    end
    return false
end

local function ReconcileQuestAutomationState(disabled)
    ReconcilePendingAccept()
    ReconcileSubmittedQuestInteraction(disabled, false)
end

local function ScheduleQuestStateRefresh(disabled)
    local packDelay = tonumber(QuestEventQuirks().questLogUpdateDelay) or 0
    for index, delay in ipairs({0.05, 0.20, 0.50}) do
        addon.scheduler:After(QUEST_AUTOMATION_OWNER,
                              "guide-quest-state-refresh-" .. index,
                              delay + packDelay, function()
            if C_QuestLog and C_QuestLog.RefreshLegacyCache then
                C_QuestLog.RefreshLegacyCache()
            end
            ReconcileQuestAutomationState(disabled)
            local frame = addon.RXPFrame
            if frame and frame.RefreshQuestState then
                frame.RefreshQuestState("QUEST_LOG_UPDATE")
            end
        end)
    end
end

function addon:QuestAutomation(event, arg1, arg2, arg3)
    local disabled
    if not addon.settings.profile.enableQuestAutomation or IsControlKeyDown() or
        addon.isHidden or addon.speedrunPracticeActive then
        disabled = true
    end

    if not event then
        if _G.GossipFrame and _G.GossipFrame:IsShown() then
            event = "GOSSIP_SHOW"
        elseif _G.QuestFrameGreetingPanel and
            _G.QuestFrameGreetingPanel:IsShown() then
            event = "QUEST_GREETING"
        elseif _G.QuestFrameProgressPanel and
            _G.QuestFrameProgressPanel:IsShown() then
            event = "QUEST_PROGRESS"
        elseif _G.QuestFrameDetailPanel and _G.QuestFrameDetailPanel:IsShown() then
            event = "QUEST_DETAIL"
        elseif _G.QuestFrameRewardPanel and _G.QuestFrameRewardPanel:IsShown() or
            _G.QuestFrameCompleteButton and
            _G.QuestFrameCompleteButton:IsShown() then
            event = "QUEST_COMPLETE"
        else
            return
        end
    end
    -- Acceptance and turn-in state must be processed even when automation is
    -- disabled, Ctrl is held, or the guide window is hidden.
    if event == "QUEST_ACCEPTED" then
        local questId = addon.NormalizeQuestAcceptedId(arg1, arg2)
        local pending = questAcceptState:GetPending(GetTime(), 5)
        if not questId and pending then
            questId = pending.questId
        end
        local reservedAccept = GetReservedQuestInteraction("accept", questId)
        CommitQuestAccept(questId)
        ScheduleQuestStateRefresh(disabled)
        -- Clear only the interaction which this event can confirm. A refreshed
        -- gossip list may already be visible on fast private-server cores.
        if reservedAccept then
            ClearQuestInteraction(reservedAccept, "accept")
        elseif not questId then
            ClearQuestInteraction(nil, "accept")
        end
        if addon.lore then addon.lore:MarkSeen(questId) end
        return
    elseif event == "QUEST_LOG_UPDATE" then
        ScheduleQuestStateRefresh(disabled)
        local delay = tonumber(QuestEventQuirks().questLogUpdateDelay) or 0
        if delay > 0 then
            addon.scheduler:After(QUEST_AUTOMATION_OWNER,
                                  "reconcile-pending-accept", delay,
                                  function()
                ReconcileQuestAutomationState(disabled)
            end)
        else
            ReconcileQuestAutomationState(disabled)
        end
        return
    elseif event == "QUEST_FINISHED" then
        if not ReconcileSubmittedQuestInteraction(disabled, true) then
            -- Accept-state caches can lag QUEST_FINISHED by one frame. Keep a
            -- single bounded reconciliation rather than requiring the player
            -- to close and reopen the NPC repeatedly.
            addon.scheduler:After(QUEST_AUTOMATION_OWNER,
                                  "finished-reconcile", 0.10, function()
                ReconcileQuestAutomationState(disabled)
            end)
        end
        return
    elseif event == "QUEST_TURNED_IN" then
        if addon.lore then addon.lore:MarkSeen(arg1) end
        -- The active element frame may receive this event first, advance the
        -- guide, and wipe questTurnIn before this coordinator runs.  The menu
        -- reservation survives that frame-order race and identifies the exact
        -- authored turn-in which was selected.
        local guideTurnIn = GetQuestAutomationElement(addon.questTurnIn,
                                                       arg1) or
                                GetReservedQuestInteraction("turnin", arg1)
        if guideTurnIn then
            questAcceptState:MarkTurnIn(GetTime())
            CompleteConfirmedQuestElement(guideTurnIn, "QUEST_TURNED_IN",
                                           arg1)
            ClearQuestInteraction(guideTurnIn, "turnin")
            if not disabled then
                addon.questAutoAccept = true
                ScheduleQuestAutomationRetries()
            end
        end
        ScheduleQuestStateRefresh(disabled)
        return
    end

    --print(event)
    if event == "GOSSIP_SHOW" then
        -- A new gossip list after our reward submission also proves the prior
        -- quest interaction finished, even on cores which omit QUEST_FINISHED.
        ReconcileSubmittedQuestInteraction(disabled, true)
        local nActive = GossipGetNumActiveQuests()
        local nAvailable = GossipGetNumAvailableQuests()
        local quests, selectAvailableByQuestID, missingTurnIn
        local candidates = {}
        if not disabled then
            if C_GossipInfo.GetActiveQuests then
                quests = C_GossipInfo.GetActiveQuests()
            end
            for i = 1, nActive do
                local title, isComplete
                local reward,isAutoTurnIn
                local selector = i
                if type(quests) == "table" then
                    title = quests[i].questID
                    isComplete = quests[i].isComplete
                    selector = addon.gameVersion == 30300 and
                                   (quests[i].index or i) or title
                    reward,isAutoTurnIn = addon.GetStepQuestReward(title)
                    if not (isComplete or missingTurnIn) and isAutoTurnIn then
                        local objectives = addon.GetQuestObjectives(title)
                        missingTurnIn = objectives and objectives[1].generated and {
                            selector = selector,
                            element = isAutoTurnIn
                        }
                    end
                else
                    title, _, _, isComplete = select(i * 6 - 5,
                                                    GossipGetActiveQuests())
                    reward,isAutoTurnIn = addon.GetStepQuestReward(title)
                end

                -- Some 3.3.5 cores report the gossip completion flag late or
                -- at a server-specific tuple position.  The numeric quest-log
                -- state is authoritative when the title resolved to the guide.
                if not isComplete and isAutoTurnIn and addon.IsQuestComplete then
                    isComplete = addon.IsQuestComplete(isAutoTurnIn.questId) and
                                     true or false
                end

                if isComplete and isAutoTurnIn then
                    candidates[#candidates + 1] = {
                        kind = "turnin",
                        selector = selector,
                        element = isAutoTurnIn
                    }
                end
            end
        end
        local availableQuests
        if C_GossipInfo.GetAvailableQuests then
            availableQuests = C_GossipInfo.GetAvailableQuests()
            selectAvailableByQuestID = true
        end
        local t = type(availableQuests) == "table"
        for i = 1, nAvailable do
            local quest
            if t then
                quest = availableQuests[i].questID
            else
                quest = select(i * 7 - 6, GossipGetAvailableQuests())
            end
            if not disabled and addon.QuestAutoAccept(quest) then
                local guideAccept = GetQuestAcceptAutomationElement(quest)
                if guideAccept then
                    candidates[#candidates + 1] = {
                        kind = "accept",
                        selector = addon.gameVersion == 30300 and
                                       (t and availableQuests[i].index or i) or
                                       selectAvailableByQuestID and quest or i,
                        element = guideAccept
                    }
                end
            end
        end
        if SelectOrderedQuestCandidate(candidates) then return end
        if missingTurnIn and IsQuestInteractionReady(missingTurnIn.element,
                                                      "turnin") then
            local order = addon.automationOrder
            if order and order.ReserveQuest then
                if order:ReserveQuest({kind = "turnin",
                                      element = missingTurnIn.element},
                                     GetTime()) == false then return end
            end
            return GossipSelectActiveQuest(missingTurnIn.selector)
        end
    elseif disabled then
        return
    elseif event == "QUEST_ACCEPT_CONFIRM" and addon.QuestAutoAccept(arg2) then
        local guideAccept = GetQuestAcceptAutomationElement(arg2)
        if guideAccept and not IsQuestInteractionReady(guideAccept, "accept") then
            return
        end
        questAcceptState:Begin(
            guideAccept and guideAccept.questId or
                (type(arg2) == "number" and arg2 or nil), nil, guideAccept,
            GetTime())
        local order = addon.automationOrder
        if order and order.MarkQuestSubmitted then
            order:MarkQuestSubmitted("accept",
                                     guideAccept and guideAccept.questId or arg2,
                                     GetTime())
        end
        ConfirmAcceptQuest()
    elseif event == "QUEST_COMPLETE" then
        local loreQuestId = GetQuestID and GetQuestID()
        if addon.lore and addon.lore:ShouldPause(loreQuestId, "turnin") then
            return
        end
        local guideTurnIn = GetReservedQuestInteraction("turnin") or
                                GetTurnInAutomationElement(loreQuestId)
        if guideTurnIn and not IsQuestInteractionReady(guideTurnIn, "turnin") then
            return
        end
        handleQuestComplete()
    elseif event == "QUEST_PROGRESS" then
        local id = GetQuestID()
        local guideTurnIn = GetReservedQuestInteraction("turnin") or
                                GetTurnInAutomationElement(id)
        if id and addon.disabledQuests[id] then
            return
        elseif guideTurnIn and
            not IsQuestInteractionReady(guideTurnIn, "turnin") then
            return
        elseif IsQuestCompletable() then
            CompleteQuest()
        elseif addon.QuestAutoAccept(id) then
            HideUIPanel(_G.QuestFrame)
        elseif questAcceptState:WasRecentTurnIn(GetTime(), 0.5) then
            HideUIPanel(_G.QuestFrame)
            questAcceptState:ClearTurnIn()
        end
        -- questProgressTimer = GetTime()
    elseif event == "QUEST_DETAIL" then
        -- Offered quests are not in the 3.3.5 quest log yet. More importantly,
        -- looking the frame title up in that log can return the just-turned-in
        -- quest when a chain reuses a title (Sarkoth 790 -> 804). Match the
        -- offered title directly against the guide's title lookup instead.
        local title = GetTitleText and GetTitleText()
        local lookup = addon.gameVersion == 30300 and title or
                           (GetQuestID() or title)
        local recentTurnIn = questAcceptState:WasRecentTurnIn(GetTime(), 0.5)
        -- Preserve the exact element selected from the preceding gossip list.
        -- During same-NPC chains the guide can advance before QUEST_DETAIL,
        -- while identical or not-yet-cached localized titles may resolve to a
        -- different element (or no element at all).
        local guideAccept = GetReservedQuestInteraction("accept") or
                                GetQuestAcceptAutomationElement(lookup)
        local questId = guideAccept and tonumber(guideAccept.questId)
        if questId and addon.disabledQuests and addon.disabledQuests[questId] then
            return
        elseif guideAccept and
            not IsQuestInteractionReady(guideAccept, "accept") then
            return
        elseif addon.lore and addon.lore:ShouldPause(questId, "accept",
                                                     guideAccept) then
            return
        elseif addon.QuestAutoAccept(lookup) or
            (recentTurnIn and guideAccept and
                (not questId or not addon.IsOnQuest(questId))) then
            questAcceptState:Begin(questId, title, guideAccept, GetTime())
            local order = addon.automationOrder
            if order and order.MarkQuestSubmitted then
                order:MarkQuestSubmitted("accept", questId, GetTime())
            end
            if _G.QuestDetailAcceptButton_OnClick then
                -- 3.3.5a: a real Accept-button click accepts the quest AND lets the
                -- quest frame close itself (which ZygorGuidesViewerRM relies on).
                -- Plain AcceptQuest() + HideUIPanel() left the frame open here.
                _G.QuestDetailAcceptButton_OnClick()
            else
                AcceptQuest()
                HideUIPanel(_G.QuestFrame)
            end
            questAcceptState:ClearTurnIn()
        elseif recentTurnIn then
            -- Do not close an unrecognised follow-up. SetStep queues another
            -- QuestAutomation pass after the guide advances, including across a
            -- guide boundary.
            addon.questAutoAccept = true
        end
    elseif event == "QUEST_GREETING" then
        ReconcileSubmittedQuestInteraction(disabled, true)
        local nActive = GetNumActiveQuests()
        local nAvailable = GetNumAvailableQuests()

        local candidates = {}
        local title, isComplete
        for i = 1, nActive do
            title, isComplete = GetActiveTitle(i)
            local reward,exists = addon.GetStepQuestReward(title)
            if not isComplete and exists and addon.IsQuestComplete then
                isComplete = addon.IsQuestComplete(exists.questId) and true or
                                 false
            end
            if exists and isComplete then
                candidates[#candidates + 1] = {
                    kind = "turnin",
                    selector = i,
                    element = exists
                }
            end
        end

        for i = 1, nAvailable do
            title, isComplete = GetAvailableTitle(i)
            if addon.QuestAutoAccept(title) then
                local guideAccept = GetQuestAcceptAutomationElement(title)
                if guideAccept then
                    candidates[#candidates + 1] = {
                        kind = "accept",
                        selector = i,
                        element = guideAccept
                    }
                end
            end
        end
        SelectOrderedGreetingCandidate(candidates)
    elseif event == "QUEST_AUTOCOMPLETE" then
        local grp = addon.currentGuide and addon.currentGuide.group
        if grp then
            grp = strupper(grp)
            if grp:find("PREP") then
                return
            end
        end
        local maxLvl = 0
        local xp = UnitXP('player')/UnitXPMax('player')

        if addon.gameVersion < 40000 then
            maxLvl = 70
        elseif addon.gameVersion < 50000 then
            maxLvl = 80
        elseif addon.gameVersion < 60000 then
            maxLvl = 85
        end

        if UnitLevel('player') == maxLvl and xp < 0.01 then
            return
        elseif arg1 and addon.disabledQuests[arg1] then
            return
        elseif (addon.gameVersion < 60000 and UnitLevel('player') < 85) then
            for i = 1, GetNumAutoQuestPopUps() do
                local id,status = GetAutoQuestPopUp(i)
                if status == "COMPLETE" or id == arg1 then
                    local frame = _G['WatchFrameAutoQuestPopUp' .. i]
                    if frame and frame:IsShown() then
                        frame:GetScript("OnMouseUp")(frame)
                    end
                end
            end
        elseif addon.gameVersion > 60000 then
            ShowQuestComplete(arg1)
        end
    end
end

function addon.IsNewCharacter()
    local n = 0
    local GetQuests = C_QuestLog and C_QuestLog.GetAllCompletedQuestIDs or _G.GetQuestsCompleted
    for i in pairs(GetQuests()) do
        n = n + 1
        if n > 1 then
            return false
        end
    end
    if UnitXP("player") == 0 then
        return true
    end
end

function addon.GetCharacterIdentity()
    local name = UnitName("player")
    local realm = GetRealmName()
    if name and name ~= "" and realm and realm ~= "" then
        return realm .. ":" .. name
    end
    return UnitGUID("player")
end

function addon:CreateMetaDataTable(wipe)
    if wipe or addon.release ~= RXPData.release or RXPData.cacheVersion ~= cacheVersion or not cacheVersion or addon.IsNewCharacter() or addon.settings.profile.preLoadData then
        RXPCData.guideMetaData = nil
        RXPCData.guideDisabled = nil
        local deleteIndexes = {}
        local guides = addon.db.profile.guides
        for key,v in pairs(guides) do
            --print(i,v)
            local grp = addon.GroupOverride(key)
            if grp ~= key then
                guides[grp] = v
                table.insert(deleteIndexes,key)
            end
        end
        for _,i in ipairs(deleteIndexes) do
            guides[i] = nil
        end
    end
    RXPData.guideMetaData = nil
    local guideMetaData = RXPCData.guideMetaData or {}
    RXPCData.guideMetaData = guideMetaData
    RXPCData.guideDisabled = RXPCData.guideDisabled or {}
    guideMetaData.dungeonGuides = guideMetaData.dungeonGuides or {}
    guideMetaData.enabledDungeons = guideMetaData.enabledDungeons or {}
    guideMetaData.enabledDungeons.Horde = guideMetaData.enabledDungeons.Horde or {}
    guideMetaData.enabledDungeons.Alliance = guideMetaData.enabledDungeons.Alliance or {}
    guideMetaData.enableGroupQuests = guideMetaData.enableGroupQuests or {}

    guideMetaData.professionGuides = guideMetaData.professionGuides or {}
    guideMetaData.enabledProfessions = guideMetaData.enabledProfessions or {}
    guideMetaData.enabledProfessions.Horde = guideMetaData.enabledProfessions.Horde or {}
    guideMetaData.enabledProfessions.Alliance = guideMetaData.enabledProfessions.Alliance or {}

end

local runtimeSubsystemsRegistered
local function RegisterRuntimeSubsystems()
    if runtimeSubsystemsRegistered then return end
    runtimeSubsystemsRegistered = true

    addon.runtime:Register({
        id = "settings",
        initialize = function()
            addon.services:Register("settings", addon.settings, "settings")
        end
    })
    addon.runtime:Register({
        id = "guide-ui",
        depends = {"settings"},
        initialize = function()
            addon.services:Register("guide-window", addon.RXPFrame)
        end
    })
    addon.runtime:Register({
        id = "guide-engine",
        depends = {"settings"},
        initialize = function()
            addon.services:Require("directives")
            addon.services:Require("guide-registry")
            addon.services:Require("guide-parser")
            addon.services:Require("guide-conditions")
            addon.services:Require("guide-state")
            local valid, errorText = addon.directives:ValidateLegacySurface()
            if not valid then error(errorText, 2) end
        end
    })
    addon.runtime:Register({
        id = "quest-engine",
        depends = {"guide-engine"},
        initialize = function()
            addon.services:Require("quest-accept-state")
            addon.services:Require("quest-cache")
            addon.services:Require("quest-automation")
            addon.services:Require("prerequisites")
        end,
        disable = function() addon.questAutomation:ResetTransient() end
    })

    local function RegisterOptional(id, label, instance, setup, dependencies)
        if not instance or type(setup) ~= "function" then return end
        addon.runtime:Register({
            id = id,
            label = label,
            depends = dependencies or {"settings"},
            optional = true,
            initialize = setup
        })
    end

    RegisterOptional("communications", "communications", addon.comms,
        function()
            addon.services:Register("communications", addon.comms, "comms")
            addon.comms:Setup()
        end)
    RegisterOptional("targeting", "targeting", addon.targeting,
        function()
            addon.services:Register("targeting", addon.targeting, "targeting")
            addon.targeting:Setup()
        end)
    RegisterOptional("talents", "talents", addon.talents,
        function()
            addon.services:Register("talents", addon.talents, "talents")
            addon.talents:Setup()
        end)
    if addon.settings.profile.enableTracker then
        RegisterOptional("leveling-tracker", "leveling tracker", addon.tracker,
            function()
                addon.services:Register("leveling-tracker", addon.tracker,
                                        "tracker")
                addon.tracker:SetupTracker()
            end)
    end
    RegisterOptional("tips", "tips", addon.tips,
        function()
            addon.services:Register("tips", addon.tips, "tips")
            addon.tips:Setup()
        end)
    RegisterOptional("vendor-treasures", "vendor treasures",
        addon.VendorTreasures, function()
            addon.services:Register("vendor-treasures", addon.VendorTreasures,
                                    "VendorTreasures")
            addon.VendorTreasures:Setup()
        end)
    RegisterOptional("item-upgrades", "item upgrades", addon.itemUpgrades,
        function()
            addon.services:Register("item-upgrades", addon.itemUpgrades,
                                    "itemUpgrades")
            addon.itemUpgrades:Setup()
        end)
    if addon.xpAssistant and addon.xpAssistant.Setup then
        addon.runtime:Register({
            id = "xp-assistant",
            label = "xp assistant",
            depends = {"settings", "guide-ui"},
            optional = true,
            initialize = function()
                addon.services:Register("xp-assistant", addon.xpAssistant,
                                        "xpAssistant")
                addon.xpAssistant:Setup()
            end,
            disable = function() addon.xpAssistant:Shutdown() end
        })
    end

    if addon.roadmap and addon.roadmap.Setup then
        addon.runtime:Register({
            id = "roadmap-features",
            phase = "post-guides",
            depends = {"settings", "guide-engine"},
            initialize = function() addon.roadmap:Setup() end
        })
    end
end

function addon:OnInitialize()
    -- Locale payloads are optional load-on-demand companion addons. Load the
    -- matching client pack before settings and guide UI begin rendering; a
    -- missing or disabled companion safely leaves the English presentation.
    if addon.guideLocalization and addon.guideLocalization.LoadCompanion then
        addon.guideLocalization:LoadCompanion()
    end

    local importGuidesDefault = {
        profile = {guides = {}, reports = {splits = {}}}
    }

    addon.db = LibStub("AceDB-3.0"):New("RXPDB", importGuidesDefault, 'global')
    RXPData = RXPData or {}
    RXPCData = RXPCData or {}

    -- SavedVariablesPerCharacter normally isolates this table. Keep an identity
    -- stamp as a second line of defence for 3.3.5 private-server clients which
    -- briefly reuse the previous character's Lua table while switching. Legacy
    -- saves migrate in place, except an unverified level-one save (the reported
    -- leakage case); an identity or GUID mismatch always starts clean.
    local characterIdentity = addon.GetCharacterIdentity()
    local characterGUID = UnitGUID("player")
    local identityMismatch = characterIdentity and RXPCData.characterIdentity and
                                 RXPCData.characterIdentity ~= characterIdentity
    local guidMismatch = characterGUID and RXPCData.characterGUID and
                             RXPCData.characterGUID ~= characterGUID
    local unverifiedLevelOneCharacter = characterIdentity and
                                            not RXPCData.characterGUID and
                                            UnitLevel("player") == 1
    if identityMismatch or guidMismatch or unverifiedLevelOneCharacter then
        RXPCData = {}
    end
    if characterIdentity then RXPCData.characterIdentity = characterIdentity end
    if characterGUID then RXPCData.characterGUID = characterGUID end

    if addon.roadmap and addon.roadmap.InitializeSavedData then
        addon.roadmap:InitializeSavedData()
    end

    local realm = _G.GetRealmName()
    RXPData.realmData = RXPData.realmData or {}
    local realmData = RXPData.realmData[realm] or {}
    RXPData.realmData[realm] = realmData
    addon.realmData = realmData


    local clientLocale = GetLocale()
    if type(RXPData.questNames) ~= "table" or
        RXPData.questNames.locale ~= clientLocale then
        -- Quest names are localized.  Changing locale invalidates only name
        -- data; guide metadata, selections, and character progress stay intact.
        RXPData.questNames = {locale = clientLocale}
        RXPCData.questNameCache = {}
    else
        RXPCData.questNameCache = type(RXPCData.questNameCache) == "table" and
                                      RXPCData.questNameCache or {}
    end
    RXPCData.questObjectivesCache = RXPCData.questObjectivesCache or {}
    RXPCData.questObjectivesCache[0] = RXPCData.questObjectivesCache[0] or 0

    if not RXPData.gameVersion then
        RXPData.gameVersion = gameVersion
    elseif math.floor(gameVersion / 1e4) ~=
        math.floor(RXPData.gameVersion / 1e4) then
        addon.db.profile.guides = {}
        RXPData.gameVersion = gameVersion
    end
    addon.settings:InitializeDatabase()
    addon.storage:Bind(RXPData, RXPCData, addon.settings.profile)
    local storageReady, storageError = addon.storage:Migrate()
    if not storageReady then error(storageError, 2) end
    addon.CreateMetaDataTable()
    addon.settings:InitializeSettings()

    RXPCData.completedWaypoints = RXPCData.completedWaypoints or {}
    addon.settings.profile.hardcore =
        addon.game == "CLASSIC" and addon.settings.profile.hardcore
    RXPCData.stepSkip = RXPCData.stepSkip or {}
    if not RXPCData.flightPaths or UnitLevel("player") <= 6 then
        RXPCData.flightPaths = {}
    end
    if RXPData.trainGenericSpells == nil then
        RXPData.trainGenericSpells = true
    end

    if _G.RXPOnInitialize then --Used for debugging purposes
        pcall(_G.RXPOnInitialize)
    end

    addon:ImportCustomThemes()
    addon:LoadActiveTheme()
    addon.settings:UpdateMinimapButton()
    addon.settings:SetupMapButton()
    addon.SetupGuideWindow()
    addon.RenderFrame()
    addon.SetupArrow()
    addon:CreateActiveItemFrame()
    -- Existing setup methods now run through a deterministic lifecycle graph.
    -- The safe-mode supervisor remains the failure boundary for optional code.
    RegisterRuntimeSubsystems()
    addon.runtime:InitializePhase("initialize")

    if addon.player.season == 2 then
        addon.settings.profile.phase = 6
    end

    addon.LoadCachedGuides()
    addon.runtime:InitializePhase("post-guides")
    addon.UpdateGuideFontSize()
    addon.isHidden = not addon.settings.profile.showEnabled or addon.settings.profile.hideGuideWindow
    addon.RXPFrame:SetShown(not addon.isHidden)
    addon.RXPFrame:SetScale(addon.settings.profile.windowScale)
    addon.arrowFrame:SetSize(32 * addon.settings.profile.arrowScale,
                             32 * addon.settings.profile.arrowScale)
    addon.arrowFrame.text:SetFont(addon.font,
                                  addon.settings.profile.arrowText, "OUTLINE")
    addon.activeItemFrame:SetScale(addon.settings.profile.activeItemsScale)
end

local function ClearCharacterGuideSelection()
    RXPCData.currentGuideGroup = nil
    RXPCData.currentGuideName = nil
    RXPCData.currentStep = nil
    RXPCData.currentStepId = nil
    RXPCData.stepSkip = {}
    RXPCData.completedWaypoints = {}
end

-- Apply the per-character guide selection from one place. 3.3.5 private-server
-- clients can finish swapping SavedVariables after ADDON_LOADED/OnEnable, so
-- this is intentionally safe to call again on the first real
-- PLAYER_ENTERING_WORLD event.
function addon:RestoreCharacterGuideProgress()
    local characterIdentity = addon.GetCharacterIdentity()
    local characterGUID = UnitGUID("player")
    if (characterIdentity and RXPCData.characterIdentity and
        RXPCData.characterIdentity ~= characterIdentity) or
        (characterGUID and RXPCData.characterGUID and
        RXPCData.characterGUID ~= characterGUID) then
        ClearCharacterGuideSelection()
    end
    if characterIdentity then RXPCData.characterIdentity = characterIdentity end
    if characterGUID then RXPCData.characterGUID = characterGUID end

    local savedGroup = RXPCData.currentGuideGroup
    local savedName = RXPCData.currentGuideName
    local hasSavedGuide = type(savedGroup) == "string" and savedGroup ~= "" and
                              type(savedName) == "string" and savedName ~= ""
    local guide = hasSavedGuide and addon.GetGuideTable(savedGroup, savedName)

    if guide then
        addon:LoadGuide(guide, true)
    else
        ClearCharacterGuideSelection()
        addon:LoadGuide(addon.emptyGuide)
    end
end

function addon:OnEnable()
    addon.LoadEmbeddedGuides()
    if addon.settings.profile.preLoadData then
        addon.LoadAllGuides()
    end
    addon.addonLoaded = true
    if addon.guideHub and addon.guideHub.setup and
        addon.guideHub.OnGuidesReady then
        addon.guideHub:OnGuidesReady()
    end
    if addon.activityPlanner and addon.activityPlanner.setup and
        addon.activityPlanner.OnGuidesReady then
        addon.activityPlanner:OnGuidesReady()
    end
    ProcessSpells()
    addon.GetProfessionLevel()
    addon:RestoreCharacterGuideProgress()
    if not addon.currentGuide then
        addon.RXPFrame:SetHeight(20)
        addon.RXPFrame.BottomFrame.UpdateFrame()
        addon.noGuide = true
    end
    --addon.RXPFrame.GenerateMenuTable()

    self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("QUEST_TURNED_IN")
    -- self:RegisterEvent("SKILL_LINES_CHANGED")
    self:RegisterEvent("TRAINER_CLOSED")
    self:RegisterEvent("TAXIMAP_OPENED")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("TRAINER_SHOW")
    self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("PLAYER_CONTROL_LOST")
    self:RegisterEvent("PLAYER_CONTROL_GAINED")

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LEAVING_WORLD")
    self:RegisterEvent("PLAYER_LOGOUT")

    if IsAddOnLoadOnDemand("Blizzard_Calendar") then
        self:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
    end
    self:RegisterEvent("ZONE_CHANGED")

    if addon.gameVersion > 90000 then
        self:RegisterEvent("COMPANION_LEARNED")
        self:RegisterEvent("COMPANION_UNLEARNED")
        self:RegisterEvent("COMPANION_UPDATE")
        self:RegisterEvent("NEW_PET_ADDED")
        self:RegisterEvent("TOYS_UPDATED")
    end

    -- self:RegisterEvent("QUEST_LOG_UPDATE")

    questFrame:RegisterEvent("QUEST_COMPLETE")
    questFrame:RegisterEvent("QUEST_PROGRESS")
    questFrame:RegisterEvent("QUEST_ACCEPT_CONFIRM")
    questFrame:RegisterEvent("QUEST_GREETING")
    questFrame:RegisterEvent("GOSSIP_SHOW")
    questFrame:RegisterEvent("QUEST_DETAIL")
    questFrame:RegisterEvent("QUEST_FINISHED")
    questFrame:RegisterEvent("QUEST_TURNED_IN")
    questFrame:RegisterEvent("QUEST_AUTOCOMPLETE")
    questFrame:RegisterEvent("QUEST_ACCEPTED")
    questFrame:RegisterEvent("QUEST_LOG_UPDATE")

    if C_QuestLog.RequestLoadQuestByID then
        self:RegisterEvent("QUEST_DATA_LOAD_RESULT")
    end

    addon.settings:LoadFramePositions()

    if addon.settings.profile.hideInRaid then
        addon:RegisterHideInRaidEvents()

        -- Check if reloading in raid
        addon.UpdateRaidVisibility()
    end

    if addon.game == "RETAIL" then
        local detectXPRateQueued = false
        self:RegisterEvent("PLAYER_FLAGS_CHANGED", function(_, unit)
            if detectXPRateQueued or unit ~= "player" then return end

            -- Warmode xp buff detection
            detectXPRateQueued = true
            C_Timer.After(1.5, function()
                addon.settings:DetectXPRate()
                detectXPRateQueued = false
            end)
        end)
    elseif addon.gameVersion > 30000 then
        local detectXPRateQueued = false
        self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", function(_, slot)
            if detectXPRateQueued then return end

            -- Abort if not chest/shoulders (addon.heirlooms isn't defined for the
            -- WotLK DB, so guard against nil).
            if not addon.heirlooms or not addon.heirlooms[slot] then
             return
            end

            detectXPRateQueued = true
            C_Timer.After(3, function()
                addon.settings:DetectXPRate()
                detectXPRateQueued = false
            end)
        end)
    end

    -- Only start update loop after everything initializes and enables
    addon.tickers:SetupTickerLoops()
    addon.runtime:EnableAll()

    RXPData.release = addon.release
    RXPData.cacheVersion = cacheVersion
end

function addon:OnDisable()
    addon.scheduler:CancelOwner(CORE_TICKER_OWNER)
    addon.runtime:DisableAll()
end

-- Tracks if a player is on a loading screen and pauses the main update loop
-- Some information is not available during zone transitions
function addon:PLAYER_ENTERING_WORLD(event, isInitialLogin)
    if addon.gameVersion == 30300 and event == "PLAYER_ENTERING_WORLD" then
        local identity = addon.GetCharacterIdentity()
        if identity and addon.characterGuideRestoreIdentity ~= identity and
            addon.characterGuideRestorePending ~= identity then
            addon.characterGuideRestorePending = identity
            C_Timer.After(0.10, function()
                if addon.GetCharacterIdentity() ~= identity then return end
                addon.characterGuideRestorePending = nil
                addon:RestoreCharacterGuideProgress()
                addon.characterGuideRestoreIdentity = identity
            end)
        end
    end
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and RXPCData then
        RXPCData.GA = false
    end
    addon.hideArrow = false
    addon.UpdateMap()
    addon.isHidden = addon.settings and
                         addon.settings.profile.hideGuideWindow or
                         not (addon.RXPFrame and addon.RXPFrame:IsShown())

    C_Timer.After(2, function()
        if addon.gameVersion ~= 30300 and addon.LoadDefaultGuide and
            addon.currentGuide.empty then
            addon.LoadDefaultGuide()
        end
    end)

    if isInitialLogin then
        C_Timer.After(4, function()
            addon.settings:DetectXPRate()
        end)

        C_Timer.After(20, function()
            addon.settings:CheckAddonCompatibility()
        end)
    end
    if addon.RXPFrame:IsShown() and WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and
                UnitLevel("player") == 1 and
                (not addon.currentGuide or addon.currentGuide.empty) then
        addon.startHardcoreIntroUI()
    end
    addon.targeting:Setup()
end
--addon:LoadGuideTable(addon.defaultGroupHC, addon.defaultGuideHC)
function addon:PLAYER_LEAVING_WORLD() addon.isHidden = true end

-- Sent when the player logs out or the UI is reloaded, just before SavedVariables are saved
function addon:SaveCharacterGuideProgress()
    local characterIdentity = addon.GetCharacterIdentity()
    local characterGUID = UnitGUID("player")
    if characterIdentity then RXPCData.characterIdentity = characterIdentity end
    if characterGUID then RXPCData.characterGUID = characterGUID end
    local guide = addon.currentGuide
    local validGuide = guide and not guide.empty and
                           type(guide.group) == "string" and guide.group ~= "" and
                           type(guide.name) == "string" and guide.name ~= "" and
                           type(guide.steps) == "table" and #guide.steps > 0

    if not validGuide then
        -- Empty/welcome state is intentional for a character which has never
        -- selected a guide. Do not serialize a synthetic step 1 as a selection.
        RXPCData.currentGuideGroup = nil
        RXPCData.currentGuideName = nil
        RXPCData.currentStep = nil
        RXPCData.currentStepId = nil
        return
    end

    local step = tonumber(RXPCData.currentStep)
    if not step or step < 1 or step > #guide.steps or
        step ~= math.floor(step) then step = 1 end

    RXPCData.currentGuideGroup = guide.group
    RXPCData.currentGuideName = guide.name
    RXPCData.currentStep = step
    RXPCData.currentStepId = guide.steps[step].stepId
    if addon.guideState and addon.guideState.SaveCurrent then
        addon.guideState:SaveCurrent()
    end
end

function addon:PLAYER_LOGOUT()
    addon:SaveCharacterGuideProgress()
    addon.settings:SaveFramePositions()
end

function addon:CALENDAR_UPDATE_EVENT_LIST()
    -- Required by .dmf
    addon.calendarLoaded = true
end

function addon:GET_ITEM_INFO_RECEIVED(_, itemNumber, success)
    if not success then return end

    if addon.itemQueryList[itemNumber] then
        addon.itemQueryList[itemNumber] = nil
        addon.updateStepText = true
    elseif GetTime() - startTime < 15 then
        addon.updateStepText = true
    end
end

function addon:ZONE_CHANGED() addon.UpdateMap() end

function addon:BAG_UPDATE_DELAYED(...) addon.UpdateItemFrame() end

function addon:PLAYER_REGEN_ENABLED(...) addon.UpdateItemFrame() end

function addon:QUEST_TURNED_IN(_, questId, xpReward)
    -- scryer/aldor quest
    addon.recentTurnIn[questId] = GetTime()
    if questId == 10551 or questId == 10552 then
        local mapId = addon.GetMapId('Shattrath City')
        for _, point in pairs(addon.activeWaypoints) do
            if point.zone == mapId then
                return C_Timer.After(1, function()
                    addon.ReloadGuide()
                end)
            end
        end
    end
end

function addon:SKILL_LINES_CHANGED(...) addon.UpdateSkillData() end

function addon:TRAINER_SHOW(...)
    trainerUpdate = GetTime()
    OnTrainer()
    if not addon.trainerFrame then
        addon.trainerFrame = CreateFrame("Frame", "RXPGuidesTrainerFrame",
                                         UIParent)
    end

    addon.trainerFrame:SetScript("OnUpdate", trainerFrameUpdate)
end

function addon:TRAINER_CLOSED(...) addon.trainerFrame:SetScript("OnUpdate", nil) end

function addon:PLAYER_LEVEL_UP(_, level)
    if not addon.currentGuide then return end

    ProcessSpells()
    --sod p2
    if addon.settings.profile.season == 3 and level == 25 then
        addon.RXPFrame.GenerateMenuTable()
        addon.ReloadGuide()
    --[[else
        local stepn = RXPCData.currentStep
        -- addon:LoadGuide(addon.currentGuide)
        addon.SetStep(1)
        addon.SetStep(stepn)]]
    end

    addon.player.level = level
end

function addon:UNIT_PET(_, unit)
    if unit ~= "player" then return end
    addon.petFamily = GetPetIcon() or addon.petFamily
end

function addon:QUEST_DATA_LOAD_RESULT(_, questId, success)
    if not success then return end

    addon.requestQuestInfo[questId] = 0
    addon.updateStepText = true
end

function addon:GROUP_LEFT(_, force)
    if not force and not addon.settings.profile.hideInRaid then return end

    if not addon.settings.profile.showEnabled then return end

    for _, frame in pairs(addon.enabledFrames) do
        local shown, isSecure = frame.IsFeatureEnabled()
        if not (isSecure and InCombatLockdown()) then
            frame:SetShown(shown)
        end
    end
end

function addon:COMPANION_LEARNED(...) addon.UpdateItemFrame() end

function addon:COMPANION_UNLEARNED(...) addon.UpdateItemFrame() end

function addon:COMPANION_UPDATE(...) addon.UpdateItemFrame() end

function addon:NEW_PET_ADDED(...) addon.UpdateItemFrame() end

function addon:TOYS_UPDATED(...) addon.UpdateItemFrame() end

function addon.HideInRaid()
    if not addon.settings.profile.hideInRaid then return end

    if not UnitInRaid("player") then return end

    for _, frame in pairs(addon.enabledFrames) do
        if not frame:IsForbidden() then frame:Hide() end
    end
end

questFrame:SetScript("OnEvent", addon.QuestAutomation)

function addon.GetGuideTable(guideGroup, guideName)
    local index = guideGroup and guideName and
        fmt("%s||%s",guideGroup,guideName) or guideGroup or 0
    return addon.guides[index]
end

addon.scheduledTasks = {}

function addon.UpdateScheduledTasks()
    if not next(addon.scheduledTasks) then return end
    local cTime = GetTime()
    local processTable = {}
    for ref, args in pairs(addon.scheduledTasks) do
        processTable[ref] = args
    end
    for ref, args in pairs(processTable) do
        --print(unpack(args))
        --print(type(ref))
        if type(ref) == "function" then
            if cTime > args[1] then
                local t = args
                --print('u',ref,cTime-0.125,unpack(args))
                addon.scheduledTasks[ref] = nil
                ref(unpack(t))
                return
            end
        elseif type(ref) == "table" then
            if cTime > args then
                addon.scheduledTasks[ref] = nil
                local element = ref.element or ref
                if element and addon.functions[element.tag] then
                    addon.Call(element.tag,addon.functions[element.tag],ref)
                end
                return
            end
        end
    end
end

function addon.ScheduleTask(self, ref, ...)
--    print('w',ref)
    local updateFrequency = 0.075

    if addon.settings.profile and addon.settings.profile.updateFrequency then
        local milliseconds = addon.settings.profile.updateFrequency
        if addon.GetEffectiveUpdateFrequency then
            milliseconds = addon.GetEffectiveUpdateFrequency(milliseconds)
        end
        updateFrequency = milliseconds / 1000
    end
    local time = type(self) == "number" and self or GetTime() + updateFrequency
    --print(type(ref))

    if type(ref) == "table" then
        addon.scheduledTasks[ref] = time
    elseif type(ref) == "function" then
        local args = addon.scheduledTasks[ref]
        if args then
            args[1] = time
        elseif not args then
            addon.scheduledTasks[ref] = {time, ...}
        end
    end
end

addon.updateActiveQuest = {}
addon.updateInactiveQuest = {}

local stepCounter = 1
local batchSize = 5
local updateTimer = GetTime()
--local cycleStart = GetTime()

local skip = 0
local updateError
local errorCount = 0
local event = ""

function addon.LegacyUpdateLoop()
    -- NewTicker calls function every updateFrequency, making diff/updateTick/tickRate logic obsolete
    if updateError then
        errorCount = errorCount + 1
    end

    local shouldContinue = addon.tickers:ShouldContinue()

    if not shouldContinue then return shouldContinue end

    updateError = true
    local guideLoaded
    local activeQuestUpdate = 0
    skip = skip + 1
    event = ""

    if not addon.loadNextStep then
        for ref, func in pairs(addon.updateActiveQuest) do
            addon.Call("updateQuest",func,ref)
            activeQuestUpdate = activeQuestUpdate + 1
            addon.updateActiveQuest[ref] = nil
            -- print('f',ref.element.step.index,math.random())
        end

        if activeQuestUpdate > 0 then event = event .. "/activeQ" end
    end

    if addon.nextStep then
        skip = 1
        addon.SetStep(addon.nextStep)
        addon.questAutoAccept = true
        addon.updateBottomFrame = true
        addon.nextStep = false
    elseif addon.loadNextStep then
        local holdForParty = addon.partySync and
                                 addon.partySync:ShouldHoldAdvance()
        if holdForParty then
            skip = 1
        else
            addon.loadNextStep = false
            -- Browse mode (/rxp browse) freezes progression so the user can
            -- navigate back without it auto-advancing to the real position.
            if not addon.browseMode then
                event = event .. "/loadNext"
                addon.SetStep(RXPCData.currentStep + 1)
                addon.questAutoAccept = true
                skip = 1
                addon.updateBottomFrame = true
            end
        end
    elseif activeQuestUpdate == 0 then
        if addon.updateSteps then
            event = event .. "/stepComplete"

            addon.UpdateStepCompletion()
        elseif addon.updateStepText and addon.currentGuide and skip % 2 == 0 then
            event = event .. "/textsingle"

            addon.updateStepText = false
            local updateText
            local steps = addon.currentGuide.steps
            local update = {}

            for n in pairs(addon.stepUpdateList) do
                tinsert(update,n)
            end

            for _,n in pairs(update) do
                if steps[n] then
                    if not updateText and steps[n].active then
                        updateText = true
                    end
                    addon.RXPFrame.BottomFrame.UpdateFrame(nil, n)
                    if not addon.updateStepText then
                        addon.stepUpdateList[n] = nil
                    end
                end
            end

            if updateText or addon.updateTipWindow then
                addon.updateTipWindow = false
                addon.RXPFrame.CurrentStepFrame.UpdateText()
            end
        elseif addon.updateBottomFrame then
            event = event .. "/bottomFrame"

            errorCount = 0
            addon.RXPFrame.BottomFrame.UpdateFrame()
            addon.RXPFrame.SetStepFrameAnchor()
            updateError = false
            skip = 1

            return 'bottomFrame'
        elseif skip % 2 == 1 and next(addon.guideCache) then
            event = event .. "/cache"
            local length = 0
            local loadGuide = true

            for _,guide in pairs(addon.guides) do
                if (loadGuide or guide.disablecaching) and not guide.steps then
                    addon:FetchGuide(guide)
                    guideLoaded = true
                    length = length + (tonumber(guide.length) or 0)
                    --print('f',not guide.steps and guide.name)
                    if length > 45000 or GetFramerate() < 60 then
                        loadGuide = false
                    end
                end
            end

            if not next(addon.guideCache) and RXPCData.guideMetaData.enabledDungeons then
                RXPCData.guideMetaData.enabledDungeons[addon.player.faction] =
                    addon.dungeons or
                    RXPCData.guideMetaData.enabledDungeons[addon.player.faction]
            end
        end
    end

    if not guideLoaded and addon.currentGuide then
        event = event .. "/istep"
        local max = #addon.currentGuide.steps
        local offset = RXPCData.currentStep + 1
        if stepCounter == offset then
            stepCounter = stepCounter + 8
        end

        addon.RXPFrame.BottomFrame.UpdateFrame(nil,offset + stepCounter % 8)

        for n = stepCounter,stepCounter + batchSize - 1 do
            addon.RXPFrame.BottomFrame.UpdateFrame(nil,n)
        end
        stepCounter = stepCounter + batchSize
        if stepCounter > max then
            local time = GetTime()
            local tdiff = time - updateTimer
            stepCounter = 1
            --print(tdiff,batchSize)

            if tdiff > 10 then
                batchSize = math.min(batchSize + 1*(math.ceil(tdiff/8)),10)
            elseif batchSize > 2 then
                batchSize = batchSize - 1
            end

            updateTimer = time
            skip = skip % 4096
        end

    end

    updateError = false
end

addon.tickers = {}
function addon.tickers:SetupTickerLoops()
    local updateFrequency = 0.075

    if addon.settings.profile and addon.settings.profile.updateFrequency then
        local milliseconds = addon.settings.profile.updateFrequency
        if addon.GetEffectiveUpdateFrequency then
            milliseconds = addon.GetEffectiveUpdateFrequency(milliseconds)
        end
        updateFrequency = milliseconds / 1000
    end

    local jitter = {
        [0] = updateFrequency + math.random(0.001, 0.01),
        [3] = updateFrequency * 3 + math.random(0.003, 0.03),
        [4] = updateFrequency * 4 + math.random(0.004, 0.04),
        [16] = updateFrequency * 16 + math.random(0.016, 0.16),
        [30] = updateFrequency * 30 + math.random(0.03, 0.3)
    }

    if not self.legacy then
        self.legacy = addon.scheduler:Ticker(CORE_TICKER_OWNER, "legacy",
                                             updateFrequency,
                                             addon.LegacyUpdateLoop)
    end

    if not self.cycleZero then
        -- skip % 4 == 0
        self.cycleZero = addon.scheduler:Ticker(CORE_TICKER_OWNER, "cycleZero",
                                                jitter[0], self.CycleZero)
    end

    if not self.cycleThree then
        -- skip % 4 == 2
        self.cycleThree = addon.scheduler:Ticker(CORE_TICKER_OWNER,
                                                 "cycleThree", jitter[3],
                                                 self.CycleThree)
    end

    if not self.cycleFour then
        -- skip % 4 == 3
        self.cycleFour = addon.scheduler:Ticker(CORE_TICKER_OWNER, "cycleFour",
                                                jitter[4], self.CycleFour)
    end

    if not self.cycleSixteen then
        -- skip % 16 == 1
        self.cycleSixteen = addon.scheduler:Ticker(CORE_TICKER_OWNER,
                                                   "cycleSixteen", jitter[16],
                                                   self.CycleSixteen)
    end

    if not self.cycleThirty then
        -- skip % 32 == 29
        self.cycleThirty = addon.scheduler:Ticker(CORE_TICKER_OWNER,
                                                  "cycleThirty", jitter[30],
                                                  self.CycleThirty)
    end

end

function addon.UpdateRaidVisibility()
    if UnitInRaid("player") then
        addon.HideInRaid()
    else
        addon:GROUP_LEFT()
    end
end

function addon:RegisterHideInRaidEvents()
    if addon.gameVersion == 30300 then
        addon:RegisterEvent("PARTY_MEMBERS_CHANGED", addon.UpdateRaidVisibility)
        addon:RegisterEvent("RAID_ROSTER_UPDATE", addon.UpdateRaidVisibility)
    else
        addon:RegisterEvent("GROUP_JOINED", addon.HideInRaid)
        addon:RegisterEvent("GROUP_FORMED", addon.HideInRaid)
        addon:RegisterEvent("GROUP_LEFT")
    end
end

function addon:UnregisterHideInRaidEvents()
    if addon.gameVersion == 30300 then
        addon:UnregisterEvent("PARTY_MEMBERS_CHANGED")
        addon:UnregisterEvent("RAID_ROSTER_UPDATE")
    else
        addon:UnregisterEvent("GROUP_JOINED")
        addon:UnregisterEvent("GROUP_FORMED")
        addon:UnregisterEvent("GROUP_LEFT")
    end
end

function addon.tickers:RestartTickerLoops()
    local tickerNames = {
        "legacy", "cycleZero", "cycleThree", "cycleFour",
        "cycleSixteen", "cycleThirty"
    }
    addon.scheduler:CancelOwner(CORE_TICKER_OWNER)
    for _, name in ipairs(tickerNames) do self[name] = nil end
    self:SetupTickerLoops()
end

function addon.tickers:ShouldContinue()
    if addon.isHidden then
        updateError = false
        --print('hidden')
        return false, 'hidden'
    end

    if errorCount >= 10 then
        -- TODO revise lastEvent = event for multiple-tickers
        addon.lastEvent = event

        errorCount = 0
        updateError = false
        -- print('error')
        return false, 'error'
    end

    return true
end

function addon.tickers.CycleZero()
    local shouldContinue = addon.tickers:ShouldContinue()

    if not shouldContinue then return shouldContinue end

    event = event .. "/goto"
    addon.UpdateGotoSteps()
    -- event = event .. "/updateGoto"
end

function addon.tickers.CycleThree()
    local shouldContinue = addon.tickers:ShouldContinue()

    if not shouldContinue then return shouldContinue end

    if addon.questAutoAccept then
        addon.questAutoAccept = false
        event = event .. "/auto"
        addon.QuestAutomation()
    end

    if addon.updateMap then
        event = event .. "/map"
        addon.UpdateMap(true)
    end
end

function addon.tickers.CycleFour()
    local shouldContinue = addon.tickers:ShouldContinue()

    if not shouldContinue then return shouldContinue end

    if addon.ProcessMessageQueue() then return end

    event = event .. "/task"
    addon.UpdateScheduledTasks()
    addon.ClearQuestCache()
end

function addon.tickers.CycleSixteen()
    local shouldContinue = addon.tickers:ShouldContinue()

    if not shouldContinue then return shouldContinue end

    event = event .. "/inactiveQ"
    local count = math.min(#addon.updateInactiveQuest, 3)
    for i = 1, count do
        -- print('ok',addon.updateInactiveQuest[i].element.step.index,addon.updateInactiveQuest[i].element.requestFromServer)
        addon.UpdateQuestCompletionData(addon.updateInactiveQuest[i])
    end
    for i = count, 1, -1 do
        table.remove(addon.updateInactiveQuest, i)
    end
end

function addon.tickers.CycleThirty()
    local shouldContinue = addon.tickers:ShouldContinue()

    if not shouldContinue then return shouldContinue end

    event = event .. "/toptext"
    addon.RXPFrame.CurrentStepFrame.UpdateText()
end

function addon.HardcoreToggle()
    local guide = addon.currentGuide
    local hc = addon.settings.profile.hardcore

    if addon.game == "CLASSIC" then
        if not (guide and
                (guide.hardcore and hc or guide.softcore and not hc)) then
            addon.settings.profile.hardcore = not hc
        end
        if hc ~= addon.settings.profile.hardcore then
            addon.RenderFrame()
        end
    end
end

function addon.GAToggle()
    if RXPCData and addon.farmGuides > 0 then
        if addon.goldAssistant and addon.goldAssistant.ToggleMode then
            addon.goldAssistant:ToggleMode()
        else
            RXPCData.GA = not RXPCData.GA
            addon.RenderFrame()
        end
    end
end

addon.stepLogic = {}

function addon.stepLogic.AldorScryerCheck(faction)
    if addon.game == "CLASSIC" then return true end
    local _, _, _, _, _, aldorRep = addon.GetFactionInfoByID(932)
    local _, _, _, _, _, scryerRep = addon.GetFactionInfoByID(934)

    if aldorRep and scryerRep then
        if type(faction) == "table" then
            if faction.aldor then
                faction = "Aldor"
            elseif faction.scryer then
                faction = "Scryer"
            end
        end
        if faction == "Aldor" then
            return (aldorRep > scryerRep)
        elseif faction == "Scryer" then
            return (aldorRep < scryerRep)
        end
    end
    return true
end

function addon.stepLogic.PhaseCheck(phase)

    if type(phase) == "table" then phase = phase.phase end

    local currentPhase = addon.settings.profile.phase or 6

    if phase and currentPhase then
        local pmin, pmax
        pmin, pmax = phase:match("(%d+)%-(%d+)")
        if pmax then
            pmin = tonumber(pmin)
            pmax = tonumber(pmax)
        else
            pmin = tonumber(phase)
            pmax = 0xffff
        end
        if pmin and currentPhase >= pmin and currentPhase <= pmax then
            return true
        else
            return false
        end
    end

    return true
end

function addon.stepLogic.DailyCheck(step)
    return not (step.daily and RXPCData.skipDailies)
end

function addon.IsStepShown(step,...)
    local isShown = true
    local ignoreEntry = {}
    for _,entry in pairs({...}) do
        ignoreEntry[entry] = true
    end
    for name,check in pairs(addon.stepLogic) do
        if not ignoreEntry[name] then
            isShown = isShown and check(step)
        end
    end
    return isShown
end

function addon.stepLogic.GroupCheck(step)
    if (not addon.settings.profile.enableGroupQuests and step.group) or
        (addon.settings.profile.enableGroupQuests and step.solo) then
        return false
    end
    return true
end

function addon.stepLogic.AHCheck(step)
    if (not addon.settings.profile.soloSelfFound and step.ssf) or
        (addon.settings.profile.soloSelfFound and step.ah) then
        return false
    end
    return true
end

--MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]--not working on cata beta
function addon.stepLogic.LoremasterCheck(step)
    local loremaster
    if addon.gameVersion < 50000 then
       loremaster = addon.game == "WOTLK" and addon.settings.profile.northrendLM or
                     addon.game == "CATA" and addon.settings.profile.loremasterMode
    elseif addon.gameVersion < 60000 then
        loremaster = addon.settings.profile.loremasterMode or UnitLevel('player') == addon.player.maxlevel
    end

    if step.questguide and not loremaster or step.speedrunguide and loremaster then
        return false
    end
    return true
end

function addon.stepLogic.SeasonCheck(step)
    local currentSeason = addon.settings.profile.season or 0
    local SoM = currentSeason == 1
    --sod p2
    --[[if currentSeason == 2 and UnitLevel("player") < 25 then
        SoM = true
    end]]
    --local SoD = currentSeason == 2
    if SoM and step.era or step.som and not SoM or SoM and
        addon.settings.profile.phase > 2 and step["era/som"] then
        return false
    end

    if step.season then
        for season in step.season:gmatch("[^,;%s]+") do
            if currentSeason == tonumber(season) then
                return true
            end
        end
        return false
    end

    return true
end

function addon.stepLogic.HardcoreCheck(step)
    local hc = addon.settings.profile.hardcore
    local hcserver = C_GameRules and C_GameRules.IsHardcoreActive and C_GameRules.IsHardcoreActive()
    if step.softcoreserver and hcserver or step.hardcoreserver and not hcserver then return false end
    if step.softcore and hc or step.hardcore and not hc then return false end
    return true
end

function addon.stepLogic.XpRateCheck(step)
    if step.xprate then
        local rate = addon.settings.profile.xprate or 1
        if addon.game == "CLASSIC" then
            rate = 1
            if addon.settings.profile.season == 1 then
                if addon.settings.profile.phase < 3 then
                    rate = 1.2
                else
                    rate = 1.5
                end
            elseif addon.settings.profile.enableBetaFeatures and addon.settings.profile.season == 2 then
                rate = 2.5
            elseif addon.settings.profile.season == 2 then
                rate = 1.5
                --local minLevel = tonumber(guide:sub(1,2))
                local maxLevel = addon.currentGuide and tonumber(addon.currentGuide.name:match("%d+%-(%d+)"))
                if UnitLevel('player') < 40 or (not step.elements or not maxLevel or maxLevel < 40) then
                    --print(minLevel,step.elements)
                    rate = 2.5
                end
            end
        end
        local xpmin, xpmax = 1, 0xfff

        step.xprate:gsub("^([<>]?)%s*(%d+%.?%d*)%-?(%d*%.?%d*)",
                         function(op, arg1, arg2)
            if op == "<" then
                xpmin = 0
                xpmax = tonumber(arg1) - 1e-4
            elseif op == ">" then
                xpmin = tonumber(arg1) + 1e-4
                xpmax = 0xfff
            else
                xpmin = tonumber(arg1) or xpmin
                xpmax = tonumber(arg2) or 0xfff
            end
        end)

        if rate < xpmin or rate > xpmax then
            return false
        end
    end

    return true
end

function addon.IsFreshAccount()
    if C_PlayerInfo and C_PlayerInfo.CanPlayerEnterChromieTime then
        local manualOverride = addon.settings.profile.chromieTime
        if not manualOverride or manualOverride == "auto" then
            return not C_PlayerInfo.CanPlayerEnterChromieTime()
        elseif manualOverride == "disabled" then
            return true
        end
    end
end

function addon.stepLogic.FreshAccountCheck(step)
    local level = UnitLevel("player")
    local maxLevelFresh = step.fresh and tonumber(step.fresh) or 1000
    local maxLevelVeteran = step.veteran and tonumber(step.veteran) or 1000
    local fresh = addon.IsFreshAccount()

    if not (step.fresh or step.veteran) then
        return true
    elseif (step.fresh and level <= maxLevelFresh) and fresh then
        return true
    elseif (step.veteran and level <= maxLevelVeteran) and not fresh then
        return true
    end

    return false
end

function addon.stepLogic.LevelCheck(step)
    if not addon.settings.profile.enableXpStepSkipping then return true end

    local level = UnitLevel("player")
    local maxLevel = tonumber(step.maxlevel) or 1000
    if level <= maxLevel then return true end
end

function addon.stepLogic.DungeonCheck(step)
    local dungeon = step.dungeon
    local dskip = step.dungeonskip
    --print(dungeon,dskip)
    if dskip and addon.settings.profile.dungeons[dskip] then
        return false
    elseif dungeon and dungeon ~= dskip and addon.settings.profile.dungeons[dungeon] then
        return true
    elseif not dungeon then
        return true
    end
end

function addon.stepLogic.ProfessionCheck(step)
    local profession = step.profession
    local pskip = step.professionskip
    --print(dungeon,dskip)
    if not addon.settings.profile.professions then
        return true
    elseif pskip and addon.settings.profile.professions == pskip then
        return false
    elseif profession and profession ~= pskip and addon.settings.profile.professions == profession then
        return true
    elseif not profession then
        return true
    end
end

addon.facade:ExposeGlobal("RXP", addon) -- legacy debug/macro compatibility
