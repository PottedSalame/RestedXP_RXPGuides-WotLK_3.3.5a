local _, addon = ...

local MAX_PACK_SIZE = 256 * 1024
local PACK_PREFIX = "RXPPACK1"

addon.compatibilityPacks = addon.compatibilityPacks or {}
local packs = addon.compatibilityPacks

local baseline = addon.CompatibilityPackBaseline335 or {
    schema = 1,
    id = "azerothcore-335",
    name = "AzerothCore 3.3.5a",
    version = 1,
    core = "AzerothCore",
    questPrerequisites = {},
    questAvailability = {},
    targetAliases = {},
    flightAliases = {},
    mapAliases = {},
    guideOverrides = {},
    resetPolicy = {}
}

local allowedRoot = {
    schema = true, id = true, name = true, version = true, core = true,
    minAddon = true, questPrerequisites = true, targetAliases = true,
    questAvailability = true, flightAliases = true, mapAliases = true,
    guideOverrides = true,
    eventQuirks = true, resetPolicy = true
}

local function PlainString(value, maximum)
    return type(value) == "string" and value ~= "" and #value <= maximum
end

local function ValidateAliases(aliases, allowList)
    if type(aliases) ~= "table" then return false end
    local normalizedKeys = {}
    for key, value in pairs(aliases) do
        if not PlainString(key, 160) then return false end
        local normalizedKey = key:lower()
        if normalizedKeys[normalizedKey] then return false end
        normalizedKeys[normalizedKey] = true
        if type(value) == "string" then
            if not PlainString(value, 160) then return false end
        elseif allowList and type(value) == "table" then
            local count, seen = 0, {}
            for _, alias in ipairs(value) do
                count = count + 1
                local normalized = type(alias) == "string" and alias:lower()
                if count > 20 or not PlainString(alias, 160) or
                    seen[normalized] then return false end
                seen[normalized] = true
            end
        else
            return false
        end
    end
    return true
end

local function ValidId(value)
    value = tonumber(value)
    return value and value > 0 and value <= 1000000 and
               value == math.floor(value)
end

local function ValidStepId(value)
    value = tonumber(value)
    return value and value > 0 and value <= 4294967295 and
               value == math.floor(value)
end

local function VersionAtLeast(current, minimum)
    local left, right = {}, {}
    for value in tostring(current or ""):gmatch("%d+") do
        left[#left + 1] = tonumber(value)
        if #left == 4 then break end
    end
    for value in tostring(minimum or ""):gmatch("%d+") do
        right[#right + 1] = tonumber(value)
        if #right == 4 then break end
    end
    if #right == 0 then return false end
    for index = 1, math.max(#left, #right) do
        local a, b = left[index] or 0, right[index] or 0
        if a ~= b then return a > b end
    end
    return true
end

local function ValidateEventQuirks(value)
    if value == nil then return true end
    if type(value) ~= "table" then return false end
    local allowed = {
        questAcceptedLogIndex = "boolean",
        questTurnedInDelayed = "number",
        questLogUpdateDelay = "number"
    }
    for key, setting in pairs(value) do
        if type(setting) ~= allowed[key] then return false end
        if type(setting) == "number" and
            (setting < 0 or setting > 5) then return false end
    end
    return true
end

local function ValidateResetPolicy(value)
    if value == nil then return true end
    if type(value) ~= "table" then return false end
    local allowed = {
        weeklyResetAt = "number", weeklyResetSeconds = "number",
        dailyResetSeconds = "number", label = "string"
    }
    for key, setting in pairs(value) do
        if type(setting) ~= allowed[key] then return false end
        if type(setting) == "number" and
            (setting < 0 or setting > 3153600000) then return false end
        if type(setting) == "string" and not PlainString(setting, 120) then
            return false
        end
    end
    return true
end

function packs:Validate(pack)
    if type(pack) ~= "table" or pack.schema ~= 1 or
        not PlainString(pack.id, 80) or not PlainString(pack.name, 120) or
        type(pack.version) ~= "number" or pack.version < 1 or
        pack.version ~= math.floor(pack.version) then
        return false, "Missing or invalid pack identity."
    end
    if pack.minAddon ~= nil and not PlainString(pack.minAddon, 40) then
        return false, "Invalid minimum addon version."
    end
    for key in pairs(pack) do
        if not allowedRoot[key] then
            return false, "Unknown field: " .. tostring(key)
        end
    end
    for _, field in ipairs({"targetAliases", "flightAliases", "mapAliases"}) do
        if pack[field] ~= nil and
            not ValidateAliases(pack[field], field == "targetAliases") then
            return false, "Invalid aliases in " .. field
        end
    end
    if pack.questPrerequisites ~= nil then
        if type(pack.questPrerequisites) ~= "table" then
            return false, "Invalid quest prerequisites."
        end
        for id, prerequisite in pairs(pack.questPrerequisites) do
            if not ValidId(id) or type(prerequisite) ~= "table" or
                type(prerequisite.clauses) ~= "table" then
                return false, "Invalid prerequisite for quest " .. tostring(id)
            end
            for _, clause in ipairs(prerequisite.clauses) do
                if type(clause) ~= "table" or #clause == 0 then
                    return false, "Empty prerequisite clause."
                end
                for _, requirement in ipairs(clause) do
                    local validState = type(requirement) == "table" and
                        (requirement.state == "R" or requirement.state == "A" or
                         requirement.state == "N")
                    if not validState or not ValidId(requirement.id) then
                        return false, "Invalid prerequisite requirement."
                    end
                end
            end
        end
    end
    if pack.questAvailability ~= nil then
        if type(pack.questAvailability) ~= "table" then
            return false, "Invalid quest availability table."
        end
        for id, available in pairs(pack.questAvailability) do
            if not ValidId(id) or type(available) ~= "boolean" then
                return false, "Invalid quest availability entry."
            end
        end
    end
    if pack.guideOverrides ~= nil then
        if type(pack.guideOverrides) ~= "table" then
            return false, "Invalid guide overrides."
        end
        for guideKey, steps in pairs(pack.guideOverrides) do
            if not PlainString(guideKey, 240) or type(steps) ~= "table" then
                return false, "Invalid guide key."
            end
            for stepId, override in pairs(steps) do
                if not ValidStepId(stepId) or type(override) ~= "table" then
                    return false, "Invalid step override."
                end
                for field, value in pairs(override) do
                    if field == "disabled" then
                        if type(value) ~= "boolean" then return false, "Invalid disabled value." end
                    elseif field == "enabled" then
                        if type(value) ~= "boolean" then return false, "Invalid enabled value." end
                    elseif field == "questId" then
                        if not ValidId(value) then return false, "Invalid quest ID override." end
                    elseif field == "targets" then
                        if type(value) ~= "table" or
                            not ValidateAliases({targets = value}, true) then
                            return false, "Invalid target override."
                        end
                    elseif field == "x" or field == "y" then
                        if type(value) ~= "number" or value < 0 or value > 100 then
                            return false, "Invalid coordinate override."
                        end
                    elseif field == "zone" then
                        if type(value) ~= "number" and not PlainString(value, 120) then
                            return false, "Invalid zone override."
                        end
                    else
                        return false, "Unknown guide override field: " .. tostring(field)
                    end
                end
            end
        end
    end
    if not ValidateEventQuirks(pack.eventQuirks) then
        return false, "Invalid or unknown event quirk."
    end
    if not ValidateResetPolicy(pack.resetPolicy) then
        return false, "Invalid or unknown reset policy."
    end
    return true
end

function packs:ValidateReferences(pack)
    if type(pack) ~= "table" or type(pack.guideOverrides) ~= "table" then
        return true
    end
    for guideKey, steps in pairs(pack.guideOverrides) do
        local guide
        for group, list in pairs(addon.guideList or {}) do
            local realGroup = group:gsub("^[*+]", "")
            for _, name in ipairs(list.names_ or {}) do
                local candidate = addon.GetGuideTable(realGroup, name) or
                                      addon.GetGuideTable(group, name)
                if candidate and candidate.key == guideKey then
                    guide = addon:FetchGuide(candidate)
                    break
                end
            end
            if guide then break end
        end
        if not guide then return false, "Dangling guide override: " .. guideKey end
        local known = {}
        for _, step in ipairs(guide.steps or {}) do
            known[tonumber(step.stepId)] = true
        end
        for stepId in pairs(steps) do
            if not known[tonumber(stepId)] then
                return false, "Dangling step override: " .. guideKey .. " / " ..
                                  tostring(stepId)
            end
        end
    end
    return true
end

function packs:GetActive()
    local id = addon.realmData and addon.realmData.compatibilityPackId or
                   baseline.id
    return RXPData.compatibilityPacks[id] or
               (id == baseline.id and baseline or nil)
end

function packs:Select(id)
    local pack = id == baseline.id and baseline or RXPData.compatibilityPacks[id]
    if not pack then return false, "Unknown compatibility pack." end
    addon.realmData.compatibilityPackId = id
    return true
end

function packs:GetQuestPrerequisite(id)
    local pack = self:GetActive()
    return pack and pack.questPrerequisites and
               (pack.questPrerequisites[id] or
                   pack.questPrerequisites[tostring(id)])
end

function packs:GetQuestAvailability(id)
    local pack = self:GetActive()
    local availability = pack and pack.questAvailability
    if not availability then return nil end
    local value = availability[tonumber(id)]
    if value == nil then value = availability[tostring(id)] end
    return value
end

function packs:GetEventQuirks()
    local pack = self:GetActive()
    return pack and pack.eventQuirks or {}
end

function packs:ResolveFlightAlias(name)
    local pack = self:GetActive()
    local aliases = pack and pack.flightAliases
    if aliases and aliases[name] then return aliases[name] end
    if type(name) == "string" then
        for source, destination in pairs(aliases or {}) do
            if source:lower() == name:lower() then return destination end
        end
    end
    return name
end

function packs:ResolveMapAlias(name)
    local pack = self:GetActive()
    local aliases = pack and pack.mapAliases
    if aliases and aliases[name] then return aliases[name] end
    if type(name) == "string" then
        for source, destination in pairs(aliases or {}) do
            if source:lower() == name:lower() then return destination end
        end
    end
    return name
end

function packs:GetTargetAliases(name)
    local pack = self:GetActive()
    local aliases = pack and pack.targetAliases
    local value = aliases and aliases[name]
    if value == nil and type(name) == "string" then
        for source, candidate in pairs(aliases or {}) do
            if source:lower() == name:lower() then value = candidate break end
        end
    end
    if type(value) == "string" then return {value} end
    return type(value) == "table" and value or {}
end

local function ApplyTargetAliases(self, guide)
    for _, step in ipairs(guide.steps or {}) do
        for _, element in ipairs(step.elements or {}) do
            if type(element.targets) == "table" then
                local originals, seen = {}, {}
                for _, target in ipairs(element.targets) do
                    table.insert(originals, target)
                    seen[target] = true
                end
                for _, target in ipairs(originals) do
                    for _, alias in ipairs(self:GetTargetAliases(target)) do
                        if not seen[alias] then
                            seen[alias] = true
                            table.insert(element.targets, alias)
                        end
                    end
                end
            end
        end
    end
end

function packs:ApplyGuide(guide)
    if type(guide) ~= "table" then return end
    ApplyTargetAliases(self, guide)
    local pack = self:GetActive()
    local overrides = pack and pack.guideOverrides and
                          pack.guideOverrides[guide.key]
    if not overrides then return end
    for _, step in ipairs(guide.steps or {}) do
        local override = overrides[step.stepId] or
                             overrides[tostring(step.stepId)]
        if override then
            if override.disabled ~= nil then step.disabled = override.disabled end
            if override.enabled ~= nil then step.disabled = not override.enabled end
            for _, element in ipairs(step.elements or {}) do
                if override.questId and element.questId then
                    element.questId = tonumber(override.questId)
                end
                if override.targets then
                    element.targets = {unpack(override.targets)}
                end
                if override.x then element.x = override.x end
                if override.y then element.y = override.y end
                if override.zone then element.zone = override.zone end
            end
        end
    end
end

function packs:Export(pack)
    pack = pack or self:GetActive()
    local serializer = LibStub("AceSerializer-3.0")
    local deflate = LibStub("LibDeflate")
    local serialized = serializer:Serialize(pack)
    return PACK_PREFIX .. ":" .. deflate:Adler32(serialized) .. ":" ..
               deflate:EncodeForPrint(deflate:CompressDeflate(serialized))
end

function packs:Import(text)
    if type(text) ~= "string" then return false, "Pack is not text." end
    if #text > MAX_PACK_SIZE * 4 then return false, "Pack text is too large." end
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    local checksum, encoded = text:match("^" .. PACK_PREFIX ..
                                             ":(%d+):(.+)$")
    if not checksum then return false, "Unknown pack format." end
    local deflate = LibStub("LibDeflate")
    local decoded = deflate:DecodeForPrint(encoded)
    local serialized = decoded and deflate:DecompressDeflate(decoded)
    if not serialized or #serialized > MAX_PACK_SIZE or
        deflate:Adler32(serialized) ~= tonumber(checksum) then
        return false, "Pack is damaged or too large."
    end
    local ok, pack = LibStub("AceSerializer-3.0"):Deserialize(serialized)
    if not ok then return false, "Pack cannot be decoded." end
    local valid, errorText = self:Validate(pack)
    if not valid then return false, errorText end
    if pack.minAddon and not VersionAtLeast(addon.release, pack.minAddon) then
        return false, "This pack requires RXPGuides " .. pack.minAddon ..
                          " or newer."
    end
    valid, errorText = self:ValidateReferences(pack)
    if not valid then return false, errorText end
    RXPData.compatibilityPacks[pack.id] = pack
    return true, pack
end

function packs:HandleCommand(input)
    local argument = input:match("^pack%s+(.+)$")
    if argument and argument ~= "import" and argument ~= "export" then
        local ok, errorText = self:Select(argument)
        addon.comms.PrettyPrint(ok and
            ("Compatibility pack: " .. argument) or errorText)
    elseif argument == "import" then
        addon.comms.OpenBrandedExport("Compatibility Pack Import",
            "Paste a validated data-only RXPPACK and press Enter.", "", 640,
            420, function(text)
                local ok, result = packs:Import(text)
                addon.comms:PopupNotification("RXP_PACK_RESULT", ok and
                    ("Imported " .. result.name .. ". Select it with /rxp pack " ..
                        result.id) or result)
            end)
    elseif argument == "export" then
        addon.comms.OpenBrandedExport("Compatibility Pack Export",
            "This export contains no realm identity.", self:Export(), 640, 420)
    else
        local active = self:GetActive()
        addon.comms.PrettyPrint(
            "Active compatibility pack: %s (%s). Use /rxp pack import or /rxp pack export.",
            active and active.name or "None", active and active.id or "none")
    end
end
