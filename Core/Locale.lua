local addonName, addon = ...

local ssplit, strjoin, ipairs, unpack, next = strsplittable, strjoin, ipairs, unpack, next

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0")

addon.locale = {}

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local delim = L.delimiter

local DEBUG = false -- One of the first files loaded, so no settings
local lazyTranslationCache = {}

if DEBUG then print(addonName .. ": Processing locale: " .. GetLocale()) end

local function getForeign(text)
    if not text then return end
    if L[text] then return L[text] end

    if lazyTranslationCache[text] then return lazyTranslationCache[text] end

    if next(L.words) == nil then
        -- No custom words added
        lazyTranslationCache[text] = text
        return text
    end

    if DEBUG then print("Phrase not found, looking for words") end

    -- Direct text doesn't match, so iterate over phrase and lazy translate
    local words = ssplit(delim, text)

    -- TODO string insensitive lookups
    for i, w in ipairs(words) do if L.words[w] then words[i] = L.words[w] end end

    local lazyPhrase = strjoin(delim, unpack(words))
    lazyTranslationCache[text] = lazyPhrase

    return lazyPhrase
end

local function noop(text) return text end

local locale = GetLocale()

-- TODO check if L returned language, remove explicit list
-- Explicitly check supported languages, default to enUS
if locale == 'zhCN' or locale == 'zhTW' or locale == 'frFR' or
    locale == 'koKR' or locale == 'esES' or locale == 'ruRU' or
    locale == 'deDE' then
    addon.locale.Get = getForeign
else
    addon.locale.Get = noop
end

addon.locale.IsEnglish = locale == "enUS" or locale == "enGB"

-- Quest turn-ins use the locale's unnamed XP-gain message. Tracker and group
-- accounting must filter that message without assuming it begins with the
-- English word "You". Keep the comparison deliberately prefix-based, matching
-- the legacy behavior while deriving the prefix from Blizzard's own format.
local unnamedXPFormat = _G.COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED
local unnamedXPPrefix = type(unnamedXPFormat) == "string" and
                            unnamedXPFormat:match("^(.-)%%") or nil
if not unnamedXPPrefix or unnamedXPPrefix == "" then
    unnamedXPPrefix = addon.locale.IsEnglish and "You" or nil
end

function addon.IsUnattributedXPMessage(text)
    return type(text) == "string" and type(unnamedXPPrefix) == "string" and
               text:sub(1, #unnamedXPPrefix) == unnamedXPPrefix
end

-- Guide prose is authored in English, but creature names are already bundled
-- for every supported locale. Translate exact phrases first, then replace the
-- names inside the guide's semantic colour spans without changing directives
-- or the maintained route data.
function addon.locale.GuideText(text)
    text = addon.locale.Get(text)
    if type(text) ~= "string" or addon.locale.IsEnglish or
        type(addon.GetCreatureName) ~= "function" then
        return text
    end

    local function ReplaceName(prefix, name, suffix)
        return prefix .. (addon.GetCreatureName(name) or name) .. suffix
    end
    text = text:gsub("(|cRXP_FRIENDLY_)(.-)(|r)", ReplaceName)
    text = text:gsub("(|cRXP_ENEMY_)(.-)(|r)", ReplaceName)
    return text
end

function addon.locale.QuestAction(action, questName, sourceText, sourceQuestName)
    if addon.locale.IsEnglish or type(questName) ~= "string" or
        questName == "" then return end
    local text = type(sourceText) == "string" and sourceText or "*quest*"
    local changed
    if text:find("*quest*", 1, true) then
        text = text:gsub("%*quest%*", questName)
        changed = true
    elseif type(sourceQuestName) == "string" and sourceQuestName ~= "" then
        local escaped = sourceQuestName:gsub("(%W)", "%%%1")
        local count
        text, count = text:gsub(escaped, questName, 1)
        changed = count > 0
    end
    if not changed then return sourceText end

    if sourceQuestName then
        local labels = {"Accept", "Turn in", _G.ACCEPT, _G.TURN_IN_QUEST}
        for _, label in ipairs(labels) do
            if type(label) == "string" and label ~= "" then
                local escaped = label:gsub("(%W)", "%%%1")
                local count
                text, count = text:gsub("^" .. escaped .. "(%s+)",
                    (action or "") .. "%1", 1)
                if count > 0 then break end
            end
        end
    end
    return text
end
