local _, addon = ...

local registry = addon.guideRegistry or {}
addon.guideRegistry = registry

local legacyRegisterGuide = addon.RegisterGuide
local legacyAddGuide = addon.AddGuide
local legacyRemoveGuide = addon.RemoveGuide

function registry:Register(...)
    return legacyRegisterGuide(...)
end

function registry:Add(guide)
    return legacyAddGuide(guide)
end

function registry:Remove(key)
    return legacyRemoveGuide(key)
end

function registry:Get(group, name)
    if addon.GetGuideTable then return addon.GetGuideTable(group, name) end
end

function registry:GetByKey(key)
    if type(key) ~= "string" then return nil end
    local direct = addon.guides and addon.guides[key]
    if type(direct) == "table" then return direct end
    for _, guide in pairs(addon.guides or {}) do
        if type(guide) == "table" and guide.key == key then return guide end
    end
end

function registry:List()
    return addon.guides
end

addon.RegisterGuide = function(...) return registry:Register(...) end
addon.AddGuide = function(guide) return registry:Add(guide) end
addon.RemoveGuide = function(key) return registry:Remove(key) end
if _G.RXPGuides then _G.RXPGuides.RegisterGuide = addon.RegisterGuide end

addon.services:Register("guide-registry", registry, "guideRegistry")

