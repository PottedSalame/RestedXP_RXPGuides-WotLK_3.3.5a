local _, addon = ...

local directives = addon.directives or {}
addon.directives = directives

local entries = {}
local domains = {}
local order = {}

local function CheckName(name)
    if type(name) ~= "string" or name == "" then
        error("RXPGuides directive names must be non-empty strings", 3)
    end
end

local function CopyMetadata(metadata)
    local copy = {}
    for key, value in pairs(metadata or {}) do copy[key] = value end
    return copy
end

function directives:Register(name, handler, metadata)
    CheckName(name)
    if type(handler) ~= "function" then
        error("RXPGuides directive '" .. name .. "' requires a handler", 2)
    end
    local current = entries[name]
    if current and current.handler ~= handler then
        error("RXPGuides directive '" .. name .. "' is already registered", 2)
    end
    if not current then
        current = {name = name, handler = handler, metadata = CopyMetadata(metadata)}
        entries[name] = current
        order[#order + 1] = name
    else
        for key, value in pairs(metadata or {}) do current.metadata[key] = value end
    end
    addon.functions[name] = handler
    local events = current.metadata.events
    if events ~= nil then addon.functions.events[name] = events end
    return handler
end

function directives:Adopt(name, metadata)
    CheckName(name)
    local handler = addon.functions[name]
    if type(handler) ~= "function" then
        error("RXPGuides directive catalog references missing handler '." ..
                  name .. "'", 2)
    end
    metadata = CopyMetadata(metadata)
    if metadata.events == nil then
        metadata.events = addon.functions.events[name]
    end
    return self:Register(name, handler, metadata)
end

function directives:RegisterDomain(id, names)
    CheckName(id)
    if domains[id] then
        error("RXPGuides directive domain '" .. id .. "' is already registered", 2)
    end
    if type(names) ~= "table" then
        error("RXPGuides directive domains require a name list", 2)
    end
    domains[id] = {}
    for _, name in ipairs(names) do
        if entries[name] and entries[name].metadata.domain ~= id then
            error("RXPGuides directive '." .. name ..
                      "' belongs to more than one domain", 2)
        end
        self:Adopt(name, {domain = id})
        domains[id][#domains[id] + 1] = name
    end
end

function directives:Get(name)
    return entries[name]
end

function directives:GetHandler(name)
    local entry = entries[name]
    return entry and entry.handler
end

function directives:GetEvents(name)
    local entry = entries[name]
    return entry and entry.metadata.events
end

function directives:GetDomain(name)
    local entry = entries[name]
    return entry and entry.metadata.domain
end

function directives:List(domain)
    local source = domain and domains[domain] or order
    local result = {}
    for index, name in ipairs(source or {}) do result[index] = name end
    return result
end

function directives:ValidateLegacySurface()
    for name, handler in pairs(addon.functions) do
        if name ~= "events" and name ~= "__index" and
            type(handler) == "function" and not entries[name] then
            return false, "Uncatalogued directive '." .. tostring(name) .. "'"
        end
    end
    return true
end

addon.services:Register("directives", directives, "directives")

