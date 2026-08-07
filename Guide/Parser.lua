local _, addon = ...

local parser = addon.guideParser or {}
addon.guideParser = parser

function parser:ParseGuide(...)
    return addon.ParseGuide(...)
end

function parser:ParseLine(...)
    return addon.ParseLine(...)
end

function parser:Applies(condition, customClass)
    return addon.applies(condition, customClass)
end

function parser:GetDirective(name)
    return addon.directives and addon.directives:GetHandler(name) or
               addon.functions[name]
end

addon.services:Register("guide-parser", parser, "guideParser")

