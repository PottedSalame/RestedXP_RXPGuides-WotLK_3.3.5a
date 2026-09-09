local _, addon = ...

local _G = _G

-- Bind RXPGuides to its private map implementation and publish that
-- implementation globally only when Compat/Bootstrap created the namespace.
-- The boolean return is intentionally useful to the pure-Lua ownership test.
function addon.PublishMapAPI335(api)
    if type(api) ~= "table" then return false end
    addon.mapAPI335 = api
    if not addon._ownsGlobalCMap335 then return false end

    local globalMap = _G.C_Map
    if type(globalMap) ~= "table" then
        globalMap = {}
        _G.C_Map = globalMap
    end
    for method, implementation in pairs(api) do
        globalMap[method] = implementation
    end
    return true
end
