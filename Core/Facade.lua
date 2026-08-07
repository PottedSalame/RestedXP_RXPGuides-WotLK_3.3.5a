local _, addon = ...

local facade = addon.facade or {}
addon.facade = facade

local addonExports = {}
local globalExports = {}

local function CheckName(name)
    if type(name) ~= "string" or name == "" then
        error("RXPGuides facade names must be non-empty strings", 3)
    end
end

function facade:ExposeAddon(name, value)
    CheckName(name)
    if value == nil then error("RXPGuides facade values cannot be nil", 2) end
    if addon[name] ~= nil and addon[name] ~= value then
        error("RXPGuides addon facade entry '" .. name .. "' conflicts", 2)
    end
    addon[name] = value
    addonExports[name] = true
    return value
end

function facade:ExposeGlobal(name, value)
    CheckName(name)
    if value == nil then error("RXPGuides facade values cannot be nil", 2) end
    if _G[name] ~= nil and _G[name] ~= value then
        error("RXPGuides global facade entry '" .. name .. "' conflicts", 2)
    end
    _G[name] = value
    globalExports[name] = true
    return value
end

function facade:IsAddonExport(name)
    return addonExports[name] == true
end

function facade:IsGlobalExport(name)
    return globalExports[name] == true
end

function facade:Snapshot()
    local result = {addon = {}, globals = {}}
    for name in pairs(addonExports) do result.addon[#result.addon + 1] = name end
    for name in pairs(globalExports) do
        result.globals[#result.globals + 1] = name
    end
    table.sort(result.addon)
    table.sort(result.globals)
    return result
end

facade:ExposeAddon("services", addon.services)
facade:ExposeAddon("scheduler", addon.scheduler)
facade:ExposeAddon("storage", addon.storage)
facade:ExposeAddon("runtime", addon.runtime)

