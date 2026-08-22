local _, addon = ...

-- The stock 3.3.5 keyring is exposed as container -2, but GetItemCount is not
-- consistent across old client builds and private-server UI replacements:
-- some include keyring stacks and some count only ordinary bags. Guide
-- completion must see keys without treating the keyring as a movable bag.

local _G = _G
local max = math.max
local tonumber, type = tonumber, type
local rawGetItemCount = _G.GetItemCount
local getContainerNumSlots = _G.GetContainerNumSlots
local getContainerItemID = _G.GetContainerItemID
local getContainerItemInfo = _G.GetContainerItemInfo
local getContainerItemLink = _G.GetContainerItemLink
local getInventoryItemID = _G.GetInventoryItemID
local getInventoryItemCount = _G.GetInventoryItemCount
local KEYRING_CONTAINER = _G.KEYRING_CONTAINER or -2
local FIRST_BAG = _G.BACKPACK_CONTAINER or 0
local LAST_BAG = _G.NUM_BAG_SLOTS or _G.NUM_BAG_FRAMES or 4
local LAST_EQUIPPED = _G.INVSLOT_LAST_EQUIPPED or 19

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, a, b, c, d = pcall(fn, ...)
    if ok then return a, b, c, d end
end

local function ItemID(item)
    if type(item) == "number" then return item end
    if type(item) ~= "string" then return end
    local id = tonumber(item) or tonumber(item:match("item:(%-?%d+)"))
    if id then return id end
    local _, link = SafeCall(_G.GetItemInfo, item)
    return type(link) == "string" and
               tonumber(link:match("item:(%-?%d+)")) or nil
end

local function ContainerItemID(container, slot)
    local id = SafeCall(getContainerItemID, container, slot)
    if id then return tonumber(id) end
    local link = SafeCall(getContainerItemLink, container, slot)
    return type(link) == "string" and
               tonumber(link:match("item:(%-?%d+)")) or nil
end

local function CountContainer(container, wantedID)
    local slots = tonumber(SafeCall(getContainerNumSlots, container)) or 0
    local count = 0
    for slot = 1, slots do
        if ContainerItemID(container, slot) == wantedID then
            local _, stack = SafeCall(getContainerItemInfo, container, slot)
            count = count + max(1, tonumber(stack) or 1)
        end
    end
    return count
end

local function CountOrdinaryCarried(wantedID)
    local count = 0
    for bag = FIRST_BAG, LAST_BAG do
        count = count + CountContainer(bag, wantedID)
    end
    if type(getInventoryItemID) == "function" then
        for slot = 1, LAST_EQUIPPED do
            if SafeCall(getInventoryItemID, "player", slot) == wantedID then
                local stack = SafeCall(getInventoryItemCount, "player", slot)
                count = count + max(1, tonumber(stack) or 1)
            end
        end
    end
    return count
end

local function RawCount(item, includeBank)
    return max(0, tonumber(SafeCall(rawGetItemCount, item, includeBank)) or 0)
end

local function GetItemCountIncludingKeyring(item, includeBank)
    local requestedCount = RawCount(item, includeBank)
    local wantedID = ItemID(item)
    if not wantedID or wantedID <= 0 then return requestedCount end

    -- Keep the common path cheap. Only reconcile the slower ordinary-bag and
    -- equipment count when this particular item is actually in the keyring.
    local keyringCount = CountContainer(KEYRING_CONTAINER, wantedID)
    if keyringCount <= 0 then return requestedCount end

    local rawCarried = RawCount(item, false)
    local explicitCarried = CountOrdinaryCarried(wantedID) + keyringCount
    local missingFromLegacyAPI = max(0, explicitCarried - rawCarried)
    return requestedCount + missingFromLegacyAPI
end

addon.GetItemCount = GetItemCountIncludingKeyring

-- C_Item is a compatibility namespace on 3.3.5, never a native API. Publish
-- the reconciled count there so guide databases and later-loaded features use
-- the same result, while leaving the global GetItemCount untouched for other
-- addons.
_G.C_Item = type(_G.C_Item) == "table" and _G.C_Item or {}
_G.C_Item.GetItemCount = GetItemCountIncludingKeyring
