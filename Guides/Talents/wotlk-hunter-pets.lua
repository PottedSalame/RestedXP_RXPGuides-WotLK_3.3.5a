local _, addon = ...

if addon.player.class ~= "HUNTER" or addon.game ~= "WOTLK" then return end

-- Coordinates follow the stock 3.3.5 pet trees.  Each plan has a legal
-- sixteen-point leveling core; the final four entries are consumed only when
-- Beast Mastery grants the pet four additional points.
addon.talents.RegisterGuide([[
#name Ferocity Solo Leveling 20-80
#displayname Ferocity - Damage and Sustain
#minLevel 20
#maxLevel 80
#pet Ferocity

level -- Cobra Reflexes (Rank 1)
    .pettalent 1,1,1,1
level -- Cobra Reflexes (Rank 2)
    .pettalent 1,1,1,2
level -- Dash or Dive
    .pettalent 1,1,2,1
level -- Spiked Collar (Rank 1)
    .pettalent 1,2,3,1
level -- Spiked Collar (Rank 2)
    .pettalent 1,2,3,2
level -- Spiked Collar (Rank 3)
    .pettalent 1,2,3,3
level -- Bloodthirsty (Rank 1)
    .pettalent 1,2,2,1
level -- Bloodthirsty (Rank 2)
    .pettalent 1,2,2,2
level -- Culling the Herd (Rank 1)
    .pettalent 1,3,1,1
level -- Culling the Herd (Rank 2)
    .pettalent 1,3,1,2
level -- Culling the Herd (Rank 3)
    .pettalent 1,3,1,3
level -- Spider's Bite (Rank 1)
    .pettalent 1,4,3,1
level -- Spider's Bite (Rank 2)
    .pettalent 1,4,3,2
level -- Spider's Bite (Rank 3)
    .pettalent 1,4,3,3
level -- Call of the Wild
    .pettalent 1,5,3,1
level -- Rabid
    .pettalent 1,5,1,1
level -- Shark Attack (Rank 1, Beast Mastery)
    .pettalent 1,6,1,1
level -- Shark Attack (Rank 2, Beast Mastery)
    .pettalent 1,6,1,2
level -- Wild Hunt (Rank 1, Beast Mastery)
    .pettalent 1,6,3,1
level -- Wild Hunt (Rank 2, Beast Mastery)
    .pettalent 1,6,3,2
]])

addon.talents.RegisterGuide([[
#name Cunning Solo Leveling 20-80
#displayname Cunning - Mobility, Focus, and Damage
#minLevel 20
#maxLevel 80
#pet Cunning

level -- Cobra Reflexes (Rank 1)
    .pettalent 1,1,1,1
level -- Cobra Reflexes (Rank 2)
    .pettalent 1,1,1,2
level -- Dash or Dive
    .pettalent 1,1,2,1
level -- Spiked Collar (Rank 1)
    .pettalent 1,2,4,1
level -- Spiked Collar (Rank 2)
    .pettalent 1,2,4,2
level -- Spiked Collar (Rank 3)
    .pettalent 1,2,4,3
level -- Owl's Focus (Rank 1)
    .pettalent 1,2,3,1
level -- Owl's Focus (Rank 2)
    .pettalent 1,2,3,2
level -- Culling the Herd (Rank 1)
    .pettalent 1,3,1,1
level -- Culling the Herd (Rank 2)
    .pettalent 1,3,1,2
level -- Culling the Herd (Rank 3)
    .pettalent 1,3,1,3
level -- Cornered (Rank 1)
    .pettalent 1,4,3,1
level -- Cornered (Rank 2)
    .pettalent 1,4,3,2
level -- Feeding Frenzy (Rank 1)
    .pettalent 1,4,4,1
level -- Feeding Frenzy (Rank 2)
    .pettalent 1,4,4,2
level -- Roar of Recovery
    .pettalent 1,5,2,1
level -- Wolverine Bite (Beast Mastery)
    .pettalent 1,5,1,1
level -- Wild Hunt (Rank 1, Beast Mastery)
    .pettalent 1,6,1,1
level -- Wild Hunt (Rank 2, Beast Mastery)
    .pettalent 1,6,1,2
level -- Bullheaded (Beast Mastery)
    .pettalent 1,5,3,1
]])

addon.talents.RegisterGuide([[
#name Tenacity Solo Leveling 20-80
#displayname Tenacity - Threat and Survivability
#minLevel 20
#maxLevel 80
#pet Tenacity

level -- Charge
    .pettalent 1,1,2,1
level -- Great Stamina (Rank 1)
    .pettalent 1,1,3,1
level -- Great Stamina (Rank 2)
    .pettalent 1,1,3,2
level -- Great Stamina (Rank 3)
    .pettalent 1,1,3,3
level -- Blood of the Rhino (Rank 1)
    .pettalent 1,2,3,1
level -- Blood of the Rhino (Rank 2)
    .pettalent 1,2,3,2
level -- Spiked Collar (Rank 1)
    .pettalent 1,2,1,1
level -- Spiked Collar (Rank 2)
    .pettalent 1,2,1,2
level -- Spiked Collar (Rank 3)
    .pettalent 1,2,1,3
level -- Guard Dog (Rank 1)
    .pettalent 1,3,1,1
level -- Guard Dog (Rank 2)
    .pettalent 1,3,1,2
level -- Guard Dog (Rank 3)
    .pettalent 1,3,1,3
level -- Thunderstomp
    .pettalent 1,3,4,1
level -- Lionhearted (Rank 1)
    .pettalent 1,3,2,1
level -- Lionhearted (Rank 2)
    .pettalent 1,3,2,2
level -- Intervene
    .pettalent 1,5,2,1
level -- Wild Hunt (Rank 1, Beast Mastery)
    .pettalent 1,6,2,1
level -- Wild Hunt (Rank 2, Beast Mastery)
    .pettalent 1,6,2,2
level -- Grace of the Mantis (Rank 1, Beast Mastery)
    .pettalent 1,3,3,1
level -- Grace of the Mantis (Rank 2, Beast Mastery)
    .pettalent 1,3,3,2
]])
