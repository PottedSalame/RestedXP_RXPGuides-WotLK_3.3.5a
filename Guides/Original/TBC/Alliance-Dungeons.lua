-- Generated from RXPGuides v4.10.20 by tools/Build-TBCGuides335.ps1.
-- Curated for the standalone 3.3.5a backport; do not replace with the upstream aggregate file.
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 15-30
<< Alliance
#name 01. The Deadmines
#displayname 1. The Deadmines
step
#completewith next
.zone Westfall >> Travel to Westfall
step
.goto Westfall,56.33,47.52
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gryan Stoutmantle|r
.accept 65 >> Accept The Defias Brotherhood
.target Gryan Stoutmantle
step
#completewith next
.goto Westfall,56.55,52.64
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thor|r
.fly Redridge >> Fly to Redridge Mountains
.target Thor
.zoneskip Redridge Mountains
step
.goto Redridge Mountains,27.35,44.07,8,0
.goto Redridge Mountains,26.48,45.34
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Wiley the Black|r inside upstairs
.turnin 65 >> Turn in The Defias Brotherhood
.accept 132 >> Accept The Defias Brotherhood
.target Wiley the Black
step
#completewith next
.goto Redridge Mountains,30.59,59.42
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ariena Stormfeather|r
.fly Sentinel Hill >> Fly to Westfall
.target Ariena Stormfeather
.zoneskip Westfall
step
.goto Westfall,56.325,47.519
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gryan Stoutmantle|r
.turnin 132 >> Turn in The Defias Brotherhood
.accept 135 >> Accept The Defias Brotherhood
.target Gryan Stoutmantle
step
#completewith next
.goto Westfall,56.55,52.64
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thor|r
.fly Stormwind >> Fly to Stormwind
.target Thor
.zoneskip Stormwind City
step
.goto StormwindClassic,75.78,59.84
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Master Mathias Shaw|r
.turnin 135 >> Turn in The Defias Brotherhood
.accept 141 >> Accept The Defias Brotherhood
.target Master Mathias Shaw
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Shoni the Shilent|r and |cRXP_FRIENDLY_Wilder Thistlenettle|r
.accept 2040 >> Accept Underground Assault
.target +Shoni the Shilent
.goto StormwindClassic,55.510,12.504
.accept 167 >> Accept Oh Brother. . .
.accept 168 >> Accept Collecting Memories
.goto StormwindClassic,65.438,21.175
.target +Wilder Thistlenettle
step
#completewith next
.goto StormwindClassic,66.277,62.137
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Dungar Longdrink|r
.fly Sentinel Hill >> Fly to Westfall
.target Dungar Longdrink
.zoneskip Westfall
step
.goto Westfall,56.325,47.519
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gryan Stoutmantle|r
.turnin 141 >> Turn in The Defias Brotherhood
.accept 142 >> Accept The Defias Brotherhood
.target Gryan Stoutmantle
step
.goto Westfall,44.50,69.62
.line Westfall,44.50,69.62,44.50,69.62,45.08,69.40,45.21,69.35,45.63,68.69,45.85,67.73,45.62,66.99,45.52,65.71,45.61,64.95,44.28,63.88,44.26,62.80,43.60,59.89,43.37,58.42,43.26,57.01,43.12,54.24,42.15,52.74,41.74,51.42,41.48,49.89,40.91,48.71,38.93,46.05,38.51,45.46,37.85,45.54,36.60,44.21,36.06,43.86,35.12,43.49,33.92,43.21,32.56,43.05,31.34,44.54,32.56,43.05,33.92,43.21,35.12,43.49,36.06,43.86,36.26,43.77,36.87,42.87,36.95,40.85,37.04,39.79,37.91,36.98,39.06,35.58,40.48,34.31,41.27,32.87,41.76,31.27,42.26,30.26,43.20,28.99,44.29,28.19,44.64,26.85,44.57,24.94,44.64,26.85,44.29,28.19,43.20,28.99,42.26,30.26,41.76,31.27,41.27,32.87,40.48,34.31,39.06,35.58,37.91,36.98,37.04,39.79,36.95,40.85,36.87,42.87,36.26,43.77,36.06,43.86,35.12,43.49,33.92,43.21,32.56,43.05,31.34,44.54,32.56,43.05,33.92,43.21,35.12,43.49,36.06,43.86,36.60,44.21,37.85,45.54,38.51,45.46,38.93,46.05,40.91,48.71,41.48,49.89,41.74,51.42,42.15,52.74,43.12,54.24,43.26,57.01,43.37,58.42,43.60,59.89,44.26,62.80,44.28,63.88,45.61,64.95,45.52,65.71,45.62,66.99,45.85,67.73,45.63,68.69,45.21,69.35,45.08,69.40,44.50,69.62
>>Kill the |cRXP_ENEMY_Defias Messenger|r. Loot him for his |cRXP_LOOT_Mysterious Message|r
>>|cRXP_WARN_The |cRXP_ENEMY_Defias Messenger|r spawns in Moonbrook. He walks along the road north of Moonbrook, to the Gold Coast Quarry and Jangolode Mine. If you don't see him along the road, wait for him to spawn in Moonbrook|r
>>|cRXP_WARN_He has a 4-5 minute respawn timer|r
.complete 142,1 
.unitscan Defias Messenger
step
.goto Westfall,56.33,47.52
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gryan Stoutmantle|r
.turnin 142 >> Turn in The Defias Brotherhood
.target Gryan Stoutmantle
step
.goto Westfall,55.68,47.50
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_The Defias Traitor|r
>>|cRXP_WARN_You may need to wait for |cRXP_FRIENDLY_The Defias Traitor|r to spawn if he's not there|r
>>|cRXP_WARN_If you've already assembled a group, make sure your group has also turned in the previous part first before starting the escort|r
.accept 155 >> Accept The Defias Brotherhood
.target The Defias Traitor
step
.goto Westfall,42.56,71.71
>>Escort the |cRXP_FRIENDLY_The Defias Traitor|r to The Deadmines
>>|cRXP_WARN_Stay beside |cRXP_FRIENDLY_The Defias Traitor|r at all times. Be ready to fight |cRXP_ENEMY_Defias Pillagers|r and |cRXP_ENEMY_Defias Looters|r upon reaching Moonbrook|r
.complete 155,1 
.target The Defias Traitor
step
.goto Westfall,56.33,47.52
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gryan Stoutmantle|r
.turnin 155 >> Turn in The Defias Brotherhood
.accept 166 >> Accept The Defias Brotherhood
.target Gryan Stoutmantle
step
.goto Westfall,56.67,47.35
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Scout Riell|r atop the Tower
.accept 214 >> Accept Red Silk Bandanas
.target Scout Riell
step
.goto 1436,56.454,69.982,0
.goto 1436,56.434,74.339,0
.goto 1436,59.384,74.184,0
.goto 1436,60.871,74.362,0
.goto 1436,60.902,77.640,0
.goto 1436,63.442,77.339,0
.goto 1436,65.203,75.286,0
.goto 1436,63.594,72.862,0
.goto 1436,63.825,70.125,0
.goto 1436,42.649,71.376
>>|cRXP_WARN_Grind |cRXP_ENEMY_Gnolls|r south of Sentinel Hill whilst assembling a Deadmines group|r
.subzone 20 >>When your group has been assembled, travel to Moonbrook
step
.goto Westfall,42.55,71.69
.subzone 1581 >> Enter the Defias Hideout with your group
step
#completewith EnterDM
>>Kill the |cRXP_ENEMY_Defias|r. Loot them for their |cRXP_LOOT_Red Silk Bandanas|r
>>|cRXP_WARN_You can also complete this inside the Deadmines|r
.complete 214,1 
.isOnQuest 214
step
#completewith next
>>Kill |cRXP_ENEMY_Skeletal Miners|r, |cRXP_ENEMY_Undead Dynamiters|r and |cRXP_ENEMY_Undead Excavators|r. Loot them for their |cRXP_LOOT_Cards|r
>>|cRXP_WARN_This is completed OUTSIDE of the Dungeon|r
.complete 168,1 
.mob Skeletal Miner
.mob Undead Dynamiter
.mob Undead Excavator
step
.goto 1415,41.18,79.80,25,0
.goto 1415,41.03,79.96,25,0
.goto 1415,40.92,80.05,25,0
.goto 1415,41.08,80.11
>>Kill |cRXP_ENEMY_Foreman Thistlenettle|r. Loot him for his |cRXP_LOOT_Badge|r
>>|cRXP_WARN_This is completed OUTSIDE of the Dungeon|r
.complete 167,1 
.unitscan Foreman Thistlenettle
step
.goto 1415,41.18,79.80,25,0
.goto 1415,41.03,79.96,25,0
.goto 1415,40.92,80.05,25,0
.goto 1415,41.08,80.11
>>Kill |cRXP_ENEMY_Skeletal Miners|r, |cRXP_ENEMY_Undead Dynamiters|r and |cRXP_ENEMY_Undead Excavators|r. Loot them for their |cRXP_LOOT_Cards|r
>>|cRXP_WARN_This is completed OUTSIDE of the Dungeon|r
.complete 168,1 
.mob Skeletal Miner
.mob Undead Dynamiter
.mob Undead Excavator
step
#label EnterDM
.goto 1415,40.94,79.76,25,0
.goto 1415,40.86,79.62,20,0
.goto 1415,40.678,79.578
.subzone 1581,2 >> Enter The Deadmines Dungeon
step
#completewith VanCleef
>>Kill the |cRXP_ENEMY_Defias|r inside The Deadmines. Loot them for their |cRXP_LOOT_Red Silk Bandanas|r
.complete 214,1 
.isOnQuest 214
step
>>Kill |cRXP_ENEMY_Sneed|r. Loot him for the |cRXP_LOOT_Gnoam Sprecklesprocket|r
.complete 2040,1 
step
#label VanCleef
>>Kill |cRXP_ENEMY_Edwin VanCleef|r. Loot him for his |cRXP_LOOT_Head|r and |T133471:0|t[|cRXP_LOOT_An Unsent Letter|r]
>>|cRXP_WARN_Use |T133471:0|t[|cRXP_LOOT_An Unsent Letter|r] to start the quest|r
.collect 2874,1,373,1 
.complete 166,1 
.accept 373 >> Accept The Unsent Letter
.use 2874 
step
>>Kill the |cRXP_ENEMY_Defias|r. Loot them for their |cRXP_LOOT_Red Silk Bandanas|r
>>|cRXP_WARN_You can also complete this inside and outside the Deadmines|r
.complete 214,1 
.isOnQuest 214
step
#completewith next
.goto Westfall,56.33,47.52,100 >> Travel to Sentinel Hill
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gryan Stoutmantle|r and |cRXP_FRIENDLY_Scout Riell|r atop the Tower
.turnin 166 >> Turn in The Defias Brotherhood
.target +Gryan Stoutmantle
.goto Westfall,56.33,47.52
.turnin -214 >> Turn in Red Silk Bandanas
.target +Scout Riell
.goto Westfall,56.67,47.35
step
#completewith next
.goto Westfall,56.55,52.64
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thor|r
.fly Stormwind >> Fly to Stormwind
.target Thor
.zoneskip Stormwind City
step
.goto StormwindClassic,48.079,30.913,10,0
.goto StormwindClassic,49.193,30.285
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Baros Alexston|r
.turnin 373 >> Turn in The Unsent Letter
.accept 389 >> Accept Bazil Thredd
.target Baros Alexston
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Wilder Thistlenettle|r and |cRXP_FRIENDLY_Shoni the Shilent|r
.turnin 167 >> Turn in Oh Brother. . .
.turnin 168 >> Turn in Collecting Memories
.target +Wilder Thistlenettle
.goto StormwindClassic,65.438,21.175
.turnin 2040 >> Turn in Underground Assault
.target +Shoni the Shilent
.goto StormwindClassic,55.510,12.504
step
.goto StormwindClassic,42.435,59.236,10,0
.goto StormwindClassic,41.102,58.091
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Warden Thelwater|r
.turnin 389 >> Turn in Bazil Thredd
.target Warden Thelwater
step
+|cRXP_WARN_You have completed The Deadmines quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 15-30
<< Alliance
#name 02. Shadowfang Keep
#displayname 2. Shadowfang Keep
step
#completewith next
.goto Wetlands,30.8,31.0,0
.goto Wetlands,37.8,29.6,0
.goto Wetlands,43.0,33.2,0
.zone Arathi Highlands >> Grind |cRXP_ENEMY_Mosshides Gnolls|r while looking for a group for Shadowfang Keep
step
#completewith next
.goto Arathi Highlands,43.01,55.00,90,0
.goto Arathi Highlands,25.45,46.95,90,0
.goto Arathi Highlands,21.29,30.24,70,0
.goto Hillsbrad Foothills,49.338,52.272
+There are no quests for Shadowfang Keep. You will have to run from Wetlands to Silverpine Forest. Ensure you stay on the road while running through Arathi Highlands, and watchout for the |cRXP_ENEMY_Forsaken Courier|r
.unitscan Forsaken Courier
step
.goto Hillsbrad Foothills,14.77,46.72,0
.goto Silverpine Forest,44.96,67.92,0
.goto Hillsbrad Foothills,14.77,46.72,100,0
.goto Silverpine Forest,47.19,69.78,100,0
.goto Silverpine Forest,44.712,67.769
.subzone 209,2 >> Enter Shadowfang Keep
step
+There are no quests for Shadowfang Keep
>>Clear Shadowfang Keep. Leave when you are finished
.zoneskip Shadowfang Keep,1
step
+|cRXP_WARN_You have completed the Shadowfang Keep quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 15-30
<< Alliance
#name 03. Blackfathom Deeps
#displayname 3. Blackfathom Deeps
step
#completewith next
.zone Stormwind City >> Travel to Stormwind
step
.goto StormwindClassic,21.40,55.80
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Argos Nightwhisper|r
.accept 3765 >> Accept The Corruption Abroad
.target Argos Nightwhisper
step
#completewith next
.zone Darnassus >> Travel to Darnassus
>>|cRXP_WARN_Buy a portal from a Mage if this is an option, otherwise travel to Wetlands and get the boat to Auberdine, followed by another boat to Darnassus|r
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Argent Guard Manados|r and |cRXP_FRIENDLY_Dawnwatcher Shaedlass|r upstairs
.accept 1199 >> Accept Twilight Falls
.target +Argent Guard Manados
.goto Darnassus,55.239,23.996 
.accept 1198 >> Accept In Search of Thaelrid
.goto Darnassus,55.360,25.024 
.target +Dawnwatcher Shaedlass
step
.goto Darnassus,29.466,41.405
.zone Teldrassil >> Take the purple portal to Rut'theran Village
.zoneskip Darnassus,1
step
#completewith next
.goto Teldrassil,58.399,94.016
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vesprystus|r
>>|cRXP_WARN_Take the boat to Darkshore if you don't have the flight path|r
.fly Auberdine >> Fly to Darkshore
.target Vesprystus
.zoneskip Darkshore
step
.goto Darkshore,38.327,43.039
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gershala Nightwhisper|r
.turnin 3765 >> Turn in The Corruption Abroad
.accept 1275 >> Accept Researching the Corruption
.target Gershala Nightwhisper
step
.goto Darkshore,36.71,44.98,5,0
.goto Darkshore,36.336,45.574
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Caylais Moonfeather|r
.fly Astranaar >> Fly to Ashenvale
.target Caylais Moonfeather
.zoneskip Ashenvale
step
.goto Ashenvale,37.6,34.0,0
+Start looking for a group for BFD
.goto Ashenvale,15.5,19.0,0
.goto Ashenvale,14.230,14.618
>>Grind |cRXP_ENEMY_Furbolgs|r north of Astranaar for |T132911:0|t[Wool Cloth] while you assemble a group
.subzoneskip 2797
step
#completewith EnterBFD
.goto Ashenvale,14.230,14.618,0
.goto 1414,43.97,35.30,50 >> Travel to Blackfathom Deeps
.subzoneskip 2797
step
#completewith next
>>Kill |cRXP_ENEMY_Fallenroot Rogues|r, |cRXP_ENEMY_Fallenroot Satyrs|r, |cRXP_ENEMY_Blackfathom Oracles|r and |cRXP_ENEMY_Blackfathom Tide Priestesses|r. Loot them for their |cRXP_LOOT_Corrupted Brain Stems|r
>>|cRXP_WARN_You may also loot |cRXP_LOOT_Corrupted Brain Stems|r once inside the Instance|r
.complete 1275,1 
.mob Blackfathom Tide Priestess
.mob Blackfathom Oracle
.mob Fallenroot Rogue
.mob Fallenroot Satyr
.isOnQuest 1275
step
#label EnterBFD
.goto 1414,43.83,35.11,25,0
.goto 1414,43.92,34.56,25,0
.goto 1414,44.02,34.57,25,0
.goto 1414,44.340,34.840
.subzone 2797,2 >> Make your way to the BFD Instance Portal. Zone in
step
#completewith Kelris
>>Kill |cRXP_ENEMY_Nagas|r and |cRXP_ENEMY_Satyrs|r. Loot them for their |cRXP_LOOT_Corrupted Brain Stems|r
.complete 1275,1 
.isOnQuest 1275
step
#label manuscript
#sticky
>>Open the |cRXP_PICK_Pitted Iron Chest|r underwater near the area with the turtles. Loot it for |cRXP_LOOT_Lorgalis' Manuscript|r
.complete 971,1 
.isOnQuest 971
step
#label Thaelrid
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Argent Guard Thaelrid|r
.turnin -1198 >> Turn in Search of Thaelrid
.accept 1200 >> Accept Blackfathom Villainy
step
#requires manuscript
#completewith Kelris
>>Kill all of the |cRXP_ENEMY_Twilight's Hammer|r. Loot them for their |cRXP_LOOT_Twilight Pendants|r
.complete 1199,1 
.isOnQuest 1199
step
#requires manuscript
#label Kelris
>>Kill |cRXP_ENEMY_Twilight Lord Kelris|r. Loot him for his |cRXP_LOOT_Head|r
.complete 1200,1 
.isOnQuest 1200
step
>>Kill all of the |cRXP_ENEMY_Twilight's Hammer|r. Loot them for their |cRXP_LOOT_Twilight Pendants|r
.complete 1199,1 
.isOnQuest 1199
step
#label FinalStem
>>Kill |cRXP_ENEMY_Nagas|r and |cRXP_ENEMY_Satyrs|r. Loot them for their |cRXP_LOOT_Corrupted Brain Stems|r
>>If you haven't completed this quest yet, click on the altar at the end of the dungeon to teleport you to the entrance. The mobs outside of the instance can also drop it.
.complete 1275,1 
.isOnQuest 1275
step
#optional
+Talk to |cRXP_FRIENDLY_Morridune|r at the end of the dungeon if you are still inside BFD to be teleported to Darnassus
.target Morridune
.zoneskip Ashenvale
.zoneskip Teldrassil
.zoneskip Darnassus
step
#completewith DarnEnd
.goto Ashenvale,34.41,47.98
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Daelyshia|r
.fly Teldrassil >> Fly to Teldrassil
.target Daelyshia
.zoneskip Teldrassil
.zoneskip Darnassus
step
#sticky
#label DarnBFD
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Argent Guard Manados|r up stairs
.turnin 1199 >> Turn in Twilight Falls
.goto Darnassus,55.239,23.996 
.target Argent Guard Manados
.isQuestComplete 1199
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Dawnwatcher Selgorm|r up stairs
.turnin 1200 >> Turn in Blackfathom Villainy
.goto Darnassus,56.167,24.395 
.target Dawnwatcher Selgorm
.isQuestComplete 1200
step
#requires DarnBFD
#label DarnEnd
.goto Darnassus,29.466,41.405
.zone Teldrassil >> Take the purple portal back to Rut'theran
.zoneskip Darkshore
.zoneskip Ashenvale
.subzoneskip 2797
step
#completewith next
.goto Ashenvale,34.41,47.98,-1
.goto Teldrassil,58.399,94.016,-1
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vesprystus|r or |cRXP_FRIENDLY_Daelyshia|r
.fly Darkshore >> Fly to Darkshore
.zoneskip Darkshore
.target Daelyshia
.target Vesprystus
step
.goto Darkshore,38.327,43.039
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gershala Nightwhisper|r
.turnin 1275 >> Turn in Researching the Corruption
.target Gershala Nightwhisper
.isQuestComplete 1275
step
#completewith KitD
.zone Ironforge >> Travel to Ironforge
step
.goto Darkshore,32.29,44.05
.zone Wetlands >> Take the boat to Menethil Harbor, then fly to Ironforge
.zoneskip Ironforge
step
#completewith next
.goto Wetlands,9.490,59.694
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Shellei Brondir|r
.fly Ironforge >> Fly to Ironforge
.target Shellei Brondir
.zoneskip Ironforge
step
#label KitD
.goto Ironforge,50.826,5.613
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gerrig Bonegrip|r
.turnin 971 >> Turn in Knowledge in the Deeps
.target Gerrig Bonegrip
step
+|cRXP_WARN_You have completed the Blackfathom Deeps quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 15-30
<< Alliance
#name 04. The Stockade
#displayname 4. The Stockade
step
#completewith next
.zone Redridge Mountains >> Travel to Redridge Mountains
step
.goto Redridge Mountains,26.258,46.580
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Guard Berton|r
.accept 386 >> Accept What Comes Around...
.target Guard Berton
step
#completewith next
.goto Redridge Mountains,30.590,59.410
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ariena Stormfeather|r
.fly Duskwood >> Fly to Duskwood
.target Ariena Stormfeather
.zoneskip Duskwood
step
.goto Duskwood,71.938,47.778
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Councilman Millstipe|r
.accept 377 >> Accept Crime and Punishment
.target Councilman Millstipe
step
#completewith next
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Felicia Maline|r
.goto Duskwood,77.49,44.28
.fly Stormwind>> Fly to Stormwind
.target Felicia Maline
.zoneskip Stormwind City
step
.goto StormwindClassic,69.25,39.63,40,0
.goto StormwindClassic,71.28,41.37,40,0
.goto StormwindClassic,73.33,45.65,40,0
.goto StormwindClassic,72.44,47.70,40,0
.goto StormwindClassic,69.25,39.63,40,0
.goto StormwindClassic,71.28,41.37,40,0
.goto StormwindClassic,73.33,45.65,40,0
.goto StormwindClassic,72.44,47.70
.line StormwindClassic,69.25,39.63,71.28,41.37,73.33,45.65,72.44,47.70,73.33,45.65,71.28,41.37,69.25,39.63
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nikova Raskol|r
>>|cRXP_FRIENDLY_Nikova Raskol|r |cRXP_WARN_patrols in Old Town|r
.accept 388 >> Accept The Color of Blood
.unitscan Nikova Raskol
step
.goto StormwindClassic,42.435,59.236,10,0
.goto StormwindClassic,41.102,58.091
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Warden Thelwater|r
.accept 391 >> Accept The Stockade Riots
.accept 387 >> Accept Quell The Uprising
.target Warden Thelwater
.isQuestTurnedIn 389
step
.goto StormwindClassic,42.435,59.236,10,0
.goto StormwindClassic,41.102,58.091
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Warden Thelwater|r
.accept 387 >> Accept Quell The Uprising
.target Warden Thelwater
step
.goto StormwindClassic,39.834,54.360
+Find a group for The Stockades. Zone in once your group is ready
.zoneskip Stormwind City,1 
step
#label stock1
#sticky
>>Kill the |cRXP_ENEMY_Defias|r. Loot them for their |cRXP_LOOT_Bandanas|r
.complete 387,1 
.complete 387,2 
.complete 387,3 
.complete 388,1 
step
#label stock2
#sticky
>>Kill |cRXP_ENEMY_Targorr the Dread|r. Loot him for his |cRXP_LOOT_Head|r. |cRXP_ENEMY_Targorr|r has a random spawn location
>>Kill |cRXP_ENEMY_Dextren Ward|r on the west prison wing. Loot him for his |cRXP_LOOT_Hand|r
.complete -386,1 
.mob +Targorr the Dread
.complete -377,1 
.mob +Dextren Ward
step
>>Kill |cRXP_ENEMY_Bazil Thredd|r on the east prison wing. Loot him for his |cRXP_LOOT_Head|r
>>|cRXP_WARN_Ensure you have 3|r |T132905:0|t[Silk Cloth] |cRXP_WARN_for the follow up of this quest chain|r
.complete 391,1 
.collect 4306,3,2746,1 
.isOnQuest 391
.mob Bazil Thredd
step
#requires stock1
step
.goto StormwindClassic,42.435,59.236,10,0
.goto StormwindClassic,41.102,58.091
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Warden Thelwater|r
.turnin 387 >> Turn in Quell The Uprising
.turnin 391 >> Turn in The Stockade Riots
.accept 392 >> Accept The Curious Visitor
.target Warden Thelwater
.isQuestTurnedIn 389
step
.goto StormwindClassic,42.435,59.236,10,0
.goto StormwindClassic,41.102,58.091
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Warden Thelwater|r
.turnin 387 >> Turn in Quell The Uprising
.target Warden Thelwater
step
.goto StormwindClassic,49.194,30.283
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Baros Alexston|r
.turnin 392 >> Turn in The Curious Visitor
.accept 393 >> Accept Shadow of the Past
.target Baros Alexston
.isQuestTurnedIn 389
step
.goto StormwindClassic,69.25,39.63,40,0
.goto StormwindClassic,71.28,41.37,40,0
.goto StormwindClassic,73.33,45.65,40,0
.goto StormwindClassic,72.44,47.70,40,0
.goto StormwindClassic,69.25,39.63,40,0
.goto StormwindClassic,71.28,41.37,40,0
.goto StormwindClassic,73.33,45.65,40,0
.goto StormwindClassic,72.44,47.70
.line StormwindClassic,69.25,39.63,71.28,41.37,73.33,45.65,72.44,47.70,73.33,45.65,71.28,41.37,69.25,39.63
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nikova Raskol|r
>>|cRXP_FRIENDLY_Nikova Raskol|r |cRXP_WARN_patrols in Old Town|r
.turnin 388 >> Turn in The Color of Blood
.unitscan Nikova Raskol
step
#completewith next
.goto StormwindClassic,74.90,54.00,20,0
.goto StormwindClassic,78.43,60.15,20,0
.goto StormwindClassic,78.67,60.13,5 >> Enter the SI:7 Headquarters. Travel up stairs toward |cRXP_FRIENDLY_Master Mathias Shaw|r
.isQuestTurnedIn 389
step
.goto StormwindClassic,75.78,59.84
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Master Mathias Shaw|r
.turnin 393 >> Turn in Shadow of the Past
.accept 350 >> Accept Look to an Old Friend
.target Master Mathias Shaw
.isQuestTurnedIn 389
step
.goto StormwindClassic,61.166,64.051,8,0
.goto StormwindClassic,59.908,64.177
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Elling Trias|r up stairs
.turnin 350 >> Turn in Look to an Old Friend
.accept 2745 >> Accept Infiltrating the Castle
.target Elling Trias
.isQuestTurnedIn 389
step
#completewith next
.goto StormwindClassic,70.347,27.208,15,0
.goto StormwindClassic,72.005,21.542,20 >> Travel to the Stormwind Keep
.isQuestTurnedIn 389
step
.goto StormwindClassic,69.205,14.404
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tyrion|r
.turnin 2745 >> Turn in Infiltrating the Castle
.accept 2746 >> Accept Items of Some Consequence
.target Tyrion
.isQuestTurnedIn 389
step
#completewith next
.goto Elwynn Forest,32.384,49.866,50 >> Exit Stormwind. Travel to Clara's Farm House in Elwynn Forest
.isQuestTurnedIn 389
step
#ah
>>Loot |cRXP_LOOT_Clara's Fresh Apples|r on the table
>>|cRXP_WARN_If you still need|r |T132905:0|t[Silk Cloth] |cRXP_WARN_buy some from the Auction House|r
.complete 2746,2 
.goto Elwynn Forest,33.952,57.162
.complete 2746,1 
.isQuestTurnedIn 389
step
>>Loot |cRXP_LOOT_Clara's Fresh Apples|r on the table
.complete 2746,2 
.goto Elwynn Forest,33.952,57.162
.complete 2746,1 
.isQuestTurnedIn 389
step
#completewith next
.goto StormwindClassic,70.347,27.208,15,0
.goto StormwindClassic,72.005,21.542,20 >> Travel to the Stormwind Keep
.isQuestTurnedIn 389
step
.goto StormwindClassic,69.205,14.404
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tyrion|r
>>|cRXP_WARN_Ensure your party has all turned in Items of Some Consequence before you accept The Attack!|r
>>|cRXP_WARN_Automatic quest accept has been turned off for this step. Note you may not be able to accept the quest if someone else is in the process of doing it|r
.turnin 2746 >> Turn in Items of Some Consequence
.accept 434,1 >> Accept The Attack!
.timer 124,The Attack! RP
.target Tyrion
.isQuestTurnedIn 389
step 
.goto StormwindClassic,68.024,14.075
>>|cRXP_WARN_Wait in the center of the courtyard for |cRXP_ENEMY_Lord Gregor Lescovar|r and |cRXP_ENEMY_Marzon the Silent Blade|r to arrive. This takes roughly 2 minutes|r
>>Kill |cRXP_ENEMY_Lord Gregor Lescovar|r and |cRXP_ENEMY_Marzon the Silent Blade|r
.complete 434,1 
.complete 434,2 
.complete 434,3 
.mob Lord Gregor Lescovar
.mob Marzon the Silent Blade
.isQuestTurnedIn 389
step
.goto StormwindClassic,61.166,64.051,8,0
.goto StormwindClassic,59.908,64.177
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Elling Trias|r up stairs
.turnin 434 >> Turn in The Attack!
.accept 394 >> Accept The Head of the Beast
.target Elling Trias
.isQuestTurnedIn 389
step
#completewith next
.goto StormwindClassic,74.90,54.00,20,0
.goto StormwindClassic,78.43,60.15,20,0
.goto StormwindClassic,78.67,60.13,5 >> Enter the SI:7 Headquarters. Travel up stairs toward |cRXP_FRIENDLY_Master Mathias Shaw|r
.isQuestTurnedIn 389
step
.goto StormwindClassic,75.78,59.84
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Master Mathias Shaw|r
.turnin 394 >> Turn in The Head of the Beast
.accept 395 >> Accept Brotherhood's End
.target Master Mathias Shaw
.isQuestTurnedIn 389
step
.goto StormwindClassic,49.194,30.283
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Baros Alexston|r
.turnin 395 >> Turn in Brotherhood's End
.accept 396 >> Accept An Audience with the King
.target Baros Alexston
.isQuestTurnedIn 389
step
#completewith next
.goto StormwindClassic,70.347,27.208,20 >> Travel to the Stormwind Keep
.isQuestTurnedIn 389
step
.goto StormwindClassic,78.105,17.750
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lady Katrana Prestor|r
.turnin 396 >> Turn in An Audience with the King
.target Lady Katrana Prestor
.isQuestTurnedIn 389
step
#completewith next
.goto StormwindClassic,66.277,62.137
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Dungar Longdrink|r
.fly Redridge >> Fly to Redridge Mountains
.target Dungar Longdrink
.zoneskip Redridge Mountains
step
.goto Redridge Mountains,26.258,46.580
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Guard Berton|r
.turnin 386 >> Turn in What Comes Around...
.target Guard Berton
step
#completewith next
.goto Redridge Mountains,30.590,59.410
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ariena Stormfeather|r
.fly Duskwood >> Fly to Duskwood
.target Ariena Stormfeather
.zoneskip Duskwood
step
.goto Duskwood,71.938,47.778
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Councilman Millstipe|r
.turnin 377 >> Turn in Crime and Punishment
.target Councilman Millstipe
step
+|cRXP_WARN_You have completed The Stockade quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 15-30 << !classic
#subgroup 30-50 << classic
<< Alliance
#name 05. Gnomeregan
#displayname 5. Gnomeregan
step
#completewith GyrodrillmaticExcavationators
.zone Stormwind City >> Travel to Stormwind
step
.goto StormwindClassic,40.551,30.959
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Brother Sarno|r
.accept 2923 >> Accept Tinkmaster Overspark
.target Brother Sarno
step
#label GyrodrillmaticExcavationators
.goto StormwindClassic,55.511,12.502
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Shoni the Shilent|r
.accept 2928 >> Accept Gyrodrillmatic Excavationators
.target Shoni the Shilent
step
#completewith StartGnomer
.goto Dun Morogh,24.2,39.1,0
+Start Looking for a Gnomeregan group
.subzoneskip 133
.subzoneskip 721,2
step
#completewith next
.zone Ironforge >> Travel to Ironforge
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gnoarn|r, |cRXP_FRIENDLY_Tinkmaster Overspark|r, |cRXP_FRIENDLY_High Tinker Mekkatorque|r, |cRXP_FRIENDLY_Master Mechanic Castpipe|r and |cRXP_FRIENDLY_Klockmort Spannerspan|r
.accept 2927 >> Accept The Day After
.target +Gnoarn
.goto Ironforge,69.182,50.556
.turnin -2923 >> Turn in Tinkmaster Overspark
.accept 2922 >> Accept Save Techbot's Brain!
.target +Tinkmaster Overspark
.goto Ironforge,69.540,50.325
.accept 2929 >> Accept The Grand Betrayal
.target +High Tinker Mekkatorque
.goto Ironforge,68.743,48.969
.accept 2930 >> Accept Data Rescue
.target +Master Mechanic Castpipe
.goto Ironforge,69.823,48.101
.accept 2924 >> Accept Essential Artificials
.target +Klockmort Spannerspan
.goto Ironforge,67.925,46.101
step
#completewith next
.goto Dun Morogh,53.5,34.9
.zone Dun Morogh>>Exit Ironforge
step
.goto Dun Morogh,46.005,48.637,10,0
.goto Dun Morogh,45.887,49.377
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ozzie Togglevolt|r
.turnin 2927 >> Turn in The Day After
.accept 2926 >> Accept Gnogaine
.target Ozzie Togglevolt
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Innkeeper Belm|r inside
.target Innkeeper Belm
.goto Dun Morogh,47.377,52.523
.home >> Set your Hearthstone to Kharanos
step
#label StartGnomer
#completewith next
.goto Dun Morogh,24.35,39.78,0
.goto Dun Morogh,24.35,39.78,30,0
.goto 1415,43.42,53.81,45 >> Travel to Gnomeregan
step
.goto 1415,43.40,53.41,50,0
.goto 1415,43.13,53.36,50,0
.goto 1415,43.38,52.94,50,0
.goto 1415,43.40,53.41
.use 9283 >>|cRXP_WARN_Use the|r |T132788:0|t[Empty Leaden Collection Phial] |cRXP_WARN_on a |cRXP_ENEMY_Irradiated Invader|r or|r |cRXP_ENEMY_Irradiated Pillager|r
>>|cRXP_WARN_The |cRXP_ENEMY_Irradiated Invader|r or |cRXP_ENEMY_Irradiated Pillager|r must be ALIVE when you use it|r
>>|cRXP_WARN_This quest is completed while OUTSIDE of the dungeon|r
.complete 2926,1 
.mob Irradiated Invader
.mob Irradiated Pillager
.isOnQuest 2926
step
#completewith next
.goto Dun Morogh,46.005,48.637,40 >> Travel to |cRXP_FRIENDLY_Ozzie Togglevolt|r in Kharanos
>>|cRXP_WARN_You will get a follow up for when you go inside the dungeon|r
.isOnQuest 2926
step
.goto Dun Morogh,46.005,48.637,10,0
.goto Dun Morogh,45.887,49.377
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ozzie Togglevolt|r
.turnin 2926 >> Turn in Gnogaine
.target Ozzie Togglevolt
.isQuestComplete 2926
step
.goto Dun Morogh,45.887,49.377
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ozzie Togglevolt|r
.accept 2962 >> Accept The Only Cure is More Green Glow
.target Ozzie Togglevolt
.isQuestTurnedIn 2926
step
#completewith next
.goto Dun Morogh,24.35,39.78,0
.goto Dun Morogh,24.35,39.78,30,0
.goto 1415,43.42,53.81,45 >> Travel to Gnomeregan
.isOnQuest 2962
step
.goto 1415,43.37,53.11,70,0
.goto 1415,43.10,52.81
>>Kill |cRXP_ENEMY_Troggs|r and |cRXP_ENEMY_Gnomes|r. Loot them for a |T133215:0|t[|cRXP_LOOT_White Punch Card|r]
.collect 9279,1,2930,1,1 
>>Kill |cRXP_ENEMY_Techbot|r. Loot him for his |cRXP_LOOT_Memory Core|r
>>|cRXP_WARN_This quest is completed while OUTSIDE of the dungeon|r
.complete 2922,1 
.mob Techbot
.isOnQuest 2922
step
.goto 1415,43.40,53.41,50,0
.goto 1415,43.13,53.36,50,0
.goto 1415,43.38,52.94,50,0
.goto 1415,43.40,53.41
>>Kill |cRXP_ENEMY_Troggs|r and |cRXP_ENEMY_Gnomes|r. Loot them for a |T133215:0|t[|cRXP_LOOT_White Punch Card|r]
.collect 9279,1 
>>|cRXP_WARN_This quest is completed while OUTSIDE of the dungeon|r
.isOnQuest 2930
step
.goto 1415,43.364,52.892,-1
.goto 1415,43.411,52.898,-1
.goto 1415,43.402,52.672,-1
.goto 1415,43.430,52.675,-1
>>|cRXP_WARN_Use the|r |T133215:0|t[|cRXP_LOOT_White Punch Card|r] |cRXP_WARN_at the|r |cRXP_PICK_Matrix Punchograph 3005-A|r
>>|cRXP_WARN_This quest is completed while OUTSIDE of the dungeon|r
.collect 9280,1,2930,1 
.itemcount 9279,1 
.skipgossip
.isOnQuest 2930
step
.goto 1415,43.17,53.36,40,0
.goto 1415,42.78,53.81
.subzone 721,2 >> Enter the Gnomeregan instance portal
step
#completewith Thermaplugg
>>Kill all |cRXP_ENEMY_Gnomeregan Mobs|r. Loot them for their |cRXP_LOOT_Robo-mechanical Guts|r
.complete 2928,1 
.isOnQuest 2928
step
>>|cRXP_WARN_Use the|r |T133215:0|t[|cRXP_LOOT_Yellow Punch Card|r] |cRXP_WARN_at the|r |cRXP_PICK_Matrix Punchograph 3005-B|r
>>The console looking machine is located at the gnomish safe zone at the bottom floor, next to the big circular room where the slimes are located
.collect 9282,1,2930,1 
.itemcount 9280,1 
.skipgossip
.isOnQuest 2930
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kernobee|r
>>|cRXP_WARN_This will start an escort quest. |cRXP_FRIENDLY_Kernobee|r spawns randomly in The Dormitory, right outside of the gnomish safe zone|r
.accept 2904 >> Accept A Fine Mess
.unitscan Kernobee
step
>>Escort |cRXP_FRIENDLY_Kernobee|r back to the start of the dungeon
.complete 2904,1 
.isOnQuest 2904
step
.use 9364 >>|cRXP_WARN_Use the|r |T132788:0|t[Heavy Leaden Collection Phial] |cRXP_WARN_on a |cRXP_ENEMY_Irradiated Slime|r or|r |cRXP_ENEMY_Irradiated Horror|r
>>|cRXP_WARN_The |cRXP_ENEMY_Irradiated Slime|r or |cRXP_ENEMY_Irradiated Horror|r must be ALIVE when you use it|r
>>|cRXP_WARN_Note: You must turn this quest in within 2 hours of acquiring the|r |T136006:0|t[High Potency Radioactive Fallout]
.complete 2962,1 
.mob Irradiated Slime
.mob Irradiated Horror
.isOnQuest 2962
step
#completewith Thermaplugg
>>Open the |cRXP_PICK_Artificial Extrapolators|r. Loot them for |cRXP_LOOT_Essential Artificials|r
.complete 2924,1 
.isOnQuest 2924
step
>>|cRXP_WARN_Use the|r |T133215:0|t[|cRXP_LOOT_Blue Punch Card|r] |cRXP_WARN_at the|r |cRXP_PICK_Matrix Punchograph 3005-C|r
>>The Punchograph is located on the suspended platform right next to the |cRXP_ENEMY_Electrocutioner 6000|r
.collect 9281,1,2930,1 
.itemcount 9282,1 
.skipgossip
.isOnQuest 2930
.unitscan Electrocutioner 6000
step
>>|cRXP_WARN_Use the|r |T133215:0|t[|cRXP_LOOT_Red Punch Card|r] |cRXP_WARN_at the|r |cRXP_PICK_Matrix Punchograph 3005-D|r
.complete 2930,1 
.itemcount 9281,1 
.skipgossip
.isOnQuest 2930
step
#label Thermaplugg
>>Kill |cRXP_ENEMY_Mekgineer Thermaplugg|r
.complete 2929,1 
.isOnQuest 2929
step
#completewith Finished
>>Open the |cRXP_PICK_Artificial Extrapolators|r. Loot them for |cRXP_LOOT_Essential Artificials|r
>>If you still haven't finished this quest, go back to places where you looted them before, since they respawn after a few minutes
.complete 2924,1 
.isOnQuest 2924
step
#completewith Finished
>>Kill all |cRXP_ENEMY_Gnomeregan Mobs|r. Loot them for their |cRXP_LOOT_Robo-mechanical Guts|r
.complete 2928,1 
.isOnQuest 2928
step
>>|cRXP_WARN_Use the|r |T135230:0|t[|cRXP_LOOT_Grime-Encrusted Ring|r] |cRXP_WARN_to start the quest|r
.accept 2945 >> Accept Grime-Encrusted Ring
.collect 9326,1,2945 
.itemcount 9326,1
.use 9326
step
>>|cRXP_WARN_Take the|r |T135230:0|t[|cRXP_LOOT_Grime-Encrusted Ring|r] |cRXP_WARN_to |cRXP_PICK_The Sparklematic 5200|r in The Clean Zone|r
*You will have to back track to The Clean Zone near the instance entrance, make sure your teamates are there to help you on your trip back
.turnin 2945 >> Turn in Grime-Encrusted Ring
.itemcount 9326,1 
step
>>Click the |cRXP_PICK_The Sparklematic 5200|r one more time
.accept 2947 >> Accept Return of the Ring
.isQuestTurnedIn 2945
step
#completewith next
.hs >> Hearth to Kharanos
.zoneskip Dun Morogh
.zoneskip Ironforge
step
.goto Dun Morogh,46.005,48.637,10,0
.goto Dun Morogh,45.887,49.377
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ozzie Togglevolt|r
.turnin 2962 >> Turn in The Only Cure is More Green Glow
.target Ozzie Togglevolt
.isQuestComplete 2962
step
#completewith next
.goto Dun Morogh,47.58,41.58,40,0
.goto Dun Morogh,50.19,40.79,20,0
.goto Ironforge,14.90,87.10,40,0
.zone Ironforge >> Travel to Ironforge
step
.goto Ironforge,36.0,4.0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Talvash del Kissel|r
.turnin 2947 >> Turn in Return of the Ring
.accept 2948 >> Accept Gnome Improvement
.target Talvash del Kissel
.isOnQuest 2947
step
.goto Ironforge,36.0,4.0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Talvash del Kissel|r
>>|cRXP_WARN_If you are able to obtain a|r |T133215:0|t[Silver Bar] |cRXP_WARN_and a|r |T134105:0|t[Moss Agate] |cRXP_WARN_finish this quest. If not, abandon it|r
.collect 2842,1,2948,1 
.collect 1206,1 
.turnin 2948,2948,1 >> Turn in Gnome Improvement
.target Talvash del Kissel
.isOnQuest 2948
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tinkmaster Overspark|r, |cRXP_FRIENDLY_High Tinker Mekkatorque|r, |cRXP_FRIENDLY_Master Mechanic Castpipe|r and |cRXP_FRIENDLY_Klockmort Spannerspan|r
.turnin -2922,1 >> Turn in Save Techbot's Brain!
.target +Tinkmaster Overspark
.goto Ironforge,69.540,50.325
.turnin -2929,1 >> Turn in The Grand Betrayal
.target +High Tinker Mekkatorque
.goto Ironforge,68.743,48.969
.turnin -2930,1 >> Turn in Data Rescue
.target +Master Mechanic Castpipe
.goto Ironforge,69.823,48.101
.turnin -2924,1 >> Turn in Essential Artificials
.target +Klockmort Spannerspan
.goto Ironforge,67.925,46.101
step
#completewith next
.goto Ironforge,76.61,51.28,10,0
.zone Stormwind City >> Take the tram to Stormwind
step
.goto StormwindClassic,55.511,12.502
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Shoni the Shilent|r
.turnin 2928 >> Turn in Gyrodrillmatic Excavationators
.target Shoni the Shilent
step
#completewith next
.goto StormwindClassic,66.277,62.137
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Dungar Longdrink|r
.fly Booty Bay>> Fly to Booty Bay
.target Dungar Longdrink
step
.goto Stranglethorn Vale,27.600,77.481
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Scooty|r
.turnin 2904 >> Turn in A Fine Mess
.isOnQuest 2904
.target Scooty
step
+|cRXP_WARN_You have completed the Gnomeregan quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 15-30 << !classic
#subgroup 30-50 << classic
<< Alliance
#name 06a. Razorfen Kraul
#displayname 6. Razorfen Kraul
step
#completewith next
.subzone 392 >> Travel to Ratchet in The Barrens
step
.goto The Barrens,62.370,37.615
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mebok Mizzyrix|r
.accept 1221 >> Accept Blueleaf Tubers
.target Mebok Mizzyrix
step
>>Loot the |cRXP_LOOT_Snufflenose Command Stick|r, |cRXP_LOOT_Snufflenose Owner's Manual|r and |cRXP_LOOT_Crate With Holes|r next to |cRXP_FRIENDLY_Mebok|r
.collect 6684,1,1221,1 
.goto The Barrens,62.340,37.607
.collect 5897,1,1221,1 
.goto The Barrens,62.332,37.623
.collect 5880,1,1221,1 
.goto The Barrens,62.323,37.620
step
#completewith CroneKraul
.zone Thousand Needles >> Travel to Thousand Needles
step
.goto Thousand Needles,30.725,24.346
>>Loot |T133741:0|t[|cRXP_LOOT_Henrig Lonebrow's Journal|r] on the ground
.use 5791 >>|cRXP_WARN_Use |T133741:0|t[|cRXP_LOOT_Henrig Lonebrow's Journal|r] to start the quest|r
.accept 1100 >> Accept Lonebrow's Journal
step
#label CroneKraul
.goto Feralas,89.634,46.563
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Falfindel Waywarder|r
.turnin -1100 >> Turn in Lonebrow's Journal
.accept 1101 >> Accept The Crone of the Kraul
.target Falfindel Waywarder
step
#completewith next
.goto Thousand Needles,10.88,33.24,0
.goto Thousand Needles,11.01,38.31,0
.goto Thousand Needles,13.27,38.47,0
.goto Thousand Needles,17.46,41.62,0
.zone The Barrens >> Grind |cRXP_ENEMY_Highperch Wyverns|r, |cRXP_ENEMY_Highperch Consorts|r and |cRXP_ENEMY_Highperch Patriarchs|r while looking for a group for Razorfen Kraul
.mob Highperch Patriarch
.mob Highperch Wyvern
.mob Highperch Consort
step
.goto The Barrens,43.46,90.18,0
.goto The Barrens,43.46,90.18,40,0
.goto 1414,50.877,70.339
.subzone 491,2 >> Enter Razorfen Kraul
step
>>Kill |cRXP_ENEMY_Charlga Razorflank|r. Loot her for |cRXP_LOOT_Razorflank's Heart|r
.complete 1101,1 
.isOnQuest 1101
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Heralath Fallowbrook|r and |cRXP_FRIENDLY_Willix the Importer|r
.accept 1142 >> Accept Mortality Wanes
.target +Heralath Fallowbrook
.accept 1144 >> Accept Willix the Importer
.target +Willix the Importer
step
#completewith next
>>Kill all |cRXP_ENEMY_Monsters|r inside of RFK. Loot them for |cRXP_LOOT_Treshala's Pendant|r
.complete 1142,1 
.isOnQuest 1142
step
>>Escort |cRXP_FRIENDLY_Willix the Importer|r through Razorfen Krual
>>|cRXP_WARN_Ensure you stay close to |cRXP_FRIENDLY_Willix|r otherwise the quest may not complete!|r
.complete 1144,1 
.isOnQuest 1144
step
#completewith next
>>Kill all |cRXP_ENEMY_Monsters|r inside of RFK. Loot them for |cRXP_LOOT_Treshala's Pendant|r
.complete 1142,1 
.isOnQuest 1142
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Willix the Importer|r
.turnin 1144 >> Turn in Willix the Importer
.target Willix the Importer
.isQuestComplete 1144
step
>>Kill all |cRXP_ENEMY_Monsters|r inside of RFK. Loot them for |cRXP_LOOT_Treshala's Pendant|r
.complete 1142,1 
.isOnQuest 1142
step
#completewith next
.zone Feralas >> Travel to Feralas
step
.goto Feralas,89.634,46.563
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Falfindel Waywarder|r
.turnin 1101 >> Turn in The Crone of the Kraul
.target Falfindel Waywarder
.isQuestComplete 1101
step
.goto The Barrens,62.370,37.615
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mebok Mizzyrix|r
.turnin 1221 >> Turn in Blueleaf Tubers
.target Mebok Mizzyrix
.isQuestComplete 1221
step
#completewith next
.zone Darnassus >> Travel to Darnassus
>>|cRXP_WARN_Buy a portal from a Mage if possible|r << !Mage
step
.goto Darnassus,62.21,57.23,10,0
.goto Darnassus,66.02,59.39,10,0
.goto Darnassus,69.529,67.759
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Treshala Fallowbrook|r up stairs
.turnin 1142 >> Turn in Mortality Wanes
.target Treshala Fallowbrook
.isQuestComplete 1142
step
+|cRXP_WARN_You have completed the Razorfen Kraul quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 30-50
<< Alliance
#name 07. Scarlet Monastery
#displayname 7. Scarlet Monastery
step
#completewith next
.zone Desolace >> Travel to Desolace
step
.goto Desolace,66.519,7.907
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Brother Anton|r
.accept 261 >> Accept Down the Scarlet Path
.target Brother Anton
step
.goto Desolace,64.30,81.96,70,0
.goto Desolace,64.00,91.70,70,0
.goto Desolace,59.91,89.42,70,0
.goto Desolace,64.00,91.70
>>Kill |cRXP_ENEMY_Undead Ravagers|r
.complete 261,1 
.mob Undead Ravager
.isOnQuest 261
step
.goto Desolace,66.519,7.907
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Brother Anton|r
.turnin 261 >> Turn in Down the Scarlet Path
.accept 1052 >> Accept Down the Scarlet Path
.target Brother Anton
step
#completewith next
.zone Ironforge >> Travel to Ironforge
step
.goto Ironforge,74.980,12.486
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Librarian Mae Paledust|r
.accept 1050 >> Accept Mythology of the Titans
.target Librarian Mae Paledust
step
#completewith next
.zone Hillsbrad Foothills >> Travel to Southshore
step
.goto Hillsbrad Foothills,51.468,58.354
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Raleigh the Devout|r up stairs
.turnin 1052 >> Turn in Down the Scarlet Path
.accept 1053 >> Accept In the Name of the Light
.target Raleigh the Devout
step
#completewith next
.goto Alterac Mountains,58.31,67.92,0
.goto Alterac Mountains,48.0,82.0,0
.zone Silverpine Forest >> Grind the |cRXP_ENEMY_Syndicate|r in Alterac Mountains while looking for a group for Scarlet Monastery
.zoneskip Tirisfal Glades
.mob Syndicate Footpad
.mob Syndicate Thief
step
.goto Silverpine Forest,69.95,7.05,150,0
.goto Tirisfal Glades,56.15,64.62,100,0
.goto 1415,47.500,19.652,25,0
.goto 1415,47.792,19.611
.subzone 796,2 >> Enter Scarlet Monastery. Start with Library so you can loot the [|cRXP_FRIENDLY_The Scarlet Key|r] at the end
step
#completewith Bosses
>>Loot the |cRXP_LOOT_Mythology of the Titans|r
>>|cRXP_WARN_This can spawn randomly on the ground or in bookshelves throughout the Library wing|r
.complete 1050,1 
.isOnQuest 1050
step
#completewith Mythology
>>Open |cRXP_PICK_Doan's Strongbox|r. Loot it for [|cRXP_FRIENDLY_The Scarlet Key|r]
.collect 7146,1 
step
#label Bosses
>>Kill |cRXP_ENEMY_Houndmaster Loksey|r, |cRXP_ENEMY_Herod|r, |cRXP_ENEMY_High Inquisitor Whitemane|r and |cRXP_ENEMY_Scarlet Commander Mograine|r
>>|cRXP_ENEMY_Houndmaster Loksey|r |cRXP_WARN_is located in the Library|r
>>|cRXP_ENEMY_Herod|r |cRXP_WARN_is located in the Armory|r
>>|cRXP_ENEMY_High Inquisitor Whitemane|r |cRXP_WARN_and |cRXP_ENEMY_Scarlet Commander Mograine|r are located in the Cathedral|r
.complete 1053,4 
.complete 1053,3 
.complete 1053,1 
.complete 1053,2 
.isOnQuest 1053
step
#label Mythology
>>Loot the |cRXP_LOOT_Mythology of the Titans|r
>>|cRXP_WARN_This can spawn randomly on the ground or in bookshelves throughout the Library wing|r
.complete 1050,1 
.isOnQuest 1050
step
#completewith next
.hs >> Hearth to Southshore
>>|cRXP_BUY_Buy food/water if needed|r << !Warrior !Rogue
>>|cRXP_BUY_Buy food if needed|r << Warrior/Rogue
step
.goto Hillsbrad Foothills,51.468,58.354
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Raleigh the Devout|r up stairs
.turnin 1053 >> Turn in In the Name of the Light
.target Raleigh the Devout
.isQuestComplete 1053
step
#completewith next
.goto Hillsbrad Foothills,49.338,52.272
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Darla Harris|r
.fly Ironforge>> Fly to Ironforge
.target Darla Harris
.zoneskip Ironforge
step
.goto Ironforge,74.980,12.486
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Librarian Mae Paledust|r
.turnin 1050 >> Turn in Mythology of the Titans
.target Librarian Mae Paledust
.isQuestComplete 1050
step
+|cRXP_WARN_You have completed the Scarlet Monastery quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 30-50
<< Alliance
#name 08. Razorfen Downs
#displayname 8. Razorfen Downs
step
#completewith HostEvil
.subzone 722 >> You will now run Razorfen Downs. Start looking for a group for it while you travel to the dungeon
step
#completewith next
.zone Stormwind City >> Travel to Stormwind City
step
.goto StormwindClassic,39.592,27.199
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archbishop Benedictus|r
.accept 3636 >> Accept Bring the Light
.target Archbishop Benedictus
step
#completewith next
.zone The Barrens >> Travel to The Barrens
step
#label HostEvil
.goto The Barrens,49.012,94.938
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Myriam Moonsinger|r
.accept 6626 >> Accept A Host of Evil
.target Myriam Moonsinger
step
>>Kill |cRXP_ENEMY_Razorfen Battleguards|r, |cRXP_ENEMY_Razorfen Thornweavers|r and |cRXP_ENEMY_Death's Head Cultists|r
>>|cRXP_WARN_This quest is completed outside of the Instance|r
.goto The Barrens,48.23,92.31,70,0
.goto The Barrens,48.15,90.57,70,0
.goto The Barrens,47.86,88.75,70,0
.goto The Barrens,46.46,90.19,70,0
.goto The Barrens,46.94,92.19,70,0
.goto The Barrens,48.23,92.31,70,0
.goto The Barrens,48.15,90.57,70,0
.goto The Barrens,47.86,88.75,70,0
.goto The Barrens,46.46,90.19,70,0
.goto The Barrens,46.94,92.19,70,0
.goto The Barrens,48.23,92.31
.complete 6626,1 
.mob +Razorfen Battleguard
.complete 6626,2 
.mob +Razorfen Thornweaver
.complete 6626,3 
.mob +Death's Head Cultist
.isOnQuest 6626
step
.goto The Barrens,49.012,94.938
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Myriam Moonsinger|r
.turnin 6626 >> Turn in A Host of Evil
.target Myriam Moonsinger
.isQuestComplete 6626
step
.goto The Barrens,49.255,93.077,0
.goto The Barrens,49.255,93.077,30,0
.goto 1414,53.26,71.18
.subzone 722,2 >> Enter Razorfen Downs
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Belnistrasz|r
>>|cRXP_WARN_Take the left path and stick left the entire way until you reach The Murder Pens to get to|r |cRXP_FRIENDLY_Belnistrasz|r
>>|cRXP_WARN_Do not accept Extinguishing the Idol until the rest of your party is ready as this begins the escort. Auto accept has been turned off for this step|r
.accept 3523 >> Accept Scourge of the Downs
.turnin 3523 >> Turn in Scourge of the Downs
.accept 3525,1 >> Accept Extinguishing the Idol
.target Belnistrasz
step
>>Follow and protect |cRXP_FRIENDLY_Belnistrasz|r during his ritual
.complete 3525,1 
.target Belnistrasz
.isOnQuest 3525
step
>>Click |cRXP_PICK_Belnistrasz's Brazier|r
.turnin 3525 >> Turn in Extinguishing the Idol
.isQuestComplete 3525
step
>>Kill |cRXP_ENEMY_Amnennar the Coldbringer|r
.complete 3636,1 
.isOnQuest 3636
step
#completewith next
.zone Stormwind City >> Travel to Stormwind City
step
.goto StormwindClassic,39.592,27.199
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archbishop Benedictus|r
.turnin 3636 >> Turn in Bring the Light
.target Archbishop Benedictus
.isQuestComplete 3636
step
+|cRXP_WARN_You have completed the Razorfen Downs quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 30-50
<< Alliance
#name 09. Uldaman
#displayname 9. Uldaman
step
#completewith IFQuests
.zone Ironforge >> Travel to Ironforge
step
.goto Ironforge,74.179,9.371
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Krom Stoutarm|r
.accept 1360 >> Accept Reclaimed Treasures
.target Krom Stoutarm
step
#label IFQuests
.goto Ironforge,74.645,11.742
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Prospector Stormpike|r
.accept 2398 >> Accept The Lost Dwarves
.accept 707 >> Accept Ironband Wants You!
.target Prospector Stormpike
step
#completewith LochQuests
.goto Ironforge,55.501,47.742
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gryth Thurden|r
.fly Loch Modan>> Fly to Loch Modan
.target Gryth Thurden
.zoneskip Loch Modan
.zoneskip Badlands
step
.goto Loch Modan,36.50,48.35,15,0
.goto Loch Modan,37.067,49.379
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ghak Healtouch|r
.accept 17 >> Accept Uldaman Reagent Run
.target Ghak Healtouch
.isQuestTurnedIn 2500
step
#optional
.goto Loch Modan,36.50,48.35,15,0
.goto Loch Modan,37.067,49.379
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ghak Healtouch|r
>>|cRXP_WARN_This quest is a prerequisite that requires killing mobs in Badlands for a follow up quest in Uldaman. If you wish to not complete it, skip this step|r
.accept 2500 >> Accept Badlands Reagent Run
.target Ghak Healtouch
step
#completewith next
.goto Loch Modan,65.93,65.62,80 >> Travel to Ironband's Excavation Site
step
.goto Loch Modan,65.934,65.622
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Prospector Ironband|r
.turnin 707 >> Turn in Ironband Wants You!
.target Prospector Ironband
.accept 738 >> Accept Find Agmond
step
#completewith EnterBandlands
.goto Loch Modan,47.04,79.27,0
.goto Loch Modan,46.71,76.90,65,0
.goto Badlands,49.23,7.80
.zone Badlands >> Travel to Badlands
step
.goto Badlands,53.027,33.944
>>Click the |cRXP_PICK_Crumpled Map|r on the ground
.accept 720 >> Accept A Sign of Hope
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Prospector Ryedol|r
.turnin 720 >> Turn in A Sign of Hope
.accept 721 >> Accept A Sign of Hope
.goto Badlands,53.421,43.393
.target Prospector Ryedol
step
#label Agmond
.goto Badlands,50.892,62.402
>>Click the |cRXP_PICK_Battered Dwarven Skeleton|r
.turnin 738 >> Turn in Find Agmond
.accept 739 >> Accept Murdaloc
step
>>Kill |cRXP_ENEMY_Stonevault Bonesnappers|r and |cRXP_ENEMY_Murdaloc|r
.complete 739,2 
.mob +Stonevault Bonesnapper
.goto Badlands,53.0,72.2,40,0
.goto Badlands,47.2,70.6,40,0
.goto Badlands,52.4,66.2,40,0
.goto Badlands,50.36,69.12
.complete 739,1 
.mob +Murdaloc
.goto Badlands,49.58,66.66
step
.goto Badlands,51.386,76.874
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Theldurin the Lost|r
.accept 709 >> Accept Solution to Doom
.target Theldurin the Lost
step
.goto Badlands,42.388,52.927
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Rigglefuzz|r
>>|cRXP_WARN_Skip this quest if you are level 44 or above. It has a very low drop rate and diminished XP|r
.accept 2418 >> Accept Power Stones
.target Rigglefuzz
step
#optional
.isOnQuest 2500
>>Kill |cRXP_ENEMY_Buzzards|r. Loot them for their |cRXP_LOOT_Gizzards|r
>>Kill |cRXP_ENEMY_Coyotes|r. Loot them for their |cRXP_LOOT_Fangs|r
>>Kill |cRXP_ENEMY_Lesser Rock Elementals|r. Loot them for their |cRXP_LOOT_Rock Elemental Shards|r
>>|cRXP_WARN_This quest is a prerequisite for a follow up quest in Uldaman. If you wish to not complete it, skip this step|r
.complete 2500,1 
.mob +Starving Buzzard
.mob +Buzzard
.mob +Giant Buzzard
.goto Badlands,49.8,53.0,80,0
.goto Badlands,56.2,67.2,80,0
.goto Badlands,50.6,74.8,80,0
.goto Badlands,60.0,70.6,80,0
.goto Badlands,60.8,53.4,80,0
.goto Badlands,55.8,60.2
.complete 2500,2 
.mob +Crag Coyote
.mob +Feral Crag Coyote
.mob +Rabid Crag Coyote
.mob +Elder Crag Coyote
.goto Badlands,49.0,32.4,80,0
.goto Badlands,49.2,48.8,80,0
.goto Badlands,57.8,47.7,80,0
.goto Badlands,56.6,73.8,80,0
.goto Badlands,58.8,54.0
.complete 2500,3 
.goto Badlands,21.2,45.8,60,0
.goto Badlands,18.0,42.8,60,0
.goto Badlands,13.8,38.6,60,0
.goto Badlands,21.2,45.8,60,0
.goto Badlands,18.0,42.8
.mob +Lesser Rock Elemental
step
#optional
#completewith Murdaloc
.zone Loch Modan >> Return to Loch Modan
step
#optional
.isQuestComplete 2500
.goto Loch Modan,36.50,48.35,15,0
.goto Loch Modan,37.067,49.379
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ghak Healtouch|r
.turnin 2500 >> Turn in Badlands Reagent Run
.accept 17 >> Accept Uldaman Reagent Run
.target Ghak Healtouch
.isQuestComplete 2500
step
#optional
.goto Loch Modan,36.50,48.35,15,0
.goto Loch Modan,37.067,49.379
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ghak Healtouch|r
.accept 17 >> Accept Uldaman Reagent Run
.target Ghak Healtouch
.isQuestTurnedIn 2500
step
#label Murdaloc
.goto Loch Modan,65.934,65.622
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Prospector Ironband|r
.turnin 739 >> Turn in Murdaloc
.accept 704 >> Accept Agmond's Fate
.target Prospector Ironband
step
.goto Badlands,4.0,80.6
.goto Badlands,15.4,88.6
.goto Badlands,11.0,88.0
.goto Badlands,44.70,12.09
.zone 1415 >> Grind |cRXP_ENEMY_Ogres|r and |cRXP_ENEMY_Greater Rock Elementals|r while looking for a group for Uldaman
>>|cRXP_WARN_Once you have found a group, skip this step|r
step
#completewith HammertoeGrez
.goto 1415,54.46,57.78
.zone 1415 >> Travel to Uldaman
step
#completewith HammertoeGrez
>>Loot the |cRXP_LOOT_Carved Stone Urns|r on the ground
>>|cRXP_WARN_This can be only be completed OUTSIDE of Uldaman|r
.complete 704,1 
.isOnQuest 704
step
#completewith HammertoeGrez
>>Loot the |cRXP_LOOT_Magenta Fungus Caps|r on the ground
>>|cRXP_WARN_This can be completed INSIDE and OUTSIDE of Uldaman|r
.complete 17,1 
.isOnQuest 17
step
#completewith UldaEnd
.isOnQuest 2418
>>Kill |cRXP_ENEMY_Dwarves|r. Loot them for their |cRXP_LOOT_Power Stones|r
>>|cRXP_WARN_This can be completed INSIDE and OUTSIDE of Uldaman|r
.complete 2418,1 
.complete 2418,2 
step
.goto 1415,54.040,57.665
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hammertoe Grez|r
.turnin 721 >> Turn in A Sign of Hope
.accept 722 >> Accept Amulet of Secrets
.target Hammertoe Grez
step
.goto 1415,54.12,58.05,30,0
.goto 1415,54.09,58.21
>>Kill |cRXP_ENEMY_Magregan Deepshadow|r. Loot him for |cRXP_LOOT_Hammertoe's Amulet|r
>>|cRXP_WARN_This is completed OUTSIDE of Uldaman|r
.complete 722,1 
.mob Magregan Deepshadow
.isOnQuest 722
step
.goto 1415,54.140,58.246
>>Open the |cRXP_PICK_Ancient Chest|r. Loot it for the |cRXP_LOOT_Tablet of Ryun'eh|r
>>|cRXP_WARN_This is completed OUTSIDE of Uldaman|r
.complete 709,1 
.isOnQuest 709
step
.goto 1415,53.874,58.577
>>Loot |cRXP_LOOT_Krom Stoutarm's Treasure|r on the ground
>>|cRXP_WARN_This is completed OUTSIDE of Uldaman|r
.complete 1360,1 
.isOnQuest 1360
step
#label HammertoeGrez
.goto 1415,54.040,57.665
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hammertoe Grez|r
.turnin 722 >> Turn in Amulet of Secrets
.accept 723 >> Accept Prospect of Faith
.target Hammertoe Grez
.isQuestTurnedIn 721
step
.goto 1415,53.85,57.81,55,0
.goto 1415,53.63,58.01,55,0
.goto 1415,54.09,58.03,55,0
.goto 1415,53.85,57.81
>>Loot the |cRXP_LOOT_Carved Stone Urns|r and |cRXP_LOOT_Magenta Fungus Caps|r on the ground
>>|cRXP_WARN_Prioritize the |cRXP_LOOT_Carved Stone Urns|r. This can only be completed OUTSIDE of Uldaman. You can finish the |cRXP_LOOT_Magenta Fungus Caps|r once inside|r
.complete 704,1 
.complete 17,1 
.disablecheckbox
.isOnQuest 704
.isOnQuest 17
step
.goto 1415,53.85,57.81,55,0
.goto 1415,53.63,58.01,55,0
.goto 1415,54.09,58.03,55,0
.goto 1415,53.85,57.81
>>Loot the |cRXP_LOOT_Carved Stone Urns|r on the ground
>>|cRXP_WARN_This can be only be completed OUTSIDE of Uldaman|r
.complete 704,1 
.isOnQuest 704
step
.goto 1415,53.850,57.641
.subzone 1337,2 >> Zone into Uldaman
step
#completewith HiddenChamber
>>Loot the |cRXP_LOOT_Magenta Fungus Caps|r on the ground
.complete 17,1 
.isOnQuest 17
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Baelog|r
.turnin 2398 >> Turn in The Lost Dwarves
.accept 2240 >> Accept The Hidden Chamber
.target Baelog
.isOnQuest 2398
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Baelog|r
.accept 2240 >> Accept The Hidden Chamber
.target Baelog
step
#completewith next
>>Open |cRXP_PICK_Baelog's Chest|r. Loot it for the |T133276:0|t[|cRXP_LOOT_Gni'kiv Medallion|r]
>>Kill |cRXP_ENEMY_Revelosh|r. Loot him for |T135225:0|t[|cRXP_LOOT_The Shaft of Tsol|r]
>>|cRXP_WARN_Note other party members can loot these items, and then combine them to create the|r |T135138:0|t[Staff of Prehistoria]|cRXP_WARN_. Only one person in the group needs to do this|r
.collect 7740,1,2240,1 
.collect 7741,1,2240,1 
.use 7740 
.use 7741 
.mob Revelosh
.isOnQuest 2240
step
#label HiddenChamber
>>|cRXP_WARN_Use the|r |T133276:0|t[|cRXP_LOOT_Gni'kiv Medallion|r] |cRXP_WARN_and|r |T135225:0|t[|cRXP_LOOT_The Shaft of Tsol|r] |cRXP_WARN_to combine them into the|r |T135138:0|t[Staff of Prehistoria]
>>|cRXP_WARN_Use the|r |T135138:0|t[Staff of Prehistoria] |cRXP_WARN_on the |cRXP_PICK_Keystone|r to summon|r |cRXP_ENEMY_Ironaya|r
>>Kill |cRXP_ENEMY_Ironaya|r. |cRXP_WARN_Run into the Hidden Chamber she came from after|r
.use 7740 
.use 7741 
.use 7733 
.complete 2240,1 
.isOnQuest 2240
step
>>Loot the |cRXP_LOOT_Magenta Fungus Caps|r on the ground
.complete 17,1 
.isOnQuest 17
step
>>Kill |cRXP_ENEMY_Archaedas|r
>>Click |cRXP_PICK_The Discs of Norgannon|r
.accept 2278 >> Accept The Platinum Discs
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lore Keeper of Norgannon|r
.complete 2278,1 
.skipgossip
.target Lore Keeper of Norgannon
step
#label UldaEnd
>>Click |cRXP_PICK_The Discs of Norgannon|r
.turnin 2278 >> Turn in The Platinum Discs
.accept 2279 >> Accept The Platinum Discs
step
+Zone out of Uldaman together as a group to turn in quests in Badlands. The closest exit is the Uldaman backdoor
.zoneskip Badlands
step
.goto Badlands,51.386,76.874
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Theldurin the Lost|r
.turnin 709 >> Turn in Solution to Doom
.target Theldurin the Lost
.isQuestComplete 709
step
.isQuestComplete 2418
.goto Badlands,42.388,52.927
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Rigglefuzz|r
>>|cRXP_WARN_Skip this quest if you are level 44 or above. It has a very low drop rate and diminished XP|r
.turnin 2418 >> Turn in Power Stones
.target Rigglefuzz
step
#optional
.abandon 2418 >> Abandon Power Stones if you did not complete it or if you don't plan on running Uldaman again
step
#label HammertoeGrez
.goto Badlands,53.421,43.393
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Prospector Ryedol|r
.turnin 723 >> Turn in Prospect of Faith
.accept 724 >> Accept Prospect of Faith
.target Prospector Ryedol
.isQuestTurnedIn 721
step
#completewith UldaLoch
.goto Badlands,49.52,9.83,0
.goto Loch Modan,46.78,78.09
.zone Loch Modan >> Travel to Loch Modan
step
.goto Loch Modan,65.93,65.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Prospector Ironband|r
.turnin 704 >> Turn in Agmond's Fate
.target Prospector Ironband
.isQuestComplete 704
step
.goto Loch Modan,36.50,48.35,15,0
.goto Loch Modan,37.067,49.379
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ghak Healtouch|r
.turnin 17 >> Turn in Uldaman Reagent Run
.target Ghak Healtouch
.isQuestComplete 17
step
#label UldaLoch
.goto Loch Modan,33.938,50.954
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thorgrum Borrelson|r
.fly Ironforge >> Fly to Ironforge
.target Thorgrum Borrelson
step
.goto Ironforge,69.930,18.548
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_High Explorer Magellas|r
.turnin 2279 >> Turn in The Platinum Discs
.accept 2439 >> Accept The Platinum Discs
.target High Explorer Magellas
.isQuestTurnedIn 2278
step
.goto Ironforge,74.645,11.742
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Prospector Stormpike|r
.turnin 2240 >> Turn in The Hidden Chamber
.target Prospector Stormpike
.isQuestComplete 2240
step
.goto Ironforge,74.179,9.371
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Krom Stoutarm|r
.turnin 1360 >> Turn in Reclaimed Treasures
.target Krom Stoutarm
.isQuestComplete 1360
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Historian Karnik|r and |cRXP_FRIENDLY_Advisor Belgrum|r
.turnin 724 >> Turn in Prospect of Faith
.accept 725 >> Accept Passing Word of a Threat
.target +Historian Karnik
.goto Ironforge,77.539,11.834
.turnin 725 >> Turn in Passing Word of a Threat
.accept 726 >> Accept Passing Word of a Threat
.target +Advisor Belgrum
.goto Ironforge,77.343,9.714
.turnin 726 >> Turn in Passing Word of a Threat
.target +Historian Karnik
.goto Ironforge,77.539,11.834
.isQuestTurnedIn 721
step
.goto Ironforge,33.874,59.136
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Dinita Stonemantle|r
.turnin 2439 >> Turn in The Platinum Discs
.target Dinita Stonemantle
.isQuestTurnedIn 2278
step
>>|cRXP_WARN_Use the |T133289:0|t[|cRXP_LOOT_Shattered Necklace|r] to start the quest|r
.accept 2198 >> Accept The Shattered Necklace
.use 7666 
.itemcount 7666,1 
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Talvash del Kissel|r
.goto Ironforge,36.377,3.614
.turnin 2198 >> Turn in The Shattered Necklace
.target Talvash del Kissel
.isOnQuest 2198
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Talvash del Kissel|r
.goto Ironforge,36.377,3.614
.accept 2199 >> Accept Lore for a Price
.target Talvash del Kissel
.isQuestTurnedIn 2198
step
.goto Ironforge,36.377,3.614
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Talvash del Kissel|r
>>Bring 5 |T133215:0|t[Silver Bars] to |cRXP_FRIENDLY_Talvash del Kissel|r
>>|cRXP_WARN_If you are unable to acquire them, abandon this quest|r
.complete 2199,1 
.turnin 2199 >> Turn in Lore for a Price
.target Talvash del Kissel
.isOnQuest 2199
step
+|cRXP_WARN_You have completed the Uldaman quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 30-50
<< Alliance
#name 10. Zul'Farrak
step
#completewith next
.zone The Hinterlands >> Travel to The Hinterlands
step
.goto The Hinterlands,9.752,44.473
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gryphon Master Talonaxe|r
.accept 2988 >> Accept Witherbark Cages
.target Gryphon Master Talonaxe
step
.goto The Hinterlands,31.98,57.31
>>Click the |cRXP_PICK_Third Witherbark Cage|r
.complete 2988,3 
step
#label FinalCages
>>Click the |cRXP_PICK_First Witherbark Cage|r and |cRXP_PICK_Second Witherbark Cage|r
.complete 2988,1 
.goto The Hinterlands,23.28,58.81
.complete 2988,2 
.goto The Hinterlands,23.12,58.82
step
.goto The Hinterlands,9.752,44.473
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gryphon Master Talonaxe|r
.turnin 2988 >> Turn in Witherbark Cages
.accept 2989 >> Accept The Altar of Zul
.target Gryphon Master Talonaxe
step
.goto The Hinterlands,48.64,68.24
>>Kill |cRXP_ENEMY_Qiaga the Keeper|r. Loot her for the |T133056:0|t[|cRXP_LOOT_Sacred Mallet|r]
>>|cRXP_ENEMY_Qiaga the Keeper|r |cRXP_WARN_is a level 50 elite. Make sure you bring a group|r << !tbc !wotlk
>>|cRXP_WARN_Skip this step if you do not wish to do it or if somebody else in your group already has the|r |T133056:0|t[|cRXP_FRIENDLY_Mallet of Zul'Farrak|r]
.collect 9241,1 
.itemcount 9240,<1
step
#completewith next
.subzone 354 >>Travel to |cFFfa9602Jintha'Alor|r
step
.goto The Hinterlands,59.70,77.81
.use 9241 >>Use the |T133056:0|t[|cRXP_LOOT_Sacred Mallet|r] at the altar in front of the cave to create the |T133056:0|t[|cRXP_FRIENDLY_Mallet of Zul'Farrak|r]
>>|cRXP_WARN_You will need to bypass a lot of level 46-50 elites. Make sure you bring a group|r << !tbc !wotlk
.collect 9240,1 
.itemcount 9241,1
step
.goto The Hinterlands,48.814,68.387
>>|cRXP_WARN_Clear your way to the top of The Altar of Zul. Ensure you are on full HP before you reach the top!|r
>>|cRXP_WARN_Run to the exploration location, then jump off to the side to evade the Elites at the top. Wait on the ledge until you have dropped Combat. Watch the video below for an example|r
.complete 2989,1 
.link https://youtu.be/Z4gDpWTXaFY >> |cRXP_WARN_Click here for video reference|r
step
.goto The Hinterlands,9.752,44.473
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gryphon Master Talonaxe|r
.turnin 2989 >> Turn in The Altar of Zul
.accept 2990 >> Accept Thadius Grimshade
.target Gryphon Master Talonaxe
step
#completewith next
.zone Blasted Lands >> Travel to Blasted Lands
step
.isQuestTurnedIn 2990
.goto Blasted Lands,66.898,19.469
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thadius Grimshade|r atop the Tower
.turnin 2990 >> Turn in Thadius Grimshade
.accept 2991 >> Accept Nekrum's Medallion
.target Thadius Grimshade
step
#completewith next
.subzone 977 >>Travel to |cFFfa9602Steamwheedle Port|r in Tanaris
step
.goto Tanaris,67.00,22.40
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yeh'kinya|r
>>|cRXP_WARN_This is a prerequisite quest for Zul'Farrak|r
.accept 3520 >> Accept Screecher Spirits
.target Yeh'kinya
step
#completewith next
.zone Feralas >>Travel to |cFFfa9602Feralas|r
step
#loop
.goto Feralas,58.39,51.88,0
.goto Feralas,57.54,48.70,0
.goto Feralas,55.74,46.71,0
.goto Feralas,58.45,55.83,0
.goto Feralas,58.39,51.88,80,0
.goto Feralas,57.54,48.70,80,0
.goto Feralas,55.74,46.71,80,0
.goto Feralas,58.45,55.83,80,0
.goto Feralas,56.70,56.13,80,0
.use 10699 >>Kill |cRXP_ENEMY_Vale Screechers|r
>>|cRXP_WARN_Use|r |T135474:0|t[Yeh'kinya's Bramble] |cRXP_WARN_on their corpses. Talk to the|r |cRXP_FRIENDLY_Screecher Spirit|r |cRXP_WARN_that appears|r
.complete 3520,1 
.unitscan Rogue Vale Screecher
.unitscan Vale Screecher
.target Screecher Spirit
.isOnQuest 3520
step
#completewith next
.zone Dustwallow Marsh >>Travel to |cFFfa9602Dustwallow Marsh|r
step
.goto Dustwallow Marsh,46.021,57.096
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tabetha|r
.accept 2846 >> Accept Tiara of the Deep
.target Tabetha
step
#completewith Prophecyt
.subzone 977 >>Travel to |cFFfa9602Steamwheedle Port|r in Tanaris
step
.goto Tanaris,67.00,22.40
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yeh'kinya|r
.turnin 3520 >>Turn in Screecher Spirits
.target Yeh'kinya
.isQuestComplete 3520
step
#label Prophecy
.goto Tanaris,66.989,22.354
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yeh'kinya|r again
.accept 3527 >> Accept The Prophecy of Mosh'aru
.target Yeh'kinya
.isQuestTurnedIn 3520
step
.goto Tanaris,51.413,28.752
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Trenton Lighthammer|r
.accept 3042 >> Accept Troll Temper
.target Trenton Lighthammer
step
.goto Tanaris,52.462,28.514
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chief Engineer Bilgewhizzle|r
.accept 2768 >> Accept Divino-matic Rod
.target Chief Engineer Bilgewhizzle
step
.goto Tanaris,51.566,26.759
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tran'rek|r
.accept 2865 >> Accept Scarab Shells
.target Tran'rek
step
#completewith next
.goto Thousand Needles,70.58,62.69,200 >>Travel to the |cFFfa9602Shimmering Flats|r
step
#label ZFPickups
.goto Thousand Needles,78.143,77.120
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Wizzle Brassbolts|r
.accept 2770 >> Accept Gahz'rilla
.target Wizzle Brassbolts
step
.goto Tanaris,73.37,47.14
.goto Tanaris,38.731,19.839
.subzone 978 >> You will now run Zul'Farrak. Grind on |cRXP_ENEMY_Pirates|r while looking for a ZF group
>>Skip this step once you have found a group
step
.goto Tanaris,38.91,20.78,40,0
.goto Tanaris,38.731,19.839
.subzone 978,2 >> Enter Zul'Farrak
step
#completewith Gahzrilla
>>Kill |cRXP_ENEMY_Trolls|r. Loot them for their |cRXP_LOOT_Troll Temper|r
.complete 3042,1 
.isOnQuest 3042
step
#completewith next
>>Kill |cRXP_ENEMY_Scarabs|r. Loot them for their |cRXP_LOOT_Uncracked Scarab Shell|r
.complete 2865,1 
.isOnQuest 2865
step
#optional
>>Kill |cRXP_ENEMY_Theka the Martyr|r. Loot him for the |cRXP_LOOT_First Mosh'aru Tablet|r
.complete 3527,1 
.mob Theka the Martyr
.isOnQuest 3527
step
>>Kill |cRXP_ENEMY_Scarabs|r. Loot them for their |cRXP_LOOT_Uncracked Scarab Shell|r
.complete 2865,1 
.isOnQuest 2865
step
#completewith NekrumMedallion
+Ascend the Pyramid
>>Kill the |cRXP_ENEMY_Sandfury Executioner|r. Loot him for the |cRXP_LOOT_Executioner's Key|r
>>|cRXP_WARN_Anyone in the party may loot the|r |cRXP_LOOT_Key|r
>>|cRXP_WARN_Use the|r |cRXP_LOOT_Executioner's Key|r |cRXP_WARN_on one of the |cRXP_PICK_Troll Cages|r to free |cRXP_FRIENDLY_Sergeant Bly|r and his band|r
.collect 8444,1 
.disablecheckbox
.isOnQuest 2991,2768
.mob Sandfury Executioner
step
>>Defend |cRXP_FRIENDLY_Sergeant Bly|r and his band, then move down with them after a short period of time
>>Kill |cRXP_ENEMY_Nekrum Gutchewer|r. Loot him for |cRXP_LOOT_Nekrum's Medallion|r
>>After you kill |cRXP_ENEMY_Nekrum Gutchewer|r, eat and drink then talk to |cRXP_FRIENDLY_Sergeant Bly|r to fight him
>>Kill |cRXP_ENEMY_Sergeant Bly|r. Loot him for the |cRXP_LOOT_Divino-matic Rod|r
.complete 2991,1 
.complete 2768,1 
.isOnQuest 2991
.isOnQuest 2768
.skipgossip
step
>>Defend |cRXP_FRIENDLY_Sergeant Bly|r and his band, then move down with them after a short period of time
>>Kill |cRXP_ENEMY_Nekrum Gutchewer|r. Loot him for |cRXP_LOOT_Nekrum's Medallion|r
.complete 2991,1 
.isOnQuest 2991
.skipgossip
step
#label NekrumMedallion
>>Defend |cRXP_FRIENDLY_Sergeant Bly|r and his band, then move down with them after a short period of time
>>Kill |cRXP_ENEMY_Nekrum Gutchewer|r. Eat and drink then talk to |cRXP_FRIENDLY_Sergeant Bly|r to fight him
>>Kill |cRXP_ENEMY_Sergeant Bly|r. Loot him for the |cRXP_LOOT_Divino-matic Rod|r
.complete 2768,1 
.isOnQuest 2768
.skipgossip
step
#optional
>>Kill |cRXP_ENEMY_Hydromancer Velratha|r. Loot her for the |cRXP_LOOT_Tiara of the Deep|r and the |cRXP_LOOT_Second Mosh'aru Tablet|r
.complete 2846,1 
.complete 3527,2 
.mob Hydromancer Velratha
.isOnQuest 2846
.isOnQuest 3527
step
#optional
>>Kill |cRXP_ENEMY_Hydromancer Velratha|r. Loot her for the |cRXP_LOOT_Tiara of the Deep|r
.complete 2846,1 
.mob Hydromancer Velratha
.isOnQuest 2846
step
#optional
>>Kill |cRXP_ENEMY_Hydromancer Velratha|r. Loot her for the |cRXP_LOOT_Second Mosh'aru Tablet|r
.complete 3527,2 
.mob Hydromancer Velratha
.isOnQuest 3527
step
#label Gahzrilla
>>|cRXP_WARN_Use the|r |T133056:0|t[Mallet of Zul'Farrak] |cRXP_WARN_on the |cRXP_PICK_Gong of Zul'Farrak|r to summon|r |cRXP_ENEMY_Gahz'rilla|r
>>Kill |cRXP_ENEMY_Gahz'rilla|r. Loot him for |cRXP_LOOT_Gahz'rilla's Electrified Scale|r
>>|cRXP_WARN_If no one in your party has the|r |T133056:0|t[Mallet of Zul'Farrak] |cRXP_WARN_you will not be able to summon|r |cRXP_ENEMY_Gahz'rilla|r
.complete 2770,1 
.mob Gahz'rilla
.isOnQuest 2770
step
>>Kill |cRXP_ENEMY_Trolls|r. Loot them for their |cRXP_LOOT_Troll Temper|r
.complete 3042,1 
.isOnQuest 3042
step
#completewith TanarisTurnins
.zone Tanaris >>Leave Zul'Farrak
step
.goto Tanaris,51.413,28.752
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Trenton Lighthammer|r
.turnin 3042 >> Turn in Troll Temper
.target Trenton Lighthammer
.isQuestComplete 3042
step
.goto Tanaris,52.462,28.514
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chief Engineer Bilgewhizzle|r
.turnin 2768 >> Turn in Divino-matic Rod
.target Chief Engineer Bilgewhizzle
.isQuestComplete 2768
step
.goto Tanaris,51.566,26.759
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tran'rek|r
.turnin 2865 >> Turn in Scarab Shells
.target Tran'rek
.isQuestComplete 2865
step
#completewith next
.goto Tanaris,66.989,22.354,100 >> Travel to |cFFfa9602Steamwheedle Port|r
step
#label TanarisTurnins
.goto Tanaris,66.989,22.354
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yeh'kinya|r
.turnin 3527 >> Turn in The Prophecy of Mosh'aru
.target Yeh'kinya
.isQuestComplete 3527
step
#completewith next
.goto Thousand Needles,70.58,62.69,200 >>Travel to the |cFFfa9602Shimmering Flats|r
step
.goto Thousand Needles,78.143,77.120
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Wizzle Brassbolts|r
.turnin 2770 >> Turn in Gahz'rilla
.target Wizzle Brassbolts
.isQuestComplete 2770
step
#completewith next
.zone Dustwallow Marsh >>Travel to |cFFfa9602Dustwallow Marsh|r
step
.goto Dustwallow Marsh,46.021,57.096
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tabetha|r
.turnin 2846 >> Turn in Tiara of the Deep
.target Tabetha
.isQuestComplete 2846
step
#completewith next
.zone Blasted Lands >> Travel to Blasted Lands
step
.isQuestTurnedIn 2990
.goto Blasted Lands,66.898,19.469
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thadius Grimshade|r atop the Tower
.turnin 2991 >> Turn in Nekrum's Medallion
.accept 2992 >> Accept The Divination
.turnin 2992 >> Turn in The Divination
.accept 2993 >> Accept Return to the Hinterlands
.target Thadius Grimshade
step
+|cRXP_WARN_You have completed the Zul'Farrak quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 30-50
<< Alliance
#name 11. Maraudon
step
#completewith StartMara
+Start looking for a group for Maraudon while you accept the quests
step
#completewith next
.subzone 513 >> Travel to Theramore Isle in Dustwallow Marsh
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Tervosh|r atop Theramore tower
.goto Dustwallow Marsh,66.423,49.260
.accept 7070 >> Accept Shadowshard Fragments
.target Archmage Tervosh
step
#completewith VyletongueCorruption
.subzone 608 >> Travel to Nijel's Point in Desolace
step
.goto Desolace,64.64,9.25,15,0
.goto Desolace,63.827,10.669
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Keeper Marandis|r
.accept 7065 >> Accept Corruption of Earth and Seed
.target Keeper Marandis
step
#label VyletongueCorruption
.goto Desolace,68.501,8.880
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Talendria|r
.accept 7041 >> Accept Vyletongue Corruption
.target Keeper Marandis
step
.goto Desolace,66.275,6.554
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Innkeeper Lyshaerya|r
>>|cRXP_WARN_This is so you can Hearth after completing the dungeon|r
.home >> Set your Hearthstone to Desolace
.target Innkeeper Lyshaerya
step
#completewith PariahInstructions
.zone Desolace >> Travel to Desolace
step
.goto Desolace,62.194,39.624
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Willow|r
.accept 7028 >> Accept Twisted Evils
.target Willow
step
#label PariahInstructions
.line Desolace,50.48,86.66,50.39,86.61,50.18,87.01,49.89,87.11,48.95,87.04,48.73,87.11,48.25,87.14,47.82,87.34,47.01,86.96,45.68,86.22,45.16,86.32,44.74,86.12,44.40,85.69,44.11,85.25,43.77,84.93,43.59,84.93
.goto Desolace,43.59,84.93,50,0
.goto Desolace,47.01,86.96,70,0
.goto Desolace,50.48,86.66,50,0
.goto Desolace,47.01,86.96,70,0
.goto Desolace,43.59,84.93,50,0
.goto Desolace,50.48,86.66
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Centaur Pariah|r
>>|cRXP_WARN_The |cRXP_FRIENDLY_Centaur Pariah|r patrols slightly around southern Desolace|r
.accept 7067 >> Accept The Pariah's Instructions
.target Centaur Pariah
step
#label StartMara
.goto Desolace,29.89,62.44,0
.goto 1414,38.43,57.97
.zone 1414 >> Travel to Maraudon
step
#completewith EnterMaraudon
>>Kill all |cRXP_ENEMY_Monsters|r in Maraudon. Loot them for their |cRXP_LOOT_Theradric Crystal Carvings|r
>>|cRXP_WARN_This can be completed OUTSIDE and INSIDE of the Instance. Don't attempt to complete this now|r
.complete 7028,1 
.isOnQuest 7028
step
>>Kill |cRXP_ENEMY_The Nameless Prophet|r. Loot it for the |T133277:0|t[|cRXP_LOOT_Amulet of Spirits|r]
>>|cRXP_WARN_This is completed OUTSIDE of the Instance. |cRXP_ENEMY_The Nameless Prophets|r may be patrolling|r
.collect 17757,1,7067,1 
.mob The Nameless Prophet
.isOnQuest 7067
step
#completewith next
>>Kill |cRXP_ENEMY_Shadowshard Smashers|r and |cRXP_ENEMY_Shadowshard Rumblers|r. Loot them for their |cRXP_LOOT_Shadowshard Fragments|r
>>|cRXP_WARN_These are only found in the Purple section outside of the Instance|r
.complete 7070,1 
.mob Shadowshard Smasher
.mob Shadowshard Rumbler
.isOnQuest 7070
step
.goto 1414,38.469,57.287,20,0
.goto 1414,38.380,57.376,30,0
.goto 1414,38.469,57.287
>>|cRXP_WARN_Use the|r |T133277:0|t[|cRXP_LOOT_Amulet of Spirits|r] |cRXP_WARN_on the|r |cRXP_FRIENDLY_Spirit of Gelk|r
>>Kill |cRXP_ENEMY_Gelk|r. Loot him for the |T134104:0|t[|cRXP_LOOT_Gem of the Second Khan|r]
>>|cRXP_WARN_This is completed OUTSIDE of the Instance|r
.collect 17762,1,7067,1 
.use 17757 
.mob Spirit of Gelk
.mob Gelk
.isOnQuest 7067
step
.goto 1414,38.13,56.90,60,0
.goto 1414,28.76,56.96,60,0
.goto 1414,38.13,56.90
>>Kill |cRXP_ENEMY_Shadowshard Smashers|r and |cRXP_ENEMY_Shadowshard Rumblers|r. Loot them for their |cRXP_LOOT_Shadowshard Fragments|r
>>|cRXP_WARN_These are only found in the Purple section outside of the Instance|r
.complete 7070,1 
.mob Shadowshard Smasher
.mob Shadowshard Rumbler
.isOnQuest 7070
step
.goto 1414,38.497,57.721
>>|cRXP_WARN_Use the|r |T133277:0|t[|cRXP_LOOT_Amulet of Spirits|r] |cRXP_WARN_on the|r |cRXP_FRIENDLY_Spirit of Kolk|r
>>Kill |cRXP_ENEMY_Kolk|r. Loot him for the |T134129:0|t[|cRXP_LOOT_Gem of the First Khan|r]
>>|cRXP_WARN_This is completed OUTSIDE of the Instance|r
.collect 17761,1,7067,1 
.use 17757 
.mob Spirit of Kolk
.mob Kolk
.isOnQuest 7067
step
.goto 1414,38.77,58.12
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Cavindra|r
.accept 7044 >> Accept Legends of Maraudon
.target Cavindra
step
.goto 1414,38.928,58.354
>>|cRXP_WARN_Use the|r |T134865:0|t[Coated Cerulean Vial] |cRXP_WARN_in the Orange pool|r
.complete 7041,2 
.use 17693 
.isOnQuest 7041
step
.goto 1414,39.00,58.32,70,0
.goto 1414,39.13,57.68,60,0
.goto 1414,39.25,57.71,20,0
.goto 1414,39.13,57.68
>>|cRXP_WARN_Use the|r |T133277:0|t[|cRXP_LOOT_Amulet of Spirits|r] |cRXP_WARN_on the|r |cRXP_FRIENDLY_Spirit of Magra|r
>>Kill |cRXP_ENEMY_Magra|r. Loot him for the |T134135:0|t[|cRXP_LOOT_Gem of the Third Khan|r]
>>|cRXP_WARN_This is completed OUTSIDE of the Instance|r
.collect 17763,1,7067,1 
.use 17757 
.mob Spirit of Magra
.mob Magra
.isOnQuest 7067
step
#label EnterMaraudon
.goto 1414,39.266,58.205
.subzone 2100,2 >> Enter the Maraudon Instance through the Orange side
step
#completewith CrystalCarving
>>Kill any |cRXP_ENEMY_Monster|r in Maraudon. Loot them for their |cRXP_LOOT_Theradric Crystal Carvings|r
.complete 7028,1 
.isOnQuest 7028
step
#completewith next
>>|cRXP_WARN_Use the|r |T134804:0|t[Filled Cerulean Vial] |cRXP_WARN_on small flowers/plants inside Orange|r
>>Kill the |cRXP_ENEMY_Noxxious Scions|r that are summoned
.complete 7041,1 
.use 17696 
.isOnQuest 7041
step
>>|cRXP_WARN_Use the|r |T133277:0|t[|cRXP_LOOT_Amulet of Spirits|r] |cRXP_WARN_on the|r |cRXP_FRIENDLY_Spirit of Veng|r
>>Kill |cRXP_ENEMY_Veng|r. Loot him for the |T134116:0|t[|cRXP_LOOT_Gem of the Fifth Khan|r]
>>|cRXP_ENEMY_Veng|r |cRXP_WARN_patrols around INSIDE the Maraudon Orange Instance|r
.collect 17765,1,7067,1 
.use 17757 
.mob Spirit of Veng
.mob Veng
.isOnQuest 7067
step
>>|cRXP_WARN_Use the|r |T134804:0|t[Filled Cerulean Vial] |cRXP_WARN_on small flowers/plants inside Orange|r
>>Kill the |cRXP_ENEMY_Noxxious Scions|r that are summoned
.complete 7041,1 
.use 17696 
.isOnQuest 7041
step
>>Kill |cRXP_ENEMY_Noxxion|r. Loot him for the |cRXP_LOOT_Celebrian Rod|r
>>Kill |cRXP_ENEMY_Lord Vyletongue|r. Loot him for the |cRXP_LOOT_Celebrian Diamond|r
>>|cRXP_ENEMY_Noxxion|r |cRXP_WARN_is in the Orange section and |cRXP_ENEMY_Lord Vyletongue|r in the Purple|r
.complete 7044,2 
.complete 7044,1 
.isOnQuest 7044
step
>>|cRXP_WARN_Use the|r |T133277:0|t[|cRXP_LOOT_Amulet of Spirits|r] |cRXP_WARN_on the|r |cRXP_FRIENDLY_Spirit of Maraudos|r
>>Kill |cRXP_ENEMY_Maraudos|r. Loot him for the |T134132:0|t[|cRXP_LOOT_Gem of the Fourth Khan|r]
>>|cRXP_ENEMY_Maraudos|r |cRXP_WARN_patrols around INSIDE the Maraudon Purple Instance|r
.collect 17764,1,7067,1 
.use 17757 
.mob Spirit of Maraudos
.mob Maraudos
.isOnQuest 7067
step
>>|cRXP_WARN_Channel any of the|r |T134129:0|t|T134104:0|t|T134135:0|t|T134132:0|t|T134116:0|t[|cRXP_LOOT_Gems of the Khans|r] |cRXP_WARN_to create the|r |T133277:0|t[|cRXP_LOOT_Amulet of Union|r]
.complete 7067,1 
.use 17761,1
.use 17762,1
.use 17763,1
.use 17764,1
.use 17765,1
.itemcount 17761,1
.itemcount 17762,1
.itemcount 17763,1
.itemcount 17764,1
.itemcount 17765,1
.isOnQuest 7067
step
>>Kill |cRXP_ENEMY_Celebras the Cursed|r then talk to |cRXP_FRIENDLY_Celebras the Redeemed|r
.turnin 7044 >> Turn in Legends of Maraudon
.isQuestComplete 7044
.mob Celebras the Cursed
.target Celebras the Redeemed
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Celebras the Redeemed|r
.accept 7046 >> Accept The Scepter of Celebras
.timer 14,Incantation of Celebras Spawning RP
.isQuestTurnedIn 7044
.target Celebras the Redeemed
step
.cast 6477 >> Click the |cRXP_PICK_Incantation of Celebras|r on the ground
.timer 34,The Scepter of Celebras RP
.isQuestTurnedIn 7044
step
>>|cRXP_WARN_Wait out the RP|r
.complete 7046,1 
.isQuestTurnedIn 7044
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Celebras the Redeemed|r
.turnin 7046 >> Turn in The Scepter of Celebras
.isQuestTurnedIn 7044
.target Celebras the Redeemed
step
>>Kill |cRXP_ENEMY_Princess Theradras|r
.complete 7065,1 
.mob Princess Theradras
.isOnQuest 7065
step
#label CrystalCarving
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Zaetar's Spirit|r
.accept 7066 >> Accept Seed of Life
.target Zaetar's Spirit
step
>>Kill any |cRXP_ENEMY_Monster|r in Maraudon. Loot them for their |cRXP_LOOT_Theradric Crystal Carvings|r
>>|cRXP_WARN_This can be completed OUTSIDE and INSIDE of the Instance|r
.complete 7028,1 
.isOnQuest 7028
step
.hs >> Hearth to Nijel's Point
step
.goto Desolace,64.64,9.15,0
.goto Desolace,63.827,10.669
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Keeper Marandis|r
.turnin 7065 >> Turn in Corruption of Earth and Seed
.target Keeper Marandis
.isQuestComplete 7065
step
.goto Desolace,68.501,8.880
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Talendria|r
.turnin 7041 >> Turn in Vyletongue Corruption
.target Talendria
.isQuestComplete 7041
step
.goto Desolace,62.194,39.624
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Willow|r
.turnin 7028 >> Turn in Twisted Evils
.target Willow
.isQuestComplete 7028
step
.line Desolace,50.48,86.66,50.39,86.61,50.18,87.01,49.89,87.11,48.95,87.04,48.73,87.11,48.25,87.14,47.82,87.34,47.01,86.96,45.68,86.22,45.16,86.32,44.74,86.12,44.40,85.69,44.11,85.25,43.77,84.93,43.59,84.93
.goto Desolace,43.59,84.93,50,0
.goto Desolace,47.01,86.96,70,0
.goto Desolace,50.48,86.66,50,0
.goto Desolace,47.01,86.96,70,0
.goto Desolace,43.59,84.93,50,0
.goto Desolace,50.48,86.66
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Centaur Pariah|r
>>|cRXP_WARN_The |cRXP_FRIENDLY_Centaur Pariah|r patrols slightly around southern Desolace|r
.turnin 7067 >> Turn in The Pariah's Instructions
.target Centaur Pariah
.isQuestComplete 7067
step
#completewith next
.goto Desolace,64.66,10.53
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Baritanas Skyriver|r
.fly Theramore >> Fly to Theramore
.target Baritanas Skyriver
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Tervosh|r atop Theramore tower
.goto Dustwallow Marsh,66.423,49.260
.turnin 7070 >> Turn in Shadowshard Fragments
.target Archmage Tervosh
.isQuestComplete 7070
step
#completewith next
.zone Moonglade >> Travel to Moonglade
step << Druid
#completewith next
.cast 18960 >> Cast Teleport: Moonglade
.zoneskip Moonglade
step
.isOnQuest 7066
.goto Moonglade,36.178,41.798
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Keeper Remulos|r
.turnin 7066 >> Turn in Seed of Life
.target Keeper Remulos
step
+|cRXP_WARN_You have completed the Maraudon quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 30-50
<< Alliance
#name 12. Sunken Temple
step << Paladin
.xp <50,1
#phase 4-6 << !tbc !wotlk
#completewith next
.zone Western Plaguelands >> Travel to Western Plaguelands
step << Paladin
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Western Plaguelands,42.702,84.031
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Ashlam Valorfist|r
.accept 8414 >> Accept Dispelling Evil
.target Commander Ashlam Valorfist
step << Paladin
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Western Plaguelands,48.91,80.84,70,0
.goto Western Plaguelands,50.01,76.90
>>Kill |cRXP_ENEMY_Skeletal Flayers|r and |cRXP_ENEMY_Slavering Ghouls|r. Loot them for their |cRXP_LOOT_Minion's Scourgestones|r
.complete 8414,1 
.mob +Slavering Ghoul
.mob +Skeletal Flayer
step << Paladin
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Western Plaguelands,51.99,82.85
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_High Priest Thel'danis|r
.turnin 8414 >> Turn in Dispelling Evil
.accept 8416 >> Accept Inert Scourgestones
.target High Priest Thel'danis
step << Paladin
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Western Plaguelands,42.702,84.031
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Ashlam Valorfist|r
.turnin 8416 >> Turn in Inert Scourgestones
.accept 8418 >> Accept Forging the Mightstone
.target Commander Ashlam Valorfist
step << Priest
.xp <50,1
#phase 4-6 << !tbc !wotlk
#ah
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to an |cRXP_FRIENDLY_Auctioneer|r in a major city
>>|cRXP_BUY_Buy a|r |T134797:0|t[Ichor of Undeath] |cRXP_BUY_from the Auction House. You will need this later for your Sunken Temple class quest|r
>>|cRXP_WARN_Skip this step if you can't acquire one|r
.collect 7972,1,8256,1 
step << Hunter/Priest
.xp <50,1
#phase 4-6 << !tbc !wotlk
#completewith next
.zone Azshara >> Travel to Azshara
step << Hunter/Priest
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Azshara,42.400,42.619
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
.accept 8153 >> Accept Courser Antlers << Hunter
.accept 8255 >> Accept Of Coursers We Know << Priest
.target Ogtinc
step << Hunter/Priest
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Azshara,51.0,30.8,80,0
.goto Azshara,47.0,19.0,80,0
.goto Azshara,57.2,21.2,80,0
.goto Azshara,71.0,29.6,80,0
.goto Azshara,75.8,21.8,80,0
.goto Azshara,57.2,21.2
>>Kill |cRXP_ENEMY_Mosshoof Coursers|r. Loot them for their |cRXP_LOOT_Perfect Courser Antlers|r << Hunter
>>Kill |cRXP_ENEMY_Mosshoof Coursers|r. Loot them for their |cRXP_LOOT_Healthy Courser Glands|r << Priest
.complete 8153,1 << Hunter 
.complete 8255,1 << Priest 
.mob Mosshoof Courser
step << Hunter/Priest
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Azshara,42.400,42.619
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
.turnin 8153 >> Turn in Courser Antlers << Hunter
.accept 8231 >> Accept Wavethrashing << Hunter
.turnin 8255 >> Turn in Of Coursers We Know << Priest
.accept 8256 >> Accept The Ichor of Undeath << Priest
.target Ogtinc
step << Hunter
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Azshara,88.69,25.88,70,0
.goto Azshara,87.0,9.0
.goto Azshara,54.2,42.2,0
.goto Azshara,59.2,35.6,0
.goto Azshara,71.6,36.8,0
.goto Azshara,90.4,33.6,0
.goto Azshara,88.69,25.88,0
>>Kill |cRXP_ENEMY_Wavethrashers|r. Loot them for their |cRXP_LOOT_Wavethrasher Scales|r
>>|cRXP_WARN_These can be hard to find. Ensure to use|r |T132328:0|t[Track Beasts] |cRXP_WARN_and cast|r |T132172:0|t[Eagle Eye] |cRXP_WARN_around the coast to find them faster|r
.complete 8231,1 
.mob Wavethrasher
.mob Young Wavethrasher
.mob Great Wavethrasher
step << Priest
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Azshara,17.12,69.00,60,0
.goto Azshara,14.22,72.74,60,0
.goto Azshara,17.12,69.00
>>Kill |cRXP_ENEMY_Highborne Apparitions|r and |cRXP_ENEMY_Highborne Lichlings|r. Loot them for an |cRXP_LOOT_Ichor of Undeath|r
.complete 8256,1 
.mob Highborne Apparition
.mob Highborne Lichling
step << Hunter/Priest
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Azshara,42.400,42.619
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
.turnin 8231 >> Turn in Wavethrashing << Hunter
.accept 8232 >> Accept The Green Drake << Hunter
.turnin 8256 >> Turn in The Ichor of Undeath
.accept 8257 >> Accept Blood of Morphaz << Priest
.target Ogtinc
step << Rogue
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Hillsbrad Foothills,75.575,22.076,20,0
.goto Alterac Mountains,86.026,78.879
.subzone 3486 >> Travel to Hillsbrad Foothills (Southshore). From there travel to Ravenholdt Manor
step << Rogue
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Alterac Mountains,86.026,78.879
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lord Jorach Ravenholdt|r upstairs
.accept 8234 >> Accept Sealed Azure Bag
.target Lord Jorach Ravenholdt
step << Mage/Rogue
.xp <50,1
#phase 4-6 << !tbc !wotlk
#completewith next
.zone Azshara >> Travel to Azshara
step << Mage
.xp <50,1
#phase 4-6 << !tbc !wotlk
#completewith next
.goto Azshara,28.113,50.088
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sanath Lim-yo|r
>>|cRXP_WARN_This will teleport you to the top of the mountain|r
.turnin 3503 >> Turn in Meeting with the Master
.target Sanath Lim-yo
step << Mage
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Azshara,29.248,40.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Xylem|r atop the Tower
.accept 8251 >> Accept Magic Dust
.target Archmage Xylem
step << Mage
.xp <50,1
#phase 4-6 << !tbc !wotlk
#completewith next
.goto Azshara,26.466,46.271
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nyrill|r
>>|cRXP_WARN_This will teleport you back down|r
.turnin 3421 >> Turn in Return Trip
.timer 8,Return Trip RP
.target Nyrill
step << Rogue
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Azshara,48.42,30.29,70,0
.goto Azshara,44.34,26.09,70,0
.goto Azshara,45.26,21.60
>>|T133644:0|t[Pick Pocket] |cRXP_ENEMY_Timbermaw Shamans|r. Loot them for the |cRXP_LOOT_Sealed Azure Bag|r
>>|cRXP_WARN_You may have to tick the [At War] checkbox for [Timbermaw Hold] in your Reputation pane to make them hostile towards you|r
.complete 8234,1 
.mob Timbermaw Shaman
step << Mage
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Azshara,55.97,29.98,30,0
.goto Azshara,56.55,28.36,30,0
.goto Azshara,57.71,31.13,50,0
.goto Azshara,59.17,31.93,40,0
.goto Azshara,58.96,28.23,30,0
.goto Azshara,56.55,28.36
>>Kill |cRXP_ENEMY_Blood Elf Reclaimers|r and |cRXP_ENEMY_Blood Elf Surveyors|r. Loot them for their |cRXP_LOOT_Glittering Dust|r
.complete 8251,1 
.mob Blood Elf Reclaimer
.mob Blood Elf Surveyor
step << Mage/Rogue
.xp <50,1
#phase 4-6 << !tbc !wotlk
#completewith next
.goto Azshara,28.113,50.088
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sanath Lim-yo|r
>>|cRXP_WARN_This will teleport you to the top of the mountain|r
.turnin 3503 >> Turn in Meeting with the Master
.target Sanath Lim-yo
step << Mage/Rogue
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Azshara,29.248,40.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Xylem|r atop the Tower
.turnin 8251 >> Turn in Magic Dust << Mage
.accept 8252 >> Accept The Siren's Coral << Mage
.turnin 8234 >> Turn in Sealed Azure Bag << Rogue
.accept 8235 >> Accept Encoded Fragments << Rogue
.target Archmage Xylem
step << Rogue
.xp <50,1
#phase 4-6 << !tbc !wotlk
.isQuestTurnedIn 8234
#completewith next
+|cRXP_WARN_Ensure you have to unticked the [At War] checkbox for [Timbermaw Hold] in your Reputation pane to make them non-hostile towards you again|r
step << Mage/Rogue
.xp <50,1
#phase 4-6 << !tbc !wotlk
#completewith next
.goto Azshara,26.466,46.271
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nyrill|r
>>|cRXP_WARN_This will teleport you back down|r
.turnin 3421 >> Turn in Return Trip
.timer 8,Return Trip RP
.target Nyrill
step << Mage
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Azshara,43.0,45.6,70,0
.goto Azshara,47.0,41.6,70,0
.goto Azshara,47.4,65.0,70,0
.goto Azshara,46.0,52.8
>>Kill |cRXP_ENEMY_Spitelash Sirens|r. Loot them for their |cRXP_LOOT_Enchanted Corals|r
.complete 8252,1 
.mob Spitelash Siren
step << Rogue
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Azshara,66.6,25.6,70,0
.goto Azshara,68.8,29.4,70,0
.goto Azshara,74.2,29.6,70,0
.goto Azshara,76.6,25.0,70,0
.goto Azshara,80.8,24.6,70,0
.goto Azshara,86.6,19.6,70,0
.goto Azshara,74.6,12.6,70,0
.goto Azshara,69.0,27.6
>>Kill |cRXP_ENEMY_Forest Oozes|r. Loot them for their |cRXP_LOOT_Encoded Fragments|r
>>|cRXP_WARN_Cast|r |T133644:0|t[Pick Pocket] |cRXP_WARN_on them before you kill them|r
.complete 8235,1 
.mob Forest Ooze
step << Mage/Rogue
.xp <50,1
#phase 4-6 << !tbc !wotlk
#completewith next
.goto Azshara,28.113,50.088
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sanath Lim-yo|r
>>|cRXP_WARN_This will teleport you to the top of the mountain|r
.turnin 3503 >> Turn in Meeting with the Master
.target Sanath Lim-yo
step << Mage/Rogue
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Azshara,29.248,40.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Xylem|r atop the Tower
.turnin 8252 >> Turn in The Siren's Coral << Mage
.turnin 8235 >> Turn in Encoded Fragments << Rogue
.accept 8253 >> Accept Destroy Morphaz << Mage
.accept 8236 >> Accept The Azure Key << Rogue
.target Archmage Xylem
step << Mage/Rogue
.xp <50,1
#phase 4-6 << !tbc !wotlk
.isOnQuest 8253,8236
.goto Azshara,26.466,46.271
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nyrill|r
>>|cRXP_WARN_This will teleport you back down|r
.turnin 3421 >> Turn in Return Trip
.timer 8,Return Trip RP
.target Nyrill
.zoneskip Azshara,1
step << Druid
.xp <50,1
#phase 4-6 << !tbc !wotlk
#completewith next
.zone Un'Goro Crater >> Travel to Un'Goro Crater
step << Druid
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Un'Goro Crater,71.639,75.960
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Torwa Pathfinder|r
.accept 9052 >> Accept Bloodpetal Poison
.target Torwa Pathfinder
step << Druid
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Un'Goro Crater,44.8,75.6,70,0
.goto Un'Goro Crater,45.0,83.6,70,0
.goto Un'Goro Crater,55.0,83.6,70,0
.goto Un'Goro Crater,54.4,76.4,70,0
.goto Un'Goro Crater,48.8,85.3
>>Kill |cRXP_ENEMY_Gorishi Stingers|r and |cRXP_ENEMY_Gorishi Wasps|r. Loot them for their |cRXP_LOOT_Gorishi Stings|r
.complete 9052,1 
.mob Gorishi Wasp
.mob Gorishi Stinger
step << Druid
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Un'Goro Crater,62.5,64.1,90,0
.goto Un'Goro Crater,38.3,53.6,90,0
.goto Un'Goro Crater,45.5,24.5
>>Open the |cRXP_PICK_Bloodpetal Sprouts|r on the ground. Loot them for |cRXP_LOOT_Bloodcaps|r
.complete 9052,2 
step << Druid
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Un'Goro Crater,71.639,75.960
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Torwa Pathfinder|r
.turnin 9052 >> Turn in Bloodpetal Poison
.accept 9051 >> Accept Toxic Test
.target Torwa Pathfinder
step << Druid
.xp <50,1
#phase 4-6 << !tbc !wotlk
>>Look for a |cRXP_ENEMY_Devilsaur|r or |cRXP_ENEMY_Ironhide Devilsaur|r. Avoid |cRXP_ENEMY_Tyrant Devilsaurs|r
>>|cRXP_WARN_You should be able to see their patrols on your map|r
>>|cRXP_WARN_The way you do this is spamming|r |T136090:0|t[Hibernate]|cRXP_WARN_. You should only spam|r |T136090:0|t[Hibernate] |cRXP_WARN_and nothing else. If it breaks early start spamming|r |T136090:0|t[Hibernate] |cRXP_WARN_again, they run with 170% movement speed so you can't outrun a|r |cRXP_ENEMY_Devilsaur|r
>>|cRXP_WARN_Use the|r |T135125:0|t[Devilsaur Barb] |cRXP_WARN_on it once it has been|r |T136090:0|t[Hibernated]
>>|cRXP_WARN_Shift into|r |T132144:0|t[Travel Form] |cRXP_WARN_and run away to reset it after|r
.complete 9051,1 
.use 22432 
.mob Devilsaur
.mob Ironhide Devilsaur
step << Druid
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Un'Goro Crater,71.639,75.960
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Torwa Pathfinder|r
.turnin 9051 >> Turn in Toxic Test
.accept 9053 >> Accept A Better Ingredient
.target Torwa Pathfinder
step << Warlock
.xp <50,1
#phase 4-6 << !tbc !wotlk
.isQuestAvailable 8419
.isQuestAvailable 8420
#ah
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to an |cRXP_FRIENDLY_Auctioneer|r
>>Buy the following items from the Auction House for an instant turn in at Felwood shortly. Skip this step if you wish to not buy any
>>|T132888:0|t[Felcloth]
.collect 14256,1,8419,1 
step << Warlock
.xp <50,1
#phase 4-6 << !tbc !wotlk
#completewith next
.zone Felwood >> Travel to Felwood
step << Warlock
.xp <50,1
#optional
#phase 4-6 << !tbc !wotlk
.isOnQuest 8419
.goto Felwood,41.52,44.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Impsy|r
.turnin 8419 >> Turn in An Imp's Request
.target Impsy
.itemcount 14256,1
step << Warlock
.xp <50,1
#phase 4-6 << !tbc !wotlk
.isQuestAvailable 8419
.goto Felwood,41.52,44.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Impsy|r
.accept 8420 >> Accept Hot and Itchy
.turnin 8420 >> Turn in Hot and Itchy
.target Impsy
.itemcount 14256,1
step << Warlock
.xp <50,1
.isQuestAvailable 8419
.isQuestAvailable 8420
#phase 4-6 << !tbc !wotlk
.goto Felwood,43.27,84.98,45,0
.goto Felwood,43.41,88.13,70,0
.goto Felwood,39.45,84.55
>>Kill |cRXP_ENEMY_Jadefire Satyrs|r and |cRXP_ENEMY_Jadefire Felsworns|r. Loot them for a |cRXP_LOOT_Felcloth|r
.collect 14256,1
.mob Jadefire Satyr
.mob Jadefire Felsworn
step << Warlock
.xp <50,1
#phase 4-6 << !tbc !wotlk
.isQuestAvailable 8419
.goto Felwood,41.52,44.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Impsy|r
.accept 8420 >> Accept Hot and Itchy
.turnin 8420 >> Turn in Hot and Itchy
.target Impsy
.itemcount 14256,1
step << Warlock
.xp <50,1
#phase 4-6 << !tbc !wotlk
.isQuestAvailable 8419
.goto Felwood,41.52,44.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Impsy|r
.accept 8421 >> Accept The Wrong Stuff
.target Impsy
step << Warlock
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Felwood,40.48,59.07,70,0
.goto Felwood,39.98,54.76,0
>>Kill |cRXP_ENEMY_Tainted Oozes|r. Loot them for their |cRXP_LOOT_Bloodvenom Essences|r
.complete 8421,2 
.mob Tainted Ooze
step << Warlock
.xp <50,1
#phase 4-6 << !tbc !wotlk
.isOnQuest 8421
.goto Felwood,49.0,29.6,70,0
.goto Felwood,53.0,22.8,70,0
.goto Felwood,49.4,18.0,70,0
.goto Felwood,46.4,24.6,70,0
.goto Felwood,49.0,29.6,70,0
.goto Felwood,53.0,22.8,70,0
.goto Felwood,49.4,18.0,70,0
.goto Felwood,46.4,24.6
>>Kill |cRXP_ENEMY_Irontree Stompers|r, |cRXP_ENEMY_Irontree Wanderers|r and |cRXP_ENEMY_Withered Protectors|r. Loot them for their |cRXP_LOOT_Rotting Wood|r
.complete 8421,1 
.mob Irontree Stomper
.mob Irontree Wanderer
.mob Withered Protector
step << Warlock
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Felwood,41.52,44.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Impsy|r
.turnin 8421 >> Turn in The Wrong Stuff
.accept 8422 >> Accept Trolls of a Feather
.target Impsy
step << Warrior
.xp <50,1
#phase 4-6 << !tbc !wotlk
#completewith next
.zone Blasted Lands >> Travel to Blasted Lands
step << Warrior
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Swamp of Sorrows,34.287,66.134
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Fallen Hero of the Horde|r
.accept 8423 >> Accept Warrior Kinship
.target Fallen Hero of the Horde
step << Warrior
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Blasted Lands,44.2,34.8,70,0
.goto Blasted Lands,47.7,38.6,70,0
.goto Blasted Lands,52.2,37.4,70,0
.goto Blasted Lands,54.8,44.8,70,0
.goto Blasted Lands,51.2,55.6,70,0
.goto Blasted Lands,45.8,48.2,70,0
.goto Blasted Lands,49.0,36.6
>>Kill |cRXP_ENEMY_Helboars|r
.complete 8423,1 
.mob Helboar
step << Warrior
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Swamp of Sorrows,34.287,66.134
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Fallen Hero of the Horde|r
.turnin 8423 >> Turn in Warrior Kinship
.accept 8424 >> Accept War on the Shadowsworn
.target Fallen Hero of the Horde
step << Warrior
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Blasted Lands,63.8,30.1,60,0
.goto Blasted Lands,63.1,45.8,60,0
.goto Blasted Lands,65.9,33.3,60,0
.goto Blasted Lands,63.6,39.2
>>Kill |cRXP_ENEMY_Shadowsworn Adepts|r, |cRXP_ENEMY_Shadowsworn Cultists|r and |cRXP_ENEMY_Shadowsworn Thugs|r
.complete 8424,1 
.complete 8424,2 
.complete 8424,3 
.mob Shadowsworn Adept
.mob Shadowsworn Cultist
.mob Shadowsworn Thug
step << Warrior
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Swamp of Sorrows,34.287,66.134
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Fallen Hero of the Horde|r
.turnin 8424 >> Turn in War on the Shadowsworn
.accept 8425 >> Accept Voodoo Feathers
.target Fallen Hero of the Horde
step << Shaman
.xp <50,1
#completewith next
.zone Ironforge >> Travel to Ironforge
step << Shaman
.xp <50,1
.goto Ironforge,55.436,28.942
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Farseer Javad|r
.accept 8410 >> Accept Elemental Mastery
.target Farseer Javad
step << Shaman
.xp <50,1
#ah
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to an |cRXP_FRIENDLY_Auctioneer|r in a major city
>>|cRXP_BUY_Buy a the following from the Auction House. You will need this later for your Sunken Temple class quest|r
>>|cRXP_WARN_Skip this step if you can't acquire them|r
.collect 7070,1,8410,1 
.collect 7069,1,8410,1 
.collect 7068,1,8410,1 
.collect 7067,1,8410,1 
step << Shaman
.xp <50,1
#completewith next
.goto Ironforge,55.501,47.742
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gryth Thurden|r
.fly Arathi >> Fly to Arathi Highlands
.target Gryth Thurden
.zoneskip Arathi Highlands
.zoneskip Alterac Mountains
.zoneskip Hillsbrad Foothills
step << Shaman
.xp <50,1
>>Kill |cRXP_ENEMY_Cresting Exiles|r, |cRXP_ENEMY_Thundering Exiles|r, |cRXP_ENEMY_Rumbling Exiles|r and |cRXP_ENEMY_Burning Exiles|r. Loot them for their |cRXP_LOOT_Elemental Water|r, |cRXP_LOOT_Elemental Air|r, |cRXP_LOOT_Elemental Earth|r and |cRXP_LOOT_Elemental Fire|r
.collect 7070,1,8410,1 
.mob +Cresting Exile
.goto Arathi Highlands,66.8,31.0
.collect 7069,1,8410,1 
.mob +Thundering Exile
.goto Arathi Highlands,52.0,50.6
.collect 7067,1,8410,1 
.mob +Rumbling Exile
.goto Arathi Highlands,36.4,57.6
.collect 7068,1,8410,1 
.mob +Burning Exile
.goto Arathi Highlands,25.4,30.6
step << Shaman
.xp <50,1
#completewith next
.zone Alterac Mountains >> Travel to Alterac Mountains
step << Shaman
.xp <50,1
.goto Alterac Mountains,80.497,66.919
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bath'rah the Windwatcher|r
.turnin 8410 >> Turn in Elemental Mastery
.accept 8412 >> Accept Spirit Totem
.target Bath'rah the Windwatcher
step << Shaman
.xp <50,1
#phase 4-6 << !tbc !wotlk
#completewith next
.zone Western Plaguelands >>Travel to Western Plaguelands
step << Shaman
.xp <50,1
#phase 4-6 << !tbc !wotlk
#loop
.goto Western Plaguelands,34.60,65.80,0
.goto Western Plaguelands,34.60,65.80,60,0
.goto Western Plaguelands,33.60,63.20,60,0
.goto Western Plaguelands,31.80,63.60,60,0
.goto Western Plaguelands,32.00,59.60,60,0
.goto Western Plaguelands,30.80,50.20,60,0
.goto Western Plaguelands,32.80,56.00,60,0
.goto Western Plaguelands,36.00,58.40,60,0
.goto Western Plaguelands,34.00,61.80,60,0
>>Kill |cRXP_ENEMY_Venom Mist Lurkers|r, |cRXP_ENEMY_Carrion Vultures|r and |cRXP_ENEMY_Diseased Black Bears|r. Loot them for their |cRXP_LOOT_Eyes|r and |cRXP_LOOT_Claws|r
.complete 8412,1 
.mob +Carrion Vulture
.mob +Venom Mist Lurker
.complete 8412,2 
.mob +Diseased Black Bear
.mob +Carrion Vulture
step << Shaman
.xp <50,1
#phase 4-6 << !tbc !wotlk
#completewith next
.zone Alterac Mountains >>Travel to Alterac Mountains
step << Shaman
.xp <50,1
#phase 4-6 << !tbc !wotlk
.goto Alterac Mountains,80.50,66.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bath'rah|r
.turnin 8412 >>Turn in Spirit Totem
.accept 8413 >>Accept Da Voodoo
.target Bath'rah the Windwatcher
step
#completewith next
.zone The Hinterlands >> Travel to The Hinterlands
step
.goto The Hinterlands,33.751,75.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Atal'ai Exile|r
.accept 1446 >> Accept Jammal'an the Prophet
.target Atal'ai Exile
step
#completewith next
.zone Feralas >> Travel to Feralas
step
.goto Feralas,31.828,45.611
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Angelas Moonbreeze|r
.accept 3445 >> Accept The Sunken Temple
.target Angelas Moonbreeze
step
#completewith next
.zone Tanaris >> Travel to Tanaris
step
.goto Tanaris,52.707,45.923
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marvon Rivetseeker|r
.turnin 3445 >> Turn in The Sunken Temple
.accept 3444 >> Accept The Stone Circle
.target Marvon Rivetseeker
step
#completewith next
.zone The Barrens >> Travel to Ratchet in The Barrens
step
.goto The Barrens,62.500,38.546
>>Open |cRXP_PICK_Marvon's Chest|r. Loot it for the |cRXP_LOOT_Stone Circle|r
.complete 3444,1 
step
#completewith next
.zone Tanaris >> Travel to Tanaris
step
.goto Tanaris,52.707,45.923
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marvon Rivetseeker|r
.turnin 3444 >> Turn in The Stone Circle
.accept 3446 >> Accept Into the Depths
.accept 3447 >> Accept Secret of the Circle
.target Marvon Rivetseeker
step
#optional
.isQuestTurnedIn 4787 
.goto Tanaris,66.989,22.354
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yeh'kinya|r
.accept 3528 >> Accept The God Hakkar
.target Yeh'kinya
step
#completewith next
.zone Stormwind City >> Travel to Stormwind
step
.isQuestTurnedIn 1469
.goto StormwindClassic,64.328,20.627
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Brohann Caskbelly|r
.accept 1475 >> Accept Into The Temple of Atal'Hakkar
.target Brohann Caskbelly
step
#completewith STEntry
.zone Blasted Lands >> You will now run Sunken Temple. Start looking for a group. You may fly to Blasted Lands and grind mobs there while you form a group
.zoneskip Swamp of Sorrows
.zoneskip 1415
step
#label STEntry
.goto 1415,56.33,76.28
.subzone 1477 >> Travel to Sunken Temple once your group is ready
step
.isOnQuest 1475
#completewith next
>>Loot the |cRXP_LOOT_Atal'ai Tablets|r on the ground
>>|cRXP_WARN_These can be looted en-route to the instance portal, as well as inside Sunken Temple|r
.complete 1475,1 
step
.goto 1415,56.33,76.28,40,0
.goto 1415,56.46,75.54,20,0
.goto 1415,56.83,75.86,20,0
.goto 1415,56.94,76.03,15,0
.goto 1415,57.06,75.58,20,0
.goto 1415,56.76,75.35,15,0
.goto 1415,56.809,75.151
.subzone 1477,2 >> Zone into Sunken Temple
step
.isOnQuest 1475
#sticky
>>Loot the |cRXP_LOOT_Atal'ai Tablets|r on the ground
.complete 1475,1 
step << Druid
.isOnQuest 9053
#completewith Altar
>>Kill |cRXP_ENEMY_Atal'alarion|r. Loot him for the |cRXP_LOOT_Putrid Vine|r
>>|cRXP_ENEMY_Atal'alarion|r |cRXP_WARN_is on the lower level of Sunken Temple and is summoned by clicking all |cRXP_PICK_Atal'ai Statues|r on the platforms|r
.complete 9053,1 
step 
.isOnQuest 3446
#completewith next
>>Click on the |cRXP_PICK_Altar of Hakkar|r
>>|cRXP_WARN_The |cRXP_PICK_Altar of Hakkar|r is located on the lower level of Sunken Temple|r
.turnin 3446 >> Turn in Into the Depths
step 
.isOnQuest 3447
>>Click on the |cRXP_PICK_Idol of Hakkar|r
>>|cRXP_WARN_Clicking all of the |cRXP_PICK_Atal'ai Statues|r on the platforms will activate the|r |cRXP_PICK_Idol of Hakkar|r
>>|cRXP_WARN_The |cRXP_PICK_Idol of Hakkar|r is located on the lower level of Sunken Temple|r
.turnin 3447 >> Turn in Secret of the Circle
step 
.isOnQuest 3446
#label Altar
>>Click on the |cRXP_PICK_Altar of Hakkar|r
>>|cRXP_WARN_The |cRXP_PICK_Altar of Hakkar|r is located on the lower level of Sunken Temple|r
.turnin 3446 >> Turn in Into the Depths
step << Druid
.isOnQuest 9053
>>Kill |cRXP_ENEMY_Atal'alarion|r. Loot him for the |cRXP_LOOT_Putrid Vine|r
>>|cRXP_ENEMY_Atal'alarion|r |cRXP_WARN_is on the lower level of Sunken Temple and is summoned by clicking all |cRXP_PICK_Atal'ai Statues|r on the platforms|r
.complete 9053,1 
step << Paladin/Warrior/Warlock/Shaman
.isOnQuest 8418,8425,8422
>>Kill |cRXP_ENEMY_Gasher|r and |cRXP_ENEMY_Zul'Lor|r. Loot them for their |cRXP_LOOT_Amber Voodoo Feathers|r
>>Kill |cRXP_ENEMY_Mijan|r and |cRXP_ENEMY_Hukku|r. Loot them for their |cRXP_LOOT_Blue Voodoo Feathers|r
>>Kill |cRXP_ENEMY_Zolo|r and |cRXP_ENEMY_Loro|r. Loot them for their |cRXP_LOOT_Green Voodoo Feathers|r
>>|cRXP_WARN_This quest is completed on the upper level of Sunken Temple|r
.complete 8418,1 << Paladin 
.complete 8418,2 << Paladin 
.complete 8418,3 << Paladin 
.complete 8425,1 << Warrior 
.complete 8425,2 << Warrior 
.complete 8425,3 << Warrior 
.complete 8422,1 << Warlock 
.complete 8422,2 << Warlock 
.complete 8422,3 << Warlock 
.complete 8413,1 << Shaman 
.complete 8413,2 << Shaman 
.complete 8413,3 << Shaman 
step
.isOnQuest 3528
>>|cRXP_WARN_Use the|r |T132834:0|t[Egg of Hakkar] |cRXP_WARN_while next to the Dragonflayer Skeleton, then complete the event|r
>>Kill the minions of |cRXP_ENEMY_Hakkar|r until the |cRXP_ENEMY_Avatar of Hakkar|r joins
>>Kill the |cRXP_ENEMY_Avatar of Hakkar|r. Loot it for the |T136148:0|t[|cRXP_LOOT_Essence of Hakkar|r]
>>|cRXP_WARN_Use the|r |T136148:0|t[|cRXP_LOOT_Essence of Hakkar|r] |cRXP_WARN_to fill the|r |T132834:0|t[Egg of Hakkar]
.collect 10663,1,3528,1 
.disablecheckbox
.complete 3528,1 
.use 10465 
.use 10663 
step
.isOnQuest 1446
>>Kill |cRXP_ENEMY_Jammal'an the Prophet|r. Loot him for his |cRXP_LOOT_Head|r
>>|cRXP_WARN_You must kill the 6 |cRXP_ENEMY_Trolls|r on the upper platforms to gain access to|r |cRXP_ENEMY_Jammal'an the Prophet|r
.complete 1446,1 
step << Hunter/Mage/Priest/Rogue
.isOnQuest 8232,8253,8257,8236
>>Kill |cRXP_ENEMY_Morphaz|r. Loot it for the |cRXP_LOOT_Tooth of Morphaz|r << Hunter
>>Kill |cRXP_ENEMY_Morphaz|r. Loot it for the |cRXP_LOOT_Arcane Shard|r << Mage
>>Kill |cRXP_ENEMY_Morphaz|r. Loot it for the |cRXP_LOOT_Blood of Morphaz|r << Priest
>>Kill |cRXP_ENEMY_Morphaz|r. Loot it for the |cRXP_LOOT_Azure Key|r << Rogue
.complete 8232,1 << Hunter 
.complete 8253,1 << Mage 
.complete 8257,1 << Priest 
.complete 8236,1 << Rogue 
step
>>Kill the |cRXP_ENEMY_Shade of Eranikus|r. Loot him for the |T135229:0|t[|cRXP_LOOT_Essence of Eranikus|r]
>>|cRXP_WARN_Use the |T135229:0|t[|cRXP_LOOT_Essence of Eranikus|r] to start the quest|r
>>|cRXP_WARN_Ensure you have killed all |cRXP_ENEMY_Dragonkin|r mobs on the upper level before engaging the |cRXP_ENEMY_Shade of Eranikus|r otherwise they will all agro onto you|r
.collect 10454,1,3373,1 
.accept 3373 >> Accept The Essence of Eranikus
step
.isOnQuest 3373
>>Click the |cRXP_PICK_Essence Font|r
.turnin 3373 >> Turn in The Essence of Eranikus
step << Warrior
.isQuestComplete 8425
.goto Swamp of Sorrows,34.287,66.134
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Fallen Hero of the Horde|r
>>|cRXP_WARN_It is strongly advised you choose the|r |T132788:0|t[|cFF0070FFDiamond Flask|r] |cRXP_WARN_as your reward. Although the other rewards are also very good, you will not ever replace the|r |T132788:0|t[|cFF0070FFDiamond Flask|r]
.turnin 8425 >> Turn in Voodoo Feathers
.target Fallen Hero of the Horde
step
#completewith TempleTurnIn
.zone Stormwind City >> Travel to Stormwind
step
.goto Blasted Lands,65.535,24.337
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Alexandra Constantine|r
.fly Stormwind >> Fly to Stormwind
.target Alexandra Constantine
.zoneskip Stormwind City
step
#label TempleTurnIn
.isQuestComplete 1475
.goto StormwindClassic,64.328,20.627
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Brohann Caskbelly|r
.turnin 1475 >> Turn in Into The Temple of Atal'Hakkar
.target Brohann Caskbelly
step << Paladin
#completewith next
.zone Western Plaguelands >> Travel to Western Plaguelands
step << Paladin
.isQuestComplete 8418
.goto Western Plaguelands,42.702,84.031
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Ashlam Valorfist|r
.turnin 8418 >> Turn in Forging the Mightstone
.target Commander Ashlam Valorfist
step << Mage/Rogue/Hunter/Priest
#completewith next
.zone Azshara >> Travel to Azshara
step << Mage/Rogue
.isQuestComplete 8253 << Mage
.isQuestComplete 8236 << Rogue
#completewith next
.goto Azshara,28.113,50.088
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sanath Lim-yo|r
>>|cRXP_WARN_This will teleport you to the top of the mountain|r
.turnin 3503 >> Turn in Meeting with the Master
.target Sanath Lim-yo
step << Mage/Rogue
.isQuestComplete 8253 << Mage
.isQuestComplete 8236 << Rogue
.goto Azshara,29.248,40.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archamge Xylem|r atop the Tower
.turnin 8253 >> Turn in Destroy Morphaz << Mage
.turnin 8236 >> Turn in The Azure Key << Rogue
.target Archamge Xylem
step << Mage/Rogue
.isQuestTurnedIn 8253 << Mage
.isQuestTurnedIn 8236 << Rogue
#completewith ArcaneRunes
.goto Azshara,26.466,46.271
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nyrill|r
>>|cRXP_WARN_This will teleport you back down|r
.turnin 3421 >> Turn in Return Trip
.timer 8,Return Trip RP
.target Nyrill
step << Hunter/Priest
.isQuestComplete 8232 << Hunter
.isQuestComplete 8257 << Priest
.goto Azshara,42.400,42.619
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
.turnin 8232 >> Turn in The Green Drake << Hunter
.turnin 8257 >> Turn in Blood of Morphaz << Priest
.target Ogtinc
step << Druid
#completewith next
.zone Un'Goro Crater >> Travel to Un'Goro Crater
step << Druid
.isQuestComplete 9053
.goto Un'Goro Crater,71.639,75.960
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Torwa Pathfinder|r
.turnin 9053 >> Turn in A Better Ingredient
.target Torwa Pathfinder
step << Druid
#completewith next
.zone Tanaris >> Travel to Tanaris
step << Druid
.isQuestComplete 3528
.goto Tanaris,66.989,22.354
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yeh'kinya|r
.turnin 3528 >> Turn in The God Hakkar
.target Yeh'kinya
step << Warlock
#completewith next
.zone Felwood >> Travel to Felwood
step << Warlock
.isQuestComplete 8422
.goto Felwood,41.52,44.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Impsy|r
.turnin 8422 >> Turn in Trolls of a Feather
.target Impsy
step
#completewith next
.zone The Hinterlands >> Travel to The Hinterlands
step
.isQuestComplete 1446
.goto The Hinterlands,33.751,75.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Atal'ai Exile|r
.turnin 1446 >> Turn in Jammal'an the Prophet
.target Atal'ai Exile
step << Shaman
#completewith next
.zone Alterac Mountains >> Travel to Alterac Mountains
step << Shaman
.isQuestComplete 8413
.goto Alterac Mountains,80.50,66.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bath'rah|r
.turnin 8413 >>Turn in Da Voodoo
.target Bath'rah the Windwatcher
step << !Druid
#completewith next
.zone Tanaris >> Travel to Tanaris
step << !Druid
.isQuestComplete 3528
.goto Tanaris,66.989,22.354
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yeh'kinya|r
.turnin 3528 >> Turn in The God Hakkar
.target Yeh'kinya
step
+|cRXP_WARN_You have completed the Sunken Temple quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 50-60
<< Alliance
#name 13. Blackrock Depths
step
#completewith AcceptBRDQuests
+You will now fly around to accept quests for Blackrock Depths.
>>Blackrock Depths is a very convoluted dungeon. In order to complete all quests in the most efficient way, it is required to leave the dungeon midrun to turn in/accept follow up quests so it may all be completed in 1 run.
>>Try to ensure all party members have the same quests and prequests complete, along with 2-3 hours of playtime.
step
.isQuestTurnedIn 3481
>>Remember to take out |T134430:0|t[Black Dragonflight Molt] from your bank if you completed the quest in Searing Gorge for it earlier. You will need it shortly
.collect 10575,1,4022,1 
step
#completewith HurleyBlackbreath
.zone Ironforge >> Travel to Ironforge
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Innkeeper Firebrew|r
>>|cRXP_WARN_If you have a Mage in your group you will set your Hearth to Lakeshire instead|r
.goto Ironforge,18.10,51.60
.home >> Set your Hearthstone to Ironforge
.target Innkeeper Firebrew
step 
.isQuestTurnedIn 3701
.goto Ironforge,39.09,56.19
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_King Magni Bronzebeard|r
.accept 4341 >> Accept Kharan Mighthammer
.target King Magni Bronzebeard
step
.isQuestComplete 4513
.goto Ironforge,75.768,23.389
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Laris Geardawdle|r
.turnin 4513 >> Turn in A Little Slime Goes a Long Way
.target Laris Geardawdle
step
#completewith next
.subzone 131 >> Travel to Kharanos
step
#label HurleyBlackbreath
.goto Dun Morogh,46.825,52.361
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ragnar Thunderbrew|r
.accept 4126 >> Accept Hurley Blackbreath
.target Ragnar Thunderbrew
step
>>|cRXP_WARN_Fly to Lakeshire. Set your Hearthstone to Lakeshire ONLY if you have a Mage in your group for BRD, if not skip this step and leave your Hearth in Ironforge|r
.home >> Set your Hearthstone to Lakeshire
step
#completewith BSQuests
.fly Burning Steppes >> Fly to Burning Steppes from your nearest Flight Master
step
.goto Burning Steppes,84.555,68.679
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Oralius|r
.accept 4286 >> Accept The Good Stuff
.target Oralius
step
.goto Burning Steppes,84.744,69.015
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marshal Maxwell|r
>>|cRXP_WARN_If you cannot accept this quest complete the Dragonkin Menace quest chain|r
.accept 4241 >> Accept Marshal Windsor
.target Marshal Maxwell
step
.goto Burning Steppes,85.415,70.064
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jalinda Sprig|r
.accept 4262 >> Accept Overmaster Pyron
.target Jalinda Sprig
step
.isQuestTurnedIn 3481
.goto Burning Steppes,95.061,31.563
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Cyrus Therepentous|r
>>Select the option: "I present you with proof of my deeds, Cyrus."
.accept 4022 >> Accept A Taste of Flame
.turnin 4022 >> Turn in A Taste of Flame
.itemcount 10575,1 
.target Cyrus Therepentous
step
.isQuestAvailable 4022
.goto Burning Steppes,95.061,31.563
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Cyrus Therepentous|r
>>If you are missing the |T134430:0|t[Black Dragonflight Molt] and cannot complete the quest, talk to |cRXP_FRIENDLY_Cyrus|r and select the option: "I do not possess any proof, Cyrus."
>>This will spawn a level 54 Elite Dragon at the entrance of the small cave. Ensure you have party members with you to help kill it, then loot it for the |T134430:0|t[Black Dragonflight Molt]
>>Select the option after: "I present you with proof of my deeds, Cyrus."
.collect 10575,1,4022,1 
.accept 4022 >> Accept A Taste of Flame
.turnin 4022 >> Turn in A Taste of Flame
.target Cyrus Therepentous
step
.isQuestTurnedIn 4022
.goto Burning Steppes,95.061,31.563
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Cyrus Therepentous|r
.accept 4024 >> Accept A Taste of Flame
.target Cyrus Therepentous
step
.goto Burning Steppes,65.152,23.911
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Maxwort Uberglint|r
.accept 4123 >> Accept The Heart of the Mountain
.target Maxwort Uberglint
step
#label BSQuests
.goto Burning Steppes,66.058,21.951
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yuka Screwspigot|r
.accept 4136 >> Accept Ribbly Screwspigot
.target Yuka Screwspigot
step
#softcoreserver
#softcore
+Die intentionally in the lava in Blackrock Mountain, ideally near the Molten Core entrance location
>>For this step you must be a |T132331:0|t[Ghost] to talk to |cRXP_FRIENDLY_Franclorn Forgewright|r inside Blackrock Mountain. Resurrect at your corpse once you have the quest
.goto 1415,48.624,64.186
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Franclorn Forgewright|r
.accept 3801 >> Accept Dark Iron Legacy
.turnin 3801 >> Turn in Dark Iron Legacy
.accept 3802 >> Accept Dark Iron Legacy
.target Franclorn Forgewright
step
#hardcoreserver
.goto 1415,48.656,64.134
.cast 417803 >>Click the |cRXP_PICK_Brazier of Embersight|r to gain the |T136215:0|t[Emberglow Vision] debuff
step
#hardcoreserver
.goto 1415,48.624,64.186
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Franclorn Forgewright|r
>>You must have the |T136215:0|t[Emberglow Vision] debuff to see him
.accept 3801 >> Accept Dark Iron Legacy
.turnin 3801 >> Turn in Dark Iron Legacy
.accept 3802 >> Accept Dark Iron Legacy
.target Franclorn Forgewright
step
#label AcceptBRDQuests
.goto 1415,48.409,63.815
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lothos Riftwaker|r
.accept 7848 >> Accept Attunement to the Core
.target Lothos Riftwaker
step
.isOnQuest 4262
>>Kill |cRXP_ENEMY_Overmaster Pyron|r
>>|cRXP_ENEMY_Overmaster Pyron|r |cRXP_WARN_patrols outside of the BRD instance portal|r
.complete 4262,1 
.mob Overmaster Pyron
step
.subzone 1584,2 >>Enter Blackrock Depths
step
#completewith FannyPack
.isOnQuest 4286
>>Kill |cRXP_ENEMY_Dwarves|r inside of BRD. Loot them for their |cRXP_LOOT_Dark Iron Fanny Packs|r
.complete 4286,1 
step
.isOnQuest 4341
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kharan Mighthammer|r
>>If your group does not have a Rogue you may need to kill |cRXP_ENEMY_High Interrogator Gerstahn|r for the |cRXP_LOOT_Prison Cell Key|r to open the doors
.turnin 4341 >> Turn in Kharan Mighthammer
.accept 4342 >> Accept Kharan's Tale
step
.isQuestTurnedIn 4341
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kharan Mighthammer|r
.accept 4342 >> Accept Kharan's Tale
step
.isQuestTurnedIn 4341
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kharan Mighthammer|r
.complete 4342,1 
.skipgossip
step
.isQuestTurnedIn 4341
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kharan Mighthammer|r
.turnin 4342 >> Turn in Kharan's Tale
.accept 4361 >> Accept The Bearer of Bad News
step
.isOnQuest 4241
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marshal Windsor|r
>>If your group does not have a Rogue you may need to kill |cRXP_ENEMY_High Interrogator Gerstahn|r for the |cRXP_LOOT_Prison Cell Key|r to open the doors
.turnin 4241 >> Turn in Marshal Windsor
.accept 4242 >> Accept Abandoned Hope
step
.isQuestTurnedIn 4241
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marshal Windsor|r
.accept 4242 >> Accept Abandoned Hope
step
#completewith next
+Hearth to Ironforge if your Hearth was set there. If you have a Mage in group, kindly ask them for a portal to Ironforge
step
.isQuestTurnedIn 4341
.goto Ironforge,39.09,56.19
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_King Magni Bronzebeard|r
.turnin 4361 >> Turn in The Bearer of Bad News
.accept 4362 >> Accept The Fate of the Kingdom
.target King Magni Bronzebeard
step
#completewith PyronIncendius
>>Hearth to Lakeshire if your Hearth is set there. Otherwise fly to Burning Steppes manually
.fly Burning Steppes >> Fly to Burning Steppes
step
.isQuestComplete 4286
.goto Burning Steppes,84.555,68.679
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Oralius|r
.turnin 4286 >> Turn in The Good Stuff
.target Oralius
step
.isOnQuest 4242
.goto Burning Steppes,84.744,69.015
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marshal Maxwell|r
>>|cRXP_WARN_The quest chain will stop here until you find|r |T134331:0|t[A Crumpled Up Note] |cRXP_WARN_at BRD|r
.turnin 4242 >> Turn in Abandoned Hope
.target Marshal Maxwell
step
.isQuestComplete 4262
.goto Burning Steppes,85.415,70.064
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jalinda Sprig|r
.turnin 4262 >> Turn in Overmaster Pyron
.accept 4263 >> Accept Incendius!
.target Jalinda Sprig
step
#label PyronIncendius
.isQuestTurnedIn 4262
.goto Burning Steppes,85.415,70.064
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jalinda Sprig|r
.accept 4263 >> Accept Incendius!
.target Jalinda Sprig
step
.subzone 1584,2 >>Enter Blackrock Depths
step
#completewith next
+Complete the Ring of Law boss event, then take the exit up the tunnel and immediately turn right, crossing up over the top of the Ring of Law, making your way to the Vault
step
.isOnQuest 4123
>>Loot |cRXP_LOOT_The Heart of the Mountain|r inside of the safe wall. It takes 15 seconds for it to respawn
>>There is a trick which allows you to loot it without having to open the safe. View the link below to see how it is done
.complete 4123,1 
.link https://youtu.be/rg_UPmatbSw >> Click here to see how to loot the Heart of the Mountain
step
.isOnQuest 3802
>>Kill |cRXP_ENEMY_Fineous Darkvire|r. Loot him for the |cRXP_LOOT_Ironfel|r
.complete 3802,1 
step
.isOnQuest 4263
>>Kill |cRXP_ENEMY_Lord Incendius|r
.complete 4263,1 
step
.isQuestComplete 3802
>>Run back near the location above the Ring of Law
>>Click the |cRXP_PICK_Monument of Franclorn Forgewright|r
.turnin 3802 >> Turn in Dark Iron Legacy
step
.isOnQuest 4024
>>Head to the Shadowforge Gates at the start of the entrance
>>Kill |cRXP_ENEMY_Bael'Gar|r
.use 11231 >>|cRXP_WARN_Use the|r |T134430:0|t[Altered Black Dragonflight Molt] |cRXP_WARN_on his corpse|r
.complete 4024,1 
step
.isQuestTurnedIn 4242
>>Kill |cRXP_ENEMY_Dwarves|r at BRD. Loot them for |T134331:0|t[A Crumpled Up Note]
.use 11446 >> |cRXP_WARN_Use|r |T134331:0|t[A Crumpled Up Note] |cRXP_WARN_to start the quest|r
>>|cRXP_WARN_It is important you do this before killing bosses |cRXP_ENEMY_General Angerforge|r and|r |cRXP_ENEMY_Golem Lord Argelmach|r
>>|cRXP_WARN_If you still have not found this by now clear around the Detention Block until it drops|r
.collect 11446,1,4264,1 
.accept 4264 >> Accept A Crumpled Up Note
step
.isOnQuest 4264
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marshal Windsor|r
.turnin 4264 >> Turn in A Crumpled Up Note
.accept 4282 >> Accept A Shred of Hope
step
.isQuestTurnedIn 4264
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marshal Windsor|r
.accept 4282 >> Accept A Shred of Hope
step
.isOnQuest 4282
>>Kill |cRXP_ENEMY_General Angerforge|r and |cRXP_ENEMY_Golem Lord Argelmach|r. Loot them both for |cRXP_LOOT_Marshal Windsor's Lost Information|r
.complete 4282,1 
.complete 4282,2 
step
.isQuestTurnedIn 4264
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marshal Windsor|r
>>|cRXP_WARN_ENSURE ALL PARTY MEMBERS HAVE AUTO ACCEPT OFF FOR THIS STEP! RestedXP HAS AUTO ACCEPT OFF FOR THIS STEP|r
>>|cRXP_WARN_Accepting this quest will begin the Jail Break escort. Ensure you have cleared all of the Detention Block area for an easier time escorting|r |cRXP_FRIENDLY_Marshal Windsor|r
.turnin 4282 >> Turn in A Shred of Hope
.accept 4322,1 >> Accept Jail Break!
step
.isOnQuest 4322
>>Escort |cRXP_FRIENDLY_Marshal Windsor|r through BRD
.complete 4322,1 
step
#completewith next
.isOnQuest 4126
>>Enter the Bar and go into the small room on the left. Do NOT attack any of the neutral mobs while running through the Bar
>>Click on the 3 |cRXP_PICK_Thunderbrew Lager Kegs|r to destroy them, forcing |cRXP_ENEMY_Hurley Blackbreath|r and his 3 |cRXP_ENEMY_Blackbreath Cronies|r to engage
>>Kill |cRXP_ENEMY_Hurley Blackbreath|r. Loot him for the |cRXP_LOOT_Lost Thunderbrew Recipe|r
.complete 4126,1 
step
.isOnQuest 4136
>>Enter the Bar and go into the small room on the left. Do NOT attack any of the neutral mobs while running through the Bar
>>Kill |cRXP_ENEMY_Ribbly Screwspigot|r. Loot him for his |cRXP_LOOT_Head|r
>>To engage |cRXP_ENEMY_Ribbly Screwspigot|r have your tank talk to him, then bring him back along with his |cRXP_ENEMY_Cronies|r into the room with the kegs
.complete 4136,1 
.skipgossip
step
.isOnQuest 4126
>>Enter the Bar and go into the small room on the left. Do NOT attack any of the neutral mobs while running through the Bar
>>Click on the 3 |cRXP_PICK_Thunderbrew Lager Kegs|r to destroy them, forcing |cRXP_ENEMY_Hurley Blackbreath|r and his 3 |cRXP_ENEMY_Blackbreath Cronies|r to engage
>>Kill |cRXP_ENEMY_Hurley Blackbreath|r. Loot him for the |cRXP_LOOT_Lost Thunderbrew Recipe|r
.complete 4126,1 
step
.isOnQuest 7848
>>Loot the |cRXP_LOOT_Core Fragment|r on the ground outside of the Molten Core instance portal
.complete 7848,1 
step
.isOnQuest 4362
>>Kill |cRXP_ENEMY_Emperor Dagran Thaurissan|r
>>|cRXP_WARN_You must NOT kill |cRXP_ENEMY_Princess Moira Bronzebeard|r in order to complete and turn in this quest|r
>>|cRXP_WARN_Have a party member kite |cRXP_ENEMY_Princess Moira Bronzebeard|r while the rest of the group kills|r |cRXP_ENEMY_Emperor Dagran Thaurissan|r
.complete 4362,1 
step
.isQuestComplete 4362
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Princess Moira Bronzebeard|r
.turnin 4362 >> Turn in The Fate of the Kingdom
.accept 4363 >> Accept The Princess's Surprise
.target Princess Moira Bronzebeard
step
.isQuestTurnedIn 4362
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Princess Moira Bronzebeard|r
.accept 4363 >> Accept The Princess's Surprise
.target Princess Moira Bronzebeard
step
#completewith HurleyTurnin
#label FannyPack
+Hearth to Ironforge if your Hearth was set there. If you have a Mage in group, kindly ask them for a portal to Ironforge
step
.isOnQuest 4363
.goto Ironforge,39.09,56.19
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_King Magni Bronzebeard|r
.turnin 4363 >> Turn in The Princess's Surprise
.target King Magni Bronzebeard
step
#completewith next
+Travel to Kharanos
step
#label HurleyTurnin
.isQuestComplete 4126
.goto Dun Morogh,46.825,52.361
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ragnar Thunderbrew|r
.turnin 4126 >> Turn in Hurley Blackbreath
.target Ragnar Thunderbrew
step
#completewith BSTurnins
>>Hearth to Lakeshire if your Hearth is set there. Otherwise fly to Burning Steppes manually
.fly Burning Steppes >> Fly to Burning Steppes
step
.isQuestComplete 4286
.goto Burning Steppes,84.555,68.679
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Oralius|r
.turnin 4286 >> Turn in The Good Stuff
.target Oralius
step
.isQuestComplete 4322
.goto Burning Steppes,84.744,69.015
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marshal Maxwell|r
.turnin 4322 >> Turn in Jail Break!
.accept 6402 >> Accept Stormwind Rendezvous
.target Marshal Maxwell
step
.isQuestTurnedIn 4322
.goto Burning Steppes,84.744,69.015
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marshal Maxwell|r
.accept 6402 >> Accept Stormwind Rendezvous
.target Marshal Maxwell
step
.isQuestComplete 4263
.goto Burning Steppes,85.415,70.064
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jalinda Sprig|r
.turnin 4263 >> Turn in Incendius!
.target Jalinda Sprig
step
.isQuestComplete 4024
.goto Burning Steppes,95.061,31.563
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Cyrus Therepentous|r
.turnin 4024 >> Turn in A Taste of Flame
.target Cyrus Therepentous
step
.isQuestComplete 4123
.goto Burning Steppes,65.152,23.911
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Maxwort Uberglint|r
.turnin 4123 >> Turn in The Heart of the Mountain
.target Maxwort Uberglint
step
#label BSTurnins
.isQuestComplete 4136
.goto Burning Steppes,66.058,21.951
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yuka Screwspigot|r
.turnin 4136 >> Turn in Ribbly Screwspigot
.target Yuka Screwspigot
step
.isQuestTurnedIn 4322
.goto Burning Steppes,84.334,68.326
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Borgun Stoutarm|r
>>Have a Mage port you if you have one in your group
.fly Stormwind >> Fly to Stormwind
.target Borgun Stoutarm
.zoneskip Stormwind City
step
.isQuestTurnedIn 4322
#completewith next
.goto StormwindClassic,70.424,85.171,5,0
.goto StormwindClassic,69.709,86.083
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Squire Rowe|r and |cRXP_FRIENDLY_Reginald Windsor|r
>>|cRXP_FRIENDLY_Squire Rowe|r will call for |cRXP_FRIENDLY_Reginald Windsor's|r arrival after you talk to him at the Gates of Stormwind
>>|cRXP_WARN_IF YOU ARE IN A PARTY ENSURE NO ONE AUTO ACCEPTS The Great Masquerade. AUTO ACCEPT HAS BEEN TURNED OFF FOR THIS STEP|r
.turnin 6402 >> Turn in Stormwind Rendezvous
.accept 6403,1 >> Accept The Great Masquerade
.skipgossip
.target Squire Rowe
.target Reginald Windsor
step
.isQuestTurnedIn 4322
.goto StormwindClassic,75.955,19.114,-1
.goto StormwindClassic,76.865,20.830,-1
>>Escort |cRXP_FRIENDLY_Reginald Windsor|r into Stormwind Keep
>>Do not assist |cRXP_FRIENDLY_Reginald Windsor|r in combat while inside the Keep. If you do so there is a high chance you may die. Stay back at the arrow location and let the event finish on its own. It will take a few minutes
.complete 6403,1 
.target Reginald Windsor
step
.isQuestComplete 6403
.goto StormwindClassic,77.569,18.864
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Highlord Bolvar Fordragon|r
.turnin 6403 >> Turn in The Great Masquerade
.accept 6501 >> Accept The Dragon's Eye
.target Highlord Bolvar Fordragon
step
.isQuestComplete 7848
.goto 1415,48.409,63.815
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lothos Riftwaker|r
>>|cRXP_WARN_You can either turn this in now or the next time you are in Blackrock Mountain|r
.turnin 7848 >> Turn in Attunement to the Core
.target Lothos Riftwaker
step
+|cRXP_WARN_You have completed the Blackrock Depths quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 50-60
<< Alliance
#name 14. Lower Blackrock Spire
step
#completewith BurningAccept
+Start looking for a group for LBRS as you acquire all of the quests
step
#optional
#completewith next
.zone Tanaris >> Travel to Tanaris
step
#optional
.isQuestTurnedIn 5065
.goto Tanaris,66.88,24.03
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Prospector Ironboot|r
.accept 4788 >> Accept The Final Tablets
.target Prospector Ironboot
step
#completewith next
.zone Burning Steppes >> Travel to Burning Steppes
step
.goto Burning Steppes,85.820,68.948
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Helendis Riverhorn|r
.accept 4701 >> Accept Put Her Down
.target Helendis Riverhorn
step
.goto Burning Steppes,65.8,22.0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kibler|r
.accept 4862 >> Accept En-Ay-Es-Tee-Why
.accept 4729 >> Accept Kibler's Exotic Pets
.target Kibler
step
#completewith Bijou
.subzone 254 >>Travel to Blackrock Mountain
step
.goto Eastern Kingdoms,48.95,63.89
.subzone 1583 >>Enter Blackrock Spire
step
#completewith Bijou
+Talk to |cRXP_FRIENDLY_Warosh|r and |cRXP_FRIENDLY_Bijou|r inside Lower Blackrock Spire
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bijou|r
.accept 4867 >>Accept Urok Doomhowl
.target Warosh
step
#label Bijou
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bijou|r
.accept 5001 >>Accept Bijou's Belongings
.target Bijou
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bijou|r
.accept 4867 >>Accept Urok Doomhowl
.target Warosh
step
#optional
#sticky
.isOnQuest 4788
>>Loot the |cRXP_PICK_Fifth Mosh'aru Tablet|r behind |cRXP_ENEMY_Shadow Hunter Vosh'gajin|r
>>Loot the |cRXP_PICK_Sixth Mosh'aru Tablet|r behind |cRXP_ENEMY_War Master Voone|r
.complete 4788,1 
.complete 4788,2 
step
#sticky
>>Loot |cRXP_PICK_Bijou's Belongings|r on the ground
>>|cRXP_WARN_This is a box found in a random location in LBRS. It is generally found amongst the |cRXP_ENEMY_Trolls|r or |cRXP_ENEMY_Orcs|r on the way to |cRXP_ENEMY_Mother Smolderweb|r|r
.complete 5001,1 
step
>>Loot a |T135124:0|t[|cRXP_PICK_Roughshod Pike|r] on the left hand side after crossing 2 bridges. This is used for summoning and killing |cRXP_ENEMY_Urok Doomhowl|r later
.collect 12533,1,4867,1 
step
.use 12533 >>|cRXP_WARN_Use the|r |T135124:0|t[|cRXP_PICK_Roughshod Pike|r] |cRXP_WARN_at the |cRXP_PICK_Challege to Urok|r (Skull pile) to begin the encounter|r
>>Kill the |cRXP_ENEMY_Ogre|r waves, then finally |cRXP_ENEMY_Urok Doomhowl|r. Loot him for |cRXP_LOOT_Warosh's Mojo|r
.complete 4867,1 
step
>>Kill |cRXP_ENEMY_Halycon|r
.complete 4701,1 
step
>>Kill |cRXP_ENEMY_Mother Smolderweb|r then loot the |cRXP_PICK_Spire Spider Eggs|r in the area
>>|cRXP_WARN_Note these can spawn small|r |cRXP_ENEMY_Spiderlings|r
.complete 4862,1 
step
.use 12262 >> |cRXP_WARN_Use the|r |T132599:0|t[Empty Worg Pup Cage] on the pups around |cRXP_ENEMY_Halcyon|r. Ensure to do this before you're group kills them all
.complete 4729,1 
step
>>Kill |cRXP_ENEMY_Overlord Wyrmthalak|r. Loot him for |T133473:0|t[|cRXP_LOOT_General Drakkisath's Command|r]
.use 12780 >> |cRXP_WARN_Use|r |T133473:0|t[|cRXP_LOOT_General Drakkisath's Command|r] |cRXP_WARN_to start the quest|r
.collect 12780,1,5089,1 
.accept 5089 >> Accept General Drakkisath's Command
step
.isQuestComplete 5001
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bijou|r
.turnin 5001 >>Turn in Bijou's Belongings
.accept 5002 >>Accept Message to Maxwell
.target Bijou
step
.isQuestTurnedIn 5001
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bijou|r
.accept 5002 >>Accept Message to Maxwell
.target Bijou
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bijou|r
.turnin 4867 >>Turn in Urok Doomhowl
.target Warosh
step
#completewith BSTurnins
.zone Burning Steppes >> Travel to Burning Steppes
step
.goto Burning Steppes,85.820,68.948
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Helendis Riverhorn|r
.turnin 4701 >> Turn in Put Her Down
.target Helendis Riverhorn
step
.goto Burning Steppes,65.8,22.0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kibler|r
.turnin 4862 >> Turn in En-Ay-Es-Tee-Why
.turnin 4729 >> Turn in Kibler's Exotic Pets
.target Kibler
step
#label BSTurnins
.goto Burning Steppes,84.744,69.015
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marshal Maxwell|r
.turnin 6402 >> Turn in Message to Maxwell
.turnin 5089 >> Turn in General Drakkisath's Command
.target Marshal Maxwell
step
#optional
#completewith next
.zone Tanaris >> Travel to Tanaris
step
#optional
.isQuestComplete 4788
.goto Tanaris,66.88,24.03
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Prospector Ironboot|r
.turnin 4788 >> Turn in The Final Tablets
.accept 8181 >> Accept Confront Yeh'kinya
.target Prospector Ironboot
step
#optional
.isQuestTurnedIn 4788
.goto Tanaris,66.88,24.03
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Prospector Ironboot|r
.accept 8181 >> Accept Confront Yeh'kinya
.target Prospector Ironboot
step
#optional
.isOnQuest 8181
.goto Tanaris,66.989,22.354
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yeh'kinya|r
.turnin 8181 >> Turn in Confront Yeh'kinya
.target Yeh'kinya
step
+|cRXP_WARN_You have completed the Lower Blackrock Spire quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 50-60
<< Alliance
#name 15. Upper Blackrock Spire
step
#completewith StartDungeon
.subzone 1583,2 >>|cRXP_WARN_This is a 10-man dungeon. You or somebody in your party must have the|r |T133343:0|t[|cRXP_LOOT_Seal of Ascension|r] |cRXP_WARN_to be able to enter Upper Blackrock Spire|r
step
#completewith next
.zone Azshara >>Travel to Azshara
step
.goto Azshara,79.28,73.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Hydraxis|r
>>|cRXP_WARN_These are prerequisite quests completed in Eastern Plaguelands and Silithus to unlock a quest in UBRS. Feel free to skip this|r
.accept 6804 >>Accept Poisoned Water
.accept 6805 >>Accept Stormers and Rumblers
.target Duke Hydraxis
step
#completewith next
.zone Silithus >>Travel to Silithus
step
>>Kill |cRXP_ENEMY_Dust Stormers|r and |cRXP_ENEMY_Desert Rumblers|r
.complete 6805,1 
.mob +Desert Rumbler
.goto Silithus,33.13,14.98,60,0
.goto Silithus,29.75,16.66,60,0
.goto Silithus,30.33,20.83,60,0
.goto Silithus,23.19,27.97,60,0
.goto Silithus,20.41,33.38,60,0
.goto Silithus,18.09,26.65,60,0
.goto Silithus,21.09,22.33,60,0
.goto Silithus,33.13,14.98,60,0
.goto Silithus,29.75,16.66,60,0
.goto Silithus,30.33,20.83,60,0
.goto Silithus,23.19,27.97,60,0
.goto Silithus,20.41,33.38,60,0
.goto Silithus,18.09,26.65,60,0
.goto Silithus,21.09,22.33
.complete 6805,2 
.mob +Dust Stormer
.goto Silithus,21.61,17.09,50,0
.goto Silithus,21.67,9.37,50,0
.goto Silithus,27.63,14.28,50,0
.goto Silithus,24.12,14.81,50,0
.goto Silithus,21.61,17.09,50,0
.goto Silithus,21.67,9.37,50,0
.goto Silithus,27.63,14.28,50,0
.goto Silithus,24.12,14.81
.isOnQuest 6805
step
#completewith next
.zone Eastern Plaguelands >>Travel to Eastern Plaguelands
step
#loop
.goto Eastern Plaguelands,71.34,34.07,0
.goto Eastern Plaguelands,51.36,49.77,0
.goto Eastern Plaguelands,64.58,80.71,0
.goto Eastern Plaguelands,59.71,79.12,0
.goto Eastern Plaguelands,64.58,80.71,50,0
.goto Eastern Plaguelands,59.71,79.12,50,0
>>Kill |cRXP_ENEMY_Water Elementals|r. Loot them for their |cRXP_LOOT_Discordant Bracers|r
>>|cRXP_WARN_They can be killed in three different locations in EPL. They are marked on your map|r
.complete 6804,1 
.mob Blighted Horror
.mob Plague Monstrosity
.mob Blighted Surge
.mob Plague Ravager
.isOnQuest 6804
step
#completewith EyeofEmber
.zone Azshara >>Travel to Azshara
step
.goto Azshara,79.28,73.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Hydraxis|r
.turnin 6804 >>Turn in Poisoned Water
.turnin 6805 >>Turn in Stormers and Rumblers
.accept 6821 >>Accept Eye of the Emberseer
.target Duke Hydraxis
.isQuestComplete 6804
.isQuestComplete 6805
step
#optional
.goto Azshara,79.28,73.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Hydraxis|r
.turnin 6805 >>Turn in Stormers and Rumblers
.target Duke Hydraxis
.isQuestComplete 6805
step
#optional
.goto Azshara,79.28,73.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Hydraxis|r
.turnin 6804 >>Turn in Poisoned Water
.target Duke Hydraxis
.isQuestComplete 6804
step
#label EyeofEmber
#optional
.goto Azshara,79.28,73.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Hydraxis|r
.accept 6821 >>Accept Eye of the Emberseer
.target Duke Hydraxis
.isQuestTurnedIn 6804
.isQuestTurnedIn 6805
step
#completewith EggFreezeAccept
.zone Burning Steppes >> Travel to Burning Steppes
step
.goto Burning Steppes,84.8,69.0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mayara Brightwing|r
.accept 4764 >> Accept Doomrigger's Clasp
.target Mayara Brightwing
step
.isQuestTurnedIn 5089
.goto Burning Steppes,84.744,69.015
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marshal Maxwell|r
.accept 5102 >> Accept General Drakkisath's Demise
.target Marshal Maxwell
step
.goto Burning Steppes,65.2,23.8
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tinkee|r
.accept 4734 >>Accept Egg Freezing
.target Tinkee Steamboil
step
#label EggFreezeAccept
.goto Burning Steppes,65.2,23.8
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tinkee|r
.accept 4735 >>Accept Egg Collection
.target Tinkee Steamboil
.isQuestTurnedIn 4734
step
#completewith StartDungeon
.subzone 254 >>Travel to Blackrock Mountain
step << !tbc !wotlk
#hardcore
.goto Eastern Kingdoms,48.94,63.92,10,0
.goto Eastern Kingdoms,49.01,64.12,10,0
.goto Eastern Kingdoms,49.12,64.09
.use 18987 >>Kill the |cRXP_ENEMY_Scarshield Quartermaster|r. Loot him for |T133473:0|t[|cRXP_LOOT_Blackhand's Command|r]. Use it to accept the quest
>>|cRXP_WARN_This is a strong level 55 elite. Do this with a group for safety|r
>>|cRXP_WARN_He is located in the hallway to the right of the Blackrock Spire instance portal|r
.collect 18987,1,7761 
.accept 7761 >>Accept Blackhand's Command
.unitscan Scarshield Quartermaster
step << !tbc !wotlk
#softcore
.goto Eastern Kingdoms,48.94,63.92,10,0
.goto Eastern Kingdoms,49.01,64.12,10,0
.goto Eastern Kingdoms,49.12,64.09
.use 18987 >>Kill the |cRXP_ENEMY_Scarshield Quartermaster|r. Loot him for |T133473:0|t[|cRXP_LOOT_Blackhand's Command|r]. Use it to accept the quest
>>|cRXP_WARN_He is located in the hallway to the right of the Blackrock Spire instance portal|r
.collect 18987,1,7761 
.accept 7761 >>Accept Blackhand's Command
.unitscan Scarshield Quartermaster
step << tbc/wotlk
.goto Eastern Kingdoms,48.94,63.92,10,0
.goto Eastern Kingdoms,49.01,64.12,10,0
.goto Eastern Kingdoms,49.12,64.09
.use 18987 >>Kill the |cRXP_ENEMY_Scarshield Quartermaster|r. Loot him for |T133473:0|t[|cRXP_LOOT_Blackhand's Command|r]. Use it to accept the quest
>>|cRXP_WARN_He is located in the hallway to the right of the Blackrock Spire instance portal|r
.collect 18987,1,7761 
.accept 7761 >>Accept Blackhand's Command
.unitscan Scarshield Quartermaster
step
#label StartDungeon
.subzone 1583,2 >>Enter Blackrock Spire
step
>>Kill |cRXP_ENEMY_Pyroguard Emberseer|r. Loot him for the |cRXP_LOOT_Eye of the Emberseer|r
.complete 6821,1 
.mob Pyroguard Emberseer
.isOnQuest 6821
step
.use 12286 >>|cRXP_WARN_Use the|r |T133003:0|t[Eggscilliscope Prototype] |cRXP_WARN_on one of the eggs in The Rookery to freeze it|r
.complete 4734,1 
.isOnQuest 4734
step
>>Click |cRXP_PICK_Drakkisath's Brand|r in the final room of Upper Blackrock Spire behind |cRXP_ENEMY_General Drakkisath|r
.turnin 7761 >>Turn in Blackhand's Command
.isOnQuest 7761
step
#completewith EggFreeze
+|cRXP_WARN_Stay in your raid group! The follow-up quest of Egg Freezing can be quickly completed inside the cleared instance|r
step
#completewith EggCollectAccept
.zone Burning Steppes >>Travel to Burning Steppes
step
#label EggFreeze
.goto Burning Steppes,65.2,23.8
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tinkee|r
.turnin 4734 >>Turn in Egg Freezing
.accept 4735 >>Accept Egg Collection
.target Tinkee Steamboil
.isQuestComplete 4734
step
#label EggCollectAccept
.goto Burning Steppes,65.2,23.8
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tinkee|r
.accept 4735 >>Accept Egg Collection
.target Tinkee Steamboil
.isQuestTurnedIn 4734
step
#completewith next
.subzone 254 >>Travel to Blackrock Mountain
step
#completewith next
.goto Eastern Kingdoms,48.95,63.89
.subzone 1583 >>Enter Blackrock Spire
step
>>Enter the rookery and use the |T133003:0|t[Eggscilliscope] on one of the eggs to freeze it. Then use the |T133014:0|t[Collectronic Module] to collect it
.complete 4735,1 
.use 12144 
.use 12287 
.isOnQuest 4735
step
#completewith next
.zone Burning Steppes >>Travel to Burning Steppes
step
.goto Burning Steppes,65.2,23.8
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tinkee|r
.turnin 4735 >>Turn in Egg Collection
.target Tinkee Steamboil
.isQuestComplete 4735
step
.goto Burning Steppes,84.8,69.0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mayara Brightwing|r
.turnin 4764 >> Turn in Doomrigger's Clasp
.accept 4765 >> Accept Delivery to Ridgewell
.target Mayara Brightwing
step
.isQuestComplete 5102
.goto Burning Steppes,84.744,69.015
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marshal Maxwell|r
.turnin 5102 >> Turn in General Drakkisath's Demise
.target Marshal Maxwell
step
#completewith next
.zone Stormwind City >> Travel to Stormwind
step
.isOnQuest 4765
.goto StormwindClassic,74.010,30.231
.target Count Remington Ridgewell
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Count Remington Ridgewell|r
.turnin 4765 >> Turn in Delivery to Ridgewell
step
#completewith next
.zone Azshara >>Travel to Azshara
step
.goto Azshara,79.28,73.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Hydraxis|r
.turnin 6821 >>Turn in Eye of the Emberseer
.target Duke Hydraxis
step
+|cRXP_WARN_You have completed the Upper Blackrock Spire quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 50-60
<< Alliance
#name 16. Scholomance
step
#completewith EnterScholo
+|cRXP_WARN_You will now be directed to pick up all available quests for Scholomance|r
step
#completewith EnterScholo
+|cRXP_WARN_You or somebody in your party must have the|r |T13704:0|t[Skeleton Key] |cRXP_WARN_to enter Scholomance (a Rogue with 300 lockpicking can also open the door)|r
>>|cRXP_WARN_Select the "Scholomance Key" guide if you wish to obtain it|r
.itemcount 13704,<1
step
#completewith next
.subzone 2268 >>Travel to Light's Hope Chapel in Eastern Plaguelands
step
.goto Eastern Plaguelands,81.47,59.66
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Betina Bigglezink|r
.accept 5529 >>Accept Plagued Hatchlings
.target Betina Bigglezink
step
.goto Eastern Plaguelands,81.627,58.077
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jessica Chambers|r
.home >>Set your Hearthstone to Light's Hope Chapel
.target Jessica Chambers
.subzoneskip 2268,1
.bindlocation 2268
step
#completewith next
.zone Western Plaguelands >>Travel to Western Plaguelands
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Weldon Barov|r
.accept 5343 >> Accept Barov Family Fortune
.goto Western Plaguelands,43.4,83.6
.target Weldon Barov
step
#completewith EnterScholo
.subzone 2298 >>Travel to the Scholomance entrance
step
.goto Western Plaguelands,70.22,73.71
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Eva Sarkhoff|r
>>|cRXP_WARN_She is located right outside Scholomance|r
>>|cRXP_WARN_This quest chain will require you to run in and out of Scholomance multiple times|r
.accept 5382 >>Accept Doctor Theolen Krastinov, the Butcher
.target Eva Sarkhoff
.skipgossip
step
#label EnterScholo
.subzone 2057 >>Enter Scholomance
step
#completewith Hatchlings
>>Loot the |cRXP_PICK_Deeds|r throughout Scholomance
>>|cRXP_PICK_The Deed to Southshore|r |cRXP_WARN_is located in the large room right after the bridge as you enter the dungeon. It's in the left corner next to a bookshelf on top of a desk|r
.complete 5341,3
>>|cRXP_PICK_The Deed to Tarren Mill|r |cRXP_WARN_is located on the desk in the right corner of the large room downstairs before the room filled with whelpes|r
.complete 5341,4
>>|cRXP_PICK_The Deed to Brill|r |cRXP_WARN_is located in |cRXP_ENEMY_Ras Frostwhisper's|r room on a table to the right side|r
.complete 5341,1
>>|cRXP_PICK_The Deed to Caer Darrow|r |cRXP_WARN_is located behind |cRXP_ENEMY_Lord Alexei Barov|r in the boss gauntlet in |cRXP_ENEMY_Grandmaster Gandling's|r room|r
.complete 5341,2
.isOnQuest 5341
step
#completewith Kirtonos
>>Kill |cRXP_ENEMY_Plagued Hatchlings|r. Loot them for a |T134319:0|t[|cRXP_LOOT_Healthy Dragon Scale|r]. Use it to accept the quest
.collect 13920,1,5582 
.accept 5582 >>Accept Healthy Dragon Scale
.complete 5529,1 
.isOnQuest 5529
step
>>Kill |cRXP_ENEMY_Doctor Theolen Krastinov|r in the boss gauntlet in |cRXP_ENEMY_Grandmaster Gandling's|r room
>>Click on the |cRXP_PICK_Remains of Eva Sarkhoff|r and |cRXP_PICK_Remains of Lucien Sarkhoff|r to burn them
>>|cRXP_WARN_They look like piles of flesh and are located in |cRXP_ENEMY_Krastinov's|r room|r
.complete 5382,1 
.complete 5382,2 
.complete 5382,3 
.mob Doctor Theolen Krastinov
.isOnQuest 5382
step
#completewith next
.goto Western Plaguelands,70.22,73.71,50 >>Return to |cRXP_FRIENDLY_Eva Sarkhoff|r outside the instance
step
.goto Western Plaguelands,70.22,73.71
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Eva Sarkhoff|r
.turnin 5382 >>Turn in Doctor Theolen Krastinov, the Butcher
.accept 5515 >>Accept Krastinov's Bag of Horrors
.isQuestComplete 5382
.target Eva Sarkhoff
step
#optional
.goto Western Plaguelands,70.22,73.71
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Eva Sarkhoff|r
.accept 5515 >>Accept Krastinov's Bag of Horrors
.target Eva Sarkhoff
.isQuestTurnedIn 5382
step
>>Kill |cRXP_ENEMY_Jandice Barov|r. Loot her for |T133648:0|t[|cRXP_LOOT_Krastinov's Bag of Horrors|r]
.complete 5515,1 
.isOnQuest 5515
.mob Jandice Barov
step
#completewith next
.goto Western Plaguelands,70.22,73.71,50 >>Return to |cRXP_FRIENDLY_Eva Sarkhoff|r outside the instance
step
.goto Western Plaguelands,70.22,73.71
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Eva Sarkhoff|r
.turnin 5515 >>Turn in Krastinov's Bag of Horrors
.accept 5384 >>Accept Kirtonos the Herald
.isQuestComplete 5515
.target Eva Sarkhoff
step
#optional
.goto Western Plaguelands,70.22,73.71
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Eva Sarkhoff|r
.accept 5515 >>Accept Kirtonos the Herald
.isQuestTurnedIn 5384
.target Eva Sarkhoff
step
#label Kirtonos
>>|cRXP_WARN_Use the|r |T134804:0|t[Blood of Innocents] |cRXP_WARN_on the |cRXP_PICK_Brazier of the Herald|r on the balcony in the second room|r
>>Kill |cRXP_ENEMY_Kirtonos the Herald|r as he spawns
.complete 5384,1 
.mob Kirtonos the Herald
.isOnQuest 5384
step
#label Hatchlings
>>Kill |cRXP_ENEMY_Plagued Hatchlings|r. Loot them for a |T134319:0|t[|cRXP_LOOT_Healthy Dragon Scale|r]. Use it to accept the quest
.collect 13920,1,5582 
.accept 5582 >>Accept Healthy Dragon Scale
.complete 5529,1 
.isOnQuest 5529
step
>>Loot the |cRXP_PICK_Deeds|r throughout Scholomance
>>|cRXP_PICK_The Deed to Southshore|r |cRXP_WARN_is located in the large room right after the bridge as you enter the dungeon. It's in the left corner next to a bookshelf on top of a desk|r
.complete 5341,3
>>|cRXP_PICK_The Deed to Tarren Mill|r |cRXP_WARN_is located on the desk in the right corner of the large room downstairs before the room filled with whelpes|r
.complete 5341,4
>>|cRXP_PICK_The Deed to Brill|r |cRXP_WARN_is located in |cRXP_ENEMY_Ras Frostwhisper's|r room on a table to the right side|r
.complete 5341,1
>>|cRXP_PICK_The Deed to Caer Darrow|r |cRXP_WARN_is located behind |cRXP_ENEMY_Lord Alexei Barov|r in the boss gauntlet in |cRXP_ENEMY_Grandmaster Gandling's|r room|r
.complete 5341,2
.isOnQuest 5341
step
#completewith next
.goto Western Plaguelands,70.22,73.71,50 >>Return to |cRXP_FRIENDLY_Eva Sarkhoff|r outside the instance
step
.goto Western Plaguelands,70.22,73.71
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Eva Sarkhoff|r
.turnin 5384 >>Turn in Kirtonos the Herald
.isQuestComplete 5384
.target Eva Sarkhoff
step
#completewith next
.use 13544 >>|cRXP_WARN_Equip the|r |T134337:0|t[|cRXP_FRIENDLY_Spectral Essence|r] |cRXP_WARN_you received from the previous quest to be able to see|r |cRXP_FRIENDLY_Magistrate Marduke|r
>>|cRXP_WARN_If you lost it you can ask|r |cRXP_FRIENDLY_Eva Sarkhoff|r |cRXP_WARN_for another|r
step
.goto Western Plaguelands,70.54,73.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Magistrate Marduke|r
.accept 5461 >>Accept The Human, Ras Frostwhisper
.target Magistrate Marduke
.isQuestTurnedIn 5384
.use 13544
step
#optional
#completewith RichRas
.use 13544 >>|cRXP_WARN_Equip the|r |T134337:0|t[|cRXP_FRIENDLY_Spectral Essence|r] |cRXP_WARN_you received from the previous quest to be able to see|r |cRXP_FRIENDLY_Magistrate Marduke|r
>>|cRXP_WARN_If you lost it you can ask|r |cRXP_FRIENDLY_Eva Sarkhoff|r |cRXP_WARN_for another|r
step
#optional
.goto Western Plaguelands,70.54,73.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Magistrate Marduke|r
.turnin 5465 >>Turn in Soulbound Keepsake
.accept 5466 >>Accept The Lich, Ras Frostwhisper
.target Magistrate Marduke
.isOnQuest 5465
.use 13544
step
#optional
#label RichRas
.goto Western Plaguelands,70.54,73.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Magistrate Marduke|r
.accept 5466 >>Accept The Lich, Ras Frostwhisper
.target Magistrate Marduke
.isQuestTurnedIn 5465
.use 13544
step
#optional
.use 13752>>|cRXP_WARN_Use the|r |T133736:0|t[Soulbound Keepsake] |cRXP_WARN_on|r |cRXP_ENEMY_Ras Frostwhisper|r
>>Kill |cRXP_ENEMY_Ras Frostwhisper|r inside Scholomance. Loot him for his |cRXP_LOOT_Head|r
.complete 5466,1 
.mob Ras Frostwhisper
.isOnQuest 5466
step
#optional
#completewith RichRas2
.goto Western Plaguelands,70.22,73.71,50 >>Return to |cRXP_FRIENDLY_Magistrate Marduke|r outside the instance
step
#optional
#completewith RichRas2
.use 13544 >>|cRXP_WARN_Equip the|r |T134337:0|t[|cRXP_FRIENDLY_Spectral Essence|r] |cRXP_WARN_you received to be able to see|r |cRXP_FRIENDLY_Magistrate Marduke|r
>>|cRXP_WARN_If you lost it you can ask|r |cRXP_FRIENDLY_Eva Sarkhoff|r |cRXP_WARN_for another|r
step
#optional
#label RichRas2
.goto Western Plaguelands,70.54,73.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Magistrate Marduke|r
.turnin 5466 >>Turn in The Lich, Ras Frostwhisper
.target Magistrate Marduke
.isQuestComplete 5466
.use 13544
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Weldon Barov|r
.accept 5343 >> Accept Barov Family Fortune
.goto Western Plaguelands,43.4,83.6
.target Weldon Barov
step
#completewith HatchlingsTurnin
.hs >>Hearth to Light's Hope Chapel
.bindlocation 2268,1
.subzoneskip 2268
.use 6948
.cooldown item,6948,>0,1
step
#completewith HatchlingsTurnin
.subzone 2268 >>Travel to Light's Hope Chapel in Eastern Plaguelands
step
#label HatchlingsTurnin
.goto Eastern Plaguelands,81.47,59.66
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Betina Bigglezink|r
.turnin 5529 >>Turn in Plagued Hatchlings
.target Betina Bigglezink
.isQuestComplete 5529
step
+|cRXP_WARN_Select the "Stratholme guide" in order to continue with the quest chain of "The Human, Ras Frostwhisper"|r
.isOnQuest 5461
step
+|cRXP_WARN_You have completed the Scholomance quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 50-60
<< Alliance
#name 17. Stratholme
step
#optional
+|cRXP_WARN_It is recommended to run Scholomance first to begin the quest chain "Doctor Theolen Krastinov, the Butcher" that will send you to Stratholme afterwards|r
.isQuestAvailable 5384
step
#completewith next
.subzone 324 >>Travel to Stromgarde Keep in Arathi Highlands
step
#loop
.goto Arathi Highlands,28.26,62.33,0
.goto Arathi Highlands,28.26,62.33,30,0
.goto Arathi Highlands,21.40,60.08,30,0
.goto Arathi Highlands,20.86,69.04,30,0
.goto Arathi Highlands,18.21,68.45,30,0
>>Loot the |cRXP_PICK_Keepsake of Remembrance|r in Stromgarde Keep
>>|cRXP_WARN_It is a little red book which can be located in any of the fireplaces inside the keep. Also check the Ogre Tower and the intact houses|r
.complete 5461,1 
.isOnQuest 5461
step
#completewith LoveandFam
.zone Western Plaguelands >>Travel to Western Plaguelands
step
#completewith DyingRas
.use 13544 >>|cRXP_WARN_Equip the|r |T134337:0|t[|cRXP_FRIENDLY_Spectral Essence|r] |cRXP_WARN_you received from the previous quest to be able to see|r |cRXP_FRIENDLY_Magistrate Marduke|r
>>|cRXP_WARN_If you lost it you can ask|r |cRXP_FRIENDLY_Eva Sarkhoff|r |cRXP_WARN_for another|r
step
.goto Western Plaguelands,70.54,73.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Magistrate Marduke|r
.turnin 5461 >>Turn in The Human, Ras Frostwhisper
.accept 5462 >>Accept The Dying, Ras Frostwhisper
.target Magistrate Marduke
.isQuestComplete 5461
.use 13544
step
#optional
#label DyingRas
.goto Western Plaguelands,70.54,73.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Magistrate Marduke|r
.accept 5462 >>Accept The Dying, Ras Frostwhisper
.target Magistrate Marduke
.isQuestTurnedIn 5461
.use 13544
step
.goto Western Plaguelands,65.7,75.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Artist Renfray|r
.turnin 5846 >>Turn in Of Love and Family
.accept 5848 >>Accept Of Love and Family
.target Artist Renfray
.isQuestComplete 5846
step
#label LoveandFam
#optional
.goto Western Plaguelands,65.7,75.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Artist Renfray|r
.accept 5848 >>Accept Of Love and Family
.target Artist Renfray
.isQuestTurnedIn 5846
step
#completewith LHCpickups
.subzone 2268 >>Travel to Light's Hope Chapel
step
.goto Eastern Plaguelands,79.60,63.87
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Alen|r
.accept 5281 >>Accept The Restless Souls
.target Caretaker Alen
step
.goto Eastern Plaguelands,81.437,59.820
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Nicholas Zverenhoff|r
.accept 5251 >>Accept The Archivist
.target Duke Nicholas Zverenhoff
step
.goto Eastern Plaguelands,81.47,59.65
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Betina Bigglezink|r
.accept 5212 >>Accept The Flesh Does Not Lie
.target Betina Bigglezink
step
.goto Eastern Plaguelands,81.73,57.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Leonid|r
.turnin 5462 >>Turn in The Dying, Ras Frostwhisper
.accept 5463 >>Accept Menethil's Gift
.target Leonid Barthalomew the Revered
.isQuestComplete 5462
step
#optional
.goto Eastern Plaguelands,81.73,57.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Leonid|r
.accept 5463 >>Accept Menethil's Gift
.target Leonid Barthalomew the Revered
.isQuestTurnedIn 5462
step
.goto Eastern Plaguelands,80.605,57.979
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Smokey LaRue|r
.accept 5214 >>Accept The Great Ezra Grimm
.target Smokey LaRue
step
#label LHCpickups
.goto Eastern Plaguelands,81.627,58.077
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jessica Chambers|r
.home >>Set your Hearthstone to Light's Hope Chapel
.target Jessica Chambers
.subzoneskip 2268,1
.bindlocation 2268
step
#completewith RestlessSouls
.subzone 2627 >>Travel to Terrordale
step
.goto Eastern Plaguelands,14.45,33.74
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Egan|r
.turnin 5281 >>Turn in The Restless Souls
.accept 5282 >>Accept The Restless Souls
.target Egan
.isOnQuest 5281
step
#label RestlessSouls
#optional
.goto Eastern Plaguelands,14.45,33.74
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Egan|r
.accept 5282 >>Accept The Restless Souls
.target Egan
.isQuestTurnedIn 5281
step
#label EnterLiving
.goto Eastern Kingdoms,52.96,28.67
.subzone 2279,2 >>Enter Stratholme
step
#completewith RivenDare
>>Loot |T132761:0|t[|cRXP_PICK_Supply Crates|r] scattered around the instance. Loot them for |T134855:0|t[|cRXP_LOOT_Stratholme Holy Water|r]
>>Some of the crates are traps and contain poison or hostile bugs inside
>>|cRXP_WARN_If careful you can tell them apart as when you move close to a trapped crate "disarm trap" will appear on the tooltip|r
.collect 13180,5,5243,1 
step
#completewith HolyWater
.use 13289 >>|cRXP_WARN_Use|r |T135614:0|t[Egan's Blaster] |cRXP_WARN_on|r |cRXP_ENEMY_Spectral Citizens|r |cRXP_WARN_and|r |cRXP_ENEMY_Ghostly Citizen|r.
>>|cRXP_ENEMY_Restless Souls|r |cRXP_WARN_will appear. Use it on them too|r
.complete 5282,1 
.mob Spectral Citizen
.mob Ghostly Citizen
.mob Restless Soul
.isOnQuest 5282
step
>>Take a left into the alleyway coming from the entrance of the living side
>>|cRXP_WARN_Click on the|r |T132761:0|t[|cRXP_PICK_Premium Grimm Tobacco|r] |cRXP_WARN_box on the ground at the end of it|r
>>|cRXP_ENEMY_Ezra Grim|r will spawn. Kill him and loot him for |cRXP_LOOT_Grimm's Premium Tobacco|r
>>|cRXP_WARN_Be careful as he will aggro every |cRXP_ENEMY_Undead|r in an extremely large radius|r
.complete 5214,1 
.mob Ezra Grim
.isOnQuest 5214
step
>>Kill |cRXP_ENEMY_Archivist Galford|r. Click the |cRXP_PICK_Scarlet Archive|r on the table
.complete 5251,1 
.complete 5251,2 
.mob Archivist Galford
.isOnQuest 5251
step
>>Loot the |cRXP_PICK_painting|r on the wall in |cRXP_ENEMY_Archivist Galford's|r room
.complete 5848,1 
.isOnQuest 5848
step
#completewith next
+|cRXP_WARN_If possible, return to Light's Hope Chapel now to turn in "The Archivist" BEFORE killing |cRXP_ENEMY_Grand Crusader Dathrohan|r |cRXP_ENEMY_(Balnazzar)|r as this will allow you to loot|r |T136183:0|t[|cRXP_LOOT_Head of Balnazzar|r]
step
.goto Eastern Plaguelands,81.437,59.820
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Nicholas Zverenhoff|r
>>|cRXP_WARN_Skip this step if you do not wish to do this now|r
.turnin 5251 >>Turn in The Archivist
.target Duke Nicholas Zverenhoff
step
>>Kill |cRXP_ENEMY_Grand Crusader Dathrohan|r |cRXP_ENEMY_(Balnazzar)|r. Loot him for |T136183:0|t[|cRXP_LOOT_Head of Balnazzar|r]. Use it to start the quest
.collect 13250,1,5262 
.accept 5262 >>Accept The Truth Comes Crashing Down
.mob Grand Crusader Dathrohan
.mob Balnazzar
.isQuestTurnedIn 5251
step
#completewith next
+|cRXP_WARN_If possible, return to Light's Hope Chapel once more to get the follow-up quest to kill |cRXP_ENEMY_Baron Rivendare|r
step
.goto Eastern Plaguelands,81.437,59.820
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Nicholas Zverenhoff|r
>>|cRXP_WARN_Skip this step if you do not wish to do this now|r
.turnin 5262 >>Turn in The Truth Comes Crashing Down
.accept 5263 >>Accept in Above and Beyond
.target Duke Nicholas Zverenhoff
step
#completewith Souls2
>>Kill |cRXP_ENEMY_Undead|r. Loot them for their |T134358:0|t[|cRXP_LOOT_Plagued Flesh Samples|r]
.complete 5212,1 
.isOnQuest 5212
step
>>Kill |cRXP_ENEMY_Baron Rivendare|r. Loot him for his |cRXP_ENEMY_Head|r
.complete 5263,1 
.mob Baron Rivendare
.isOnQuest 5263
step
#label RivenDare
>>Kill |cRXP_ENEMY_Baron Rivendare|r. Afterwards, click |cRXP_FRIENDLY_Menethil's Gift|r in the orange circle on the ground
.turnin 5463 >>Turn in Menethil's Gift
.accept 5464 >>Accept Menethil's Gift
.mob Baron Rivendare
step
#label HolyWater
>>Loot |T132761:0|t[|cRXP_PICK_Supply Crates|r] scattered around the instance. Loot them for |T134855:0|t[|cRXP_LOOT_Stratholme Holy Water|r]
>>Some of the crates are traps and contain poison or hostile bugs inside
>>|cRXP_WARN_If careful you can tell them apart as when you move close to a trapped crate "disarm trap" will appear on the tooltip|r
.collect 13180,5,5243,1 
step
#label Souls2
.use 13289 >>|cRXP_WARN_Use|r |T135614:0|t[Egan's Blaster] |cRXP_WARN_on|r |cRXP_ENEMY_Spectral Citizens|r |cRXP_WARN_and|r |cRXP_ENEMY_Ghostly Citizen|r.
>>|cRXP_ENEMY_Restless Souls|r |cRXP_WARN_will appear. Use it on them too|r
.complete 5282,1 
.mob Spectral Citizen
.mob Ghostly Citizen
.mob Restless Soul
.isOnQuest 5282
step
>>Kill |cRXP_ENEMY_Undead|r. Loot them for their |T134358:0|t[|cRXP_LOOT_Plagued Flesh Samples|r]
.complete 5212,1 
.isOnQuest 5212
step
#completewith RestlessSouls
.subzone 2627 >>Travel to Terrordale
step
.goto Eastern Plaguelands,14.45,33.74
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Egan|r
.turnin 5282 >>Turn in The Restless Souls
.target Egan
.isQuestComplete 5282
step
#completewith LCHTurnins
.hs >>Hearth to Light's Hope Chapel
.bindlocation 2268,1
.subzoneskip 2268
.use 6948
.cooldown item,6948,>0,1
step
.goto Eastern Plaguelands,81.437,59.820
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Nicholas Zverenhoff|r
.turnin 5262 >>Turn in The Truth Comes Crashing Down
.accept 5263 >>Accept in Above and Beyond
.target Duke Nicholas Zverenhoff
.isOnQuest 5262
step
.goto Eastern Plaguelands,81.437,59.820
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Nicholas Zverenhoff|r
.turnin 5263 >>Turn in Above and Beyond
.accept 5264 >>Accept Lord Maxwell Tyrosus
.target Duke Nicholas Zverenhoff
.isQuestComplete 5263
step
#optional
.goto Eastern Plaguelands,81.437,59.820
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Nicholas Zverenhoff|r
.accept 5264 >>Accept Lord Maxwell Tyrosus
.target Duke Nicholas Zverenhoff
.isQuestTurnedIn 5263
step
.goto Eastern Plaguelands,81.74,57.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lord Maxwell Tyrosus|r
.turnin 5264 >>Turn in Lord Maxwell Tyrosus
.accept 5265 >>Accept The Argent Hold
.target Lord Maxwell Tyrosus
.isQuestComplete 5264
step
#optional
.goto Eastern Plaguelands,81.74,57.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lord Maxwell Tyrosus|r
.accept 5265 >>Accept The Argent Hold
.target Lord Maxwell Tyrosus
.isQuestTurnedIn 5264
step
.goto Eastern Plaguelands,81.81,57.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tClick on |cRXP_FRIENDLY_The Argent Hold|r a small chest next to Maxwell
.turnin 5265 >>Turn in The Argent Hold
.target The Argent Hold
.isOnQuest 5265
step
.goto Eastern Plaguelands,81.73,57.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Leonid|r
.accept 5243 >>Accept Houses of the Holy
.turnin 5243 >>Turn in Houses of the Holy
.target Leonid Barthalomew the Revered
.itemcount 13180,5
step
.goto Eastern Plaguelands,81.73,57.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Leonid|r
.turnin 5464 >>Turn in Menethil's Gift
.accept 5465 >>Accept Soulbound Keepsake
.target Leonid Barthalomew the Revered
.isOnQuest 5464
step
#optional
.goto Eastern Plaguelands,81.73,57.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Leonid|r
.accept 5465 >>Accept Soulbound Keepsake
.target Leonid Barthalomew the Revered
.isQuestTurnedIn 5464
step
.goto Eastern Plaguelands,81.47,59.65
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Betina Bigglezink|r
.turnin 5212 >> Turn in The Flesh Does Not Lie
.target Betina Bigglezink
.isQuestComplete 5212
step
#label LCHTurnins
.goto Eastern Plaguelands,80.605,57.979
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Smokey LaRue|r
.accept 5214 >>Accept The Great Ezra Grimm
.target Smokey LaRue
.isQuestComplete 5214
step
.goto Eastern Plaguelands,7.59,43.57
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tirion|r
.turnin 5848 >>Turn in Of Love and Family
.target Tirion Fordring
.isQuestComplete 5848
step
#completewith RichRas
.zone Western Plaguelands >>Travel to Western Plaguelands
step
#completewith RichRas
.use 13544 >>|cRXP_WARN_Equip the|r |T134337:0|t[|cRXP_FRIENDLY_Spectral Essence|r] |cRXP_WARN_you received from the previous quest to be able to see|r |cRXP_FRIENDLY_Magistrate Marduke|r
>>|cRXP_WARN_If you lost it you can ask|r |cRXP_FRIENDLY_Eva Sarkhoff|r |cRXP_WARN_for another|r
step
.goto Western Plaguelands,70.54,73.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Magistrate Marduke|r
.turnin 5465 >>Turn in Soulbound Keepsake
.accept 5466 >>Accept The Lich, Ras Frostwhisper
.target Magistrate Marduke
.isOnQuest 5465
.use 13544
step
#optional
#label RichRas
.goto Western Plaguelands,70.54,73.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Magistrate Marduke|r
.accept 5466 >>Accept The Lich, Ras Frostwhisper
.target Magistrate Marduke
.isQuestTurnedIn 5465
.use 13544
step
#completewith next
+|cRXP_WARN_Find a group for Scholomance now if you wish to complete the final quest of the chain "The Lich, Ras Frostwhisper"|r
step
.use 13752>>|cRXP_WARN_Use the|r |T133736:0|t[Soulbound Keepsake] |cRXP_WARN_on|r |cRXP_ENEMY_Ras Frostwhisper|r
>>Kill |cRXP_ENEMY_Ras Frostwhisper|r inside Scholomance. Loot him for his |cRXP_LOOT_Head|r
.complete 5466,1 
.mob Ras Frostwhisper
.isOnQuest 5466
step
#optional
#completewith RichRas2
.goto Western Plaguelands,70.22,73.71,50 >>Return to |cRXP_FRIENDLY_Magistrate Marduke|r outside the instance
step
#optional
#completewith RichRas2
.use 13544 >>|cRXP_WARN_Equip the|r |T134337:0|t[|cRXP_FRIENDLY_Spectral Essence|r] |cRXP_WARN_you received to be able to see|r |cRXP_FRIENDLY_Magistrate Marduke|r
>>|cRXP_WARN_If you lost it you can ask|r |cRXP_FRIENDLY_Eva Sarkhoff|r |cRXP_WARN_for another|r
step
#optional
#label RichRas2
.goto Western Plaguelands,70.54,73.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Magistrate Marduke|r
.turnin 5466 >>Turn in The Lich, Ras Frostwhisper
.target Magistrate Marduke
.isQuestComplete 5466
.use 13544
step
+|cRXP_WARN_You have completed the Stratholme quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 50-60
<< Alliance
#name 18. Dire Maul (East)
step << era
#optional
#phase 1
+Dire Maul is not until accessible until Phase 2 has released
step
#completewith EnterDME
+Start looking for a group for Dire Maul (East) while you accept the quests for the dungeon
step
#completewith EnterDME
.zone Feralas >> Travel to Feralas
step
.goto Feralas,31.8,44.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Scholar Runethorn|r
>>|cRXP_FRIENDLY_Scholar Runethorn|r |cRXP_WARN_patrols slightly through Feathermoon Stronghold|r
.accept 7482 >> Accept Elven Legends
.target Scholar Runethorn
step
.goto Feralas,30.379,46.170
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Latronicus Moonspear|r
.accept 7488 >> Accept Lethtendris's Web
.target Latronicus Moonspear
step
.goto Feralas,76.910,37.353
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Azj'Tordin|r
.accept 7441 >> Accept Pusillin and the Elder Azj'Tordin
.target Azj'Tordin
step << Mage era
#softcore
.xp <60,1
>>If it is possible, enter Dire Maul (North) and head into the Library to accept the quest for your level 60 Mage Water quest
>>You will need to have the |cRXP_LOOT_Crescent Key|r to open the door to the Library or consider looking for someone selling Tribute buffs that has already opened the door
>>|cRXP_WARN_If you cannot do this, skip this step|r
>>Talk to |cRXP_FRIENDLY_Lorekeeper Lydros|r in Dire Maul (North) Library
.accept 7463 >> Accept Arcane Refreshment
.target Lorekeeper Lydros
step
#label EnterDME
.goto 1414,43.83,67.40,15 >> Enter Dire Maul (East)
step
>>Talk to |cRXP_FRIENDLY_Pusillin|r and continue to chase him through Dire Maul by talking to him every time he stops
>>Kill |cRXP_ENEMY_Pusillin|r. Loot him for the |cRXP_LOOT_Crescent Key|r and |cRXP_LOOT_Book of Incantations|r
.collect 18249,1 
.complete 7441,1 
.target Pusillin
.skipgossip
step
>>Kill |cRXP_ENEMY_Lethtendris|r. Loot her for |cRXP_LOOT_Lethtendris's Web|r
.complete 7488,1 
.mob Lethtendris
step << Mage era
.isOnQuest 7463
>>Kill |cRXP_ENEMY_Hydrospawn|r. Loot it for the |cRXP_LOOT_Hydrospawn Essence|r
.complete 7463,1 
.mob Hydrospawn
step
>>Kill |cRXP_ENEMY_Alzzin the Wildshaper|r. Loot a |cRXP_PICK_Felvine Shard|r on the ground after
.collect 18501,1,5526,1 
step << Mage era
#softcore
.xp <60,1
.isQuestComplete 7463
>>Talk to |cRXP_FRIENDLY_Lorekeeper Lydros|r in the Dire Maul (North) Library
>>|cRXP_WARN_Skip this if you can't access it|r
.turnin 7463 >> Turn in Arcane Refreshment
.target Lorekeeper Lydros
step
.isQuestComplete 7441
.goto Feralas,76.910,37.353
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Azj'Tordin|r in Feralas
.turnin 7441 >> Turn in Pusillin and the Elder Azj'Tordin
.target Azj'Tordin
step
.goto Feralas,30.379,46.170
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Latronicus Moonspear|r
.turnin 7488 >> Turn in Lethtendris's Web
.target Latronicus Moonspear
step
#completewith SotF
.zone Moonglade >> Travel to Moonglade
step
.isQuestTurnedIn 5527
.goto Moonglade,51.685,45.096
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Rabine Saturna|r
.accept 5526 >> Accept Shards of the Felvine
.target Rabine Saturna
step
.isOnQuest 5526
.isQuestTurnedIn 5527
.use 18539 >> |cRXP_WARN_Use the|r |T132595:0|t[Reliquary of Purity]
.complete 5526,1 
step
#label SotF
.isQuestComplete 5526
.goto Moonglade,51.685,45.096
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Rabine Saturna|r
.turnin 5526 >> Turn in Shards of the Felvine
.target Rabine Saturna
step
+|cRXP_WARN_You have completed the Dire Maul (East) quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 50-60
<< Alliance
#name 19. Dire Maul (West)
step << era
#optional
#phase 1
+Dire Maul is not until accessible until Phase 2 has released
step
#completewith EnterDM
.zone Feralas >> Travel to Feralas
step
.goto Feralas,31.8,44.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Scholar Runethorn|r
>>|cRXP_FRIENDLY_Scholar Runethorn|r |cRXP_WARN_patrols slightly through Feathermoon Stronghold|r
.accept 7482 >> Accept Elven Legends
.target Scholar Runethorn
step
#label EnterDM
.goto 1414,42.97,67.79,15 >> Enter Dire Maul (West)
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Shen'dralar Ancient|r
>>|cRXP_WARN_She is inside DM:West on the bridge in the upper section|r
.accept 7461 >> Accept The Madness Within
.target Shen'dralar Ancient
step
>>Kill |cRXP_ENEMY_Immol'thar|r and |cRXP_ENEMY_Prince Tortheldrin|r
.complete 7461,1 
.mob +Immol'thar
.complete 7461,2 
.mob +Prince Tortheldrin
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Shen'dralar Ancient|r
>>|cRXP_WARN_She is inside DM:West on the bridge in the upper section|r
.turnin 7461 >> Turn in The Madness Within
.accept 7877 >> Accept The Treasure of the Shen'dralar
.target Shen'dralar Ancient
step
>>Click the |cRXP_PICK_The Treasure of the Shen'dralar|r
>>|cRXP_WARN_This is found back where you killed |cRXP_ENEMY_Prince Tortheldrin|r in the Library, under the ramp leading to him|r
.turnin 7877 >> Turn in The Treasure of the Shen'dralar
step << Mage era
#optional
#softcore
.xp <60,1
.isQuestComplete 7463
>>Talk to |cRXP_FRIENDLY_Lorekeeper Lydros|r in the Dire Maul (North) Library
.turnin 7463 >> Turn in Arcane Refreshment
.target Lorekeeper Lydros
step
.isOnQuest 7482
>>Click the |cRXP_PICK_Skeletas Remains of Kariel Winthalus|r inside the Dire Maul Library
>>|cRXP_WARN_This is located beside|r |cRXP_FRIENDLY_Lorekeeper Lydros|r
.complete 7482,1 
step
#completewith next
.zone Feralas >> Travel to Feralas
step
.goto Feralas,31.8,44.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Scholar Runethorn|r
>>|cRXP_FRIENDLY_Scholar Runethorn|r |cRXP_WARN_patrols slightly through Feathermoon Stronghold|r
.turnin 7482 >> Turn in Elven Legends
.target Scholar Runethorn
step
+|cRXP_WARN_You have completed the Dire Maul (West) quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 50-60
<< Alliance
#name 20. Dire Maul (North)
step << era
#optional
#phase 1
+Dire Maul is not until accessible until Phase 2 has released
step
>>The following materials are required if you wish to complete a Tribute run
>>|cRXP_WARN_You will also need a Rogue with 300 Lockpicking skill OR a Powerful Seaforium Charge OR a Truesilver Skeleton Key|r
>>|cRXP_WARN_Skip buying the Bolt of Runecloth, Rugged Leather and Rune Thread if you decide to simply buy the Gordok Ogre Suit|r
>>|cRXP_WARN_Skip this step if you wish to complete the dungeon normally|r
.collect 18258,1 
.collect 14048,4 
.collect 8170,8 
.collect 14341,2 
.collect 15994,1 
.collect 3829,1 
step
#completewith EnterDM
.zone Feralas >> Travel to Feralas
step
.goto Feralas,31.8,44.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Scholar Runethorn|r
>>|cRXP_FRIENDLY_Scholar Runethorn|r |cRXP_WARN_patrols slightly through Feathermoon Stronghold|r
.accept 7482 >> Accept Elven Legends
.target Scholar Runethorn
step
#label EnterDM
.goto 1414,43.45,66.52,15 >> Enter Dire Maul (North)
step
.isOnQuest 7482
>>Click the |cRXP_PICK_Skeletas Remains of Kariel Winthalus|r inside the Dire Maul Library
>>|cRXP_WARN_This is located beside|r |cRXP_FRIENDLY_Lorekeeper Lydros|r
.complete 7482,1 
step
+|cRXP_WARN_If you are doing a Tribute run:|r
>>Completely avoid |cRXP_ENEMY_Guard Mol'dar|r, |cRXP_ENEMY_Guard Fengus|r and |cRXP_ENEMY_Stomper Kreeg|r
>>Make sure someone in your party loots |cRXP_PICK_Fengus's Chest|r for the |cRXP_LOOT_Gordok Courtyard Key|r
>>Use the materials aquired earlier to trap |cRXP_ENEMY_Guard Slip'kik|r
>>Head up the ramp and loot the |cRXP_PICK_Ogre Tannin|r, then return below to |cRXP_FRIENDLY_Knot Thimblejack|r to make the |T132636:0|t[|cRXP_LOOT_Gordok Ogre Suit|r] if you didn't buy one
>>Talk to |cRXP_ENEMY_Captain Kromcrush|r while wearing the |T132636:0|t[|cRXP_LOOT_Gordok Ogre Suit|r]
>>Kill |cRXP_ENEMY_King Gordok|r. Keep |cRXP_ENEMY_Cho'Rush the Observer|r alive
>>|cRXP_WARN_Skip this step if you are doing a normal clear|r
step
+Complete Dire Maul (North)
>>There are no other quests to complete. Exit the instance once complete
step
#completewith next
.zone Feralas >> Travel to Feralas
step
.goto Feralas,31.8,44.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Scholar Runethorn|r
>>|cRXP_FRIENDLY_Scholar Runethorn|r |cRXP_WARN_patrols slightly through Feathermoon Stronghold|r
.turnin 7482 >> Turn in Elven Legends
.target Scholar Runethorn
step
+|cRXP_WARN_You have completed the Dire Maul (North) quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 60-70
<< Alliance !classic
#name 21. Hellfire Ramparts
step
#completewith next
.zone Hellfire Peninsula >> Travel to Hellfire Peninsula in Outland
step
.goto Hellfire Peninsula,56.37,65.99,20,0
.goto Hellfire Peninsula,56.61,66.77,14,0
.goto Hellfire Peninsula,56.64,66.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Force Commander Danath Trollbane|r upstairs in the Keep
.accept 10141 >> Accept The Legion Reborn
.target Force Commander Danath Trollbane
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sergeant Altumus|r
.goto Hellfire Peninsula,61.74,60.67,15,0
.goto Hellfire Peninsula,61.69,60.90
.turnin 10141 >> Turn in The Legion Reborn
.accept 10142 >> Accept The Path of Anguish
.target Sergeant Altumus
step
#loop
.line Hellfire Peninsula,65.83,59.06,67.03,58.91,69.16,59.36,69.64,57.71,68.15,56.25,67.55,54.60,66.82,56.63,65.55,55.62,65.83,59.06
.goto Hellfire Peninsula,65.83,59.06,50,0
.goto Hellfire Peninsula,67.03,58.91,50,0
.goto Hellfire Peninsula,69.16,59.36,50,0
.goto Hellfire Peninsula,69.64,57.71,50,0
.goto Hellfire Peninsula,68.15,56.25,50,0
.goto Hellfire Peninsula,67.55,54.60,50,0
.goto Hellfire Peninsula,66.82,56.63,50,0
.goto Hellfire Peninsula,65.55,55.62,50,0
>>Kill a |cRXP_ENEMY_Dreadcaller|r, |cRXP_ENEMY_Flamewaker Imps|r and |cRXP_ENEMY_Infernal Warbringers|r
.complete 10142,1 
.mob +Dreadcaller
.complete 10142,2 
.mob +Flamewaker Imp
.complete 10142,3 
.mob +Infernal Warbringer
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sergeant Altumus|r
.goto Hellfire Peninsula,61.74,60.67,15,0
.goto Hellfire Peninsula,61.69,60.90
.turnin 10142 >> Turn in The Path of Anguish
.accept 10143 >> Accept Expedition Point
.target Sergeant Altumus
step
#label ExpeditionPoint
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Forward Commander Kingston|r
.turnin 10143 >> Turn in Expedition Point
.goto Hellfire Peninsula,71.34,62.76
.target Forward Commander Kingston
step
.goto Hellfire Peninsula,56.724,66.337
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lieutenant Chadwick|r
.accept 9575 >> Accept Weaken the Ramparts
.target Lieutenant Chadwick
step
.isQuestAvailable 9575,9587
.goto Hellfire Peninsula,53.38,83.80,-1
.goto Hellfire Peninsula,47.543,53.609,-1
.subzone 3562 >> |cRXP_WARN_You will now run Hellfire Ramparts. Grind on nearby |cRXP_ENEMY_Unyielding Footmen|r, |cRXP_ENEMY_Unyielding Sorcerers|r and |cRXP_ENEMY_Unyielding Knights|r until you've found a group. Zone in once you have a group|r
.mob Unyielding Footman
.mob Unyielding Sorcerer
.mob Unyielding Knight
step
.isOnQuest 9575
#completewith next
>>Kill |cRXP_ENEMY_Watchkeeper Gargolmar|r. Loot him for |cRXP_LOOT_Gargolmar's Hand|r
>>Kill |cRXP_ENEMY_Omor the Unscarred|r. Loot him for |cRXP_LOOT_Omor's Hoof|r
>>Kill |cRXP_ENEMY_Nazan|r. Loot it for |cRXP_LOOT_Nazan's Head|r
.complete 9575,1 
.complete 9575,2 
.complete 9575,3 
step
>>Kill |cRXP_ENEMY_Vazruden|r. Loot him for the |T134940:0|t[|cRXP_LOOT_Ominous Letter|r]
.use 23890 >>|cRXP_WARN_Use the|r |T134940:0|t[|cRXP_LOOT_Ominous Letter|r] |cRXP_WARN_to start the quest|r
.collect 23890,1,9587,1 
.accept 9587 >> Accept Dark Tidings
step
.isOnQuest 9575
>>Kill |cRXP_ENEMY_Watchkeeper Gargolmar|r. Loot him for |cRXP_LOOT_Gargolmar's Hand|r
>>Kill |cRXP_ENEMY_Omor the Unscarred|r. Loot him for |cRXP_LOOT_Omor's Hoof|r
>>Kill |cRXP_ENEMY_Nazan|r. Loot it for |cRXP_LOOT_Nazan's Head|r
.complete 9575,1 
.complete 9575,2 
.complete 9575,3 
step
#optional
.zone Hellfire Peninsula >> Exit Hellfire Ramparts
>>|cRXP_WARN_You will run Blood Furnace after turning in the quests for Hellfire Ramparts. Consider asking your group to run Blood Furnace now if you wish to also run that|r
.subzoneskip 3562,1
step
.zone Hellfire Peninsula >> Exit Hellfire Ramparts
.subzoneskip 3562,1
step
#completewith WeakenRamparts
.subzone 3538 >> Return to Honor Hold
step
.isOnQuest 9587
.goto Hellfire Peninsula,56.64,66.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Force Commander Danath Trollbane|r upstairs in the Keep
.turnin 9587 >> Turn in Dark Tidings
.target Force Commander Danath Trollbane
step
#label WeakenRamparts
.isQuestComplete 9575
.goto Hellfire Peninsula,56.400,66.656
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gunny|r upstairs in the Keep
.turnin 9575 >> Turn in Weaken the Ramparts
.target Gunny
step
+|cRXP_WARN_You have completed the Hellfire Ramparts quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 60-70
<< Alliance !classic
#name 22. The Blood Furnace
step
#completewith next
.zone Hellfire Peninsula >> Travel to Hellfire Peninsula in Outland
step
.isQuestTurnedIn 9587
.isQuestTurnedIn 9575
.goto Hellfire Peninsula,56.400,66.656
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gunny|r upstairs in the Keep
.accept 9589 >> Accept The Blood is Life
.accept 9607 >> Accept Heart of Rage
.target Gunny
step
.isQuestTurnedIn 9587
.goto Hellfire Peninsula,56.400,66.656
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gunny|r upstairs in the Keep
.accept 9589 >> Accept The Blood is Life
.target Gunny
step
.isQuestTurnedIn 9575
.goto Hellfire Peninsula,56.400,66.656
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gunny|r upstairs in the Keep
.accept 9607 >> Accept Heart of Rage
.target Gunny
step
.isQuestAvailable 9589,9607
.goto Hellfire Peninsula,53.38,83.80,-1
.goto Hellfire Peninsula,45.821,52.007,-1
.subzone 3713 >> |cRXP_WARN_You will now run Blood Furnace. Grind on |cRXP_ENEMY_Unyielding Footmen|r, |cRXP_ENEMY_Unyielding Sorcerers|r and |cRXP_ENEMY_Unyielding Knights|r until you've found a group. Zone in once you have a group|r
.mob Unyielding Footman
.mob Unyielding Sorcerer
.mob Unyielding Knight
step
.isOnQuest 9589
#completewith next
>>Kill |cRXP_ENEMY_Orcs|r. Loot them for their |cRXP_LOOT_Fel Orc Blood Vials|r
.complete 9589,1 
step
.isOnQuest 9607
>>Explore the final room of the Blood Furnace
.complete 9607,1 
step
.isOnQuest 9589
>>Kill |cRXP_ENEMY_Orcs|r. Loot them for their |cRXP_LOOT_Fel Orc Blood Vials|r
.complete 9589,1 
step
.zone Hellfire Peninsula >> Exit the Blood Furnace
.subzoneskip 3713,1
step
#completewith HeartofRage
.subzone 3538 >> Return to Honor Hold
step
.isQuestComplete 9589
.goto Hellfire Peninsula,56.400,66.656
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gunny|r upstairs in the Keep
.turnin 9589 >> Turn in The Blood is Life
.target Gunny
step
#label HeartofRage
.isQuestComplete 9607
.goto Hellfire Peninsula,56.64,66.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Force Commander Danath Trollbane|r upstairs in the Keep
.turnin 9607 >> Turn in Heart of Rage
.target Force Commander Danath Trollbane
step
+|cRXP_WARN_You have completed the Blood Furnace quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 60-70
<< Alliance !classic
#name 23. The Underbog
step
#completewith EnterUB
.zone Zangarmarsh >> Travel to Zangarmarsh
step
.goto Zangarmarsh,19.368,49.785
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_T'shu|r
.accept 9717 >> Accept Oh, It's On!
.target T'shu
.reputation 970,friendly,<0,1 
.xp <63,1
step
.goto Zangarmarsh,19.650,49.701
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khn'nix|r
.accept 9719 >> Accept Stalk the Stalker
.target Khn'nix
.reputation 970,neutral,<0,1 
.xp <63,1
step
#completewith next
.isQuestAvailable 9717,9719,9738
.goto Zangarmarsh,24.93,41.85,-1 
.goto Zangarmarsh,50.379,40.900,-1 
.subzone 3905 >> |cRXP_WARN_You will now run Underbog. Grind on nearby |cRXP_ENEMY_Bloodscale Slavedrivers|r and |cRXP_ENEMY_Bloodscale Enchantresses|r until you've found a group. Zone in once you have a group|r
>>|cRXP_WARN_Once you're in a group, swim down into the Coilfang Reservoir|r
.mob Bloodscale Slavedriver
.mob Bloodscale Enchantress
.subzoneskip 3716 
step
.goto Zangarmarsh,52.291,35.959
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Watcher Jhang|r
.accept 9738 >> Accept Lost in Action
.target Watcher Jhang
step
#label EnterUB
.isQuestAvailable 9717,9719,9738
.goto Zangarmarsh,54.297,34.449
.subzone 3716 >> Zone into the Underbog
step
#sticky
>>Loot the mobs inside Underbog for |cRXP_LOOT_Sanguine Hibiscus|r
>>|cRXP_LOOT_Sanguine Hibiscus|r plants can also be looted on the ground
.collect 24246,5,9715,1 
.reputation 970,friendly,<0,1 
.subzoneskip 3716,1
step
.isOnQuest 9717
>>Loot the |cRXP_LOOT_Underspore Frond|r on the ground after defeating |cRXP_ENEMY_Hungarfen|r
.complete 9717,1 
step
.isOnQuest 9738
>>Talk to |cRXP_FRIENDLY_Earthbinder Rayge|r and |cRXP_FRIENDLY_Windcaller Claw|r inside Underbog
.complete 9738,1 
.target +Earthbinder Rayge
.complete 9738,4 
.target +Windcaller Claw
step
.isOnQuest 9719
>>Kill |cRXP_ENEMY_The Black Stalker|r. Loot it for the |cRXP_LOOT_Brain of the Black Stalker|r
.complete 9719,1 
.mob The Black Stalker
step
+|cRXP_WARN_Exit the Underbog. Consider asking your group to run the Slave Pens now if you wish to also complete that|r
.subzoneskip 3716,1
step
#optional
.isQuestComplete 9738
.goto Zangarmarsh,52.291,35.959
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Watcher Jhang|r
.turnin 9738 >> Turn in Lost in Action
.target Watcher Jhang
step
#optional
.isQuestComplete 9717
.goto Zangarmarsh,19.368,49.785
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_T'shu|r
.turnin 9717 >> Turn in Oh, It's On!
.target T'shu
step
#optional
.isQuestComplete 9719
.goto Zangarmarsh,19.650,49.701
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khn'nix|r
.turnin 9719 >> Turn in Stalk the Stalker
.target Khn'nix
step
#optional
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gzhun'tt|r
.accept 9715 >> Accept Bring Me A Shrubbery!
.turnin 9715 >> Turn in Bring Me A Shrubbery!
.goto Zangarmarsh,19.54,50.04
.target Gzhun'tt
.itemcount 24246,5 
.reputation 970,friendly,<0,1 
.xp <63,1
step
+|cRXP_WARN_You have completed the Underbog quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 60-70
<< Alliance !classic
#name 24. The Slave Pens
step
#completewith EnterSP
.zone Zangarmarsh >> Travel to Zangarmarsh
step
.goto Zangarmarsh,52.291,35.959
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Watcher Jhang|r
.accept 9738 >> Accept Lost in Action
.target Watcher Jhang
step
#label EnterSP
.goto Zangarmarsh,49.018,35.631
.subzone 3717 >> Zone into the Slave Pens
step
.isOnQuest 9738
>>Talk to |cRXP_FRIENDLY_Naturalist Bite|r and |cRXP_FRIENDLY_Weeder Greenthumb|r inside the Slave Pens
.complete 9738,2 
.target +Naturalist Bite
.complete 9738,3 
.target +Weeder Greenthumb
step
+|cRXP_WARN_Exit the Slave Pens|r
.subzoneskip 3717,1
step
#optional
.isQuestComplete 9738
.goto Zangarmarsh,52.291,35.959
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Watcher Jhang|r
.turnin 9738 >> Turn in Lost in Action
.target Watcher Jhang
step
+|cRXP_WARN_You have completed the Slave Pens quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 60-70
<< Alliance !classic
#name 25. Mana-Tombs
step
#completewith MTQuests
.zone Terokkar Forest >> Travel to Terokkar Forest
step
.isQuestAvailable 10216,10165,10218
#completewith MT1
.subzone 3792 >> |cRXP_WARN_You will shortly run Mana-Tombs. Start looking for a group to run it|r
step
#completewith next
.isQuestAvailable 10216,10165,10218
.goto Terokkar Forest,39.58,59.52,0
.subzone 3792 >> |cRXP_WARN_You will now run Mana-Tombs. Grind on nearby |cRXP_ENEMY_Cabals|r until you've found a group. Once you have found a group, head to Mana-Tombs and accept the quests outside of the dungeon|r
>>|cRXP_WARN_NOTE: You must be level 64 to accept the quests for Mana-Tombs!|r
.subzoneskip 3893 
.mob Cabal Initiate
.mob Cabal Spell-weaver
.mob Cabal Skirmisher
step
#label MTQuests
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Artificer Morphalius|r and |cRXP_FRIENDLY_Nexus-Prince Haramad|r
>>|cRXP_WARN_NOTE: These quests require level 64 to accept!|r
.accept 10216 >> Accept Safety Is Job One
.target +Artificer Morphalius
.goto Terokkar Forest,39.422,58.514
.accept 10165 >> Accept Undercutting the Competition
.target +Nexus-Prince Haramad
.goto Terokkar Forest,39.371,58.475
step
>>Kill |cRXP_ENEMY_Ethereal Crypt Raiders|r, |cRXP_ENEMY_Nexus Stalkers|r, |cRXP_ENEMY_Ethereal Sorcerers|r and |cRXP_ENEMY_Ethereal Spellbinders|r
.complete 10216,1 
.mob +Ethereal Crypt Raider
.complete 10216,2 
.mob +Nexus Stalker
.complete 10216,3 
.mob +Ethereal Sorcerer
.complete 10216,4 
.mob +Ethereal Spellbinder
step
.isQuestComplete 10216
>>Click the |cRXP_PICK_Ethereal Transporter Control Panel|r inside the dungeon
>>|cRXP_WARN_It is recommended not to accept the follow up escort quest until you have cleared the dungeon|r
.turnin 10216 >> Turn in Safety Is Job One
step
>>Kill |cRXP_ENEMY_Nexus-Prince Shaffar|r. Loot him for |cRXP_LOOT_Shaffar's Wrappings|r
.complete 10165,1 
step
.isQuestTurnedIn 10216
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Cryo-Engineer Sha'heen|r
.accept 10218 >> Accept Someone Else's Hard Work Pays Off
.target Cryo-Engineer Sha'heen
step
>>Escort |cRXP_FRIENDLY_Cryo-Engineer Sha'heen|r out of the Mana-Tombs
.complete 10218,1 
.target Cryo-Engineer Sha'heen
step
#completewith MTTurnins
.zone Terokkar Forest >> |cRXP_WARN_Exit the Mana-Tombs|r
.subzoneskip 3792,1
step
.isQuestComplete 10165
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nexus-Prince Haramad|r
.turnin 10165 >> Turn in Undercutting the Competition
.target Nexus-Prince Haramad
.goto Terokkar Forest,39.371,58.475
step
#label MTTurnins
.isQuestComplete 10218
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nexus-Prince Haramad|r
.turnin 10218 >> Turn in Someone Else's Hard Work Pays Off
.target Nexus-Prince Haramad
.goto Terokkar Forest,39.371,58.475
step
+|cRXP_WARN_You have completed the Mana-Tombs quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 60-70
<< Alliance !classic
#name 26. Auchenai Crypts
step
#completewith CryptsQ
.zone Terokkar Forest >> Travel to Terokkar Forest
step
#sticky
+|cRXP_WARN_There is only 1 quest for Auchenai Crypts and it is chain requiring to go to multiple zones. Simply find a group and run Auchenai Crypts if you wish to skip it, however below is the full quest chain if you wish to complete it all|r
step
.goto Terokkar Forest,35.091,65.085
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ha'lei|r
>>|cRXP_FRIENDLY_Ha'lei|r |cRXP_WARN_is located outside the Auchenai Crypts instance portal|r
.accept 10227 >> Accept I See Dead Draenei
.target Ha'lei
step
.goto Terokkar Forest,35.158,66.308
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ramdor the Mad|r
.turnin 10227 >> Turn in I See Dead Draenei
.accept 10228 >> Accept Ezekiel
.target Ramdor the Mad
step
#completewith WhatBook
.zone Shattrath City >> Travel to Shattrath
step
.goto Shattrath City,53.0,57.8,70,0
.goto Shattrath City,45.4,48.2,70,0
.goto Shattrath City,52.0,33.2,70,0
.goto Shattrath City,60.6,37.2,70,0
.goto Shattrath City,61.6,51.0,70,0
.goto Shattrath City,54.6,57.8,70,0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ezekiel|r
>>|cRXP_FRIENDLY_Ezekiel|r |cRXP_WARN_patrols the inner ring of Shattrath|r
.turnin 10228 >> Turn in Ezekiel
.accept 10231 >> Accept What Book? I Don't See Any Book.
.target Ezekiel
step
#label WhatBook
.goto Shattrath City,43.632,29.761
>>Talk to then attack |cRXP_ENEMY_"Dirty" Larry|r until he turns friendly
>>|cRXP_WARN_This quest is difficult. Find a group for it if needed|r
.complete 10231,1 
.turnin 10231 >> Turn in What Book? I Don't See Any Book.
.accept 10251 >> Accept The Master's Grand Design?
.target "Dirty" Larry
step
#completewith VotD
.zone Nagrand >> Travel to Nagrand
step
.goto Nagrand,51.389,57.172,20,0
.goto Nagrand,51.820,56.845
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nitrin the Learned|r inside the building
.turnin 10251 >> Turn in The Master's Grand Design?
.accept 10252 >> Accept Vision of the Dead
.target Nitrin the Learned
step
>>Kill |cRXP_ENEMY_Mountain Gronns|r. Loot it for its |cRXP_LOOT_Eyeball|r
>>Kill |cRXP_ENEMY_Greater Windrocs|r. Loot them for their |cRXP_LOOT_Flawless Greater Windroc Beak|r
>>Kill |cRXP_ENEMY_Aged Clefthoofs|r. Loot them for their |cRXP_LOOT_Aged Clefthoof Blubber|r
.complete 10252,1 
.goto Nagrand,24.37,41.81
.mob +Mountain Gronn
.complete 10252,2 
.goto Nagrand,35.97,29.37,55,0
.goto Nagrand,35.71,18.67,55,0
.goto Nagrand,32.69,22.30,55,0
.goto Nagrand,33.39,26.11,55,0
.goto Nagrand,30.88,32.97
.mob +Greater Windroc
.complete 10252,3 
.goto Nagrand,30.88,63.61,75,0
.goto Nagrand,32.53,61.08,75,0
.goto Nagrand,33.99,60.44,75,0
.goto Nagrand,36.31,58.76,75,0
.goto Nagrand,37.39,58.63,75,0
.goto Nagrand,38.67,59.52,75,0
.goto Nagrand,40.46,60.74,75,0
.goto Nagrand,44.52,61.64,75,0
.goto Nagrand,46.20,63.09,75,0
.goto Nagrand,46.71,66.40,75,0
.goto Nagrand,46.31,67.69,75,0
.goto Nagrand,45.46,68.24,75,0
.goto Nagrand,43.63,68.35,75,0
.goto Nagrand,43.05,67.77,75,0
.goto Nagrand,42.75,66.72,75,0
.goto Nagrand,42.56,64.36,75,0
.goto Nagrand,41.98,62.64,75,0
.goto Nagrand,40.82,61.30,75,0
.goto Nagrand,38.67,59.52
.mob +Aged Clefthoof
step
#label VotD
.goto Nagrand,51.389,57.172,20,0
.goto Nagrand,51.820,56.845
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nitrin the Learned|r inside the building
.turnin 10252 >> Turn in Vision of the Dead
.accept 10253 >> Accept Levixus the Soul Caller
.target Nitrin the Learned
step
#completewith next
.zone Terokkar Forest >> Travel to Terokkar Forest
step
.goto Terokkar Forest,39.64,71.28
>>Kill |cRXP_ENEMY_Levixus|r. Loot him for him for his |cRXP_LOOT_Book of the Dead|r
>>|cRXP_WARN_Be careful, |cRXP_ENEMY_Levixus|r is a strong elite. He can cast|r |T136206:0|t[Mind Control]|cRXP_WARN_,|r |T136135:0|t[Cripple] |cRXP_WARN_and he can summon an|r |T136219:0|t[Inferno]
>>|cRXP_WARN_It is recommended to do this with at least 3 players|r
.complete 10253,1 
.mob Levixus
step
.goto Terokkar Forest,35.14,66.25
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ramdor the Mad|r
.turnin 10253 >>Turn in Levixus the Soul Caller
.target Ramdor the Mad
step
.goto Terokkar Forest,35.03,65.16
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to|r |cRXP_FRIENDLY_Greatfather Aldrimus|r
.accept 10164 >>Accept Everything Will Be Alright
.target Greatfather Aldrimus
.isQuestTurnedIn 10253
step
#label CryptsQ
.goto Terokkar Forest,34.40,65.59
.subzone 3790 >>Find a group and complete Auchenai Crypts
step
>>Kill |cRXP_ENEMY_Exarch Maladaar|r
.complete 10164,1 
.mob Exarch Maladaar
.isOnQuest 10164
step
.goto Terokkar Forest,35.03,65.16
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to|r |cRXP_FRIENDLY_Greatfather Aldrimus|r
.turnin 10164 >>Turn in Everything Will Be Alright
.target Greatfather Aldrimus
.isQuestComplete 10164
step
+|cRXP_WARN_You have completed the Auchenai Crypts quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 60-70
<< Alliance !classic
#name 27. Sethekk Halls
step
#optional
.goto Shattrath City,57.989,15.161
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Oloraak|r
.accept 10180 >> Accept Can't Stay Away
.target Oloraak
.zoneskip Shattrath City,1
step
#completewith next
.goto Terokkar Forest,43.1,65.6,20 >>Travel to Sethekk Halls in Auchindoun
step
.goto Terokkar Forest,44.070,64.963
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Isfar|r
.turnin -10180 >>Turn In Can't Stay Away
.accept 10097 >>Accept Brother Against Brother
.accept 10098 >>Accept Terokk's Legacy
.target Isfar
step
.goto Terokkar Forest,44.90,65.61,10 >>Enter Sethekk Halls
step
>>Kill |cRXP_ENEMY_Darkweaver Syth|r. Loot him for |cRXP_LOOT_Terokk's Mask|r
>>Click on |cRXP_FRIENDLY_Lakka's|r cage
.complete 10097,1 
.complete 10098,2 
.complete 10097,2 
step
>>Loot |cRXP_PICK_The Saga of Terokk|r on the ground
>>|cRXP_WARN_This is in the centre of the room before the final boss|r
.complete 10098,1 
step
>>Kill |cRXP_ENEMY_Talon King Ikiss|r. Loot him for |cRXP_LOOT_Terokk's Quill|r
.complete 10098,3 
step
>>Open |cRXP_PICK_The Talon King's Coffer|r. Loot it for the |cRXP_LOOT_Shadow Labyrinth Key|r
.collect 27991,1 
step
.goto Terokkar Forest,44.070,64.963
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Isfar|r
.turnin 10097 >>Turn In Brother Against Brother
.turnin 10098 >>Turn In Terokk's Legacy
.target Isfar
step
+|cRXP_WARN_You have completed the Sethekk Halls quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 60-70
<< Alliance !classic
#name 28. Old Hillsbrad (Escape from Durnholde)
step
#completewith CoTUnlock
.zone Tanaris >> Travel to Tanaris
step
#completewith CoTUnlock
.goto Tanaris,65.33,49.713,20 >> Travel to the Caverns of Time
step
.goto Tanaris,65.334,49.711
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Steward of Time|r
.target Steward of Time
.accept 10279 >>Accept To The Master's Lair
step
.goto Tanaris,58.06,54.097
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Andormu|r
.target Andormu
.turnin 10279 >>Turn in To The Master's Lair
.accept 10277 >>Accept The Caverns of Time
step
>>|cRXP_WARN_You may either follow your |cRXP_FRIENDLY_Custodian of Time|r around the Caverns, or simply wait beside|r |cRXP_FRIENDLY_Andormu|r << tbc
>>|cRXP_WARN_Follow your |cRXP_FRIENDLY_Custodian of Time|r around the Caverns|r << wotlk
>>|cRXP_WARN_This RP takes approximately 10 minutes|r
.complete 10277,1 
.target Custodian of Time
step
#label CoTUnlock
.goto Tanaris,58.06,54.097
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Andormu|r
.target Andormu
.turnin 10277 >>Turn in The Caverns of Time
.accept 10282 >>Accept Old Hillsbrad
step
#completewith next
.goto Tanaris,55.416,53.529,30 >> Enter Old Hillsbrad (Escape from Durnholde)
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Andormu|r
.turnin 10282 >>Turn in Old Hillsbrad
.accept 10283 >>Accept Taretha's Diversion
.target Erozion
step
>>Click the five |cRXP_PICK_Barrels|r inside the Lodges
.complete 10283,1 
step
#completewith next
+|cRXP_WARN_Ensure quest auto accept has been turned OFF from other addons like Questie etc for this upcoming step!|r
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thrall|r
>>|cRXP_WARN_Only accept this quest once all of your party has turned in Taretha's Diversion. Rested XP has auto accept turned OFF for this step|r
.turnin 10283 >> Turn in Taretha's Diversion
.accept 10284,1 >>Accept Escape from Durnholde
.target Thrall
step
>>Complete Old Hillsbrad. Ensure you keep |cRXP_FRIENDLY_Thrall|r alive
.complete 10284,1 
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Erozion|r
.turnin 10284 >> Turn in Escape from Durnholde
.accept 10285 >> Accept Return to Andormu
.target Erozion
step
#completewith next
+Talk to |cRXP_FRIENDLY_Erozion|r to teleport back to the Caverns of Time
.skipgossip
.target Erozion
step
.goto Tanaris,58.062,54.095
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Andormu|r
.target Andormu
.turnin 10285 >>Turn in Return to Andormu
step
+|cRXP_WARN_You have completed the Old Hillsbrad (Escape from Durnholde) quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 60-70
<< Alliance !classic
#name 29. Black Morass (Opening the Dark Portal)
step
#optional
.isQuestAvailable 10285
+You must first complete Old Hillsbrad (Escape from Durnholde) in order to enter Black Morass (Opening the Dark Portal)
step
.zone Tanaris >> Travel to Tanaris
.subzoneskip 1941
step
.goto Tanaris,65.33,49.713,20 >> Travel to the Caverns of Time
.subzoneskip 1941
step
.goto Tanaris,58.062,54.095
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Andormu|r
.target Andormu
.accept 10296 >>Accept The Black Morass
step
#completewith next
.goto Tanaris,57.048,62.237,30 >> Enter the Black Morass (Opening the Dark Portal)
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sa'at|r
.target Sa'at
.turnin 10296 >>Turn in The Black Morass
.accept 10297 >>Accept The Opening of the Dark Portal
step
>>Complete the Black Morass
.complete 10297,1
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sa'at|r
.target Sa'at
.turnin 10297 >>Turn in The Opening of the Dark Portal
.accept 10298 >>Accept Hero of the Brood
step
#completewith next
.goto Tanaris,58.062,54.095,30 >> Return to |cRXP_FRIENDLY_Andormu|r in the Caverns of Time
step
.goto Tanaris,58.062,54.095
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Andormu|r
.target Andormu
.turnin 10298 >>Turn in Hero of the Brood
step
+|cRXP_WARN_You have completed the Black Morass (Opening the Dark Portal) quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 60-70
<< Alliance !classic
#name 30. Shadow Labyrinth
step
#completewith EnterSL
.goto Terokkar Forest,40.043,72.156,15 >> Travel to the Shadow Labyrinth in Auchindoun
step
.goto Terokkar Forest,40.043,72.156
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Field Commander Mahfuun|r
.target Field Commander Mahfuun
.accept 10094 >>Accept The Codex of Blood
step
.goto Terokkar Forest,39.938,72.286
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spy Grik'tha|r
.target Spy Grik'tha
.accept 10178 >>Accept Find Spy To'gun
step
#label EnterSL
.goto Terokkar Forest,39.636,73.536,10 >> Enter the Shadow Labyrinth
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Field Commander Mahfuun|r
>>|cRXP_FRIENDLY_Spy To'gun|r |cRXP_WARN_is located down the hallway behind|r |cRXP_ENEMY_Ambassador Hellmaw|r
.turnin 10178 >>Turn in Find Spy To'gun
.accept 10091 >>Accept The Soul Devices
.target Spy To'gun
step
#completewith KillMurmur
>>Loot the |cRXP_PICK_Soul Devices|r on the ground
.complete 10091,1 
step
>>Click the |cRXP_PICK_The Codex of Blood|r
>>|cRXP_WARN_This is located beneath|r |cRXP_ENEMY_Grandmaster Vorpil|r
.turnin 10094 >>Turn in The Codex of Blood
.accept 10095 >>Accept Into the Heart of the Labyrinth
step
#label KillMurmur
>>Kill |cRXP_ENEMY_Murmur|r
.complete 10095,1 
step
>>Loot the |cRXP_PICK_Soul Devices|r on the ground
.complete 10091,1 
step
#completewith next
.zone Shattrath City >> Travel to Shattrath City
step
.goto Shattrath City,50.246,45.356
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spymistress Mehlisah Highcrown|r
.target Spymistress Mehlisah Highcrown
.turnin 10091 >>Turn in The Soul Devices
.turnin 10095 >>Turn in Into the Heart of the Labyrinth
step
+|cRXP_WARN_You have completed the Shadow Labyrinth quest guide. Please select a new guide|r
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#version 1
#group Original Guides - RXP Dungeon Quest Guides (A)
#subgroup 60-70
<< Alliance !classic
#name 31. The Steamvault
step
#optional
#completewith next
.zone Shattrath City >>Travel to Shattrath City
step
#optional
.goto Shattrath City,54.73,44.33
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khadgar|r
.accept 9832 >>Accept The Second and Third Fragments
.target Khadgar
.isQuestTurnedIn 9831
step
#completewith EnterSV
.goto Zangarmarsh,50.37,40.84,25,0
.goto Zangarmarsh,51.91,35.99,70 >>Swim through the underwater tunnel into Coilfang Reservoir
step
.goto Zangarmarsh,52.291,35.959
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Watcher Jhang|r
.accept 9763 >>Accept The Warlord's Hideout
.target Watcher Jhang
step
#label EnterSV
.goto Zangarmarsh,50.38,33.36
.subzone 3715 >>Enter The Steamvault
step
#sticky
>>Loot the |T134332:0|t[|cRXP_LOOT_Orders from Lady Vashj|r]
>>|cRXP_WARN_This can drop from any of the |cRXP_ENEMY_Coilfang Naga|r in The Steamvault|r
>>|cRXP_WARN_You may have to more than one run to get the drop|r
.collect 24367,1,9764 
.accept 9764 >>Accept Orders from Lady Vashj
step
#optional
>>Open the |cRXP_PICK_Arcane Container|r to spawn the |cRXP_ENEMY_Fragment Guardian|r
>>Kill the |cRXP_ENEMY_Fragment Guardian|r. Loot them for the |cRXP_LOOT_Second Key Fragment|r
.complete 9832,1 
.mob Second Fragment Guardian
.isOnQuest 9832
step
>>Kill |cRXP_ENEMY_Warlord Kalithresh|r
.complete 9763,1 
.mob Warlord Kalithresh
step
#completewith SVTurnins
.zone Zangarmarsh >>Exit The Steamvault
.subzoneskip 3715,1
step
.goto Zangarmarsh,52.291,35.959
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Watcher Jhang|r
.turnin 9763 >>Turn in The Warlord's Hideout
.target Watcher Jhang
.isQuestComplete 9763
step
#label SVTurnins
.goto Zangarmarsh,78.40,62.02
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ysiel|r
.turnin 9764 >>Turn in Orders from Lady Vashj
.target Ysiel Windsinger
.isOnQuest 9764
step
+|cRXP_WARN_You have completed the Steamvault quest guide. Please select a new guide|r
]]);
