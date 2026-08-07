local _, addon = ...

addon.directives:RegisterDomain("navigation", {
    "areapoiexists", "flygoto", "goto", "groundgoto", "line", "loop", "mob",
    "openmap", "pin", "questgoto", "questwaypoint", "rare", "subzone",
    "subzoneskip", "target", "treasure", "unitscan", "waypoint", "wpradius",
    "zone", "zoneskip"
})

