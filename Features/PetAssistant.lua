local _, addon = ...
local L = addon.locale.Get

local _G = _G
local format = string.format
local floor, max, min = math.floor, math.max, math.min
local tinsert = table.insert

addon.petAssistant = addon.petAssistant or {}
local pet = addon.petAssistant

local function IsHunter()
    return addon.player and addon.player.class == "HUNTER"
end

local function HappinessText(value)
    if value == 3 then return L("Happy"), 0.2, 1, 0.2 end
    if value == 2 then return L("Content"), 1, 0.82, 0 end
    if value == 1 then return L("Unhappy"), 1, 0.25, 0.25 end
    return L("Unavailable"), 0.7, 0.7, 0.7
end

local function KnownPetSkills()
    local result, seen = {}, {}
    local hasSpells = type(_G.HasPetSpells) == "function" and _G.HasPetSpells()
    local count = tonumber(hasSpells) or (hasSpells and 200 or 0)
    if count and count > 0 and type(_G.GetSpellName) == "function" then
        for index = 1, min(count, 200) do
            local name, rank = _G.GetSpellName(index, _G.BOOKTYPE_PET or "pet")
            if name and not seen[name .. tostring(rank)] then
                seen[name .. tostring(rank)] = true
                tinsert(result, rank and rank ~= "" and (name .. " " .. rank) or name)
            end
        end
    end
    if #result == 0 and type(_G.GetPetActionInfo) == "function" then
        for index = 1, (_G.NUM_PET_ACTION_SLOTS or 10) do
            local name = _G.GetPetActionInfo(index)
            if name and not seen[name] then
                seen[name] = true
                tinsert(result, name)
            end
        end
    end
    table.sort(result)
    return result
end

local function UpcomingPetStep()
    local guide = addon.currentGuide
    local current = tonumber(RXPCData.currentStep) or 1
    local ahead = addon.settings and
                      tonumber(addon.settings.profile.preflightLookahead) or 20
    for index = current, min(type(guide) == "table" and type(guide.steps) == "table" and
                                #guide.steps or 0, current + ahead - 1) do
        local step = guide.steps[index]
        for _, element in ipairs(step.elements or {}) do
            if element.tag == "stable" or element.tag == "tame" or
                element.tag == "petfamily" then
                return index, element.tag, element.text
            end
        end
    end
end

local function PetTalentStatus()
    local points
    if type(_G.GetUnspentTalentPoints) == "function" then
        local ok, value = pcall(_G.GetUnspentTalentPoints, false, true)
        if not ok then ok, value = pcall(_G.GetUnspentTalentPoints, true) end
        if ok then points = tonumber(value) end
    end
    local tree = type(_G.GetPetTalentTree) == "function" and _G.GetPetTalentTree()
    local guide = tree and addon.talents and addon.talents.petGuides and
                      addon.talents.petGuides[tree]
    return points, guide, tree
end

function pet:BuildText()
    if not IsHunter() then return L("The Hunter Pet Assistant is available to Hunters.") end
    local lines = {}
    local hasPet = UnitExists("pet") and not UnitIsDead("pet")
    if not hasPet then
        tinsert(lines, "[!] No active living pet.")
    else
        local level = UnitLevel("pet") or 0
    local family = UnitCreatureFamily("pet") or L("Unknown family")
        local health, healthMax = UnitHealth("pet") or 0, UnitHealthMax("pet") or 0
        local happiness = type(_G.GetPetHappiness) == "function" and
                              _G.GetPetHappiness()
        local happinessText = HappinessText(happiness)
        tinsert(lines, format("Pet: level %d %s", level, family))
        tinsert(lines, format("Health: %d/%d", health, healthMax))
        tinsert(lines, "Happiness: " .. happinessText)
    end

    local food = addon.supplies and addon.supplies.GetPetFoodStatus and
                     addon.supplies:GetPetFoodStatus() or
                     {diets = {}, items = {}, total = 0}
    tinsert(lines, "")
    tinsert(lines, "Diet: " .. (#food.diets > 0 and table.concat(food.diets, ", ") or
                                      "not reported by the client"))
    tinsert(lines, format("Compatible food carried: %d", food.total or 0))
    for index = 1, min(#food.items, 4) do
        local item = food.items[index]
        tinsert(lines, format("  %s x%d (%s)", item.name, item.count, item.family))
    end
    if hasPet and (food.total or 0) == 0 then
        tinsert(lines, "[!] Carry compatible pet food before a long route.")
    end
    local ammoSlot = _G.INVSLOT_AMMO or 0
    local ammoId = _G.GetInventoryItemID and _G.GetInventoryItemID("player", ammoSlot)
    if ammoId then
        tinsert(lines, format("Ammunition: %s x%d", _G.GetItemInfo(ammoId) or
            ("Item " .. ammoId), _G.GetItemCount(ammoId) or 0))
    elseif UnitLevel("player") >= 10 then
        tinsert(lines, "[!] No ammunition is equipped.")
    end

    local points, guide, tree = PetTalentStatus()
    tinsert(lines, "")
    tinsert(lines, format("Pet talents: %s unspent; plan: %s",
        points ~= nil and tostring(points) or "unknown",
        guide and (guide.displayname or guide.name or "selected") or
            (tree and "no matching plan" or "pet tree unavailable")))

    local skills = KnownPetSkills()
    tinsert(lines, format("Known pet skills: %d", #skills))
    if #skills > 0 then
        local shown = {}
        for index = 1, min(#skills, 8) do shown[index] = skills[index] end
        tinsert(lines, "  " .. table.concat(shown, ", "))
        if #skills > 8 then tinsert(lines, format("  ...and %d more", #skills - 8)) end
    end

    local step, tag, text = UpcomingPetStep()
    tinsert(lines, "")
    if step then
        tinsert(lines, format("Next pet preparation: step %d (%s)%s", step, tag,
            text and text ~= "" and (" - " .. tostring(text):gsub(
                "|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) or ""))
    else
        tinsert(lines, "No stable, tame, or pet-family directive in the current look-ahead.")
    end

    if addon.supplies and addon.supplies.BuildChecklist then
        local checklist = addon.supplies:BuildChecklist()
        local prep = {}
        for _, entry in ipairs(checklist or {}) do
            if entry.key == "ammunition" or entry.key == "petFood" then
                tinsert(prep, format("%s: %d/%d", entry.name, entry.have, entry.target))
            end
        end
        if #prep > 0 then
            tinsert(lines, "")
            tinsert(lines, "Hunter supplies:")
            for _, value in ipairs(prep) do tinsert(lines, "  " .. value) end
        end
    end
    return table.concat(lines, "\n")
end

function pet:Refresh()
    if not (self.frame and self.frame:IsShown()) then return end
    local text = self:BuildText()
    self.frame.text:SetText(text)
    self.frame.scrollChild:SetHeight(max(330, self.frame.text:GetStringHeight() + 12))
    local step = UpcomingPetStep()
    if step then self.frame.stepButton:Enable() else self.frame.stepButton:Disable() end
end

function pet:CreateWindow()
    local frame = CreateFrame("Frame", "RXPHunterPetAssistant", UIParent)
    frame:SetSize(535, 430)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true,
        tileSize = 32, edgeSize = 32,
        insets = {left = 8, right = 8, top = 8, bottom = 8}})
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -18)
    title:SetText(L("Hunter Pet Assistant"))
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)
    local scroll = CreateFrame("ScrollFrame", "RXPHunterPetAssistantScroll", frame,
                               "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 22, -48)
    scroll:SetPoint("BOTTOMRIGHT", -36, 52)
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(460, 330)
    scroll:SetScrollChild(child)
    frame.scrollChild = child
    frame.text = child:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    frame.text:SetPoint("TOPLEFT")
    frame.text:SetWidth(455)
    frame.text:SetJustifyH("LEFT")
    frame.text:SetJustifyV("TOP")

    local supplies = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    supplies:SetSize(110, 24)
    supplies:SetPoint("BOTTOMLEFT", 20, 18)
    supplies:SetText(L("Supplies"))
    supplies:SetScript("OnClick", function()
        if addon.supplies then addon.supplies:Toggle() end
    end)
    local stepButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    stepButton:SetSize(125, 24)
    stepButton:SetPoint("LEFT", supplies, "RIGHT", 8, 0)
    stepButton:SetText(L("Go to Pet Step"))
    stepButton:SetScript("OnClick", function()
        local step = UpcomingPetStep()
        if step and addon.GoToStep then addon.GoToStep(step) end
    end)
    frame.stepButton = stepButton
    local rescan = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    rescan:SetSize(100, 24)
    rescan:SetPoint("LEFT", stepButton, "RIGHT", 8, 0)
    rescan:SetText(L("Refresh"))
    rescan:SetScript("OnClick", function() pet:Refresh() end)
    frame:SetScript("OnShow", function() pet:Refresh() end)
    frame:Hide()
    self.frame = frame
    self:Refresh()
end

function pet:Toggle()
    if not IsHunter() then
        addon.comms.PrettyPrint("The Pet Assistant is available to Hunters.")
        return
    end
    if not self.frame then self:CreateWindow() end
    if self.frame:IsShown() then self.frame:Hide() else self.frame:Show() end
end

function pet:ScheduleRefresh()
    self.refreshSerial = (self.refreshSerial or 0) + 1
    local serial = self.refreshSerial
    C_Timer.After(0.15, function()
        if serial == pet.refreshSerial then pet:Refresh() end
    end)
end

function pet:Setup()
    if self.setup or not IsHunter() then return end
    self.setup = true
    local eventFrame = CreateFrame("Frame")
    local events = {"UNIT_PET", "PET_UI_UPDATE", "PET_BAR_UPDATE",
        "PET_HAPPINESS_UPDATE", "UNIT_HEALTH", "UNIT_LEVEL", "PET_TALENT_UPDATE",
        "PLAYER_TALENT_UPDATE", "BAG_UPDATE", "SPELLS_CHANGED", "PET_STABLE_SHOW",
        "PET_STABLE_CLOSED"}
    for _, event in ipairs(events) do pcall(eventFrame.RegisterEvent, eventFrame, event) end
    eventFrame:SetScript("OnEvent", function(_, event, unit)
        if event == "UNIT_HEALTH" or event == "UNIT_LEVEL" or
            event == "UNIT_PET" then
            if unit ~= "pet" and unit ~= "player" then return end
        end
        pet:ScheduleRefresh()
    end)
    self.eventFrame = eventFrame
    addon:RegisterMessage("RXP_STEP_ACTIVATED", function() pet:ScheduleRefresh() end)
    addon:RegisterMessage("RXP_GUIDE_LOADED", function() pet:ScheduleRefresh() end)
end
