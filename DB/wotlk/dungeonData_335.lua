local _, addon = ...

if addon.gameVersion ~= 30300 then return end

local L = addon.locale.Get

-- Explicit names avoid C_Map.GetAreaInfo(), which has no reliable area-ID
-- equivalent on the 3.3.5 client. Canonical tags match the guide parser and
-- the upstream dungeon scoring table.
local dungeonNames = {
    RFC = "Ragefire Chasm",
    WC = "Wailing Caverns",
    DM = "The Deadmines",
    SFK = "Shadowfang Keep",
    BFD = "Blackfathom Deeps",
    STOCKS = "The Stockade",
    GNOMER = "Gnomeregan",
    RFK = "Razorfen Kraul",
    SM = "Scarlet Monastery",
    RFD = "Razorfen Downs",
    ULDA = "Uldaman",
    ZF = "Zul'Farrak",
    MARA = "Maraudon",
    ST = "The Temple of Atal'Hakkar",
    RAMPARTS = "Hellfire Ramparts",
    BF = "The Blood Furnace",
    SP = "The Slave Pens",
    UB = "The Underbog",
    MT = "Mana-Tombs",
    CRYPTS = "Auchenai Crypts"
}

local aliases = {
    DEADMINES = "DM",
    VC = "DM",
    STOCKADE = "STOCKS",
    STOCKADES = "STOCKS",
    GNOMEREGAN = "GNOMER",
    ULDAMAN = "ULDA",
    ["TEMPLE OF ATAL'HAKKAR"] = "ST",
    SUNKEN = "ST",
    ["SUNKEN TEMPLE"] = "ST",
    ["HELLFIRE RAMPARTS"] = "RAMPARTS",
    ["BLOOD FURNACE"] = "BF",
    ["THE BLOOD FURNACE"] = "BF",
    ["SLAVE PENS"] = "SP",
    ["THE SLAVE PENS"] = "SP",
    UNDERBOG = "UB",
    ["THE UNDERBOG"] = "UB",
    ["MANA TOMBS"] = "MT",
    ["MANA-TOMBS"] = "MT",
    ["AUCHENAI CRYPTS"] = "CRYPTS"
}

for tag, name in pairs(dungeonNames) do
    aliases[string.upper(name)] = tag
end

function addon.GetDungeonName(instance)
    if type(instance) ~= "string" then return end
    local upper = string.upper(instance)
    local tag = dungeonNames[upper] and upper or aliases[upper]
    local name = tag and dungeonNames[tag]
    if not name then return end
    return L(name), tag
end

local fields = {
    "travel", "quest", "DRUID", "HUNTER", "MAGE", "PALADIN",
    "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"
}

-- Upstream v4.10.20 Classic/TBC travel, quest, and class-impact scores,
-- compacted to the dungeon tags used by this backport's loaded guides.
local encoded = {
    Alliance = {
        WC = {0,2,2,2,1,1,1,2,2,1,1},
        DM = {0,3,3,3,2,3,3,3,3,2,3},
        SFK = {0,1,1,1,2,1,3,2,1,2,1},
        BFD = {3,3,2,1,3,2,3,1,1,3,2},
        STOCKS = {3,3,0,0,0,0,0,0,0,0,0},
        GNOMER = {3,3,3,3,2,2,3,3,3,2,2},
        RFK = {1,2,1,1,2,3,3,2,1,2,3},
        SM = {1,1,1,1,3,3,3,3,2,3,3},
        RFD = {1,2,1,1,3,2,3,3,1,3,2},
        ULDA = {3,3,1,1,1,2,2,1,1,1,2},
        ZF = {3,3,2,2,1,2,1,2,2,1,2},
        MARA = {1,2,2,3,2,2,2,3,3,2,3},
        ST = {1,1,1,2,2,1,2,2,1,1,3},
        RAMPARTS = {3,3,3,3,3,3,3,3,3,3,3},
        BF = {3,3,3,3,3,3,3,3,3,3,3},
        SP = {3,3,3,3,3,3,3,3,3,3,3},
        UB = {3,3,3,3,3,3,3,3,3,3,3},
        MT = {3,3,3,3,3,3,3,3,3,3,3},
        CRYPTS = {1,0,1,1,1,1,1,1,1,1,1}
    },
    Horde = {
        RFC = {1,3,2,1,2,3,3,3,2,2,3},
        WC = {3,3,3,3,3,3,3,3,3,3,3},
        DM = {0,0,3,2,2,2,2,3,2,2,2},
        SFK = {3,2,2,1,3,2,3,2,2,3,2},
        BFD = {3,3,2,2,3,2,3,3,2,3,2},
        GNOMER = {2,2,3,3,2,3,3,3,2,2,2},
        RFK = {3,3,2,1,2,3,3,2,2,2,3},
        SM = {1,2,1,1,3,2,3,3,2,3,2},
        RFD = {3,2,1,1,3,2,3,3,2,3,2},
        ULDA = {3,3,1,2,2,3,2,2,2,2,3},
        ZF = {2,3,2,2,2,2,2,2,2,2,2},
        MARA = {2,3,2,3,2,3,2,3,2,2,3},
        ST = {1,3,1,3,3,3,3,2,3,3,3},
        RAMPARTS = {3,3,3,3,3,3,3,3,3,3,3},
        BF = {3,3,3,3,3,3,3,3,3,3,3},
        SP = {3,3,3,3,3,3,3,3,3,3,3},
        UB = {3,3,3,3,3,3,3,3,3,3,3},
        MT = {3,3,3,3,3,3,3,3,3,3,3},
        CRYPTS = {1,0,1,1,1,1,1,1,1,1,1}
    }
}

addon.dungeonStats = {}
for faction, dungeons in pairs(encoded) do
    addon.dungeonStats[faction] = {}
    for tag, values in pairs(dungeons) do
        local scoreData = {}
        for index, field in ipairs(fields) do
            scoreData[field] = values[index] or 0
        end
        addon.dungeonStats[faction][tag] = scoreData
    end
end

