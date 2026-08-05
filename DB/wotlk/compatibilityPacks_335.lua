local _, addon = ...

-- Data-only baseline for stock AzerothCore 3.3.5a. Resolver-time overrides
-- live here instead of changing the bundled guide source. Keep this table free
-- of callbacks or executable payload fields so the offline validator can audit
-- the same schema accepted by CompatibilityPacks.lua.
addon.CompatibilityPackBaseline335 = {
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
    eventQuirks = {},
    resetPolicy = {}
}
