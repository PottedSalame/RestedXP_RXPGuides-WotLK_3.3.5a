local _, addon = ...

if addon.gameVersion > 60000 then return end

local GetItemInfo = C_Item and C_Item.GetItemInfo or _G.GetItemInfo
local GetSpellInfo = C_Spell and C_Spell.GetSpellInfo and addon.GetSpellInfo or _G.GetSpellInfo
local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or _G.GetSpellTexture
local GetSpellSubtext = C_Spell and C_Spell.GetSpellSubtext or _G.GetSpellSubtext
local IsCurrentSpell = C_Spell and C_Spell.IsCurrentSpell or _G.IsCurrentSpell
local IsSpellKnown = C_Spell and C_Spell.IsSpellKnown or _G.IsSpellKnown
local IsPlayerSpell = C_Spell and C_Spell.IsPlayerSpell or _G.IsPlayerSpell
local GetTime, GetMirrorTimerProgress = _G.GetTime, _G.GetMirrorTimerProgress
local UnitHealth, UnitHealthMax, UnitIsDead = _G.UnitHealth, _G.UnitHealthMax, _G.UnitIsDead
local GetInventoryItemID, IsPlayerSpell = GetInventoryItemID, IsPlayerSpell
local HasAction, GetActionInfo, GetMacroSpell = HasAction, GetActionInfo, GetMacroSpell
local IsOnBarOrSpecialBar = C_ActionBar.IsOnBarOrSpecialBar
local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or _G.GetContainerNumSlots
local GetContainerItemID = C_Container and C_Container.GetContainerItemID or _G.GetContainerItemID
local tinsert, fmt = tinsert, string.format
local GetRealZoneText = GetRealZoneText
local UIErrorsFrame = _G.UIErrorsFrame
local STRING_ENVIRONMENTAL_DAMAGE_DROWNING = _G.STRING_ENVIRONMENTAL_DAMAGE_DROWNING

local L = addon.locale.Get

addon.tips = addon:NewModule("Tips", "AceEvent-3.0")

local session = {
    checkFrequency = 0.5,
    checkLast = GetTime(),
    lastAlert = 0,
    alertFrequency = 1,
    emergencyItems = {},
    emergencySpells = {},
    highlights = {},
    actionBarMap = {},
    dangerousMobs = {}
}

local function SetTipsFont(region, size)
    local font = addon.font or _G.STANDARD_TEXT_FONT
    if region and font then region:SetFont(font, size, "") end
    if region and not select(1, region:GetFont()) then
        region:SetFont("Fonts\\FRIZQT__.TTF", size, "")
    end
end

function addon.tips:Setup()
    if not addon.settings.profile.enableTips then
        self:HideTipsFrame()
        self:DisableDangerWarning()
        return
    end

    self:CreateTipsFrame()
    self:CreateDangerWarning()

    if self.setupComplete then return end
    self.setupComplete = true

    self:RegisterEvent("MIRROR_TIMER_START")
    self:RegisterEvent("MIRROR_TIMER_STOP")

    self:CatalogInventory()

    self:RegisterEvent("PLAYER_STARTED_MOVING")
    self:UpdateEmergencySpells()

    self:CatalogActionBars()
    self:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    self:RegisterEvent("UPDATE_MACROS", "RefreshEmergencyActions")
    self:RegisterEvent("SPELLS_CHANGED", "RefreshEmergencyActions")
    self:RegisterEvent("LEARNED_SPELL_IN_TAB", "RefreshEmergencyActions")

    WorldFrame:HookScript("OnUpdate", self.CheckEvents)

    if addon.dangerousMobs then
        self:LoadDangerousMobs()
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    end
end

function addon.tips:PLAYER_STARTED_MOVING()
    -- Spams at login, so delay until after player moves
    self:RegisterEvent("UNIT_INVENTORY_CHANGED")

    self:UnregisterEvent("PLAYER_STARTED_MOVING")
end

function addon.tips:CreateTipsFrame()
    if not addon.settings.profile.enableTipsFrame then
        self:HideTipsFrame()
        return
    end
    if self.tipsFrame then return self.tipsFrame end

    local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
    local frame = CreateFrame("Frame", "RXPTipsFrame", UIParent,
                              backdropTemplate)
    frame:SetSize(230, 66)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, -145)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:Hide()
    frame.entries = {}

    addon.enabledFrames["tipsFrame"] = frame
    frame.IsFeatureEnabled = function()
        return addon.settings.profile.enableTips and
                   addon.settings.profile.enableTipsFrame and
                   session.tipsFrameActive or false, false
    end

    frame.onMouseDown = function()
        if addon.settings.profile.lockFrames and not IsAltKeyDown() then return end
        frame:StartMoving()
    end
    frame.onMouseUp = function()
        frame:StopMovingOrSizing()
        addon.settings:SaveFramePositions()
    end
    frame:SetScript("OnMouseDown", frame.onMouseDown)
    frame:SetScript("OnMouseUp", frame.onMouseUp)

    frame.title = CreateFrame("Frame", "$parent_title", frame,
                              backdropTemplate)
    frame.title:SetPoint("TOPLEFT", frame, 5, 5)
    frame.title:EnableMouse(true)
    frame.title:SetScript("OnMouseDown", frame.onMouseDown)
    frame.title:SetScript("OnMouseUp", frame.onMouseUp)
    -- A bare FontString has no inherited font on stock 3.3.5a. SetText() on
    -- such a region throws "Font not set" before UpdateVisuals can assign the
    -- active theme font, which can abort standalone addon initialization.
    frame.title.text = frame.title:CreateFontString(nil, "OVERLAY",
                                                     "GameFontNormalSmall")
    frame.title.text:SetPoint("CENTER", frame.title, 0, 1)
    frame.title.text:SetJustifyH("CENTER")
    SetTipsFont(frame.title.text, 9)
    frame.title.text:SetText(L("Emergency actions"))

    frame.UpdateVisuals = function(this)
        this:ClearBackdrop()
        this:SetBackdrop(addon.RXPFrame.backdrop.edge)
        local r, g, b = unpack(addon.colors.background)
        this:SetBackdropColor(r, g, b, 0.82)
        this.title:ClearBackdrop()
        this.title:SetBackdrop(addon.RXPFrame.backdrop.edge)
        this.title:SetBackdropColor(unpack(addon.colors.background))
        SetTipsFont(this.title.text, 9)
        this.title.text:SetTextColor(unpack(addon.activeTheme.textColor))
        this.title:SetSize(this.title.text:GetStringWidth() + 14, 19)
        for _, entry in ipairs(this.entries) do
            SetTipsFont(entry.text, 10)
            entry.text:SetTextColor(unpack(addon.activeTheme.textColor))
        end
    end
    frame:UpdateVisuals()

    self.tipsFrame = frame
    return frame
end

function addon.tips:HideTipsFrame()
    session.tipsFrameActive = false
    if self.tipsFrame then self.tipsFrame:Hide() end
end

function addon.tips:HideEmergencyHighlights()
    for _, border in pairs(session.highlights) do
        if border:IsShown() then border:Hide() end
    end
end

function addon.tips:UpdateTipsFrame()
    if not (addon.settings.profile.enableTips and
        addon.settings.profile.enableTipsFrame) then
        self:HideTipsFrame()
        return
    end

    local frame = self.tipsFrame or self:CreateTipsFrame()
    if not frame then return end

    local actions, seen = {}, {}
    local function AddActions(list, kind)
        for _, action in ipairs(list or {}) do
            local key = kind .. ":" .. tostring(action.id or action.name)
            if not seen[key] and action.name and action.texture then
                seen[key] = true
                action.kind = kind
                tinsert(actions, action)
            end
        end
    end
    AddActions(session.emergencyItems, "item")
    AddActions(session.emergencySpells, "spell")

    local maximum = math.min(#actions, 6)
    if maximum == 0 then
        self:HideTipsFrame()
        return
    end

    for index = 1, maximum do
        local entry = frame.entries[index]
        if not entry then
            entry = CreateFrame("Frame", "$parentEntry" .. index, frame)
            entry:SetHeight(28)
            entry:EnableMouse(true)
            entry.icon = entry:CreateTexture(nil, "ARTWORK")
            entry.icon:SetSize(24, 24)
            entry.icon:SetPoint("LEFT", entry, "LEFT", 3, 0)
            entry.text = entry:CreateFontString(nil, "OVERLAY",
                                                "GameFontHighlightSmall")
            entry.text:SetPoint("LEFT", entry.icon, "RIGHT", 7, 0)
            entry.text:SetPoint("RIGHT", entry, "RIGHT", -4, 0)
            entry.text:SetJustifyH("LEFT")
            SetTipsFont(entry.text, 10)
            entry.text:SetTextColor(unpack(addon.activeTheme.textColor))
            entry:SetScript("OnEnter", function(this)
                if not this.action then return end
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(this.action.name, 1, 1, 1)
                GameTooltip:AddLine(L("Available emergency action"), 0, 1, 0)
                GameTooltip:Show()
            end)
            entry:SetScript("OnLeave", function() GameTooltip:Hide() end)
            frame.entries[index] = entry
        end

        local action = actions[index]
        entry.action = action
        entry.icon:SetTexture(action.texture)
        entry.icon:SetTexCoord(0, 1, 0, 1)
        entry.text:SetText(action.name)
        entry:ClearAllPoints()
        entry:SetPoint("TOPLEFT", frame, "TOPLEFT", 7,
                       -23 - (index - 1) * 29)
        entry:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7,
                       -23 - (index - 1) * 29)
        entry:Show()
    end
    for index = maximum + 1, #frame.entries do
        frame.entries[index].action = nil
        frame.entries[index]:Hide()
    end

    frame:SetHeight(31 + maximum * 29)
    session.tipsFrameActive = true
    if addon.settings.profile.showEnabled then frame:Show() end
end

function addon.tips:ApplySettings()
    if addon.settings.profile.enableTips then self:Setup() end
    if not addon.settings.profile.enableTips or
        not addon.settings.profile.enableTipsFrame then
        self:HideTipsFrame()
        self:DisableDangerWarning()
        self:HideEmergencyHighlights()
    end
end

function addon.tips:SetDrowningWarningEnabled(enabled)
    if not enabled then
        session.breath = nil
        self:DisableDangerWarning()
        return
    end

    -- The mirror-timer start event may already have fired while the setting was
    -- disabled. Reconstruct the active draining breath timer immediately.
    if _G.GetMirrorTimerInfo then
        for index = 1, (_G.MIRRORTIMER_NUMTIMERS or 3) do
            local timer, value, maxValue, rate =
                _G.GetMirrorTimerInfo(index)
            if timer == "BREATH" and value and maxValue and
                (rate == nil or rate < 0) then
                session.breath = {value = value, maxValue = maxValue}
                break
            end
        end
    end
end

function addon.tips:SetEmergencyActionsEnabled(enabled)
    if not enabled then
        self:HideTipsFrame()
        self:HideEmergencyHighlights()
        return
    end
    self:CatalogInventory()
    self:RefreshEmergencyActions()
    self:CheckEmergencyActions()
end

function addon.tips:MIRROR_TIMER_START(_, timerName, value, maxValue, rate)
    if timerName ~= "BREATH" or not addon.settings.profile.enableDrowningWarning then return end

    -- Recovering breath
    if rate > 0 then
        session.breath = nil
        return
    end

    -- Draining down, event fires with 30 when regaining breath
    session.breath = {value = value, maxValue = maxValue}
end

function addon.tips:MIRROR_TIMER_STOP(_, timerName)
    if timerName ~= "BREATH" then return end

    session.breath = nil
end

function addon.tips.CheckEvents()
    if not addon.settings.profile.enableTips then return end

    if GetTime() - session.checkLast <= session.checkFrequency then return end

    if not addon.settings.profile.enableDrowningWarning then
        session.breath = nil
    elseif session.breath then
        session.breath.value = GetMirrorTimerProgress("BREATH")

        if session.breath.value == 0 or (session.breath.value / session.breath.maxValue) <
            addon.settings.profile.drowningThreshold then

            if GetTime() - session.lastAlert > session.alertFrequency then
                if addon.settings.profile.enableDrowningScreenFlash then
                    addon.tips:EnableDangerWarning(2)
                end
                FlashClientIcon()
                UIErrorsFrame:AddMessage(STRING_ENVIRONMENTAL_DAMAGE_DROWNING, 1.0, 0.1, 0.1, session.alertFrequency);

                if addon.settings.profile.enableDrowningWarningSound then
                    if addon.gameVersion == 30300 then
                        PlaySound(_G.SOUNDKIT.RAID_WARNING)
                    else
                        PlaySound(_G.SOUNDKIT.RAID_WARNING, "Master")
                    end
                end
                session.lastAlert = GetTime()
            end
        end
    end

    addon.tips:CheckEmergencyActions()

    session.checkLast = GetTime()
end

function addon.tips:CheckEmergencyActions()
    if not addon.settings.profile.enableEmergencyActions then
        addon.tips:HideTipsFrame()
        addon.tips:HideEmergencyHighlights()
        return
    end
    if UnitIsDead('player') then
        addon.tips:HideEmergencyHighlights()
        addon.tips:HideTipsFrame()
        return
    end

    local maxHP = UnitHealthMax("player")
    if maxHP > 0 and UnitHealth("player") / maxHP < addon.settings.profile.emergencyThreshold then

        addon.tips:HighlightEmergencyItem()
        addon.tips:HighlightEmergencySpell()
        addon.tips:UpdateTipsFrame()

        if addon.settings.profile.enableEmergencyScreenFlash then addon.tips:EnableDangerWarning(1) end
        return
    end

    addon.tips:HideEmergencyHighlights()
    addon.tips:HideTipsFrame()

end

function addon.tips:CatalogInventory()
    if not addon.emergencyItems or not addon.settings.profile.enableEmergencyActions then return end
    local itemList = {}

    local itemName, itemTexture, id

    for i = 1, _G.INVSLOT_LAST_EQUIPPED do
        id = GetInventoryItemID("player", i)
        if id and addon.emergencyItems[id] then
            itemName, _, _, _, _, _, _, _, _, itemTexture, _, _ = GetItemInfo(id)
            tinsert(itemList, {name = itemName, texture = itemTexture, invSlot = i, id = id})
        end
    end

    local bagSlots
    for bag = _G.BACKPACK_CONTAINER, _G.NUM_BAG_FRAMES do
        bagSlots = GetContainerNumSlots(bag)
        for slot = 1, bagSlots do
            id = GetContainerItemID(bag, slot)
            if id and addon.emergencyItems[id] then
                itemName, _, _, _, _, _, _, _, _, itemTexture, _, _ = GetItemInfo(id)

                tinsert(itemList, {
                    name = itemName,
                    texture = itemTexture,
                    bag = bag,
                    slot = slot,
                    id = id,
                    bagSlotFrameId = bagSlots + 1 - slot
                })
            end
        end
    end

    session.emergencyItems = itemList
end

function addon.tips:UpdateEmergencySpells()
    if not addon.emergencySpells or not addon.settings.profile.enableEmergencyActions then return end

    local spellList = {}

    local name, icon

    for spellId in pairs(addon.emergencySpells.professions or {}) do
        -- Only add spells on action bars
        if IsPlayerSpell(spellId) and IsOnBarOrSpecialBar(spellId) then
            name, _, icon = GetSpellInfo(spellId)
            tinsert(spellList, {name = name, texture = icon, spell = true, id = spellId})
        end
    end

    if addon.emergencySpells[addon.player.race] then
        for spellId in pairs(addon.emergencySpells[addon.player.race]) do
            -- Only add spells on action bars
            if IsPlayerSpell(spellId) and IsOnBarOrSpecialBar(spellId) then
                name, _, icon = GetSpellInfo(spellId)
                tinsert(spellList, {name = name, texture = icon, spell = true, id = spellId})
            end
        end
    end

    if addon.emergencySpells[addon.player.class] then
        for spellId in pairs(addon.emergencySpells[addon.player.class]) do
            -- Only add spells on action bars
            if IsPlayerSpell(spellId) and IsOnBarOrSpecialBar(spellId) then
                name, _, icon = GetSpellInfo(spellId)
                tinsert(spellList, {name = name, texture = icon, spell = true, id = spellId})
            end
        end
    end

    session.emergencySpells = spellList
end

function addon.tips:GetHighlight(name)
    if not name then return end

    if session.highlights[name] then return session.highlights[name] end

    local parent = _G[name]
    local border = parent:CreateTexture(name .. 'Emergency', 'ARTWORK')

    border.animation = border:CreateAnimationGroup()
    local animOut = border.animation:CreateAnimation("Alpha")
    animOut:SetOrder(1)
    animOut:SetDuration(0.2)
    animOut:SetFromAlpha(1)
    animOut:SetToAlpha(1)
    animOut:SetStartDelay(0.2)

    -- local animOut = border.animation:CreateAnimation("Rotation")
    -- animOut:SetDegrees(-360)
    -- animOut:SetDuration(1)
    -- animOut:SetSmoothing("OUT")

    border:SetTexture("Interface/Buttons/UI-ActionButton-Border")
    border:SetBlendMode('ADD')
    border:SetAlpha(0.5)
    border:SetSize(68, 68)
    border:SetPoint('CENTER', parent, 'CENTER', 0, 1)
    border:Hide()

    session.highlights[name] = border

    return border
end

function addon.tips:HighlightEmergencyItem()
    local bagBorder, actionBarLookup, actionBarBorder

    for _, item in ipairs(session.emergencyItems) do
        bagBorder = item.bag and item.bagSlotFrameId and
                        addon.tips:GetHighlight(fmt('ContainerFrame%sItem%s', item.bag + 1, item.bagSlotFrameId))

        if bagBorder then
            if _G.IsBagOpen(item.bag) then
                bagBorder:Show()
                if addon.settings.profile.enableEmergencyIconAnimations and not bagBorder.animation:IsPlaying() then
                    bagBorder.animation:Play()
                end
            else
                bagBorder:Hide()
            end
        end

        actionBarLookup = item.id and session.actionBarMap['item:' .. item.id]
        if actionBarLookup then
            actionBarBorder = addon.tips:GetHighlight(actionBarLookup.button)

            if actionBarBorder then
                actionBarBorder:Show()
                if addon.settings.profile.enableEmergencyIconAnimations and not actionBarBorder.animation:IsPlaying() then
                    actionBarBorder.animation:Play()
                end
            end

        end
    end

end

function addon.tips:HighlightEmergencySpell()
    local actionBarLookup, actionBarBorder

    for _, item in ipairs(session.emergencySpells) do

        actionBarLookup = session.actionBarMap['spell:' .. item.id]
        if actionBarLookup then
            actionBarBorder = addon.tips:GetHighlight(actionBarLookup.button)

            if actionBarBorder then
                actionBarBorder:Show()
                if addon.settings.profile.enableEmergencyIconAnimations and not actionBarBorder.animation:IsPlaying() then
                    actionBarBorder.animation:Play()
                end
            end

        end
    end

end

function addon.tips:UNIT_INVENTORY_CHANGED(_, target)
    if target ~= "player" then return end

    self:CatalogInventory()
end

function addon.tips:BAG_NEW_ITEMS_UPDATED() self:CatalogInventory() end

-- Can be overriden by ElvUI, Bartender, Domino, etc
local ActionBars = {'Action', 'MultiBarBottomLeft', 'MultiBarBottomRight', 'MultiBarRight', 'MultiBarLeft'}

function addon.tips:CatalogActionBars()
    session.actionBarMap = {}

    local button, slot, actionType, id, key

    for _, barName in pairs(ActionBars) do
        for i = 1, 12 do
            button = _G[barName .. 'Button' .. i]
            slot = _G.ActionButton_GetPagedID(button) or _G.ActionButton_CalculateAction(button) or
                       button:GetAttribute('action')

            if button and slot and HasAction(slot) then
                actionType, id = GetActionInfo(slot)

                if actionType == 'macro' then
                    _, _, id = GetMacroSpell(id)
                    if id then key = 'spell:' .. id end
                elseif actionType == 'item' and id then
                    key = 'item:' .. id
                elseif actionType == 'spell' and id then
                    key = 'spell:' .. id
                else
                    key = nil
                    id = nil
                end

                if id and key then
                    session.actionBarMap[key] = {button = barName .. 'Button' .. i, slot = slot}
                end
            end
        end
    end
end

function addon.tips:RefreshEmergencyActions()
    self:CatalogActionBars()
    self:UpdateEmergencySpells()
end

function addon.tips:ACTIONBAR_SLOT_CHANGED() self:RefreshEmergencyActions() end

function addon.tips:CreateDangerWarning()
    if self.dangerWarning then return self.dangerWarning end

    -- The original fullscreen vignette could remain stuck on the 3.3.5
    -- renderer.  Four ordinary, explicitly managed edge textures provide the
    -- same warning without animations, texture atlases, or persistent state.
    local warning = CreateFrame("Frame", "RXPDangerFrame", UIParent)
    warning:SetAllPoints(UIParent)
    warning:SetFrameStrata("FULLSCREEN_DIALOG")
    warning:SetFrameLevel(1)
    warning:EnableMouse(false)
    warning.elapsed = 0
    warning.duration = 0
    warning.intensity = 0
    warning.edges = {}

    local function CreateEdge(point1, relativePoint1, x1, y1,
                              point2, relativePoint2, x2, y2)
        local edge = warning:CreateTexture(nil, "OVERLAY")
        edge:SetTexture("Interface\\Buttons\\WHITE8X8")
        edge:SetPoint(point1, warning, relativePoint1, x1, y1)
        edge:SetPoint(point2, warning, relativePoint2, x2, y2)
        edge:SetVertexColor(1, 0.04, 0.02)
        edge:SetAlpha(0)
        tinsert(warning.edges, edge)
    end

    CreateEdge("TOPLEFT", "TOPLEFT", 0, 0,
               "TOPRIGHT", "TOPRIGHT", 0, -18)
    CreateEdge("BOTTOMLEFT", "BOTTOMLEFT", 0, 0,
               "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 18)
    CreateEdge("TOPLEFT", "TOPLEFT", 0, -18,
               "BOTTOMLEFT", "BOTTOMLEFT", 18, 18)
    CreateEdge("TOPRIGHT", "TOPRIGHT", 0, -18,
               "BOTTOMRIGHT", "BOTTOMRIGHT", -18, 18)

    warning:SetScript("OnUpdate", function(frame, elapsed)
        frame.elapsed = frame.elapsed + elapsed
        if frame.elapsed >= frame.duration then
            addon.tips:DisableDangerWarning()
            return
        end

        -- A short rise and a smooth fade make repeated danger checks visible
        -- without ever leaving a static border behind.
        local progress = frame.elapsed / frame.duration
        local fade = progress < 0.18 and progress / 0.18 or
                         (1 - progress) / 0.82
        local pulse = 0.72 + 0.28 * math.sin(frame.elapsed * 15)
        local alpha = math.max(0, fade * pulse * frame.intensity)
        for _, edge in ipairs(frame.edges) do edge:SetAlpha(alpha) end
    end)
    warning:Hide()
    self.dangerWarning = warning
    return warning
end

function addon.tips:EnableDangerWarning(level)
    local warning = self.dangerWarning or self:CreateDangerWarning()
    if not warning then return end

    warning.elapsed = 0
    warning.duration = level == 2 and 1.15 or 0.8
    warning.intensity = level == 2 and 0.72 or 0.52
    warning:Show()
end

function addon.tips:DisableDangerWarning()
    local warning = self.dangerWarning or _G.RXPDangerFrame
    if warning then
        warning.elapsed = 0
        warning.duration = 0
        warning.intensity = 0
        for _, edge in ipairs(warning.edges or {}) do edge:SetAlpha(0) end
        warning:Hide()
    end
end

local function IsStepActive(self)
    local levelBuffer = 1000
    local profile = addon.settings.profile
    local active
    if addon.gameVersion < 20000 then
        active = profile.showDangerousMobsMap
    else
        active = profile.showRares and self.rare or profile.showTreasures and self.treasure
    end
    if (not active and self.mapTooltip) or (self.isUnitscan and not profile.showDangerousUnitscan) then
        -- DevTools_Dump(self.elements[1].unitscan)
        -- DevTools_Dump(self.elements[1].targets)
        return false
    elseif not profile.debug and self.levelBuffer then
        levelBuffer = self.levelBuffer or 0
    end
    if not self.MaxLevel or self.MaxLevel >= UnitLevel("player") - levelBuffer then return true end
end

function addon.tips:LoadDangerousMobs(reloadData)
    if not addon.dangerousMobs then return end

    local mapId = C_Map.GetBestMapForUnit("player") or 0
    local zone = addon.mapIdToName and addon.mapIdToName[mapId] or GetRealZoneText()
    local zoneList

    addon.UpdateMap()

    if not zone or not addon.dangerousMobs[zone] then zone = mapId end

    -- print(zone,addon.dangerousMobs[zone])
    if not addon.dangerousMobs[zone] then
        addon.tips.dangerousMobs = nil
        addon.generatedSteps["dangerousMobs"] = nil
        return
    end

    local dangerousMobs = session.dangerousMobs[zone] or {}
    session.dangerousMobs[zone] = dangerousMobs
    zoneList = zoneList or {addon.dangerousMobs[zone]}

    -- dangerousMobs DB has nested objects, flatten and fake step data
    if not dangerousMobs.processed or reloadData == true then
        addon.currentGuideName = "Addon Tips"

        local steps = {}
        local step, element, skip, prefix

        for _, zoneData in pairs(zoneList) do
            for name, list in pairs(zoneData) do
                for _, mobData in ipairs(list) do
                    if not mobData.applies or addon.applies(mobData.applies) then
                        if type(name) == "number" then
                            name = fmt("npc:%s:%d", mobData.Name or "", name)
                        end
                        -- added a semicolon separator in case the database entry has multiple coords
                        for line in mobData.Location:gmatch("[^\r\n;]+") do
                            line:gsub("^%s+", "")
                            line:gsub("%s+$", "")

                            element = addon.ParseLine(line)
                            skip = false

                            if element then
                                step = {}

                                if element.tag == "rare" then step.rare = true end
                                if element.tag == "treasure" then step.treasure = true end

                                element.step = step
                                -- element.drawCenterPoint = true--Adds an icon at the center of the lines
                                step.isActive = IsStepActive
                                step.levelBuffer = mobData.Classification == "Normal" and 1 or 3

                                if element.wx or element.segments then
                                    -- step.linethickness = 2
                                    step.showTooltip = true -- Shows tooltip when hovering over a line
                                    step.icon = mobData.Icon or "|TInterface/GossipFrame/BattleMasterGossipIcon:0|t" -- texture used for the icon
                                    step.alternateIcon = mobData.AltIcon
                                    prefix = ""

                                    if addon.gameVersion < 20000 then
                                        prefix = _G.VOICEMACRO_1_Sc_0
                                        step.mapTooltip = fmt("%s %s (%d)", prefix, name, mobData.MaxLevel) -- Tooltip title
                                    else
                                        step.mapTooltip = name -- Tooltip title
                                    end

                                    -- Tooltip description:
                                    if mobData.Movement then
                                        element.mapTooltip =
                                            fmt("%s - %s\n%s", mobData.Classification or "", mobData.Movement or "",
                                                mobData.Notes or "")
                                    else
                                        element.mapTooltip =
                                            fmt("%s\n%s", mobData.Classification or "", mobData.Notes or "")
                                    end
                                elseif element.targets or element.unitscan or element.mobs then
                                    if addon.settings.profile.showDangerousUnitscan then
                                        step.isUnitscan = true
                                    else
                                        skip = true
                                    end
                                end

                                if not skip then
                                    step.hideMinimap = true
                                    step.elements = {element}
                                    tinsert(steps, step)
                                end
                            end
                        end
                    end
                end
            end
        end

        addon.currentGuideName = nil
        dangerousMobs.steps = steps

        addon:ScheduleTask(addon.RegisterGeneratedSteps)
    end

    addon.generatedSteps["dangerousMobs"] = dangerousMobs.steps
    dangerousMobs.processed = true
    addon.tips.dangerousMobs = dangerousMobs
end

addon.tips.ZONE_CHANGED_NEW_AREA = addon.tips.LoadDangerousMobs
