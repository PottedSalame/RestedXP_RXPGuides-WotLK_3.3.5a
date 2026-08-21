--[[ ------------------------------------------------------------------------
    HereBeDragons-335.lua  -  Astrolabe-backed map/coordinate shim for 3.3.5a

    RXPGuides talks to the map through:
      * C_Map                (uiMapID based queries)
      * HereBeDragons-2.0    (world/zone coordinate conversion, player position)
      * HereBeDragons-Pins-2.0 (world map + minimap pins)

    None of the modern uiMapID / UnitPosition machinery exists on 3.3.5a, so this
    file re-implements exactly the subset RXPGuides uses on top of Astrolabe
    (the classic continent/zone-index coordinate library, bundled in libs/Astrolabe).

    The bridge between RXP's uiMapIDs and Astrolabe's (continent, zone) indices is
    built from Astrolabe's locale-independent map-file tokens. Localized
    GetMapZones() values are retained only for display.

    "World coordinates" in this shim are continent-normalized (0-1) coordinates
    plus an instance == continent index. All conversions round-trip through
    Astrolabe:TranslateWorldMapPosition so they are internally consistent; only
    the navigation arrow's global orientation depends on the yard-frame axes and
    is verified in-game.
------------------------------------------------------------------------------ ]]

local addonName, addon = ...
local _G = _G

-- Obtain the Astrolabe instance (registered through DongleStub).
local Astrolabe
if _G.DongleStub then
    local ok, lib = pcall(_G.DongleStub, "Astrolabe-0.4-RXP335")
    if ok and lib then Astrolabe = lib end
end
if not Astrolabe then
    _G.geterrorhandler()("RXPGuides 3.3.5: bundled Astrolabe is unavailable; map features are disabled")
    return
end

local floor, atan2, sqrt, PI2 = math.floor, math.atan2, math.sqrt, math.pi * 2

--=========================================================================
-- uiMapID <-> (continent, zone) bridge
--=========================================================================
local uiMapIDToCZ = {}     -- uiMapID -> { continentIndex, zoneIndex }
local czToUiMapID = {}     -- continentIndex*1000 + zoneIndex -> uiMapID
local nameByID     = {}    -- uiMapID -> zone name
local contSize     = {}    -- continentIndex -> { width, height } in yards
local bridgeBuilt  = false

local function czKey(c, z) return c * 1000 + z end

-- GetMapZones() returns localized display names, while addon.mapId is keyed by
-- the English names authored in guides. Astrolabe already resolves every zone
-- index to GetMapInfo()'s stable map-file token during its initialization, so
-- use that token as the identity boundary. These aliases cover the historical
-- file-name abbreviations and misspellings present in the 3.3.5 client data.
local legacyMapFileAliases = {
    Aszhara = "Azshara",
    Barrens = "The Barrens",
    Darnassis = "Darnassus",
    Dustwallow = "Dustwallow Marsh",
    Ogrimmar = "Orgrimmar",
    Alterac = "Alterac Mountains",
    Arathi = "Arathi Highlands",
    Elwynn = "Elwynn Forest",
    Hilsbrad = "Hillsbrad Foothills",
    Hinterlands = "The Hinterlands",
    Redridge = "Redridge Mountains",
    Silverpine = "Silverpine Forest",
    Stormwind = "Stormwind City",
    Stranglethorn = "Stranglethorn Vale",
    Sunwell = "Isle of Quel'Danas",
    Tirisfal = "Tirisfal Glades",
    Hellfire = "Hellfire Peninsula",
    LakeWintergrasp = "Wintergrasp",
}

local function normalizeMapName(name)
    if type(name) ~= "string" then return nil end
    local normalized = name:lower():gsub("[^%w]", "")
    normalized = normalized:gsub("^the", "")
    return normalized ~= "" and normalized or nil
end

local function buildStableMapLookup(mapId)
    local lookup = {}
    for name, id in pairs(mapId) do
        if type(name) == "string" and type(id) == "number" then
            local key = normalizeMapName(name)
            if key and lookup[key] == nil then
                lookup[key] = id
            elseif key and lookup[key] ~= id then
                lookup[key] = false
            end
        end
    end
    return lookup
end

local function computeContSize(c)
    if contSize[c] then return contSize[c] end
    local w = Astrolabe:ComputeDistance(c, 0, 0, 0.5, c, 0, 1, 0.5)
    local h = Astrolabe:ComputeDistance(c, 0, 0.5, 0, c, 0, 0.5, 1)
    if w and h and w > 0 and h > 0 then
        contSize[c] = { w, h }
        return contSize[c]
    end
end

-- Build the bridge from addon.mapId + native zone enumeration. Safe to call
-- repeatedly; only does real work once addon.mapId is populated.
local function BuildBridge()
    local mapId = addon and addon.mapId
    if not mapId or not next(mapId) then return false end
    if bridgeBuilt then return true end

    wipe(uiMapIDToCZ); wipe(czToUiMapID); wipe(nameByID)

    local stableMapIDs = buildStableMapLookup(mapId)

    -- Continent indexes are stable in the 3.3.5 client; only their display
    -- names are localized. Resolve the authored map IDs by canonical identity.
    local continents = { _G.GetMapContinents() }
    local continentKeys = {
        [1] = "Kalimdor",
        [2] = "Eastern Kingdoms",
        [3] = "Outland",
        [4] = "Northrend",
    }
    for c, cname in ipairs(continents) do
        local canonical = continentKeys[c]
        local id = canonical and mapId[canonical]
        if id then
            uiMapIDToCZ[id] = { c, 0 }
            czToUiMapID[czKey(c, 0)] = id
            nameByID[id] = type(cname) == "string" and cname or canonical
        end
    end

    -- Astrolabe.ContinentList contains locale-independent map-file tokens in
    -- the same indexes as the localized GetMapZones() result.
    for c = 1, #continents do
        local localizedZones = { _G.GetMapZones(c) }
        local mapFiles = Astrolabe.ContinentList and
                             Astrolabe.ContinentList[c] or {}
        for zoneIdx, mapFile in ipairs(mapFiles) do
            local canonical = legacyMapFileAliases[mapFile]
            local id = canonical and mapId[canonical]
            if not id then
                local key = normalizeMapName(mapFile)
                id = key and stableMapIDs[key]
                if id == false then id = nil end
            end
            -- English clients can still resolve unusual private-server map
            -- tokens from their display name, but localized names are never
            -- treated as identity.
            if not id then id = mapId[localizedZones[zoneIdx]] end
            if id then
                uiMapIDToCZ[id] = { c, zoneIdx }
                czToUiMapID[czKey(c, zoneIdx)] = id
                nameByID[id] = localizedZones[zoneIdx] or canonical or mapFile
            end
        end
    end

    -- Death Knight starting area: Astrolabe treats it as continent 5, zone 1.
    local dkID = mapId["Plaguelands: The Scarlet Enclave"] or mapId["ScarletEnclave"]
    if dkID then
        uiMapIDToCZ[dkID] = { 5, 1 }
        czToUiMapID[czKey(5, 1)] = dkID
    end

    -- Reverse-fill any remaining names from addon.mapId that resolved.
    for name, id in pairs(mapId) do
        if uiMapIDToCZ[id] and not nameByID[id] then nameByID[id] = name end
    end

    bridgeBuilt = true
    return true
end

-- Resolve a uiMapID to (continent, zone), building the bridge on demand.
local function resolve(uiMapID)
    if not uiMapID then return nil end
    if not bridgeBuilt then BuildBridge() end
    local cz = uiMapIDToCZ[uiMapID]
    if cz then return cz[1], cz[2] end
    return nil
end

-- Rebuild once map data is guaranteed ready.
local bridgeFrame = CreateFrame("Frame")
bridgeFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
bridgeFrame:SetScript("OnEvent", function()
    bridgeBuilt = false
    BuildBridge()
end)

-- Non-invasive "current zone uiMapID" via zone text (avoids changing map zoom).
local function currentPlayerUiMapID()
    local mapId = addon and addon.mapId
    if not mapId then return nil end
    if not bridgeBuilt then BuildBridge() end
    local c, z = Astrolabe:GetCurrentPlayerPosition()
    local id = c and czToUiMapID[czKey(c, z or 0)]
    if id then return id end
    return mapId[_G.GetSubZoneText()] or mapId[_G.GetZoneText()] or
               mapId[_G.GetRealZoneText()]
end

-- WorldSafeLocs.dbc stores graveyards in the legacy server coordinate frame,
-- while this 3.3.5 bridge exposes continent-normalized Astrolabe coordinates.
-- Keep the conversion here so callers never compare those incompatible
-- coordinate systems directly.  The Azeroth frames are the WotLK world-map
-- bounds used by HereBeDragons; Outland is its own world and therefore uses
-- its continent bounds directly.
local legacyWorldFrames = {
    [0] = { continent = 2, width = 48033.24, height = 32020.80,
            left = 36867.97, top = 14848.84, azeroth = true },
    [1] = { continent = 1, width = 47908.72, height = 31935.28,
            left = 8552.61, top = 18467.83, azeroth = true },
    [530] = { continent = 3, width = 17463.987300595,
              height = 11642.355227091, left = 12996.67,
              top = 5829.17 },
    [571] = { continent = 4, width = 47662.70, height = 31772.19,
              left = 25198.53, top = 11072.07, azeroth = true },
}

local function transformLegacyExpansionPosition(x, y, instance)
    -- HereBeDragons uses the inverse axis order of WorldSafeLocs: its world X
    -- is the server Y coordinate and its world Y is the server X coordinate.
    x, y = y, x

    -- Blood Elf and Draenei zones live in map 530 in the 3.3.5 data files but
    -- are rendered on the Eastern Kingdoms and Kalimdor continent maps.  These
    -- are the same WotLK transforms used by HereBeDragons proper.
    if instance == 530 then
        if x >= -10133.3 and x <= -2666.67 and
                y >= 4800 and y <= 16000 then
            return x + 2662.8, y - 2400, 0
        elseif x >= -16000 and x <= -8000 and
                y >= -6933.33 and y <= 533.33 then
            return x + 17600, y + 10339.7, 1
        end
    end
    return x, y, instance
end

local function legacyPositionToAstrolabe(x, y, instance)
    if type(x) ~= "number" or type(y) ~= "number" or
            type(instance) ~= "number" then
        return nil, nil, nil
    end

    x, y, instance = transformLegacyExpansionPosition(x, y, instance)
    local frame = legacyWorldFrames[instance]
    local maps = _G.WorldMapSize
    local continent = frame and maps and maps[frame.continent]
    if not frame or not continent or not continent.width or
            not continent.height then
        return nil, nil, nil
    end

    local nx = (frame.left - x) / frame.width
    local ny = (frame.top - y) / frame.height
    if frame.azeroth then
        local world = maps[0]
        if not world or not world.width or not world.height then
            return nil, nil, nil
        end
        nx = (nx * world.width - (continent.xOffset or 0)) /
                 continent.width
        ny = (ny * world.height - (continent.yOffset or 0)) /
                 continent.height
    end

    return nx, ny, frame.continent
end

--=========================================================================
-- C_Map  (fill the table created by Compat335.lua)
--=========================================================================
local C_Map = _G.C_Map or {}
_G.C_Map = C_Map

function C_Map.GetBestMapForUnit(unit)
    if unit ~= "player" then return nil end
    return currentPlayerUiMapID()
end

function C_Map.GetPlayerMapPosition(uiMapID, unit)
    unit = unit or "player"
    local c, z, x, y = Astrolabe:GetCurrentPlayerPosition()
    if not c or not x then return nil end
    local tc, tz = resolve(uiMapID)
    if tc and (tc ~= c or tz ~= z) then
        local nx, ny = Astrolabe:TranslateWorldMapPosition(c, z, x, y, tc, tz)
        if nx then x, y = nx, ny end
    end
    return _G.CreateVector2D(x, y)
end

function C_Map.GetMapInfo(uiMapID)
    if not uiMapID then return nil end
    local c, z = resolve(uiMapID)
    local parent
    if c then parent = czToUiMapID[czKey(c, 0)] end
    local mapType = _G.Enum.UIMapType.Zone
    if z == 0 then mapType = _G.Enum.UIMapType.Continent end
    return {
        mapID = uiMapID,
        name = nameByID[uiMapID] or "",
        parentMapID = parent or 0,
        mapType = mapType,
    }
end

-- Modern GetAreaInfo(areaID) -> localized area name. The legacy client only
-- exposes the current area as text, so keep the 3.3.5a AreaTable names needed
-- by every guide loaded from GuideList_335.xml. Keeping this compatibility at
-- the C_Map boundary also fixes .home, .bindlocation, .subzone and
-- .subzoneskip without teaching each directive about the old API.
--
-- Source: AzerothCore's 3.3.5a AreaTable documentation.
local legacyAreaNames = {
    [20] = "Moonbrook",
    [25] = "Blackrock Mountain",
    [33] = "Stranglethorn Vale",
    [35] = "Booty Bay",
    [43] = "Wild Shore",
    [99] = "Rebel Camp",
    [100] = "Nesingwary's Expedition",
    [101] = "Kurzen's Compound",
    [106] = "The Stockpile",
    [117] = "Grom'gol Base Camp",
    [131] = "Kharanos",
    [133] = "Gnomeregan",
    [144] = "Thelsamar",
    [152] = "The Bulwark",
    [159] = "Brill",
    [190] = "Hearthglen",
    [192] = "Northridge Lumber Camp",
    [209] = "Shadowfang Keep",
    [222] = "Bloodhoof Village",
    [228] = "The Sepulcher",
    [251] = "Flame Crest",
    [254] = "Blackrock Mountain",
    [271] = "Southshore",
    [272] = "Tarren Mill",
    [279] = "Dalaran Crater",
    [281] = "Ruins of Alterac",
    [286] = "Hillsbrad Fields",
    [288] = "Azurelode Mine",
    [297] = "Jaguero Isle",
    [311] = "Ruins of Aboraz",
    [316] = "Boulderfist Hall",
    [317] = "Witherbark Village",
    [320] = "Refuge Pointe",
    [321] = "Hammerfall",
    [324] = "Stromgarde Keep",
    [340] = "Kargath",
    [348] = "Aerie Peak",
    [349] = "Wildhammer Keep",
    [350] = "Quel'Danil Lodge",
    [351] = "Skulk Rock",
    [353] = "Shadra'Alor",
    [354] = "Jintha'Alor",
    [355] = "The Altar of Zul",
    [367] = "Sen'jin Village",
    [378] = "Camp Taurajo",
    [386] = "The Forgotten Pools",
    [388] = "The Stagnant Oasis",
    [392] = "Ratchet",
    [403] = "Shady Rest Inn",
    [460] = "Sun Rock Retreat",
    [477] = "Ruins of Jubuwal",
    [479] = "The Rustmaul Dig Site",
    [484] = "Freewind Post",
    [491] = "Razorfen Kraul",
    [496] = "Brackenwall Village",
    [503] = "Sentry Point",
    [513] = "Theramore Isle",
    [537] = "Fire Plume Ridge",
    [541] = "Marshal's Refuge",
    [542] = "Fungal Rock",
    [608] = "Nijel's Point",
    [721] = "Gnomeregan",
    [722] = "Razorfen Downs",
    [796] = "Scarlet Monastery",
    [879] = "Southfury River",
    [976] = "Gadgetzan",
    [977] = "Steamwheedle Port",
    [978] = "Zul'Farrak",
    [980] = "Thistleshrub Valley",
    [981] = "The Gaping Chasm",
    [982] = "The Noxious Lair",
    [983] = "Dunemaul Compound",
    [1099] = "Camp Mojache",
    [1237] = "Valormok",
    [1336] = "Lost Rigger Cove",
    [1337] = "Uldaman",
    [1417] = "Sunken Temple",
    [1443] = "The Slag Pit",
    [1446] = "Thorium Point",
    [1477] = "The Temple of Atal'Hakkar",
    [1497] = "Undercity",
    [1519] = "Stormwind City",
    [1537] = "Ironforge",
    [1581] = "The Deadmines",
    [1583] = "Blackrock Spire",
    [1584] = "Blackrock Depths",
    [1637] = "Orgrimmar",
    [1638] = "Thunder Bluff",
    [1659] = "Craftsmen's Terrace",
    [1682] = "Dandred's Fold",
    [1684] = "Chillwind Point",
    [1763] = "Jaedenar",
    [1770] = "Shadow Hold",
    [1880] = "Featherbeard's Hovel",
    [1883] = "Valorwind Lake",
    [1941] = "Caverns of Time",
    [1997] = "Bloodvenom Post",
    [1998] = "Talonbranch Glade",
    [2017] = "Stratholme",
    [2057] = "Scholomance",
    [2100] = "Maraudon",
    [2101] = "Stoutlager Inn",
    [2104] = "Deepwater Tavern",
    [2240] = "Mirage Raceway",
    [2241] = "Frostsaber Rock",
    [2244] = "Winterfall Village",
    [2248] = "Dun Mandarr",
    [2253] = "Starfall Village",
    [2255] = "Everlook",
    [2257] = "Deeprun Tram",
    [2264] = "Corin's Crossing",
    [2268] = "Light's Hope Chapel",
    [2273] = "Zul'Mashar",
    [2277] = "Plaguewood",
    [2279] = "Stratholme",
    [2298] = "Caer Darrow",
    [2300] = "Caverns of Time",
    [2371] = "Dun Garok",
    [2407] = "Kormek's Hut",
    [2408] = "Shadowprey Village",
    [2437] = "Ragefire Chasm",
    [2479] = "Emerald Sanctuary",
    [2557] = "Dire Maul",
    [2562] = "Karazhan",
    [2627] = "Terrordale",
    [2740] = "The Crystal Vale",
    [2797] = "Blackfathom Deeps",
    [2837] = "The Master's Cellar",
    [2897] = "Zoram'gar Outpost",
    [3197] = "Chillwind Camp",
    [3317] = "Revantusk Village",
    [3425] = "Cenarion Hold",
    [3486] = "Ravenholdt Manor",
    [3536] = "Thrallmar",
    [3538] = "Honor Hold",
    [3543] = "The Great Fissure",
    [3551] = "Ruins of Sha'naar",
    [3552] = "Temple of Telhamat",
    [3553] = "Pools of Aggonar",
    [3554] = "Falcon Watch",
    [3562] = "Hellfire Ramparts",
    [3565] = "Cenarion Refuge",
    [3607] = "Serpentshrine Cavern",
    [3610] = "Burning Blade Ruins",
    [3613] = "Garadar",
    [3614] = "Skysong Lake",
    [3615] = "Throne of the Elements",
    [3623] = "Aeris Landing",
    [3626] = "Telaar",
    [3628] = "Halaa",
    [3637] = "Kil'sorrow Fortress",
    [3640] = "Daggerfen Village",
    [3641] = "Umbrafen Village",
    [3642] = "Feralfen Village",
    [3643] = "Bloodscale Enclave",
    [3644] = "Telredor",
    [3645] = "Zabra'jin",
    [3648] = "The Dead Mire",
    [3649] = "Sporeggar",
    [3650] = "Ango'rosh Grounds",
    [3651] = "Ango'rosh Stronghold",
    [3653] = "Serpent Lake",
    [3655] = "Umbrafen Lake",
    [3667] = "Hewn Bog",
    [3672] = "Mag'hari Procession",
    [3673] = "Nesingwary Safari",
    [3674] = "Cenarion Thicket",
    [3675] = "Tuurem",
    [3677] = "Veil Skith",
    [3678] = "Veil Shalas",
    [3683] = "Stonebreaker Hold",
    [3684] = "Allerian Stronghold",
    [3686] = "Veil Lithic",
    [3712] = "Area 52",
    [3713] = "The Blood Furnace",
    [3715] = "The Steamvault",
    [3716] = "The Underbog",
    [3717] = "The Slave Pens",
    [3718] = "Swamprat Post",
    [3724] = "Cosmowrench",
    [3725] = "Ruins of Enkaat",
    [3733] = "The Violet Tower",
    [3737] = "Celestial Ridge",
    [3738] = "The Stormspire",
    [3742] = "Socrethar's Seat",
    [3743] = "Legion Hold",
    [3744] = "Shadowmoon Village",
    [3745] = "Wildhammer Stronghold",
    [3747] = "The Fel Pits",
    [3752] = "Illidari Point",
    [3753] = "Ruins of Baa'ri",
    [3754] = "Altar of Sha'tar",
    [3758] = "Netherwing Fields",
    [3759] = "Netherwing Ledge",
    [3766] = "Orebor Harborage",
    [3769] = "Thunderlord Stronghold",
    [3772] = "Sylvanaar",
    [3786] = "Ogri'la",
    [3789] = "Shadow Labyrinth",
    [3790] = "Auchenai Crypts",
    [3792] = "Mana-Tombs",
    [3807] = "Reaver's Fall",
    [3808] = "Cenarion Post",
    [3812] = "Spinebreaker Post",
    [3815] = "Expedition Point",
    [3816] = "Zeppelin Crash",
    [3819] = "Darkcrest Enclave",
    [3822] = "Eclipse Point",
    [3841] = "Darkcrest Shore",
    [3844] = "Mok'Nathal Village",
    [3846] = "The Arcatraz",
    [3848] = "The Arcatraz",
    [3851] = "Midrealm Post",
    [3852] = "Tuluman's Landing",
    [3854] = "Protectorate Watch Post",
    [3864] = "Bash'ir Landing",
    [3874] = "Eco-Dome Farfield",
    [3881] = "Trelleum Mine",
    [3887] = "Refugee Caravan",
    [3888] = "Shadow Tomb",
    [3893] = "Ring of Observance",
    [3896] = "Aldor Rise",
    [3898] = "Scryer's Tier",
    [3901] = "Allerian Post",
    [3902] = "Stonebreaker Camp",
    [3905] = "Coilfang Reservoir",
    [3918] = "Toshley's Station",
    [3920] = "Shatter Point",
    [3928] = "The Altar of Damnation",
    [3934] = "Town Square",
    [3938] = "Sanctum of the Stars",
    [3943] = "Invasion Point: Cataclysm",
    [3951] = "Evergrove",
    [3958] = "Sha'tari Base Camp",
    [3973] = "Blackwind Landing",
    [3975] = "Terokk's Rest",
    [4010] = "Mudsprocket",
    [4046] = "Direhorn Post",
    [4049] = "Tabetha's Farm",
}

function C_Map.GetAreaInfo(areaID)
    areaID = tonumber(areaID)
    local name = legacyAreaNames[areaID]
    if not name and addon and type(addon.LegacyAreaNames335) == "table" then
        name = addon.LegacyAreaNames335[areaID]
    end
    if name and addon and type(addon.LocalizeLegacyLocationName) == "function" then
        return addon.LocalizeLegacyLocationName(name)
    end
    return name
end

-- GetWorldPosFromMapPos(uiMapID, mapPos) -> instanceID, worldVector
function C_Map.GetWorldPosFromMapPos(uiMapID, mapPos)
    local c, z = resolve(uiMapID)
    if not c then return nil end
    local x, y = 0, 0
    if mapPos and mapPos.GetXY then x, y = mapPos:GetXY() end
    local wx, wy = Astrolabe:TranslateWorldMapPosition(c, z, x, y, c, 0)
    return c, _G.CreateVector2D(wx or 0, wy or 0)
end

-- WorldMapFrame:GetMapID() -> the uiMapID currently displayed on the world map.
-- (Modern method; 3.3.5a uses GetCurrentMapContinent/Zone.) map.lua calls this
-- every frame while drawing lines, so it must exist.
if _G.WorldMapFrame and _G.WorldMapFrame.GetMapID == nil then
    _G.WorldMapFrame.GetMapID = function()
        if not bridgeBuilt then BuildBridge() end
        local c = (_G.GetCurrentMapContinent and _G.GetCurrentMapContinent()) or -1
        local z = (_G.GetCurrentMapZone and _G.GetCurrentMapZone()) or 0
        return czToUiMapID[czKey(c, z)] or czToUiMapID[czKey(c, 0)]
            or currentPlayerUiMapID()
    end
end

--=========================================================================
-- C_DeathInfo (legacy corpse position with map-state preservation)
--=========================================================================
do
    local C_DeathInfo = _G.C_DeathInfo or {}
    _G.C_DeathInfo = C_DeathInfo
    local corpseCache = {retryAt = 0}

    local function restoreMap(continent, zone)
        if not _G.SetMapZoom then return end
        if continent == nil then
            if _G.SetMapToCurrentZone then pcall(_G.SetMapToCurrentZone) end
            return
        end
        local ok = pcall(_G.SetMapZoom, continent, zone)
        if not ok and _G.SetMapToCurrentZone then
            pcall(_G.SetMapToCurrentZone)
        end
    end

    local function readCorpseOnMap(continent, zone)
        if not (_G.SetMapZoom and _G.GetCorpseMapPosition) then return nil end
        local ok = pcall(_G.SetMapZoom, continent, zone)
        if not ok then return nil end
        local x, y = _G.GetCorpseMapPosition()
        if x and y and (x > 0 or y > 0) then return x, y end
        return nil
    end

    function C_DeathInfo.GetCorpseMapPosition(uiMapID)
        local continent, zone = resolve(uiMapID)
        if not continent then return nil end
        local oldContinent = _G.GetCurrentMapContinent and _G.GetCurrentMapContinent()
        local oldZone = _G.GetCurrentMapZone and _G.GetCurrentMapZone()
        local x, y = readCorpseOnMap(continent, zone or 0)
        restoreMap(oldContinent, oldZone)
        if x then return _G.CreateVector2D(x, y) end
        return nil
    end

    -- Internal extension used by map.lua when the corpse is outside the
    -- player's current zone. Returns uiMapID, Vector2D.
    function C_DeathInfo.GetCorpseMapLocation()
        if not (_G.UnitIsGhost and _G.UnitIsGhost("player")) then return nil end
        if not bridgeBuilt then BuildBridge() end
        if corpseCache.mapID and corpseCache.position then
            return corpseCache.mapID, corpseCache.position
        end
        local now = _G.GetTime()
        if now < (corpseCache.retryAt or 0) then return nil end
        corpseCache.retryAt = now + 2

        local oldContinent = _G.GetCurrentMapContinent and _G.GetCurrentMapContinent()
        local oldZone = _G.GetCurrentMapZone and _G.GetCurrentMapZone()
        local foundContinent, foundZone, foundX, foundY

        local function tryMap(continent, zone)
            local x, y = readCorpseOnMap(continent, zone)
            if x then
                foundContinent, foundZone, foundX, foundY = continent, zone, x, y
                return true
            end
            return false
        end

        local function scan()
            if oldContinent and oldContinent > 0 and
                tryMap(oldContinent, oldZone or 0) then return end

            local playerContinent, playerZone = Astrolabe:GetCurrentPlayerPosition()
            if playerContinent and tryMap(playerContinent, playerZone or 0) then return end

            local count = _G.GetMapContinents and select("#", _G.GetMapContinents()) or 0
            for continent = 1, count do
                if tryMap(continent, 0) then break end
            end

            -- A continent position is sufficient, but a zone position gives the
            -- most stable conversion through Astrolabe when one is available.
            if foundContinent and _G.GetMapZones then
                local continentX, continentY = foundX, foundY
                local zoneCount = select("#", _G.GetMapZones(foundContinent))
                for zone = 1, zoneCount do
                    if tryMap(foundContinent, zone) then return end
                end
                foundZone, foundX, foundY = 0, continentX, continentY
            end
        end

        pcall(scan)
        restoreMap(oldContinent, oldZone)

        if foundContinent and foundX then
            local mapID = czToUiMapID[czKey(foundContinent, foundZone or 0)]
            if mapID then
                corpseCache.mapID = mapID
                corpseCache.position = _G.CreateVector2D(foundX, foundY)
                return corpseCache.mapID, corpseCache.position
            end
        end
        return nil
    end

    local corpseEvents = _G.CreateFrame("Frame")
    corpseEvents:RegisterEvent("PLAYER_DEAD")
    corpseEvents:RegisterEvent("PLAYER_ALIVE")
    corpseEvents:RegisterEvent("PLAYER_UNGHOST")
    corpseEvents:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    corpseEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
    corpseEvents:SetScript("OnEvent", function()
        corpseCache.mapID, corpseCache.position, corpseCache.retryAt = nil, nil, 0
    end)
end

--=========================================================================
-- HereBeDragons-2.0
--=========================================================================
local HBD
if _G.LibStub then
    HBD = _G.LibStub:NewLibrary("HereBeDragons-2.0", 9000)
end
if HBD then
    HBD.transforms = HBD.transforms or {}
    HBD.mapData    = HBD.mapData or {}

    -- Internal 3.3.5 extension used by static server-coordinate databases
    -- (currently Spirit Healers).  Returned values deliberately use this
    -- shim's normal continent-coordinate domain and can therefore be passed
    -- to GetWorldDistance/GetWorldVector without special handling.
    function HBD:GetWorldCoordinatesFromLegacyPosition(x, y, instance)
        return legacyPositionToAstrolabe(x, y, instance)
    end

    -- Convert local (0-1) zone coordinates to world (continent-normalized) coords.
    -- @return worldX, worldY, instance(continent)
    function HBD:GetWorldCoordinatesFromZone(x, y, zone)
        if not x or not y then return nil, nil, nil end
        local c, z = resolve(zone)
        if not c then return nil, nil, nil end
        local wx, wy = Astrolabe:TranslateWorldMapPosition(c, z, x, y, c, 0)
        if not wx then return nil, nil, nil end
        return wx, wy, c
    end

    -- Convert world (continent-normalized) coords back to local zone coords.
    function HBD:GetZoneCoordinatesFromWorld(x, y, zone, allowOutOfBounds)
        if not x or not y then return nil, nil end
        local c, z = resolve(zone)
        if not c then return nil, nil end
        local zx, zy = Astrolabe:TranslateWorldMapPosition(c, 0, x, y, c, z)
        if not zx then return nil, nil end
        if not allowOutOfBounds and (zx < 0 or zx > 1 or zy < 0 or zy > 1) then
            return nil, nil
        end
        return zx, zy
    end

    -- Distance in yards between two world positions on the same continent.
    -- @return distance, deltaX(east, yards), deltaY(south, yards)
    function HBD:GetWorldDistance(instance, oX, oY, dX, dY)
        if not (oX and oY and dX and dY) then return nil, nil, nil end
        local size = computeContSize(instance)
        if not size then return nil, nil, nil end
        local dx = (dX - oX) * size[1]
        local dy = (dY - oY) * size[2]
        return sqrt(dx * dx + dy * dy), dx, dy
    end

    -- Bearing + distance to a target world position. Reproduces HereBeDragons-2.0's
    -- exact angle so RXP's DrawArrow (written for HBD-2.0) behaves as on retail.
    -- Our GetWorldDistance returns dx = east(+), dy = south(+); HBD-2.0 works in a
    -- (north, west) frame, so convert: north = -dy, west = -dx, then apply HBD-2.0's
    -- formula verbatim.
    function HBD:GetWorldVector(instance, oX, oY, dX, dY)
        local distance, dx, dy = self:GetWorldDistance(instance, oX, oY, dX, dY)
        if not distance then return nil, nil end
        -- dx = east(+), dy = south(+) yard deltas. This reproduces
        -- Astrolabe:GetDirectionToIcon EXACTLY (the same math that places the
        -- correct minimap pin), so RXP's arrow rotation (angle - GetPlayerFacing)
        -- matches the CCW-from-north convention GetPlayerFacing uses.
        local angle = atan2(dx, -dy)
        if angle > 0 then
            angle = PI2 - angle
        else
            angle = -angle
        end
        return angle, distance
    end

    function HBD:GetPlayerWorldPosition()
        local c, z, x, y = Astrolabe:GetCurrentPlayerPosition()
        if not c or not x then return nil, nil, nil end
        local wx, wy = Astrolabe:TranslateWorldMapPosition(c, z, x, y, c, 0)
        if not wx then return nil, nil, c end
        return wx, wy, c
    end

    function HBD:GetPlayerZone()
        local c, z = Astrolabe:GetCurrentPlayerPosition()
        if not c then
            return currentPlayerUiMapID()
        end
        return czToUiMapID[czKey(c, z)] or currentPlayerUiMapID()
    end

    function HBD:GetPlayerZonePosition(allowOutOfBounds)
        local c, z, x, y = Astrolabe:GetCurrentPlayerPosition()
        if not c or not x then return nil, nil, nil, nil end
        local uiMapID = czToUiMapID[czKey(c, z)]
        return x, y, uiMapID, (z == 0 and _G.Enum.UIMapType.Continent or _G.Enum.UIMapType.Zone)
    end

    function HBD:GetZoneSize(zone)
        local c, z = resolve(zone)
        if not c then return 0, 0 end
        local w = Astrolabe:ComputeDistance(c, z, 0, 0.5, c, z, 1, 0.5)
        local h = Astrolabe:ComputeDistance(c, z, 0.5, 0, c, z, 0.5, 1)
        return w or 0, h or 0
    end

    -- Approximate GetZoneDistance used by some helpers.
    function HBD:GetZoneDistance(oZone, oX, oY, dZone, dX, dY)
        local owx, owy, oi = self:GetWorldCoordinatesFromZone(oX, oY, oZone)
        local dwx, dwy, di = self:GetWorldCoordinatesFromZone(dX, dY, dZone)
        if not owx or not dwx or oi ~= di then return nil, nil, nil end
        return self:GetWorldDistance(oi, owx, owy, dwx, dwy)
    end

    function HBD:GetUniqueZoneCoordinatesFromWorld(...) return self:GetZoneCoordinatesFromWorld(...) end
    function HBD:GetAllMapIDs()
        if not bridgeBuilt then BuildBridge() end
        local t = {}
        for id in pairs(uiMapIDToCZ) do t[#t + 1] = id end
        return t
    end
    function HBD:GetMapInfo(uiMapID) return C_Map.GetMapInfo(uiMapID) end
end

--=========================================================================
-- HereBeDragons-Pins-2.0  (world map + minimap pins, backed by Astrolabe)
--=========================================================================
_G.HBD_PINS_WORLDMAP_SHOW_WORLD     = 1
_G.HBD_PINS_WORLDMAP_SHOW_CONTINENT = 2
_G.HBD_PINS_WORLDMAP_SHOW_PARENT    = 3
_G.HBD_PINS_WORLDMAP_SHOW_CURRENT   = 4

local Pins
if _G.LibStub then
    Pins = _G.LibStub:NewLibrary("HereBeDragons-Pins-2.0", 9000)
end
if Pins then
    local minimapPins = Pins._minimapPins or {}   -- owner -> { [icon]=true }
    local worldPins   = Pins._worldPins   or {}   -- owner -> { [icon]={c,z,x,y} }
    Pins._minimapPins = minimapPins
    Pins._worldPins   = worldPins

    local worldMapAnchor = _G.WorldMapDetailFrame

    local function ownerTable(t, owner)
        local set = t[owner]
        if not set then set = {}; t[owner] = set end
        return set
    end

    function Pins:AddMinimapIconMap(owner, icon, uiMapID, x, y, showFlag, floatOnEdge)
        local c, z = resolve(uiMapID)
        if not c or not icon then return end
        Astrolabe:PlaceIconOnMinimap(icon, c, z, x, y)
        ownerTable(minimapPins, owner)[icon] = true
    end

    function Pins:RemoveMinimapIcon(owner, icon)
        if not icon then return end
        Astrolabe:RemoveIconFromMinimap(icon)
        local set = minimapPins[owner]
        if set then set[icon] = nil end
    end

    function Pins:RemoveAllMinimapIcons(owner)
        local set = minimapPins[owner]
        if not set then return end
        for icon in pairs(set) do
            Astrolabe:RemoveIconFromMinimap(icon)
            set[icon] = nil
        end
    end

    local function placeWorldIcon(icon, c, z, x, y)
        if not worldMapAnchor then worldMapAnchor = _G.WorldMapDetailFrame end
        if not worldMapAnchor then return end
        -- Astrolabe:PlaceIconOnWorldMap only anchors + shows the icon; it does NOT
        -- reparent it. Parent it to the world-map frame so it is hidden together
        -- with the map (otherwise the pin renders on-screen permanently) and draws
        -- above the map art.
        -- WorldMapButton is a transparent full-map input layer and is declared
        -- after WorldMapDetailFrame in stock 3.3.5 FrameXML. Interactive icons
        -- parented to the detail frame remain visible but cannot receive hover
        -- or click events. Reparent only explicitly marked interactive pins to
        -- that input layer; ordinary guide pins keep their existing behavior.
        local iconParent = worldMapAnchor
        if icon.__HBD335InteractiveWorldPin and _G.WorldMapButton then
            iconParent = _G.WorldMapButton
        end
        icon:SetParent(iconParent)
        icon:SetFrameStrata(iconParent:GetFrameStrata())
        icon:SetFrameLevel((iconParent:GetFrameLevel() or 0) + 5)
        local ok = Astrolabe:PlaceIconOnWorldMap(worldMapAnchor, icon, c, z, x, y)
        -- Astrolabe returns nil-ish and hides the icon when it is not on the
        -- currently displayed map.
        if ok == nil then icon:Hide() end
    end

    function Pins:AddWorldMapIconMap(owner, icon, uiMapID, x, y, showFlags)
        local c, z = resolve(uiMapID)
        if not c or not icon then return end
        ownerTable(worldPins, owner)[icon] = { c, z, x, y }
        placeWorldIcon(icon, c, z, x, y)
    end

    function Pins:RemoveWorldMapIcon(owner, icon)
        if icon then icon:Hide() end
        local set = worldPins[owner]
        if set then set[icon] = nil end
    end

    function Pins:RemoveAllWorldMapIcons(owner)
        local set = worldPins[owner]
        if not set then return end
        for icon in pairs(set) do
            icon:Hide()
            set[icon] = nil
        end
    end

    local function refreshWorldMapIcons(owner)
        if owner then
            local set = worldPins[owner]
            if not set then return end
            for icon, data in pairs(set) do
                placeWorldIcon(icon, data[1], data[2], data[3], data[4])
            end
            return
        end

        for _, set in pairs(worldPins) do
            for icon, data in pairs(set) do
                placeWorldIcon(icon, data[1], data[2], data[3], data[4])
            end
        end
    end

    -- Modules may explicitly refresh one owner after changing the legacy map
    -- layout without unregistering and rebuilding its entire static pin set.
    function Pins:RefreshWorldMapIcons(owner)
        refreshWorldMapIcons(owner)
    end

    -- Re-place world map pins whenever the displayed world map changes.
    if not Pins._updateFrame then
        local f = CreateFrame("Frame")
        Pins._updateFrame = f
        f:RegisterEvent("WORLD_MAP_UPDATE")
        f:SetScript("OnEvent", function()
            -- The legacy map emits several events while it opens and resizes.
            -- Collapse a same-frame burst and place each registered pin only
            -- once against the final map dimensions.
            f.refreshGeneration = (f.refreshGeneration or 0) + 1
            local generation = f.refreshGeneration
            if C_Timer and C_Timer.After then
                C_Timer.After(0, function()
                    if generation == f.refreshGeneration then
                        refreshWorldMapIcons()
                    end
                end)
            else
                refreshWorldMapIcons()
            end
        end)
    end
end
