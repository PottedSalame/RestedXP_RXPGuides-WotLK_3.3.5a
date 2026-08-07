local _, addon = ...

if addon.gameVersion > 50000 then return end

local GameTooltip = _G.GameTooltip
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0", true)
local EasyMenu = function(...)
    if _G.EasyMenu then
        _G.EasyMenu(...)
    else
        LibDD:EasyMenu(...)
    end
end

local fmt, sgmatch = string.format, string.gmatch
local tonumber, type, pcall = tonumber, type, pcall
local tinsert, tsort = tinsert, table.sort
local UnitLevel = UnitLevel
local strsplit = _G.strsplit or string.split
local strjoin = _G.strjoin or string.join
if type(strjoin) ~= "function" then
    strjoin = function(delimiter, ...)
        local values = {...}
        for index = 1, #values do values[index] = tostring(values[index]) end
        return table.concat(values, delimiter)
    end
end
local GetPetTalentTree, GetUnspentTalentPoints, GetGroupPreviewTalentPointsSpent, AddPreviewTalentPoints,
      UnitCharacterPoints = _G.GetPetTalentTree, _G.GetUnspentTalentPoints, _G.GetGroupPreviewTalentPointsSpent,
                            _G.AddPreviewTalentPoints, _G.UnitCharacterPoints
local GetTalentTabInfo, GetActiveTalentGroup = _G.GetTalentTabInfo,
                                                  _G.GetActiveTalentGroup
local PanelTemplates_GetSelectedTab, PlayerTalentFrame = _G.PanelTemplates_GetSelectedTab, _G.PlayerTalentFrame
local BackdropTemplate = BackdropTemplateMixin and "BackdropTemplate"

local L = addon.locale.Get

-- Several of the strings used by the upstream talent UI were added after
-- Wrath. Keep all user-facing talent labels valid on 3.3.5 (and on clients
-- with incomplete/custom localization tables) instead of passing nil to
-- string.format.
local function GetGlobalString(key, fallback)
    local value = _G[key]
    if type(value) == "string" and value ~= "" then return value end
    return fallback
end

local talentText = {
    learned = GetGlobalString("TRADE_SKILLS_LEARNED_TAB", GetGlobalString("LEARNED", "Learned")),
    optional = GetGlobalString("COMMUNITIES_CHANNEL_DESCRIPTION_INSTRUCTIONS",
                               GetGlobalString("OPTIONAL", "Optional")),
    level = GetGlobalString("LEVEL", "Level"),
    rank = GetGlobalString("RANK", "Rank"),
    preview = GetGlobalString("PREVIEW", "Preview"),
    talents = GetGlobalString("TALENTS", "Talents"),
    levelRange = GetGlobalString("LEVEL_RANGE", "Level range"),
    notAvailable = GetGlobalString("ADDON_NOT_AVAILABLE", "Not available"),
    missing = GetGlobalString("ADDON_MISSING", "Missing"),
    talentPoints = GetGlobalString("TALENT_POINTS", "talent points"),
    incompatible = GetGlobalString("ADDON_INCOMPATIBLE", "incompatible"),
    reset = GetGlobalString("RESET_TO_DEFAULT", "reset")
}

addon.talents = addon:NewModule("Talents", "AceEvent-3.0")
addon.talents.functions = {}
addon.talents.guides = {}
addon.talents.maxLevel = GetMaxPlayerLevel()

addon.talents.petGuides = {
    -- ['Ferocity'] = {},
    -- ['Cunning'] = {},
    -- ['Tenacity'] = {}
}

local compatible = true
local indexLookup = {['player'] = {}}
local talentTooltips = {
    hooked = false,
    highlightColors = {
        [1] = {14 / 255, 131 / 255, 18 / 255}, -- RXP_BUY
        [2] = {0, 1, 37 / 255}, -- RXP_FRIENDLY
        [3] = {0, 1, 37 / 255}, -- RXP_FRIENDLY
        [4] = {0, 1, 37 / 255}, -- RXP_FRIENDLY
        [5] = {252 / 255, 220 / 250, 0} -- RXP_WARN
    }
}

local activeIndices, levelsForIndex
local talentGuideRegistrationOrder = 0

if addon.gameVersion < 40000 then
    -- Classic, TBC, Wrath use a single-tab view, each view change resets the highlight state
    -- These also share the same frame elements but different talentIndex
    talentTooltips.data = {}
    talentTooltips.highlights = {}
    activeIndices = {}
    levelsForIndex = {}
else
    -- Cata+ uses a three tab single view
    talentTooltips.cataPlan = {
        [1] = {
            -- [talentIndex] = { ['ht'] = hightlightFrame, ['levels'] = [11,12,13,21] }
        },
        [2] = {},
        [3] = {}
    }
end

local function GetTableLength(T)
    local count = 0
    for _ in pairs(type(T) == "table" and T or {}) do count = count + 1 end
    return count
end

local function GetRemainingTalentPoints(pet)
    local unspent, previewSpent

    if type(GetUnspentTalentPoints) == "function" then
        local ok
        if pet then
            ok, unspent = pcall(GetUnspentTalentPoints, nil, true)
        else
            ok, unspent = pcall(GetUnspentTalentPoints)
        end
        if not ok then unspent = nil end
    end

    if unspent == nil and type(UnitCharacterPoints) == "function" and not pet then
        local ok
        ok, unspent = pcall(UnitCharacterPoints, "player")
        if not ok then unspent = nil end
    end

    if type(GetGroupPreviewTalentPointsSpent) == "function" then
        local ok
        if pet then
            ok, previewSpent = pcall(GetGroupPreviewTalentPointsSpent, true, 1)
        else
            ok, previewSpent = pcall(GetGroupPreviewTalentPointsSpent)
        end
        if not ok then previewSpent = nil end
    end

    unspent = tonumber(unspent) or 0
    previewSpent = tonumber(previewSpent) or 0
    return math.max(0, unspent - previewSpent)
end

local function buildTalentGuidesMenu()
    local menu = {}

    local playerLevel = UnitLevel("player")
    local disabled, invalidReason, menuData = false, nil, nil
    local orderedGuides, unorderedGuides = {}, {}

    if PlayerTalentFrame.pet then
        tinsert(menu, {text = _G.PET_TALENTS, isTitle = 1, notCheckable = 1})

        for key, guide in pairs(addon.talents.petGuides) do
            if playerLevel < guide.minLevel then
                invalidReason = "< " .. guide.minLevel
                disabled = true
            elseif playerLevel > guide.maxLevel then
                invalidReason = "> " .. guide.maxLevel
                disabled = true
            else
                disabled = false
                invalidReason = nil
            end

            if type(GetPetTalentTree) == "function" and guide.pet == GetPetTalentTree() then
                tinsert(menu, {
                    text = guide.name,
                    tooltipTitle = fmt("%s: %s", talentText.levelRange, guide.levelRange),
                    notCheckable = 1,
                    disabled = disabled,
                    tooltipText = invalidReason,
                    tooltipOnButton = true,
                    tooltipWhileDisabled = true,
                    func = function()
                        if addon.talents:ProcessTalents('validate') then
                            addon.talents:DrawTalents()
                        end
                    end
                })
            end
        end
    else
        tinsert(menu, {text = L("Available Guides"), isTitle = 1, notCheckable = 1})

        for key, guide in pairs(addon.talents.guides) do

            if playerLevel < guide.minLevel then
                invalidReason = "< " .. guide.minLevel
                disabled = true
            elseif playerLevel > guide.maxLevel then
                invalidReason = "> " .. guide.maxLevel
                disabled = true
            else
                disabled = false
                invalidReason = nil
            end

            menuData = {
                text = guide.name,
                tooltipTitle = fmt("%s: %s", talentText.levelRange, guide.levelRange),
                notCheckable = 1,
                disabled = disabled,
                tooltipText = invalidReason,
                tooltipOnButton = true,
                tooltipWhileDisabled = true,
                arg1 = key,
                func = function(_, arg1)
                    addon.talents:UpdateSelectedGuide(arg1)

                    -- TODO should also audit?
                    if addon.talents:ProcessTalents('validate') then addon.talents:DrawTalents() end
                end
            }

            -- Hide hardcore guides when not hardcore
            if addon.game == "CLASSIC" and guide.hardcore then
                if addon.settings.profile.hardcore then
                    if guide.order then
                        menuData.guideOrder = guide.order
                        orderedGuides[guide.order] = menuData
                    else
                        tinsert(unorderedGuides, menuData)
                    end
                end
            else
                if guide.order then
                    menuData.guideOrder = guide.order
                    orderedGuides[guide.order] = menuData
                else
                    tinsert(unorderedGuides, menuData)
                end
            end
        end
    end

    -- LUA doesn't order tables well, so track sparse indices, then iterate over that
    local orderedGuidesOrder = {}
    for _, guideMenu in pairs(orderedGuides) do tinsert(orderedGuidesOrder, guideMenu.guideOrder) end

    table.sort(orderedGuidesOrder, function(k1, k2) return k1 < k2 end)

    for _, guideOrder in ipairs(orderedGuidesOrder) do tinsert(menu, orderedGuides[guideOrder]) end

    table.sort(unorderedGuides, function(a, b)
        return string.lower(tostring(a.text or "")) < string.lower(tostring(b.text or ""))
    end)
    for _, guideMenu in ipairs(unorderedGuides) do tinsert(menu, guideMenu) end

    tinsert(menu, {text = "", notCheckable = 1, isTitle = 1})

    tinsert(menu, {
        text = _G.APPLY,
        notCheckable = 1,
        func = function() if addon.talents:Audit() then addon.talents:ProcessTalents() end end
    })

    if addon.settings.profile.debug then
    tinsert(menu, {text = L("Audit"), notCheckable = 1, func = function() addon.talents:Audit() end})
    end

    tinsert(menu, {text = _G.GAMEOPTIONS_MENU, notCheckable = 1, func = function() addon.settings.OpenSettings() end})

    tinsert(menu, {text = _G.CLOSE, notCheckable = 1, func = function(self) self:Hide() end})

    return menu
end

function addon.talents:IsSupported() return self.guides and next(self.guides) ~= nil and compatible end

function addon.talents:Setup()
    if not addon.settings.profile.enableTalentGuides then return end

    if not self:IsSupported() then return end

    self:RegisterEvent("ADDON_LOADED")

    if addon.game == "WOTLK" then
        self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED",
                           "RefreshSelectedGuideForSpec")
        self:RegisterEvent("PLAYER_TALENT_UPDATE",
                           "RefreshSelectedGuideForSpec")
        self:RegisterEvent("PLAYER_LEVEL_UP",
                           "RefreshSelectedGuideForSpec")
    end

    self:UpdateSelectedGuide(RXPCData.activeTalentGuide)
    self:RefreshSelectedGuideForSpec()

    -- Blizzard_TalentUI is normally load-on-demand, but another addon may
    -- have loaded it before RXP's modules finish setting up.
    if type(IsAddOnLoaded) == "function" and IsAddOnLoaded("Blizzard_TalentUI") then
        self:ADDON_LOADED(nil, "Blizzard_TalentUI")
    end

    if tonumber(GetCVar("previewTalents")) == 0 and addon.game == "WOTLK" and addon.settings.profile.previewTalents then
        -- Talents are enabled in RXP, so match client
        -- This only lasts per session, does not persist in-game setting
        SetCVar("previewTalents", 1)
    end
end

function addon.talents:ADDON_LOADED(_, loadedAddon)
    -- Talent frame/globals get loaded on demand when it's first opened
    if loadedAddon == "Blizzard_TalentUI" then
        if self.uiHooked or not _G.PlayerTalentFrame then return end
        self.uiHooked = true

        _G.PlayerTalentFrame:HookScript("OnShow", function() addon.talents:HookUI() end)

        -- The original handler rebuilt the complete overlay every rendered
        -- frame. A short throttle remains visually immediate while avoiding
        -- needless talent-tree and texture work.
        local drawElapsed = 0
        _G.PlayerTalentFrame:HookScript("OnUpdate", function(_, elapsed)
            drawElapsed = drawElapsed + (tonumber(elapsed) or 0)
            if drawElapsed < 0.10 then return end
            drawElapsed = 0
            self:DrawTalents()
        end)

        PlayerTalentFrame = _G.PlayerTalentFrame

        self:BuildIndexLookup()
        if PlayerTalentFrame:IsShown() then self:HookUI() end
    elseif loadedAddon == "Talented" then
        compatible = false
        addon.comms.PrettyPrint(L("Talented detected, please disable for talent guide functionality")) -- TODO locale
    end
end

function addon.talents:UpdateTalentsButton()
    local iconReference = {}

    if _G.PlayerSpecTab3 and _G.PlayerSpecTab3:IsShown() then -- Wrath hunter regardless of dual-spec
        iconReference.frame = _G.PlayerSpecTab3
        iconReference.size = iconReference.frame:GetWidth()

        -- Offset RXP button as much as Tab2 is from Tab1
        _, _, _, _, iconReference.offsetY = _G.PlayerSpecTab3:GetPoint()
        iconReference.point = {"TOP", iconReference.frame, "BOTTOM", 0, iconReference.offsetY}

    elseif _G.PlayerSpecTab2 and _G.PlayerSpecTab2:IsShown() then -- Dual spec non-hunter
        iconReference.frame = _G.PlayerSpecTab2
        iconReference.size = iconReference.frame:GetWidth()

        -- Offset RXP button as much as Tab2 is from Tab1
        _, _, _, _, iconReference.offsetY = _G.PlayerSpecTab2:GetPoint()

        iconReference.point = {"TOP", iconReference.frame, "BOTTOM", 0, iconReference.offsetY}
    elseif addon.game == "CATA" and _G.PlayerSpecTab1 then -- Cata, non dual-spec non-hunter
        iconReference.frame = _G.PlayerTalentFrame
        iconReference.size = 32
        iconReference.point = {"TOPLEFT", iconReference.frame, "TOPRIGHT", 0, -65}
    elseif _G.PlayerSpecTab1 then -- Wrath, non dual-spec non-hunter
        iconReference.frame = _G.PlayerTalentFrame
        iconReference.size = 32
        iconReference.point = {"TOPLEFT", iconReference.frame, "TOPRIGHT", -32, -65}
    elseif addon.game == "CLASSIC" then
        iconReference.frame = _G.PlayerTalentFrame
        iconReference.size = 32
        iconReference.point = {"TOPLEFT", iconReference.frame, "TOPRIGHT", -32, -65}
        -- elseif Retail
    else
        return nil
    end

    local button = self.talentsButton
    -- Build a button to match Wrath dual-spec talent tabs
    if not button then
        button = CreateFrame("Button", "$parentRXPTalents", iconReference.frame)
        button:SetNormalTexture(addon.GetTexture("rxp_logo-64"))

        button.bg = button:CreateTexture("$parentBG", "BACKGROUND")
        button.bg:SetSize(64, 64)
        button.bg:SetPoint("TOPLEFT", -3, 11)
        button.bg:SetTexture("Interface/SpellBook/SpellBook-SkillLineTab")

        button.bg.ht = button:CreateTexture(nil, "HIGHLIGHT")
        button.bg.ht:SetAllPoints(true)
        button.bg.ht:SetTexture("Interface/Buttons/ButtonHilight-Square")
        button.bg.ht:SetBlendMode("ADD")

        self.talentsButton = button

        button:SetScript("OnEnter", function(this)
            if (this.IsForbidden and this:IsForbidden()) or
                (GameTooltip.IsForbidden and GameTooltip:IsForbidden()) then return end
            GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT", iconReference.size, 0)
            GameTooltip:ClearLines()

            local guide = addon.talents:GetCurrentGuide()
            if guide then
                GameTooltip:AddLine(guide.name)
                GameTooltip:AddLine(L("Left click to apply talents"), 0, 1, 0)
                GameTooltip:AddLine(fmt("%s: %d - %d", talentText.levelRange, guide.minLevel, guide.maxLevel), 1, 1,
                                    1)
            else
                GameTooltip:AddLine(L("Welcome to RestedXP Guides\nRight click to pick a guide"))
            end

            GameTooltip:Show()
        end)

        button:SetScript("OnLeave", function(this)
            if (this.IsForbidden and this:IsForbidden()) or
                (GameTooltip.IsForbidden and GameTooltip:IsForbidden()) then return end
            GameTooltip:Hide()
        end)

        self.talentsButton = button
    end

    button:SetWidth(iconReference.size)
    button:SetHeight(iconReference.size)
    button:SetPoint(unpack(iconReference.point))

    return true
end

function addon.talents:HookUI()
    if not self:IsSupported() then return end

    if not self:UpdateTalentsButton() then
        addon.error(fmt("%s - %s", talentText.talents, talentText.notAvailable))

        return
    end

    if not talentTooltips.hooked then
        hooksecurefunc("PlayerTalentFrameTalent_OnEnter", talentTooltips.updateFunc)

        talentTooltips.hooked = true
    end

    if not self.menuFrame then
        self.menuFrame = CreateFrame("Frame", "RXP_TalentsMenuFrame", self.talentsButton, "UIDropDownMenuTemplate")

        self.talentsButton:SetScript("OnMouseUp", function(_, click)
            if click == "RightButton" then
                EasyMenu(buildTalentGuidesMenu(), self.menuFrame, self.talentsButton, 0, 0, "MENU", 1)
            else
                if self:Audit() then self:ProcessTalents() end
            end
        end)
    end
end

function addon.talents.RegisterGuide(text)
    local guide = addon.talents:ParseGuide(text)

    if not (guide and guide.key) then return end

    if guide.pet then
        addon.talents.petGuides[guide.pet] = guide
        return
    end

    talentGuideRegistrationOrder = talentGuideRegistrationOrder + 1
    guide.registrationOrder = talentGuideRegistrationOrder

    if addon.talents.guides[guide.key] then
        addon.comms.PrettyPrint("%s: Duplicate talent guide key %s", L("Error parsing guide"), guide.key)
        return
    end

    addon.talents.guides[guide.key] = guide
end

-- Compact internal representation for complete Wrath builds. Each semicolon-
-- separated entry is tab,tier,column,count; it is expanded into the ordinary
-- level/.talent guide syntax so all existing auditing, highlighting, preview,
-- and application paths remain authoritative. This is intentionally not added
-- to the public RXPGuides.talents interface.
function addon.talents.RegisterBuild(name, encoded, minLevel, maxLevel)
    if addon.game ~= "WOTLK" then return end
    minLevel = tonumber(minLevel) or 10
    maxLevel = tonumber(maxLevel) or 80
    if type(name) ~= "string" or name == "" or type(encoded) ~= "string" then
        addon.error("Invalid compact talent build registration")
        return
    end

    local lines = {
        "#name " .. name,
        "#minLevel " .. minLevel,
        "#maxLevel " .. maxLevel,
        ""
    }
    local ranks, treePoints, pointCount = {}, {[1] = 0, [2] = 0, [3] = 0}, 0

    for rawEntry in encoded:gmatch("[^;]+") do
        local entry = rawEntry:gsub("^%s+", ""):gsub("%s+$", "")
        local tab, tier, column, count, extra = strsplit(',', entry)
        tab, tier, column, count = tonumber(tab), tonumber(tier), tonumber(column), tonumber(count)
        if extra or not tab or not tier or not column or not count or
            tab < 1 or tab > 3 or tier < 1 or tier > 11 or
            column < 1 or column > 4 or count < 1 or count > 5 then
            addon.error(fmt("Invalid compact talent entry for %s: %s", name, entry))
            return
        end

        local requiredPoints = (tier - 1) * 5
        if treePoints[tab] < requiredPoints then
            addon.error(fmt("Invalid compact talent tier for %s: %s requires %d prior points", name, entry,
                            requiredPoints))
            return
        end

        local key = fmt("%d,%d,%d", tab, tier, column)
        local startingRank = ranks[key] or 0
        if startingRank + count > 5 then
            addon.error(fmt("Invalid compact talent rank for %s: %s", name, entry))
            return
        end

        for offset = 1, count do
            local rank = startingRank + offset
            tinsert(lines, "level")
            tinsert(lines, fmt("    .talent %d,%d,%d,%d", tab, tier, column, rank))
            tinsert(lines, "")
            pointCount = pointCount + 1
        end
        ranks[key] = startingRank + count
        treePoints[tab] = treePoints[tab] + count
    end

    local expectedPoints = maxLevel - minLevel + 1
    if pointCount ~= expectedPoints then
        addon.error(fmt("Invalid compact talent build %s: expected %d points, found %d", name, expectedPoints,
                        pointCount))
        return
    end
    addon.talents.RegisterGuide(table.concat(lines, "\n"))
end

local talentGuideTags = {
    name = true,
    next = true,
    minLevel = true,
    maxLevel = true,
    description = true,
    displayname = true,
    key = true,
    pet = true,
    order = true,
    hardcore = true,
    reset = true
}

function addon.talents:ParseGuide(text)
    if not text then return end

    local guide = {steps = {}}

    local step = {}
    local linenumber = 0
    local currentStep = 0
    local parseSuccess = true

    -- Loop over each line in guide
    for line in sgmatch(text, "[^\n\r]+") do
        line = line:gsub("^%s+", "")
        line = line:gsub("%s+$", "")
        linenumber = linenumber + 1

        if line == "level" or line:match("^level%s") then
            currentStep = currentStep + 1
            guide.steps[currentStep] = {elements = {}}

            step = guide.steps[currentStep]
            -- print("Starting new step", currentStep)
        elseif currentStep > 0 then
            local command, lineArgs = line:match("^[%.#](%S+)%s*(.*)")
            if command and self.functions[command] then
                local ok, element = pcall(self.functions[command], lineArgs)
                if ok and element then
                    tinsert(step.elements, element)
                else
                    parseSuccess = false
                    if not ok then
                        addon.error(L("Error parsing guide") .. " " .. (guide.name or 'Unknown') .. ": " ..
                                        tostring(element))
                    end
                end
            elseif command == "optional" then
                step.optional = true
            elseif not line:match("^%-%-") then
                parseSuccess = false
                addon.error(L("Error parsing guide") .. " " .. (guide.name or 'Unknown') ..
                                ": Invalid function call or line\n" .. line)
            end
        elseif line ~= "" then
            local tag, value = line:match("^#(%S+)%s*(.*)")
            if tag and talentGuideTags[tag] and guide[tag] == nil then
                guide[tag] = tonumber(value) or value
            elseif not line:match("^%-%-") then
                parseSuccess = false
                addon.error(L("Error parsing guide") .. ": Invalid or duplicate metadata at line " .. linenumber ..
                                "\n" .. line)
            end
        end

        if not parseSuccess then
            addon.comms.PrettyPrint("%s: Critical failure for %s", L("Error parsing guide"),
                                    guide.name or guide.key or 'Unknown')

            return
        end
    end

    -- Ensure guide tags exist with good defaults
    if not guide.name then
        addon.comms.PrettyPrint("%s: Missing #%s", L("Error parsing guide"), "name")
        return
    end

    guide.minLevel = tonumber(guide.minLevel) or 10
    guide.maxLevel = tonumber(guide.maxLevel) or addon.talents.maxLevel
    if guide.minLevel < 1 or guide.maxLevel < guide.minLevel or #guide.steps == 0 then
        addon.comms.PrettyPrint("%s: Invalid level range or empty plan for %s", L("Error parsing guide"), guide.name)
        return
    end
    if addon.game ~= "CATA" and #guide.steps ~= guide.maxLevel - guide.minLevel + 1 then
        addon.comms.PrettyPrint("%s: %s has %d steps for levels %d-%d", L("Error parsing guide"), guide.name,
                                #guide.steps, guide.minLevel, guide.maxLevel)
        return
    end
    for stepNumber, talentStep in ipairs(guide.steps) do
        if type(talentStep.elements) ~= "table" or #talentStep.elements == 0 then
            addon.comms.PrettyPrint("%s: %s has an empty level step at %d", L("Error parsing guide"), guide.name,
                                    guide.minLevel + stepNumber - 1)
            return
        end
    end
    guide.levelRange = fmt("%d-%d", guide.minLevel, guide.maxLevel)
    guide.description = guide.description or fmt("%s - %s (%s)", addon.player.localeClass, guide.name, guide.levelRange)
    guide.displayname = guide.displayname or guide.description
    guide.key = guide.key or fmt("%s - %s", addon.player.class, guide.name)
    guide.nextKey = guide.next and fmt("%s - %s", addon.player.class, guide.next)

    -- A Wrath specialization is the talent tab receiving the majority of the
    -- plan's points. This metadata lets the runtime match guides without a
    -- separate class/spec database and also supports imported talent plans.
    if addon.game == "WOTLK" then
        local tabCounts = {}
        for _, talentStep in ipairs(guide.steps) do
            for _, element in ipairs(talentStep.elements) do
                for _, talent in ipairs(element.talent or {}) do
                    if talent.tab then
                        tabCounts[talent.tab] = (tabCounts[talent.tab] or 0) + 1
                    end
                end
            end
        end
        local bestCount = 0
        for tab = 1, 3 do
            local count = tabCounts[tab] or 0
            if count > bestCount then
                guide.primaryTab = tab
                bestCount = count
            end
        end
    end

    return guide
end

local function GetTalentData(tab, talentIndex, pet)
    if type(GetTalentInfo) ~= "function" or not tonumber(tab) or not tonumber(talentIndex) then return nil, 0 end

    local name, rank, previewRank

    if addon.game == "CATA" then
        name, _, _, _, rank, _, _, previewRank = GetTalentInfo(tab, talentIndex)
    elseif addon.game == "WOTLK" then
        name, _, _, _, rank, _, _, _, previewRank = GetTalentInfo(tab, talentIndex, nil, pet)
    elseif addon.game == "TBC" then
        name, _, _, _, rank, _, _, previewRank = GetTalentInfo(tab, talentIndex)
    else
        name, _, _, _, rank = GetTalentInfo(tab, talentIndex)
    end

    -- previewRank can be nil (or zero on some legacy cores) when talent
    -- previewing is disabled. It must never hide an already learned rank.
    rank = tonumber(rank) or 0
    previewRank = tonumber(previewRank)
    return name, previewRank and math.max(rank, previewRank) or rank
end

local function GetAllocatedTalentPoints(pet)
    local kind = 'player'
    if pet then
        kind = type(GetPetTalentTree) == "function" and GetPetTalentTree()
    end
    local lookup = kind and indexLookup[kind]
    if not (lookup and lookup.initialized) then return end

    local allocated = 0
    for tab, tiers in pairs(lookup) do
        if type(tab) == "number" and type(tiers) == "table" then
            for _, columns in pairs(tiers) do
                for _, talentIndex in pairs(type(columns) == "table" and columns or {}) do
                    local _, rank = GetTalentData(tab, talentIndex, pet)
                    allocated = allocated + (tonumber(rank) or 0)
                end
            end
        end
    end
    return allocated
end

local function GetAvailablePlanLevel(guide, playerLevel, pet)
    local remaining = GetRemainingTalentPoints(pet)
    if addon.game == "WOTLK" then
        local allocated = GetAllocatedTalentPoints(pet)
        if allocated then
            -- Death Knights earn their initial points from quests while staying
            -- near level 55. Derive progress from points actually granted rather
            -- than pretending level - 9 points already exist.
            return math.min(guide.maxLevel, guide.minLevel - 1 + allocated + remaining), remaining
        end
    end
    return playerLevel, remaining
end

function addon.talents:Audit()
    if not PlayerTalentFrame or PlayerTalentFrame.pet then return end

    self:BuildIndexLookup()

    if not indexLookup['player'].initialized then return end

    local guide = self:GetCurrentGuide()

    if not guide then return end

    addon.comms.PrettyDebug("Auditing %s", guide.displayname)

    -- TODO consolidate with ProcessGuide
    if addon.game == "CATA" then addon.talents.cata:SkipTalentSummariesPage(guide) end

    if addon.player.level < guide.minLevel then
        addon.comms.PrettyPrint(L("Too low for %s"), guide.displayname) --
        return
    end

    if addon.player.level > guide.maxLevel then
        addon.comms.PrettyPrint(L("Too high for %s"), guide.displayname) --
        return
    end

    -- learnedTalents["1,2,3"] = 4
    local learnedTalents = {}

    local previewRankOrRank, allocatedPoints = nil, 0

    -- Build lookup of all talents and ranks
    for tab, tiers in pairs(indexLookup['player']) do
        -- Exclude indexLookup['player'].initialized
        for tier, columns in pairs(type(tiers) == "table" and tiers or {}) do
            for column, index in pairs(columns) do
                _, previewRankOrRank = GetTalentData(tab, index)

                -- Only track decisions that may impact guide
                if (tonumber(previewRankOrRank) or 0) > 0 then
                    learnedTalents[fmt("%d,%d,%d", tab, tier, column)] = previewRankOrRank
                    allocatedPoints = allocatedPoints + previewRankOrRank
                end
            end
        end
    end

    local stepLevel, remainingPoints
    remainingPoints = GetRemainingTalentPoints(false)
    local spentPlanLevel = (tonumber(addon.player.level) or UnitLevel("player")) - remainingPoints
    if addon.game == "WOTLK" then
        spentPlanLevel = guide.minLevel - 1 + allocatedPoints
    end
    local optionalLearned
    local expectedRank, auditFailed, talentKey

    for stepNum, step in ipairs(guide.steps) do
        stepLevel = guide.minLevel + stepNum - 1

        -- If reached exit condition, evaluate if any leftover learnedTalents
        -- Audit up to stepLevel minus any remainingPoints, unspent points don't break Apply
        if stepLevel > spentPlanLevel then
            -- If no remaining learnedTalents, nothing to conflict
            -- print("Audit up to level", stepLevel, GetTableLength(learnedTalents) == 0)
            guide.audit = GetTableLength(learnedTalents) == 0
            return guide.audit
        end

        -- print("Evaluating step", stepNum, "for level", stepLevel)
        if step.optional then optionalLearned = nil end

        for _, element in ipairs(step.elements) do

            -- Level steps can have multiple .talent underneath, only for #optional
            for tag, _ in pairs(element) do
                if tag == "talent" then

                    for _, talentData in ipairs(element.talent or {}) do
                        talentKey = fmt("%d,%d,%d", talentData.tab, talentData.tier, talentData.column)

                        -- learnedTalents[fmt("%d,%d,%d", tab, tier, column)] = previewRankOrRank
                        expectedRank = learnedTalents[talentKey]

                        -- Already inventoried all talents, so reduce GetTalentData call by checking learnedTalents first
                        if expectedRank then
                            -- Remove learnedTalents from audit if they are identical
                            if expectedRank == talentData.rank then
                                learnedTalents[talentKey] = nil
                                -- else -- Rank 1-4, removed above when rank 5
                                --    print("Else", talentKey), talentData.rank)
                            end
                        else
                            if not step.optional then
                                addon.comms.PrettyDebug('%s - Audit failed for level %d', guide.name, stepLevel)
                            end

                            if not optionalLearned then
                                -- Avoid blocking on user action if talent exists in any optional blocks
                                optionalLearned = talentKey
                            end

                            auditFailed = true
                        end

                    end
                end
            end
        end

        if step.optional and optionalLearned then auditFailed = false end

        if auditFailed then
            addon.comms:PopupNotification("RXPTalentsAuditFailed",
                                          fmt("%s - %s\n\n%s\n%s %s - %s", addon.title, talentText.talents,
                                              guide.name, talentText.talents, string.lower(talentText.incompatible),
                                              string.lower(talentText.reset)))

            guide.audit = false
            return false
        end
    end

    guide.audit = true
    return true
end

-- { tab, talentIndex, name }
local function learnClassicTalent(payload)
    if addon.game ~= "CLASSIC" then return end

    local tab, talentIndex, name = unpack(payload)
    local ok, result = pcall(LearnTalent, tab, talentIndex)
    if ok and result ~= false then addon.comms.PrettyPrint("%s - %s", talentText.learned, name or "Talent") end
    return ok and result ~= false
end

function addon.talents.functions.talent(element, validate, optional)
    if type(element) == "string" then -- on parse
        -- TODO if more than one .talent in a step without #optional, error
        local e = {talent = {}}
        local args = element
        -- Strip whitespace
        args = args:gsub("%s*,%s*", ",")

        local tab, tier, column, rank, extra = strsplit(',', args)
        tab, tier, column, rank = tonumber(tab), tonumber(tier), tonumber(column), tonumber(rank) or 1
        if extra or not tab or not tier or not column or tab < 1 or tab > 3 or tier < 1 or tier > 11 or
            column < 1 or column > 4 or rank < 1 or rank > 5 then
            addon.error("Invalid .talent directive: " .. tostring(element))
            return
        end

        tinsert(e.talent, {tab = tab, tier = tier, column = column, rank = rank})

        return e
    end

    local talentIndex
    local name, previewRankOrRank
    local lookup
    local tempData

    for _, talentData in ipairs(element.talent) do
        lookup = indexLookup['player'][talentData.tab]

        if not (lookup and lookup[talentData.tier] and lookup[talentData.tier][talentData.column]) then

            addon.comms.PrettyPrint("Invalid talentIndex lookup for [%d][%d][%d]", talentData.tab, talentData.tier,
                                    talentData.column)
            return false
        end

        talentIndex = lookup[talentData.tier][talentData.column]

        name, previewRankOrRank = GetTalentData(talentData.tab, talentIndex)
        if not name then
            addon.comms.PrettyPrint("Invalid talent data for [%d][%d][%d]", talentData.tab, talentData.tier,
                                    talentData.column)
            return false
        end

        if optional then
            if previewRankOrRank == talentData.rank then
                addon.comms.PrettyPrint("%s - (%s) %s (%s %d)", talentText.learned, talentText.optional, name,
                                        talentText.rank, talentData.rank)

                -- Handle in level step processing, if return value is rank from at least one optional step, continue
                return true, fmt("%s (%s %d)", name, talentText.rank, talentData.rank)
            end

            -- Return false if not selected, check upstream to verify at least one #optional step talent chosen
            return false, fmt("%s (%s %d)", name, talentText.rank, talentData.rank)
        end

        if previewRankOrRank < talentData.rank then
            if validate then return true end

            if addon.game == "CLASSIC" then -- Classic doesn't have Preview Talents
                tempData = {talentData.tab, talentIndex, name}

                addon.comms:ConfirmChoice("RXPTalentPrompt",
                                          fmt(GetGlobalString("CONFIRM_LEARN_TALENT", "Learn %s?"), name),
                                          learnClassicTalent, tempData)

                -- Stop as soon as first learning prompt, not a blocking dialog
                return -1
            elseif addon.settings.profile.previewTalents then -- TBC/Wrath/Cata
                if type(AddPreviewTalentPoints) ~= "function" then return false end
                tempData = GetRemainingTalentPoints(false)
                AddPreviewTalentPoints(talentData.tab, talentIndex, 1)

                -- Verify training actually worked, there's no return value from Preview
                if tempData == GetRemainingTalentPoints(false) then
                    addon.error(fmt("%s - %s", GetGlobalString("ERR_TALENT_FAILED_UNKNOWN", "Unable to learn talent"),
                                    name))
                    return false
                end

                addon.comms.PrettyPrint("%s - %s (%s %d)", talentText.preview, name, talentText.rank, talentData.rank)
            else -- TBC/Wrath/Cata, not previewed
                local ok, result = pcall(LearnTalent, talentData.tab, talentIndex)
                if not ok or result == false then
                    addon.error(fmt("%s - %s", GetGlobalString("ERR_TALENT_FAILED_UNKNOWN", "Unable to learn talent"),
                                    name))
                    return false
                end
                addon.comms.PrettyPrint("%s - %s (%s %d)", talentText.learned, name, talentText.rank,
                                        talentData.rank)
            end
        end

    end

    return true
end

function addon.talents.functions.pettalent(element, validate)
    if addon.game ~= "WOTLK" then return end

    if type(element) == "string" then -- on parse
        local e = {pettalent = {}}
        local args = element
        -- Strip whitespace
        args = args:gsub("%s*,%s*", ",")

        local tab, tier, column, rank, extra = strsplit(',', args)
        tab, tier, column, rank = tonumber(tab), tonumber(tier), tonumber(column), tonumber(rank) or 1
        if extra or not tab or not tier or not column or tab < 1 or tab > 3 or tier < 1 or tier > 6 or
            column < 1 or column > 4 or rank < 1 or rank > 3 then
            addon.error("Invalid .pettalent directive: " .. tostring(element))
            return
        end

        tinsert(e.pettalent, {tab = tab, tier = tier, column = column, rank = rank})

        return e
    end

    local talentIndex
    local name, previewRankOrRank
    local lookup

    for _, talentData in pairs(element.pettalent) do
        local petTree = type(GetPetTalentTree) == "function" and GetPetTalentTree()
        lookup = petTree and indexLookup[petTree] and indexLookup[petTree][talentData.tab]

        if not (lookup and lookup[talentData.tier] and lookup[talentData.tier][talentData.column]) then

            addon.comms.PrettyPrint("Invalid pet talentIndex lookup for [%d][%d][%d]", talentData.tab, talentData.tier,
                                    talentData.column)
            return false
        end

        talentIndex = lookup[talentData.tier][talentData.column]

        if talentIndex and validate then return true end

        name, previewRankOrRank = GetTalentData(talentData.tab, talentIndex, true)

        -- TODO handle off-plan talents
        if name and previewRankOrRank < talentData.rank then
            if addon.settings.profile.previewTalents then
                if type(AddPreviewTalentPoints) ~= "function" then return false end
                local before = GetRemainingTalentPoints(true)
                AddPreviewTalentPoints(talentData.tab, talentIndex, 1, true, PlayerTalentFrame.talentGroup)

                -- Verify training actually worked, there's no return value from Preview
                if before == GetRemainingTalentPoints(true) then
                    addon.error(fmt("%s - %s", GetGlobalString("ERR_TALENT_FAILED_UNKNOWN", "Unable to learn talent"),
                                    name))
                    return false
                end

                addon.comms.PrettyPrint("%s - %s (%s %d)", talentText.preview, name, talentText.rank, talentData.rank)
            else
                local ok, result = pcall(LearnTalent, talentData.tab, talentIndex, true)
                if not ok or result == false then
                    addon.error(fmt("%s - %s", GetGlobalString("ERR_TALENT_FAILED_UNKNOWN", "Unable to learn talent"),
                                    name))
                    return false
                end
                addon.comms.PrettyPrint("%s - %s (%s %d)", talentText.learned, name, talentText.rank,
                                        talentData.rank)
            end
        end

    end

    return true
end

function addon.talents:GetActiveSpecTab()
    if addon.game ~= "WOTLK" or type(GetTalentTabInfo) ~= "function" then return end

    local talentGroup = type(GetActiveTalentGroup) == "function" and
                            GetActiveTalentGroup() or 1
    local selectedTab, selectedPoints, tied
    for tab = 1, 3 do
        local ok, _, _, points = pcall(GetTalentTabInfo, tab, false, false,
                                        talentGroup)
        if not ok then
            ok, _, _, points = pcall(GetTalentTabInfo, tab)
        end
        points = ok and tonumber(points) or 0
        if points > (selectedPoints or 0) then
            selectedTab, selectedPoints, tied = tab, points, false
        elseif points > 0 and points == selectedPoints then
            tied = true
        end
    end
    if tied or not selectedPoints or selectedPoints <= 0 then return end
    return selectedTab
end

function addon.talents:SelectGuideForActiveSpec()
    local playerLevel = UnitLevel("player")
    local current = self.guides[RXPCData.activeTalentGuide]

    -- Do not strand characters who level past a split plan while the talent
    -- window is closed. This also covers reloads one or more levels after the
    -- transition point.
    if current and playerLevel > current.maxLevel and current.nextKey and self.guides[current.nextKey] then
        RXPCData.activeTalentGuide = current.nextKey
        return true
    end

    local activeTab = self:GetActiveSpecTab()
    if not activeTab then return false end

    if current and current.primaryTab == activeTab and
        playerLevel >= current.minLevel and playerLevel <= current.maxLevel then
        return false
    end

    local selected
    for _, guide in pairs(self.guides) do
        if guide.primaryTab == activeTab and playerLevel >= guide.minLevel and
            playerLevel <= guide.maxLevel and
            (not selected or guide.maxLevel < selected.maxLevel or
                (guide.maxLevel == selected.maxLevel and
                    (guide.registrationOrder or math.huge) <
                        (selected.registrationOrder or math.huge))) then
            selected = guide
        end
    end
    if not selected or selected.key == RXPCData.activeTalentGuide then return false end

    RXPCData.activeTalentGuide = selected.key
    return true
end

function addon.talents:RefreshSelectedGuideForSpec()
    local changed = self:SelectGuideForActiveSpec()
    local guide = self:GetCurrentGuide()
    if guide then guide.audit = nil end

    if PlayerTalentFrame and PlayerTalentFrame:IsShown() and not PlayerTalentFrame.pet then
        if changed then self:Audit() end
        self:DrawTalents()
    end
    if changed and addon.itemUpgrades and addon.itemUpgrades.Setup then
        addon.itemUpgrades:Setup()
        if addon.gearAdvisor then addon.gearAdvisor:Refresh() end
    end
    return changed
end

function addon.talents:GetCurrentGuide()
    if PlayerTalentFrame and PlayerTalentFrame.pet then
        local petTree = type(GetPetTalentTree) == "function" and GetPetTalentTree()
        return petTree and self.petGuides[petTree]
    else
        if not self.guides[RXPCData.activeTalentGuide] then
            self:SelectGuideForActiveSpec()
        end
        return self.guides[RXPCData.activeTalentGuide]
    end
end

function addon.talents:UpdateSelectedGuide(key)
    if not key then return end

    if not self.guides[key] then return end

    if UnitLevel("player") < self.guides[key].minLevel then
        addon.comms.PrettyPrint(L("Too low for %s"), self.guides[key].displayname)

        return
    end

    if addon.game == "CATA" then self.cata.CleanupTalentPlan() end

    -- This is shared, so errors on swapping if shared profiles are used!
    -- e.g. Hunter guide loaded but load in a Shaman
    RXPCData.activeTalentGuide = key
    self.guides[key].audit = nil
    if addon.itemUpgrades and addon.itemUpgrades.Setup then
        addon.itemUpgrades:Setup()
        if addon.gearAdvisor then addon.gearAdvisor:Refresh() end
    end
    -- print("RXPCData.activeTalentGuide", RXPCData.activeTalentGuide)
    return true
end

if addon.game ~= "CATA" then
    talentTooltips.updateFunc = function(self)
        if not self or type(self.GetID) ~= "function" then return end
        local tooltip = talentTooltips.data[self:GetID()]
        if not tooltip then return end

        -- Handle refreshing of UI
        GameTooltip:AddLine(tooltip, 1, 1, 1)

        -- Force tooltip redraw
        GameTooltip:Show()
    end
else
    talentTooltips.updateFunc = function(talentIndexFrame)
        if not (talentIndexFrame.RXP and talentIndexFrame.RXP.levels) then return end

        -- Because drawing at tooltip time, extra step required to order it vs everytime in drawTalents
        local sorted_levels = {}
        for l, _ in pairs(talentIndexFrame.RXP.levels) do tinsert(sorted_levels, l) end

        tsort(sorted_levels)

        local levelsCsv = ''
        for _, level in pairs(sorted_levels) do levelsCsv = fmt('%s%d ', levelsCsv, level) end

        -- Only calculate string on tooltip hover, vs every DrawTalents like on Era
        local rxpTooltip = fmt("%s\n%s%s: %s %s|r", talentIndexFrame.RXP.tooltipTextHeader, addon.colors.tooltip,
                               talentText.learned, talentText.level, levelsCsv)
        -- Handle refreshing of UI
        GameTooltip:AddLine(rxpTooltip, 1, 1, 1)

        -- Force tooltip redraw
        GameTooltip:Show()
    end
end

local function DrawTalentLevels(talentIndex, numbers)
    local ht = talentTooltips.highlights[talentIndex]

    if not ht or type(numbers) ~= "table" or #numbers == 0 then return end

    if not ht.levelHeader then
        ht.levelHeader = CreateFrame("Frame", "$parent_levelText", _G["PlayerTalentFrameTalent" .. talentIndex],
                                     BackdropTemplate)

        ht.levelHeader:SetPoint("TOPLEFT", ht, 0, 0)
        ht.levelHeader.text = ht.levelHeader:CreateFontString(nil, "OVERLAY")

        ht.levelHeader.text:ClearAllPoints()
        ht.levelHeader.text:SetPoint("CENTER", ht.levelHeader, 0, 3)
        ht.levelHeader.text:SetJustifyH("LEFT")
        ht.levelHeader.text:SetJustifyV("MIDDLE")

        -- TODO specific text color setting?
        ht.levelHeader.text:SetTextColor(unpack(addon.activeTheme.textColor))
        ht.levelHeader.text:SetFont(addon.font, 10, "OUTLINE")
    end

    -- If 5 levels of preview, overlaps with nearby
    ht.levelHeader:ClearAllPoints()
    if #numbers == 5 then
        ht.levelHeader.text:SetFont(addon.font, 7, "OUTLINE")
        ht.levelHeader:SetPoint("TOPLEFT", ht, -3, 0)
    elseif #numbers == 4 then
        ht.levelHeader.text:SetFont(addon.font, 9, "OUTLINE")
        ht.levelHeader:SetPoint("TOPLEFT", ht, -1, 0)
    else
        ht.levelHeader.text:SetFont(addon.font, 10, "OUTLINE")
        ht.levelHeader:SetPoint("TOPLEFT", ht, 1, 0)
    end

    -- Ensure single number ends up as a string
    local newText = '' .. strjoin(',', unpack(numbers))

    -- No changes, prevent uneeded UI calls
    if ht.levelHeader.text:GetText() == newText then return end

    ht.levelHeader.text:SetText(newText)
    ht.levelHeader:SetSize(ht.levelHeader.text:GetStringWidth() + 10, 17)
end

local function setHighlightColor(talentIndex, index)
    -- Set color to last if no specific match
    local color = talentTooltips.highlightColors[index] or
                      talentTooltips.highlightColors[#talentTooltips.highlightColors]
    local highlight = talentTooltips.highlights[talentIndex]
    if highlight then highlight:SetVertexColor(unpack(color)) end
end

function addon.talents:DrawTalents()
    local guide = self:GetCurrentGuide()
    if not guide then return end

    if not PlayerTalentFrame or not PlayerTalentFrame:IsShown() then return end
    if PlayerTalentFrame.pet then return end

    -- Intialization race condition at login, silently ignore instead of spammy or retries
    if not indexLookup['player'].initialized then return end

    if addon.game == "CATA" then return addon.talents.cata:DrawTalents(guide) end

    if not addon.settings.profile.hightlightTalentPlan then
        -- If disabled, cleanup old draws for dynamic settings
        local ht
        for i in pairs(talentTooltips.highlights) do
            ht = talentTooltips.highlights[i]
            if ht:IsShown() then ht:Hide() end

            if ht.levelHeader and ht.levelHeader:IsShown() then
                ht.levelHeader:Hide()
                ht.levelHeader.text:SetText(nil)
            end
        end

        return
    end

    local currentTab = type(PanelTemplates_GetSelectedTab) == "function" and
                           PanelTemplates_GetSelectedTab(PlayerTalentFrame)
    if not tonumber(currentTab) then return end
    local remainingPoints, levelStep, talentIndex

    local playerLevel = tonumber(addon.player.level) or UnitLevel("player")
    playerLevel, remainingPoints = GetAvailablePlanLevel(guide, playerLevel, false)
    local advancedWarning = playerLevel + (tonumber(addon.settings.profile.upcomingTalentCount) or 5)
    wipe(talentTooltips.data)

    -- If audit failed, draw the entire range
    if guide.audit == false then
        playerLevel = guide.minLevel - 1
        -- Keep existing player level based advancedWarning
    end

    -- Track state better than with Blizz frame re-use
    wipe(activeIndices)
    wipe(levelsForIndex)

    local newHightlightTexture, tooltipPrefix

    -- Create highlight frames and set data objects for later processing
    for upcomingTalent = (playerLevel + 1 - remainingPoints), advancedWarning do

        levelStep = guide.steps[upcomingTalent - guide.minLevel + 1]

        if levelStep then
            tooltipPrefix = levelStep.optional and talentText.optional or talentText.learned
            if type(tooltipPrefix) ~= "string" or tooltipPrefix == "" then
                tooltipPrefix = levelStep.optional and "Optional" or "Learned"
            end

            for _, element in ipairs(type(levelStep.elements) == "table" and levelStep.elements or {}) do
                for _, talentData in ipairs(element.talent or {}) do
                    local tabLookup = indexLookup['player'][talentData.tab]
                    local tierLookup = tabLookup and tabLookup[talentData.tier]
                    talentIndex = tierLookup and tierLookup[talentData.column]

                    local talentFrame = talentIndex and _G["PlayerTalentFrameTalent" .. talentIndex]
                    local talentSlot = talentIndex and _G["PlayerTalentFrameTalent" .. talentIndex .. "Slot"]
                    if talentIndex and talentFrame and talentSlot and currentTab == talentData.tab then
                        activeIndices[talentIndex] = talentData.tab

                        talentTooltips.data[talentIndex] = talentTooltips.data[talentIndex] or
                                                               fmt("\n%s - %s", tostring(addon.title or "RestedXP Guides"),
                                                                   tostring(guide.name or guide.key or "Talent Guide"))

                        talentTooltips.data[talentIndex] = fmt("%s\n%s%s: %s %d|r", talentTooltips.data[talentIndex],
                                                               tostring(addon.colors.tooltip or ""), tooltipPrefix,
                                                               tostring(talentText.level or "Level"),
                                                               upcomingTalent)

                        -- TODO Pre-seed tooltip to prevent delay

                        if not talentTooltips.highlights[talentIndex] then
                            newHightlightTexture = talentFrame:CreateTexture("$parent_LevelPreview", "BORDER")

                            newHightlightTexture:SetTexture("Interface/Buttons/ButtonHilight-Square")
                            newHightlightTexture:SetBlendMode("ADD")
                            newHightlightTexture:SetAllPoints(talentSlot)

                            talentTooltips.highlights[talentIndex] = newHightlightTexture
                        end

                        setHighlightColor(talentIndex, upcomingTalent - playerLevel)

                        if levelsForIndex[talentIndex] then
                            tinsert(levelsForIndex[talentIndex], upcomingTalent)
                        else
                            levelsForIndex[talentIndex] = {upcomingTalent}
                        end

                    end

                end -- ipairs(element.talent)
            end -- ipairs(levelStep.elements)

        end -- if levelStep
    end

    -- Ensure all highlights and levelHeaders are shown/hidden as applicable
    for index, ht in pairs(talentTooltips.highlights) do

        if activeIndices[index] and activeIndices[index] == currentTab then
            -- Set levelHeader data from array data
            DrawTalentLevels(index, levelsForIndex[index])

            if not ht:IsShown() then ht:Show() end
            if ht.levelHeader and not ht.levelHeader:IsShown() then ht.levelHeader:Show() end
        else
            if ht:IsShown() then ht:Hide() end
            if ht.levelHeader and ht.levelHeader:IsShown() then ht.levelHeader:Hide() end
        end

    end

end

function addon.talents:BuildIndexLookup()
    if not PlayerTalentFrame or type(_G.GetNumTalentTabs) ~= "function" or type(_G.GetNumTalents) ~= "function" or
        type(GetTalentInfo) ~= "function" then return end

    local isPet = PlayerTalentFrame.pet and true or false
    local kind = 'player'
    if isPet then
        if type(GetPetTalentTree) ~= "function" then return end
        kind = GetPetTalentTree()
        if not kind then return end
    end

    if indexLookup[kind] and indexLookup[kind].initialized then return end

    indexLookup[kind] = {}

    local tier, column
    local name
    local foundTalent

    -- print("BuildIndexLookup() looping", kind)

    local numTabs = tonumber(_G.GetNumTalentTabs(nil, isPet, PlayerTalentFrame.talentGroup)) or 0
    for tabIndex = 1, numTabs do
        indexLookup[kind][tabIndex] = {}

        local numTalents = tonumber(_G.GetNumTalents(tabIndex, nil, isPet, PlayerTalentFrame.talentGroup)) or 0
        for talentIndex = 1, numTalents do
            name, _, tier, column = GetTalentInfo(tabIndex, talentIndex, nil, isPet,
                                                  PlayerTalentFrame.talentGroup)
            tier, column = tonumber(tier), tonumber(column)
            if name and tier and column then
                indexLookup[kind][tabIndex][tier] = indexLookup[kind][tabIndex][tier] or {}
                indexLookup[kind][tabIndex][tier][column] = talentIndex
                foundTalent = true
            end

        end
    end

    if foundTalent then indexLookup[kind].initialized = true end
end

function addon.talents:ProcessTalents(validate)
    if not PlayerTalentFrame then return false end
    if PlayerTalentFrame.pet then return self:ProcessPetTalents(validate) end

    self:BuildIndexLookup()

    local playerLevel = UnitLevel("player")

    local guide = self:GetCurrentGuide()

    if not guide then return end

    local availablePlanLevel
    availablePlanLevel = GetAvailablePlanLevel(guide, playerLevel, false)

    -- Somehow guide not audited, force an audit
    if guide.audit == nil then self:Audit() end

    if guide.audit ~= true then return end

    if validate then addon.comms.PrettyDebug("Validating %s", guide.displayname) end

    if playerLevel < guide.minLevel and not validate then
        addon.comms.PrettyPrint(L("Too low for %s"), guide.displayname) --
        return
    end

    if playerLevel > guide.maxLevel and not validate then
        addon.comms.PrettyPrint(L("Too high for %s"), guide.displayname) --
        return
    end

    if addon.game == "CATA" then addon.talents.cata:SkipTalentSummariesPage(guide) end

    local stepLevel, remainingPoints, result
    local optionalName, optionalLearned, optionalNotLearned

    for stepNum, step in ipairs(guide.steps) do
        stepLevel = guide.minLevel + stepNum - 1

        remainingPoints = GetRemainingTalentPoints(false)

        if (stepLevel > availablePlanLevel) or remainingPoints == 0 then
            if not validate and playerLevel == guide.maxLevel and guide.nextKey then
                addon.comms.PrettyPrint(L("Reached maximum level for guide"))

                if self:UpdateSelectedGuide(guide.nextKey) then
                    addon.comms.PrettyPrint(L("Loaded next guide, %s"), guide.next)
                end
            end

            if validate then return true end
            return
        end

        -- print("Evaluating step", stepNum, "for level", stepLevel)
        if step.optional then
            optionalLearned = nil
            optionalNotLearned = {}
        end

        for _, element in ipairs(step.elements) do

            -- Level steps can have multiple .talent underneath, only for #optional
            for tag, _ in pairs(element) do
                -- print("Evaluating tag", tag)
                if self.functions[tag] then
                    -- print("Executing tag function", tag)
                    result, optionalName = self.functions[tag](element, validate, step.optional)
                else
                    result = false
                    addon.error(L("Error parsing guide") .. " " .. (guide.name or 'Unknown') ..
                                    ": Invalid function call (." .. tag .. ")\n" .. stepNum)
                end

                if step.optional and optionalName then
                    -- .talent optional returns {true, name} if learned or {false, name} if not learned
                    if result then
                        -- Avoid blocking on user action if talent exists in any optional blocks
                        optionalLearned = optionalName
                    else
                        -- Specific optional .talent not learned
                        tinsert(optionalNotLearned, optionalName)
                    end
                elseif result == false or result == -1 then
                    -- Exit processing if error found
                    -- Rely on in-tag-function error output for user communication
                    -- Explicitly require false, accept nil as truthy
                    -- print("Aborting step processing", result)

                    return
                end
            end
        end

        if step.optional and not optionalLearned then
            addon.comms:PopupNotification("RXPTalentsMissingOptional",
                                          fmt("%s %s %s: %s\n%s\n\n%s", talentText.missing, talentText.optional,
                                              string.lower(talentText.talentPoints),
                                              fmt(GetGlobalString("UNIT_LEVEL_TEMPLATE", "Level %d"), stepLevel),
                                              GetGlobalString("TALENT_BUTTON_TOOLTIP_SELECT_INSTRUCTIONS",
                                                              "Select one of these talents"),
                                              strjoin("\n", unpack(optionalNotLearned))))
            return
        end

    end

    return true

end

-- Pet talents vary by spec, gained at 20 then every 4, just handle separately
function addon.talents:ProcessPetTalents(validate)
    if not PlayerTalentFrame then return false end
    self:BuildIndexLookup()

    local playerLevel = UnitLevel("player")

    local guide = self:GetCurrentGuide()

    if not guide or not guide.pet then return end

    if validate then addon.comms.PrettyDebug("Validating %s", guide.displayname) end

    if playerLevel < guide.minLevel and not validate then
        addon.comms.PrettyPrint(L("Too low for %s"), guide.displayname) --
        return
    end

    if playerLevel > guide.maxLevel and not validate then
        addon.comms.PrettyPrint(L("Too high for %s"), guide.displayname) --
        return
    end

    local remainingPoints

    for stepNum, step in ipairs(guide.steps) do
        remainingPoints = GetRemainingTalentPoints(true)

        if remainingPoints == 0 then
            if not validate and playerLevel == guide.maxLevel then
                addon.comms.PrettyPrint(L("Reached maximum level for guide"))
            end

            if validate then return true end
            return
        end

        -- print("Evaluating pet step", stepNum)
        local result

        for _, element in ipairs(step.elements) do
            for tag, _ in pairs(element) do
                -- print("Evaluating tag", tag)
                if self.functions[tag] then
                    -- print("Executing tag function", tag)
                    result = self.functions[tag](element, validate, step.optional)
                else
                    result = false
                    addon.error(L("Error parsing guide") .. " " .. (guide.name or 'Unknown') ..
                                    ": Invalid function call (." .. tag .. ")\n" .. stepNum)
                end

                if result == false then
                    addon.comms.PrettyDebug("Aborting processing at step %d", stepNum)
                    return
                end
            end

        end

    end

end

addon.talents.cata = {}

function addon.talents.cata:SkipTalentSummariesPage(guide)
    if _G.PanelTemplates_GetSelectedTab(PlayerTalentFrame) == _G.GLYPH_TALENT_TAB then
        _G["PlayerTalentFrameTab" .. _G.TALENTS_TAB]:Click()
    end
    -- Cata uses gives summary of trees on fresh 10/respec "View Talent Trees"
    if _G.PlayerTalentFramePanel1Summary:IsShown() then
        -- Click to leverage PlayerTalentFrame_ShowOrHideSummaries to show talents
        _G.PlayerTalentFrameToggleSummariesButton:Click()
    end

    -- then "Select a X Specialization" based on first talent chosen
    local firstTalentTab = -1

    for _, step in ipairs(guide.steps) do
        if firstTalentTab > -1 then break end

        for _, element in ipairs(step.elements) do
            if element.talent and element.talent[1] and element.talent[1].tab then
                firstTalentTab = element.talent[1].tab
                break
            end
        end
    end

    local firstTalentTabButton = _G["PlayerTalentFramePanel" .. firstTalentTab .. "SelectTreeButton"]
    if firstTalentTabButton then
        if firstTalentTabButton:IsShown() then firstTalentTabButton:Click() end
    else
        -- Failure to get first tab, panic?
    end

    return true
end

local function cataDrawTalentLevels(talentIndexFrameName, levels)
    local talentIndexFrame = _G[talentIndexFrameName]
    if not talentIndexFrame then return end

    if not talentIndexFrame.levelHeader then
        local anchor = _G[talentIndexFrameName .. 'IconOverlay']
        talentIndexFrame.levelHeader = CreateFrame("Frame", "$parent_RXPLevelText", anchor or talentIndexFrame,
                                                   BackdropTemplate)

        talentIndexFrame.levelHeader:SetPoint("BOTTOMLEFT", talentIndexFrame, "TOPLEFT", 0, -4)
        talentIndexFrame.levelHeader.text = talentIndexFrame.levelHeader:CreateFontString(nil, "OVERLAY")

        talentIndexFrame.levelHeader.text:ClearAllPoints()
        talentIndexFrame.levelHeader.text:SetPoint("LEFT", talentIndexFrame.levelHeader, 0, 0)
        talentIndexFrame.levelHeader.text:SetJustifyH("LEFT")
        talentIndexFrame.levelHeader.text:SetJustifyV("MIDDLE")

        talentIndexFrame.levelHeader.text:SetTextColor(unpack(addon.activeTheme.textColor))
        talentIndexFrame.levelHeader.text:SetFont(addon.font, 8, "OUTLINE")
    end

    -- TODO cache optimization
    -- Because drawing at tooltip time, extra step required to order it
    local sorted_levels = {}
    for l, _ in pairs(levels) do tinsert(sorted_levels, l) end

    tsort(sorted_levels)
    local newText = '' .. strjoin(',', unpack(sorted_levels))

    -- If 5 levels of preview, overlaps with nearby
    if #sorted_levels < 4 then
        -- talentIndexFrame.levelHeader.text:SetFont(addon.font, 8, "OUTLINE")
        talentIndexFrame.levelHeader:SetPoint("BOTTOMLEFT", talentIndexFrame, "TOPLEFT", 0, -4)
    else
        -- talentIndexFrame.levelHeader.text:SetFont(addon.font, 8, "OUTLINE")
        talentIndexFrame.levelHeader:SetPoint("BOTTOMLEFT", talentIndexFrame, "TOPLEFT", -2 * #sorted_levels, -4)
    end

    -- No changes, prevent uneeded UI calls
    if talentIndexFrame.levelHeader.text:GetText() == newText then return end

    talentIndexFrame.levelHeader.text:SetText(newText)
    talentIndexFrame.levelHeader:SetSize(talentIndexFrame.levelHeader.text:GetStringWidth() + 10, 17)
end

-- https://www.wowhead.com/guide=cataclysm&mastery#talents
local cataTalentLevels = {
    10, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49, 51, 53, 55, 57, 59, 61, 63, 65,
    67, 69, 71, 73, 75, 77, 79, 81, 82, 83, 84, 85
}

local function lookupTalentLevel(nextTalentStepIndex) return cataTalentLevels[nextTalentStepIndex] end

function addon.talents.cata:DrawTalents(guide)
    guide = guide or self:GetCurrentGuide()
    if not guide then return end

    if not PlayerTalentFrame or not PlayerTalentFrame:IsShown() then return end
    if PlayerTalentFrame.pet then return end

    -- Initialization issue, probably Glyphs tab loaded at first login
    -- Silently exit instead of spammy errors or BuildIndexLookup retries
    if not indexLookup['player'].initialized then return end

    -- hightlightTalentPlan doesn't include highlights in Cata
    if not addon.settings.profile.hightlightTalentPlan then
        -- If disabled, cleanup old draws for dynamic settings
        self.CleanupTalentPlan()

        return
    end

    local remainingPoints, levelStep, talentIndex

    remainingPoints = GetRemainingTalentPoints(false)

    local playerLevel = UnitLevel("player")

    local advancedWarning = playerLevel + (tonumber(addon.settings.profile.upcomingTalentCount) or 5)

    -- TODO cache data if unchanged
    local talentInfo, levelLookup, levelStepIndex

    -- Create plan frames and set data objects for later processing
    for upcomingTalent = (playerLevel + 1 - remainingPoints), advancedWarning do
        levelStepIndex = upcomingTalent - guide.minLevel + 1
        levelStep = guide.steps[levelStepIndex]

        if levelStep then

            for _, element in ipairs(levelStep.elements) do
                for _, talentData in ipairs(element.talent) do

                    talentIndex = indexLookup['player'][talentData.tab][talentData.tier][talentData.column]

                    if talentTooltips.cataPlan[talentData.tab][talentIndex] then
                        talentInfo = talentTooltips.cataPlan[talentData.tab][talentIndex]
                    else
                        talentInfo = {
                            levels = {},
                            talentData = talentData,
                            tooltipTextHeader = fmt("%s - %s", addon.title, guide.name)
                        }

                        talentTooltips.cataPlan[talentData.tab][talentIndex] = talentInfo
                    end

                    levelLookup = lookupTalentLevel(levelStepIndex)
                    if not levelLookup then
                        -- Error looking up level, misformatted guide
                        return
                    end

                    if levelLookup and not talentInfo.levels[levelLookup] then
                        talentInfo.levels[levelLookup] = levelLookup
                    end

                    if not talentInfo.talentIndexFrameName then
                        talentInfo.talentIndexFrameName = "PlayerTalentFramePanel" .. talentData.tab .. "Talent" ..
                                                              talentIndex
                        talentInfo.talentIndexFrame = _G[talentInfo.talentIndexFrameName]

                        -- Add reverse lookup for tooltip updateFunc logic
                        talentInfo.talentIndexFrame.RXP = talentInfo
                    end

                end -- ipairs(element.talent)
            end -- ipairs(levelStep.elements)

        end -- if levelStep
    end

    -- Ensure all plans and levelHeaders are shown/hidden as applicable
    for _, tabData in pairs(talentTooltips.cataPlan) do
        for _, tInfo in pairs(tabData) do
            cataDrawTalentLevels(tInfo.talentIndexFrameName, tInfo.levels)

            if not _G[tInfo.talentIndexFrameName].levelHeader:IsShown() then
                _G[tInfo.talentIndexFrameName].levelHeader:Show()
            end
        end
    end
end

function addon.talents.cata.CleanupTalentPlan()
    if _G.PlayerTalentFrameResetButton_OnClick then _G.PlayerTalentFrameResetButton_OnClick() end

    local f

    for _, tabData in pairs(talentTooltips.cataPlan) do
        for _, tInfo in pairs(tabData) do
            f = _G[tInfo.talentIndexFrameName]

            if f and f.levelHeader and f.levelHeader:IsShown() then
                f.levelHeader:Hide()

                if f.levelHeader.text then f.levelHeader.text:SetText(nil) end
            end

            wipe(tInfo.levels)
        end
    end
end

_G.RXPGuides.talents = {RegisterGuide = addon.talents.RegisterGuide}
