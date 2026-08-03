-- Generated from RXPGuides v4.10.20 by tools/Build-TBCGuides335.ps1.
-- Curated for the standalone 3.3.5a backport; do not replace with the upstream aggregate file.
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 15-30
<< Horde
#name 101 Ragefire Chasm
#displayname 1. Ragefire Chasm
step
#completewith EnterRFC
+|cRXP_WARN_You will now be directed to pick up all available quests for Ragefire Chasm|r
>>|cRXP_WARN_Some quests have long travel time. Feel free to skip them|r
step
#completewith TBPickups
.zone Thunder Bluff >>Travel to |cFFfa9602Thunder Bluff|r
step
#label TBPickups
.goto Thunder Bluff,70.4,29.6
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Rahauro|r
.accept 5722 >>Accept Searching for the Lost Satchel
.accept 5723 >>Accept Testing an Enemy's Strength
.target Rahauro
step
#completewith next
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thrall|r
>>|cRXP_WARN_This is a prerequisite quest for Ragefire Chasm|r
.accept 5726 >>Accept Hidden Enemies
.target Thrall
step
.goto Orgrimmar,54.10,68.42
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Innkeeper Gryshka|r
>>|cRXP_WARN_This is so you can Hearth after completing the dungeon|r
.home >> Set your Hearthstone to Orgrimmar
.target Innkeeper Gryshka
.zoneskip Orgrimmar,1
.bindlocation 1637
.isQuestAvailable 5725
step
#completewith UCZep1
.zone Durotar >>Leave Orgrimmar
.zoneskip Undercity
step
.goto Durotar,53.08,9.19
>>Kill |cRXP_ENEMY_Burning Blade|r mobs in Skull Rock until |cRXP_LOOT_Lieutenant's Insignia|r drops
.complete 5726,1 
.isOnQuest 5726
step
#label UCZep1
#completewith UCPickup
.goto Durotar,50.8,13.8,40 >>Go up the Zeppelin Tower
.zone Tirisfal Glades >>Take the Zeppelin to Tirisfal Glades
.zoneskip Tirisfal Glades
.zoneskip Undercity
.isQuestAvailable 5725
step
#requires UCZep1
#label Undercity1
#completewith UCPickup
.goto Tirisfal Glades,61.80,65.06,20,0
.zone Undercity >>Enter |cFFfa9602Undercity|r
.zoneskip Undercity
.isQuestAvailable 5725
step
#requires Undercity1
#completewith UCPickup
.goto Undercity,66.09,20.06,35,0
.goto Undercity,64.37,23.94,35,0
.goto Undercity,65.93,26.71,10,0
.goto Undercity,65.89,34.03,10,0
.goto Undercity,64.22,39.77,10,0
.goto Undercity,65.53,43.62,15 >>Take the lift down to the Undercity
.isQuestAvailable 5725
step
#requires Undercity1
#completewith UCPickup
.goto Undercity,51.99,64.54,10,0
.goto Undercity,46.25,73.22,10,0
.goto Undercity,45.32,78.32,10,0
.goto Undercity,46.26,83.91,10,0
.goto Undercity,49.03,87.92,10,0
.goto Undercity,52.94,89.60,10 >>Enter the Royal Quarter
.isQuestAvailable 5725
step
#label UCPickup
.goto Undercity,56.2,96.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Varimathras|r
.accept 5725 >>Accept The Power to Destroy...
.target Varimathras
step
#optional
#completewith EnterRFC
.hs >>Hearth to Orgrimmar
.cooldown item,6948,>0,1
.use 6948
.zoneskip Orgrimmar
.bindlocation 1637,1
step
#completewith EnterRFC
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thrall|r
.turnin 5726 >>Turn in Hidden Enemies
.accept 5727 >>Accept Hidden Enemies
.target Thrall
.isQuestComplete 5726
step
#optional
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thrall|r
.accept 5727 >>Accept Hidden Enemies
.target Thrall
.isQuestTurnedIn 5726
step
.goto Orgrimmar,49.6,50.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Neeru Fireblade|r
.accept 5761 >>Accept Slaying the Beast
.target Neeru Fireblade
step
.goto Orgrimmar,49.6,50.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Neeru Fireblade|r
.complete 5727,1 
.skipgossip
.target Neeru Fireblade
.isOnQuest 5727
step
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thrall|r
.turnin 5727 >>Turn in Hidden Enemies
.accept 5728 >>Accept Hidden Enemies
.target Thrall
.isQuestComplete 5727
step
#optional
#label OrgPickups
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thrall|r
.accept 5728 >>Accept Hidden Enemies
.target Thrall
.isQuestTurnedIn 5727
step
#completewith EnterRFC
.destroy 14544 >>|cRXP_WARN_Destroy|r |T134417:0|t[Lieutenant's Insignia] |cRXP_WARN_as you no longer need it|r
step
#label EnterRFC
.goto Orgrimmar,52.77,48.97
.subzone 2437 >>Enter the Ragefire Chasm Instance portal. Zone in
step
#completewith next
>>Kill |cRXP_ENEMY_Ragefire Troggs|r and |cRXP_ENEMY_Ragefire Shamans|r
.complete 5723,1 
.mob +Ragefire Trogg
.complete 5723,2 
.mob +Ragefire Shaman
.isOnQuest 5723
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Maur|r
.turnin 5722 >>Turn in Searching for the Lost Satchel
.accept 5724 >>Accept Returning the Lost Satchel
.target Maur Grimtotem
.isOnQuest 5722
step
#optional
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Maur|r
.accept 5724 >>Accept Returning the Lost Satchel
.target Maur Grimtotem
.isQuestTurnedIn 5722
step
#label TroggsShamans
>>Kill |cRXP_ENEMY_Ragefire Troggs|r and |cRXP_ENEMY_Ragefire Shamans|r
.complete 5723,1 
.mob +Ragefire Trogg
.complete 5723,2 
.mob +Ragefire Shaman
.isOnQuest 5723
step
#requires TroggsShamans
#completewith BazzalanandJergosh
>>Kill |cRXP_ENEMY_Searing Blade Cultists|r and |cRXP_ENEMY_Searing Blade Warlocks|r. Loot them for the |cRXP_LOOT_Spells of Shadow|r and |cRXP_LOOT_Incantations from the Nether|r
.complete 5725,1 
.complete 5725,2 
.mob Searing Blade Cultist
.mob Searing Blade Warlock
.isOnQuest 5725
step
>>Kill |cRXP_ENEMY_Taragaman the Hungerer|r. Loot him for his |cRXP_LOOT_Heart|r
.complete 5761,1 
.mob Taragaman the Hungerer
.isOnQuest 5761
step
#label BazzalanandJergosh
>>Kill |cRXP_ENEMY_Bazzalan|r and |cRXP_ENEMY_Jergosh the Invoker|r
.complete 5728,1 
.mob +Bazzalan
.complete 5728,2 
.mob +Jergosh the Invoker
.isOnQuest 5728
step
>>Kill |cRXP_ENEMY_Searing Blade Cultists|r and |cRXP_ENEMY_Searing Blade Warlocks|r. Loot them for the |cRXP_LOOT_Spells of Shadow|r and |cRXP_LOOT_Incantations from the Nether|r
.complete 5725,1 
.complete 5725,2 
.mob Searing Blade Cultist
.mob Searing Blade Warlock
.isOnQuest 5725
step
#completewithTBTurnins
+|cRXP_WARN_You will now be directed to turn in all completed quests for Ragefire Chasm|r
step
#optional
.zone Orgrimmar >>Exit Ragefire Chasm
.zoneskip Durotar
.zoneskip Undercity
.zoneskip Thunder Bluff
.zoneskip The Barrens
.zoneskip Tirisfal Glades
.zoneskip Mulgore
step
.goto Orgrimmar,49.6,50.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Neeru Fireblade|r
.turnin 5761 >>Turn in Slaying the Beast
.target Neeru Fireblade
.isQuestComplete 5761
step
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thrall|r
.turnin 5728 >>Turn in Hidden Enemies
.accept 5729 >>Accept Hidden Enemies
.target Thrall
.isQuestComplete 5728
step
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thrall|r
.accept 5729 >>Accept Hidden Enemies
.target Thrall
.isQuestTurnedIn 5728
step
.goto Orgrimmar,49.6,50.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Neeru Fireblade|r
.turnin 5729 >>Turn in Hidden Enemies
.accept 5730 >>Accept Hidden Enemies
.target Neeru Fireblade
.isQuestTurnedIn 5728
step
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thrall|r
.turnin 5730 >>Turn in Hidden Enemies
.target Thrall
.isQuestTurnedIn 5728
step
#completewith next
.zone Durotar >>Leave Orgrimmar
.zoneskip Undercity
step
#label UCZep2
#completewith UCPickup
.goto Durotar,50.8,13.8,40 >>Go up the Zeppelin Tower
.zone Tirisfal Glades >>Take the Zeppelin to Tirisfal Glades
.zoneskip Tirisfal Glades
.zoneskip Undercity
.isQuestComplete 5725
step
#requires UCZep2
#label Undercity2
#completewith UCPickup
.goto Tirisfal Glades,61.80,65.06,20,0
.zone Undercity >>Enter |cFFfa9602Undercity|r
.zoneskip Undercity
.isQuestComplete 5725
step
#requires Undercity2
#completewith UCTurnin
.goto Undercity,66.09,20.06,35,0
.goto Undercity,64.37,23.94,35,0
.goto Undercity,65.93,26.71,10,0
.goto Undercity,65.89,34.03,10,0
.goto Undercity,64.22,39.77,10,0
.goto Undercity,65.53,43.62,15 >>Take the lift down to the Undercity
.isQuestComplete 5725
step
#requires Undercity2
#completewith UCTurnin
.goto Undercity,51.99,64.54,10,0
.goto Undercity,46.25,73.22,10,0
.goto Undercity,45.32,78.32,10,0
.goto Undercity,46.26,83.91,10,0
.goto Undercity,49.03,87.92,10,0
.goto Undercity,52.94,89.60,10 >>Enter the Royal Quarter
.isQuestComplete 5725
step
#label UCTurnin
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Varimathras|r
.turnin 5725 >>Turn in The Power to Destroy...
.target Varimathras
.isQuestComplete 5725
step
#completewith TBTurnins
.zone Thunder Bluff >>Travel to |cFFfa9602Thunder Bluff|r
step
.goto Thunder Bluff,70.4,29.6
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Rahauro|r
.turnin 5724 >>Turn in Returning the Lost Satchel
.turnin 5723 >>Turn in Testing an Enemy's Strength
.target Rahauro
.isOnQuest 5724
.isQuestComplete 5723
step
#optional
.goto Thunder Bluff,70.4,29.6
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Rahauro|r
.turnin 5724 >>Turn in Returning the Lost Satchel
.target Rahauro
.isOnQuest 5724
step
#optional
#label TBTurnins
.goto Thunder Bluff,70.4,29.6
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Rahauro|r
.turnin 5723 >>Turn in Testing an Enemy's Strength
.target Rahauro
.isQuestComplete 5723
step
+|cRXP_WARN_This is the end of the Ragefire Chasm guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 15-30
<< Horde
#name 102 Wailing Caverns
#displayname 2. Wailing Caverns
step
#completewith WCPickups
+|cRXP_WARN_You will now be directed to pick up all available quests for Wailing Caverns|r
>>|cRXP_WARN_Some quests have long travel time. Feel free to skip them|r
step
.goto The Barrens,52.26,31.93
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tonga|r
>>|cRXP_WARN_This is a prerequisite quest for Wailing Caverns|r
.accept 870 >>Accept The Forgotten Pools
.target Tonga Runetotem
step
#completewith next
.subzone 386 >>Travel to the Forgotten Pools
step
.goto The Barrens,45.06,22.54
>>Dive underwater to the |cRXP_PICK_Bubble Fissure|r
.complete 870,1 
.isOnQuest 870
step
.goto The Barrens,52.26,31.93
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tonga|r
>>|cRXP_WARN_This is a prerequisite quest for Wailing Caverns|r
.turnin 870 >>Turn in The Forgotten Pools
.accept 877 >>Accept The Stagnant Oasis
.target Tonga Runetotem
.isQuestComplete 870
step
#optional
.goto The Barrens,52.26,31.93
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tonga|r
>>|cRXP_WARN_This is a prerequisite quest for Wailing Caverns|r
.accept 877 >>Accept The Stagnant Oasis
.target Tonga Runetotem
.isQuestTurnedIn 870
step
#completewith next
.subzone 388 >>Travel to the Stagnant Oasis
step
.goto The Barrens,55.61,42.75
>>Click the |cRXP_PICK_Bubble Fissure|r underwater
.complete 877,1 
.isOnQuest 877
step
.goto The Barrens,52.26,31.93
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tonga|r
>>|cRXP_WARN_This is a prerequisite quest for Wailing Caverns|r
.turnin 877 >>Turn in The Stagnant Oasis
.accept 880 >>Accept Altered Beings
.target Tonga Runetotem
.isQuestComplete 877
step
#optional
.goto The Barrens,52.26,31.93
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tonga|r
>>|cRXP_WARN_This is a prerequisite quest for Wailing Caverns|r
.accept 880 >>Accept Altered Beings
.target Tonga Runetotem
.isQuestTurnedIn 877
step
#completewith next
.subzone 388 >>Travel to the Stagnant Oasis
step
#loop
.goto The Barrens,55.59,43.39,0
.goto The Barrens,46.68,39.69,0
.goto The Barrens,55.59,43.39,40,0
.goto The Barrens,55.09,43.00,40,0
.goto The Barrens,55.03,42.21,40,0
.goto The Barrens,55.47,41.51,40,0
.goto The Barrens,55.99,42.00,40,0
.goto The Barrens,56.15,42.53,40,0
.goto The Barrens,56.01,43.40,40,0
>>Kill |cRXP_ENEMY_Oasis Snapjaws|r in and around the lake. Loot them for their |cRXP_LOOT_Shells|r
>>|cRXP_WARN_Additional|r |cRXP_ENEMY_Oasis Snapjaws|r |cRXP_WARN_can be found at the Stagnant Oasis (marked on your map)|r
.complete 880,1 
.mob Oasis Snapjaw
.isOnQuest 880
step
.goto The Barrens,52.26,31.93
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tonga|r
>>|cRXP_WARN_This is a prerequisite quest for Wailing Caverns|r
.turnin 880 >>Turn in Altered Beings
.accept 1489 >>Accept Hamuul Runetotem
.target Tonga Runetotem
.isQuestComplete 880
step
#optional
.goto The Barrens,52.26,31.93
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tonga|r
>>|cRXP_WARN_This is a prerequisite quest for Wailing Caverns|r
.accept 1489 >>Accept Hamuul Runetotem
.target Tonga Runetotem
.isQuestTurnedIn 880
step
#completewith RatchetPickups
.subzone 392 >>Travel to |cFFfa9602Ratchet|r
step
.goto The Barrens,62.37,37.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mebok|r
.accept 1491 >>Accept Smart Drinks
.target Mebok Mizzyrix
step
#label RatchetPickups
.goto The Barrens,63.09,37.61
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bigglefuzz|r
.accept 959 >>Accept Trouble at the Docks
.target Crane Operator Bigglefuzz
step
.goto The Barrens,62.05,39.41
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Innkeeper Wiley|r
>>|cRXP_WARN_This is so you can Hearth after completing the dungeon|r
.home >>Set your Hearthstone to Ratchet
.target Innkeeper Wiley
.bindlocation 392
.subzoneskip 392,1
step
#completewith TBPickups
.zone Thunder Bluff >>Travel to |cFFfa9602Thunder Bluff|r
step
#completewith next
.goto Thunder Bluff,28.51,28.95,10 >>Travel to the Spirit Rise and enter the pools of vision
step
.goto Thunder Bluff,22.82,20.88
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Zamah|r
.accept 962 >>Accept Serpentbloom
.target Apothecary Zamah
step
#completewith TBPickups
.goto Thunder Bluff,69.88,30.90,80 >>Travel to the Elder Rise
step
.goto Thunder Bluff,78.61,28.55
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hamuul|r
.turnin 1489 >>Turn in Hamuul Runetotem
.accept 1490 >>Accept Nara Wildmane
.target Arch Druid Hamuul Runetotem
.isOnQuest 1489
step
#optional
.goto Thunder Bluff,78.61,28.55
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hamuul|r
.accept 1490 >>Accept Nara Wildmane
.target Arch Druid Hamuul Runetotem
.isQuestTurnedIn 1489
step
.goto Thunder Bluff,75.65,31.57
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nara|r
.turnin 1490 >>Turn in Nara Wildmane
.accept 914 >>Accept Leaders of the Fang
.target Nara Wildmane
.isOnQuest 1490
step
#label TBPickups
#optional
.goto Thunder Bluff,75.65,31.57
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nara|r
.accept 914 >>Accept Leaders of the Fang
.target Nara Wildmane
.isQuestTurnedIn 1490
step
#completewith WCPickups
.goto The Barrens,46.15,36.93,100 >>Travel to |cFFfa9602Wailing Caverns|r
step
#completewith next
.goto The Barrens,46.95,35.18,0
.goto The Barrens,46.95,35.18,30,0
.goto The Barrens,46.83,34.74,20,0
.goto Kalimdor,51.98,55.36,20,0
.goto Kalimdor,51.89,55.55,10,0
.goto Kalimdor,51.87,55.50,10 >>Run up the mountain at the Wailing Caverns meeting stone
>>|cRXP_WARN_Follow the arrow closely to reach the hidden cave|r
step
#label WCPickups
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nalpak|r and |cRXP_FRIENDLY_Ebru|r
>>|cRXP_WARN_They are located above the the Wailing Caverns cave entrance|r
.accept 1486 >> Accept Deviate Hides
.target +Nalpak
.goto Kalimdor,51.91,55.42
.accept 1487 >> Accept Deviate Eradication
.target +Ebru
.goto Kalimdor,51.92,55.44
step
#optional
#hardcore
#completewith EnterWC
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
>>|cRXP_WARN_It is recommended that maximum 3 players attempt to complete this quest if you're doing only 1 run. There aren't enough|r |cRXP_PICK_Serpentbloom|r |cRXP_WARN_for everybody|r
>>|cRXP_WARN_Cast|r |T133939:0|t[Find Herbs] |cRXP_WARN_to see them on your minimap|r
.complete 962,1 
.skill herbalism,<1,1
.isOnQuest 962
step
#hardcore
#completewith EnterWC
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
>>|cRXP_WARN_It is recommended that maximum 3 players attempt to complete this quest if you're doing only 1 run. There aren't enough|r |cRXP_PICK_Serpentbloom|r |cRXP_WARN_for everybody|r
.complete 962,1 
.skill herbalism,1,1
.isOnQuest 962
step
#optional
#softcore
#completewith EnterWC
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
>>|cRXP_WARN_Cast|r |T133939:0|t[Find Herbs] |cRXP_WARN_to see them on your minimap|r
.complete 962,1 
.skill herbalism,<1,1
.isOnQuest 962
step
#softcore
#completewith EnterWC
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
.complete 962,1 
.skill herbalism,1,1
.isOnQuest 962
step
#hardcore
#completewith EnterWC
>>Kill all the |cRXP_ENEMY_Deviate Beasts|r you see. Loot them for their |cRXP_LOOT_Hides|r
>>|cRXP_WARN_It is recommended that maximum 3 players attempt to complete this quest if you're doing only 1 run. There aren't enough|r |cRXP_LOOT_Hides|r |cRXP_WARN_for everybody|r
.complete 1486,1 
.isOnQuest 1486
step
#softcore
#completewith EnterWC
>>Kill all the |cRXP_ENEMY_Deviate Beasts|r you see. Loot them for their |cRXP_LOOT_Hides|r
.complete 1486,1 
.isOnQuest 1486
step
#completewith EnterWC
>>Kill |cRXP_ENEMY_Ectoplasms|r. Loot them for their |cRXP_LOOT_Essence|r
.complete 1491,1 
.isOnQuest 1491
step
#label MadMagg
#loop
.goto Kalimdor,51.97,55.23,0
.goto Kalimdor,51.82,54.86,0
.goto Kalimdor,52.01,55.02,0
.goto Kalimdor,52.15,55.15,0
.goto Kalimdor,51.97,55.23,30,0
.goto Kalimdor,51.82,54.86,30,0
.goto Kalimdor,52.01,55.02,30,0
.goto Kalimdor,52.15,55.15,30,0
>>Kill |cRXP_ENEMY_Mad Magglish|r. Loot him for the |cRXP_LOOT_99-Year-Old Port|r
>>|cRXP_WARN_He has a long respawn timer. Skip this step if you cannot find him|r
.complete 959,1 
.mob Mad Magglish
.isOnQuest 959
step
#label EnterWC
.goto Kalimdor,51.89,54.77,20,0
.goto Kalimdor,51.95,54.56,20,0
.goto Kalimdor,52.27,54.65,30,0
.goto Kalimdor,52.40,55.20,30 >>Enter the WC Instance portal. Zone in
step
#optional
#hardcore
#completewith GlowingShard
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
>>|cRXP_WARN_It is recommended that maximum 3 players attempt to complete this quest if you're doing only 1 run. There aren't enough|r |cRXP_PICK_Serpentbloom|r |cRXP_WARN_for everybody|r
>>|cRXP_WARN_Cast|r |T133939:0|t[Find Herbs] |cRXP_WARN_to see them on your minimap|r
.complete 962,1 
.skill herbalism,<1,1
.isOnQuest 962
step
#optional
#hardcore
#completewith GlowingShard
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
>>|cRXP_WARN_It is recommended that maximum 3 players attempt to complete this quest if you're doing only 1 run. There aren't enough|r |cRXP_PICK_Serpentbloom|r |cRXP_WARN_for everybody|r
.complete 962,1 
.skill herbalism,1,1
.isOnQuest 962
step
#optional
#softcore
#completewith GlowingShard
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
>>|cRXP_WARN_Cast|r |T133939:0|t[Find Herbs] |cRXP_WARN_to see them on your minimap|r
.complete 962,1 
.skill herbalism,<1,1
.isOnQuest 962
step
#optional
#softcore
#completewith GlowingShard
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
.complete 962,1 
.skill herbalism,1,1
.isOnQuest 962
step
#optional
#hardcore
#completewith GlowingShard
>>Kill |cRXP_ENEMY_Ectoplasms|r. Loot them for their |cRXP_LOOT_Essence|r
>>|cRXP_WARN_It is recommended that maximum 3 players attempt to complete this quest if you're doing only 1 run. There aren't enough|r |cRXP_LOOT_Hides|r |cRXP_WARN_for everybody|r
.complete 1491,1 
.isOnQuest 1491
step
#optional
#softcore
#completewith GlowingShard
>>Kill |cRXP_ENEMY_Ectoplasms|r. Loot them for their |cRXP_LOOT_Essence|r
.complete 1491,1 
.isOnQuest 1491
step
#completewith GlowingShard
>>Kill |cRXP_ENEMY_Deviate Ravagers|r, |cRXP_ENEMY_Vipers|r, |cRXP_ENEMY_Shamblers|r and |cRXP_ENEMY_Dreadfangs|r
.complete 1487,1 
.mob +Deviate Ravager
.complete 1487,2 
.mob +Deviate Viper
.complete 1487,3 
.mob +Deviate Shambler
.complete 1487,4 
.mob +Deviate Dreadfang
.complete 1486,1 
.isOnQuest 1487
step
#label Gems
>>Kill |cRXP_ENEMY_Lord Cobrahn|r, |cRXP_ENEMY_Lady Anacondra|r, |cRXP_ENEMY_Lord Pythas|r and |cRXP_ENEMY_Lord Serpentis|r. Loot them for their |cRXP_LOOT_Gems|r
.complete 914,1 
.mob +Lord Cobrahn
.complete 914,2 
.mob +Lady Anacondra
.complete 914,3 
.mob +Lord Pythas
.complete 914,4 
.mob +Lord Serpentis
.isOnQuest 914
step
#requires Gems
#completewith next
+|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Disciple of Naralex|r at the entrance of Wailing Caverns. Escort him safely to |cRXP_FRIENDLY_Naralex|r
.target Disciple of Naralex
.skipgossip
step
#label GlowingShard
>>Once you have reached |cRXP_FRIENDLY_Naralex|r you will get attack by two waves of enemies and finally by |cRXP_ENEMY_Mutanus the Devourer|r
>>Kill him and loot him for the |T135229:0|t[|cRXP_LOOT_Glowing Shard|r] and use it to start the quest
.collect 10441,1 
.accept 6981 >> Accept The Glowing Shard
.use 10441
.mob Mutanus the Devourer
step
#optional
#completewith DeviateRaptors
>>Kill |cRXP_ENEMY_Ectoplasms|r. Loot them for their |cRXP_LOOT_Essence|r
.complete 1491,1 
.isOnQuest 1491
step
#optional
#hardcore
#completewith Ectoplasms
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
>>|cRXP_WARN_It is recommended that maximum 3 players attempt to complete this quest if you're doing only 1 run. There aren't enough|r |cRXP_PICK_Serpentbloom|r |cRXP_WARN_for everybody|r
>>|cRXP_WARN_Cast|r |T133939:0|t[Find Herbs] |cRXP_WARN_to see them on your minimap|r
.complete 962,1 
.skill herbalism,<1,1
.isOnQuest 962
step
#optional
#hardcore
#completewith Ectoplasms
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
>>|cRXP_WARN_It is recommended that maximum 3 players attempt to complete this quest if you're doing only 1 run. There aren't enough|r |cRXP_PICK_Serpentbloom|r |cRXP_WARN_for everybody|r
.complete 962,1 
.skill herbalism,1,1
.isOnQuest 962
step
#optional
#softcore
#completewith Ectoplasms
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
>>|cRXP_WARN_Cast|r |T133939:0|t[Find Herbs] |cRXP_WARN_to see them on your minimap|r
.complete 962,1 
.skill herbalism,<1,1
.isOnQuest 962
step
#optional
#softcore
#completewith Ectoplasms
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
.complete 962,1 
.skill herbalism,1,1
.isOnQuest 962
step
#optional
>>Kill |cRXP_ENEMY_Deviate Ravagers|r, |cRXP_ENEMY_Vipers|r, |cRXP_ENEMY_Shamblers|r and |cRXP_ENEMY_Dreadfangs|r. . Loot them for their |cRXP_ENEMY_Hides|r
.complete 1487,1 
.mob +Deviate Ravager
.complete 1487,2 
.mob +Deviate Viper
.complete 1487,3 
.mob +Deviate Shambler
.complete 1487,4 
.mob +Deviate Dreadfang
.complete 1486,1 
.disablecheckbox
.isOnQuest 1487
.isOnQuest 1486
step
>>Kill |cRXP_ENEMY_Deviate Ravagers|r, |cRXP_ENEMY_Vipers|r, |cRXP_ENEMY_Shamblers|r and |cRXP_ENEMY_Dreadfangs|r
.complete 1487,1 
.mob +Deviate Ravager
.complete 1487,2 
.mob +Deviate Viper
.complete 1487,3 
.mob +Deviate Shambler
.complete 1487,4 
.mob +Deviate Dreadfang
.isOnQuest 1487
step
#label DeviateRaptors
>>Kill |cRXP_ENEMY_Deviate Raptors|r. Loot them for their |cRXP_ENEMY_Hides|r
.complete 1486,1 
.mob Deviate Ravager
.mob Deviate Viper
.mob Deviate Shambler
.mob Deviate Dreadfang
.isOnQuest 1486
step
#label Ectoplasms
>>Kill |cRXP_ENEMY_Ectoplasms|r. Loot them for their |cRXP_LOOT_Essence|r
.complete 1491,1 
.mob Devouring Ectoplasm
.mob Evolving Ectoplasm
.mob Nightmare Ectoplasm
.isOnQuest 1491
step
#optional
#hardcore
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
>>|cRXP_WARN_It is recommended that maximum 3 players attempt to complete this quest if you're doing only 1 run. There aren't enough|r |cRXP_PICK_Serpentbloom|r |cRXP_WARN_for everybody|r
>>|cRXP_WARN_Cast|r |T133939:0|t[Find Herbs] |cRXP_WARN_to see them on your minimap|r
.complete 962,1 
.skill herbalism,<1,1
.isOnQuest 962
step
#hardcore
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
>>|cRXP_WARN_It is recommended that maximum 3 players attempt to complete this quest if you're doing only 1 run. There aren't enough|r |cRXP_PICK_Serpentbloom|r |cRXP_WARN_for everybody|r
.complete 962,1 
.skill herbalism,1,1
.isOnQuest 962
step
#optional
#softcore
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
>>|cRXP_WARN_Cast|r |T133939:0|t[Find Herbs] |cRXP_WARN_to see them on your minimap|r
.complete 962,1 
.skill herbalism,<1,1
.isOnQuest 962
step
#softcore
>>Loot the |cRXP_PICK_Serpentbloom|r on the ground
.complete 962,1 
.skill herbalism,1,1
.isOnQuest 962
step
#completewith RatchetTurnins
.hs >>Hearth to Ratchet
.cooldown item,6948,>0,1
.use 6948
.subzoneskip 392
.bindlocation 392,1
step
#completewith RatchetTurnins
.subzone 392 >>Travel to |cFFfa9602Ratchet|r
step
.goto The Barrens,62.37,37.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mebok|r
.turnin 1491 >>Turn in Smart Drinks
.target Mebok Mizzyrix
.isQuestComplete 1491
step
.goto The Barrens,63.09,37.61
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bigglefuzz|r
.turnin 959 >>Turn in Trouble at the Docks
.target Crane Operator Bigglefuzz
.isQuestComplete 959
step
#label RatchetTurnins
.goto The Barrens,62.99,37.22
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sputtervalve|r
.complete 6981,1 
.skipgossip
.target Sputtervalve
.isOnQuest 6981
step
#completewith next
.goto The Barrens,50.49,34.36,20,0
.goto The Barrens,49.61,34.54,20,0
.goto The Barrens,49.14,34.02,20,0
.goto The Barrens,48.18,32.78,50 >>Travel up the mountain
step
.goto The Barrens,48.18,32.78
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Falla|r
.turnin 6981 >>Turn in The Glowing Shard
.accept 3369 >>Accept In Nightmares
.target Falla Sagewind
.isOnQuest 6981
step
.goto The Barrens,48.18,32.78
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Falla|r
.accept 3369 >>Accept In Nightmares
.target Falla Sagewind
.isQuestTurnedIn 6981
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nalpak|r and |cRXP_FRIENDLY_Ebru|r
>>|cRXP_WARN_They are located above the the Wailing Caverns cave entrance|r
.turnin 1486 >>Turn in Deviate Hides
.target +Nalpak
.goto Kalimdor,51.91,55.42
.turnin 1487 >>Turn in Deviate Eradication
.target +Ebru
.goto Kalimdor,51.92,55.44
.isQuestComplete 1487
.isQuestComplete 1486
step
#optional
.goto Kalimdor,51.92,55.44
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ebru|r
>>|cRXP_WARN_He is located above the the Wailing Caverns cave entrance|r
.turnin 1487 >>Turn in Deviate Eradication
.target Ebru
.isQuestComplete 1487
step
#optional
.goto Kalimdor,51.91,55.42
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nalpak|r
>>|cRXP_WARN_He is located above the the Wailing Caverns cave entrance|r
.turnin 1486 >>Turn in Deviate Hides
.target Nalpak
.isQuestComplete 1486
step
#completewith TBTurnins
.zone Thunder Bluff >>Travel to |cFFfa9602Thunder Bluff|r
step
.goto Thunder Bluff,75.65,31.57
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nara|r
.turnin 914 >>Turn in Leaders of the Fang
.target Nara Wildmane
.isQuestComplete 914
step
.goto Thunder Bluff,78.61,28.55
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hamuul|r
.turnin 3369 >>Turn in In Nightmares
.target Arch Druid Hamuul Runetotem
.isOnQuest 3369
step
#completewith next
.goto Thunder Bluff,28.51,28.95,10 >>Travel to the Spirit Rise and enter the pools of vision
.isQuestComplete 962
step
#label TBTurnins
.goto Thunder Bluff,23.0,21.0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Apothecary Zamah|r
.turnin 962 >>Turn in Serpentbloom
.target Apothecary Zamah
.isQuestComplete 962
step
+|cRXP_WARN_This is the end of the Wailing Caverns guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 15-30
<< Horde
#name 103. Shadowfang Keep
#displayname 3. Shadowfang Keep
step
#completewith SepulchPickups
+|cRXP_WARN_You will now be directed to pick up all available quests for Shadowfang Keep|r
step
#completewith next
.zone Undercity >>Travel to |cFFfa9602Undercity|r
step
.goto Undercity,53.74,54.49
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bel'dugur|r
.accept 1013 >>Accept The Book of Ur
.target Keeper Bel'dugur
step
#completewith SepulchPickups
.subzone 228 >>Travel to |cFFfa9602The Sepulcher|r in Silverpine Forest
step
.goto Silverpine Forest,43.43,40.85
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hadrec|r
.accept 1098 >>Accept Deathstalkers in Shadowfang
.target High Executor Hadrec
step
#label SepulchPickups
.goto Silverpine Forest,44.22,39.81
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Dalar|r
.accept 1014 >>Accept Arugal Must Die
.target Dalar Dawnweaver
step
#label EnterSFK
.goto Silverpine Forest,44.87,67.86
.subzone 209,2 >>Enter the SFK Instance portal. Zone in
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vincent|r
.turnin 1098 >> Turn in Deathstalkers in Shadowfang
.target Deathstalker Vincent
.isOnQuest 1098
step
>>Loot the |cRXP_PICK_Book of Ur|r from the bookshelf in |cRXP_ENEMY_Fenrus the Devourer's|r room
.complete 1013,1 
.isOnQuest 1013
step
>>Kill |cRXP_ENEMY_Archmage Arugal|r. Loot him for his |cRXP_LOOT_Head|r
.complete 1014,1 
.mob Archmage Arugal
.isOnQuest 1014
step
#completewith SepulchTurnins
.subzone 228 >>Travel to |cFFfa9602The Sepulcher|r in Silverpine Forest
step
.goto Silverpine Forest,43.43,40.85
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hadrec|r
.turnin 1098 >>Turn in Deathstalkers in Shadowfang
.target High Executor Hadrec
.isQuestComplete 1098
step
#label SepulchTurnins
.goto Silverpine Forest,44.22,39.81
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Dalar|r
.turnin 1014 >>Turn in Arugal Must Die
.target Dalar Dawnweaver
.isQuestComplete 1014
step
#completewith next
.zone Undercity >>Travel to |cFFfa9602Undercity|r
step
.goto Undercity,53.74,54.49
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bel'dugur|r
.turnin 1013 >>Turn in The Book of Ur
.target Keeper Bel'dugur
.isQuestComplete 1013
step
+|cRXP_WARN_This is the end of the Shadowfang Keep guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 15-30
<< Horde
#name 104 Blackfathom Deeps
#displayname 4. Blackfathom Deeps
step
#completewith ZoramPickups
+|cRXP_WARN_You will now be directed to pick up all available quests for Blackfathom Deeps|r
step
#completewith next
.subzone 460 >>Travel to |cFFfa9602Sun Rock Retreat|r in Stonetalon Mountains
step
.goto Stonetalon Mountains,47.36,64.25
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tsunaman|r
>>|cRXP_WARN_This is a prerequisite quest for Blackfathom Deeps|r
.accept 6562 >>Accept Trouble in the Deeps
.target Tsunaman
step
#completewith ZoramPickups
.subzone 2897 >>Travel to |cFFfa9602Zoram'gar Outpost|r in Ashenvale
step
.goto Ashenvale,11.56,34.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Je'neu Sancrea|r
.turnin 6562 >>Turn in Trouble in the Deeps
.target Je'neu Sancrea
.isOnQuest 6562
step
.goto Ashenvale,11.56,34.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Je'neu Sancrea|r
.accept 6563 >>Accept The Essence of Aku'Mai
.target Je'neu Sancrea
.isQuestTurnedIn 6562
step
#label ZoramPickups
.goto Ashenvale,11.56,34.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Je'neu Sancrea|r
.accept 6921 >>Accept Amongst the Ruins
.target Je'neu Sancrea
step
#optional
.goto Ashenvale,11.56,34.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Je'neu Sancrea|r
.accept 6565 >>Accept Allegiance to the Old Gods
.target Je'neu Sancrea
.isQuestTurnedIn 6564
step
#completewith DampNote
.goto Kalimdor,43.89,35.23,100 >>Travel to the entrance of |cFFfa9602Blackfathom Deeps|r
step
#completewith AllegianceTI
>>Loot |cRXP_LOOT_Sapphire of Aku'Mai|r from the wall
.complete 6563,1 
.isOnQuest 6563
step
#label DampNote
#loop
.goto Kalimdor,43.94,34.86,0
.goto Kalimdor,43.81,35.16,20,0
.goto Kalimdor,43.94,34.86,20,0
.goto Kalimdor,43.90,34.59,20,0
.goto Kalimdor,44.00,34.57,20,0
.goto Kalimdor,44.16,34.85,20,0
.goto Kalimdor,44.35,34.97,20,0
.goto Kalimdor,44.53,34.86,20,0
>>Kill |cRXP_ENEMY_Blackfathom Tide Priestesses|r. Loot them for a |T134332:0|t[|cRXP_LOOT_Damp Note|r] and use it to start the quest
.collect 16790,1,6564 
.accept 6564 >> Accept Allegiance to the Old Gods
.mob Blackfathom Tide Priestess
.use 16790
step
#completewith next
.subzone 2897 >>Return to Zoram'gar Outpost to turn in "Allegiance to the Old Gods" for a follow-up quest
step
#label AllegianceTI
.goto Ashenvale,11.56,34.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Je'neu Sancrea|r
>>|cRXP_WARN_Skip this step if you do not want to return to Zoram'gar Outpost right now|r
.turnin 6564 >>Turn in Allegiance to the Old Gods
.accept 6565 >>Accept Allegiance to the Old Gods
.target Je'neu Sancrea
.isOnQuest 6564
step
#loop
.goto Kalimdor,44.34,35.11,0
.goto Kalimdor,44.53,34.86,20,0
.goto Kalimdor,44.35,34.97,20,0
.goto Kalimdor,44.16,34.85,20,0
.goto Kalimdor,44.00,34.57,20,0
.goto Kalimdor,43.90,34.59,20,0
.goto Kalimdor,43.94,34.86,20,0
.goto Kalimdor,43.81,35.16,20,0
.goto Kalimdor,44.34,35.11,20,0
>>Loot |cRXP_LOOT_Sapphire of Aku'Mai|r from the wall
.complete 6563,1 
.isOnQuest 6563
step
#label EnterBFD
.goto Kalimdor,44.36,34.86
.subzone 2797,2 >>Enter the BFD Instance portal. Zone in
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Argent Guard Thaelrid|r
.accept 6561 >>Accept Blackfathom Villainy
.target Argent Guard Thaelrid
step
>>Kill |cRXP_ENEMY_Lorguss Jett |r
.complete 6565,1 
.mob Lorguss Jett
.isOnQuest 6565
step
#completewith next
>>Loot the |cRXP_PICK_Fathom Stone|r in the water on the ground for the |cRXP_LOOT_Fathom Core|r
>>|cRXP_WARN_Looting this will spawn|r |cRXP_ENEMY_Baron Aquanis|r
.complete 6921,1 
.isOnQuest 6921
step
>>Kill |cRXP_ENEMY_Baron Aquanis|r. Loot him for a |T136222:0|t[|cRXP_LOOT_Strange Water Globe|r]. Use it to accept the quest
.collect 16782,1,6782 
.accept 6922 >>Accept Baron Aquanis
.mob Baron Aquanis
.use 16782
step
>>Loot the |cRXP_PICK_Fathom Stone|r in the water on the ground for the |cRXP_LOOT_Fathom Core|r
.complete 6921,1 
.isOnQuest 6921
step
>>Kill |cRXP_ENEMY_Twilight Lord Kelris|r. Loot him for his |cRXP_LOOT_Head|r
.complete 6561,1 
.mob Twilight Lord Kelris
.isOnQuest 6561
step
#completewith ZoramTurnins
.subzone 2897 >>Travel to |cFFfa9602Zoram'gar Outpost|r in Ashenvale
>>|cRXP_WARN_Kill|r |cRXP_ENEMY_Aku'mai|r |cRXP_WARN_first if you wish. This is the last boss of the dungeon|r
step
.goto Ashenvale,11.56,34.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Je'neu Sancrea|r
.turnin 6564 >>Turn in Allegiance to the Old Gods
.target Je'neu Sancrea
.isOnQuest 6564
step
.goto Ashenvale,11.56,34.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Je'neu Sancrea|r
.turnin 6565 >>Turn in Allegiance to the Old Gods
.target Je'neu Sancrea
.isQuestComplete 6565
step
.goto Ashenvale,11.56,34.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Je'neu Sancrea|r
.turnin 6563 >>Turn in The Essence of Aku'Mai
.target Je'neu Sancrea
.isQuestComplete 6563
step
.goto Ashenvale,11.56,34.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Je'neu Sancrea|r
.turnin 6921 >>Turn in Amongst The Ruins
.target Je'neu Sancrea
.isQuestComplete 6521
step
#label ZoramTurnins
.goto Ashenvale,11.56,34.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Je'neu Sancrea|r
.turnin 6922 >>Turn in Baron Aquanis
.target Je'neu Sancrea
.isQuestComplete 6922
step
#completewith next
.zone Thunder Bluff >>Travel to |cFFfa9602Thunder Bluff|r
step
.goto Thunder Bluff,71.04,34.19
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bashana|r
.turnin 6561 >>Turn in Blackfathom Villainy
.target Bashana Runetotem
.isQuestComplete 6561
step
+|cRXP_WARN_This is the end of the Blackfathom Deeps guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 15-30 << !classic
#subgroup 30-50 << classic
<< Horde
#name 105 Razorfen Kraul
#displayname 5. Razorfen Kraul
step
#completewith RatchetPickups
+|cRXP_WARN_You will now be directed to pick up all available quests for Razorfen Kraul|r
>>|cRXP_WARN_Some quests have long travel time. Feel free to skip them|r
step
#completewith next
.zone Undercity >>Travel to |cFFfa9602Undercity|r
step
.goto Undercity,48.80,69.28
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Faranell|r
.accept 1109 >> Accept Going, Going, Guano!
.target Master Apothecary Faranell
.xp <30,1
step
#completewith next
.zone Thunder Bluff >>Travel to |cFFfa9602Thunder Bluff|r
step
.goto Thunder Bluff,36.01,59.90
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Auld|r
.accept 1102 >> Accept A Vengeful Fate
.target Auld Stonespire
step
.goto Thunder Bluff,45.83,64.74
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Innkeeper Pala|r
>>|cRXP_WARN_This is so you can Hearth after completing the dungeon|r
.home >>Set your Hearthstone to Thunder Bluff
.target Innkeeper Pala
.bindlocation 1638
.zoneskip Thunder Bluff,1
step
#completewith RatchetPickups
.subzone 392 >>Travel to |cFFfa9602Ratchet|r
step
.goto The Barrens,62.370,37.615
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mebok|r
.accept 1221 >> Accept Blueleaf Tubers
.target Mebok Mizzyrix
step
#label RatchetPickups
>>Loot the |cRXP_LOOT_Snufflenose Command Stick|r, |cRXP_LOOT_Snufflenose Owner's Manual|r and |cRXP_LOOT_Crate With Holes|r next to |cRXP_FRIENDLY_Mebok|r
.collect 6684,1,1221,1 
.goto The Barrens,62.340,37.607
.collect 5897,1,1221,1 
.goto The Barrens,62.332,37.623
.collect 5880,1,1221,1 
.goto The Barrens,62.323,37.620
.isOnQuest 1221
step
#label EnterRFK
.goto The Barrens,43.46,90.18,0
.goto The Barrens,43.46,90.18,40,0
.goto 1414,50.89,70.35
.subzone 491,2 >> Enter Razorfen Kraul
step
>>Kill |cRXP_ENEMY_Kraul Bats|r. Loot them for a |cRXP_LOOT_Kraul Guano|r
.complete 1109,1 
.mob Kraul Bat
.mob Greater Kraul Bat
.isOnQuest 1109
step
>>Kill |cRXP_ENEMY_Charlga Razorflank|r. Loot her for her |cRXP_LOOT_Heart|r and for the |T134939:0|t[|cRXP_LOOT_Small Scroll|r]. Use the scroll to start the quest
.complete 1102,1 
.collect 17008,1,6522 
.accept 6522 >>Accept An Unholy Alliance
.mob Charlga Razorflank
.use 17008
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Willix the Importer|r
>>|cRXP_WARN_This will start an escort|r
.accept 1144 >> Accept Willix the Importer
.target Willix the Importer
step
>>Escort |cRXP_FRIENDLY_Willix the Importer|r through Razorfen Kraul
>>|cRXP_WARN_Ensure you stay close to |cRXP_FRIENDLY_Willix|r otherwise the quest may not complete!|r
.complete 1144,1 
.isOnQuest 1144
.target Willix the Importer
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Willix the Importer|r
.turnin 1144 >> Turn in Willix the Importer
.target Willix the Importer
.isQuestComplete 1144
step
>>|cRXP_WARN_When at the start of the instance, take the first left. Once you reach the Vine at the end, drop down below to where you see |cRXP_ENEMY_Agam'ars|r below|r
>>|cRXP_WARN_Kill the |cRXP_ENEMY_Agam'ars|r below with your party to create a clear space|r
>>|cRXP_WARN_Use the|r |T132765:0|t[Crate With Holes] |cRXP_WARN_to summon a |cRXP_FRIENDLY_Snufflenose Gopher|r at this location. Finding the correct spot to summon it can be finicky|r
>>|cRXP_WARN_Use the|r |T135474:0|t[Snufflenose Command Stick] |cRXP_WARN_to action the |cRXP_FRIENDLY_Gopher|r to dig up|r |cRXP_LOOT_Blueleaf Tubers|r
>>|cRXP_WARN_Loot the |cRXP_LOOT_Blueleaf Tuber|r once it has dug it up|r
>>|cRXP_WARN_Continue to use the|r |T135474:0|t[Snufflenose Command Stick] |cRXP_WARN_on it again so it digs up another one. Repeat this process until you have 6|r |cRXP_LOOT_Blueleaf Tubers|r
>>|cRXP_WARN_If your |cRXP_FRIENDLY_Gopher|r despawns, use the|r |T132765:0|t[Crate With Holes] |cRXP_WARN_to summon another. Note it only has 5 charges|r
.complete 1221,1 
.use 5880 
.use 6684 
.target Snufflenose Gopher
.isOnQuest 1221
step
#completewith next
.hs >>Hearth to Thunder Bluff
.cooldown item,6948,>0,1
.use 6948
.zoneskip Thunder Bluff
.bindlocation 1638,1
step
#completewith next
.zone Thunder Bluff >>Travel to |cFFfa9602Thunder Bluff|r
step
.goto Thunder Bluff,36.01,59.90
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Auld|r
.turnin 1102 >> Turn in A Vengeful Fate
.target Auld Stonespire
.isQuestComplete 1102
step
#completewith next
.subzone 392 >>Travel to |cFFfa9602Ratchet|r
step
.goto The Barrens,62.370,37.615
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mebok|r
.turnin 1221 >> Turn in Blueleaf Tubers
.target Mebok Mizzyrix
.isQuestComplete 1221
step
#completewith UndercityTurnins
.zone Undercity >>Travel to |cFFfa9602Undercity|r
step
.goto Undercity,48.80,69.28
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Faranell|r
.turnin 1109 >> Turn in Going, Going, Guano!
.target Master Apothecary Faranell
.isQuestComplete 1109
step
#completewith next
.goto Undercity,51.92,64.68,15 >>Travel toward |cRXP_FRIENDLY_Varimathras|r
step
#label UndercityTurnins
.goto Undercity,56.24,92.19
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Varimathras|r
.turnin 6522 >>Turn in An Unholy Alliance
.target Varimathras
.isOnQuest 6522
step
+|cRXP_WARN_This is the end of the Razorfen Kraul guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 15-30 << !classic
#subgroup 30-50 << classic
<< Horde
#name 106 Gnomeregan
#displayname 6. Gnomeregan
step
#completewith OrgPickups
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step
.goto Orgrimmar,76.00,25.39
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nogg|r
.accept 2841 >>Accept Rig Wars
.target Nogg
step
#label OrgPickups
.goto Orgrimmar,75.50,25.34
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sovik|r
>>|cRXP_WARN_Go through his dialogue to accept this quest|r
.accept 2842 >>Accept Chief Engineer Scooty
.target Sovik
step
.goto Orgrimmar,54.10,68.42
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Innkeeper Gryshka|r
>>|cRXP_WARN_This is so you can Hearth after completing the dungeon|r
.home >> Set your Hearthstone to Orgrimmar
.target Innkeeper Gryshka
.zoneskip Orgrimmar,1
.bindlocation 1637
step
#completewith GnomeTransporter
.subzone 35 >>Travel to |cFFfa9602Booty Bay|r in Stranglethorn Vale
step
.goto Stranglethorn Vale,27.60,77.48
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Scooty|r
.turnin 2842 >>Turn in Chief Engineer Scooty
.accept 2843 >>Accept Gnomer-gooooone!
.target Scooty
.timer 9 >> Goblin Transponder
step
.goto Stranglethorn Vale,27.60,77.48
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Scooty|r
.turnin 2843 >>Turn in Gnomer-gooooone!
.target Scooty
step
#label GnomeTransporter
.goto Stranglethorn Vale,27.63,77.55
.goto Eastern Kingdoms,42.75,59.93,30 >> Step onto the Gnomeregan Transponder
step
#label EnterGNOMER
.goto Eastern Kingdoms,42.64,59.80,20,0
.goto Eastern Kingdoms,42.58,59.82,20,0
.goto Eastern Kingdoms,42.56,59.87,20,0
.goto Eastern Kingdoms,42.51,60.15,20,0
.goto Eastern Kingdoms,42.34,60.18
.zone Gnomeregan,2 >> Enter Gnomeregan
step
>>Kill |cRXP_ENEMY_Mekgineer Thermaplugg|r. Loot him for his |cRXP_LOOT_Safe Combination|r
>>Loot |cRXP_PICK_Thermaplugg's Safe|r in the northern side of the room for the |cRXP_LOOT_Rig Blueprints|r
.complete 2841,2 
.complete 2841,1 
.mob Mekgineer Thermaplugg
step
#completewith next
.hs >>Hearth to Orgrimmar
.cooldown item,6948,>0,1
.use 6948
.zoneskip Orgrimmar
.bindlocation 1637,1
step
#completewith next
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step
.goto Orgrimmar,76.00,25.39
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nogg|r
.turnin 2841 >>Turn in Rig Wars
.target Nogg
.isQuestComplete 2841
step
+|cRXP_WARN_This is the end of the Gnomeregan guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 30-50
<< Horde
#name 107 Razorfen Downs
#displayname 7. Razorfen Downs
step
#completewith UCpickups
+|cRXP_WARN_You will now be directed to pick up all available quests for Razorfen Downs|r
step
#completewith UCpickups
.zone Undercity >>Travel to |cFFfa9602Undercity|r
step
.goto Undercity,74.05,33.28
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Andrew|r
.accept 3341 >> Accept Bring the End
.target Andrew Brownell
.xp <37,1
step
#completewith next
.goto Undercity,51.92,64.68,15 >>Travel toward |cRXP_FRIENDLY_Varimathras|r
.isOnQuest 6522
step
#label UCpickups
.goto Undercity,56.24,92.19
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Varimathras|r
.accept 6521 >>Accept An Unholy Alliance
.target Varimathras
.isQuestTurnedIn 6522 
step
.goto Undercity,67.74,37.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Norman|r
>>|cRXP_WARN_This is so you can Hearth after completing the dungeon|r
.home >> Set your Hearthstone to Undercity
.target Innkeeper Norman
.bindlocation 1497
.zoneskip Undercity,1
step
#completewith EnterRFD
.goto The Barrens,46.30,90.27,200 >> Travel to Razorfen Downs
step
#completewith next
.goto The Barrens,46.30,90.27,50,0
.goto The Barrens,46.92,91.84,50,0
.goto The Barrens,48.20,92.66,50,0
>>Kill |cRXP_ENEMY_Ambassador Malcin|r. Loot him for his |cRXP_LOOT_Head|r
>>|cRXP_WARN_He can spawn at 4 different tents outside the instance|r
.complete 6521,1 
.unitscan Ambassador Malcin
.isOnQuest 6521
step
.goto The Barrens,49.012,94.938
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Myriam Moonsinger|r
.accept 6626 >> Accept A Host of Evil
.target Myriam Moonsinger
step
#completewith next
>>Kill |cRXP_ENEMY_Razorfen Battleguards|r, |cRXP_ENEMY_Razorfen Thornweavers|r and |cRXP_ENEMY_Death's Head Cultists|r
>>|cRXP_WARN_This quest is completed outside of the Instance|r
.complete 6626,1 
.mob +Razorfen Battleguard
.complete 6626,2 
.mob +Razorfen Thornweaver
.complete 6626,3 
.mob +Death's Head Cultist
.isOnQuest 6626
step
#loop
.goto The Barrens,48.57,95.69,0
.goto The Barrens,48.20,92.66,0
.goto The Barrens,46.92,91.84,0
.goto The Barrens,46.30,90.27,0
.goto The Barrens,48.57,95.69,50,0
.goto The Barrens,48.20,92.66,50,0
.goto The Barrens,46.92,91.84,50,0
.goto The Barrens,46.30,90.27,50,0
>>Kill |cRXP_ENEMY_Ambassador Malcin|r. Loot him for his |cRXP_LOOT_Head|r
>>|cRXP_WARN_He can spawn at 4 different tents outside the instance|r
.complete 6521,1 
.unitscan Ambassador Malcin
.isOnQuest 6521
step
#loop
.goto The Barrens,48.23,92.31,0
.goto The Barrens,48.23,92.31,70,0
.goto The Barrens,48.15,90.57,70,0
.goto The Barrens,47.86,88.75,70,0
.goto The Barrens,46.46,90.19,70,0
.goto The Barrens,46.94,92.19,70,0
>>Kill |cRXP_ENEMY_Razorfen Battleguards|r, |cRXP_ENEMY_Razorfen Thornweavers|r and |cRXP_ENEMY_Death's Head Cultists|r
>>|cRXP_WARN_This quest is completed outside of the Instance|r
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
#label EnterRFD
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
>>Kill |cRXP_ENEMY_Amnennar the Coldbringer|r. Loot him for his |cRXP_LOOT_Skull|r
.complete 3341,1 
.mob Amnennar the Coldbringer
.isOnQuest 3341
step
#completewith UCTurnins
.hs >>Hearth to Undercity
.cooldown item,6948,>0,1
.use 6948
.zoneskip Undercity
.bindlocation 1497,1
step
#completewith UCTurnins
.zone Undercity >>Travel to |cFFfa9602Undercity|r
step
.goto Undercity,74.05,33.28
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Andrew|r
.turnin 3341 >>Turn in Bring the End
.target Andrew Brownell
.isQuestComplete 3341
step
#completewith next
.goto Undercity,51.92,64.68,15 >>Travel toward |cRXP_FRIENDLY_Varimathras|r
step
#label UCTurnins
.goto Undercity,56.24,92.19
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Varimathras|r
.turnin 6521 >>Turn in An Unholy Alliance
.target Varimathras
.isQuestComplete 6521
step
+|cRXP_WARN_This is the end of the Razorfen Downs guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 30-50
<< Horde
#name 108 Scarlet Monastery
#displayname 8. Scarlet Monastery
step
#completewith UCpickups
+|cRXP_WARN_You will now be directed to pick up all available quests for Scarlet Monastery|r
step << !Undead
#completewith next
.zone Thunder Bluff >>Travel to |cFFfa9602Thunder Bluff|r
step << !Undead 
.goto Thunder Bluff,34.42,46.93
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sage|r
.accept 1049 >> Accept Compendium of the Fallen
.target Sage Truthseeker
step
#completewith UCpickups
.zone Undercity >>Travel to |cFFfa9602Undercity|r
step
#completewith next
.goto Undercity,51.92,64.68,15 >>Travel toward |cRXP_FRIENDLY_Varimathras|r
step
.goto Undercity,56.24,92.19
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Varimathras|r
.accept 1048 >>Accept Into The Scarlet Monastery
.target Varimathras
step
#completewith next
.goto Undercity,47.20,59.69,0
.goto Undercity,47.20,59.69,12,0
.goto Undercity,43.55,68.11,12,0
.goto Undercity,45.20,71.67,12 >>Travel toward |cRXP_FRIENDLY_Zinge|r
step
#label UCpickups
.goto Undercity,48.80,69.28
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Faranell|r
.accept 1113 >> Accept Hearts of Zeal
.target Master Apothecary Faranell
.isQuestTurnedIn 1109 
-Start dungeon
step
#label EnterSM
.goto Eastern Kingdoms,47.43,19.71,30,0
.goto Eastern Kingdoms,47.76,19.49
.subzone 796,2 >> Enter Scarlet Monastery. Start with Library so you can loot the [|cRXP_FRIENDLY_The Scarlet Key|r] at the end
.zoneskip Scarlet Monastery
step << !Undead
#completewith Bosses
>>Loot the |cRXP_LOOT_Compendium of the Fallen|r
>>|cRXP_WARN_It's located in a bookshelf on the left in the last corner of the Library dungeon|r
.complete 1049,1 
step
#completewith Compendium
>>Kill |cRXP_LOOT_Scarlet|r mobs. Loot them for their |cRXP_LOOT_Hearts of Zeal|r
.complete 1113,1 
.isOnQuest 1113
step
#label Bosses
>>Kill |cRXP_ENEMY_Houndmaster Loksey|r, |cRXP_ENEMY_Herod|r, |cRXP_ENEMY_High Inquisitor Whitemane|r and |cRXP_ENEMY_Scarlet Commander Mograine|r
>>|cRXP_ENEMY_Houndmaster Loksey|r |cRXP_WARN_is located in the Library|r
>>|cRXP_ENEMY_Herod|r |cRXP_WARN_is located in the Armory|r
>>|cRXP_ENEMY_High Inquisitor Whitemane|r |cRXP_WARN_and |cRXP_ENEMY_Scarlet Commander Mograine|r are located in the Cathedral|r
.complete 1048,4 
.complete 1048,3 
.complete 1048,1 
.complete 1048,2 
.isOnQuest 1048
.mob Houndmaster Loksey
.mob Herod
.mob High Inquisitor Whitemane
.mob Scarlet Commander Mograine
step << !Undead
#label Compendium
>>Loot the |cRXP_LOOT_Compendium of the Fallen|r
>>|cRXP_WARN_It's located in a bookshelf on the left in the last corner of the Library dungeon|r
.complete 1049,1 
.isOnQuest 1049
-Quest turnins
step
#completewith UCturnins
.zone Undercity >>Travel to |cFFfa9602Undercity|r
step
#completewith SMturnin
.goto Undercity,51.92,64.68,15 >>Travel toward |cRXP_FRIENDLY_Varimathras|r
.isQuestComplete 1048
step
#label SMturnin
.goto Undercity,56.24,92.19
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Varimathras|r
.turnin 1048 >>Turn in Into The Scarlet Monastery
.isQuestComplete 1048
.target Varimathras
step
#completewith next
.goto Undercity,47.20,59.69,0
.goto Undercity,47.20,59.69,12,0
.goto Undercity,43.55,68.11,12,0
.goto Undercity,45.20,71.67,12 >>Travel toward |cRXP_FRIENDLY_Faranell|r
step
#label UCturnins
.goto Undercity,48.80,69.28
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Faranell|r
.turnin 1113 >> Turn in Hearts of Zeal
.target Master Apothecary Faranell
.isQuestComplete 1113
step << !Undead
#completewith next
.zone Thunder Bluff >>Travel to |cFFfa9602Thunder Bluff|r
step << !Undead 
.goto Thunder Bluff,34.42,46.93
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sage|r
.turnin 1049 >>Turn in Compendium of the Fallen
.target Sage
.isQuestComplete 1049
step
+|cRXP_WARN_This is the end of the Scarlet Monastery guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 30-50
<< Horde
#name 109 Uldaman
#displayname 9. Uldaman
step
#completewith SolDoom
+|cRXP_WARN_You will now be directed to pick up all available quests for Uldaman|r
>>|cRXP_WARN_Consider putting your hearthstone in Orgrimmar to reduce travel time|r
step
#completewith next
.zone Undercity >>Travel to |cFFfa9602Undercity|r
step
.goto Undercity,62.31,48.59
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Patrick|r
.accept 2342 >> Accept Reclaimed Treasures
.target Patrick
step
#completewith UldaSub
.zone Badlands >>Travel to |cFFfa9602Badlands|r
step
.goto Badlands,2.42,46.05
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jarkal Mossmeld|r
>>|cRXP_WARN_This is a prerequisite quest for Uldaman|r
.accept 2258 >>Accept Badlands Reagent Run
.target Jarkal Mossmeld
step
#completewith next
>>Kill |cRXP_ENEMY_Buzzards|r. Loot them for their |cRXP_LOOT_Gizzards|r
>>Kill |cRXP_ENEMY_Coyotes|r. Loot them for their |cRXP_LOOT_Fangs|r
.complete 2258,1 
.mob +Buzzard
.mob +Giant Buzzard
.mob +Starving Buzzard
.complete 2258,2 
.mob +Crag Coyote
.mob +Feral Crag Coyote
.mob +Rabid Crag Coyote
.mob +Elder Crag Coyote
.isOnQuest 2258
step
#loop
.goto Badlands,23.41,45.26,0
.goto Badlands,23.41,45.26,50,0
.goto Badlands,21.90,43.22,50,0
.goto Badlands,19.99,43.10,50,0
.goto Badlands,17.76,41.06,50,0
.goto Badlands,16.62,38.29,50,0
.goto Badlands,14.78,37.34,50,0
.goto Badlands,13.48,37.80,50,0
.goto Badlands,13.01,40.09,50,0
.goto Badlands,15.11,41.89,50,0
.goto Badlands,16.94,42.80,50,0
.goto Badlands,19.17,45.74,50,0
.goto Badlands,20.47,48.40,50,0
.goto Badlands,23.12,48.20,50,0
>>Kill |cRXP_ENEMY_Lesser Rock Elementals|r. Loot them for their |cRXP_LOOT_Elemental Shards|r
.complete 2258,3 
.mob Lesser Rock Elemental
.isOnQuest 2258
step
#optional
#completewith next
>>Kill |cRXP_ENEMY_Buzzards|r. Loot them for their |cRXP_LOOT_Gizzards|r
.complete 2258,1 
.mob Buzzard
.mob Giant Buzzard
.mob Starving Buzzard
.isOnQuest 2258
step
#loop
.goto Badlands,25.09,55.10,0
.goto Badlands,44.11,71.87,90,0
.goto Badlands,37.09,69.28,90,0
.goto Badlands,30.28,62.70,90,0
.goto Badlands,25.09,55.10,90,0
>>Kill |cRXP_ENEMY_Coyotes|r. Loot them for their |cRXP_LOOT_Fangs|r
.complete 2258,2 
.mob Crag Coyote
.mob Feral Crag Coyote
.mob Rabid Crag Coyote
.mob Elder Crag Coyote
.isOnQuest 2258
step
#loop
.goto Badlands,17.24,58.53,0
.goto Badlands,17.24,58.53,50,0
.goto Badlands,15.35,58.51,50,0
.goto Badlands,14.85,60.16,50,0
.goto Badlands,15.00,61.98,50,0
.goto Badlands,16.15,61.84,50,0
.goto Badlands,17.01,61.24,50,0
>>Kill |cRXP_ENEMY_Buzzards|r. Loot them for their |cRXP_LOOT_Gizzards|r
.complete 2258,1 
.mob Buzzard
.mob Giant Buzzard
.mob Starving Buzzard
.isOnQuest 2258
step
.goto Badlands,2.42,46.05
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jarkal|r
.turnin 2258 >>Turn in Badlands Reagent Run
.target Jarkal Mossmeld
.isQuestComplete 2258
step
.goto Badlands,2.42,46.05
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jarkal Mossmeld|r
.accept 2202 >>Accept Uldaman Reagent Run
.target Jarkal Mossmeld
.isQuestTurnedIn 2258
step
#label SolDoom
.goto Badlands,51.38,76.88
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Theldurin the Lost|r
.accept 709 >>Accept Solution to Doom
.target Theldurin the Lost
step
#label UldaSub
.goto 1415,52.36,63.59
.zone 1415 >> Travel to Uldaman
step
#completewith Treasure
>>Kill |cRXP_ENEMY_Shadowforge Dwarves|r and |cRXP_ENEMY_Stonevault Troggs|r. Loot them for the |T133289:0|t[|cRXP_LOOT_Shattered Necklace|r]. Use it to accept the quest
.collect 7666,1,2283 
.accept 2283 >>Accept Necklace Recovery
.mob Shadowforge Surveyor
.mob Shadowforge Digger
.mob Shadowforge Ruffian
.mob Stonevault Cave Hunter
.mob Stonevault Cave Hunter
step
#completewith SNecklace
>>Loot the |cRXP_LOOT_Magenta Fungus Caps|r on the ground
>>|cRXP_WARN_This can be completed INSIDE and OUTSIDE of Uldaman|r
.complete 2202,1 
.isOnQuest 2202
step
.goto 1415,52.107,64.008
>>Open the |cRXP_PICK_Ancient Chest|r. Loot it for the |cRXP_LOOT_Tablet of Ryun'eh|r
>>|cRXP_WARN_This is completed OUTSIDE of Uldaman|r
.complete 709,1 
.isOnQuest 709
step
#label Treasure
.goto Eastern Kingdoms,51.78,63.77,15,0
.goto Eastern Kingdoms,51.72,63.73,15,0
.goto Eastern Kingdoms,51.68,63.81,15,0
.goto Eastern Kingdoms,51.80,64.00
>>Loot the |cRXP_PICK_Garret Family Chest|r in the southern corner of the South Common Hall for the |cRXP_LOOT_Garrett Family Treasure|r
>>|cRXP_WARN_The South Common Hall is southwest of the Uldaman instance portal|r
.complete 2342,1 
.isOnQuest 2342
step
#label SNecklace
#loop
.goto Eastern Kingdoms,52.35,63.53,50,0
.goto Eastern Kingdoms,52.14,63.60,50,0
.goto Eastern Kingdoms,51.85,63.71,50,0
.goto Eastern Kingdoms,51.94,63.98,50,0
.goto Eastern Kingdoms,51.86,64.21,50,0
.goto Eastern Kingdoms,52.10,64.00,50,0
>>Kill |cRXP_ENEMY_Shadowforge Dwarves|r and |cRXP_ENEMY_Stonevault Troggs|r. Loot them for the |T133289:0|t[|cRXP_LOOT_Shattered Necklace|r]. Use it to accept the quest
.collect 7666,1,2283 
.accept 2283 >>Accept Necklace Recovery
.mob Shadowforge Surveyor
.mob Shadowforge Digger
.mob Shadowforge Ruffian
.mob Stonevault Cave Hunter
.mob Stonevault Cave Hunter
step
#completewith NecklacePt1
.hs >>Hearth to Orgrimmar
.cooldown item,6948,>0,1
.use 6948
.zoneskip Orgrimmar
.bindlocation 1637,1
step
#completewith NecklacePt1
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step
#label NecklacePt1
.goto Orgrimmar,59.58,36.53
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Dran Droffers|r
>>|cRXP_WARN_The follow-up quests are completed inside Uldaman. Skip this step if you do not wish to travel to Orgrimmar now|r
.accept 2283 >>Accept Necklace Recovery
.turnin 2283 >>Turn in Necklace Recovery
.accept 2284 >>Accept Necklace Recovery, Take 2
.target Dran Droffers
step
#optional
#completewith next
>>Loot the |cRXP_LOOT_Magenta Fungus Caps|r on the ground
>>|cRXP_WARN_This can be completed INSIDE and OUTSIDE of Uldaman|r
.complete 2202,1 
.isOnQuest 2202
step
#label EnterUldaman1
.goto Eastern Kingdoms,51.86,63.50,15 >>Zone into Uldaman
step
#completewith Translate1
>>Loot the |cRXP_LOOT_Magenta Fungus Caps|r on the ground
>>|cRXP_WARN_This can be completed INSIDE and OUTSIDE of Uldaman|r
.complete 2202,1 
.isOnQuest 2202
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Remains of a Paladin|r
>>|cRXP_WARN_He is located in the north/western hallway after you enter the 1st room of the dungeon|r
.turnin 2284 >>Turn in Necklace Recovery, Take 2
.accept 2318 >>Accept Translating the Journal
.target Remains of a Paladin
.isOnQuest 2284
step
#label Translate1
#optional
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Remains of a Paladin|r
>>|cRXP_WARN_He is located in the north/western hallway after you enter the 1st room of the dungeon|r
.accept 2318 >>Accept Translating the Journal
.target Remains of a Paladin
.isQuestTurnedIn 2284
step
#completewith Translate2
.subzone 340 >>Travel to |cFFfa9602Kargath|r
step
.goto Badlands,2.42,46.05
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jarkal Mossmeld|r
.turnin 2318 >>Turn in Translating the Journal
.target Jarkal Mossmeld
.isOnQuest 2318
step
.goto Badlands,2.42,46.05
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jarkal Mossmeld|r
.accept 2338 >>Accept Translating the Journal
.turnin 2338 >>Turn in Translating the Journal
.timer 63,Translating the Journal RP
.target Jarkal Mossmeld
.isQuestTurnedIn 2318
step
#label Translate2
.goto Badlands,2.42,46.05
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jarkal Mossmeld|r
>>|cRXP_WARN_Wait for the RP to finish|r
.accept 2339 >>Accept Find the Gems and Power Source
.target Jarkal Mossmeld
.isQuestTurnedIn 2338
step
#label EnterUldaman2
.goto Eastern Kingdoms,51.86,63.50,15 >>Zone into Uldaman
step
#completewith Archaedas
>>Loot the |cRXP_LOOT_Magenta Fungus Caps|r on the ground
>>|cRXP_WARN_This can be completed INSIDE and OUTSIDE of Uldaman|r
.complete 2202,1 
.isOnQuest 2202
step
>>Collect the pieces of the |cRXP_LOOT_Shattered Necklace|r
>>|cRXP_WARN_The|r |cRXP_LOOT_Shattered Necklace Topaz|r |cRXP_WARN_is located in a |cRXP_PICK_Conspicuous Urn|r in "Dig Two" (the three dwarves room)|r
>>|cRXP_WARN_The |cRXP_LOOT_Shattered Necklace Sapphire|r is dropped by|r |cRXP_ENEMY_Grimlok|r
>>|cRXP_WARN_The |cRXP_LOOT_Shattered Necklace Ruby|r is looted from a |cRXP_PICK_Chest|r in |cRXP_ENEMY_Galgann Firehammer's|r room|r
.complete 2339,3 
.mob +Olaf
.complete 2339,2 
.mob +Grimlok
.complete 2339,1 
.mob +Galgann Firehammer
.isOnQuest 2339
step
>>Kill |cRXP_ENEMY_Archaedas|r. Loot him for the |cRXP_LOOT_Shattered Necklace Power Source|r
.complete 2339,4 
.mob Archaedas
.isOnQuest 2339
step
#label Archaedas
>>Kill |cRXP_ENEMY_Archaedas|r
>>Click |cRXP_PICK_The Discs of Norgannon|r
.accept 2278 >> Accept The Platinum Discs
.mob Archaedas
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lore Keeper of Norgannon|r
.complete 2278,1 
.skipgossip
.target Lore Keeper of Norgannon
step
>>Click |cRXP_PICK_The Discs of Norgannon|r
.turnin 2278 >> Turn in The Platinum Discs
.accept 2280 >> Accept The Platinum Discs
step
#completewith BadlandsTurnins
.zone Badlands >>Leave Uldaman
step
.goto Badlands,51.38,76.88
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Theldurin the Lost|r
.turnin 709 >>Turn in Solution to Doom
.accept 728 >>Accept To the Undercity for Yagyin's Digest
.target Theldurin the Lost
.isQuestComplete 709
step
#optional
.goto Badlands,51.38,76.88
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Theldurin the Lost|r
.accept 728 >>Accept To the Undercity for Yagyin's Digest
.target Theldurin the Lost
.isQuestTurnedIn 709
step
.goto Badlands,2.42,46.05
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jarkal Mossmeld|r
.turnin 2202 >>Turn in Uldaman Reagent Run
.target Jarkal Mossmeld
.isQuestComplete 2202
step
.goto Badlands,2.42,46.05
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jarkal Mossmeld|r
.turnin 2339 >>Turn in Find the Gems and Power Source
.accept 2340 >>Accept Deliver the Gems
.target Jarkal Mossmeld
.isQuestComplete 2339
step
#optional
#label BadlandsTurnins
.goto Badlands,2.42,46.05
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jarkal Mossmeld|r
.accept 2340 >>Accept Deliver the Gems
.target Jarkal Mossmeld
.isQuestTurnedIn 2339
step
#completewith NecklacePt2
.hs >>Hearth to Orgrimmar
.cooldown item,6948,>0,1
.use 6948
.zoneskip Orgrimmar
.bindlocation 1637,1
step
#completewith NecklacePt2
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step
#optional
.goto Orgrimmar,59.58,36.53
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Dran Droffers|r
.accept 2283 >> Accept Necklace Recovery
.turnin 2283 >> Turn in Necklace Recovery
.target Dran Droffers
.itemcount 7666,1
step
.goto Orgrimmar,59.58,36.53
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Dran Droffers|r
.turnin 2340 >>Turn in Deliver the Gems
.accept 2341 >>Accept Necklace Recovery, Take 3
.target Dran Droffers
.isQuestComplete 2340
step
#optional
#label NecklacePt2
.goto Orgrimmar,59.58,36.53
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Dran Droffers|r
.accept 2341 >>Accept Necklace Recovery, Take 3
.target Dran Droffers
.isQuestTurnedIn 2340
step
#completewith PortensUldum
.zone Thunder Bluff >>Travel to |cFFfa9602Thunder Bluff|r
step
.goto Thunder Bluff,34.42,46.90
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sage|r
.turnin 2280 >> Turn in The Platinum Discs
.accept 2440 >> Accept The Platinum Discs
.target Sage Truthseeker
.isQuestTurnedIn 2278
step
.goto Thunder Bluff,46.61,33.17
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bena|r
.turnin 2440 >> Turn in The Platinum Discs
.accept 2965 >> Accept Portents of Uldum
.target Bena Winterhoof
.isQuestTurnedIn 2278
step
#label PortensUldum
.goto Thunder Bluff,75.67,31.58
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nara|r
.turnin 2965 >> Turn in Portents of Uldum
.accept 2966 >> Accept Seeing What Happens
.target Nara Wildmane
.isQuestTurnedIn 2278
step
#completewith StoneWatcher
.zone Tanaris >>Travel to |cFFfa9602Tanaris|r
step
.goto Tanaris,39.69,78.30,60,0
.goto Tanaris,39.21,80.25,25,0
.goto Tanaris,38.67,80.45,25,0
.goto Tanaris,38.47,80.99,30,0
.goto Tanaris,37.63,81.40
>>Click the |cRXP_PICK_Uldum Pedestal|r
>>|cRXP_WARN_Be careful! There are elite|r |cRXP_ENEMY_Dune Giants|r |cRXP_WARN_in the area. Follow the waypoint arrow to avoid agro|r
.turnin 2966 >> Turn in Seeing What Happens
.accept 2954 >> Accept The Stone Watcher
.unitscan Dune Smasher
.unitscan Raging Dune Smasher
.isQuestTurnedIn 2965
step
.goto Tanaris,37.63,81.40
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Stone Watcher of Norgannon|r
.complete 2954,1 
.skipgossip
.target Stone Watcher of Norgannon
.isQuestTurnedIn 2965
step
#label StoneWatcher
.goto Tanaris,37.63,81.40
>>Click the |cRXP_PICK_Uldum Pedestal|r
.turnin 2954 >> Turn in The Stone Watcher
.accept 2967 >> Accept Return to Thunder Bluff
.isQuestTurnedIn 2965
step
#completewith FutureTask
.zone Thunder Bluff >>Travel to |cFFfa9602Thunder Bluff|r
step
.goto Thunder Bluff,75.67,31.58
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nara|r
.turnin 2967 >> Turn in Return to Thunder Bluff
.accept 2968 >> Accept A Future Task
.target Nara Wildmane
.isQuestTurnedIn 2954
step
#label FutureTask
.goto Thunder Bluff,34.42,46.90
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sage|r
.turnin 2968 >> Turn in A Future Task
.target Sage Truthseeker
.isQuestTurnedIn 2954
step
#completewith UCTurnins
.zone Undercity >>Travel to |cFFfa9602Undercity|r
step
.goto Undercity,53.77,54.48
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bel'dugur|r
.turnin 728 >>Turn in To the Undercity for Yagyin's Digest
.target Keeper Bel'dugur
.isOnQuest 728
step << skip
#optional
.goto Undercity,53.77,54.48
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bel'dugur|r
.accept 736 >>Accept The Star, the Hand and the Heart
.target Keeper Bel'dugur
.isQuestTurnedIn 728
step
#label UCTurnins
.goto Undercity,62.31,48.59
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Patrick|r
.turnin 2342 >> Turn in Reclaimed Treasures
.target Patrick
.isQuestComplete 2342
step
#completewith next
.subzone 340 >>Travel to |cFFfa9602Kargath|r
step
.goto Badlands,2.42,46.05
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jarkal Mossmeld|r
.turnin 2341 >>Turn in Necklace Recovery, Take 3
.target Jarkal Mossmeld
.isOnQuest 2341
step
+|cRXP_WARN_This is the end of the Uldaman guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 30-50
<< Horde
#name 110 Zul'Farrak
#displayname 10. Zul'Farrak
step
#completewith ZFPickups
+|cRXP_WARN_You will now be directed to pick up all available quests for Zul'Farrak|r
step
#completewith next
.subzone 355 >>Travel to |cFFfa9602The Altar of Zul|r in The Hinterlands
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
#completewith Prophecy
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
#label EnterZF
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
>>Kill |cRXP_ENEMY_Theka the Martyr|r. Loot him for the |cRXP_LOOT_First Mosh'aru Tablet|r
.complete 3527,1 
.mob Theka the Martyr
.isOnQuest 3527
step
>>Kill |cRXP_ENEMY_Scarabs|r. Loot them for their |cRXP_LOOT_Uncracked Scarab Shell|r
.complete 2865,1 
.isOnQuest 2865
step
#completewith next
+Ascend the Pyramid
>>Kill the |cRXP_ENEMY_Sandfury Executioner|r. Loot him for the |cRXP_LOOT_Executioner's Key|r
>>|cRXP_WARN_Anyone in the party may loot the|r |cRXP_LOOT_Key|r
>>|cRXP_WARN_Use the|r |cRXP_LOOT_Executioner's Key|r |cRXP_WARN_on one of the |cRXP_PICK_Troll Cages|r to free |cRXP_FRIENDLY_Sergeant Bly|r and his band|r
.collect 8444,1 
.disablecheckbox
.isOnQuest 2768
.mob Sandfury Executioner
step
>>Defend |cRXP_FRIENDLY_Sergeant Bly|r and his band, then move down with them after a short period of time
>>Kill |cRXP_ENEMY_Nekrum Gutchewer|r. Eat and drink then talk to |cRXP_FRIENDLY_Sergeant Bly|r to fight him
>>Kill |cRXP_ENEMY_Sergeant Bly|r. Loot him for the |cRXP_LOOT_Divino-matic Rod|r
.complete 2768,1 
.isOnQuest 2768
.skipgossip
step
>>Kill |cRXP_ENEMY_Hydromancer Velratha|r. Loot her for the |cRXP_LOOT_Tiara of the Deep|r and the |cRXP_LOOT_Second Mosh'aru Tablet|r
.complete 2846,1 
.complete 3527,2 
.mob Hydromancer Velratha
.isOnQuest 2846
.isOnQuest 3527
step
>>Kill |cRXP_ENEMY_Hydromancer Velratha|r. Loot her for the |cRXP_LOOT_Tiara of the Deep|r
.complete 2846,1 
.mob Hydromancer Velratha
.isOnQuest 2846
step
>>Kill |cRXP_ENEMY_Hydromancer Velratha|r. Loot her for the |cRXP_LOOT_Second Mosh'aru Tablet|r
.complete 3527,2 
.mob Hydromancer Velratha
.isOnQuest 3527
step
#label Gahzrilla
>>|cRXP_WARN_Use the|r |T133056:0|t[|cRXP_FRIENDLY_Mallet of Zul'Farrak|r] |cRXP_WARN_on the |cRXP_PICK_Gong of Zul'Farrak|r to summon|r |cRXP_ENEMY_Gahz'rilla|r
>>Kill |cRXP_ENEMY_Gahz'rilla|r. Loot him for |cRXP_LOOT_Gahz'rilla's Electrified Scale|r
>>|cRXP_WARN_If no one in your party has the|r |T133056:0|t[|cRXP_FRIENDLY_Mallet of Zul'Farrak|r] |cRXP_WARN_you will not be able to summon|r |cRXP_ENEMY_Gahz'rilla|r
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
+|cRXP_WARN_This is the end of the Zul'Farrak guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 30-50
<< Horde
#name 111 Maraudon
#displayname 11. Maraudon
step
#completewith MaraPickups
+|cRXP_WARN_You will now be directed to pick up all available quests for Maraudon|r
step
#completewith next
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step
.goto Orgrimmar,39.16,86.27
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Uthel'nay|r
.accept 7068 >>Accept Shadowshard Fragments
.target Uthel'nay
step
#completewith MaraPickups
.zone Desolace >>Travel to |cFFfa9602Desolace|r
step
.goto Desolace,23.22,70.33
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vark|r at the top of the hut
.accept 7029 >> Accept Vyletongue Corruption
.target Vark Battlescar
step
.goto Desolace,24.09,68.21
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Innkeeper Sikewa|r
>>|cRXP_WARN_This is so you can Hearth after completing the dungeon|r
.home >>Set your Hearthstone to Shadowprey Village
.target Innkeeper Sikewa
.bindlocation 2408
step
.goto Desolace,26.87,77.67
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Selendra|r
.accept 7064 >> Accept Corruption of Earth and Seed
.target Selendra
step
#loop
.line Desolace,50.48,86.66,50.39,86.61,50.18,87.01,49.89,87.11,48.95,87.04,48.73,87.11,48.25,87.14,47.82,87.34,47.01,86.96,45.68,86.22,45.16,86.32,44.74,86.12,44.40,85.69,44.11,85.25,43.77,84.93,43.59,84.93
.goto Desolace,43.59,84.93,50,0
.goto Desolace,47.01,86.96,70,0
.goto Desolace,50.48,86.66,50,0
.goto Desolace,50.48,86.66,0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Centaur Pariah|r
>>|cRXP_WARN_The |cRXP_FRIENDLY_Centaur Pariah|r patrols slightly around southern Desolace|r
.accept 7067 >> Accept The Pariah's Instructions
.target Centaur Pariah
step
#label MaraPickups
.goto Desolace,62.194,39.624
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Willow|r
.accept 7028 >> Accept Twisted Evils
.target Willow
step
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
.complete 7068,1 
.mob Shadowshard Smasher
.mob Shadowshard Rumbler
.isOnQuest 7068
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
.complete 7068,1 
.mob Shadowshard Smasher
.mob Shadowshard Rumbler
.isOnQuest 7068
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
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Centaur Pariah|r
.accept 7044 >> Accept Legends of Maraudon
.target Cavindra
step
.goto 1414,38.928,58.354
>>|cRXP_WARN_Use the|r |T134865:0|t[Coated Cerulean Vial] |cRXP_WARN_in the Orange pool|r
.complete 7029,2 
.use 17693 
.isOnQuest 7029
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
.complete 7029,1 
.use 17696 
.isOnQuest 7029
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
.complete 7029,1 
.use 17696 
.isOnQuest 7029
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
.target Celebras the Redeemed
.isQuestTurnedIn 7044
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
.complete 7064,1 
.mob Princess Theradras
.isOnQuest 7064
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
#completewith MaraTurnins
.zone Desolace >> Leave the Maraudon instance
step
#completewith MaraTurnins
.hs >>Hearth to Shadowprey Village
.cooldown item,6948,>0,1
.use 6948
.zoneskip Desolace
.bindlocation 2408,1
step
.goto Desolace,23.22,70.33
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vark|r at the top of the hut
.turnin 7029 >> Turn in Vyletongue Corruption
.target Vark Battlescar
.isQuestComplete 7029
step
.goto Desolace,26.87,77.67
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Selendra|r
.turnin 7064 >> Turn in Corruption of Earth and Seed
.target Selendra
.isQuestComplete 7064
step
#loop
.line Desolace,50.48,86.66,50.39,86.61,50.18,87.01,49.89,87.11,48.95,87.04,48.73,87.11,48.25,87.14,47.82,87.34,47.01,86.96,45.68,86.22,45.16,86.32,44.74,86.12,44.40,85.69,44.11,85.25,43.77,84.93,43.59,84.93
.goto Desolace,43.59,84.93,50,0
.goto Desolace,47.01,86.96,70,0
.goto Desolace,50.48,86.66,50,0
.goto Desolace,50.48,86.66,0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Centaur Pariah|r
>>|cRXP_WARN_The |cRXP_FRIENDLY_Centaur Pariah|r patrols slightly around southern Desolace|r
.turnin 7067 >> Turn in The Pariah's Instructions
.target Centaur Pariah
.isQuestComplete 7067
step
#label MaraTurnins
.goto Desolace,62.194,39.624
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Willow|r
.turnin 7028 >> Turn in Twisted Evils
.target Willow
.isQuestComplete 7028
step
#completewith next
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step
.goto Orgrimmar,39.16,86.27
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Uthel'nay|r
.turnin 7068 >>Turn in Shadowshard Fragments
.target Uthel'nay
step << !Druid
#completewith next
.zone Felwood >>Travel to |cFFfa9602Felwood|r
step << !Druid
#completewith next
.goto Felwood,65.37,6.92,20,0
.goto Felwood,64.89,5.82,20,0
.goto Felwood,64.56,3.46,20,0
.goto Felwood,65.41,2.77,20,0
.goto Felwood,65.38,1.08,20,0
.goto Felwood,65.98,0.64,20,0
.goto Kalimdor,52.27,22.95,20,0
.goto Kalimdor,52.33,22.62,20,0
.goto Kalimdor,52.23,22.49,20,0
.goto Kalimdor,52.27,22.35,20,0
.goto Kalimdor,52.33,22.34,20,0
.goto Moonglade,35.74,72.37,20,0
.zone Moonglade >>Enter the tunnel, then take the north exit into Moonglade
.zoneskip Moonglade
.isOnQuest 7066
step << Druid
#completewith next
.cast 18960 >>|cRXP_WARN_Cast|r |T135758:0|t[Teleport: Moonglade]
.zoneskip Moonglade
step
.goto Moonglade,36.178,41.798
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Keeper Remulos|r
.turnin 7066 >> Turn in Seed of Life
.target Keeper Remulos
.isOnQuest 7066
step
+|cRXP_WARN_This is the end of the Maraudon guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 30-50
<< Horde
#name 112 Sunken Temple
#displayname 12. Sunken Temple
step
#completewith DungeonTime
+|cRXP_WARN_You will now be directed to pick up all available quests for Sunken Temple|r
>>|cRXP_WARN_Be aware that every Sunken Temple quest has prerequisite quests that need to be completed first. The guide will guide you through this, but feel free to skip anything you do not wish to do|r
step << Shaman
#phase 4-6
#completewith next
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step << Shaman
#phase 4-6
.goto Orgrimmar,38.66,35.91
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sagorne|r
.accept 8410 >>Accept Elemental Mastery
.target Sagorne Creststrider
step << Warrior
#phase 4-6
#completewith next
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step << Warrior
#phase 4-6
.goto Orgrimmar,80.39,32.38
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sorek|r
.accept 8417 >>Accept A Troubled Spirit
.target Sorek
step << Rogue
#phase 4-6
#completewith next
.zone Undercity >>Travel to |cFFfa9602Undercity|r
step << Rogue
#phase 4-6
#label RogueSTClassQ
.goto Undercity,85.20,71.57
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Miles Dexter|r
.accept 8233 >>Accept A Simple Request
.target Miles Dexter
step << Rogue
#phase 4-6
#completewith next
.goto Undercity,63.27,48.55
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Michael|r
.fly Tarren Mill >> Fly to Tarren Mill
.target Michael Garrett
.zoneskip Hillsbrad Foothills
.isOnQuest 8233
step << Rogue
#phase 4-6
.goto Hillsbrad Foothills,75.575,22.076,20,0
.goto Alterac Mountains,86.026,78.879
.subzone 3486 >> Travel to Ravenholdt Manor
.isOnQuest 8233
step << Rogue
#phase 4-6
.goto Hillsbrad Foothills,75.49,23.96,30,0
.goto Hillsbrad Foothills,75.61,19.52,30,0
.goto Hillsbrad Foothills,77.68,22.59,30,0
.goto Hillsbrad Foothills,77.58,19.61,30,0
.goto Alterac Mountains,86.02,78.88
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jorach|r
.turnin 8233 >> Turn in A Simple Request
.accept 8234 >> Accept Sealed Azure Bag
.target Lord Jorach Ravenholdt
.isOnQuest 8233
step << Rogue
#phase 4-6
#optional
.goto Hillsbrad Foothills,75.49,23.96,30,0
.goto Hillsbrad Foothills,75.61,19.52,30,0
.goto Hillsbrad Foothills,77.68,22.59,30,0
.goto Hillsbrad Foothills,77.58,19.61,30,0
.goto Alterac Mountains,86.02,78.88
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jorach|r
.accept 8234 >> Accept Sealed Azure Bag
.target Lord Jorach Ravenholdt
.isQuestTurnedIn 8233
step << Rogue
#phase 4-6
#completewith AzureKey
.zone Azshara >>Travel to |cFFfa9602Azshara|r
step << Rogue
#phase 4-6
.goto Azshara,44.20,22.40
>>Pickpocket |cRXP_ENEMY_Timbermaw Shamans|r until you loot a |cRXP_LOOT_Sealed Azure Bag|r
.complete 8234,1 
.mob Timbermaw Shaman
.isOnQuest 8234
step << Rogue
#phase 4-6
#completewith next
.goto Azshara,28.11,50.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sanath Lim-yo|r
.turnin 3503 >>Turn in Meeting with the Master
.target Sanath Lim-yo
step << Rogue
#phase 4-6
.goto Azshara,27.64,41.49,30,0
.goto Azshara,29.7,40.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Xylem|r
>>|cRXP_WARN_The Archmage wanders his tower|r
.turnin 8234 >>Turn in Sealed Azure Bag
.accept 8235 >>Accept Encoded Fragments
.target Archmage Xylem
.isQuestComplete 8234
step << Rogue
#optional
#phase 4-6
.goto Azshara,27.64,41.49,30,0
.goto Azshara,29.7,40.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Xylem|r
>>|cRXP_WARN_The Archmage wanders his tower|r
.accept 8235 >>Accept Encoded Fragments
.target Archmage Xylem
.isQuestTurnedIn 8234
step << Rogue
#phase 4-6
#completewith next
.goto Azshara,26.466,46.271
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nyrill|r
>>|cRXP_WARN_This will teleport you back down|r
.turnin 3421 >> Turn in Return Trip
.timer 8,Return Trip RP
.target Nyrill
step << Rogue
#phase 4-6
#loop
.goto Azshara,66.60,25.20,0
.goto Azshara,66.60,25.20,60,0
.goto Azshara,69.00,25.60,60,0
.goto Azshara,71.60,29.20,60,0
.goto Azshara,71.60,24.60,60,0
.goto Azshara,80.80,24.60,60,0
.goto Azshara,86.60,19.60,60,0
.goto Azshara,74.60,12.60,60,0
>>Kill |cRXP_ENEMY_Forest Oozes|r. Loot them for their |cRXP_LOOT_Encoded Fragments|r
.complete 8235,1 
.unitscan Forest Ooze
.isOnQuest 8235
step << Rogue
#phase 4-6
#completewith next
.goto Azshara,28.11,50.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sanath|r
.turnin 3503 >>Turn in Meeting with the Master
.target Sanath Lim-yo
step << Rogue
#label AzureKey
#phase 4-6
.goto Azshara,29.248,40.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Xylem|r atop the Tower
.turnin 8235 >>Turn in Encoded Fragments
.accept 8236 >>Accept The Azure Key
.target Archmage Xylem
.isQuestComplete 8235
step << Mage
#phase 4-6
#completewith next
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step << Mage
#phase 4-6
.goto Orgrimmar,39.20,86.30
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Uthel'nay|r
.accept 8250 >> Accept Magecraft
.target Uthel'nay
step << Mage
#phase 4-6
#completewith DestroyMorphaz
.zone Azshara >>Travel to |cFFfa9602Azshara|r
step << Mage
#phase 4-6
#completewith MagicDust
.goto Azshara,28.11,50.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sanath Lim-yo|r
.turnin 3503 >>Turn in Meeting with the Master
.target Sanath Lim-yo
step << Mage
#phase 4-6
.goto Azshara,29.2,40.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Xylem|r
>>|cRXP_WARN_The Archmage wanders his tower|r
.turnin 8250 >>Turn in Magecraft
.accept 8251 >>Accept Magic Dust
.target Archmage Xylem
.isOnQuest 8250
step << Mage
#label MagicDust
#optional
#phase 4-6
.goto Azshara,29.2,40.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Xylem|r
>>|cRXP_WARN_The Archmage wanders his tower|r
.accept 8251 >>Accept Magic Dust
.target Archmage Xylem
.isOnQuest 8250
step << Mage
#phase 4-6
#completewith next
.goto Azshara,26.466,46.271
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nyrill|r
>>|cRXP_WARN_This will teleport you back down|r
.turnin 3421 >> Turn in Return Trip
.timer 8,Return Trip RP
.target Nyrill
step << Mage
#phase 4-6
#loop
.goto Azshara,55.80,25.90,0
.goto Azshara,55.80,25.90,50,0
.goto Azshara,57.80,26.40,50,0
.goto Azshara,58.00,28.20,50,0
.goto Azshara,59.20,29.60,50,0
.goto Azshara,57.90,31.40,50,0
.goto Azshara,57.00,30.30,50,0
.goto Azshara,56.90,27.50,50,0
.goto Azshara,56.00,29.70,50,0
.goto Azshara,55.40,29.70,50,0
>>Kill |cRXP_ENEMY_Blood Elf Reclaimers|r and |cRXP_ENEMY_Blood Elf Surveyors|r. Loot them for their |cRXP_LOOT_Dust|r
>>|cRXP_WARN_Be careful!|r |cRXP_ENEMY_Surveyors|r |cRXP_WARN_have a short cooldown Fire Nova, and|r |cRXP_ENEMY_Reclaimers|r |cRXP_WARN_have a high-damage fireball|r
.complete 8251,1 
.mob +Blood Elf Reclaimer
.mob +Blood Elf Surveyor
.isOnQuest 3505
step << Mage
#phase 4-6
#completewith next
.goto Azshara,28.11,50.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sanath Lim-yo|r
.turnin 3503 >>Turn in Meeting with the Master
.target Sanath Lim-yo
step << Mage
#phase 4-6
.goto Azshara,29.2,40.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Xylem|r
>>|cRXP_WARN_The Archmage wanders his tower|r
.turnin 8251 >>Turn in Magic Dust
.accept 8252 >>Accept The Siren's Coral
.target Archmage Xylem
step << Mage
#phase 4-6
#completewith next
.goto Azshara,28.11,50.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sanath Lim-yo|r
.turnin 3503 >>Turn in Meeting with the Master
.target Sanath Lim-yo
step << Mage
#phase 4-6
#loop
.goto Azshara,44.00,48.20,0
.goto Azshara,44.00,48.20,50,0
.goto Azshara,45.60,43.80,50,0
.goto Azshara,47.00,41.60,50,0
.goto Azshara,48.80,45.00,50,0
.goto Azshara,47.40,49.00,50,0
.goto Azshara,48.20,54.00,50,0
.goto Azshara,48.20,59.80,50,0
.goto Azshara,48.60,64.80,50,0
.goto Azshara,46.20,61.00,50,0
.goto Azshara,45.60,57.80,50,0
.goto Azshara,46.00,52.80,50,0
>>Kill |cRXP_ENEMY_Spitelash Sirens|r. Loot them for their |cRXP_LOOT_Enchanted Corals|r
.complete 8252,1 
.mob Spitelash Siren
step << Mage
#phase 4-6
#completewith DestroyMorphaz
.goto Azshara,28.11,50.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sanath|r
.turnin 3503 >>Turn in Meeting with the Master
.target Sanath Lim-yo
step << Mage
#phase 4-6
.goto Azshara,29.248,40.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Xylem|r atop the Tower
.turnin 8252 >>Turn in The Siren's Coral
.accept 8253 >>Accept Destroy Morphaz
.target Archmage Xylem
.isQuestComplete 8252
step << Mage
#label DestroyMorphaz
#phase 4-6
#optional
.goto Azshara,29.248,40.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Xylem|r atop the Tower
.accept 8253 >>Accept Destroy Morphaz
.target Archmage Xylem
.isQuestTurnedIn 8252
step << Priest
#phase 4-6
#completewith next
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step << Priest
#phase 4-6
.goto Orgrimmar,35.59,87.80
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to|r |cRXP_FRIENDLY_Ur'kyo|r
.accept 8254 >> Accept Cenarion Aid
.target Ur'kyo
step << Priest
#phase 4-6
#completewith BloodofMorphaz
.zone Azshara >>Travel to |cFFfa9602Azshara|r
step << Priest
#phase 4-6
#loop
.goto Azshara,17.80,67.80,0
.goto Azshara,17.80,67.80,50,0
.goto Azshara,16.60,71.80,50,0
.goto Azshara,14.60,73.60,50,0
.goto Azshara,13.60,72.60,50,0
.goto Azshara,16.60,68.60,50,0
.goto Azshara,17.20,66.00,50,0
>>Kill |cRXP_ENEMY_Highborne Apparitions|r and |cRXP_ENEMY_Highborne Lichlings|r. Loot them for an |T134437:0|t[|cRXP_LOOT_Ichor of Undeath|r]
.collect 7972,1 << Priest 
.mob Highborne Apparition
.mob Highborne Lichling
.isOnQuest 8254
step << Priest
#phase 4-6
#completewith next
.goto Azshara,41.61,42.68,50 >> Travel toward |cRXP_FRIENDLY_Ogtinc|r, he is located on a small peak
step << Priest
#phase 4-6
.goto Azshara,42.40,42.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
>>|cRXP_WARN_Be careful of falling as you approach him; he's in a precarious spot|r
.turnin 8254 >>Turn in Cenarion Aid
.accept 8255 >>Accept Of Coursers We Know
.target Ogtinc
.isOnQuest 8254
step << Priest
#phase 4-6
#optional
.goto Azshara,42.40,42.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
>>|cRXP_WARN_Be careful of falling as you approach him; he's in a precarious spot|r
.accept 8255 >>Accept Of Coursers We Know
.target Ogtinc
.isQuestTurnedIn 8254
step << Priest
#phase 4-6
#loop
.goto Azshara,48.40,33.20,0
.goto Azshara,48.40,33.20,60,0
.goto Azshara,48.40,16.40,60,0
.goto Azshara,55.20,17.00,60,0
.goto Azshara,59.60,22.90,60,0
.goto Azshara,70.60,28.40,60,0
.goto Azshara,83.20,25.00,60,0
.goto Azshara,76.60,27.30,60,0
.goto Azshara,67.80,27.40,60,0
.goto Azshara,61.40,23.30,60,0
.goto Azshara,55.30,25.30,60,0
.goto Azshara,50.20,25.40,60,0
>>Kill |cRXP_ENEMY_Mosshoof Coursers|r. Loot them for their |cRXP_LOOT_Glands|r << Priest
>>|cRXP_ENEMY_Mosshoof Coursers|r |cRXP_WARN_share respawn with Hippogryphs and Chimaeras|r
.complete 8255,1 << Priest 
.mob Mosshoof Courser
.isOnQuest 8255
step << Priest
#phase 4-6
.goto Azshara,42.40,42.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
.turnin 8255 >>Turn in Accept Of Coursers We Know
.accept 8256 >>Accept The Ichor of Undeath
.target Ogtinc
.isQuestComplete 8255
step << Priest
#phase 4-6
#optional
.goto Azshara,42.40,42.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
.accept 8256 >>Accept The Ichor of Undeath
.target Ogtinc
.isQuestTurnedIn 8255
step << Priest
#phase 4-6
#loop
.goto Azshara,17.80,67.80,0
.goto Azshara,17.80,67.80,50,0
.goto Azshara,16.60,71.80,50,0
.goto Azshara,14.60,73.60,50,0
.goto Azshara,13.60,72.60,50,0
.goto Azshara,16.60,68.60,50,0
.goto Azshara,17.20,66.00,50,0
>>Kill |cRXP_ENEMY_Highborne Apparitions|r and |cRXP_ENEMY_Highborne Lichlings|r. Loot them for an |T134437:0|t[|cRXP_LOOT_Ichor of Undeath|r]
.collect 7972,1 << Priest 
.mob Highborne Apparition
.mob Highborne Lichling
.isOnQuest 8254
step << Priest
#phase 4-6
.goto Azshara,42.40,42.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
.turnin 8256 >>Turn in The Ichor of Undeath
.accept 8257 >>Accept Blood of Morphaz
.target Ogtinc
.isQuestTurnedIn 8255
step << Priest
#phase 4-6
#label BloodofMorphaz
#optional
.goto Azshara,42.400,42.619
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
.accept 8257 >> Accept Blood of Morphaz
.target Ogtinc
.isQuestTurnedIn 8256
step << Hunter
#phase 4-6
#completewith next
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step << Hunter
#phase 4-6
.goto Orgrimmar,66.05,18.52
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ormak|r
.accept 8151 >>Accept The Hunter's Charm
.target Ormak Grimshot
step << Hunter
#phase 4-6
#completewith TheGreenDrake
.zone Azshara >>Travel to |cFFfa9602Azshara|r
step << Hunter
#phase 4-6
#completewith CoursersAntlers
.goto Azshara,41.61,42.68,50 >>Travel toward |cRXP_FRIENDLY_Ogtinc|r, he is located on a small peak
step << Hunter
#phase 4-6
.goto Azshara,42.40,42.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
>>|cRXP_WARN_Be careful of falling as you approach him; he's in a precarious spot|r
.turnin 8151 >>Turn in The Hunter's Charm
.accept 8153 >>Accept Courser Antlers
.target Ogtinc
.isQuestComplete 8151
step << Hunter
#phase 4-6
#label CoursersAntlers
#optional
.goto Azshara,42.40,42.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
>>|cRXP_WARN_Be careful of falling as you approach him; he's in a precarious spot|r
.accept 8153 >>Accept Courser Antlers
.target Ogtinc
.isQuestTurnedIn 8151
step << Hunter
#phase 4-6
#loop
.goto Azshara,48.40,33.20,0
.goto Azshara,48.40,33.20,60,0
.goto Azshara,48.40,16.40,60,0
.goto Azshara,55.20,17.00,60,0
.goto Azshara,59.60,22.90,60,0
.goto Azshara,70.60,28.40,60,0
.goto Azshara,83.20,25.00,60,0
.goto Azshara,76.60,27.30,60,0
.goto Azshara,67.80,27.40,60,0
.goto Azshara,61.40,23.30,60,0
.goto Azshara,55.30,25.30,60,0
.goto Azshara,50.20,25.40,60,0
>>Kill |cRXP_ENEMY_Mosshoof Coursers|r. Loot them for their |cRXP_LOOT_Antlers|r
>>|cRXP_ENEMY_Mosshoof Coursers|r |cRXP_WARN_share respawn with Hippogryphs and Chimaeras|r
.complete 8153,1 
.mob Mosshoof Courser
.isOnQuest 8153
step << Hunter
#phase 4-6
.goto Azshara,42.40,42.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
.turnin 8153 >>Turn in Coursers Antlers
.accept 8231 >>Accept Wavethrashing
.target Ogtinc
.isQuestComplete 8153
step << Hunter
#phase 4-6
#optional
.goto Azshara,42.40,42.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
.accept 8231 >>Accept Wavethrashing
.isQuestTurnedIn 8153
.target Ogtinc
step << Hunter
#phase 4-6
#completewith next
.goto Azshara,47.80,60.80,50
>>Travel south to the cliff and jump down into the water
step << Hunter
#phase 4-6
#loop
.goto Azshara,88.69,25.88,70,0
.goto Azshara,54.2,42.2,70,0
.goto Azshara,59.2,35.6,70,0
.goto Azshara,71.6,36.8,70,0
.goto Azshara,90.4,33.6,70,0
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
.isOnQuest 8231
step << Hunter
#phase 4-6
.goto Azshara,42.40,42.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
.turnin 8231 >>Turn in Wavethrashing
.accept 8232 >>Accept The Green Drake
.target Ogtinc
.isQuestComplete 8231
step << Hunter
#phase 4-6
#label TheGreenDrake
#optional
.goto Azshara,42.40,42.62
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
.accept 8232 >>Accept The Green Drake
.target Ogtinc
.isQuestTurnedIn 8231
step << Warlock
#phase 4-6
#completewith next
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step << Warlock
#phase 4-6
.goto Orgrimmar,48.62,46.95
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mirket|r
.trainer >>Train your class spells
.accept 8419 >>Accept An Imp's Request
.target Mirket
step << Warlock
#ah
#phase 4-6
.goto Orgrimmar,55.59,62.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thathung|r
>>|cRXP_BUY_Buy an|r |T132888:0|t[Felcloth] |cRXP_BUY_from the Auction House|r
>>|cRXP_WARN_This is for an instant turn in at Felwood shortly. Skip this step if you wish to not buy any|r
.collect 14256,1,8419,1 
.target Auctioneer Thathung
.zoneskip Orgrimmar,1
step << Warlock
#phase 4-6
#completewith TrollsofaFeather
.zone Felwood >>Travel to |cFFfa9602Felwood|r
step << Warlock
#phase 4-6
#loop
.goto Felwood,43.41,88.13,0
.goto Felwood,39.45,84.55,0
.goto Felwood,43.41,88.13,70,0
.goto Felwood,39.45,84.55,70,0
>>Kill all |cRXP_ENEMY_Jadefire Satyrs|r until you loot 1 |cRXP_LOOT_Felcloth|r
.collect 14256,1,8419,1 
.mob Jadefire Rogue
.mob Jadefire Felsworn
.unitscan Jadefire Shadowstalker
.isOnQuest 8419
step << Warlock
#phase 4-6
.goto Felwood,41.52,44.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Impsy|r
.turnin 8419 >> Turn in An Imp's Request
.accept 8421 >> Accept The Wrong Stuff
.target Impsy
.isQuestComplete 8419
step << Warlock
#phase 4-6
#optional
.goto Felwood,41.52,44.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Impsy|r
.accept 8421 >> Accept The Wrong Stuff
.target Impsy
.isQuestTurnedIn 8419
step << Warlock
#phase 4-6
#loop
.goto Felwood,41.20,45.40,0
.goto Felwood,41.20,45.40,50,0
.goto Felwood,43.40,48.20,50,0
.goto Felwood,42.60,50.20,50,0
.goto Felwood,39.60,54.00,50,0
.goto Felwood,40.80,59.80,50,0
.goto Felwood,40.80,66.00,50,0
.goto Felwood,40.20,68.60,50,0
.goto Felwood,38.80,71.60,50,0
.goto Felwood,41.60,71.60,50,0
.goto Felwood,42.00,67.80,50,0
.goto Felwood,40.80,66.00,50,0
.goto Felwood,40.80,59.80,50,0
.goto Felwood,39.60,54.00,50,0
.goto Felwood,41.20,50.60,50,0
.goto Felwood,38.60,49.60,50,0
.goto Felwood,43.40,48.20,50,0
>>Kill |cRXP_ENEMY_Tainted Oozes|r. Loot them for their |cRXP_LOOT_Bloodvenom Essence|r
>>|cRXP_WARN_Only|r |cRXP_ENEMY_Tainted Oozes|r |cRXP_WARN_can drop|r |cRXP_LOOT_Bloodvenom Essence|r
.complete 8421,2 
.mob Cursed Ooze
.mob Tainted Ooze
.isOnQuest 8421
step << Warlock
#phase 4-6
#loop
.goto Felwood,49.60,30.00,0
.goto Felwood,49.60,30.00,60,0
.goto Felwood,46.40,24.60,60,0
.goto Felwood,49.20,19.80,60,0
.goto Felwood,53.00,20.40,60,0
.goto Felwood,52.00,24.80,60,0
>>Kill |cRXP_ENEMY_Withered Protectors|, |cRXP_ENEMY_Irontree Stompers| and |cRXP_ENEMY_Irontree Wanderers|. Loot them for their |cRXP_LOOT_Rotting Wood|r
.complete 8421,1 
.mob Withered Protectors
.mob Irontree Stompers
.mob Irontree Wanderers
.isOnQuest 8421
step << Warlock
#phase 4-6
.goto Felwood,37.6,68.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Impsy|r
.turnin 8421 >>Turn in The Wrong Stuff
.accept 8422 >>Accept Trolls of a Feather
.target Impsy
.isQuestComplete 8421
step << Warlock
#phase 4-6
#label TrollsofaFeather
#optional
.goto Felwood,41.52,44.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Impsy|r
.accept 8422 >>Accept Trolls of a Feather
.target Impsy
.isQuestTurnedIn 8421
step
#completewith next
.zone Feralas >>Travel to |cFFfa9602Feralas|r
step
.goto Feralas,74.50,43.40
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Uzer'i|r
.accept 3380 >>Accept The Sunken Temple
.target Witch Doctor Uzer'i
step
#completewith StoneCircle
.zone Tanaris >>Travel to |cFFfa9602Tanaris|r
step
.goto Tanaris,66.989,22.354
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yeh'kinya|r
.accept 4787 >>Accept The Ancient Egg
.target Yeh'kinya
.isQuestTurnedIn 3527
step
#optional
.goto Tanaris,66.989,22.354
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yeh'kinya|r
.accept 3528 >>Accept The God Hakkar
.target Yeh'kinya
.isQuestTurnedIn 4787 
step
.goto Tanaris,52.70,45.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tReturn to |cRXP_FRIENDLY_Marvon|r
.turnin 3380 >>Turn in The Sunken Temple
.accept 3444 >>Accept The Stone Circle
.target Marvon Rivetseeker
.isOnQuest 3380
step
#optional
.goto Tanaris,52.70,45.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tReturn to |cRXP_FRIENDLY_Marvon|r
.accept 3444 >>Accept The Stone Circle
.target Marvon Rivetseeker
.isQuestTurnedIn 3380
step
#optional
.goto Tanaris,52.70,45.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marvon|r
.turnin 3444 >>Turn in The Stone Circle
.accept 3446 >>Accept Into the Depths
.accept 3447 >>Accept Secret of the Circle
.target Marvon Rivetseeker
.isQuestComplete 3444
step
#label StoneCircle
#optional
.goto Tanaris,52.707,45.923
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marvon Rivetseeker|r
.accept 3446 >>Accept Into the Depths
.accept 3447 >>Accept Secret of the Circle
.target Marvon Rivetseeker
.isQuestTurnedIn 3444
step
#completewith MarvonsWorkshop
.zone Un'Goro Crater >>Travel to |cFFfa9602Un'Goro Crater|r
step << Druid
#phase 4-6
.goto Un'Goro Crater,71.64,75.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Torwa|r
.accept 9052 >>Accept Bloodpetal Poison
.target Torwa Pathfinder
step << Druid
#phase 4-6
#loop
.goto Un'Goro Crater,51.74,75.36,0
.goto Un'Goro Crater,49.44,82.85,40,0
.goto Un'Goro Crater,50.35,79.55,50,0
.goto Un'Goro Crater,48.69,76.45,70,0
.goto Un'Goro Crater,47.58,81.58,70,0
.goto Un'Goro Crater,49.38,82.32,70,0
.goto Un'Goro Crater,52.38,84.31,70,0
.goto Un'Goro Crater,54.03,78.15,70,0
.goto Un'Goro Crater,51.74,75.36,70,0
>>Kill |cRXP_ENEMY_Gorishi Silithid|r. Loot them for |cRXP_LOOT_Gorishi Stings|r
.complete 9052,1 
.mob Gorishi Worker
.mob Gorishi Wasp
.mob Gorishi Reaver
.mob Gorishi Tunneler
.mob Gorishi Stinger
.mob Gorishi Hive Guard
step << Druid
#phase 4-6
.goto Un'Goro Crater,71.64,75.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Torwa|r
.turnin 9052 >>Turn in Bloodpetal Poison
.accept 9051 >>Accept Toxic Test
.target Torwa Pathfinder
.isQuestComplete 9052
step << Druid
#phase 4-6
#optional
.goto Un'Goro Crater,71.64,75.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Torwa|r
.accept 9051 >>Accept Toxic Test
.target Torwa Pathfinder
.isQuestTurnedIn 9052
step << Druid
#phase 4-6
>>Look for a |cRXP_ENEMY_Devilsaur|r or |cRXP_ENEMY_Ironhide Devilsaur|r. Avoid |cRXP_ENEMY_Tyrant Devilsaurs|r
>>|cRXP_WARN_You should be able to see their patrols on your map|r
>>|cRXP_WARN_The way you do this is spamming|r |T136090:0|t[Hibernate]|cRXP_WARN_. You should only spam|r |T136090:0|t[Hibernate] |cRXP_WARN_and nothing else. If it breaks early start spamming|r |T136090:0|t[Hibernate] |cRXP_WARN_again, they run with 170% movement speed so you can't outrun a|r |cRXP_ENEMY_Devilsaur|r
>>|cRXP_WARN_Use the|r |T135125:0|t[Devilsaur Barb] |cRXP_WARN_on it once it has been|r |T136090:0|t[Hibernated]
>>|cRXP_WARN_Shift into|r |T132144:0|t[Travel Form] |cRXP_WARN_and run away to reset it after|r
.complete 9051,1 
.use 22432 
.unitscan Devilsaur
.unitscan Ironhide Devilsaur
.isOnQuest 9051
step << Druid
#phase 4-6
.goto Un'Goro Crater,71.64,75.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Torwa|r
.turnin 9051 >>Turn in Toxic Test
.target Torwa Pathfinder
.isQuestComplete 9051
step << Druid
#phase 4-6
#label ABetterIngredient
.goto Un'Goro Crater,71.639,75.960
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Torwa|r
.accept 9053 >>Accept A Better Ingredient
.target Torwa Pathfinder
.isQuestTurnedIn 9051
step
.goto Un'Goro Crater,45.53,8.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Larion|r
.accept 4145 >>Accept Larion and Muigin
.target Larion
step
#loop
.goto Un'Goro Crater,57.60,36.80,0
.goto Un'Goro Crater,57.60,36.80,60,0
.goto Un'Goro Crater,64.40,30.80,60,0
.goto Un'Goro Crater,68.20,24.00,60,0
.goto Un'Goro Crater,71.20,31.00,60,0
.goto Un'Goro Crater,74.20,39.60,60,0
.goto Un'Goro Crater,76.00,47.40,60,0
.goto Un'Goro Crater,74.20,39.60,60,0
.goto Un'Goro Crater,69.40,38.00,60,0
.goto Un'Goro Crater,66.60,35.60,60,0
.goto Un'Goro Crater,60.00,39.40,60,0
>>Kill |cRXP_ENEMY_Bloodpetal Threshers|r, |cRXP_ENEMY_Bloodpetal Lashers|r and |cRXP_ENEMY_Bloodpetal Flayers|r
>>|cRXP_WARN_Their poison deals high damage and they can disarm|r << Warrior/Rogue/Shaman
>>|cRXP_WARN_Their poison deals high damage and drains mana|r << !Warrior !Rogue !Shaman
.complete 4145,4 
.mob +Bloodpetal Thresher
.complete 4145,1 
.mob +Bloodpetal Lasher
.complete 4145,3 
.mob +Bloodpetal Flayer
.isOnQuest 4145
step
#label BloodpetalTrappers
#loop
.goto Un'Goro Crater,31.16,31.18,0
.goto Un'Goro Crater,31.16,31.18,60,0
.goto Un'Goro Crater,40.68,31.29,60,0
.goto Un'Goro Crater,41.51,39.52,60,0
.goto Un'Goro Crater,41.05,43.46,60,0
.goto Un'Goro Crater,39.34,51.44,60,0
.goto Un'Goro Crater,29.37,43.13,60,0
>>Kill |cRXP_ENEMY_Bloodpetal Trappers|r
>>|cRXP_WARN_Their poison deals high damage, and they can cast entangling roots|r << Warrior/Rogue/Shaman
>>|cRXP_WARN_Their poison deals high damage and drains mana. They can cast entangling roots|r << !Warrior !Rogue !Shaman
.complete 4145,2 
.mob Bloodpetal Trapper
.isOnQuest 4145
step
.goto Un'Goro Crater,45.53,8.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Larion|r
.turnin 4145 >>Turn in Larion and Muigin
.accept 4147 >>Accept Marvon's Workshop
.target Larion
.isQuestComplete 4145
step
#label MarvonsWorkshop
#optional
.goto Un'Goro Crater,45.53,8.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Larion|r
.accept 4147 >>Accept Marvon's Workshop
.target Larion
.isQuestTurnedIn 4145
step
#completewith ZapperFuel
.subzone 392 >>Travel to |cFFfa9602Ratchet|r in The Barrens
step
.goto The Barrens,62.50,38.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Liv|r
.turnin 4147 >>Turn in Marvon's Workshop
.accept 4146 >>Accept Zapper Fuel
.target Liv Rizzlefix
.isOnQuest 4147
step
#optional
.goto The Barrens,62.50,38.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Liv|r
.accept 4146 >>Accept Zapper Fuel
.target Liv Rizzlefix
.isQuestTurnedIn 4147
step
#label ZapperFuel
.goto The Barrens,62.50,38.60
>>Loot |cRXP_PICK_Marvon's Chest|r outside of the building for the |cRXP_LOOT_Stone Circle|r
.complete 3444,1 
step
#completewith TanarisPickups
.zone Tanaris >>Travel to |cFFfa9602Tanaris|r
step
.goto Tanaris,52.70,45.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marvon|r
>>|cRXP_WARN_Skip this for now if you intend to do "The Ancient Egg"|r
.turnin 3444 >>Turn in The Stone Circle
.accept 3446 >>Accept Into the Depths
.accept 3447 >>Accept Secret of the Circle
.target Marvon Rivetseeker
.isQuestComplete 3444
step
#label TanarisPickups
#optional
.goto Tanaris,52.707,45.923
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marvon Rivetseeker|r
>>|cRXP_WARN_Skip this for now if you intend to do "The Ancient Egg"|r
.accept 3446 >>Accept Into the Depths
.accept 3447 >>Accept Secret of the Circle
.target Marvon Rivetseeker
.isQuestTurnedIn 3444
step
#completewith TheAtalExile
.zone Swamp of Sorrows >>Travel to |cFFfa9602Swamp of Sorrows|r
step
.goto Swamp of Sorrows,47.80,55.20
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Fel'zerul|r on the top floor of the large building
.accept 1424 >>Accept Pool of Tears
.target Fel'zerul
step
#loop
.goto Swamp of Sorrows,75.44,60.41,0
.goto Swamp of Sorrows,75.44,60.41,50,0
.goto Swamp of Sorrows,71.14,61.44,50,0
.goto Swamp of Sorrows,65.36,57.19,50,0
.goto Swamp of Sorrows,65.99,47.10,50,0
.goto Eastern Kingdoms,53.87,79.26,50,0
.goto Swamp of Sorrows,70.57,46.04,50,0
.goto Swamp of Sorrows,75.03,50.83,50,0
>>Loot the |cRXP_LOOT_Atal'ai Artifacts|r scattered all around the Pool of Tears' shore, or at the bottom of the Pool of Tears itself
>>|cRXP_WARN_The artifacts have different models. Open your menu, click System, then Graphics, then adjust the Environmental Clutter slider (at the very bottom) to 0|r
.complete 1424,1 
.isOnQuest 1424
step
.goto Swamp of Sorrows,48.00,54.90
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tReturn to |cRXP_FRIENDLY_Fel'zerul|r in Stonard
.turnin 1424 >>Turn in Pool of Tears
.accept 1429 >>Accept The Atal'ai Exile
.target Fel'zerul
.isQuestComplete 1424
step
#label TheAtalExile
#optional
.goto Swamp of Sorrows,48.00,54.90
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tReturn to |cRXP_FRIENDLY_Fel'zerul|r in Stonard
.accept 1429 >>Accept The Atal'ai Exile
.target Fel'zerul
.isQuestTurnedIn 1424
step << Shaman
#phase 4-6
#completewith SpiritTotem
.zone Alterac Mountains >>Travel to |cFFfa9602Alterac Mountains|r
step << Shaman
#phase 4-6
.goto Alterac Mountains,80.50,66.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bath'rah|r
.turnin 8410 >>Turn in Elemental Mastery
.accept 8412 >>Accept Spirit Totem
.target Bath'rah the Windwatcher
.isOnQuest 8410
step << Shaman
#phase 4-6
#label SpiritTotem
#optional
.goto Alterac Mountains,80.50,66.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bath'rah|r
.accept 8412 >>Accept Spirit Totem
.target Bath'rah the Windwatcher
.isOnQuest 8410
step << Shaman
#phase 4-6
#completewith next
.zone Western Plaguelands >>Travel north to Western Plaguelands
>>|cRXP_WARN_Be careful of Chillwind Camp (small Alliance camp)! Swim across the water to avoid it|r
step << Shaman
#phase 4-6
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
.isOnQuest 8412
step << Shaman
#phase 4-6
#completewith DaVoodoo
.zone Alterac Mountains >>Travel to |cFFfa9602Alterac Mountains|r
step << Shaman
#phase 4-6
.goto Alterac Mountains,80.50,66.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bath'rah|r
.turnin 8412 >>Turn in Spirit Totem
.accept 8413 >>Accept Da Voodoo
.target Bath'rah the Windwatcher
.isQuestComplete 8412
step << Shaman
#phase 4-6
#label DaVoodoo
#optional
.goto Alterac Mountains,80.50,66.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bath'rah|r
.accept 8413 >>Accept Da Voodoo
.target Bath'rah the Windwatcher
.isQuestTurnedIn 8412
step
#completewith AncientEgg
.zone The Hinterlands >>Travel to |cFFfa9602The Hinterlands|r
step
.goto The Hinterlands,33.751,75.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Atal'ai Exile|r
.turnin 1429 >>Turn in The Atal'ai Exile
.accept 1444 >>Accept Return to Fel'Zerul
.accept 1446 >>Accept Jammal'an the Prophet
.target Atal'ai Exile
.isOnQuest 1429
step
#optional
.goto The Hinterlands,33.751,75.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Atal'ai Exile|r
.accept 1444 >>Accept Return to Fel'Zerul
.accept 1446 >>Accept Jammal'an the Prophet
.target Atal'ai Exile
.isQuestTurnedIn 1429
step
#optional
.goto The Hinterlands,33.751,75.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Atal'ai Exile|r
.accept 1446 >>Accept Jammal'an the Prophet
.target Atal'ai Exile
step
#label AncientEgg
.goto The Hinterlands,57.60,86.79
>>Loot the |cRXP_LOOT_Ancient Egg|r in the cave in Jintha'alor
>>|cRXP_WARN_You will have to kill many elites, make sure you have a group ready|r << !tbc !wotlk
.complete 4787,1 
.isOnQuest 4787
step
#completewith GodofHakkar
.zone Tanaris >>Travel to |cFFfa9602Tanaris|r
step
.goto Tanaris,66.989,22.354
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yeh'kinya|r
.turnin 4787 >>Turn in The Ancient Egg
.accept 3528 >>Accept The God Hakkar
.target Yeh'kinya
.isQuestComplete 4787
step
.goto Tanaris,66.989,22.354
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yeh'kinya|r
.accept 3528 >>Accept The God Hakkar
.target Yeh'kinya
.isQuestTurnedIn 4787 
step
.goto Tanaris,52.70,45.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marvon|r
.turnin 3444 >>Turn in The Stone Circle
.accept 3446 >>Accept Into the Depths
.accept 3447 >>Accept Secret of the Circle
.target Marvon Rivetseeker
.isQuestComplete 3444
step
#label GodofHakkar
#optional
.goto Tanaris,52.707,45.923
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Marvon Rivetseeker|r
.accept 3446 >>Accept Into the Depths
.accept 3447 >>Accept Secret of the Circle
.target Marvon Rivetseeker
.isQuestTurnedIn 3444
step
#completewith TempleofAtalHakkar
.zone Swamp of Sorrows >>Travel to |cFFfa9602Swamp of Sorrows|r
step
.goto Swamp of Sorrows,47.90,55.00
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Fel'zerul|r
.turnin 1444 >>Turn in Return to Fel'Zerul
.accept 1445 >>Accept The Temple of Atal'Hakkar
.target Fel'zerul
.isOnQuest 1444
step
#optional
#label TempleofAtalHakkar
.goto Swamp of Sorrows,47.93,54.79
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Fel'zerul|r
.accept 1445 >>Accept The Temple of Atal'Hakkar
.isQuestTurnedIn 1444
step << Warrior
#phase 4-6
.goto Swamp of Sorrows,34.20,66.00
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Fallen Hero of the Horde|r
.turnin 8417 >>Turn in A Troubled Spirit
.accept 8423 >>Accept Warrior Kinship
.target Fallen Hero of the Horde
step << Warrior
#phase 4-6
#completewith next
.zone Blasted Lands >>Travel to |cFFfa9602Blasted Lands|r
step << Warrior
#phase 4-6
#loop
.goto Blasted Lands,53.60,37.20,0
.goto Blasted Lands,53.60,37.20,60,0
.goto Blasted Lands,54.60,41.40,60,0
.goto Blasted Lands,55.60,43.20,60,0
.goto Blasted Lands,52.80,41.80,60,0
.goto Blasted Lands,50.20,38.60,60,0
.goto Blasted Lands,48.00,37.60,60,0
.goto Blasted Lands,46.60,40.20,60,0
.goto Blasted Lands,44.60,37.00,60,0
.goto Blasted Lands,44.60,33.80,60,0
.goto Blasted Lands,48.00,34.40,60,0
.goto Blasted Lands,50.80,36.00,60,0
>>Kill |cRXP_ENEMY_Helboars|r in the Blasted Lands
.complete 8423,1 
.mob Helboar
.isOnQuest 8423
step << Warrior
#phase 4-6
.goto Swamp of Sorrows,34.20,66.00
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Fallen Hero of the Horde|r
.turnin 8423 >>Turn in Warrior Kinship
.accept 8424 >>Accept War on the Shadowsworn
.target Fallen Hero of the Horde
.isQuestComplete 8423
step << Warrior
#phase 4-6
#optional
.goto Swamp of Sorrows,34.20,66.00
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Fallen Hero of the Horde|r
.accept 8424 >>Accept War on the Shadowsworn
.target Fallen Hero of the Horde
.isQuestTurnedIn 8423
step << Warrior
#phase 4-6
#completewith next
.zone Blasted Lands >>Travel to |cFFfa9602Blasted Lands|r
step << Warrior
#phase 4-6
#loop
.goto Blasted Lands,62.40,39.40,0
.goto Blasted Lands,62.40,39.40,50,0
.goto Blasted Lands,62.40,43.00,50,0
.goto Blasted Lands,64.60,47.80,50,0
.goto Blasted Lands,64.00,45.60,50,0
.goto Blasted Lands,63.60,42.60,50,0
.goto Blasted Lands,63.60,39.20,50,0
>>Kill |cRXP_ENEMY_Shadowsworn Adepts|r, |cRXP_ENEMY_Shadowsworn Cultists|r and |cRXP_ENEMY_Shadowsworn Thugs|r
.complete 8424,1 
.mob +Shadowsworn Adept
.complete 8424,2 
.mob +Shadowsworn Cultist
.complete 8424,3 
.mob +Shadowsworn Thug
.isOnQuest 8424
step << Warrior
#phase 4-6
.goto Swamp of Sorrows,34.287,66.134
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Fallen Hero of the Horde|r
.turnin 8424 >> Turn in War on the Shadowsworn
.accept 8425 >> Accept Voodoo Feathers
.target Fallen Hero of the Horde
.isQuestComplete 8425
step << Warrior
#phase 4-6
#label VoodooFeathers
#optional
.goto Swamp of Sorrows,34.287,66.134
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Fallen Hero of the Horde|r
.accept 8425 >>Accept Voodoo Feathers
.target Fallen Hero of the Horde
.isQuestTurnedIn 8424
step
#label DungeonTime
.goto 1415,56.33,76.28
.subzone 1477 >> Travel to Sunken Temple
step
#completewith next
>>Kill |cRXP_ENEMY_Atal'ai Trolls|r in the Sunken Temple. Loot them for their |cRXP_LOOT_Fetish of Hakkar|r
>>|cRXP_WARN_The trolls outside as well as inside Sunken Temple can drop these|r
.complete 1445,1 
.isOnQuest 1445
step
#label EnterST
.goto 1415,56.33,76.28,40,0
.goto 1415,56.46,75.54,20,0
.goto 1415,56.83,75.86,20,0
.goto 1415,56.94,76.03,15,0
.goto 1415,57.06,75.58,20,0
.goto 1415,56.76,75.35,15,0
.goto 1415,56.809,75.151
.subzone 1477,2 >> Zone into Sunken Temple
step
#sticky
>>Kill |cRXP_ENEMY_Atal'ai Trolls|r in the Sunken Temple. Loot them for their |cRXP_LOOT_Fetish of Hakkar|r
.complete 1445,1 
.isOnQuest 1445
step
#sticky
>>Kill |cRXP_ENEMY_Deep Lurkers|r, |cRXP_ENEMY_Murk Worms|r and |cRXP_ENEMY_Saturated Oozes|r. Loot them for their |cRXP_LOOT_Atal'ai Haze|r
>>|cRXP_WARN_Take a right down the stairs at the beginning of the instance to find these mobs|r
.complete 4146,1 
.isOnQuest 4146
step << Druid
#phase 4-6
#completewith Altar
>>Kill |cRXP_ENEMY_Atal'alarion|r. Loot him for the |cRXP_LOOT_Putrid Vine|r
>>|cRXP_ENEMY_Atal'alarion|r |cRXP_WARN_is on the lower level of Sunken Temple and is summoned by clicking all |cRXP_PICK_Atal'ai Statues|r on the platforms|r
.complete 9053,1 
.isOnQuest 9053
step 
#completewith next
>>Click on the |cRXP_PICK_Altar of Hakkar|r
>>|cRXP_WARN_The |cRXP_PICK_Altar of Hakkar|r is located on the lower level of Sunken Temple|r
.turnin 3446 >> Turn in Into the Depths
.isOnQuest 3446
step 
>>Click on the |cRXP_PICK_Idol of Hakkar|r
>>|cRXP_WARN_Clicking all of the |cRXP_PICK_Atal'ai Statues|r on the platforms will activate the|r |cRXP_PICK_Idol of Hakkar|r
>>|cRXP_WARN_The |cRXP_PICK_Idol of Hakkar|r is located on the lower level of Sunken Temple|r
.turnin 3447 >> Turn in Secret of the Circle
.isOnQuest 3447
step 
#label Altar
>>Click on the |cRXP_PICK_Altar of Hakkar|r
>>|cRXP_WARN_The |cRXP_PICK_Altar of Hakkar|r is located on the lower level of Sunken Temple|r
.turnin 3446 >> Turn in Into the Depths
.isOnQuest 3446
step << Druid
#phase 4-6
>>Kill |cRXP_ENEMY_Atal'alarion|r. Loot him for the |cRXP_LOOT_Putrid Vine|r
>>|cRXP_ENEMY_Atal'alarion|r |cRXP_WARN_is on the lower level of Sunken Temple and is summoned by clicking all |cRXP_PICK_Atal'ai Statues|r on the platforms|r
.complete 9053,1 
.isOnQuest 9053
step << Shaman/Warrior/Warlock
#phase 4-6
>>Kill |cRXP_ENEMY_Gasher|r and |cRXP_ENEMY_Zul'Lor|r. Loot them for their |cRXP_LOOT_Amber Voodoo Feathers|r
>>Kill |cRXP_ENEMY_Mijan|r and |cRXP_ENEMY_Hukku|r. Loot them for their |cRXP_LOOT_Blue Voodoo Feathers|r
>>Kill |cRXP_ENEMY_Zolo|r and |cRXP_ENEMY_Loro|r. Loot them for their |cRXP_LOOT_Green Voodoo Feathers|r
>>|cRXP_WARN_This quest is completed on the upper level of Sunken Temple|r
.complete 8413,1 << Shaman 
.complete 8413,2 << Shaman 
.complete 8413,3 << Shaman 
.complete 8425,1 << Warrior 
.complete 8425,2 << Warrior 
.complete 8425,3 << Warrior 
.complete 8422,1 << Warlock 
.complete 8422,2 << Warlock 
.complete 8422,3 << Warlock 
.isOnQuest 8413 << Shaman
.isOnQuest 8425 << Warrior
.isOnQuest 8422 << Warlock
step
>>|cRXP_WARN_Use the|r |T132834:0|t[Egg of Hakkar] |cRXP_WARN_while next to the Dragonflayer Skeleton, then complete the event|r
>>Kill the minions of |cRXP_ENEMY_Hakkar|r until the |cRXP_ENEMY_Avatar of Hakkar|r joins
>>Kill the |cRXP_ENEMY_Avatar of Hakkar|r. Loot it for the |T136148:0|t[|cRXP_LOOT_Essence of Hakkar|r]
>>|cRXP_WARN_Use the|r |T136148:0|t[|cRXP_LOOT_Essence of Hakkar|r] |cRXP_WARN_to fill the|r |T132834:0|t[Egg of Hakkar]
.collect 10663,1,3528,1 
.disablecheckbox
.complete 3528,1 
.use 10465 
.use 10663 
.isOnQuest 3528
step
>>Kill |cRXP_ENEMY_Jammal'an the Prophet|r. Loot him for his |cRXP_LOOT_Head|r
>>|cRXP_WARN_You must kill the 6 |cRXP_ENEMY_Trolls|r on the upper platforms to gain access to|r |cRXP_ENEMY_Jammal'an the Prophet|r
.complete 1446,1 
.isOnQuest 1446
step << Hunter/Mage/Priest/Rogue
#phase 4-6
>>Kill |cRXP_ENEMY_Morphaz|r. Loot it for the |cRXP_LOOT_Tooth of Morphaz|r << Hunter
>>Kill |cRXP_ENEMY_Morphaz|r. Loot it for the |cRXP_LOOT_Arcane Shard|r << Mage
>>Kill |cRXP_ENEMY_Morphaz|r. Loot it for the |cRXP_LOOT_Blood of Morphaz|r << Priest
>>Kill |cRXP_ENEMY_Morphaz|r. Loot it for the |cRXP_LOOT_Azure Key|r << Rogue
.complete 8232,1 << Hunter 
.complete 8253,1 << Mage 
.complete 8257,1 << Priest 
.complete 8236,1 << Rogue 
.isOnQuest 8232 << Hunter
.isOnQuest 8253 << Mage
.isOnQuest 8257 << Priest
.isOnQuest 8236 << Rogue
step
>>Kill the |cRXP_ENEMY_Shade of Eranikus|r. Loot him for the |T135229:0|t[|cRXP_LOOT_Essence of Eranikus|r]
>>|cRXP_WARN_Use the |T135229:0|t[|cRXP_LOOT_Essence of Eranikus|r] to start the quest|r
>>|cRXP_WARN_Ensure you have killed all |cRXP_ENEMY_Dragonkin|r mobs on the upper level before engaging the |cRXP_ENEMY_Shade of Eranikus|r otherwise they will all agro onto you|r
.collect 10454,1,3373,1 
.accept 3373 >> Accept The Essence of Eranikus
step
>>Click the |cRXP_PICK_Essence Font|r
.turnin 3373 >> Turn in The Essence of Eranikus
.isOnQuest 3373
step
.zone Swamp of Sorrows >>Leave the Sunken Temple Instance
step
.goto Swamp of Sorrows,47.93,54.79
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Fel'zerul|r
.turnin 1445 >>Turn in The Temple of Atal'Hakkar
.isQuestComplete 1445
step << Warrior
#phase 4-6
.goto Swamp of Sorrows,34.287,66.134
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Fallen Hero of the Horde|r
>>|cRXP_WARN_It is strongly advised you choose the|r |T132788:0|t[|cFF0070FFDiamond Flask|r] |cRXP_WARN_as your reward. Although the other rewards are also very good, you will not ever replace the|r |T132788:0|t[|cFF0070FFDiamond Flask|r]
.turnin 8425 >>Turn in Voodoo Feathers
.target Fallen Hero of the Horde
.isQuestComplete 842
step << Shaman
#phase 4-6
#completewith next
.zone Alterac Mountains >>Travel to |cFFfa9602Alterac Mountains|r
step << Shaman
#phase 4-6
.goto Alterac Mountains,80.50,66.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bath'rah|r
.turnin 8413 >> Turn in Da Voodoo
.target Bath'rah the Windwatcher
.isQuestComplete 8413
step
#completewith next
.zone The Hinterlands >>Travel to |cFFfa9602The Hinterlands|r
step
.goto The Hinterlands,33.751,75.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Atal'ai Exile|r
.turnin 1446 >> Turn in Jammal'an the Prophet
.target Atal'ai Exile
.isQuestComplete 1446
step << Hunter/Priest/Mage/Rogue
#phase 4-6
#completewith AzsharaTurnin
.zone Azshara >>Travel to |cFFfa9602Azshara|r
step << Hunter/Priest
#label AzsharaTurnin
#phase 4-6
.goto Azshara,42.400,42.619
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ogtinc|r
.turnin 8232 >> Turn in The Green Drake << Hunter
.turnin 8257 >> Turn in Blood of Morphaz << Priest
.target Ogtinc
.isQuestComplete 8232 << Hunter
.isQuestComplete 8257 << Priest
step << Mage/Rogue
#phase 4-6
#completewith AzsharaTurnin
.goto Azshara,28.113,50.088
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sanath Lim-yo|r
>>|cRXP_WARN_This will teleport you to the top of the mountain|r
.turnin 3503 >> Turn in Meeting with the Master
.target Sanath Lim-yo
step << Mage/Rogue
#label AzsharaTurnin
#phase 4-6
.goto Azshara,29.248,40.210
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Archmage Xylem|r atop the Tower
.turnin 8253 >> Turn in Destroy Morphaz << Mage
.turnin 8236 >> Turn in The Azure Key << Rogue
.target Archmage Xylem
.isQuestComplete 8253 << Mage
.isQuestComplete 8236 << Rogue
step << Warlock
#phase 4-6
#completewith next
.zone Felwood >>Travel to |cFFfa9602Felwood|r
step << Warlock
#phase 4-6
.goto Felwood,41.52,44.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Impsy|r
.turnin 8422 >> Turn in Trolls of a Feather
.target Impsy
.isQuestComplete 8422
step
#completewith next
.zone Tanaris >>Travel to |cFFfa9602Tanaris|r
step
.goto Tanaris,66.989,22.354
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yeh'kinya|r
.turnin 3528 >> Turn in The God Hakkar
.target Yeh'kinya
.isQuestComplete 3528
step
#completewith BetterIngredientTI << Druid
#completewith next << !Druid
.zone Un'Goro Crater >>Travel to |cFFfa9602Un'Goro Crater|r
step
.goto Un'Goro Crater,45.53,8.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Larion|r
.turnin 4146 >>Turn in Zapper Fuel
.target Larion
.isQuestComplete 4146
step << Druid
#label BetterIngredientTI
#phase 4-6
.goto Un'Goro Crater,71.639,75.960
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Torwa Pathfinder|r
.turnin 9053 >>Turn in A Better Ingredient
.target Torwa Pathfinder
.isQuestComplete 9053
step
+|cRXP_WARN_This is the end of the Sunken Temple guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 50-60
<< Horde
#name 113 Blackrock Depths
#displayname 13. Blackrock Depths
step
#completewith KargathBRDQuests
+You will now begin to collect quests for Blackrock Depths
>>Blackrock Depths is a very convoluted dungeon. In order to complete all quests in the most efficient way, it is required to leave the dungeon midrun to turn in/accept follow up quests so it may all be completed in 1 run
>>|cRXP_WARN_Try to ensure all party members have the same quests and prequests complete, along with 2-3 hours of playtime|r
step
.goto Badlands,3.77,47.47
>>Click the |cRXP_PICK_Wanted Poster|r
.accept 4081 >> Accept KILL ON SIGHT: Dark Iron Dwarves
step
.goto Badlands,3.31,48.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thunderheart|r
>>|cRXP_FRIENDLY_Thunderheart|r|cRXP_WARN_might be patrolling around the mountain at Kargath. Find him or wait for him to return|r
.accept 3906 >> Accept Disharmony of Flame
.unitscan Thunderheart
step
.goto Badlands,2.90,47.76
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vivian|r
>>|cRXP_FRIENDLY_Vivian|r|cRXP_WARN_might be patrolling around the mountain near Kargath. Find her or wait for her to return|r
.accept 7201 >> Accept The Last Element
.accept 4134 >> Accept Lost Thunderbrew Recipe
.unitscan Shadowmage Vivian Lagrave
.isQuestTurnedIn 3906 
step
#optional
.goto Badlands,2.90,47.76
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vivian|r
>>|cRXP_FRIENDLY_Vivian|r|cRXP_WARN_might be patrolling around the mountain near Kargath. Find her or wait for her to return|r
.accept 4134 >> Accept Lost Thunderbrew Recipe
.unitscan Shadowmage Vivian Lagrave
step
#label KargathBRDQuests
.goto Badlands,3.03,47.80
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hierophant Theodora Mulvadania|r
.accept 4061 >> Accept The Rise of the Machines
.target Hierophant Theodora Mulvadania
step
#completewith next
+|cRXP_WARN_Set your hearthstone to Kargath if you have a mage in your group!|r
step
.goto Badlands,3.98,44.76
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gorrik|r
.fly Flame Crest >> Fly to Flame Crest
.target Gorrik
.zoneskip Burning Steppes
step
.goto Burning Steppes,65.152,23.911
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Maxwort Uberglint|r
.accept 4123 >> Accept The Heart of the Mountain
.target Maxwort Uberglint
step
.goto Burning Steppes,66.058,21.951
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yuka Screwspigot|r
.accept 4136 >> Accept Ribbly Screwspigot
.target Yuka Screwspigot
step
#loop
.goto Burning Steppes,67.37,44.38,0
.goto Burning Steppes,62.74,34.92,60,0
.goto Burning Steppes,57.43,36.36,60,0
.goto Burning Steppes,53.03,39.25,60,0
.goto Burning Steppes,59.19,40.17,60,0
.goto Burning Steppes,63.33,43.19,60,0
.goto Burning Steppes,67.37,44.38,60,0
>>Kill |cRXP_ENEMY_War Reavers|r. Loot them for their |cRXP_LOOT_Shards|r
>>|cRXP_WARN_Completing this will unlock an optional BRD quest. It can be skipped|r
.complete 4061,1 
.mob War Reaver
step
.goto Burning Steppes,95.061,31.563
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Cyrus Therepentous|r
>>Select the option: "I present you with proof of my deeds, Cyrus."
.accept 4022 >> Accept A Taste of Flame
.turnin 4022 >> Turn in A Taste of Flame
.itemcount 10575,1 
.target Cyrus Therepentous
.isQuestTurnedIn 3481
step
.goto Burning Steppes,95.061,31.563
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Cyrus Therepentous|r
>>If you are missing the |T134430:0|t[Black Dragonflight Molt] and cannot complete the quest, talk to |cRXP_FRIENDLY_Cyrus|r and select the option: "I do not possess any proof, Cyrus."
>>This will spawn a level 54 Elite Dragon at the entrance of the small cave. Ensure you have party members with you to help kill it, then loot it for the |T134430:0|t[Black Dragonflight Molt]
>>Select the option after: "I present you with proof of my deeds, Cyrus."
.collect 10575,1,4022,1 
.accept 4022 >> Accept A Taste of Flame
.turnin 4022 >> Turn in A Taste of Flame
.target Cyrus Therepentous
.isQuestAvailable 4022
step
.goto Burning Steppes,95.061,31.563
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Cyrus Therepentous|r
.accept 4024 >> Accept A Taste of Flame
.target Cyrus Therepentous
.isQuestTurnedIn 4022
step
#completewith CoreAttunement
.subzone 25 >> Travel to Blackrock Mountain
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
.cast 417803 >>|cRXP_WARN_Click the |cRXP_PICK_Brazier of Embersight|r to gain the|r |T136215:0|t[Emberglow Vision] |cRXP_WARN_debuff|r
step
#hardcoreserver
.goto 1415,48.624,64.186
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Franclorn Forgewright|r
>>|cRXP_WARN_You must have the|r |T136215:0|t[Emberglow Vision] |cRXP_WARN_debuff to see him|r
.accept 3801 >> Accept Dark Iron Legacy
.turnin 3801 >> Turn in Dark Iron Legacy
.accept 3802 >> Accept Dark Iron Legacy
.target Franclorn Forgewright
step
#label CoreAttunement
.goto 1415,48.409,63.815
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lothos Riftwaker|r
.accept 7848 >> Accept Attunement to the Core
.target Lothos Riftwaker
step
>>Kill |cRXP_ENEMY_Overmaster Pyron|r
>>|cRXP_ENEMY_Overmaster Pyron|r |cRXP_WARN_patrols outside of the BRD instance portal|r
.complete 3906,1 
.mob Overmaster Pyron
.isOnQuest 3906
step
#label EnterBRD1
.subzone 1584 >>Enter the Blackrock Depths instance
step
>>Kill |cRXP_ENEMY_Anvilrage Dwarves|r
.complete 4081,1 
.mob +Anvilrage Guardsman
.complete 4081,2 
.mob +Anvilrage Warden
.complete 4081,3 
.mob +Anvilrage Footman
.isOnQuest 4081
step
#completewith next
+Travel back to Kargath
step
.goto Badlands,3.31,48.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thunderheart|r
>>|cRXP_FRIENDLY_Thunderheart|r|cRXP_WARN_might be patrolling around the mountain at Kargath. Find him or wait for him to return|r
.turnin 3906 >> Turn in Disharmony of Flame
.unitscan Thunderheart
.isQuestComplete 3906
step
.goto Badlands,3.31,48.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thunderheart|r
>>|cRXP_FRIENDLY_Thunderheart|r|cRXP_WARN_might be patrolling around the mountain at Kargath. Find him or wait for him to return|r
.accept 3907 >> Accept Disharmony of Fire
.unitscan Thunderheart
.isQuestTurnedIn 3906
step
.goto Badlands,3.03,47.80
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hierophant Theodora Mulvadania|r
.turnin 4061 >> Turn in The Rise of the Machines
.target Hierophant Theodora Mulvadania
.isQuestComplete 4061
step
.goto Badlands,3.03,47.80
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hierophant Theodora Mulvadania|r
.accept 4062 >> Accept The Rise of the Machines
.target Hierophant Theodora Mulvadania
.isQuestTurnedIn 4061
step
.goto Badlands,5.81,47.52
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Warlord Goretooth|r
.turnin 4081 >> Turn in KILL ON SIGHT: Dark Iron Dwarves
.target Warlord Goretooth
.isQuestComplete 4081
step
.goto Badlands,5.96,47.73
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Galamav the Marksman|r on top of the tower
.accept 3981 >> Accept Commander Gor'shak
.target Galamav the Marksman
.isQuestTurnedIn 3906
step
.goto Badlands,3.97,46.77
>>Click the |cRXP_PICK_Wanted Poster|r
.accept 4082 >> Accept KILL ON SIGHT: High Ranking Dark Iron Officials
.isQuestTurnedIn 4081
step
.goto Badlands,25.95,44.86
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lotwil Veriatus|r
.turnin 4062 >> Turn in The Rise of the Machines
.accept 4063 >> Accept The Rise of the Machines
.target Lotwil Veriatus
.isQuestTurnedIn 4061
step
#label EnterBRD2
.subzone 1584 >>Return to Blackrock Mountain and enter the Blackrock Depths instance
step
#completewith WhatsGoingOn
>>Kill |cRXP_ENEMY_Fire Elementals|r and |cRXP_ENEMY_Golems|r. Loot them for their |cRXP_LOOT_Essence of the Elements|r
>>|cRXP_WARN_This quest does not need to be completed now|r
.complete 7201,1 
.isOnQuest 7201
step
#completewith next
+Complete the Ring of Law boss event, then take the exit up the tunnel and immediately turn right, crossing up over the top of the Ring of Law, making your way to the Vault
step
>>Loot |cRXP_LOOT_The Heart of the Mountain|r inside of the safe wall. It takes 15 seconds for it to respawn
>>There is a trick which allows you to loot it without having to open the safe. View the link below to see how it is done
.complete 4123,1 
.link https://youtu.be/694e1n_aiKY >> Click here to see how to loot the Heart of the Mountain
.isOnQuest 4123
step
>>Kill |cRXP_ENEMY_Fineous Darkvire|r. Loot him for the |cRXP_LOOT_Ironfel|r
.complete 3802,1 
.target Fineous Darkvire
.isOnQuest 3802
step
>>Kill |cRXP_ENEMY_Lord Incendius|r
.complete 3907,1 
.target Lord Incendius
.isOnQuest 3907
step
>>Run back near the location above the Ring of Law
>>Click the |cRXP_PICK_Monument of Franclorn Forgewright|r
.turnin 3802 >> Turn in Dark Iron Legacy
.isQuestComplete 3802
step
#completewith next
>>Kill |cRXP_ENEMY_Anvilrage Dwarves|r
.complete 4082,1 
.mob +Anvilrage Medic
.complete 4082,2 
.mob +Anvilrage Soldier
.complete 4082,3 
.mob +Anvilrage Officer
.isOnQuest 4082
step
>>Head to the Shadowforge Gates at the start of the entrance
>>Kill |cRXP_ENEMY_Bael'Gar|r
.use 11231 >>|cRXP_WARN_Use the|r |T134430:0|t[Altered Black Dragonflight Molt] |cRXP_WARN_on his corpse|r
.complete 4024,1 
.mob Bael'Gar
.isOnQuest 4024
step
>>Finish killing |cRXP_ENEMY_Anvilrage Dwarves|r
.complete 4082,1 
.mob +Anvilrage Medic
.complete 4082,2 
.mob +Anvilrage Soldier
.complete 4082,3 
.mob +Anvilrage Officer
.isOnQuest 4082
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Gor'shak|r
>>If your group does not have a Rogue you may need to kill |cRXP_ENEMY_High Interrogator Gerstahn|r for the |cRXP_LOOT_Prison Cell Key|r to open the doors
>>|cRXP_WARN_ENSURE ALL PARTY MEMBERS HAVE AUTO ACCEPT OFF FOR THIS STEP! RestedXP HAS AUTO ACCEPT OFF FOR THIS STEP|r
.turnin 3981 >> Turn in Commander Gor'shak
.accept 3982,1 >> Accept What Is Going On?
.target Commander Gor'shak
step
>>Defend |cRXP_FRIENDLY_Commander Gor'shak|r from the incoming |cRXP_ENEMY_Anvilrage Dwarves|r
.complete 3982,1 
.target Commander Gor'shak
.isQuestTurnedIn 3981
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Gor'shak|r
.turnin 3982 >> Turn in What Is Going On?
.accept 4001 >> Accept What Is Going On?
.target Commander Gor'shak
.isQuestTurnedIn 3981
step
#label WhatsGoingOn
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kharan Mighthammer|r and listen to his story
>>|cRXP_WARN_He is located accross the hall from|r |cRXP_FRIENDLY_Commander Gor'shak|r
.complete 4001,1 
.target Kharan Mighthammer
.skipgossip
.isQuestTurnedIn 3981
step
#completewith RoyalResc
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thrall|r
.turnin 4001 >> Turn in What Is Going On?
.accept 4002 >> Accept The Eastern Kingdoms
.target Thrall
.isQuestTurnedIn 3982
step
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thrall|r again
.complete 4002,1
.target Thrall
.isQuestTurnedIn 3982
step
#label RoyalResc
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thrall|r
.turnin 4002 >> Turn in The Eastern Kingdoms
.accept 4003 >> Accept The Royal Rescue
.target Thrall
.isQuestTurnedIn 3982
step
#completewith EnterBRD3
+Hearth to Kargath if you put your hearthstone there. If you didn't, take the zeppelin to Stranglethorn and fly there instead
step
.goto Badlands,3.31,48.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thunderheart|r
>>|cRXP_FRIENDLY_Thunderheart|r|cRXP_WARN_might be patrolling around the mountain at Kargath. Find him or wait for him to return|r
.turnin 3907 >> Turn in Disharmony of Fire
.unitscan Thunderheart
.isQuestComplete 3907
step
.goto Badlands,2.90,47.76
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vivian|r
>>|cRXP_FRIENDLY_Vivian|r|cRXP_WARN_might be patrolling around the mountain near Kargath. Find her or wait for her to return|r
.turnin 7201 >> Turn in The Last Element
.unitscan Shadowmage Vivian Lagrave
.isQuestComplete 7201
step
.goto Badlands,5.81,47.52
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Warlord Goretooth|r
.turnin 4082 >> Turn in KILL ON SIGHT: High Ranking Dark Iron Officials
.target Warlord Goretooth
.isQuestComplete 4082
step
#label EnterBRD3
.subzone 1584 >>Enter Blackrock Depths
step
#completewith PrincessSaved
>>Kill |cRXP_ENEMY_Fire Elementals|r and |cRXP_ENEMY_Golems|r. Loot them for their |cRXP_LOOT_Essence of the Elements|r
.complete 7201,1 
.isOnQuest 7201
step
>>Kill |cRXP_ENEMY_Golem Lord Argelmach|r. Loot him for his |cRXP_LOOT_Head|r
>>Kill |cRXP_ENEMY_Golems|r. Loot them for their |cRXP_LOOT_Elemental Cores|r
.complete 4063,1 
.mob +Golem Lord Argelmach
.complete 4063,2 
.mob +Wrath Hammer Construct
step
#completewith next
>>Enter the Bar and go into the small room on the left. Do NOT attack any of the neutral mobs while running through the Bar
>>Click on the 3 |cRXP_PICK_Thunderbrew Lager Kegs|r to destroy them, forcing |cRXP_ENEMY_Hurley Blackbreath|r and his 3 |cRXP_ENEMY_Blackbreath Cronies|r to engage
>>Kill |cRXP_ENEMY_Hurley Blackbreath|r. Loot him for the |cRXP_LOOT_Lost Thunderbrew Recipe|r
.complete 4134,1 
.target Hurley Blackbreath
.isOnQuest 4134
step
>>Enter the Bar and go into the small room on the left. Do NOT attack any of the neutral mobs while running through the Bar
>>Kill |cRXP_ENEMY_Ribbly Screwspigot|r. Loot him for his |cRXP_LOOT_Head|r
>>To engage |cRXP_ENEMY_Ribbly Screwspigot|r you have your tank talk to him, then bring him back along with his |cRXP_ENEMY_Cronies|r into the room with the kegs
.complete 4136,1 
.target Ribbly Screwspigot
.skipgossip
.isOnQuest 4136
step
>>Enter the Bar and go into the small room on the left. Do NOT attack any of the neutral mobs while running through the Bar
>>Click on the 3 |cRXP_PICK_Thunderbrew Lager Kegs|r to destroy them, forcing |cRXP_ENEMY_Hurley Blackbreath|r and his 3 |cRXP_ENEMY_Blackbreath Cronies|r to engage
>>Kill |cRXP_ENEMY_Hurley Blackbreath|r. Loot him for the |cRXP_LOOT_Lost Thunderbrew Recipe|r
.complete 4134,1 
.isOnQuest 4134
step
>>Loot the |cRXP_LOOT_Core Fragment|r on the ground outside of the Molten Core instance portal
.complete 7848,1 
.isOnQuest 7848
step
>>Kill |cRXP_ENEMY_Emperor Dagran Thaurissan|r
>>|cRXP_WARN_You must NOT kill |cRXP_ENEMY_Princess Moira Bronzebeard|r in order to complete and turn in this quest|r
>>|cRXP_WARN_Have a party member kite |cRXP_ENEMY_Princess Moira Bronzebeard|r while the rest of the group kills|r |cRXP_ENEMY_Emperor Dagran Thaurissan|r
.complete 4003,1 
.isOnQuest 4003
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Princess Moira Bronzebeard|r
.turnin 4003 >> Turn in The Royal Rescue
.accept 4004 >> Accept The Princess Saved?
.target Princess Moira Bronzebeard
.isQuestComplete 4003
step
#label PrincessSaved
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Princess Moira Bronzebeard|r
.accept 4004 >> Accept The Princess Saved?
.target Princess Moira Bronzebeard
.isQuestTurnedIn 4003
step
#completewith KargathTurnins
+|cRXP_WARN_Hearth or travel back to Kargath|r
step
.goto Badlands,2.90,47.76
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vivian|r
>>|cRXP_FRIENDLY_Vivian|r|cRXP_WARN_might be patrolling around the mountain near Kargath. Find her or wait for her to return|r
.turnin 4134 >> Turn in Lost Thunderbrew Recipe
.unitscan Shadowmage Vivian Lagrave
.isQuestComplete 4134
step
.goto Badlands,2.90,47.76
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vivian|r
>>|cRXP_FRIENDLY_Vivian|r|cRXP_WARN_might be patrolling around the mountain near Kargath. Find her or wait for her to return|r
.turnin 7201 >> Turn in The Last Element
.unitscan Shadowmage Vivian Lagrave
.isQuestComplete 7201
step
#label KargathTurnins
.goto Badlands,25.95,44.86
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lotwil Veriatus|r
.turnin 4063 >> Turn in The Rise of the Machines
.target Lotwil Veriatus
.isQuestTurnedIn 4062
step
.goto Badlands,3.98,44.76
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gorrik|r
.fly Flame Crest >> Fly to Flame Crest
.target Gorrik
.zoneskip Burning Steppes
step
.goto Burning Steppes,65.152,23.911
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Maxwort Uberglint|r
.turnin 4123 >> Turn in The Heart of the Mountain
.target Maxwort Uberglint
.isQuestComplete 4123
step
.goto Burning Steppes,66.058,21.951
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yuka Screwspigot|r
.turnin 4136 >> Turn in Ribbly Screwspigot
.target Yuka Screwspigot
.isQuestComplete 4136
step
.goto Burning Steppes,95.061,31.563
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Cyrus Therepentous|r
.turnin 4024 >> Turn in A Taste of Flame
.target Cyrus Therepentous
.isQuestComplete 4024
step
.goto 1415,48.409,63.815
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lothos Riftwaker|r
>>|cRXP_WARN_You can either turn this in now or the next time you are in Blackrock Mountain|r
.turnin 7848 >> Turn in Attunement to the Core
.target Lothos Riftwaker
.isQuestComplete 7848
step << !Mage
#completewith next
+|cRXP_WARN_Hearth to Everlook and fly to Orgrimmar. If you have a mage, kindly ask for a portal to Orgrimmar instead|r
step << Mage
#completewith next
.cast 3567 >>|cRXP_WARN_Cast|r |T135759:0|t[Teleport: Orgrimmar]
.zoneskip Orgrimmar
step
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Thrall|r
.turnin 4004 >> Turn in The Princess Saved?
.target Thrall
.isQuestTurnedIn 4003
step
+|cRXP_WARN_This is the end of the Blackrock Depths guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 50-60
<< Horde
#name 114 Lower Blackrock Spire
#displayname 14. Lower Blackrock Spire
step
#completewith BSPickups
+|cRXP_WARN_You will now be directed to pick up all available quests for Lower Blackrock Spire|r
step
#completewith BadlandsPickups
.subzone 340 >>Travel to Kargath in |cFFfa9602Badlands|r
step
.goto Badlands,5.81,47.52
>>Talk to |cRXP_FRIENDLY_Warlord Goretooth|r to receive |T133473:0|t[|cRXP_LOOT_Warlord Goretooth's Command|r]. Use it to accept the quest
.collect 12563,1,4903 
.accept 4903 >>Accept Warlord's Command
.target Warlord Goretooth
.skipgossip 0,1,1,1,1,1
step
.goto Badlands,5.88,47.64
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lexlort|r on top of the tower
.accept 4981 >>Accept Operative Bijou
.target Lexlort
step
#label BadlandsPickups
.goto Badlands,5.96,47.73
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Galamav the Marksman|r on top of the tower
.accept 4724 >>Accept The Pack Mistress
.target Galamav the Marksman
step
#completewith BSPickups
.zone Burning Steppes >>|cRXP_WARN_Travel to|r |cFFfa9602Burning Steppes|r
step
.goto Burning Steppes,65.8,22.0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kibler|r
.accept 4862 >>Accept En-Ay-Es-Tee-Why
.target Kibler
step
#label BSPickups
.goto Burning Steppes,65.8,22.0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kibler|r
.accept 4729 >>Accept Kibler's Exotic Pets
.target Kibler
step
#completewith LBRS1
.subzone 254 >>Travel to |cFFfa9602Blackrock Mountain|r
step
#completewith LBRS1
.goto Eastern Kingdoms,48.95,63.89
.subzone 1583 >>Enter Blackrock Spire
step
#sticky
#label ImportantDocuments
>>Loot the |cRXP_LOOT_Important Blackrock Documents|r
>>This has 4 different possible spawn points in the dungeon:
>>|cRXP_WARN_At the feet of|r |cRXP_ENEMY_Overlord Wyrmthalak|r
>>|cRXP_WARN_In an empty corner next to|r |cRXP_ENEMY_War Master Voone|r
>>|cRXP_WARN_Near|r |cRXP_ENEMY_Highlord Omokk|r
>>|cRXP_WARN_Next to |cRXP_ENEMY_Urok Doomhowl's|r Tribute Pile|r
.complete 4903,4 
.isOnQuest 4903
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bijou|r
>>|cRXP_WARN_He is located outside of the troll area, you can clear to them through the pyramid or jump onto him from the outside|r
.turnin 4981 >>Turn in Operative Bijou
.accept 4982 >>Accept Bijou's Belongings
.target Bijou
.isOnQuest 4981
step
#optional
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bijou|r
>>|cRXP_WARN_He is located outside of the troll area, you can clear to them through the pyramid or jump onto him from the outside|r
.accept 4982 >>Accept Bijou's Belongings
.target Bijou
.isQuestTurnedIn 4981
step
>>Keep clearing through the instance until you reach the bottom floor. In the corridor filled with |cRXP_ENEMY_Orc Soldiers|r and their camps keep looking for a small brown crate, loot it for |T133652:0|t[|cRXP_PICK_Bijou's Belongings|r]
.complete 4982,1 
.isOnQuest 4982
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bijou|r
>>|cRXP_WARN_He is located outside of the troll area, you can clear to them through the pyramid or jump onto him from the outside|r
.turnin 4982 >>Turn in Bijou's Belongings
.accept 4983 >>Accept Bijou's Reconnaissance Report
.target Bijou
.isQuestComplete 4982
step
#optional
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Bijou|r
>>|cRXP_WARN_He is located outside of the troll area, you can clear to them through the pyramid or jump onto him from the outside|r
.accept 4983 >>Accept Bijou's Reconnaissance Report
.target Bijou
.isQuestTurnedIn 4982
step
>>Loot |T132833:0|t[|cRXP_PICK_Spire Spider Eggs|r] from clusters on the ground in the spider area
>>|cRXP_WARN_Be careful as multiple|r |cRXP_ENEMY_Spire Spiderlings|r |cRXP_WARN_may spawn after looting an egg|r
.complete 4862,1
.isOnQuest 4862
step
.use 12262 >>|cRXP_WARN_Once you reach the Wolf area, target a |cRXP_ENEMY_Bloodaxe Worg Pup|r and use the|r |T132599:0|t[Empty Worg Pup Cage] |cRXP_WARN_on it|r
.complete 4729,1 
.mob Bloodaxe Worg Pup
.isOnQuest 4729
step
>>Kill the Wolf boss |cRXP_ENEMY_Halycon|r
.mob Halycon
.complete 4724,1 
.isOnQuest 4724
step
#label LBRS1
>>Kill |cRXP_ENEMY_Highlord Omokk|r, |cRXP_ENEMY_War Master Voone|r and |cRXP_ENEMY_Overlord Wyrmthalak|r
.complete 4903,2 
.mob +Highlord Omokk
.complete 4903,3 
.mob +War Master Voone
.complete 4903,1 
.mob +Overlord Wyrmthalak
.isOnQuest 4903
step
#requires ImportantDocuments
#completewith BadlandsTurnins
.subzone 340 >>Travel to Kargath in |cFFfa9602Badlands|r
step
#requires ImportantDocuments
.goto Badlands,5.81,47.52
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Warlord Goretooth|r
.turnin 4903 >>Turn in Warlord's Command
.accept 4941 >>Accept Eitrigg's Wisdom
.target Warlord Goretooth
.isQuestComplete 4903
step
#optional
#requires ImportantDocuments
.goto Badlands,5.81,47.52
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Warlord Goretooth|r
.accept 4941 >>Accept Eitrigg's Wisdom
.target Warlord Goretooth
.isQuestTurnedIn 4941
step
.goto Badlands,5.88,47.64
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Lexlort|r on top of the tower
.turnin 4983 >>Turn in Bijou's Reconnaissance Report
.target Lexlort
.isOnQuest 4983
step
#label BadlandsTurnins
.goto Badlands,5.96,47.73
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Galamav the Marksman|r on top of the tower
.turnin 4724 >>Turn in The Pack Mistress
.target Galamav the Marksman
.isQuestComplete 4724
step
#completewith BSTurnins
.zone Burning Steppes >>|cRXP_WARN_Travel to|r |cFFfa9602Burning Steppes|r
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kibler|r
.turnin 4729 >> Turn in Kibler's Exotic Pets
.goto Burning Steppes,65.8,22.0
.target Kibler
.isQuestComplete 4729
step
#label BSTurnins
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kibler|r
.turnin 4862 >> Turn in En-Ay-Es-Tee-Why
.goto Burning Steppes,65.8,22.0
.target Kibler
.isQuestComplete 4862
step
+|cRXP_WARN_This is the end of the Lower Blackrock Spire guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 50-60
<< Horde
#name 115 Upper Blackrock Spire
#displayname 15. Upper Blackrock Spire
step
#completewith StartDungeon
.subzone 1583,2 >>|cRXP_WARN_This is a 10-man dungeon. You or somebody in your party must have the|r |T133343:0|t[|cRXP_LOOT_Seal of Ascension|r] |cRXP_WARN_to be able to enter Upper Blackrock Spire|r
step
#completewith ForTheHorde
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step
.goto Orgrimmar,34.27,39.35,10,0
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Eitrigg|r and go through the dialogue, then talk to |cRXP_FRIENDLY_Thrall|r
.turnin 4941 >>Turn in Eitrigg's Wisdom
.accept 4974 >>Accept For The Horde!
.target Eitrigg
.target Thrall
.skipgossip
.isOnQuest 4941
step
#label ForTheHorde
.goto Orgrimmar,34.27,39.35,10,0
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Eitrigg|r and go through the dialogue, then talk to |cRXP_FRIENDLY_Thrall|r
.accept 4974 >>Accept For The Horde!
.target Eitrigg
.target Thrall
.skipgossip
.isQuestTurnedIn 4941
step
#completewith next
.zone Azshara >>Travel to |cFFfa9602Azshara|r
step
.goto Azshara,79.28,73.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Hydraxis|r
>>|cRXP_WARN_These are prerequisite quests completed in Eastern Plaguelands and Silithus to unlock a quest in UBRS. Feel free to skip this|r
.accept 6804 >>Accept Poisoned Water
.accept 6805 >>Accept Stormers and Rumblers
.target Duke Hydraxis
step
#completewith next
.zone Silithus >>Travel to |cFFfa9602Silithus|r
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
.zone Eastern Plaguelands >>Travel to |cFFfa9602Eastern Plaguelands|r
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
.zone Azshara >>Travel to |cFFfa9602Azshara|r
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
#label EyeofEmber
#optional
.goto Azshara,79.28,73.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Hydraxis|r
.accept 6821 >>Accept Eye of the Emberseer
.target Duke Hydraxis
.isQuestTurnedIn 6804
.isQuestTurnedIn 6805
step
#completewith next
.subzone 340 >>Travel to Kargath in |cFFfa9602Badlands|r
step
.goto Badlands,2.90,47.76
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vivian|r
>>|cRXP_FRIENDLY_Vivian|r|cRXP_WARN_might be patrolling around the mountain near Kargath. Find her or wait for her to return|r
.accept 4768 >>Accept The Darkstone Tablet
.unitscan Shadowmage Vivian Lagrave
step
#completewith EggFreezeAccept
.zone Burning Steppes >>Travel to |cFFfa9602Burning Steppes|r
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
.subzone 254 >>Travel to |cFFfa9602Blackrock Mountain|r
step << !tbc !wotlk
#phase 3
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
#phase 3
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
#optional
#completewith next
.use 12286 >>|cRXP_WARN_Use the|r |T133003:0|t[Eggscilliscope Prototype] |cRXP_WARN_on one of the eggs in The Rookery to freeze it|r
.complete 4734,1 
.isOnQuest 4734
step
>>Loot the |cRXP_PICK_Darkstone Tablet|r laying in The Rookery
>>|cRXP_WARN_It's located to the left of the rubble ramp leading upstairs|r
.complete 4768,1 
.isOnQuest 4768
step
.use 12286 >>|cRXP_WARN_Use the|r |T133003:0|t[Eggscilliscope Prototype] |cRXP_WARN_on one of the eggs in The Rookery to freeze it|r
.complete 4734,1 
.isOnQuest 4734
step
>>Kill |cRXP_ENEMY_Rend Blackhand|r. Loot him for his |cRXP_LOOT_Head|r
.complete 4974,1 
.mob Rend Blackhand
.isOnQuest 4974
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Awbee|r and complete his dialogue
>>|cRXP_FRIENDLY_Awbee|r |cRXP_WARN_is located in the room you enter after defeating|r |cRXP_ENEMY_Rend Blackhand|r
>>|cRXP_WARN_Make sure your group knows you want to pick up this quest as the mobs guarding |cRXP_FRIENDLY_Awbee|r are usually skipped|r
.accept 5160 >>Accept The Matron Protectorate
.skipgossip
.isQuestAvailable 5160
.target Awbee
step
>>Click |cRXP_PICK_Drakkisath's Brand|r in the final room of Upper Blackrock Spire behind |cRXP_ENEMY_General Drakkisath|r
.turnin 7761 >>Turn in Blackhand's Command
.isOnQuest 7761
step
#completewith EggFreeze
+|cRXP_WARN_Stay in your raid group! The follow-up quest of "Egg Freezing" can be quickly completed inside the cleared instance|r
step
#completewith EggCollectAccept
.zone Burning Steppes >>Travel to |cFFfa9602Burning Steppes|r
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
.subzone 254 >>Travel to |cFFfa9602Blackrock Mountain|r
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
.zone Burning Steppes >>Travel to |cFFfa9602Burning Steppes|r
step
.goto Burning Steppes,65.2,23.8
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tinkee|r
.turnin 4735 >>Turn in Egg Collection
.target Tinkee Steamboil
.isQuestComplete 4735
step
#completewith next
.subzone 340 >>Travel to Kargath in |cFFfa9602Badlands|r
step
.goto Badlands,2.90,47.76
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vivian|r
>>|cRXP_FRIENDLY_Vivian|r|cRXP_WARN_might be patrolling around the mountain near Kargath. Find her or wait for her to return|r
.turnin 4768 >> Turn in The Darkstone Tablet
.unitscan Shadowmage Vivian Lagrave
.isQuestComplete 4768
step
#completewith next
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step
.goto Orgrimmar,34.27,39.35,10,0
.goto Orgrimmar,31.74,37.82
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Eitrigg|r and go through the dialogue, then talk to |cRXP_FRIENDLY_Thrall|r
>>|cRXP_WARN_The follow-up quest is part of the Onyxia Attunement chain. Select the Onyxia Attunement guide if you wish to complete this|r
.turnin 4974 >>Turn in For The Horde!
.target Eitrigg
.target Thrall
.skipgossip
.isQuestComplete 4974
step
#completewith next
.zone Azshara >>Travel to |cFFfa9602Azshara|r
step
.goto Azshara,79.28,73.70
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Hydraxis|r
.turnin 6821 >>Turn in Eye of the Emberseer
.target Duke Hydraxis
step
+|cRXP_WARN_This is the end of the Upper Blackrock Spire guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 50-60
<< Horde
#name 116 Scholomance
#displayname 16. Scholomance
step
#completewith EnterScholo
+|cRXP_WARN_You will now be directed to pick up all available quests for Scholomance|r
step
#completewith EnterScholo
+|cRXP_WARN_You or somebody in your party must have the|r |T13704:0|t[Skeleton Key] |cRXP_WARN_to enter Scholomance (a Rogue with 300 lockpicking can also open the door)|r
>>|cRXP_WARN_Select the "Scholomance Key" guide if you wish to obtain it|r
.itemcount 13704,<1
step << Shaman
>>|cRXP_WARN_Go to the Auction House in any Major city and buy an|r |T134094:0|t[Azerothian Diamond] |cRXP_WARN_and a|r |T134072:0|t[Pristine Black Diamond]
>>|cRXP_WARN_Skip this step if they are not available or if it's too expensive|r
.collect 12800,1,7667,1 
.collect 18335,1,7667,1 
.xp <58,1
step << Shaman
#completewith next
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step << Shaman
.goto Orgrimmar,38.66,35.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sagorne Creststrider|r
.accept 7667 >>Accept Material Assistance
.turnin 7667 >>Turn in Material Assistance
.accept 8258 >>Accept The Darkreaver Menace
.target Sagorne Creststrider
.itemcount 12800,1
.itemcount 18335,1
.xp <58,1
step << Shaman
#optional
.goto Orgrimmar,38.66,35.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sagorne Creststrider|r
.accept 8258 >>Accept The Darkreaver Menace
.target Sagorne Creststrider
.isQuestTurnedIn 8258
.xp <58,1
step
#completewith next
.subzone 2268 >>Travel to |cFFfa9602Light's Hope Chapel|r in Eastern Plaguelands
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
.zone Tirisfal Glades >>Travel to |cFFfa9602Tirisfal Glades|r
step
.goto Tirisfal Glades,83.05,71.61
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Alexi Barov|r
.accept 5341 >>Accept Barov Family Fortune
.target Alexi Barov
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
step << Shaman
.use 18746 >>|cRXP_WARN_Use the|r |T133866:0|t[Divination Scryer] |cRXP_WARN_in |cRXP_ENEMY_Rattlegore's|r room|r
>>|cRXP_WARN_Many |cRXP_ENEMY_Spirits|r will spawn. Kill them until the |cRXP_ENEMY_Death Knight Darkreaver|r spawns|r
>>Kill the |cRXP_ENEMY_Death Knight Darkreaver|r. Loot him for his |cRXP_LOOT_Head|r
.complete 8258,1 
.mob Death Knight Darkreaver
.isOnQuest 8258
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
.accept 5384 >>Accept Kirtonos the Herald
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
#completewith next
.zone Tirisfal Glades >>Travel to |cFFfa9602Tirisfal Glades|r
step
.goto Tirisfal Glades,83.05,71.61
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Alexi Barov|r
.turnin 5341 >>Turn in Barov Family Fortune
.target Alexi Barov
.isQuestComplete 5341
step
#completewith HatchlingsTurnin
.hs >>Hearth to Light's hope Chapel
.bindlocation 2268,1
.subzoneskip 2268
.use 6948
.cooldown item,6948,>0,1
step
#completewith HatchlingsTurnin
.subzone 2268 >>Travel to |cFFfa9602Light's Hope Chapel|r in Eastern Plaguelands
step
#label HatchlingsTurnin
.goto Eastern Plaguelands,81.47,59.66
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Betina Bigglezink|r
.turnin 5529 >>Turn in Plagued Hatchlings
.target Betina Bigglezink
.isQuestComplete 5529
step << Shaman
#completewith next
.zone Orgrimmar >>Travel to |cFFfa9602Orgrimmar|r
step << Shaman
.goto Orgrimmar,38.66,35.92
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sagorne Creststrider|r
.turnin 8258 >>Turn in The Darkreaver Menace
.target Sagorne Creststrider
.isQuestComplete 8258
step
+|cRXP_WARN_Select the "Stratholme guide" in order to continue with the quest chain of "The Human, Ras Frostwhisper"|r
.isOnQuest 5461
step
+|cRXP_WARN_This is the end of the Scholomance guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 50-60
<< Horde
#name 117 Stratholme
#displayname 17. Stratholme
step
#optional
+|cRXP_WARN_It is recommended to run Scholomance first to begin the quest chain "Doctor Theolen Krastinov, the Butcher" that will send you to Stratholme afterwards|r
.isQuestAvailable 5384
step
#completewith next
.subzone 324 >>Travel to |cFFfa9602Stromgarde Keep|r in Arathi Highlands
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
.zone Western Plaguelands >>Travel to |cFFfa9602Western Plaguelands|r
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
.zone Eastern Plaguelands >>Travel to |cFFfa9602Eastern Plaguelands|r
step
.goto Eastern Plaguelands,26.55,74.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nathanos|r
>>|cRXP_WARN_These are pre-requisite quests for a quest in Stratholme|r
.accept 6022 >>Accept To Kill With Purpose
.accept 6042 >>Accept Un-Life's Little Annoyances
.accept 6133 >>Accept The Ranger Lord's Behest
.target Nathanos Blightcaller
step
#completewith next
>>Kill |cRXP_ENEMY_Undead|r. Loot them for their |cRXP_LOOT_Living Rot|r.
>>|cRXP_WARN_Groups of elites patrol the north and east road. Invisible mobs patrol inside of Corrin's Crossing, so try to pull mobs out|r
.collect 15447,7 
.mob Hate Shrieker
.mob Scourge Warder
.mob Stitched Horror
.mob Gibbering Ghoul
.mob Unseen Servant
.mob Dark Caster
step
#loop
.goto Eastern Plaguelands,58.20,70.20,0
.goto Eastern Plaguelands,58.20,70.20,25,0
.goto Eastern Plaguelands,60.40,71.60,25,0
.goto Eastern Plaguelands,61.00,69.40,25,0
.goto Eastern Plaguelands,61.40,66.40,25,0
.goto Eastern Plaguelands,59.40,66.40,25,0
.goto Eastern Plaguelands,58.00,67.60,25,0
.use 15454 >>|cRXP_WARN_Use the|r |T133748:0|t[Mortar and Pestle] |cRXP_WARN_before the |cRXP_LOOT_Living Rot|r expires|r
.complete 6022,1 
.isOnQuest 6022
step
#loop
.goto Eastern Plaguelands,77.94,69.64,0
.goto Eastern Plaguelands,46.14,65.32,70,0
.goto Eastern Plaguelands,49.24,61.48,70,0
.goto Eastern Plaguelands,50.26,54.66,70,0
.goto Eastern Plaguelands,55.24,54.72,70,0
.goto Eastern Plaguelands,61.47,61.92,70,0
.goto Eastern Plaguelands,65.18,70.17,70,0
.goto Eastern Plaguelands,69.94,72.99,70,0
.goto Eastern Plaguelands,72.99,75.98,70,0
.goto Eastern Plaguelands,77.94,69.64,70,0
>>Kill |cRXP_ENEMY_Noxious Plaguebats|r
.complete 6042,1 
.mob Noxious Plaguebat
.isOnQuest 6042
step
#loop
.goto Eastern Plaguelands,51.18,39.91,0
.goto Eastern Plaguelands,69.73,50.55,70,0
.goto Eastern Plaguelands,70.42,43.50,70,0
.goto Eastern Plaguelands,70.34,38.47,70,0
.goto Eastern Plaguelands,67.02,34.41,70,0
.goto Eastern Plaguelands,62.69,34.72,70,0
.goto Eastern Plaguelands,50.36,28.49,70,0
.goto Eastern Plaguelands,51.18,39.91,70,0
>>Kill |cRXP_ENEMY_Monstrous Plaguebats|r
>>|cRXP_WARN_Be careful as|r |cRXP_ENEMY_Monstrous Plaguebats|r |cRXP_WARN_can silence for 10 seconds in melee range|r << !Rogue !Warrior
.complete 6042,2 
.mob +Monstrous Plaguebat
.isOnQuest 6042
step
#completewith next
.goto Eastern Plaguelands,52.14,18.30,0
>>Loot the |cRXP_LOOT_Quel'Thalas Registry|r on top of the bench
.complete 6133,4 
.isOnQuest 6133
step
#loop
.goto Eastern Plaguelands,52.88,19.18,0
.goto Eastern Plaguelands,51.75,21.66,40,0
.goto Eastern Plaguelands,50.73,18.33,40,0
.goto Eastern Plaguelands,50.89,16.50,40,0
.goto Eastern Plaguelands,52.97,17.29,40,0
.goto Eastern Plaguelands,52.88,19.18,40,0
>>Kill |cRXP_ENEMY_Pathstriders|r, |cRXP_ENEMY_Rangers|r and |cRXP_ENEMY_Woodsmen|r
>>|cRXP_WARN_These mobs hit very hard for non-elites|r << !Rogue !Druid
>>|cRXP_WARN_These mobs hit very hard for non-elites; remember Pathstrider's Faerie Fire ability, in case you need to escape|r << Rogue/Druid
.complete 6133,1 
.mob +Pathstrider
.complete 6133,2 
.mob +Ranger
.complete 6133,3 
.mob +Woodsman
.isOnQuest 6133
step
.goto Eastern Plaguelands,52.14,18.30
>>Loot the |cRXP_LOOT_Quel'Thalas Registry|r on top of the bench
.complete 6133,4 
.isOnQuest 6133
step
.goto Eastern Plaguelands,26.55,74.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nathanos|r
.turnin 6022 >>Turn in To Kill With Purpose
.target Nathanos Blightcaller
.isQuestComplete 6022
step
.goto Eastern Plaguelands,26.55,74.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nathanos|r
.turnin 6042 >>Turn in Un-Life's Little Annoyances
.target Nathanos Blightcaller
.isQuestComplete 6042
step
.goto Eastern Plaguelands,26.55,74.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nathanos|r
.turnin 6133 >>Turn in The Ranger Lord's Behest
.target Nathanos Blightcaller
.isQuestComplete 6133
step
.goto Eastern Plaguelands,26.55,74.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nathanos|r
>>|cRXP_WARN_These are pre-requisite quests for a quest in Stratholme|r
.accept 6135 >>Accept Duskwing, Oh How I Hate Thee...
.accept 6136 >>Accept The Corpulent One
.target Nathanos Blightcaller
.isQuestTurnedIn 6022
.isQuestTurnedIn 6042
.isQuestTurnedIn 6133
step
.goto Eastern Plaguelands,46.2,64.0,0
.goto Eastern Plaguelands,27.2,73.6,0
.goto Eastern Plaguelands,46.2,64.0,80,0
.goto Eastern Plaguelands,27.2,73.6,80,0
>>Kill |cRXP_ENEMY_Duskwing|r. Loot him for his |cRXP_LOOT_Fur|r
>>|cRXP_WARN_He patrols nearby|r
.complete 6135,1 
.unitscan Duskwing
.isOnQuest 6135
step
.goto Eastern Plaguelands,56.3,31.0
>>Kill |cRXP_ENEMY_Borelgore|r
>>|cRXP_WARN_He patrols around this area. Find him & kill him|r
.complete 6136,1 
.unitscan Borelgore
step
.goto Eastern Plaguelands,26.55,74.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nathanos|r
.turnin 6135 >>Turn in Duskwing, Oh How I Hate Thee...
.target Nathanos Blightcaller
.isQuestComplete 6135
step
.goto Eastern Plaguelands,26.55,74.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nathanos|r
.turnin 6136 >>Turn in The Corpulent One
.target Nathanos Blightcaller
.isQuestComplete 6136
step
.goto Eastern Plaguelands,26.55,74.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nathanos|r
.accept 6163 >>Accept Ramstein
.target Nathanos Blightcaller
.isQuestTurnedIn 6135
.isQuestTurnedIn 6136
step
.goto Eastern Plaguelands,26.55,74.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nathanos|r
.accept 6163 >>Accept Ramstein
.target Nathanos Blightcaller
.isQuestAvailable 6163
step
#completewith LHCpickups
.subzone 2268 >>Travel to |cFFfa9602Light's Hope Chapel|r
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
.accept 5214 >>Accept The Great Fras Siabi
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
+|cRXP_WARN_If possible, return to Light's hope Chapel now to turn in "The Archivist" BEFORE killing |cRXP_ENEMY_Grand Crusader Dathrohan|r |cRXP_ENEMY_(Balnazzar)|r as this will allow you to loot|r |T136183:0|t[|cRXP_LOOT_Head of Balnazzar|r]
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
+|cRXP_WARN_If possible, return to Light's hope Chapel once more to get the follow-up quest to kill |cRXP_ENEMY_Baron Rivendare|r
step
.goto Eastern Plaguelands,81.437,59.820
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Nicholas Zverenhoff|r
>>|cRXP_WARN_Skip this step if you do not wish to do this now|r
.turnin 5262 >>Turn in The Truth Comes Crashing Down
.accept 5263 >>Accept Above and Beyond
.target Duke Nicholas Zverenhoff
step
#completewith Souls2
>>Kill |cRXP_ENEMY_Undead|r. Loot them for their |T134358:0|t[|cRXP_LOOT_Plagued Flesh Samples|r]
.complete 5212,1 
.isOnQuest 5212
step
>>Kill |cRXP_ENEMY_Ramstein|r. Loot him for his |cRXP_LOOT_Head|r
.complete 6163,1 
.mob Ramstein the Gorger
.isOnQuest 6163
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
.hs >>Hearth to Light's hope Chapel
.bindlocation 2268,1
.subzoneskip 2268
.use 6948
.cooldown item,6948,>0,1
step
.goto Eastern Plaguelands,81.437,59.820
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Duke Nicholas Zverenhoff|r
.turnin 5262 >>Turn in The Truth Comes Crashing Down
.accept 5263 >>Accept Above and Beyond
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
.accept 5214 >>Accept The Great Fras Siabi
.target Smokey LaRue
.isQuestComplete 5214
step
.goto Eastern Plaguelands,26.55,74.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nathanos|r
.turnin 6163 >>Turn in Ramstein
.target Nathanos Blightcaller
.isQuestComplete 6163
step
.goto Eastern Plaguelands,7.59,43.57
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tirion|r
.turnin 5848 >>Turn in Of Love and Family
.target Tirion Fordring
.isQuestComplete 5848
step
#completewith RichRas
.zone Western Plaguelands >>Travel to |cFFfa9602Western Plaguelands|r
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
+|cRXP_WARN_This is the end of the Stratholme guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 50-60
<< Horde
#name 118 Dire Maul (East)
#displayname 18. Dire Maul (East)
step << era
#optional
#phase 1
+|cRXP_WARN_Dire Maul is not until accessible until Phase 2 has released|r
step
#completewith EnterDME
.zone Feralas >> Travel to Feralas
step
.goto Feralas,76.18,43.83
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Talo Thornhoof|r
.accept 7489 >>Accept Lethtendris's Web
.target Talo Thornhoof
step
.goto Feralas,76.910,37.353
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Azj'Tordin|r
.accept 7441 >>Accept Pusillin and the Elder Azj'Tordin
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
.isOnQuest 7441
step
>>Kill |cRXP_ENEMY_Lethtendris|r. Loot her for |cRXP_LOOT_Lethtendris's Web|r
.complete 7489,1 
.mob Lethtendris
step << Mage era
>>Kill |cRXP_ENEMY_Hydrospawn|r. Loot it for the |cRXP_LOOT_Hydrospawn Essence|r
.complete 7463,1 
.mob Hydrospawn
step
>>Kill |cRXP_ENEMY_Alzzin the Wildshaper|r. Loot a |cRXP_PICK_Felvine Shard|r on the ground after
.collect 18501,1,5526,1 
.mob Alzzin the Wildshaper
.isOnQuest 7463
step << Mage era
#softcore
>>Talk to |cRXP_FRIENDLY_Lorekeeper Lydros|r in the Dire Maul (North) Library
>>|cRXP_WARN_Skip this if you can't access it|r
.turnin 7463 >>Turn in Arcane Refreshment
.target Lorekeeper Lydros
.xp <60,1
.isQuestComplete 7463
step
.goto Feralas,76.910,37.353
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Azj'Tordin|r in Feralas
.turnin 7441 >>Turn in Pusillin and the Elder Azj'Tordin
.target Azj'Tordin
.isQuestComplete 7441
step
.goto Feralas,76.18,43.83
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Talo Thornhoof|r
.turnin 7489 >>Turn in Lethtendris's Web
.target Talo Thornhoof
.isQuestComplete 7489
step
#completewith SotF
.zone Moonglade >> Travel to Moonglade
step
.goto Moonglade,51.685,45.096
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Rabine Saturna|r
.accept 5526 >>Accept Shards of the Felvine
.target Rabine Saturna
.isQuestTurnedIn 5527
step
.use 18539 >> |cRXP_WARN_Use the|r |T132595:0|t[Reliquary of Purity]
.complete 5526,1 
.isOnQuest 5526
.isQuestTurnedIn 5527
step
#label SotF
.goto Moonglade,51.685,45.096
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Rabine Saturna|r
.turnin 5526 >> Turn in Shards of the Felvine
.target Rabine Saturna
.isQuestComplete 5526
step
+|cRXP_WARN_This is the end of the Dire Maul (East) guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 50-60
<< Horde
#name 119 Dire Maul (West)
#displayname 19. Dire Maul (West)
step << era
#optional
#phase 1
+Dire Maul is not until accessible until Phase 2 has released
step
#completewith EnterDM
.zone Feralas >> Travel to Feralas
step
#loop
.goto Feralas,74.15,44.79,0
.goto Feralas,74.15,44.79,30,0
.goto Feralas,74.39,44.01,30,0
.goto Feralas,75.22,43.75,30,0
.goto Feralas,76.58,43.23,30,0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sage Korolusk|r
>>|cRXP_FRIENDLY_Sage Korolusk|r |cRXP_WARN_patrols slightly through Camp Mojache|r
.accept 7481 >>Accept Elven Legends
.target Sage Korolusk
step
#label EnterDM
.goto 1414,42.97,67.79,15 >>Enter Dire Maul (West)
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Shen'dralar Ancient|r
>>|cRXP_WARN_She is inside DM:West on the bridge in the upper section|r
.accept 7461 >>Accept The Madness Within
.target Shen'dralar Ancient
step
>>Kill |cRXP_ENEMY_Immol'thar|r and |cRXP_ENEMY_Prince Tortheldrin|r
.complete 7461,1 
.mob +Immol'thar
.complete 7461,2 
.mob +Prince Tortheldrin
.isOnQuest 7461
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Shen'dralar Ancient|r
>>|cRXP_WARN_She is inside DM:West on the bridge in the upper section|r
.turnin 7461 >>Turn in The Madness Within
.accept 7877 >>Accept The Treasure of the Shen'dralar
.target Shen'dralar Ancient
.isQuestComplete 7461
step
#optional
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Shen'dralar Ancient|r
>>|cRXP_WARN_She is inside DM:West on the bridge in the upper section|r
.accept 7877 >>Accept The Treasure of the Shen'dralar
.target Shen'dralar Ancient
.isQuestTurnedIn 7461
step
>>Click the |cRXP_PICK_The Treasure of the Shen'dralar|r
>>|cRXP_WARN_This is found back where you killed |cRXP_ENEMY_Prince Tortheldrin|r in the Library, under the ramp leading to him|r
.turnin 7877 >>Turn in The Treasure of the Shen'dralar
.isOnQuest 7877
step << Mage era
#optional
#softcore
>>Talk to |cRXP_FRIENDLY_Lorekeeper Lydros|r in the Dire Maul (North) Library
.turnin 7463 >> Turn in Arcane Refreshment
.target Lorekeeper Lydros
.xp <60,1
.isQuestComplete 7463
step
>>Click the |cRXP_PICK_Skeletas Remains of Kariel Winthalus|r inside the Dire Maul Library
>>|cRXP_WARN_This is located beside|r |cRXP_FRIENDLY_Lorekeeper Lydros|r
.complete 7481,1 
.isOnQuest 7481
step
#completewith next
.zone Feralas >>Travel to Feralas
step
#loop
.goto Feralas,74.15,44.79,0
.goto Feralas,74.15,44.79,30,0
.goto Feralas,74.39,44.01,30,0
.goto Feralas,75.22,43.75,30,0
.goto Feralas,76.58,43.23,30,0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sage Korolusk|r
>>|cRXP_FRIENDLY_Sage Korolusk|r |cRXP_WARN_patrols slightly through Camp Mojache|r
.accept 7481 >>Accept Elven Legends
.target Sage Korolusk
.isQuestComplete 7481
step
+|cRXP_WARN_This is the end of the Dire Maul (West) guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 50-60
<< Horde
#name 120 Dire Maul (North)
#displayname 20. Dire Maul (North)
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
.zone Feralas >>Travel to Feralas
step
#loop
.goto Feralas,74.15,44.79,0
.goto Feralas,74.15,44.79,30,0
.goto Feralas,74.39,44.01,30,0
.goto Feralas,75.22,43.75,30,0
.goto Feralas,76.58,43.23,30,0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sage Korolusk|r
>>|cRXP_FRIENDLY_Sage Korolusk|r |cRXP_WARN_patrols slightly through Camp Mojache|r
.accept 7481 >>Accept Elven Legends
.target Sage Korolusk
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
>>|cRXP_WARN_There are no other quests to complete. Exit the instance once complete|r
.zoneskip Feralas
step
#completewith next
.zone Feralas >>Travel to Feralas
step
.goto Feralas,31.8,44.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Scholar Runethorn|r
>>|cRXP_FRIENDLY_Scholar Runethorn|r |cRXP_WARN_patrols slightly through Feathermoon Stronghold|r
.turnin 7482 >> Turn in Elven Legends
.target Scholar Runethorn
step
+|cRXP_WARN_This is the end of the Dire Maul (North) guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 60-70
<< Horde !classic
#name 121 Hellfire Ramparts
#displayname 21. Hellfire Ramparts
step
#completewith next
.zone Blasted Lands >>Travel to |cFFfa9602Blasted Lands|r
step
.goto Blasted Lands,58.1,56.1
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Warlord Dar'toon|r
.accept 9407 >>Accept Through the Dark Portal
.target Warlord Dar'toon
step
#completewith next
.goto Blasted Lands,58.74,60.28
.zone Hellfire Peninsula >>Go through the Dark Portal
step
.goto Hellfire Peninsula,87.35,49.80
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Orion|r
.turnin 9407 >>Turn in Through the Dark Portal
.accept 10120 >>Accept Arrival in Outland
.target Lieutenant General Orion
step
.goto Hellfire Peninsula,87.34,48.13
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vlagga|r
.turnin 10120 >>Turn in Arrival in Outland
.accept 10289 >>Accept Journey to Thrallmar
.target Vlagga Freyfeather
step
.goto Hellfire Peninsula,87.34,48.13
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vlagga|r
.fly Thrallmar >>Fly to Thrallmar
.skipgossip
.isOnQuest 10289
.target Vlagga Freyfeather
.subzoneskip 3536
step
#label ArriveThrallmar
.goto Hellfire Peninsula,55.89,36.60,15,0
.goto Hellfire Peninsula,55.86,37.12
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Krakork|r
.turnin 10289 >>Turn in Journey to Thrallmar
.accept 10291 >>Accept Report to Nazgrel
.target General Krakork
step
.goto Hellfire Peninsula,55.14,37.28,20,0
.goto Hellfire Peninsula,55.01,35.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nazgrel|r
.turnin 10291 >>Turn in Report to Nazgrel
.accept 10121 >>Accept Eradicate the Burning Legion
.target Nazgrel
step
#hardcore
#completewith next
+|cFFFF0000HIGH DEATH RISK WARNING:|r
>>|cRXP_WARN_DO NOT APPROACH|r |cRXP_FRIENDLY_Sergeant Shatterskull|r |cRXP_WARN_yet!|r
>>|cRXP_WARN_Every 5-10 minutes a group of |cRXP_ENEMY_Infernal Invaders|r will drop out of the sky which will stun and kill you INSTANTLY at the quest giver location|r
>>|cRXP_WARN_Wait until this happens. After this is over you have time to safely accept the quest|r
step
#hardcore
.goto Hellfire Peninsula,57.00,43.28 
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Shatterskull|r
.turnin 10121 >> Turn in Eradicate the Burning Legion
.accept 10123 >> Accept Felspark Ravine
.target Sergeant Shatterskull
step
#softcore
.goto Hellfire Peninsula,58.07,41.28
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Shatterskull|r
.turnin 10121 >> Turn in Eradicate the Burning Legion
.accept 10123 >> Accept Felspark Ravine
.target Sergeant Shatterskull
step
#loop
.goto Hellfire Peninsula,61.11,38.982,0
.goto Hellfire Peninsula,63.228,37.783,0
.goto Hellfire Peninsula,66.843,36.485,0
.goto Hellfire Peninsula,61.11,38.982,50,0
.goto Hellfire Peninsula,63.228,37.783,50,0
.goto Hellfire Peninsula,66.843,36.485,50,0
>>Kill a |cRXP_ENEMY_Dreadcaller|r, |cRXP_ENEMY_Imps|r and |cRXP_ENEMY_Infernals|r
.complete 10123,1 
.mob +Dreadcaller
.complete 10123,2 
.mob +Flamewaker Imp
.complete 10123,3 
.mob +Infernal Warbringer
step
#hardcore
#completewith next
+|cFFFF0000HIGH DEATH RISK WARNING:|r
>>|cRXP_WARN_DO NOT APPROACH|r |cRXP_FRIENDLY_Sergeant Shatterskull|r |cRXP_WARN_yet!|r
>>|cRXP_WARN_Every 5-10 minutes a group of |cRXP_ENEMY_Infernal Invaders|r will drop out of the sky which will stun and kill you INSTANTLY at the quest giver location|r
>>|cRXP_WARN_Wait until this happens. After this is over you have time to safely turn in the quest|r
step
#hardcore
#label ThrallmarHS
.goto Hellfire Peninsula,57.00,43.28 
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Shatterskull|r
.turnin 10123 >>Turn in Felspark Ravine
.accept 10124 >>Accept Forward Base: Reaver's Fall
.target Sergeant Shatterskull
step
#softcore
#label ThrallmarHS
.goto Hellfire Peninsula,58.07,41.28
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Shatterskull|r
.turnin 10123 >>Turn in Felspark Ravine
.accept 10124 >>Accept Forward Base: Reaver's Fall
.target Sergeant Shatterskull
step
#completewith next
.subzone 3807 >>Travel to Reaver's Fall
step
.goto Hellfire Peninsula,65.89,43.59
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_To'arch|r
>>|cRXP_WARN_After this quest is turned in, Ramparts quests will unlock|r
.turnin 10124 >>Turn in Forward Base: Reaver's Fall
.target Forward Commander To'arch
step
.goto Hellfire Peninsula,55.19,36.00
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Stone Guard Stok'ton|r
.accept 9572 >>Accept Weaken the Ramparts
.target Stone Guard Stok'ton
step
#label EnterRamparts
.goto Hellfire Peninsula,47.66,53.56
.subzone 3562 >>|cRXP_WARN_Enter Hellfire Ramparts|r
.isQuestAvailable 9572,9588
step
#completewith next
>>Kill |cRXP_ENEMY_Watchkeeper Gargolmar|r. Loot him for |cRXP_LOOT_Gargolmar's Hand|r
>>Kill |cRXP_ENEMY_Omor the Unscarred|r. Loot him for |cRXP_LOOT_Omor's Hoof|r
>>Kill |cRXP_ENEMY_Nazan|r. Loot it for |cRXP_LOOT_Nazan's Head|r
.complete 9572,1 
.mob +Watchkeeper Gargolmar
.complete 9572,2 
.mob +Omor the Unscarred
.complete 9572,3 
.mob +Nazan
.isOnQuest 9572
step
>>Kill |cRXP_ENEMY_Vazruden|r. Loot him for the |T134940:0|t[|cRXP_LOOT_Ominous Letter|r]
.use 23890 >>|cRXP_WARN_Use the|r |T134940:0|t[|cRXP_LOOT_Ominous Letter|r] |cRXP_WARN_to start the quest|r
.collect 23890,1,9588 
.accept 9588 >> Accept Dark Tidings
.mob Vazruden
step
>>Kill |cRXP_ENEMY_Watchkeeper Gargolmar|r. Loot him for |cRXP_LOOT_Gargolmar's Hand|r
>>Kill |cRXP_ENEMY_Omor the Unscarred|r. Loot him for |cRXP_LOOT_Omor's Hoof|r
>>Kill |cRXP_ENEMY_Nazan|r. Loot it for |cRXP_LOOT_Nazan's Head|r
.complete 9572,1 
.mob +Watchkeeper Gargolmar
.complete 9572,2 
.mob +Omor the Unscarred
.complete 9572,3 
.mob +Nazan
.isOnQuest 9572
step
#completewith WeakenRamparts
.subzone 3536 >>Return to |cFFfa9602Thrallmar|r
step
.goto Hellfire Peninsula,55.01,35.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nazgrel|r
.turnin 9588 >> Turn in Dark Tidings
.target Nazgrel
.isOnQuest 9588
step
#label WeakenRamparts
.goto Hellfire Peninsula,55.19,36.00
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Stone Guard Stok'ton|r
.turnin 9572 >> Turn in Weaken the Ramparts
.target Stone Guard Stok'ton
.isQuestComplete 9572
step
+|cRXP_WARN_This is the end of the Hellfire Ramparts guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 60-70
<< Horde !classic
#name 122 Blood Furnace
#displayname 22. Blood Furnace
step
#completewith BFPickups
.subzone 3536 >>Travel to to |cFFfa9602Thrallmar|r
step
.goto Hellfire Peninsula,54.89,36.02
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Caza'Rez|r
.accept 9590 >> Accept The Blood is Life
.accept 9608 >> Accept Heart of Rage
.target Caza'Rez
.isQuestTurnedIn 9588
.isQuestTurnedIn 9572
step
#optional
.goto Hellfire Peninsula,54.89,36.02
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Caza'Rez|r
.accept 9590 >> Accept The Blood is Life
.target Caza'Rez
.isQuestTurnedIn 9588
step
#label BFPickups
#optional
.goto Hellfire Peninsula,54.89,36.02
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Caza'Rez|r
.accept 9608 >> Accept Heart of Rage
.target Caza'Rez
.isQuestTurnedIn 9572
step
.isQuestAvailable 9590,9608
.goto Hellfire Peninsula,46.00,51.81
.subzone 3713 >> |cRXP_WARN_Enter Blood Furnace|r
step
#completewith next
>>Kill |cRXP_ENEMY_Orcs|r. Loot them for their |cRXP_LOOT_Fel Orc Blood Vials|r
.complete 9590,1 
.isOnQuest 9590
step
>>Explore the final room of the Blood Furnace
.complete 9608,1 
.isOnQuest 9608
step
>>Kill |cRXP_ENEMY_Orcs|r. Loot them for their |cRXP_LOOT_Fel Orc Blood Vials|r
.complete 9590,1 
.isOnQuest 9590
step
.zone Hellfire Peninsula >> Exit the Blood Furnace
.subzoneskip 3713,1
step
#completewith BFTurnins
.subzone 3536 >>Return to |cFFfa9602Thrallmar|r
step
.goto Hellfire Peninsula,54.89,36.02
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Caza'Rez|r
.turnin 9590 >>Turn in The Blood is Life
.target Caza'Rez
.isQuestComplete 9590
step
#label BFTurnins
.goto Hellfire Peninsula,55.01,35.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nazgrel|r
.turnin 9608 >>Turn in Heart of Rage
.target Nazgrel
.isQuestComplete 9608
step
+|cRXP_WARN_This is the end of the Blood Furnace guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 60-70
<< Horde !classic
#name 123 Underbog
#displayname 23. Underbog
step
#completewith SporeggarPickups
.subzone 3649 >>Travel to |cFFfa9602Sporeggar|r
step
.goto Zangarmarsh,19.368,49.785
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_T'shu|r
.accept 9717 >>Accept Oh, It's On!
.target T'shu
.reputation 970,friendly,<0,1 
.xp <63,1
step
#label SporeggarPickups
.goto Zangarmarsh,19.650,49.701
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khn'nix|r
.accept 9719 >>Accept Stalk the Stalker
.target Khn'nix
.reputation 970,neutral,<0,1 
.xp <63,1
step
#completewith EnterUB
.goto Zangarmarsh,50.37,40.84,25,0
.goto Zangarmarsh,51.91,35.99,70 >>Swim through the underwater tunnel into Coilfang Reservoir
step
.goto Zangarmarsh,52.291,35.959
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Watcher Jhang|r
.accept 9738 >>Accept Lost in Action
.target Watcher Jhang
step
#label EnterUB
.goto Zangarmarsh,54.297,34.449
.subzone 3716 >>Zone into the Underbog
.isQuestAvailable 9717,9719,9738
step
#sticky
>>Loot the mobs inside Underbog for |cRXP_LOOT_Sanguine Hibiscus|r
>>|cRXP_LOOT_Sanguine Hibiscus|r plants can also be looted on the ground
.collect 24246,5,9715,1 
.reputation 970,friendly,<0,1 
.subzoneskip 3716,1
step
>>Loot the |cRXP_LOOT_Underspore Frond|r on the ground after defeating |cRXP_ENEMY_Hungarfen|r
.complete 9717,1 
.isOnQuest 9717
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Earthbinder Rayge|r and |cRXP_FRIENDLY_Windcaller Claw|r inside Underbog
.complete 9738,1 
.target +Earthbinder Rayge
.complete 9738,4 
.target +Windcaller Claw
.isOnQuest 9738
step
>>Kill |cRXP_ENEMY_The Black Stalker|r. Loot it for the |cRXP_LOOT_Brain of the Black Stalker|r
.complete 9719,1 
.mob The Black Stalker
.isOnQuest 9719
step
#completewith SporeggarTurnins
.zone Zangarmarsh >>Exit Underbog
.subzoneskip 3716,1
step
.goto Zangarmarsh,52.291,35.959
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Watcher Jhang|r
.turnin 9738 >>Turn in Lost in Action
.target Watcher Jhang
.isQuestComplete 9738
step
#completewith SporeggarTurnins
.subzone 3649 >>Travel to |cFFfa9602Sporeggar|r
step
.goto Zangarmarsh,19.368,49.785
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_T'shu|r
.turnin 9717 >>Turn in Oh, It's On!
.target T'shu
.isQuestComplete 9717
step
.goto Zangarmarsh,19.650,49.701
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khn'nix|r
.turnin 9719 >>Turn in Stalk the Stalker
.target Khn'nix
.isQuestComplete 9719
step
#label SporeggarTurnins
.goto Zangarmarsh,19.54,50.04
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gzhun'tt|r
.accept 9715 >> Accept Bring Me A Shrubbery!
.turnin 9715 >> Turn in Bring Me A Shrubbery!
.target Gzhun'tt
.itemcount 24246,5 
.reputation 970,friendly,<0,1 
.xp <63,1
step
+|cRXP_WARN_This is the end of the Underbog guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 60-70
<< Horde !classic
#name 124 Slave Pens
#displayname 24. Slave Pens
step
#completewith EnterSP
.goto Zangarmarsh,50.37,40.84,25,0
.goto Zangarmarsh,51.91,35.99,70 >>Swim through the underwater tunnel into Coilfang Reservoir
step
.goto Zangarmarsh,52.291,35.959
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Watcher Jhang|r
.accept 9738 >>Accept Lost in Action
.target Watcher Jhang
step
#label EnterSP
.goto Zangarmarsh,49.018,35.631
.subzone 3717 >>Zone into the Slave Pens
.isQuestAvailable 9738
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Naturalist Bite|r and |cRXP_FRIENDLY_Weeder Greenthumb|r inside the Slave Pens
.complete 9738,2 
.target +Naturalist Bite
.complete 9738,3 
.target +Weeder Greenthumb
.isOnQuest 9738
step
#completewith next
.zone Zangarmarsh >>|cRXP_WARN_Exit the Slave Pens|r
.subzoneskip 3717,1
step
.goto Zangarmarsh,52.291,35.959
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Watcher Jhang|r
.turnin 9738 >>Turn in Lost in Action
.target Watcher Jhang
.isQuestComplete 9738
step
+|cRXP_WARN_This is the end of the Slave Pens guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 60-70
<< Horde !classic
#name 125 Mana Tombs
#displayname 25. Mana Tombs
step
#completewith next
.isQuestAvailable 10216,10165,10218
.goto Terokkar Forest,39.63,60.30,0
.subzone 3792 >> Travel to |cFFfa9602Mana-Tombs|r
>>|cRXP_WARN_NOTE: You must be level 64 to accept the quests for Mana-Tombs!|r
.subzoneskip 3893 
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Artificer Morphalius|r and |cRXP_FRIENDLY_Nexus-Prince Haramad|r
>>|cRXP_WARN_NOTE: These quests require level 64 to accept!|r
.accept 10216 >> Accept Safety Is Job One
.target +Artificer Morphalius
.goto Terokkar Forest,39.422,58.514
.accept 10165 >> Accept Undercutting the Competition
.target +Nexus-Prince Haramad
.goto Terokkar Forest,39.371,58.475
step
#label EnterMT
.subzone 3792 >>Enter Mana Tombs
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
.isOnQuest 10216
step
>>Click the |cRXP_PICK_Ethereal Transporter Control Panel|r inside the dungeon
>>|cRXP_WARN_It is recommended not to accept the follow up escort quest until you have cleared the dungeon|r
.turnin 10216 >> Turn in Safety Is Job One
.isQuestComplete 10216
step
>>Kill |cRXP_ENEMY_Nexus-Prince Shaffar|r. Loot him for |cRXP_LOOT_Shaffar's Wrappings|r
.complete 10165,1 
.isOnQuest 10165
step
.isQuestTurnedIn 10216
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Cryo-Engineer Sha'heen|r
.accept 10218 >> Accept Someone Else's Hard Work Pays Off
.target Cryo-Engineer Sha'heen
step
>>Escort |cRXP_FRIENDLY_Cryo-Engineer Sha'heen|r out of the Mana-Tombs
.complete 10218,1 
.target Cryo-Engineer Sha'heen
.isOnQuest 10218
step
#completewith MTTurnins
.zone Terokkar Forest >> |cRXP_WARN_Exit the Mana-Tombs|r
.subzoneskip 3792,1
step
.goto Terokkar Forest,39.371,58.475
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nexus-Prince Haramad|r
.turnin 10165 >> Turn in Undercutting the Competition
.target Nexus-Prince Haramad
.isQuestComplete 10165
step
#label MTTurnins
.goto Terokkar Forest,39.371,58.475
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nexus-Prince Haramad|r
.turnin 10218 >> Turn in Someone Else's Hard Work Pays Off
.target Nexus-Prince Haramad
.isQuestComplete 10218
step
+|cRXP_WARN_This is the end of the Mana Tombs guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 60-70
<< Horde !classic
#name 126 Auchenai Crypts
#displayname 26. Auchenai Crypts
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
+|cRXP_WARN_You have completed the Auchenai Crypts guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 60-70
<< Horde !classic
#name 127 Sethekk Halls
#displayname 27. Sethekk Halls
step
.goto Terokkar Forest,44.07,64.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Isfar|r
.accept 10097 >>Accept Brother Against Brother
.accept 10098 >>Accept Terokk's Legacy
.target Isfar
step
.goto Terokkar Forest,44.90,65.61,10 >>Enter Sethekk Halls
.isQuestAvailable 10097,10098
step
>>Kill |cRXP_ENEMY_Darkweaver Syth|r. Loot him for |cRXP_LOOT_Terokk's Mask|r
.complete 10097,1 
.complete 10098,2 
.mob Darkweaver Syth
.isOnQuest 10097
.isOnQuest 10098
step
#optional
>>Kill |cRXP_ENEMY_Darkweaver Syth|r
.complete 10097,1 
.mob Darkweaver Syth
.isOnQuest 10097
.isNotOnQuest 10098
step
>>Talk to |cRXP_FRIENDLY_Lakka|r to free him
.complete 10097,2 
.target Lakka
.skipgossip
.isOnQuest 10097
step
>>Loot the |cRXP_PICK_Saga of Terokk|r on the ground
>>|cRXP_WARN_It's located in the center of 2nd to last room|r
.complete 10098,1 
.isOnQuest 10098
step
>>Kill |cRXP_ENEMY_Talon King Ikiss|r. Loot him for |cRXP_LOOT_Terokk's Quill|r
.complete 10098,3 
.mob Talon King Ikiss
.isOnQuest 10098
step
>>Loot |cRXP_PICK_The Talon King's Coffer|r in the back of |cRXP_ENEMY_Talon King Ikiss'|r room for the |T134236:0|t[|cRXP_LOOT_Shadow Labyrinth Key|r]
.collect 27991,1 
step
#completewith SethekkTurnins
.zone Terokkar Forest >>Exit Sethekk Halls
step
.goto Terokkar Forest,44.07,64.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Isfar|r
.turnin 10098 >>Turn in Terokk's Legacy
.turnin 10097 >>Turn in Brother Against Brother
.target Isfar
.isQuestComplete 10098
.isQuestComplete 10097
step
.goto Terokkar Forest,44.07,64.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Isfar|r
.turnin 10097 >>Turn in Brother Against Brother
.target Isfar
.isQuestComplete 10097
step
#label SethekkTurnins
.goto Terokkar Forest,44.07,64.96
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Isfar|r
.turnin 10098 >>Turn in Terokk's Legacy
.target Isfar
.isQuestComplete 10098
step
+|cRXP_WARN_This is the end of the Sethekk Halls guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 60-70
<< Horde !classic
#name 128 Shadow Labyrinth
#displayname 28. Shadow Labyrinth
step
#optional
+|cRXP_WARN_The Shadow Labyrinth quests require a minimum level of 68. It is recommended to come back once you have reached this level|r
.xp >68,1
step
#optional
#completewith KaraAttuneQ
.zone Shattrath City >>Travel to |cFFfa9602Shattrath City|r
step
#optional
.goto Shattrath City,54.74,44.32
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khadgar|r
.turnin 9829 >>Turn in Khadgar
.accept 9831 >>Accept Entry Into Karazhan
.target Khadgar
.isOnQuest 9829
step
#optional
#label KaraAttuneQ
.goto Shattrath City,54.74,44.32
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khadgar|r
.accept 9831 >>Accept Entry Into Karazhan
.target Khadgar
.isQuestTurnedIn 9829
step
#completewith EnterSL
.goto Terokkar Forest,39.64,71.10,15 >>Travel to the |cFFfa9602Shadow Labyrinth|r in Auchindoun
step
.goto Terokkar Forest,40.05,72.17
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Field Commander Mahfuun|r
.accept 10094 >>Accept The Codex of Blood
.target Field Commander Mahfuun
step
.goto Terokkar Forest,39.93,72.29
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spy Grik'tha|r
.accept 10178 >>Accept Find Spy To'gun
.target Spy Grik'tha
step
#label EnterSL
.goto Terokkar Forest,39.64,73.49,10 >>Enter the Shadow Labyrinth
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Field Commander Mahfuun|r
>>|cRXP_FRIENDLY_Spy To'gun|r |cRXP_WARN_is located down the hallway behind|r |cRXP_ENEMY_Ambassador Hellmaw|r
.turnin 10178 >>Turn in Find Spy To'gun
.accept 10091 >>Accept The Soul Devices
.target Spy To'gun
.isOnQuest 10178
step
#optional
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Field Commander Mahfuun|r
>>|cRXP_FRIENDLY_Spy To'gun|r |cRXP_WARN_is located down the hallway behind|r |cRXP_ENEMY_Ambassador Hellmaw|r
.accept 10091 >>Accept The Soul Devices
.target Spy To'gun
.isQuestTurnedIn 10178
step
#completewith FirstKeyFrag
>>Loot the |cRXP_PICK_Soul Devices|r on the ground
.complete 10091,1 
.isOnQuest 10091
step
>>Click the |cRXP_PICK_The Codex of Blood|r
>>|cRXP_WARN_This is located beneath|r |cRXP_ENEMY_Grandmaster Vorpil|r
.turnin 10094 >>Turn in The Codex of Blood
.accept 10095 >>Accept Into the Heart of the Labyrinth
.isOnQuest 10094
step
#optional
>>Click the |cRXP_PICK_The Codex of Blood|r
>>|cRXP_WARN_This is located beneath|r |cRXP_ENEMY_Grandmaster Vorpil|r
.accept 10095 >>Accept Into the Heart of the Labyrinth
step
>>Kill |cRXP_ENEMY_Murmur|r
.complete 10095,1 
.isOnQuest 10095
step
#label FirstKeyFrag
>>|cRXP_WARN_After you kill |cRXP_ENEMY_Murmur|r, open the |cRXP_PICK_Arcane Container|r on the ground to spawn the|r |cRXP_ENEMY_First Fragment Guardian|r
>>Kill the |cRXP_ENEMY_First Fragment Guardian|r. Loot it for the |cRXP_LOOT_First Key Fragment|r
.complete 9831,1 
.mob First Fragment Guardian
.isOnQuest 9831
step
>>Loot the |cRXP_PICK_Soul Devices|r on the ground
.complete 10091,1 
.isOnQuest 10091
step
#completewith ShatTurnins
.zone Shattrath City >>Travel to |cFFfa9602Shattrath City|r
step
.goto Shattrath City,50.24,45.36
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spymistress Mehlisah Highcrown|r
.turnin 10091 >>Turn in The Soul Devices
.turnin 10095 >>Turn in Into the Heart of the Labyrinth
.target Spymistress Mehlisah Highcrown
.isQuestComplete 10091
.isQuestComplete 10095
step
#optional
.goto Shattrath City,50.24,45.36
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spymistress Mehlisah Highcrown|r
.turnin 10095 >>Turn in Into the Heart of the Labyrinth
.target Spymistress Mehlisah Highcrown
.isQuestComplete 10095
step
#optional
.goto Shattrath City,50.24,45.36
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spymistress Mehlisah Highcrown|r
.turnin 10091 >>Turn in The Soul Devices
.target Spymistress Mehlisah Highcrown
.isQuestComplete 10091
step
#optional
#label ShatTurnins
.goto Shattrath City,54.73,44.33
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khadgar|r
.turnin 9831 >>Turn in Entry Into Karazhan
.target Khadgar
.isQuestComplete 9831
step
+|cRXP_WARN_This is the end of the Shadow Labyrinth guide. Please pick another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 60-70
<< Horde !classic
#name 129 Old Hillsbrad (Escape from Durnholde)
#displayname 29. Old Hillsbrad (Escape from Durnholde)
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
+|cRXP_WARN_You have completed the Old Hillsbrad (Escape from Durnholde) quest guide. Please select another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 60-70
<< Horde !classic
#name 30 Black Morass (Opening the Dark Portal)
#displayname 30. Black Morass (Opening the Dark Portal)
step
#optional
.isQuestAvailable 10285
+|cRXP_WARN_You must first complete Old Hillsbrad (Escape from Durnholde) in order to enter Black Morass (Opening the Dark Portal)|r
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
+|cRXP_WARN_You have completed the Black Morass (Opening the Dark Portal) quest guide. Please select another guide to continue|r
]]);
RXPGuides.RegisterGuide([[
#classic
#tbc
#wotlk
#version 1
#group RestedXP Dungeon Quest Guides (H)
#subgroup 60-70
<< Horde !classic
#name 31 The Steamvault
#displayname 31. The Steamvault
step
#optional
#completewith next
.zone Shattrath City >>Travel to |cFFfa9602Shattrath City|r
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
+|cRXP_WARN_This is the end of the Steamvault guide. Please pick another guide to continue|r
]]);
