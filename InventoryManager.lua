local addonName,addon = ...
local L = addon.locale.Get

local inventoryManager = {}
addon.inventoryManager = inventoryManager

local gameVersion = select(4, GetBuildInfo())

local GetItemInfo = C_Item and C_Item.GetItemInfo or _G.GetItemInfo
local GetContainerNumFreeSlots = C_Container and C_Container.GetContainerNumFreeSlots or _G.GetContainerNumFreeSlots
local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or _G.GetContainerNumSlots

local GetContainerItemID = C_Container and C_Container.GetContainerItemID or _G.GetContainerItemID

local PickupContainerItem = C_Container and C_Container.PickupContainerItem or _G.PickupContainerItem

local UseContainerItem = C_Container and C_Container.UseContainerItem or _G.UseContainerItem
local GetItemSpell = C_Item and C_Item.GetItemSpell or _G.GetItemSpell
local GetContainerItemLink = C_Container and C_Container.GetContainerItemLink or _G.GetContainerItemLink
local GetItemCount = C_Item and C_Item.GetItemCount or _G.GetItemCount

local GetCoinTextureString = C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString or _G.GetCoinTextureString

inventoryManager.bagHook = _G.ContainerFrame_Update

local GetContainerItemInfo
local SOUL_SHARD_ID = 6265
local SOUL_BAG_FAMILY = 0x4

if C_Container and C_Container.GetContainerItemInfo then
    GetContainerItemInfo = function(...)
        local itemTable = C_Container.GetContainerItemInfo(...)
        if itemTable then
            return itemTable.texture,
                    itemTable.stackCount,
                    itemTable.isLocked,
                    itemTable.quality,
                    itemTable.isReadable,
                    itemTable.hasLoot,
                    itemTable.hyperlink,
                    itemTable.isFiltered,
                    itemTable.hasNoValue,
                    itemTable.itemID,
                    itemTable.isBound
        end
    end
else
    GetContainerItemInfo = _G.GetContainerItemInfo
end


--TODO: Handle UI options:
function inventoryManager.IsRightClickEnabled()
    if not inventoryManager.bagHook then return false end
    return addon.settings.profile.rightClickJunk
end

function inventoryManager.IsBagAutomationEnabled()
    if not inventoryManager.bagHook then return false end
    return addon.settings.profile.autoDiscardItems
end

function inventoryManager.IsMerchantAutomationEnabled()
    if not inventoryManager.bagHook then return false end
    return addon.settings.profile.autoSellJunk
end

function inventoryManager.IsJunkIconEnabled()
    local enabled = addon.settings and addon.settings.profile and
                        addon.settings.profile.showJunkIcon
    if gameVersion == 30300 then
        -- Stock bags are supported directly below. Do not make their overlay
        -- depend on ContainerFrame_Update already existing at file-load time.
        -- AceDB supplies the true default, while this nil fallback also covers
        -- the short interval before the profile has been attached.
        return enabled ~= false
    end
    if not inventoryManager.bagHook then return false end
    return enabled
end

function inventoryManager.GetModKey()
    --IsAltKeyDown or IsControlKeyDown, shift is used for splitting stacks
    --Ctrl + Left click is used for dressing room
    local mod = addon.settings.profile.rightClickMod
    if mod == 3 then
        return IsControlKeyDown() and IsAltKeyDown()
    elseif mod == 2 then
        return IsAltKeyDown()
    else
        return IsControlKeyDown()
    end
end

function inventoryManager.GetMouseButton()
    --LeftButton/RightButton
    return "RightButton"
end

local projectileType = 0
local quiverFreeSlots = 0
local quiverSlot
local organizeQuiver
local closestSlot = {}
local sortTimer = 0

local function GetProjectileSubclass(itemID)
    local _, _, _, _, _, _, itemSubType, stackMax, equipLoc, _, price,
        classID, subclassID = GetItemInfo(itemID)
    if classID == Enum.ItemClass.Projectile and type(subclassID) == "number" then
        return subclassID, stackMax, price
    end
    if equipLoc == "INVTYPE_AMMO" and _G.GetItemFamily then
        local family = bit.band(_G.GetItemFamily(itemID) or 0, 3)
        if family == 1 or family == 2 then
            return family + 1, stackMax, price
        end
    end
    if equipLoc == "INVTYPE_AMMO" and type(itemSubType) == "string" then
        local subtype = itemSubType:lower()
        if subtype:find("arrow", 1, true) then
            return 2, stackMax, price
        elseif subtype:find("bullet", 1, true) then
            return 3, stackMax, price
        end
    end
    return nil, stackMax, price
end

local function SortQuiver()
--Makes sure you only have 1 partial stack at the left most quiver slot for each ammo type
    if gameVersion > 30300 or UnitIsDead('player') or InCombatLockdown() then
        return
    end
    organizeQuiver = false
    local function GetQuiverSlot()
        quiverSlot, projectileType, quiverFreeSlots = nil, 0, 0
        for bag = BACKPACK_CONTAINER, NUM_BAG_FRAMES do
            local free, bagFamily = GetContainerNumFreeSlots(bag)
            local family = bit.band(bagFamily or 0, 3)
            if family == 1 or family == 2 then
                quiverSlot = bag
                projectileType = family + 1
                quiverFreeSlots = free
            end
        end
    end

    if not quiverSlot then
        GetQuiverSlot()
    else
        local _,quiverType = GetContainerNumFreeSlots(quiverSlot)
        if bit.band(quiverType or 0,3) == 0 then
            GetQuiverSlot()
        end
    end
    if not quiverSlot then return end
    local id
    table.wipe(closestSlot)
    local numQuiverSlots = GetContainerNumSlots(quiverSlot)
    local t = GetTime()
    local colour = addon.guideTextColors["RXP_WARN_"]
    if inventoryManager.manualDelete then
        inventoryManager.manualDelete = false
        addon.comms.PrettyPrint(L("|c%sSorting arrows/bullets|r"), colour)
    elseif t - sortTimer > 3 then
        addon.comms.PrettyPrint(L("|c%sInventory is full, sorting arrows/bullets|r"), colour)
    end
    sortTimer = t

    for slot = 1, numQuiverSlots do
        id = GetContainerItemID(quiverSlot, slot)

        if id then
            if not closestSlot[id] then
                closestSlot[id] = numQuiverSlots
            end
            --local t = GetItemInfo(id)
            local maxStack = select(8, GetItemInfo(id))
            --print(maxStack)
            local itemtable,stack,locked = GetContainerItemInfo(quiverSlot, slot)
            if type(itemtable) == "table" then
                stack,locked = itemtable.stackCount,itemtable.isLocked
            end
            --print('sl',stack,locked)
            if slot < closestSlot[id] then
                closestSlot[id] = slot
            elseif stack < maxStack then
                local itemExists,_,destLocked = GetContainerItemInfo(quiverSlot,closestSlot[id])
                if type(itemExists) == "table" then
                    destLocked = itemExists.isLocked
                end
                organizeQuiver = true
                if not (GetCursorInfo() or locked or itemExists and destLocked) then
                    C_Timer.After(0.01,function()
                        if not (GetCursorInfo() or UnitIsDead('player') or InCombatLockdown()) then
                            PickupContainerItem(quiverSlot, slot)
                            PickupContainerItem(quiverSlot, closestSlot[id])
                            ClearCursor()
                            --print(quiverSlot, slot)
                        end
                    end)
                    break
                end
            end
        end

    end

end

local exceptions = {
    [6196] = true,
}

-- Restrict automatic class/proficiency disposal to worn armor, shields, and
-- actual weapon slots. ItemUpgrades requires a definite spellbook or localized
-- skill-line result before it reports a weapon as unwearable; unknown metadata
-- therefore remains protected from automatic selling/deletion.
local BODY_ARMOR_EQUIP_LOCS = {
    INVTYPE_HEAD = true,
    INVTYPE_SHOULDER = true,
    INVTYPE_CHEST = true,
    INVTYPE_ROBE = true,
    INVTYPE_WAIST = true,
    INVTYPE_LEGS = true,
    INVTYPE_FEET = true,
    INVTYPE_WRIST = true,
    INVTYPE_HAND = true
}

local WEAPON_EQUIP_LOCS = {
    INVTYPE_WEAPON = true,
    INVTYPE_WEAPONMAINHAND = true,
    INVTYPE_WEAPONOFFHAND = true,
    INVTYPE_2HWEAPON = true,
    INVTYPE_RANGED = true,
    INVTYPE_RANGEDRIGHT = true,
    INVTYPE_THROWN = true
}

local function IsEquippableLocation(itemEquipLoc)
    return itemEquipLoc and itemEquipLoc ~= "" and
               itemEquipLoc ~= "INVTYPE_AMMO" and
               itemEquipLoc ~= "INVTYPE_BAG" and
               itemEquipLoc ~= "INVTYPE_BODY" and
               itemEquipLoc ~= "INVTYPE_TABARD" and
               itemEquipLoc ~= "INVTYPE_NON_EQUIP_IGNORE"
end

local function GetManualJunkKey(id, itemLink, itemEquipLoc)
    if not IsEquippableLocation(itemEquipLoc) or type(itemLink) ~= "string" then
        return id
    end
    -- Equipment with random properties shares its base item ID with every
    -- suffix. Keep the complete item string so a manual decision for one copy
    -- does not contaminate a differently rolled upgrade.
    return itemLink:match("|H(item:[^|]+)|h") or
               itemLink:match("(item:[^|]+)") or id
end

local function IsConsumable(itemID, itemLink, itemType)
    if _G.IsConsumableItem then
        for _, item in ipairs({itemID, itemLink}) do
            if item then
                local ok, result = pcall(_G.IsConsumableItem, item)
                if ok and (result == true or result == 1) then return true end
            end
        end
    end

    -- GetItemInfo's class name is localized and some 3.3.5 cores use the
    -- singular while their Auction House global is plural. Compare every known
    -- client-local string, retaining English only as a final fallback.
    if type(itemType) == "string" then
        local normalizedType = itemType:lower()
        for _, className in pairs({
            _G.ITEMCLASS_CONSUMABLE,
            _G.ITEM_CLASS_CONSUMABLE,
            _G.AUCTION_CATEGORY_CONSUMABLES,
            "Consumable",
            "Consumables"
        }) do
            if type(className) == "string" and
                normalizedType == className:lower() then
                return true
            end
        end
    end

    -- AzerothCore can omit or alter the class string for a few legacy items.
    -- Food, water, potions, bandages, and scrolls expose an on-use spell even
    -- when their item-class metadata is incomplete. Conservatively protecting
    -- other on-use items is preferable to automatically selling/deleting them;
    -- they remain manually markable through the explicit override below.
    if GetItemSpell then
        for _, item in ipairs({itemID, itemLink}) do
            if item then
                local ok, spellName = pcall(GetItemSpell, item)
                if ok and spellName then return true end
            end
        end
    end
    return false
end

local function IsMiscellaneousItemType(itemType)
    if type(itemType) ~= "string" then return nil end
    local normalizedType = itemType:lower()
    for _, className in pairs({
        _G.ITEMCLASS_MISCELLANEOUS,
        _G.ITEM_CLASS_MISCELLANEOUS,
        _G.AUCTION_CATEGORY_MISCELLANEOUS,
        "Miscellaneous"
    }) do
        if type(className) == "string" and
            normalizedType == className:lower() then
            return true
        end
    end
    return false
end

local function IsProtectedUtilityItem(itemType, itemEquipLoc)
    -- Hunters must never lose ammunition to a generic white-item rule, and bags
    -- are useful containers rather than vendor trash.
    if itemEquipLoc == "INVTYPE_AMMO" or itemEquipLoc == "INVTYPE_BAG" then
        return true
    end
    -- Non-equipment classes other than Miscellaneous cover quest items, keys,
    -- recipes, reagents, trade goods, gems, glyphs, and similar functional items.
    -- Unknown/localized metadata stays protected until it can be classified.
    local miscellaneous = IsMiscellaneousItemType(itemType)
    return miscellaneous == nil or not miscellaneous
end

local function IsSoulBag(bag)
    if bag == nil then return false end
    local _, bagType = GetContainerNumFreeSlots(bag)
    return bit.band(bagType or 0, SOUL_BAG_FAMILY) ~= 0
end

-- Whole stacks are marked only when every shard in that stack is beyond the
-- configured cap. This may conservatively retain one stack which crosses the
-- boundary, but automatic selling/deletion can never take the player below it.
local function IsSurplusSoulShard(bag, slot)
    if addon.player.class ~= "WARLOCK" or bag == nil or slot == nil or
        IsSoulBag(bag) then return false end

    local cap = math.max(0, math.floor(tonumber(
        addon.settings.profile.maxSoulShards) or 100))
    if (GetItemCount(SOUL_SHARD_ID) or 0) <= cap then return false end

    local protectedCount = 0
    local ordinaryBefore = 0
    local firstBag = _G.BACKPACK_CONTAINER or 0
    local lastBag = _G.NUM_BAG_FRAMES or _G.NUM_BAG_SLOTS or 4
    for scanBag = firstBag, lastBag do
        local soulBag = IsSoulBag(scanBag)
        for scanSlot = 1, GetContainerNumSlots(scanBag) do
            if GetContainerItemID(scanBag, scanSlot) == SOUL_SHARD_ID then
                local _, stack = GetContainerItemInfo(scanBag, scanSlot)
                stack = tonumber(stack) or 1
                if soulBag then
                    protectedCount = protectedCount + stack
                elseif scanBag < bag or
                    (scanBag == bag and scanSlot < slot) then
                    ordinaryBefore = ordinaryBefore + stack
                end
            end
        end
    end

    local ordinaryAllowance = math.max(cap - protectedCount, 0)
    return ordinaryBefore >= ordinaryAllowance
end

local function IsJunk(id, bag, slot)
    if not id then return end
    -- The bag link contains random suffixes, enchants, and other instance data
    -- which GetItemInfo(itemID) discards. Scoring the base item could therefore
    -- mark a green "+Agility" upgrade as junk while its visible tooltip showed
    -- positive EP. Always evaluate the exact item instance when one is present.
    local bagItemLink = bag ~= nil and slot ~= nil and
                            GetContainerItemLink(bag, slot)
    local itemName, cachedLink, quality, _, _, itemType, _, _, itemEquipLoc =
        GetItemInfo(bagItemLink or id)
    local itemLink = bagItemLink or cachedLink
    local explicitOverrides = RXPCData.manualJunkOverrides
    local overrideKey = GetManualJunkKey(id, itemLink, itemEquipLoc)
    local explicit = explicitOverrides and explicitOverrides[overrideKey]
    local legacyExplicit = overrideKey ~= id and explicitOverrides and
                               explicitOverrides[id]
    -- New manual choices always win, including for consumables. Keeping these
    -- separate from discardPile also prevents hidden consumable assignments
    -- created while the old consumable toggle was broken from resurfacing.
    if explicit ~= nil then return explicit end
    -- An old item-ID-wide useful choice is always safe to preserve. A legacy
    -- junk=true choice for equipment is deferred to the current EP result below
    -- because it may describe a different random suffix.
    if legacyExplicit == false then return false end

    -- Never sell/delete an item while the legacy cache has not supplied enough
    -- metadata to classify it. Bag and item-info events will retry shortly.
    if not itemName or not itemLink then return false end

    if IsConsumable(id, itemLink, itemType) then return false end

    -- `manualJunkOverrides` records all choices made by current versions. Keep a
    -- legacy "useful" choice as a safety override, but defer legacy junk=true
    -- until after current wearability/EP calculations: old releases also wrote
    -- automatic classifications into discardPile, where they otherwise remain
    -- stale after gear, level, spec, or stat changes.
    local discard = RXPCData.discardPile[id]
    if discard == false then return false end

    if exceptions[id] then return false end
    if id == SOUL_SHARD_ID then return IsSurplusSoulShard(bag, slot) end

    local equippable = IsEquippableLocation(itemEquipLoc)
    if equippable then
        local upgrades = addon.itemUpgrades
        -- Explicitly junk body armor, shields, and weapons outside the
        -- character's current proficiency. The shared wearability helper uses
        -- the class map plus the actual 3.3.5 spellbook/skill-line result, and
        -- returns "unknown" rather than risking an item when metadata is late.
        if upgrades and upgrades.GetItemWearability and itemLink and
            (BODY_ARMOR_EQUIP_LOCS[itemEquipLoc] or
                itemEquipLoc == "INVTYPE_SHIELD" or
                WEAPON_EQUIP_LOCS[itemEquipLoc]) and
            upgrades:GetItemWearability(itemLink) == "unwearable" then
            return true
        end

        -- Mark scored equipment of any quality as junk when every valid slot
        -- comparison proves a negative EP result.  Multi-slot items remain safe
        -- if they improve even one slot, and equal/unknown comparisons are kept.
        -- Manual useful overrides above always take precedence.
        if upgrades and upgrades.GetItemUpgradeStatus and itemLink then
            local status = upgrades:GetItemUpgradeStatus(itemLink)
            if status == "upgrade" then return false end
            if status == "downgrade" then return true end
            if status == "equal" and
                (quality == Enum.ItemQuality.Poor or
                    quality == Enum.ItemQuality.Common) then
                return true
            end
        end
        -- Equal, unknown, or not-yet-cached equipment stays safe. Current manual
        -- junk choices already returned through manualJunkOverrides above; a
        -- legacy discardPile=true must not turn an uncertain item into a sale.
        return false
    end
    if IsProtectedUtilityItem(itemType, itemEquipLoc) then return false end
    if discard == true then return true end
    if quality == Enum.ItemQuality.Poor or
        quality == Enum.ItemQuality.Common then return true end
    --TODO: Integrate with item upgrade system to auto sell soulbound greens, check if C_Item.IsBound exists, otherwise parse tooltips, check if character has enchanting or not
end

inventoryManager.IsJunk = IsJunk

local function ToggleJunk(id,bag,slot)
    if not id then return end
    local junk = IsJunk(id, bag, slot)
    local bagItemLink = bag ~= nil and slot ~= nil and
                            GetContainerItemLink(bag, slot)
    local _, cachedLink, _, _, _, _, _, _, itemEquipLoc =
        GetItemInfo(bagItemLink or id)
    local link = bagItemLink or cachedLink
    local overrideKey = GetManualJunkKey(id, link, itemEquipLoc)
    local colour = addon.guideTextColors["RXP_WARN_"]
    local newState = not junk
    RXPCData.discardPile[id] = newState
    RXPCData.manualJunkOverrides = RXPCData.manualJunkOverrides or {}
    if overrideKey ~= id then
        -- Replace the obsolete ID-wide equipment choice with the exact item
        -- instance selected by the player.
        RXPCData.manualJunkOverrides[id] = nil
    end
    RXPCData.manualJunkOverrides[overrideKey] = newState
    if junk then
        addon.comms.PrettyPrint(L("|c%sSet %s as useful|r"), colour, link)
    else
        addon.comms.PrettyPrint(L("|c%sSet %s as junk|r"), colour, link)
    end
    inventoryManager.UpdateAllBags()
    -- Stock 3.3.5 bag buttons are refreshed/recycled after the modified-click
    -- handler returns. Reapply the logical state after that refresh so the coin
    -- overlay cannot be restored to its previous visual state for one frame.
    C_Timer.After(0.05, function() inventoryManager.UpdateAllBags() end)
    C_Timer.After(0.25, function() inventoryManager.UpdateAllBags() end)
    addon:SendEvent("RXP_JUNK", id, bag, slot)
end

inventoryManager.ToggleJunk = ToggleJunk

local function FindJunk(deleteItem)

    inventoryManager.deleteBag = nil
    inventoryManager.deleteSlot = nil

    if organizeQuiver then
        SortQuiver()
    end
    quiverSlot, projectileType, quiverFreeSlots = nil, 0, 0

    for bag = BACKPACK_CONTAINER, NUM_BAG_FRAMES do
        local freeSlots, bagType = GetContainerNumFreeSlots(bag)
        --print(bagType,freeSlots,deleteItem)
        if bagType and bagType == 0 and freeSlots and freeSlots > 0 and not deleteItem then
            return
        end

        local ammoFamily = bit.band(bagType or 0, 3)
        --bit flag 1 for arrows, 2 for guns, according to ItemBagFamily.db2
        --add 1 to compare with Enum.ItemWeaponSubclass (2 for arrows, 3 for bullets)
        if ammoFamily == 1 or ammoFamily == 2 then
            quiverSlot = bag
            projectileType = ammoFamily + 1
            quiverFreeSlots = freeSlots
        end
    end

    local movingAmmo
    local bestBag, bestSlot
    local bestValue = math.huge

    for bag = BACKPACK_CONTAINER, NUM_BAG_FRAMES do
        local _,bagType = GetContainerNumFreeSlots(bag)
        local numSlots
        if not bagType or bagType > 2 then
            numSlots = 0
        else
            numSlots = GetContainerNumSlots(bag)
        end
        for slot = 1, numSlots do
            local isProjectile
            local id = GetContainerItemID(bag, slot)
            if id then
                local subclass, stackMax, price = GetProjectileSubclass(id)
                if bagType == 0 and subclass == projectileType then
                    isProjectile = true
                end

                if not (isProjectile or movingAmmo) then
                    local t,count = GetContainerItemInfo(bag,slot)
                    if type(t) == "table" and not count then
                        count = t.stackCount
                    end
                    if stackMax and count and IsJunk(id,bag,slot) then
                        --local item_count = select(2, GetContainerItemInfo(bag, slot))
                        price = price or 0
                        local value = (stackMax + count) * price/2
                        if value < bestValue then
                            bestBag = bag
                            bestSlot = slot
                            bestValue = value
                            --print(bestBag,bestSlot)
                        end
                    end
                elseif isProjectile and quiverFreeSlots > 0 then
                    local _, quiverFamily = GetContainerNumFreeSlots(quiverSlot)
                    local expectedSubclass = bit.band(quiverFamily or 0, 3) + 1
                    if expectedSubclass == subclass and not (InCombatLockdown() or
                        UnitIsDead('player') or GetCursorInfo()) then
                        movingAmmo = true
                        bestBag,bestSlot,bestValue = nil,nil,nil
                        PickupContainerItem(bag, slot)
                        PutItemInBag(quiverSlot + CharacterBag0Slot:GetID() - 1)

                        --CharacterBag0Slot:BagSlotButton_OnClick()
                        --/run local bagframe = _G["CharacterBag".. tostring(1 - 1) .."Slot"] local f = bagframe:GetScript("OnClick") print(f) f(bagframe,"LeftButton")

                        quiverFreeSlots = quiverFreeSlots -1
                    end
                end
            end
        end
    end

    if movingAmmo then
        SortQuiver()
    elseif bestBag and bestSlot then
        inventoryManager.deleteBag = bestBag
        inventoryManager.deleteSlot = bestSlot
    elseif inventoryManager.clickFrame then
        inventoryManager.clickFrame:Hide()
    end
    --print(bestBag,bestSlot)
end

local function DeleteItems()
    if inventoryManager.sellGoods and MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 then
        inventoryManager.ProcessJunk(true)
        return
    elseif UnitIsDead('player') or GetCursorInfo() then
        return
    elseif inventoryManager.deleteBag then
        PickupContainerItem(inventoryManager.deleteBag,inventoryManager.deleteSlot)
        DeleteCursorItem()
        local colour = addon.guideTextColors["RXP_WARN_"]
        local _,stack,_,_,_,_,link = GetContainerItemInfo(inventoryManager.deleteBag,inventoryManager.deleteSlot)
        if link then
            if inventoryManager.manualDelete then
               addon.comms.PrettyPrint(L("|c%sDeleting %sx%s|r"),colour,link,stack)
            else
                addon.comms.PrettyPrint(L("|c%sInventory is full, deleting %sx%s|r"),colour,link,stack)
            end
        end
        inventoryManager.deleteBag = nil
        inventoryManager.deleteSlot = nil
    elseif organizeQuiver and not InCombatLockdown() then
        SortQuiver()
    end
end

local DeleteCheapestItem = function(self,deleteIfFull)

    if not inventoryManager.bagUpdated then
        return
    end
    inventoryManager.manualDelete = true
    FindJunk(not deleteIfFull)
    DeleteItems(true)
    inventoryManager.manualDelete = false
end

inventoryManager.itemsToOpen = {}
local function OpenItems()
    if not next(inventoryManager.itemsToOpen) then return end
    for bag = _G.BACKPACK_CONTAINER, _G.NUM_BAG_FRAMES do
        for slot = 1, GetContainerNumSlots(bag) do
            local _, _, locked, _, _, _, _, _, _, id = GetContainerItemInfo(bag, slot)
            if not locked and inventoryManager.itemsToOpen[id] then
                UseContainerItem(bag, slot)
            end
        end
    end
end

addon.DeleteCheapestItem = DeleteCheapestItem
--A3 =DeleteCheapestItem

local btn = CreateFrame("BUTTON", "RXPInventory_DeleteJunk")
btn:SetScript("OnClick", function()
    DeleteCheapestItem()
end)

BINDING_HEADER_RXPInventory = addon.title

_G["BINDING_NAME_CLICK RXPInventory_DeleteJunk:LeftButton"] =
    L("Delete Cheapest Junk Item")

local function IsEventSupported(event)
    return not (C_EventUtils and C_EventUtils.IsEventValid) or
               C_EventUtils.IsEventValid(event)
end

local function RegisterSupportedEvent(frame, event)
    if not IsEventSupported(event) then return false end
    frame:RegisterEvent(event)
    return true
end

-- BAG_UPDATE_DELAYED does not exist in the stock 3.3.5 client. Registering an
-- unknown event aborts the remainder of this file, which also prevents the
-- stock ContainerFrame hook and junk textures from ever being installed.
local bagEvent = IsEventSupported("BAG_UPDATE_DELAYED") and
                     "BAG_UPDATE_DELAYED" or "BAG_UPDATE"
local WorldFrameHook = function(self,...)
    --local n = self and self:GetName()
    --print(n,...)
    if inventoryManager.IsBagAutomationEnabled() then
        DeleteItems()
    end
    OpenItems()
end
local f = inventoryManager.DeleteJunkFrame or CreateFrame("Frame","RXPDeleteJunk",UIParent)
f:RegisterEvent("PLAYER_ENTERING_WORLD")

local clickFrame

if f.SetPassThroughButtons then
    --post patch 1.15.7 workaround
    clickFrame = CreateFrame("Frame","RXPJunkHandler",UIParent)
    inventoryManager.clickFrame = clickFrame
    clickFrame:SetAllPoints(UIParent)
    clickFrame:SetScript("OnMouseDown", function(self)
        WorldFrameHook()
        if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i)
            end
        end
        clickFrame:Hide()
    end)

    local button = "LootButton"
    local current = _G["LootButton1"]
    local i = 1
    while current and i < 10 do
        current:HookScript("OnClick",WorldFrameHook)
        i = i + 1
        current = _G[button .. i]
    end

    clickFrame:EnableMouse(false)
    clickFrame:SetMouseClickEnabled(true)
    clickFrame:EnableMouseMotion(false)
    clickFrame:EnableMouseWheel(false)
    clickFrame:SetFrameStrata("BACKGROUND")
    clickFrame:SetFrameLevel(0)
    clickFrame:Hide()
end

--You can only delete items on a hardware input, so we hook every keyboard input and mouse click to our item deletion function

f:SetScript("OnEvent",function(self)
    inventoryManager.bagUpdated = true
    self:RegisterEvent(bagEvent)
    local lootEvent = C_EventUtils and C_EventUtils.IsEventValid and
        C_EventUtils.IsEventValid("LOOT_READY") and "LOOT_READY" or "LOOT_OPENED"
    self:RegisterEvent(lootEvent)
    self:RegisterEvent("UI_ERROR_MESSAGE")

    self:SetScript("OnEvent",function(self,event,flag,msg)
        if clickFrame then
            if inventoryManager.IsBagAutomationEnabled() then
                if event == "UI_ERROR_MESSAGE" and flag == 3 and msg == INVENTORY_FULL and LootFrame:IsShown() then
                    clickFrame:Show()
                end
            else
                clickFrame:Hide()
            end
        end
        if inventoryManager.IsBagAutomationEnabled() then
            FindJunk()
        end
    end)
    RXPCData.discardPile = RXPCData.discardPile or {}
    RXPCData.manualJunkOverrides = RXPCData.manualJunkOverrides or {}

    WorldFrame:HookScript("OnMouseDown", WorldFrameHook)
    WorldFrame:HookScript("OnMouseUp", WorldFrameHook)

    inventoryManager.DeleteJunkFrame = self

    self:SetPropagateKeyboardInput(true)
    self:SetScript("OnKeyDown", WorldFrameHook)
    self:SetScript("OnKeyUp", WorldFrameHook)

    if _G["ContainerFrameItemButton_OnModifiedClick"] then
        hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", function(self,button)
            local mod = inventoryManager.GetModKey()
            if not inventoryManager.IsRightClickEnabled() or not mod or button ~= inventoryManager.GetMouseButton() then
                return
            end
            local parent = self:GetParent()
            local bag = parent and parent:GetID()
            local slot = self:GetID()
            if bag and slot then
                local id = GetContainerItemID(bag,slot)
                ToggleJunk(id,bag,slot)
            end

        end)
    end

    -- Guard: a bag addon (e.g. Bagnon) may have replaced these globals, and
    -- hooksecurefunc errors if the named global isn't a function.
    if type(_G.ToggleAllBags) == "function" then
        hooksecurefunc('ToggleAllBags', inventoryManager.InitializeBags)
    end
    if type(_G.ToggleBag) == "function" then
        hooksecurefunc('ToggleBag', inventoryManager.InitializeBags)
    end
    _G.MainMenuBarBackpackButton:HookScript("OnClick",inventoryManager.InitializeBags)
    if inventoryManager.EnsureStockBagHooks then
        inventoryManager.EnsureStockBagHooks()
    end

end)

local junkIcons = {}

local function ShowJunkIcon(frame)

    if not frame.RXPJunkIcon then
        -- A stock item button owns a Cooldown child frame which renders above
        -- textures created directly on the button. Give the junk marker its
        -- own mouse-transparent child frame at a higher frame level so it stays
        -- visible regardless of the cooldown/quest-border state.
        local overlay = CreateFrame("Frame", nil, frame)
        overlay:SetAllPoints(frame)
        overlay:SetFrameLevel((frame:GetFrameLevel() or 0) + 8)
        overlay:EnableMouse(false)

        local texture = overlay:CreateTexture(nil, "OVERLAY")
        table.insert(junkIcons,texture)
        texture:SetTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up")
        texture:SetWidth(16)
        texture:SetHeight(16)
        texture:SetTexCoord(0, 1, 0, 1)
        texture:SetAlpha(1)
        if inventoryManager.alignment == "TOPRIGHT" then
            texture:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", -1, -1)
        else
            texture:SetPoint("TOPLEFT", overlay, "TOPLEFT", 1, -1)
        end
        frame.RXPJunkOverlay = overlay
        frame.RXPJunkIcon = texture
    end

    if inventoryManager.IsJunkIconEnabled() then
        frame.RXPJunkOverlay:Show()
        frame.RXPJunkIcon:Show()
    else
        frame.RXPJunkIcon:Hide()
        frame.RXPJunkOverlay:Hide()
    end

end

local function HideJunkIcon(frame)

    if frame.RXPJunkIcon then
        frame.RXPJunkIcon:Hide()
        if frame.RXPJunkOverlay then frame.RXPJunkOverlay:Hide() end
    end

end

local function UpdateBagButton(button,bag,slot)
    local id = GetContainerItemID(bag, slot)

    local isJunk = IsJunk(id, bag, slot)
    --print(bag,slot,isJunk)
    if isJunk then
        ShowJunkIcon(button)
    else
        HideJunkIcon(button)
    end
end

local bagFrame = {}

for i = BACKPACK_CONTAINER, NUM_BAG_FRAMES do
    bagFrame[i] = {}
end



local function UpdateBag(frame,name,pattern)
    if not inventoryManager.IsJunkIconEnabled() then
        return
    end
    pattern = pattern or inventoryManager.containerPattern
    name = name or frame:GetName()
    local i = 1
    local ref = format(pattern,name,i)
    local lastFrame
    local button = _G[ref]

    while button and lastFrame ~= ref do
        local parent = button:GetParent()
        local bag = parent and parent:GetID()
        if bag and bag >= BACKPACK_CONTAINER and bag <= NUM_BAG_FRAMES then
            local slot = button:GetID()
            bagFrame[bag][slot] = ref
            --print(ref)
            UpdateBagButton(button,bag,slot)
        end
        i = i + 1
        lastFrame = ref
        ref = format(pattern,name,i)
        button = _G[ref]
    end
end

--Junk icon has to hook into existing UI elements, different bag UI mods have different frame names causing compatibility issues

inventoryManager.containerPattern = "%sItem%d"
inventoryManager.containerName = "ContainerFrame%d"
inventoryManager.containerIndex = -1
inventoryManager.alignment = "TOPLEFT"

local function DetectBagMods()
    if _G["BagnonContainerItem1"] then
        inventoryManager.containerName = "BagnonContainerItem%d"
        inventoryManager.containerPattern = "%s"
    elseif _G["ElvUI_ContainerFrame"] then
        inventoryManager.containerName = "ElvUI_ContainerFrameBag%d"
        inventoryManager.containerPattern = "%sSlot%d"
    elseif _G["AdiBagsItemButton1"] then
        inventoryManager.containerName = "AdiBagsItemButton%d"
        inventoryManager.containerPattern = "%s"
    elseif _G["BetterBagsItemButton1"] then
        inventoryManager.containerName = "BetterBagsItemButton%d"
        inventoryManager.containerPattern = "%s"
    elseif _G["BagginsPooledItemButton0"] then
        inventoryManager.containerName = "BagginsPooledItemButton%d"
        inventoryManager.containerPattern = "%s"
    elseif _G["ARKINV_Frame1ScrollContainer"] then
        inventoryManager.containerName = "ARKINV_Frame1ScrollContainerBag%d"
    elseif _G["BaudBagSubBag0"] then
        inventoryManager.containerName = "BaudBagSubBag%d"
    elseif _G["Baganator"] then
        inventoryManager.containerName = "BGRLiveItemButton%d"
        inventoryManager.containerPattern = "%s"
        inventoryManager.alignment = "TOPRIGHT"
    end
end


local function UpdateAllBags(self,name,i)
    if not inventoryManager.IsJunkIconEnabled() then
        for _,icon in pairs(junkIcons) do
            icon:Hide()
        end
        return
    end
    DetectBagMods()
    i = i or inventoryManager.containerIndex
    name = name or inventoryManager.containerName
    if gameVersion == 30300 and name == "ContainerFrame%d" then
        -- All thirteen stock frames exist up front and are recycled between
        -- bags. Only their shown instances have a meaningful current bag ID.
        for index = 1, (_G.NUM_CONTAINER_FRAMES or 13) do
            local frame = _G[format(name, index)]
            if frame and frame:IsShown() then UpdateBag(frame) end
        end
        return
    end
    --print(name,inventoryManager.containerPattern)
    local ref = format(name,i)
    local frame = _G[ref]
    while frame or i <= 0 do
        if frame then
            UpdateBag(frame,ref)
        end
        i = i + 1
        ref = format(name,i)
        frame = _G[ref]
    end
end
inventoryManager.UpdateAllBags = UpdateAllBags

local iconRefreshSerial = 0
function inventoryManager.RefreshJunkIcons(delay)
    iconRefreshSerial = iconRefreshSerial + 1
    local serial = iconRefreshSerial
    C_Timer.After(delay or 0, function()
        if serial == iconRefreshSerial then UpdateAllBags() end
    end)
end

local invUpdate = CreateFrame("Frame")
local hasItemLocked = RegisterSupportedEvent(invUpdate, "ITEM_LOCKED")
local hasItemUnlocked = RegisterSupportedEvent(invUpdate, "ITEM_UNLOCKED")
-- Stock 3.3.5 combines the two newer lock events into this one.
if not (hasItemLocked and hasItemUnlocked) then
    RegisterSupportedEvent(invUpdate, "ITEM_LOCK_CHANGED")
end
RegisterSupportedEvent(invUpdate, "BAG_CONTAINER_UPDATE")
if bagEvent ~= "BAG_UPDATE" then
    RegisterSupportedEvent(invUpdate, bagEvent)
end
RegisterSupportedEvent(invUpdate, "BAG_UPDATE")
if gameVersion == 30300 then
    RegisterSupportedEvent(invUpdate, "ITEM_PUSH")
end
RegisterSupportedEvent(invUpdate, "GET_ITEM_INFO_RECEIVED")
RegisterSupportedEvent(invUpdate, "PLAYER_EQUIPMENT_CHANGED")
RegisterSupportedEvent(invUpdate, "LOOT_CLOSED")
RegisterSupportedEvent(invUpdate, "MERCHANT_SHOW")
RegisterSupportedEvent(invUpdate, "PLAYER_MONEY")
local updateTimer = 0
local merchantOpened
local updateBags
inventoryManager.BagHandler = function(self,event,bag,slot)
    if type(event) == "number" then
        updateTimer = updateTimer + event
        if updateTimer > 0.33 then
            if merchantOpened then
                merchantOpened = false
                inventoryManager.ProcessJunk(true)
            end
            if updateBags then
                updateBags = false
                UpdateAllBags()
            end
            updateTimer = 0
            self:SetScript("OnUpdate",nil)
        end
        return
    elseif event == "PLAYER_MONEY" and inventoryManager.sellGoods then
        merchantOpened = true
        updateTimer = 0.125
        self:SetScript("OnUpdate",inventoryManager.BagHandler)
        return
    elseif event == "BAG_CONTAINER_UPDATE" then
        updateTimer = 0
        updateBags = true
        self:SetScript("OnUpdate",inventoryManager.BagHandler)
    elseif event == "MERCHANT_SHOW" then
        merchantOpened = true
        updateTimer = 0
        self:SetScript("OnUpdate",inventoryManager.BagHandler)
    elseif event == "BAG_UPDATE_DELAYED" or event == "BAG_UPDATE" or
        event == "ITEM_PUSH" or
        event == "LOOT_CLOSED" or
        event == "GET_ITEM_INFO_RECEIVED" or
        event == "PLAYER_EQUIPMENT_CHANGED" then
        updateTimer = 0
        updateBags = true
        self:SetScript("OnUpdate",inventoryManager.BagHandler)
    elseif inventoryManager.containerPattern ~= "%s" then
        if event == "ITEM_LOCKED" then
            local frame = bagFrame[bag] and bagFrame[bag][slot]
            frame = frame and _G[frame]
            if frame then
                HideJunkIcon(frame)
            end
        elseif event == "ITEM_UNLOCKED" or event == "ITEM_LOCK_CHANGED" then
            local frame = bagFrame[bag] and bagFrame[bag][slot]
            frame = frame and _G[frame]
            if frame then
                UpdateBagButton(frame,bag,slot)
            end
        end
    end
    if not next(junkIcons) then
        updateBags = true
        self:SetScript("OnUpdate",inventoryManager.BagHandler)
    end
end

invUpdate:SetScript("OnEvent",inventoryManager.BagHandler)


function inventoryManager.InitializeBags()
    if inventoryManager.EnsureStockBagHooks then
        inventoryManager.EnsureStockBagHooks()
    end
    -- Stock bag frames are pooled and can be reassigned to a different bag on
    -- every open. Always schedule a pass so an existing texture follows the
    -- button's current bag/slot rather than trusting its previous state.
    updateBags = true
    invUpdate:SetScript("OnUpdate",inventoryManager.BagHandler)
end

local stockBagHooksInstalled
local function EnsureStockBagHooks()
    if stockBagHooksInstalled then return true end
    if type(_G.ContainerFrame_Update) ~= "function" then return false end

    local ok = pcall(hooksecurefunc, "ContainerFrame_Update", function(self)
        UpdateBag(self, nil, "%sItem%d")
    end)
    if not ok then return false end

    -- ContainerFrame_OnShow calls ContainerFrame_Update on stock 3.3.5, but a
    -- second post-show pass also covers clients whose FrameXML was modified.
    if type(_G.ContainerFrame_OnShow) == "function" then
        pcall(hooksecurefunc, "ContainerFrame_OnShow", function(self)
            UpdateBag(self, nil, "%sItem%d")
        end)
    end
    inventoryManager.bagHook = _G.ContainerFrame_Update
    stockBagHooksInstalled = true
    return true
end
inventoryManager.EnsureStockBagHooks = EnsureStockBagHooks
EnsureStockBagHooks()

--[[
hooksecurefunc('ContainerFrameItemButton_OnEnter',function(self)
    print(self:GetName(),self:GetParent():GetID(),self:GetID())
end)]]


local function ProcessJunk(sellWares,override)
    local isMerchant = sellWares and MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 and (inventoryManager.IsMerchantAutomationEnabled() or override)
    local totalCost = 0
    local itemsToSell = {}
    for bag = BACKPACK_CONTAINER, NUM_BAG_FRAMES do
        for slot = 1, GetContainerNumSlots(bag) do
            local id = GetContainerItemID(bag,slot)
            local _,stack,locked,quality = GetContainerItemInfo(bag, slot)
            local junk = IsJunk(id, bag, slot)
            if junk then
                local price = select(11,GetItemInfo(id))
                local value = price * stack
                if isMerchant and value > 0 then
                    table.insert(itemsToSell,{bag = bag, slot = slot, value = value, quality = quality})
                end
                totalCost = totalCost + value
            end
        end
    end

    if totalCost == 0 then
        if inventoryManager.sellGoods then
            local value = GetMoney() - inventoryManager.sellGoods
            local colour = addon.guideTextColors["RXP_WARN_"]
            if value > 0 then
                addon.comms.PrettyPrint(L("|c%sSold junk items for|r %s"), colour, GetCoinTextureString(value))
            end
            inventoryManager.sellGoods = false
        end
    elseif isMerchant then
        inventoryManager.sellGoods = inventoryManager.sellGoods or GetMoney()
        --Sorts the item list to sell low quality/cheap items first, in case of needing to buy stuff back
        table.sort(itemsToSell,function(i1,i2)
            if i1.quality == i2.quality then
                return i1.value < i2.value
            else
                return i1.quality < i2.quality
            end
        end)

        for _,item in ipairs(itemsToSell) do
            PickupContainerItem(item.bag,item.slot)
            PickupMerchantItem()
        end

    end

    return totalCost
end
inventoryManager.ProcessJunk = ProcessJunk

function inventoryManager.ResetJunk()
    RXPCData.discardPile = {}
    RXPCData.manualJunkOverrides = {}
    inventoryManager.UpdateAllBags()
    inventoryManager.RefreshJunkIcons(0.05)
    addon:SendEvent("RXP_JUNK")
end

function inventoryManager.GetNetWorth()
    local inventory = ProcessJunk()
    return GetMoney() + inventory
end

