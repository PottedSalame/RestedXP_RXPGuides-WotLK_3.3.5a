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
service.englishObjectives = {}

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
local MACHINE_BADGE = " |cff70a0ff[MT]|r"
local FALLBACK_PATTERN = "%s*|cff9d9d9d%[EN%]|r$"
local MACHINE_PATTERN = "%s*|cff70a0ff%[MT%]|r$"
local PACK_SCHEMA = 1

local statusRank = {official = 1, reviewed = 2, machine = 3, fallback = 4}

local function MergeStatus(left, right)
    left = statusRank[left] and left or "fallback"
    right = statusRank[right] and right or "fallback"
    return statusRank[left] >= statusRank[right] and left or right
end

local function HashSource(value)
    local hash = 5381
    value = tostring(value or "")
    for index = 1, #value do
        hash = (hash * 33 + value:byte(index)) % 4294967296
    end
    return string.format("%08x", hash)
end

service.HashSource = HashSource

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

local function AlphaIndex(value)
    local output = ""
    repeat
        local digit = value % 26
        output = string.char(97 + digit) .. output
        value = math.floor(value / 26) - 1
    until value < 0
    return output
end

local function Tokenize(value)
    if type(value) ~= "string" then return value, {}, "" end
    local tokens, count = {}, 0
    local function Protect(kind, atom)
        count = count + 1
        local key = kind .. "_" .. AlphaIndex(count - 1)
        tokens[key] = atom
        return "{" .. key .. "}"
    end

    -- Protect complete atoms first. Warning/action colour spans deliberately
    -- remain translatable; only entity spans are opaque named values.
    value = value:gsub("|H.-|h.-|h", function(atom)
        return Protect("link", atom)
    end)
    value = value:gsub("|T.-|t", function(atom)
        return Protect("texture", atom)
    end)
    value = value:gsub("|cRXP_FRIENDLY_.-|r", function(atom)
        return Protect("friendly", atom)
    end)
    value = value:gsub("|cRXP_ENEMY_.-|r", function(atom)
        return Protect("enemy", atom)
    end)
    value = value:gsub("\\n", function(atom)
        return Protect("newline", atom)
    end)
    value = value:gsub("\n", function(atom)
        return Protect("newline", atom)
    end)
    value = value:gsub("|cRXP_[A-Z]+_", function(atom)
        return Protect("rxpcolor", atom)
    end)
    value = value:gsub("|c%x%x%x%x%x%x%x%x", function(atom)
        return Protect("color", atom)
    end)
    value = value:gsub("|r", function(atom)
        return Protect("colorend", atom)
    end)
    value = value:gsub("%%[%d%.%-%+]*[sdif]", function(atom)
        return Protect("format", atom)
    end)
    value = value:gsub("%-?%d+%.?%d*", function(atom)
        return Protect("number", atom)
    end)

    local names = {}
    for name in value:gmatch("{([%a_]+)}") do names[#names + 1] = name end
    table.sort(names)
    return value, tokens, table.concat(names, "\031")
end

local function Materialize(template, tokens)
    if type(template) ~= "string" then return template end
    return (template:gsub("{([%a_]+)}", function(key)
        return tokens[key] or ("{" .. key .. "}")
    end))
end

function service:Tokenize(text)
    return Tokenize(text)
end

local function StripMarkup(value)
    if type(value) ~= "string" then return "" end
    value = value:gsub("|T.-|t", "")
    value = value:gsub("|cRXP_[A-Z]+_", "")
    value = value:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    value = value:gsub("|H.-|h", ""):gsub("|h", "")
    return Trim(value)
end

local function IsLanguageNeutral(value)
    local plain = StripMarkup(value)
    return plain == "" or plain:match("^[%d%s%p]+$") ~= nil
end

local function IsEntityOnly(value)
    local plain = StripMarkup(value)
    return plain:match("^%[[^%]]+%]$") ~= nil
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
        -- Guide comments are deliberately removed before directive parsing,
        -- but many `.complete` comments contain the authored English
        -- objective name. Capture that display-only metadata first so
        -- Original English mode on a localized client does not need generic
        -- "Complete objective N" wording.
        local completeArgs, objectiveName = line:match(
            "^%s*%.complete%s+([^>]-)%s*%-%-%s*(.-)%s*$")
        if completeArgs and objectiveName then
            local questId, objective = completeArgs:match(
                "^%-?(%d+)%s*,%s*(%d+)")
            questId, objective = tonumber(questId), tonumber(objective)
            objectiveName = StripMarkup(
                objectiveName:gsub("%s*<<.*$", ""):gsub("%s*%(%d+%)%s*$", ""))
            if questId and objective and objectiveName ~= "" then
                local objectives = self.englishObjectives[questId]
                if not objectives then
                    objectives = {}
                    self.englishObjectives[questId] = objectives
                end
                objectives[objective] = objectives[objective] or objectiveName
            end
        end
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
    catalog.translations = catalog.translations or {
        reviewed = {}, machine = {}, contextualReviewed = {},
        contextualMachine = {}, uiReviewed = {}, uiMachine = {},
    }
    cache = {}
    return true
end

function service:RegisterExactCatalog(code, entries, source)
    if code ~= locale or type(entries) ~= "table" then return false end
    catalog = catalog or {}
    catalog.exact = catalog.exact or {}
    catalog.exactSources = catalog.exactSources or {}
    catalog.translations = catalog.translations or {
        reviewed = {}, machine = {}, contextualReviewed = {},
        contextualMachine = {}, uiReviewed = {}, uiMachine = {},
    }
    for english, translated in pairs(entries) do
        if type(english) == "string" and english ~= "" and
           type(translated) == "string" and translated ~= "" and
           not catalog.exact[english] then
            catalog.exact[english] = translated
            catalog.exactSources[english] = source
            catalog.translations.reviewed[english] = {
                text = translated,
                status = "reviewed",
                source = source,
                sourceSignature = HashSource(english),
            }
        end
    end
    cache = {}
    return true
end

local function NormalizePackEntry(english, value, defaultStatus, source,
                                  revision)
    if type(english) ~= "string" or english == "" then return end
    local entry
    if type(value) == "string" then
        entry = {text = value}
    elseif type(value) == "table" then
        entry = value
    else
        return
    end
    if type(entry.text) ~= "string" or entry.text == "" then return end
    local status = entry.status or defaultStatus
    if status ~= "reviewed" and status ~= "machine" then return end
    local expected = entry.sourceSignature or HashSource(english)
    if expected ~= HashSource(english) then return end
    local tokenized, tokens, sourceTokens = Tokenize(english)
    local translatedTokens = ""
    if entry.tokenized then
        local names = {}
        for name in entry.text:gmatch("{([%a_]+)}") do
            names[#names + 1] = name
        end
        table.sort(names)
        translatedTokens = table.concat(names, "\031")
        if translatedTokens ~= sourceTokens then return end
    end
    return {
        text = entry.text,
        status = status,
        source = entry.source or source,
        sourceSignature = expected,
        tokenized = entry.tokenized == true,
        tokens = entry.tokenized and tokens or nil,
        tokenizedSource = entry.tokenized and tokenized or nil,
        revision = entry.revision or revision,
    }
end

function service:RegisterTranslationPack(code, pack)
    if code ~= locale or type(pack) ~= "table" or
       tonumber(pack.schema) ~= PACK_SCHEMA then return false end
    catalog = catalog or {}
    catalog.translations = catalog.translations or {
        reviewed = {}, machine = {}, contextualReviewed = {},
        contextualMachine = {}, uiReviewed = {}, uiMachine = {},
    }
    local translations = catalog.translations
    local source = pack.source or "translation pack"
    local revision = pack.revision or "unspecified"
    local function Import(values, defaultStatus, destination, contextual)
        if type(values) ~= "table" then return end
        for key, value in pairs(values) do
            local english = contextual and type(value) == "table" and
                                value.english or key
            local entry = NormalizePackEntry(english, value, defaultStatus,
                                             source, revision)
            if entry and not destination[key] then
                destination[key] = entry
            end
        end
    end
    Import(pack.reviewed, "reviewed", translations.reviewed)
    Import(pack.machine, "machine", translations.machine)
    Import(pack.contextualReviewed, "reviewed",
           translations.contextualReviewed, true)
    Import(pack.contextualMachine, "machine",
           translations.contextualMachine, true)
    Import(pack.uiReviewed, "reviewed", translations.uiReviewed)
    Import(pack.uiMachine, "machine", translations.uiMachine)
    catalog.revision = revision
    cache = {}
    return true
end

function service:RegisterCompressedPack(code, encoded)
    if code ~= locale or type(encoded) ~= "string" or encoded == "" then
        return false
    end
    local deflate = LibStub and LibStub("LibDeflate", true)
    if not deflate then return false end
    local compressed = deflate:DecodeForPrint(encoded)
    local payload = compressed and deflate:DecompressDeflate(compressed)
    if type(payload) ~= "string" or #payload > 16 * 1024 * 1024 then
        return false
    end
    local recordSeparator, fieldSeparator = string.char(30), string.char(31)
    local pack = {
        schema = PACK_SCHEMA,
        reviewed = {}, machine = {}, contextualReviewed = {},
        contextualMachine = {}, uiReviewed = {}, uiMachine = {},
    }
    local first = true
    for record in payload:gmatch("[^" .. recordSeparator .. "]+") do
        local fields, offset = {}, 1
        for index = 1, 6 do
            local boundary = record:find(fieldSeparator, offset, true)
            if not boundary then break end
            fields[index] = record:sub(offset, boundary - 1)
            offset = boundary + 1
        end
        fields[7] = record:sub(offset)
        local kind, status, key, english, translated, signature, tokenized =
            unpack(fields)
        if first then
            first = false
            if kind ~= "H" or tonumber(status) ~= PACK_SCHEMA then return false end
            pack.revision, pack.source = key, english
        else
            local destination
            if kind == "G" then
                destination = status == "R" and pack.reviewed or pack.machine
                english = key
            elseif kind == "C" then
                destination = status == "R" and pack.contextualReviewed or
                                  pack.contextualMachine
            elseif kind == "U" then
                destination = status == "R" and pack.uiReviewed or pack.uiMachine
                english = key
            end
            if destination and english and translated and signature then
                destination[key] = {
                    english = kind == "C" and english or nil,
                    text = translated,
                    status = status == "R" and "reviewed" or "machine",
                    sourceSignature = signature,
                    tokenized = tokenized == "1",
                }
            end
        end
    end
    local registered = self:RegisterTranslationPack(code, pack)
    if registered then self.loadedCompanion = code end
    return registered
end

function service:GetCompanionAddonName()
    if englishClient or not supported[locale] then return end
    return "RXPGuides_Locale_" .. locale
end

function service:LoadCompanion()
    local companion = self:GetCompanionAddonName()
    if not companion then
        self.companionState = "not-required"
        return true
    end
    if self.loadedCompanion == locale then
        self.companionState = "loaded"
        return true
    end
    if type(GetAddOnInfo) ~= "function" or type(LoadAddOn) ~= "function" then
        self.companionState = "unsupported"
        return false, "API_UNAVAILABLE"
    end
    local installed = GetAddOnInfo(companion)
    if not installed then
        self.companionState = "missing"
        return false, "MISSING"
    end
    if type(IsAddOnLoaded) == "function" and IsAddOnLoaded(companion) then
        self.companionState = self.loadedCompanion == locale and "loaded" or
                                  "invalid"
        return self.loadedCompanion == locale, "PACK_NOT_REGISTERED"
    end
    local called, loaded, reason = pcall(LoadAddOn, companion)
    if not called then
        self.companionState = "failed"
        self.companionError = loaded
        return false, "LOAD_ERROR"
    end
    if not loaded then
        self.companionState = "unavailable"
        self.companionError = reason
        return false, reason
    end
    if self.loadedCompanion ~= locale then
        self.companionState = "invalid"
        return false, "PACK_NOT_REGISTERED"
    end
    self.companionState = "loaded"
    self.companionError = nil
    return true
end

function service:GetCompanionState()
    return self.companionState, self.companionError,
           self:GetCompanionAddonName()
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

local function ContextKey(element, field, source)
    if type(element) ~= "table" then return end
    local step = type(element.step) == "table" and element.step or element
    local guideKey = element.sourceGuideKey or step.sourceGuideKey or
                         element.key
    local stepId = step.stepId
    if not guideKey then return end
    return table.concat({tostring(guideKey), tostring(stepId or "guide"),
                         tostring(field or "text"), HashSource(source)}, "\031")
end

function service:BuildContextKey(element, field, source)
    return ContextKey(element, field, source)
end

local function LookupTranslation(source, element, field, wantedStatus)
    local translations = catalog and catalog.translations
    if not translations or type(source) ~= "string" then return end
    local context = ContextKey(element, field, source)
    local entry
    if wantedStatus ~= "machine" then
        entry = context and translations.contextualReviewed[context] or nil
        entry = entry or translations.reviewed[source]
    end
    if not entry and wantedStatus ~= "reviewed" then
        entry = context and translations.contextualMachine[context] or nil
        entry = entry or translations.machine[source]
    end
    if not entry or entry.sourceSignature ~= HashSource(source) then return end
    if entry.tokenized then
        local _, tokens, signature = Tokenize(source)
        local names = {}
        for name in entry.text:gmatch("{([%a_]+)}") do
            names[#names + 1] = name
        end
        table.sort(names)
        if table.concat(names, "\031") ~= signature then return end
        return Materialize(entry.text, tokens), entry
    end
    return entry.text, entry
end

function service:UIWithMetadata(key)
    local translations = catalog and catalog.translations
    local entry = translations and
                      (translations.uiReviewed[key] or
                           translations.uiMachine[key])
    if entry and entry.sourceSignature == HashSource(key) then
        local text = entry.tokenized and
                         Materialize(entry.text, select(2, Tokenize(key))) or
                         entry.text
        return text, {
            status = entry.status,
            source = entry.source,
            catalogRevision = entry.revision,
            sourceSignature = entry.sourceSignature,
            machine = entry.status == "machine",
            reviewed = entry.status == "reviewed",
            fallback = false,
        }
    end
    local reviewed = catalog and catalog.ui and catalog.ui[key]
    if reviewed then
        return reviewed, {status = "reviewed", reviewed = true, fallback = false}
    end
    return key, {status = "fallback", fallback = true}
end

function service:UI(key)
    return (self:UIWithMetadata(key))
end

function service:GetFallbackExplanation()
    return self:UI("This instruction has not yet been reviewed in your language.")
end


function service:GetMachineExplanation()
    local value = self:UI("This text was machine translated and has not yet been reviewed.")
    if value == "This text was machine translated and has not yet been reviewed." then
        return value
    end
    return value
end

function service:GetStatusExplanation(status)
    if status == "machine" then return self:GetMachineExplanation() end
    if status == "fallback" then return self:GetFallbackExplanation() end
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

local function ReplaceKnownLocationNames(text)
    if type(addon.LocalizeLegacyLocationText) ~= "function" then
        return text, false
    end
    return addon.LocalizeLegacyLocationText(text)
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

local function LocalizeSemanticValue(value, element)
    if type(value) ~= "string" or type(element) ~= "table" then
        return LocalizeLocation(value), false
    end
    local tag = element.tag
    local changed = false
    if tag == "accept" or tag == "turnin" or tag == "abandon" then
        local id = tonumber(element.questId or element.id)
        local localized = element.title
        if (type(localized) ~= "string" or localized == "") and
           id and type(addon.GetQuestName) == "function" then
            localized = addon.GetQuestName(id)
        end
        local authored = type(element.sourceText) == "string" and
                             StripMarkup(element.sourceText) or ""
        local english = service.englishNames.quests[id] or
                            authored:match("^[Aa]ccept%s+(.+)$") or
                            authored:match("^[Tt]urn in%s+(.+)$") or
                            authored:match("^[Aa]bandon%s+(.+)$")
        if type(localized) == "string" and localized ~= "" and
           type(english) == "string" and english ~= "" and
           localized ~= english then
            local escaped = english:gsub("(%W)", "%%%1")
            local count
            value, count = value:gsub(escaped, function() return localized end, 1)
            if count == 0 and StripMarkup(value) == english then
                value, count = localized, 1
            end
            changed = count > 0
        end
    elseif itemTags[tag] and type(element.itemName) == "string" and
           element.itemName ~= "" then
        local count
        value, count = value:gsub("%[([^%]]+)%]", function()
            return "[" .. element.itemName .. "]"
        end, 1)
        changed = count > 0
    elseif spellTags[tag] then
        local spellId = tonumber(element.id)
        local localized = spellId and GetSpellInfo(spellId)
        if type(localized) == "string" and localized ~= "" then
            local count
            value, count = value:gsub("%[([^%]]+)%]", function()
                return "[" .. localized .. "]"
            end, 1)
            if count == 0 then
                local english = service.englishNames.spells[spellId]
                if english and english ~= localized then
                    value, count = value:gsub(
                        english:gsub("(%W)", "%%%1"),
                        function() return localized end, 1)
                end
            end
            changed = count > 0
        end
    end
    local located = LocalizeLocation(value)
    if located ~= value then value, changed = located, true end
    return value, changed
end

local function TranslateLine(line, element, field)
    if not catalog then return line, "fallback" end
    local exact, exactEntry = LookupTranslation(line, element, field, "reviewed")
    if exact then return exact, exactEntry.status, exactEntry end

    local function TranslateBody(body, wantedStatus)
        local bodyExact, bodyEntry = LookupTranslation(
            body, element, field, wantedStatus)
        if bodyExact then return bodyExact, bodyEntry.status, bodyEntry end
        if wantedStatus == "machine" then return body, "fallback" end
        local flight = body:match("^Get the (.+) flight path$")
        if flight and catalog.flightPath then
            flight = LocalizeLocation(flight)
            return Substitute(catalog.flightPath, {value = flight}), "reviewed",
                   {source = "reviewed semantic template"}
        end
        for _, action in ipairs(catalog.actions or {}) do
            local value = body:match(action.pattern)
            if value then
                local official
                value, official = LocalizeSemanticValue(value, element)
                return Substitute(action.template, {value = value}),
                       (official or ValueLooksReviewed(value)) and "reviewed" or
                           "fallback",
                       {source = "reviewed semantic template"}
            end
        end
        return body, "fallback"
    end

    local indent, icon, body = line:match("^(%s*)(|T.-|t%s*)(.*)$")
    if not body then
        indent, body = line:match("^(%s*)(.*)$")
        icon = ""
    end

    local translated, bodyStatus, bodyMeta = TranslateBody(body, "reviewed")
    local partial, partialMeta
    if translated ~= body and bodyStatus == "reviewed" then
        return indent .. icon .. translated, bodyStatus, bodyMeta
    elseif translated ~= body then
        partial, partialMeta = translated, bodyMeta
    end

    exact, exactEntry = LookupTranslation(line, element, field, "machine")
    if exact then return exact, exactEntry.status, exactEntry end
    translated, bodyStatus, bodyMeta = TranslateBody(body, "machine")
    if translated ~= body then
        return indent .. icon .. translated, bodyStatus, bodyMeta
    end

    local changed, spanStatus, spanMeta = false, "reviewed"
    body = body:gsub("(|cRXP_[A-Z]+_)(.-)(|r)", function(prefix, content, suffix)
        local replacement, contentStatus, contentMeta =
            TranslateBody(content, "reviewed")
        if replacement == content then
            replacement, contentStatus, contentMeta =
                TranslateBody(content, "machine")
        end
        if replacement ~= content then
            changed = true
            spanStatus = MergeStatus(spanStatus, contentStatus)
            spanMeta = spanMeta or contentMeta
        end
        return prefix .. replacement .. suffix
    end)
    if changed then
        local outside = StripMarkup(body)
        -- A semantic span can translate the actionable clause while adjacent
        -- authored commentary remains English. Keep that sentence visibly
        -- marked unless the remainder is only punctuation/short named data.
        if not ValueLooksReviewed(outside) then spanStatus = "fallback" end
        return indent .. icon .. body, spanStatus, spanMeta
    end
    if partial then
        return indent .. icon .. partial, "fallback", partialMeta
    end
    return line, "fallback"
end

local function TranslateLines(text, element, field)
    local output, status, count, provenance = {}, "official", 0
    for line in (text .. "\n"):gmatch("(.-)\n") do
        local translated, lineStatus, lineMeta = TranslateLine(line, element, field)
        output[#output + 1] = translated
        if HasDisplayText(line) then
            count = count + 1
            status = MergeStatus(status, lineStatus)
            provenance = provenance or lineMeta
        end
    end
    return table.concat(output, "\n"), count > 0 and status or "official",
           provenance
end

local function GetLiveProgress(source, current)
    if type(source) ~= "string" or type(current) ~= "string" or
       source == current then return nil end
    local count, total = current:match("(%d+)%s*/%s*(%d+)")
    if count and total and not source:find("%d+%s*/%s*%d+") then
        return "\n" .. count .. "/" .. total
    end
    return nil
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
        return text
    elseif tag == "complete" and element.questId then
        local questId, objective = tonumber(element.questId),
                                       tonumber(element.obj) or 1
        local indexed = questId and service.englishObjectives[questId]
        local objectiveText = indexed and indexed[objective]
        objectiveText = objectiveText or
                            (type(element.sourceLine) == "string" and
                                 element.sourceLine:match("%-%-%s*(.-)%s*$"))
        if objectiveText and objectiveText ~= "" then
            objectiveText = objectiveText:gsub("%s*%(%d+%)%s*$", "")
            return objectiveText
        end
        local quest = service.englishNames.quests[questId] or
                          ("Quest #" .. tostring(element.questId))
        return "Complete objective " .. objective .. " for " .. quest
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
    -- On an English client the live quest log already supplies the best
    -- English objective wording and counters. Preserve the pre-localization
    -- behavior for generated/dynamic elements instead of replacing it with a
    -- synthetic catalog sentence.
    if not localized and englishClient and not element.sourceAuthored and
       type(text) == "string" and Trim(text) ~= "" and Trim(text) ~= " " then
        return text, true, nil
    end
    -- Quest objectives supplied by the client are already authoritative and
    -- localized. Preserve those live counters/descriptions in translated mode;
    -- English mode uses the stable quest/objective formatter below.
    if localized and element.tag == "complete" and
       type(text) == "string" and Trim(text) ~= "" and Trim(text) ~= " " then
        return text, true, nil
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
            local value = icon .. generated
            return value, false, GetLiveProgress(value, text)
        end
        return generated, false, GetLiveProgress(generated, text)
    end
    if type(source) == "string" and Trim(source) ~= "" then
        return source, false, GetLiveProgress(source, text)
    end
    if (element.tag == "accept" or element.tag == "turnin" or
       element.tag == "abandon") and type(element.sourceText) == "string" and
       Trim(element.sourceText) ~= "" then
        return element.sourceText, false, GetLiveProgress(element.sourceText, text)
    end
    return text, false, nil
end

function service:Render(text, element, field, options)
    if type(text) ~= "string" then
        return text, {mode = GetMode(), locale = locale, fallback = false}
    end
    text = text:gsub(FALLBACK_PATTERN, ""):gsub(MACHINE_PATTERN, "")
    local localized = GetMode() == "localized"
    local source, sourceOfficial, liveProgress =
        SourceFor(text, element, field, localized)
    if type(source) ~= "string" then source = text end
    if localized and IsLanguageNeutral(source) then sourceOfficial = true end
    local entityOnly = IsEntityOnly(source)
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
    local status = semanticLocalized and "official" or
                       sourceOfficial and "official" or "fallback"
    local translationMeta
    if localized then
        if not semanticLocalized and not sourceOfficial then
            output, status, translationMeta =
                TranslateLines(output, element, field)
        end
        output = ReplaceQuestName(output, element, true)
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
        local embeddedLocationChanged
        output, embeddedLocationChanged = ReplaceKnownLocationNames(output)
        locationChanged = locationChanged or embeddedLocationChanged
        if status == "fallback" and entityOnly and
           (itemChanged or spellChanged) then
            -- A line containing only a texture and one bracketed entity has
            -- no prose left to translate once the client supplies its
            -- localized item/spell name.
            status = "official"
        end
        if status == "fallback" and generatedDisplay and
           (itemChanged or spellChanged or factionChanged or locationChanged) then
            -- Generated sentences use reviewed action grammar; official names
            -- fill the named value without making authored English prose look
            -- reviewed merely because one proper noun changed.
            status = "reviewed"
        end
    else
        output = ReplaceQuestName(output, element, false)
        status = "reviewed"
    end
    if liveProgress then output = output .. liveProgress end

    local hasText = HasDisplayText(output)
    local fallback = localized and hasText and status == "fallback"
    local machine = localized and hasText and status == "machine"
    if addon.settings and addon.settings.ReplaceColors then
        output = addon.settings.ReplaceColors(output)
    end
    if not (options and options.noBadge) then
        if fallback then
            output = output .. FALLBACK_BADGE
        elseif machine then
            output = output .. MACHINE_BADGE
        end
    end
    local meta = {
        mode = localized and "localized" or "english",
        locale = locale,
        status = status,
        reviewed = status == "reviewed" or status == "official",
        official = status == "official",
        machine = machine,
        fallback = fallback,
        source = translationMeta and translationMeta.source or
                     status == "official" and "localized client data" or nil,
        catalogRevision = translationMeta and translationMeta.revision or
                              catalog and catalog.revision,
        sourceSignature = HashSource(source),
    }
    if type(element) == "table" and (field == nil or field == "text") then
        element.guideTranslationFallback = fallback or nil
        element.guideTranslationMachine = machine or nil
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

function service:RenderTitle(text, noBadge, context)
    if type(text) ~= "string" then
        return text, {status = "official", fallback = false}
    end
    if GetMode() ~= "localized" then
        if addon.settings and addon.settings.ReplaceColors then
            text = addon.settings.ReplaceColors(text)
        end
        return text, {status = "reviewed", reviewed = true, fallback = false}
    end
    local source = text:gsub(FALLBACK_PATTERN, ""):gsub(MACHINE_PATTERN, "")
    local output, entry = LookupTranslation(source, context, "title", "reviewed")
    local status = entry and entry.status
    local exact = not output and catalog and catalog.titles and
                      catalog.titles[source]
    local reviewed
    if exact then
        output, reviewed = exact, true
        status = "reviewed"
    elseif not output then
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
        status = reviewed and "reviewed" or "fallback"
        if not reviewed then
            local machineOutput, machineEntry =
                LookupTranslation(source, context, "title", "machine")
            if machineOutput then
                output, entry, status = machineOutput, machineEntry, "machine"
            end
        end
    end
    local fallback = HasDisplayText(output) and status == "fallback"
    local machine = HasDisplayText(output) and status == "machine"
    if addon.settings and addon.settings.ReplaceColors then
        output = addon.settings.ReplaceColors(output)
    end
    if not noBadge then
        if fallback then
            output = output .. FALLBACK_BADGE
        elseif machine then
            output = output .. MACHINE_BADGE
        end
    end
    return output, {
        status = status,
        fallback = fallback,
        machine = machine,
        reviewed = status == "reviewed" or status == "official",
        official = status == "official",
        source = entry and entry.source,
        catalogRevision = entry and entry.revision or
                              catalog and catalog.revision,
        sourceSignature = HashSource(source),
    }
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
    return self:RenderTitle(text, noBadge, guide)
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
