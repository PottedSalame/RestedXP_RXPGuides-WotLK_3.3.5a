local addonName, addon = ...

local ipairs, next, type, tostring = ipairs, next, type, tostring
local sfind, ssub, tconcat = string.find, string.sub, table.concat

-- `strsplittable` is not part of every 3.3.5 client build.  Locale word
-- fallback only needs literal delimiter splitting, so keep it independent of
-- newer Blizzard string helpers and preserve empty fields/spacing exactly.
local function SplitLiteral(delimiter, text)
    if type(text) ~= "string" then return {} end
    delimiter = tostring(delimiter or " ")
    if delimiter == "" then return {text} end

    local fields, offset = {}, 1
    while true do
        local boundary = sfind(text, delimiter, offset, true)
        if not boundary then
            fields[#fields + 1] = ssub(text, offset)
            break
        end
        fields[#fields + 1] = ssub(text, offset, boundary - 1)
        offset = boundary + #delimiter
    end
    return fields
end

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0")

addon.locale = {}

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local delim = L.delimiter
if type(delim) ~= "string" or delim == "" then delim = " " end

local DEBUG = false -- One of the first files loaded, so no settings
local lazyTranslationCache = {}
local uiMetadataByText = {}

if DEBUG then print(addonName .. ": Processing locale: " .. GetLocale()) end

local function getForeignWithMetadata(text)
    if not text then return end
    local translated = L[text]
    if translated and translated ~= text then
        return translated, {status = "reviewed", reviewed = true, fallback = false}
    end

    -- Machine UI packs are registered after this compatibility module loads.
    -- Consult them lazily so existing reviewed AceLocale phrases always win.
    if addon.guideLocalization and addon.guideLocalization.UIWithMetadata then
        local packed, metadata = addon.guideLocalization:UIWithMetadata(text)
        if metadata and not metadata.fallback then return packed, metadata end
    end

    if lazyTranslationCache[text] then
        return lazyTranslationCache[text],
               {status = "machine", machine = true, fallback = false,
                source = "legacy word translation"}
    end

    if next(L.words) == nil then
        -- No custom words added
        lazyTranslationCache[text] = text
        return text, {status = "fallback", fallback = true}
    end

    if DEBUG then print("Phrase not found, looking for words") end

    -- Direct text doesn't match, so iterate over phrase and lazy translate
    local words = SplitLiteral(delim, text)

    -- TODO string insensitive lookups
    for i, w in ipairs(words) do if L.words[w] then words[i] = L.words[w] end end

    local lazyPhrase = tconcat(words, delim)
    lazyTranslationCache[text] = lazyPhrase
    if lazyPhrase ~= text then
        return lazyPhrase,
               {status = "machine", machine = true, fallback = false,
                source = "legacy word translation"}
    end
    return translated or text, {status = "fallback", fallback = true}
end

local function RememberMetadata(text, metadata)
    if type(text) == "string" and type(metadata) == "table" then
        local previous = uiMetadataByText[text]
        if not previous or metadata.fallback or
           metadata.machine and not previous.fallback then
            uiMetadataByText[text] = metadata
        end
    end
    return text
end

local function noop(text) return text end
local function getForeign(text)
    local translated, metadata = getForeignWithMetadata(text)
    return RememberMetadata(translated, metadata)
end

local locale = GetLocale()

-- TODO check if L returned language, remove explicit list
-- Explicitly check supported languages, default to enUS
if locale == 'zhCN' or locale == 'zhTW' or locale == 'frFR' or
    locale == 'koKR' or locale == 'esES' or locale == 'ruRU' or
    locale == 'deDE' then
    addon.locale.Get = getForeign
    addon.locale.GetWithMetadata = getForeignWithMetadata
else
    addon.locale.Get = noop
    addon.locale.GetWithMetadata = function(text)
        return text, {status = "reviewed", reviewed = true, fallback = false}
    end
end


function addon.locale.GetMetadataForText(text)
    return type(text) == "string" and uiMetadataByText[text] or nil
end

function addon.locale.GetStatusExplanationForText(text)
    local metadata = addon.locale.GetMetadataForText(text)
    if metadata and addon.guideLocalization and
       addon.guideLocalization.GetStatusExplanation then
        return addon.guideLocalization:GetStatusExplanation(metadata.status),
               metadata
    end
end

-- Compact controls keep their labels clean.  Translation provenance is
-- exposed on hover instead, and the hook is installed only once per frame.
function addon.locale.AttachStatusTooltip(frame, renderedText, metadata)
    if not frame or type(frame.HookScript) ~= "function" then
        return renderedText
    end
    metadata = metadata or addon.locale.GetMetadataForText(renderedText)
    frame.rxpLocaleMetadata = metadata
    if frame.rxpLocaleTooltipHooked then return renderedText end
    frame.rxpLocaleTooltipHooked = true
    frame:HookScript("OnEnter", function(self)
        local current = self.rxpLocaleMetadata
        local localization = addon.guideLocalization
        local explanation = current and localization and
                                localization.GetStatusExplanation and
                                localization:GetStatusExplanation(current.status)
        if not explanation or explanation == "" or not GameTooltip then return end
        if not GameTooltip.IsOwned or not GameTooltip:IsOwned(self) then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        end
        GameTooltip:AddLine(explanation, 0.65, 0.78, 1, true)
        GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function(self)
        if GameTooltip and (not GameTooltip.IsOwned or
           GameTooltip:IsOwned(self)) then GameTooltip:Hide() end
    end)
    return renderedText
end

function addon.locale.Widget(frame, english)
    local rendered, metadata = addon.locale.GetWithMetadata(english)
    addon.locale.AttachStatusTooltip(frame, rendered, metadata)
    return rendered
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
