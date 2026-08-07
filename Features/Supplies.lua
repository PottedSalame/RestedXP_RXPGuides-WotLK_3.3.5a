local _, addon = ...
local L = addon.locale.Get

local _G = _G
local format = string.format
local GetItemCount = _G.GetItemCount

addon.supplies = addon.supplies or {}
local supplies = addon.supplies

local reagentData = {
    PALADIN = {
        {id = 17033, key = "symbolDivinity", name = "Symbol of Divinity", minLevel = 30, target = 20, spells = {19752}},
        {id = 21177, key = "symbolKings", name = "Symbol of Kings", minLevel = 60, target = 20, spells = {25890, 25894, 25898, 25899}}
    },
    PRIEST = {
        {id = 17028, key = "holyCandle", name = "Holy Candle", minLevel = 48, target = 20, spells = {21562, 27681, 27683}},
        {id = 17029, key = "sacredCandle", name = "Sacred Candle", minLevel = 60, target = 20, spells = {21564, 48162, 48074, 48170}}
    },
    MAGE = {
        {id = 17031, key = "teleportRune", name = "Rune of Teleportation", minLevel = 20, target = 20, spells = {3561, 3562, 3563, 3565, 3566, 3567, 32271, 32272, 53140}},
        {id = 17032, key = "portalRune", name = "Rune of Portals", minLevel = 40, target = 5, spells = {10059, 11416, 11417, 11418, 11419, 11420, 32266, 32267, 53142}}
    },
    SHAMAN = {
        {id = 17030, key = "ankh", name = "Ankh", minLevel = 30, target = 5, spells = {20608}}
    },
    WARLOCK = {
        {id = 6265, key = "soulShard", name = "Soul Shard", minLevel = 10, target = 3, noVendor = true}
    },
    ROGUE = {
        {id = 3775, key = "cripplingPoison", name = "Crippling Poison", minLevel = 20, target = 20, spells = {2842}},
        {id = 5237, key = "mindNumbingPoison", name = "Mind-numbing Poison", minLevel = 24, target = 20, spells = {2842}},
        {id = 43231, key = "instantPoison", name = "Instant Poison", minLevel = 79, target = 20, spells = {2842}},
        {id = 43233, key = "deadlyPoison", name = "Deadly Poison", minLevel = 80, target = 20, spells = {2842}},
        {id = 43235, key = "woundPoison", name = "Wound Poison", minLevel = 80, target = 20, spells = {2842}},
        {id = 43230, key = "anestheticPoison", name = "Anesthetic Poison", minLevel = 68, target = 20, spells = {2842}}
    }
}

local foodFamilies = {
    Meat = {[117] = true, [2287] = true, [3770] = true, [3771] = true,
            [4599] = true, [8952] = true, [27854] = true, [33454] = true},
    Fish = {[787] = true, [4592] = true, [4593] = true, [4594] = true,
            [21552] = true, [27858] = true, [33451] = true},
    Bread = {[4540] = true, [4541] = true, [4542] = true, [4544] = true,
             [4601] = true, [8950] = true, [27855] = true, [33449] = true},
    Fruit = {[4536] = true, [4537] = true, [4538] = true, [4539] = true,
             [4602] = true, [8953] = true, [27856] = true, [35948] = true},
    Fungus = {[4604] = true, [4605] = true, [4606] = true, [4607] = true,
              [4608] = true, [8948] = true, [27859] = true, [35947] = true},
    Cheese = {[414] = true, [422] = true, [1707] = true, [2070] = true,
              [3927] = true, [8932] = true, [27857] = true, [33443] = true}
}

local function ItemID(link)
    return link and tonumber(link:match("item:(%d+)"))
end

local function KnownSpellNames()
    local known = {}
    if not GetNumSpellTabs or not GetSpellTabInfo or not GetSpellName then
        return known
    end
    for tab = 1, GetNumSpellTabs() do
        local _, _, offset, count = GetSpellTabInfo(tab)
        for index = (offset or 0) + 1, (offset or 0) + (count or 0) do
            local name = GetSpellName(index, _G.BOOKTYPE_SPELL or "spell")
            if name then known[name] = true end
        end
    end
    return known
end

local function KnowsDefinition(definition, known)
    if type(definition.spells) ~= "table" then return true end
    for _, spellId in ipairs(definition.spells) do
        local name = GetSpellInfo(spellId)
        if name and known[name] then return true end
    end
    return false
end

local function MerchantItems()
    local output = {}
    if not _G.MerchantFrame or not _G.MerchantFrame:IsShown() then return output end
    for index = 1, GetMerchantNumItems() do
        local name, texture, price, quantity, numAvailable, isUsable,
              extendedCost = GetMerchantItemInfo(index)
        local link = GetMerchantItemLink(index)
        local id = ItemID(link)
        if id then
            local _, _, _, itemLevel, requiredLevel, itemType, itemSubType,
                  stack, equipLoc = GetItemInfo(link)
            output[id] = {
                id = id, index = index, name = name, link = link,
                price = tonumber(price) or 0,
                quantity = math.max(tonumber(quantity) or 1, 1),
                available = tonumber(numAvailable) or -1,
                usable = isUsable ~= false,
                extendedCost = extendedCost == true,
                itemLevel = tonumber(itemLevel) or 0,
                requiredLevel = tonumber(requiredLevel) or 0,
                itemType = itemType, itemSubType = itemSubType,
                stack = tonumber(stack) or 1, equipLoc = equipLoc
            }
        end
    end
    return output
end

function supplies:IsProtectedItem(itemId)
    itemId = tonumber(itemId)
    for _, definition in ipairs(reagentData[addon.player.class] or {}) do
        if definition.id == itemId and
            self:GetTarget(definition.key, definition.target) > 0 then
            if definition.key == "soulShard" then
                return (GetItemCount(itemId) or 0) <
                           self:GetTarget(definition.key, definition.target)
            end
            return true
        end
    end
    for _, entry in ipairs(self.lastChecklist or {}) do
        if entry.id == itemId and (entry.target or 0) > 0 then
            if entry.key ~= "soulShard" or
                (GetItemCount(itemId) or 0) < entry.target then return true end
        end
    end
    local steps = addon.currentGuide and addon.currentGuide.steps
    local current = tonumber(RXPCData.currentStep) or 1
    for stepIndex = current, math.min(steps and #steps or 0, current + 10) do
        for _, element in ipairs(steps[stepIndex].elements or {}) do
            if element.tag == "buy" and tonumber(element.id) == itemId and
                self:GetTarget("guide:" .. itemId,
                               tonumber(element.qty) or 1) > 0 then
                return true
            end
        end
    end
    return false
end

function supplies:GetTarget(key, default)
    RXPCData.supplyTargets = RXPCData.supplyTargets or {}
    local value = RXPCData.supplyTargets[key]
    if value == nil then return default end
    return math.max(0, math.floor(tonumber(value) or 0))
end

local function CompatibleAmmoSubtype()
    local link = GetInventoryItemLink("player", _G.INVSLOT_RANGED)
    if not link then return end
    local _, _, _, _, _, _, subtype = GetItemInfo(link)
    if type(subtype) ~= "string" then return end
    local function Subtype(itemId)
        return select(7, GetItemInfo(itemId))
    end
    local bow, crossbow, gun = Subtype(2504), Subtype(15807), Subtype(2511)
    if subtype == bow or subtype == crossbow then
        return Subtype(2512) or "arrow", 1
    elseif subtype == gun then
        return Subtype(2516) or "bullet", 2
    end
    local value = subtype:lower()
    if value:find("bow", 1, true) or value:find("crossbow", 1, true) then
        return Subtype(2512) or "arrow", 1
    elseif value:find("gun", 1, true) then
        return Subtype(2516) or "bullet", 2
    end
end

local function PetFoodTypes()
    local result = {}
    if type(_G.GetPetFoodTypes) == "function" then
        local values = {_G.GetPetFoodTypes()}
        for _, value in ipairs(values) do
            if type(value) == "string" then result[value:lower()] = true end
        end
    end
    return result
end

local localizedFoodFamily = {
    Meat = "PET_DIET_MEAT", Fish = "PET_DIET_FISH",
    Bread = "PET_DIET_BREAD", Fruit = "PET_DIET_FRUIT",
    Fungus = "PET_DIET_FUNGUS", Cheese = "PET_DIET_CHEESE"
}

local function PetAcceptsFamily(family, diets)
    if diets[family:lower()] then return true end
    local localized = _G[localizedFoodFamily[family]]
    return type(localized) == "string" and diets[localized:lower()] == true
end

function supplies:GetPetFoodStatus()
    local diets = PetFoodTypes()
    local status = {diets = {}, items = {}, total = 0}
    for family, ids in pairs(foodFamilies) do
        if PetAcceptsFamily(family, diets) then
            table.insert(status.diets, family)
            for id in pairs(ids) do
                local count = GetItemCount(id) or 0
                if count > 0 then
                    table.insert(status.items, {id = id, count = count,
                        name = GetItemInfo(id) or ("Item " .. id), family = family})
                    status.total = status.total + count
                end
            end
        end
    end
    table.sort(status.diets)
    table.sort(status.items, function(a, b)
        if a.count == b.count then return a.id < b.id end
        return a.count > b.count
    end)
    return status
end

local function AddRequirement(output, definition, merchant, targetOverride)
    local target = supplies:GetTarget(definition.key,
                                      targetOverride or definition.target)
    if target <= 0 then return end
    local have = GetItemCount(definition.id) or 0
    local vendor = merchant[definition.id]
    for _, existing in ipairs(output) do
        if existing.id == definition.id then
            existing.target = math.max(existing.target, target)
            existing.need = math.max(existing.target - existing.have, 0)
            if definition.source == "guide" then
                existing.source = "guide"
                existing.key = definition.key
            end
            return
        end
    end
    table.insert(output, {
        id = definition.id,
        key = definition.key,
        name = (vendor and vendor.name) or definition.name or
                   (GetItemInfo(definition.id)) or ("Item " .. definition.id),
        have = have,
        target = target,
        need = math.max(target - have, 0),
        vendor = definition.noVendor and nil or vendor,
        source = definition.source or "class"
    })
end

function supplies:BuildChecklist()
    local merchant = MerchantItems()
    local output, playerLevel = {}, UnitLevel("player")
    local known = KnownSpellNames()
    local selectedDefinitions = {}
    for _, definition in ipairs(reagentData[addon.player.class] or {}) do
        if playerLevel >= definition.minLevel and
            KnowsDefinition(definition, known) then
            local previous = selectedDefinitions[definition.key]
            if not previous or definition.minLevel > previous.minLevel then
                selectedDefinitions[definition.key] = definition
            end
        end
    end
    for _, definition in pairs(selectedDefinitions) do
        if playerLevel >= definition.minLevel then
            AddRequirement(output, definition, merchant)
        end
    end

    if addon.player.class == "HUNTER" then
        local wantedSubtype, wantedFamily = CompatibleAmmoSubtype()
        local bestAmmo
        for _, item in pairs(merchant) do
            if item.equipLoc == "INVTYPE_AMMO" and item.usable and
                item.requiredLevel <= playerLevel then
                local subtype = type(item.itemSubType) == "string" and
                                    item.itemSubType or ""
                if (not wantedSubtype or subtype == wantedSubtype or
                    subtype:lower():find(tostring(wantedSubtype):lower(), 1, true)) and
                    (not bestAmmo or item.itemLevel > bestAmmo.itemLevel) then
                    bestAmmo = item
                end
            end
        end
        if bestAmmo then
            local specialtySlots = 0
            if wantedFamily and GetContainerNumFreeSlots then
                for bag = 1, _G.NUM_BAG_SLOTS or 4 do
                    local _, bagFamily = GetContainerNumFreeSlots(bag)
                    if bagFamily and bit.band(bagFamily, wantedFamily) ~= 0 then
                        specialtySlots = specialtySlots + GetContainerNumSlots(bag)
                    end
                end
            end
            local defaultAmmo = bestAmmo.stack *
                                    math.max(specialtySlots, 4)
            local target = self:GetTarget("ammunition", defaultAmmo)
            AddRequirement(output, {id = bestAmmo.id, key = "ammunition",
                name = bestAmmo.name, target = target, source = "hunter"},
                merchant)
        end

        local diets = PetFoodTypes()
        local bestFood, bestFamily
        for family, ids in pairs(foodFamilies) do
            if PetAcceptsFamily(family, diets) then
                for id in pairs(ids) do
                    local item = merchant[id]
                    if item and item.usable and item.requiredLevel <= playerLevel and
                        (not bestFood or item.itemLevel > bestFood.itemLevel) then
                        bestFood, bestFamily = item, family
                    end
                end
            end
        end
        if bestFood then
            AddRequirement(output, {id = bestFood.id, key = "petFood",
                name = bestFood.name .. " (" .. bestFamily .. ")", target = 20,
                source = "hunter"}, merchant)
        end
    end

    local steps = addon.currentGuide and addon.currentGuide.steps
    local current = tonumber(RXPCData.currentStep) or 1
    for stepIndex = current, math.min(steps and #steps or 0, current + 10) do
        for _, element in ipairs(steps[stepIndex].elements or {}) do
            if element.tag == "buy" and tonumber(element.id) then
                local id = tonumber(element.id)
                AddRequirement(output, {id = id, key = "guide:" .. id,
                    target = tonumber(element.qty) or 1, source = "guide"},
                    merchant, tonumber(element.qty) or 1)
            end
        end
    end
    table.sort(output, function(a, b)
        if a.source ~= b.source then return a.source == "guide" end
        return a.name < b.name
    end)
    self.lastChecklist = output
    return output
end

function supplies:Refresh()
    if not self.frame then return end
    local checklist = self:BuildChecklist()
    for index, row in ipairs(self.frame.rows) do
        local entry = checklist[index]
        row.entry = entry
        if entry then
            row:Show()
            local availability = entry.need == 0 and "|cff40ff40Ready|r" or
                (entry.vendor and "|cffffd100Available|r" or "|cffff4040Not sold here|r")
            row.name:SetText(entry.name)
            row.state:SetText(format("%d/%d  %s", entry.have,
                                     entry.target, availability))
            if not row.target:HasFocus() then
                row.target:SetText(tostring(entry.target))
            end
        else
            row:Hide()
        end
    end
    if _G.MerchantFrame and _G.MerchantFrame:IsShown() then
        self.frame.buy:Enable()
    else
        self.frame.buy:Disable()
    end
end

function supplies:GetPurchasePlan()
    local plan, total = {}, 0
    for _, entry in ipairs(self:BuildChecklist()) do
        local vendor = entry.vendor
        if entry.need > 0 and vendor and vendor.usable and
            not vendor.extendedCost then
            local quantity = entry.need
            if vendor.available >= 0 then
                quantity = math.min(quantity, vendor.available)
            end
            local bundles = math.ceil(quantity / vendor.quantity)
            table.insert(plan, {index = vendor.index, bundles = bundles,
                                bundleSize = vendor.quantity,
                                id = entry.id, need = quantity,
                                name = entry.name})
            total = total + bundles * vendor.price
        end
    end
    return plan, total
end

function supplies:ExecutePurchase(plan)
    if InCombatLockdown() or not _G.MerchantFrame or
        not _G.MerchantFrame:IsShown() or CursorHasItem() or
        UnitIsDeadOrGhost("player") then return end
    for _, purchase in ipairs(plan or {}) do
        for _ = 1, purchase.bundles do
            BuyMerchantItem(purchase.index)
        end
    end
    C_Timer.After(0.2, function() supplies:Refresh() end)
end

function supplies:BuyMissing()
    local plan, total = self:GetPurchasePlan()
    if #plan == 0 then return end
    if total > (GetMoney() or 0) then
        addon.comms:PopupNotification("RXP_SUPPLIES_MONEY",
            L("You do not have enough money for the missing supplies."))
        return
    end
    local freeSlots = 0
    for bag = _G.BACKPACK_CONTAINER or 0,
        _G.NUM_BAG_SLOTS or _G.NUM_BAG_FRAMES or 4 do
        local free = GetContainerNumFreeSlots and
                         select(1, GetContainerNumFreeSlots(bag)) or 0
        freeSlots = freeSlots + (tonumber(free) or 0)
    end
    if freeSlots == 0 then
        local stackRoom = false
        for _, purchase in ipairs(plan) do
            local maxStack = select(8, GetItemInfo(purchase.id)) or 1
            for bag = _G.BACKPACK_CONTAINER or 0,
                _G.NUM_BAG_SLOTS or _G.NUM_BAG_FRAMES or 4 do
                for slot = 1, GetContainerNumSlots(bag) do
                    if ItemID(GetContainerItemLink(bag, slot)) == purchase.id then
                        local _, count = GetContainerItemInfo(bag, slot)
                        if (tonumber(count) or 0) < maxStack then
                            stackRoom = true
                            break
                        end
                    end
                end
                if stackRoom then break end
            end
            if stackRoom then break end
        end
        if not stackRoom then
            addon.comms:PopupNotification("RXP_SUPPLIES_BAGS",
                L("No safe bag space is available for these supplies."))
            return
        end
    end
    local threshold = math.min(10000, math.floor((GetMoney() or 0) * 0.25))
    if total > threshold then
        addon.comms:ConfirmChoice("RXP_SUPPLIES_COST",
            format(L("Buy the missing class supplies for %s?"),
                   GetCoinTextureString(total)), function(data)
                supplies:ExecutePurchase(data)
            end, plan)
    else
        self:ExecutePurchase(plan)
    end
end

function supplies:CreateFrame()
    local frame = CreateFrame("Frame", "RXPSuppliesFrame", UIParent)
    frame:SetSize(520, 350)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                       edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                       tile = true, tileSize = 32, edgeSize = 32,
                       insets = {left = 8, right = 8, top = 8, bottom = 8}})
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -18)
    title:SetText(L("Class Supplies"))
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)
    frame.rows = {}
    for index = 1, 11 do
        local row = CreateFrame("Frame", nil, frame)
        row:SetSize(468, 22)
        row:SetPoint("TOPLEFT", 26, -52 - (index - 1) * 22)
        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.name:SetPoint("LEFT", 0, 0)
        row.name:SetPoint("RIGHT", -210, 0)
        row.name:SetJustifyH("LEFT")
        row.state = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.state:SetPoint("LEFT", 270, 0)
        row.state:SetPoint("RIGHT", -54, 0)
        row.state:SetJustifyH("LEFT")
        row.target = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        row.target:SetSize(48, 20)
        row.target:SetPoint("RIGHT", 0, 0)
        row.target:SetAutoFocus(false)
        row.target:SetNumeric(true)
        row.target:SetMaxLetters(5)
        row.target:SetScript("OnEnterPressed", function(box)
            local entry = row.entry
            if entry then
                RXPCData.supplyTargets[entry.key] =
                    math.max(0, math.floor(tonumber(box:GetText()) or 0))
            end
            box:ClearFocus()
            supplies:Refresh()
        end)
        frame.rows[index] = row
    end
    frame.buy = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.buy:SetSize(140, 24)
    frame.buy:SetPoint("BOTTOMLEFT", 24, 22)
    frame.buy:SetText(L("Buy Missing"))
    frame.buy:SetScript("OnClick", function() supplies:BuyMissing() end)
    local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("BOTTOMRIGHT", -24, 28)
    hint:SetText(L("Edit a target count; 0 disables that supply."))
    frame:SetScript("OnShow", function() supplies:Refresh() end)
    frame:Hide()
    self.frame = frame
    table.insert(_G.UISpecialFrames, "RXPSuppliesFrame")
end

function supplies:Toggle()
    if not self.frame then self:CreateFrame() end
    self.frame:SetShown(not self.frame:IsShown())
end

function supplies:Setup()
    if self.setup then return end
    self.setup = true
    RXPCData.supplyTargets = type(RXPCData.supplyTargets) == "table" and
                                RXPCData.supplyTargets or {}
    self:CreateFrame()
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("MERCHANT_SHOW")
    self.eventFrame:RegisterEvent("MERCHANT_CLOSED")
    local bagEvent = C_EventUtils and C_EventUtils.IsEventValid and
                         C_EventUtils.IsEventValid("BAG_UPDATE_DELAYED") and
                         "BAG_UPDATE_DELAYED" or "BAG_UPDATE"
    self.eventFrame:RegisterEvent(bagEvent)
    self.eventFrame:RegisterEvent("UNIT_PET")
    self.eventFrame:SetScript("OnEvent", function(_, event)
        if event == "MERCHANT_SHOW" and supplies:IsRelevantMerchant() then
            supplies.frame:Show()
        end
        supplies:Refresh()
    end)
end

function supplies:IsRelevantMerchant()
    for _, entry in ipairs(self:BuildChecklist()) do
        if entry.vendor then return true end
    end
    return false
end
