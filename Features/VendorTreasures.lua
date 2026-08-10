--[[
Cpt. Stadics' Vendor Treasures
Derived from https://www.curseforge.com/wow/addons/cpt-stadics-map-of-vendor-treasures

Creative Commons Attribution-NonCommercial 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
]] local _, addon = ...

local L = addon.locale.Get
local build = select(4, GetBuildInfo())
local legacy335 = build == 30300
if build > 40000 then return end
local HBD = LibStub("HereBeDragons-2.0")
local HBDPins = LibStub("HereBeDragons-Pins-2.0")

local GetItemInfo = C_Item and C_Item.GetItemInfo or _G.GetItemInfo
local GetItemQualityColor = C_Item and C_Item.GetItemQualityColor or _G.GetItemQualityColor

local GameTooltip, WorldMapFrame = _G.GameTooltip, _G.WorldMapFrame
local VendorTooltip = legacy335 and (_G.WorldMapTooltip or GameTooltip) or
                          GameTooltip
local UnitOnTaxi, GetBestMapForUnit, GetPlayerMapPosition = _G.UnitOnTaxi, C_Map.GetBestMapForUnit,
                                                            C_Map.GetPlayerMapPosition
local pairs, tinsert = pairs, table.insert
local HORDE, ALLIANCE, NEUTRAL = "Horde", "Alliance", "Neutral"

addon.VendorTreasures = addon:NewModule("VendorTreasures")

-- New Pin owner
local PIN_OWNER = addon.VendorTreasures

local RARE_ADDON_NAME = L("Cpt. Stadics' Vendor Treasures")
local ICON_PATH = "Interface/GossipFrame/VendorGossipIcon.blp"
local TOOLTIP_LOOT_INDEX = 1
local DISTANCE_NPCS = {}
local DISTANCE_THRESHOLD = 0.01
local GetTableLength

local CLASS_POTION = L("Potion Vendor")
local CLASS_GEAR = L("Gear Vendor")

local CLASS_COLORS = {}
CLASS_COLORS[CLASS_POTION] = {1, 0.82, 0}
CLASS_COLORS[CLASS_GEAR] = {0.12, 1.0, 0.0}

local FACTION_COLORS = {
    [HORDE] = {0.9, 0.2, 0.15},
    [ALLIANCE] = {0.2, 0.55, 1.0},
    [NEUTRAL] = {0.9, 0.8, 0.2},
}

-- TODO addon.mapId
-- Kalimdor
local ZONE_TELDRASSIL = 1438;
local ZONE_WINTERSPRING = 1452;
local ZONE_DARKSHORE = 1439;
local ZONE_FELWOOD = 1448;
local ZONE_AZSHARA = 1447;
local ZONE_ASHENVALE = 1440;
local ZONE_STONETALON_MOUNTAINS = 1442;
local ZONE_DUROTAR = 1411;
local ZONE_BARRENS = 1413;
local ZONE_DESOLACE = 1443;
local ZONE_MULGORE = 1412;
local ZONE_DUSTWALLOW_MARSH = 1445;
local ZONE_FERALAS = 1444;
local ZONE_THOUSAND_NEEDLES = 1441;
local ZONE_TANARIS = 1446;
local ZONE_UNGORO_CRATER = 1449;
local ZONE_SILITHUS = 1451;
local ZONE_ORGRIMMAR = 1454;
local ZONE_THUNDERBLUFF = 1456;
local ZONE_DARNASSUS = 1457;
local ZONE_MOONGLADE = 1450;

-- Eastern Kingdoms
local ZONE_EASTERN_PLAGUELANDS = 1423;
local ZONE_WESTERN_PLAGUELANDS = 1422;
local ZONE_TIRISFAL_GLADES = 1420;
local ZONE_ALTERAC_MOUNTAINS = 1416;
local ZONE_SILVERPINE_FOREST = 1421;
local ZONE_HINTERLANDS = 1425;
local ZONE_HILLSBRAD_FOOTHILLS = 1424;
local ZONE_ARATHI_HIGHLANDS = 1417;
local ZONE_WETLANDS = 1437;
local ZONE_LOCH_MODAN = 1432;
local ZONE_DUN_MOROGH = 1426;
local ZONE_BADLANDS = 1418;
local ZONE_BURNING_STEPPES = 1428;
local ZONE_SEARING_GORGE = 1427;
local ZONE_REDRIDGE_MOUNTAINS = 1433;
local ZONE_ELWYNN_FOREST = 1429;
local ZONE_SWAMP_OF_SORROWS = 1435;
local ZONE_DUSKWOOD = 1431;
local ZONE_WESTFALL = 1436;
local ZONE_BLASTED_LANDS = 1419;
local ZONE_STRANGLETHORN_VALE = 1434;
local ZONE_STORMWIND_CITY = 1453;
local ZONE_IRONFORGE = 1455;
local ZONE_UNDERCITY = 1458;

local DELAY = 5 -- Seconds
local DATA = {}

local WORLD_MAP_ID = -1
local WORLD_MAP_PIN_SIZE = 18

local MINI_MAP_ID = -1;
local MINI_MAP_PIN_SIZE = 12;

local PLAYER_MAP_ID = -1;

local Frame = CreateFrame("Frame", "RXPVendorTreasuresFrame")

function Frame:InitializeZones()
    -- ZONE, NAME, X, Y, CLASS, FACTION, LOOT

    -- Azshara
    Frame:SetZoneNPCData(ZONE_AZSHARA, "Brinna Valanaar", 12.0, 78.2, CLASS_GEAR, ALLIANCE, {11305})

    -- Azshara
    Frame:SetZoneNPCData(ZONE_MOONGLADE, "Kharedon", 56.6, 29.8, CLASS_GEAR, NEUTRAL, {12254})

    -- Ashenvale
    Frame:SetZoneNPCData(ZONE_ASHENVALE, "Harklan & Bhaldaran", 50.8, 67.0, CLASS_GEAR, ALLIANCE, {11305, 929, 3385})

    -- Stonetalon Mountains
    Frame:SetZoneNPCData(ZONE_STONETALON_MOUNTAINS, "Veenix", 58.2, 51.6, CLASS_GEAR, NEUTRAL, {4818, 4817, 4838, 4837});
    Frame:SetZoneNPCData(ZONE_STONETALON_MOUNTAINS, "Jeeda", 47.6, 61.6, CLASS_POTION, HORDE, {3385, 929});
    Frame:SetZoneNPCData(ZONE_STONETALON_MOUNTAINS, "Borand", 45.2, 59.2, CLASS_GEAR, HORDE, {11304});
    Frame:SetZoneNPCData(ZONE_STONETALON_MOUNTAINS, "Nizzik", 62.6, 40.2, CLASS_GEAR, NEUTRAL,
                         {4835, 4833, 4831, 4830, 4832, 4829, 4827, 4828})

    -- The Barrens
    Frame:SetZoneNPCData(ZONE_BARRENS, "Kiknikle & Pizznukle", 41.8, 38.6, CLASS_GEAR, NEUTRAL,
                         {4781, 4782, 4786, 4788, 4789});
    Frame:SetZoneNPCData(ZONE_BARRENS, "Lizzarik", 59, 38.2, CLASS_GEAR, NEUTRAL, {4778, 4777, 4765, 4766, 858, 2455});
    Frame:SetZoneNPCData(ZONE_BARRENS, "Grazlix & Vexspindle", 62.2, 38.4, CLASS_GEAR, NEUTRAL,
                         {4798, 4799, 4820, 4816, 4800, 4821, 4822, 4794, 4795, 4796})
    Frame:SetZoneNPCData(ZONE_BARRENS, "Vrang Wildgore", 43.8, 12.2, CLASS_GEAR, HORDE,
                         {4800, 4816, 4778, 4777, 4798, 4799})
    Frame:SetZoneNPCData(ZONE_BARRENS, "Halija Whitestrider", 52.2, 31.8, CLASS_GEAR, HORDE,
                         {4793, 4792, 4781, 4786, 4782})
    Frame:SetZoneNPCData(ZONE_BARRENS, "Uthrok & Nargal Deatheye", 51.0, 29.0, CLASS_GEAR, HORDE, {11304, 4765, 4766})

    -- Desolace
    Frame:SetZoneNPCData(ZONE_DESOLACE, "Vendor-Tron 1000", 60.2, 38.2, CLASS_POTION, NEUTRAL, {3827, 1710})
    Frame:SetZoneNPCData(ZONE_DESOLACE, "Hae'Wilani", 25.8, 71.0, CLASS_GEAR, HORDE, {12250, 12249})

    -- Dustwallow Marsh
    Frame:SetZoneNPCData(ZONE_DUSTWALLOW_MARSH, "Zulrg & Zanara", 36.2, 31.6, CLASS_GEAR, HORDE, {12251, 12250, 11305});
    Frame:SetZoneNPCData(ZONE_DUSTWALLOW_MARSH, "Balai Lok'Wein", 36.4, 30.2, CLASS_POTION, HORDE,
                         {929, 3385, 1711, 2290, 1478, 1712, 954, 3012})
    Frame:SetZoneNPCData(ZONE_DUSTWALLOW_MARSH, "Piter Verance", 67.4, 47.8, CLASS_GEAR, ALLIANCE,
                         {4835, 4833, 4825, 4824, 4826, 4832, 4830, 4831, 4818, 4817})
    Frame:SetZoneNPCData(ZONE_DUSTWALLOW_MARSH, "Marie Holdston", 64.6, 50.0, CLASS_GEAR, ALLIANCE, {12248, 12250})
    Frame:SetZoneNPCData(ZONE_DUSTWALLOW_MARSH, "Jensen Farran", 67.8, 49.8, CLASS_GEAR, ALLIANCE, {11305})
    Frame:SetZoneNPCData(ZONE_DUSTWALLOW_MARSH, "Uma Bartulm", 64.0, 47.6, CLASS_POTION, ALLIANCE, {1710, 3827})

    -- Feralas
    Frame:SetZoneNPCData(ZONE_FERALAS, "Logannas", 32.6, 44.0, CLASS_POTION, ALLIANCE, {3928, 6149})
    Frame:SetZoneNPCData(ZONE_FERALAS, "Bronk", 76.0, 43.4, CLASS_POTION, HORDE, {3928, 6149})
    Frame:SetZoneNPCData(ZONE_FERALAS, "Cawind Trueaim", 74.8, 45.6, CLASS_GEAR, HORDE, {11308})
    Frame:SetZoneNPCData(ZONE_FERALAS, "Worb Strongstich", 74.6, 42.6, CLASS_GEAR, HORDE, {12254, 12253})

    -- Thousand Needles
    Frame:SetZoneNPCData(ZONE_THOUSAND_NEEDLES, "Starn & Montarr", 45.0, 50.6, CLASS_GEAR, HORDE,
                         {11305, 11304, 929, 1711, 2290, 1478, 1712})

    -- Winterspring
    Frame:SetZoneNPCData(ZONE_WINTERSPRING, "Evie Whirlbrew", 60.8, 37.8, CLASS_POTION, NEUTRAL, {3928, 6149})

    -- Eastern Plaguelands
    Frame:SetZoneNPCData(ZONE_EASTERN_PLAGUELANDS, "Augustus the Touched", 14.4, 33.6, CLASS_GEAR, NEUTRAL, {15902})

    -- Tirisfall Glades
    Frame:SetZoneNPCData(ZONE_TIRISFAL_GLADES, "Selina Weston", 61.8, 50.0, CLASS_POTION, HORDE, {858})

    -- Alterac Mountains
    Frame:SetZoneNPCData(ZONE_ALTERAC_MOUNTAINS, "Bro'Kin", 38.4, 38.8, CLASS_POTION, NEUTRAL, {14634, 3827, 1710})

    -- Silverpine Forest
    Frame:SetZoneNPCData(ZONE_SILVERPINE_FOREST, "Alexandre, Andrea, Nadia & Edwin", 44.6, 39.2, CLASS_GEAR, HORDE,
                         {11304, 4788, 4789, 4781, 4786, 4782, 858})
    Frame:SetZoneNPCData(ZONE_SILVERPINE_FOREST, "Wallace the Blind", 46.4, 86.4, CLASS_GEAR, NEUTRAL,
                         {4818, 4817, 4778, 4777, 11304, 929})

    -- Hillsbrad Foothills
    Frame:SetZoneNPCData(ZONE_HILLSBRAD_FOOTHILLS, "Kirs Legace", 80.0, 39.0, CLASS_GEAR, NEUTRAL,
                         {4832, 4830, 4831, 4794, 4795, 4796})
    Frame:SetZoneNPCData(ZONE_HILLSBRAD_FOOTHILLS, "Zixil", 55.6, 34.6, CLASS_GEAR, NEUTRAL, {4829, 4827, 4828, 4838})
    Frame:SetZoneNPCData(ZONE_HILLSBRAD_FOOTHILLS, "Ott", 60.4, 26.0, CLASS_GEAR, HORDE,
                         {12247, 12249, 4825, 4824, 4826, 4818, 4817})
    Frame:SetZoneNPCData(ZONE_HILLSBRAD_FOOTHILLS, "Robert & Nandar", 51.2, 57.0, CLASS_GEAR, ALLIANCE,
                         {4835, 4833, 4798, 4816, 4799, 4800, 1710, 3827})

    -- Arathi Highlands
    Frame:SetZoneNPCData(ZONE_ARATHI_HIGHLANDS, "Deneb Walker", 27.0, 58.8, CLASS_POTION, ALLIANCE,
                         {3385, 929, 1711, 2290, 1478, 1712})
    Frame:SetZoneNPCData(ZONE_ARATHI_HIGHLANDS, "Drovnar Strongbrew", 46.4, 47.0, CLASS_POTION, ALLIANCE, {3827, 1710})
    Frame:SetZoneNPCData(ZONE_ARATHI_HIGHLANDS, "Mu'uta", 72.6, 33.6, CLASS_GEAR, HORDE, {11305})

    -- Wetlands
    Frame:SetZoneNPCData(ZONE_WETLANDS, "Kixxle", 50.2, 37.8, CLASS_POTION, NEUTRAL, {929})
    Frame:SetZoneNPCData(ZONE_WETLANDS, "Wenna Silkbeard", 25.6, 25.8, CLASS_GEAR, ALLIANCE,
                         {4835, 4833, 4831, 4830, 4832, 4829, 4827, 4828})
    Frame:SetZoneNPCData(ZONE_WETLANDS, "Naela Trance & Brak Durnad", 11.2, 58.6, CLASS_GEAR, ALLIANCE,
                         {11304, 4818, 4817})
    Frame:SetZoneNPCData(ZONE_WETLANDS, "Jennabink & Dewin", 8.0, 55.8, CLASS_GEAR, ALLIANCE,
                         {4829, 4827, 4828, 4793, 4792, 929})
    Frame:SetZoneNPCData(ZONE_WETLANDS, "Samor Festivus", 10.4, 60.2, CLASS_POTION, ALLIANCE, {929})
    Frame:SetZoneNPCData(ZONE_WETLANDS, "Dark Iron Entrepreneur", 46.6, 18.2, CLASS_GEAR, NEUTRAL,
                         {4835, 4833, 4825, 4824, 4826, 4832, 4830, 4831})

    -- Loch Modan
    Frame:SetZoneNPCData(ZONE_LOCH_MODAN, "Kat Sampson & Cliff Hadin", 82.6, 64.0, CLASS_GEAR, ALLIANCE,
                         {4788, 4789, 11304})
    Frame:SetZoneNPCData(ZONE_LOCH_MODAN, "Morhan Coppertongue", 34.0, 46.6, CLASS_GEAR, ALLIANCE, {4765, 4766})
    Frame:SetZoneNPCData(ZONE_LOCH_MODAN, "Aldren Cordon", 64.8, 66.0, CLASS_GEAR, ALLIANCE, {4781, 4786, 4782})
    Frame:SetZoneNPCData(ZONE_LOCH_MODAN, "Nillen Andemar", 42.8, 10.0, CLASS_GEAR, ALLIANCE, {4778, 4777})

    -- Redridge Mountains
    Frame:SetZoneNPCData(ZONE_REDRIDGE_MOUNTAINS, "Franklin Hamar", 27.2, 45.4, CLASS_GEAR, ALLIANCE, {4781, 4786, 4782})
    Frame:SetZoneNPCData(ZONE_REDRIDGE_MOUNTAINS, "Kara Adams", 30.6, 46.6, CLASS_GEAR, ALLIANCE, {4820, 4821, 4822})
    Frame:SetZoneNPCData(ZONE_REDRIDGE_MOUNTAINS, "Captured Servant of Azora", 74.6, 79.6, CLASS_GEAR, ALLIANCE,
                         {4793, 4792})
    Frame:SetZoneNPCData(ZONE_REDRIDGE_MOUNTAINS, "Bernard Brubaker", 88.2, 71.6, CLASS_GEAR, ALLIANCE,
                         {4794, 4795, 4796})

    -- Elwynn Forest
    Frame:SetZoneNPCData(ZONE_ELWYNN_FOREST, "Antonio Perelli", 42.6, 66.6, CLASS_GEAR, ALLIANCE,
                         {4794, 4795, 4796, 4818, 4817, 4778, 4777, 858})
    Frame:SetZoneNPCData(ZONE_ELWYNN_FOREST, "Dawn Brightstar", 64.8, 69.2, CLASS_POTION, ALLIANCE,
                         {858, 2455, 954, 3012, 955, 1180, 1181, 3013})

    -- Swamp of Sorrows
    Frame:SetZoneNPCData(ZONE_SWAMP_OF_SORROWS, "Masat T'andr", 26.4, 31.6, CLASS_GEAR, NEUTRAL, {12254, 12253})
    Frame:SetZoneNPCData(ZONE_SWAMP_OF_SORROWS, "Thralosh", 45.0, 51.6, CLASS_GEAR, HORDE, {12255, 12256})
    Frame:SetZoneNPCData(ZONE_SWAMP_OF_SORROWS, "Thultazor & Rartar", 45.0, 51.6, CLASS_POTION, HORDE, {3928, 6149})

    -- Duskwood
    Frame:SetZoneNPCData(ZONE_DUSKWOOD, "Kzixx", 81.8, 19.8, CLASS_GEAR, NEUTRAL,
                         {4829, 4827, 4828, 4838, 4837, 3385, 929})
    Frame:SetZoneNPCData(ZONE_DUSKWOOD, "Bliztik", 18.0, 54.6, CLASS_POTION, NEUTRAL, {3385, 929})
    Frame:SetZoneNPCData(ZONE_DUSKWOOD, "Avette Fellwood", 73.2, 44.8, CLASS_GEAR, ALLIANCE, {11304})
    Frame:SetZoneNPCData(ZONE_DUSKWOOD, "Morg & Gaving Gnarltree", 73.8, 48.6, CLASS_GEAR, ALLIANCE,
                         {4798, 4816, 4799, 4800, 12247, 12249})

    -- Westfall
    Frame:SetZoneNPCData(ZONE_WESTFALL, "Defias Profiteer", 43.4, 66.8, CLASS_GEAR, NEUTRAL, {4788, 4789})
    Frame:SetZoneNPCData(ZONE_WESTFALL, "William MacGregor", 57.6, 53.8, CLASS_GEAR, ALLIANCE, {11304})

    -- Blasted Lands
    Frame:SetZoneNPCData(ZONE_BLASTED_LANDS, "Nina Lightbrew", 66.8, 18.6, CLASS_POTION, ALLIANCE, {3928, 6149})

    -- Stranglethorn Vale
    Frame:SetZoneNPCData(ZONE_STRANGLETHORN_VALE, "Jutak", 27.4, 77.4, CLASS_GEAR, NEUTRAL, {12248})
    Frame:SetZoneNPCData(ZONE_STRANGLETHORN_VALE, "Vharr", 32.2, 28.0, CLASS_GEAR, HORDE, {12248, 12250})
    Frame:SetZoneNPCData(ZONE_STRANGLETHORN_VALE, "Zarena & Kizz & Haren", 28.4, 75.4, CLASS_GEAR, NEUTRAL,
                         {12251, 12252, 4778, 4777, 11305})
    Frame:SetZoneNPCData(ZONE_STRANGLETHORN_VALE, "Glyx Brewright", 28.0, 78.0, CLASS_POTION, NEUTRAL, {1710, 3827})
    Frame:SetZoneNPCData(ZONE_STRANGLETHORN_VALE, "Jaquilina Dramet", 35.6, 10.6, CLASS_GEAR, NEUTRAL, {12250})
    Frame:SetZoneNPCData(ZONE_STRANGLETHORN_VALE, "Fargon Mortalak", 29.0, 75.0, CLASS_GEAR, NEUTRAL, {12257})

    -- Stormwind City
    Frame:SetZoneNPCData(ZONE_STORMWIND_CITY, "Charys Yserian", 32.4, 80.0, CLASS_GEAR, ALLIANCE,
                         {4825, 4824, 4826, 4829, 4827, 4828, 3385, 929})
    Frame:SetZoneNPCData(ZONE_STORMWIND_CITY, "Frederick Stover", 50.2, 57.4, CLASS_GEAR, ALLIANCE,
                         {11307, 11306, 11303})
    Frame:SetZoneNPCData(ZONE_STORMWIND_CITY, "Marda Weller", 57.2, 57.0, CLASS_GEAR, ALLIANCE, {7371})
    Frame:SetZoneNPCData(ZONE_STORMWIND_CITY, "Keldric Boucher", 55.8, 65.2, CLASS_POTION, ALLIANCE, {858})
    Frame:SetZoneNPCData(ZONE_STORMWIND_CITY, "Adair Gilroy", 41.6, 65.2, CLASS_POTION, ALLIANCE,
                         {1711, 2290, 1478, 1712, 954, 3012, 955, 1180, 1181, 3013})

    -- Orgrimmar
    Frame:SetZoneNPCData(ZONE_ORGRIMMAR, "Jin'Sora", 77.8, 38.6, CLASS_GEAR, HORDE, {11307, 11306, 11303})
    Frame:SetZoneNPCData(ZONE_ORGRIMMAR, "Tor'phan", 62.6, 50.6, CLASS_GEAR, HORDE, {12255})
    Frame:SetZoneNPCData(ZONE_ORGRIMMAR, "Handor", 62.8, 44.8, CLASS_GEAR, HORDE, {12256})

    -- Ironforge
    Frame:SetZoneNPCData(ZONE_IRONFORGE, "Skolmin Goldfury", 71.6, 66.2, CLASS_GEAR, ALLIANCE, {11307, 11306, 11303})
    Frame:SetZoneNPCData(ZONE_IRONFORGE, "Thalgus Thunderfist", 61.6, 89.0, CLASS_GEAR, ALLIANCE, {7371})

    -- Thunderbluff
    Frame:SetZoneNPCData(ZONE_THUNDERBLUFF, "Kuna Thunderhorn", 46.8, 45.8, CLASS_GEAR, HORDE, {11307, 11306, 11303})
    Frame:SetZoneNPCData(ZONE_THUNDERBLUFF, "Delgo Ragetotem", 53.8, 57.2, CLASS_GEAR, HORDE, {12249})

    -- Undercity
    Frame:SetZoneNPCData(ZONE_UNDERCITY, "Abigail Sawyer", 54.8, 38.0, CLASS_GEAR, HORDE, {11307, 11306, 11303})
    Frame:SetZoneNPCData(ZONE_UNDERCITY, "Benijah Fenner", 58.6, 32.6, CLASS_GEAR, HORDE, {7371})
    Frame:SetZoneNPCData(ZONE_UNDERCITY, "Salazar Bloch", 77.2, 38.6, CLASS_POTION, HORDE,
                         {1711, 2290, 1478, 1712, 954, 3012, 955, 1180, 1181, 3013})

    -- Darnassus
    Frame:SetZoneNPCData(ZONE_DARNASSUS, "Landria", 63.2, 66.6, CLASS_GEAR, ALLIANCE, {11308, 11306, 11303})
    Frame:SetZoneNPCData(ZONE_DARNASSUS, "Glorandiir", 64.0, 59.0, CLASS_GEAR, ALLIANCE, {12249})
    Frame:SetZoneNPCData(ZONE_DARNASSUS, "Turian", 62.6, 65.6, CLASS_GEAR, ALLIANCE, {12247})
    Frame:SetZoneNPCData(ZONE_DARNASSUS, "Vinasia", 60.8, 72.6, CLASS_GEAR, ALLIANCE, {12256})

    -- Outland (TBC/WotLK clients)
    if build > 20000 then
        Frame:SetZoneNPCData(addon.mapId["Netherstorm"], "Qiff", 32.648, 66.747,
            CLASS_GEAR, NEUTRAL, {23782, 23784, 23786, 23787})
        Frame:SetZoneNPCData(addon.mapId["Netherstorm"], "Dealer Najeeb", 44.989,
            36.525, CLASS_GEAR, NEUTRAL,
            {22572, 22574, 22578, 22576, 23785, 23784})
        Frame:SetZoneNPCData(addon.mapId["Terokkar Forest"], "Dealer Tariq", 39.452,
            70.054, CLASS_GEAR, NEUTRAL, {22572, 22574, 22578, 22576})
        Frame:SetZoneNPCData(addon.mapId["Shattrath City"], "Wind Trader Lathrai",
            72.232, 30.774, CLASS_GEAR, NEUTRAL, {23811})
        Frame:SetZoneNPCData(addon.mapId["The Exodar"], "Feera", 53.612, 90.844,
            CLASS_GEAR, ALLIANCE, {23811})
        Frame:SetZoneNPCData(addon.mapId["Silvermoon City"], "Yatheon", 75.614,
            40.713, CLASS_GEAR, HORDE, {23811})
        Frame:SetZoneNPCData(addon.mapId["Zangarmarsh"], "Seer Janidi", 32.379,
            51.960, CLASS_GEAR, HORDE, {22901, 22902})
        Frame:SetZoneNPCData(addon.mapId["Zangarmarsh"], 19383, 32.40, 48.00,
            CLASS_GEAR, HORDE, {23811})
        Frame:SetZoneNPCData(addon.mapId["Terokkar Forest"], "Leeli Longhaggle",
            57.740, 53.367, CLASS_GEAR, ALLIANCE, {22901, 22911})
        Frame:SetZoneNPCData(addon.mapId["Zangarmarsh"], "Haalrun", 67.805, 47.917,
            CLASS_GEAR, ALLIANCE, {22902, 22907, 22909, 22909})
        Frame:SetZoneNPCData(addon.mapId["Blade's Edge Mountains"], "Daga Ramba",
            51.074, 57.815, CLASS_GEAR, HORDE, {22907, 22911, 22909, 22909})
        Frame:SetZoneNPCData(addon.mapId["Hellfire Peninsula"],
            "Apothecary Antonivich", 52.284, 36.460, CLASS_GEAR, HORDE, {22900})
        Frame:SetZoneNPCData(addon.mapId["Silvermoon City"], "Melaris", 67.149,
            19.488, CLASS_GEAR, HORDE, {22900, 23574})
        Frame:SetZoneNPCData(addon.mapId["Hellfire Peninsula"], "Alchemist Gribble",
            53.802, 65.817, CLASS_GEAR, ALLIANCE, {22900})
        Frame:SetZoneNPCData(addon.mapId["The Exodar"], "Altaa", 28.154, 61.875,
            CLASS_GEAR, ALLIANCE, {22900, 23574})
        Frame:SetZoneNPCData(addon.mapId["Shattrath City"], "Skreah", 45.797,
            20.002, CLASS_GEAR, NEUTRAL, {23574})
    end

end

function Frame:SetZoneNPCData(zone, name, x, y, cl, faction, loot)
    if not zone or not (faction == NEUTRAL or addon.player.faction == faction) then
        return
    end
    if type(zone) ~= "number" or type(x) ~= "number" or type(y) ~= "number" or
        x < 0 or x > 100 or y < 0 or y > 100 then
        return
    end

    -- Ensure sure the zone data exists
    if DATA[zone] == nil then DATA[zone] = {} end

    -- Loot Data for this NPC
    local npcData = {}
    npcData.zone = zone
    if type(name) == "number" then
        npcData.name = addon.GetNpcName and addon.GetNpcName(name) or
                           string.format("NPC %d", name)
    else
        npcData.name = name
    end
    npcData.x = x
    npcData.y = y
    npcData.kind = cl
    npcData.faction = faction
    npcData.loot = loot
    npcData.loaded = false

    if loot then for _, itemID in ipairs(loot) do GetItemInfo(itemID) end end

    -- Store the data foor this NPC in the corresponding zone data
    DATA[zone][name] = npcData
end

function Frame:GetZoneData(zone) return DATA[zone] end

function Frame:CreateMapPin(_, data, isInteractiveWorldPin)
    local pinFrame = CreateFrame("Button", nil, UIParent)
    pinFrame:EnableMouse(true)
    pinFrame:SetFrameLevel(2100)
    pinFrame:SetScript("OnClick", function(pin)
        pin.__vendorTooltipToken = (pin.__vendorTooltipToken or 0) + 1
        Frame:ShowPinItemTooltip(pin)
    end)
    pinFrame:SetScript("OnEnter", function(pin)
        pin.__vendorTooltipToken = (pin.__vendorTooltipToken or 0) + 1
        pin.__vendorTooltipRefreshAttempts = 0
        Frame:ShowPinTooltip(pin)
    end)
    pinFrame:SetScript("OnLeave", function(pin)
        pin.__vendorTooltipToken = (pin.__vendorTooltipToken or 0) + 1
        pin.__vendorTooltipRefreshAttempts = nil
        Frame:HidePinTooltip()
    end)
    local pinTexture = pinFrame:CreateTexture(nil, "OVERLAY")
    pinTexture:SetAllPoints(pinFrame)
    pinTexture:SetTexture(ICON_PATH)
    pinFrame.__data = data
    pinFrame.__HBD335InteractiveWorldPin = isInteractiveWorldPin and true or nil
    pinFrame.texture = pinTexture
    pinFrame:SetHighlightTexture(ICON_PATH, "ADD")
    pinFrame:Hide()

    return pinFrame
end

function Frame:ShowPinItemTooltip(pin)

    if pin == nil then return end

    local npcData = pin.__data

    if npcData == nil then return end

    local npcLoot = npcData.loot

    if type(npcLoot) ~= "table" or next(npcLoot) == nil then return end

    if TOOLTIP_LOOT_INDEX > GetTableLength(npcLoot) then
        TOOLTIP_LOOT_INDEX = 1
        self:ShowPinTooltip(pin)
        return
    end

    local npcLootID = npcLoot[TOOLTIP_LOOT_INDEX]

    VendorTooltip:SetHyperlink("item:" .. npcLootID .. ":0:0:0:0:0:0:0")

    TOOLTIP_LOOT_INDEX = TOOLTIP_LOOT_INDEX + 1

end

function Frame:ShowPinTooltip(pin)

    if pin == nil then return end

    local npcData = pin.__data

    if npcData == nil then return end

    local npcClass = npcData.kind
    local npcLoot = npcData.loot

    local npcColor = CLASS_COLORS[npcClass] or {1, 1, 1}
    local factionColor = FACTION_COLORS[npcData.faction] or {1, 1, 1}
    local mapInfo = C_Map and C_Map.GetMapInfo and
                        C_Map.GetMapInfo(npcData.zone)
    local zoneName = mapInfo and mapInfo.name
    if not zoneName or zoneName == "" then
        zoneName = string.format("Map %s", tostring(npcData.zone or "?"))
    end

    local center = pin.GetCenter and pin:GetCenter()
    local anchor = center and center > (UIParent:GetWidth() / 2) and
                       "ANCHOR_LEFT" or "ANCHOR_RIGHT"

    local function AddInformation(label, value, r, g, b)
        value = value or "-"
        if VendorTooltip.AddDoubleLine then
            VendorTooltip:AddDoubleLine(label, value, 0.95, 0.82, 0.25,
                                        r or 1, g or 1, b or 1)
        else
            VendorTooltip:AddLine(label .. " " .. value, r or 1, g or 1,
                                  b or 1)
        end
    end

    VendorTooltip:SetOwner(pin, anchor)
    VendorTooltip:ClearLines()
    VendorTooltip:SetText(npcData.name or L("Unknown"), npcColor[1],
                          npcColor[2], npcColor[3])
    AddInformation(L("Vendor Type:"), npcClass)
    AddInformation(L("Faction:"), npcData.faction, factionColor[1],
                   factionColor[2], factionColor[3])
    AddInformation(L("Zone:"), zoneName)
    AddInformation(L("Coordinates:"),
                   string.format("%.1f, %.1f", npcData.x or 0,
                                 npcData.y or 0))

    if type(npcLoot) == "table" and next(npcLoot) ~= nil then
        VendorTooltip:AddLine(" ")
        VendorTooltip:AddLine(L("Notable Stock:"), 0.95, 0.82, 0.25)

        local missingItemInfo
        for _, itemID in ipairs(npcLoot) do
            local itemName, itemLink, itemRarity, _, itemMinLevel, itemType,
                  itemSubType = GetItemInfo(itemID)
            if not itemName then missingItemInfo = true end
            local itemText = itemLink or itemName or
                                 string.format("Item #%d", itemID)
            local detail = itemSubType or itemType or ""
            if itemMinLevel and itemMinLevel > 0 then
                local levelText = string.format(L("Requires level %d"),
                                                itemMinLevel)
                detail = detail ~= "" and (detail .. " - " .. levelText) or
                             levelText
            end
            local r, g, b = 0.7, 0.7, 0.7
            if itemRarity ~= nil then
                r, g, b = GetItemQualityColor(itemRarity)
            end
            if VendorTooltip.AddDoubleLine then
                VendorTooltip:AddDoubleLine(itemText, detail, r, g, b, 0.75,
                                            0.75, 0.75)
            else
                VendorTooltip:AddLine(itemText ..
                                          (detail ~= "" and " - " .. detail or
                                              ""), r, g, b)
            end
        end
        VendorTooltip:AddLine(L("Click to inspect each item"), 0.7, 0.7,
                              0.7)

        -- A fresh client often has none of these item records cached yet.
        -- GetItemInfo starts the server query; retry the open card a few times
        -- so IDs are replaced by names/details without requiring another hover.
        local attempts = pin.__vendorTooltipRefreshAttempts or 0
        if missingItemInfo and attempts < 3 then
            attempts = attempts + 1
            pin.__vendorTooltipRefreshAttempts = attempts
            local token = pin.__vendorTooltipToken
            C_Timer.After(0.35 * attempts, function()
                if pin.__vendorTooltipToken == token and
                    VendorTooltip:GetOwner() == pin then
                    Frame:ShowPinTooltip(pin)
                end
            end)
        end
    end

    VendorTooltip:Show()

end

function Frame:HidePinTooltip()
    TOOLTIP_LOOT_INDEX = 1
    VendorTooltip:Hide()
end

local function GetMapID()
    return GetBestMapForUnit("player")
end

local function IsWorldMapAvailable()
    if not WorldMapFrame or not WorldMapFrame:IsVisible() then return false end
    if legacy335 then
        local detail = _G.WorldMapDetailFrame
        return detail and detail:GetWidth() > 0 and detail:GetHeight() > 0
    end
    local canvas = WorldMapFrame.GetCanvas and WorldMapFrame:GetCanvas()
    if not canvas then return false end
    local width, height = canvas:GetSize()
    return width and height and width > 0 and height > 0
end

local function GetWorldMapID()
    if WorldMapFrame and WorldMapFrame.GetMapID then
        return WorldMapFrame:GetMapID()
    end
end

GetTableLength = function(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

function Frame:CheckZone()
    if not addon.settings.profile.enableVendorTreasure then
        self:HideWorldMapPins()
        self:HideMiniMapPins()
        return
    end
    self:CheckMiniMap()
    self:CheckWorldMap()
end

-- Upstream intentionally leaves minimap pins disabled. Keep the data and pin
-- helpers available, but do not add map clutter implicitly on the legacy client.
function Frame:CheckMiniMap() end

function Frame:CheckWorldMap()
    if legacy335 then
        self:ShowAllWorldMapPins()
        return
    end
    if not IsWorldMapAvailable() then return end
    if GetWorldMapID() ~= WORLD_MAP_ID then self:DrawWorldMapPins() end
end

-- World Map --
function Frame:ShowWorldMapNPC(data)
    if type(data) ~= "table" or type(data.zone) ~= "number" then return end
    self:LoadNPCData(data)

    local x, y = data.x, data.y
    if type(x) ~= "number" or type(y) ~= "number" then return end
    if x > 1 or y > 1 then x, y = x / 100, y / 100 end
    if x < 0 or x > 1 or y < 0 or y > 1 then return end

    -- Frame:SetScale also scales its anchor offsets on the legacy client, which
    -- moves a pin away from the coordinate it is meant to mark. Resize the pin
    -- itself and leave its coordinate space at scale 1.
    local pinScale = tonumber(addon.settings.profile.vendorTreasurePinScale) or 1
    local pinSize = WORLD_MAP_PIN_SIZE * pinScale
    data.worldpin:SetScale(1)
    data.worldpin:SetSize(pinSize, pinSize)

    HBDPins:AddWorldMapIconMap(PIN_OWNER, data.worldpin, data.zone, x, y, _G.HBD_PINS_WORLDMAP_SHOW_CONTINENT)
end

function Frame:DrawWorldMapPins()
    Frame:HideWorldMapPins()
    if legacy335 then
        self:ShowAllWorldMapPins()
    elseif GetMapID() == GetWorldMapID() then
        self:ShowWorldMapPins()
    end
end

function Frame:HideWorldMapPins()
    HBDPins:RemoveAllWorldMapIcons(PIN_OWNER)
    self.worldPinsRegistered = false
    self.worldPinScale = nil
end

function Frame:ShowWorldMapPins()
    if legacy335 then return self:ShowAllWorldMapPins() end
    WORLD_MAP_ID = GetWorldMapID()

    -- Display pins for player's map if soloSelfFound
    if addon.settings.profile.soloSelfFound then
        for _, zoneData in pairs(DATA) do for _, npcData in pairs(zoneData) do self:ShowWorldMapNPC(npcData) end end
    else
        local zoneData = DATA[GetMapID()] or {}

        for _, npcData in pairs(zoneData) do self:ShowWorldMapNPC(npcData) end
    end
end

function Frame:ShowAllWorldMapPins()
    local pinScale = tonumber(addon.settings.profile.vendorTreasurePinScale) or 1
    if self.worldPinsRegistered and self.worldPinScale == pinScale then return end

    -- Register the static vendor dataset once. HereBeDragons already moves all
    -- registered icons on WORLD_MAP_UPDATE, so rebuilding every vendor here on
    -- every map event only repeats the most expensive part of opening the map.
    if self.worldPinsRegistered then
        HBDPins:RemoveAllWorldMapIcons(PIN_OWNER)
    end
    for _, zoneData in pairs(DATA) do
        for _, npcData in pairs(zoneData) do
            self:ShowWorldMapNPC(npcData)
        end
    end
    self.worldPinsRegistered = true
    self.worldPinScale = pinScale
end

-- Mini Map --
-- TODO RXP, port World Map changes

-- Mini map pins with HBDPins
function Frame:HideMiniMapNPC(data) if data.minipin then HBDPins:RemoveMinimapIcon(PIN_OWNER, data.minipin) end end

function Frame:ShowMiniMapNPC(data)
    if type(data) ~= "table" or type(data.zone) ~= "number" then return end
    self:LoadNPCData(data)

    -- ensure the pin actually has size
    local pinScale = tonumber(addon.settings.profile.vendorTreasurePinScale) or 1
    local pinSize = MINI_MAP_PIN_SIZE * pinScale
    data.minipin:SetScale(1)
    data.minipin:SetSize(pinSize, pinSize)

    local x, y = data.x, data.y
    if type(x) ~= "number" or type(y) ~= "number" then return end
    if x > 1 or y > 1 then x, y = x / 100, y / 100 end
    if x < 0 or x > 1 or y < 0 or y > 1 then return end

    -- showOnEdge=true so an arrow appears if the point is off the minimap
    HBDPins:AddMinimapIconMap(PIN_OWNER, data.minipin, data.zone, x, y, true)
end

function Frame:DrawMiniMapPins()
    Frame:HideMiniMapPins()
    Frame:ShowMiniMapPins()
end

function Frame:HideMiniMapPins() HBDPins:RemoveAllMinimapIcons(PIN_OWNER) end

function Frame:ShowMiniMapPins()
    MINI_MAP_ID = GetMapID()

    -- Use current map’s data; if none, try parent so city/indoors still show
    local zoneData = Frame:GetZoneData(MINI_MAP_ID)
    if not zoneData then
        local info = C_Map.GetMapInfo(MINI_MAP_ID)
        if info and info.parentMapID then zoneData = Frame:GetZoneData(info.parentMapID) end
    end
    if not zoneData then return end

    for _, npcData in pairs(zoneData) do Frame:ShowMiniMapNPC(npcData) end
end

function Frame:LoadNPCData(data)
    if data.loaded then return end

    -- Pre-load the loot to prevent bugs on tooltips
    local rarity = 0
    local itemRarity
    if type(data.loot) == "table" then
        for _, itemID in ipairs(data.loot) do
            _, _, itemRarity = GetItemInfo(itemID)
            if itemRarity ~= nil and itemRarity > rarity then rarity = itemRarity end
        end
    end

    data.loaded = true
    data.rarity = rarity
    data.worldpin = Frame:CreateMapPin(nil, data, true)
    data.minipin = Frame:CreateMapPin(nil, data, false)

end

function addon.VendorTreasures.UpdatePins()
    if not addon.settings.profile.enableVendorTreasure then
        Frame:HideWorldMapPins()
        Frame:HideMiniMapPins()
        return
    end
    if not next(DATA) then Frame:InitializeZones() end
    Frame:CheckWorldMap()
end

local eventsRegistered
local function OnVendorEvent(_, event)
    if event == "WORLD_MAP_UPDATE" then
        addon.VendorTreasures.UpdatePins()
    else
        Frame:CheckZone()
    end
end

function addon.VendorTreasures:Setup()
    if not addon.settings.profile.enableVendorTreasure then
        Frame:HideWorldMapPins()
        Frame:HideMiniMapPins()
        return
    end
    if not next(DATA) then Frame:InitializeZones() end
    if not eventsRegistered then
        eventsRegistered = true
        Frame:RegisterEvent("ZONE_CHANGED")
        Frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        -- The bundled legacy HereBeDragons bridge owns WORLD_MAP_UPDATE and
        -- repositions the already-registered pins. Modern clients still need
        -- this module's map-change redraw path.
        if not legacy335 then Frame:RegisterEvent("WORLD_MAP_UPDATE") end
        Frame:SetScript("OnEvent", OnVendorEvent)
    end
    Frame:CheckZone()
end
