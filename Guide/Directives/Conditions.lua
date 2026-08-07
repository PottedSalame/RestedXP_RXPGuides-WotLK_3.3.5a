local _, addon = ...

addon.directives:RegisterDomain("condition", {
    "aura", "blastedLands", "cooldown", "dailyreset", "dmf", "holiday",
    "isInScenario", "isWorldQuestAvailable", "isWorldQuestUnavailable",
    "landfall", "klaxxi", "neutralzonefinished", "nodmf", "requires",
    "skipto", "vale"
})
