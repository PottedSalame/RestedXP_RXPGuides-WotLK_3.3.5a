local _, addon = ...

-- Guide localization is deliberately a presentation service.  Parsed guide
-- fields remain the canonical English/automation data; this module only
-- produces strings for FontStrings, menus and tooltips.
local service = {}
addon.guideLocalization = service
service.englishNames = {
    quests = {
        [9671] = "Urgent Delivery",
        [10024] = "Voren'thal's Visions",
        [11940] = "Drake Hunt",
    },
    items = {},
    spells = {},
    factions = {},
}

local locale = GetLocale()
local supported = {
    deDE = true, esES = true, frFR = true, koKR = true, ruRU = true,
    zhCN = true, zhTW = true,
}
local englishClient = locale == "enUS" or locale == "enGB"
local cache = {}
local catalog
local standingNames
local FALLBACK_BADGE = " |cff9d9d9d[EN]|r"
local FALLBACK_PATTERN = "%s*|cff9d9d9d%[EN%]|r$"

local sourceFields = {
    text = "sourceText",
    tooltipText = "sourceTooltipText",
    mapTooltip = "sourceMapTooltip",
    title = "sourceTitle",
    arrowtext = "sourceArrowText",
}

local function Trim(value)
    if type(value) ~= "string" then return value end
    return value:match("^%s*(.-)%s*$")
end

local function Substitute(template, values)
    return (template:gsub("{([%a_][%w_]*)}", function(key)
        local value = values and values[key]
        return value == nil and ("{" .. key .. "}") or tostring(value)
    end))
end

local function StripMarkup(value)
    if type(value) ~= "string" then return "" end
    value = value:gsub("|T.-|t", "")
    value = value:gsub("|cRXP_[A-Z]+_", "")
    value = value:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    value = value:gsub("|H.-|h", ""):gsub("|h", "")
    return Trim(value)
end

local function EnglishNameFromText(tag, text)
    text = StripMarkup((text or ""):gsub("%s*<<.*$", ""))
    if tag == "accept" then
        return text:match("^[Aa]ccept%s+(.+)$") or text ~= "" and text or nil
    elseif tag == "turnin" then
        return text:match("^[Tt]urn in%s+(.+)$")
    elseif tag == "train" then
        return text:match("^[Tt]rain%s+(.+)$") or
                   text:match("^[Ll]earn%s+(.+)$") or
                   text:match("%[([^%]]+)%]")
    end
    return text:match("%[([^%]]+)%]")
end

function service:IndexEnglishGuideSource(source)
    if type(source) ~= "string" then return end
    for line in source:gmatch("[^\r\n]+") do
        local dailyTag, dailyIds, dailyText = line:match(
            "^%s*%.([%a]+)%s+([^>]+)>>%s*(.-)%s*$")
        if (dailyTag == "daily" or dailyTag == "dailyturnin") and
           dailyIds and dailyText then
            dailyText = StripMarkup(dailyText:gsub("%s*<<.*$", ""))
            local dailyName = dailyText:match("^[Aa]ccept%s+(.+)$") or
                                  dailyText:match("^[Tt]urn in%s+(.+)$")
            if dailyName and dailyName ~= "" then
                for dailyId in dailyIds:gmatch("%d+") do
                    dailyId = tonumber(dailyId)
                    self.englishNames.quests[dailyId] =
                        self.englishNames.quests[dailyId] or dailyName
                end
            end
        end
        local tag, id = line:match("^%s*%.(%S+)%s+%-?(%d+)")
        if tag and id then
            id = tonumber(id)
            local visible = line:match(">>%s*(.-)%s*$")
            local name = visible and EnglishNameFromText(tag, visible)
            if name and name ~= "" and name ~= "*quest*" then
                if tag == "accept" or tag == "turnin" then
                    self.englishNames.quests[id] = self.englishNames.quests[id] or name
                elseif tag == "train" or tag == "usespell" then
                    self.englishNames.spells[id] = self.englishNames.spells[id] or name
                elseif tag == "collect" or tag == "buy" or tag == "equip" or
                       tag == "use" or tag == "itemcount" then
                    self.englishNames.items[id] = self.englishNames.items[id] or name
                end
            end
        end
    end
end

local function HasDisplayText(value)
    value = StripMarkup(value)
    return value ~= "" and value ~= "-" and value:find("[%a\128-\255]") ~= nil
end

local function GetMode()
    local profile = addon.settings and addon.settings.profile
    local requested = profile and profile.guideLanguage or "localized"
    if requested ~= "english" then requested = "localized" end
    if englishClient or not supported[locale] then return "english" end
    return requested
end

function service:RegisterCatalog(code, data)
    if code ~= locale or type(data) ~= "table" then return false end
    catalog = data
    cache = {}
    return true
end

function service:RegisterExactCatalog(code, entries, source)
    if code ~= locale or type(entries) ~= "table" then return false end
    catalog = catalog or {}
    catalog.exact = catalog.exact or {}
    catalog.exactSources = catalog.exactSources or {}
    for english, translated in pairs(entries) do
        if type(english) == "string" and english ~= "" and
           type(translated) == "string" and translated ~= "" and
           not catalog.exact[english] then
            catalog.exact[english] = translated
            catalog.exactSources[english] = source
        end
    end
    cache = {}
    return true
end

function service:RegisterEnglishNames(names)
    if type(names) ~= "table" then return end
    for kind, values in pairs(names) do
        local target = self.englishNames[kind]
        if target and type(values) == "table" then
            for id, name in pairs(values) do
                id = tonumber(id)
                if id and type(name) == "string" and name ~= "" then
                    target[id] = target[id] or name
                end
            end
        end
    end
end

function service:GetClientLocale() return locale end
function service:IsSupported() return supported[locale] == true end
function service:GetMode() return GetMode() end
function service:IsLocalized() return GetMode() == "localized" end

function service:UI(key)
    return catalog and catalog.ui and catalog.ui[key] or key
end

function service:GetFallbackExplanation()
    return self:UI("This instruction has not yet been reviewed in your language.")
end

function service:ClearCache()
    cache = {}
end

local function ReplaceCreatureNames(text)
    if type(addon.GetCreatureName) ~= "function" then return text, false end
    local changed = false
    local function Replace(prefix, name, suffix)
        local translated = addon.GetCreatureName(name) or name
        if translated ~= name then changed = true end
        return prefix .. translated .. suffix
    end
    text = text:gsub("(|cRXP_FRIENDLY_)(.-)(|r)", Replace)
    text = text:gsub("(|cRXP_ENEMY_)(.-)(|r)", Replace)
    return text, changed
end

local itemTags = {
    collect = true, buy = true, equip = true, use = true, itemcount = true,
    itemStat = true, destroy = true,
}
local function ReplaceItemName(text, element)
    if type(element) ~= "table" or not itemTags[element.tag] or
       type(element.itemName) ~= "string" or element.itemName == "" then
        return text, false
    end
    local count = 0
    text, count = text:gsub("%[([^%]]+)%]", "[" .. element.itemName .. "]", 1)
    if count == 0 then
        local englishName = service.englishNames.items[tonumber(element.id)]
        if englishName and englishName ~= element.itemName then
            local escaped = englishName:gsub("(%W)", "%%%1")
            text, count = text:gsub(escaped, element.itemName, 1)
        end
    end
    return text, count > 0
end

local spellTags = {
    train = true, aura = true, spellmissing = true, usespell = true,
    cast = true,
}
local function ReplaceSpellName(text, element)
    if type(element) ~= "table" or not spellTags[element.tag] then
        return text, false
    end
    local id = tonumber(element.id)
    local localizedName = id and GetSpellInfo(id)
    if type(localizedName) ~= "string" or localizedName == "" then
        return text, false
    end
    local englishName = service.englishNames.spells[id]
    local count = 0
    if englishName and englishName ~= localizedName then
        local escaped = englishName:gsub("(%W)", "%%%1")
        text, count = text:gsub(escaped, localizedName, 1)
    end
    if count == 0 then
        text, count = text:gsub("%[([^%]]+)%]", "[" .. localizedName .. "]", 1)
    end
    return text, count > 0
end

local function ReplaceQuestName(text, element, localized)
    if type(element) ~= "table" or
        (element.tag ~= "accept" and element.tag ~= "turnin" and
         element.tag ~= "abandon" and element.tag ~= "complete") then
        return text, false
    end

    local sourceName
    local authored = type(element.sourceText) == "string" and
                         StripMarkup(element.sourceText) or nil
    if authored and not authored:find("\n", 1, true) then
        sourceName = authored:match("^[Aa]ccept%s+(.+)$") or
                         authored:match("^[Tt]urn in%s+(.+)$") or
                         authored:match("^[Aa]bandon%s+(.+)$")
        if sourceName == "*quest*" then sourceName = nil end
    end
    if element.tag == "complete" then
        sourceName = service.englishNames.quests[tonumber(element.questId)]
    elseif localized and element.tag == "accept" and addon.GetGuideAcceptTitle then
        sourceName = sourceName or addon.GetGuideAcceptTitle(element)
    elseif localized and element.tag == "turnin" and addon.GetGuideTurnInTitle then
        sourceName = sourceName or addon.GetGuideTurnInTitle(element)
    end
    if not localized and (type(sourceName) ~= "string" or sourceName == "") then
        sourceName = service.englishNames.quests[tonumber(element.questId)]
    end
    local replacement = localized and element.title or sourceName
    if localized and element.tag == "complete" and addon.GetQuestName then
        replacement = addon.GetQuestName(tonumber(element.questId)) or replacement
    end
    if type(replacement) ~= "string" or replacement == "" then
        replacement = sourceName
    end
    if type(replacement) ~= "string" or replacement == "" then
        replacement = "Quest " .. tostring(element.questId or "")
    end

    local changed = false
    if text:find("*quest*", 1, true) then
        text = text:gsub("%*quest%*", replacement)
        changed = true
    elseif sourceName and sourceName ~= replacement then
        local escaped = sourceName:gsub("(%W)", "%%%1")
        local count
        text, count = text:gsub(escaped, replacement, 1)
        changed = count > 0
    end
    return text, changed
end

local function ReplaceFactionNames(text, element)
    if type(element) ~= "table" or element.tag ~= "reputation" then
        return text, false
    end
    local changed = false
    local factionId = tonumber(element.faction)
    local englishFaction = service.englishNames.factions[factionId]
    local localizedFaction = factionId and addon.GetFactionInfoByID and
                                 addon.GetFactionInfoByID(factionId)
    if englishFaction and localizedFaction and englishFaction ~= localizedFaction then
        local escaped = englishFaction:gsub("(%W)", "%%%1")
        local count
        text, count = text:gsub(escaped, localizedFaction, 1)
        changed = count > 0
    end
    local standingId = tonumber(element.standing)
    local englishStanding = standingNames and standingNames[standingId]
    local localizedStanding = standingId and
                                  _G["FACTION_STANDING_LABEL" .. standingId]
    if englishStanding and localizedStanding and
       englishStanding ~= localizedStanding then
        local escaped = englishStanding:gsub("(%W)", "%%%1")
        local count
        text, count = text:gsub(escaped, localizedStanding, 1)
        changed = changed or count > 0
    end
    return text, changed
end

local function LocalizeLocation(value)
    if type(addon.LocalizeLegacyLocationName) ~= "function" then return value end
    local translated = addon.LocalizeLegacyLocationName(Trim(value))
    if type(translated) == "string" and translated ~= "" then
        local lead = value:match("^%s*") or ""
        local tail = value:match("%s*$") or ""
        return lead .. translated .. tail
    end
    return value
end

local function ReplaceLocationName(text, element)
    local source = type(element) == "table" and element.sourceLocation
    if type(source) ~= "string" or source == "" then return text, false end
    local localized = LocalizeLocation(source)
    if localized == source then return text, false end
    local escaped = source:gsub("(%W)", "%%%1")
    local count
    text, count = text:gsub(escaped, localized)
    return text, count > 0
end

local function ValueLooksReviewed(value)
    -- A named semantic token is safe to move through a reviewed template, but
    -- adjacent prose is not. Strip the named spans and require the remainder
    -- to be punctuation/numbers; this prevents a translated verb from hiding
    -- an unreviewed English explanation in the same line.
    if value:find("|cRXP_[A-Z]+_", 1) then
        local remainder = value:gsub("|cRXP_[A-Z]+_.-|r", "")
        remainder = StripMarkup(remainder):gsub("[%s%p%d]+", "")
        if remainder == "" then return true end
        return false
    end
    if value:find("|H", 1, true) then
        local remainder = value:gsub("|H.-|h.-|h", "")
        remainder = StripMarkup(remainder):gsub("[%s%p%d]+", "")
        if remainder == "" then return true end
        return false
    end
    local plain = StripMarkup(value)
    if plain:match("^%d+%.?%d*%s*,%s*%d+%.?%d*%s+%(.+%)$") then
        return true
    end
    if plain:match("^[a-z]") then return false end
    if plain:find("[,;:]%s+[%a\128-\255]") or
       plain:find("%s+[Aa][Nn][Dd]%s+") or
       plain:find("%s+[Tt][Hh][Ee][Nn]%s+") or
       plain:find("%s+[Uu][Nn][Tt][Ii][Ll]%s+") or
       plain:find("%s+[Uu][Ss][Ii][Nn][Gg]%s+") or
       plain:find("%s+[Ii][Nn][Ss][Ii][Dd][Ee]%s+") or
       plain:find("%s+[Oo][Uu][Tt][Ss][Ii][Dd][Ee]%s+") or
       plain:find("%s+[Yy][Oo][Uu][Rr]%s+") or
       plain:find("%s+[Tt][Hh][Ii][Ss]%s+") then
        return false
    end
    local words = 0
    for _ in plain:gmatch("%S+") do words = words + 1 end
    return words <= 7
end

local function TranslateLine(line)
    if not catalog then return line, false end
    local exact = catalog.exact and catalog.exact[line]
    if exact then return exact, true end

    local function TranslateBody(body)
        local flight = body:match("^Get the (.+) flight path$")
        if flight and catalog.flightPath then
            flight = LocalizeLocation(flight)
            return Substitute(catalog.flightPath, {value = flight}), true
        end
        for _, action in ipairs(catalog.actions or {}) do
            local value = body:match(action.pattern)
            if value then
                value = LocalizeLocation(value)
                return Substitute(action.template, {value = value}),
                       ValueLooksReviewed(value)
            end
        end
        return body, false
    end

    local indent, icon, body = line:match("^(%s*)(|T.-|t%s*)(.*)$")
    if not body then
        indent, body = line:match("^(%s*)(.*)$")
        icon = ""
    end

    local bodyExact = catalog.exact and catalog.exact[body]
    if bodyExact then return indent .. icon .. bodyExact, true end

    local translated, reviewed = TranslateBody(body)
    if translated ~= body then return indent .. icon .. translated, reviewed end

    local changed, spansReviewed = false, true
    body = body:gsub("(|cRXP_[A-Z]+_)(.-)(|r)", function(prefix, content, suffix)
        local replacement, contentReviewed = TranslateBody(content)
        if replacement ~= content then
            changed = true
            spansReviewed = spansReviewed and contentReviewed
        end
        return prefix .. replacement .. suffix
    end)
    if changed then
        local outside = StripMarkup(body)
        -- A semantic span can translate the actionable clause while adjacent
        -- authored commentary remains English. Keep that sentence visibly
        -- marked unless the remainder is only punctuation/short named data.
        return indent .. icon .. body,
               spansReviewed and ValueLooksReviewed(outside)
    end
    return line, false
end

local function TranslateLines(text)
    local output, reviewed, count = {}, true, 0
    for line in (text .. "\n"):gmatch("(.-)\n") do
        local translated, lineReviewed = TranslateLine(line)
        output[#output + 1] = translated
        if HasDisplayText(line) then
            count = count + 1
            reviewed = reviewed and lineReviewed
        end
    end
    return table.concat(output, "\n"), reviewed and count > 0
end

local function AppendLiveProgress(source, current)
    if type(source) ~= "string" or type(current) ~= "string" or
       source == current then return source end
    local count, total = current:match("(%d+)%s*/%s*(%d+)")
    if count and total and not source:find("%d+%s*/%s*%d+") then
        return source .. "\n" .. count .. "/" .. total
    end
    return source
end

standingNames = {
    [1] = "Hated", [2] = "Hostile", [3] = "Unfriendly", [4] = "Neutral",
    [5] = "Friendly", [6] = "Honored", [7] = "Revered", [8] = "Exalted",
}

local function GeneratedEnglish(element, current)
    if type(element) ~= "table" or element.sourceAuthored then return nil end
    local tag = element.tag
    local location = element.sourceLocation or element.location or
                         element.zone or element.map or element.mapID
    if tag == "accept" then
        return "Accept *quest*"
    elseif tag == "turnin" then
        return "Turn in *quest*"
    elseif tag == "goto" and element.x and element.y then
        return string.format("Go to %.1f,%.1f (%s)", element.x, element.y,
                             tostring(location or "unknown location"))
    elseif tag == "zone" and location then
        return "Go to " .. tostring(location)
    elseif tag == "fp" and location then
        return "Get the " .. tostring(location) .. " flight path"
    elseif tag == "fly" and location then
        return "Fly to " .. tostring(location)
    elseif (tag == "home" or tag == "sethome") and location then
        return "Set your Hearthstone to " .. tostring(location)
    elseif tag == "vendor" then
        return "Sell junk/resupply"
    elseif tag == "trainer" then
        return "Train skills"
    elseif tag == "train" then
        local spell = service.englishNames.spells[tonumber(element.id)]
        return spell and ("Train " .. spell) or "Train skills"
    elseif tag == "stable" then
        return "Stable your pet"
    elseif tag == "deathskip" then
        return "Die and respawn at the graveyard"
    elseif tag == "xp" and element.level then
        local xp = tonumber(element.xp) or 0
        if xp < 0 then
            return "Grind until you are " .. tostring(-xp) ..
                       " xp away from level " .. tostring(element.level)
        elseif xp >= 1 then
            return "Grind until you are " .. tostring(xp) ..
                       " xp into level " .. tostring(element.level)
        elseif xp > 0 then
            return "Grind until you are " ..
                       tostring(math.floor(xp * 100 + 0.5)) ..
                       "% into level " .. tostring(element.level)
        end
        return "Grind to level " .. tostring(element.level)
    elseif tag == "collect" and element.id then
        local item = service.englishNames.items[tonumber(element.id)]
        local text = item and ("Collect " .. item) or
                         ("Collect Item #" .. tostring(element.id))
        return AppendLiveProgress(text, current)
    elseif tag == "complete" and element.questId then
        local objectiveText = type(element.sourceLine) == "string" and
                                  element.sourceLine:match("%-%-%s*(.-)%s*$")
        if objectiveText and objectiveText ~= "" then
            objectiveText = objectiveText:gsub("%s*%(%d+%)%s*$", "")
            return AppendLiveProgress(objectiveText, current)
        end
        local quest = service.englishNames.quests[tonumber(element.questId)] or
                          ("Quest #" .. tostring(element.questId))
        local objective = tonumber(element.obj) or 1
        return AppendLiveProgress("Complete objective " .. objective ..
                                      " for " .. quest, current)
    elseif tag == "reputation" and element.faction then
        local faction = service.englishNames.factions[tonumber(element.faction)] or
                            ("Faction #" .. tostring(element.faction))
        local standing = standingNames[tonumber(element.standing)] or
                             ("standing " .. tostring(element.standing or ""))
        local value = tonumber(element.repValue) or 0
        if value < 0 then
            return "Grind until you are " .. tostring(-value) .. " away from " ..
                       standing .. " with " .. faction
        elseif value >= 1 then
            return "Grind until you are " .. tostring(value) .. " into " ..
                       standing .. " with " .. faction
        elseif value > 0 then
            return "Grind until you are " ..
                       tostring(math.floor(value * 100 + 0.5)) .. "% into " ..
                       standing .. " with " .. faction
        end
        return "Grind to " .. standing .. " with " .. faction
    end
end

local function GeneratedLocalized(element)
    local semantic = catalog and catalog.semantic
    if type(element) ~= "table" or element.sourceAuthored or
       type(semantic) ~= "table" then return nil end
    if element.tag == "xp" and element.level then
        local xp = tonumber(element.xp) or 0
        local key = xp < 0 and "xpAway" or xp >= 1 and "xpInto" or
                        xp > 0 and "xpPercent" or "grindLevel"
        if type(semantic[key]) ~= "string" then return nil end
        local amount = xp < 0 and -xp or xp >= 1 and xp or
                           math.floor(xp * 100 + 0.5)
        return Substitute(semantic[key], {
            amount = amount,
            level = element.level,
        })
    elseif element.tag == "reputation" and element.faction then
        local factionId = tonumber(element.faction)
        local standingId = tonumber(element.standing)
        local faction = factionId and addon.GetFactionInfoByID and
                            addon.GetFactionInfoByID(factionId) or
                            service.englishNames.factions[factionId] or
                            ("Faction #" .. tostring(factionId or ""))
        local standing = standingId and
                             _G["FACTION_STANDING_LABEL" .. standingId] or
                             standingNames[standingId] or
                             ("standing " .. tostring(standingId or ""))
        local value = tonumber(element.repValue) or 0
        local key = value < 0 and "repAway" or value >= 1 and "repInto" or
                        value > 0 and "repPercent" or "reputation"
        if type(semantic[key]) ~= "string" then return nil end
        local amount = value < 0 and -value or value >= 1 and value or
                           math.floor(value * 100 + 0.5)
        return Substitute(semantic[key], {
            amount = amount,
            standing = standing,
            faction = faction,
        })
    end
end

local function SourceFor(text, element, field, localized)
    if type(element) ~= "table" then return text, false end
    -- Quest objectives supplied by the client are already authoritative and
    -- localized. Preserve those live counters/descriptions in translated mode;
    -- English mode uses the stable quest/objective formatter below.
    if localized and element.tag == "complete" and
       type(text) == "string" and Trim(text) ~= "" and Trim(text) ~= " " then
        return text, true
    end
    local source = sourceFields[field or "text"]
    source = source and element[source] or nil
    if type(source) ~= "string" and field == "tooltipText" and
       type(element.sourceText) == "string" then
        local icon = text:match("^(|T.-|t%s*)") or ""
        source = icon .. element.sourceText
    end
    local generated = GeneratedEnglish(element, text)
    if generated then
        if field == "tooltipText" then
            local icon = text:match("^(|T.-|t%s*)") or ""
            return icon .. generated, false
        end
        return generated, false
    end
    if type(source) == "string" and Trim(source) ~= "" then
        return AppendLiveProgress(source, text), false
    end
    if (element.tag == "accept" or element.tag == "turnin" or
       element.tag == "abandon") and type(element.sourceText) == "string" and
       Trim(element.sourceText) ~= "" then
        return AppendLiveProgress(element.sourceText, text), false
    end
    return text, false
end

function service:Render(text, element, field, options)
    if type(text) ~= "string" then
        return text, {mode = GetMode(), locale = locale, fallback = false}
    end
    text = text:gsub(FALLBACK_PATTERN, "")
    local localized = GetMode() == "localized"
    local source, sourceOfficial = SourceFor(text, element, field, localized)
    if type(source) ~= "string" then source = text end
    local generatedDisplay = type(element) == "table" and
                                 not element.sourceAuthored and
                                 GeneratedEnglish(element, text) ~= nil

    local cacheKey
    if not element then
        cacheKey = (localized and "L\031" or "E\031") .. tostring(field) ..
                       "\031" .. source
        local cached = cache[cacheKey]
        if cached then return cached[1], cached[2] end
    end

    local semanticLocalized = localized and GeneratedLocalized(element)
    local output = semanticLocalized or source
    local reviewed = semanticLocalized ~= nil or sourceOfficial
    local official = semanticLocalized ~= nil or sourceOfficial
    local questChanged
    output, questChanged = ReplaceQuestName(output, element, localized)
    official = official or questChanged
    if localized then
        local translated
        translated, reviewed = TranslateLines(output)
        output = translated
        local creatureChanged
        output, creatureChanged = ReplaceCreatureNames(output)
        local itemChanged
        output, itemChanged = ReplaceItemName(output, element)
        local spellChanged
        output, spellChanged = ReplaceSpellName(output, element)
        local factionChanged
        output, factionChanged = ReplaceFactionNames(output, element)
        local locationChanged
        output, locationChanged = ReplaceLocationName(output, element)
        official = official or creatureChanged or itemChanged or spellChanged or
                       factionChanged or locationChanged
        reviewed = reviewed or semanticLocalized ~= nil or sourceOfficial or
                       questChanged or generatedDisplay and
                           (itemChanged or spellChanged or factionChanged or
                            locationChanged)
    else
        reviewed = true
    end

    local fallback = localized and HasDisplayText(output) and not reviewed
    if addon.settings and addon.settings.ReplaceColors then
        output = addon.settings.ReplaceColors(output)
    end
    if fallback and not (options and options.noBadge) then
        output = output .. FALLBACK_BADGE
    end
    local meta = {
        mode = localized and "localized" or "english",
        locale = locale,
        reviewed = reviewed,
        official = official,
        fallback = fallback,
    }
    if type(element) == "table" and (field == nil or field == "text") then
        element.guideTranslationFallback = fallback or nil
    end
    if cacheKey then cache[cacheKey] = {output, meta} end
    return output, meta
end

local function TranslateTitleWords(text)
    local changed = false
    local remainder = text
    if not catalog or not catalog.titleWords then return text, false, text end
    for _, pair in ipairs(catalog.titleWords) do
        local count
        text, count = text:gsub(pair[1], pair[2])
        changed = changed or count > 0
        remainder = remainder:gsub(pair[1], "")
    end
    for _, token in ipairs({"RestedXP", "RXP", "WotLK", "TBC", "Classic",
                            "SoD", "HC", "JJ", "GPH", "XP"}) do
        remainder = remainder:gsub(token, "")
    end
    remainder = remainder:gsub("%f[%a][AH]%f[%A]", "")
    remainder = StripMarkup(remainder)
    local namedRemainder = remainder:gsub("^[%d%s%p]+", "")
    namedRemainder = Trim(namedRemainder:gsub("[%s%p]+$", ""))
    local residue = remainder:gsub("[%d%s%p]+", "")
    return text, changed and residue == "", namedRemainder
end

function service:RenderTitle(text, noBadge)
    if type(text) ~= "string" then return text, {fallback = false} end
    if GetMode() ~= "localized" then
        if addon.settings and addon.settings.ReplaceColors then
            text = addon.settings.ReplaceColors(text)
        end
        return text, {fallback = false}
    end
    local source = text:gsub(FALLBACK_PATTERN, "")
    local exact = catalog and catalog.titles and catalog.titles[source]
    local output, reviewed
    if exact then
        output, reviewed = exact, true
    else
        local namedRemainder
        output, reviewed, namedRemainder = TranslateTitleWords(source)
        if namedRemainder and namedRemainder ~= "" then
            local localizedName = LocalizeLocation(namedRemainder)
            if localizedName ~= namedRemainder then
                local escaped = namedRemainder:gsub("(%W)", "%%%1")
                output = output:gsub(escaped, localizedName, 1)
                reviewed = true
            end
        end
        local prefix, location = output:match("^([%d%s%-–]+)(.+)$")
        if location then
            local localizedLocation = LocalizeLocation(location)
            if localizedLocation ~= location then
                output = prefix .. localizedLocation
                reviewed = true
            end
        end
    end
    local fallback = HasDisplayText(output) and not reviewed
    if addon.settings and addon.settings.ReplaceColors then
        output = addon.settings.ReplaceColors(output)
    end
    if fallback and not noBadge then output = output .. FALLBACK_BADGE end
    return output, {fallback = fallback, reviewed = reviewed}
end

function service:RenderElement(element, field, text, options)
    field = field or "text"
    if text == nil and type(element) == "table" then text = element[field] end
    return self:Render(text, element, field, options)
end

function service:RenderGuideName(guide, text, noBadge)
    if text == nil and type(guide) == "table" then
        text = guide.sourceDisplayName or guide.displayname or
                   guide.sourceName or guide.name
    end
    return self:RenderTitle(text, noBadge)
end

function service:RenderGroup(group, noBadge)
    return self:RenderTitle(tostring(group or ""):gsub("^[*+]", ""), noBadge)
end

function service:SetMode(mode)
    if mode ~= "english" then mode = "localized" end
    if addon.settings and addon.settings.profile then
        addon.settings.profile.guideLanguage = mode
    end
    self:ClearCache()
    if type(addon.RefreshGuideLanguage) == "function" then
        addon.RefreshGuideLanguage()
    end
    addon:SendMessage("RXP_GUIDE_LANGUAGE_CHANGED", mode, locale)
end

function service:Menu()
    return {
        {
            text = self:UI("Translated (client language)"),
            checked = function() return GetMode() == "localized" end,
            func = function() service:SetMode("localized") end,
        },
        {
            text = self:UI("Original English"),
            checked = function() return GetMode() == "english" end,
            func = function() service:SetMode("english") end,
        },
    }
end

-- Compatibility entry point used by the existing guide and map renderers.
addon.locale.GuideText = function(text, element, field, options)
    local rendered = service:Render(text, element, field, options)
    -- GuideText predates translation metadata and is also used as a nested
    -- argument by legacy integrations. Keep its historical single return;
    -- first-party renderers that need metadata call service:Render directly.
    return rendered
end
