local addonName, addon = ...
local L = addon.locale.Get

if not (addon.game == "CLASSIC" or addon.game == "TBC" or addon.game == "CATA" or addon.game == "WOTLK") then return end

local locale = GetLocale()

local fmt, tinsert, ipairs, pairs, next, type, wipe, tonumber, strlower, smatch = string.format, table.insert, ipairs,
                                                                                  pairs, next, type, wipe, tonumber,
                                                                                  strlower, string.match

local GetItemInfo = C_Item and C_Item.GetItemInfo or _G.GetItemInfo
local GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant or _G.GetItemInfoInstant
local NativeIsEquippedItem = C_Item and C_Item.IsEquippedItem or _G.IsEquippedItem
local GetItemStats = C_Item and C_Item.GetItemStats or _G.GetItemStats
local UnitLevel = _G.UnitLevel
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or _G.GetContainerNumSlots
local GetContainerItemLink = C_Container and C_Container.GetContainerItemLink or _G.GetContainerItemLink
local PickupContainerItem = C_Container and C_Container.PickupContainerItem or _G.PickupContainerItem
local PickupInventoryItem = _G.PickupInventoryItem

local ItemArmorSubclass, ItemWeaponSubclass = Enum.ItemArmorSubclass, Enum.ItemWeaponSubclass

local function IsEquippedItem(itemLink)
    if not itemLink then return false end
    if NativeIsEquippedItem then
        local ok, equipped = pcall(NativeIsEquippedItem, itemLink)
        if ok and equipped then return true end
    end
    -- The legacy helper can return false for a fully-qualified link even when
    -- that exact link is equipped. Inventory slots are authoritative and also
    -- work on cores where IsEquippedItem is absent or incomplete.
    for slot = 1, (_G.INVSLOT_LAST_EQUIPPED or 19) do
        if GetInventoryItemLink("player", slot) == itemLink then return true end
    end
    return false
end

addon.itemUpgrades = addon:NewModule("ItemUpgrades", "AceEvent-3.0")

local session = {
    isInitialized = false,

    -- Loaded stat weights for class
    -- Available spec weights, e.g. ele/enh or mageAoe/mageSingle
    specWeights = {},

    -- Active loaded stat weights
    activeStatWeights = {},

    -- Capturable regexes for tooltip parsing
    statsRegexes = {},

    -- Item stats cache
    itemCache = {},

    -- Track compatible
    equippableSlots = {},
    equippableArmor = {},
    equippableWeapons = {},
    trainedWeapons = {},
    trainedArmor = {},
    trainedShield = nil,
    wearabilityLevel = nil,
    wearabilityClass = nil,

    weaponSlotToWeightKey = {},

    -- TODO handle thread-safe?
    comparisonTip = nil,

    -- Upgrade prompts are session-only. A declined item is reconsidered after it
    -- leaves the bags or the equipped comparison changes.
    promptedUpgrades = {},
    upgradeScanSerial = 0,
    upgradePopupOpen = false,
    pendingUpgradeEquip = nil,
    upgradeQueryRetries = 0,

    -- Remember explicit hand replacements so the displaced weapon is not
    -- offered straight back against the exact item which replaced it. The
    -- suppression expires naturally as soon as that replacement changes.
    equippedHandLinks = {},
    suppressedHandReversals = {}
}

-- Defined with the legacy subtype helpers below; forward-declared because the
-- main setup routine is intentionally kept near the event registration code.
local RefreshWeaponProficiencies
local QueueUpgradeScan

local function SnapshotHandEquipment()
    session.equippedHandLinks[_G.INVSLOT_MAINHAND] =
        GetInventoryItemLink("player", _G.INVSLOT_MAINHAND)
    session.equippedHandLinks[_G.INVSLOT_OFFHAND] =
        GetInventoryItemLink("player", _G.INVSLOT_OFFHAND)
end

-- TODO support spec awareness
-- Ignoring for now since overrides are rare and specific
local ITEM_WEIGHT_ADDITIONS = {
    ["DEATHKNIGHT"] = {},
    ["DRUID"] = {},
    ["HUNTER"] = {},
    ["MAGE"] = {},
    ["PALADIN"] = {},
    ["PRIEST"] = {},
    ["ROGUE"] = {},
    ["SHAMAN"] = {
        -- [4908] = 12 -- Additional 12 EP for testing
    },
    ["WARLOCK"] = {},
    ["WARRIOR"] = {}
}

-- Some legacy cores expose one of these spell queries but not the other (or
-- omit hidden passives from one of them). Use both when deciding whether a
-- class-specific slot is currently available.
local function KnowsLegacySpell(spellID)
    if type(_G.IsPlayerSpell) == "function" and
        _G.IsPlayerSpell(spellID) then
        return true
    end
    return type(_G.IsSpellKnown) == "function" and
               _G.IsSpellKnown(spellID) and true or false
end

local function GetLegacyOffhandWeaponSlot()
    -- 674 is the normal Dual Wield passive. WotLK Enhancement Shamans learn
    -- the talent passive (30798), which not every private core mirrors back to
    -- IsSpellKnown(674).
    return (KnowsLegacySpell(674) or KnowsLegacySpell(30798)) and
               _G.INVSLOT_OFFHAND or nil
end

local CLASS_MAP = {
    ["All"] = {
        ["Slot"] = {
            ["INVTYPE_HEAD"] = _G.INVSLOT_HEAD,
            ["INVTYPE_NECK"] = _G.INVSLOT_NECK,
            ["INVTYPE_SHOULDER"] = _G.INVSLOT_SHOULDER,
            ["INVTYPE_BODY"] = _G.INVSLOT_BODY,
            ["INVTYPE_CHEST"] = _G.INVSLOT_CHEST,
            ["INVTYPE_ROBE"] = _G.INVSLOT_CHEST,
            ["INVTYPE_WAIST"] = _G.INVSLOT_WAIST,
            ["INVTYPE_LEGS"] = _G.INVSLOT_LEGS,
            ["INVTYPE_FEET"] = _G.INVSLOT_FEET,
            ["INVTYPE_WRIST"] = _G.INVSLOT_WRIST,
            ["INVTYPE_HAND"] = _G.INVSLOT_HAND,
            ["INVTYPE_FINGER"] = {[_G.INVSLOT_FINGER1] = _G.INVSLOT_FINGER1, [_G.INVSLOT_FINGER2] = _G.INVSLOT_FINGER2},
            ["INVTYPE_TRINKET"] = {
                [_G.INVSLOT_TRINKET1] = _G.INVSLOT_TRINKET1,
                [_G.INVSLOT_TRINKET2] = _G.INVSLOT_TRINKET2
            },
            ["INVTYPE_CLOAK"] = _G.INVSLOT_BACK,
            ["INVTYPE_HOLDABLE"] = _G.INVSLOT_OFFHAND,
            ["INVTYPE_WEAPONMAINHAND"] = _G.INVSLOT_MAINHAND,
            ["INVTYPE_WEAPON"] = _G.INVSLOT_MAINHAND,
            ["INVTYPE_2HWEAPON"] = _G.INVSLOT_MAINHAND
        },
        ["ArmorType"] = {
            [ItemArmorSubclass.Generic] = true, -- Trinkets, rings, necks
            [ItemArmorSubclass.Cloth] = true -- Cloaks plus cloth armor
        },
        ["WeaponType"] = {[ItemWeaponSubclass.Generic] = true}
    },
    ["DEATHKNIGHT"] = {
        ["Slot"] = {
            ["INVTYPE_RELIC"] = _G.INVSLOT_RANGED,
            ["INVTYPE_WEAPONOFFHAND"] = GetLegacyOffhandWeaponSlot
        },
        ["ArmorType"] = {
            [ItemArmorSubclass.Leather] = true,
            [ItemArmorSubclass.Mail] = true,
            [ItemArmorSubclass.Plate] = true, -- DK always 55+
            [ItemArmorSubclass.Sigil] = true
        },
        ["WeaponType"] = {
            [ItemWeaponSubclass.Axe1H] = true,
            [ItemWeaponSubclass.Axe2H] = true,
            [ItemWeaponSubclass.Mace1H] = true,
            [ItemWeaponSubclass.Mace2H] = true,
            [ItemWeaponSubclass.Polearm] = function() return UnitLevel("player") >= 18 end,
            [ItemWeaponSubclass.Sword1H] = true,
            [ItemWeaponSubclass.Sword2H] = true,
            [ItemWeaponSubclass.Unarmed] = true
        }
    },
    ["DRUID"] = {
        ["Slot"] = {["INVTYPE_RELIC"] = _G.INVSLOT_RANGED},
        ["ArmorType"] = {
            [ItemArmorSubclass.Leather] = true,
            [ItemArmorSubclass.Idol] = true
        },
        ["WeaponType"] = {
            [ItemWeaponSubclass.Mace1H] = true,
            [ItemWeaponSubclass.Mace2H] = true,
            [ItemWeaponSubclass.Polearm] = function()
                return addon.game == "WOTLK" or addon.game == "CATA"
            end,
            [ItemWeaponSubclass.Staff] = true,
            [ItemWeaponSubclass.Unarmed] = true,
            [ItemWeaponSubclass.Dagger] = true
        }
    },
    ["HUNTER"] = {
        ["Slot"] = {
            ["INVTYPE_THROWN"] = _G.INVSLOT_RANGED,
            ["INVTYPE_RANGEDRIGHT"] = _G.INVSLOT_RANGED,
            ["INVTYPE_RANGED"] = _G.INVSLOT_RANGED,
            ["INVTYPE_WEAPONOFFHAND"] = GetLegacyOffhandWeaponSlot
        },
        ["ArmorType"] = {
            [ItemArmorSubclass.Leather] = true,
            [ItemArmorSubclass.Mail] = function() return UnitLevel("player") >= 40 end
        },
        ["WeaponType"] = {
            [ItemWeaponSubclass.Axe1H] = true,
            [ItemWeaponSubclass.Axe2H] = true,
            [ItemWeaponSubclass.Bows] = true,
            [ItemWeaponSubclass.Guns] = true,
            [ItemWeaponSubclass.Polearm] = function() return UnitLevel("player") >= 18 end,
            [ItemWeaponSubclass.Sword1H] = true,
            [ItemWeaponSubclass.Sword2H] = true,
            [ItemWeaponSubclass.Staff] = true,
            [ItemWeaponSubclass.Unarmed] = true,
            [ItemWeaponSubclass.Dagger] = true,
            [ItemWeaponSubclass.Crossbow] = true
        }
    },
    ["MAGE"] = {
        ["Slot"] = {["INVTYPE_RANGEDRIGHT"] = _G.INVSLOT_RANGED},
        ["ArmorType"] = {},
        ["WeaponType"] = {
            [ItemWeaponSubclass.Sword1H] = true,
            [ItemWeaponSubclass.Dagger] = true,
            [ItemWeaponSubclass.Staff] = true,
            [ItemWeaponSubclass.Wand] = true
        }
    },
    ["PALADIN"] = {
        ["Slot"] = {
            ["INVTYPE_SHIELD"] = _G.INVSLOT_OFFHAND,
            ["INVTYPE_RELIC"] = _G.INVSLOT_RANGED
        },
        ["ArmorType"] = {
            [ItemArmorSubclass.Shield] = true,
            [ItemArmorSubclass.Leather] = true,
            [ItemArmorSubclass.Mail] = true,
            [ItemArmorSubclass.Plate] = function() return UnitLevel("player") >= 40 end,
            [ItemArmorSubclass.Libram] = true
        },
        ["WeaponType"] = {
            [ItemWeaponSubclass.Axe1H] = true,
            [ItemWeaponSubclass.Axe2H] = true,
            [ItemWeaponSubclass.Mace1H] = true,
            [ItemWeaponSubclass.Mace2H] = true,
            [ItemWeaponSubclass.Polearm] = function() return UnitLevel("player") >= 18 end,
            [ItemWeaponSubclass.Sword1H] = true,
            [ItemWeaponSubclass.Sword2H] = true
        }
    },
    ["PRIEST"] = {
        ["Slot"] = {["INVTYPE_RANGEDRIGHT"] = _G.INVSLOT_RANGED},
        ["ArmorType"] = {},
        ["WeaponType"] = {
            [ItemWeaponSubclass.Mace1H] = true,
            [ItemWeaponSubclass.Dagger] = true,
            [ItemWeaponSubclass.Staff] = true,
            [ItemWeaponSubclass.Wand] = true
        }
    },
    ["ROGUE"] = {
        ["Slot"] = {
            ["INVTYPE_THROWN"] = _G.INVSLOT_RANGED,
            ["INVTYPE_RANGEDRIGHT"] = _G.INVSLOT_RANGED,
            ["INVTYPE_RANGED"] = _G.INVSLOT_RANGED,
            ["INVTYPE_WEAPONOFFHAND"] = GetLegacyOffhandWeaponSlot
        },
        ["ArmorType"] = {[ItemArmorSubclass.Leather] = true},
        ["WeaponType"] = {
            [ItemWeaponSubclass.Axe1H] = function()
                return addon.game == "WOTLK" or addon.game == "CATA"
            end,
            [ItemWeaponSubclass.Bows] = true,
            [ItemWeaponSubclass.Guns] = true,
            [ItemWeaponSubclass.Mace1H] = true,
            [ItemWeaponSubclass.Sword1H] = true,
            [ItemWeaponSubclass.Unarmed] = true,
            [ItemWeaponSubclass.Dagger] = true,
            [ItemWeaponSubclass.Thrown] = true,
            [ItemWeaponSubclass.Crossbow] = true
        }
    },
    ["SHAMAN"] = {
        ["Slot"] = {
            ["INVTYPE_SHIELD"] = _G.INVSLOT_OFFHAND,
            ["INVTYPE_RELIC"] = _G.INVSLOT_RANGED,
            ["INVTYPE_WEAPONOFFHAND"] = GetLegacyOffhandWeaponSlot
        },
        ["ArmorType"] = {
            [ItemArmorSubclass.Shield] = true,
            [ItemArmorSubclass.Leather] = true,
            [ItemArmorSubclass.Mail] = function() return UnitLevel("player") >= 40 end,
            [ItemArmorSubclass.Totem] = true
        },
        ["WeaponType"] = {
            [ItemWeaponSubclass.Axe1H] = true,
            [ItemWeaponSubclass.Axe2H] = true,
            [ItemWeaponSubclass.Mace1H] = true,
            [ItemWeaponSubclass.Mace2H] = true,
            [ItemWeaponSubclass.Staff] = true,
            [ItemWeaponSubclass.Unarmed] = true,
            [ItemWeaponSubclass.Dagger] = true
        }
    },
    ["WARLOCK"] = {
        ["Slot"] = {["INVTYPE_RANGEDRIGHT"] = _G.INVSLOT_RANGED},
        ["ArmorType"] = {},
        ["WeaponType"] = {
            [ItemWeaponSubclass.Sword1H] = true,
            [ItemWeaponSubclass.Dagger] = true,
            [ItemWeaponSubclass.Staff] = true,
            [ItemWeaponSubclass.Wand] = true
        }
    },
    ["WARRIOR"] = {
        ["Slot"] = {
            ["INVTYPE_THROWN"] = _G.INVSLOT_RANGED,
            ["INVTYPE_RANGED"] = _G.INVSLOT_RANGED,
            ["INVTYPE_RANGEDRIGHT"] = _G.INVSLOT_RANGED,
            ["INVTYPE_SHIELD"] = _G.INVSLOT_OFFHAND,
            ["INVTYPE_WEAPONOFFHAND"] = GetLegacyOffhandWeaponSlot
        },
        ["ArmorType"] = {
            [ItemArmorSubclass.Shield] = true,
            [ItemArmorSubclass.Leather] = true,
            [ItemArmorSubclass.Mail] = true,
            [ItemArmorSubclass.Plate] = function() return UnitLevel("player") >= 40 end
        },
        ["WeaponType"] = {
            [ItemWeaponSubclass.Axe1H] = true,
            [ItemWeaponSubclass.Axe2H] = true,
            [ItemWeaponSubclass.Bows] = true,
            [ItemWeaponSubclass.Guns] = true,
            [ItemWeaponSubclass.Mace1H] = true,
            [ItemWeaponSubclass.Mace2H] = true,
            [ItemWeaponSubclass.Polearm] = function() return UnitLevel("player") >= 18 end,
            [ItemWeaponSubclass.Sword1H] = true,
            [ItemWeaponSubclass.Sword2H] = true,
            [ItemWeaponSubclass.Staff] = true,
            [ItemWeaponSubclass.Unarmed] = true,
            [ItemWeaponSubclass.Thrown] = true,
            [ItemWeaponSubclass.Dagger] = true,
            [ItemWeaponSubclass.Crossbow] = true
        }
    }
}

-- Map quasi-friendly key from GSheet/StatWeights to regex-friendly value
-- GSheet or pretty name = Regex formatting
local KEY_TO_TEXT = {
    ['ITEM_MOD_STRENGTH_SHORT'] = _G.ITEM_MOD_STRENGTH,
    ['ITEM_MOD_AGILITY_SHORT'] = _G.ITEM_MOD_AGILITY,
    ['ITEM_MOD_INTELLECT_SHORT'] = _G.ITEM_MOD_INTELLECT,
    ['ITEM_MOD_STAMINA_SHORT'] = _G.ITEM_MOD_STAMINA,
    ['ITEM_MOD_SPIRIT_SHORT'] = _G.ITEM_MOD_SPIRIT,
    ['ITEM_MOD_HEALTH_REGEN_SHORT'] = _G.ITEM_MOD_HEALTH_REGEN,
    ['ITEM_MOD_POWER_REGEN0_SHORT'] = _G.ITEM_MOD_MANA_REGENERATION,
    ['ITEM_MOD_SPELL_HEALING_DONE'] = _G.ITEM_MOD_SPELL_HEALING_DONE,
    ['ITEM_MOD_HIT_SPELL_RATING_SHORT'] = _G.ITEM_MOD_HIT_SPELL_RATING,
    ['ITEM_MOD_CRIT_SPELL_RATING_SHORT'] = _G.ITEM_MOD_CRIT_SPELL_RATING,

    ['ITEM_MOD_RANGED_ATTACK_POWER_SHORT'] = _G.ITEM_MOD_RANGED_ATTACK_POWER,
    ['ITEM_MOD_DEFENSE_SKILL_RATING_SHORT'] = _G.ITEM_MOD_DEFENSE_SKILL_RATING

    -- Data in GetItemStats
    -- ['ITEM_MOD_DAMAGE_PER_SECOND_SHORT'] = _G.DPS_TEMPLATE,
    -- ['ITEM_MOD_SPELL_DAMAGE_DONE'] = { -- CANNOT BE TRUSTED, replaced by parsing STAT_SPELLDAMAGE
    --   _G.ITEM_MOD_SPELL_POWER, _G.ITEM_MOD_SPELL_DAMAGE_DONE
    -- },

    -- Wrong global variable for text, unable to find corresponding easily
    -- ['ITEM_MOD_HIT_RATING_SHORT'] = _G.ITEM_MOD_HIT_RATING,
    -- ['ITEM_MOD_CRIT_RATING_SHORT'] = _G.ITEM_MOD_CRIT_RATING,
    -- ['ITEM_MOD_DODGE_RATING_SHORT'] = _G.ITEM_MOD_DODGE_RATING,
    -- ['ITEM_MOD_PARRY_RATING_SHORT'] = _G.ITEM_MOD_PARRY_RATING
    -- ['ITEM_MOD_ATTACK_POWER_SHORT'] = _G.ITEM_MOD_ATTACK_POWER,
}

if addon.game == "CATA" then
    KEY_TO_TEXT['ITEM_MOD_MASTERY_RATING_SHORT'] = _G.ITEM_MOD_MASTERY_RATING

    KEY_TO_TEXT['ITEM_MOD_HIT_RANGED_RATING_SHORT'] = _G.ITEM_MOD_HIT_RANGED_RATING

    KEY_TO_TEXT['ITEM_MOD_CRIT_RANGED_RATING_SHORT'] = _G.ITEM_MOD_CRIT_RANGED_RATING
    KEY_TO_TEXT['ITEM_MOD_SPELL_PENETRATION_SHORT'] = _G.ITEM_MOD_SPELL_PENETRATION

    KEY_TO_TEXT['ITEM_MOD_HEALTH_REGEN_SHORT'] = _G.ITEM_MOD_HEALTH_REGEN
    KEY_TO_TEXT['ITEM_MOD_BLOCK_RATING_SHORT'] = _G.ITEM_MOD_BLOCK_RATING
    KEY_TO_TEXT['ITEM_MOD_RESILIENCE_RATING_SHORT'] = _G.ITEM_MOD_RESILIENCE_RATING
end

-- Keys only obtained from tooltip text parsing
-- Explicitly set regex
local OUT_OF_BAND_KEYS = {
    ['ITEM_MOD_CR_SPEED_SHORT'] = _G.ITEM_MOD_CR_SPEED_SHORT .. "%s+(%d+%.%d+)",
    ['ITEM_MOD_CRIT_RATING_SHORT'] = "%s+Improves your chance to get a critical strike by (%d+)%%.",
    ['ITEM_MOD_HIT_RATING_SHORT'] = "%s+Improves your chance to hit by (%d+)%%.",
    ['ITEM_MOD_DODGE_RATING_SHORT'] = "%s+Increases your chance to dodge an attack by (%d+)%%.",
    ['ITEM_MOD_PARRY_RATING_SHORT'] = "%s+Increases your chance to parry an attack by (%d+)%%.",
    ['ITEM_MOD_ATTACK_POWER_SHORT'] = "%s+%+(%d+)%s+" .. ITEM_MOD_ATTACK_POWER_SHORT,

    -- Stats cannot be trusted, explicitly parse
    -- Overrides ITEM_MOD_SPELL_DAMAGE_DONE built-in
    ['STAT_SPELLDAMAGE'] = {_G.ITEM_MOD_SPELL_POWER, _G.ITEM_MOD_SPELL_DAMAGE_DONE}
}

local WEAPON_SLOT_MAP = {
    ['2H'] = {['Slot'] = {["INVTYPE_2HWEAPON"] = _G.INVSLOT_MAINHAND}},
    ['MH'] = {['Slot'] = {["INVTYPE_WEAPON"] = _G.INVSLOT_MAINHAND, ["INVTYPE_WEAPONMAINHAND"] = _G.INVSLOT_MAINHAND}},
    ['OH'] = {['Slot'] = {["INVTYPE_WEAPON"] = _G.INVSLOT_OFFHAND, ["INVTYPE_WEAPONOFFHAND"] = _G.INVSLOT_OFFHAND}},
    ['RANGED'] = {
        ["Slot"] = {
            ["INVTYPE_THROWN"] = _G.INVSLOT_RANGED,
            ["INVTYPE_RANGED"] = _G.INVSLOT_RANGED,
            ["INVTYPE_RANGEDRIGHT"] = _G.INVSLOT_RANGED
        }
    }
}

-- Used for dpsWeights post-processing
local SPEED_SUFFIX_SLOT_MAP = {
    ['2H'] = _G.INVSLOT_MAINHAND,
    ['MH'] = _G.INVSLOT_MAINHAND,
    ['OH'] = _G.INVSLOT_OFFHAND,
    ['RANGED'] = _G.INVSLOT_RANGED
}

local SPEED_SUFFIX_NAME_MAP = {
    ['2H'] = _G.INVTYPE_2HWEAPON,
    ['MH'] = _G.INVTYPE_WEAPONMAINHAND,
    ['OH'] = _G.INVTYPE_WEAPONOFFHAND,
    ['RANGED'] = _G.INVTYPE_RANGED
}

-- Turn GSheet suffix
local SPELL_KIND_MAP = {
    -- SPELL_SCHOOL1_NAME = "STAT_SPELLDAMAGE_HOLY",
    [SPELL_SCHOOL2_NAME] = "STAT_SPELLDAMAGE_FIRE",
    [SPELL_SCHOOL3_NAME] = "STAT_SPELLDAMAGE_NATURE",
    [SPELL_SCHOOL4_NAME] = "STAT_SPELLDAMAGE_FROST",
    [SPELL_SCHOOL5_NAME] = "STAT_SPELLDAMAGE_SHADOW",
    [SPELL_SCHOOL6_NAME] = "STAT_SPELLDAMAGE_ARCANE"
}

local SPELL_KIND_MATCH = "Increases damage done by (%a+) spells and effects by up to (%d+)."

if locale == 'frFR' then
    SPELL_KIND_MATCH = "Augmente les dégâts infligés par les sorts et effets d?e?'? ?(%a+) de (%d+) au maximum."

    -- Comma decimal delimiter
    OUT_OF_BAND_KEYS['ITEM_MOD_CR_SPEED_SHORT'] = _G.ITEM_MOD_CR_SPEED_SHORT .. "%s+(%d+,%d+)"

    OUT_OF_BAND_KEYS['ITEM_MOD_CRIT_RATING_SHORT'] = "%s+Augmente vos chances d'infliger un coup critique de (%d+)%%."
    OUT_OF_BAND_KEYS['ITEM_MOD_HIT_RATING_SHORT'] = "%s+Augmente vos chances de toucher de (%d+)%%."
    OUT_OF_BAND_KEYS['ITEM_MOD_DODGE_RATING_SHORT'] = "%s+Augmente vos chances d'esquiver une attaque de (%d+)%%."
    OUT_OF_BAND_KEYS['ITEM_MOD_PARRY_RATING_SHORT'] = "%s+Augmente vos chances de parer une attaque de (%d+)%%."
end

local SPEC_MAP = {
    ["WARRIOR"] = {[1] = "Arms", [2] = "Fury", [3] = "Protection"},
    ["PALADIN"] = {[1] = "Holy", [2] = "Protection", [3] = "Retribution"},
    ["HUNTER"] = {[1] = "Beast Mastery", [2] = "Marksmanship", [3] = "Survival"},
    ["ROGUE"] = {[1] = "Assassination", [2] = "Combat", [3] = "Subtlety"},
    ["PRIEST"] = {[1] = "Discipline", [2] = "Holy", [3] = "Shadow"},
    ["SHAMAN"] = {[1] = "Elemental", [2] = "Enhancement", [3] = "Restoration"},
    ["MAGE"] = {[1] = "Arcane", [2] = "Fire", [3] = "Frost"},
    ["WARLOCK"] = {[1] = "Affliction", [2] = "Demonology", [3] = "Destruction"},
    ["DRUID"] = {[1] = "Balance", [2] = "Feral Combat", [3] = "Restoration"},
    ["DEATHKNIGHT"] = {[1] = "Blood", [2] = "Frost", [3] = "Unholy"}
}

-- Before the player spends a talent point, pairs()/next() made the selected
-- weight set effectively random. These are practical leveling/speedrun defaults
-- and are only used until talent points or a manual selection provide a choice.
local DEFAULT_LEVELING_SPEC = {
    WARRIOR = "Arms", PALADIN = "Retribution", HUNTER = "Beast Mastery",
    ROGUE = "Combat", PRIEST = "Shadow", DEATHKNIGHT = "Unholy",
    SHAMAN = "Enhancement", MAGE = "Frost", WARLOCK = "Affliction",
    DRUID = "Feral Combat"
}

-- Setup reverse lookup in session.weaponSlotToWeightKey
for weaponKey, d in pairs(WEAPON_SLOT_MAP) do
    if not d.Slot then
        addon.error("Incomplete WEAPON_SLOT_MAP slot data for", weaponKey)
        return
    end

    for itemEquipLoc, _ in pairs(d.Slot) do
        if not session.weaponSlotToWeightKey[itemEquipLoc] then session.weaponSlotToWeightKey[itemEquipLoc] = {} end

        -- ['INVTYPE_WEAPON'] = { "MH", "OH" }
        tinsert(session.weaponSlotToWeightKey[itemEquipLoc], weaponKey)
    end
end

local function regexify(input)
    -- Replace '%s' with '(%d+)' to match numbers
    -- Remove leading control characters on stats
    return input:gsub("%%[ds]", "(%%d%+)"):gsub("^%%c", '')
end

-- Maps regex global string with stat rating key
-- Turn descriptive text into number friendly regexes
local function KeyToRegex(keyString)
    if session.statsRegexes[keyString] then return session.statsRegexes[keyString] end

    local regex = KEY_TO_TEXT[keyString]
    -- Return nil for keys without mappings
    if not regex then return end

    if type(regex) == "table" then
        for i, _ in ipairs(regex) do regex[i] = regexify(regex[i]) end
    else
        regex = regexify(regex)
    end

    session.statsRegexes[keyString] = regex

    return regex
end

local function prettyPrintRatio(ratio)
    if not ratio then return "NaN" end

    local percentage

    if ratio == 1 then
        return '100%'
    elseif ratio > 0 then
        percentage = ((ratio * 100) - 100)
    elseif ratio == 0 then
        return '0%'
    else -- < 0
        percentage = (ratio * 100)
    end

    return fmt("%.2f%%", percentage)
end

local function IsWeaponSlot(itemEquipLoc)
    return itemEquipLoc == 'INVTYPE_WEAPON' or itemEquipLoc == 'INVTYPE_RANGED' or itemEquipLoc == 'INVTYPE_2HWEAPON' or
               itemEquipLoc == 'INVTYPE_WEAPONMAINHAND' or itemEquipLoc == 'INVTYPE_WEAPONOFFHAND' or itemEquipLoc ==
               'INVTYPE_THROWN' or itemEquipLoc == 'INVTYPE_RANGEDRIGHT'
end

local function IsMeleeSlot(itemEquipLoc)
    return itemEquipLoc == 'INVTYPE_WEAPON' or itemEquipLoc == 'INVTYPE_2HWEAPON' or itemEquipLoc ==
               'INVTYPE_WEAPONMAINHAND' or itemEquipLoc == 'INVTYPE_WEAPONOFFHAND'
end

local function enableTotalEPLines(itemData, lines)
    if itemData.dpsWeights then -- IsWeaponSlot equivalent
        for suffix, data in pairs(itemData.dpsWeights) do
            tinsert(lines, fmt("  Total EP (%s): %.2f", SPEED_SUFFIX_NAME_MAP[suffix], data.totalWeight))
        end
    else -- Armor
        tinsert(lines, fmt("  Total EP: %.2f", itemData.totalWeight))
    end
end

local function AddUnavailableComparisonLine(tooltip, message)
    if not (tooltip and message) then return end
    tooltip:AddLine(fmt("%s - %s", addon.title, _G.ITEM_UPGRADE))
    tooltip:AddLine(message, 1, 0.35, 0.35, true)
    tooltip:Show()
end

local function ExplainUnavailableComparison(itemLink, itemData)
    local _, _, _, _, minimumLevel, _, itemSubType, _, itemEquipLoc =
        GetItemInfo(itemLink)
    minimumLevel = tonumber(minimumLevel) or 0
    local playerLevel = tonumber(UnitLevel("player")) or 0

    if minimumLevel > playerLevel then
        return fmt(L("Requires level %d; EP will be compared once it can be equipped."),
                   minimumLevel)
    end

    if itemData and itemData.unusable then
        if itemData.proficiencyUnknown then
            return L("Weapon proficiency could not be verified; this item is kept safe but is not scored.")
        end
        if IsWeaponSlot(itemEquipLoc or itemData.itemEquipLoc) then
            return fmt(L("%s proficiency is not trained; this weapon is kept safe but is not scored."),
                       itemSubType or L("Required weapon"))
        end
        return L("This item cannot currently be equipped, so it is not scored.")
    end

    if IsWeaponSlot(itemEquipLoc) then
        return L("EP comparison is waiting for complete weapon data.")
    end
end

local function TooltipSetItem(tooltip, ...)
    if not addon.settings.profile.enableItemUpgrades or
        not addon.settings.profile.enableTips or
        addon.settings.profile.disableUpgradeTooltip then return end

    local _, itemLink = tooltip:GetItem()
    if not itemLink then return end
    -- print("TooltipSetItem", tooltip:GetName(), itemLink)

    local clientUsable
    if addon.gameVersion == 30300 and tooltip.GetOwner then
        local owner = tooltip:GetOwner()
        local choice = owner and owner.type == "choice" and owner.GetID and
                           owner:GetID()
        if choice and choice > 0 and choice <= GetNumQuestChoices() then
            local choiceLink = GetQuestItemLink("choice", choice)
            if choiceLink == itemLink then
                clientUsable = select(5, GetQuestItemInfo("choice", choice))
            end
        end
    end

    local itemData = addon.itemUpgrades:GetItemData(itemLink, tooltip,
                                                     clientUsable)
    if not (itemData and itemData.totalWeight) then
        AddUnavailableComparisonLine(
            tooltip, ExplainUnavailableComparison(itemLink, itemData))
        return
    end

    local lines = {}
    -- Exclude addon text when looking at an equipped item
    --  Unless enableTotalEP
    if IsEquippedItem(itemLink) then
        if addon.settings.profile.enableTotalEP then
            enableTotalEPLines(itemData, lines)

            if #lines > 0 then
                tooltip:AddLine(fmt("%s - %s", addon.title, _G.ITEM_UPGRADE))

                for _, line in ipairs(lines) do tooltip:AddLine(line) end
            end
        end

        return
    end

    local statComparisons, comparisonReason, comparisonState =
        addon.itemUpgrades:CompareItemWeight(itemLink, tooltip, true,
                                             clientUsable)

    -- Effectively only used when an item downgrade
    -- TODO when weapons have stats, this may be a problem
    if not statComparisons or next(statComparisons) == nil then
        if addon.settings.profile.enableTotalEP then
            enableTotalEPLines(itemData, lines)

            if #lines > 0 then
                tooltip:AddLine(fmt("%s - %s SC", addon.title, _G.ITEM_UPGRADE))

                for _, line in ipairs(lines) do tooltip:AddLine(line) end
            end
        end

        if #lines == 0 and IsWeaponSlot(itemData.itemEquipLoc) and
            (comparisonReason == "query failed" or
                comparisonState == "unknown") then
            AddUnavailableComparisonLine(
                tooltip, L("EP comparison is waiting for complete weapon data."))
        end

        return
    end

    local lineText

    for _, statsData in ipairs(statComparisons) do
        lineText = nil

        if IsWeaponSlot(statsData.itemEquipLoc) then
            local slotName
            if itemData.itemEquipLoc == "INVTYPE_2HWEAPON" then
                slotName = _G.INVTYPE_2HWEAPON
            elseif itemData.itemEquipLoc == "INVTYPE_RANGED" or
                itemData.itemEquipLoc == "INVTYPE_RANGEDRIGHT" or
                itemData.itemEquipLoc == "INVTYPE_THROWN" then
                slotName = _G.INVTYPE_RANGED
            elseif statsData.SlotCompared == _G.INVSLOT_OFFHAND then
                slotName = _G.INVTYPE_WEAPONOFFHAND
            else
                slotName = _G.INVTYPE_WEAPONMAINHAND
            end

            if statsData.ItemLink == _G.EMPTY and statsData.ComparedWeight then
                lineText = fmt("  %s (%s): +%.2f EP", _G.EMPTY, slotName,
                               statsData.ComparedWeight)
            elseif statsData.Ratio and statsData.EquippedWeight and
                statsData.ComparedWeight then
                lineText = fmt("  %s (%s): %s / +%.2f EP", statsData.ItemLink,
                               slotName, prettyPrintRatio(statsData.Ratio),
                               statsData.ComparedWeight - statsData.EquippedWeight)
            elseif (statsData.ComparisonState == "downgrade" or
                statsData.ComparisonState == "equal") and
                statsData.EquippedWeight and statsData.ComparedWeight then
                local difference = statsData.ComparedWeight -
                                       statsData.EquippedWeight
                local result = statsData.ComparisonState == "equal" and
                                   L("Equal") or fmt("%+.2f EP", difference)
                lineText = fmt("  %s (%s): %s", statsData.ItemLink,
                               slotName, result)
            end

            if lineText and statsData.debug and addon.settings.profile.debug then
                lineText = fmt("%s (%s)", lineText, statsData.debug)
            end
            if lineText then tinsert(lines, lineText) end
        else
            if statsData['Ratio'] then
                lineText = fmt("  %s: %s / +%.2f EP", statsData['ItemLink'] or _G.UNKNOWN,
                               prettyPrintRatio(statsData['Ratio']), statsData.WeightIncrease)
            elseif statsData['ItemLink'] == _G.EMPTY then
                lineText = fmt("  %s: +%s EP", _G.EMPTY, statsData.WeightIncrease)
            elseif (statsData.ComparisonState == "downgrade" or
                statsData.ComparisonState == "equal") and
                statsData.EquippedWeight and statsData.ComparedWeight then
                local difference = statsData.ComparedWeight -
                                       statsData.EquippedWeight
                local result = statsData.ComparisonState == "equal" and
                                   L("Equal") or fmt("%+.2f EP", difference)
                lineText = fmt("  %s: %s", statsData.ItemLink or _G.UNKNOWN,
                               result)
            end

            if lineText then tinsert(lines, lineText) end
        end
    end

    if #lines > 0 then
        tooltip:AddLine(fmt("%s - %s", addon.title, _G.ITEM_UPGRADE))

        if addon.settings.profile.enableTotalEP then enableTotalEPLines(itemData, lines) end

        for _, line in ipairs(lines) do tooltip:AddLine(line) end
    end

    tooltip:Show()
end

function addon.itemUpgrades:UpdateSlotMap()
    local _, currentClass = UnitClass("player")
    currentClass = currentClass or addon.player.class
    local classData = CLASS_MAP[currentClass] or CLASS_MAP.All
    local function BuildResolvedMap(category)
        local result = {}
        for k, v in pairs(CLASS_MAP.All[category] or {}) do result[k] = v end
        for k, v in pairs(classData[category] or {}) do
            if type(v) == "function" then v = v() end
            result[k] = v
        end
        return result
    end

    -- Never mutate CLASS_MAP.All. Apart from leaking one class into another on
    -- clients which retain the Lua VM across character switches, the old code
    -- also left level-gated mail/plate results stale after level 40.
    session.equippableSlots = BuildResolvedMap("Slot")
    session.equippableArmor = BuildResolvedMap("ArmorType")
    session.equippableWeapons = BuildResolvedMap("WeaponType")
    session.wearabilityLevel = UnitLevel("player")
    session.wearabilityClass = currentClass
end

function addon.itemUpgrades:Setup()
    -- Toggle functionality off
    if not addon.settings.profile.enableItemUpgrades or not addon.settings.profile.enableTips then
        if session.upgradePopupOpen then
            -- Setup may hide the prompt because the feature was disabled. Do
            -- not mistake that programmatic hide for the player's Equip click.
            session.pendingUpgradeEquip = nil
            _G.StaticPopup_Hide("RXPItemUpgradeFound")
        end
        if self.AH and self.AH.Setup then self.AH:Setup() end
        return
    end

    self:UpdateSlotMap()
    RefreshWeaponProficiencies()
    if not next(session.equippedHandLinks) then SnapshotHandEquipment() end
    if not self:LoadStatWeights() then return end
    if not self:ActivateSpecWeights() then return end
    session.itemCache = {}

    -- Only register events and hookScript once
    if session.isInitialized then
        wipe(session.promptedUpgrades)
        QueueUpgradeScan(0.25)
        if self.AH and self.AH.Setup then self.AH:Setup() end
        return
    end

    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    self:RegisterEvent("SKILL_LINES_CHANGED", "WEAPON_PROFICIENCY_CHANGED")
    self:RegisterEvent("SPELLS_CHANGED", "WEAPON_PROFICIENCY_CHANGED")
    self:RegisterEvent("LEARNED_SPELL_IN_TAB", "WEAPON_PROFICIENCY_CHANGED")
    -- BAG_UPDATE_DELAYED was added after the original 3.3.5 client. Some
    -- private cores expose it, others do not, and item data can arrive after
    -- the one bag event raised by looting. Always listen to the stock legacy
    -- events and use the delayed event as an additional signal when available.
    if addon.gameVersion == 30300 then
        self:RegisterEvent("BAG_UPDATE", "UPGRADE_INVENTORY_CHANGED")
        if C_EventUtils and C_EventUtils.IsEventValid and
            C_EventUtils.IsEventValid("BAG_UPDATE_DELAYED") then
            self:RegisterEvent("BAG_UPDATE_DELAYED", "UPGRADE_INVENTORY_CHANGED")
        end
        if C_EventUtils and C_EventUtils.IsEventValid and
            C_EventUtils.IsEventValid("ITEM_PUSH") then
            self:RegisterEvent("ITEM_PUSH", "UPGRADE_INVENTORY_CHANGED")
        end
        self:RegisterEvent("LOOT_CLOSED", "UPGRADE_INVENTORY_CHANGED")
    else
        self:RegisterEvent("BAG_UPDATE_DELAYED", "UPGRADE_INVENTORY_CHANGED")
    end
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "UPGRADE_EQUIPMENT_CHANGED")
    self:RegisterEvent("GET_ITEM_INFO_RECEIVED", "UPGRADE_ITEM_INFO_RECEIVED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UPGRADE_INVENTORY_CHANGED")

    local lookup
    -- Only load stats coming from GSheet
    for key, _ in pairs(session.activeStatWeights) do
        -- print("Checking", key)
        lookup = KeyToRegex(key)
        if lookup then
            -- print("Match loaded", lookup)
            session.statsRegexes[key] = lookup
        end

    end

    -- Add out-of-band (aka hackery) stat parsing
    for key, regex in pairs(OUT_OF_BAND_KEYS) do session.statsRegexes[key] = regex end

    -- Inventory
    if GameTooltip then GameTooltip:HookScript("OnTooltipSetItem", TooltipSetItem) end

    -- Vendor?
    if ItemRefTooltip then ItemRefTooltip:HookScript("OnTooltipSetItem", TooltipSetItem) end

    -- Enable AH
    if ShoppingTooltip1 then ShoppingTooltip1:HookScript("OnTooltipSetItem", TooltipSetItem) end
    -- ShoppingTooltip2:HookScript("OnTooltipSetItem", TooltipSetItem)

    session.isInitialized = true

    self.AH:Setup()
    QueueUpgradeScan(1)
end

-- Reset cache on levelup
function addon.itemUpgrades:PLAYER_LEVEL_UP()
    if not addon.settings.profile.enableItemUpgrades then return end
    C_Timer.After(0.25, function()
        addon.itemUpgrades:Setup()
        QueueUpgradeScan(0.25)
    end)
end

function addon.itemUpgrades:PLAYER_TALENT_UPDATE()
    if addon.settings.profile.enableItemUpgrades then
        self:Setup()
        wipe(session.promptedUpgrades)
        QueueUpgradeScan(0.25)
    end
end

function addon.itemUpgrades:ACTIVE_TALENT_GROUP_CHANGED()
    if addon.settings.profile.enableItemUpgrades then
        self:Setup()
        wipe(session.promptedUpgrades)
        QueueUpgradeScan(0.25)
    end
end

function addon.itemUpgrades:WEAPON_PROFICIENCY_CHANGED()
    if not addon.settings.profile.enableItemUpgrades then return end
    -- Re-resolve slot functions as well as subtype proficiencies. This matters
    -- for Dual Wield (including the WotLK Shaman talent), which changes whether
    -- an off-hand-only weapon is usable without changing the item itself.
    self:UpdateSlotMap()
    RefreshWeaponProficiencies()
    -- Previously rejected items must be reconsidered as soon as the player
    -- trains a new weapon skill.
    session.itemCache = {}
    wipe(session.promptedUpgrades)
    if addon.inventoryManager and addon.inventoryManager.UpdateAllBags then
        addon.inventoryManager.UpdateAllBags()
    end
    addon:SendEvent("RXP_JUNK")
    QueueUpgradeScan(0.25)
end

function addon.itemUpgrades:LoadStatWeights()
    if not addon.statWeights then return end

    local newWeights = {}

    local guideMode = addon.settings.profile.hardcore and "HARDCORE" or "SPEEDRUN"

    -- TODO chance this doesn't evaluate properly on PLAYER_LEVEL_UP event
    local playerLevel = UnitLevel("player")

    for dbTitle, data in pairs(addon.statWeights) do
        if data.MAX_LEVEL <= data.MIN_LEVEL then
            addon.comms.PrettyPrint("Invalid min (%s) and max %s level for for %s", data.MIN_LEVEL, data.MAX_LEVEL,
                                    dbTitle)
        end

        if strupper(data.Class) == addon.player.class and strupper(data.Kind) == guideMode
            and playerLevel >= data.MIN_LEVEL then
            -- Pick, per spec, the highest bracket the player qualifies for. Within
            -- a version this is just the in-range bracket, but it also lets a level
            -- above the top bracket (e.g. WOTLK 70-80 reusing the TBC weights, which
            -- cap at 70) fall back to that top bracket instead of getting nothing.
            local specKey = (data.Spec or data.Class):gsub("^%s+", ""):gsub("%s+$", "")
            if addon.game == "WOTLK" and specKey == "Feral" then
                specKey = "Feral Combat"
            end

            local specKeys = {specKey}
            -- The original speedrun sheet used class-wide Hunter/Rogue sets.
            -- Apply those leveling brackets to every Wrath talent tree instead
            -- of abandoning them for a generic level-80 fallback.
            if addon.game == "WOTLK" and not data.Spec and data.Class == "Hunter" then
                specKeys = {"Beast Mastery", "Marksmanship", "Survival"}
            elseif addon.game == "WOTLK" and not data.Spec and data.Class == "Rogue" then
                specKeys = {"Assassination", "Combat", "Subtlety"}
            end

            for _, resolvedSpec in ipairs(specKeys) do
                local existing = newWeights[resolvedSpec]
                if not existing or data.MIN_LEVEL > existing.MIN_LEVEL then
                    newWeights[resolvedSpec] = data
                end
            end
        end
    end

    for spec, data in pairs(newWeights) do
        for kind, value in pairs(data) do
            -- Optimization: remove all 0 stats

            if tonumber(value) and value == 0 then
                -- print("Removed", spec .. ':' .. kind)
                data[kind] = nil
            end
        end

        -- SoD
        if addon.player.season == 3 and data['ITEM_MOD_SPIRIT_SHORT'] then
            if addon.player.class == "PRIEST" then
                data['ITEM_MOD_SPIRIT_SHORT'] = data['ITEM_MOD_SPIRIT_SHORT'] * 0.75
            else
                data['ITEM_MOD_SPIRIT_SHORT'] = data['ITEM_MOD_SPIRIT_SHORT'] * 0.5
            end
        end
    end

    session.specWeights = newWeights

    return session.specWeights ~= nil
end

local function getSpec()
    -- Classes with className as spec only have one (Rogue, Warrior), use that
    if session.specWeights[addon.player.class] then
        return addon.player.class, "class"
    end

    if addon.settings.profile.enableTalentGuides and addon.talents and
        addon.talents.GetCurrentGuide then
        local talentGuide = addon.talents:GetCurrentGuide()
        local plannedSpec = talentGuide and talentGuide.primaryTab and
                                SPEC_MAP[addon.player.class] and
                                SPEC_MAP[addon.player.class][talentGuide.primaryTab]
        if plannedSpec and session.specWeights[plannedSpec] then
            return plannedSpec, "talent guide"
        end
    end

    -- if addon.settings.profile.enableTalentGuides then
    --     -- Difficult/impossible to map talent guide
    --     -- RXPCData.activeTalentGuide == "Rogue - Hardcore Rogue 10-60"
    -- end

    -- Calculate most likely spec
    local pointsSpent
    local guessedSpec = {index = nil, count = 0}

    for tabIndex = 1, _G.GetNumTalentTabs(false) do
        -- id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked
        _, _, _, _, pointsSpent = _G.GetTalentTabInfo(tabIndex)

        if pointsSpent > guessedSpec.count then
            guessedSpec.index = tabIndex
            guessedSpec.count = pointsSpent
        end
    end

    local specName
    -- No tabs found with > 0 talents, likely fresh character
    if guessedSpec.index then
        specName = SPEC_MAP[addon.player.class][guessedSpec.index]

        addon.comms.PrettyDebug("ItemUpgrades, spec guessed as %s", specName)
    end

    -- If calculated spec has no weights, then class is unsupported
    -- Likely exited earlier with Rogue/Warrior in this scenario then
    if session.specWeights[specName] then return specName, "active talents" end

    -- No talents yet: select a deterministic leveling-oriented set.
    specName = DEFAULT_LEVELING_SPEC[addon.player.class]
    if not session.specWeights[specName] then specName, _ = next(session.specWeights) end

    -- Returns first specName, or nil
    return specName, "leveling default"
end

-- Always run after LoadStatWeights
function addon.itemUpgrades:ActivateSpecWeights()
    if not session.specWeights then return end

    local spec, source = getSpec()
    local selected = addon.settings.profile.itemUpgradeSpec
    local manual = addon.settings.profile.itemUpgradeSpecManual
    -- Existing profiles predate the explicit marker. Preserve a value which
    -- differs from the automatic choice as a manual user selection.
    if manual == nil and selected and selected ~= spec and
        session.specWeights[selected] then
        manual = true
        addon.settings.profile.itemUpgradeSpecManual = true
    end
    if manual and selected and session.specWeights[selected] then
        spec, source = selected, "manual setting"
    else
        addon.settings.profile.itemUpgradeSpecManual = false
        addon.settings.profile.itemUpgradeSpec = spec
    end

    if not addon.settings.profile.itemUpgradeSpec then return end

    addon.comms.PrettyDebug("Activating spec weights for %s", addon.settings.profile.itemUpgradeSpec)

    session.activeStatWeights = session.specWeights[addon.settings.profile.itemUpgradeSpec]
    session.activeWeightSource = source

    if not session.activeStatWeights then return end

    session.activeStatWeights.extraWeight = ITEM_WEIGHT_ADDITIONS[addon.player.class] or {}

    return session.activeStatWeights ~= nil
end

function addon.itemUpgrades:GetSpecWeights()
    local options = {}
    for k, _ in pairs(session.specWeights) do options[k] = k end

    -- No current support for class, spec, etc
    if next(options) == nil then return end

    return options
end

-- ITEM_SET_NAME = "%s (%d/%d)";
local SET_BONUS_MATCH = "(%w+)%s+%((%d+)/(%d+)%)"

local function GetTooltipLines(tooltip, baseItemData)
    local textLines = {}
    -- print("GetTooltipLines, tooltip", tooltip:GetName(), tooltip:NumLines())

    -- Something went wrong
    if not tooltip or not tooltip.NumLines or tooltip:NumLines() == 0 then return end

    local rText
    local setMatch = {}

    -- 3.3.5 does not guarantee GetRegions() order. Read the numbered tooltip
    -- font strings first so damage, speed and stat lines stay in display order.
    local tooltipName = tooltip:GetName()
    for lineIndex = 1, tooltip:NumLines() do
        local left = tooltipName and _G[tooltipName .. "TextLeft" .. lineIndex]
        local right = tooltipName and _G[tooltipName .. "TextRight" .. lineIndex]
        for _, fontString in ipairs({left, right}) do
            rText = fontString and fontString:GetText()
            if rText and rText ~= "" then
                if baseItemData and baseItemData.setID then
                    setMatch = {smatch(rText, SET_BONUS_MATCH)}
                    if setMatch[1] and setMatch[2] and setMatch[3] then
                        return textLines
                    end
                end
                tinsert(textLines, rText)
            end
        end
    end

    -- Fallback for an anonymous/custom tooltip.
    if #textLines == 0 then
        for _, region in ipairs({tooltip:GetRegions()}) do
            if region:IsObjectType("FontString") and region:GetText() then
                tinsert(textLines, region:GetText())
            end
        end
    end
    return textLines
end

local LEGACY_STAT_TEMPLATES = {
    {"ITEM_MOD_STRENGTH_SHORT", "ITEM_MOD_STRENGTH"},
    {"ITEM_MOD_AGILITY_SHORT", "ITEM_MOD_AGILITY"},
    {"ITEM_MOD_INTELLECT_SHORT", "ITEM_MOD_INTELLECT"},
    {"ITEM_MOD_STAMINA_SHORT", "ITEM_MOD_STAMINA"},
    {"ITEM_MOD_SPIRIT_SHORT", "ITEM_MOD_SPIRIT"},
    {"RESISTANCE0_NAME", "ARMOR_TEMPLATE"},
    {"ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT", "ITEM_MOD_ARMOR_PENETRATION_RATING"},
    {"ITEM_MOD_ATTACK_POWER_SHORT", "ITEM_MOD_ATTACK_POWER"},
    {"ITEM_MOD_BLOCK_RATING_SHORT", "ITEM_MOD_BLOCK_RATING"},
    {"ITEM_MOD_BLOCK_VALUE_SHORT", "ITEM_MOD_BLOCK_VALUE"},
    {"ITEM_MOD_CRIT_RATING_SHORT", "ITEM_MOD_CRIT_RATING"},
    {"ITEM_MOD_DEFENSE_SKILL_RATING_SHORT", "ITEM_MOD_DEFENSE_SKILL_RATING"},
    {"ITEM_MOD_DODGE_RATING_SHORT", "ITEM_MOD_DODGE_RATING"},
    {"ITEM_MOD_EXPERTISE_RATING_SHORT", "ITEM_MOD_EXPERTISE_RATING"},
    {"ITEM_MOD_FERAL_ATTACK_POWER_SHORT", "ITEM_MOD_FERAL_ATTACK_POWER"},
    {"ITEM_MOD_HASTE_RATING_SHORT", "ITEM_MOD_HASTE_RATING"},
    {"ITEM_MOD_HEALTH_REGEN_SHORT", "ITEM_MOD_HEALTH_REGEN"},
    {"ITEM_MOD_HIT_RATING_SHORT", "ITEM_MOD_HIT_RATING"},
    {"ITEM_MOD_POWER_REGEN0_SHORT", "ITEM_MOD_MANA_REGENERATION"},
    {"ITEM_MOD_PARRY_RATING_SHORT", "ITEM_MOD_PARRY_RATING"},
    {"ITEM_MOD_RANGED_ATTACK_POWER_SHORT", "ITEM_MOD_RANGED_ATTACK_POWER"},
    {"ITEM_MOD_SPELL_PENETRATION_SHORT", "ITEM_MOD_SPELL_PENETRATION"},
    {"ITEM_MOD_SPELL_POWER", "ITEM_MOD_SPELL_POWER"},
    {"ITEM_MOD_DAMAGE_PER_SECOND_SHORT", "DPS_TEMPLATE"},
}

local legacyStatPatterns
local function BuildLegacyStatPatterns()
    if legacyStatPatterns then return legacyStatPatterns end
    legacyStatPatterns = {}
    for _, definition in ipairs(LEGACY_STAT_TEMPLATES) do
        local key, globalName = definition[1], definition[2]
        for _, template in ipairs({_G[globalName], _G[globalName .. "_SHORT"]}) do
            if type(template) == "string" and template:find("%%") then
                local pattern = template:gsub("1%$", ""):gsub("2%$", ""):gsub("3%$", ""):gsub("4%$", "")
                pattern = pattern:gsub("%%%.%d+f", "\002"):gsub("%%f", "\002")
                pattern = pattern:gsub("%%", "\001")
                pattern = pattern:gsub("([%(%)%.%+%-%*%?%[%]%^%$])", "%%%1")
                pattern = pattern:gsub("\001d", "([%d]+)")
                pattern = pattern:gsub("\001c", "([%+%-]?)")
                pattern = pattern:gsub("\001s", "([%d%.,]+)")
                pattern = pattern:gsub("\002", "([%d%.,]+)")
                tinsert(legacyStatPatterns, {key = key, pattern = "^%s*" .. strlower(pattern) .. "%s*$"})
            end
        end
    end
    return legacyStatPatterns
end

local function AddParsedStat(stats, key, value, sign)
    value = type(value) == "string" and tonumber((value:gsub(",", ".", 1))) or tonumber(value)
    if not (key and value) then return end
    if sign == "-" then value = -value end
    stats[key] = (stats[key] or 0) + value
end

local function ParseLegacyNumber(value)
    if type(value) ~= "string" then return tonumber(value) end
    return tonumber((value:gsub(",", ".", 1)))
end

local function ParseLegacyTooltipStats(stats, lines)
    local damageLow, damageHigh, weaponSpeed
    local providedStats = {}
    for key in pairs(stats) do providedStats[key] = true end
    local speedLabel = strlower(_G.WEAPON_SPEED or "Speed")
    speedLabel = speedLabel:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    for _, rawLine in ipairs(lines or {}) do
        local line = strlower(rawLine:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
        local matchedKeys = {}
        for _, entry in ipairs(BuildLegacyStatPatterns()) do
            if not providedStats[entry.key] and not matchedKeys[entry.key] then
                local first, second = smatch(line, entry.pattern)
                if first then
                    AddParsedStat(stats, entry.key, second or first, second and first or nil)
                    matchedKeys[entry.key] = true
                end
            end
        end

        -- Private 3.3.5 realms commonly use the final Wrath English wording.
        -- These flexible fallbacks cover lines whose format globals are absent.
        local value
        value = smatch(line, "increases spell power by (%d+)")
        if value and not providedStats.ITEM_MOD_SPELL_POWER and
            not matchedKeys.ITEM_MOD_SPELL_POWER then
            AddParsedStat(stats, "ITEM_MOD_SPELL_POWER", value)
        end
        value = smatch(line, "increases attack power by (%d+)")
        if value and not providedStats.ITEM_MOD_ATTACK_POWER_SHORT and
            not matchedKeys.ITEM_MOD_ATTACK_POWER_SHORT and
            not line:find("ranged attack power", 1, true) then
            AddParsedStat(stats, "ITEM_MOD_ATTACK_POWER_SHORT", value)
        end
        value = smatch(line, "increases ranged attack power by (%d+)")
        if value and not providedStats.ITEM_MOD_RANGED_ATTACK_POWER_SHORT and
            not matchedKeys.ITEM_MOD_RANGED_ATTACK_POWER_SHORT then
            AddParsedStat(stats, "ITEM_MOD_RANGED_ATTACK_POWER_SHORT", value)
        end
        value = smatch(line, "restores (%d+) mana per 5 sec")
        if value and not providedStats.ITEM_MOD_POWER_REGEN0_SHORT and
            not matchedKeys.ITEM_MOD_POWER_REGEN0_SHORT then
            AddParsedStat(stats, "ITEM_MOD_POWER_REGEN0_SHORT", value)
        end

        local rating = smatch(line, "rating by (%d+)") or smatch(line, "%+(%d+) [^%.]- rating")
        if rating then
            local ratingKey
            if line:find("critical strike", 1, true) then ratingKey = "ITEM_MOD_CRIT_RATING_SHORT"
            elseif line:find("armor penetration", 1, true) then ratingKey = "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT"
            elseif line:find("expertise", 1, true) then ratingKey = "ITEM_MOD_EXPERTISE_RATING_SHORT"
            elseif line:find("haste", 1, true) then ratingKey = "ITEM_MOD_HASTE_RATING_SHORT"
            elseif line:find("defense", 1, true) then ratingKey = "ITEM_MOD_DEFENSE_SKILL_RATING_SHORT"
            elseif line:find("dodge", 1, true) then ratingKey = "ITEM_MOD_DODGE_RATING_SHORT"
            elseif line:find("parry", 1, true) then ratingKey = "ITEM_MOD_PARRY_RATING_SHORT"
            elseif line:find("block", 1, true) then ratingKey = "ITEM_MOD_BLOCK_RATING_SHORT"
            elseif line:find("hit", 1, true) then ratingKey = "ITEM_MOD_HIT_RATING_SHORT" end
            if ratingKey and not providedStats[ratingKey] and
                not matchedKeys[ratingKey] then
                AddParsedStat(stats, ratingKey, rating)
            end
        end

        -- Damage templates are localized while their leading numeric range is
        -- stable. Do not require the English word "Damage" here.
        if not damageLow then
            local low, high = smatch(
                                  line,
                                  "^%s*([%d%.,]+)%s*%-%s*([%d%.,]+)")
            if not (low and high) then
                low, high = smatch(
                                line,
                                "([%d%.,]+)%s*%-%s*([%d%.,]+)%s+damage")
            end
            if low and high then
                damageLow, damageHigh = ParseLegacyNumber(low),
                                        ParseLegacyNumber(high)
            end
        end
        -- gsub returns both the new string and its replacement count. Parenthesize
        -- the call so Lua passes only the string to tonumber (otherwise the count
        -- becomes tonumber's optional base and can raise "base out of range").
        weaponSpeed = weaponSpeed or tonumber(((smatch(line, speedLabel .. "%s+([%d%.,]+)") or ""):gsub(",", ".")))
    end

    if weaponSpeed and weaponSpeed > 0 then
        if not providedStats.ITEM_MOD_CR_SPEED_SHORT then
            stats.ITEM_MOD_CR_SPEED_SHORT = weaponSpeed
        end
        if not providedStats.ITEM_MOD_DAMAGE_PER_SECOND_SHORT and
            not stats.ITEM_MOD_DAMAGE_PER_SECOND_SHORT and damageLow and damageHigh then
            stats.ITEM_MOD_DAMAGE_PER_SECOND_SHORT = ((damageLow + damageHigh) / 2) / weaponSpeed
        end
    end
end

local function GetComparisonTip()
    if session.comparisonTip then return session.comparisonTip end

    session.comparisonTip = CreateFrame("GameTooltip", "RXPItemUpgradesComparison", nil, "GameTooltipTemplate")
    session.comparisonTip:SetOwner(WorldFrame, "ANCHOR_NONE")
    session.comparisonTip:AddFontStrings(session.comparisonTip:CreateFontString("$parentTextLeft1", nil,
                                                                                "GameTooltipText"),
                                         session.comparisonTip:CreateFontString("$parentTextRight1", nil,
                                                                                 "GameTooltipText"))

    if addon.gameVersion == 30300 then
        -- The legacy GameTooltip money handler anchors its sell-price frame to
        -- "$parentTextLeft<NumLines>". Hidden scanner tooltips do not create a
        -- globally named font string for every C-side tooltip line, so a green
        -- item with a sell price can make that anchor point at a region which
        -- does not exist. Item value already comes from GetItemInfo and is not
        -- parsed from this tooltip; suppressing only this private tooltip's
        -- money display avoids the bad anchor without changing visible tips.
        session.comparisonTip:SetScript("OnTooltipAddMoney", function() end)
    end

    return session.comparisonTip
end

-- 3.3.5a: GetItemInfo does not return the numeric subclass ID that retail exposes
-- (position 13), only a localized name. English names are retained as fallbacks;
-- localized AH categories and proficiency spell names are added below.
local WEAPON_SUBCLASS_BY_NAME = {
    ["One-Handed Axes"] = ItemWeaponSubclass.Axe1H,
    ["Two-Handed Axes"] = ItemWeaponSubclass.Axe2H,
    ["Bows"] = ItemWeaponSubclass.Bows,
    ["Guns"] = ItemWeaponSubclass.Guns,
    ["One-Handed Maces"] = ItemWeaponSubclass.Mace1H,
    ["Two-Handed Maces"] = ItemWeaponSubclass.Mace2H,
    ["Polearms"] = ItemWeaponSubclass.Polearm,
    ["One-Handed Swords"] = ItemWeaponSubclass.Sword1H,
    ["Two-Handed Swords"] = ItemWeaponSubclass.Sword2H,
    ["Staves"] = ItemWeaponSubclass.Staff,
    ["Fist Weapons"] = ItemWeaponSubclass.Unarmed,
    ["Daggers"] = ItemWeaponSubclass.Dagger,
    ["Thrown"] = ItemWeaponSubclass.Thrown,
    ["Crossbows"] = ItemWeaponSubclass.Crossbow,
    ["Wands"] = ItemWeaponSubclass.Wand,
    ["Fishing Poles"] = ItemWeaponSubclass.Fishingpole,
    ["Miscellaneous"] = ItemWeaponSubclass.Generic,
}
local ARMOR_SUBCLASS_BY_NAME = {
    ["Miscellaneous"] = ItemArmorSubclass.Generic,
    ["Cloth"] = ItemArmorSubclass.Cloth,
    ["Leather"] = ItemArmorSubclass.Leather,
    ["Mail"] = ItemArmorSubclass.Mail,
    ["Plate"] = ItemArmorSubclass.Plate,
    ["Shields"] = ItemArmorSubclass.Shield,
    ["Librams"] = ItemArmorSubclass.Libram,
    ["Idols"] = ItemArmorSubclass.Idol,
    ["Totems"] = ItemArmorSubclass.Totem,
    ["Sigils"] = ItemArmorSubclass.Sigil,
}

-- Weapon-proficiency spell IDs are stable across locales.  Their localized
-- names let 3.3.5 map GetItemInfo's localized subtype result without assuming
-- an English client, and IsPlayerSpell tells us whether this character has
-- actually learned the weapon type.
local WEAPON_PROFICIENCY_SPELL = {
    [ItemWeaponSubclass.Axe1H] = 196,
    [ItemWeaponSubclass.Axe2H] = 197,
    [ItemWeaponSubclass.Bows] = 264,
    [ItemWeaponSubclass.Guns] = 266,
    [ItemWeaponSubclass.Mace1H] = 198,
    [ItemWeaponSubclass.Mace2H] = 199,
    [ItemWeaponSubclass.Polearm] = 200,
    [ItemWeaponSubclass.Sword1H] = 201,
    [ItemWeaponSubclass.Sword2H] = 202,
    [ItemWeaponSubclass.Staff] = 227,
    [ItemWeaponSubclass.Unarmed] = 15590,
    [ItemWeaponSubclass.Dagger] = 1180,
    [ItemWeaponSubclass.Thrown] = 2567,
    [ItemWeaponSubclass.Crossbow] = 5011,
    [ItemWeaponSubclass.Wand] = 5009,
}

-- Shield is an armor proficiency rather than a weapon skill.  The 3.3.5
-- quest-reward API can report a shield as "usable" based only on its level,
-- so that flag must not override the character's actual proficiency.
local SHIELD_PROFICIENCY_SPELL = 9116
local ARMOR_PROFICIENCY_SPELL = {
    [ItemArmorSubclass.Mail] = 8737,
    [ItemArmorSubclass.Plate] = 750
}

local function IsKnownProficiencySpell(spellID)
    local checked
    if type(_G.IsPlayerSpell) == "function" then
        checked = true
        if _G.IsPlayerSpell(spellID) then return true end
    end
    if type(_G.IsSpellKnown) == "function" then
        checked = true
        if _G.IsSpellKnown(spellID) then return true end
    end

    -- AzerothCore normally exposes the hidden passive through IsSpellKnown,
    -- but scan the legacy spellbook as a secondary source for private cores
    -- which omit it from that API.
    local wantedName = _G.GetSpellInfo and _G.GetSpellInfo(spellID)
    if wantedName and _G.GetNumSpellTabs and _G.GetSpellTabInfo then
        checked = true
        local bookType = _G.BOOKTYPE_SPELL or "spell"
        for tab = 1, _G.GetNumSpellTabs() do
            local _, _, offset, count = _G.GetSpellTabInfo(tab)
            offset, count = tonumber(offset) or 0, tonumber(count) or 0
            for slot = offset + 1, offset + count do
                local name
                if _G.GetSpellName then
                    name = _G.GetSpellName(slot, bookType)
                elseif _G.GetSpellInfo then
                    name = _G.GetSpellInfo(slot, bookType)
                end
                if name == wantedName then return true end
            end
        end
    end
    return checked and false or nil
end

local subclassMapsBuilt
local function NormalizeSubclassName(name)
    if type(name) ~= "string" then return nil end
    name = name:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
    if name == "" then return nil end
    return strlower(name)
end

function addon.itemUpgrades:GetActiveSpecSource()
    return addon.settings.profile.itemUpgradeSpec, session.activeWeightSource
end

local function AddSubclassName(map, name, id)
    if type(name) ~= "string" or name == "" or type(id) ~= "number" then return end
    map[name] = id
    map[strlower(name)] = id
    local normalized = NormalizeSubclassName(name)
    if normalized then map[normalized] = id end
end

local function LookupSubclassName(map, name)
    if type(name) ~= "string" then return nil end
    return map[name] or map[strlower(name)] or
               map[NormalizeSubclassName(name)]
end

local function ScanLegacyWeaponSkills()
    local learned = {}
    if addon.gameVersion ~= 30300 or not _G.GetNumSkillLines or
        not _G.GetSkillLineInfo then
        return learned, false
    end

    -- GetNumSkillLines follows the Skills window's expanded/collapsed state.
    -- Briefly expand collapsed headers so detection cannot change with that UI
    -- state, then restore every header (and the selected row) before returning.
    local collapsedHeaders = {}
    local selectedSkill = _G.GetSelectedSkill and _G.GetSelectedSkill()
    if _G.ExpandSkillHeader and _G.CollapseSkillHeader then
        local index = 1
        while index <= (tonumber(_G.GetNumSkillLines()) or 0) do
            local _, isHeader, isExpanded = _G.GetSkillLineInfo(index)
            if isHeader and not isExpanded then
                local ok = pcall(_G.ExpandSkillHeader, index)
                if ok then collapsedHeaders[#collapsedHeaders + 1] = index end
            end
            index = index + 1
        end
    end

    local hasWeaponSkillData = false
    local numSkills = tonumber(_G.GetNumSkillLines()) or 0
    for index = 1, numSkills do
        local skillName, isHeader = _G.GetSkillLineInfo(index)
        if skillName and not isHeader then
            local subclassID = LookupSubclassName(WEAPON_SUBCLASS_BY_NAME,
                                                   skillName)
            if subclassID and WEAPON_PROFICIENCY_SPELL[subclassID] and
                subclassID ~= ItemWeaponSubclass.Unarmed then
                learned[subclassID] = true
                hasWeaponSkillData = true
            end
        end
    end

    for index = #collapsedHeaders, 1, -1 do
        pcall(_G.CollapseSkillHeader, collapsedHeaders[index])
    end
    if selectedSkill and _G.SetSelectedSkill then
        pcall(_G.SetSelectedSkill, selectedSkill)
    end
    return learned, hasWeaponSkillData
end

local function AddAuctionSubclasses(classIndex, map, validIDs)
    if addon.gameVersion ~= 30300 or not _G.GetAuctionItemSubClasses then return end
    local values = {pcall(_G.GetAuctionItemSubClasses, classIndex)}
    if not values[1] then return end
    table.remove(values, 1)
    for index, name in ipairs(values) do
        local subclassID = index - 1
        if validIDs[subclassID] then AddSubclassName(map, name, subclassID) end
    end
end

local function BuildLegacySubclassMaps()
    if subclassMapsBuilt then return end
    subclassMapsBuilt = true

    local weaponIDs, armorIDs = {}, {}
    for _, id in pairs(ItemWeaponSubclass) do
        if type(id) == "number" then weaponIDs[id] = true end
    end
    for _, id in pairs(ItemArmorSubclass) do
        if type(id) == "number" then armorIDs[id] = true end
    end

    -- In the legacy AH category list Weapons and Armor are categories 1 and 2.
    -- Armor subclasses are contiguous; weapon spell names below also cover the
    -- historical gaps in the weapon-subclass numbering.
    AddAuctionSubclasses(1, WEAPON_SUBCLASS_BY_NAME, weaponIDs)
    AddAuctionSubclasses(2, ARMOR_SUBCLASS_BY_NAME, armorIDs)

    for subclassID, spellID in pairs(WEAPON_PROFICIENCY_SPELL) do
        local spellName = _G.GetSpellInfo and _G.GetSpellInfo(spellID)
        AddSubclassName(WEAPON_SUBCLASS_BY_NAME, spellName, subclassID)
    end
end

RefreshWeaponProficiencies = function()
    BuildLegacySubclassMaps()
    wipe(session.trainedWeapons)
    wipe(session.trainedArmor)

    -- On 3.3.5 the Skills panel is the closest representation of what the
    -- server will actually let this character equip. Some private cores report
    -- hidden weapon passives through IsSpellKnown even before the associated
    -- skill has been trained. Record every visible weapon skill first and, once
    -- at least one is available, treat the absence of another ordinary weapon
    -- skill as an explicit "not trained" result.
    local legacyWeaponSkills, hasLegacyWeaponSkillData =
        ScanLegacyWeaponSkills()

    for subclassID, spellID in pairs(WEAPON_PROFICIENCY_SPELL) do
        local knownBySpell = IsKnownProficiencySpell(spellID)
        if addon.gameVersion == 30300 and hasLegacyWeaponSkillData and
            subclassID ~= ItemWeaponSubclass.Unarmed then
            session.trainedWeapons[subclassID] =
                legacyWeaponSkills[subclassID] == true
        else
            -- Fist Weapons deliberately retain the proficiency-spell result:
            -- the legacy Skills panel commonly calls the skill "Unarmed", which
            -- every class has and which is not proof that fist weapons are usable.
            session.trainedWeapons[subclassID] = knownBySpell
        end
    end

    if addon.gameVersion == 30300 then
        for subclassID, spellID in pairs(ARMOR_PROFICIENCY_SPELL) do
            session.trainedArmor[subclassID] =
                IsKnownProficiencySpell(spellID)
        end
    end

    if addon.gameVersion == 30300 then
        session.trainedShield =
            IsKnownProficiencySpell(SHIELD_PROFICIENCY_SPELL)
        if session.trainedShield == true then
            -- Respect custom AzerothCore characters which were explicitly
            -- granted the proficiency, even if their stock class normally
            -- cannot use shields.
            session.equippableSlots["INVTYPE_SHIELD"] = _G.INVSLOT_OFFHAND
            session.equippableArmor[ItemArmorSubclass.Shield] = true
        elseif session.trainedShield == false then
            session.equippableSlots["INVTYPE_SHIELD"] = nil
            session.equippableArmor[ItemArmorSubclass.Shield] = nil
        end
    else
        session.trainedShield = nil
    end
end

function addon.itemUpgrades.SubclassNameToID(subclassName, itemEquipLoc)
    if type(subclassName) ~= "string" then return nil end
    BuildLegacySubclassMaps()
    if IsWeaponSlot(itemEquipLoc) then
        return LookupSubclassName(WEAPON_SUBCLASS_BY_NAME, subclassName)
    end
    return LookupSubclassName(ARMOR_SUBCLASS_BY_NAME, subclassName)
end

local function IsUsableForClass(itemSubTypeID, itemEquipLoc)
    if type(itemEquipLoc) ~= "string" then return true end

    -- INVTYPE_SHIELD is sufficient to make this decision even when a localized
    -- 3.3.5 client supplies a subtype name that the lookup table does not know.
    -- Returning early on a missing numeric subtype used to let those shields
    -- bypass the proficiency test entirely.
    if addon.gameVersion == 30300 and itemEquipLoc == "INVTYPE_SHIELD" then
        if session.trainedShield == true then return true end
        if session.trainedShield == false then return false end
        -- INVTYPE_SHIELD is itself unambiguous. If a core exposes no spellbook
        -- proficiency query, fall back to the stock class map instead of the
        -- reward UI hint (which is known to ignore armor proficiency).
        return session.equippableSlots["INVTYPE_SHIELD"] and
                   session.equippableArmor[ItemArmorSubclass.Shield] and true or
                   false
    end

    -- Preserve an explicit unknown result when a private core supplies neither a
    -- numeric subclass nor a localized name we can map. Legacy weapon callers
    -- keep this conservative and refuse to score the item; other equipment may
    -- still use the client's hint. A hint must never override a recognized
    -- class, level, or proficiency restriction.
    if type(itemSubTypeID) ~= "number" then return nil end

    if IsWeaponSlot(itemEquipLoc) then
        local proficiencySpell = WEAPON_PROFICIENCY_SPELL[itemSubTypeID]
        local trained = proficiencySpell and
                            session.trainedWeapons[itemSubTypeID] or nil
        -- On 3.3.5 the learned proficiency is authoritative. This both rejects
        -- trainable-but-unlearned weapons and permits WotLK/custom-core weapon
        -- training which may be absent from the static class fallback map.
        if addon.gameVersion == 30300 then
            -- A recognized legacy weapon must have a positive proficiency
            -- result. "Unknown" stays distinct from "untrained" so inventory
            -- cleanup can protect uncertain items, but neither may be scored,
            -- recommended, or auto-equipped as an upgrade.
            if proficiencySpell then
                if trained ~= true then return trained end
            else
                return nil
            end
        elseif trained == false then
            return false
        end

        -- Main-hand and two-hand slots are shared defaults. Specialized weapon
        -- locations still require the class to expose that slot (ranged,
        -- thrown, or an off-hand-only weapon after Dual Wield is learned).
        if (itemEquipLoc == "INVTYPE_WEAPONOFFHAND" or
            itemEquipLoc == "INVTYPE_RANGED" or
            itemEquipLoc == "INVTYPE_RANGEDRIGHT" or
            itemEquipLoc == "INVTYPE_THROWN") and
            not session.equippableSlots[itemEquipLoc] then
            -- A weapon proficiency does not grant Dual Wield, so off-hand-only
            -- weapons retain that independent requirement. Ranged weapon types
            -- all use the same physical ranged slot and may be granted by a
            -- custom AzerothCore trainer even if the stock class map omits it.
            if itemEquipLoc == "INVTYPE_WEAPONOFFHAND" or trained ~= true then
                return false
            end
            session.equippableSlots[itemEquipLoc] = _G.INVSLOT_RANGED
        end
        if addon.gameVersion ~= 30300 and trained ~= true and
            not session.equippableWeapons[itemSubTypeID] then
            return false
        end
    else
        if not session.equippableArmor[itemSubTypeID] then return false end
        local proficiencySpell = ARMOR_PROFICIENCY_SPELL[itemSubTypeID]
        if addon.gameVersion == 30300 and proficiencySpell and
            session.trainedArmor[itemSubTypeID] == false then
            return false
        end
    end
    return true
end

-- Public, scoring-independent wearability result for InventoryManager. This
-- deliberately reflects what the character can equip *now*: hunter/shaman mail
-- and warrior/paladin plate therefore remain unwearable until level 40 and the
-- corresponding proficiency has actually been learned.
function addon.itemUpgrades:GetItemWearability(itemLink)
    if not itemLink then return "unknown" end
    local _, currentClass = UnitClass("player")
    currentClass = currentClass or addon.player.class
    if not next(session.equippableArmor) or not next(session.equippableWeapons) or
        session.wearabilityLevel ~= UnitLevel("player") or
        session.wearabilityClass ~= currentClass then
        self:UpdateSlotMap()
        RefreshWeaponProficiencies()
    end

    local _, _, _, _, _, _, itemSubType, _, itemEquipLoc, _, _, _,
        itemSubTypeID = GetItemInfo(itemLink)
    if not itemEquipLoc or itemEquipLoc == "" or
        itemEquipLoc == "INVTYPE_AMMO" or itemEquipLoc == "INVTYPE_BAG" or
        itemEquipLoc == "INVTYPE_BODY" or itemEquipLoc == "INVTYPE_TABARD" or
        itemEquipLoc == "INVTYPE_NON_EQUIP_IGNORE" then
        return "not_equipment"
    end
    if type(itemSubTypeID) ~= "number" then
        itemSubTypeID = self.SubclassNameToID(itemSubType, itemEquipLoc)
    end
    if type(itemSubTypeID) ~= "number" then return "unknown" end
    local itemID = GetItemInfoInstant(itemLink)
    -- Profession tools and fishing poles are useful utility items, not combat
    -- upgrades. Their weapon subtype must not make them automatic junk when the
    -- character lacks the corresponding combat proficiency.
    if itemID == 7005 or itemID == 2901 or itemID == 5956 or
        itemSubTypeID == ItemWeaponSubclass.Fishingpole then
        return "utility"
    end
    local usability = IsUsableForClass(itemSubTypeID, itemEquipLoc)
    if usability == nil then return "unknown" end
    return usability and "wearable" or "unwearable"
end

local function CalculateDPSWeight(itemData, stats, itemEquipLoc)
    -- Example:
    -- itemData = {
    --    ['itemEquipLoc'] = 'INVTYPE_RANGED',
    --    ...
    -- }
    -- stats = {
    --    ['ITEM_MOD_DAMAGE_PER_SECOND_SHORT'] = 12.3456789,
    --    ...
    -- }
    local dpsWeights = {}

    -- This only happens if an empty slot comparison
    -- Fake a 0 weight base item to preserve upstream comparison logic
    if itemEquipLoc and not itemData then
        for _, keySuffix in ipairs(session.weaponSlotToWeightKey[itemEquipLoc] or {}) do
            dpsWeights[keySuffix] = {['totalWeight'] = 0.00, ['speedWeight'] = 0.00}
        end

        return dpsWeights
    end

    -- Shield gets here from being INVTYPE_OFFHAND
    if itemData.itemEquipLoc == "INVTYPE_SHIELD" then return end

    if not stats or not stats['ITEM_MOD_CR_SPEED_SHORT'] then
        addon.comms.PrettyDebug("itemUpgrades CalculateDPSWeight, Speed property required %s",
                                itemData and itemData['itemLink'])
        return nil
    end

    itemEquipLoc = itemData.itemEquipLoc
    local speedWeightKey, speedWeightModifier, dpsWeight, speedKindWeight, dpsWeightModifier

    -- Look through weaponSlotToWeightKey for all kinds associated with itemEquipLoc
    -- - which then gives the WEAPON_SLOT_MAP key for weight lookup
    -- weaponSlotToWeightKey['INVTYPE_WEAPON'] = { "MH", "OH" }
    for _, keySuffix in ipairs(session.weaponSlotToWeightKey[itemEquipLoc] or {}) do
        if itemEquipLoc == 'INVTYPE_RANGED' or itemEquipLoc == 'INVTYPE_THROWN' or itemEquipLoc == 'INVTYPE_RANGEDRIGHT' then

            dpsWeightModifier = session.activeStatWeights['ITEM_MOD_DAMAGE_PER_SECOND_SHORT_RANGED']
        else
            dpsWeightModifier = session.activeStatWeights['ITEM_MOD_DAMAGE_PER_SECOND_SHORT']
        end

        if dpsWeightModifier and dpsWeightModifier > 0 then
            dpsWeight = stats['ITEM_MOD_DAMAGE_PER_SECOND_SHORT'] * dpsWeightModifier
        else
            -- A zero/absent DPS weight is intentional for caster sets. Counting
            -- raw weapon DPS here made caster staves look like upgrades solely
            -- because they swung harder.
            dpsWeight = 0
        end

        -- Lookup speed weight key with kind suffix (MH, OH, RANGED, 2H)
        speedWeightKey = 'ITEM_MOD_CR_SPEED_SHORT_' .. keySuffix
        speedWeightModifier = session.activeStatWeights[speedWeightKey]

        -- Exclude Off-hand comparison before trained
        if keySuffix == "OH" and not session.equippableSlots['INVTYPE_WEAPONOFFHAND'] then
            -- print("Untrained OH")
        elseif speedWeightModifier and speedWeightModifier ~= 0 then
            speedKindWeight = stats['ITEM_MOD_CR_SPEED_SHORT'] * speedWeightModifier

            -- (DPS * 1_DPS_WEIGHT) + (SPEED * WEAPON_WEIGHT)
            dpsWeights[keySuffix] = {['totalWeight'] = dpsWeight + speedKindWeight, ['speedWeight'] = speedKindWeight}
        else -- Weapon speed irrelevant for this weight set
            dpsWeights[keySuffix] = {['totalWeight'] = dpsWeight, ['speedWeight'] = 0.00}
        end
    end

    return dpsWeights
end

local function CalculateSpellWeight(stats, tooltipTextLines)
    -- Example:
    -- stats = {
    --    ['ITEM_MOD_SPELL_DAMAGE_DONE'] = 12, -- Always 1 lower than tooltip shows
    --    ...
    -- }

    -- No spellpower weights for class
    if not (session.activeStatWeights['STAT_SPELLDAMAGE'] or session.activeStatWeights['ITEM_MOD_SPELL_POWER']) then
        return 0
    end

    local schoolStatWeight, totalStatWeight = 0, 0
    local schoolKey, schoolName, spellPower

    -- Check all tooltip lines for regex matches
    for _, line in ipairs(tooltipTextLines) do
        -- print("CalculateSpellWeight (", line, ")")
        schoolName, spellPower = smatch(line, SPELL_KIND_MATCH)

        if schoolName then
            schoolKey = SPELL_KIND_MAP[strlower(schoolName)]

            -- print("Matched schoolName", strlower(schoolName), schoolKey, spellPower)
            if session.activeStatWeights[schoolKey] and session.activeStatWeights[schoolKey] > 0 then

                -- ITEM_MOD_SPELL_DAMAGE_DONE cannot be trusted, byRef add parsed stats
                stats[schoolKey] = spellPower
                schoolStatWeight = spellPower * session.activeStatWeights[schoolKey]

                totalStatWeight = totalStatWeight + schoolStatWeight
            end
        end
    end

    -- Not a magic school, return default weighting
    -- ITEM_MOD_SPELL_DAMAGE_DONE cannot be trusted, e.g. 40 Shadow + 40 Frost == 78 ITEM_MOD_SPELL_DAMAGE_DONE
    if totalStatWeight == 0 and stats['STAT_SPELLDAMAGE'] then -- Legacy block
        -- print("STAT_SPELLDAMAGE: Not a magic school", stats['STAT_SPELLDAMAGE'])
        -- ITEM_MOD_SPELL_DAMAGE_DONE cannot be trusted without validation
        -- Set spellPower stat to built-in stat after verifying no school
        return stats['STAT_SPELLDAMAGE'] * session.activeStatWeights['STAT_SPELLDAMAGE']

    elseif totalStatWeight == 0 and stats['ITEM_MOD_SPELL_POWER'] then -- Anniversary/Era/SoD/Cata
        -- print("ITEM_MOD_SPELL_POWER: Not a magic school", stats['ITEM_MOD_SPELL_POWER'])
        -- Set spellPower stat to built-in stat after verifying no school
        stats['STAT_SPELLDAMAGE'] = stats['ITEM_MOD_SPELL_POWER']

        return stats['STAT_SPELLDAMAGE'] *
                   (session.activeStatWeights['STAT_SPELLDAMAGE'] or session.activeStatWeights['ITEM_MOD_SPELL_POWER'])
    end

    return totalStatWeight
end

function addon.itemUpgrades:GetItemData(itemLink, tooltip, clientUsable)
    if not itemLink or type(itemLink) ~= "string" then
        -- print("addon.itemUpgrades:GetItemData, itemLink string required", itemLink)
        return
    end

    -- An already-equipped item is unambiguously usable. This also bypasses
    -- false negatives from private cores which omit a passive weapon
    -- proficiency from IsSpellKnown/GetSkillLineInfo.
    local currentlyEquipped = IsEquippedItem(itemLink)
    local clientSaysUsable = clientUsable == true or clientUsable == 1 or
                                 currentlyEquipped
    if session.itemCache[itemLink] then
        -- Re-evaluate only an old/uncertain subtype false-negative. Recognized
        -- class restrictions remain data objects so every caller (tooltips,
        -- rewards, junk, and auto-equip) receives the same unusable result.
        if session.itemCache[itemLink].unusable and currentlyEquipped then
            session.itemCache[itemLink] = nil
        elseif session.itemCache[itemLink].unusable and clientSaysUsable and
            not session.itemCache[itemLink].classRestricted and
            not session.itemCache[itemLink].proficiencyUnknown then
            session.itemCache[itemLink] = nil
        elseif session.itemCache[itemLink].unusable then
            return session.itemCache[itemLink]
        else
            if clientSaysUsable then
                session.itemCache[itemLink].clientUsable = true
            end
            return session.itemCache[itemLink]
        end
    end

    local _, _, _, itemLevel, itemMinLevel, _, itemSubType, _, itemEquipLoc, _, sellPrice, _, itemSubTypeID, _, _, setID =
        GetItemInfo(itemLink)

    -- 3.3.5a: GetItemInfo has no numeric subclass ID (position 13); derive it from
    -- the localized subclass name so IsUsableForClass can filter by armor/weapon type.
    if type(itemSubTypeID) ~= "number" then
        itemSubTypeID = addon.itemUpgrades.SubclassNameToID(itemSubType, itemEquipLoc)
    end

    -- Not an equippable item
    if not itemEquipLoc or itemEquipLoc == "" or itemEquipLoc == "INVTYPE_AMMO" or itemEquipLoc == "INVTYPE_BAG" or
        itemEquipLoc == "INVTYPE_BODY" or itemEquipLoc == "INVTYPE_TABARD" or
        itemEquipLoc == "INVTYPE_NON_EQUIP_IGNORE" then return end

    local itemData

    local classUsability = IsUsableForClass(itemSubTypeID, itemEquipLoc)
    -- The equipped slots are authoritative for every item type, including
    -- off-hand frills granted by custom/private-server class rules. Restricting
    -- this bypass to weapons could leave an actually equipped off hand with no
    -- EP data, which in turn made a 2H comparison incomplete.
    if currentlyEquipped then
        classUsability = true
    end
    -- On 3.3.5 GetQuestItemInfo's fifth return is only a UI hint on several
    -- cores. It has been observed as true for low-level Hunter mail, so a known
    -- class/level/proficiency failure is authoritative for every equipment type,
    -- not just shields. Unknown localized armor may still use the hint, while
    -- unknown weapons are kept but excluded from upgrade automation below.
    if classUsability == false and
        (addon.gameVersion == 30300 or not clientSaysUsable) then
        itemData = {
            unusable = true,
            classRestricted = true,
            itemLink = itemLink,
            itemSubTypeID = itemSubTypeID,
            itemEquipLoc = itemEquipLoc,
            sellPrice = sellPrice,
            itemMinLevel = itemMinLevel,
            setID = setID
        }

        session.itemCache[itemLink] = itemData

        return itemData
    end

    -- A recognized item with unavailable proficiency data must remain safe in
    -- the bags, but it must not pass through to EP scoring based on the legacy
    -- reward window's unreliable "usable" flag. Skill/spell events clear this
    -- cache and retry immediately when the character learns a weapon skill.
    if addon.gameVersion == 30300 and IsWeaponSlot(itemEquipLoc) and
        classUsability ~= true then
        itemData = {
            unusable = true,
            proficiencyUnknown = true,
            itemLink = itemLink,
            itemSubTypeID = itemSubTypeID,
            itemEquipLoc = itemEquipLoc,
            sellPrice = sellPrice,
            itemMinLevel = itemMinLevel,
            setID = setID
        }
        session.itemCache[itemLink] = itemData
        return itemData
    end

    itemMinLevel = tonumber(itemMinLevel) or 0
    itemLevel = tonumber(itemLevel) or 0

    -- Required level determines whether an item can be equipped. Item level is
    -- not a usability limit: Outland and especially Northrend rewards routinely
    -- have an item level far above the character level. The old itemLevel + 10
    -- heuristic silently discarded valid TBC/Wrath upgrades before scoring.
    local playerLevel = tonumber(UnitLevel("player")) or
                            tonumber(addon.player.level) or 0
    if itemMinLevel > playerLevel then return end

    -- Need itemID for easier code lookups
    local itemID = GetItemInfoInstant(itemLink)

    -- Exclude skinning knife, mining pick, and blacksmith hammer
    if itemID == 7005 or itemID == 2901 or itemID == 5956 then return end

    -- Parse API stats first before processing tooltip text
    local stats = GetItemStats and GetItemStats(itemLink) or {}

    local totalWeight = 0
    local statWeight, tooltipTextLines

    if session.activeStatWeights and session.activeStatWeights.extraWeight and
        session.activeStatWeights.extraWeight[itemID] then
        totalWeight = session.activeStatWeights.extraWeight[itemID]
    end

    itemData = {
        itemID = itemID,
        itemLink = itemLink,
        clientUsable = clientSaysUsable or nil,
        itemSubTypeID = itemSubTypeID,
        itemEquipLoc = itemEquipLoc,
        sellPrice = sellPrice,
        itemMinLevel = itemMinLevel,
        setID = setID
    }

    -- Parse tooltip for all additional stats
    if tooltip then
        tooltipTextLines = GetTooltipLines(tooltip, itemData)

        if not tooltipTextLines then return end
    else -- If not tooltip, set hidden comparison tooltip
        tooltip = GetComparisonTip()

        if not tooltip then
            -- print("Comparisontip failure")
            return
        end

        -- Note: Calling this function with the same link which is currently shown, will close the Tooltip.
        tooltip:SetHyperlink(itemLink)
        -- print("RXPItemUpgradesComparison:SetHyperlink", itemLink)

        tooltipTextLines = GetTooltipLines(tooltip, itemData)

        if not tooltipTextLines then
            -- print("Comparisontip lines empty")
            return
        end

        -- Would bug out if cache is reset or invalidated
        tooltip:ClearLines()
    end

    if addon.gameVersion == 30300 then
        ParseLegacyTooltipStats(stats, tooltipTextLines)
    end

    local match1, match2

    -- Will be more stat weighted keys than tooltip lines
    -- Use larger dataset as parent loop
    for key, regex in pairs(session.statsRegexes) do
        if addon.gameVersion == 30300 then break end
        -- Skip if stat already came from API call
        if not stats[key] then

            -- Check all tooltip lines for regex matches
            for _, line in ipairs(tooltipTextLines) do
                -- print("Checking tooltip line", i, line)

                if type(regex) == "table" then
                    for _, r in ipairs(regex) do
                        -- print("Parsing table", i, line, "for", r)
                        match1, match2 = smatch(line, r)

                        -- Only expect one number per line, so ignore if double match
                        if match1 and not match2 then
                            -- print("Extracted multi-match", tonumber(match1), "from", line)
                            -- If no match, try EU , -> . for numbers
                            stats[key] = tonumber(match1) or tonumber((match1:gsub(",", "%.", 1)))
                        end
                    end
                else
                    -- print("Parsing not-table", i, line, "for", regex)
                    match1, match2 = smatch(line, regex)

                    -- Only expect one number per line, so ignore if double match
                    if match1 and not match2 then
                        -- print("Extracted", tonumber(match1), "from", line)
                        -- If no match, try EU , -> . for numbers
                        stats[key] = tonumber(match1) or tonumber((match1:gsub(",", "%.", 1)))
                    end
                end
            end
        end
    end

    -- After parsing API data and tooltip text, add up stat weights
    for key, value in pairs(stats) do
        -- print("Weighting stat", key, "value", value)

        -- Weapon DPS only comes back as a single stat/key
        if key == 'ITEM_MOD_DAMAGE_PER_SECOND_SHORT' then
            -- CalculateDPSWeight requires speed pulled from text

            itemData.dpsWeights = CalculateDPSWeight(itemData, stats)
            -- print("Key", key, "Value", value, "weighted at", statWeight)
            -- If weapon DPS fails to parse, return nil
            if not itemData.dpsWeights then
                -- print("CalculateDPSWeight return nil", itemData.itemLink)
                return
            end
            statWeight = nil

            -- dpsWeights is evaluated later, based on slot comparison wich this level doesn't know about
            -- totalWeight = statWeight + dpsWeight
        elseif key == 'ITEM_MOD_SPELL_DAMAGE_DONE' or key == 'ITEM_MOD_SPELL_POWER' then
            -- ITEM_MOD_SPELL_DAMAGE_DONE is terrible, but it's built-in so key off that to parse spell damage
            statWeight = CalculateSpellWeight(stats, tooltipTextLines)
            -- print("Spell: Key", key, "Value", value, "weighted at", statWeight)

            -- If fails to parse, return nil instead of misallocating to all spellpower
            if not statWeight then
                -- print("CalculateSpellWeight return nil", itemData.itemLink)
                return
            end

            totalWeight = totalWeight + statWeight
        elseif session.activeStatWeights[key] then -- Only calculate values explicitly configured

            statWeight = value * session.activeStatWeights[key]
            totalWeight = totalWeight + statWeight

            -- print("General: Key", key, "Value", value, "weighted at", statWeight)
        end
    end

    itemData.totalWeight = addon.Round(totalWeight, 6)
    itemData.stats = stats

    -- TODO validate edge cases or failures before return
    session.itemCache[itemLink] = itemData

    return itemData
end

function addon.itemUpgrades:CalculateWeaponWeight(itemData, slotComparisonId)
    if not itemData.dpsWeights then return -1 end

    for suffix, dpsData in pairs(itemData.dpsWeights or {}) do
        if slotComparisonId == SPEED_SUFFIX_SLOT_MAP[suffix] then
            -- print("CalculateWeaponWeight, suffix", suffix, slotComparisonId, itemData.totalWeight + dpsData.totalWeight)

            return itemData.totalWeight + dpsData.totalWeight
        end
    end

    return -1
end

-- Speed weights describe preferences within one hand layout (for example, a
-- slower two-hander for large instant attacks). They are not interchangeable
-- between one- and two-handed weapons. Comparing the 2H speed coefficient to
-- the MH coefficient made low-DPS starter weapons become apparent upgrades
-- after crossing a level bracket. For a layout change, compare the ordinary
-- stat and DPS contribution and let the complete-hand calculation below add
-- the displaced off hand.
function addon.itemUpgrades:CalculateWeaponLayoutWeight(itemData,
                                                         slotComparisonId)
    if not itemData or not itemData.dpsWeights then return -1 end

    local preferredSuffix
    if itemData.itemEquipLoc == "INVTYPE_2HWEAPON" then
        preferredSuffix = "2H"
    elseif itemData.itemEquipLoc == "INVTYPE_RANGED" or
        itemData.itemEquipLoc == "INVTYPE_RANGEDRIGHT" or
        itemData.itemEquipLoc == "INVTYPE_THROWN" then
        preferredSuffix = "RANGED"
    elseif itemData.itemEquipLoc == "INVTYPE_WEAPONOFFHAND" or
        slotComparisonId == _G.INVSLOT_OFFHAND then
        preferredSuffix = "OH"
    else
        preferredSuffix = "MH"
    end

    -- INVTYPE_WEAPON can expose both MH and OH entries. Never let pairs()
    -- choose one arbitrarily when evaluating a complete hand layout.
    local dpsData = itemData.dpsWeights[preferredSuffix]
    if not dpsData then _, dpsData = next(itemData.dpsWeights) end
    if dpsData then
        local total = tonumber(dpsData.totalWeight)
        if total then
            return (tonumber(itemData.totalWeight) or 0) + total -
                       (tonumber(dpsData.speedWeight) or 0)
        end
    end

    return -1
end

local function IsCrossHandLayout(equippedData, comparedData,
                                 slotComparisonId)
    if slotComparisonId ~= _G.INVSLOT_MAINHAND or not equippedData or
        not comparedData or not IsMeleeSlot(equippedData.itemEquipLoc) or
        not IsMeleeSlot(comparedData.itemEquipLoc) then
        return false
    end

    return (equippedData.itemEquipLoc == "INVTYPE_2HWEAPON") ~=
               (comparedData.itemEquipLoc == "INVTYPE_2HWEAPON")
end

-- return ratio, weight, debugMsg
function addon.itemUpgrades:GetEquippedComparisonRatio(equippedItemLink, comparedData, slotComparisonId)
    if not comparedData or not equippedItemLink then return nil, -1, "invalid parameters" end

    -- Load equipped item into hidden tooltip for parsing
    local equippedData = self:GetItemData(equippedItemLink, nil)

    if not equippedData then return nil, -1, "not equippedData" end

    local equippedWeight, comparedWeight

    -- _G.INVSLOT_RANGED, _G.INVSLOT_OFFHAND, _G.INVSLOT_MAINHAND
    -- MH / OH have more complex handling, requires DPS calculations here
    if IsWeaponSlot(equippedData.itemEquipLoc) then
        if IsCrossHandLayout(equippedData, comparedData,
                             slotComparisonId) then
            equippedWeight = self:CalculateWeaponLayoutWeight(
                                 equippedData, slotComparisonId)
            comparedWeight = self:CalculateWeaponLayoutWeight(
                                 comparedData, slotComparisonId)
        else
            equippedWeight = self:CalculateWeaponWeight(equippedData, slotComparisonId)
            comparedWeight = self:CalculateWeaponWeight(comparedData, slotComparisonId)
        end
    else
        equippedWeight = equippedData.totalWeight
        comparedWeight = comparedData.totalWeight
    end

    -- If -1, then failed to calculate speed/DPS EP
    if equippedWeight < 0 or comparedWeight < 0 then
        return nil, -1, _G.UNKNOWN, equippedWeight, comparedWeight
    elseif equippedWeight == 0 then
        return 1.0, comparedWeight, _G.EMPTY, equippedWeight, comparedWeight
    elseif comparedWeight == 0 then
        return nil, 0, _G.EMPTY, equippedWeight, comparedWeight
    elseif comparedWeight > equippedWeight then
        return comparedWeight / equippedWeight, comparedWeight - equippedWeight, 'upgrade', equippedWeight,
               comparedWeight
    elseif comparedWeight < equippedWeight then
        -- Item upgrade being negative is confusing and difficult to represent accurately, ignore
        -- return -1 * comparedWeight / equippedWeight
        -- Display 'downgrade' when debugging
        return nil, -1, 'downgrade', equippedWeight, comparedWeight
    elseif comparedWeight == equippedWeight then
        return nil, 0, 'equal', equippedWeight, comparedWeight
    end

    return nil, -1, _G.UNKNOWN
end

local function RefreshHandReplacementState()
    for _, slotId in ipairs({_G.INVSLOT_MAINHAND, _G.INVSLOT_OFFHAND}) do
        local oldLink = session.equippedHandLinks[slotId]
        local newLink = GetInventoryItemLink("player", slotId)
        if oldLink and newLink and oldLink ~= newLink then
            session.suppressedHandReversals[oldLink] = {
                replacement = newLink,
                slot = slotId
            }
        end
        session.equippedHandLinks[slotId] = newLink
    end

    -- A suppression represents only one exact player-selected setup. Once that
    -- setup changes, the old weapon may legitimately be an upgrade again.
    for oldLink, replacement in pairs(session.suppressedHandReversals) do
        if GetInventoryItemLink("player", replacement.slot) ~=
            replacement.replacement then
            session.suppressedHandReversals[oldLink] = nil
        end
    end
end

local function IsSuppressedHandReversal(itemLink, comparison)
    local replacement = session.suppressedHandReversals[itemLink]
    return replacement and comparison and
               comparison.SlotCompared == replacement.slot and
               GetInventoryItemLink("player", replacement.slot) ==
                   replacement.replacement
end

-- nil if same item
-- % change otherwise
function addon.itemUpgrades:CompareItemWeight(itemLink, tooltip,
                                               includeNonUpgrades,
                                               clientUsable)
    local clientSaysUsable = clientUsable == true or clientUsable == 1
    local comparedData = self:GetItemData(itemLink, tooltip, clientUsable)

    -- Failed to load (wait for next try) or not equippable
    if not comparedData then
        -- print("CompareItemWeight: Failed to query comparedStats", itemLink)
        return nil, "query failed"
    end

    -- Not an equippable item
    if not comparedData.itemEquipLoc then
        -- print("CompareItemWeight: not comparedData.itemEquipLoc")
        return nil, "not itemEquipLoc"
    end
    -- print("comparedData.itemEquipLoc", comparedData.itemEquipLoc)

    if comparedData.unusable then return nil, "unusable" end

    local classUsability = IsUsableForClass(comparedData.itemSubTypeID,
                                             comparedData.itemEquipLoc)
    if addon.gameVersion == 30300 and
        IsWeaponSlot(comparedData.itemEquipLoc) and classUsability ~= true then
        return nil, "unusable"
    end
    if classUsability == false and
        (addon.gameVersion == 30300 or
            not (clientSaysUsable or comparedData.clientUsable)) then
        -- print("CompareItemWeight: not usable by class")
        return nil, "unusable"
    end

    local statComparisons = {
        -- { ['Ratio'] = 1.23, ['WeightIncrease'] = 23.4, ['ItemLink'] = 'item:1234', ['itemEquipLoc'] = itemEquipLoc },
    }
    local equippedItemLink, equippedData, ratio, weightIncrease, debug
    local equippedWeight, comparedWeight
    local slotNamesToCompare, dpsWeights = {}, nil
    local sawUpgrade, sawDowngrade, sawNonWorse, sawUnknown

    if type(session.equippableSlots[comparedData.itemEquipLoc]) == "table" then
        -- print("is multi-slot", comparedData.itemEquipLoc)
        slotNamesToCompare = session.equippableSlots[comparedData.itemEquipLoc]
    else
        slotNamesToCompare[comparedData.itemEquipLoc] = session.equippableSlots[comparedData.itemEquipLoc]
    end

    -- if 1H weapon, check OH if INVTYPE_WEAPONOFFHAND, add to slot comparisons
    if comparedData.itemEquipLoc == 'INVTYPE_WEAPON' and session.equippableSlots['INVTYPE_WEAPONOFFHAND'] then
        local currentMainHand = self:GetItemData(GetInventoryItemLink("player", _G.INVSLOT_MAINHAND), nil)
        if not currentMainHand or currentMainHand.itemEquipLoc ~= "INVTYPE_2HWEAPON" then
            slotNamesToCompare['INVTYPE_WEAPONOFFHAND'] = session.equippableSlots['INVTYPE_WEAPONOFFHAND']
        end
    end

    -- A two-hander occupies both hands. Off-hand-only weapons cannot fill the
    -- visually empty off-hand slot while it is equipped; treating that slot as
    -- a zero-weight upgrade caused impossible recommendations. Generic one-hand
    -- weapons still compare against the main hand and may free the off hand.
    if comparedData.itemEquipLoc == "INVTYPE_WEAPONOFFHAND" then
        local currentMainHand = self:GetItemData(
                                    GetInventoryItemLink("player",
                                                         _G.INVSLOT_MAINHAND),
                                    nil)
        if currentMainHand and
            currentMainHand.itemEquipLoc == "INVTYPE_2HWEAPON" then
            wipe(slotNamesToCompare)
        end
    end

    -- Check applicable slots
    -- Will be 1 for most and 1-2 for rings
    for itemEquipLoc, slotId in pairs(slotNamesToCompare) do
        dpsWeights = nil
        equippedWeight, comparedWeight = nil, nil
        equippedItemLink, equippedData = nil, nil
        ratio, weightIncrease, debug = nil, nil, nil

        -- print("Stack2.2, CompareItemWeight pairs(slotNamesToCompare)", slotId or itemEquipLoc)
        equippedItemLink = GetInventoryItemLink("player", slotId or itemEquipLoc)

        if comparedData.itemEquipLoc == "INVTYPE_SHIELD" or comparedData.itemEquipLoc == "INVTYPE_HOLDABLE" then
            if equippedItemLink then
                ratio, weightIncrease, debug, equippedWeight, comparedWeight =
                    self:GetEquippedComparisonRatio(equippedItemLink, comparedData, slotId)
            else
                -- An empty off-hand is fillable only when the main hand is not a
                -- two-hander. This preserves useful shield/holdable suggestions
                -- without pretending they can coexist with a 2H weapon.
                local mainHand = self:GetItemData(GetInventoryItemLink("player", _G.INVSLOT_MAINHAND), nil)
                if not mainHand or mainHand.itemEquipLoc ~= "INVTYPE_2HWEAPON" then
                    equippedItemLink = _G.EMPTY
                    equippedWeight = 0
                    comparedWeight = comparedData.totalWeight
                    weightIncrease = comparedWeight
                    debug = _G.EMPTY
                end
            end
        elseif comparedData.itemLink == equippedItemLink then
            -- Same item, so not an upgrade
            ratio = nil
            debug = 'same'
            weightIncrease = nil
        elseif slotId == _G.INVSLOT_MAINHAND or slotId == _G.INVSLOT_OFFHAND or slotId == _G.INVSLOT_RANGED then
            ratio, weightIncrease, debug, equippedWeight, comparedWeight =
                self:GetEquippedComparisonRatio(equippedItemLink, comparedData, slotId)

            -- Never parse an equipped link from the candidate's visible tooltip.
            equippedData = self:GetItemData(equippedItemLink, nil)

            if equippedData and equippedData.stats then
                dpsWeights = CalculateDPSWeight(equippedData, equippedData.stats)
            elseif not equippedItemLink or equippedItemLink == "" then
                dpsWeights = CalculateDPSWeight(nil, nil, itemEquipLoc)

                debug = _G.EMPTY
                equippedItemLink = _G.EMPTY
                ratio = nil
                weightIncrease = nil
                equippedWeight = 0
                comparedWeight = self:CalculateWeaponWeight(comparedData, slotId)
            else
                -- Never turn an equipped-item cache/tooltip failure into an
                -- empty slot. That produced false +EP results and automatic
                -- prompts for displaced starter weapons. Keep the result
                -- unknown until the equipped item can be parsed on a later
                -- inventory/item-info update.
                debug = _G.UNKNOWN
                ratio = nil
                weightIncrease = nil
                equippedWeight = nil
                comparedWeight = nil
            end

            -- Equipping a two-hander also removes the current off-hand. Compare
            -- against the complete old hand setup, including shields/holdables.
            if comparedData.itemEquipLoc == "INVTYPE_2HWEAPON" and
                slotId == _G.INVSLOT_MAINHAND then
                local offhandLink = GetInventoryItemLink("player", _G.INVSLOT_OFFHAND)
                local offhandData = self:GetItemData(offhandLink, nil)
                if offhandLink and not offhandData then
                    -- Never call a two-hander an upgrade until every displaced
                    -- item has been parsed. A later item/inventory event retries
                    -- the comparison after the legacy cache finishes loading.
                    ratio = nil
                    weightIncrease = nil
                    equippedWeight = nil
                    comparedWeight = nil
                    debug = _G.UNKNOWN
                elseif offhandData then
                    local offhandWeight
                    if IsWeaponSlot(offhandData.itemEquipLoc) then
                        -- The main-hand comparison above excludes speed when
                        -- changing layouts; use the same domain for a weapon
                        -- displaced from the off hand.
                        if equippedData and IsCrossHandLayout(
                            equippedData, comparedData, slotId) then
                            offhandWeight =
                                self:CalculateWeaponLayoutWeight(
                                    offhandData, _G.INVSLOT_OFFHAND)
                        else
                            offhandWeight = self:CalculateWeaponWeight(
                                                offhandData,
                                                _G.INVSLOT_OFFHAND)
                        end
                    else
                        offhandWeight = offhandData.totalWeight
                    end
                    if offhandWeight and offhandWeight > 0 and equippedWeight and equippedWeight >= 0 then
                        equippedWeight = equippedWeight + offhandWeight
                        if comparedWeight and comparedWeight > equippedWeight then
                            ratio = comparedWeight / equippedWeight
                            weightIncrease = comparedWeight - equippedWeight
                            debug = "upgrade"
                        else
                            ratio = nil
                            weightIncrease = comparedWeight and comparedWeight - equippedWeight or -1
                            debug = "downgrade"
                        end
                    end
                end
            end
        elseif not equippedItemLink or equippedItemLink == "" then
            ratio = nil
            debug = _G.EMPTY
            equippedItemLink = _G.EMPTY
            weightIncrease = comparedData.totalWeight
        else
            ratio, weightIncrease, debug, equippedWeight, comparedWeight =
                self:GetEquippedComparisonRatio(equippedItemLink, comparedData, slotId)
        end

        local effectiveIncrease = tonumber(weightIncrease)
        if not effectiveIncrease and equippedItemLink == _G.EMPTY and
            comparedWeight then
            effectiveIncrease = comparedWeight - (equippedWeight or 0)
        end
        local slotState
        if ratio and ratio > 1 or effectiveIncrease and effectiveIncrease > 0 then
            slotState = "upgrade"
            sawUpgrade = true
        elseif debug == "downgrade" or
            debug == _G.EMPTY and equippedItemLink ~= _G.EMPTY and
                (equippedWeight or 0) > 0 and comparedWeight == 0 then
            slotState = "downgrade"
            sawDowngrade = true
        elseif debug == "equal" or debug == "same" or
            debug == _G.EMPTY and (effectiveIncrease or 0) == 0 then
            slotState = "equal"
            sawNonWorse = true
        else
            slotState = "unknown"
            sawUnknown = true
        end

        -- Even if ratio nil, add to comparisons for upstream handling based on debug value
        if ratio or equippedItemLink == _G.EMPTY or
            equippedItemLink == _G.NONE or
            includeNonUpgrades and slotState ~= "unknown" then
            tinsert(statComparisons, {
                ['Ratio'] = ratio,
                ['DpsWeights'] = dpsWeights,
                ['TotalWeight'] = comparedData.totalWeight,
                ['EquippedWeight'] = equippedWeight,
                ['ComparedWeight'] = comparedWeight,
                ['WeightIncrease'] = weightIncrease or 0,
                ['ItemLink'] = equippedItemLink or _G.UNKNOWN, -- Pass "Unknown" for debugging
                ['itemEquipLoc'] = itemEquipLoc, -- Is actually slotID for rings/trinkets
                ['SlotCompared'] = slotId, -- Track slotId number for weapon display later
                ['ComparisonState'] = slotState,
                ['debug'] = addon.settings.profile.debug and debug
            })
        end

    end

    local comparisonState
    if sawUpgrade then
        comparisonState = "upgrade"
    elseif sawUnknown then
        comparisonState = "unknown"
    elseif sawNonWorse then
        comparisonState = "equal"
    elseif sawDowngrade then
        comparisonState = "downgrade"
    else
        comparisonState = "unknown"
    end

    return statComparisons, nil, comparisonState
end

local function GetComparisonIncrease(comparison)
    if not comparison then return 0 end
    local increase = tonumber(comparison.WeightIncrease) or 0
    if increase <= 0 and comparison.ItemLink == _G.EMPTY and
        comparison.ComparedWeight then
        increase = comparison.ComparedWeight -
                       (comparison.EquippedWeight or 0)
    end
    return increase
end

function addon.itemUpgrades:GetBestUpgradeComparison(itemLink)
    local comparisons, reason, state = self:CompareItemWeight(itemLink)
    if state ~= "upgrade" or not comparisons then
        return nil, state or "unknown", reason
    end

    local best, bestIncrease
    for _, comparison in ipairs(comparisons) do
        local increase = GetComparisonIncrease(comparison)
        if increase > 0 and (not bestIncrease or increase > bestIncrease) then
            best = comparison
            bestIncrease = increase
        end
    end
    return best, best and "upgrade" or "unknown", reason
end

-- Returns a conservative four-state result. Callers which can destroy or sell
-- an item must act only on "downgrade"; equal and unparseable items are kept.
function addon.itemUpgrades:GetItemUpgradeStatus(itemLink)
    if not addon.settings.profile.enableItemUpgrades or
        not addon.settings.profile.enableTips then return "unknown" end
    local _, reason, state = self:CompareItemWeight(itemLink)
    if reason or not state then return "unknown" end
    return state
end

local LEGACY_BIND_CONFIRMATIONS = {
    "EQUIP_BIND",
    "AUTOEQUIP_BIND",
    "EQUIP_BIND_CONFIRM",
    "AUTOEQUIP_BIND_CONFIRM"
}

local function GetVisibleBindConfirmation()
    if type(_G.StaticPopup_Visible) ~= "function" then return end

    for _, which in ipairs(LEGACY_BIND_CONFIRMATIONS) do
        local index = _G.StaticPopup_Visible(which)
        if index then
            -- Stock 3.3.5 returns the popup frame's global name. Some backports
            -- return its numeric index instead, so accept both conventions.
            local popup
            if type(index) == "string" then
                popup = _G[index]
            elseif type(index) == "number" then
                popup = _G["StaticPopup" .. index]
            end
            return which, popup
        end
    end
end


function addon.itemUpgrades:GetComparisonIncrease(comparison)
    return GetComparisonIncrease(comparison)
end

local function ConfirmPendingUpgradeEquip(inventorySlot, itemLink)
    if addon.gameVersion ~= 30300 or type(_G.EquipPendingItem) ~= "function" then return false end

    local which, popup = GetVisibleBindConfirmation()
    if not which then return false end

    -- Stock 3.3.5 stores the destination slot in popup.data. Prefer that exact
    -- pending value, with our selected inventory slot as a compatibility
    -- fallback for cores whose StaticPopup_Visible does not expose the frame.
    local pendingSlot = popup and tonumber(popup.data) or inventorySlot
    if type(pendingSlot) ~= "number" then pendingSlot = inventorySlot end
    local ok = pcall(_G.EquipPendingItem, pendingSlot)
    if not ok then return false end

    -- Do not consume Blizzard's dialog if a non-standard core rejected the
    -- operation without throwing. Leaving it visible lets the player confirm
    -- manually instead of silently losing the requested equipment change.
    if itemLink then
        local equippedLink = GetInventoryItemLink("player", inventorySlot)
        if equippedLink ~= itemLink then return false end
    end

    -- EquipPendingItem completes the operation. Dismiss the now-stale stock
    -- dialog; its OnHide cancellation is harmless once no pending item remains.
    if type(_G.StaticPopup_Hide) == "function" then
        _G.StaticPopup_Hide(which)
    end
    return true
end

function addon.itemUpgrades:EquipBagUpgrade(data)
    if not data or InCombatLockdown() or UnitIsDeadOrGhost("player") or
        GetCursorInfo() then return false end
    if GetContainerItemLink(data.bag, data.bagSlot) ~= data.itemLink then return false end

    -- Re-evaluate at click time: the player may have changed gear while the
    -- confirmation was open, especially for rings, trinkets, and weapons.
    local comparison, state = self:GetBestUpgradeComparison(data.itemLink)
    local inventorySlot = comparison and comparison.SlotCompared
    if state ~= "upgrade" or type(inventorySlot) ~= "number" then return false end

    -- Never consume an unrelated bind confirmation which was already open.
    if GetVisibleBindConfirmation() then return false end

    -- The stock helper handles the displaced item's return to the bags. On
    -- 3.3.5, explicitly complete the BoE confirmation produced by this call:
    -- the player has already authorized it by clicking RXP's Equip button.
    if _G.EquipItemByName then
        _G.EquipItemByName(data.itemLink, inventorySlot)
        ConfirmPendingUpgradeEquip(inventorySlot, data.itemLink)
        return GetInventoryItemLink("player", inventorySlot) == data.itemLink
    end

    PickupContainerItem(data.bag, data.bagSlot)
    if not GetCursorInfo() then return false end
    PickupInventoryItem(inventorySlot)
    local bindConfirmation = GetVisibleBindConfirmation()
    local bindConfirmed = ConfirmPendingUpgradeEquip(inventorySlot,
                                                       data.itemLink)
    -- A non-standard client may expose the confirmation before it accepts the
    -- pending operation. Leave that stock dialog and cursor state intact so its
    -- own button can finish the swap.
    if bindConfirmation and not bindConfirmed then return false end
    -- A swap leaves the old equipped item on the cursor. Put it into the bag
    -- slot vacated by the upgrade; an empty equipment slot leaves no cursor item.
    if GetCursorInfo() then PickupContainerItem(data.bag, data.bagSlot) end
    if GetCursorInfo() then ClearCursor() end
    return GetInventoryItemLink("player", inventorySlot) == data.itemLink
end

StaticPopupDialogs["RXPItemUpgradeFound"] = {
    text = "%s",
    button1 = _G.EQUIP_ITEM or _G.EQUIP or L("Equip"),
    button2 = _G.CANCEL,
    timeout = 0,
    hideOnEscape = 1,
    showAlert = 1,
    OnShow = function()
        session.pendingUpgradeEquip = nil
        session.upgradePopupOpen = true
    end,
    OnAccept = function(_, data)
        -- A BoE equip can open Blizzard's own static popup. On 3.3.5 that
        -- second popup cannot reliably claim a slot until this RXP popup has
        -- finished hiding. Remember the click and perform the protected equip
        -- from OnHide, which is still part of the same hardware click.
        session.pendingUpgradeEquip = data
    end,
    OnHide = function()
        local pendingEquip = session.pendingUpgradeEquip
        session.pendingUpgradeEquip = nil
        session.upgradePopupOpen = false
        if pendingEquip then
            local equipped = addon.itemUpgrades:EquipBagUpgrade(pendingEquip)
            if not equipped and pendingEquip.itemLink then
                -- A combat transition, stale bag slot, or core-specific bind
                -- failure should not permanently suppress this valid upgrade.
                session.promptedUpgrades[pendingEquip.itemLink] = nil
            end
        end
        QueueUpgradeScan(0.4)
    end
}

function addon.itemUpgrades:ScanBagUpgrades()
    if session.upgradePopupOpen or GetVisibleBindConfirmation() or InCombatLockdown() or
        UnitIsDeadOrGhost("player") or GetCursorInfo() or
        not addon.settings.profile.enableItemUpgrades or
        not addon.settings.profile.enableTips then return end

    local present = {}
    local bestOffer, bestIncrease
    local needsItemInfoRetry
    local firstBag = _G.BACKPACK_CONTAINER or 0
    local lastBag = _G.NUM_BAG_SLOTS or _G.NUM_BAG_FRAMES or 4
    for bag = firstBag, lastBag do
        for bagSlot = 1, GetContainerNumSlots(bag) do
            local itemLink = GetContainerItemLink(bag, bagSlot)
            if itemLink then
                present[itemLink] = true
                if not session.promptedUpgrades[itemLink] then
                    local comparison, state, reason = self:GetBestUpgradeComparison(itemLink)
                    local increase = GetComparisonIncrease(comparison)
                    if reason == "query failed" then
                        -- A cached non-equipment/future-level item also returns no
                        -- comparison; retry only while the item itself is absent
                        -- from the client cache.
                        local cachedName = GetItemInfo(itemLink)
                        if not cachedName then needsItemInfoRetry = true end
                    end
                    if state == "upgrade" and comparison and
                        type(comparison.SlotCompared) == "number" and
                        not IsSuppressedHandReversal(itemLink, comparison) and
                        increase > 0 and
                        (not bestIncrease or increase > bestIncrease) then
                        bestIncrease = increase
                        bestOffer = {
                            bag = bag,
                            bagSlot = bagSlot,
                            itemLink = itemLink,
                            comparison = comparison,
                            increase = increase
                        }
                    end
                end
            end
        end
    end

    for itemLink in pairs(session.promptedUpgrades) do
        if not present[itemLink] then session.promptedUpgrades[itemLink] = nil end
    end
    for itemLink in pairs(session.suppressedHandReversals) do
        if not present[itemLink] then
            session.suppressedHandReversals[itemLink] = nil
        end
    end

    if addon.inventoryManager and
        addon.inventoryManager.RefreshJunkIcons then
        addon.inventoryManager.RefreshJunkIcons(0.05)
    end

    if not bestOffer then
        -- GetItemInfo/tooltip data is asynchronous on 3.3.5, particularly for
        -- newly looted expansion items. Recheck for a short bounded window even
        -- on clients which do not implement GET_ITEM_INFO_RECEIVED.
        if needsItemInfoRetry and session.upgradeQueryRetries < 8 then
            session.upgradeQueryRetries = session.upgradeQueryRetries + 1
            QueueUpgradeScan(0.5)
        else
            session.upgradeQueryRetries = 0
        end
        return
    end
    session.upgradeQueryRetries = 0
    session.promptedUpgrades[bestOffer.itemLink] = true
    local oldItem = bestOffer.comparison.ItemLink
    if not oldItem or oldItem == _G.EMPTY or oldItem == _G.NONE then
        oldItem = _G.EMPTY
    end
    local gain = fmt("+%.2f EP", bestOffer.increase)
    if bestOffer.comparison.Ratio then
        gain = fmt("%s (%s)", gain,
                   prettyPrintRatio(bestOffer.comparison.Ratio))
    end
    local message = fmt("%s\n\n%s\n\n%s: %s\n%s", _G.ITEM_UPGRADE,
                        bestOffer.itemLink, L("Replace"), oldItem, gain)
    local popup = _G.StaticPopup_Show("RXPItemUpgradeFound", message, nil,
                                      bestOffer)
    if not popup then
        session.promptedUpgrades[bestOffer.itemLink] = nil
        QueueUpgradeScan(1)
    end
end

QueueUpgradeScan = function(delay)
    if not session.isInitialized then return end
    session.upgradeScanSerial = session.upgradeScanSerial + 1
    local serial = session.upgradeScanSerial
    C_Timer.After(delay or 0.25, function()
        if serial == session.upgradeScanSerial then
            addon.itemUpgrades:ScanBagUpgrades()
        end
    end)
end

function addon.itemUpgrades:UPGRADE_INVENTORY_CHANGED()
    session.upgradeQueryRetries = 0
    QueueUpgradeScan(0.25)
end

function addon.itemUpgrades:UPGRADE_EQUIPMENT_CHANGED()
    -- Let the legacy inventory API settle before recording the old -> new hand
    -- transition and rescanning the displaced bag item.
    C_Timer.After(0, function()
        RefreshHandReplacementState()
        wipe(session.promptedUpgrades)
        QueueUpgradeScan(0.25)
        if addon.inventoryManager and
            addon.inventoryManager.RefreshJunkIcons then
            addon.inventoryManager.RefreshJunkIcons(0.05)
        end
    end)
end

function addon.itemUpgrades:UPGRADE_ITEM_INFO_RECEIVED(_, _, success)
    if success then
        session.upgradeQueryRetries = 0
        QueueUpgradeScan(0.25)
    end
end

function addon.itemUpgrades.Test()
    local itemData
    local testData = {
        ['CLASSIC'] = {
            ['WARRIOR'] = {16886, 7719, 9379, 9479, 12927, 12929, 12963, 18298, 11907, 13052, 20703},
            ['SHAMAN'] = {892, 14136, 16923, 6324, 209671}
        },
        ['CATA'] = {['WARRIOR'] = {11820, 35042, 35916, 63827, 66884, 66933}, ['SHAMAN'] = {14136, 16923, 199329}}
    }

    addon.itemUpgrades.testItems = {}
    for _, itemID in pairs(testData[addon.game][addon.player.class]) do
        print('----- ' .. itemID)
        itemData = addon.itemUpgrades:GetItemData("item:" .. itemID)

        if itemData then addon.itemUpgrades.testItems[itemData.itemID] = itemData end

        if addon.settings.profile.debug and itemData then
            for key, value in pairs(itemData) do print('  ', key, value) end
            print('  stats:')
            for key, value in pairs(itemData.stats) do print('  - ', key, value) end
        end
    end
end

local CanSendAuctionQuery, QueryAuctionItems, SetSelectedAuctionItem = _G.CanSendAuctionQuery, _G.QueryAuctionItems,
                                                                       _G.SetSelectedAuctionItem
local GetNumAuctionItems, GetAuctionItemLink, GetAuctionItemInfo = _G.GetNumAuctionItems, _G.GetAuctionItemLink,
                                                                   _G.GetAuctionItemInfo

local function GetAuctionListData(index)
    local name, texture, count, quality, canUse, level, levelColHeader,
          minBid, minIncrement, buyoutPrice, bidAmount, highBidder =
        GetAuctionItemInfo("list", index)
    local itemLink = GetAuctionItemLink("list", index)
    -- Stock 3.3.5 GetAuctionItemInfo has no itemID return; modern clients do.
    -- Parsing the hyperlink works on both and avoids depending on core-added
    -- return values.
    local itemID = itemLink and tonumber(smatch(itemLink, "item:(%d+)"))
    return itemLink, name, texture, count, quality, canUse, level,
           levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount,
           highBidder, itemID
end

local AuctionFilterButtons = {["Weapons"] = 1, ["Armor"] = 2}

local ahSession = {
    isInitialized = false,
    infoItemsReceived = {}, -- takes itemID, not itemLinks

    -- Cannot cache to RXPCData, because comparisons are mutable and embedded in weighting
    scanData = {},

    scanPage = 0,
    scanResults = 0,
    scanType = AuctionFilterButtons["Armor"],

    selectedRow = nil,
    queryRetries = 0,
    itemRetries = 0,
    scanSerial = 0,
    cancelled = false,
    maxPages = 50
}

addon.itemUpgrades.AH = addon:NewModule("ItemUpgradesAH", "AceEvent-3.0")

function addon.itemUpgrades.AH:Setup()
    if addon.game == "CATA" or
        (addon.game == "WOTLK" and addon.gameVersion ~= 30300) then return end

    local enabled = addon.settings.profile.enableTips and
                        addon.settings.profile.enableItemUpgrades and
                        addon.settings.profile.enableItemUpgradesAH
    if not enabled then
        if ahSession.isInitialized then
            self:UnregisterAllEvents()
            ahSession.isInitialized = false
        end
        if ahSession.tabButton then ahSession.tabButton:Hide() end
        if ahSession.displayFrame then ahSession.displayFrame:Hide() end
        return
    end

    if ahSession.tabButton then ahSession.tabButton:Show() end

    if ahSession.isInitialized then return end

    self:RegisterEvent("AUCTION_HOUSE_SHOW")
    self:RegisterEvent("AUCTION_HOUSE_CLOSED")

    self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")

    ahSession.isInitialized = true
    if _G.AuctionFrame and _G.AuctionFrame:IsShown() then self:CreateEmbeddedGui() end
end

function addon.itemUpgrades.AH:AUCTION_HOUSE_SHOW() self:CreateEmbeddedGui() end

function addon.itemUpgrades.AH:AUCTION_HOUSE_CLOSED()

    -- Reset session
    ahSession.sentQuery = false
    ahSession.scanPage = 0
    ahSession.scanResults = 0
    ahSession.scanType = AuctionFilterButtons["Armor"]
    ahSession.cancelled = true
    ahSession.scanSerial = ahSession.scanSerial + 1
    ahSession.queryRetries = 0
    ahSession.itemRetries = 0
    if ahSession.displayFrame and ahSession.displayFrame.scanButton then
        ahSession.displayFrame.scanButton:SetText(_G.SEARCH)
        ahSession.displayFrame.scanButton:Enable()
    end
    if ahSession.displayFrame and ahSession.displayFrame.cancelButton then
        ahSession.displayFrame.cancelButton:Disable()
    end
end

function addon.itemUpgrades.AH:CancelScan(message)
    ahSession.cancelled = true
    ahSession.sentQuery = false
    ahSession.scanSerial = ahSession.scanSerial + 1
    ahSession.queryRetries = 0
    ahSession.itemRetries = 0
    if ahSession.displayFrame and ahSession.displayFrame.scanButton then
        ahSession.displayFrame.scanButton:SetText(_G.SEARCH or "Search")
        ahSession.displayFrame.scanButton:Enable()
    end
    if ahSession.displayFrame and ahSession.displayFrame.cancelButton then
        ahSession.displayFrame.cancelButton:Disable()
    end
    if message then addon.comms.PrettyPrint(message) end
end

-- Fired when GetItemInfo queries the server for an uncached item and the reponse has arrived.
function addon.itemUpgrades.AH:GET_ITEM_INFO_RECEIVED(_, itemID, success)
    if not success then return end

    if ahSession.infoItemsReceived[itemID] then return end

    -- If item queried, it's probably applicable to ItemUpgrades, so build and cache
    -- TODO ensure no infinite loop
    addon.itemUpgrades:GetItemData("item:" .. itemID)
    ahSession.infoItemsReceived[itemID] = true
end

-- Helper function for scanning.xml RXP_IU_AH_BuyButton:OnClick
function addon.itemUpgrades.AH:SearchForSelectedItem()
    if not ahSession.selectedRow or not ahSession.selectedRow.nodeData then return end
    return self:SearchForBuyoutItem(ahSession.selectedRow.nodeData)
end

function addon.itemUpgrades.AH:SearchForBuyoutItem(itemData)
    if not itemData.Name then return end

    if not _G.AuctionFrame:IsShown() then return end

    -- print("SearchForBuyoutItem", itemData.itemLink)

    if _G.BrowseResetButton then _G.BrowseResetButton:Click() end

    _G.BrowseName:SetText(addon.gameVersion == 30300 and itemData.Name or
                              ('"' .. itemData.Name .. '"'))

    if itemData.ItemLevel then
        _G.BrowseMinLevel:SetText(itemData.ItemLevel)
        _G.BrowseMaxLevel:SetText(itemData.ItemLevel)
    end

    -- Sort to make item very likely on first page
    -- sortTable, sortColumn, oppositeOrder
    _G.AuctionFrame_SetSort("list", "bid", false);
    _G.AuctionFrameTab1:Click()

    -- Pre-populates UI, so let user retry if server overloaded
    if CanSendAuctionQuery() then
        session.sentQuery = true
        _G.AuctionFrameBrowse_Search()
    end

    -- Results get processed async by AUCTION_ITEM_LIST_UPDATE
end

function addon.itemUpgrades.AH:FindItemAuction(itemData, recursive)
    if not itemData then
        -- print("FindItemAuction error: itemData nil")
        return
    end
    if not (itemData.ItemID and itemData.ItemLink and itemData.BuyoutMoney) then return end

    local resultCount, totalAuctions = GetNumAuctionItems("list")

    if resultCount == 0 then
        -- print("FindItemAuction no results, recursive =", recursive)
        return
    end

    -- print("FindItemAuction", itemData.Name, resultCount)
    local itemLink, buyoutPrice, itemID

    for i = 1, resultCount do
        itemLink, _, _, _, _, _, _, _, _, _, buyoutPrice, _, _, itemID =
            GetAuctionListData(i)
        -- print("Evaluating", i, itemLink, buyoutPrice)

        if itemID == itemData.ItemID and itemLink == itemData.ItemLink and buyoutPrice == itemData.BuyoutMoney then
            SetSelectedAuctionItem("list", i)
            return i
        end

    end

    -- Rely on BrowseNextPageButton:IsEnabled() for easy pagination handling
    if _G.BrowseNextPageButton:IsEnabled() then
        -- If next button is enabled, and we're down here; then auction not found
        -- Additionally, the next page button is disabled on final page, so no need to track count
        _G.BrowseNextPageButton:Click()
        return self:FindItemAuction(itemData, true)
    else
        -- If next page not enabled, and we're here; then no results at all
        -- print("FindItemAuction no matches in", totalAuctions, "results")
        return nil
    end
end

-- Triggers each time the scroll panel is updated
-- Scrolling, initial population
-- Blizzard's standard auction house view overcomes this problem by reacting to AUCTION_ITEM_LIST_UPDATE and re-querying the items.
function addon.itemUpgrades.AH:AUCTION_ITEM_LIST_UPDATE()
    -- TODO prevent overwriting/blocking full scan
    if ahSession.selectedRow and ahSession.selectedRow.nodeData then
        self:FindItemAuction(ahSession.selectedRow.nodeData)
    end

    if not ahSession.sentQuery then return end

    local resultCount, totalAuctions = GetNumAuctionItems("list")
    -- print("AUCTION_ITEM_LIST_UPDATE", resultCount, totalAuctions)

    ahSession.displayFrame.scanButton:SetText(_G.SEARCHING)

    if resultCount == 0 or totalAuctions == 0 then
        ahSession.sentQuery = false
        ahSession.scanPage = 0 -- TODO show scanPage on UI

        if ahSession.scanType == AuctionFilterButtons["Armor"] then
            ahSession.scanType = AuctionFilterButtons["Weapons"] -- weapons
            self:Scan()
        else
            ahSession.scanType = AuctionFilterButtons["Armor"]
            self:Analyze()
            ahSession.displayFrame.scanButton:SetText(_G.SEARCH)
            ahSession.displayFrame.scanButton:Enable()
            if ahSession.displayFrame.cancelButton then
                ahSession.displayFrame.cancelButton:Disable()
            end
            self:DisplayEmbeddedResults()
        end

        return
    end

    local itemLink
    local name, texture, level, buyoutPrice, itemID

    for i = 1, resultCount do
        itemLink, name, texture, _, _, _, level, _, _, _, buyoutPrice, _, _,
            itemID = GetAuctionListData(i)

        -- TODO if not hasAllInfo
        if itemLink and itemID and buyoutPrice and buyoutPrice > 0 and
            ahSession.scanData[itemLink] then
            if buyoutPrice < ahSession.scanData[itemLink].lowestPrice then
                ahSession.scanData[itemLink].lowestPrice = buyoutPrice
            end
        elseif itemLink and itemID and buyoutPrice and buyoutPrice > 0 then
            ahSession.scanData[itemLink] = {
                name = name,
                lowestPrice = buyoutPrice,
                itemID = itemID,
                level = level,
                scanType = ahSession.scanType, -- TODO propagate scanType for proper filters
                itemIcon = texture
            }
        end

        -- print("scan", itemLink, itemID, hasAllInfo, buyoutPrice)
    end

    ahSession.sentQuery = false

    ahSession.scanPage = ahSession.scanPage + 1

    ahSession.scanResults = ahSession.scanResults + resultCount

    self:Scan()
end

function addon.itemUpgrades.AH:Scan()
    -- Prevent double calls
    if ahSession.sentQuery or ahSession.cancelled then return end
    if not _G.AuctionFrame or not _G.AuctionFrame:IsShown() then return end
    if addon.gameVersion ~= 30300 and not AuctionCategories then return end -- AH frame isn't loaded yet

    -- TODO use better queueing
    -- TODO abort on multiple retries
    if not CanSendAuctionQuery() then
        -- print("addon.itemUpgrades.AH:Scan() - queued", ahSession.scanPage, ahSession.scanType)

        ahSession.queryRetries = (ahSession.queryRetries or 0) + 1
        if ahSession.queryRetries > 12 then
            self:CancelScan("Auction upgrade scan stopped after repeated server query delays.")
            return
        end
        local serial = ahSession.scanSerial
        C_Timer.After(0.35, function()
            if serial == ahSession.scanSerial then self:Scan() end
        end)
        return
    end
    ahSession.queryRetries = 0
    if ahSession.scanPage >= ahSession.maxPages then
        ahSession.sentQuery = false
        if ahSession.scanType == AuctionFilterButtons["Armor"] then
            ahSession.scanType = AuctionFilterButtons["Weapons"]
            ahSession.scanPage = 0
            self:Scan()
        else
            ahSession.scanType = AuctionFilterButtons["Armor"]
            self:Analyze()
            if ahSession.displayFrame and ahSession.displayFrame.scanButton then
                ahSession.displayFrame.scanButton:SetText(_G.SEARCH)
                ahSession.displayFrame.scanButton:Enable()
            end
            if ahSession.displayFrame and ahSession.displayFrame.cancelButton then
                ahSession.displayFrame.cancelButton:Disable()
            end
            self:DisplayEmbeddedResults()
        end
        return
    end
    -- print("addon.itemUpgrades.AH:Scan()", ahSession.scanType, ahSession.scanPage)

    -- TODO remove debugging +15
    -- TODO reset usable = true

    local maxLevel = UnitLevel("player") -- + 15

    ahSession.sentQuery = true

    if addon.gameVersion == 30300 then
        -- 3.3.5 signature: name, minLevel, maxLevel, invType, class,
        -- subclass, page, usable, quality, getAll. Weapon and armor are the
        -- first two legacy AH class categories.
        QueryAuctionItems("", math.max(0, maxLevel - 5), maxLevel, nil,
                          ahSession.scanType, nil, ahSession.scanPage, true,
                          Enum.ItemQuality.Uncommon, false)
    else
        -- text, minLevel, maxLevel, page, usable, rarity, getAll, exactMatch, filterData
        QueryAuctionItems("", maxLevel - 5, maxLevel, ahSession.scanPage, true,
                          Enum.ItemQuality.Uncommon, false, false,
                          AuctionCategories[ahSession.scanType].filters)
    end
end

local function calculate(itemLink, scanData)
    if scanData.lowestPrice <= 0 then return true end
    local itemData = addon.itemUpgrades:GetItemData("item:" .. scanData.itemID)

    -- Should only have queried usable items, so not intentionally nil
    if not itemData then
        GetItemInfo("item:" .. scanData.itemID)
        return false
    end

    scanData.totalWeight = itemData.totalWeight
    scanData.weightPerCopper = itemData.totalWeight / scanData.lowestPrice
    scanData.itemEquipLoc = itemData.itemEquipLoc
    local comparison, state = addon.itemUpgrades:GetBestUpgradeComparison(itemLink)
    scanData.comparison = comparison
    scanData.state = state or "unknown"
    if state ~= "upgrade" or not comparison then
        scanData.ratio = 0
        scanData.relativeWeightPerCopper = nil
        scanData.weightIncrease = 0
        return true
    end
    -- The shared comparison is the complete-layout solver used by bags and
    -- quest rewards, including two-hand/off-hand and duplicate-slot layouts.
    local increase = GetComparisonIncrease(comparison)
    scanData.ratio = tonumber(comparison.Ratio) or increase
    scanData.relativeWeightPerCopper = increase / scanData.lowestPrice
    scanData.weightIncrease = increase
    return true
end

local function analyzeSlotUpgrade(scanData, itemLink, bAS)
    -- Empty slot, so the rest of this won't handle itself
    if not bAS then return end

    if scanData.ratio and scanData.ratio > bAS.best.ratio then
        bAS.best.ratio = scanData.ratio
        bAS.best.itemLink = itemLink
        bAS.best.itemID = scanData.itemID
        bAS.best.itemIcon = scanData.itemIcon
        bAS.best.name = scanData.name
        bAS.best.level = scanData.level
        bAS.best.weightIncrease = scanData.weightIncrease
        bAS.best.totalWeight = scanData.totalWeight

        bAS.best.lowestPrice = ahSession.scanData[itemLink].lowestPrice
    end

    -- Done processing, is empty slot
    if not scanData.relativeWeightPerCopper then return true end

    if scanData.relativeWeightPerCopper > bAS.budget.rwpc then
        bAS.budget.ratio = scanData.ratio
        bAS.budget.rwpc = scanData.relativeWeightPerCopper
        bAS.budget.itemLink = itemLink
        bAS.budget.itemID = scanData.itemID
        bAS.budget.itemIcon = scanData.itemIcon
        bAS.budget.name = scanData.name
        bAS.budget.level = scanData.level
        bAS.budget.weightIncrease = scanData.weightIncrease
        bAS.budget.totalWeight = scanData.totalWeight

        bAS.budget.lowestPrice = ahSession.scanData[itemLink].lowestPrice
    end

    -- Finished processing, not an empty character slot
    return true
end

-- Because of processing sequencing, override some names for UI
local function getAHSlotName(invEquipType)
    if invEquipType == 'INVTYPE_THROWN' then
        return _G['INVTYPE_RANGED']
    elseif invEquipType == 'INVTYPE_HOLDABLE' then
        return _G['INVTYPE_WEAPONOFFHAND']
    end

    return _G[invEquipType]
end

function addon.itemUpgrades.AH:Analyze()
    ahSession.bestAnalysis = {}

    -- We already know all of this is usable, so just care about slots
    for invEquipType, _ in pairs(session.equippableSlots) do
        ahSession.bestAnalysis[invEquipType] = {
            slotName = getAHSlotName(invEquipType),
            best = {ratio = 0, lowestPrice = 0, itemLink = nil}, -- Biggest upgrade ratio
            budget = {rwpc = 0, lowestPrice = 0, itemLink = nil} -- Biggest upgrade ratio / copper
        }
    end

    local bAS

    local pending = 0
    for itemLink, scanData in pairs(ahSession.scanData) do
        if not calculate(itemLink, scanData) then pending = pending + 1 end

        bAS = ahSession.bestAnalysis[scanData.itemEquipLoc]
        -- print("Analyze", itemLink, "weightPerCopper",
        --      scanData.weightPerCopper, "relativeWPC",
        --      scanData.relativeWeightPerCopper, "ratio", scanData.ratio)
        analyzeSlotUpgrade(scanData, itemLink, bAS)
    end
    if pending > 0 and not ahSession.cancelled and ahSession.itemRetries < 8 then
        ahSession.itemRetries = ahSession.itemRetries + 1
        local serial = ahSession.scanSerial
        C_Timer.After(0.25, function()
            if serial == ahSession.scanSerial and not ahSession.cancelled then
                addon.itemUpgrades.AH:Analyze()
                addon.itemUpgrades.AH:DisplayEmbeddedResults()
            end
        end)
    end
end

function addon.itemUpgrades.AH:GetAdvisorResults()
    local output = {}
    for itemLink, data in pairs(ahSession.scanData or {}) do
        if data.state == "upgrade" and (data.weightIncrease or 0) > 0 then
            output[#output + 1] = {
                link = itemLink, name = data.name, state = data.state,
                increase = data.weightIncrease,
                epPerCopper = data.relativeWeightPerCopper or 0,
                comparison = data.comparison,
                reason = "AH: " .. tostring(data.lowestPrice or 0) .. " copper",
                auctionData = {
                    Name = data.name, ItemLink = itemLink,
                    ItemID = data.itemID, BuyoutMoney = data.lowestPrice,
                    ItemLevel = data.level
                }
            }
        end
    end
    table.sort(output, function(a, b)
        if a.epPerCopper ~= b.epPerCopper then
            return a.epPerCopper > b.epPerCopper
        end
        return a.increase > b.increase
    end)
    return output
end

-- TODO get parent frame names instead
local buyoutIncr = 0
-- SmallMoneyFrameTemplate doesn't handle parentKey well in .xml, moved to Lua
local function createBuyoutFrame(buyout, buyoutMoney)
    if not buyout then
        -- print("createBuyoutFrame: error", buyout)
        return
    end

    if buyout.Money then return end

    buyout.Money = CreateFrame("Frame", "$parentMoneyFrame" .. buyoutIncr, buyout, "SmallMoneyFrameTemplate")
    buyoutIncr = buyoutIncr + 1
    buyout.Money:SetPoint("RIGHT", 0, -6)

    buyout.Money.staticMoney = buyoutMoney

    MoneyFrame_SetType(buyout.Money, "AUCTION")
end

local function updateBuyoutFrame(buyout, buyoutMoney)
    buyout.Money.staticMoney = buyoutMoney
    MoneyFrame_Update(buyout.Money, buyoutMoney)

    buyout.Label:SetPoint("RIGHT", buyout.Money, "LEFT")
end

local function setKindIcon(frame, image)
    if not frame or not image then
        -- print("setKindIcon: error", frame, image)
        return
    end

    if frame.KindIcon then return end

    frame.KindIcon = frame:CreateTexture(nil, 'OVERLAY')
    frame.KindIcon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    frame.KindIcon:SetSize(16, 16)
    frame.KindIcon:SetTexture(image)
end

local function getColorizedName(itemLink, itemName)
    if not (itemLink and itemName) then return end
    local quality = C_Item.GetItemQualityByID(itemLink)
    if quality then
        local h = ITEM_QUALITY_COLORS[quality].hex

        return h .. itemName .. '|r'
    end

    return itemName
end

local function prettyPrintUpgradeColumn(data)
    -- print("data.ratio", data.ratio, "prettyPrintRatio(data.ratio)",
    --      prettyPrintRatio(data.ratio), "addon.Round(data.weightIncrease, 2))",
    --      addon.Round(data.weightIncrease, 2))

    if data.ratio < 0 then return fmt("%s / +%s EP (BIS)", _G.EMPTY, addon.Round(data.weightIncrease, 2)) end

    return fmt("%s / +%s EP (BIS)", prettyPrintRatio(data.ratio), addon.Round(data.weightIncrease, 2))
end

local function prettyPrintBudgetColumn(data)
    if data.ratio < 0 then return fmt("%s / +%s EP (BIS)", _G.EMPTY, addon.Round(data.weightIncrease, 2)) end

    return fmt("%s / +%s EP (EP/%s)", prettyPrintRatio(data.ratio), addon.Round(data.weightIncrease, 2), _G.ICON_TAG_RAID_TARGET_STAR3)
end

function addon.itemUpgrades.AH.RowOnEnter(row)
    if ahSession.selectedRow == row then return end
    row:LockHighlight()
end

function addon.itemUpgrades.AH.RowOnLeave(row)
    if ahSession.selectedRow == row then return end
    row:UnlockHighlight()
end

function addon.itemUpgrades.AH.RowOnClick(this)
    -- print("row:OnClick", this.nodeData.ItemID, this.nodeData.Name, this.nodeData.BuyoutMoney)

    if ahSession.selectedRow == this then
        ahSession.selectedRow = nil
        this:UnlockHighlight()
        _G.RXP_IU_AH_BuyButton:Disable()
    else
        -- Remove previous locked highlight
        if ahSession.selectedRow then ahSession.selectedRow:UnlockHighlight() end
        ahSession.selectedRow = this
        this:LockHighlight()

        if this.nodeData.BuyoutMoney <= GetMoney() then
            _G.RXP_IU_AH_BuyButton:Enable()
        else
            _G.RXP_IU_AH_BuyButton:Disable()
        end
    end
end

local function Initializer(frame, data)
    frame.Header.Name:SetText(data.Name)

    local d = data.best
    if d then
        local f = frame.Best

        f.nodeData = d -- TODO minimize reference
        f.ItemLink = d.ItemLink
        f.ItemID = d.ItemID
        f.Name:SetText(d.ColorizedName)
        f.ItemLevel.Text:SetText(d.ItemLevel)
        f.UpdateEP.Text:SetText(d.UpdateEPText)
        f.ItemIcon:SetNormalTexture(d.ItemIcon)
        setKindIcon(f.ItemIcon, d.ItemKindIcon)

        createBuyoutFrame(f.Buyout, d.BuyoutMoney)
        updateBuyoutFrame(f.Buyout, d.BuyoutMoney)

        f:Show()
    else
        frame.Best:Hide()
    end

    -- Won't be populated if best == budget items
    d = data.budget
    if data.budget then
        local f = frame.Budget

        f.nodeData = d
        f.ItemLink = d.ItemLink
        f.ItemID = d.ItemID
        f.Name:SetText(d.ColorizedName)
        f.ItemLevel.Text:SetText(d.ItemLevel)
        f.UpdateEP.Text:SetText(d.UpdateEPText)
        f.ItemIcon:SetNormalTexture(d.ItemIcon)
        setKindIcon(f.ItemIcon, d.ItemKindIcon)

        createBuyoutFrame(f.Buyout)
        updateBuyoutFrame(f.Buyout, d.BuyoutMoney)

        f:Show()
    else
        frame.Budget:Hide()
    end
end

local function CustomFactory(factory, node)
    local data = node:GetData()
    local template = data.Template
    factory(template, Initializer)
end

local LEGACY_AH_BLOCK_HEIGHT = 72
local LEGACY_AH_VISIBLE_BLOCKS = 4

local function CreateLegacyAHRow(parent, yOffset)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(770, 26)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    row:RegisterForClicks("LeftButtonUp")

    row.Icon = row:CreateTexture(nil, "ARTWORK")
    row.Icon:SetSize(24, 24)
    row.Icon:SetPoint("LEFT", 2, 0)
    row.KindIcon = row:CreateTexture(nil, "OVERLAY")
    row.KindIcon:SetSize(11, 11)
    row.KindIcon:SetPoint("BOTTOMRIGHT", row.Icon, "BOTTOMRIGHT", 1, -1)

    row.Name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Name:SetSize(205, 24)
    row.Name:SetPoint("LEFT", 31, 0)
    row.Name:SetJustifyH("LEFT")
    row.Level = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Level:SetSize(62, 24)
    row.Level:SetPoint("LEFT", 245, 0)
    row.Upgrade = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Upgrade:SetSize(245, 24)
    row.Upgrade:SetPoint("LEFT", 315, 0)
    row.Upgrade:SetJustifyH("LEFT")
    row.Buyout = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.Buyout:SetSize(185, 24)
    row.Buyout:SetPoint("RIGHT", -2, 0)
    row.Buyout:SetJustifyH("RIGHT")

    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(true)
    highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    highlight:SetBlendMode("ADD")
    row:SetHighlightTexture(highlight)

    row:SetScript("OnEnter", function(this)
        if this.ItemLink then
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(this.ItemLink)
            GameTooltip:Show()
        end
        addon.itemUpgrades.AH.RowOnEnter(this)
    end)
    row:SetScript("OnLeave", function(this)
        addon.itemUpgrades.AH.RowOnLeave(this)
        GameTooltip:Hide()
    end)
    row:SetScript("OnClick", function(this)
        if this.nodeData then addon.itemUpgrades.AH.RowOnClick(this) end
    end)
    return row
end

local function CreateLegacyAHBlock(parent, index)
    local block = CreateFrame("Frame", nil, parent)
    block:SetSize(770, LEGACY_AH_BLOCK_HEIGHT)
    block:SetPoint("TOPLEFT", parent, "TOPLEFT", 22,
                   -78 - (index - 1) * LEGACY_AH_BLOCK_HEIGHT)

    local headerBG = block:CreateTexture(nil, "BACKGROUND")
    headerBG:SetTexture("Interface\\Buttons\\WHITE8X8")
    headerBG:SetVertexColor(0.16, 0.12, 0.08, 0.82)
    headerBG:SetPoint("TOPLEFT", 0, 0)
    headerBG:SetPoint("TOPRIGHT", 0, 0)
    headerBG:SetHeight(18)

    block.Header = block:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    block.Header:SetPoint("TOPLEFT", 5, -2)
    block.Header:SetJustifyH("LEFT")
    block.Best = CreateLegacyAHRow(block, -18)
    block.Budget = CreateLegacyAHRow(block, -44)
    return block
end

local function PopulateLegacyAHRow(row, data)
    if not data then
        row.nodeData = nil
        row.ItemLink = nil
        row:Hide()
        return
    end

    row.nodeData = data
    row.ItemLink = data.ItemLink
    row.Icon:SetTexture(data.ItemIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
    row.Icon:SetTexCoord(0, 1, 0, 1)
    row.KindIcon:SetTexture(data.ItemKindIcon)
    row.KindIcon:SetTexCoord(0, 1, 0, 1)
    row.Name:SetText(data.ColorizedName or data.Name or "")
    row.Level:SetText(data.ItemLevel or "")
    row.Upgrade:SetText(data.UpdateEPText or "")
    if _G.GetCoinTextureString then
        row.Buyout:SetText(_G.GetCoinTextureString(data.BuyoutMoney or 0))
    else
        row.Buyout:SetText(tostring(data.BuyoutMoney or 0))
    end
    row:Show()
end

function addon.itemUpgrades.AH:RefreshLegacyResults()
    local frame = ahSession.displayFrame
    if not frame or not frame.legacyScroll then return end

    if ahSession.selectedRow then
        ahSession.selectedRow:UnlockHighlight()
        ahSession.selectedRow = nil
        if _G.RXP_IU_AH_BuyButton then _G.RXP_IU_AH_BuyButton:Disable() end
    end

    local data = ahSession.legacyData or {}
    _G.FauxScrollFrame_Update(frame.legacyScroll, #data,
                              LEGACY_AH_VISIBLE_BLOCKS,
                              LEGACY_AH_BLOCK_HEIGHT)
    local offset = _G.FauxScrollFrame_GetOffset(frame.legacyScroll)
    for index, block in ipairs(frame.legacyBlocks) do
        local blockData = data[offset + index]
        if blockData then
            block.Header:SetText(blockData.Name or "")
            PopulateLegacyAHRow(block.Best, blockData.best)
            PopulateLegacyAHRow(block.Budget, blockData.budget)
            block:Show()
        else
            block:Hide()
        end
    end
end

function addon.itemUpgrades.AH:CreateLegacyEmbeddedGui()
    if ahSession.displayFrame then return end
    local attachment = _G.AuctionFrame
    if not attachment or not _G.FauxScrollFrame_Update then return end

    local frame = CreateFrame("Frame", "RXP_IU_AH_Frame", attachment)
    frame:SetPoint("TOPLEFT", attachment, "TOPLEFT", 0, 0)
    frame:SetPoint("BOTTOMRIGHT", attachment, "BOTTOMRIGHT", 0, 0)
    frame:SetFrameLevel(attachment:GetFrameLevel() + 8)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    frame:SetBackdropColor(0.04, 0.035, 0.025, 0.98)
    frame:Hide()
    ahSession.displayFrame = frame
    ahSession.legacyData = ahSession.legacyData or {}

    local title = frame:CreateFontString("RXP_IU_AH_Title", "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -18)
    title:SetText(fmt("%s - %s", addon.title,
                      _G.MINIMAP_TRACKING_AUCTIONEER or "Auction House"))

    local function Header(text, x, width)
        local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", frame, "TOPLEFT", x, -55)
        label:SetSize(width, 18)
        label:SetJustifyH("LEFT")
        label:SetText(text)
    end
    Header(_G.ITEM or "Item", 53, 205)
    Header(_G.REQ_LEVEL_ABBR or _G.LEVEL_ABBR or "Lvl", 267, 62)
    Header("Upgrade / EP", 337, 245)
    Header(_G.AUCTION_PRICE or _G.BUYOUT or "Buyout", 590, 185)

    frame.legacyScroll = CreateFrame("ScrollFrame",
        "RXP_IU_AH_LegacyScrollFrame", frame, "FauxScrollFrameTemplate")
    frame.legacyScroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -75)
    frame.legacyScroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 48)
    frame.legacyScroll:SetScript("OnVerticalScroll", function(scroll, offset)
        _G.FauxScrollFrame_OnVerticalScroll(scroll, offset,
            LEGACY_AH_BLOCK_HEIGHT,
            function() addon.itemUpgrades.AH:RefreshLegacyResults() end)
    end)

    frame.legacyBlocks = {}
    for index = 1, LEGACY_AH_VISIBLE_BLOCKS do
        frame.legacyBlocks[index] = CreateLegacyAHBlock(frame, index)
    end

    local close = CreateFrame("Button", "RXP_IU_AH_CloseButton", frame,
                              "UIPanelButtonTemplate")
    close:SetSize(82, 22)
    close:SetPoint("BOTTOMRIGHT", -12, 16)
    close:SetText(_G.CLOSE or "Close")
    close:SetScript("OnClick", function() HideUIPanel(attachment) end)

    local buy = CreateFrame("Button", "RXP_IU_AH_BuyButton", frame,
                            "UIPanelButtonTemplate")
    buy:SetSize(82, 22)
    buy:SetPoint("RIGHT", close, "LEFT", -3, 0)
    buy:SetText(_G.BUYOUT or "Buyout")
    buy:SetScript("OnClick", function(this)
        this:Disable()
        addon.itemUpgrades.AH:SearchForSelectedItem()
    end)
    buy:Disable()

    local search = CreateFrame("Button", "RXP_IU_AH_SearchButton", frame,
                               "UIPanelButtonTemplate")
    search:SetSize(82, 22)
    search:SetPoint("RIGHT", buy, "LEFT", -3, 0)
    search:SetText(_G.SEARCH or "Search")
    search:SetScript("OnClick", function(this)
        this:Disable()
        wipe(ahSession.scanData)
        wipe(ahSession.legacyData)
        ahSession.sentQuery = false
        ahSession.scanPage = 0
        ahSession.scanResults = 0
        ahSession.scanType = AuctionFilterButtons["Armor"]
        ahSession.cancelled = false
        ahSession.queryRetries = 0
        ahSession.itemRetries = 0
        ahSession.scanSerial = ahSession.scanSerial + 1
        if frame.cancelButton then frame.cancelButton:Enable() end
        addon.itemUpgrades.AH:RefreshLegacyResults()
        addon.itemUpgrades.AH:Scan()
    end)
    frame.scanButton = search

    local cancel = CreateFrame("Button", "RXP_IU_AH_CancelButton", frame,
                               "UIPanelButtonTemplate")
    cancel:SetSize(72, 22)
    cancel:SetPoint("RIGHT", search, "LEFT", -3, 0)
    cancel:SetText(_G.CANCEL or "Cancel")
    cancel:SetScript("OnClick", function()
        addon.itemUpgrades.AH:CancelScan("Auction upgrade scan cancelled.")
    end)
    cancel:Disable()
    frame.cancelButton = cancel

    local index = (attachment.numTabs or 3) + 1
    local tabButton = CreateFrame("Button", "AuctionFrameTab" .. index,
                                  attachment, "AuctionTabTemplate")
    ahSession.tabButton = tabButton
    tabButton.isRXP = true
    tabButton:SetText(addon.name)
    tabButton:SetID(index)
    tabButton:SetPoint("TOPLEFT", "AuctionFrameTab" .. (index - 1),
                       "TOPRIGHT", -8, 0)
    tabButton.Selected = function(this)
        PanelTemplates_SetTab(attachment, this:GetID())
        _G.AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopLeft")
        _G.AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Top")
        _G.AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopRight")
        _G.AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft")
        _G.AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot")
        _G.AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight")
        attachment.type = "list"
        _G.SetAuctionsTabShowing(false)
        PanelTemplates_SelectTab(this)
        frame:Show()
        addon.itemUpgrades.AH:RefreshLegacyResults()
    end
    hooksecurefunc(_G, "AuctionFrameTab_OnClick", function(button)
        if button and button.isRXP then
            tabButton:Selected()
        else
            frame:Hide()
            PanelTemplates_DeselectTab(tabButton)
        end
    end)

    PanelTemplates_TabResize(tabButton, 0, nil, 36)
    PanelTemplates_SetNumTabs(attachment, index)
    PanelTemplates_EnableTab(attachment, index)
end

function addon.itemUpgrades.AH:CreateEmbeddedGui()
    if addon.gameVersion == 30300 then
        return self:CreateLegacyEmbeddedGui()
    end
    if ahSession.displayFrame then return end

    local attachment = _G.AuctionFrame
    if not attachment then return end

    ahSession.displayFrame = _G["RXP_IU_AH_Frame"]
    if not ahSession.displayFrame then return end

    ahSession.displayFrame:SetParent(attachment)
    ahSession.displayFrame:SetPoint("TOPLEFT", attachment, "TOPLEFT")
    ahSession.displayFrame:SetPoint("BOTTOMRIGHT", attachment, "BOTTOMRIGHT")

    _G.RXP_IU_AH_Title:SetText(fmt("%s - %s", addon.title, _G.MINIMAP_TRACKING_AUCTIONEER))

    local ScrollBar = ahSession.displayFrame.ScrollBox.ScrollBar
    ScrollBar:SetHideIfUnscrollable(false)

    local DataProvider = CreateDataProvider()
    local ScrollView = CreateScrollBoxListLinearView()

    ScrollView:SetElementFactory(CustomFactory)
    ScrollView:SetDataProvider(DataProvider)
    ScrollView:SetElementExtent(19 + 37 * 2)

    ahSession.displayFrame.DataProvider = DataProvider

    ScrollUtil.InitScrollBoxListWithScrollBar(ahSession.displayFrame.ScrollBox, ScrollBar, ScrollView)

    ScrollView:SetElementInitializer("RXP_IU_AH_ItemBlock", Initializer)

    ScrollView:SetElementExtentCalculator(function(_, itemBlock)
        if itemBlock.best and itemBlock.budget then
            -- Header + two rows
            return 93 -- 19 + 37 * 2
        end

        -- print("SetElementExtentCalculator", itemBlock.Name, "one row")
        -- Header + one row
        return 56 -- 19 + 37
    end)

    ahSession.displayFrame.scanButton = _G.RXP_IU_AH_SearchButton

    ahSession.displayFrame.scanButton:SetScript("OnClick", function()
        ahSession.displayFrame.DataProvider:Flush()
        addon.itemUpgrades.AH:Scan()
    end)

    _G.RXP_IU_AH_BuyButton:Disable()

    -- Create tab button
    local index = attachment.numTabs + 1
    local tabButton = CreateFrame("Button", "AuctionFrameTab" .. index, attachment, "AuctionTabTemplate")
    ahSession.tabButton = tabButton
    tabButton.isRXP = true
    tabButton:SetText(addon.name)
    tabButton:SetID(index)

    tabButton:SetPoint("TOPLEFT", "AuctionFrameTab" .. (index - 1), "TOPRIGHT", -8, 0)

    tabButton:HookScript("OnHide", function() ahSession.displayFrame:Hide() end)

    tabButton.Selected = function(this)
        PanelTemplates_SetTab(attachment, this)

        _G.AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopLeft")
        _G.AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Top")
        _G.AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopRight")
        _G.AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft")
        _G.AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot")
        _G.AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight")

        ahSession.displayFrame:Show()

        _G.AuctionFrame.type = "list"
        _G.SetAuctionsTabShowing(false)
        PanelTemplates_SelectTab(this)
    end

    tabButton.Deselected = function(this)
        PanelTemplates_DeselectTab(this)
        ahSession.displayFrame:Hide()
    end

    hooksecurefunc(_G, "AuctionFrameTab_OnClick", function(button, ...)
        if not button.isRXP then
            tabButton:Deselected()
            return
        end

        tabButton:Selected()
    end)

    PanelTemplates_TabResize(tabButton, 0, nil, 36)
    PanelTemplates_SetNumTabs(attachment, index)
    PanelTemplates_EnableTab(attachment, index)
end

StaticPopupDialogs["RXPNoUpgradesFound"] = {
    text = L("No item upgrades found"),
    button1 = _G.OKAY,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    showAlert = 1
}

function addon.itemUpgrades.AH:DisplayEmbeddedResults()
    self:CreateEmbeddedGui()
    if not _G.AuctionFrame:IsShown() then return end

    if addon.gameVersion == 30300 then
        wipe(ahSession.legacyData)
    end

    local blockData
    local n = 0
    for itemEquipLoc, data in pairs(ahSession.bestAnalysis) do
        if data.budget.itemLink or data.best.itemLink then
            n = n + 1
            -- print("DisplayEmbeddedResults:", data.slotName, "processing upgrades")
            blockData = {['Name'] = data.slotName}

            -- Best upgrade
            if data.best.itemLink then
                -- print("  - DisplayEmbeddedResults best", data.best.itemLink)
                blockData.best = {
                    ItemLink = data.best.itemLink,
                    ItemID = data.best.itemID,
                    ItemKindIcon = "Interface/AddOns/" .. addonName .. "/Textures/rxp_logo-64",
                    Name = data.best.name,
                    ColorizedName = getColorizedName(data.best.itemLink, data.best.name),
                    ItemLevel = data.best.level,
                    UpdateEPText = prettyPrintUpgradeColumn(data.best),
                    TotalWeight = data.best.totalWeight,
                    BuyoutMoney = data.best.lowestPrice,
                    ItemIcon = data.best.itemIcon
                }
            end

            if data.budget.itemLink then
                -- print("  - DisplayEmbeddedResults budget", data.budget.itemLink)
                if data.best.itemLink and data.budget.itemLink and data.best.itemLink ~= data.budget.itemLink then
                    blockData.budget = {
                        ItemLink = data.budget.itemLink,
                        ItemID = data.budget.itemID,
                        ItemKindIcon = 'Interface/GossipFrame/VendorGossipIcon.blp',
                        Name = data.budget.name,
                        ColorizedName = getColorizedName(data.budget.itemLink, data.budget.name),
                        ItemLevel = data.budget.level,
                        UpdateEPText = prettyPrintBudgetColumn(data.budget),
                        TotalWeight = data.budget.totalWeight,
                        BuyoutMoney = data.budget.lowestPrice,
                        ItemIcon = data.budget.itemIcon
                    }
                end

            end

            if blockData.best or blockData.budget then
                -- print("  - DisplayEmbeddedResults inserting", blockData.Name)
                if addon.gameVersion == 30300 then
                    tinsert(ahSession.legacyData, blockData)
                else
                    ahSession.displayFrame.DataProvider:Insert(blockData)
                end
            end
        else
            -- print("DisplayEmbeddedResults:", data.slotName, "no upgrades found")
        end
    end
    if addon.gameVersion == 30300 then
        table.sort(ahSession.legacyData, function(a, b)
            return tostring(a.Name or "") < tostring(b.Name or "")
        end)
        self:RefreshLegacyResults()
    end
    if addon.gearAdvisor and addon.gearAdvisor.Refresh then
        addon.gearAdvisor:Refresh()
    end
    if n == 0 then _G.StaticPopup_Show("RXPNoUpgradesFound") end
end

-- Update icons to Brandung mockup
-- Add owner to scanData for additional buyout validation
