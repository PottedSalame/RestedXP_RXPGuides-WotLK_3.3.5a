local _, companion = ...

local core = LibStub and LibStub("AceAddon-3.0", true)
core = core and core:GetAddon("RXPGuides", true)
if not core or not core.guideLocalization then return end

-- Generated locale payloads were intentionally compiled against the core
-- addon's private table. Share only the presentation service with this
-- companion; automation and guide state remain owned by RXPGuides.
companion.guideLocalization = core.guideLocalization

