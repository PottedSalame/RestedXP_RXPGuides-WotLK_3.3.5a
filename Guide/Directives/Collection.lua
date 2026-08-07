local _, addon = ...

addon.directives:RegisterDomain("collection", {
    "achievement", "achievementComplete", "achievementIncomplete",
    "achievementskip", "collect", "collectcurrency", "collectmount",
    "collectpet", "collecttoy", "mountcount"
})

