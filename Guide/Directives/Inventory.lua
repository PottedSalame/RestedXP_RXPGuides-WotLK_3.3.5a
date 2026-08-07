local _, addon = ...

addon.directives:RegisterDomain("inventory", {
    "addquestitem", "bankdeposit", "bankwithdraw", "bronzetube", "buy",
    "destroy", "equip", "itemStat", "itemcount", "money", "openitem",
    "questitemcount", "scrap", "totalbagslots", "vendor"
})

