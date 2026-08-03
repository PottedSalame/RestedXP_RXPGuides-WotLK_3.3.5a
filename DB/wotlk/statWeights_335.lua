local _, addon = ...

if addon.game ~= "WOTLK" then return end

-- Complete Wrath coverage for ItemUpgrades. The level-bracketed TBC speedrun
-- weights remain preferable while leveling through Outland. At level 70 these
-- spec-specific sets take over so Northrend rating/stat budgets are not scored
-- with the old class-wide level-60 bracket. Death Knights use them from 55
-- because no TBC bracket exists for that class.
addon.statWeights = addon.statWeights or {}

local KEY_MAP = {
    STR = "ITEM_MOD_STRENGTH_SHORT", AGI = "ITEM_MOD_AGILITY_SHORT",
    INT = "ITEM_MOD_INTELLECT_SHORT", STA = "ITEM_MOD_STAMINA_SHORT",
    SPI = "ITEM_MOD_SPIRIT_SHORT", AP = "ITEM_MOD_ATTACK_POWER_SHORT",
    RAP = "ITEM_MOD_RANGED_ATTACK_POWER_SHORT",
    SP = "ITEM_MOD_SPELL_POWER", MP5 = "ITEM_MOD_POWER_REGEN0_SHORT",
    HIT = "ITEM_MOD_HIT_RATING_SHORT", CRIT = "ITEM_MOD_CRIT_RATING_SHORT",
    HASTE = "ITEM_MOD_HASTE_RATING_SHORT",
    EXP = "ITEM_MOD_EXPERTISE_RATING_SHORT",
    ARP = "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
    DPS = "ITEM_MOD_DAMAGE_PER_SECOND_SHORT",
    RDPS = "ITEM_MOD_DAMAGE_PER_SECOND_SHORT_RANGED",
    ARMOR = "RESISTANCE0_NAME", DEF = "ITEM_MOD_DEFENSE_SKILL_RATING_SHORT",
    DODGE = "ITEM_MOD_DODGE_RATING_SHORT", PARRY = "ITEM_MOD_PARRY_RATING_SHORT",
    BLOCK = "ITEM_MOD_BLOCK_RATING_SHORT", BLOCKV = "ITEM_MOD_BLOCK_VALUE_SHORT",
    FAP = "ITEM_MOD_FERAL_ATTACK_POWER_SHORT"
}

local function Add(className, spec, stats)
    local minLevel = className == "DeathKnight" and 55 or 70
    local data = {
        Title = className .. " " .. minLevel .. "-80 - " .. spec,
        Class = className, Spec = spec, MIN_LEVEL = minLevel, MAX_LEVEL = 80,
        Kind = "Speedrun"
    }
    for shortKey, value in pairs(stats) do
        local key = KEY_MAP[shortKey]
        if key then data[key] = value end
    end
    addon.statWeights[data.Title] = data
end

Add("DeathKnight", "Blood", {STR=.99, DPS=3.60, AP=.36, HIT=.91, EXP=.90, CRIT=.57, HASTE=.55, ARP=1, STA=.05, ARMOR=.01})
Add("DeathKnight", "Frost", {STR=.97, DPS=3.37, AP=.35, HIT=1, EXP=.81, CRIT=.45, HASTE=.28, ARP=.61, STA=.05, ARMOR=.01})
Add("DeathKnight", "Unholy", {STR=1, DPS=2.09, AP=.34, HIT=.66, EXP=.51, CRIT=.45, HASTE=.48, ARP=.32, STA=.05, ARMOR=.01})

Add("Druid", "Balance", {INT=.22, SPI=.22, SP=.66, HIT=1, CRIT=.43, HASTE=.54, STA=.05})
Add("Druid", "Feral Combat", {STR=.80, AGI=1, AP=.40, FAP=.40, HIT=.50, EXP=.50, CRIT=.55, HASTE=.35, ARP=.90, STA=.05})
Add("Druid", "Restoration", {INT=.51, SPI=.32, MP5=.73, SP=1, CRIT=.11, HASTE=.57, STA=.05})

Add("Hunter", "Beast Mastery", {AGI=.58, RDPS=2.13, AP=.30, RAP=.30, HIT=1, CRIT=.40, HASTE=.21, ARP=.28, INT=.37, STA=.05})
Add("Hunter", "Marksmanship", {AGI=.74, RDPS=3.79, AP=.32, RAP=.32, HIT=1, CRIT=.57, HASTE=.24, ARP=.40, INT=.39, STA=.05})
Add("Hunter", "Survival", {AGI=.76, RDPS=1.81, AP=.29, RAP=.29, HIT=1, CRIT=.42, HASTE=.31, ARP=.26, INT=.35, STA=.05})

Add("Mage", "Arcane", {INT=.34, SPI=.14, SP=.49, HIT=1, CRIT=.37, HASTE=.54, STA=.05})
Add("Mage", "Fire", {INT=.13, SPI=.08, SP=.46, HIT=1, CRIT=.43, HASTE=.53, STA=.05})
Add("Mage", "Frost", {INT=.16, SPI=.08, SP=.39, HIT=1, CRIT=.19, HASTE=.42, STA=.05})

Add("Paladin", "Holy", {INT=1, MP5=.88, CRIT=.46, HASTE=.35, SP=.58, STA=.05})
Add("Paladin", "Protection", {STR=.16, AGI=.60, EXP=.59, STA=1, ARMOR=.08, DEF=.45, DODGE=.55, PARRY=.30, BLOCK=.07, BLOCKV=.06})
Add("Paladin", "Retribution", {STR=.80, DPS=4.70, AGI=.32, AP=.34, HIT=1, EXP=.66, CRIT=.40, HASTE=.30, ARP=.22, SP=.09, STA=.05})

Add("Priest", "Discipline", {INT=.65, SPI=.22, MP5=.67, SP=1, CRIT=.48, HASTE=.59, STA=.05})
Add("Priest", "Holy", {INT=.69, SPI=.52, MP5=1, SP=.60, CRIT=.38, HASTE=.31, STA=.05})
Add("Priest", "Shadow", {INT=.16, SPI=.16, SP=.76, HIT=1, CRIT=.54, HASTE=.50, STA=.05})

Add("Rogue", "Assassination", {STR=.55, AGI=1, DPS=1.70, AP=.65, HIT=.83, EXP=.87, CRIT=.81, HASTE=.64, ARP=.65, STA=.05})
Add("Rogue", "Combat", {STR=.55, AGI=1, DPS=2.20, AP=.50, HIT=.80, EXP=.82, CRIT=.75, HASTE=.73, ARP=1, STA=.05})
Add("Rogue", "Subtlety", {STR=.55, AGI=1, DPS=2.28, AP=.50, HIT=.80, EXP=1, CRIT=.75, HASTE=.75, ARP=.75, STA=.05})

Add("Shaman", "Elemental", {INT=.11, SP=.60, HIT=1, CRIT=.40, HASTE=.56, STA=.05})
Add("Shaman", "Enhancement", {STR=.35, AGI=.55, DPS=1.35, AP=.32, HIT=1, EXP=.84, CRIT=.55, HASTE=.42, ARP=.26, INT=.55, SP=.29, STA=.05})
Add("Shaman", "Restoration", {INT=.85, MP5=1, SP=.77, CRIT=.62, HASTE=.35, STA=.05})

Add("Warlock", "Affliction", {INT=.15, SPI=.34, SP=.72, HIT=1, CRIT=.38, HASTE=.61, STA=.05})
Add("Warlock", "Demonology", {INT=.13, SPI=.29, SP=.45, HIT=1, CRIT=.31, HASTE=.50, STA=.05})
Add("Warlock", "Destruction", {INT=.13, SPI=.26, SP=.47, HIT=1, CRIT=.16, HASTE=.46, STA=.05})

Add("Warrior", "Arms", {STR=1, AGI=.65, DPS=4, AP=.45, HIT=.90, EXP=.85, CRIT=.80, HASTE=.50, ARP=.65, STA=.05, ARMOR=.01})
Add("Warrior", "Fury", {STR=.82, AGI=.53, DPS=3.5, AP=.31, HIT=.48, EXP=1, CRIT=.66, HASTE=.36, ARP=.52, STA=.05, ARMOR=.05})
Add("Warrior", "Protection", {STR=.48, AGI=.67, DPS=1, AP=.01, HIT=.10, EXP=.19, CRIT=.07, HASTE=.01, ARP=.10, STA=1, ARMOR=.06, DEF=.86, DODGE=.90, PARRY=.67, BLOCK=.48, BLOCKV=.81})
