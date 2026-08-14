local _, addon = ...

-- Pure 3.3.5 XP rules and locale-safe combat-XP parsing.  Keep this file free
-- of frames and SavedVariables so reports, communications, tests, and the XP
-- Assistant can share one authoritative implementation.
addon.xpFormula = addon.xpFormula or {}
local xp = addon.xpFormula

local _G = _G
local concat = table.concat
local floor, max, min = math.floor, math.max, math.min
local tonumber, type = tonumber, type

local CONTENT_BASE = {
    classic = 45,
    outland = 235,
    northrend = 580,
}

function xp:GetContentBase(content)
    return CONTENT_BASE[content]
end

function xp:GetProgress(playerLevel, current, maximum, rested, levelCap)
    playerLevel = floor(tonumber(playerLevel) or 0)
    current = max(0, tonumber(current) or 0)
    maximum = max(0, tonumber(maximum) or 0)
    if maximum > 0 then current = min(current, maximum) end
    levelCap = floor(tonumber(levelCap) or 80)
    local atMax = playerLevel >= levelCap or maximum <= 0
    return {
        level = playerLevel,
        current = current,
        maximum = maximum,
        remaining = atMax and 0 or max(0, maximum - current),
        percent = maximum > 0 and current / maximum * 100 or 100,
        rested = max(0, tonumber(rested) or 0),
        atMax = atMax,
    }
end

function xp:GetGrayLevel(playerLevel)
    playerLevel = floor(tonumber(playerLevel) or 0)
    if playerLevel <= 5 then
        return 0
    elseif playerLevel <= 39 then
        return playerLevel - 5 - floor(playerLevel / 10)
    elseif playerLevel <= 59 then
        return playerLevel - 1 - floor(playerLevel / 5)
    end
    return playerLevel - 9
end

function xp:GetZeroDifference(playerLevel)
    playerLevel = floor(tonumber(playerLevel) or 0)
    if playerLevel < 8 then return 5 end
    if playerLevel < 10 then return 6 end
    if playerLevel < 12 then return 7 end
    if playerLevel < 16 then return 8 end
    if playerLevel < 20 then return 9 end
    if playerLevel < 30 then return 11 end
    if playerLevel < 40 then return 12 end
    if playerLevel < 45 then return 13 end
    if playerLevel < 50 then return 14 end
    if playerLevel < 55 then return 15 end
    if playerLevel < 60 then return 16 end
    return 17
end

function xp:GetBaseMobXP(playerLevel, mobLevel, content)
    playerLevel = floor(tonumber(playerLevel) or 0)
    mobLevel = floor(tonumber(mobLevel) or 0)
    local contentBase = CONTENT_BASE[content]
    if playerLevel < 1 or mobLevel < 1 or not contentBase then return end

    local base = playerLevel * 5 + contentBase
    if mobLevel >= playerLevel then
        local difference = min(mobLevel - playerLevel, 4)
        -- Mirror AzerothCore's uint32 division order exactly.
        return floor((floor(base * (20 + difference) / 10) + 1) / 2)
    end
    if mobLevel > self:GetGrayLevel(playerLevel) then
        local zeroDifference = self:GetZeroDifference(playerLevel)
        return floor(base * (zeroDifference + mobLevel - playerLevel) /
                         zeroDifference)
    end
    return 0
end

function xp:GetYellowLevels(playerLevel)
    playerLevel = floor(tonumber(playerLevel) or 0)
    local levels = {}
    for mobLevel = max(1, playerLevel - 2), playerLevel + 2 do
        levels[#levels + 1] = mobLevel
    end
    return levels
end

function xp:GetKillsRemaining(remaining, perKill, restedPool)
    remaining = max(0, floor(tonumber(remaining) or 0))
    perKill = tonumber(perKill)
    if remaining == 0 then return 0 end
    if not perKill or perKill <= 0 then return end

    restedPool = max(0, floor(tonumber(restedPool) or 0))
    if restedPool == 0 then return math.ceil(remaining / perKill) end

    -- GetXPExhaustion is the remaining bonus pool.  Before that pool expires a
    -- normal kill contributes its ordinary XP plus an equal rested bonus.
    if remaining <= restedPool * 2 then
        return math.ceil(remaining / (perKill * 2))
    end
    return math.ceil((remaining - restedPool) / perKill)
end

function xp:GetCalibration(samples, required)
    local valid = {}
    for _, value in ipairs(type(samples) == "table" and samples or {}) do
        value = tonumber(value)
        if value and value == value and value > 0 and value <= 1000 then
            valid[#valid + 1] = value
        end
    end
    table.sort(valid)
    local count = #valid
    required = max(1, floor(tonumber(required) or 3))
    if count < required then return nil, count, false end
    local middle = floor((count + 1) / 2)
    local median = count % 2 == 1 and valid[middle] or
                       (valid[middle] + valid[middle + 1]) / 2
    local squaredDifference = 0
    for _, value in ipairs(valid) do
        squaredDifference = squaredDifference + (value - median) ^ 2
    end
    local relativeDeviation = median > 0 and
        math.sqrt(squaredDifference / count) / median or 0
    return median, count, relativeDeviation > 0.10
end

local function EscapePattern(text)
    return (text:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
end

local function CompileFormat(formatText)
    if type(formatText) ~= "string" or formatText == "" then return end
    local pattern, captureArguments = {}, {}
    local implicitArgument, cursor = 1, 1
    while cursor <= #formatText do
        local percent = formatText:find("%", cursor, true)
        if not percent then
            pattern[#pattern + 1] = EscapePattern(formatText:sub(cursor))
            break
        end
        if percent > cursor then
            pattern[#pattern + 1] = EscapePattern(
                formatText:sub(cursor, percent - 1))
        end

        local rest = formatText:sub(percent)
        if rest:sub(1, 2) == "%%" then
            pattern[#pattern + 1] = "%%"
            cursor = percent + 2
        else
            local _, finish, position = rest:find(
                "^%%(%d+)%$[-+ #0]*%d*%.?%d*[ds]")
            local argument
            if finish then
                argument = tonumber(position)
            else
                _, finish = rest:find("^%%[-+ #0]*%d*%.?%d*[ds]")
                argument = implicitArgument
                implicitArgument = implicitArgument + 1
            end
            if finish then
                pattern[#pattern + 1] = "(.-)"
                captureArguments[#captureArguments + 1] = argument
                cursor = percent + finish
            else
                pattern[#pattern + 1] = "%%"
                cursor = percent + 1
            end
        end
    end
    return "^" .. concat(pattern) .. "$", captureArguments
end

local function ParseNumber(value)
    if type(value) == "number" then return value end
    if type(value) ~= "string" then return end
    local digits = value:gsub("[^%d]", "")
    if digits == "" then return end
    return tonumber(digits)
end

local formatDescriptors
local function AddDescriptor(target, globalName, xpArgument, bonusArgument,
                             named)
    local formatText = _G[globalName]
    local pattern, captureArguments = CompileFormat(formatText)
    if pattern then
        target[#target + 1] = {
            globalName = globalName,
            source = formatText,
            pattern = pattern,
            captureArguments = captureArguments,
            xpArgument = xpArgument,
            bonusArgument = bonusArgument,
            named = named,
        }
    end
end

function xp:RefreshCombatXPFormats()
    local descriptors = {}
    for exhaustion = 1, 5 do
        local prefix = "COMBATLOG_XPGAIN_EXHAUSTION" .. exhaustion
        local bonusArgument = exhaustion <= 2 and 3 or nil
        AddDescriptor(descriptors, prefix, 2, bonusArgument, true)
        AddDescriptor(descriptors, prefix .. "_GROUP", 2, bonusArgument, true)
        AddDescriptor(descriptors, prefix .. "_RAID", 2, bonusArgument, true)
    end
    AddDescriptor(descriptors, "COMBATLOG_XPGAIN_FIRSTPERSON_GROUP", 2, nil,
                  true)
    AddDescriptor(descriptors, "COMBATLOG_XPGAIN_FIRSTPERSON_RAID", 2, nil,
                  true)
    AddDescriptor(descriptors, "COMBATLOG_XPGAIN_FIRSTPERSON", 2, nil, true)
    AddDescriptor(descriptors, "COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED_GROUP", 1,
                  nil, false)
    AddDescriptor(descriptors, "COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED_RAID", 1,
                  nil, false)
    AddDescriptor(descriptors, "COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED", 1, nil,
                  false)
    AddDescriptor(descriptors, "COMBATLOG_XPGAIN_QUEST", 1, nil, false)
    formatDescriptors = descriptors
    return descriptors
end

function xp:ParseCombatXPMessage(text)
    if type(text) ~= "string" or text == "" then return end
    local descriptors = formatDescriptors or self:RefreshCombatXPFormats()
    for _, descriptor in ipairs(descriptors) do
        local captures = {text:match(descriptor.pattern)}
        if #captures > 0 then
            local arguments = {}
            for index, argument in ipairs(descriptor.captureArguments) do
                arguments[argument] = captures[index]
            end
            local total = ParseNumber(arguments[descriptor.xpArgument])
            if total and total > 0 then
                local restedBonus
                if descriptor.bonusArgument then
                    restedBonus = ParseNumber(
                        arguments[descriptor.bonusArgument])
                end
                return {
                    total = total,
                    restedBonus = restedBonus,
                    named = descriptor.named,
                    sourceName = descriptor.named and arguments[1] or nil,
                    formatName = descriptor.globalName,
                    exact = true,
                }
            end
        end
    end

    -- Private servers occasionally customize GlobalStrings after login.  The
    -- guarded fallback retains existing behavior, while calibration still
    -- requires a correlated killed unit before accepting this value.
    local compact = text:gsub("[%s\194\160]", "")
    local token = compact:match("%d[%d%.,]*")
    local total = ParseNumber(token)
    if not total or total <= 0 then return end
    local unattributed = addon.IsUnattributedXPMessage and
                             addon.IsUnattributedXPMessage(text)
    return {
        total = total,
        -- Custom server text cannot be classified reliably.  Preserve an
        -- explicit false when another compatibility helper recognizes an
        -- unattributed award; otherwise leave attribution unknown.  The XP
        -- Assistant accepts unknown text only alongside PARTY_KILL and the
        -- authoritative live XP delta, while reports require an exact format.
        named = unattributed and false or nil,
        exact = false,
    }
end

function addon.ParseCombatXPMessage(text)
    return xp:ParseCombatXPMessage(text)
end
