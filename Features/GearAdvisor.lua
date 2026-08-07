local _, addon = ...

local _G = _G
local format = string.format
local L = addon.locale.Get

addon.gearAdvisor = addon.gearAdvisor or {}
local advisor = addon.gearAdvisor
local MAX_ROWS = 11

local stateOrder = {upgrade = 1, equal = 2, unknown = 3, downgrade = 4}
local slotLabels = {}
local function AddSlotLabel(slot, label)
    if type(slot) == "number" then slotLabels[slot] = label end
end
AddSlotLabel(_G.INVSLOT_MAINHAND, _G.INVTYPE_WEAPONMAINHAND or "Main hand")
AddSlotLabel(_G.INVSLOT_OFFHAND, _G.INVTYPE_WEAPONOFFHAND or "Off hand")
AddSlotLabel(_G.INVSLOT_RANGED, _G.INVTYPE_RANGED or "Ranged")
AddSlotLabel(_G.INVSLOT_FINGER1, _G.INVTYPE_FINGER or "Ring")
AddSlotLabel(_G.INVSLOT_FINGER2, _G.INVTYPE_FINGER or "Ring")
AddSlotLabel(_G.INVSLOT_TRINKET1, _G.INVTYPE_TRINKET or "Trinket")
AddSlotLabel(_G.INVSLOT_TRINKET2, _G.INVTYPE_TRINKET or "Trinket")

local function Increase(comparison)
    return addon.itemUpgrades:GetComparisonIncrease(comparison)
end

local function ItemName(link)
    return (link and GetItemInfo(link)) or link or L("Unknown item")
end

function advisor:ScanBags()
    local output = {}
    for bag = _G.BACKPACK_CONTAINER or 0,
        _G.NUM_BAG_SLOTS or _G.NUM_BAG_FRAMES or 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local _, _, _, _, requiredLevel, _, _, _, equipLoc =
                    GetItemInfo(link)
                if equipLoc and equipLoc ~= "" and
                    (tonumber(requiredLevel) or 0) <= UnitLevel("player") then
                    local comparison, itemState, reason =
                        addon.itemUpgrades:GetBestUpgradeComparison(link)
                    if not comparison then
                        local _, compareReason, compareState =
                            addon.itemUpgrades:CompareItemWeight(link, nil, true)
                        itemState = compareState or itemState or "unknown"
                        reason = compareReason or reason
                    end
                    table.insert(output, {
                        link = link, name = ItemName(link), bag = bag, slot = slot,
                        comparison = comparison, state = itemState or "unknown",
                        reason = reason,
                        increase = comparison and Increase(comparison) or 0
                    })
                end
            end
        end
    end
    table.sort(output, function(a, b)
        local ao = stateOrder[a.state] or 9
        local bo = stateOrder[b.state] or 9
        if ao ~= bo then return ao < bo end
        if a.increase ~= b.increase then return a.increase > b.increase end
        return a.name < b.name
    end)
    return output
end

function advisor:ScanRewards()
    local output = {}
    local count = GetNumQuestChoices and GetNumQuestChoices() or 0
    for choice = 1, count do
        local link = GetQuestItemLink("choice", choice)
        if link then
            local comparison, itemState, reason =
                addon.itemUpgrades:GetBestUpgradeComparison(link)
            if not comparison then
                local _, compareReason, compareState =
                    addon.itemUpgrades:CompareItemWeight(link, nil, true)
                itemState = compareState or itemState or "unknown"
                reason = compareReason or reason
            end
            table.insert(output, {
                link = link, name = ItemName(link), choice = choice,
                comparison = comparison, state = itemState or "unknown",
                reason = reason,
                increase = comparison and Increase(comparison) or 0
            })
        end
    end
    table.sort(output, function(a, b)
        return a.increase > b.increase
    end)
    return output
end

function advisor:BuildRows()
    if self.view == "rewards" then return self:ScanRewards() end
    if self.view == "auction" then
        return addon.itemUpgrades.AH and
                   addon.itemUpgrades.AH:GetAdvisorResults() or {}
    end
    return self:ScanBags()
end

local function StateText(entry)
    if entry.state == "upgrade" then
        return format("|cff40ff40" .. L("Upgrade +%.2f EP") .. "|r", entry.increase)
    elseif entry.state == "downgrade" then
        return "|cffff5050" .. L("Downgrade") .. "|r"
    elseif entry.state == "equal" then
        return "|cffffd100" .. L("Equivalent") .. "|r"
    end
    return "|cffb0b0b0" .. L("Unknown/cache pending") .. "|r"
end

local function LayoutText(entry)
    local comparison = entry.comparison
    if not comparison then return entry.reason or L("No complete comparison yet") end
    local equipLoc = select(9, GetItemInfo(entry.link))
    local slot = comparison.SlotCompared
    local slotName = slot and slotLabels[slot] or
                         (slot and ("#" .. tostring(slot)))
    local replaced = comparison.ItemLink and ItemName(comparison.ItemLink)
    if equipLoc == "INVTYPE_2HWEAPON" then
        return format(L("Replaces main-hand + off-hand layout%s"),
            replaced and (" (" .. format(L("including %s"), replaced) .. ")") or "")
    end
    return format("%s%s%s", entry.reason or "",
        slotName and ((entry.reason and entry.reason ~= "" and "  " or "") ..
            L("slot") .. " " .. tostring(slotName)) or "",
        replaced and (" " .. format(L("replacing %s"), replaced)) or "")
end

function advisor:Refresh()
    if not self.frame or not self.frame:IsShown() then return end
    local spec, source = addon.itemUpgrades:GetActiveSpecSource()
    self.frame.source:SetText(format(L("Weights: %s (%s)"),
        tostring(spec or L("unavailable")), tostring(source or L("unknown"))))
    local entries = self:BuildRows()
    self.entries = entries
    local offset = FauxScrollFrame_GetOffset(self.frame.scroll)
    FauxScrollFrame_Update(self.frame.scroll, #entries, MAX_ROWS, 32)
    for index, row in ipairs(self.frame.rows) do
        local entry = entries[offset + index]
        row.entry = entry
        if entry then
            row:Show()
            row.name:SetText(entry.link or entry.name)
            row.state:SetText(StateText(entry))
            row.detail:SetText(LayoutText(entry))
            if entry.state == "upgrade" and entry.bag ~= nil then
                row.action:SetText(L("Equip"))
                row.action:Enable()
            elseif entry.choice then
                row.action:SetText(L("Select"))
                row.action:Enable()
            elseif entry.auctionData then
                row.action:SetText(L("Find"))
                row.action:Enable()
            else
                row.action:SetText("--")
                row.action:Disable()
            end
        else
            row:Hide()
        end
    end
    self.frame.auctionHint:SetShown(self.view == "auction" and #entries == 0)
    self.frame.openAuction:SetShown(self.view == "auction" and #entries == 0)
end

function advisor:Equip(entry)
    if not entry then return end
    if entry.bag ~= nil then
        addon.itemUpgrades:EquipBagUpgrade({
            bag = entry.bag, bagSlot = entry.slot, itemLink = entry.link
        })
    elseif entry.choice then
        local button = _G.QuestInfo_GetRewardButton and
                           _G.QuestInfo_GetRewardButton(
                               _G.QuestInfoRewardsFrame, entry.choice)
        if button and button:IsShown() and button.Click then button:Click() end
    elseif entry.auctionData and addon.itemUpgrades.AH then
        addon.itemUpgrades.AH:SearchForBuyoutItem(entry.auctionData)
    end
    C_Timer.After(0.3, function() advisor:Refresh() end)
end

function advisor:SetView(view)
    self.view = view
    if self.frame and self.frame.scroll then
        FauxScrollFrame_SetOffset(self.frame.scroll, 0)
    end
    self:Refresh()
end

local function Tab(parent, text, x, view)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(105, 24)
    button:SetPoint("TOPLEFT", x, -72)
    button:SetText(text)
    button:SetScript("OnClick", function() advisor:SetView(view) end)
end

function advisor:CreateFrame()
    local frame = CreateFrame("Frame", "RXPGearAdvisor", UIParent)
    frame:SetSize(720, 500)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
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
    title:SetText(L("Gear Advisor"))
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)
    frame.source = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.source:SetPoint("TOPLEFT", 24, -48)
    Tab(frame, L("Bags"), 24, "bags")
    Tab(frame, L("Quest Rewards"), 137, "rewards")
    Tab(frame, L("Auction House"), 250, "auction")
    frame.rows = {}
    for index = 1, MAX_ROWS do
        local row = CreateFrame("Frame", nil, frame)
        row:SetSize(666, 31)
        row:SetPoint("TOPLEFT", 26, -108 - (index - 1) * 32)
        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.name:SetPoint("TOPLEFT", 2, -2)
        row.name:SetPoint("RIGHT", -245, 0)
        row.name:SetJustifyH("LEFT")
        row.state = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.state:SetPoint("TOPLEFT", 425, -2)
        row.state:SetPoint("RIGHT", -75, 0)
        row.state:SetJustifyH("LEFT")
        row.detail = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.detail:SetPoint("BOTTOMLEFT", 2, 1)
        row.detail:SetPoint("RIGHT", -75, 0)
        row.detail:SetJustifyH("LEFT")
        row.action = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.action:SetSize(66, 22)
        row.action:SetPoint("RIGHT", -1, 0)
        row.action:SetText(L("Equip"))
        row.action:SetScript("OnClick", function()
            advisor:Equip(row.entry)
        end)
        row:SetScript("OnEnter", function(self)
            if self.entry and self.entry.link then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(self.entry.link)
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row:EnableMouse(true)
        frame.rows[index] = row
    end
    frame.scroll = CreateFrame("ScrollFrame", "RXPGearAdvisorScroll", frame,
                               "FauxScrollFrameTemplate")
    frame.scroll:SetPoint("TOPLEFT", 20, -104)
    frame.scroll:SetPoint("BOTTOMRIGHT", -25, 38)
    frame.scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, 32,
                                         function() advisor:Refresh() end)
    end)
    frame.auctionHint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.auctionHint:SetPoint("CENTER", 0, 10)
    frame.auctionHint:SetText(
        L("Open an Auction House, then use RXPGuides' bounded upgrade scan.\nResults use the same complete-layout EP solver as bags and rewards."))
    frame.openAuction = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.openAuction:SetSize(180, 24)
    frame.openAuction:SetPoint("CENTER", 0, -40)
    frame.openAuction:SetText(L("Open RXP Auction Tab"))
    frame.openAuction:SetScript("OnClick", function()
        if _G.AuctionFrame and _G.AuctionFrame:IsShown() and
            addon.itemUpgrades.AH then
            addon.itemUpgrades.AH:CreateEmbeddedGui()
        else
            addon.comms.PrettyPrint(L("Open an Auction House first."))
        end
    end)
    frame:SetScript("OnShow", function() advisor:Refresh() end)
    frame:Hide()
    self.frame = frame
    table.insert(_G.UISpecialFrames, "RXPGearAdvisor")
end

function advisor:Toggle()
    if not self.frame then self:CreateFrame() end
    self.frame:SetShown(not self.frame:IsShown())
end

function advisor:Setup()
    if self.setup or not addon.itemUpgrades then return end
    self.setup = true
    self.view = "bags"
    self:CreateFrame()
    self.eventFrame = CreateFrame("Frame")
    for _, event in ipairs({"BAG_UPDATE", "BAG_UPDATE_DELAYED",
                             "PLAYER_EQUIPMENT_CHANGED",
                             "GET_ITEM_INFO_RECEIVED", "QUEST_COMPLETE",
                             "QUEST_LOG_UPDATE", "PLAYER_TALENT_UPDATE",
                             "ACTIVE_TALENT_GROUP_CHANGED"}) do
        pcall(self.eventFrame.RegisterEvent, self.eventFrame, event)
    end
    self.eventFrame:SetScript("OnEvent", function()
        C_Timer.After(0.15, function() advisor:Refresh() end)
    end)
end
