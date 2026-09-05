-- Generated from RXPGuides v4.10.20 by tools/Build-TBCGuides335.ps1.
-- Curated for the standalone 3.3.5a backport; do not replace with the upstream aggregate file.
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#group RXP TBC Reputation Guide
#subgroup Ogri'la
#name 0_Ogrila Unlock
#next 1_Ogrila Dailies
#displayname |cFF1EFF000|r - Ogri'la Quests
#title Ogri'la
step
+|cRXP_WARN_The Ogri'la daily quests will not unlock until Phase 2 has launched. This is currently estimated to go live in Spring 2026|r
step
#completewith Grok
.zone 1955 >> Travel to Shattrath City
step
.goto Shattrath City,56.471,49.096
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_V'eru|r
.target V'eru
.accept 10984 >>Accept Speak with the Ogre
step
#label Grok
.goto Shattrath City,64.931,68.124
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Grok|r
.target Grok
.turnin 10984 >>Turn in Speak with the Ogre
.accept 10983 >>Accept Mog'dorg the Wizened
step
#completewith Maggoc
.zone 1949 >> Travel to Blade's Edge Mountains
step
.goto Blade's Edge Mountains,55.486,44.852
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mog'dorg the Wizened|r
.target Mog'dorg the Wizened
.turnin 10983 >>Turn in Mog'dorg the Wizened
.accept 10995 >>Accept Grulloc Has Two Skulls
.accept 10996 >>Accept Maggoc's Treasure Chest
.accept 10997 >>Accept Even Gronn Have Standards
step
.goto Blade's Edge Mountains,60.931,47.617
>>Kill |cRXP_ENEMY_Grulloc|r. Loot |cRXP_PICK_Grulloc's Dragon Skull|r that drops on the ground
>>|cRXP_WARN_You will need a group for this quest. If someone else has killed him, you can still loot |cRXP_PICK_Grulloc's Dragon Skull|r on the ground|r
.complete 10995,1 
.mob Grulloc
step
#label Maggoc
#loop
.goto Blade's Edge Mountains,58.166,62.65,70,0
.goto Blade's Edge Mountains,61.494,55.187,70,0
.goto Blade's Edge Mountains,67.044,57.053,70,0
.goto Blade's Edge Mountains,68.207,71.818,70,0
>>Kill |cRXP_ENEMY_Maggoc|r. Loot |cRXP_PICK_Maggoc's Treasure Chest|r that drops on the ground
>>|cRXP_WARN_You will need a group for this quest. If someone else has killed him, you can still loot |cRXP_PICK_Maggoc's Treasure Chest|r on the ground|r
>>|cRXP_ENEMY_Maggoc|r |cRXP_WARN_patrols a large area|r
.complete 10996,1 
.mob Maggoc
step
#completewith Grok
.zone 1952 >> Travel to the Barrier Hills above Shattrath City
step
.goto Terokkar Forest,20.439,17.639
>>Kill |cRXP_ENEMY_Slaag|r. Loot |cRXP_PICK_Slaag's Standard|r that drops on the ground
>>|cRXP_WARN_You will need a group for this quest. If someone else has killed him, you can still loot |cRXP_PICK_Slaag's Standard|r on the ground|r
.complete 10997,1 
.mob Maggoc
step
#completewith OgreHeaven
.zone 1949 >> Return to Blade's Edge Mountains
step
.goto Blade's Edge Mountains,55.486,44.852
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mog'dorg the Wizened|r
.target Mog'dorg the Wizened
.turnin 10995 >>Turn in Grulloc Has Two Skulls
.turnin 10996 >>Turn in Maggoc's Treasure Chest
.turnin 10997 >>Turn in Even Gronn Have Standards
.accept 10998 >>Accept Grim(oire) Business
step
.goto Blade's Edge Mountains,77.521,31.209
>>Kill |cRXP_ENEMY_Vim'gol the Vile|r. Loot |cRXP_PICK_Vim'gol's Vile Grimoire|r that drops on the ground
>>|cRXP_WARN_You will need a group for this quest. If someone else has killed him, you can still loot |cRXP_PICK_Vim'gol's Vile Grimoire|r on the ground|r
>>|cRXP_WARN_NOTE: You must have 5 players stand in the fire rings in order to summon|r |cRXP_ENEMY_Vim'gol the Vile|r
.complete 10998,1 
.mob Vim'gol the Vile
step
.goto Blade's Edge Mountains,55.488,44.849
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mog'dorg the Wizened|r
.target Mog'dorg the Wizened
.turnin 10998 >>Turn in Grim(oire) Business
.accept 11000 >>Accept Into the Soulgrinder
step
.goto Blade's Edge Mountains,60.001,24.145
.use 32467 >>|cRXP_WARN_Use|r |T133738:0|t[Vim'gol's Grimoire] |cRXP_WARN_at the Soulgrinder's Barrow to begin the encounter|r
>>Kill the |cRXP_ENEMY_Sundered Spirits|r that spawn. After approx 3 minutes, |cRXP_ENEMY_Skulloc Soulgrinder|r will spawn
>>Kill |cRXP_ENEMY_Skulloc Soulgrinder|r. Loot |cRXP_PICK_Skulloc's Soul|r that drops on the ground
>>|cRXP_WARN_You will need a group for this quest. If someone else has killed him, you can still loot |cRXP_PICK_Skulloc's Soul|r on the ground|r
.complete 11000,1 
.mob Skulloc Soulgrinder
step
#label OgreHeaven
.goto Blade's Edge Mountains,55.488,44.849
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mog'dorg the Wizened|r
.target Mog'dorg the Wizened
.turnin 11000 >>Turn in Into the Soulgrinder
.accept 11009 >>Accept Ogre Heaven
step
#completewith next
.subzone 3786 >> Travel to Ogri'la
step
.goto Blade's Edge Mountains,28.758,57.36
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chu'a'lor|r
.target Chu'a'lor
.turnin 11009 >>Turn in Ogre Heaven
.accept 11025 >>Accept The Crystals
step
#loop
.goto 1949,29.6,68.4,70,0
.goto 1949,30.2,47.4,70,0
>>Kill the |cRXP_ENEMY_creatures|r atop the mountains. Loot them for their |cRXP_LOOT_Apexis Shards|r
>>|cRXP_PICK_Apexis Shard Formations|r |cRXP_WARN_can also be looted nearby|r |cRXP_ENEMY_Apexis Flayers|r
.complete 11025,1 
step
.goto Blade's Edge Mountains,28.751,57.355
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chu'a'lor|r
.target Chu'a'lor
.turnin 11025 >>Turn in The Crystals
.accept 11058 >>Accept An Apexis Relic
step
.goto Blade's Edge Mountains,28.373,57.642
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Torkus|r
.target Torkus
.accept 11030 >>Accept Our Boy Wants To Be A Skyguard Ranger
step
.goto Blade's Edge Mountains,33.134,52.317
>>Look for an |cRXP_PICK_Apexis Monument|r surrounded by |cRXP_PICK_Apexis Relics|r. Stand underneath the |cRXP_PICK_Apexis Relic|r and talk to it to begin the memory game
>>|cRXP_WARN_The |cRXP_PICK_Apexis Relic|r will randomly illuminate one of the four colored |cRXP_PICK_Clusters|r on the ground, after which you will need to click that corresponding|r |cRXP_PICK_Cluster|r
>>|cRXP_WARN_After each round, the number of |cRXP_PICK_Clusters|r it illuminates will increase by one. Repeat this process until the quest completes|r
>>|cRXP_WARN_You will need one |cRXP_LOOT_Apexis Shard|r to begin|r
.collect 32569,1,11058,1 
.complete 11058,1 
step
.goto Blade's Edge Mountains,32.786,40.469
>>Click the |cRXP_PICK_Fel Crystalforge|r to receive an |cRXP_LOOT_Unstable Flask of the Beast|r
>>|cRXP_WARN_You will need 10|r |cRXP_LOOT_Apexis Shards|r
.collect 32569,10,11030,1 
.complete 11030,1 
step
.goto Blade's Edge Mountains,28.756,57.363
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chu'a'lor|r
.target Chu'a'lor
.turnin 11058 >>Turn in An Apexis Relic
step
.goto Blade's Edge Mountains,28.375,57.645
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Torkus|r
.target Torkus
.turnin 11030 >>Turn in Our Boy Wants To Be A Skyguard Ranger
.accept 11061 >>Accept A Father's Duty
step
.goto Blade's Edge Mountains,28.756,57.363
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chu'a'lor|r
.target Chu'a'lor
.daily 11080 >>Accept The Relic's Emanation
step
.isOnQuest 11080
.goto Blade's Edge Mountains,33.134,52.317
>>Stand underneath an |cRXP_PICK_Apexis Relic|r and talk to it to begin the memory game
>>|cRXP_WARN_The |cRXP_PICK_Apexis Relic|r will randomly illuminate one of the four colored |cRXP_PICK_Clusters|r on the ground, after which you will need to click that corresponding|r |cRXP_PICK_Cluster|r
>>|cRXP_WARN_After each round, the number of |cRXP_PICK_Clusters|r it illuminates will increase by one. Repeat this process until the quest completes|r
>>|cRXP_WARN_You will need one |cRXP_LOOT_Apexis Shard|r to begin|r
.collect 32569,1,11080,1 
.complete 11080,1 
step
.isOnQuest 11080
.goto Blade's Edge Mountains,28.758,57.358
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chu'a'lor|r
.target Chu'a'lor
.dailyturnin 11080 >>Turn in The Relic's Emanation
step
.goto Blade's Edge Mountains,28.758,57.358
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chu'a'lor|r
.target Chu'a'lor
.accept 11062 >>Accept The Skyguard Outpost
step
.goto Blade's Edge Mountains,27.405,52.693
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Commander Keller|r
.target Sky Commander Keller
.turnin 11062 >>Turn in The Skyguard Outpost
step
.goto Blade's Edge Mountains,27.575,52.903
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Sergeant Vanderlip|r
.target Sky Sergeant Vanderlip
.accept 11010 >>Accept Bombing Run << !Druid
.accept 11102 >>Accept Bombing Run << Druid
step
#loop
.goto 1949,36.0,39.6,0
.goto 1949,29.4,84.2,0
.goto 1949,33.8,43.8,30,0
.goto 1949,32.2,40.8,30,0
.goto 1949,36.0,39.6,30,0
.goto 1949,29.4,84.2,30,0
.use 32456 >> |cRXP_WARN_Use the|r |T133712:0|t[Skyguard Bombs] |cRXP_WARN_on the |cRXP_PICK_Fel Cannonball Stacks|r. These are beside the|r |cRXP_ENEMY_Legion Flak Cannons|r
.complete 11010,1 << !Druid 
.complete 11102,1 << Druid 
step
.goto Blade's Edge Mountains,27.575,52.903
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Sergeant Vanderlip|r
.target Sky Sergeant Vanderlip
.turnin 11010 >>Turn in Bombing Run << !Druid
.turnin 11102 >>Turn in Bombing Run << Druid
step << skip
.goto Blade's Edge Mountains,27.575,52.903
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Sergeant Vanderlip|r
.target Sky Sergeant Vanderlip
.daily 11023 >>Accept Bomb Them Again!
step
.goto Blade's Edge Mountains,27.405,52.69
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Commander Keller|r
.target Sky Commander Keller
.accept 11119 >>Accept Assault on Bash'ir Landing!
step
.goto Blade's Edge Mountains,27.897,52.168
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Aether-tech Apprentice|r
.target Aether-tech Apprentice
.turnin 11119 >>Turn in Assault on Bash'ir Landing!
step
.goto Blade's Edge Mountains,27.949,51.449
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Skyguard Khatie|r
.target Skyguard Khatie
.accept 11065 >>Accept Wrangle Some Aether Rays!
step
#loop
.goto 1949,30.2,66.6,0
.goto 1949,31.8,57.8,0
.goto 1949,29.0,47.0,0
.goto 1949,30.2,66.6,70,0
.goto 1949,31.8,57.8,70,0
.goto 1949,29.0,47.0,70,0
>>Attack |cRXP_ENEMY_Aether Rays|r to 40% HP
.use 32698 >>|cRXP_WARN_Use the |T134326:0|t[Wrangling Rope] on them once they are below 40% HP|r
.complete 11065,1 
step
.goto Blade's Edge Mountains,27.949,51.452
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Skyguard Khatie|r
.target Skyguard Khatie
.turnin 11065 >>Turn in Wrangle Some Aether Rays!
step << skip
.daily 11066 >>Accept Wrangle More Aether Rays!
step
.goto Blade's Edge Mountains,28.758,57.358
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chu'a'lor|r
.target Chu'a'lor
.accept 11059 >>Accept Guardian of the Monument
step
.goto Blade's Edge Mountains,33.411,51.836
>>Stand underneath an |cRXP_PICK_Apexis Monument|r and talk to it to begin the memory game
>>|cRXP_WARN_You will need a group for this quest|r
>>|cRXP_WARN_The |cRXP_PICK_Apexis Monument|r will randomly illuminate one of the four colored |cRXP_PICK_Clusters|r on the ground, after which you will need to click that corresponding|r |cRXP_PICK_Cluster|r
>>|cRXP_WARN_After each round, the number of |cRXP_PICK_Clusters|r it illuminates will increase by one|r
>>After 6 rounds, the |cRXP_ENEMY_Apexis Guardian|r will spawn. Kill it. Loot it for the |cRXP_LOOT_Apexis Guardian's Head|r
>>|cRXP_WARN_You will need 35 |cRXP_LOOT_Apexis Shards|r to begin|r
.collect 32569,35,11059,1 
.complete 11059,1 
.mob Apexis Guardian
step
.goto Blade's Edge Mountains,28.754,57.363
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chu'a'lor|r
.target Chu'a'lor
.turnin 11059 >>Turn in Guardian of the Monument
.accept 11091 >>Accept A Special Thank You
step
.goto Blade's Edge Mountains,28.061,58.735
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Jho'nass|r
.target Jho'nass
.turnin 11091 >>Turn in A Special Thank You
step
#completewith next
.subzone 3864 >> Travel to Bash'ir Landing
step
.goto Blade's Edge Mountains,54.386,10.718
>>Click the |cRXP_PICK_Bash'ir Crystalforge|r
>>|cRXP_WARN_You will need 10|r |cRXP_LOOT_Apexis Shards|r
.collect 32569,10,11061,1 
.complete 11061,1 
.skipgossip
step
#completewith next
.subzone 3786 >> Return to Ogri'la
step
.goto Blade's Edge Mountains,28.371,57.642
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Torkus|r
.target Torkus
.turnin 11061 >>Turn in A Father's Duty
step
.goto Blade's Edge Mountains,28.48,58.085
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gahk|r
.target Gahk
.accept 11079 >>Accept A Fel Whip For Gahk
step
.goto Blade's Edge Mountains,31.61,39.236,0
.goto Blade's Edge Mountains,30.207,77.171
>>Click the |cRXP_PICK_Fel Crystal Prism|r to summon a random |cRXP_ENEMY_Demon|r
>>Kill the |cRXP_ENEMY_Demon|r. Loot it for its |cRXP_LOOT_Fel Whip|r
>>|cRXP_WARN_You will need a group for this quest|r
>>|cRXP_WARN_You will need 35 |cRXP_LOOT_Apexis Shard|r to summon it|r
.complete 11079,1 
.mob Braxxus
.mob Mo'arg Incinerator
.mob Galvanoth
.mob Zarcsin
step
.goto Blade's Edge Mountains,28.482,58.082
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gahk|r
.target Gahk
.turnin 11079 >>Turn in A Fel Whip For Gahk
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#group RXP TBC Reputation Guide
#subgroup Sha'tari Skyguard
#name 0_Shatari Skyguard Unlock
#next 1_Shatari Skyguard Dailies
#displayname |cFF1EFF000|r - Sha'tari Skyguard Quests
#title Sha'tari Skyguard
step
+|cRXP_WARN_The Sha'tari Skyguard daily quests will not unlock until Phase 2 has launched. This is currently estimated to go live in Spring 2026|r
step
#completewith ToSkettis
.zone 1955 >> Travel to Shattrath City
step
.goto Shattrath City,64.326,42.333
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yuula|r
.target Yuula
.accept 11096 >>Accept Threat from Above
step
#loop
.goto Terokkar Forest,26.412,10.039,55,0
.goto Terokkar Forest,22.451,9.133,55,0
.goto Terokkar Forest,20.519,15.733,55,0
>>Kill |cRXP_ENEMY_Gordunni Ogres|r above Shattrath City
.complete 11096,1 
.mob Gordunni Back-Breaker
.mob Gordunni Head-Splitter
.mob Gordunni Elementalist
.mob Gordunni Soulreaper
step
#label ToSkettis
.goto Shattrath City,64.318,42.333
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yuula|r
.target Yuula
.turnin 11096 >>Turn in Threat from Above
.accept 11098 >>Accept To Skettis!
step
#completewith next
.subzone 3973 >> Travel to Blackwind Landing
step
.goto Terokkar Forest,64.545,66.7
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Sergeant Doryn|r
.target Sky Sergeant Doryn
.turnin 11098 >>Turn in To Skettis!
step
.goto Terokkar Forest,64.545,66.7
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Sergeant Doryn|r
.target Sky Sergeant Doryn
.daily 11008 >>Accept Fires Over Skettis
step
.goto Terokkar Forest,64.052,66.878
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Severin|r
.target Severin
.accept 11004 >>Accept World of Shadows
step
.goto Terokkar Forest,63.497,65.811
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Skyguard Handler Deesak|r
.target Skyguard Handler Deesak
.accept 11093 >>Accept Hungry Nether Rays
step
#completewith ShadowDust
#label EscapeSkettis
>>|cRXP_WARN_Keep an eye out for the |cRXP_FRIENDLY_Skyguard Prisoner|r. Talk to him to begin the escort quest. He spawns randomly in one of the tree houses|r
.daily 11085 >>Accept Escape from Skettis
.target Skyguard Prisoner
step
#sticky
.isOnQuest 11085
#optional
#requires EscapeSkettis
>>|cRXP_WARN_Escort the |cRXP_FRIENDLY_Skyguard Prisoner|r from the tree house you are on|r
.complete 11085,1 
.target Skyguard Prisoner
step
#sticky
#label KaliriEggs
.isOnQuest 11008
#loop
.goto Terokkar Forest,69.365,74.467,45,0
.goto Terokkar Forest,71.586,82.389,45,0
.goto Terokkar Forest,74.467,80.586,45,0
.goto Terokkar Forest,74.576,88.361,45,0
.goto Terokkar Forest,67.788,85.489,45,0
.goto Terokkar Forest,61.471,73.411,45,0
.use 32406 >> |cRXP_WARN_Use the|r |T133715:0|t[Skyguard Blasting Charges] |cRXP_WARN_on|r |cRXP_PICK_Monstrous Kaliri Eggs|r
>>|cRXP_WARN_These are found on the top of tree houses/roofs|r
.complete 11008,1 
.mob Monstrous Kaliri Egg
step
#sticky
#label ShadowDust
#loop
.goto 1952,61.2,75.0,0
.goto 1952,69.8,76.2,0
.goto 1952,75.0,82.8,0
.goto 1952,72.2,87.8,0
.goto 1952,61.2,75.0,70,0
.goto 1952,69.8,76.2,70,0
.goto 1952,75.0,82.8,70,0
.goto 1952,72.2,87.8,70,0
>>Kill the |cRXP_ENEMY_Arakoa|r. Loot them for their |cRXP_LOOT_Shadow Dust|r
.complete 11004,1 
.mob Skettis Talonite
.mob Skettis Soulcaller
.mob Skettis Windwalker
.mob Skettis Wing Guard
.mob Talonsworn Forest-Rager
.mob Skettis Kaliri
.mob Time-Lost Skettis Worshipper
.mob Time-Lost Skettis High Priest
.mob Time-Lost Skettis Reaver
step
#requires ShadowDust
step
#requires KaliriEggs
step
#completewith next
.cast 41423 >> |cRXP_WARN_Use the|r |T132599:0|t[Nether Ray Cage] |cRXP_WARN_to summon the|r |cRXP_FRIENDLY_Hungry Nether Ray|r
.use 32834
step
#loop
.goto 1952,62.6,72.0,0
.goto 1952,61.8,82.0,0
.goto 1952,67.2,86.6,0
.goto 1952,70.2,89.0,0
.goto 1952,62.6,72.0,60,0
.goto 1952,61.8,82.0,60,0
.goto 1952,67.2,86.6,60,0
.goto 1952,70.2,89.0,60,0
.goto 1952,67.2,72.8,60,0
.use 32834 >>Kill |cRXP_ENEMY_Blackwind Warp Chasers|r
>>|cRXP_WARN_Ensure you are close to them when they die and the |cRXP_FRIENDLY_Hungry Nether Ray|r is next to you|r
.complete 11093,1 
.mob Blackwind Warp Chaser
step
#loop
.goto 1952,61.0,75.6,20,0
.goto 1952,68.4,74.0,20,0
.goto 1952,75.0,86.2,20,0
>>|cRXP_WARN_Keep an eye out for the |cRXP_FRIENDLY_Skyguard Prisoner|r. Talk to him to begin the escort quest. He spawns randomly in one of the tree houses|r
.daily 11085 >>Accept Escape from Skettis
.target Skyguard Prisoner
step
.isOnQuest 11085
>>|cRXP_WARN_Escort the |cRXP_FRIENDLY_Skyguard Prisoner|r from the tree house you are on|r
.complete 11085,1 
.target Skyguard Prisoner
step
.isOnQuest 11008
.goto Terokkar Forest,64.547,66.697
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Sergeant Doryn|r
.target Sky Sergeant Doryn
.dailyturnin 11008 >>Turn in Fires Over Skettis
step
.isQuestComplete 11085
.goto Terokkar Forest,64.547,66.697
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Sergeant Doryn|r
.target Sky Sergeant Doryn
.dailyturnin 11085 >>Turn in Escape from Skettis
step 
.goto Terokkar Forest,64.052,66.878
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Severin|r
.target Severin
.turnin 11004 >>Turn in World of Shadows
step
.goto Terokkar Forest,64.084,66.9
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Commander Adaris|r
.target Sky Commander Adaris
.accept 11005 >>Accept Secrets of the Talonpriests
step
.goto Terokkar Forest,63.497,65.811
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Skyguard Handler Deesak|r
.target Skyguard Handler Deesak
.turnin 11093 >>Turn in Hungry Nether Rays
step
#completewith next
.aura 37678 >> |cRXP_WARN_Use the|r |T134711:0|t[Elixir of Shadows] |cRXP_WARN_to gain the|r |T136152:0|t[Elixir of Shadows] |cRXP_WARN_buff. This buff lasts for 20 minutes|r
step
>>Kill |cRXP_ENEMY_Talonpriest Ishaal|r, |cRXP_ENEMY_Talonpriest Skizzik|r and |cRXP_ENEMY_Talonpriest Zellek|r
>>Loot |cRXP_ENEMY_Talonpriest Ishaal|r for |T133738:0|t[|cRXP_LOOT_Ishaal's Almanac|r]
.use 32523 >> |cRXP_WARN_Use|r |T133738:0|t[|cRXP_LOOT_Ishaal's Almanac|r] |cRXP_WARN_to begin the quest|r
>>|cRXP_WARN_You must have the|r |T136152:0|t[Elixir of Shadows] |cRXP_WARN_buff in order to see them. If you have lost the buff, kill the |cRXP_ENEMY_Arakoa|r for 6 |cRXP_LOOT_Shadow Dust|r and turn it in to |cRXP_FRIENDLY_Severin|r to receive more|r |T134711:0|t[Elixir of Shadows]
.collect 32523,1,11021,1 
.accept 11021 >> Accept Ishaal's Almanac
.complete 11005,1 
.goto Terokkar Forest,69.325,78.172,-1
.mob +Talonpriest Ishaal
.complete 11005,2 
.goto Terokkar Forest,69.791,81.842,-1
.mob +Talonpriest Skizzik
.complete 11005,3 
.goto Terokkar Forest,70.167,74.381,-1
.mob +Talonpriest Zellek
step
#loop
.goto 1952,69.6,76.0,70,0
.goto 1952,70.0,83.6,70,0
.goto 1952,75.2,81.6,70,0
.goto 1952,73.0,87.8,70,0
.goto 1952,66.6,80.2,70,0
.goto 1952,62.0,75.8,70,0
+|cRXP_WARN_NOTE: While you have the|r |T136152:0|t[Elixir of Shadows] |cRXP_WARN_buff, it is highly advised to kill |cRXP_ENEMY_Time-Lost Skettis Worshippers|r, |cRXP_ENEMY_Time-Lost Skettis Reavers|r and |cRXP_ENEMY_Time-Lost Skettis High Priests|r and loot them for their|r |cRXP_LOOT_Time-Lost Scrolls|r
>>|cRXP_WARN_Soon you will need 40 of these pages for an upcoming quest. |cRXP_LOOT_Time-Lost Scrolls|r can also be bought from the auction house however they may be expensive|r
>>|cRXP_WARN_These NPCs can only ever be seen while you have this buff|r
>>|cRXP_WARN_Skip this step if you wish to acquire these later|r
.collect 32620,40 
.aura -37678
.mob Time-Lost Skettis Worshipper
.mob Time-Lost Skettis Reaver
.mob Time-Lost Skettis High Priest
step
.goto Terokkar Forest,64.082,66.908
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Commander Adaris|r
.target Sky Commander Adaris
.turnin 11005 >>Turn in Secrets of the Talonpriests
.turnin 11021 >>Turn in Ishaal's Almanac
.accept 11024 >>Accept An Ally in Lower City
step
#completewith next
.zone 1955 >> Travel to Shattrath City
step
.goto Shattrath City,52.529,21.008
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Rilak the Redeemed|r
.target Rilak the Redeemed
.turnin 11024 >>Turn in An Ally in Lower City
.accept 11028 >>Accept Countdown to Doom
step
#completewith next
.subzone 3973 >> Travel to Blackwind Landing
step
.goto Terokkar Forest,64.082,66.906
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Commander Adaris|r
.target Sky Commander Adaris
.turnin 11028 >>Turn in Countdown to Doom
step
.goto Terokkar Forest,64.23,66.964
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hazzik|r
.target Hazzik
.accept 11056 >>Accept Hazzik's Bargain
step
.goto Terokkar Forest,74.852,80.083
>>Loot |cRXP_PICK_Hazzik's Package|r inside the hut
.complete 11056,1 
step
.goto Terokkar Forest,64.23,66.961
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hazzik|r
.target Hazzik
.turnin 11056 >>Turn in Hazzik's Bargain
.accept 11029 >>Accept A Shabby Disguise
step
.isOnQuest 11029
.subzone 3975 >> Head to Terokk's Rest
step
#completewith next
.cast 41181 >> |cRXP_WARN_Use the|r |T133707:0|t[Shabby Arakkoa Disguise]
.use 32741
step
.goto Terokkar Forest,67.014,79.656
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sahaak|r
>>|cRXP_BUY_Buy the|r [Adversarial Bloodlines] |cRXP_WARN_from him|r
.complete 11029,1 
.target Sahaak
step
.goto Terokkar Forest,64.23,66.967
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hazzik|r
.target Hazzik
.turnin 11029 >>Turn in A Shabby Disguise
.accept 11885 >>Accept Adversarial Blood
step
#loop
.goto 1952,61.2,75.0,0
.goto 1952,69.8,76.2,0
.goto 1952,75.0,82.8,0
.goto 1952,72.2,87.8,0
.goto 1952,61.2,75.0,70,0
.goto 1952,69.8,76.2,70,0
.goto 1952,75.0,82.8,70,0
.goto 1952,72.2,87.8,70,0
>>|cRXP_WARN_Kill the |cRXP_ENEMY_Arakoa|r. Loot them for their|r |cRXP_LOOT_Shadow Dust|r
>>|cRXP_WARN_Once you have 6 |cRXP_LOOT_Shadow Dust|r, talk to |cRXP_FRIENDLY_Severin|r to receive an|r |T134711:0|t[Elixir of Shadows]
>>|cRXP_WARN_Use the|r |T134711:0|t[Elixir of Shadows] |cRXP_WARN_to gain the 20 minute|r |T136152:0|t[Elixir of Shadows] |cRXP_WARN_buff|r
>>|cRXP_WARN_While you have this buff, kill |cRXP_ENEMY_Time-Lost Skettis Worshippers|r, |cRXP_ENEMY_Time-Lost Skettis Reavers|r and |cRXP_ENEMY_Time-Lost Skettis High Priests|r. Loot them for their|r |cRXP_LOOT_Time-Lost Scrolls|r
>>|cRXP_WARN_Once you have 40 |cRXP_LOOT_Time-Lost Scrolls|r, click one of the |cRXP_PICK_Skull Piles|r in Skettis to summon the |cRXP_ENEMY_Descendants|r. 10 |cRXP_LOOT_Time-Lost Scrolls|r is required per summon. These can also be bought from the auction house. Try to find at least 1-2 other players before you summon as they can be dangerous|r
>>Kill |cRXP_ENEMY_Darkscreecher Akkarai|r, |cRXP_ENEMY_Karrog|r, |cRXP_ENEMY_Gezzarak the Huntress|r and |cRXP_ENEMY_Vakkiz the Windrager|r
.collect 32388,6 
.disablecheckbox
.collect 32620,40 
.disablecheckbox
.complete 11885,1 
.mob +Darkscreecher Akkarai
.complete 11885,2 
.mob +Karrog
.complete 11885,3 
.mob +Gezzarak the Huntress
.complete 11885,4 
.mob +Vakkiz the Windrager
.mob Time-Lost Skettis Worshipper
.mob Time-Lost Skettis Reaver
.mob Time-Lost Skettis High Priest
step
.goto Terokkar Forest,64.23,66.967
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Hazzik|r
.target Hazzik
.turnin 11885 >>Turn in Adversarial Blood
step
.goto Terokkar Forest,64.082,66.903
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Commander Adaris|r
.target Sky Commander Adaris
.accept 11073 >>Accept Terokk's Downfall
step
.goto Terokkar Forest,66.214,77.486
>>Click the |cRXP_PICK_Ancient Skull Pile|r to summon |cRXP_ENEMY_Terokk|r
>>Kill |cRXP_ENEMY_Terokk|r
>>|cRXP_WARN_You will need a group for this quest|r
.complete 11073,1 
.mob Terokk
step
.goto Terokkar Forest,64.082,66.903
>>Talk to |cRXP_FRIENDLY_Sky Commander Adaris|r
.turnin 11073 >>Turn in Terokk's Downfall
.target Sky Commander Adaris
step
+|cRXP_WARN_You have completed all of the Sha'tari Skyguard quests in Skettis. If you have not already, complete the quests in Ogri'la, as that also contains daily quests that award reputation with the Sha'tari Skyguard|r
.subzoneskip 3973,1 
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#group RXP TBC Reputation Guide
#subgroup Ogri'la
#name 1_Ogrila Dailies
#displayname |cFF1EFF001|r - Daily Quests
#title Ogri'la Dailies
step
+|cRXP_WARN_The Ogri'la daily quests will not unlock until Phase 2 has launched. This is currently estimated to go live in Spring 2026|r
step
.isQuestTurnedIn 11026
.goto Blade's Edge Mountains,28.9,57.919
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kronk|r
.daily 11051 >> Accept Banish More Demons
.target Kronk
step
.goto Blade's Edge Mountains,28.756,57.363
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chu'a'lor|r
.target Chu'a'lor
.daily 11080 >>Accept The Relic's Emanation
step
.goto Blade's Edge Mountains,27.575,52.903
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Sergeant Vanderlip|r
.target Sky Sergeant Vanderlip
.daily 11023 >>Accept Bomb Them Again!
step
.goto Blade's Edge Mountains,27.949,51.452
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Skyguard Khatie|r
.target Skyguard Khatie
.daily 11066 >>Accept Wrangle More Aether Rays!
step
.isOnQuest 11066
#loop
.goto 1949,30.2,66.6,0
.goto 1949,31.8,57.8,0
.goto 1949,29.0,47.0,0
.goto 1949,30.2,66.6,70,0
.goto 1949,31.8,57.8,70,0
.goto 1949,29.0,47.0,70,0
>>Attack |cRXP_ENEMY_Aether Rays|r to 40% HP
.use 32698 >>|cRXP_WARN_Use the |T134326:0|t[Wrangling Rope] on them once they are below 40% HP|r
.complete 11066,1 
step
.isOnQuest 11080
.goto Blade's Edge Mountains,33.134,52.317
>>Stand underneath an |cRXP_PICK_Apexis Relic|r and talk to it to begin the memory game
>>|cRXP_WARN_The |cRXP_PICK_Apexis Relic|r will randomly illuminate one of the four colored |cRXP_PICK_Clusters|r on the ground, after which you will need to click that corresponding|r |cRXP_PICK_Cluster|r
>>|cRXP_WARN_After each round, the number of |cRXP_PICK_Clusters|r it illuminates will increase by one. Repeat this process until the quest completes|r
>>|cRXP_WARN_You will need one |cRXP_LOOT_Apexis Shard|r to begin|r
.collect 32569,1,11080,1 
.complete 11080,1 
step
#completewith next
.isOnQuest 11023
#loop
.goto 1949,36.0,39.6,0
.goto 1949,29.4,84.2,0
.goto 1949,33.8,43.8,30,0
.goto 1949,32.2,40.8,30,0
.goto 1949,36.0,39.6,30,0
.goto 1949,29.4,84.2,30,0
.use 32456 >> |cRXP_WARN_Use the|r |T133712:0|t[Skyguard Bombs] |cRXP_WARN_on the |cRXP_PICK_Fel Cannonball Stacks|r. These are beside the|r |cRXP_ENEMY_Legion Flak Cannons|r
.complete 11023,1 
step
.isOnQuest 11051
#loop
.goto 1949,36.0,39.6,0
.goto 1949,29.4,84.2,0
.goto 1949,33.8,43.8,30,0
.goto 1949,32.2,40.8,30,0
.goto 1949,36.0,39.6,30,0
.goto 1949,29.4,84.2,30,0
.use 32696 >> |cRXP_WARN_Use the|r |T134079:0|t[Banishing Crystal] |cRXP_WARN_then kill the |cRXP_ENEMY_Demons|r near it|r
>>|cRXP_WARN_You must kill the |cRXP_ENEMY_Demons|r within 30 yards of the portal. The portal lasts for 3 minutes|r
>>|cRXP_WARN_You will need one |cRXP_LOOT_Apexis Shard|r to begin|r
.collect 32569,1,11051,1 
.complete 11051,1 
step
.isOnQuest 11023
#loop
.goto 1949,36.0,39.6,0
.goto 1949,29.4,84.2,0
.goto 1949,33.8,43.8,30,0
.goto 1949,32.2,40.8,30,0
.goto 1949,36.0,39.6,30,0
.goto 1949,29.4,84.2,30,0
.use 32456 >> |cRXP_WARN_Use the|r |T133712:0|t[Skyguard Bombs] |cRXP_WARN_on the |cRXP_PICK_Fel Cannonball Stacks|r. These are beside the|r |cRXP_ENEMY_Legion Flak Cannons|r
.complete 11023,1 
step
.isOnQuest 11066
.goto Blade's Edge Mountains,27.949,51.452
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Skyguard Khatie|r
.target Skyguard Khatie
.turnin 11066 >>Turn in Wrangle More Aether Rays!
step
.isOnQuest 11023
.goto Blade's Edge Mountains,27.575,52.903
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Sergeant Vanderlip|r
.target Sky Sergeant Vanderlip
.dailyturnin 11023 >>Turn in Bomb Them Again!
step
.isOnQuest 11080
.goto Blade's Edge Mountains,28.758,57.358
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chu'a'lor|r
.target Chu'a'lor
.dailyturnin 11080 >>Turn in The Relic's Emanation
step
.isOnQuest 11051
.goto Blade's Edge Mountains,28.9,57.919
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kronk|r
.dailyturnin 11051 >>Turn in Banish More Demons
.target Kronk
step 
#optional
.reputation 1038,honored,<0,1
.goto Blade's Edge Mountains,28.9,57.919
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kronk|r
.accept 11026 >> Accept Banish the Demons
.target Kronk
step
#optional
.isOnQuest 11026
#loop
.goto 1949,36.0,39.6,0
.goto 1949,29.4,84.2,0
.goto 1949,33.8,43.8,30,0
.goto 1949,32.2,40.8,30,0
.goto 1949,36.0,39.6,30,0
.goto 1949,29.4,84.2,30,0
.use 32696 >> |cRXP_WARN_Use the|r |T134079:0|t[Banishing Crystal] |cRXP_WARN_then kill the |cRXP_ENEMY_Demons|r near it|r
>>|cRXP_WARN_You must kill the |cRXP_ENEMY_Demons|r within 30 yards of the portal. The portal lasts for 3 minutes|r
>>|cRXP_WARN_You will need one |cRXP_LOOT_Apexis Shard|r to begin|r
.collect 32569,1,11026,1 
.complete 11026,1 
step
#optional
.isOnQuest 11026
.goto Blade's Edge Mountains,28.9,57.919
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kronk|r
.turnin 11026 >>Turn in Banish the Demons
.target Kronk
step
+|cRXP_WARN_You have completed all available daily quests for Ogri'la today. Load the same guide again tomorrow once the daily quests have reset to complete more daily quests|r
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#group RXP TBC Reputation Guide
#subgroup Sha'tari Skyguard
#name 1_Shatari Skyguard Dailies
#displayname |cFF1EFF001|r - Daily Quests
#title Sha'tari Skyguard Dailies
step
+|cRXP_WARN_The Sha'tari Skyguard daily quests will not unlock until Phase 2 has launched. This is currently estimated to go live in Spring 2026|r
step
#completewith next
.subzone 3973 >> Travel to Blackwind Landing
step
.goto Terokkar Forest,64.545,66.7
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Sergeant Doryn|r
.target Sky Sergeant Doryn
.daily 11008 >>Accept Fires Over Skettis
step
#completewith EggDestroyed
#label RescuePrisoner
>>|cRXP_WARN_Keep an eye out for the |cRXP_FRIENDLY_Skyguard Prisoner|r. Talk to him to begin the escort quest. He spawns randomly in one of the tree houses|r
.daily 11085 >>Accept Escape from Skettis
.target Skyguard Prisoner
step
#completewith EggDestroyed
.isOnQuest 11085
#optional
#requires RescuePrisoner
>>|cRXP_WARN_Escort the |cRXP_FRIENDLY_Skyguard Prisoner|r from the tree house you are on|r
.complete 11085,1 
.target Skyguard Prisoner
step
#label EggDestroyed
.isOnQuest 11008
#loop
.goto Terokkar Forest,69.365,74.467,45,0
.goto Terokkar Forest,71.586,82.389,45,0
.goto Terokkar Forest,74.467,80.586,45,0
.goto Terokkar Forest,74.576,88.361,45,0
.goto Terokkar Forest,67.788,85.489,45,0
.goto Terokkar Forest,61.471,73.411,45,0
.use 32406 >> |cRXP_WARN_Use the|r |T133715:0|t[Skyguard Blasting Charges] |cRXP_WARN_on|r |cRXP_PICK_Monstrous Kaliri Eggs|r
>>|cRXP_WARN_These are found on the top of tree houses/roofs|r
.complete 11008,1 
.mob Monstrous Kaliri Egg
step
#loop
.goto 1952,61.0,75.6,20,0
.goto 1952,68.4,74.0,20,0
.goto 1952,75.0,86.2,20,0
>>|cRXP_WARN_Keep an eye out for the |cRXP_FRIENDLY_Skyguard Prisoner|r. Talk to him to begin the escort quest. He spawns randomly in one of the tree houses|r
.daily 11085 >>Accept Escape from Skettis
.target Skyguard Prisoner
step
.isOnQuest 11085
>>|cRXP_WARN_Escort the |cRXP_FRIENDLY_Skyguard Prisoner|r from the tree house you are on|r
.complete 11085,1 
.target Skyguard Prisoner
step
.isOnQuest 11008
.goto Terokkar Forest,64.547,66.697
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Sergeant Doryn|r
.target Sky Sergeant Doryn
.dailyturnin 11008 >>Turn in Fires Over Skettis
step
.isQuestComplete 11085
.goto Terokkar Forest,64.547,66.697
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sky Sergeant Doryn|r
.target Sky Sergeant Doryn
.dailyturnin 11085 >>Turn in Escape from Skettis
step
+|cRXP_WARN_You have completed all available daily quests at Skettis for Sha'tari Skyguard today. If you have not completed the daily quests at Ogri'la yet, load that guide for additional Sha'tari Skyguard daily quests|r
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#group RXP TBC Reputation Guide
#subgroup The Scryers
#name 1. Shattrath City (Scryers)
#next 2. Netherstorm (Scryers)
step
#completewith CityofLight
.zone Shattrath City >> Travel to Shattrath City
step
.goto Shattrath City,59.657,41.428
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Haggard War Veteran|r
.target Haggard War Veteran
.accept 10210 >>Accept A'dal
step
.goto Shattrath City,53.991,44.743
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_A'dal|r
.target A'dal
.turnin 10210 >>Turn in A'dal
step
#label CityofLight
.goto Shattrath City,54.751,44.322
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khadgar|r
.target Khadgar
.accept 10211 >>Accept City of Light
.timer 530,City of Light RP
step << tbc
.goto Shattrath City,50.36,42.87
>>|cRXP_WARN_Head up to the second floor next to |cRXP_FRIENDLY_G'eras|r and wait out the RP|r
>>|cRXP_WARN_If someone else's |cRXP_FRIENDLY_Khadgar's Servant|r arrives in the meantime, you can target it and it will complete the quest for you. If the quest fails, abandon City of Light, accept the quest from |cRXP_FRIENDLY_Khadgar|r again, then follow |cRXP_FRIENDLY_Khadgar's Servant|r through Shattrath|r
.complete 10211,1 
.target Khadgar's Servant
step << wotlk
.goto Shattrath City,50.36,42.87
>>|cRXP_WARN_Follow |cRXP_FRIENDLY_Khadgar's Servant|r through Shattrath City|r
.complete 10211,1 
.target Khadgar's Servant
step
.goto Shattrath City,54.751,44.322
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khadgar|r
>>|cFFFF0000Ensure to turn off |cRXP_WARN_Questie|r or any other addon that has an automatic turn in option!|r
.target Khadgar
.turnin 10211 >> Turn in City of Light
step
.goto Shattrath City,54.751,44.322
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khadgar|r
.accept 10552 >> Accept Allegiance to the Scryers
.turnin 10552 >> Turn in Allegiance to the Scryers
>>|cFFFF0000Ensure to turn off |cRXP_WARN_Questie|r or any other addon that has an automatic turn in option!|r
.target Khadgar
step
#scryer
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khadgar|r
.goto Shattrath City,54.751,44.322
.accept 10553 >>Accept Voren'thal the Seer
.target Khadgar
step
#scryer
.skill riding,225,1
#completewith VorenthaltheSeer
.goto Shattrath City,49.82,63.49,20 >> Take the elevator up to the Scryer's Tier
step
#scryer
#label VorenthaltheSeer
.goto Shattrath City,42.782,91.723
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Voren'thal the Seer|r
.turnin 10553 >>Turn in Voren'thal the Seer
.target Voren'thal the Seer
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#group RXP TBC Reputation Guide
#subgroup The Aldor
#name 1. Terokkar Forest (Aldor)
#next 2. Netherstorm (Aldor)
step
#completewith CityofLight
.zone Shattrath City >> Travel to Shattrath City
step
.goto Shattrath City,59.657,41.428
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Haggard War Veteran|r
.target Haggard War Veteran
.accept 10210 >>Accept A'dal
step
.goto Shattrath City,53.991,44.743
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_A'dal|r
.target A'dal
.turnin 10210 >>Turn in A'dal
step
#label CityofLight
.goto Shattrath City,54.751,44.322
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khadgar|r
.target Khadgar
.accept 10211 >>Accept City of Light
.timer 530,City of Light RP
step << tbc
.goto Shattrath City,50.36,42.87
>>|cRXP_WARN_Head up to the second floor next to |cRXP_FRIENDLY_G'eras|r and wait out the RP|r
>>|cRXP_WARN_If someone else's |cRXP_FRIENDLY_Khadgar's Servant|r arrives in the meantime, you can target it and it will complete the quest for you. If the quest fails, abandon City of Light, accept the quest from |cRXP_FRIENDLY_Khadgar|r again, then follow |cRXP_FRIENDLY_Khadgar's Servant|r through Shattrath|r
.complete 10211,1 
.target Khadgar's Servant
step << wotlk
.goto Shattrath City,50.36,42.87
>>|cRXP_WARN_Follow |cRXP_FRIENDLY_Khadgar's Servant|r through Shattrath City|r
.complete 10211,1 
.target Khadgar's Servant
step
.goto Shattrath City,54.751,44.322
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khadgar|r
>>|cFFFF0000Ensure to turn off |cRXP_WARN_Questie|r or any other addon that has an automatic turn in option!|r
.target Khadgar
.turnin 10211 >> Turn in City of Light
step
.goto Shattrath City,54.751,44.322
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khadgar|r
.accept 10551 >> Accept Allegiance to the Aldor
.turnin 10551 >> Turn in Allegiance to the Aldor
>>|cFFFF0000Ensure to turn off |cRXP_WARN_Questie|r or any other addon that has an automatic turn in option!|r
.target Khadgar
step
#aldor
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Khadgar|r
.goto Shattrath City,54.751,44.322
.accept 10554 >> Accept Ishanah
.target Khadgar
step
#aldor
.skill riding,225,1
#completewith next
.goto Shattrath City,41.73,38.60,30 >> Take the elevator up to the Aldor Rise
step
#aldor
.goto Shattrath City,23.959,29.735
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ishanah|r
.target Ishanah
.turnin 10554 >>Turn in Ishanah
.accept 10021 >>Accept Restoring the Light
step
#aldor
.goto Shattrath City,64.486,15.112
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sha'nir|r
.target Sha'nir
.accept 10020 >>Accept A Cure for Zahlia
step
#aldor
.goto Terokkar Forest,48.10,14.51
>>Click the |cRXP_PICK_Western Altar|r
.complete 10021,3 
step
#aldor
.goto Terokkar Forest,50.67,16.54
>>Click the |cRXP_PICK_Northern Altar|r
.complete 10021,1 
step
#aldor
.goto Terokkar Forest,49.25,20.32
>>Click the |cRXP_PICK_Eastern Altar|r
.complete 10021,2 
step
#aldor
#loop
.goto Terokkar Forest,60.77,23.14,50,0
.goto Terokkar Forest,60.97,24.34,50,0
.goto Terokkar Forest,61.46,25.43,50,0
.goto Terokkar Forest,62.10,27.12,50,0
.goto Terokkar Forest,62.77,27.68,50,0
.goto Terokkar Forest,63.32,28.38,50,0
.goto Terokkar Forest,63.72,29.37,50,0
.goto Terokkar Forest,64.54,30.01,50,0
.goto Terokkar Forest,66.31,30.54,50,0
.goto Terokkar Forest,67.93,30.85,50,0
.goto Terokkar Forest,68.35,31.31,50,0
.goto Terokkar Forest,69.16,31.22,50,0
.goto Terokkar Forest,69.63,30.88,50,0
.goto Terokkar Forest,70.35,29.82,50,0
.goto Terokkar Forest,71.26,28.70,50,0
.line Terokkar Forest,71.26,28.70,70.35,29.82,69.63,30.88,69.16,31.22,68.35,31.31,67.93,30.85,66.31,30.54,64.54,30.01,63.72,29.37,63.32,28.38,62.77,27.68,62.10,27.12,61.46,25.43,60.97,24.34,60.77,23.14
>>Kill |cRXP_ENEMY_Stonegazer|r. Loot him for his |cRXP_LOOT_Blood|r
>>|cRXP_ENEMY_Stonegazer|r |cRXP_WARN_patrols a large area|r
>>|cRXP_WARN_This quest is difficult. Find a group for him if needed. Skip this step if you're unable to find a group or solo him|r << tbc
.complete 10020,1 
.unitscan Stonegazer
step
#aldor
.isQuestComplete 10020
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sha'nir|r
.turnin 10020 >> Turn in A Cure for Zahlia
.goto Shattrath City,64.486,15.112
.target Sha'nir
step
#aldor
.skill riding,225,1
#completewith next
.goto Shattrath City,41.73,38.60,30 >> Take the elevator up to the Aldor Rise
step
#aldor
.goto Shattrath City,23.959,29.735
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ishanah|r
.turnin 10021 >> Turn in Restoring the Light
.target Ishanah
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#group RXP TBC Reputation Guide
#subgroup The Aldor
#name 2. Netherstorm (Aldor)
#next 3. Shadowmoon Valley (Aldor)
step
#completewith next
.zone Netherstorm >> Travel to Netherstorm
step
#aldor
.goto Netherstorm,32.07,64.18
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Exarch Orelis|r
.accept 10241 >> Accept Distraction at Manaforge B'naar
.target Exarch Orelis
step
#aldor
>>Kill |cRXP_ENEMY_Sunfury Magisters|r and |cRXP_ENEMY_Sunfury Bloodwarders|r
.complete 10241,1 
.mob +Sunfury Magister
.goto Netherstorm,25.64,68.35,50,0
.goto Netherstorm,26.58,68.65,50,0
.goto Netherstorm,25.18,68.81
.complete 10241,2 
.mob +Sunfury Bloodwarder
.goto Netherstorm,28.09,64.84,50,0
.goto Netherstorm,27.43,65.29,50,0
.goto Netherstorm,25.91,66.72,50,0
.goto Netherstorm,25.16,67.41
step
#aldor
.goto Netherstorm,32.07,64.18
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Exarch Orelis|r
.turnin 10241 >> Turn in Distraction at Manaforge B'naar
.accept 10313 >> Accept Measuring Warp Energies
.target Exarch Orelis
step
#aldor
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Anchorite Karja|r
.goto Netherstorm,32.04,64.18
.accept 10243 >> Accept Naaru Technology
.target Anchorite Karja
step
#aldor
.goto Netherstorm,25.79,60.21
.use 29324 >>|cRXP_WARN_Use the|r |T134125:0|t[Warp-Attuned Orb] |cRXP_WARN_next to the|r |cRXP_PICK_Northern Pipeline|r
.complete 10313,1 
step
#aldor
.goto Netherstorm,20.88,67.20
.use 29324 >>|cRXP_WARN_Use the|r |T134125:0|t[Warp-Attuned Orb] |cRXP_WARN_next to the|r |cRXP_PICK_Western Pipeline|r
.complete 10313,4 
step
#aldor
.goto Netherstorm,20.50,70.95
.use 29324 >>|cRXP_WARN_Use the|r |T134125:0|t[Warp-Attuned Orb] |cRXP_WARN_next to the|r |cRXP_PICK_Southern Pipeline|r
.complete 10313,3 
step
#aldor
.goto Netherstorm,23.217,68.284
>>|cRXP_WARN_Go inside Manaforge B'naar|r
>>Click to the |cRXP_PICK_B'naar Control Console|r
.turnin 10243 >> Turn in Naaru Technology
.accept 10245 >> Accept B'naar Console Transcription
step
#aldor
.goto Netherstorm,28.91,72.29
.use 29324 >>|cRXP_WARN_Use the|r |T134125:0|t[Warp-Attuned Orb] |cRXP_WARN_next to the|r |cRXP_PICK_Eastern Pipeline|r
.complete 10313,2 
step
#aldor
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Anchorite Karja|r and |cRXP_FRIENDLY_Exarch Orelis|r
.turnin 10245 >> Turn in B'naar Console Transcription
.accept 10299 >> Accept Shutting Down Manaforge B'naar
.target +Anchorite Karja
.goto Netherstorm,32.04,64.18,-1
.turnin 10313 >> Turn in Measuring Warp Energies
.target +Exarch Orelis
.goto Netherstorm,32.07,64.18,-1
step
#aldor
.goto Netherstorm,24.20,68.10,40,0
.goto Netherstorm,23.68,70.02,40,0
.goto Netherstorm,23.85,70.77
>>Kill |cRXP_ENEMY_Overseer Theredis|r inside Manaforge B'naar. Loot him for the |cRXP_LOOT_B'naar Access Crystal|r
.complete 10299,2 
.mob Overseer Theredis
step
#aldor
.goto Netherstorm,23.217,68.284
>>Click to the |cRXP_PICK_B'naar Control Console|r to start the event
>>Kill the |cRXP_ENEMY_Sunfury|r that try to stop the shutdown. The shutdown will complete after 2 minutes
.complete 10299,1 
.skipgossip
.mob Sunfury Warp-Engineer
.mob Sunfury Warp-Master
.mob Sunfury Technician
step
#aldor
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Anchorite Karja|r and |cRXP_FRIENDLY_Exarch Orelis|r
.turnin 10299 >> Turn in Shutting Down Manaforge B'naar
.accept 10321 >> Accept Shutting Down Manaforge Coruu
.target +Anchorite Karja
.goto Netherstorm,32.04,64.18
step
#aldor
.goto Netherstorm,49.02,81.52
>>Kill |cRXP_ENEMY_Overseer Seylanna|r inside Manaforge Coruu. Loot her for the |cRXP_LOOT_Coruu Access Crystal|r
.complete 10321,2 
.mob Overseer Seylanna
step
#aldor
#label Coruu
.goto Netherstorm,48.926,81.613
>>Click to the |cRXP_PICK_Coruu Control Console|r to start the event
>>Kill the |cRXP_ENEMY_Sunfury|r that try to stop the shutdown. The shutdown will complete after 2 minutes
.complete 10321,1 
.skipgossip
.mob Sunfury Technician
step
#aldor
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Anchorite Karja|r and |cRXP_FRIENDLY_Exarch Orelis|r
.turnin 10321 >> Turn in Shutting Down Manaforge Coruu
.accept 10322 >> Accept Shutting Down Manaforge Duro
.target +Anchorite Karja
.goto Netherstorm,32.04,64.18
.accept 10246 >> Accept Attack on Manaforge Coruu
.target +Exarch Orelis
.goto Netherstorm,32.07,64.18
step
#aldor
>>Kill |cRXP_ENEMY_Sunfury Researchers|r and |cRXP_ENEMY_Sunfury Arcanists|r around Manaforge Coruu
.goto Netherstorm,49.46,82.42,40,0
.goto Netherstorm,48.55,81.01,40,0
.goto Netherstorm,51.75,81.23
.complete 10246,1
.mob +Sunfury Researcher
.complete 10246,2
.mob +Sunfury Arcanist
step
#aldor
.goto Netherstorm,32.07,64.18
.target Exarch Orelis
.turnin 10246 >> Turn in Attack on Manaforge Coruu
.accept 10328 >> Accept Sunfury Briefings
step
#aldor
#completewith DuroShutDown
>>Kill |cRXP_ENEMY_Sunfury Bowmen|r and |cRXP_ENEMY_Sunfury Centurions|r. Loot them for the |cRXP_LOOT_Military Briefing|r
>>Kill |cRXP_ENEMY_Sunfury Conjurers|r. Loot them for the |cRXP_LOOT_Arcane Briefing|r
.complete 10328,1 
.mob +Sunfury Bowman
.mob +Sunfury Centurion
.complete 10328,2 
.mob +Sunfury Conjurer
step
#aldor
.goto Netherstorm,59.99,68.52
>>Kill |cRXP_ENEMY_Overseer Athanel|r inside Manaforge Duro. Loot him for the |cRXP_LOOT_Duro Access Crystal|r
.complete 10322,2 
.mob Overseer Athanel
step
#aldor
#label DuroShutDown
.goto Netherstorm,59.19,66.72
>>Click to the |cRXP_PICK_Duro Control Console|r to start the event
>>Kill the |cRXP_ENEMY_Sunfury|r that try to stop the shutdown. The shutdown will complete after 2 minutes
.complete 10322,1 
.skipgossip
step
#aldor
#loop
.line Netherstorm,58.84,62.54,58.31,62.97,58.10,62.71,57.76,63.29,57.21,63.42,56.82,63.89,57.34,64.44,57.39,65.29,57.22,65.92,56.95,66.52,57.34,67.19,57.38,66.58,57.22,65.92,57.39,65.29,57.34,64.44,57.91,64.06,57.76,63.29,58.10,62.71,58.31,62.97,58.84,62.54,59.10,63.14,59.45,63.04,59.20,62.36,58.84,62.54
.goto Netherstorm,58.84,62.54,50,0
.goto Netherstorm,58.31,62.97,50,0
.goto Netherstorm,58.10,62.71,50,0
.goto Netherstorm,57.76,63.29,50,0
.goto Netherstorm,57.21,63.42,50,0
.goto Netherstorm,56.82,63.89,50,0
.goto Netherstorm,57.34,64.44,50,0
.goto Netherstorm,57.39,65.29,50,0
.goto Netherstorm,57.22,65.92,50,0
.goto Netherstorm,56.95,66.52,50,0
.goto Netherstorm,57.34,67.19,50,0
.goto Netherstorm,57.38,66.58,50,0
.goto Netherstorm,57.22,65.92,50,0
.goto Netherstorm,57.39,65.29,50,0
.goto Netherstorm,57.34,64.44,50,0
.goto Netherstorm,57.91,64.06,50,0
.goto Netherstorm,57.76,63.29,50,0
.goto Netherstorm,58.10,62.71,50,0
.goto Netherstorm,58.31,62.97,50,0
.goto Netherstorm,58.84,62.54,50,0
.goto Netherstorm,59.10,63.14,50,0
.goto Netherstorm,59.45,63.04,50,0
.goto Netherstorm,59.20,62.36,50,0
>>Kill |cRXP_ENEMY_Bowmen|r and |cRXP_ENEMY_Centurions|r. Loot them for the |cRXP_LOOT_Military Briefing|r
>>Kill |cRXP_ENEMY_Sunfury Conjurers|r. Loot them for the |cRXP_LOOT_Arcane Briefing|r
.complete 10328,1 
.mob +Sunfury Bowman
.mob +Sunfury Centurion
.complete 10328,2 
.mob +Sunfury Conjurer
step
#aldor
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Anchorite Karja|r and |cRXP_FRIENDLY_Exarch Orelis|r
.turnin 10322 >> Turn in Shutting Down Manaforge Duro
.accept 10323 >> Accept Shutting Down Manaforge Ara
.target +Anchorite Karja
.goto Netherstorm,32.04,64.18
.turnin 10328 >> Turn in Sunfury Briefings
.accept 10431 >> Accept Outside Assistance
.target +Exarch Orelis
.goto Netherstorm,32.07,64.18
step
#completewith next
.subzone 3852 >> Travel to Tuluman's Landing
step
#aldor
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kaylaan|r
.turnin 10431 >> Turn in Outside Assistance
.accept 10380 >> Accept A Dark Pact
.target +Kaylaan
.goto Netherstorm,34.80,38.30
step
#completewith next
.goto Netherstorm,26.37,43.87
.subzone 3881 >> Enter the Trelleum Mine
step
#aldor
.goto Netherstorm,26.95,38.34,30,0
.goto Netherstorm,25.59,41.65,30,0
.goto Netherstorm,26.43,42.61,30,0
.goto Netherstorm,26.95,38.34,30,0
.goto Netherstorm,25.59,41.65,30,0
.goto Netherstorm,26.43,42.61
>>Kill |cRXP_ENEMY_Gan'arg Warp-Tinkers|r and |cRXP_ENEMY_Mo'arg Warp-Master|r inside the mine
.complete 10380,1 
.mob +Gan'arg Warp-Tinker
.complete 10380,3 
.mob +Mo'arg Warp-Master
step
#aldor
#loop
.line Netherstorm,28.43,41.71,28.33,40.23,28.57,37.74,30.85,39.73,29.61,44.04,28.43,41.71
.goto Netherstorm,28.43,41.71,45,0
.goto Netherstorm,28.33,40.23,45,0
.goto Netherstorm,28.57,37.74,45,0
.goto Netherstorm,30.85,39.73,45,0
.goto Netherstorm,29.61,44.04,45,0
>>Kill |cRXP_ENEMY_Daughters of Destiny|r
.complete 10380,2 
.mob +Daughter of Destiny
.skill riding,<225,1
step
#aldor
#loop
.line Netherstorm,28.43,41.71,28.33,40.23,30.85,39.73,29.61,44.04,28.43,41.71
.goto Netherstorm,28.43,41.71,45,0
.goto Netherstorm,28.33,40.23,45,0
.goto Netherstorm,30.85,39.73,45,0
.goto Netherstorm,29.61,44.04,45,0
.goto Netherstorm,28.43,41.71,45,0
>>Kill |cRXP_ENEMY_Daughters of Destiny|r
.complete 10380,2 
.mob +Daughter of Destiny
.skill riding,225,1
step
#aldor
.goto Netherstorm,26.0,38.7
>>Kill |cRXP_ENEMY_Overseer Azarad|r inside Manaforge Ara. Loot the |cRXP_LOOT_Ara Access Crystal|r
>>|cRXP_WARN_Look for a group of at least 3 people for completing this quest|r
.complete 10323,2 
.mob Overseer Azarad
step
#aldor
.goto Netherstorm,25.936,38.721
>>Click to the |cRXP_PICK_Ara Control Console|r to start the event
>>Kill the |cRXP_ENEMY_Demons|r that try to stop the shutdown. The shutdown will complete after 2 minutes
.complete 10323,1 
.skipgossip
step
#completewith next
.subzone 3852 >> Return to Tuluman's Landing
step
#aldor
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Kaylaan|r
.turnin 10380 >> Turn in A Dark Pact
.accept 10381 >> Accept Aldor No More
.goto Netherstorm,34.80,38.30
.target Kaylaan
step
.skill riding,225,1
#completewith next
.goto Netherstorm,45.31,34.87
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Grennik|r
.fly Area 52>> Fly to Area 52
.target Grennik
.subzoneskip 3712
step
#aldor
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Anchorite Karja|r and |cRXP_FRIENDLY_Exarch Orelis|r
.turnin 10381 >> Turn in Aldor No More
.target +Exarch Orelis
.goto Netherstorm,32.07,64.18
.turnin 10323 >> Turn in Shutting Down Manaforge Ara
.accept 10407 >> Accept Socrethar's Shadow
.target +Anchorite Karja
.goto Netherstorm,32.04,64.18
step
.skill riding,225,1
#completewith next
.goto Netherstorm,33.74,63.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Krexcil|r
.fly The Stormspire>> Fly to The Stormspire
.target Krexcil
.subzoneskip 3712,1
step
#aldor
.goto Netherstorm,36.85,27.82
>>Kill |cRXP_ENEMY_Morug|r. Loot him for the |cRXP_LOOT_First Half of Socrethar's Stone|r
>>|cRXP_WARN_This quest is difficult. Find a group for him if needed|r
.complete 10407,1 
.mob Forgemaster Morug
step
#aldor
.goto Netherstorm,40.87,19.54
>>Kill |cRXP_ENEMY_Silroth|r. Loot him for the |cRXP_LOOT_Second Half of Socrethar's Stone|r
>>|cRXP_WARN_This quest is difficult. Find a group for him if needed|r
.complete 10407,2 
.mob Silroth
step
.skill riding,225,1
#completewith next
.goto Netherstorm,45.31,34.87
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Grennik|r
.fly Area 52>> Fly to Area 52
.target Grennik
.subzoneskip 3712
step
#aldor
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Exarch Orelis|r
.turnin 10407 >> Turn in Socrethar's Shadow
.accept 10410 >> Accept Ishanah's Help
.target Anchorite Karja
.goto Netherstorm,32.04,64.18
step << !Mage
.skill riding,225,1
#completewith next
.goto Netherstorm,45.31,34.87
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Grennik|r
.fly Shattrath >> Fly to Shattrath
.target Grennik
.subzoneskip 3712
step << Mage
.cast 33690 >> |cRXP_WARN_Cast|r |T135760:0|t[Teleport: Shattrath]
.usespell 33690
.zoneskip Shattrath City
step
#completewith next
.zone Shattrath City >> Travel to Shattrath City
step
#aldor
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ishanah|r
.turnin 10410 >> Turn in Ishanah's Help
.accept 10409 >> Accept Deathblow to the Legion
.target Ishanah
.goto Shattrath City,23.959,29.735
step
.skill riding,225,1
#completewith next
.goto Shattrath City,64.061,41.112
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nutral|r
.fly The Stormspire>> Fly to The Stormspire
.target Nutral
step
.isOnQuest 10409
#optional
.goto Netherstorm,36.442,18.338
.xp >70,1
.cast 35745 >> |cRXP_WARN_Use|r |T134465:0|t[Socrethar's Teleportation Stone] |cRXP_WARN_at the teleporter to create a portal to Socrethar's Seat|r
>>|cRXP_WARN_You will need a 5 man group for this quest. It is recommended to have a dedicated Tank and Healer|r
.use 29796
step
.isOnQuest 10409
#optional
.goto Netherstorm,36.442,18.338
.xp >70,1
.subzone 3742 >> Go through the teleporter to Socrethar's Seat
step
#optional
#completewith next
.subzone 3742 >> Fly on your mount to Socrethar's Seat
step
.goto Netherstorm,30.657,17.49,10,0 
.goto Netherstorm,29.324,13.704
>>Talk to |cRXP_FRIENDLY_Adyen the Lightwarden|r to begin the RP once your group is ready
>>Kill |cRXP_ENEMY_Socrethar|r
>>|cRXP_WARN_You will need a 5 man group for this quest. It is recommended to have a dedicated Tank and Healer|r
.complete 10409,1
.mob Socrethar
.target Adyen the Lightwarden
step
#completewith next
.zone Shattrath City >> Return to Shattrath City
step
#aldor
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ishanah|r
.turnin 10409 >> Turn in Deathblow to the Legion
.target Ishanah
.goto Shattrath City,23.959,29.735
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#group RXP TBC Reputation Guide
#subgroup The Scryers
#name 2. Netherstorm (Scryers)
#next 3. Shadowmoon Valley (Scryers)
step
#completewith next
.zone Netherstorm >> Travel to Netherstorm
step
#scryer
.goto Netherstorm,32.00,64.07
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spymaster Thalodien|r
.accept 10189 >> Accept Manaforge B'naar
.target Spymaster Thalodien
step
#scryer
.goto Netherstorm,27.58,65.19,30,0
.goto Netherstorm,27.00,65.67
>>Kill |cRXP_ENEMY_Captain Arathyn|r. Loot him for the |cRXP_LOOT_B'naar Personnel Roster|r
.complete 10189,1 
.mob Captain Arathyn
step
#scryer
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spymaster Thalodien|r and |cRXP_FRIENDLY_Magistrix Larynna|r
.goto Netherstorm,31.36,66.15,-1
.turnin 10189 >> Turn in Manaforge B'naar
.accept 10193 >> Accept High Value Targets
.target +Spymaster Thalodien
.goto Netherstorm,32.00,64.08,-1
.accept 10204 >> Accept Bloodgem Crystals
.target +Magistrix Larynna
.goto Netherstorm,32.05,63.99,-1
step
#scryer
#completewith Geologists
>>Kill |cRXP_ENEMY_Sunfury Magisters|r. Loot them for a |T132787:0|t[|cRXP_LOOT_Bloodgem Shard|r]
.collect 28452,1,10204 
.mob Sunfury Magister
step
#scryer
#completewith Geologists
.use 28452 >>|cRXP_WARN_Channel the|r |T132787:0|t[|cRXP_LOOT_Bloodgem Shard|r] |cRXP_WARN_on one of the floating Bloodgem Crystals|r
.complete 10204,1 
step
#scryer
#label Geologists
#loop
.goto Netherstorm,22.6,73.4,0
.goto Netherstorm,28.8,72.8,0
.goto Netherstorm,25.4,67.4,0
.goto Netherstorm,22.6,73.4,60,0
.goto Netherstorm,28.8,72.8,60,0
.goto Netherstorm,25.4,67.4,60,0
>>Kill |cRXP_ENEMY_Sunfury Geologists|r
.complete 10193,3 
.mob Sunfury Geologist
step
#scryer
#loop
.line Netherstorm,26.44,68.93,25.64,68.86,25.59,68.10,24.90,66.46,24.93,65.53,25.47,65.14,26.44,68.93
.goto Netherstorm,26.44,68.93,45,0
.goto Netherstorm,25.64,68.86,45,0
.goto Netherstorm,25.59,68.10,45,0
.goto Netherstorm,24.90,66.46,45,0
.goto Netherstorm,24.93,65.53,45,0
.goto Netherstorm,25.47,65.14,45,0
.goto Netherstorm,26.44,68.93,45,0
>>Kill |cRXP_ENEMY_Sunfury Magisters|r. Loot them for a |T132787:0|t[|cRXP_LOOT_Bloodgem Shard|r]
.collect 28452,1,10204 
.isOnQuest 10204
.mob Sunfury Magister
step
#scryer
.goto Netherstorm,26.07,68.37,-1
.goto Netherstorm,26.18,68.89,-1
.goto Netherstorm,26.43,68.38,-1
.goto Netherstorm,26.25,68.54,-1
.goto Netherstorm,25.16,66.11,-1
.goto Netherstorm,25.30,65.52,-1
.goto Netherstorm,25.51,65.90,-1
.goto Netherstorm,25.30,65.85,-1
.use 28452 >>|cRXP_WARN_Use the|r |T132787:0|t[|cRXP_LOOT_Bloodgem Shard|r] |cRXP_WARN_on one of the floating Bloodgem Crystals|r
.complete 10204,1 
.isOnQuest 10204
step
#scryer
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spymaster Thalodien|r and |cRXP_FRIENDLY_Magistrix Larynna|r
.turnin 10193 >> Turn in High Value Targets
.accept 10329 >> Accept Shutting Down Manaforge B'naar
.target +Spymaster Thalodien
.goto Netherstorm,32.00,64.08,-1
.turnin 10204 >> Turn in Bloodgem Crystals
.target +Magistrix Larynna
.goto Netherstorm,32.05,63.99,-1
step
#scryer
.goto Netherstorm,24.20,68.10,40,0
.goto Netherstorm,23.68,70.02,40,0
.goto Netherstorm,23.85,70.77
>>Kill |cRXP_ENEMY_Overseer Theredis|r inside Manaforge B'naar. Loot him for the |cRXP_LOOT_B'naar Access Crystal|r
.complete 10329,2 
.mob Overseer Theredis
step
#scryer
.goto Netherstorm,23.217,68.284
>>Click to the |cRXP_PICK_B'naar Control Console|r to start the event
>>Kill the |cRXP_ENEMY_Sunfury|r that try to stop the shutdown. The shutdown will complete after 2 minutes
.complete 10329,1 
.skipgossip
.mob Sunfury Warp-Engineer
.mob Sunfury Warp-Master
.mob Sunfury Technician
step
#scryer
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spymaster Thalodien|r
.turnin 10329 >> Turn in Shutting Down Manaforge B'naar
.accept 10194 >> Accept Stealth Flight
.target Spymaster Thalodien
step
#scryer
.goto Netherstorm,33.81,64.23
.fly >>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Veronia|r to fly to Manaforge Coruu
.turnin 10194 >> Turn in Stealth Flight
.accept 10652 >> Accept Behind Enemy Lines
.skipgossip
.timer 42,Behind Enemy Lines flight
.target Veronia
step
#scryer
.goto Netherstorm,48.24,86.60
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Caledis Brightdawn|r once you land
.turnin 10652 >> Turn in Behind Enemy Lines
.accept 10197 >> Accept A Convincing Disguise
.target Caledis Brightdawn
step
.skill riding,225,1
#aldor
#completewith next
.goto Netherstorm,44.07,76.56,40,0
.goto Netherstorm,45.55,78.99,40 >> Cross the bridge toward Manaforge Coruu
.zoneskip Netherstorm,1
step
#scryer
#loop
.line Netherstorm,51.82,81.16,52.34,82.73,51.04,82.80,50.19,84.42,50.67,82.16,51.53,81.80,51.36,81.00,51.82,81.16
.goto Netherstorm,51.82,81.16,55,0
.goto Netherstorm,52.34,82.73,55,0
.goto Netherstorm,51.04,82.80,55,0
.goto Netherstorm,50.19,84.42,55,0
.goto Netherstorm,50.67,82.16,55,0
.goto Netherstorm,51.53,81.80,55,0
.goto Netherstorm,51.36,81.00,55,0
>>Kill |cRXP_ENEMY_Sunfury Researchers|r. Loot them for their |cRXP_LOOT_Sunfury Researcher Gloves|r
>>Kill |cRXP_ENEMY_Sunfury Guardsmen|r. Loot them for their |cRXP_LOOT_Medallion|r
>>Kill |cRXP_ENEMY_Sunfury Arcanists|r. Loot them for their |cRXP_LOOT_Robes|r
.complete 10197,1 
.mob +Sunfury Researcher
.complete 10197,2 
.mob +Sunfury Guardsman
.complete 10197,3 
.mob +Sunfury Arcanist
step
#scryer
.goto Netherstorm,48.24,86.60
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Caledis Brightdawn|r
.turnin 10197 >> Turn in A Convincing Disguise
.accept 10198 >> Accept Information Gathering
.target Caledis Brightdawn
step
#scryer
#completewith next
.cast 34603 >> |cRXP_WARN_Use the |r|T134473:0|t[Sunfury Disguise] |cRXP_WARN_before you enter Manaforge Coruu|r
.use 28607
step
#scryer
.goto Netherstorm,48.25,83.86,20,0
.timer 121,Information Gathering RP
.goto Netherstorm,48.15,84.18
.use 28607 >>|cRXP_WARN_While disguised, enter Manaforge Coruu|r
>>|cRXP_WARN_Go into the southern room. Wait out the RP between |cRXP_ENEMY_Commander Dawnforge|r, |cRXP_ENEMY_Arcanist Ardonis|r and|r |cRXP_ENEMY_Pathaleon the Calculator's Image|r
.complete 10198,1 
.mob Commander Dawnforge
.mob Arcanist Ardonis
.mob Pathaleon the Calculator's Image
step
#scryer
.goto Netherstorm,48.24,86.60
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Caledis Brightdawn|r
.turnin 10198 >> Turn in Information Gathering
.accept 10330 >> Accept Shutting Down Manaforge Coruu
.target Caledis Brightdawn
step
#scryer
.goto Netherstorm,49.02,81.52
>>Kill |cRXP_ENEMY_Overseer Seylanna|r inside Manaforge Coruu. Loot her for the |cRXP_LOOT_Coruu Access Crystal|r
.complete 10330,2 
.mob Overseer Seylanna
step
#scryer
#label Coruu
.goto Netherstorm,48.926,81.613
>>Click to the |cRXP_PICK_Coruu Control Console|r to start the event
>>Kill the |cRXP_ENEMY_Sunfury|r that try to stop the shutdown. The shutdown will complete after 2 minutes
.complete 10330,1 
.skipgossip
step
#scryer
.goto Netherstorm,48.24,86.60
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Caledis Brightdawn|r
.turnin 10330 >> Turn in Shutting Down Manaforge Coruu
.accept 10200 >> Accept Return to Thalodien
.target Caledis Brightdawn
step
#scryer
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spymaster Thalodien|r and |cRXP_FRIENDLY_Magistrix Larynna|r
.turnin 10200 >> Turn in Return to Thalodien
.accept 10338 >> Accept Shutting Down Manaforge Duro
.target +Spymaster Thalodien
.goto Netherstorm,32.00,64.08
.accept 10341 >> Accept Kick Them While They're Down
.target +Magistrix Larynna
.goto Netherstorm,32.05,63.99
step
#scryer
.goto Netherstorm,59.99,68.52
>>Kill |cRXP_ENEMY_Overseer Athanel|r inside Manaforge Duro. Loot him for the |cRXP_LOOT_Duro Access Crystal|r
.complete 10338,2 
.mob Overseer Athanel
step
#scryer
.goto Netherstorm,59.19,66.72
>>Click to the |cRXP_PICK_Duro Control Console|r to start the event
>>Kill the |cRXP_ENEMY_Sunfury|r that try to stop the shutdown. The shutdown will complete after 2 minutes
.complete 10338,1 
.skipgossip
step
#scryer
#loop
.line Netherstorm,58.84,62.54,58.31,62.97,58.10,62.71,57.76,63.29,57.21,63.42,56.82,63.89,57.34,64.44,57.39,65.29,57.22,65.92,56.95,66.52,57.34,67.19,57.38,66.58,57.22,65.92,57.39,65.29,57.34,64.44,57.91,64.06,57.76,63.29,58.10,62.71,58.31,62.97,58.84,62.54,59.10,63.14,59.45,63.04,59.20,62.36,58.84,62.54
.goto Netherstorm,58.84,62.54,50,0
.goto Netherstorm,58.31,62.97,50,0
.goto Netherstorm,58.10,62.71,50,0
.goto Netherstorm,57.76,63.29,50,0
.goto Netherstorm,57.21,63.42,50,0
.goto Netherstorm,56.82,63.89,50,0
.goto Netherstorm,57.34,64.44,50,0
.goto Netherstorm,57.39,65.29,50,0
.goto Netherstorm,57.22,65.92,50,0
.goto Netherstorm,56.95,66.52,50,0
.goto Netherstorm,57.34,67.19,50,0
.goto Netherstorm,57.38,66.58,50,0
.goto Netherstorm,57.22,65.92,50,0
.goto Netherstorm,57.39,65.29,50,0
.goto Netherstorm,57.34,64.44,50,0
.goto Netherstorm,57.91,64.06,50,0
.goto Netherstorm,57.76,63.29,50,0
.goto Netherstorm,58.10,62.71,50,0
.goto Netherstorm,58.31,62.97,50,0
.goto Netherstorm,58.84,62.54,50,0
.goto Netherstorm,59.10,63.14,50,0
.goto Netherstorm,59.45,63.04,50,0
.goto Netherstorm,59.20,62.36,50,0
>>Kill |cRXP_ENEMY_Sunfury Conjurers|r, |cRXP_ENEMY_Bowmen|r and |cRXP_ENEMY_Centurions|r. Loot them for their |cRXP_LOOT_Signets|r and a |cRXP_LOOT_Tome|r
.complete 10341,1 
.mob +Sunfury Conjurer
.complete 10341,2 
.mob +Sunfury Bowman
.complete 10341,3 
.mob +Sunfury Centurion
.mob +Sunfury Conjurer
.mob +Sunfury Bowman
.mob +Sunfury Centurion
step
#scryer
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spymaster Thalodien|r and |cRXP_FRIENDLY_Magistrix Larynna|r
.turnin 10338 >> Turn in Shutting Down Manaforge Duro
.accept 10365 >> Accept Shutting Down Manaforge Ara
.target +Spymaster Thalodien
.goto Netherstorm,32.00,64.08
.turnin 10341 >> Turn in Kick Them While They're Down
.accept 10202 >> Accept A Defector
.target +Magistrix Larynna
.goto Netherstorm,32.05,63.99
step
.skill riding,225,1
#completewith next
.goto Netherstorm,33.59,37.77,50,0
.goto Netherstorm,31.51,41.63,50 >> Cross the bridge to Manaforge Ara
step
#scryer
.skill riding,225,1
#completewith next
.goto Netherstorm,29.56,41.80,50,0
.goto Netherstorm,29.42,39.76,50 >> Travel up the hill to Manaforge Ara
step
#scryer
.goto Netherstorm,26.19,41.57
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Magister Theledorn|r
.turnin 10202 >> Turn in A Defector
.accept 10432 >> Accept Damning Evidence
.target Magister Theledorn
step
#scryer
#loop
.line Netherstorm,28.43,41.71,28.33,40.23,28.57,37.74,30.85,39.73,29.61,44.04,28.43,41.71
.goto Netherstorm,28.43,41.71,45,0
.goto Netherstorm,28.33,40.23,45,0
.goto Netherstorm,28.57,37.74,45,0
.goto Netherstorm,30.85,39.73,45,0
.goto Netherstorm,29.61,44.04,45,0
>>Kill |cRXP_ENEMY_Demons|r at Manaforge Ara. Loot the Demons for their |cRXP_LOOT_Orders|r
.complete 10432,1 
.mob +Daughter of Destiny
.mob +Gan'arg Warp-Tinker
.mob +Mo'arg Warp-Master
.skill riding,<225,1
step
#scryer
#loop
.line Netherstorm,28.43,41.71,28.33,40.23,30.85,39.73,29.61,44.04,28.43,41.71
.goto Netherstorm,28.43,41.71,45,0
.goto Netherstorm,28.33,40.23,45,0
.goto Netherstorm,30.85,39.73,45,0
.goto Netherstorm,29.61,44.04,45,0
>>Kill |cRXP_ENEMY_Demons|r at Manaforge Ara. Loot the Demons for their |cRXP_LOOT_Orders|r
.complete 10432,1 
.mob +Daughter of Destiny
.mob +Gan'arg Warp-Tinker
.mob +Mo'arg Warp-Master
.skill riding,225,1
step
#scryer
.goto Netherstorm,26.0,38.7
>>Kill |cRXP_ENEMY_Overseer Azarad|r inside Manaforge Ara. Loot the |cRXP_LOOT_Ara Access Crystal|r
>>|cRXP_WARN_Look for a group of at least 3 people for completing this quest|r
.complete 10365,2 
.mob Overseer Azarad
step
#scryer
.goto Netherstorm,25.936,38.721
>>Click to the |cRXP_PICK_Ara Control Console|r to start the event
>>Kill the |cRXP_ENEMY_Demons|r that try to stop the shutdown. The shutdown will complete after 2 minutes
.complete 10365,1 
.skipgossip
step
#scryer
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spymaster Thalodien|r
.turnin 10365 >> Turn in Shutting Down Manaforge Ara
.turnin 10432 >> Turn in Damning Evidence
.accept 10508 >> Accept A Gift for Voren'thal
.target Spymaster Thalodien
.goto Netherstorm,32.00,64.08
step
.skill riding,225,1
#completewith next
.goto Netherstorm,33.74,63.99
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Krexcil|r
.fly The Stormspire>> Fly to The Stormspire
.target Krexcil
.subzoneskip 3712,1
step
#scryer
.goto Netherstorm,36.85,27.82
>>Kill |cRXP_ENEMY_Morug|r. Loot him for the |cRXP_LOOT_First Half of Socrethar's Stone|r
>>|cRXP_WARN_This quest is difficult. Find a group for him if needed|r
.complete 10508,1 
.mob Forgemaster Morug
step
#scryer
.goto Netherstorm,40.87,19.54
>>Kill |cRXP_ENEMY_Silroth|r. Loot him for the |cRXP_LOOT_Second Half of Socrethar's Stone|r
>>|cRXP_WARN_This quest is difficult. Find a group for him if needed|r
.complete 10508,2 
.mob Silroth
step
.skill riding,225,1
#completewith next
.goto Netherstorm,45.31,34.87
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Grennik|r
.fly Area 52>> Fly to Area 52
.target Grennik
.subzoneskip 3712
step
#scryer
.goto Netherstorm,32.00,64.08
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Spymaster Thalodien|r
.turnin 10508 >> Turn in A Gift for Voren'thal
.accept 10509 >> Accept Bound for Glory
.target Spymaster Thalodien
step << !Mage
.skill riding,225,1
#completewith next
.goto Netherstorm,45.31,34.87
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Grennik|r
.fly Shattrath >> Fly to Shattrath
.target Grennik
.subzoneskip 3712
step << Mage
.cast 33690 >> |cRXP_WARN_Cast|r |T135760:0|t[Teleport: Shattrath]
.usespell 33690
.zoneskip Shattrath City
step
#completewith next
.zone Shattrath City >> Travel to Shattrath City
step
#scryer
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Voren'thal the Seer|r
.turnin 10509 >> Turn in Bound for Glory
.accept 10507 >> Accept Turning Point
.target Voren'thal the Seer
.goto Shattrath City,42.782,91.723
step
.skill riding,225,1
#completewith next
.goto Shattrath City,64.061,41.112
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nutral|r
.fly The Stormspire>> Fly to The Stormspire
.target Nutral
step
#optional
.goto Netherstorm,36.442,18.338
.xp >70,1
.cast 35745 >> |cRXP_WARN_Use|r |T134465:0|t[Socrethar's Teleportation Stone] |cRXP_WARN_at the teleporter to create a portal to Socrethar's Seat|r
>>|cRXP_WARN_You will need a 5 man group for this quest. It is recommended to have a dedicated Tank and Healer|r
.use 29796
step
#optional
.goto Netherstorm,36.442,18.338
.xp >70,1
.subzone 3742 >> Go through the teleporter to Socrethar's Seat
step
#optional
#completewith next
.subzone 3742 >> Fly on your mount to Socrethar's Seat
step
.goto Netherstorm,30.657,17.49,10,0 
.goto Netherstorm,29.324,13.704
>>Kill |cRXP_ENEMY_Socrethar|r
.use 30259 >>|cRXP_WARN_Use|r |T134335:0|t[Voren'thal's Presence] |cRXP_WARN_on |cRXP_ENEMY_Socrethar|r to weaken him|r
>>|cRXP_WARN_You will need a 5 man group for this quest. It is recommended to have a dedicated Tank and Healer|r
.complete 10507,1
.mob Socrethar
step
#completewith next
.zone Shattrath City >> Return to Shattrath City
step
#scryer
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Voren'thal the Seer|r
.turnin 10507 >> Turn in Turning Point
.target Voren'thal the Seer
.goto Shattrath City,42.782,91.723
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#group RXP TBC Reputation Guide
#subgroup The Aldor
#name 3. Shadowmoon Valley (Aldor)
step
#completewith next
.zone Shadowmoon Valley >> Travel to Shadowmoon Valley
step
#completewith next
.subzone 3754 >> Travel to the Altar of Sha'tar
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Exarch Onaala|r and |cRXP_FRIENDLY_Vindicator Aluumen|r
.accept 10619 >> Accept The Ashtongue Tribe
.target +Vindicator Aluumen
.goto Shadowmoon Valley,61.172,29.147,-1
.accept 10587 >> Accept Karabor Training Grounds
.goto Shadowmoon Valley,61.198,29.232,-1
.target +Exarch Onaala
step
.goto Shadowmoon Valley,62.648,28.445
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Anchorite Ceyla|r
.accept 10568 >> Accept Tablets of Baa'ri
.target Anchorite Ceyla
step
.skill riding,225,1
#completewith TabletFragments
.goto Shadowmoon Valley,54.86,33.349,40 >> Travel to the Ruins of Baa'ri
step
#completewith next
>>Kill |cRXP_ENEMY_Ashtongue Handlers|r, |cRXP_ENEMY_Ashtongue Warriors|r and |cRXP_ENEMY_Ashtongue Shamans|r
.complete 10619,1 
.mob +Ashtongue Handler
.complete 10619,2 
.mob +Ashtongue Warrior
.complete 10619,3 
.mob +Ashtongue Shaman
step
#label TabletFragments
#loop
.goto Shadowmoon Valley,56.0,37.1,0
.goto Shadowmoon Valley,59.0,34.9,70,0
.goto Shadowmoon Valley,56.0,37.1,70,0
.goto Shadowmoon Valley,59.1,39.3,70,0
>>Loot the |cRXP_PICK_Baa'ri Tablet Fragments|r on the ground
.complete 10568,1 
step
#loop
.goto Shadowmoon Valley,56.0,37.1,0
.goto Shadowmoon Valley,59.0,34.9,70,0
.goto Shadowmoon Valley,56.0,37.1,70,0
.goto Shadowmoon Valley,59.1,39.3,70,0
>>Kill |cRXP_ENEMY_Ashtongue Handlers|r, |cRXP_ENEMY_Ashtongue Warriors|r and |cRXP_ENEMY_Ashtongue Shamans|r
.complete 10619,1 
.mob +Ashtongue Handler
.complete 10619,2 
.mob +Ashtongue Warrior
.complete 10619,3 
.mob +Ashtongue Shaman
step
.goto Shadowmoon Valley,61.172,29.147
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Vindicator Aluumen|r
.turnin 10619 >> Turn in The Ashtongue Tribe
.accept 10816 >> Accept Reclaiming Holy Grounds
.target Vindicator Aluumen
step
.goto Shadowmoon Valley,62.648,28.445
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Anchorite Ceyla|r
.turnin 10568 >> Turn in Tablets of Baa'ri
.accept 10571 >> Accept Oronu the Elder
.target Anchorite Ceyla
step
.skill riding,225,1
#completewith next
.goto Shadowmoon Valley,54.86,33.349,40,0
.goto Shadowmoon Valley,56.14,35.05,60 >> Return to the Ruins of Baa'ri
step
.goto Shadowmoon Valley,57.191,32.877
>>Kill |cRXP_ENEMY_Oronu|r on the balcony
.complete 10571,1 
.mob Oronu the Elder
step
#label gizzard
.goto Shadowmoon Valley,62.648,28.445
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Anchorite Ceyla|r
.turnin 10571 >> Turn in Oronu the Elder
.accept 10574 >> Accept The Ashtongue Corruptors
.target Anchorite Ceyla
step
.goto Shadowmoon Valley,49.887,23.012
>>Destroy the totems protecting |cRXP_ENEMY_Lakaan|r. Kill and loot him for his |cRXP_LOOT_Medallion Fragment|r
.complete 10574,3 
.mob Lakaan
step
.goto Shadowmoon Valley,48.289,39.564
>>Destroy the totems protecting |cRXP_ENEMY_Uylaru|r. Kill and loot him for his |cRXP_LOOT_Medallion Fragment|r
.complete 10574,4 
.mob Uylaru
step
.goto Shadowmoon Valley,51.164,52.840
>>Destroy the totems protecting |cRXP_ENEMY_Eykenen|r. Kill and loot him for his |cRXP_LOOT_Medallion Fragment|r
.complete 10574,1 
.mob Eykenen
step
.goto Shadowmoon Valley,57.083,73.687
>>Destroy the totems protecting |cRXP_ENEMY_Haalum|r. Kill and loot him for |cRXP_LOOT_Haalum's Medallion Fragment|r
.complete 10574,2 
.mob Haalum
step
.goto Shadowmoon Valley,62.648,28.445
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Anchorite Ceyla|r
.turnin 10574 >> Turn in The Ashtongue Corruptors
.accept 10575 >> Accept The Warden's Cage
.target Anchorite Ceyla
step
#completewith next
+|cRXP_WARN_Go down the small opening to talk to |cRXP_FRIENDLY_Sanoru|r underground|r
step
.goto Shadowmoon Valley,57.328,49.577
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sanoru|r
.turnin 10575 >> Turn in The Warden's Cage
.target Sanoru
step
#loop
.goto Shadowmoon Valley,71.6,35.2,0
.goto Shadowmoon Valley,68.2,40.0,60,0
.goto Shadowmoon Valley,71.4,40.0,60,0
.goto Shadowmoon Valley,71.6,35.2,60,0
.goto Shadowmoon Valley,69.0,34.2,60,0
>>Kill |cRXP_ENEMY_Shadowmoon Slayers|r, |cRXP_ENEMY_Shadowmoon Chosens|r and |cRXP_ENEMY_Shadowmoon Darkweavers|r
.complete 10816,1 
.mob +Shadowmoon Slayer
.complete 10816,2 
.mob +Shadowmoon Chosen
.complete 10816,3 
.mob +Shadowmoon Darkweaver
step
.goto Shadowmoon Valley,68.8,49.2
>>Kill |cRXP_ENEMY_Demon Hunter Initiates|r and |cRXP_ENEMY_Demon Hunter Supplicants|r. Loot them for their |cRXP_LOOT_Sunfury Glaives|r
.complete 10587,1 
.mob Demon Hunter Supplicant
.mob Demon Hunter Initiate
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Exarch Onaala|r and |cRXP_FRIENDLY_Vindicator Aluumen|r
.turnin 10587 >> Turn in Karabor Training Grounds
.accept 10637 >> Accept A Necessary Distraction
.target +Exarch Onaala
.goto Shadowmoon Valley,61.198,29.232,-1
.turnin 10816 >> Turn in Reclaiming Holy Grounds
.target +Vindicator Aluumen
.goto Shadowmoon Valley,61.172,29.147,-1
step
#completewith next
.goto Shadowmoon Valley,69.8,51.0,0
.goto Shadowmoon Valley,72.2,49.2,0
.goto Shadowmoon Valley,71.4,52.6,0
.goto Shadowmoon Valley,69.8,51.0,50,0
.goto Shadowmoon Valley,72.2,49.2,50,0
.goto Shadowmoon Valley,71.4,52.6,50,0
>>Kill |cRXP_ENEMY_Sunfury Warlocks|r. Loot them for a |T134937:0|t[Scroll of Demonic Unbanishing]
.collect 30811,1,10637,1 
.mob Sunfury Warlock
step
.goto Shadowmoon Valley,69.841,51.410
.use 30811 >> |cRXP_WARN_Use the|r |T134937:0|t[Scroll of Demonic Unbanishing] |cRXP_WARN_on|r |cRXP_ENEMY_Azaloth|r
.complete 10637,1 
.mob Azaloth
step
.goto Shadowmoon Valley,61.198,29.232
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Exarch Onaala|r
.turnin 10637 >> Turn in A Necessary Distraction
.accept 10640 >> Accept Altruis
.target Exarch Onaala
step
#completewith next
.zone Nagrand >> Travel to Nagrand
step
.goto Nagrand,27.33,43.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Altruis the Sufferer|r
.turnin 10640 >> Turn in Altruis
.accept 10641 >> Accept Against the Legion
.accept 10668 >> Accept Against the Illidari
.accept 10669 >> Accept Against All Odds
.target Altruis the Sufferer
step
#completewith Xelethslain
.zone Zangarmarsh >> Travel to Zangarmarsh
step
#completewith next
.goto Zangarmarsh,16.234,40.689
.cast 37904 >>|cRXP_WARN_Use the|r |T135127:0|t[Imbued Silver Spear] |cRXP_WARN_at the portal to summon|r |cRXP_ENEMY_Xeleth|r
.use 30853
step
#label Xelethslain
.goto Zangarmarsh,16.234,40.689
>>Kill |cRXP_ENEMY_Xeleth|r
.complete 10669,1 
.mob Xeleth
step
#completewith next
.zone Netherstorm >> Travel to Netherstorm
step
.goto Netherstorm,41.2,21.6
>>Kill a |cRXP_ENEMY_Wrath Priestess|r. Loot them for their |T136124:0|t[|cRXP_LOOT_Freshly Drawn Blood|r]. Note this only lasts for 1 minute
.use 30850 >> |cRXP_WARN_Use the|r |T136124:0|t[|cRXP_LOOT_Freshly Drawn Blood|r] |cRXP_WARN_to summon the|r |cRXP_ENEMY_Avatar of Sathal|r
>>Kill the |cRXP_ENEMY_Avatar of Sathal|r
.collect 30850,1,10641,1
.mob +Wrath Priestess
.complete 10641,1 
.mob +Avatar of Sathal
step
#completewith next
.zone Shadowmoon Valley >> Travel to Shadowmoon Valley
step
.goto Shadowmoon Valley,28.6,50.6
>>Kill |cRXP_ENEMY_Lothros|r
>>|cRXP_WARN_He patrols slightly in Illidari Point|r
.complete 10668,1 
.mob Lothros
step
#completewith next
.zone Nagrand >> Travel to Nagrand
step
.goto Nagrand,27.33,43.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Altruis the Sufferer|r
.turnin 10641 >> Turn in Against the Legion
.turnin 10668 >> Turn in Against the Illidari
.turnin 10669 >> Turn in Against All Odds
.accept 10646 >> Accept Illidan's Pupil
.target Altruis the Sufferer
step
.goto Nagrand,27.33,43.09
>>Talk to |cRXP_FRIENDLY_Altruis the Sufferer|r
.complete 10646,1 
.skipgossip
step
.goto Nagrand,27.33,43.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Altruis the Sufferer|r
.turnin 10646 >> Turn in Illidan's Pupil
.accept 10649 >> Accept The Book of Fel Names
.target Altruis the Sufferer
step
>>You must now find a group and kill |cRXP_ENEMY_Blackheart the Inciter|r in the Shadow Labyrinth. Loot him for the |cRXP_LOOT_Book of Fel Names|r
.complete 10649,1 
step
#completewith next
.zone Nagrand >> Travel to Nagrand
step
.goto Nagrand,27.33,43.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Altruis the Sufferer|r
.turnin 10649 >> Turn in The Book of Fel Names
.accept 10650 >> Accept Return to the Aldor
.target Altruis the Sufferer
step
#completewith next
.zone Shadowmoon Valley >> Travel to Shadowmoon Valley
step
.goto Shadowmoon Valley,61.198,29.232
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Exarch Onaala|r
.turnin 10650 >> Turn in Return to the Aldor
.accept 10651 >> Accept Varedis Must Be Stopped
.target Exarch Onaala
step
>>Kill |cRXP_ENEMY_Varedis|r, |cRXP_ENEMY_Netharel|r, |cRXP_ENEMY_Theras|r and |cRXP_ENEMY_Alandien|r
>>|cRXP_WARN_It is recommended to complete this with a full group consisting of also a Tank and Healer|r
.use 30854 >> |cRXP_WARN_Use the|r |T133738:0|t[Book of Fel Names] |cRXP_WARN_on |cRXP_ENEMY_Varedis|r once he uses Metamorphosis. Note this has a 10 second cast time|r
.complete 10651,2 
.goto Shadowmoon Valley,68.73,52.73
.mob +Netharel
.complete 10651,3 
.goto Shadowmoon Valley,72.38,48.40
.mob +Theras
.complete 10651,4 
.goto Shadowmoon Valley,69.56,54.12
.mob +Alandien
.complete 10651,1 
.goto Shadowmoon Valley,72.18,53.68
.mob +Varedis
step
.goto Shadowmoon Valley,61.198,29.232
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Exarch Onaala|r
.turnin 10651 >> Turn in Varedis Must Be Stopped
.target Exarch Onaala
step
.goto Shadowmoon Valley,24.213,34.453
+|cRXP_WARN_Congratulations! You have reached the end of The Aldor reputation guide|r
>>Killing the |cRXP_ENEMY_Demons|r at Legion Hold for |T133832:0|t[|cRXP_FRIENDLY_Fel Armament|r] and |T136149:0|t[Mark of Sargeras] will increase your Aldor reputation when turned in. You may also buy these from the Auction House.
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#group RXP TBC Reputation Guide
#subgroup The Scryers
#name 3. Shadowmoon Valley (Scryers)
step
#completewith next
.subzone 3938 >> Travel to the Sanctum of the Stars in Shadowmoon Valley
step
.goto Shadowmoon Valley,54.730,58.199
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Varen the Reclaimer|r
.accept 10807 >> Accept The Ashtongue Broken
.target Varen the Reclaimer
step
.goto Shadowmoon Valley,55.732,58.168
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Larissa Sunstrike|r
.accept 10687 >> Accept Karabor Training Grounds
.target Larissa Sunstrike
step
.goto Shadowmoon Valley,56.258,59.586
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Arcanist Thelis|r
.accept 10683 >> Accept Tablets of Baa'ri
.target Arcanist Thelis
step
#completewith BaariFragments
.subzone 3753 >> Travel to the Ruins of Baa'ri
step
#completewith BaariFragments
>>Kill |cRXP_ENEMY_Ashtongue Handlers|r, |cRXP_ENEMY_Ashtongue Warriors|r and |cRXP_ENEMY_Ashtongue Shamans|r
.complete 10807,1 
.mob +Ashtongue Handler
.complete 10807,2 
.mob +Ashtongue Warrior
.complete 10807,3 
.mob +Ashtongue Shaman
step
#label BaariFragments
#loop
.goto Shadowmoon Valley,57.6,39.2,0
.goto Shadowmoon Valley,57.6,39.2,70,0
.goto Shadowmoon Valley,60.8,34.6,70,0
.goto Shadowmoon Valley,55.8,39.4,70,0
.goto Shadowmoon Valley,60.6,38.2,70,0
>>Loot the |cRXP_PICK_Baa'ri Tablet Fragments|r on the ground
.complete 10683,1 
step
#loop
.goto Shadowmoon Valley,57.6,39.2,0
.goto Shadowmoon Valley,57.6,39.2,70,0
.goto Shadowmoon Valley,60.8,34.6,70,0
.goto Shadowmoon Valley,55.8,39.4,70,0
.goto Shadowmoon Valley,60.6,38.2,70,0
>>Kill |cRXP_ENEMY_Ashtongue Handlers|r, |cRXP_ENEMY_Ashtongue Warriors|r and |cRXP_ENEMY_Ashtongue Shamans|r
.complete 10807,1 
.mob +Ashtongue Handler
.complete 10807,2 
.mob +Ashtongue Warrior
.complete 10807,3 
.mob +Ashtongue Shaman
step
.goto Shadowmoon Valley,54.730,58.199
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Varen the Reclaimer|r
.turnin 10807 >> Turn in The Ashtongue Broken
.accept 10817 >> Accept The Great Retribution
.target Varen the Reclaimer
step
.goto Shadowmoon Valley,56.258,59.586
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Arcanist Thelis|r
.turnin 10683 >> Turn in Tablets of Baa'ri
.accept 10684 >> Accept Oronu the Elder
.target Arcanist Thelis
step
#completewith next
.subzone 3753 >> Travel to the Ruins of Baa'ri again
step
.goto Shadowmoon Valley,57.191,32.877
>>Kill |cRXP_ENEMY_Oronu|r on the balcony
.complete 10684,1 
.mob Oronu the Elder
step
.goto Shadowmoon Valley,56.258,59.586
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Arcanist Thelis|r
.turnin 10684 >> Turn in Oronu the Elder
.accept 10685 >> Accept The Ashtongue Corruptors
.target Arcanist Thelis
step
.goto Shadowmoon Valley,57.083,73.687
>>Destroy the totems protecting |cRXP_ENEMY_Haalum|r. Kill and loot him for |cRXP_LOOT_Haalum's Medallion Fragment|r
.complete 10685,2 
.mob Haalum
step
.goto Shadowmoon Valley,51.164,52.840
>>Destroy the totems protecting |cRXP_ENEMY_Eykenen|r. Kill and loot him for his |cRXP_LOOT_Medallion Fragment|r
.complete 10685,1 
.mob Eykenen
step
.goto Shadowmoon Valley,48.289,39.564
>>Destroy the totems protecting |cRXP_ENEMY_Uylaru|r. Kill and loot him for his |cRXP_LOOT_Medallion Fragment|r
.complete 10685,4 
.mob Uylaru
step
.goto Shadowmoon Valley,49.887,23.012
>>Destroy the totems protecting |cRXP_ENEMY_Lakaan|r. Kill and loot him for his |cRXP_LOOT_Medallion Fragment|r
.complete 10685,3 
.mob Lakaan
step
.goto Shadowmoon Valley,56.258,59.586
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Arcanist Thelis|r
.turnin 10685 >> Turn in The Ashtongue Corruptors
.accept 10686 >> Accept The Warden's Cage
.target Arcanist Thelis
step
#completewith next
+|cRXP_WARN_Go down the small opening to talk to |cRXP_FRIENDLY_Sanoru|r underground|r
step
.goto Shadowmoon Valley,57.328,49.577
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Sanoru|r
.turnin 10686 >> Turn in The Warden's Cage
.target Sanoru
step
.goto Shadowmoon Valley,68.8,49.2
>>Kill |cRXP_ENEMY_Demon Hunter Initiates|r and |cRXP_ENEMY_Demon Hunter Supplicants|r. Loot them for their |cRXP_LOOT_Sunfury Glaives|r
.complete 10687,1 
.mob Demon Hunter Supplicant
.mob Demon Hunter Initiate
step
#loop
.goto Shadowmoon Valley,71.6,35.2,0
.goto Shadowmoon Valley,68.2,40.0,60,0
.goto Shadowmoon Valley,71.4,40.0,60,0
.goto Shadowmoon Valley,71.6,35.2,60,0
.goto Shadowmoon Valley,69.0,34.2,60,0
>>Kill |cRXP_ENEMY_Shadowmoon Slayers|r, |cRXP_ENEMY_Shadowmoon Chosens|r and |cRXP_ENEMY_Shadowmoon Darkweavers|r
.complete 10817,1 
.mob +Shadowmoon Slayer
.complete 10817,2 
.mob +Shadowmoon Chosen
.complete 10817,3 
.mob +Shadowmoon Darkweaver
step
#completewith next
.subzone 3938 >> Return to the Sanctum of the Stars
step
.isQuestComplete 10817
.goto Shadowmoon Valley,54.730,58.199
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Varen the Reclaimer|r
.turnin 10817 >> Turn in The Great Retribution
.target Varen the Reclaimer
step
.goto Shadowmoon Valley,55.732,58.168
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Larissa Sunstrike|r
.turnin 10687 >> Turn in Karabor Training Grounds
.accept 10688 >> Accept A Necessary Distraction
.target Larissa Sunstrike
step
#completewith next
.goto Shadowmoon Valley,69.8,51.0,0
.goto Shadowmoon Valley,72.2,49.2,0
.goto Shadowmoon Valley,71.4,52.6,0
.goto Shadowmoon Valley,69.8,51.0,50,0
.goto Shadowmoon Valley,72.2,49.2,50,0
.goto Shadowmoon Valley,71.4,52.6,50,0
>>Kill |cRXP_ENEMY_Sunfury Warlocks|r. Loot them for a |T134937:0|t[Scroll of Demonic Unbanishing]
.collect 30811,1,10637,1 
.mob Sunfury Warlock
step
.goto Shadowmoon Valley,69.841,51.410
.use 30811 >> |cRXP_WARN_Use the|r |T134937:0|t[Scroll of Demonic Unbanishing] |cRXP_WARN_on|r |cRXP_ENEMY_Azaloth|r
.complete 10688,1 
.mob Azaloth
step
#optional
#completewith next
.subzone 3938 >> Return to the Sanctum of the Stars
step
.goto Shadowmoon Valley,55.732,58.168
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Larissa Sunstrike|r
.turnin 10688 >> Turn in A Necessary Distraction
.accept 10689 >> Accept Altruis
.target Larissa Sunstrike
step
#completewith next
.zone Nagrand >> Travel to Nagrand
step
.goto Nagrand,27.33,43.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Altruis the Sufferer|r
.turnin 10689 >> Turn in Altruis
.accept 10641 >> Accept Against the Legion
.accept 10668 >> Accept Against the Illidari
.accept 10669 >> Accept Against All Odds
.target Altruis the Sufferer
step
#completewith Xelethslain
.zone Zangarmarsh >> Travel to Zangarmarsh
step
#completewith next
.goto Zangarmarsh,16.234,40.689
.cast 37904 >>|cRXP_WARN_Use the|r |T135127:0|t[Imbued Silver Spear] |cRXP_WARN_at the portal to summon|r |cRXP_ENEMY_Xeleth|r
.use 30853
step
#label Xelethslain
.goto Zangarmarsh,16.234,40.689
>>Kill |cRXP_ENEMY_Xeleth|r
.complete 10669,1 
.mob Xeleth
step
#completewith next
.zone Netherstorm >> Travel to Netherstorm
step
.goto Netherstorm,41.2,21.6
>>Kill a |cRXP_ENEMY_Wrath Priestess|r. Loot them for their |T136124:0|t[|cRXP_LOOT_Freshly Drawn Blood|r]. Note this only lasts for 1 minute
.use 30850 >> |cRXP_WARN_Use the|r |T136124:0|t[|cRXP_LOOT_Freshly Drawn Blood|r] |cRXP_WARN_to summon the|r |cRXP_ENEMY_Avatar of Sathal|r
>>Kill the |cRXP_ENEMY_Avatar of Sathal|r
.collect 30850,1,10641,1
.mob +Wrath Priestess
.complete 10641,1 
.mob +Avatar of Sathal
step
#completewith next
.zone Shadowmoon Valley >> Travel to Shadowmoon Valley
step
.goto Shadowmoon Valley,28.6,50.6
>>Kill |cRXP_ENEMY_Lothros|r
>>|cRXP_WARN_He patrols slightly in Illidari Point|r
.complete 10668,1 
.mob Lothros
step
#completewith next
.zone Nagrand >> Travel to Nagrand
step
.goto Nagrand,27.33,43.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Altruis the Sufferer|r
.turnin 10641 >> Turn in Against the Legion
.turnin 10668 >> Turn in Against the Illidari
.turnin 10669 >> Turn in Against All Odds
.accept 10646 >> Accept Illidan's Pupil
.target Altruis the Sufferer
step
.goto Nagrand,27.33,43.09
>>Talk to |cRXP_FRIENDLY_Altruis the Sufferer|r
.complete 10646,1 
.skipgossip
step
.goto Nagrand,27.33,43.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Altruis the Sufferer|r
.turnin 10646 >> Turn in Illidan's Pupil
.accept 10649 >> Accept The Book of Fel Names
.target Altruis the Sufferer
step
>>You must now find a group and kill |cRXP_ENEMY_Blackheart the Inciter|r in the Shadow Labyrinth. Loot him for the |cRXP_LOOT_Book of Fel Names|r
.complete 10649,1 
step
#completewith next
.zone Nagrand >> Travel to Nagrand
step
.goto Nagrand,27.33,43.09
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Altruis the Sufferer|r
.turnin 10649 >> Turn in The Book of Fel Names
.accept 10691 >> Accept Return to the Scryers
.target Altruis the Sufferer
step
#completewith next
.zone Shadowmoon Valley >> Travel to Shadowmoon Valley
step
.goto Shadowmoon Valley,55.732,58.168
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Larissa Sunstrike|r
.turnin 10691 >> Turn in Return to the Scryers
.accept 10692 >> Accept Varedis Must Be Stopped
.target Larissa Sunstrike
step
>>Kill |cRXP_ENEMY_Varedis|r, |cRXP_ENEMY_Netharel|r, |cRXP_ENEMY_Theras|r and |cRXP_ENEMY_Alandien|r
>>|cRXP_WARN_It is recommended to complete this with a full group consisting of also a Tank and Healer|r
.use 30854 >> |cRXP_WARN_Use the|r |T133738:0|t[Book of Fel Names] |cRXP_WARN_on |cRXP_ENEMY_Varedis|r once he uses Metamorphosis. Note this has a 10 second cast time|r
.complete 10692,2 
.goto Shadowmoon Valley,68.73,52.73
.mob +Netharel
.complete 10692,3 
.goto Shadowmoon Valley,72.38,48.40
.mob +Theras
.complete 10692,4 
.goto Shadowmoon Valley,69.56,54.12
.mob +Alandien
.complete 10692,1 
.goto Shadowmoon Valley,72.18,53.68
.mob +Varedis
step
.goto Shadowmoon Valley,55.732,58.168
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Larissa Sunstrike|r
.turnin 10692 >> Turn in Varedis Must Be Stopped
.target Larissa Sunstrike
step
.goto Netherstorm,46.261,81.381,0
.goto Netherstorm,57.97,63.173,0
+|cRXP_WARN_Congratulations! You have reached the end of The Scryers reputation guide|r
>>Killing the |cRXP_ENEMY_Sunfury|r in Netherstorm for |T133739:0|t[|cRXP_FRIENDLY_Arcane Tome|r] and |T133378:0|t[Sunfury Signet] will increase your Scryers reputation when turned in. You may also buy these from the Auction House.
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#group RXP TBC Reputation Guide
#name Netherwing
#subgroup Netherwing
#displayname |cFF1EFF001|r - Netherwing
#title Netherwing
#subweight -1
step
+|cRXP_WARN_The Netherwing daily quests will not unlock until Phase 3 has launched. This is currently estimated to go live in Summer 2026|r
step
#completewith next
.zone 1948 >> Travel to Shadowmoon Valley
step
.goto Shadowmoon Valley,62.245,60.081
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mordenai|r
>>|cRXP_FRIENDLY_Mordenai|r |cRXP_WARN_patrols slightly|r
.target Mordenai
.accept 10804 >>Accept Kindness
step
#loop
.goto 1948,59.2,57.0,0
.goto 1948,63.6,55.4,0
.goto 1948,64.0,60.4,0
.goto 1948,59.2,57.0,70,0
.goto 1948,63.6,55.4,70,0
.goto 1948,64.0,60.4,70,0
>>Kill |cRXP_ENEMY_Rocknail Flayers|r. Loot them for their |T134368:0|t[|cRXP_LOOT_Rocknail Flayer Carcasses|r]
.use 31373 >>|cRXP_WARN_You can also kill |cRXP_ENEMY_Rocknail Rippers|r for their|r |T134341:0|t[|cRXP_LOOT_Rocknail Flayer Giblets|r]|cRXP_WARN_, then combine 5 of them into a|r |T134368:0|t[|cRXP_LOOT_Rocknail Flayer Carcass|r]
.use 31372 >>|cRXP_WARN_Use the|r |T134368:0|t[|cRXP_LOOT_Rocknail Flayer Carcass|r] |cRXP_WARN_and wait for the|r |cRXP_ENEMY_Mature Netherwing Drake|r |cRXP_WARN_to eat it|r
.complete 10804,1 
.mob Rocknail Flayer
.mob Rocknail Ripper
step
.goto Shadowmoon Valley,59.115,58.701
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mordenai|r
>>|cRXP_FRIENDLY_Mordenai|r |cRXP_WARN_patrols slightly|r
.target Mordenai
.turnin 10804 >>Turn in Kindness
.accept 10811 >>Accept Seek Out Neltharaku
step
.goto Shadowmoon Valley,69.333,62.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Neltharaku|r
>>|cRXP_FRIENDLY_Neltharaku|r |cRXP_WARN_is in the air flying above Dragonmaw Fortress and Netherwing Fields|r
.target Neltharaku
.turnin 10811 >>Turn in Seek Out Neltharaku
.accept 10814 >>Accept Neltharaku's Tale
step
.goto Shadowmoon Valley,69.305,62.476
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Neltharaku|r
.complete 10814,1 
.skipgossip
.target Neltharaku
step
.goto Shadowmoon Valley,69.305,62.476
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Neltharaku|r
.turnin 10814 >>Turn in Neltharaku's Tale
.accept 10836 >>Accept Infiltrating Dragonmaw Fortress
.target Neltharaku
step
#loop
.goto 1948,68.8,60.2,0
.goto 1948,66.6,59.4,70,0
.goto 1948,71.4,63.4,70,0
>>Kill |cRXP_ENEMY_Dragonmaw Orcs|r
.complete 10836,1 
step
.goto Shadowmoon Valley,68.071,60.531
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Neltharaku|r
>>|cRXP_FRIENDLY_Neltharaku|r |cRXP_WARN_is in the air flying above Dragonmaw Fortress and Netherwing Fields|r
.target Neltharaku
.turnin 10836 >>Turn in Infiltrating Dragonmaw Fortress
.accept 10837 >>Accept To Netherwing Ledge!
step
#completewith next
.subzone 3759 >> Travel to Netherwing Ledge
step
#loop
.goto 1948,67.7,80.2,0
.goto 1948,75.6,82.8,0
.goto 1948,74.1,90.7,0
.goto 1948,70.2,89.9,0
.goto 1948,67.7,80.2,70,0
.goto 1948,75.6,82.8,70,0
.goto 1948,74.1,90.7,70,0
.goto 1948,70.2,89.9,70,0
>>Loot the |cRXP_PICK_Nethervine Crystals|r on the ground
.complete 10837,1 
step
.goto Shadowmoon Valley,67.622,60.36
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Neltharaku|r
>>|cRXP_FRIENDLY_Neltharaku|r |cRXP_WARN_is in the air flying above Dragonmaw Fortress and Netherwing Fields|r
.target Neltharaku
.turnin 10837 >>Turn in To Netherwing Ledge!
.accept 10854 >>Accept The Force of Neltharaku
step
#loop
.goto 1948,71.6,64.0,0
.goto 1948,68.6,58.0,0
.goto 1948,67.6,61.8,0
.goto 1948,71.6,64.0,70,0
.goto 1948,68.6,58.0,70,0
.goto 1948,67.6,61.8,70,0
.use 31652 >> |cRXP_WARN_Use the|r |T134081:0|t[Enchanted Nethervine Crystal] |cRXP_WARN_on|r |cRXP_FRIENDLY_Enslaved Netherwing Drakes|r
>>Kill the |cRXP_ENEMY_Dragonmaw Subjugator|r afterwards
.complete 10854,1 
.target Enslaved Netherwing Drake
step
.goto Shadowmoon Valley,66.518,60.422
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Neltharaku|r
>>|cRXP_FRIENDLY_Neltharaku|r |cRXP_WARN_is in the air flying above Dragonmaw Fortress and Netherwing Fields|r
.target Neltharaku
.turnin 10854 >>Turn in The Force of Neltharaku
.accept 10858 >>Accept Karynaku
step
.goto Shadowmoon Valley,69.869,61.445
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Karynaku|r
>>|cRXP_WARN_Before you turn this quest in, start looking for a 5 man group for the quest Zuluhed the Whacked|r
.target Karynaku
.turnin 10858 >>Turn in Karynaku
.accept 10866 >>Accept Zuluhed the Whacked
step
.goto Shadowmoon Valley,70.705,61.352
>>Kill |cRXP_ENEMY_Zuluhed the Whacked|r. Loot him for |cRXP_LOOT_Zuluhed's Key|r
.complete 10866,2
.mob Zuluhed the Whacked
step
.goto Shadowmoon Valley,69.845,61.287
>>Click |cRXP_PICK_Zuluhed's Chains|r
.complete 10866,1
step
.goto Shadowmoon Valley,69.867,61.453
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Karynaku|r
.target Karynaku
.turnin 10866 >>Turn in Zuluhed the Whacked
.accept 10870 >>Accept Ally of the Netherwing
step
.goto Shadowmoon Valley,59.327,58.693
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mordenai|r
.target Mordenai
.turnin 10870 >>Turn in Ally of the Netherwing
step
.goto Shadowmoon Valley,59.327,58.693
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mordenai|r
>>|cRXP_WARN_Artisan Riding is required to continue further|r
>>|cRXP_WARN_You can train this from |cRXP_FRIENDLY_Ilsa Blusterbrew|r for 5000g at Wildhammer Stronghold|r << Alliance
>>|cRXP_WARN_You can train this from |cRXP_FRIENDLY_Olrokk|r for 5000g at Shadowmoon Village|r << Horde
.target Mordenai
.target Ilsa Blusterbrew << Alliance
.target Olrokk << Horde
.accept 11012 >>Accept Blood Oath of the Netherwing
.turnin 11012 >>Turn in Blood Oath of the Netherwing
step
.goto Shadowmoon Valley,59.327,58.693
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mordenai|r
.target Mordenai
.accept 11013 >>Accept In Service of the Illidari
step
#completewith next
.subzone 3759 >> Travel to Netherwing Ledge
step
.goto Shadowmoon Valley,66.216,85.655
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.turnin 11013 >>Turn in In Service of the Illidari
.accept 11014 >>Accept Enter the Taskmaster
step
.goto Shadowmoon Valley,66.118,86.353
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.turnin 11014 >>Turn in Enter the Taskmaster
step
.goto Shadowmoon Valley,66,86.465
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yarzill the Merc|r
.target Yarzill the Merc
.accept 11019 >>Accept Your Friend On The Inside
.turnin 11019 >>Turn in Your Friend On The Inside
step
.goto Shadowmoon Valley,66,86.465
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yarzill the Merc|r
.target Yarzill the Merc
.accept 11049 >>Accept The Great Netherwing Egg Hunt
step
#optional
.isQuestComplete 11049
.goto Shadowmoon Valley,66,86.465
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yarzill the Merc|r
.target Yarzill the Merc
.turnin 11049 >>Turn in The Great Netherwing Egg Hunt
step 
#aldor
.isQuestTurnedIn 11100
#completewith next
.subzone 3754 >> Travel to the Altar of Sha'tar
step 
#scryer
.isQuestTurnedIn 11095
#completewith next
.subzone 3938 >> Travel to the Sanctum of the Stars
step 
#aldor
.isQuestTurnedIn 11100
.goto Shadowmoon Valley,62.384,29.329
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Arcus|r
.daily 11101 >> Accept The Deadliest Trap Ever Laid
.target Commander Arcus
step 
#scryer
.isQuestTurnedIn 11095
.goto Shadowmoon Valley,56.482,58.647
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Hobb|r
.daily 11097 >> Accept The Deadliest Trap Ever Laid
.target Commander Hobb
step
#aldor
.isOnQuest 11101
.goto Shadowmoon Valley,64.516,31.011
>>Kill the attacking |cRXP_ENEMY_Dragonmaw Skybreakers|r
>>|cRXP_WARN_Focus on staying alive and let the friendly NPCs tank them. The quest will complete after about 2 minutes|r
.complete 11101,1 
.mob Dragonmaw Skybreaker
step
#scryer
.isOnQuest 11097
.goto Shadowmoon Valley,57.48,57.662
>>Kill the attacking |cRXP_ENEMY_Dragonmaw Skybreakers|r
>>|cRXP_WARN_Focus on staying alive and let the friendly NPCs tank them. The quest will complete after about 2 minutes|r
.complete 11097,1 
.mob Dragonmaw Skybreaker
step
#completewith AcceptDaily
.subzone 3759 >> Travel to Netherwing Ledge
step
#aldor
.isOnQuest 11101
.goto Shadowmoon Valley,66.298,85.557
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.dailyturnin 11101 >>Turn in The Deadliest Trap Ever Laid
step
#scryer
.isOnQuest 11097
.goto Shadowmoon Valley,66.298,85.557
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.dailyturnin 11097 >>Turn in The Deadliest Trap Ever Laid
step 
.isQuestTurnedIn 11084
.goto Shadowmoon Valley,66.298,85.557
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.daily 11086 >>Accept Disrupting the Twilight Portal
step
.goto Shadowmoon Valley,65.996,86.465
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yarzill the Merc|r
.target Yarzill the Merc
.daily 11020 >>Accept A Slow Death
.daily 11035 >>Accept The Not-So-Friendly Skies...
step
.goto Shadowmoon Valley,66.118,86.364
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.daily 11015 >>Accept Netherwing Crystals
.daily 11017 >>Accept Netherdust Pollen
.skill herbalism,<350,1 
step
.isNotOnQuest 11017 
.goto Shadowmoon Valley,66.118,86.364
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.daily 11015 >>Accept Netherwing Crystals
.daily 11018 >>Accept Nethercite Ore
.skill mining,<350,1 
step
.isNotOnQuest 11017
.isNotOnQuest 11018
.goto Shadowmoon Valley,66.118,86.364
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.daily 11015 >>Accept Netherwing Crystals
.daily 11016 >>Accept Nethermine Flayer Hide
.skill skinning,<355,1 
step
#label AcceptDaily
.goto Shadowmoon Valley,66.118,86.364
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.daily 11015 >>Accept Netherwing Crystals
step 
.isQuestTurnedIn 11054
.goto Shadowmoon Valley,66.86,86.105
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chief Overseer Mudlump|r
.target Chief Overseer Mudlump
.daily 11055 >>Accept The Booterang: A Cure For The Common Worthless Peon
step
.isOnQuest 11015
#sticky
#label NetherwingCrystals
#loop
.waypoint Shadowmoon Valley,76.196,88.341,70,0
.waypoint Shadowmoon Valley,72.905,81.673,70,0
.waypoint Shadowmoon Valley,64.365,80.981,70,0
.waypoint Shadowmoon Valley,73.027,85.554,70,0
>>Kill |cRXP_ENEMY_any mobs|r on Netherwing Ledge. Loot them for their |cRXP_LOOT_Netherwing Crystals|r
.complete 11015,1 
step
.isOnQuest 11016
#sticky
#label NethermineFlayerHide
#loop
.waypoint Shadowmoon Valley,71.116,85.682,40,0
.waypoint Shadowmoon Valley,73.956,85.827,40,0
.waypoint Shadowmoon Valley,72.062,83.79,40,0
>>Kill |cRXP_ENEMY_Overmine Flayers|r. Skin them for their |cRXP_LOOT_Nethermine Flayer Hides|r
>>|cRXP_WARN_The |cRXP_ENEMY_Flayers|r inside the Mines can also be skinned for|r |cRXP_LOOT_Nethermine Flayer Hides|r
.complete 11016,1 
.mob Overmine Flayer
step
.isOnQuest 11018
#sticky
#label NetherciteOre
#loop
.waypoint Shadowmoon Valley,76.196,88.341,70,0
.waypoint Shadowmoon Valley,72.905,81.673,70,0
.waypoint Shadowmoon Valley,64.365,80.981,70,0
.waypoint Shadowmoon Valley,73.027,85.554,70,0
>>Mine the |cRXP_PICK_Nethercite Deposits|r for |cRXP_LOOT_Nethercite Ore|r
>>|cRXP_WARN_Remember to have|r |T136025:0|t[Find Minerals] |cRXP_WARN_on|r
.complete 11018,1 
step
.isOnQuest 11017
#sticky
#label NetherdustPollen
#loop
.waypoint Shadowmoon Valley,76.196,88.341,70,0
.waypoint Shadowmoon Valley,72.905,81.673,70,0
.waypoint Shadowmoon Valley,64.365,80.981,70,0
.waypoint Shadowmoon Valley,73.027,85.554,70,0
>>Pick the |cRXP_PICK_Netherdust Bushes|r for |cRXP_LOOT_Netherdust Pollen|r
>>|cRXP_WARN_Remember to have|r |T133939:0|t[Find Herbs] |cRXP_WARN_on|r
.complete 11017,1 
step
.isOnQuest 11020
#sticky
#label PeonPoisoned
#loop
.waypoint Shadowmoon Valley,76.196,88.341,70,0
.waypoint Shadowmoon Valley,72.905,81.673,70,0
.waypoint Shadowmoon Valley,64.365,80.981,70,0
.waypoint Shadowmoon Valley,73.027,85.554,70,0
>>Kill the |cRXP_ENEMY_Wildlife|r on Netherwing Ledge. Loot them for their |cRXP_LOOT_Fel Glands|r
.use 32503 >>|cRXP_WARN_Use|r |T134016:0|t[Yarzill's Mutton] |cRXP_WARN_next to|r |cRXP_ENEMY_Dragonmaw Peons|r
.collect 32502,12,11020,1,-1 
.complete 11020,1 
.mob Dragonmaw Peon
step
.isOnQuest 11035
#sticky
#label NetherwingRelics
#loop
.waypoint 1948,74.6,75.7,0
.waypoint 1948,72.0,75.1,0
.waypoint 1948,72.3,64.3,0
.waypoint 1948,72.0,75.1,40,0
.waypoint 1948,74.6,75.7,40,0
.waypoint 1948,72.3,64.3,40,0
>>Kill |cRXP_ENEMY_Dragonmaw Transporters|r. Loot them for their |cRXP_LOOT_Netherwing Relics|r
.complete 11035,1 
.mob Dragonmaw Transporter
step
.isOnQuest 11055
#sticky
#label PeonDisciplined
#loop
.waypoint 1948,68.0,90.2,70,0
.waypoint 1948,75.6,89.6,70,0
.waypoint 1948,77.4,82.8,70,0
.waypoint 1948,70.0,80.6,70,0
.waypoint 1948,62.4,81.6,70,0
.waypoint 1948,64.8,90.8,70,0
.use 32680 >> |cRXP_WARN_Use the|r |T132544:0|t[Booterang] |cRXP_WARN_on|r |cRXP_ENEMY_Disobedient Dragonmaw Peons|r
>>|cRXP_WARN_You can complete this while on your flying mount|r
.complete 11055,1 
.mob Disobedient Dragonmaw Peon
step
#requires NetherwingCrystals
step
#requires NethermineFlayerHide
step
#requires NetherciteOre
step
#requires NetherdustPollen
step
#requires PeonPoisoned
step
#requires NetherwingRelics
step
#requires PeonDisciplined
step
.isOnQuest 11055
.goto Shadowmoon Valley,66.856,86.102
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chief Overseer Mudlump|r
.target Chief Overseer Mudlump
.dailyturnin 11055 >>Turn in The Booterang: A Cure For The Common Worthless Peon
step
.isOnQuest 11015
.goto Shadowmoon Valley,66.118,86.364
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.dailyturnin 11015 >>Turn in Netherwing Crystals
step
.isQuestComplete 11016
.goto Shadowmoon Valley,66.118,86.364
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.dailyturnin 11016 >>Turn in Nethermine Flayer Hide
step
.isQuestComplete 11018
.goto Shadowmoon Valley,66.118,86.364
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.dailyturnin 11018 >>Turn in Nethercite Ore
step
.isQuestComplete 11017
.goto Shadowmoon Valley,66.118,86.364
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.dailyturnin 11017 >>Turn in Netherdust Pollen
step
.isOnQuest 11020
.goto Shadowmoon Valley,65.996,86.465
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yarzill the Merc|r
.target Yarzill the Merc
.dailyturnin 11020 >>Turn in A Slow Death
step
.isOnQuest 11035
.goto Shadowmoon Valley,65.996,86.465
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Yarzill the Merc|r
.target Yarzill the Merc
.dailyturnin 11035 >>Turn in The Not-So-Friendly Skies...
step 
.isQuestTurnedIn 11053
.isQuestTurnedIn 11075
.goto Shadowmoon Valley,65.431,90.136
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mistress of the Mines|r
.target Mistress of the Mines
.daily 11076 >>Accept Picking Up The Pieces...
step 
.isOnQuest 11076
#completewith next
.goto Shadowmoon Valley,65.355,89.312,10 >> Enter the Dragonmaw Mines
step 
.isQuestTurnedIn 11053
.isQuestTurnedIn 11075
#loop
.goto Shadowmoon Valley,65.469,89.233,10,0
.goto Shadowmoon Valley,65.031,87.346,10,0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to a |cRXP_FRIENDLY_Dragonmaw Foreman|r
>>|cRXP_WARN_They patrol slightly inside the Mines|r
.target Dragonmaw Foreman
.daily 11077 >>Accept Dragons are the Least of Our Problems
step
.isOnQuest 11076
#sticky
#label NethermineCargo2
#loop
.waypoint Shadowmoon Valley,65.48,82.456,50,0
.waypoint Shadowmoon Valley,68.56,81.496,50,0
.waypoint Shadowmoon Valley,73.705,84.889,50,0
.waypoint Shadowmoon Valley,73.816,88.148,50,0
.waypoint Shadowmoon Valley,69.893,86.659,50,0
.waypoint Shadowmoon Valley,67.573,83.28,50,0
.waypoint Shadowmoon Valley,64.975,85.361,50,0
>>Loot the |cRXP_PICK_Nethermine Cargo|r carts
.complete 11076,1 
step
.isOnQuest 11077
#sticky
#label NethermineFlayerRavager2
#loop
.waypoint Shadowmoon Valley,65.48,82.456,50,0
.waypoint Shadowmoon Valley,68.56,81.496,50,0
.waypoint Shadowmoon Valley,73.705,84.889,50,0
.waypoint Shadowmoon Valley,73.816,88.148,50,0
>>Kill |cRXP_ENEMY_Nethermine Flayers|r and |cRXP_ENEMY_Nethermine Ravagers|r
.complete 11077,1 
.mob +Nethermine Flayer
.complete 11077,2 
.mob +Nethermine Ravager
step
.isOnQuest 11016
#sticky
#label NethermineFlayerHide2
#loop
.waypoint Shadowmoon Valley,65.48,82.456,50,0
.waypoint Shadowmoon Valley,68.56,81.496,50,0
.waypoint Shadowmoon Valley,73.705,84.889,50,0
.waypoint Shadowmoon Valley,73.816,88.148,50,0
>>Kill |cRXP_ENEMY_Overmine Flayers|r. Skin them for their |cRXP_LOOT_Nethermine Flayer Hides|r
>>|cRXP_WARN_The |cRXP_ENEMY_Flayers|r inside the Mines can also be skinned for|r |cRXP_LOOT_Nethermine Flayer Hides|r
.complete 11016,1 
.mob Overmine Flayer
step
#requires NethermineCargo2
step
#requires NethermineFlayerRavager2
step
#requires NethermineFlayerHide2
step
.isOnQuest 11077
.goto Shadowmoon Valley,65.371,89.018
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to a |cRXP_FRIENDLY_Dragonmaw Foreman|r
>>|cRXP_WARN_They patrol slightly inside the Mines|r
.target Dragonmaw Foreman
.dailyturnin 11077 >>Turn in Dragons are the Least of Our Problems
step
.isOnQuest 11076
.goto Shadowmoon Valley,65.431,90.136
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mistress of the Mines|r
.target Mistress of the Mines
.dailyturnin 11076 >>Turn in Picking Up The Pieces...
step
.isQuestComplete 11016
.goto Shadowmoon Valley,66.118,86.364
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.dailyturnin 11016 >>Turn in Nethermine Flayer Hide
step 
#completewith next
.zone Nagrand >> Travel to Nagrand
step
.isOnQuest 11086
#loop
.goto Nagrand,12.031,39.013,70,0
.goto Nagrand,8.248,40.826,70,0
.goto Nagrand,10.158,43.381,70,0
>>Kill the |cRXP_ENEMY_Deathshadow Agents|r
.complete 11086,1 
.mob Deathshadow Acolyte
.mob Deathshadow Archon
.mob Deathshadow Overlord
.mob Deathshadow Spellbinder
.mob Deathshadow Warlock
.mob Deathshadow Agent
step
.isOnQuest 11086
.goto Shadowmoon Valley,66.296,85.557
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.dailyturnin 11086 >>Turn in Disrupting the Twilight Portal
step 
#optional
.isQuestTurnedIn 11108
+|cRXP_WARN_You have completed all available daily quests for Netherwing today. Load the same guide again tomorrow once the daily quests have reset to complete more daily quests|r
step 
+|cRXP_WARN_You have completed all available daily quests for Netherwing today. Load the same guide again tomorrow once the daily quests have reset to complete more daily quests|r
>>|cRXP_WARN_You can earn more reputation by finding|r |T134430:0|t[|cRXP_FRIENDLY_Netherwing Eggs|r] |cRXP_WARN_and turning them in at |cRXP_FRIENDLY_Yarzill the Merc|r at the Dragonmaw Base Camp. These can be found randomly on Netherwing Ledge or a very low drop chance from all mobs|r
.reputation 1015,friendly,>0,1 
step
.goto Shadowmoon Valley,66.12,86.359
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.accept 11053 >>Accept Rise, Overseer!
.reputation 1015,friendly,<0,1 
step
.isOnQuest 11053
.goto Shadowmoon Valley,66.296,85.557
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.turnin 11053 >>Turn in Rise, Overseer!
step
.isQuestTurnedIn 11053
.goto Shadowmoon Valley,66.118,86.359
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.accept 11075 >>Accept The Netherwing Mines
step
.isQuestTurnedIn 11053
.goto Shadowmoon Valley,65.431,90.136
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mistress of the Mines|r
.target Mistress of the Mines
.turnin 11075 >>Turn in The Netherwing Mines
step
.isQuestTurnedIn 11053
.goto Shadowmoon Valley,65.431,90.136
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mistress of the Mines|r
.target Mistress of the Mines
.daily 11076 >>Accept Picking Up The Pieces...
step
.isOnQuest 11076
#completewith next
.goto Shadowmoon Valley,65.355,89.312,10 >> Enter the Dragonmaw Mines
step
.isQuestTurnedIn 11053
#loop
.goto Shadowmoon Valley,65.469,89.233,10,0
.goto Shadowmoon Valley,65.031,87.346,10,0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to a |cRXP_FRIENDLY_Dragonmaw Foreman|r
>>|cRXP_WARN_They patrol slightly inside the Mines|r
.target Dragonmaw Foreman
.daily 11077 >>Accept Dragons are the Least of Our Problems
step
.isOnQuest 11076
#sticky
#label NethermineCargo
#loop
.waypoint Shadowmoon Valley,65.48,82.456,50,0
.waypoint Shadowmoon Valley,68.56,81.496,50,0
.waypoint Shadowmoon Valley,73.705,84.889,50,0
.waypoint Shadowmoon Valley,73.816,88.148,50,0
.waypoint Shadowmoon Valley,69.893,86.659,50,0
.waypoint Shadowmoon Valley,67.573,83.28,50,0
.waypoint Shadowmoon Valley,64.975,85.361,50,0
>>Loot the |cRXP_PICK_Nethermine Cargo|r carts
.complete 11076,1 
step
.isOnQuest 11077
#sticky
#label NethermineFlayerRavager
#loop
.waypoint Shadowmoon Valley,65.48,82.456,50,0
.waypoint Shadowmoon Valley,68.56,81.496,50,0
.waypoint Shadowmoon Valley,73.705,84.889,50,0
.waypoint Shadowmoon Valley,73.816,88.148,50,0
.waypoint Shadowmoon Valley,69.893,86.659,50,0
.waypoint Shadowmoon Valley,67.573,83.28,50,0
.waypoint Shadowmoon Valley,64.975,85.361,50,0
>>Kill |cRXP_ENEMY_Nethermine Flayers|r and |cRXP_ENEMY_Nethermine Ravagers|r
.complete 11077,1 
.mob +Nethermine Flayer
.complete 11077,2 
.mob +Nethermine Ravager
step 
.isQuestTurnedIn 11053
#completewith CrazedandConfused
>>Kill |cRXP_ENEMY_Black Bloods of Draenor|r. Loot them for their |T134570:0|t[|cRXP_LOOT_Sludge-covered Objects|r]
.use 32724 >>Open the |T134570:0|t[|cRXP_LOOT_Sludge-covered Objects|r] until you get the |T133459:0|t[|cRXP_LOOT_Murkblood Escape Plans|r]
.use 32726 >>|cRXP_WARN_Use the|r |T133459:0|t[|cRXP_LOOT_Murkblood Escape Plans|r] |cRXP_WARN_to begin the quest|r
.collect 32724,1 
.disablecheckbox
.collect 32726,1 
.disablecheckbox
.accept 11081 >> Accept The Great Murkblood Revolt
.mob Black Blood of Draenor
step 
.isQuestTurnedIn 11053
.goto Shadowmoon Valley,71.636,87.785
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ronag the Slave Driver|r
>>|cRXP_FRIENDLY_Ronag the Slave Driver|r |cRXP_WARN_is inside the Netherwing Mines|r
.target Ronag the Slave Driver
.accept 11083 >>Accept Crazed and Confused
step 
#completewith next
.goto Shadowmoon Valley,68.724,85.819,10,0
.goto Shadowmoon Valley,69.502,85.352,10,0
.goto Shadowmoon Valley,70.542,85.699,10,0
.goto Shadowmoon Valley,71.565,83.683,20,0
.goto Shadowmoon Valley,72.987,83.991,30,0
.goto Shadowmoon Valley,74.273,89.293,45 >> |cRXP_WARN_Follow the arrow closely to get to the |cRXP_ENEMY_Crazed Murkblood Foreman|r and|r |cRXP_ENEMY_Crazed Murkblood Miners|r
step 
.isOnQuest 11083
.goto Shadowmoon Valley,72.616,89.686
>>Kill the |cRXP_ENEMY_Crazed Murkblood Foreman|r and |cRXP_ENEMY_Crazed Murkblood Miners|r
.complete 11083,1 
.mob +Crazed Murkblood Foreman
.complete 11083,2 
.mob +Crazed Murkblood Miner
step 
.isQuestComplete 11083
#label CrazedandConfused
.goto Shadowmoon Valley,71.636,87.785
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ronag the Slave Driver|r
>>|cRXP_FRIENDLY_Ronag the Slave Driver|r |cRXP_WARN_is inside the Netherwing Mines|r
.target Ronag the Slave Driver
.turnin 11083 >>Turn in Crazed and Confused
step 
.isQuestTurnedIn 11053
#loop
.goto Shadowmoon Valley,69.893,86.659,50,0
.goto Shadowmoon Valley,67.573,83.28,50,0
.goto Shadowmoon Valley,64.975,85.361,50,0
>>Kill |cRXP_ENEMY_Black Bloods of Draenor|r. Loot them for their |T134570:0|t[|cRXP_LOOT_Sludge-covered Objects|r]
.use 32724 >>Open the |T134570:0|t[|cRXP_LOOT_Sludge-covered Objects|r] until you get the |T133459:0|t[|cRXP_LOOT_Murkblood Escape Plans|r]
.use 32726 >>|cRXP_WARN_Use the|r |T133459:0|t[|cRXP_LOOT_Murkblood Escape Plans|r] |cRXP_WARN_to begin the quest|r
.collect 32724,1 
.disablecheckbox
.collect 32726,1 
.disablecheckbox
.accept 11081 >> Accept The Great Murkblood Revolt
.mob Black Blood of Draenor
step
#requires NethermineCargo
step
#requires NethermineFlayerRavager
step
.isOnQuest 11077
.goto Shadowmoon Valley,65.371,89.018
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to a |cRXP_FRIENDLY_Dragonmaw Foreman|r
>>|cRXP_WARN_They patrol slightly inside the Mines|r
.target Dragonmaw Foreman
.dailyturnin 11077 >>Turn in Dragons are the Least of Our Problems
step 
.goto Shadowmoon Valley,65.436,90.131
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mistress of the Mines|r
.target Mistress of the Mines
.turnin 11081 >>Turn in The Great Murkblood Revolt
.accept 11082 >>Accept Seeker of Truth
.reputation 1015,friendly,<0,1 
step
.isOnQuest 11076
.goto Shadowmoon Valley,65.431,90.136
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mistress of the Mines|r
.target Mistress of the Mines
.dailyturnin 11076 >>Turn in Picking Up The Pieces...
step 
.isOnQuest 11082
.goto Shadowmoon Valley,68.298,79.442
>>Talk to a |cRXP_FRIENDLY_Murkblood Overseer|r inside the Mines
.complete 11082,1 
.skipgossip
.target Murkblood Overseer
step 
.isOnQuest 11082
.goto Shadowmoon Valley,65.436,90.131
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mistress of the Mines|r
.target Mistress of the Mines
.turnin 11082 >>Turn in Seeker of Truth
step 
.goto Shadowmoon Valley,66.86,86.105
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chief Overseer Mudlump|r
.target Chief Overseer Mudlump
.accept 11054 >>Accept Overseeing and You: Making the Right Choices
.reputation 1015,friendly,<0,1 
step
#completewith next
.zone Netherstorm >> Travel to Netherstorm
step
.isOnQuest 11054
#loop
.goto Netherstorm,46.6,10.8,0
.goto Netherstorm,45.0,12.6,60,0
.goto Netherstorm,46.6,10.8,60,0
.goto Netherstorm,46.6,7.2,60,0
>>Kill |cRXP_ENEMY_Tyrantus|r. Loot him for the |cRXP_LOOT_Hardened Hide of Tyrantus|r
>>|cRXP_ENEMY_Tyrantus|r |cRXP_WARN_patrols inside Eco-Dome Farfield|r
.complete 11054,2 
.mob Tyrantus
step
.isOnQuest 11054
>>Gather 10 |T134259:0|t|cRXP_LOOT_Knothide Leather|r from a Skinner or from the Auction House
.complete 11054,1 
step
#completewith next
.subzone 3759 >> Return to Netherwing Ledge in Shadowmoon Valley
step 
.goto Shadowmoon Valley,66.86,86.105
.isOnQuest 11054
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chief Overseer Mudlump|r
.target Chief Overseer Mudlump
.turnin 11054 >>Turn in Overseeing and You: Making the Right Choices
step 
.goto Shadowmoon Valley,66.86,86.105
.isQuestTurnedIn 11054
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chief Overseer Mudlump|r
.target Chief Overseer Mudlump
.daily 11055 >>Accept The Booterang: A Cure For The Common Worthless Peon
step
.isOnQuest 11055
#loop
.goto 1948,68.0,90.2,70,0
.goto 1948,75.6,89.6,70,0
.goto 1948,77.4,82.8,70,0
.goto 1948,70.0,80.6,70,0
.goto 1948,62.4,81.6,70,0
.goto 1948,64.8,90.8,70,0
.use 32680 >> |cRXP_WARN_Use the|r |T132544:0|t[Booterang] |cRXP_WARN_on|r |cRXP_ENEMY_Disobedient Dragonmaw Peons|r
>>|cRXP_WARN_You can complete this while on your flying mount|r
.complete 11055,1 
.mob Disobedient Dragonmaw Peon
step
.isOnQuest 11055
.goto Shadowmoon Valley,66.856,86.102
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Chief Overseer Mudlump|r
.target Chief Overseer Mudlump
.dailyturnin 11055 >>Turn in The Booterang: A Cure For The Common Worthless Peon
step
+|cRXP_WARN_You have completed all available daily quests for Netherwing today. Load the same guide again tomorrow once the daily quests have reset to complete more daily quests|r
>>|cRXP_WARN_You can earn more reputation by finding|r |T134430:0|t[|cRXP_FRIENDLY_Netherwing Eggs|r] |cRXP_WARN_and turning them in at |cRXP_FRIENDLY_Yarzill the Merc|r at the Dragonmaw Base Camp. These can be found randomly on Netherwing Ledge or a very low drop chance from all mobs|r
.reputation 1015,honored,>0,1 
step
.goto Shadowmoon Valley,66.12,86.353
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.accept 11084 >>Accept Stand Tall, Captain!
.reputation 1015,honored,<0,1
step
.goto Shadowmoon Valley,66.298,85.557
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.turnin 11084 >>Turn in Stand Tall, Captain!
.reputation 1015,honored,<0,1
step
.isQuestTurnedIn 11084
.goto Shadowmoon Valley,66.298,85.557
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.daily 11086 >>Accept Disrupting the Twilight Portal
step
.isQuestTurnedIn 11084
.goto Shadowmoon Valley,66.304,85.699
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Illidari Lord Balthas|r
.target Illidari Lord Balthas
.accept 11089 >>Accept The Soul Cannon of Reth'hedron
step
.isQuestTurnedIn 11084
>>|cRXP_WARN_Acquire the following items from a Miner/Engineer or the Auction House|r
>>2 x |T133231:0|t[Felsteel Bar]
>>1 x |T133004:0|t[Adamantite Frame]
>>1 x |T133018:0|t[Khorium Power Core]
.complete 11089,1 
.complete 11089,2 
.complete 11089,3 
step
.isQuestTurnedIn 11084
.goto Terokkar Forest,44.852,42.452
>>Talk to |cRXP_FRIENDLY_Sar'this|r in Terokkar Forest to summon the |cRXP_ENEMY_Flawless Arcane Elemental|r. Follow him around and kill the |cRXP_ENEMY_Elementals|r he summons
>>Kill the |cRXP_ENEMY_Flawless Arcane Elemental|r. Loot it for its |cRXP_LOOT_Flawless Arcane Essence|r
.complete 11089,4 
.mob Flawless Arcane Elemental
.target Sar'this
.skipgossip
step
.isQuestTurnedIn 11084
.goto Shadowmoon Valley,66.304,85.699
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Illidari Lord Balthas|r
.target Illidari Lord Balthas
.turnin 11089 >>Turn in The Soul Cannon of Reth'hedron
.accept 11090 >>Accept Subdue the Subduer
step
#completewith next
.zone Nagrand >> Travel to Nagrand
step
.isQuestTurnedIn 11084
.goto Nagrand,8.71,42.98
.use 32825 >> |cRXP_WARN_Channel the|r |T133863:0|t[Soul Cannon] |cRXP_WARN_on |cRXP_ENEMY_Reth'hedron the Subduer|r until his health reaches 1% and he then walks into the Portal|r
>>|cRXP_WARN_Complete this while remaining on your flying mount and staying at max range. The item can be channeled from 60 yards away. Avoid his abilities while you channel|r
.complete 11090,1 
.mob Reth'hedron the Subduer
step
.isQuestTurnedIn 11084
.goto Shadowmoon Valley,66.3,85.701
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Illidari Lord Balthas|r
.target Illidari Lord Balthas
.turnin 11090 >>Turn in Subdue the Subduer
step
.isOnQuest 11086
#loop
.goto Nagrand,12.031,39.013,70,0
.goto Nagrand,8.248,40.826,70,0
.goto Nagrand,10.158,43.381,70,0
>>Kill the |cRXP_ENEMY_Deathshadow Agents|r
.complete 11086,1 
.mob Deathshadow Acolyte
.mob Deathshadow Archon
.mob Deathshadow Overlord
.mob Deathshadow Spellbinder
.mob Deathshadow Warlock
.mob Deathshadow Agent
step
.isOnQuest 11086
.goto Shadowmoon Valley,66.296,85.557
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.dailyturnin 11086 >>Turn in Disrupting the Twilight Portal
step
.goto Shadowmoon Valley,65.893,87.18
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ja'y Nosliw|r
.target Ja'y Nosliw
.turnin 11063 >>Turn in Earning Your Wings...
.reputation 1015,honored,<0,1
step
.isQuestTurnedIn 11063
.goto Shadowmoon Valley,65.164,85.652
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Murg "Oldie" Muckjaw|r
.target Murg "Oldie" Muckjaw
.accept 11064 >>Accept Dragonmaw Race: The Ballad of Oldie McOld
step
.isQuestTurnedIn 11063
>>Follow |cRXP_FRIENDLY_Murg "Oldie" Muckjaw|r closely on your flying mount. Dodge the objects he throws at you
.complete 11064,1 
.target Murg "Oldie" Muckjaw
step
.isQuestTurnedIn 11063
.goto Shadowmoon Valley,65.893,87.18
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ja'y Nosliw|r
.target Ja'y Nosliw
.turnin 11064 >>Turn in Dragonmaw Race: The Ballad of Oldie McOld
step
.isQuestTurnedIn 11063
.goto Shadowmoon Valley,65.164,85.467
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Trope the Filth-Belcher|r
.target Trope the Filth-Belcher
.accept 11067 >>Accept Dragonmaw Race: Trope the Filth-Belcher
step
.isQuestTurnedIn 11063
>>Follow |cRXP_FRIENDLY_Trope the Filth-Belcher|r closely on your flying mount. Dodge the objects he throws at you
.complete 11067,1 
.target Trope the Filth-Belcher
step
.isQuestTurnedIn 11063
.goto Shadowmoon Valley,65.891,87.177
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ja'y Nosliw|r
.target Ja'y Nosliw
.turnin 11067 >>Turn in Dragonmaw Race: Trope the Filth-Belcher
step
.isQuestTurnedIn 11063
.goto Shadowmoon Valley,65.185,85.232
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Corlok the Vet|r
.target Corlok the Vet
.accept 11068 >>Accept Dragonmaw Race: Corlok the Vet
step
.isQuestTurnedIn 11063
>>Follow |cRXP_FRIENDLY_Corlok the Vet|r closely on your flying mount. Dodge the objects he throws at you
.complete 11068,1 
.target Corlok the Vet
step
.isQuestTurnedIn 11063
.goto Shadowmoon Valley,65.898,87.163
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ja'y Nosliw|r
.target Ja'y Nosliw
.turnin 11068 >>Turn in Dragonmaw Race: Corlok the Vet
step
.isQuestTurnedIn 11063
.goto Shadowmoon Valley,65.176,85.05
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Wing Commander Ichman|r
.target Wing Commander Ichman
.accept 11069 >>Accept Dragonmaw Race: Wing Commander Ichman
step
.isQuestTurnedIn 11063
>>Follow |cRXP_FRIENDLY_Wing Commander Ichman|r closely on your flying mount. Dodge the objects he throws at you
.complete 11069,1 
.target Wing Commander Ichman
step
.isQuestTurnedIn 11063
.goto Shadowmoon Valley,65.896,87.163
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ja'y Nosliw|r
.target Ja'y Nosliw
.turnin 11069 >>Turn in Dragonmaw Race: Wing Commander Ichman
step
.isQuestTurnedIn 11063
.goto Shadowmoon Valley,65.173,84.883
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Wing Commander Mulverick|r
.target Wing Commander Mulverick
.accept 11070 >>Accept Dragonmaw Race: Wing Commander Mulverick
step
.isQuestTurnedIn 11063
>>Follow |cRXP_FRIENDLY_Wing Commander Mulverick|r closely on your flying mount. Dodge the objects he throws at you
.complete 11070,1 
.target Wing Commander Mulverick
step
.isQuestTurnedIn 11063
.goto Shadowmoon Valley,65.895,87.177
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ja'y Nosliw|r
.target Ja'y Nosliw
.turnin 11070 >>Turn in Dragonmaw Race: Wing Commander Mulverick
step
.isQuestTurnedIn 11063
.goto Shadowmoon Valley,65.455,85.276
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Captain Skyshatter|r
.target Captain Skyshatter
.accept 11071 >>Accept Dragonmaw Race: Captain Skyshatter
step
.isQuestTurnedIn 11063
>>Follow |cRXP_FRIENDLY_Captain Skyshatter|r closely on your flying mount. Dodge the objects he throws at you
.complete 11071,1 
.target Captain Skyshatter
step
.isQuestTurnedIn 11063
.goto Shadowmoon Valley,65.893,87.185
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ja'y Nosliw|r
.target Ja'y Nosliw
.turnin 11071 >>Turn in Dragonmaw Race: Captain Skyshatter
step
+|cRXP_WARN_You have completed all available daily quests for Netherwing today. Load the same guide again tomorrow once the daily quests have reset to complete more daily quests|r
>>|cRXP_WARN_You can earn more reputation by finding|r |T134430:0|t[|cRXP_FRIENDLY_Netherwing Eggs|r] |cRXP_WARN_and turning them in at |cRXP_FRIENDLY_Yarzill the Merc|r at the Dragonmaw Base Camp. These can be found randomly on Netherwing Ledge or a very low drop chance from all mobs|r
.reputation 1015,revered,>0,1 
step
.goto Shadowmoon Valley,66.12,86.353
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.accept 11092 >>Accept Hail, Commander!
.reputation 1015,revered,<0,1
step
.isOnQuest 11092
.goto Shadowmoon Valley,66.298,85.557
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.turnin 11092 >>Turn in Hail, Commander!
step
#aldor
.isQuestTurnedIn 11092
.goto Shadowmoon Valley,66.298,85.557
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.accept 11099 >>Accept Kill Them All!
step
#scryer
.isQuestTurnedIn 11092
.goto Shadowmoon Valley,66.298,85.557
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.accept 11094 >>Accept Kill Them All!
step
#aldor
#completewith next
.subzone 3754 >> Travel to the Altar of Sha'tar
step
#scryer
#completewith next
.subzone 3938 >> Travel to the Sanctum of the Stars
step
#aldor
.isQuestTurnedIn 11092
.goto Shadowmoon Valley,62.648,28.445
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Anchorite Ceyla|r
.turnin 11099 >> Turn in Kill Them All!
.accept 11100 >> Accept Commander Arcus
.target Anchorite Ceyla
step
#scryer
.isQuestTurnedIn 11092
.goto Shadowmoon Valley,56.258,59.586
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Arcanist Thelis|r
.turnin 11094 >> Turn in Kill Them All!
.accept 11095 >> Accept Commander Hobb
.target Arcanist Thelis
step
#aldor
.isQuestTurnedIn 11092
.goto Shadowmoon Valley,62.384,29.329
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Arcus|r
.turnin 11100 >> Turn in Commander Arcus
.target Commander Arcus
step
#scryer
.isQuestTurnedIn 11092
.goto Shadowmoon Valley,56.482,58.647
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Hobb|r
.turnin 11095 >> Turn in Commander Hobb
.target Commander Hobb
step
#aldor
.isQuestTurnedIn 11092
.goto Shadowmoon Valley,62.384,29.329
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Arcus|r
.daily 11101 >> Accept The Deadliest Trap Ever Laid
.target Commander Arcus
step
#scryer
.isQuestTurnedIn 11092
.goto Shadowmoon Valley,56.482,58.647
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Hobb|r
.daily 11097 >> Accept The Deadliest Trap Ever Laid
.target Commander Hobb
step
#aldor
.isOnQuest 11101
.goto Shadowmoon Valley,64.516,31.011
>>Kill the attacking |cRXP_ENEMY_Dragonmaw Skybreakers|r
>>|cRXP_WARN_Focus on staying alive and let the friendly NPCs tank them. The quest will complete after about 2 minutes|r
.complete 11101,1 
.mob Dragonmaw Skybreaker
step
#scryer
.isOnQuest 11097
.goto Shadowmoon Valley,57.48,57.662
>>Kill the attacking |cRXP_ENEMY_Dragonmaw Skybreakers|r
>>|cRXP_WARN_Focus on staying alive and let the friendly NPCs tank them. The quest will complete after about 2 minutes|r
.complete 11097,1 
.mob Dragonmaw Skybreaker
step
#aldor
#completewith next
.subzone 3759 >> Return to Netherwing Ledge
step
#scryer
#completewith next
.subzone 3759 >> Return to Netherwing Ledge
step
#aldor
.isOnQuest 11101
.goto Shadowmoon Valley,66.298,85.557
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.dailyturnin 11101 >>Turn in The Deadliest Trap Ever Laid
step
#scryer
.isOnQuest 11097
.goto Shadowmoon Valley,66.298,85.557
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.dailyturnin 11097 >>Turn in The Deadliest Trap Ever Laid
step
+|cRXP_WARN_You have completed all available daily quests for Netherwing today. Load the same guide again tomorrow once the daily quests have reset to complete more daily quests|r
>>|cRXP_WARN_You can earn more reputation by finding|r |T134430:0|t[|cRXP_FRIENDLY_Netherwing Eggs|r] |cRXP_WARN_and turning them in at |cRXP_FRIENDLY_Yarzill the Merc|r at the Dragonmaw Base Camp. These can be found randomly on Netherwing Ledge or a very low drop chance from all mobs|r
.reputation 1015,exalted,>0,1 
step
.goto Shadowmoon Valley,66.118,86.356
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Taskmaster Varkule Dragonbreath|r
.target Taskmaster Varkule Dragonbreath
.accept 11107 >>Accept Bow to the Highlord
.reputation 1015,exalted,<0,1
step
.goto Shadowmoon Valley,66.3,85.551
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Overlord Mor'ghor|r
.target Overlord Mor'ghor
.turnin 11107 >>Turn in Bow to the Highlord
.accept 11108 >>Accept Lord Illidan Stormrage
.reputation 1015,exalted,<0,1
step
.isOnQuest 11108
.goto Shadowmoon Valley,65.898,86.263
>>|cRXP_WARN_Wait out the RP|r
.complete 11108,1 
step
.isOnQuest 11108
.zone Shattrath City >> Wait out the flight to Shattrath
step
.isOnQuest 11108
.goto Shattrath City,66.623,16.415
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Barthamus|r
.target Barthamus
.turnin 11108 >>Turn in Lord Illidan Stormrage
step
+|cRXP_WARN_You have completed all available daily quests for Netherwing today. Load the same guide again tomorrow once the daily quests have reset to complete more daily quests|r
>>|cRXP_WARN_You can earn more reputation by finding|r |T134430:0|t[|cRXP_FRIENDLY_Netherwing Eggs|r] |cRXP_WARN_and turning them in at |cRXP_FRIENDLY_Yarzill the Merc|r at the Dragonmaw Base Camp. These can be found randomly on Netherwing Ledge or a very low drop chance from all mobs|r
.reputation 1015,exalted,>0,1 
step 
.isQuestTurnedIn 11108
+|cRXP_WARN_Congratulations on finishing the Netherwing Reputation Guide. Talk to one of the |cRXP_FRIENDLY_Drakes|r once you decide which one you want as your reward. Remember you can only chosoe one!|r
.zoneskip Shattrath City,1
]]);
RXPGuides.RegisterGuide([[
#tbc
#wotlk
#group RXP TBC Reputation Guide
#name The Consortium
step
#tip
#completewith NeutralGrind
>>From Neutral to Friendly you have 2 options to gain reputation with The Consortium:
>>|cRXP_WARN_Option 1:|r Turn-ins of |T134096:0|t[Oshu'gun Crystal Fragment] OR |T133721:0|t[Pair of Ivory Tusks]. Acquire these in Nagrand or purchase them from the Auction House. Each turn in gives 250 rep. Each turn in is 10 x |T134096:0|t[Oshu'gun Crystal Fragment] OR 3 x |T133721:0|t[Pair of Ivory Tusks]
>>|cRXP_WARN_Option 2:|r Run Mana-Tombs until Friendly
step
#label NeutralGrind
.goto Nagrand,30.6,75.6,0
.goto Nagrand,34.6,64.2,0
.goto Nagrand,41.8,70.6,0
.goto Nagrand,34.8,75.8,0
.goto Nagrand,31.365,57.793,-1
.goto Nagrand,31.770,56.788,-1
.reputation 933,friendly
>>Travel to Nagrand and kill |cRXP_ENEMY_Wild Elekks|r (found all over Nagrand) for |T133721:0|t[Pair of Ivory Tusks] or kill |cRXP_ENEMY_Vir'aani Raiders|r for |T134096:0|t[Oshu'gun Crystal Fragment]. They can also be looted from the ground around Oshu'gun. You will not be able to turn either of these in after reaching Friendly
>>|cRXP_WARN_NOTE:|r It is important not to complete any other quests for The Consortium as these quests will be an easy way to gain reputation later
.accept 9914 >>Accept A Head Full of Ivory
.turnin 9914 >>Turn in A Head Full of Ivory
.accept 9882 >>Accept Stealing from Thieves
.turnin 9882 >>Turn in Stealing from Thieves
.dailyturnin 9915
.disablecheckbox
.dailyturnin 9883
.disablecheckbox
.mob Wild Elekk
.mob Vir'aani Raider
.target Gezhe
.target Shadrek
.reputation 933,friendly,>0,1
step
.goto Terokkar Forest,39.58,59.52,0
.reputation 933,honored >> Run Mana-Tombs until Honored with The Consortium
>>You can also complete the 2 quests outside of the dungeon, however you should not turn them in until you have reached Honored as Mana-Tombs stops giving rep once Honored
.accept 10216 >> Accept Safety Is Job One
.target +Artificer Morphalius
.goto Terokkar Forest,39.422,58.514
.accept 10165 >> Accept Undercutting the Competition
.target +Nexus-Prince Haramad
.goto Terokkar Forest,39.371,58.475
step
#tip
#completewith ReveredGrind
.reputation 933,revered >> Try to run Heroic Mana Tombs every day, as it is the most efficient way to gain reputation with The Consortium.
step
#completewith MTTurnins
+|cRXP_WARN_Run Mana-Tombs and complete the quests|r
step
.goto Terokkar Forest,39.58,59.52,0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Artificer Morphalius|r and |cRXP_FRIENDLY_Nexus-Prince Haramad|r
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
.isOnQuest 10218
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
#completewith NagrandQuests
.zone Nagrand >> Travel to Nagrand
step
.goto Nagrand,31.365,57.793
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gezhe|r
.target Gezhe
.accept 9893 >>Accept Obsidian Warbeads
step
#optional
.goto Nagrand,31.365,57.793
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gezhe|r
.target Gezhe
.turnin 9893 >>Turn in Obsidian Warbeads
.itemcount 25433,10
step
.goto Nagrand,30.783,58.133
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Zerid|r
.target Zerid
.accept 9900 >>Accept Gava'xi
.accept 9925 >>Accept Matters of Security
step
#completewith next
>>Kill |cRXP_ENEMY_Voidspawns|r
.complete 9925,1 
.mob Voidspawn
step
#label Gava
.goto Nagrand,42.39,73.49,50,0
.goto Nagrand,43.65,74.59,50,0
.goto Nagrand,43.47,72.86,50,0
.goto Nagrand,42.45,72.32,50,0
.goto Nagrand,41.53,71.33
>>Kill |cRXP_ENEMY_Gava'xi|r
>>|cRXP_ENEMY_Gava'xi|r |cRXP_WARN_patrols slightly|r
.complete 9900,1 
.unitscan Gava'xi
step
#loop
.line Nagrand,30.51,66.79,32.23,69.85,31.75,74.99,36.51,77.38,38.03,79.58,40.19,77.22,37.87,76.04,39.87,72.76,39.35,67.61,41.46,62.82,37.64,66.21,34.90,65.37,32.91,67.36,30.51,66.79
.goto Nagrand,30.51,66.79,60,0
.goto Nagrand,32.23,69.85,60,0
.goto Nagrand,31.75,74.99,60,0
.goto Nagrand,36.51,77.38,60,0
.goto Nagrand,38.03,79.58,60,0
.goto Nagrand,40.19,77.22,60,0
.goto Nagrand,37.87,76.04,60,0
.goto Nagrand,39.87,72.76,60,0
.goto Nagrand,39.35,67.61,60,0
.goto Nagrand,41.46,62.82,60,0
.goto Nagrand,37.64,66.21,60,0
.goto Nagrand,34.90,65.37,60,0
.goto Nagrand,32.91,67.36,60,0
>>Kill |cRXP_ENEMY_Voidspawns|r
.complete 9925,1 
.mob Voidspawn
step
#loop
.goto Nagrand,50.6,56.6,0
.goto Nagrand,40.6,31.0,0
.goto Nagrand,50.6,56.6,50,0
.goto Nagrand,40.6,31.0,50,0
>>Kill |cRXP_ENEMY_Ogres|r in Nagrand. Loot them for their |cRXP_LOOT_Obsidian Warbeads|r
.complete 9893,1 
.mob Boulderfist Warrior
.mob Boulderfist Mage
step
.goto Nagrand,30.783,58.133
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Zerid|r
.target Zerid
.turnin 9900 >>Turn in Gava'xi
.turnin 9925 >>Turn in Matters of Security
step
#label NagrandQuests
.goto Nagrand,31.365,57.793
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gezhe|r
.target Gezhe
.turnin 9893 >>Turn in Obsidian Warbeads
step
#completewith NetherstormQuests
.zone Netherstorm >> Travel to Area 52 in Netherstorm
step
.goto Netherstorm,32.442,64.206
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nether-Stalker Khay'ji|r
.accept 10265 >> Accept Consortium Crystal Collection
.target Nether-Stalker Khay'ji
step
.goto Netherstorm,42.46,72.76
>>Kill |cRXP_ENEMY_Pentatharon|r. Loot him for his |cRXP_LOOT_Arklon Crystal Artifact|r
.complete 10265,1 
.mob Pentatharon
step
.goto Netherstorm,32.442,64.206
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nether-Stalker Khay'ji|r
.turnin 10265 >> Turn in Consortium Crystal Collection
.accept 10262 >> Accept A Heap of Ethereals
.target Nether-Stalker Khay'ji
step
#loop
.line Netherstorm,28.16,76.82,28.59,77.91,28.17,79.67,29.23,80.03,29.26,78.72,30.50,79.13,30.62,75.59,31.47,76.40,31.81,75.01,30.92,73.97,30.03,74.68,29.19,75.33,28.16,76.82
.goto Netherstorm,28.16,76.82,55,0
.goto Netherstorm,28.59,77.91,55,0
.goto Netherstorm,28.17,79.67,55,0
.goto Netherstorm,29.23,80.03,55,0
.goto Netherstorm,29.26,78.72,55,0
.goto Netherstorm,30.50,79.13,55,0
.goto Netherstorm,30.62,75.59,55,0
.goto Netherstorm,31.47,76.40,55,0
.goto Netherstorm,31.81,75.01,55,0
.goto Netherstorm,30.92,73.97,55,0
.goto Netherstorm,30.03,74.68,55,0
.goto Netherstorm,29.19,75.33,55,0
>>Kill |cRXP_ENEMY_Zaxxis Raiders|r and |cRXP_ENEMY_Zaxxis Stalkers|r. Loot them for their |cRXP_LOOT_Insignias|r
.complete 10262,1 
.mob Zaxxis Raider
.mob Zaxxis Stalker
step
.goto Netherstorm,32.442,64.206
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nether-Stalker Khay'ji|r
.turnin 10262 >> Turn in A Heap of Ethereals
.accept 10205 >> Accept Warp-Raider Nesaad
.target Nether-Stalker Khay'ji
step
.goto Netherstorm,28.27,79.61
>>Kill |cRXP_ENEMY_Warp-Raider Nesaad|r
.complete 10205,1 
.mob Warp-Raider Nesaad
step
.goto Netherstorm,32.442,64.206
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nether-Stalker Khay'ji|r
.turnin 10205 >> Turn in Warp-Raider Nesaad
.accept 10266 >> Accept Request for Assistance
.target Nether-Stalker Khay'ji
step
#completewith next
.subzone 3851 >> Travel to Midrealm Post
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gahruj|r and |cRXP_FRIENDLY_Mehrdad|r
.turnin 10266 >> Turn in Request for Assistance
.accept 10267 >> Accept Rightful Repossession
.accept 10311 >> Accept Drijya Needs Your Help
.target +Gahruj
.goto Netherstorm,46.66,56.94
.accept 10348 >> Accept New Opportunities
.accept 10417 >> Accept Run a Diagnostic!
.target +Mehrdad
.goto Netherstorm,46.45,56.41
step
.goto Netherstorm,48.23,55.00
>>Loot the |cRXP_PICK_Diagnostic Equipment|r on the ground
.complete 10417,1 
step
.goto Netherstorm,46.45,56.41
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mehrdad|r
.turnin 10417 >> Turn in Run a Diagnostic!
.accept 10418 >> Accept Deal With the Saboteurs
.target Mehrdad
step
#completewith next
>>Loot the |cRXP_PICK_Ivory Bells|r on the ground
.complete 10348,1 
step
#loop
.line Netherstorm,46.94,54.53,47.57,53.95,47.62,52.83,47.02,52.66,46.75,51.68,46.05,50.41,45.29,51.93,45.91,53.50,46.94,54.53
.goto Netherstorm,46.94,54.53,50,0
.goto Netherstorm,47.57,53.95,50,0
.goto Netherstorm,47.62,52.83,50,0
.goto Netherstorm,47.02,52.66,50,0
.goto Netherstorm,46.75,51.68,50,0
.goto Netherstorm,46.05,50.41,50,0
.goto Netherstorm,45.29,51.93,50,0
.goto Netherstorm,45.91,53.50,50,0
>>Kill |cRXP_ENEMY_Barbscale Crocolisks|r
.complete 10418,1 
.mob Barbscale Crocolisk
step
#loop
.line Netherstorm,46.50,49.46,45.71,48.52,44.49,48.48,44.44,49.73,42.99,50.75,42.60,53.37,43.30,54.76,43.19,55.94,44.24,57.16,44.67,54.74,45.91,57.22,46.50,49.46
.goto Netherstorm,46.50,49.46,50,0
.goto Netherstorm,45.71,48.52,50,0
.goto Netherstorm,44.49,48.48,50,0
.goto Netherstorm,44.44,49.73,50,0
.goto Netherstorm,42.99,50.75,50,0
.goto Netherstorm,42.60,53.37,50,0
.goto Netherstorm,43.30,54.76,50,0
.goto Netherstorm,43.19,55.94,50,0
.goto Netherstorm,44.24,57.16,50,0
.goto Netherstorm,44.67,54.74,50,0
.goto Netherstorm,45.91,57.22,50,0
>>Loot the |cRXP_PICK_Ivory Bells|r on the ground
.complete 10348,1 
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Mehrdad|r
.goto Netherstorm,46.48,56.04
.turnin 10348 >> Turn in New Opportunities
.turnin 10418 >> Turn in Deal With the Saboteurs
.accept 10423 >> Accept To the Stormspire
.goto Netherstorm,46.45,56.41
.target Mehrdad
step
#completewith next
+|cRXP_WARN_Find another 1-2 party members for the upcoming escort quest|r
step
.goto Netherstorm,48.11,63.50
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Drijya|r
>>|cRXP_WARN_You may need to wait for |cRXP_FRIENDLY_Drijya|r to return if he is not there|r
.turnin 10311 >> Turn in Drijya Needs Your Help
.accept 10310,1 >> Accept Sabotage the Warp-Gate!
.target Drijya
step
.goto Netherstorm,49.47,65.72
>>Kill the attacking |cRXP_ENEMY_Demons|r while |cRXP_FRIENDLY_Drijya|r sabotages the warp-gate
.complete 10310,1 
.target Drijya
.mob Warp-Gate Engineer
.mob Legion Destroyer
step
#loop
.line Netherstorm,58.84,62.54,58.31,62.97,58.10,62.71,57.76,63.29,57.21,63.42,56.82,63.89,57.34,64.44,57.39,65.29,57.22,65.92,56.95,66.52,57.34,67.19,57.38,66.58,57.22,65.92,57.39,65.29,57.34,64.44,57.91,64.06,57.76,63.29,58.10,62.71,58.31,62.97,58.84,62.54,59.10,63.14,59.45,63.04,59.20,62.36,58.84,62.54
.goto Netherstorm,58.84,62.54,50,0
.goto Netherstorm,58.31,62.97,50,0
.goto Netherstorm,58.10,62.71,50,0
.goto Netherstorm,57.76,63.29,50,0
.goto Netherstorm,57.21,63.42,50,0
.goto Netherstorm,56.82,63.89,50,0
.goto Netherstorm,57.34,64.44,50,0
.goto Netherstorm,57.39,65.29,50,0
.goto Netherstorm,57.22,65.92,50,0
.goto Netherstorm,56.95,66.52,50,0
.goto Netherstorm,57.34,67.19,50,0
.goto Netherstorm,57.38,66.58,50,0
.goto Netherstorm,57.22,65.92,50,0
.goto Netherstorm,57.39,65.29,50,0
.goto Netherstorm,57.34,64.44,50,0
.goto Netherstorm,57.91,64.06,50,0
.goto Netherstorm,57.76,63.29,50,0
.goto Netherstorm,58.10,62.71,50,0
.goto Netherstorm,58.31,62.97,50,0
.goto Netherstorm,58.84,62.54,50,0
.goto Netherstorm,59.10,63.14,50,0
.goto Netherstorm,59.45,63.04,50,0
.goto Netherstorm,59.20,62.36,50,0
>>Loot the |cRXP_PICK_Surveying Equipment|r boxes on the ground
.complete 10267,1 
step
.goto Netherstorm,46.66,56.94
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Gahruj|r
.turnin 10310 >> Turn in Sabotage the Warp-Gate!
.turnin 10267 >> Turn in Rightful Repossession
.accept 10268 >> Accept An Audience with the Prince
.target Gahruj
step
#completewith next
.subzone 3738 >> Travel to the Stormspire
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ghabar|r
.turnin 10423 >> Turn in To the Stormspire
.accept 10424 >> Accept Diagnosis: Critical
.goto Netherstorm,43.54,35.15
.target Ghabar
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Zuben Elgenubi|r
.accept 10290 >> Accept In Search of Farahlite
.goto Netherstorm,44.08,36.05
.target Zuben Elgenubi
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nether-Stalker Nauthis|r and |cRXP_FRIENDLY_Zephyrion|r
.accept 10336 >> Accept The Minions of Culuthas
.accept 10855 >> Accept Fel Reavers, No Thanks!
.target +Nether-Stalker Nauthis
.goto Netherstorm,44.71,34.94,-1
.accept 10335 >> Accept Surveying the Ruins
.target +Zephyrion
.goto Netherstorm,44.73,34.87,-1
step
.goto Netherstorm,45.87,35.97
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Image of Nexus-Prince Haramad|r
.turnin 10268 >> Turn in An Audience with the Prince
.accept 10269 >> Accept Triangulation Point One
.target Image of Nexus-Prince Haramad
step
.goto Netherstorm,47.64,26.77
.use 29803 >>|cRXP_WARN_Use the|r |T133859:0|t[Diagnostic Device] |cRXP_WARN_at the|r |cRXP_PICK_Eco-Dome Sutheron Generator|r
.complete 10424,1 
step
#loop
.line Netherstorm,39.11,28.77,38.01,30.41,36.22,30.11,35.54,28.97,35.83,28.22,37.14,27.86,36.23,26.00,36.73,24.74,38.68,25.07,38.12,27.81,39.57,27.48,39.11,28.77
.goto Netherstorm,39.11,28.77,50,0
.goto Netherstorm,38.01,30.41,50,0
.goto Netherstorm,36.22,30.11,50,0
.goto Netherstorm,35.54,28.97,50,0
.goto Netherstorm,35.83,28.22,50,0
.goto Netherstorm,37.14,27.86,50,0
.goto Netherstorm,36.23,26.00,50,0
.goto Netherstorm,36.73,24.74,50,0
.goto Netherstorm,38.68,25.07,50,0
.goto Netherstorm,38.12,27.81,50,0
.goto Netherstorm,39.57,27.48,50,0
>>Kill |cRXP_ENEMY_Gan'arg Mekgineers|r. Loot them for their |cRXP_LOOT_Condensed Nether Gas|r
.collect 31653,5,10855,1 
.mob Gan'arg Mekgineer
step
.goto Netherstorm,35.86,28.84,-1
.goto Netherstorm,36.73,25.15,-1
.goto Netherstorm,37.95,25.69,-1
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to an |cRXP_FRIENDLY_Inactive Fel Reaver|r
.turnin 10850 >> Turn in Nether Gas In a Fel Fire Engine
.isOnQuest 10855
.target Inactive Fel Reaver
.itemcount 31653,5
step
#loop
.line Netherstorm,47.57,20.27,44.88,18.75,45.10,16.70,50.08,17.24,47.57,20.27
.goto Netherstorm,47.57,20.27,50,0
.goto Netherstorm,44.88,18.75,50,0
.goto Netherstorm,45.10,16.70,50,0
.goto Netherstorm,50.08,17.24,50,0
>>Kill |cRXP_ENEMY_Farahlon Breakers|r. Loot them for their |cRXP_LOOT_Raw Farahlite|r
>>|cRXP_WARN_This quest is difficult. Find a group for them if needed|r
.complete 10290,1 
.mob Farahlon Breaker
step
#completewith next
.subzone 3738 >> Return to the Stormspire
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nether-Stalker Nauthis|r and |cRXP_FRIENDLY_Ghabar|r
.turnin 10855 >> Turn in Fel Reavers, No Thanks!
.accept 10856 >> Accept The Best Defense
.target +Nether-Stalker Nauthis
.goto Netherstorm,44.71,34.94
.turnin 10424 >> Turn in Diagnosis: Critical
.accept 10430 >> Accept Testing the Prototype
.goto Netherstorm,43.54,35.15
.target +Ghabar
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Zuben Elgenubi|r
.turnin 10290 >> Turn in In Search of Farahlite
.accept 10293 >> Accept Hitting the Motherlode
.target +Zuben Elgenubi
.goto Netherstorm,44.08,36.05
step
#loop
.line Netherstorm,39.72,25.01,38.33,20.39,37.91,18.04,39.17,18.25,39.86,17.13,41.32,17.73,42.35,18.87,40.86,21.45,42.71,20.12,43.35,21.69,42.30,23.87,40.86,23.90,39.72,25.01
.goto Netherstorm,39.72,25.01,70,0
.goto Netherstorm,38.33,20.39,70,0
.goto Netherstorm,37.91,18.04,70,0
.goto Netherstorm,39.17,18.25,70,0
.goto Netherstorm,39.86,17.13,70,0
.goto Netherstorm,41.32,17.73,70,0
.goto Netherstorm,42.35,18.87,70,0
.goto Netherstorm,40.86,21.45,70,0
.goto Netherstorm,42.71,20.12,70,0
.goto Netherstorm,43.35,21.69,70,0
.goto Netherstorm,42.30,23.87,70,0
.goto Netherstorm,40.86,23.90,70,0
>>Kill |cRXP_ENEMY_Wrathbringers|r
.complete 10856,1 
.mob Wrathbringer
step
#completewith next
.subzone 3874 >>Travel to Eco-Dome Farfield
step
.goto Netherstorm,44.69,14.58
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tashar|r
.turnin 10430 >> Turn in Testing the Prototype
.accept 10436 >> Accept All Clear!
.target Tashar
step
#loop
.line Netherstorm,43.16,13.33,43.68,11.53,44.90,10.74,45.01,8.01,46.51,7.78,47.05,10.12,46.35,12.99,45.28,12.71
.goto Netherstorm,43.16,13.33,65,0
.goto Netherstorm,43.68,11.53,65,0
.goto Netherstorm,44.90,10.74,65,0
.goto Netherstorm,45.01,8.01,65,0
.goto Netherstorm,46.51,7.78,65,0
.goto Netherstorm,47.05,10.12,65,0
.goto Netherstorm,46.35,12.99,65,0
.goto Netherstorm,45.28,12.71,65,0
>>Kill |cRXP_ENEMY_Scythetooth Raptors|r
.complete 10436,1 
.mob Scythetooth Raptor
step
.goto Netherstorm,44.69,14.58
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Tashar|r. Wait for his RP
.turnin 10436 >> Turn in All Clear!
.accept 10440 >> Accept Success!
.target Tashar
step
.goto Netherstorm,47.54,21.09,60,0
.goto Netherstorm,47.59,20.49,60,0
.goto Netherstorm,47.82,19.69,60,0
.goto Netherstorm,48.66,19.33,60,0
.goto Netherstorm,48.98,18.74,60,0
.goto Netherstorm,49.46,18.15,60,0
.goto Netherstorm,49.82,17.23
.line Netherstorm,47.54,21.09,47.59,20.49,47.82,19.69,48.66,19.33,48.98,18.74,49.46,18.15,49.82,17.23
>>Kill |cRXP_ENEMY_Cragskaar|r. Loot him for his |cRXP_LOOT_Core|r
>>|cRXP_WARN_This quest is difficult. Find a group for him if needed|r
.complete 10293,1 
.isOnQuest 10293
.mob Cragskaar
step
.goto Netherstorm,66.73,33.89
.use 28962 >> |cRXP_WARN_Use the|r |T135164:0|t[Triangulation Device]
>>|cRXP_WARN_Walk 10 yards away then walk into the red arrow|r
.complete 10269,1 
step
.goto Netherstorm,58.35,31.26
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Dealer Hazzin|r
.turnin 10269 >> Turn in Triangulation Point One
.accept 10275 >> Accept Triangulation Point Two
.target Dealer Hazzin
step
#completewith next
.subzone 3738 >> Return to the Stormspire
tep
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Zuben Elgenubi|r
.turnin 10293 >> Turn in Hitting the Motherlode
.goto Netherstorm,44.08,36.05
.isQuestComplete 10293
.target Zuben Elgenubi
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Ghabar|r and |cRXP_FRIENDLY_Nether-Stalker Nauthis|r
.turnin 10440 >> Turn in Success!
.target +Ghabar
.goto Netherstorm,43.54,35.15
.turnin 10856 >> Turn in The Best Defense
.accept 10857 >> Accept Teleport This!
.target +Nether-Stalker Nauthis
.goto Netherstorm,44.71,34.94
step
#completewith next
.subzone 3852 >> Travel to Tuluman's Landing
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Wind Trader Tuluman|r and |cRXP_FRIENDLY_Nether-Stalker Oazul|r
.accept 10317 >> Accept Dealing with the Foreman
.target +Wind Trader Tuluman
.goto Netherstorm,34.62,37.95
.accept 10315 >> Accept Neutralizing the Nethermancers
.goto Netherstorm,34.50,37.80
.target +Nether-Stalker Oazul
step
#completewith next
.goto Netherstorm,26.37,43.87
.subzone 3881 >> Enter the Trelleum Mine
step
.goto Netherstorm,26.37,42.27
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Foreman Sundown|r inside the mine
.turnin 10317 >> Turn in Dealing with the Foreman
.accept 10318 >> Accept Dealing with the Overmaster
.target Foreman Sundown
step
#completewith Point2
>>Kill |cRXP_ENEMY_Sunfury Nethermancers|r
.complete 10315,1 
.mob Sunfury Nethermancer
step
.goto Netherstorm,26.82,35.84
>>Kill |cRXP_ENEMY_Overmaster Grindgarr|r at the end of the mine
.complete 10318,1 
.mob Overmaster Grindgarr
step
#completewith next
.skill riding,225,1
.goto Netherstorm,29.56,41.80,50,0
.goto Netherstorm,29.42,39.76,50 >> Travel up the mountain to Manaforge Ara
step
#label Point2
.goto Netherstorm,28.74,41.29
.use 29018 >> |cRXP_WARN_Use the|r |T135164:0|t[Triangulation Device]
>>|cRXP_WARN_Walk 10 yards away then walk into the red arrow|r
.complete 10275,1 
step
#loop
.line Netherstorm,28.43,41.71,28.33,40.23,28.57,37.74,30.85,39.73,29.61,44.04,28.43,41.71
.goto Netherstorm,28.43,41.71,45,0
.goto Netherstorm,28.33,40.23,45,0
.goto Netherstorm,28.57,37.74,45,0
.goto Netherstorm,30.85,39.73,45,0
.goto Netherstorm,29.61,44.04,45,0
>>Kill |cRXP_ENEMY_Sunfury Nethermancers|r
.complete 10315,1 
.mob Sunfury Nethermancer
step
#completewith next
.subzone 3852 >> Return to Tuluman's Landing
step
#aldor
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nether-Stalker Oazul|r and |cRXP_FRIENDLY_Wind Trader Tuluman|r
.turnin 10315 >> Turn in Neutralizing the Nethermancers
.target +Nether-Stalker Oazul
.goto Netherstorm,34.50,37.80
.turnin 10275 >> Turn in Triangulation Point Two
.accept 10276 >> Accept Full Triangle
.turnin 10318 >> Turn in Dealing with the Overmaster
.target +Wind Trader Tuluman
.goto Netherstorm,34.62,37.95
step
#completewith next
.goto Netherstorm,39.36,20.83
.cast 38915 >> |cRXP_WARN_Use the|r |T135147:0|t[Mental Interference Rod] |cRXP_WARN_on a|r |cRXP_ENEMY_Cyber-Rage Forgelord|r
.use 31678
.mob Cyber-Rage Forgelord
step
.goto Netherstorm,39.19,20.43
>>|cRXP_WARN_With a|r |cRXP_ENEMY_Forgelord|r |cRXP_WARN_mind controlled, cast|r |T136193:0|t[Detonate Teleporter] (3) |cRXP_WARN_to destroy the|r |cRXP_PICK_Western Teleporter|r
.complete 10857,1 
.use 31678
.mob Cyber-Rage Forgelord
step
#completewith next
.goto Netherstorm,40.93,18.71
.cast 38915 >> |cRXP_WARN_Use the|r |T135147:0|t[Mental Interference Rod] |cRXP_WARN_on a|r |cRXP_ENEMY_Cyber-Rage Forgelord|r
.use 31678
.mob Cyber-Rage Forgelord
step
.goto Netherstorm,41.08,19.42
>>|cRXP_WARN_With a|r |cRXP_ENEMY_Forgelord|r |cRXP_WARN_mind controlled, cast|r |T136193:0|t[Detonate Teleporter] (3) |cRXP_WARN_to destroy the|r |cRXP_PICK_Central Teleporter|r
.complete 10857,2 
.mob Cyber-Rage Forgelord
step
#completewith next
.goto Netherstorm,41.82,21.10
.cast 38915 >> |cRXP_WARN_Use the|r |T135147:0|t[Mental Interference Rod] |cRXP_WARN_on a|r |cRXP_ENEMY_Cyber-Rage Forgelord|r
.use 31678
.mob Cyber-Rage Forgelord
step
.goto Netherstorm,42.28,21.07
>>|cRXP_WARN_With a|r |cRXP_ENEMY_Forgelord|r |cRXP_WARN_mind controlled, cast|r |T136193:0|t[Detonate Teleporter] (3) |cRXP_WARN_to destroy the|r |cRXP_PICK_Eastern Teleporter|r
.complete 10857,3 
.mob Cyber-Rage Forgelord
step
#completewith Surveying
.goto Netherstorm,54.5,22.0,0
>>Kill the |cRXP_ENEMY_Hounds of Culuthas|r and |cRXP_ENEMY_Eyes of Culuthas|r
.complete 10336,1 
.mob +Hound of Culuthas
.complete 10336,2 
.mob +Eye of Culuthas
step
.goto Netherstorm,51.65,20.49
.use 29445 >>|cRXP_WARN_Use the|r |T135482:0|t[Surveying Markers] |cRXP_WARN_next to the banner|r
.complete 10335,1 
step
.goto Netherstorm,53.50,21.53
>>Kill |cRXP_ENEMY_Culuthas|r. Loot him for his |cRXP_LOOT_Crystal|r
>>|cRXP_WARN_This quest is difficult. Find a group for him if needed|r
.complete 10276,1 
.mob Culuthas
step
#label Surveying
.use 29445 >>|cRXP_WARN_Use the|r |T135482:0|t[Surveying Markers] |cRXP_WARN_next to the banners|r
.complete 10335,2 
.goto Netherstorm,54.54,22.82
.complete 10335,3 
.goto Netherstorm,55.82,19.92
step
#loop
.line Netherstorm,56.15,19.69,55.29,21.86,54.32,22.98,54.95,24.74,52.68,23.78,51.27,21.26,52.13,20.00,53.54,19.55,54.18,19.34,56.15,19.69
.goto Netherstorm,56.15,19.69,50,0
.goto Netherstorm,55.29,21.86,50,0
.goto Netherstorm,54.32,22.98,50,0
.goto Netherstorm,54.95,24.74,50,0
.goto Netherstorm,52.68,23.78,50,0
.goto Netherstorm,51.27,21.26,50,0
.goto Netherstorm,52.13,20.00,50,0
.goto Netherstorm,53.54,19.55,50,0
.goto Netherstorm,54.18,19.34,50,0
>>Kill the |cRXP_ENEMY_Hounds|r and |cRXP_ENEMY_Eyes of Culuthas|r
.complete 10336,1 
.mob +Hound of Culuthas
.complete 10336,2 
.mob +Eye of Culuthas
step
#completewith next
.subzone 3738 >> Return to the Stormspire
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Nether-Stalker Nauthis|r and |cRXP_FRIENDLY_Zephyrion|r
.turnin 10336 >> Turn in The Minions of Culuthas
.turnin 10857 >> Turn in Teleport This!
.target +Nether-Stalker Nauthis
.goto Netherstorm,44.71,34.94
.turnin 10335 >> Turn in Surveying the Ruins
.target +Zephyrion
.goto Netherstorm,44.73,34.87
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Image of Nexus-Prince Haramad|r
.turnin 10276 >> Turn in Full Triangle
.accept 10280 >> Accept Special Delivery to Shattrath City
.goto Netherstorm,45.87,35.97
.target Image of Nexus-Prince Haramad
step
#completewith next
.subzone 3854 >> Travel to the Protectorate Watch Post
step
#sticky
#label CaptainTyralius
#loop
.waypoint Netherstorm,58.60,31.77,40,0
.waypoint Netherstorm,58.91,32.02,40,0
.waypoint Netherstorm,59.14,32.12,40,0
.waypoint Netherstorm,59.47,31.88,40,0
.waypoint Netherstorm,59.86,31.91,40,0
.waypoint Netherstorm,60.07,32.52,40,0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Flesh Handler Viridius|r
>>|cRXP_FRIENDLY_Flesh Handler Viridius|r |cRXP_WARN_patrols the Protectorate Watch Post|r
.accept 10422 >> Accept Captain Tyralius
.target Flesh Handler Viridius
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Wind Trader Marid|r, |cRXP_FRIENDLY_Researcher Navuud|r and |cRXP_FRIENDLY_Professor Dabiri|r
.accept 10270 >> Accept A Not-So-Modest Proposal
.target +Researcher Navuud
.goto Netherstorm,58.32,31.66
.accept 10411 >> Accept Electro-Shock Goodness!
.target +Wind Trader Marid
.goto Netherstorm,59.25,32.58
.accept 10437 >> Accept Recipe for Destruction
.goto Netherstorm,60.11,31.72
.target +Professor Dabiri
step
.goto Netherstorm,59.5,32.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Ameer|r
.accept 10339 >> Accept The Ethereum
.accept 10970 >> Accept A Mission of Mercy
>>|cRXP_WARN_This quest chain can only be done at level 70|r << !70
.target Commander Ameer
step
#requires CaptainTyralius
.isOnQuest 10411
.cast 35685 >> |cRXP_WARN_Use|r |T134716:0|t[Navuud's Concoction]
.use 29737
.aura 35685
step
#loop
.line Netherstorm,64.26,35.80,65.80,39.03,66.04,41.34,63.72,42.87,62.89,44.65,61.15,43.65,59.42,41.53,59.74,39.06,64.26,35.80
.goto Netherstorm,64.26,35.80,50,0
.goto Netherstorm,65.80,39.03,50,0
.goto Netherstorm,66.04,41.34,50,0
.goto Netherstorm,63.72,42.87,50,0
.goto Netherstorm,62.89,44.65,50,0
.goto Netherstorm,61.15,43.65,50,0
.goto Netherstorm,59.42,41.53,50,0
.goto Netherstorm,59.74,39.06,50,0
>>Kill |cRXP_ENEMY_Voidshriekers|r and |cRXP_ENEMY_Unstable Voidwraiths|r. Loot them for their |cRXP_LOOT_Fragments of Dimensius|r
>>|cRXP_WARN_Be careful as |cRXP_ENEMY_Voidshriekers|r take reduced damage from the first spell school cast on them|r << !Warrior !Rogue
.use 29737 >>Attack |cRXP_ENEMY_Seeping Sludges|r, then kill the |cRXP_ENEMY_Seeping Sludge Globules|r that spawn
.complete 10437,1 
.mob +Voidshrieker
.mob +Unstable Voidwraith
.complete 10411,1 
.mob +Seeping Sludge
.mob +Seeping Sludge Globule
step
.goto Netherstorm,59.42,45.03
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Agent Araxes|r
.accept 10345 >> Accept The Flesh Lies...
.target Agent Araxes
step
#completewith next
.goto Netherstorm,61.075,45.290,15 >> Enter the Access Shaft Zeon mine
>>|cRXP_WARN_Stay to the left as you enter the mine|r
step
#completewith Arconus
.use 29473 >>|cRXP_WARN_Use the|r |T135626:0|t[Protectorate Igniter] |cRXP_WARN_on |cRXP_ENEMY_Withered Corpses|r inside the mine|r
.complete 10345,1 
.mob Withered Corpse
step
.goto Netherstorm,61.02,44.52,15,0
.goto Netherstorm,60.52,43.54,15,0
.goto Netherstorm,60.02,43.35,15,0
.goto Netherstorm,59.71,42.63,15,0
>>|cRXP_WARN_Hug the left wall of the cave|r
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Agent Ya-six|r
.accept 10353 >> Accept Arconus the Insatiable
.goto Netherstorm,60.92,41.53
step
>>Loot the |cRXP_PICK_Teleporter Power Pack|r behind |cRXP_FRIENDLY_Agent Ya-six|r
.complete 10270,1 
.goto Netherstorm,60.98,41.52
.target Agent Ya-six
step
#label Arconus
.goto Netherstorm,59.71,42.63,15,0
.goto Netherstorm,60.11,43.50,15,0
.goto Netherstorm,60.48,42.90,15,0
.goto Netherstorm,60.74,41.36,15,0
.goto Netherstorm,60.03,40.56,15,0
.goto Netherstorm,60.20,39.91
>>|cRXP_WARN_Head back the way you came. Follow the arrow to|r |cRXP_ENEMY_Arconus the Insatiable|r
>>Kill |cRXP_ENEMY_Arconus the Insatiable|r
.complete 10353,1 
.mob Arconus the Insatiable
step
#loop
.goto Netherstorm,60.03,40.56,15,0
.goto Netherstorm,60.74,41.36,15,0
.goto Netherstorm,61.77,41.96,15,0
.goto Netherstorm,61.75,43.39,15,0
.goto Netherstorm,61.12,44.45,15,0
.goto Netherstorm,61.03,46.23,15,0
.use 29473 >>|cRXP_WARN_Use the|r |T135626:0|t[Protectorate Igniter] |cRXP_WARN_in your bags to burn |cRXP_ENEMY_Withered Corpses|r in the mine|r
.complete 10345,1 
.mob Withered Corpse
step
#completewith next
.goto Netherstorm,61.03,46.23,20 >> Exit the Access Shaft Zeon mine
step
.goto Netherstorm,59.42,45.03
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Agent Araxes|r
.turnin 10345 >> Turn in The Flesh Lies...
.target Agent Araxes
step
#sticky
#label SalvagedKey
.isOnQuest 10970
.goto Netherstorm,59.5,32.4,0
>>|cRXP_WARN_Keep a lookout while looting the |cRXP_ENEMY_Ethereum|r for a |T134889:0|t[|cRXP_LOOT_Salvaged Ethereum Prison Key|r]. If you loot one, turn it in at |cRXP_FRIENDLY_Commander Ameer|r at the Protectorate Watch Post immediately|r
.complete 10970,1 
.turnin 10970 >> Turn in A Mission of Mercy
.accept 10971 >> Accept Ethereum Secrets
step
#optional
#completewith next
.isOnQuest 10411
.cast 35685 >> |cRXP_WARN_Use|r |T134716:0|t[Navuud's Concoction]
.use 29737
.aura 35685
step
#completewith Tyralius
.use 29737 >>Attack |cRXP_ENEMY_Void Wastes|r, then kill the |cRXP_ENEMY_Void Waste Globules|r that spawn
.complete 10411,2 
.mob Void Waste
.mob Void Waste Globule
step
.goto Netherstorm,54.36,41.23
>>Kill |cRXP_ENEMY_Warden Icoshock|r. Loot him for |cRXP_LOOT_The Warden's Key|r
.collect 29742,1,10422,1 
.mob Warden Icoshock
step
#label Tyralius
.goto Netherstorm,53.30,41.43
>>Click |cRXP_PICK_Captain Tyralius's Prison|r
.complete 10422,1 
step
.line Netherstorm,55.61,45.18,54.87,43.96,55.24,42.73,54.70,41.97,54.91,41.19
.goto Netherstorm,55.61,45.18,50,0
.goto Netherstorm,54.87,43.96,50,0
.goto Netherstorm,55.24,42.73,50,0
.goto Netherstorm,54.70,41.97,50,0
.goto Netherstorm,54.91,41.19
.use 29737 >>Attack |cRXP_ENEMY_Void Wastes|r, then kill the |cRXP_ENEMY_Void Waste Globules|r that spawn
.complete 10411,2 
.mob Void Waste
.mob Void Waste Globule
step
#optional
.aura -35685 >> |cRXP_WARN_Click off the|r |T135990:0|t[Electro-Shock Therapy] |cRXP_WARN_buff on you|r
step
>>Kill |cRXP_ENEMY_Captain Zovax|r, |cRXP_ENEMY_Ethereum Assassins|r, |cRXP_ENEMY_Ethereum Shocktroopers|r and |cRXP_ENEMY_Ethereum Researchers|r
.complete 10339,4 
.goto Netherstorm,57.0,37.6
.mob +Captain Zovax
.complete 10339,1 
.goto Netherstorm,57.0,37.6,50,0
.goto Netherstorm,55.2,41.6,50,0
.goto Netherstorm,57.0,37.6,50,0
.goto Netherstorm,55.2,41.6
.mob +Ethereum Assassin
.complete 10339,2 
.goto Netherstorm,57.0,37.6,50,0
.goto Netherstorm,55.2,41.6,50,0
.goto Netherstorm,57.0,37.6,50,0
.goto Netherstorm,55.2,41.6
.mob +Ethereum Shocktrooper
.complete 10339,3 
.goto Netherstorm,57.0,37.6,50,0
.goto Netherstorm,55.2,41.6,50,0
.goto Netherstorm,57.0,37.6,50,0
.goto Netherstorm,55.2,41.6
.mob +Ethereum Researcher
step
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Image of Commander Ameer|r
.goto Netherstorm,56.810,38.700
.turnin 10339 >> Turn in The Ethereum
.accept 10384 >> Accept Ethereum Data
.target Image of Commander Ameer
step
.goto Netherstorm,55.767,39.895
>>Loot the |cRXP_PICK_Ethereum Data Cell|r
.complete 10384,1 
step
.goto Netherstorm,56.810,38.700
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Image of Commander Ameer|r
.turnin 10384 >> Turn in Ethereum Data
.accept 10385 >> Accept Potential for Brain Damage = High
.target Image of Commander Ameer
step
>>Kill the |cRXP_ENEMY_Ethereum|r. Loot them for their |T134729:0|t[|cRXP_LOOT_Ethereum Essence|r]
.use 29482 >> |cRXP_WARN_Use the|r |T134729:0|t[|cRXP_LOOT_Ethereum Essence|r] |cRXP_WARN_to be able to see and kill |cRXP_ENEMY_Ethereum Relays|r (they look like |cRXP_ENEMY_Mana Wyrms|r). Loot them for their|r |cRXP_LOOT_Ethereum Relay Data|r
>>|cRXP_WARN_NOTE: The|r |T134729:0|t[|cRXP_LOOT_Ethereum Essence|r] |cRXP_WARN_buff only lasts for only 1 minute|r
.collect 29482,1
.disablecheckbox
.complete 10385,1 
.mob Ethereum Relay
step
.goto Netherstorm,56.810,38.700
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Image of Commander Ameer|r
.turnin 10385 >> Turn in Potential for Brain Damage = High
.accept 10405 >> Accept S-A-B-O-T-A-G-E
.target Image of Commander Ameer
step
#loop
.goto Netherstorm,56.6,40.6,50,0
.goto Netherstorm,56.0,45.6,50,0
.goto Netherstorm,56.0,42.8,0
>>Kill |cRXP_ENEMY_Ethereum Archons|r and |cRXP_ENEMY_Ethereum Overlords|r. Loot them for a |cRXP_LOOT_Prepared Ethereum Wrapping|r
.complete 10405,1 
.mob Ethereum Archon
.mob Ethereum Overlord
step
.goto Netherstorm,56.810,38.700
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Image of Commander Ameer|r
.turnin 10405 >> Turn in S-A-B-O-T-A-G-E
.accept 10406 >> Accept Delivering the Message
.target Image of Commander Ameer
step
.goto Netherstorm,56.24,42.90
>>Escort the |cRXP_FRIENDLY_Protectorate Demolitionist|r through the Staging Grounds
.complete 10406,1 
.target Protectorate Demolitionist
step
.goto Netherstorm,56.810,38.700
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Image of Commander Ameer|r
.turnin 10406 >> Turn in Delivering the Message
.accept 10408 >> Accept Nexus-King Salhadaar
.target Image of Commander Ameer
step
.goto Netherstorm,53.59,42.37
.use 29618 >>Kill the |cRXP_ENEMY_Ethereum|r at the pillars around |cRXP_ENEMY_Nexus-King Salhadaar|r and use the |T133002:0|t[Protectorate Disruptor] to release him
>>Kill |cRXP_ENEMY_Nexus-King Salhadaar|r
>>|cRXP_WARN_Having a 5 man group with Tank + Healer is recommended for this step|r
.complete 10408,1 
.mob Nexus-King Salhadaar
step
.goto Netherstorm,56.810,38.700
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to the |cRXP_FRIENDLY_Image of Commander Ameer|r
.turnin 10408 >> Turn in Nexus-King Salhadaar
.target Image of Commander Ameer
step
#requires SalvagedKey
step
#sticky
#label CaptainTyraliusTurnin
#loop
.waypoint Netherstorm,58.60,31.77,40,0
.waypoint Netherstorm,58.91,32.02,40,0
.waypoint Netherstorm,59.14,32.12,40,0
.waypoint Netherstorm,59.47,31.88,40,0
.waypoint Netherstorm,59.86,31.91,40,0
.waypoint Netherstorm,60.07,32.52,40,0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Flesh Handler Viridius|r
>>|cRXP_FRIENDLY_Flesh Handler Viridius|r |cRXP_WARN_patrols the Protectorate Watch Post|r
.turnin 10422 >> Turn in Captain Tyralius
.target Flesh Handler Viridius
step
#label Protectorate2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Researcher Navuud|r, |cRXP_FRIENDLY_Professor Dabiri|r and |cRXP_FRIENDLY_Commander Ameer|r
.turnin 10411 >> Turn in Electro-Shock Goodness!
.target +Researcher Navuud
.goto Netherstorm,59.25,32.58,-1
.turnin 10437 >> Turn in Recipe for Destruction
.accept 10438 >> Accept On Nethery Wings
.goto Netherstorm,60.11,31.72,-1
.target +Professor Dabiri
.turnin 10353 >> Turn in Arconus the Insatiable
.goto Netherstorm,59.51,32.39,-1
.target +Commander Ameer
step
#requires CaptainTyraliusTurnin
.isOnQuest 10438
.goto Netherstorm,60.21,31.76
.gossip 20903,0 >> Talk to the |cRXP_FRIENDLY_Protectorate Nether Drake|r
.skipgossip
.target Protectorate Nether Drake
step
.goto Netherstorm,62.42,40.88
.use 29778 >>|cRXP_WARN_Once you reach the top of the Manaforge, use the|r |T133018:0|t[Phase Disruptor] |cRXP_WARN_repeatedly|r
.complete 10438,1 
step
.goto Netherstorm,60.11,31.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Professor Dabiri|r
.turnin 10438 >> Turn in On Nethery Wings
.accept 10439 >> Accept Dimensius the All-Devouring
.target Professor Dabiri
step
.goto Netherstorm,60.63,32.08,10,0
.goto Netherstorm,62.41,40.89
>>Talk to |cRXP_FRIENDLY_Captain Saeed|r at the Protectorate Watchpost to begin the attack on |cRXP_ENEMY_Dimensius the All-Devouring|r
>>Kill |cRXP_ENEMY_Dimensius the All-Devouring|r
>>|cRXP_WARN_Having a 5 man group with Tank + Healer is recommended for this step|r
.complete 10439,1 
.complete 10439,2 
.target Captain Saeed
.mob Dimensius the All-Devouring
step
.goto Netherstorm,60.11,31.72
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Professor Dabiri|r
.turnin 10439 >> Turn in Dimensius the All-Devouring
.target Professor Dabiri
step
.skill riding,225,1
#completewith next
.groundgoto Netherstorm,69.34,34.45,50,0
.groundgoto Netherstorm,70.06,37.52,50 >> Travel down the Celestial Ridge
step
#label NetherstormQuests
.goto Netherstorm,71.142,38.991
>>Click the |cRXP_PICK_Ethereal Teleport Pad|r, then talk to |cRXP_FRIENDLY_Wind Trader Marid|r
.turnin 10270 >> Turn in A Not-So-Modest Proposal
.target Wind Trader Marid
step
#label ReveredGrind
step
#tip
#completewith ReveredGrind2
>>The |cRXP_PICK_Ethereum Prisons|r can also spawn a random |cRXP_FRIENDLY_Friendly|r NPC awarding 500 rep with one of the following factions: Consortium, Cenarion Expedition, Keepers of Time, Lower City, The Sha'tar or Sporeggar. |cRXP_WARN_The reputation you gain through this method is party wide so you and 4 other friends can benefit from it|r
>>|T134889:0|t[|cRXP_LOOT_Ethereum Prison Key|r] can be bought from the Auction House
step
#label ReveredGrind2
.goto Nagrand,31.4,57.6,0
.goto Nagrand,31.365,57.793,0
.goto Nagrand,50.6,56.6,0
.goto Nagrand,40.6,31.0,0
.goto Netherstorm,30.4,76.6,0
.goto Netherstorm,32.442,64.206,0
.goto Netherstorm,59.5,32.4,0
.goto Netherstorm,54.46,40.36,0
.reputation 933,revered >>|cRXP_WARN_You now have a few choices to grind out the rep|r
>>Complete Heroic Mana-Tombs once every day (Requires Lower City Revered)
.dailyturnin 9892 >>Kill |cRXP_ENEMY_Ogres|r in Nagrand. Loot them for their |cRXP_LOOT_Obsidian Warbeads|r. Turn them in at |cRXP_FRIENDLY_Gezhe|r
.disablecheckbox
.dailyturnin 10308 >>Kill |cRXP_ENEMY_Zaxxis|r in Netherstorm. Loot them for their |cRXP_LOOT_Zaxxis Insignias|r. Turn them in at |cRXP_FRIENDLY_Nether-Stalker Khay'ji|r
.disablecheckbox
>>|cRXP_WARN_You will also be able to loot |cRXP_ENEMY_Zaxxis|r and |cRXP_ENEMY_Ethereum|r in Netherstorm and Mana-Tombs for|r |T134889:0|t[|cRXP_LOOT_Ethereum Prison Key|r]
.dailyturnin 10972 >>|cRXP_WARN_Use the keys at |cRXP_PICK_Ethereum Prisons|r at the Ethereum Staging Grounds in Netherstorm. This will spawn a |cRXP_ENEMY_Hostile|r mob which drops a |T134391:0|t[|cRXP_LOOT_Ethereum Prisoner I.D. Tag|r] that can be turned in at |cRXP_FRIENDLY_Commander Ameer|r for 250 rep|r
.disablecheckbox
step
.goto Netherstorm,59.5,32.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Ameer|r
.turnin 10971 >> Turn in Ethereum Secrets
.accept 10973 >> Accept A Thousand Worlds
.target Commander Ameer
.isQuestComplete 10971
step
.goto Netherstorm,59.5,32.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Ameer|r
>>|cRXP_WARN_NOTE: This quest chain requires turning in 5 x |T134889:0|t[|cRXP_LOOT_Ethereum Prison Key|r] and unlocks the ability to summon |cRXP_ENEMY_Yor|r in Heroic Mana-Tombs|r
.collect 29460,5,10973,1 
.turnin 10973 >> Turn in A Thousand Worlds
.target Commander Ameer
step
.goto Netherstorm,59.5,32.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Ameer|r
.accept 10973 >> Accept A Thousand Worlds
.target Commander Ameer
.isQuestTurnedIn 10971
step
.goto Netherstorm,59.5,32.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Commander Ameer|r
>>|cRXP_WARN_NOTE: This quest chain requires turning in 5 x |T134889:0|t[|cRXP_LOOT_Ethereum Prison Key|r] and unlocks the ability to summon |cRXP_ENEMY_Yor|r in Heroic Mana-Tombs|r
.collect 29460,5,10973,1 
.turnin 10973 >> Turn in A Thousand Worlds
.accept 10974 >> Accept Stasis Chambers of Bash'ir
.target Commander Ameer
step
.goto Blade's Edge Mountains,51.129,11.553
>>Click the |cRXP_PICK_Stasis Chamber Alpha|r to summon |cRXP_ENEMY_Thuk the Defiant|r
>>Kill |cRXP_ENEMY_Thuk the Defiant|r. Loot him for the |cRXP_LOOT_Evidence from Alpha|r
>>|cRXP_WARN_He has roughly 80,000 HP. He can be CC'd. Find 1-2 extra people to help you with it if needed|r
.complete 10974,1 
.mob Thuk the Defiant
step
.goto Blade's Edge Mountains,52.854,14.983
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Image of Commander Ameer|r
.turnin 10974 >> Turn in Stasis Chambers of Bash'ir
.accept 10976 >> Accept The Mark of the Nexus-King
.target Image of Commander Ameer
step
.goto Blade's Edge Mountains,52.854,14.983
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Image of Commander Ameer|r
>>Turn in 5 |T134889:0|t[|cRXP_LOOT_Ethereum Prison Key|r] to receive a |T134891:0|t[|cRXP_LOOT_Ethereum Stasis Chamber Key|r]
.collect 29460,5,10976,1 
.collect 29750,1,10976,1 
.dailyturnin 10975 >> Turn in Purging the Chambers of Bash'ir
.disablecheckbox
.target Image of Commander Ameer
step
#loop
.goto Blade's Edge Mountains,52.70,20.25,50,0
.goto Blade's Edge Mountains,49.40,21.31,50,0
.goto Blade's Edge Mountains,49.56,15.64,50,0
>>Open the |cRXP_PICK_Ethereum Stasis Chambers|r to summon |cRXP_ENEMY_Elites|r. Kill them and loot them for a |cRXP_LOOT_Mark of the Nexus-King|r
>>|cRXP_WARN_Ensure you have a few people helping you when you summon them|r
>>|cRXP_WARN_The |cRXP_LOOT_Mark of the Nexus-King|r is not a gaurenteed drop|r
.complete 10976,1 
step
.goto Blade's Edge Mountains,52.854,14.983
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Image of Commander Ameer|r
.turnin 10976 >> Turn in The Mark of the Nexus-King
.accept 10977 >> Accept Stasis Chambers of the Mana-Tombs
.target Image of Commander Ameer
step
>>Find a group for Heroic: Mana-Tombs
>>Click the |cRXP_PICK_Stasis Chamber|r inside. It is in the room after |cRXP_ENEMY_Pandemonius|r
.complete 10977,1 
step
#completewith next
.zone Blade's Edge Mountains >> Return to Blade's Edge Mountains
step
.goto Blade's Edge Mountains,52.854,14.983
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Image of Commander Ameer|r
.turnin 10977 >> Turn in Stasis Chambers of the Mana-Tombs
.accept 10981 >> Accept Nexus-Prince Shaffar's Personal Chamber
.target Image of Commander Ameer
step
#loop
.goto Blade's Edge Mountains,52.70,20.25,50,0
.goto Blade's Edge Mountains,49.40,21.31,50,0
.goto Blade's Edge Mountains,49.56,15.64,50,0
>>Obtain another |cRXP_LOOT_Mark of the Nexus-King|r by opening the |cRXP_PICK_Ethereum Stasis Chambers|r to summon and kill the |cRXP_ENEMY_Elites|r
>>|cRXP_WARN_You must turn in 5 |T134889:0|t[|cRXP_LOOT_Ethereum Prison Key|r] to receive a |T134891:0|t[|cRXP_LOOT_Ethereum Stasis Chamber Key|r] which allows you to open|r |cRXP_PICK_Ethereum Stasis Chambers|r
.complete 10981,1 
step
.goto Blade's Edge Mountains,52.854,14.983
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tTalk to |cRXP_FRIENDLY_Image of Commander Ameer|r
.turnin 10981 >> Turn in Nexus-Prince Shaffar's Personal Chamber
.target Image of Commander Ameer
step
#tip
#completewith ExaltedGrind
>>The |cRXP_PICK_Ethereum Prisons|r can also spawn a random |cRXP_FRIENDLY_Friendly|r NPC awarding 500 rep with one of the following factions: Consortium, Cenarion Expedition, Keepers of Time, Lower City, The Sha'tar or Sporeggar. |cRXP_WARN_The reputation you gain through this method is party wide so you and 4 other friends can benefit from it|r
>>|T134889:0|t[|cRXP_LOOT_Ethereum Prison Key|r] can be bought from the Auction House
step
#label ExaltedGrind
.goto Nagrand,31.4,57.6,0
.goto Nagrand,31.365,57.793,0
.goto Nagrand,50.6,56.6,0
.goto Nagrand,40.6,31.0,0
.goto Netherstorm,30.4,76.6,0
.goto Netherstorm,32.442,64.206,0
.goto Netherstorm,59.5,32.4,0
.goto Netherstorm,54.46,40.36,0
.reputation 933,exalted >>|cRXP_WARN_You now have a few choices to grind out the rep|r
>>Complete Heroic Mana-Tombs once every day (Requires Lower City Revered)
.dailyturnin 9892 >>Kill |cRXP_ENEMY_Ogres|r in Nagrand. Loot them for their |cRXP_LOOT_Obsidian Warbeads|r. Turn them in at |cRXP_FRIENDLY_Gezhe|r
.disablecheckbox
.dailyturnin 10308 >>Kill |cRXP_ENEMY_Zaxxis|r in Netherstorm. Loot them for their |cRXP_LOOT_Zaxxis Insignias|r. Turn them in at |cRXP_FRIENDLY_Nether-Stalker Khay'ji|r
.disablecheckbox
>>|cRXP_WARN_You will also be able to loot |cRXP_ENEMY_Zaxxis|r and |cRXP_ENEMY_Ethereum|r in Netherstorm and Mana-Tombs for|r |T134889:0|t[|cRXP_LOOT_Ethereum Prison Key|r]
.dailyturnin 10972 >>|cRXP_WARN_Use the keys at |cRXP_PICK_Ethereum Prisons|r at the Ethereum Staging Grounds in Netherstorm. This will spawn a |cRXP_ENEMY_Hostile|r mob which drops a |T134391:0|t[|cRXP_LOOT_Ethereum Prisoner I.D. Tag|r] that can be turned in at |cRXP_FRIENDLY_Commander Ameer|r for 250 rep|r
.disablecheckbox
step
+|cRXP_WARN_Congratulations! You have reached the end of The Consortium reputation guide|r
]]);
