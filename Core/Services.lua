local _, addon = ...

-- Small explicit service registry for first-party runtime dependencies.  It is
-- intentionally simpler than a general dependency-injection framework: WoW
-- loads files in TOC order, while the runtime registry validates lifecycle
-- ordering later during ADDON_LOADED.
local services = addon.services or {}
addon.services = services

local instances = {}
local order = {}

local function ValidateName(name)
    if type(name) ~= "string" or name == "" then
        error("RXPGuides service names must be non-empty strings", 3)
    end
end

function services:Register(name, instance, legacyAliases)
    ValidateName(name)
    if instance == nil then
        error("RXPGuides service '" .. name .. "' cannot be nil", 2)
    end
    local current = instances[name]
    if current and current ~= instance then
        error("RXPGuides service '" .. name .. "' is already registered", 2)
    end
    if not current then
        instances[name] = instance
        order[#order + 1] = name
    end
    if type(legacyAliases) == "string" then
        legacyAliases = {legacyAliases}
    end
    for _, alias in ipairs(type(legacyAliases) == "table" and
                                legacyAliases or {}) do
        ValidateName(alias)
        if addon[alias] ~= nil and addon[alias] ~= instance then
            error("RXPGuides legacy alias '" .. alias .. "' already exists", 2)
        end
        addon[alias] = instance
    end
    return instance
end

function services:Get(name)
    ValidateName(name)
    return instances[name]
end

function services:Require(name)
    local instance = self:Get(name)
    if instance == nil then
        error("RXPGuides required service '" .. name .. "' is unavailable", 2)
    end
    return instance
end

function services:Has(name)
    ValidateName(name)
    return instances[name] ~= nil
end

function services:List()
    local result = {}
    for index, name in ipairs(order) do result[index] = name end
    return result
end

