local addonName, addon = ...

local _G = _G
local C_Timer = addon.timer

local GetNumQuests = addon.questLog.GetNumQuestLogEntries or
                         _G.GetNumQuestLogEntries
local LegacyGetQuestLogTitle = _G.RXPCompatGetQuestLogTitle
local GetQuestLogTitle = addon.questLog.GetInfo or LegacyGetQuestLogTitle or
                             _G.GetQuestLogTitle

local function PositiveQuestID(value)
    value = tonumber(value)
    if value and value > 0 then return value end
end

local function GetLegacyQuestIDAtIndex(index)
    if type(LegacyGetQuestLogTitle) == "function" then
        return PositiveQuestID(select(8, LegacyGetQuestLogTitle(index)))
    end
    if type(_G.GetQuestLogTitle) ~= "function" then return nil end

    -- AzerothCore 3.3.5 exposes questID at #9; later legacy clients may expose
    -- it at #8. Prefer #9 so the stock isDaily value cannot be mistaken for an
    -- ID, then retain the later-client fallback for shared code paths.
    local _, _, _, _, _, _, _, eighth, ninth = _G.GetQuestLogTitle(index)
    return PositiveQuestID(ninth) or PositiveQuestID(eighth)
end

local L = addon.locale.Get
local maxQuests = 25
if addon.game == "CLASSIC" then
    maxQuests = 20
end

local lastIndex

function addon.UpdateQuestButton(index)
    if type(index) ~= 'number' or index > maxQuests then
        index = lastIndex or
            _G.GetQuestLogSelection and _G.GetQuestLogSelection()
    end
    --print(maxQuests)
    if not index then return end
    local button = addon.questLogButton
    local anchor = _G.QuestLogExDetailScrollChildFrame or
                       _G.QuestLogDetailScrollChildFrame
    if not anchor or anchor:IsForbidden() then return end
    if not button then
        button = CreateFrame("Button", "$parentRXP", anchor)
        button:SetWidth(32)
        button:SetHeight(32)
        button:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", 0, 0)
        button:SetNormalTexture(addon.GetTexture("rxp_logo-64"))
        addon.questLogButton = button

        local function tpOnEnter(self)
            if self:IsForbidden() or _G.GameTooltip:IsForbidden() then
                return
            end
            _G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -10)
            _G.GameTooltip:ClearLines()
            _G.GameTooltip:AddLine(self.tooltip)
            _G.GameTooltip:Show()
        end
        local function tpOnLeave(self)
            if self:IsForbidden() or _G.GameTooltip:IsForbidden() then
                return
            end
            _G.GameTooltip:Hide()
        end
        button:SetScript("OnEnter", tpOnEnter)
        button:SetScript("OnLeave", tpOnLeave)

    end
    local questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete,
          frequency, questID = (_G.RXPCompatGetQuestLogTitle or _G.GetQuestLogTitle)(index);
    local showButton
    local function GetGuideList(list,qid)
        -- local guides = {}
        local output = ""
        local groups = {}
        local guides = {}
        for _, entry in pairs(list) do
            local step = entry.step
            if not entry.guide.lowPrio and
                 addon.IsGuideActive(entry.guide) and
                  addon.IsStepShown(step,"GroupCheck") and
                  (step.group or addon.stepLogic.GroupCheck(step)) then
                    --print(entry.guide.name,entry.guide.lowPrio)
                if not guides[entry.group] then
                    guides[entry.group] = {}
                    table.insert(groups, entry.group)
                end
                local solo = step.solo or not step.group
                local grpTbl = guides[entry.group]
                grpTbl[entry.name] = grpTbl[entry.name] or solo
                --print(entry.name,entry.group,solo,qid)
            end
        end
        table.sort(groups)
        for _, group in ipairs(groups) do
            local guideList = {}
            for guide,solo in pairs(guides[group]) do
                local suffix = ""
                if not solo then
                    suffix = L" (Group)"
                end
                table.insert(guideList, guide .. suffix)
            end
            table.sort(guideList)
            output = output .. "\n   " .. group .. ":"
            for _, guide in ipairs(guideList) do
                output = output .. "\n     " .. guide
            end
        end
        return output
    end

    if questID then
        local tooltip = ""
        local separator = ""
        if addon.pickUpList[questID] then
            local pickUpList = GetGuideList(addon.pickUpList[questID],questID)
            if pickUpList ~= "" then
                tooltip = format("%s%s%s%s|r%s", tooltip, addon.icons.accept,
                                 addon.colors.tooltip,
                                 L("Quest is being picked up at"), pickUpList)
                showButton = true
                separator = "\n\n"
            end
        end
        if addon.turnInList[questID] then
            local turnInList = GetGuideList(addon.turnInList[questID],questID)
            if turnInList ~= "" then
                tooltip = format("%s%s%s%s%s|r%s", tooltip, separator,
                                 addon.icons.turnin, addon.colors.tooltip,
                                 L("Quest is being turned in at"), turnInList)
                showButton = true
            end
        end

        -- Only evaluates true on first load
        -- addon.orphanedList is updated when QuestLogFrame opens/closes
        if not addon.orphanedList or (addon.questRouteInspection and not addon.questRouteInspection:IsReady()) then
            addon.GetOrphanedQuests()
        end

        -- If showButton, then it's a pickUp or turnIn, without the table lookup cost
        if not showButton and addon.orphanedList and addon.orphanedList[questID] then
            tooltip = format("%s%s%s%s%s|r", tooltip, separator,
                                addon.icons.error, addon.colors.tooltip,
                                L("Quest is not part of any guide"))

            button:SetNormalTexture("Interface/AddOns/" .. addonName ..
                                        "/Textures/orphaned_quest-64")
            showButton = true
        else
            -- Inefficient, but set back to default texture in case of orphans
            button:SetNormalTexture(addon.GetTexture("rxp_logo-64"))
        end
        button.tooltip = tooltip
    end

    if showButton then
        lastIndex = index
        button:Show()
    else
        button:Hide()
    end
end

if _G.QuestLog_SetSelection then
    hooksecurefunc("QuestLog_SetSelection", addon.UpdateQuestButton)
end

-- Debug function, helps finding out quest log problems on a given guide
--Returns the expected quest log and a list of quest that will be turend in later
--This will run from the 1st guide to the point where you are now, counting the accept/turn in steps in order to determine the quest log state
--After determining the expected quest log, it will run from the current step forward, counting existing turn in steps for the quests in your quest log currently

--Guides have a lot of optional steps of the like: Turn in this quest if you have completed it, otherwise do it later

local stepIndex = 0
local guideKey,qLogCache,futureTurnInsCache
-- Only the orphan/expected-log inspection yields. Explicit debugging calls to
-- GetQuestLog keep their synchronous contract; no directive actions run here.
local inspection = {revision = 0}
addon.questRouteInspection = inspection
local BuildExpectedQuestLog
local routeSettings = {"hardcore", "soloSelfFound", "enableGroupQuests", "phase",
    "season", "xprate", "professions", "northrendLM", "loremasterMode",
    "enableXpStepSkipping", "enableBetaFeatures", "chromieTime"}

local function Context()
    local profile = addon.settings.profile
    local guide = addon.currentGuide
    local group = guide and addon.guideList[guide.group]
    local context = {refs = setmetatable({guide, profile}, {__mode = "v"}),
        signature = guide and guide.sourceSignature, step = RXPCData.currentStep,
        revision = inspection.revision, level = UnitLevel("player"),
        skipDailies = RXPCData.skipDailies, gold = RXPCData.GA,
        start = group and group.defaultGuide_, values = {}, dungeons = {}}
    for _, key in ipairs(routeSettings) do context.values[key] = profile[key] end
    for key, value in pairs(profile.dungeons or {}) do context.dungeons[key] = value end
    return context
end

local function Current(context)
    local guide, profile = addon.currentGuide, addon.settings.profile
    local group = guide and addon.guideList[guide.group]
    if not context or not guide or context.refs[1] ~= guide or context.refs[2] ~= profile or
        context.signature ~= guide.sourceSignature or context.step ~= RXPCData.currentStep or
        context.revision ~= inspection.revision or context.level ~= UnitLevel("player") or
        context.skipDailies ~= RXPCData.skipDailies or context.gold ~= RXPCData.GA or
        context.start ~= (group and group.defaultGuide_) then return false end
    for _, key in ipairs(routeSettings) do
        if context.values[key] ~= profile[key] then return false end
    end
    for key, value in pairs(profile.dungeons or {}) do
        if context.dungeons[key] ~= value then return false end
    end
    for key, value in pairs(context.dungeons) do
        if (profile.dungeons or {})[key] ~= value then return false end
    end
    return true
end

function inspection:Release()
    for _, release in pairs(self.owners or {}) do release() end
    self.owners, self.worker = nil, nil
end

function inspection:IsReady()
    return self.status == "ready" and Current(self.context)
end

function inspection:StatusText()
    return self.status == "error" and L("Quest inspection is unavailable. No quests were abandoned.") or
        L("Quest inspection is pending. Please try again shortly.")
end

function inspection:Invalidate(restart)
    local pending = self.worker ~= nil
    addon.scheduler:CancelOwner(self)
    self:Release()
    self.revision = self.revision + 1
    self.context, self.status = nil, nil
    qLogCache, futureTurnInsCache, addon.orphanedList = nil, nil, nil
    if pending and restart ~= false then self:Request() end
end

function inspection:Own(guide)
    if guide and guide.key and addon.guideBodyCache and not self.owners[guide.key] then
        self.owners[guide.key] = addon.guideBodyCache:Retain(guide)
    end
    for key in pairs(guide and guide.bodyCacheDependencies335 or {}) do
        if addon.guideBodyCache and not self.owners[key] then
            self.owners[key] = addon.guideBodyCache:Retain({key = key})
        end
    end
end

local function InspectionBoundary(chapter)
    if inspection.runningWorker and coroutine.running() == inspection.runningWorker then
        if inspection.worker ~= inspection.runningWorker then error("Quest inspection cancelled", 0) end
        inspection.work = (inspection.work or 0) + 1
        if chapter or inspection.work >= 32 then
            inspection.work = 0
            coroutine.yield()
        end
    end
end

function inspection:Schedule()
    if not self.worker or addon.scheduler:Has(self, "slice") then return end
    if addon.questRewardTransaction and addon.questRewardTransaction.active then return end
    addon.scheduler:AfterCombat(self, "slice", function()
        if addon.PerfInvoke then addon.PerfInvoke("quest route inspection", self.RunSlice, self)
        else self:RunSlice() end
    end)
end

function inspection:RunSlice()
    if not self.worker then return end
    if not Current(self.context) then self:Invalidate(); return end
    if _G.InCombatLockdown and _G.InCombatLockdown() then self:Schedule(); return end
    if addon.questRewardTransaction and addon.questRewardTransaction.active then return end
    local worker = self.worker
    self.runningWorker = worker
    local ok, quests, future = coroutine.resume(worker)
    self.runningWorker = nil
    if self.worker ~= worker then return end -- invalidated by a synchronous callback
    if not ok then
        self.status = "error"
        self:Release()
        if _G.geterrorhandler then _G.geterrorhandler()(quests) end
        return
    end
    if coroutine.status(self.worker) ~= "dead" then self:Schedule(); return end
    if not Current(self.context) then self:Invalidate(); return end
    qLogCache, futureTurnInsCache = quests or {}, future or {}
    self.status = "ready"
    self:Release()
    addon.orphanedList = nil
    if addon.UpdateQuestButton then addon:ScheduleTask(addon.UpdateQuestButton) end
    local registry = LibStub and LibStub("AceConfigRegistry-3.0", true)
    if registry and registry.NotifyChange then registry:NotifyChange(addon.title) end
end

function inspection:Request()
    if Current(self.context) then self:Schedule(); return end
    addon.scheduler:CancelOwner(self)
    self:Release()
    qLogCache, futureTurnInsCache, addon.orphanedList = nil, nil, nil
    self.context, self.status, self.owners, self.work = Context(), "pending", {}, 0
    if not addon.currentGuide or not addon.currentGuide.steps then
        self.status = "error"; return
    end
    self:Own(addon.currentGuide)
    self.worker = coroutine.create(function() return BuildExpectedQuestLog() end)
    self:Schedule()
end

local function QuestView(group, name)
    InspectionBoundary(true) -- at most one chapter parse per scheduler cycle
    local guide
    if addon.GetGuideQuestView then guide = addon:GetGuideQuestView(group, name)
    else guide = addon:FetchGuide(group, name) end
    if inspection.worker and coroutine.running() == inspection.worker then
        if name and not (guide and guide.steps) then
            error("Quest inspection could not read a requested chapter", 0)
        end
        inspection:Own(guide)
    end
    return guide
end
local function ProcessQuestView(guide)
    local processed = addon.ProcessGuideTable(guide)
    if inspection.worker and coroutine.running() == inspection.worker then inspection:Own(processed) end
    return processed
end
function addon.GetExpectedQuestLog()
    inspection:Request()
    if inspection.status ~= "ready" then return {}, {}, inspection.status end
    return qLogCache, futureTurnInsCache, "ready"
end

function BuildExpectedQuestLog()
    local guide = addon.currentGuide
    local startGuide
    local currentStep = RXPCData.currentStep
    local scanQuests
    if guideKey ~= guide.key or stepIndex ~= currentStep or not qLogCache then
        scanQuests = true
    end
    guideKey = guide.key
    stepIndex = currentStep

    local function scanGuides()
        if guide.standalone then
            startGuide = guide
        else
            local group = guide.group
            local name = addon.guideList[group].defaultGuide_
            startGuide = QuestView(group,name)
        end
        startGuide = ProcessQuestView(startGuide)
        if not (startGuide and startGuide.steps) then
            error("Quest inspection has no readable route entry", 0)
        end
        --print(group,name)
        local qLog = addon.GetQuestLog(nil,nil,startGuide,true,guide.key,currentStep)
        if not qLog or not next(qLog) then
            return {},{}
        end
        local futureTurnIns = {}

        local function ProcessStep(step,guide)
            InspectionBoundary(false)
            for _,element in ipairs(step.elements) do
                if element.tag and (element.tag:find("turnin")) then
                    local ids = element.ids or {element.questId}
                    for _,id in pairs(ids) do
                        if addon.IsOnQuest(id) then
                            futureTurnIns[id] = guide.key
                        end
                    end
                end
            end
        end
        for i = currentStep,#guide.steps do
            local step = guide.steps[i]
            if step then
                ProcessStep(step,guide)
            end
        end

        local nextGroup,nextName,nextGuide

        local visited = {[guide.key] = true}
        repeat
            nextGroup,nextName = addon.functions.next(false,guide)
            nextGuide = QuestView(nextGroup,nextName)
            if nextGuide and nextGuide.steps then
                if not visited[nextGuide.key] then
                    visited[nextGuide.key] = true
                    nextGuide = ProcessQuestView(nextGuide)
                    guide = nextGuide
                    for _,step in ipairs(guide.steps) do
                        ProcessStep(step,guide)
                    end
                else
                    nextGuide = nil
                end
            end
        until not nextGuide

        return qLog,futureTurnIns
    end
    if scanQuests then
        return scanGuides()
    end
    return qLogCache,futureTurnInsCache
end
local maxQLogSize = 0
local maxIndex = 0
function addon.GetQuestLog(QL, LT, guide, silent, stopGuide, stopStep, visited)
    if not (QL and LT) then
        QL = {}
        LT = {}
        guide = guide or addon.currentGuide
    end
    if not guide then return QL end
    visited = visited or {}
    if visited[guide.key or guide] then return QL end
    visited[guide.key or guide] = true
    local name = guide.name
    local group = addon.functions
    local qError
    local eStep
    local stop
    local lastQuestAccepted
    if not (guide and addon.stepLogic.SeasonCheck(guide)) then return end
    for _, step in ipairs(guide.steps) do
        InspectionBoundary(false)
        local remove = tonumber(step.qremove)
        if remove then
            QL[remove] = nil
        end
        for en, element in pairs(step.elements) do
            local ids
            if element.tag == "accept" or element.tag == "daily" then
                local id = element.questId or element.ids[1]
                id = addon.GetQuestId(id,guide)
                local qname = element.text or tostring(id)
                LT[id] = false
                qname = qname:gsub("^Accept ", "")
                lastQuestAccepted = qname
                QL[id] = qname
            elseif element.tag and (element.tag:find("turnin") or element.tag == "abandon") then
                ids = element.ids or {element.questId}
                for _,id in pairs(ids) do
                    id = addon.GetQuestId(id,guide)
                    if LT[id] == nil and not element.skipIfMissing then
                        local t = id .. "/" ..
                                    (element.text or tostring(id)) ..
                                    "/" .. guide.name
                        LT[id] = t:gsub("^[Tt]urn in", "")
                    end
                    QL[id] = nil
                end
            end
        end
        local nQuests = 0
        for n in pairs(QL) do nQuests = nQuests + 1 end
        if nQuests > maxQLogSize then
            maxIndex = step.index
            maxQLogSize = nQuests
        end
        if (not silent and (nQuests > maxQuests or step.stop)) or (stopGuide == guide.key and stopStep == step.index) then
            qError = true
            eStep = step
            stop = step.stop
            break
        end
    end

    if not silent then
        local n = 0
        print("\n\nGuide: " .. name)
        for i, v in pairs(QL) do
            print(format("%s (%d)", v:gsub("^Accept ", ""), i))
            n = n + 1
        end
        print("QuestLog length: " .. n)
        print(format("QuestLog maximum size: %d - step %d",maxQLogSize,maxIndex))
        maxQLogSize = 0
        maxIndex = 0
    end
    if qError then
        if not silent then
            if stop then
                print(format("Stopped at step %d", eStep.index or 0))
            else
                print(format("Error at step %d: Quest log length greater than " ..
                                maxQuests, eStep.index or 0))
                print('Last Quest Accepted: ',lastQuestAccepted)
            end
        end
    else
        local nextGroup,nextName = group.next(false,guide)
        local nextGuide = QuestView(nextGroup,nextName)
        if nextGuide and nextGuide.steps then
            nextGuide = ProcessQuestView(nextGuide)
            if guide.key ~= nextGuide.key then
                return addon.GetQuestLog(QL, LT, nextGuide, silent, stopGuide, stopStep, visited)
            end
        elseif eStep and not silent then
            addon.comms.PrettyPrint("Error at step %d (%s)", eStep.index or 0,guide.name)
        end
    end

    if not silent then
        local prefix = "\n\nQuests missing an accept step:\n"
        for _, v in pairs(LT) do
            if type(v) == "string" and not v:find("A Donation of") then
                print(prefix .. v)
                prefix = ""
            end
        end
    end
    return QL
end

local function SetItemTooltip(tooltip, tooltipInfo)
    if tooltip:IsForbidden() or _G.GameTooltip:IsForbidden() then return end

    local id
    if tooltipInfo then
        id = tooltipInfo.id
    else
        local _, link = tooltip:GetItem()
        id = type(link) == "string" and tonumber(link:match("item:(%d+)"))
    end

    local questId = id and addon.questItemList[id]
    local guideList = questId and addon.turnInList[questId]

    if guideList and #guideList > 0 then
        local activeGuides = {}
        local prefix = L"Item used in guide:\n"
        for _, entry in ipairs(guideList) do
            local step = entry.step
            local guide = entry.guide
            if addon.IsGuideActive(guide) and not guide.lowPrio and
                addon.IsStepShown(step,"GroupCheck") then
                    local groupText = ""
                    if step.group then
                        groupText = L" (Group)"
                    end
                local guideName = prefix .. addon.icons.turnin .. entry.name .. groupText
                if not activeGuides[guideName] then
                    activeGuides[guideName] = true
                    tooltip:AddLine(guideName)
                    prefix = ""
                end
            end
        end
    end
end

if _G.TooltipDataProcessor then
    _G.TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item,
                                               SetItemTooltip)
else
    _G.GameTooltip:HookScript("OnTooltipSetItem", SetItemTooltip)
end

local function getQuestData(questLogIndex)
    local data
    local questInfo, questLogTitleText, level, isHeader, isComplete, frequency,
          questID

    if addon.questLog.GetInfo then
        questInfo = addon.questLog.GetInfo(questLogIndex) or {}
        questID = tonumber(questInfo.questID)
        isComplete = questInfo.isComplete
        if questID and type(addon.questLog.IsComplete) == "function" then
            isComplete = addon.questLog.IsComplete(questID)
        end

        data = {
            ["questLogTitleText"] = questInfo.title,
            ["level"] = questInfo.level,
            ["isHeader"] = questInfo.isHeader,
            ["questID"] = questID,
            ["frequency"] = questInfo.frequency,

            ["isComplete"] = isComplete
        }
    else
        questLogTitleText, level, _, isHeader, _, isComplete, frequency, questID =
            GetQuestLogTitle(questLogIndex)

        data = {
            ["questLogTitleText"] = questLogTitleText,
            ["level"] = level,
            ["isHeader"] = isHeader,
            ["questID"] = questID,
            ["frequency"] = frequency,

            ["isComplete"] = questID and isComplete
        }
    end

    return data
end

-- Set on first GetOrphanedQuests run, likely by UpdateQuestButton call
addon.orphanedList = nil -- {}
function addon.GetOrphanedQuests(allowHidden)
    if (addon.isHidden and not allowHidden) or not addon.currentGuide or not addon.currentGuide.key then
        addon.orphanedList = nil
        return {}, "unavailable"
    end
    local invertedList, orphanedList = {}, {}

    local guideQuests, futureTurnIns, status = addon.GetExpectedQuestLog()
    if status ~= "ready" then addon.orphanedList = nil; return {}, status end

    local questData, orphanData
    local isPartOfGuide

    for i = 1, GetNumQuests() do
        questData = getQuestData(i)
        local questID = questData and tonumber(questData.questID)

        if questData and not questData.isHeader and questID and questID > 0 then
            orphanData = {
                ["questLogTitleText"] = questData.questLogTitleText,
                ["level"] = questData.level,
                ["questID"] = questID,
                ["questLogIndex"] = i
            }

            isPartOfGuide = guideQuests[questID] or futureTurnIns[questID]

            if not isPartOfGuide and not questData.isComplete then
                table.insert(invertedList, 1, orphanData)

                orphanedList[questID] = orphanData
            end
        end

    end

    -- orphanedList for quest log parsing similar to addon.turnInList
    addon.orphanedList = orphanedList

    -- invertedList to abandon from questlog bottom, no required refresh on bulk abandon
    return invertedList, "ready"
end


local SetAbandonQuest = addon.questLog.SetAbandonQuest or _G.SetAbandonQuest
local AbandonQuest = addon.questLog.AbandonQuest or _G.AbandonQuest

local function ValidatedOrphans(requested)
    local live, status = addon.GetOrphanedQuests(true)
    if status ~= "ready" then
        addon.comms.PrettyPrint(inspection:StatusText())
        return
    end
    if not requested then return live end
    local byId, result = {}, {}
    for _, quest in ipairs(live) do byId[quest.questID] = quest end
    for _, quest in ipairs(requested) do
        if byId[quest.questID] then result[#result + 1] = byId[quest.questID]; byId[quest.questID] = nil end
    end
    return result
end

function addon.AbandonOrphanedQuests(orphans)
    -- Confirmation payloads are suggestions, never authoritative cached state.
    orphans = ValidatedOrphans(orphans)
    if not orphans then return end
    local approvedContext = inspection.context

    local function abandonQuest(questInfo)
        addon.comms.PrettyPrint("Abandoning %s", questInfo.questLogTitleText)

        if addon.questLog.SetSelectedQuest then
            addon.questLog.SetSelectedQuest(questInfo.questID)
        else
            _G.SelectQuestLogEntry(questInfo.questLogIndex)
        end

        SetAbandonQuest()

        AbandonQuest()
    end

    local id, questData

    -- Reverse process list, to avoid searching, abandon from bottom
    for i = #orphans, 1, -1 do
        if not Current(approvedContext) then
            addon.comms.PrettyPrint(inspection:StatusText())
            return
        end
        questData = orphans[i]

        if addon.questLog.SetSelectedQuest then
            abandonQuest(questData)
        else
            id = GetLegacyQuestIDAtIndex(questData.questLogIndex)

            if id == questData.questID then
                abandonQuest(questData)
            else
                for j = 1, GetNumQuests() do
                    id = GetLegacyQuestIDAtIndex(j)

                    if id == questData.questID then
                        abandonQuest(questData)

                        break
                    end
                end
            end
        end
    end

    -- Workaround async UI draws, abandon won't have completed before next name func called
    C_Timer.After(2, function()
        LibStub("AceConfigRegistry-3.0"):NotifyChange(addon.title)
    end)
end

-- ====================================================================
-- Quest Log Button: Cleanup Orphaned Quests (Retail + Classic support)
-- ====================================================================

-- Localization for button/tooltip — don't shadow your global L() accessor
local Loc = addon and addon.L or nil
local CLEANUP_LABEL = (Loc and Loc.CLEANUP_ORPHANED_QUESTS) or "Cleanup Orphaned Quests"
local CLEANUP_DESC  = (Loc and Loc.CLEANUP_ORPHANED_QUESTS_DESC)
    or "Abandons quests that aren't referenced by your current RestedXP guide."

-- Icon path for button + tooltip
local ICON_PATH = "Interface\\AddOns\\" .. addonName .. "\\Textures\\rxp_logo-64"
local ICON_INLINE = "|T" .. ICON_PATH .. ":14|t "

-- ---------- helpers --------------------------------------------------
local function GetQuestLogParentAndAbandon()
    -- Retail
    local qmf = _G.QuestMapFrame
    if qmf and qmf.DetailsFrame and qmf.DetailsFrame.AbandonButton then
        return qmf.DetailsFrame, qmf.DetailsFrame.AbandonButton, "RETAIL"
    end
-- ClassicQuestLog
    if _G.QuestLogFrame and _G.QuestLogFrameAbandonButton then
        return _G.QuestLogFrame, _G.QuestLogFrameAbandonButton, "CLASSIC"
    end

    -- Popular replacements
    if _G.ClassicQuestLog and _G.QuestLogFrameAbandonButton then
        return _G.ClassicQuestLog, _G.QuestLogFrameAbandonButton, "CLASSIC"
    end
    if _G.QuestLogEx and _G.QuestLogFrameAbandonButton then
        return _G.QuestLogEx, _G.QuestLogFrameAbandonButton, "CLASSIC"
    end
    if _G.QuestGuru and _G.QuestLogFrameAbandonButton then
        return _G.QuestGuru, _G.QuestLogFrameAbandonButton, "CLASSIC"
    end

    return nil, nil, nil
end

local function BuildOrphanListText(orphans)
    local t = {}
    for i = 1, #orphans do
        local q = orphans[i]
        local name = q.questLogTitleText or "Unknown"
        local lvl  = q.level and (" (level " .. q.level .. ")") or ""
        t[#t+1] = name .. lvl
    end
    return table.concat(t, "\n")
end

local function TrySettingsCleanup(orphans)
    if addon.SettingsPanel and type(addon.SettingsPanel.CleanupOrphanedQuests) == "function" then
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function() addon.SettingsPanel:CleanupOrphanedQuests(orphans) end)
        else
            addon.SettingsPanel:CleanupOrphanedQuests(orphans)
        end
        return true
    end
    if type(addon.CleanupOrphanedQuests) == "function" then
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function() addon:CleanupOrphanedQuests(true, orphans) end)
        else
            addon:CleanupOrphanedQuests(true, orphans)
        end
        return true
    end
    return false
end

function addon.BeginAbandonOrphans(orphans)
    orphans = ValidatedOrphans(orphans)
    if not orphans then return end
    if not (type(orphans) == "table" and #orphans > 0) then
        addon.comms.PrettyPrint("Cleanup: no orphaned quests to abandon.")
        return
    end

    addon.comms.PrettyPrint("Cleanup: abandoning %d orphaned quest(s)...", #orphans)

    local i = #orphans
    local approvedContext = inspection.context
    local function step()
        if i < 1 then
            if C_Timer and C_Timer.After then
                C_Timer.After(0.5, function()
                    local reg = LibStub and LibStub("AceConfigRegistry-3.0", true)
                    if reg and addon and addon.title then
                        reg:NotifyChange(addon.title)
                    end
                end)
            end
            return
        end

        if not Current(approvedContext) then
            addon.comms.PrettyPrint(inspection:StatusText())
            return
        end

        local q = orphans[i]
        i = i - 1

        if addon.questLog and addon.questLog.SetSelectedQuest then
            addon.questLog.SetSelectedQuest(q.questID)
        else
            _G.SelectQuestLogEntry(q.questLogIndex)
        end

        if addon.questLog and addon.questLog.SetAbandonQuest then
            addon.questLog.SetAbandonQuest()
        else
            _G.SetAbandonQuest()
        end

        if addon.questLog and addon.questLog.AbandonQuest then
            addon.questLog.AbandonQuest()
        else
            _G.AbandonQuest()
        end

        if _G.ConfirmAbandonQuest then
            _G.ConfirmAbandonQuest()
        else
            local f = _G.StaticPopup_FindVisible and _G.StaticPopup_FindVisible("ABANDON_QUEST")
            if f and f.button1 and f.button1.Click then
                f.button1:Click()
            end
        end

        if C_Timer and C_Timer.After then
            C_Timer.After(0.15, step)
        else
            step()
        end
    end

    step()
end

local function VerifyThenFallback(originalOrphans)
    local wasHidden = addon.isHidden
    addon.isHidden = false
    local still, status = addon.GetOrphanedQuests()
    addon.isHidden = wasHidden
    if status ~= "ready" then addon.comms.PrettyPrint(inspection:StatusText()); return end

    if still and #still > 0 then
        addon.comms.PrettyPrint("Cleanup: Settings handler did not complete; using fallback.")
        addon.BeginAbandonOrphans(originalOrphans)
    else
        addon.comms.PrettyPrint("Cleanup: completed via Settings handler.")
    end
end

local function RXP_RunCleanupOrphanedQuests()
    if not (addon.currentGuide and addon.currentGuide.key) then
        addon.comms.PrettyPrint("Cleanup: no active guide detected.")
        return
    end

    -- ensure GetOrphanedQuests() returns data even if UI = hidden
    local wasHidden = addon.isHidden
    addon.isHidden = false
    local orphans, status = addon.GetOrphanedQuests()
    addon.isHidden = wasHidden
    if status ~= "ready" then addon.comms.PrettyPrint(inspection:StatusText()); return end

    local count = (orphans and #orphans) or 0
    if count == 0 then
        addon.comms.PrettyPrint("Cleanup: no orphaned quests found.")
        return
    end

    local listText = BuildOrphanListText(orphans)
    local DLG = "RXP_CONFIRM_ORPHANED_CLEANUP_LIST"
    if not _G.StaticPopupDialogs[DLG] then
        _G.StaticPopupDialogs[DLG] = {
        text = L("Abandon the following quests?\n%s"),
            button1 = ACCEPT,
            button2 = CANCEL,
            OnAccept = function(_, data)
                data = ValidatedOrphans(data)
                if not data or #data == 0 then return end
                if TrySettingsCleanup(data) then
                    if C_Timer and C_Timer.After then
                        C_Timer.After(0.25, function() VerifyThenFallback(data) end)
                    else
                        VerifyThenFallback(data)
                    end
                else
                    addon.BeginAbandonOrphans(data)
                end
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1,
            showAlert = 0,
            preferredIndex = 3,
        }
    end
    _G.StaticPopup_Show(DLG, listText, nil, orphans)
end

-- ---------- UI creation Retail + ClassicQuestLog -------

local cleanupBtn
local createdCleanupBtn = false

local function SetCleanupBtnEnabled(enabled)
    if not cleanupBtn then return end
    if enabled then
        cleanupBtn:Enable()
        cleanupBtn:SetAlpha(1)
    else
        cleanupBtn:Disable()
        cleanupBtn:SetAlpha(0.5)
    end
end

local function AnchorCleanupButton()
    if not cleanupBtn or not cleanupBtn:GetParent() then return end
    local _, abandon = GetQuestLogParentAndAbandon()
    if abandon and abandon:IsShown() then
        cleanupBtn:ClearAllPoints()
        cleanupBtn:SetPoint("TOPLEFT", abandon, "BOTTOMLEFT", 0, -6)
    else
        -- Defensive fallback inside parent
        cleanupBtn:ClearAllPoints()
        cleanupBtn:SetPoint("BOTTOMLEFT", cleanupBtn:GetParent(), "BOTTOMLEFT", 20, 45)
    end
end

local function CreateCleanupButton()
    if createdCleanupBtn then return end

    -- Ensure the relevant Blizzard UI is loaded
    if not GetQuestLogParentAndAbandon() and _G.UIParentLoadAddOn then
        pcall(_G.UIParentLoadAddOn, "Blizzard_WorldMap")   -- Retail
        pcall(_G.UIParentLoadAddOn, "Blizzard_QuestLog")   -- Classic
    end

    local parent, _, flavor = GetQuestLogParentAndAbandon()
    if not parent then return end

    cleanupBtn = CreateFrame("Button", "RXPQuestLogCleanupButton", parent, "UIPanelButtonTemplate")
    cleanupBtn:SetText(ICON_INLINE .. CLEANUP_LABEL)
    cleanupBtn:SetSize(200, 22)

    AnchorCleanupButton()

    cleanupBtn:SetScript("OnClick", function()
        if InCombatLockdown and InCombatLockdown() then
            addon.comms.PrettyPrint("You can't do that in combat.")
            return
        end
        RXP_RunCleanupOrphanedQuests()
    end)

    cleanupBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("|T" .. ICON_PATH .. ":16|t " .. CLEANUP_LABEL, 1, 1, 1)
        GameTooltip:AddLine(CLEANUP_DESC, nil, nil, nil, true)
        if InCombatLockdown and InCombatLockdown() then
            GameTooltip:AddLine("\nUnavailable in combat.", 1, 0.2, 0.2, true)
        end
        GameTooltip:Show()
    end)
    cleanupBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    createdCleanupBtn = true
    SetCleanupBtnEnabled(not (InCombatLockdown and InCombatLockdown()))
    cleanupBtn:SetShown(not addon.isHidden)

    -- Re-anchor
    if parent.HookScript then
        parent:HookScript("OnShow", function()
            AnchorCleanupButton()
            if cleanupBtn then
                cleanupBtn:SetShown(not addon.isHidden)
            end
        end)
    end

    if flavor == "RETAIL" and _G.WorldMapFrame and _G.WorldMapFrame.HookScript then
        _G.WorldMapFrame:HookScript("OnShow", function()
            AnchorCleanupButton()
            if cleanupBtn then
                cleanupBtn:SetShown(not addon.isHidden)
            end
        end)
    end
end

local function ReanchorCleanupButtonIfNeeded()
    if not cleanupBtn or not cleanupBtn:IsShown() then return end
    AnchorCleanupButton()
end

-- ---------- events ---------------------------------------------------
do
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:RegisterEvent("PLAYER_LOGIN")
    f:RegisterEvent("PLAYER_REGEN_DISABLED")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:RegisterEvent("QUEST_LOG_UPDATE")
    f:RegisterEvent("PLAYER_LEVEL_UP")
    f:RegisterEvent("UPDATE_FACTION")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("PLAYER_LOGOUT")

    local hookedToggle = false

    f:SetScript("OnEvent", function(_, ev, arg1)
        if ev == "ADDON_LOADED" then
            if arg1 == "Blizzard_QuestLog" or arg1 == "Blizzard_WorldMap" or arg1 == addonName then
                CreateCleanupButton()
            end

        elseif ev == "PLAYER_LOGIN" then
            CreateCleanupButton()

            if not createdCleanupBtn and not hookedToggle then
                if _G.ToggleQuestLog then
                    hookedToggle = true
                    hooksecurefunc("ToggleQuestLog", function()
                        CreateCleanupButton()
                        ReanchorCleanupButtonIfNeeded()
                    end)
                elseif _G.WorldMapFrame and _G.WorldMapFrame.HookScript then
                    hookedToggle = true
                    _G.WorldMapFrame:HookScript("OnShow", function()
                        CreateCleanupButton()
                        ReanchorCleanupButtonIfNeeded()
                    end)
                end
            end

            if cleanupBtn then
                cleanupBtn:SetShown(not addon.isHidden)
            end

        elseif ev == "QUEST_LOG_UPDATE" or ev == "PLAYER_LEVEL_UP" or
            ev == "UPDATE_FACTION" or ev == "PLAYER_ENTERING_WORLD" then
            inspection:Invalidate()

        elseif ev == "PLAYER_LOGOUT" then
            inspection:Invalidate(false)

        elseif ev == "PLAYER_REGEN_DISABLED" then
            SetCleanupBtnEnabled(false)

        elseif ev == "PLAYER_REGEN_ENABLED" then
            SetCleanupBtnEnabled(true)
        end
    end)
end


--[[ no longer necessary
-- Classic / Cata
if _G.ToggleQuestLog and _G.QuestLogFrame then
    hooksecurefunc("ToggleQuestLog", function()
        if _G.QuestLogFrame:IsShown() then
            -- Update before UpdateQuestButton fires
            addon.GetOrphanedQuests()
        else
            -- Inventory orphaned quests on close
            addon:ScheduleTask(addon.GetOrphanedQuests)
        end
    end)
-- else
--     addon.game == 'RETAIL'
end
]]
