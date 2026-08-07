local _, addon = ...

local _G = _G
local format = string.format
local floor, max, abs = math.floor, math.max, math.abs
local L = addon.locale.Get
local GetContainerNumSlots = C_Container and
                                 C_Container.GetContainerNumSlots or
                                 _G.GetContainerNumSlots
local GetContainerItemLink = C_Container and
                                 C_Container.GetContainerItemLink or
                                 _G.GetContainerItemLink
local GetContainerItemInfo = _G.GetContainerItemInfo

addon.goldAssistant = addon:NewModule("GoldAssistant", "AceEvent-3.0")
local gold = addon.goldAssistant

local zoneMinimumLevels = {
    ["un'goro crater"] = 45,
    ["winterspring"] = 53,
    ["hellfire peninsula"] = 58,
    ["zangarmarsh"] = 60,
    ["terokkar forest"] = 62,
    ["nagrand"] = 64,
    ["blade's edge mountains"] = 65,
    ["blades edge mountains"] = 65,
    ["netherstorm"] = 67,
    ["shadowmoon valley"] = 67,
    ["borean tundra"] = 68,
    ["howling fjord"] = 68,
    ["dragonblight"] = 71,
    ["grizzly hills"] = 73,
    ["zul'drak"] = 74,
    ["sholazar basin"] = 76,
    ["the storm peaks"] = 77,
    ["storm peaks"] = 77,
    ["icecrown"] = 77,
    ["wintergrasp"] = 77,
}

local function GuideKey(guide)
    return guide and (guide.key or addon.BuildGuideKey(guide))
end

local function ItemID(link)
    return link and tonumber(link:match("item:(%d+)"))
end

local function EnsureData()
    RXPCData.goldAssistant = type(RXPCData.goldAssistant) == "table" and
                                RXPCData.goldAssistant or {}
    local data = RXPCData.goldAssistant
    data.runs = type(data.runs) == "table" and data.runs or {}
    return data
end

local function NormalizeRun(run, guide)
    run = type(run) == "table" and run or {}
    run.guideKey = GuideKey(guide) or run.guideKey
    run.group = guide and guide.group or run.group
    run.name = guide and guide.name or run.name
    run.elapsed = max(0, tonumber(run.elapsed) or 0)
    run.moneyChange = tonumber(run.moneyChange) or 0
    run.lootValue = max(0, tonumber(run.lootValue) or 0)
    run.itemChanges = type(run.itemChanges) == "table" and
                          run.itemChanges or {}
    run.segments = max(0, floor(tonumber(run.segments) or 0))
    run.running = run.running == true
    run.baselineItems = type(run.baselineItems) == "table" and
                            run.baselineItems or nil
    return run
end

local function CaptureInventory()
    local items = {}
    for bag = 0, (_G.NUM_BAG_SLOTS or 4) do
        local slots = GetContainerNumSlots and GetContainerNumSlots(bag) or 0
        for slot = 1, slots do
            local link = GetContainerItemLink and
                             GetContainerItemLink(bag, slot)
            local id = ItemID(link)
            if id then
                local _, count
                if GetContainerItemInfo then
                    _, count = GetContainerItemInfo(bag, slot)
                end
                local entry = items[id]
                if not entry then
                    entry = {count = 0, link = link}
                    items[id] = entry
                end
                entry.count = entry.count + max(0, tonumber(count) or 0)
                if link then entry.link = link end
            end
        end
    end
    return items
end

local function InventoryChanges(baseline)
    baseline = type(baseline) == "table" and baseline or {}
    local current = CaptureInventory()
    local changes = {}
    for id, entry in pairs(current) do
        local before = baseline[id]
        local delta = entry.count -
                          (type(before) == "table" and
                              (tonumber(before.count) or 0) or 0)
        if delta ~= 0 then
            changes[id] = {count = delta, link = entry.link}
        end
    end
    for id, before in pairs(baseline) do
        if not current[id] and type(before) == "table" then
            local count = max(0, tonumber(before.count) or 0)
            if count > 0 then
                changes[id] = {count = -count, link = before.link}
            end
        end
    end
    return changes
end

local function MergeItemChanges(target, source)
    target = type(target) == "table" and target or {}
    for id, change in pairs(source or {}) do
        if type(change) == "table" then
            local count = tonumber(change.count) or 0
            local entry = target[id]
            if type(entry) ~= "table" then
                entry = {count = 0}
                target[id] = entry
            end
            entry.count = (tonumber(entry.count) or 0) + count
            entry.link = change.link or entry.link
            if entry.count == 0 then target[id] = nil end
        end
    end
    return target
end

local function ValueItemChanges(changes)
    local positiveValue, netValue, unknown = 0, 0, 0
    for id, entry in pairs(changes or {}) do
        if type(entry) == "table" then
            local count = tonumber(entry.count) or 0
            if count ~= 0 then
                local item = entry.link or tonumber(id) or id
                local sellPrice = _G.GetItemInfo and
                                      select(11, _G.GetItemInfo(item))
                if type(sellPrice) == "number" then
                    netValue = netValue + sellPrice * count
                    if count > 0 then
                        positiveValue = positiveValue + sellPrice * count
                    end
                else
                    unknown = unknown + abs(count)
                    if _G.GetItemInfo then _G.GetItemInfo(item) end
                end
            end
        end
    end
    return positiveValue, netValue, unknown
end

local function FormatMoney(value, signed)
    value = floor(tonumber(value) or 0)
    local prefix = signed and value > 0 and "+" or
                       (value < 0 and "-" or "")
    local coin = _G.GetCoinTextureString and
                     _G.GetCoinTextureString(abs(value)) or
                     format(L("%d copper"), abs(value))
    return prefix .. coin
end

local function FormatDuration(seconds)
    seconds = max(0, floor(tonumber(seconds) or 0))
    local hours = floor(seconds / 3600)
    local minutes = floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return format("%02d:%02d:%02d", hours, minutes, secs)
end

local function ProfessionRequirements(guide)
    local display = tostring(guide and
        (guide.displayname or addon.GetGuideName(guide) or guide.name) or "")
    display = display:lower()
    local group = tostring(guide and guide.group or ""):lower()
    local requirements = {}
    if display == "mining" then
        requirements.mining = true
    elseif display == "herbalism" then
        requirements.herbalism = true
    elseif display == "mining & herbalism" or
        (display:find("mining", 1, true) and
            display:find("herbalism", 1, true)) then
        requirements.mining = true
        requirements.herbalism = true
    end
    if display:find("leather", 1, true) or
        display:find("dragonscale", 1, true) or
        display:find("fel hide", 1, true) or
        display:find("wind scale", 1, true) or
        display:find("cobra scales", 1, true) or
        group:find("skinning", 1, true) then
        requirements.skinning = true
    end
    return requirements
end

function gold:IsGuideCompatible(guide)
    if type(guide) ~= "table" or not guide.farm then return true end
    local zone = tostring(guide.subgroup or ""):lower()
    local minimum = zoneMinimumLevels[zone]
    local level = UnitLevel("player") or 1
    if minimum and level < minimum then
        return false, format(L("Recommended level %d or higher for %s"),
                             minimum, guide.subgroup)
    end

    local missing = {}
    for profession in pairs(ProfessionRequirements(guide)) do
        local skill = addon.GetSkillLevel and addon.GetSkillLevel(profession)
        if not skill or skill <= 0 then
            missing[#missing + 1] = profession:sub(1, 1):upper() ..
                                       profession:sub(2)
        end
    end
    table.sort(missing)
    if #missing > 0 then
        return false, "Requires " .. table.concat(missing, " and ")
    end
    return true
end

function gold:GetRun(guide, create)
    local key = GuideKey(guide)
    if not key then return end
    local data = EnsureData()
    local run = data.runs[key]
    if not run and create then
        run = NormalizeRun({}, guide)
        data.runs[key] = run
    elseif run then
        run = NormalizeRun(run, guide)
        data.runs[key] = run
    end
    return run, key
end

function gold:GetLiveValues(run)
    if not run then return 0, 0, 0, 0, 0 end
    local elapsed = run.elapsed
    local moneyChange = run.moneyChange
    local itemChanges = {}
    MergeItemChanges(itemChanges, run.itemChanges)
    if run.running and run.segmentStartedAt then
        elapsed = elapsed + max(0, GetTime() - run.segmentStartedAt)
        moneyChange = moneyChange +
                          ((_G.GetMoney and _G.GetMoney() or 0) -
                              (tonumber(run.segmentMoney) or 0))
        MergeItemChanges(itemChanges,
                         InventoryChanges(run.baselineItems))
    end
    local positiveValue, netValue, unknown = ValueItemChanges(itemChanges)
    local legacyValue = max(0, tonumber(run.lootValue) or 0)
    return elapsed, moneyChange, legacyValue + positiveValue,
           moneyChange + legacyValue + netValue, unknown
end

function gold:CommitSegment(run)
    if not run or not run.running or not run.segmentStartedAt then return end
    run.elapsed = run.elapsed + max(0, GetTime() - run.segmentStartedAt)
    run.moneyChange = run.moneyChange +
                          ((_G.GetMoney and _G.GetMoney() or 0) -
                              (tonumber(run.segmentMoney) or 0))
    run.itemChanges = MergeItemChanges(run.itemChanges,
                                      InventoryChanges(run.baselineItems))
    run.running = false
    run.segmentStartedAt = nil
    run.segmentMoney = nil
    run.baselineItems = nil
    run.lastUpdated = time()
end

function gold:PauseActive()
    local data = EnsureData()
    local key = data.activeRunKey
    local run = key and data.runs[key]
    if run then self:CommitSegment(run) end
    data.activeRunKey = nil
    self:Refresh()
end

function gold:Resume(guide)
    if type(guide) ~= "table" or not guide.farm then return end
    local compatible = self:IsGuideCompatible(guide)
    if not compatible then return end
    local data = EnsureData()
    local run, key = self:GetRun(guide, true)
    if data.activeRunKey and data.activeRunKey ~= key then
        local previous = data.runs[data.activeRunKey]
        if previous then self:CommitSegment(previous) end
    end
    data.activeRunKey = key
    if not run.running then
        run.running = true
        run.segmentStartedAt = GetTime()
        run.segmentMoney = _G.GetMoney and _G.GetMoney() or 0
        run.baselineItems = CaptureInventory()
        run.segments = run.segments + 1
        run.lastUpdated = time()
    end
    self:Refresh()
end

function gold:ResetCurrent()
    local guide = addon.currentGuide
    if not guide or not guide.farm then return end
    local data = EnsureData()
    local key = GuideKey(guide)
    data.runs[key] = NormalizeRun({}, guide)
    data.activeRunKey = nil
    self:Resume(guide)
end

function gold:RememberGuide(guide)
    if type(guide) ~= "table" or guide.empty then return end
    local data = EnsureData()
    local reference = {group = guide.group, name = guide.name}
    if guide.farm then
        data.lastFarmGuide = reference
    else
        data.lastQuestGuide = reference
    end
end

local function ResolveReference(reference, farm)
    if type(reference) ~= "table" or type(reference.group) ~= "string" or
        type(reference.name) ~= "string" then return end
    local guide = addon.GetGuideTable(reference.group, reference.name)
    local isFarm = guide and guide.farm == true
    if not guide or guide.empty or isFarm ~= (farm == true) or
        not addon.IsGuideActive(guide) then return end
    if farm and not gold:IsGuideCompatible(guide) then return end
    return guide
end

function gold:ToggleMode()
    if not RXPCData or addon.farmGuides <= 0 then return end
    local data = EnsureData()
    self:RememberGuide(addon.currentGuide)
    if addon.guideState and addon.guideState.SaveCurrent then
        addon.guideState:SaveCurrent()
    end
    if RXPCData.GA then self:PauseActive() end
    RXPCData.GA = not RXPCData.GA
    addon.RenderFrame(nil, true)
    local reference = RXPCData.GA and data.lastFarmGuide or
                          data.lastQuestGuide
    local guide = ResolveReference(reference, RXPCData.GA == true)
    if guide and addon.guideState then
        addon.guideState:Load(guide, false, "mode")
    else
        addon:LoadGuide(addon.emptyGuide)
    end
    if addon.guideHub and addon.guideHub.Refresh then
        addon.guideHub.selected = nil
        addon.guideHub:Refresh()
    end
end

function gold:OnGuideLoaded(guide)
    self:RememberGuide(guide)
    if RXPCData.GA and guide and guide.farm then
        self:Resume(guide)
    else
        self:PauseActive()
    end
end

function gold:CreateFrame()
    if self.frame then return self.frame end
    local frame = CreateFrame("Frame", "RXPGoldAssistantReport", UIParent)
    frame:SetSize(455, 290)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = {left = 8, right = 8, top = 8, bottom = 8}
    })
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -18)
    title:SetText(L("Gold Assistant"))
    frame.route = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.route:SetPoint("TOPLEFT", 28, -50)
    frame.route:SetPoint("TOPRIGHT", -28, -50)
    frame.route:SetJustifyH("LEFT")
    frame.compatibility = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.compatibility:SetPoint("TOPLEFT", frame.route, "BOTTOMLEFT", 0, -5)
    frame.compatibility:SetPoint("TOPRIGHT", frame.route, "BOTTOMRIGHT", 0, -5)
    frame.compatibility:SetJustifyH("LEFT")

    frame.values = {}
    local labels = {
        L("Active time"), L("Wallet change"), L("Unsold loot value"),
        L("Estimated total"), L("Estimated gold/hour")
    }
    for index, label in ipairs(labels) do
        local left = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        left:SetPoint("TOPLEFT", 38, -96 - (index - 1) * 27)
        left:SetText(label)
        local value = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        value:SetPoint("RIGHT", -38, 0)
        value:SetPoint("TOP", 0, -96 - (index - 1) * 27)
        value:SetJustifyH("RIGHT")
        frame.values[index] = value
    end
    frame.note = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.note:SetPoint("BOTTOMLEFT", 30, 57)
    frame.note:SetPoint("BOTTOMRIGHT", -30, 57)
    frame.note:SetJustifyH("LEFT")

    frame.pause = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.pause:SetSize(105, 24)
    frame.pause:SetPoint("BOTTOMLEFT", 28, 25)
    frame.pause:SetScript("OnClick", function()
        local data = EnsureData()
        local run = data.activeRunKey and data.runs[data.activeRunKey]
        if run and run.running then
            gold:PauseActive()
        elseif addon.currentGuide and addon.currentGuide.farm then
            gold:Resume(addon.currentGuide)
        end
    end)
    frame.reset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.reset:SetSize(105, 24)
    frame.reset:SetPoint("LEFT", frame.pause, "RIGHT", 8, 0)
    frame.reset:SetText(L("Reset Run"))
    frame.reset:SetScript("OnClick", function()
        addon.comms:ConfirmChoice("RXP_GOLD_RESET",
            L("Reset the current farming run?"), function()
                gold:ResetCurrent()
            end)
    end)
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)
    frame:SetScript("OnShow", function() gold:Refresh(true) end)
    frame:SetScript("OnUpdate", function(_, elapsed)
        frame.updateElapsed = (frame.updateElapsed or 0) + elapsed
        if frame.updateElapsed >= 1 then
            frame.updateElapsed = 0
            gold:Refresh()
        end
    end)
    frame:Hide()
    self.frame = frame
    table.insert(_G.UISpecialFrames, "RXPGoldAssistantReport")
    return frame
end

function gold:Refresh(force)
    local frame = self.frame
    if not frame or (not force and not frame:IsShown()) then return end
    local guide = addon.currentGuide
    local run = guide and guide.farm and self:GetRun(guide, false)
    frame.route:SetText(guide and guide.farm and
        (addon.GetGuideName(guide) or guide.name or L("Farming route")) or
        L("No farming route selected"))
    local compatible, reason = self:IsGuideCompatible(guide)
    frame.compatibility:SetText(guide and guide.farm and
        (compatible and L("Route is compatible with this character.") or reason) or
        L("Choose a route from Gold Assistant mode."))
    local elapsed, moneyChange, lootValue, total, unknown =
        self:GetLiveValues(run)
    local perHour = elapsed > 0 and total * 3600 / elapsed or 0
    frame.values[1]:SetText(FormatDuration(elapsed))
    frame.values[2]:SetText(FormatMoney(moneyChange, true))
    frame.values[3]:SetText(FormatMoney(lootValue, false))
    frame.values[4]:SetText(FormatMoney(total, true))
    frame.values[5]:SetText(FormatMoney(perHour, true))
    frame.note:SetText(unknown > 0 and
        format(L("Waiting for %d item price%s from the server cache."), unknown,
               unknown == 1 and "" or "s") or
        L("Vendor values are guaranteed estimates; Auction House prices are not used."))
    frame.pause:SetText(run and run.running and L("Pause Run") or L("Resume Run"))
    if guide and guide.farm and compatible then
        frame.pause:Enable()
        frame.reset:Enable()
    else
        frame.pause:Disable()
        frame.reset:Disable()
    end
end

function gold:ToggleReport()
    local frame = self:CreateFrame()
    frame:SetShown(not frame:IsShown())
end

function gold:PLAYER_LOGOUT()
    self:PauseActive()
end

function gold:RefreshIfShown()
    self:Refresh(false)
end

function gold:Setup()
    if self.setup then return end
    self.setup = true
    EnsureData()
    self:CreateFrame()
    self:RegisterEvent("PLAYER_LOGOUT")
    self:RegisterEvent("PLAYER_MONEY", "RefreshIfShown")
    self:RegisterEvent("BAG_UPDATE", "RefreshIfShown")
    self:RegisterEvent("GET_ITEM_INFO_RECEIVED", "RefreshIfShown")
    self:RegisterEvent("SKILL_LINES_CHANGED", "ProfessionsChanged")
    self:RegisterEvent("PLAYER_LEVEL_UP", "ProfessionsChanged")
    self.guideCallback = function(_, guide) gold:OnGuideLoaded(guide) end
    addon:RegisterMessage("RXP_GUIDE_LOADED", self.guideCallback)
    self:OnGuideLoaded(addon.currentGuide)
end

function gold:ProfessionsChanged()
    if addon.RXPFrame and addon.RXPFrame.GenerateMenuTable then
        addon.RXPFrame.GenerateMenuTable()
    end
    if addon.guideHub then addon.guideHub:Refresh() end
    self:Refresh()
end
