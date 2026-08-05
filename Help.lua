local _, addon = ...

local H = {}

H["I'm missing a lot of exp, why?"] = [[
You should be grinding mobs between quests, not just moving from objective to objective.

This guide is based on speed - which means less quests to turn in. Grinding from quest to quest makes up for the lost xp.
]]

H["Why is my guide missing levels?"] = [[
The level ranges on our guides are intended for standard exp rates, do not worry about following the leveling brackets while on 20% or 50% exp.

Just follow the guide the best you can.
]]

H["Why is my guide skipping lots of steps or zones?"] = [[
These are inefficient areas that we skip if you are missing quest chains or if you are ahead in levels compared to the guide.
]]

H["What are command the line options?"] = [[
|cff909090/rxp|r - Open general addon settings
|cff909090/rxp import|r - Open Import Guide interface
|cff909090/rxp debug|r - enable debugging output
|cff909090/rxp splits|r - Toggle Level Splits on or off, if enabled
|cff909090/rxp show||hide||toggle|r - Toggle all enabled frames on or off
|cff909090/rxp bug||feedback|r - Open Feedback Form
|cff909090/rxp guides|r - Open the searchable Guide Hub
|cff909090/rxp backup|r - Export, merge, replace, or undo a settings/progress backup
|cff909090/rxp diagnose|r - Explain the current step and its blockers
|cff909090/rxp catchup|r - Preview a safe starting step
|cff909090/rxp route|r - Plan a conservative return route
|cff909090/rxp supplies|r - Open the class supplies checklist
|cff909090/rxp gear|r - Open the Gear Advisor
|cff909090/rxp dailies|r - Open the WotLK activity planner
|cff909090/rxp record|r - Open the opt-in Guide Author Recorder
|cff909090/rxp party on||off||wait||suggest|r - Control opt-in party guide sync
|cff909090/rxp lore off||first||always|r - Control quest-text automation pauses
|cff909090/rxp colorblind MODE|r - Apply an accessible color/symbol preset
|cff909090/rxp help|r - This output
]]

addon.help = H

local C = {}

C["TomTom"] = {
    ["Reason"] = "has known incompatibilities with the Waypoint Arrow.",
    ["Recommendation"] = "Disable it if you're experiencing navigation issues."
}
C["SilverDragon"] = C["TomTom"]
C["TotemTimers"] = C["TomTom"]
C["Leatrix Maps"] = C["TomTom"]

C["Narcissus"] = {
    ["Reason"] = "can replace map and unit-frame layers used by navigation markers.",
    ["Recommendation"] = "If markers are hidden, test once with its map and unit-frame modules disabled."
}

addon.compatibility = C
