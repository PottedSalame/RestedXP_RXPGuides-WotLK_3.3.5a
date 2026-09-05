-- Converted from the GPL-licensed ZygorGuidesViewerRM 3.3.5 leveling routes.
-- This guide-data file remains GPL-licensed; conversion is offline and creates no runtime dependency.
RXPGuides.RegisterGuide([[
#wotlk
#ac335
#version 1
#group RestedXP WotLK Guide (H)
#subgroup Northrend 70-80
<< Horde
#name 70-72 Northrend
#next 72-74 Northrend
step
.zone Orgrimmar
>>Go to Orgrimmar
step
.zone Durotar
>>Go outside to Durotar
step
.goto Durotar,41.4,17.8
.zone Borean Tundra
>>Ride the zeppelin to Borean Tundra
step
.goto Borean Tundra,41.6,54
.target Warsong Recruitment Officer
.accept 11585 >> Accept Hellscream's Vigil
step
.goto Borean Tundra,41.3,53.6
>>Go downstairs to 41.3,53.6
.target Garrosh Hellscream
.turnin 11585 >> Turn in Hellscream's Vigil
step
.goto Borean Tundra,41.3,53.6
.target High Overlord Saurfang
.accept 11596 >> Accept The Defense of Warsong Hold
step
.goto Borean Tundra,43.2,55
>>Go outside to 43.2,55
.target Overlord Razgor
.turnin 11596 >> Turn in The Defense of Warsong Hold
.accept 11598 >> Accept Taking Back Mightstone Quarry
step
.goto Borean Tundra,43.3,55.4
.target Quartermaster Holgoth
.accept 11606 >> Accept Patience is a Virtue that We Don't Need
step
.goto Borean Tundra,42.2,56.2
.target Foreman Mortuus
.accept 11611 >> Accept Taken by the Scourge
step
.goto Borean Tundra,43.3,57.9
.complete 11598,1
.mob Nerub'ar
>>Kill Nerub'ar
>>Click the Warsong Munitions crates - They look like wooden crates on the ground around this area
.complete 11606,1
>>Collect Warsong Munitions
step
.goto Borean Tundra,42.8,58.1
>>Attack the shaking white cocoons on the ground - When you break the cocoons, you will not always free a peon
.complete 11611,1
>>Free 5 Warsong Peons
step
.goto Borean Tundra,42.2,56.2
.target Foreman Mortuus
.turnin 11611 >> Turn in Taken by the Scourge
step
.goto Borean Tundra,43.3,55.4
.target Quartermaster Holgoth
.turnin 11606 >> Turn in Patience is a Virtue that We Don't Need
.accept 11608 >> Accept Bury Those Cockroaches!
step
.goto Borean Tundra,43.2,55
.target Overlord Razgor
.turnin 11598 >> Turn in Taking Back Mightstone Quarry
.accept 11602 >> Accept Cutting Off the Source
.target Shadowstalker Barthus
.accept 11614 >> Accept Untold Truths
step
.goto Borean Tundra,44.6,59.3
>>Go south up the metal stairs to 44.6,59.3
>>Attack the Nerub'ar Egg Sacs on the ground - They look like small white-ish eggs on the ground around this area, near structures
.complete 11602,1
>>Destroy 10 Nerub'ar Egg Sacs
step
.goto Borean Tundra,44.3,56.9
.use 34710
>>Use your Seaforium Depth Charge Bundle while standing next to the hole
.complete 11608,2
>>Destroy the East Nerub'ar Sinkhole
step
.goto Borean Tundra,41.7,58.3
.use 34710
>>Use your Seaforium Depth Charge Bundle while standing next to the hole
.complete 11608,1
>>Destroy the South Nerub'ar Sinkhole
step
.goto Borean Tundra,39.8,52.6
.use 34710
>>Use your Seaforium Depth Charge Bundle while standing next to the hole
.complete 11608,3
>>Destroy the West Nerub'ar Sinkhole
step
.goto Borean Tundra,40.1,52.1
.target Shadowstalker Luther
.turnin 11614 >> Turn in Untold Truths
.accept 11615 >> Accept Nerub'ar Secrets
step
.goto Borean Tundra,41.3,50.4
.use 34710
>>Use your Seaforium Depth Charge Bundle while standing next to the hole
.complete 11608,4
>>Destroy the North Nerub'ar Sinkhole
step
.goto Borean Tundra,43.3,55.4
.target Quartermaster Holgoth
.turnin 11608 >> Turn in Bury Those Cockroaches!
step
.goto Borean Tundra,43.2,55
.target Overlord Razgor
.turnin 11602 >> Turn in Cutting Off the Source
.accept 11634 >> Accept Wind Master To'bor
.target Shadowstalker Barthus
.turnin 11615 >> Turn in Nerub'ar Secrets
.accept 11616 >> Accept Message to Hellscream
step
.goto Borean Tundra,41.3,53.6
>>Go into Warsong Hold to 41.3,53.6
.target Garrosh Hellscream
.turnin 11616 >> Turn in Message to Hellscream
.accept 11618 >> Accept Reinforcements Incoming...
step
.goto Borean Tundra,40.4,51.4
>>Go to the very top of Warsong Hold to 40.4,51.4
.target Turida Coldwind
.fp Warsong Hold, Borean Tundra >> Get the Warsong Hold flight path
step
.goto Borean Tundra,42.3,54.9
.target Wind Master To'bor
.turnin 11634 >> Turn in Wind Master To'bor
.accept 11636 >> Accept Magic Carpet Ride
step
.goto Borean Tundra,38.1,52.6
>>Go northwest outside to 38.1,52.6
.target Shadowstalker Ickoris
.turnin 11618 >> Turn in Reinforcements Incoming...
.accept 11686 >> Accept The Warsong Farms
step
.goto Borean Tundra,37.9,52.6
.target Shadowstalker Canarius
.accept 11676 >> Accept Merciful Freedom
step
.goto Borean Tundra,37.9,52.3
.target Farmer Torp
.accept 11688 >> Accept Damned Filthy Swine
step
.goto Borean Tundra,37.2,51.4
.complete 11688,1
.mob Unliving Swine
>>Kill Unliving Swine
step
.goto Borean Tundra,39.5,48.1
.complete 11686,3
>>Scout the Warsong Slaughterhouse
step
.goto Borean Tundra,36.4,48.1
.mob En'kilah Necrolord+,Warsong Aberration
>>Kill En'kilah Necrolord+,Warsong Aberration
>>Collect Scourge Cage Key
>>Click the Scourge Cages as you see them - The Scourge Cages look like tall cages with big white skulls on top of them
.complete 11676,1
>>Free 5 Scourge Prisoners
step
.goto Borean Tundra,36.7,52.4
.complete 11686,2
>>Scout Torp's Farm
step
.goto Borean Tundra,35,54.7
.complete 11686,1
>>Scout the Warsong Granary
step
.goto Borean Tundra,37.9,52.6
.target Shadowstalker Canarius
.turnin 11676 >> Turn in Merciful Freedom
.target Shadowstalker Ickoris
.turnin 11686 >> Turn in The Warsong Farms
.accept 11703 >> Accept Get to Getry
step
.goto Borean Tundra,37.9,52.3
.target Farmer Torp
.turnin 11688 >> Turn in Damned Filthy Swine
.accept 11690 >> Accept Bring 'Em Back Alive
step
>>Search around for Infected Kodo Beasts
.use 34954
>>Use Torp's Kodo Snaffle on Infected Kodo Beasts
>>Ride the kodos back to Farmer Torp
.macro Deliver Kodo,134400 >>/cast Deliver Kodo
>>Use the Deliver Kodo skill to return the kodos
.complete 11690,1
>>Rescue 8 Kodos
step
.goto Borean Tundra,37.9,52.3
.target Farmer Torp
.turnin 11690 >> Turn in Bring 'Em Back Alive
step
.goto Borean Tundra,34.6,46.4
>>Go northwest to the top of the tower at 34.6,46.4
.target Shadowstalker Getry
.turnin 11703 >> Turn in Get to Getry
.accept 11705 >> Accept Foolish Endeavors
step
>>Follow Shadowstalker Getry down the tower and watch the cutscene
>>Make sure to hit Varidus the Flenser at least once, then let the NPCs fight for you
.complete 11705,1
>>Defeat Varidus the Flenser
step
.goto Borean Tundra,41.3,53.6
.target Garrosh Hellscream
.turnin 11705 >> Turn in Foolish Endeavors
.accept 11709 >> Accept Nork Bloodfrenzy's Charge
step
.goto Borean Tundra,43.7,54.5
>>Go outside to 43.7,54.5
.target Warden Nork Bloodfrenzy
.turnin 11709 >> Turn in Nork Bloodfrenzy's Charge
.accept 11711 >> Accept Coward Delivery... Under 30 Minutes or it's Free
step
.goto Borean Tundra,55.3,50.8
.use 34971
>>Standing at the crossroads and use your Warsong Flare Gun
.complete 11711,1
>>Deliver the Alliance Deserter
step
.goto Borean Tundra,53.1,51.6
.target Scout Tungok
.turnin 11711 >> Turn in Coward Delivery... Under 30 Minutes or it's Free
.accept 11714 >> Accept Vermin Extermination
step
.goto Borean Tundra,52.1,52.5
.target Bloodmage Laurith
.accept 11716 >> Accept The Wondrous Bloodspore
step
.goto Borean Tundra,52.7,52.7
>>Click the Bloodspore Carpel around this area - The Bloodspore Carpel look like bright red tall flowers around this area
.complete 11716,1
>>Collect Bloodspore Carpel
.complete 11714,1
.mob Bloodspore Harvester
>>Kill Bloodspore Harvester
.complete 11714,2
.mob Bloodspore Firestarter
>>Kill Bloodspore Firestarter
.complete 11714,3
.mob Bloodspore Roaster
>>Kill Bloodspore Roaster
step
.goto Borean Tundra,52.1,52.5
.target Bloodmage Laurith
.turnin 11716 >> Turn in The Wondrous Bloodspore
.accept 11717 >> Accept Pollen from the Source
step
.goto Borean Tundra,53.1,51.6
.target Scout Tungok
.turnin 11714 >> Turn in Vermin Extermination
step
>>Kill Bloodspore Moths all around this area
.complete 11717,1
>>Collect Bloodspore Moth Pollen
step
.goto Borean Tundra,52.1,52.5
.target Bloodmage Laurith
.turnin 11717 >> Turn in Pollen from the Source
.accept 11719 >> Accept A Suitable Test Subject
.use 34978
>>Use the Pollinated Bloodspore Flower in your bags
.turnin 11719 >> Turn in A Suitable Test Subject
.accept 11720 >> Accept The Invasion of Gammoth
step
.goto Borean Tundra,52.2,52.8
.target Primal Mighthorn
.turnin 11720 >> Turn in The Invasion of Gammoth
.accept 11721 >> Accept Gammothra the Tormentor
step
>>Go southwest into the cave at 49.2,58.4
.goto Borean Tundra,49.2,58.4,0.5
>>Go inside the cave
step
.goto Borean Tundra,46.1,62.1
>>Follow the path all the way down to 46.1,62.1
.use 34979
>>Use your Pouch of Crushed Bloodspore on Gammothra the Tormentor
.mob Gammothra the Tormentor
>>Kill Gammothra the Tormentor
.complete 11721,1
>>Collect Head of Gammothra
step
.goto Borean Tundra,49.4,65.6
>>Leave the cave and go southeast to 49.4,65.6
.goto Borean Tundra,49.4,65.6,0.5
>>The path up to the Massive Glowing Egg starts here
step
.goto Borean Tundra,48.5,59.1
>>Follow the path up and jump down to 48.5,59.1
>>Click the Massive Glowing Egg - Near the top of the hill, among a bunch of moths. You will have to jump down to it. It looks like a big round orange egg sac thing
.accept 11724 >> Accept Massive Moth Omelet?
step
.goto Borean Tundra,52.2,52.8
.target Primal Mighthorn
.turnin 11721 >> Turn in Gammothra the Tormentor
.accept 11722 >> Accept Trophies of Gammoth
step
.goto Borean Tundra,52.2,52.8
.target Bloodmage Laurith
.turnin 11724 >> Turn in Massive Moth Omelet?
step
.goto Borean Tundra,41.3,53.6
.target Garrosh Hellscream
.turnin 11722 >> Turn in Trophies of Gammoth
step
.goto Borean Tundra,42.3,55.7
>>Go to the top of Warsong Hold to 42.3,55.7
.target Yanni
.goto Borean Tundra,32.1,54.6,1
>>Go to Garrosh's Landing
step
.goto Borean Tundra,32.2,54.1
.target Gorge the Corpsegrinder
.turnin 11636 >> Turn in Magic Carpet Ride
.accept 11642 >> Accept Tank Ain't Gonna Fix Itself
step
.goto Borean Tundra,32.1,54.3
.target Mobu
.turnin 11642 >> Turn in Tank Ain't Gonna Fix Itself
.accept 11643 >> Accept Mobu's Pneumatic Tank Transjigamarig
.accept 11644 >> Accept Super Strong Metal Plates!
step
.goto Borean Tundra,32.3,54.3
.target Waltor of Pal'ea
.accept 11655 >> Accept Into the Mist
.accept 11660 >> Accept Horn of the Ancient Mariner
step
.goto Borean Tundra,31.9,52.3
>>Go north to the top of the tower to 31.9,52.3
.target Mootoo the Younger
.accept 11664 >> Accept Escaping the Mist
.complete 11664,1
>>Escort Mootoo the Younger out of the tower
step
.goto Borean Tundra,31.7,54.4
.target Elder Mootoo
.turnin 11664 >> Turn in Escaping the Mist
step
.goto Borean Tundra,29.9,54.4
>>Click Super Strong Metal Plates on the ground - They look like tan-ish metal plates half buried in the sand
.complete 11644,1
>>Collect Super Strong Metal Plate
step
.goto Borean Tundra,30.4,53.5
.mob Kvaldir mobs
>>Kill Kvaldir mobs
.complete 11655,1
>>Collect Tuskarr Relic
.mob Kvaldir Mistweavers
>>Kill Kvaldir Mistweavers
.complete 11660,1
>>Collect Horn of the Ancient Mariner
step
.goto Borean Tundra,32.4,49.1
>>Click the Pneumatic Tank Transjigamarig - Inside a small house, it looks like a small metal turret thing
.complete 11643,1
>>Collect Pneumatic Tank Transjigamarig
step
.goto Borean Tundra,32.1,54.3
.target Mobu
.turnin 11643 >> Turn in Mobu's Pneumatic Tank Transjigamarig
.turnin 11644 >> Turn in Super Strong Metal Plates!
.accept 11651 >> Accept Tanks a lot...
step
.goto Borean Tundra,32.2,54.1
.target Gorge the Corpsegrinder
.turnin 11651 >> Turn in Tanks a lot...
.accept 11652 >> Accept The Plains of Nasam
step
.goto Borean Tundra,32.3,54.3
.target Waltor of Pal'ea
.turnin 11655 >> Turn in Into the Mist
.accept 11656 >> Accept Burn in Effigy
.turnin 11660 >> Turn in Horn of the Ancient Mariner
.accept 11661 >> Accept Orabus the Helmsman
step
.goto Borean Tundra,29.8,52.6
>>Stand at the front of the ship
.use 34830
>>Use your Tuskarr Torch
.complete 11656,3
>>Destroy Bor's Hammer
step
.goto Borean Tundra,31,49
>>Stand at the front of the ship
.use 34830
>>Use your Tuskarr Torch
.complete 11656,2
>>Destroy The Kur Drakkar
step
.goto Borean Tundra,31.7,48.3
>>Stand at the front of the ship
.use 34830
>>Use your Tuskarr Torch
.complete 11656,1
>>Destroy The Serpent's Maw
step
.goto Borean Tundra,26.8,54.7
>>Stand at the very edge of the rocks
.use 34844
>>Use your Horn of the Ancient Mariner
.complete 11661,1
.mob Orabus the Helmsman
>>Kill Orabus the Helmsman
step
.goto Borean Tundra,30.1,61.7
>>Stand at the front of the ship
.use 34830
>>Use your Tuskarr Torch
.complete 11656,4
>>Destroy Bor's Anvil
step
.goto Borean Tundra,32.3,54.3
.target Waltor of Pal'ea
.turnin 11656 >> Turn in Burn in Effigy
.turnin 11661 >> Turn in Orabus the Helmsman
.accept 11662 >> Accept Seek Out Karuk!
step
.vehicle
>>Click one of the Horde Siege Tanks sitting behind you to get into one
step
.goto Borean Tundra,34,61.6
>>Ride south to 34,61.6
>>Use the buttons on your tank action bar to do the following around this area:
.complete 11652,1
>>Ride near the big undead structure to Identify the Scourge Leader
.complete 11652,2
>>Obliterate 100 Scourge Units
.complete 11652,3
>>Rescue 3 Injured Warsong Soldiers
step
.goto Borean Tundra,41.3,53.6
>>Exit the tank in a safe spot and go to Warsong Hold
.target Garrosh Hellscream
.turnin 11652 >> Turn in The Plains of Nasam
.accept 11916 >> Accept Hellscream's Champion
step
.goto Borean Tundra,41.7,54.7
.target Endorah
.accept 11574 >> Accept Too Close For Comfort
step
.goto Borean Tundra,47.1,75.5
>>Go southeast outside to 47.1,75.5
.target Karuk
.turnin 11662 >> Turn in Seek Out Karuk!
.accept 11613 >> Accept Karuk's Oath
step
.goto Borean Tundra,46.5,77.2
.complete 11613,1
.mob Skadir Raider
>>Kill Skadir Raider
.complete 11613,2
.mob Skadir Longboatsman
>>Kill Skadir Longboatsman
step
.goto Borean Tundra,44.2,77.8
>>Kill the Riplash Myrmidon and cheering Skadir mobs
.target Captured Tuskarr Prisoner
.accept 12471 >> Accept Cruelty of the Kvaldir
step
.goto Borean Tundra,47.1,75.5
.target Karuk
.turnin 11613 >> Turn in Karuk's Oath
.accept 11619 >> Accept Gamel the Cruel
.turnin 12471 >> Turn in Cruelty of the Kvaldir
step
.goto Borean Tundra,46.4,78.2
.complete 11619,1
>>Kill Gamel the Cruel inside the cave
step
.goto Borean Tundra,47.1,75.5
.target Karuk
.turnin 11619 >> Turn in Gamel the Cruel
.accept 11620 >> Accept A Father's Words
step
.goto Borean Tundra,43.6,80.5
.target Veehja
.turnin 11620 >> Turn in A Father's Words
.accept 11625 >> Accept The Trident of Naz'jan
step
.goto Borean Tundra,54.7,89.1
>>Go into the big building
.mob Ragnar Drakkarlund
>>Kill Ragnar Drakkarlund
.complete 11625,1
>>Collect Trident of Naz'jan
step
.goto Borean Tundra,43.6,80.5
.target Veehja
.turnin 11625 >> Turn in The Trident of Naz'jan
.accept 11626 >> Accept The Emissary
step
.goto Borean Tundra,52.2,88.2
>>Swim underwater to the bubbling rock at the very bottom - Stand on the bubbling rock at the very bottom underwater, so you don't run out of air
.use 35850
>>Use your Trident of Naz'jan on Leviroth
.complete 11626,1
.mob Leviroth
>>Kill Leviroth
step
.goto Borean Tundra,47.1,75.5
.target Karuk
.turnin 11626 >> Turn in The Emissary
step
.goto Borean Tundra,57,44.3
.target Arch Druid Lathorius
.accept 11864 >> Accept A Mission Statement
.turnin 11864 >> Turn in A Mission Statement
.accept 11866 >> Accept Ears of Our Enemies
.accept 11876 >> Accept Help Those That Cannot Help Themselves
step
.goto Borean Tundra,57.3,44.1
.target Hierophant Cenius
.accept 11869 >> Accept Happy as a Clam
step
.goto Borean Tundra,57,44
.target Killinger the Den Watcher
.accept 11884 >> Accept Ned, Lord of Rhinos...
step
.goto Borean Tundra,56.8,44
.target Zaza
.accept 11865 >> Accept Unfit for Death
step
.goto Borean Tundra,53.8,40.6
.use 35228
>>Use your D.E.H.T.A. Trap Smasher while standing next to Trapped Mammoth Calves
.complete 11876,1
>>Free 8 Mammoth Calves
step
.goto Borean Tundra,53.4,42.7
.complete 11869,1
.mob Loot Crazed Diver
>>Kill Loot Crazed Diver
.mob Loot Crazed Divers
>>Kill Loot Crazed Divers
.complete 11866,1
>>Collect Nesingwary Lackey Ear
step
.goto Borean Tundra,46.4,40
.complete 11884,2
>>Find and kill "Lunchbox"
.complete 11884,1
.mob Nedar, Lord of Rhinos
>>Kill Nedar, Lord of Rhinos
step
.goto Borean Tundra,56.2,50.5
>>Stand inside the Caribou Traps on the ground - They look like metal spiked traps on the ground
.use 35127
>>Use your Pile of Fake Furs
.complete 11865,1
>>Trap 8 Nesingwary Trappers
step
.goto Borean Tundra,57,44.3
.target Arch Druid Lathorius
.turnin 11866 >> Turn in Ears of Our Enemies
.turnin 11876 >> Turn in Help Those That Cannot Help Themselves
.accept 11878 >> Accept Khu'nok Will Know
step
.goto Borean Tundra,57.3,44.1
.target Hierophant Cenius
.turnin 11869 >> Turn in Happy as a Clam
.accept 11870 >> Accept The Abandoned Reach
step
.goto Borean Tundra,57,44
.target Killinger the Den Watcher
.turnin 11884 >> Turn in Ned, Lord of Rhinos...
step
.goto Borean Tundra,56.8,44
.target Zaza
.turnin 11865 >> Turn in Unfit for Death
.accept 11868 >> Accept The Culler Cometh
step
.goto Borean Tundra,59.5,30.4
.target Khu'nok the Behemoth
.turnin 11878 >> Turn in Khu'nok Will Know
.accept 11879 >> Accept Kaw the Mammoth Destroyer
step
>>Ride around and find a Wooly Mammoth Bull
.vehicle
>>Click it to ride it
step
.goto Borean Tundra,53.7,23.9
>>Go north on the Wooly Mammoth Bull to 53.7,23.9
>>Use the skills on your mammoth action bar to do the following:
.mob Kaw the Mammoth Destroyer
>>Kill Kaw the Mammoth Destroyer
>>Click Kaw's War Halberd on the ground
.complete 11879,1
>>Collect Kaw's War Halberd
step
.goto Borean Tundra,57,44.3
.target Arch Druid Lathorius
.turnin 11879 >> Turn in Kaw the Mammoth Destroyer
step
.goto Borean Tundra,57.3,56.5
.complete 11868,1
.mob Karen "I Don't Caribou" the Culler
>>Kill Karen "I Don't Caribou" the Culler
step
.goto Borean Tundra,57.8,55.1
.target Hierophant Liandra
.turnin 11870 >> Turn in The Abandoned Reach
.accept 11871 >> Accept Not On Our Watch
step
.goto Borean Tundra,59.1,55.9
.mob Northsea Thugs
>>Kill Northsea Thugs
>>Click the Shipment of Animal Parts containers on the ground - They look like brown bags and crates sitting on the ground around this area
.complete 11871,1
>>Collect Shipment of Animal Parts
step
.goto Borean Tundra,57.8,55.1
.target Hierophant Liandra
.turnin 11871 >> Turn in Not On Our Watch
.accept 11872 >> Accept The Nefarious Clam Master...
step
.goto Borean Tundra,61.5,66.5
.complete 11872,1
.mob Clam Master K
>>Kill Clam Master K
step
.goto Borean Tundra,57.3,44.1
.target Hierophant Cenius
.turnin 11872 >> Turn in The Nefarious Clam Master...
step
.goto Borean Tundra,56.8,44
.target Zaza
.turnin 11868 >> Turn in The Culler Cometh
step
.goto Borean Tundra,54.3,36.1
.target Etaruk
.accept 11612 >> Accept Reclaiming the Quarry
step
.goto Borean Tundra,54.7,35.8
.target Elder Atkanok
.accept 11605 >> Accept The Honored Ancestors
step
.goto Borean Tundra,54.4,35.1
.complete 11612,1
.mob Beryl Treasure Hunter
>>Kill Beryl Treasure Hunter
step
.goto Borean Tundra,52.8,34
>>Click the Elder Sagani - It looks like 2 small totem pole things at the base of the big stone on the huge bone cart
.complete 11605,2
>>Identify the Elder Sagani
step
.goto Borean Tundra,52.3,31.2
>>Click the Elder Takret - It looks like 2 small totem pole things at the base of the big stone on the huge bone cart
.complete 11605,3
>>Identify the Elder Takret
step
.goto Borean Tundra,50.9,32.4
>>Click the Elder Kesuk - It looks like 2 small totem pole things at the base of the big stone on the huge bone cart
.complete 11605,1
>>Identify the Elder Kesuk
step
.goto Borean Tundra,54.7,35.8
.target Elder Atkanok
.turnin 11605 >> Turn in The Honored Ancestors
.accept 11607 >> Accept The Lost Spirits
step
.goto Borean Tundra,54.3,36.1
.target Etaruk
.turnin 11612 >> Turn in Reclaiming the Quarry
.accept 11617 >> Accept Hampering Their Escape
step
.goto Borean Tundra,51.5,31.4
.mob Beryl Hounds
>>Kill Beryl Hounds
>>Collect Cores of Malice
.use 34711
>>Use the Cores of Malice on Kaskala Craftsmen and Kaskala Shaman
.complete 11607,1
>>Free 3 Kaskala Craftsman spirits
.complete 11607,2
>>Free 3 Kaskala Shaman spirits
step
>>Kill Beryl Reclaimers all around this area
.collect 34772,3,11617 >> Collect 3 Gnomish Grenade
step
.goto Borean Tundra,52.2,32.1
.use 34772
>>Use your Gnomish Grenade while standing under the floating platform
.complete 11617,2
>>Destroy the North Platform
step
.goto Borean Tundra,51,33.9
.use 34772
>>Use your Gnomish Grenade while standing under the floating platform
.complete 11617,3
>>Destroy the West Platform
step
.goto Borean Tundra,52.8,34.5
.use 34772
>>Use your Gnomish Grenade while standing under the floating platform
.complete 11617,1
>>Destroy the East Platform
step
.goto Borean Tundra,54.7,35.8
.target Elder Atkanok
.turnin 11607 >> Turn in The Lost Spirits
.accept 11609 >> Accept Picking Up the Pieces
step
.goto Borean Tundra,54.3,36.1
.target Etaruk
.turnin 11617 >> Turn in Hampering Their Escape
.accept 11623 >> Accept A Visit to the Curator
step
.goto Borean Tundra,53.1,33.3
>>Click the Tuskarr Ritual Objects on the ground - They look like small stone fish and blue smoking bowls on the ground around this area
.complete 11609,1
>>Collect Tuskarr Ritual Object
step
.goto Borean Tundra,50.1,32.6
>>Go west up the hill to 50.1,32.6
.complete 11623,1
.mob Curator Insivius
>>Kill Curator Insivius
step
.goto Borean Tundra,54.7,35.8
.target Elder Atkanok
.turnin 11609 >> Turn in Picking Up the Pieces
.accept 11610 >> Accept Leading the Ancestors Home
step
.goto Borean Tundra,54.3,36.1
.target Etaruk
.turnin 11623 >> Turn in A Visit to the Curator
step
.goto Borean Tundra,52.8,34
.use 34715
>>Use your Tuskarr Ritual Object while standing next to the Elder Sagani
.complete 11610,2
>>Complete Elder Sagani's ceremony
step
.goto Borean Tundra,52.3,31.2
.use 34715
>>Use your Tuskarr Ritual Object while standing next to the Elder Takret
.complete 11610,3
>>Complete Elder Takret's ceremony
step
.goto Borean Tundra,50.9,32.4
.use 34715
>>Use your Tuskarr Ritual Object while standing next to the Elder Kesuk
.complete 11610,1
>>Complete Elder Kesuk's ceremony
step
.goto Borean Tundra,54.7,35.8
.target Elder Atkanok
.turnin 11610 >> Turn in Leading the Ancestors Home
step
.goto Borean Tundra,45.3,34.5
.target Surristrasz
.fp Amber Ledge, Borean Tundra >> Get the Amber Ledge flight path
step
.goto Borean Tundra,45,33.4
.target Librarian Donathan
.turnin 11574 >> Turn in Too Close For Comfort
.accept 11587 >> Accept Prison Break
step
.goto Borean Tundra,45,33.4
.target Librarian Garren
.accept 11576 >> Accept Monitoring the Rift: Cleftcliff Anomaly
step
.goto Borean Tundra,40.5,39.2
.mob Beryl Mage Hunters
>>Kill Beryl Mage Hunters
>>Collect Beryl Prison Key
>>Click an Arcane Prison
.complete 11587,1
>>Free an Arcane Prisoner
step
.goto Borean Tundra,41.2,41.8
.goto Borean Tundra,41.2,41.8,0.5
>>The path down to Monitoring the Rift: Cleftcliff Anomaly starts here
step
.goto Borean Tundra,34.3,42
.use 34669
>>Use your Arcanometer in this spot next to the purple glowing crack in the ground
.complete 11576,1
>>Take the Cleftcliff Anomaly Reading
step
.goto Borean Tundra,45.3,33.3
.target Librarian Donathan
.turnin 11587 >> Turn in Prison Break
.accept 11590 >> Accept Abduction
step
.goto Borean Tundra,45,33.4
.target Librarian Garren
.turnin 11576 >> Turn in Monitoring the Rift: Cleftcliff Anomaly
.accept 11582 >> Accept Monitoring the Rift: Sundered Chasm
step
.goto Borean Tundra,46.8,29.3
.goto Borean Tundra,46.8,29.3,0.5
>>The path down to Monitoring the Rift: Sundered Chasm starts here
step
.goto Borean Tundra,44,28.6
>>Go down the path and underwater to 44,28.6
.use 34669
>>Use your Arcanometer next to the huge pink crack underwater
.complete 11582,1
>>Take the Sundered Chasm Reading
step
.goto Borean Tundra,45,33.4
.target Librarian Garren
.turnin 11582 >> Turn in Monitoring the Rift: Sundered Chasm
.accept 12728 >> Accept Monitoring the Rift: Winterfin Cavern
step
.goto Borean Tundra,46.8,29.3
.goto Borean Tundra,46.8,29.3,0.5
>>The path down to Monitoring the Rift: Sundered Chasm starts here
step
.goto Borean Tundra,40.1,19.7
>>Stand in the mouth of the cave, past the torches
.use 34669
>>Use your Arcanometer
.complete 12728,1
>>Take the Winterfin Cavern Reading
step
.goto Borean Tundra,45,33.4
.target Librarian Garren
.turnin 12728 >> Turn in Monitoring the Rift: Winterfin Cavern
step
.goto Borean Tundra,43.5,37.4
>>Fight a Beryl Sorcerer
.use 34691
>>Use your Arcane Binder on him when you see the "Beryl Sorcerer can now be captured" message in your chat window
.complete 11590,1
>>Capture a Beryl Sorcerer
step
.goto Borean Tundra,45.3,33.3
.target Librarian Donathan
.turnin 11590 >> Turn in Abduction
.accept 11646 >> Accept The Borean Inquisition
step
.goto Borean Tundra,46.3,32.8
>>Go inside the tall tower to 46.3,32.8
.target Librarian Normantis
.turnin 11646 >> Turn in The Borean Inquisition
.accept 11648 >> Accept The Art of Persuasion
step
.use 34811
>>Use your Neural Needler on the Imprisoned Beryl Sorcerer repeatedly to Interrogate the Prisoner
.complete 11648,1
>>Interrogate the Prisoner
step
.goto Borean Tundra,46.3,32.8
.target Librarian Normantis
.turnin 11648 >> Turn in The Art of Persuasion
.accept 11663 >> Accept Sharing Intelligence
step
.goto Borean Tundra,45.3,33.3
>>Go outside the tower to 45.3,33.3
.target Librarian Donathan
.turnin 11663 >> Turn in Sharing Intelligence
.accept 11671 >> Accept A Race Against Time
step
.goto Borean Tundra,42.1,39.5
.use 34897
>>Use your Beryl Shield Detonator inside the big blue glowing circle
.mob Inquisitor Salrand
>>Kill Inquisitor Salrand
>>Click Salrand's Lockbox
.complete 11671,1
>>Collect Salrand's Broken Key
step
.goto Borean Tundra,45.3,33.3
.target Librarian Donathan
.turnin 11671 >> Turn in A Race Against Time
.accept 11679 >> Accept Reforging the Key
step
.goto Borean Tundra,45.3,34.5
.target Surristrasz
.turnin 11679 >> Turn in Reforging the Key
.accept 11680 >> Accept Taking Wing
step
.goto Borean Tundra,46.4,37.3
.target Warmage Anzim
.turnin 11680 >> Turn in Taking Wing
.accept 11681 >> Accept Rescuing Evanor
.goto Borean Tundra,46.4,32.6,0.3
>>Watch the cutscene, then you'll get teleported back to Amber Ledge
step
.goto Borean Tundra,46.4,32.4
.target Archmage Evanor
.turnin 11681 >> Turn in Rescuing Evanor
.accept 11682 >> Accept Dragonspeak
step
.goto Borean Tundra,45.3,34.5
>>Go outside the tower to 45.3,34.5
.target Surristrasz
.turnin 11682 >> Turn in Dragonspeak
.accept 11733 >> Accept Traversing the Rift
.fly Transitus Shield, Coldarra >> Fly to Transitus Shield
>>Fly to Transitus Shield
step
.goto Borean Tundra,32.9,34.4
.target Archmage Berinand
.turnin 11733 >> Turn in Traversing the Rift
.accept 11900 >> Accept Reading the Meters
.accept 11910 >> Accept Secrets of the Ancients
step
.goto Borean Tundra,33.3,34.5
.target Raelorasz
.accept 11918 >> Accept Basic Training
step
.goto Borean Tundra,33.5,34.4
.target Librarian Serrah
.accept 11912 >> Accept Nuts for Berries
step
+As you do the following steps, do the following:
>>Kill Glacial Ancients and get 3 Glacial Splinters
>>Kill Magic-Bound Ancients and get 3 Magic-Bound Splinters
>>Kill 10 Coldarra Spellweaver
>>Click Frostberry Bushes
>>Collect Frostberry
step
.goto Borean Tundra,32.7,29
.mob Coldarra Spellbinders
>>Kill Coldarra Spellbinders
>>Collect Scintillating Fragment
.use 35648
>>Click the Scintillating Fragment in your bags
.accept 11941 >> Accept Puzzling...
step
.goto Borean Tundra,28.3,28.5
>>Click the Coldarra Geological Monitor - It looks like a blue sphere on the ground at the base of the building
.complete 11900,1
>>Take the Nexus Geological Reading
step
.goto Borean Tundra,31.7,20.6
>>Click the Coldarra Geological Monitor - It looks like a blue sphere on the ground in the entrance of the building
.complete 11900,3
>>Take the Northern Coldarra Reading
step
.goto Borean Tundra,22.6,23.5
>>Click the Coldarra Geological Monitor - It looks like a blue sphere on the ground in the entrance of the building
.complete 11900,4
>>Take the Western Coldarra Reading
step
.goto Borean Tundra,28.3,35
>>Click the Coldarra Geological Monitor - It looks like a blue sphere on the ground in the entrance of the building
.complete 11900,2
>>Take the Southern Coldarra Reading
step
>>Make sure you have:
.complete 11910,1
>>3 Glacial Splinters
.complete 11910,2
>>3 Magic-Bound Splinters
.complete 11918,1
>>Killed 10 Coldarra Spellweavers
.complete 11912,1
>>10 Frostberries
step
.goto Borean Tundra,32.9,34.4
.target Archmage Berninand
.turnin 11900 >> Turn in Reading the Meters
.turnin 11910 >> Turn in Secrets of the Ancients
step
.goto Borean Tundra,33.3,34.5
.target Raelorasz
.turnin 11918 >> Turn in Basic Training
.accept 11936 >> Accept Hatching a Plan
.turnin 11941 >> Turn in Puzzling...
.accept 11943 >> Accept The Cell
step
.goto Borean Tundra,33.5,34.4
.target Librarian Serrah
.turnin 11912 >> Turn in Nuts for Berries
.accept 11914 >> Accept Keep the Secret Safe
step
+As you do the following steps:
.mob Coldarra Wyrmkin
>>Kill Coldarra Wyrmkin
>>Collect Frozen Axe
>>Skip to the next step of the guide
step
.goto Borean Tundra,24.1,29.6
.mob Warbringer Goredrak
>>Kill Warbringer Goredrak
.complete 11943,1
>>Collect Energy Core
step
.goto Borean Tundra,27.3,20.5
.mob General Cerulean
>>Kill General Cerulean
.complete 11943,2
>>Collect Prison Casing
step
.collect 35586,5,11936
>>Make sure you have 5 Frozen Axes
step
.goto Borean Tundra,27.8,24.2
.mob Arcane Serpents
>>Kill Arcane Serpents
.complete 11914,1
>>Collect Nexus Mana Essence
>>Click Blue Dragon Eggs - The Blue Dragon Eggs look like big eggs with blue crystals on them on the ground
.complete 11936,1
>>Destroy 5 Dragon Eggs
step
.goto Borean Tundra,33.3,34.5
.target Raelorasz
.turnin 11936 >> Turn in Hatching a Plan
.accept 11919 >> Accept Drake Hunt
.turnin 11943 >> Turn in The Cell
step
.goto Borean Tundra,33.5,34.4
.target Librarian Serrah
.turnin 11914 >> Turn in Keep the Secret Safe
step
.xp 71
step
.goto Borean Tundra,24.6,27.1
.use 35506
>>Use your Raelorasz's Spear on a Nexus Drake Hatchling
>>Do not kill it, let it hit you until it becomes friendly
step
.goto Borean Tundra,33.3,34.5
.complete 11940,1
>>Capture the Nexus Drake
.target Raelsorasz
.turnin 11919 >> Turn in Drake Hunt
.accept 11931 >> Accept Cracking the Code
step
.use 35671
>>Use the Augmented Arcane Prison in your bags
.target Keristrasza
.accept 11946 >> Accept Keristrasza
.turnin 11946 >> Turn in Keristrasza
.accept 11951 >> Accept Bait and Switch
step
.goto Borean Tundra,32.7,29
.mob Coldarra Spellbinders
>>Kill Coldarra Spellbinders
.complete 11931,1
>>Collect Shimmering Rune
step
.goto Borean Tundra,32.7,27.8
.mob Inquisitor Caleras
>>Kill Inquisitor Caleras
.complete 11931,2
>>Collect Azure Codex
step
>>Wander all around and do the following:
>>Click Crystallized Mana on the ground - They look like pink crystals
.complete 11951,1
>>Collect Crystallized Mana Shard
step
.use 35671
>>Use the Augmented Arcane Prison in your bags
.target Keristrasza
.turnin 11951 >> Turn in Bait and Switch
.accept 11957 >> Accept Saragosa's End
step
.use 35671
>>Use the Augmented Arcane Prison in your bags
.target Keristrasza
.goto Borean Tundra,21.2,22.5,0.5
>>Tell her you are ready to face Saragosa
step
>>She teleports you to a platform
.use 35690
>>Click the Arcane Power Focus in your bags
.mob Saragosa
>>Kill Saragosa
.complete 11957,1
>>Collect Saragosa's Corpse
step
.use 35671
>>Use the Augmented Arcane Prison in your bags
.target Keristrasza
.turnin 11957 >> Turn in Saragosa's End
.accept 11967 >> Accept Mustering the Reds
step
.use 35671
>>Use the Augmented Arcane Prison in your bags
.target Keristrasza
.goto Borean Tundra,33.3,34.4,0.5
>>Tell her to return you to Transitus Shield
step
.goto Borean Tundra,33.3,34.5
.target Raelorasz
.turnin 11931 >> Turn in Cracking the Code
.turnin 11967 >> Turn in Mustering the Reds
.accept 11969 >> Accept Springing the Trap
step
.goto Borean Tundra,25.4,21.7
.use 44950
>>Use Raelorasz' Spark next to the Signal Fire
>>Watch the cutscene
.complete 11969,1
>>Lure Malygos
step
.goto Borean Tundra,33.3,34.5
.target Raelorasz
.turnin 11969 >> Turn in Springing the Trap
step
.fly Warsong Hold, Borean Tundra >> Fly to Warsong Hold
>>Fly to Warsong Hold
step
.goto Borean Tundra,41.7,54.7
>>Go downstairs to 41.7,54.7
.target Ambassador Talonga
.accept 11888 >> Accept Ride to Taunka'le Village
step
.goto Borean Tundra,41.6,53.5
.target Sauranok the Mystic
.accept 12486 >> Accept To Bor'gorok Outpost, Quickly!
step
.fly Amber Ledge, Borean Tundra >> Fly to Amber Ledge
>>Fly to Amber Ledge
step
.goto Borean Tundra,63.8,46.1
.target Ataika
.accept 11949 >> Accept Not Without a Fight!
step
.goto Borean Tundra,64,45.7
.target Utaik
.accept 11945 >> Accept Preparing for the Worst
step
.goto Borean Tundra,65.3,47.2
.complete 11949,1
.mob Kvaldir Raider
>>Kill Kvaldir Raider
>>Click Kaskala Supplies baskets on the ground - The Kaskala Supplies look like wooden baskets on the ground
.complete 11945,1
>>Collect Kaskala Supplies
step
.goto Borean Tundra,63.8,46.1
.target Ataika
.turnin 11949 >> Turn in Not Without a Fight!
.accept 11950 >> Accept Muahit's Wisdom
step
.goto Borean Tundra,64,45.7
.target Utaik
.turnin 11945 >> Turn in Preparing for the Worst
step
.goto Borean Tundra,67.2,54.9
.target Elder Muahit
.turnin 11950 >> Turn in Muahit's Wisdom
.accept 11961 >> Accept Spirits Watch Over Us
step
.goto Borean Tundra,67.7,50.4
>>Click Iruk's body - His body is floating underwater
>>Search his corpse
.complete 11961,1
>>Collect Issliruk's Totem
step
.goto Borean Tundra,67.2,54.9
.target Elder Muahit
.turnin 11961 >> Turn in Spirits Watch Over Us
.accept 11968 >> Accept The Tides Turn
step
.goto Borean Tundra,67.4,56.8
.complete 11968,1
.mob Heigarr the Horrible
>>Kill Heigarr the Horrible
step
.goto Borean Tundra,67.2,54.9
.target Elder Muahit
.turnin 11968 >> Turn in The Tides Turn
step
.goto Borean Tundra,67.2,54.9
.target Hotawa
.accept 12117 >> Accept Travel to Moa'ki Harbor
step
.goto Borean Tundra,64,35.8
.target Crashed Recon Pilot
.accept 11887 >> Accept Emergency Supplies
step
.goto Borean Tundra,62.9,35.8
>>Click Fizzcrank Recon Pilots on the ground around this area
>>Search their bodies for the pilot's emergency toolkit
.complete 11887,1
>>Collect Gnomish Emergency Toolkit
step
.goto Borean Tundra,77.8,37.8
.target Omu Spiritbreeze
.fp Taunka'le Village, Borean Tundra >> Get the Taunka'le Village flight path
step
.goto Borean Tundra,77.5,37
.target Fezzix Geartwist
.turnin 11887 >> Turn in Emergency Supplies
.accept 11881 >> Accept Load'er Up!
step
.goto Borean Tundra,77.3,36.9
.target Greatmother Taiga
.accept 11674 >> Accept Sage Highmesa is Missing
step
.home Taunka'le Village >> Set your Hearthstone to Taunka'le Village
step
.goto Borean Tundra,75.9,37.2
.target Chieftain Wintergale
.turnin 11916 >> Turn in Hellscream's Champion
step
.goto Borean Tundra,77.1,37.8
.target Greatfather Mahan
.accept 11684 >> Accept Scouting the Sinkholes
step
.goto Borean Tundra,77.3,38.5
.target Sage Earth and Sky
.turnin 11888 >> Turn in Ride to Taunka'le Village
.accept 11890 >> Accept What Are They Up To?
step
.goto Borean Tundra,70.6,36.9
.use 34920
>>Use your Map of the Geyser Fields next to the huge hole in the ground
.complete 11684,1
>>Mark the Location of the South Sinkhole
step
.goto Borean Tundra,69.9,32.8
.use 34920
>>Use your Map of the Geyser Fields next to the huge hole in the ground
.complete 11684,2
>>Mark the Location of the Northeast Sinkhole
step
.goto Borean Tundra,66.4,32.9
.use 34920
>>Use your Map of the Geyser Fields next to the huge hole in the ground
.complete 11684,3
>>Mark the Location of the Northwest Sinkhole
step
.goto Borean Tundra,63.5,37
.use 35272
>>Use Jenny's Whistle next to this crashed airplane
.complete 11881,1
>>Escort Jenny back to Fezzix Geartwist at 77.5,37
step
.goto Borean Tundra,77.5,37
.target Fezzix Geartwist
.turnin 11881 >> Turn in Load 'er Up!
step
.goto Borean Tundra,77.6,36.9
.target Dorain Frosthoof
.accept 11893 >> Accept The Power of the Elements
step
.goto Borean Tundra,77.1,37.8
.target Greatfather Mahan
.turnin 11684 >> Turn in Scouting the Sinkholes
.accept 11685 >> Accept The Heart of the Elements
step
.goto Borean Tundra,75.5,33.6
.use 35281
>>Use your Windsoul Totem to plant a Windsoul Totem in the ground
.mob Steam Ragers near the Totem
>>Kill Steam Ragers near the Totem
.complete 11893,1
>>Collect 10 Energy
step
.goto Borean Tundra,74.7,23.7
.target Sage Highmesa
.turnin 11674 >> Turn in Sage Highmesa is Missing
.accept 11675 >> Accept A Proper Death
step
.goto Borean Tundra,75.2,18.7
.complete 11675,1
.mob Plagued Magnataur
>>Kill Plagued Magnataur
step
.goto Borean Tundra,74.7,23.7
.target Sage Highmesa
.turnin 11675 >> Turn in A Proper Death
.accept 11677 >> Accept Stop the Plague
step
.goto Borean Tundra,74.7,14.1
.use 34913
>>Use Highmesa's Cleansing Seeds next to the Den of Dying Plague Cauldron
.complete 11677,1
>>Neutralize the Plague Cauldron
step
.goto Borean Tundra,74.7,23.7
.target Sage Highmesa
.turnin 11677 >> Turn in Stop the Plague
.accept 11678 >> Accept Find Bristlehorn
.accept 11683 >> Accept Fallen Necropolis
step
.goto Borean Tundra,68.2,17
.mob Undead mobs
>>Kill Undead mobs
.complete 11683,1
>>Destroy 20 Talramas Scourge
step
.goto Borean Tundra,69.8,12.6
>>Go inside the undead building and upstairs to 69.8,12.6
.target Longrunner Bristlehorn
.turnin 11678 >> Turn in Find Bristlehorn
.accept 11687 >> Accept The Doctor and the Lich-Lord
step
.goto Borean Tundra,69.7,13.1
>>Go outside and follow the path to the top of the building to 69.7,13.1
.complete 11687,1
.mob Doctor Razorgrin
>>Kill Doctor Razorgrin
step
.goto Borean Tundra,69.7,13.9
>>Go to the very top of the building to 69.7,13.9
.complete 11687,2
.mob Lich-Lord Chillwinter
>>Kill Lich-Lord Chillwinter
step
.goto Borean Tundra,74.7,23.7
.target Sage Highmesa
.turnin 11687 >> Turn in The Doctor and the Lich-Lord
.accept 11689 >> Accept Return with the Bad News
.turnin 11683 >> Turn in Fallen Necropolis
step
.goto Borean Tundra,66.2,21.9
.complete 11890,1
>>Inspect the Fizzcrank Pumping Station environs
step
.goto Borean Tundra,76.3,37.2,0.5
.hs >> Hearth to Taunka'le Village
>>Hearth to Taunka'le Village
step
.goto Borean Tundra,77.3,36.9
.target Greatmother Taiga
.turnin 11689 >> Turn in Return with the Bad News
step
.goto Borean Tundra,77.6,36.9
.target Dorain Frosthoof
.turnin 11893 >> Turn in The Power of the Elements
step
.goto Borean Tundra,77.5,37
.target Fezzix Geartwist
.accept 11894 >> Accept Patching Up
step
.goto Borean Tundra,77.3,38.5
.target Sage Earth and Sky
.turnin 11890 >> Turn in What Are They Up To?
.accept 11895 >> Accept Master the Storm
step
.goto Borean Tundra,77.1,38.7
>>Click the Storm Totem
.mob Storm Tempest
>>Kill Storm Tempest
.complete 11895,1
>>Master the Storm
step
.goto Borean Tundra,77.3,38.5
.target Sage Earth and Sky
.turnin 11895 >> Turn in Master the Storm
.accept 11896 >> Accept Weakness to Lightning
step
.goto Borean Tundra,76.9,37.6
.target Iron Eyes
.accept 11906 >> Accept Cleaning Up the Pools
step
.goto Borean Tundra,77.3,36.9
.target Greatmother Taiga
.accept 11899 >> Accept Souls of the Decursed
step
.goto Borean Tundra,76.5,40.7
.mob Marsh Caribous
>>Kill Marsh Caribous
.collect 35288,5,11894 >> Collect 5 Uncured Caribou Hide
step
.goto Borean Tundra,87.7,42.5
.mob Frozen Elementals
>>Kill Frozen Elementals
.complete 11685,1
>>Collect Elemental Heart
step
.goto Borean Tundra,75.6,35.8
.target Wind Tamer Barah
.turnin 11685 >> Turn in The Heart of the Elements
.accept 11695 >> Accept The Horn of Elemental Fury
step
.goto Borean Tundra,75.8,32.5
.use 35288
>>Click the Uncured Caribou Hides in your bags next to the small steam vent
.complete 11894,1
>>Collect Steam Cured Hide
step
.goto Borean Tundra,78.7,28.4
.mob Chieftain Gurgleboggle
>>Kill Chieftain Gurgleboggle
>>Collect Gurbleboggle's Key
>>Click Gurbleboggle's Bauble - Gurbleboggle's Bauble looks like a small stone altar in this small pond with a big white pearl sitting on it
.complete 11695,2
>>Collect Lower Horn Half
step
.goto Borean Tundra,77.5,37
.target Fezzix Geartwist
.turnin 11894 >> Turn in Patching Up
step
.goto Borean Tundra,75.9,37.2
.target Chieftain Wintergale
.accept 11628 >> Accept Shrouds of the Scourge
step
.goto Borean Tundra,82.2,30.4
.mob Scourged Mammoths
>>Kill Scourged Mammoths
.complete 11628,1
>>Collect Scourged Mammoth Pelt
step
.goto Borean Tundra,75.9,37.2
.target Chieftain Wintergale
.turnin 11628 >> Turn in Shrouds of the Scourge
.accept 11630 >> Accept The Bad Earth
step
.goto Borean Tundra,76.1,28
>>Click the Scourged Earth - They look like piles of dirt on the ground
.complete 11630,1
>>Collect Scourged Earth
step
.goto Borean Tundra,75.9,37.2
.target Chieftain Wintergale
.turnin 11630 >> Turn in The Bad Earth
.accept 11633 >> Accept Blending In
step
.goto Borean Tundra,84.1,31.1,1
.use 34782
>>Equip the Imbued Scourge Shroud in your bags
step
.goto Borean Tundra,88.9,28.6
.complete 11633,3
>>Scout the Spire of Pain
step
.goto Borean Tundra,88.11,20.9
.complete 11633,2
>>Scout the Spire of Blood
step
.goto Borean Tundra,83.91,20.5
.complete 11633,1
>>Scout the Spire of Decay
step
.goto Borean Tundra,75.9,37.2
.target Chieftain Wintergale
.turnin 11633 >> Turn in Blending In
.accept 11640 >> Accept Words of Power
step
.goto Borean Tundra,76,37.3
.target Sage Aeire
.accept 11647 >> Accept Neutralizing the Cauldrons
.target Durm Icehide
.accept 11641 >> Accept A Courageous Strike
step
.goto Borean Tundra,68.6,40.4
.mob Chieftain Burblegobble
>>Kill Chieftain Burblegobble
>>Collect Burblegobble's Key
>>Click Burblegobble's Bauble - Burblegobble's Bauble looks like a small stone altar in this small pond with a big white pearl sitting on it
.complete 11695,1
>>Collect Upper Horn Half
step
+Click Fizzcrank Spare Parts on the ground as you do the following steps: - They look like metal parts on the ground
>>Collect Fizzcrank Spare Parts
>>Skip to the next step of the guide
step
.goto Borean Tundra,68.1,27.5
.use 35352
>>Use Sage's Lightning Rod on robots and kill them
.complete 11896,1
>>Weaken and destroy 15 Robots
step
.goto Borean Tundra,64.6,23.6
.mob Fizzcrank Mechagnomes
>>Kill Fizzcrank Mechagnomes
.use 35401
>>Use The Greatmother's Soulcatcher on their bodies
.complete 11899,1
>>Capture 10 Gnome souls
step
.complete 11906,1
>>Make sure you have 15 Fizzcrank Spare Parts
step
.goto Borean Tundra,76.3,37.2,0.5
.hs >> Hearth to Taunka'le Village
>>Hearth to Taunka'le Village
step
.goto Borean Tundra,76.9,37.6
.target Iron Eyes
.turnin 11906 >> Turn in Cleaning Up the Pools
step
.goto Borean Tundra,77.3,38.5
.target Sage Earth and Sky
.turnin 11896 >> Turn in Weakness to Lightning
.accept 11907 >> Accept The Sub-Chieftains
step
.goto Borean Tundra,77.3,36.9
.target Greatmother Taiga
.turnin 11899 >> Turn in Souls of the Decursed
.accept 11909 >> Accept Defeat the Gearmaster
step
.goto Borean Tundra,75.6,35.8
.target Wind Tamer Barah
.turnin 11695 >> Turn in The Horn of Elemental Fury
.accept 11706 >> Accept The Collapse
step
.goto Borean Tundra,85.2,28.5
.complete 11641,1
.mob En'kilah Ghoul
>>Kill En'kilah Ghoul
.complete 11641,2
.mob En'kilah Necromancer
>>Kill En'kilah Necromancer
step
.goto Borean Tundra,89.4,28.9
>>Kill the 2 bug guards and the 2 cocoons next to him
.mob High Priest Talet-Kha
>>Kill High Priest Talet-Kha
.complete 11640,2
>>Collect High Priest Talet-Kha's Scroll
step
.goto Borean Tundra,87.7,29.8
.use 34806
>>Use Sage Aeire's Totem next to this big cauldron
.complete 11647,1
>>Cleanse the East Cauldron
step
.goto Borean Tundra,88.1,20.9
.mob High Priest Andorath
>>Kill High Priest Andorath
.complete 11640,3
>>Collect High Priest Andorath's Scroll
step
.goto Borean Tundra,86.2,22.7
.use 34806
>>Use Sage Aeire's Totem next to this big cauldron
.complete 11647,2
>>Cleanse the Central Cauldron
step
.goto Borean Tundra,83.9,20.5
.mob the 3 guards
>>Kill the 3 guards
.mob High Priest Naferset
>>Kill High Priest Naferset
.complete 11640,1
>>Collect High Priest Naferset's Scroll
step
.goto Borean Tundra,85.5,20.2
.use 34806
>>Use Sage Aeire's Totem next to this big cauldron
.complete 11647,3
>>Cleanse the West Cauldron
step
.goto Borean Tundra,87.7,22.0
>>Find and Kill Darkfallen Bloodbearer - He walks up and down the path to the biggest temple
>>Collect Vial of Fresh Blood
.use 34815
>>Click the Vial of Fresh Blood
.accept 11654 >> Accept The Spire of Blood
step
.goto Borean Tundra,87.6,20
>>Go inside the big temple to 87.6,20
.target Snow Tracker Grumm
.turnin 11654 >> Turn in The Spire of Blood
.accept 11659 >> Accept Shatter the Orbs!
step
>>Walk around on this floor:
>>Attack En'Kilah Blood Globes - They look like red globes sitting on golden pedestals
.complete 11659,1
>>Shatter 5 Blood Globes
step
.goto Borean Tundra,76.7,37.9
.target Snow Tracker Junek
.turnin 11659 >> Turn in Shatter the Orbs!
step
.goto Borean Tundra,76,37.3
.target Sage Aeire
.turnin 11647 >> Turn in Neutralizing the Cauldrons
step
.goto Borean Tundra,76,37.3
.target Durm Icehide
.turnin 11641 >> Turn in A Courageous Strike
step
.goto Borean Tundra,75.9,37.2
.target Chieftain Wintergale
.turnin 11640 >> Turn in Words of Power
step
.goto Borean Tundra,70.6,36.9
>>Stand next to the sinkhole - It's a huge hole in the ground
.use 34968
>>Use The Horn of Elemental Fury in your bags
.complete 11706,2
>>Collapse the Nerubian tunnels
>>Wait for Lord Kryxix that spawns
.complete 11706,1
.mob Lord Kryxix
>>Kill Lord Kryxix
step
.goto Borean Tundra,65.2,28.8
>>Click the South Point Station Valve - It looks like a red round handle on the side of the metal pipe
.complete 11907,4
.mob The Grinder
>>Kill The Grinder
step
.goto Borean Tundra,64.4,23.4
>>Go north on top of the pump station to 64.4,23.4
.complete 11909,1
>>Click The Gearmaster's Manual
.mob Gearmaster Mechazod
>>Kill Gearmaster Mechazod
.complete 11909,2
>>Collect Mechazod's Head
step
.goto Borean Tundra,63.7,22.5
>>Click the Mid Point Station Valve - It looks like a red round handle on the side of the metal pipe
.complete 11907,3
.mob Max Blasto
>>Kill Max Blasto
step
.goto Borean Tundra,60.2,20.4
>>Click the West Point Station Valve - It looks like a red round handle on the side of the metal pipe
.complete 11907,1
.mob Twonky
>>Kill Twonky
step
.goto Borean Tundra,65.4,17.4
>>Click the North Point Station Valve - It looks like a red round handle on the side of the metal pipe
.complete 11907,2
.mob ED-210
>>Kill ED-210
step
.goto Borean Tundra,76.3,37.2,0.5
.hs >> Hearth to Taunka'le Village
>>Hearth to Taunka'le Village
step
.goto Borean Tundra,75.6,35.8
.target Wind Tamer Barah
.turnin 11706 >> Turn in The Collapse
step
.goto Borean Tundra,77.3,36.9
.target Greatmother Taiga
.turnin 11909 >> Turn in Defeat the Gearmaster
step
.goto Borean Tundra,77.3,38.5
.target Sage Earth and Sky
.turnin 11907 >> Turn in The Sub-Chieftains
step
.fly Amber Ledge, Borean Tundra >> Fly to Amber Ledge
>>Fly to Amber Ledge
step
.goto Borean Tundra,48.4,19.7
.target Grunt Ragefist
.accept 11593 >> Accept The Honored Dead
.accept 11594 >> Accept Put Them to Rest
step
.goto Borean Tundra,47.9,21.3
.use 34692
>>Use Ragefist's Torch on Dead Caravan Guards and Workers
.complete 11593,1
>>Torch 10 Fallen Caravan Guards & Workers
.mob Ghostly Sages and Risen Longrunners
>>Kill Ghostly Sages and Risen Longrunners
.complete 11594,1
>>Lay 20 Taunka spirits to rest
step
.goto Borean Tundra,48.4,19.7
.target Grunt Ragefist
.turnin 11593 >> Turn in The Honored Dead
.turnin 11594 >> Turn in Put Them to Rest
step
.goto Borean Tundra,48.3,19.7
.target Longrunner Proudhoof
.accept 11592 >> Accept We Strike!
step
>>Follow and fight with Longrunner Proudhoof
>>Make sure to keep him alive
.complete 11592,1
>>Successfully assist Longrunner Proudhoof's assault
step
.goto Borean Tundra,43.5,14
.target King Mrgl-Mrgl
.accept 11571 >> Accept Learning to Communicate
step
.goto Borean Tundra,42.5,15.9
>>Go southwest underwater to 42.5,15.9
.mob Scalder
>>Kill Scalder
.use 34598
>>Use The King's Empty Conch on Scalder's corpse
.complete 11571,1
>>Collect The King's Filled Conch
step
.goto Borean Tundra,43.5,14
.target King Mrgl-Mrgl
.turnin 11571 >> Turn in Learning to Communicate
.accept 11559 >> Accept Winterfin Commerce
step
.goto Borean Tundra,41.5,13.4
>>Click Winterfin Clams underwater - They look like small tanish clams on the ground underwater
.complete 11559,1
>>Collect Winterfin Clam
step
.goto Borean Tundra,43,13.8
.target Ahlurglgr
.turnin 11559 >> Turn in Winterfin Commerce
step
.goto Borean Tundra,42.8,13.7
.target Brglmurgl
.accept 11561 >> Accept Them!
step
.goto Borean Tundra,43.5,14
.target King Mrgl-Mrgl
.accept 11560 >> Accept Oh Noes, the Tadpoles!
step
.goto Borean Tundra,40.6,17.5
.complete 11561,1
.mob Winterfin murlocs
>>Kill Winterfin murlocs
>>Click the yellow cages
.complete 11560,1
>>Rescue 20 Winterfin Tadpoles
step
.goto Borean Tundra,42.8,13.7
.target Brglmurgl
.turnin 11561 >> Turn in Them!
step
.goto Borean Tundra,43.5,14
.target King Mrgl-Mrgl
.turnin 11560 >> Turn in Oh Noes, the Tadpoles!
.accept 11562 >> Accept I'm Being Blackmailed By My Cleaner
step
.goto Borean Tundra,42,12.8
.target Mrmrglmr
.turnin 11562 >> Turn in I'm Being Blackmailed By My Cleaner
.accept 11563 >> Accept Grmmurggll Mrllggrl Glrggl!!!
step
.goto Borean Tundra,42,13.2
.target Cleaver Bmurglbrm
.accept 11564 >> Accept Succulent Orca Stew
step
.goto Borean Tundra,40.3,12.4
.mob Glimmer Bay Orcas
>>Kill Glimmer Bay Orcas
.complete 11564,1
>>Collect Succulent Orca Blubber
step
.goto Borean Tundra,37.4,9.8
.mob Glrggl
>>Kill Glrggl
.complete 11563,1
>>Collect Glrggl's Head
step
.goto Borean Tundra,42,12.8
.target Mrmrglmr
.turnin 11563 >> Turn in Grmmurggll Mrllggrl Glrggl!!!
.accept 11565 >> Accept The Spare Suit
step
.goto Borean Tundra,42,13.2
.target Cleaver Bmurglbrm
.turnin 11564 >> Turn in Succulent Orca Stew
step
.goto Borean Tundra,43.5,14
.target King Mrgl-Mrgl
.turnin 11565 >> Turn in The Spare Suit
.accept 11566 >> Accept Surrender... Not!
step
>>Go southwest to Winterfin Village
.use 34620
.aura 45278
>>Use King Mrgl-Mrgl's Spare Suit
step
.goto Borean Tundra,37.8,23.2
>>Go inside the cave to 37.8,23.2
.target Glrglrglr
.accept 11569 >> Accept Keymaster Urmgrgl
step
.goto Borean Tundra,38.4,22.7
>>Go down the path and underneath you to 38.4,22.7
.mob Keymaster Urmgrgl
>>Kill Keymaster Urmgrgl
.complete 11569,1
>>Collect Urmgrgl's Key
step
.goto Borean Tundra,37.6,27.4
>>Follow the path up and to the back of the cave to 37.6,27.4
.mob Claximus
>>Kill Claximus
.complete 11566,1
>>Collect Claw of Claximus
step
.goto Borean Tundra,37.8,23.2
>>Go back up the path to 37.8,23.2
.target Glrglrglr
.turnin 11569 >> Turn in Keymaster Urmgrgl
step
.goto Borean Tundra,37.8,23
.target Lurgglbr
.accept 11570 >> Accept Escape from the Winterfin Caverns
.complete 11570,1
>>Escort Lurgglbr to safety
step
.goto Borean Tundra,43.5,14
.target King Mrgl-Mrgl
.turnin 11566 >> Turn in Surrender... Not!
.turnin 11570 >> Turn in Escape from the Winterfin Caverns
step
.goto Borean Tundra,49.6,11.1
.target Kimbiza
.fp Bor'gorok Outpost, Borean Tundra >> Get the Bor'gorok Outpost flight path
step
.goto Borean Tundra,49.6,10.6
.target Overlord Bor'gorok
.turnin 11592 >> Turn in We Strike!
step
.goto Borean Tundra,50.3,9.7
.target Spirit Talker Snarlfang
.turnin 12486 >> Turn in To Bor'gorok Outpost, Quickly!
.accept 11624 >> Accept The Sky Will Know
step
.goto Borean Tundra,46.6,9.3
.target Imperean
.turnin 11624 >> Turn in The Sky Will Know
.accept 11627 >> Accept Boiling Point
step
.goto Borean Tundra,45.9,13.1
.complete 11627,2
>>Fight Churn until he submits
step
.goto Borean Tundra,50.8,15.5
.complete 11627,1
>>Fight Simmer until he submits
step
.goto Borean Tundra,46.6,9.3
.target Imperean
.turnin 11627 >> Turn in Boiling Point
.accept 11649 >> Accept Motes of the Enraged
step
.goto Borean Tundra,45.2,9.3
.mob Enraged Tempests
>>Kill Enraged Tempests
.complete 11649,1
>>Collect Tempest Mote
step
.goto Borean Tundra,46.6,9.3
.target Imperean
.turnin 11649 >> Turn in Motes of the Enraged
.accept 11629 >> Accept Return to the Spirit Talker
step
.goto Borean Tundra,50.3,9.7
.target Spirit Talker Snarlfang
.turnin 11629 >> Turn in Return to the Spirit Talker
.accept 11631 >> Accept Vision of Air
step
.use 34779
>>Use Imperean's Primal in your bags next to Spirit Talker Snarlfang's Totem
.complete 11631,1
>>Divine Farseer Grimwalker's fate
step
.goto Borean Tundra,50.3,9.7
.target Spirit Talker Snarlfang
.turnin 11631 >> Turn in Vision of Air
.accept 11635 >> Accept Farseer Grimwalker's Spirit
step
.goto Borean Tundra,49.5,10
.target Ortrosh
.accept 11639 >> Accept Revenge Upon Magmoth
step
.goto Borean Tundra,53.8,9.4
.complete 11639,1
.mob Magmoth Shaman
>>Kill Magmoth Shaman
.complete 11639,2
.mob Magmoth Forager
>>Kill Magmoth Forager
.complete 11639,3
.mob Magmoth Crusher
>>Kill Magmoth Crusher
step
.goto Borean Tundra,54.2,13.1
.complete 11639,4
>>Kill 3 Mate of Magmothregar inside this cave
step
.goto Borean Tundra,56.1,9.1
>>Go to the bottom of the cave to 56.1,9.1
.target Farseer Grimwalker's Spirit
.turnin 11635 >> Turn in Farseer Grimwalker's Spirit
.accept 11637 >> Accept Kaganishu
step
.goto Borean Tundra,56.2,12.8
.mob Kaganishu
>>Kill Kaganishu
.complete 11637,2
>>Collect Kaganishu's Fetish
step
.goto Borean Tundra,56.1,9.1
.use 34781
>>Use Kaganishu's Fetish on Farseer Grimwalker's Spirit
.target Farseer Grimwalker's Spirit
.turnin 11637 >> Turn in Kaganishu
.accept 11638 >> Accept Return My Remains
>>Click Farseer Grimwalker's Remains on the ground that you're standing on
.complete 11638,1
>>Collect Farseer Grimwalker's Remains
step
.goto Borean Tundra,49.5,10
>>Leave the cave and go to 49.5,10
.target Ortrosh
.turnin 11639 >> Turn in Revenge Upon Magmoth
step
.goto Borean Tundra,50.3,9.7
.target Spirit Talker Snarlfang
.turnin 11638 >> Turn in Return My Remains
step
.fly Warsong Hold, Borean Tundra >> Fly to Warsong Hold
>>Fly to Warsong Hold
step
.goto Borean Tundra,41.4,53.7
.zone Durotar
>>Ride the zeppelin to Orgrimmar
step
.goto Durotar,50.8,13.8
.zone Tirisfal Glades
>>Ride the zeppelin to Undercity
step
.goto Tirisfal Glades,59.1,59.0
.zone Howling Fjord
>>Ride the zeppelin to Howling Fjord
step
.goto Howling Fjord,78.5,29
>>Go down the zeppelin tower to 78.5,29
.target Apothecary Lysander
.accept 11167 >> Accept The New Plague
step
.goto Howling Fjord,79,29.7
.target Bat Handler Adeline
.fp Vengeance Landing, Howling Fjord >> Get the Vengeance Landing flight path
step
.home Vengeance Landing >> Set your Hearthstone to Vengeance Landing
step
.goto Howling Fjord,79.2,31.2
.target Pontius
.accept 11227 >> Accept Let Them Eat Crow
step
.goto Howling Fjord,78.6,31.2
.target High Executor Anselm
.accept 11270 >> Accept War is Hell
step
.goto Howling Fjord,75.8,31.5
.use 33278
>>Use your Burning Torch on Alliance and Forsaken Corpses
.complete 11270,1
>>Burn 10 Fallen Combatants
.use 33221
>>Use your Plaguehound Cage
.mob Fjord Crows
>>Kill Fjord Crows
.collect 33238,5,11227 >> Collect 5 Crow Meat
.use 33238
>>Click the Crow Meat in your bags
.complete 11227,1
>>Feed your Plaguehound 5 times
step
.goto Howling Fjord,81,35.5
>>Click the Plague Containers - They look like barrels with green stripes on the middle of them. They are on this ship and on the beach
.complete 11167,1
>>Collect Intact Plague Container
step
.goto Howling Fjord,78.6,31.2
.target High Executor Anselm
.turnin 11270 >> Turn in War is Hell
.accept 11221 >> Accept Reports from the Field
step
.goto Howling Fjord,79.2,31.2
.target Pontius
.turnin 11227 >> Turn in Let Them Eat Crow
.accept 11253 >> Accept Sniff Out the Enemy
step
.goto Howling Fjord,78.5,29
.target Apothecary Lysander
.turnin 11167 >> Turn in The New Plague
.accept 11168 >> Accept Spiking the Mix
step
.xp 72
]]);
RXPGuides.RegisterGuide([[
#wotlk
#ac335
#version 1
#group RestedXP WotLK Guide (H)
#subgroup Northrend 70-80
<< Horde
#name 72-74 Northrend
#next 74-76 Northrend
step
.goto Howling Fjord,77.6,34.7
.target Deathstalker Razael
.complete 11221,1
>>Listen to Razael's Report
step
.goto Howling Fjord,79.5,36.2
.target Dark Ranger Lyana
.complete 11221,2
>>Listen to Lyana's Report
step
.goto Howling Fjord,78.6,31.2
.target High Executor Anselm
.turnin 11221 >> Turn in Reports from the Field
.accept 11229 >> Accept The Windrunner Fleet
step
.goto Howling Fjord,79.2,31.2
>>Stand next to Pontius - Standing in front of some dog kennels
.use 33486
>>Use the Plaguehound Leash in your bags
>>Follow the Plaguehound Tracker that spawns
.goto Howling Fjord,76.5,20.1,0.5
>>He leads you to a cave
step
.goto Howling Fjord,75.9,19.7
>>Go inside the cave to 75.9,19.7
>>Click the Dragonskin Scroll - It looks like a opened scroll laying on the ground, next to a bubbling cauldron
.turnin 11253 >> Turn in Sniff Out the Enemy
.accept 11254 >> Accept The Dragonskin Map
step
.goto Howling Fjord,76.9,20
>>Go outside the cave to 76.9,20
.mob Giant Tidecrawlers
>>Kill Giant Tidecrawlers
.complete 11168,1
>>Collect Giant Toxin Gland
step
.goto Howling Fjord,78.5,29
.target Apothecary Lysander
.turnin 11168 >> Turn in Spiking the Mix
.accept 11170 >> Accept Test at Sea
step
.goto Howling Fjord,78.6,31.2
.target High Executor Anselm
.turnin 11254 >> Turn in The Dragonskin Map
.accept 11295 >> Accept The Offensive Begins
step
.goto Howling Fjord,79.1,29.8
.target Bat Handler Camille
>>Tell her you want to intercept the Alliance reinforcements
.use 33349
>>Use the Plague Vials in your bags while flying over the Alliance ships
.complete 11170,1
>>Infect 16 North Fleet Reservists
step
.goto Howling Fjord,78.5,29
.target Apothecary Lysander
.turnin 11170 >> Turn in Test at Sea
.accept 11304 >> Accept New Agamand
step
.goto Howling Fjord,79.1,29.8
.target Bat Handler Camille
.goto Howling Fjord,84.6,36.3,0.5
>>Fly to the Windrunner
step
.goto Howling Fjord,84.7,36.5
.target Captain Harker
.turnin 11229 >> Turn in The Windrunner Fleet
.accept 11230 >> Accept Ambushed!
step
>>Run around on this ship
.complete 11230,1
.mob North Fleet Marine
>>Kill North Fleet Marine
step
.goto Howling Fjord,84.7,36.5
.target Captain Harker
.turnin 11230 >> Turn in Ambushed!
.accept 11232 >> Accept Guide Our Sights
step
.goto Howling Fjord,80.3,38.2
.use 33335
>>Use Cannoneer's Smoke Flare next to the cannon
.complete 11232,1
>>Mark the Eastern Cannon
step
.goto Howling Fjord,79.3,40.1
.use 33335
>>Use Cannoneer's Smoke Flare next to the cannon
.complete 11232,2
>>Mark the Western Cannon
step
.goto Howling Fjord,79.5,36.2
.target Dark Ranger Lyana
.turnin 11232 >> Turn in Guide Our Sights
.accept 11233 >> Accept Landing the Killing Blow
step
.goto Howling Fjord,82.2,40.8
.complete 11233,3
.mob Sergeant Lorric
>>Kill Sergeant Lorric
step
.goto Howling Fjord,81.5,43.4
.complete 11233,1
.mob Captain Olster
>>Kill Captain Olster
step
.goto Howling Fjord,83.2,43.3
.complete 11233,2
.mob Lieutenant Celeyne
>>Kill Lieutenant Celeyne
step
.goto Howling Fjord,83.2,43.2
.target Apothecary Hanes
.accept 11241 >> Accept Trail of Fire
.complete 11241,1
>>Escort Apothecary Hanes to safety
step
.goto Howling Fjord,79.5,36.2
.target Dark Ranger Lyana
.turnin 11233 >> Turn in Landing the Killing Blow
.accept 11234 >> Accept Report to Anselm
step
.goto Howling Fjord,78.6,31.2
.target High Executor Anselm
.turnin 11234 >> Turn in Report to Anselm
step
.goto Howling Fjord,78.5,29
.target Apothecary Lysander
.turnin 11241 >> Turn in Trail of Fire
step
.goto Howling Fjord,71.1,39.1
>>Go southwest up the huge lift to 71.1,39.1
.target Sergeant Gorth
.turnin 11295 >> Turn in The Offensive Begins
.accept 11282 >> Accept A Lesson in Fear
step
.goto Howling Fjord,71.5,39.2
.target Longrunner Nanik
.accept 12566 >> Accept Help for Camp Winterhoof
step
.goto Howling Fjord,69.1,38.5
.mob Winterskorn Defenders close around this area
>>Kill Winterskorn Defenders close around this area
>>Oric the Baleful will spawn here - You will see them yell in red text in your chat
.mob Oric the Baleful
>>Kill Oric the Baleful
.use 33563
>>Use your Forsaken Banner on his corpse
.complete 11282,1
>>Impale Oric the Baleful
step
.goto Howling Fjord,69.6,40.1
.mob Winterskorn Defenders close around this area
>>Kill Winterskorn Defenders close around this area
>>Gunnar Thorvardsson will spawn here - You will see them yell in red text in your chat
.mob Gunnar Thorvardsson
>>Kill Gunnar Thorvardsson
.use 33563
>>Use your Forsaken Banner on his corpse
.complete 11282,3
>>Impale Gunnar Thorvardsson
step
.goto Howling Fjord,69.4,39.5
.mob Winterskorn Defenders close around this area
>>Kill Winterskorn Defenders close around this area
>>Ulf the Bloodletter will spawn here - You will see them yell in red text in your chat
.mob Ulf the Bloodletter
>>Kill Ulf the Bloodletter
.use 33563
>>Use your Forsaken Banner on his corpse
.complete 11282,2
>>Impale Ulf the Bloodletter
step
.goto Howling Fjord,71.1,39.1
.target Sergeant Gorth
.turnin 11282 >> Turn in A Lesson in Fear
.accept 11285 >> Accept Baleheim Must Burn!
.accept 11283 >> Accept Baleheim Bodycount
step
.goto Howling Fjord,66.7,39.8
.use 33472
>>Use Gorth's Torch while standing next to this tower
.complete 11285,2
>>Burn the Winterskorn Watchtower
step
.goto Howling Fjord,66.2,39.6
.use 33472
>>Use Gorth's Torch while standing next to this bridge
.complete 11285,3
>>Burn the Winterskorn Bridge
step
.goto Howling Fjord,63.8,40
.use 33472
>>Use Gorth's Torch while standing next to this building
.complete 11285,4
>>Burn the Winterskorn Barracks
step
.goto Howling Fjord,64.9,40.9
.use 33472
>>Use Gorth's Torch while standing next to this building
.complete 11285,1
>>Burn the Winterskorn Dwelling
step
>>Kill Winterskorn Vrykuls all around this town
.complete 11283,1
>>Collect Baleheim Bodycount to 16
step
.goto Howling Fjord,71.1,39.1
.target Sergeant Gorth
.turnin 11283 >> Turn in Baleheim Bodycount
.turnin 11285 >> Turn in Baleheim Must Burn!
.accept 11303 >> Accept The Ambush
step
.goto Howling Fjord,65.9,36.8
.target Lydell
.turnin 11303 >> Turn in The Ambush
.accept 12481 >> Accept Adding Injury to Insult
step
.goto Howling Fjord,64.2,38.8
.use 33581
>>Use your Vrykul Insult on Bjorn Halgurdsson
.complete 12481,1
>>Insult Bjorn Halgurdsson
step
.goto Howling Fjord,65.9,36.8
>>RUN BACK TO LYDELL - Next to a huge cart
.complete 12481,2
>>Defeat Bjorn Halgurdsson
step
.goto Howling Fjord,65.9,36.8
.target Lydell
.turnin 12481 >> Turn in Adding Injury to Insult
step
.goto Howling Fjord,67.4,60.6
.target Ranger Captain Areiel
.accept 12482 >> Accept Against Nifflevar
step
.goto Howling Fjord,67.3,60.3
.target Scribe Seguine
.accept 11423 >> Accept The Enemy's Legacy
step
.goto Howling Fjord,69.6,57.1
.complete 12482,1
.mob Dragonflayer Warrior
>>Kill Dragonflayer Warrior
.complete 12482,2
.mob Dragonflayer Rune-Seer
>>Kill Dragonflayer Rune-Seer
.complete 12482,3
.mob Dragonflayer Hunting Hound
>>Kill Dragonflayer Hunting Hound
step
.goto Howling Fjord,67.4,57.2
>>Click the Saga of the Val'kyr - It's a scroll inside this building, sitting on the floor on a red rug
.complete 11423,2
>>Collect Saga of the Val'kyr
step
.goto Howling Fjord,68.9,52.6
>>Click the Saga of the Winter Curse - It's a scroll inside this building, sitting on the floor in the back of the room next to the wall
.complete 11423,3
>>Collect Saga of the Winter Curse
step
.goto Howling Fjord,64.7,53.6
>>Click the Saga of the Twins - It's a scroll inside this building, on the top floor, in the very back next to the wall
.complete 11423,1
>>Collect Saga of the Twins
step
.goto Howling Fjord,67.4,60.6
.target Ranger Captain Areiel
.turnin 12482 >> Turn in Against Nifflevar
step
.goto Howling Fjord,67.3,60.3
.target Scribe Seguine
.turnin 11423 >> Turn in The Enemy's Legacy
step
.goto Howling Fjord,53.6,66.4
.target Chief Plaguebringer Harris
.turnin 11304 >> Turn in New Agamand
.accept 11305 >> Accept A Tailor-Made Formula
step
.goto Howling Fjord,53.7,65.2
.target "Hacksaw" Jenny
.accept 11424 >> Accept Shield Hill
step
.goto Howling Fjord,53.1,66.9
.target Plaguebringer Tillinghast
.accept 11279 >> Accept Green Eggs and Whelps
step
.home New Agamand >> Set your Hearthstone to New Agamand
step
.goto Howling Fjord,52,67.4
.target Tobias Sarkhoff
.fp New Agamand, Howling Fjord >> Get the New Agamand flight path
step
.goto Howling Fjord,57.6,76.5
.mob Risen Vrykul Ancestors
>>Kill Risen Vrykul Ancestors
.complete 11424,1
>>Collect Ancient Vrykul Bone
step
.goto Howling Fjord,46.8,68.1
.mob Thorvald
>>Kill Thorvald
.complete 11305,1
>>Collect Dragonflayer Patriarch's Blood
step
.goto Howling Fjord,40.3,60.3
.target Orfus of Kamagua
.accept 11504 >> Accept The Dead Rise!
step
.goto Howling Fjord,42,54.4
.use 33418
>>Use Tillinghast's Plague Canister on Proto-Drake Eggs
.mob Plagued Proto-Whelps that spawn
>>Kill Plagued Proto-Whelps that spawn
.complete 11279,1
>>Collect Plagued Proto-Whelp Specimen
step
.goto Howling Fjord,37.4,51.9
.target Ember Clutch Ancient
.accept 11182 >> Accept Root Causes
step
.goto Howling Fjord,40.6,51.5
.complete 11182,1
.mob Dragonflayer Handler
>>Kill Dragonflayer Handler
step
.goto Howling Fjord,41.5,52.3
.complete 11182,2
.mob Skeld Drakeson
>>Kill Skeld Drakeson
step
.goto Howling Fjord,37.4,51.9
.target Ember Clutch Ancient
.turnin 11182 >> Turn in Root Causes
step
.goto Howling Fjord,52.2,66.5,0.5
.hs >> Hearth to New Agamand
>>Hearth to New Agamand
step
.goto Howling Fjord,53.1,66.9
.target Plaguebringer Tillinghast
.turnin 11279 >> Turn in Green Eggs and Whelps
.accept 11280 >> Accept Draconis Gastritis
step
.goto Howling Fjord,53.7,65.2
.target "Hacksaw" Jenny
.turnin 11424 >> Turn in Shield Hill
step
.goto Howling Fjord,53.6,66.4
.target Chief Plaguebringer Harris
.turnin 11305 >> Turn in A Tailor-Made Formula
.accept 11306 >> Accept Apply Heat and Stir
step
.goto Howling Fjord,53.6,66.5
>>Stand next to the cauldron
.use 34023
>>Use the Empty Apothecary's Flask in your bags
.collect 33615,1,11306 >> Collect 1 Flask of Vrykul Blood
>>Stand next to the table at 53.5,66.3
.use 33615
>>Use the Flask of Vrykul Blood in your bags
.use 33614
>>Keep filling the Empty Apothecary's Flasks at the cauldron
.use 33615
>>And then use the Flask of Vrykul Blood next to the table
.complete 11306,1
>>Collect Balanced Concoction
step
.goto Howling Fjord,53.6,66.4
.target Chief Plaguebringer Harris
.turnin 11306 >> Turn in Apply Heat and Stir
.accept 11307 >> Accept Field Test
step
.goto Howling Fjord,57.7,77.5
>>Click the Mound of Debris - It looks like a pile of dirt in the bottom of this small pit, next to a skeleton
.complete 11504,1
>>Collect Fengir's Clue
step
.goto Howling Fjord,59.2,77
>>Click the Unlocked Chest - It looks like a small chest in the bottom of this small pit, next to a skeleton
.complete 11504,2
>>Collect Rodin's Clue
step
.goto Howling Fjord,59.8,79.4
>>Click the Long Tail Feather - It's a small blue feather sitting on a circular shield in this pit, on top of a skeleton
.complete 11504,3
>>Collect Isuldof's Clue
step
.goto Howling Fjord,62,80
>>Click the Cannonball - It looks like a big round grey ball sitting in the dirt in this pit, between a skeleton's legs
.complete 11504,4
>>Collect Windan's Clue
step
.goto Howling Fjord,48.5,57.4
.use 33621
>>Use your Plague Spray on Plagued Dragonflayer mobs
.complete 11307,1
>>Spray 10 Plagued Vrykul
step
.goto Howling Fjord,40.3,60.3
.target Orfus of Kamagua
.turnin 11504 >> Turn in The Dead Rise!
.accept 11507 >> Accept Elder Atuik and Kamagua
step
.goto Howling Fjord,41.7,53.7
.use 33441
>>Use Tillinghast's Plagued Meat in your bags when a Proto-Drake is flying over you
.mob Proto-Drake
>>Kill Proto-Drake
.complete 11280,1
>>Observe the Proto-Drake Plague Results
step
.goto Howling Fjord,53.1,66.9
.target Plaguebringer Tillinghast
.turnin 11280 >> Turn in Draconis Gastritis
step
.goto Howling Fjord,53.6,66.4
.target Chief Plaguebringer Harris
.turnin 11307 >> Turn in Field Test
.accept 11308 >> Accept Time for Cleanup
step
.goto Howling Fjord,53.7,65.2
.target "Hacksaw" Jenny
.turnin 11308 >> Turn in Time for Cleanup
.accept 11309 >> Accept Parts for the Job
step
.goto Howling Fjord,50.3,65.8
.mob Shoveltusks
>>Kill Shoveltusks
.complete 11309,1
>>Collect Shoveltusk Ligament
step
.goto Howling Fjord,49.4,74.3
.target Anton
.complete 11309,2
>>Buy buy 1 Fresh Pound of Flesh
step
.goto Howling Fjord,53.7,65.2
.target "Hacksaw" Jenny
.turnin 11309 >> Turn in Parts for the Job
.accept 11310 >> Accept Warning: Some Assembly Required
step
.goto Howling Fjord,49.6,57.2
.use 33613
>>Use your Abomination Assembly Kit to control the Mindless Abomination
>>Run around and gather a bunch of Plagued Dragonflayer mobs
.macro Plagued Blood Explosion,134400 >>/cast Plagued Blood Explosion
>>Use your Plagued Blood Explosion to explode the group of mobs
.complete 11310,1
>>Exterminate 20 Plagued Vrykul
step
.goto Howling Fjord,53.7,65.2
.target "Hacksaw" Jenny
.turnin 11310 >> Turn in Warning: Some Assembly Required
step
.goto Howling Fjord,25.0,57.0
>>Go northwest across the Ancient Lift to 25.0,57.0
.target Elder Atuik
.turnin 11507 >> Turn in Elder Atuik and Kamagua
.accept 11508 >> Accept Grezzix Spindlesnap
.accept 11456 >> Accept Feeding the Survivors
step
.goto Howling Fjord,24.7,57.8
.target Kip Trawlskip
.fp Kamagua, Howling Fjord >> Get the Kamagua flight path
step
.goto Howling Fjord,29.1,58.8
.mob Island Shoveltusks
>>Kill Island Shoveltusks
.complete 11456,1
>>Collect Island Shoveltusk Meat
step
.goto Howling Fjord,25.0,57.0
.target Elder Atuik
.turnin 11456 >> Turn in Feeding the Survivors
.accept 11457 >> Accept Arming Kamagua
step
.goto Howling Fjord,26.4,62.9
.mob Frostwing Chimaeras
>>Kill Frostwing Chimaeras
.complete 11457,1
>>Collect Chimaera Horn
step
.goto Howling Fjord,25.0,57.0
.target Elder Atuik
.turnin 11457 >> Turn in Arming Kamagua
.accept 11458 >> Accept Avenge Iskaal
step
.goto Howling Fjord,23.1,62.7
.target Grezzix Spindlesnap
.turnin 11508 >> Turn in Grezzix Spindlesnap
.accept 11509 >> Accept Street "Cred"
step
.goto Howling Fjord,35.1,80.9
.target "Silvermoon" Harry
.turnin 11509 >> Turn in Street "Cred"
.accept 11510 >> Accept "Scoodles"
step
.goto Howling Fjord,35.6,80.2
.target Handsome Terry
.accept 11434 >> Accept Forgotten Treasure
step
.goto Howling Fjord,37.8,79.6
.target Scuttle Frostprow
.accept 11469 >> Accept Swabbin' Soap
step
.goto Howling Fjord,38.3,83.4
.mob "Scoodles"
>>Kill "Scoodles"
.complete 11510,1
>>Collect Sin'dorei Scrying Crystal
step
.goto Howling Fjord,37.8,84.6
>>Click the Eagle Figurine - It's a blue eagle statue inside this ship on the middle floor
.complete 11434,2
>>Collect Eagle Figurine
step
.goto Howling Fjord,37.1,85.5
>>Click the Amani Vase - It looks like a grey vase at the bottom of this wrecked ship
.complete 11434,1
>>Collect Amani Vase
step
.goto Howling Fjord,31.4,77.9
.mob Big Roy
>>Kill Big Roy
.complete 11469,1
>>Collect Big Roy's Blubber
step
.goto Howling Fjord,35.1,80.9
.target "Silvermoon" Harry
.turnin 11510 >> Turn in "Scoodles"
.accept 11567 >> Accept The Ancient Armor of the Kvaldir
.accept 11512 >> Accept The Frozen Heart of Isuldof
.accept 11519 >> Accept The Lost Shield of the Aesirites
.accept 11511 >> Accept The Staff of Storm's Fury
step
.goto Howling Fjord,35.6,80.2
.target Handsome Terry
.turnin 11434 >> Turn in Forgotten Treasure
.accept 11455 >> Accept The Fragrance of Money
step
.goto Howling Fjord,36.3,80.5
.target Taruk
.accept 11464 >> Accept Gambling Debt
step
.goto Howling Fjord,35.1,80.9
.target "Silvermoon" Harry
>>Tell him to pay up
>>Fight him until he surrenders
.complete 11464,1
>>Collect "Silvermoon" Harry's Debt
step
.goto Howling Fjord,36.3,80.5
.target Taruk
.turnin 11464 >> Turn in Gambling Debt
.accept 11466 >> Accept Jack Likes His Drink
step
.goto Howling Fjord,35.3,79.6
>>Go inside the long building to 35.3,79.6
.target Olga, the Scalawag Wench
>>Pay 1 gold to bribe her into giving Jack Adams a drink
>>He passes out on the table
.target Jack Adams
>>Search his pockets
.complete 11466,1
>>Collect Jack Adams' Debt
step
.goto Howling Fjord,36.3,80.5
.target Taruk
.turnin 11466 >> Turn in Jack Likes His Drink
.accept 11467 >> Accept Dead Man's Debt
step
.goto Howling Fjord,37.8,79.6
.target Scuttle Frostprow
.turnin 11469 >> Turn in Swabbin' Soap
step
.goto Howling Fjord,37.2,74.8
.target Captain Ellis
.turnin 11519 >> Turn in The Lost Shield of the Aesirites
.accept 11527 >> Accept Mutiny on the Mercy
step
>>Go downstairs in the ship
.mob Mutinous Sea Dog ghouls
>>Kill Mutinous Sea Dog ghouls
.complete 11527,1
>>Collect Barrel of Blasting Powder
step
.goto Howling Fjord,37.2,74.8
>>Go upstairs to the ship deck to 37.2,74.8
.target Captain Ellis
.turnin 11527 >> Turn in Mutiny on the Mercy
.accept 11529 >> Accept Sorlof's Booty
step
>>Run to the other end of the ship deck to the big cannon
>>Keep clicking The Big Gun until Sorlof is dead
>>Sorlof will drop a big pile of gold on the shore
>>Jump off the ship and click Sorlof's Booty
.complete 11529,1
>>Collect Sorlof's Booty
step
.goto Howling Fjord,37.2,74.8
.target Captain Ellis
.turnin 11529 >> Turn in Sorlof's Booty
.accept 11530 >> Accept The Shield of the Aesirites
step
.goto Howling Fjord,34.1,76.9
.mob Rabid Brown Bears
>>Kill Rabid Brown Bears
.complete 11455,1
>>Collect Bear Musk
step
.goto Howling Fjord,33.5,75.4,0.5
>>Go down into the cave to 33.5,75.4
step
.goto Howling Fjord,32.3,78.7
>>Go down the hill and into the cave to 32.3,78.7
>>Hug the wall to the left inside the cave to avoid fighting "Mad" Jonah Sterling
>>Follow the path around past the big white sleeping bear, he won't attack you if he's asleep
>>Click The Frozen Heart of Isuldof - Inside the cave, it looks like a big blue jewel on the ground
.complete 11512,1
>>Collect The Frozen Heart of Isuldof
step
.goto Howling Fjord,33.2,63.9
>>Leave the cave and go north to 33.2,63.9
.complete 11458,1
.mob Crazed Northsea Slaver
>>Kill Crazed Northsea Slaver
step
.goto Howling Fjord,35.3,64.8
>>Go onto the ship to 35.3,64.8
>>Wait for Abdul the Insane to walk up to the top deck, then run downstairs
>>Click The Staff of Storm's Fury - On the very bottom floor of this ship. It looks like a staff standing upright with lightning shooting out of it
.complete 11511,1
>>Collect The Staff of Storm's Fury
step
.goto Howling Fjord,29.0,60.5
.goto Howling Fjord,29.0,60.5,0.3
>>The path up to Dead Man's Debt starts here
step
.goto Howling Fjord,32.7,60.2
>>Click the Dirt Mound - It looks like a big pile of dirt
>>Kill Black Conrad's Ghost and his friends that spawn
.complete 11467,1
>>Collect Black Conrad's Treasure
step
.goto Howling Fjord,25.0,57.0
.target Elder Atuik
.turnin 11458 >> Turn in Avenge Iskaal
step
.goto Howling Fjord,24.6,58.9
.target Anuniaq
.accept 11472 >> Accept The Way to His Heart...
step
.goto Howling Fjord,28.9,74.8
.use 40946
>>Use Anuniaq's Net on the Schools of Tasty Reef Fish
.mob Great Reef Sharks
>>Kill Great Reef Sharks
.collect 34127,10,11472 >> Collect 10 Tasty Reef Fish
step
.goto Howling Fjord,31,74.4
.use 34127
>>Use your Tasty Reef Fish on a Reef Bull as far away as you can
>>He will come to the spot where you're standing
>>Keep doing this - The goal is to lead the Reef Bull to the other side of the water to a Reef Cow
.complete 11472,1
>>Lead the Reef Bull to a Reef Cow on the other side of the water
step
.goto Howling Fjord,35.6,80.2
.target Handsome Terry
.turnin 11455 >> Turn in The Fragrance of Money
.accept 11473 >> Accept A Traitor Among Us
step
.goto Howling Fjord,35.6,80.6
.target Zeh'gehn
.turnin 11473 >> Turn in A Traitor Among Us
.accept 11459 >> Accept Zeh'gehn Sez
step
.goto Howling Fjord,35.6,80.2
.target Handsome Terry
.turnin 11459 >> Turn in Zeh'gehn Sez
.accept 11476 >> Accept A Carver and a Croaker
step
.goto Howling Fjord,35.1,80.9
.target "Silvermoon" Harry
.complete 11476,2
>>Buy buy 1 Shiny Knife
step
.goto Howling Fjord,35.6,81.7
>>Click a Scalawag Frog - They are blue and green frogs that hop around on the ground here
.complete 11476,1
>>Collect Scalawag Frog
step
.goto Howling Fjord,35.6,80.6
.target Zeh'gehn
.turnin 11476 >> Turn in A Carver and a Croaker
.accept 11479 >> Accept "Crowleg" Dan
step
.goto Howling Fjord,36.3,80.5
.target Taruk
.turnin 11467 >> Turn in Dead Man's Debt
step
.goto Howling Fjord,35.9,83.6
.target "Crowleg" Dan
.complete 11479,1
.mob "Crowleg" Dan
>>Kill "Crowleg" Dan
step
.goto Howling Fjord,35.6,80.2
.target Handsome Terry
.turnin 11479 >> Turn in "Crowleg" Dan
.accept 11480 >> Accept Meet Number Two
step
.goto Howling Fjord,35.4,79.4
>>Go inside the long building to 35.4,79.4
.target Annie Bonn
.turnin 11480 >> Turn in Meet Number Two
step
.goto Howling Fjord,36.1,81.6
.target Alanya
>>Tell her to want to fly to Bael'gun's
.goto Howling Fjord,80.9,75.1,0.3
>>You will land near a ship
step
.goto Howling Fjord,81.8,73.9
>>Go onto the ship and downstairs to 81.8,73.9
>>Click The Ancient Armor of the Kvaldir - Inside this ship, on the very bottom floor in the very back of the room. It looks like a floating chestplate
.complete 11567,1
>>Collect The Ancient Armor of the Kvaldir
step
.goto Howling Fjord,80.9,75.1
>>Click Harry's Bomber - It's a plane on the water's edge
.goto Howling Fjord,36.1,81.7,0.3
>>Go back to Scalawag Point
step
.goto Howling Fjord,40.3,60.3
>>Ride the big lift to the top of the cliff and go to 40.3,60.3
.target Orfus of Kamagua
.turnin 11567 >> Turn in The Ancient Armor of the Kvaldir
.turnin 11512 >> Turn in The Frozen Heart of Isuldof
.turnin 11530 >> Turn in The Shield of the Aesirites
.turnin 11511 >> Turn in The Staff of Storm's Fury
.accept 11568 >> Accept A Return to Resting
step
.goto Howling Fjord,57.6,77.4
.use 34624
>>Use your Bundle of Vrykul Artifacts while standing near the skeleton
.complete 11568,1
>>Return the Shield of Aesirites
step
.goto Howling Fjord,59.2,77
.use 34624
>>Use your Bundle of Vrykul Artifacts while standing near the skeleton
.complete 11568,2
>>Return the Staff of Storm's Fury
step
.goto Howling Fjord,59.7,79.4
.use 34624
>>Use your Bundle of Vrykul Artifacts while standing near the skeleton
.complete 11568,3
>>Return the Frozen Heart of Isuldof
step
.goto Howling Fjord,61.9,80.2
.use 34624
>>Use your Bundle of Vrykul Artifacts while standing near the skeleton
.complete 11568,4
>>Return the Ancient Armor of the Kvaldir
step
.goto Howling Fjord,40.3,60.3
.target Orfus of Kamagua
.turnin 11568 >> Turn in A Return to Resting
.accept 11572 >> Accept Return to Atuik
step
.goto Howling Fjord,25.0,57.0
>>Go across the Ancient Lift to 25.0,57.0
.target Elder Atuik
.turnin 11572 >> Turn in Return to Atuik
step
.goto Howling Fjord,24.6,58.9
.target Anuniaq
.turnin 11472 >> Turn in The Way to His Heart...
step
.goto Howling Fjord,31.3,24.4
>>Go back across the Ancient Lift and north to 31.3,24.4
.target Longrunner Skycloud
.accept 11296 >> Accept Rivenwood Captives
step
.goto Howling Fjord,31.2,24.5
.target Sage Mistwalker
.accept 11286 >> Accept The Artifacts of Steel Gate
step
.goto Howling Fjord,31.1,20.9
>>Attack Riven Widow Cocoons - They look like big squirming white cocoons
.complete 11296,1
>>Free 7 Winterhoof Longrunners
step
.goto Howling Fjord,31.3,24.4
.target Longrunner Skycloud
.turnin 11296 >> Turn in Rivenwood Captives
step
.goto Howling Fjord,31.8,25.6
>>Click the Steel Gate Artifacts - They look like big broken stone tablet pieces laying on the ground around this area
.complete 11286,1
>>Collect Steel Gate Artifact
step
.goto Howling Fjord,31.2,24.5
>>Go back up the hill to 31.2,24.5
.target Sage Mistwalker
.turnin 11286 >> Turn in The Artifacts of Steel Gate
.accept 11317 >> Accept The Cleansing
step
.goto Howling Fjord,26,25.1
.target Lilleth Radescu
.fp Apothecary Camp, Howling Fjord >> Get the Apothecary Camp flight path
step
.goto Howling Fjord,26.1,24.7
.target Apothecary Anastasia
.accept 11397 >> Accept And You Thought Murlocs Smelled Bad!
step
.goto Howling Fjord,26,24.4
.target Apothecary Grick
.accept 11301 >> Accept Brains! Brains! Brains!
step
.goto Howling Fjord,26.4,24.5
.target Apothecary Malthus
.accept 11298 >> Accept What's in That Brew?
step
.goto Howling Fjord,33.8,33.7
.goto Howling Fjord,33.8,33.7,0.5
>>The path down to Brains! Brains! Brains! and What's in That Brew? starts here
step
.goto Howling Fjord,33.3,36.5
>>Go down the hill to 33.3,36.5
>>Click the Dwarven Kegs - They look like huge barrels sitting on the ground around this area
.complete 11298,1
>>Collect Dwarven Keg
.mob Deranged Explorers all around this area
>>Kill Deranged Explorers all around this area
.use 33554
>>Use Grick's Bonesaw on their corpses
.complete 11301,1
>>Collect Deranged Explorer Brain
step
.goto Howling Fjord,26.4,24.5
.target Apothecary Malthus
.turnin 11298 >> Turn in What's in That Brew?
step
.goto Howling Fjord,26,24.4
.target Apothecary Grick
.turnin 11301 >> Turn in Brains! Brains! Brains!
step
.goto Howling Fjord,25.5,20.1
.goto Howling Fjord,25.5,20.1,0.3
>>The path down to the coast starts here
step
.goto Howling Fjord,23,21.9
>>Go down the path to 23,21.9
.mob undead murlocs and other mobs
>>Kill undead murlocs and other mobs
.complete 11397,1
>>Kill 15 Chillmere Coast Scourge
.mob undead mobs
>>Kill undead mobs
>>Collect a Scourge Device
.use 33962
>>Click the Scourge Device
.accept 11398 >> Accept It's a Scourge Device
step
.goto Howling Fjord,19.8,22.2
.target Old Icefin
.accept 11422 >> Accept Trident of the Son
step
.goto Howling Fjord,23.7,35.2
.mob Rotgill
>>Kill Rotgill
.complete 11422,1
>>Collect Rotgill's Trident
step
.goto Howling Fjord,19.8,22.2
.target Old Icefin
.turnin 11422 >> Turn in Trident of the Son
step
.goto Howling Fjord,23.7,21.8
.goto Howling Fjord,23.7,21.8
>>The path back up from the coast starts here
step
.goto Howling Fjord,26.1,24.7
>>Go up the path and south to 26.1,24.7
.target Apothecary Anastasia
.turnin 11397 >> Turn in And You Thought Murlocs Smelled Bad!
.turnin 11398 >> Turn in It's a Scourge Device
.accept 11399 >> Accept Bring Down Those Shields
step
.xp 73
step
.goto Howling Fjord,25.5,20.1
.goto Howling Fjord,25.5,20.1,0.3
>>The path down to the coast starts here
step
.goto Howling Fjord,22.9,20.1
>>Go down the path to 22.9,20.1
.use 33960
>>Use your Scourging Crystal Controller on the Scourge Crystal
>>Attack the Scourge Crystal when the purple bubble shield disappears
.complete 11399,1
>>Destroy 1 Scourge Crystal
step
.goto Howling Fjord,22.6,17.6
.use 33960
>>Use your Scourging Crystal Controller on the Scourge Crystal
>>Attack the Scourge Crystal when the purple bubble shield disappears
.complete 11399,1
>>Destroy 1 Scourge Crystal
step
.goto Howling Fjord,21.8,22.5
.use 33960
>>Use your Scourging Crystal Controller on the Scourge Crystal
>>Attack the Scourge Crystal when the purple bubble shield disappears
.complete 11399,1
>>Destroy 1 Scourge Crystal
step
.goto Howling Fjord,23.7,21.8
.goto Howling Fjord,23.7,21.8
>>The path back up from the coast starts here
step
.goto Howling Fjord,26.1,24.7
>>Go up the path and south to 26.1,24.7
.target Apothecary Anastasia
.turnin 11399 >> Turn in Bring Down Those Shields
step
.goto Howling Fjord,49.3,12
.target Nokoma Snowseer
.accept 11275 >> Accept Making the Horn
step
.goto Howling Fjord,49.6,11.6
.target Celea Frozenmane
.fp Camp Winterhoof, Howling Fjord >> Get the Camp Winterhoof flight path
step
.goto Howling Fjord,48.4,11
.target Ahota Whitefrost
.accept 11271 >> Accept Hasty Preparations
step
.goto Howling Fjord,48,10.7
.target Chieftain Ashtotem
.turnin 12566 >> Turn in Help for Camp Winterhoof
step
.goto Howling Fjord,50.9,11
>>Click Spotted Hippogryph Down feathers on the ground - They look like brown feathers on the ground all around this area
.complete 11271,1
>>Collect Spotted Hippogryph Down
.mob Frosthorn Rams
>>Kill Frosthorn Rams
.complete 11275,1
>>Collect Undamaged Ram Horn
step
.goto Howling Fjord,48.4,11
.target Ahota Whitefrost
.turnin 11271 >> Turn in Hasty Preparations
step
.goto Howling Fjord,49.3,12
.target Nokoma Snowseer
.turnin 11275 >> Turn in Making the Horn
.accept 11281 >> Accept Mimicking Nature's Call
.accept 11312 >> Accept The Frozen Glade
step
.goto Howling Fjord,48.9,12
.target Wind Tamer Kagan
.accept 11311 >> Accept Suppressing the Elements
step
.goto Howling Fjord,52.5,6.5
>>Kill Iceshard Elementals
.complete 11311,1
.mob Mountain Elementals
>>Kill Mountain Elementals
>>You can find more Iceshard Elementals at 51.2,2.9
step
.goto Howling Fjord,48.9,12
.target Wind Tamer Kagan
.turnin 11311 >> Turn in Suppressing the Elements
step
.goto Howling Fjord,49.2,12.2
.target Longrunner Pembe
.accept 11350 >> Accept The Book of Runes
step
.goto Howling Fjord,52.4,3.7
.use 33450
>>Use your Carved Horn next to the Frozen Waterfall
.mob Frostgore that spawns
>>Kill Frostgore that spawns
.complete 11281,1
>>Test Nokoma's Horn
step
.goto Howling Fjord,54.1,8.2
.goto Howling Fjord,54.1,8.2,0.3
>>The path up to The Cleansing starts here
step
.goto Howling Fjord,61.1,2
>>Follow the path up to 61.1,2
>>Click the Frostblade Shrine - It's a big blue glowing altar table thing
.complete 11317,1
>>Kill Your Inner Turmoil that spawns
step
.goto Howling Fjord,61.5,22.8
.target Lurielle
.turnin 11312 >> Turn in The Frozen Glade
.accept 11313 >> Accept Spirits of the Ice
step
.goto Howling Fjord,60.6,22.4
.mob Ice Elementals
>>Kill Ice Elementals
.complete 11313,1
>>Collect Icy Core
step
.goto Howling Fjord,61.5,22.8
.target Lurielle
.turnin 11313 >> Turn in Spirits of the Ice
.accept 11314 >> Accept The Fallen Sisters
.accept 11315 >> Accept Wild Vines
step
.goto Howling Fjord,53.3,27.8
.use 33606
>>Use Lurielle's Pendant on Chill Nymphs when they are weak
.complete 11314,1
>>Free 7 Chill Nymphs
.complete 11315,1
.mob Scarlet Ivy
>>Kill Scarlet Ivy
step
.goto Howling Fjord,61.5,22.8
.target Lurielle
.turnin 11314 >> Turn in The Fallen Sisters
.turnin 11315 >> Turn in Wild Vines
.accept 11316 >> Accept Spawn of the Twisted Glade
.accept 11319 >> Accept Seeds of the Blacksouled Keepers
step
.goto Howling Fjord,54.7,20.5
.complete 11316,1
.mob Thornvine Creeper
>>Kill Thornvine Creeper
.mob Spores
>>Kill Spores
.use 33607
>>Use your Enchanted Ice Core on Spore corpses
.complete 11319,1
>>Freeze 8 Spores
step
.goto Howling Fjord,61.5,22.8
.target Lurielle
.turnin 11316 >> Turn in Spawn of the Twisted Glade
.turnin 11319 >> Turn in Seeds of the Blacksouled Keepers
.accept 11428 >> Accept Keeper Witherleaf
step
.goto Howling Fjord,53.7,18.6
.complete 11428,1
.mob Keeper Witherleaf
>>Kill Keeper Witherleaf
step
.goto Howling Fjord,61.5,22.8
.target Lurielle
.turnin 11428 >> Turn in Keeper Witherleaf
step
.goto Howling Fjord,65.0,28.5
.mob Iron Rune Stonecallers and Iron Rune Binders
>>Kill Iron Rune Stonecallers and Iron Rune Binders
.collect 33778,1,11350 >> Collect 1 Book of Runes - Chapter 1
.collect 33779,1,11350 >> Collect 1 Book of Runes - Chapter 2
.collect 33780,1,11350 >> Collect 1 Book of Runes - Chapter 3
.use 33778
>>Click a Book of Runes - Chapter in your bags
.complete 11350,1
>>Collect The Book of Runes
step
.goto Howling Fjord,49.2,12.2
.target Longrunner Pembe
.turnin 11350 >> Turn in The Book of Runes
.accept 11351 >> Accept Mastering the Runes
step
.goto Howling Fjord,49.3,12
.target Nokoma Snowseer
.turnin 11281 >> Turn in Mimicking Nature's Call
step
.goto Howling Fjord,48,10.7
.target Chieftain Ashtotem
.accept 11256 >> Accept Skorn Must Fall!
step
.goto Howling Fjord,71.2,28.7
>>Click the Iron Rune Carving Tools - It looks like a small metal chest
.complete 11351,1
>>Collect Iron Rune Carving Tools
>>If they are not there, they can also spawn at the following 5 locations as well:
>>At 67.5,23.5
>>At 69.1,22.8
>>At 72.4,17.8
>>At 73.4,24.9
>>At 67.5,29.2
step
.goto Howling Fjord,49.2,12.2
.target Longrunner Pembe
.turnin 11351 >> Turn in Mastering the Runes
.accept 11352 >> Accept The Rune of Command
step
.goto Howling Fjord,71.9,24.6
.use 33796
>>Use your Rune of Command on a Stone Giant around this area to control it
>>Once you are controlling the Stone Giant, come here
.complete 11352,2
.mob Binder Murdis
>>Kill Binder Murdis
step
.goto Howling Fjord,49.2,12.2
.target Longrunner Pembe
.turnin 11352 >> Turn in The Rune of Command
step
.goto Howling Fjord,44.4,26.2
.use 33340
>>Use your Winterhoof Emblem in your bags
.target Winterhoof Brave
.turnin 11256 >> Turn in Skorn Must Fall!
.accept 11257 >> Accept Gruesome, But Necessary
.accept 11258 >> Accept Burn Skorn, Burn!
.accept 11259 >> Accept Towers of Certain Doom
step
.goto Howling Fjord,45.3,27
.mob Winterskorn mobs
>>Kill Winterskorn mobs
.use 33342
>>Use The Brave's Machete on their corpses
.complete 11257,1
>>Dismember 20 Winterskorn Vrykul
>>Collect Vrykul Scroll of Ascension
.use 33345
>>Click the Vrykul Scroll of Ascension in your bags
.accept 11260 >> Accept Stop the Ascension!
step
.goto Howling Fjord,43.7,28.5
.use 33343
>>Use the Brave's Torch inside this house
.complete 11258,1
>>Set the Northwest Longhouse Ablaze
step
.goto Howling Fjord,43.6,30.3
.use 33344
>>Use the Brave's Flare next to this tower
.complete 11259,1
>>Target the Northwest Tower
step
.goto Howling Fjord,43.2,35.8
.use 33344
>>Use the Brave's Flare next to this tower
.complete 11259,3
>>Target the Southwest Tower
step
.goto Howling Fjord,44.9,35
.use 33346
>>Use your Vrykul Scroll of Ascension next to the bonfire
.complete 11260,1
.mob Halfdan the Ice-Hearted
>>Kill Halfdan the Ice-Hearted
step
.goto Howling Fjord,46.9,37.1
.use 33344
>>Use the Brave's Flare next to this tower
.complete 11259,4
>>Target the Southeast Tower
step
.goto Howling Fjord,46.5,33.2
.use 33344
>>Use the Brave's Flare next to this tower
.complete 11259,2
>>Target the East Tower
step
.goto Howling Fjord,46,30.7
.use 33343
>>Use the Brave's Torch inside this building
.complete 11258,3
>>Set the Barracks Ablaze
step
.goto Howling Fjord,46.4,28.2
.use 33343
>>Use the Brave's Torch inside this house
.complete 11258,2
>>Set the Northeast Longhouse Ablaze
step
.use 33340
>>Use your Winterhoof Emblem in your bags
.target Winterhoof Brave
.turnin 11257 >> Turn in Gruesome, But Necessary
.turnin 11258 >> Turn in Burn Skorn, Burn!
.turnin 11259 >> Turn in Towers of Certain Doom
.accept 11261 >> Accept The Conqueror of Skorn!
step
.goto Howling Fjord,48.2,10.7
.target Greatmother Ankha
.turnin 11260 >> Turn in Stop the Ascension!
step
.goto Howling Fjord,48,10.7
.target Chieftain Ashtotem
.turnin 11261 >> Turn in The Conqueror of Skorn!
.accept 11263 >> Accept Dealing With Gjalerbron
step
.goto Howling Fjord,48.2,10.7
.target Greatmother Ankha
.accept 11265 >> Accept Of Keys and Cages
step
.goto Howling Fjord,31.2,24.5
.target Sage Mistwalker
.turnin 11317 >> Turn in The Cleansing
.accept 11323 >> Accept In Worg's Clothing
step
.goto Howling Fjord,29.7,5.7
.use 33618
>>Use your Worg Disguise to turn into a Worg
.target Ulfang
.turnin 11323 >> Turn in In Worg's Clothing
.accept 11415 >> Accept Brother Betrayers
step
.goto Howling Fjord,28.3,23.9
.complete 11415,1
.mob Bjomolf
>>Kill Bjomolf
step
.goto Howling Fjord,33.8,29.3
.complete 11415,2
.mob Varg
>>Kill Varg
step
.goto Howling Fjord,35.1,16
.complete 11263,1
.mob Gjalerbron Warrior
>>Kill Gjalerbron Warrior
.complete 11263,2
.mob Gjalerbron Rune-Caster
>>Kill Gjalerbron Rune-Caster
.complete 11263,3
.mob Gjalerbron Sleep-Watcher
>>Kill Gjalerbron Sleep-Watcher
.mob Gjalerbron mobs
>>Kill Gjalerbron mobs
>>Collect Gjalerbron Cage Keys
>>Click Gjalerbron Cages
.complete 11265,1
>>Free 10 Gjalerbron Prisoners
>>Collect Gjalerbron Attack Plans
.use 33347
>>Click the Gjalerbron Attack Plans in your bags
.accept 11266 >> Accept Gjalerbron Attack Plans
step
.goto Howling Fjord,29.7,5.7
.use 33618
>>Use your Worg Disguise to turn into a Worg
.target Ulfang
.turnin 11415 >> Turn in Brother Betrayers
.accept 11417 >> Accept Eyes of the Eagle
step
.goto Howling Fjord,41.4,37.7
>>Click Talonshrike's Egg - It's an egg sitting in a nest with 2 other eggs at the base of this waterfall, in the water on a rock
.mob Talonshrike
>>Kill Talonshrike
.complete 11417,1
>>Collect Eyes of the Eagle
step
.goto Howling Fjord,29.7,5.7
.use 33618
>>Use your Worg Disguise to turn into a Worg
.target Ulfang
.turnin 11417 >> Turn in Eyes of the Eagle
.accept 11324 >> Accept Alpha Worg
step
.goto Howling Fjord,26.3,12.8
.complete 11324,1
.mob Garwal
>>Kill Garwal
step
.goto Howling Fjord,31.2,24.5
.target Sage Mistwalker
.turnin 11324 >> Turn in Alpha Worg
step
.goto Howling Fjord,48.2,10.7
.target Greatmother Ankha
.turnin 11265 >> Turn in Of Keys and Cages
.accept 11268 >> Accept The Walking Dead
step
.goto Howling Fjord,48,10.7
.target Chieftain Ashtotem
.turnin 11263 >> Turn in Dealing With Gjalerbron
.accept 11264 >> Accept Necro Overlord Mezhen
step
.goto Howling Fjord,48.4,11
.target Ahota Whitefrost
.accept 11433 >> Accept Sleeping Giants
step
.goto Howling Fjord,49.6,11.6
.target Celea Frozenmane
.turnin 11266 >> Turn in Gjalerbron Attack Plans
step
.home Camp Winterhoof >> Set your Hearthstone to Camp Winterhoof
step
.goto Howling Fjord,35.7,15.8
>>Go up onto the platform to 35.7,15.8
.complete 11268,1
.mob Deathless Watcher
>>Kill Deathless Watcher
.complete 11268,3
.mob Putrid Wight
>>Kill Putrid Wight
.goto Howling Fjord,38.2,11.8
>>You can find another Putrid Wight and more Deathless Watchers at 38.2,11.8
step
.goto Howling Fjord,38.8,13
.complete 11264,1
.mob Necro Overlord Mezhen
>>Kill Necro Overlord Mezhen
>>Collect Mezhen's Writings
.use 34091
>>Click Mezhen's Writings
.accept 11453 >> Accept The Slumbering King
step
.goto Howling Fjord,39.8,7.6
.goto Howling Fjord,39.8,7.6,0.3
>>This is the entrance to The Slumbering King - Go up the big ramp to this spot
step
.goto Howling Fjord,40.9,6.5
>>Go inside and downstairs to 40.9,6.5
.complete 11453,1
.mob Queen Angerboda
>>Kill Queen Angerboda
step
.goto Howling Fjord,34.5,13.2
>>Go outside to 34.5,13.2
.goto Howling Fjord,34.5,13.2,0.3
>>The entrance down into the Walking Halls starts here
step
.goto Howling Fjord,35,11.9
>>Go down the stairs to 35,11.9
.complete 11268,2
.mob Fearsome Horror
>>Kill Fearsome Horror
.mob Necrolords
>>Kill Necrolords
.collect 34083,5,11433 >> Collect 5 Awakening Rod
.use 34083
>>Use your Awakening Rods on Dormant Vrykul
.complete 11433,1
.mob Dormant Vrykul
>>Kill Dormant Vrykul
step
.goto Howling Fjord,49.5,10.8,0.3
.hs >> Hearth to Camp Winterhoof
>>Hearth to Camp Winterhoof
step
.goto Howling Fjord,48.4,11
.target Ahota Whitefrost
.turnin 11433 >> Turn in Sleeping Giants
step
.goto Howling Fjord,48.2,10.7
.target Greatmother Ankha
.turnin 11268 >> Turn in The Walking Dead
step
.goto Howling Fjord,48,10.7
.target Chieftain Ashtotem
.turnin 11264 >> Turn in Necro Overlord Mezhen
.turnin 11453 >> Turn in The Slumbering King
step
.fly New Agamand, Howling Fjord >> Fly to New Agamand
>>Fly to New Agamand
step
.goto Howling Fjord,53.6,66.4
.target Chief Plaguebringer Harris
.accept 12181 >> Accept Give it a Name
step
.goto Howling Fjord,52,67.4
.target Tobias Sarkhoff
.turnin 12181 >> Turn in Give it a Name
.accept 12182 >> Accept To Venomspite!
step
.goto Dragonblight,76.6,62.4,0.3
>>He will fly you to Dragonblight
step
.goto Dragonblight,76.5,62.2
.target Junter Weiss
.fp Venomspite, Dragonblight >> Get the Venomspite flight path
step
.goto Dragonblight,77,62.9
.target Apothecary Vicky Levine
.accept 12206 >> Accept Blighted Last Rites
step
>>Next to where you are standing, there is a Scarlet Onslaught Prisoner in a cage:
.use 37129
>>Use your Flask of Blight on the Scarlet Onslaught Prisoner
.complete 12206,1
>>Test the Flask of Blight
step
.goto Dragonblight,77,62.9
.target Apothecary Vicky Levine
.turnin 12206 >> Turn in Blighted Last Rites
.accept 12211 >> Accept Let Them Not Rise!
step
.goto Dragonblight,77.7,62.8
.target Chief Plaguebringer Middleton
.turnin 12182 >> Turn in To Venomspite!
.accept 12188 >> Accept The Forsaken Blight and You: How Not to Die
step
.goto Dragonblight,76.9,62.8
>>Click the Wanted Poster - On the left of the doorway entrance to the inn
.accept 12205 >> Accept Wanted: The Scarlet Onslaught
step
.home Venomspite >> Set your Hearthstone to Venomspite
step
.goto Dragonblight,76.8,63.3
.target High Executor Wroth
.accept 12487 >> Accept To Conquest Hold, But Be Careful!
step
.goto Dragonblight,76,63.3
.target Quartermaster Bartlett
.accept 12303 >> Accept Funding the War Effort
.accept 12209 >> Accept Materiel Plunder
step
.goto Dragonblight,79.3,65.1
.target Surveyor Hansen
.accept 12304 >> Accept Beachfront Property
step
.goto Dragonblight,82.9,65.1
.complete 12304,1
.mob Forgotten ghosts
>>Kill Forgotten ghosts
.mob Forgotten ghosts
>>Kill Forgotten ghosts
.complete 12188,1
>>Collect Ectoplasmic Residue
step
.goto Dragonblight,82.5,73.1
>>Click the Forgotten Treasure - They look like brown chests underwater around this area
.complete 12303,1
>>Collect Forgotten Treasure
step
.goto Dragonblight,79.3,65.1
.target Surveyor Hansen
.turnin 12304 >> Turn in Beachfront Property
step
.goto Dragonblight,76,63.3
.target Quartermaster Bartlett
.turnin 12303 >> Turn in Funding the War Effort
step
.goto Dragonblight,77.7,62.8
.target Chief Plaguebringer Middleton
.turnin 12188 >> Turn in The Forsaken Blight and You: How Not to Die
.accept 12200 >> Accept Emerald Dragon Tears
step
.goto Dragonblight,73.7,66.6
.complete 12205,1
.mob Members of the Scarlet Onslaught
>>Kill Members of the Scarlet Onslaught
.use 37187
>>Use your Container of Rats on Scarlet Onslaught corpses after you kill them
.complete 12211,1
>>Pick 15 Scarlet Onslaught corpses clean
step
.goto Dragonblight,72.6,69.7
>>Click Scarlet Onslaught Weapon Racks - The Scarlet Onslaught Weapon Racks look like standing racks with weapons on them around this whole town
.complete 12209,2
>>Collect Scarlet Onslaught Weapon
>>Click Scarlet Onslaught Armor Stands - The Scarlet Onslaught Armor Stands look like stands with a chainmail chest piece hanging on them around this whole town
.complete 12209,1
>>Collect Scarlet Onslaught Armor
step
.goto Dragonblight,63.3,70.3
>>Go souhwest to 63.3,70.3
>>Click Emerald Dragon Tears - They look like green jewels laying on the ground around this area
.complete 12200,1
>>Collect Emerald Dragon Tear
step
.goto Dragonblight,63.7,71.9
.target Nishera the Garden Keeper
.accept 12454 >> Accept Cycle of Life
step
.complete 12454,1
.mob Emerald Skytalon
>>Kill Emerald Skytalon
step
.goto Dragonblight,63.7,71.9
.target Nishera the Garden Keeper
.turnin 12454 >> Turn in Cycle of Life
step
.goto Dragonblight,76,63.3
.target Quartermaster Bartlett
.turnin 12209 >> Turn in Materiel Plunder
step
.goto Dragonblight,75.9,61.9
.target Hansel Bauer
.accept 12214 >> Accept Fresh Remounts
step
.goto Dragonblight,77,62.9
.target Apothecary Vicky Levine
.turnin 12211 >> Turn in Let Them Not Rise!
step
.goto Dragonblight,76.8,63.3
.target High Executor Wroth
.turnin 12205 >> Turn in Wanted: The Scarlet Onslaught
step
.goto Dragonblight,76.7,63
>>Go upstairs to 76.7,63
.target Spy Mistress Repine
.accept 12245 >> Accept No Mercy for the Captured
step
.goto Dragonblight,77.7,62.8
.target Chief Plaguebringer Middleton
.turnin 12200 >> Turn in Emerald Dragon Tears
.accept 12218 >> Accept Spread the Good Word
step
.goto Dragonblight,77.5,62
.target Deathguard Molder
.accept 12230 >> Accept Stealing from the Siegesmiths
step
.goto Dragonblight,74.5,65.8
.mob an Onslaught Knight (be sure not to kill the horse)
>>Kill an Onslaught Knight (be sure not to kill the horse)
>>Loot it and get it's Onslaught Riding Crop
.use 37202
>>Use the Onslaught Riding Crop on the Onslaught Warhorse
>>Ride the horse back to Hansel Bauer at 75.9,61.9
.macro Hand Over Reins,134400 >>/cast Hand Over Reins
>>Use the Hand Over Reins ability to turn the horse in
>>Repeat this 3 times
.complete 12214,1
>>Hand over 3 Scarlet Onslaught Warhorse reins
step
.goto Dragonblight,75.9,61.9
.target Hansel Bauer
.turnin 12214 >> Turn in Fresh Remounts
step
.goto Dragonblight,71.4,72.2
.target Deathguard Schneider
.complete 12245,1
.mob Deathguard Schneider
>>Kill Deathguard Schneider
step
.goto Dragonblight,72.7,72.6
.target Chancellor Amai
.complete 12245,4
.mob Chancellor Amai
>>Kill Chancellor Amai
step
.goto Dragonblight,72.8,74.4
.target Engineer Burke
.complete 12245,3
.mob Engineer Burke
>>Kill Engineer Burke
step
.goto Dragonblight,69.4,73.9
.target Senior Scrivener Barriga
.complete 12245,2
.mob Senior Scrivener Barriga
>>Kill Senior Scrivener Barriga
step
.goto Dragonblight,76.8,63.3
.target High Executor Wroth
.turnin 12245 >> Turn in No Mercy for the Captured
.accept 12252 >> Accept Torture the Torturer
step
.goto Dragonblight,69.8,72
>>Go southwest into the basement of this building to 69.8,72
.use 37314
>>Use High Executor's Branding Iron 5 times on Torturer LeCraft
.complete 12252,1
>>Fully Question Torturer LeCraft
.complete 12252,2
.mob Torturer LeCraft
>>Kill Torturer LeCraft
>>Collect Torturer's Rod
.use 37432
>>Click the Torturer's Rod in your bags
.accept 12271 >> Accept The Rod of Compulsion
step
.goto Dragonblight,76.8,63.3
>>Go northeast out of the fort to 76.8,63.3
.target High Executor Wroth
.turnin 12252 >> Turn in Torture the Torturer
.turnin 12271 >> Turn in The Rod of Compulsion
.accept 12273 >> Accept The Denouncement
step
.goto Dragonblight,70.8,70.5
.use 37438
>>Use the Rod of Compulsion on Blacksmith Goodman when he's about halfway dead
.mob Blacksmith Goodman
>>Kill Blacksmith Goodman
.complete 12273,3
>>Get Blacksmith Goodman's denouncement & death
step
.goto Dragonblight,69.7,71.8
>>Go inside the fort and upstairs to 69.7,71.8
.use 37438
>>Use the Rod of Compulsion on Commander Jordan when he's about halfway dead
.mob Commander Jordan
>>Kill Commander Jordan
.complete 12273,1
>>Get Commander Jordan's denouncement & death
step
.goto Dragonblight,67.9,75.9
>>Go outside of the fort to 67.9,75.9
.use 37438
>>Use the Rod of Compulsion on Stable Master Mercer when he's about halfway dead
.mob Stable Master Mercer
>>Kill Stable Master Mercer
.complete 12273,4
>>Get Stable Master Mercer's denouncement & death
step
.goto Dragonblight,72.9,78.1
>>Go southeast down the big hill to 72.9,78.1
.use 37438
>>Use the Rod of Compulsion on Lead Cannoneer Zierhut when he's about halfway dead
.mob Lead Cannoneer Zierhut
>>Kill Lead Cannoneer Zierhut
.complete 12273,2
>>Get Lead Cannoneer Zierhut's denouncement & death
step
.goto Dragonblight,76.9,63.1,0.3
.hs >> Hearth to Venomspite
>>Hearth to Venomspite
step
.goto Dragonblight,76.8,63.3
.target High Executor Wroth
.turnin 12273 >> Turn in The Denouncement
step
.goto Dragonblight,77.8,61.6
.vehicle
>>Click a Forsaken Blight Spreader to ride it - They look like big catapult car things
step
.goto Dragonblight,85.9,57.9
>>Shoot your catapult toward the ghouls and skeletons to the northwest
.complete 12218,1
.mob Hungering Dead
>>Kill Hungering Dead
step
.exitvehicle
>>Click the red arrow button to Leave the Vehicle
step
.goto Dragonblight,85,51.1
>>Click the Siegesmith Bombs on the ground - They look like metal spikey balls sitting on the ground around this area
.complete 12230,1
>>Collect Siegesmith Bomb
step
.goto Dragonblight,77.5,62
.target Deathguard Molder
.turnin 12230 >> Turn in Stealing from the Siegesmiths
.accept 12232 >> Accept Bombard the Ballistae
step
.goto Dragonblight,77.7,62.8
.target Chief Plaguebringer Middleton
.turnin 12218 >> Turn in Spread the Good Word
.accept 12221 >> Accept The Forsaken Blight
step
.goto Dragonblight,77,62.9
.target Apothecary Vicky Levine
.accept 12240 >> Accept A Means to an End
step
.goto Dragonblight,76.7,63
>>Go into the building to 76.7,63
.target Spy Mistress Repine
.accept 12234 >> Accept Need to Know
step
.goto Dragonblight,73.3,67.6
.use 37259
>>Use your Siegesmith Bombs on New Hearthglen Ballistas
.complete 12232,1
>>Bombard 5 New Hearthglen Ballistas
step
.goto Dragonblight,69.7,71.9
>>Go into the fort to 69.7,71.9
>>Click the Scarlet Onslaught Daily Orders: Barracks - Sitting on a small table next to the base of the stairs, inside the fort
.complete 12234,2
>>Collect Scarlet Onslaught Daily Orders: Barracks
step
.goto Dragonblight,73.4,72.6
>>Go across the courtyard into the cathedral to 73.4,72.6
>>Click the Scarlet Onslaught Daily Orders: Abbey - Sitting on a table with a bunch of books on it, in the Library Wing of the cathedral building
.complete 12234,1
>>Collect Scarlet Onslaught Daily Orders: Abbey
step
.goto Dragonblight,71.6,80.4
>>Go down the hill to the beach to 71.6,80.4
>>Click the Scarlet Onslaught Daily Orders: Beach - Sitting on a small crate on the beach, next to a bonfire and some tents
.complete 12234,3
>>Collect Scarlet Onslaught Daily Orders: Beach
step
.goto Dragonblight,68.3,74.2
>>Go back up the hill and into the lumber mill to 68.3,74.2
>>Stand inside the Lumber Mill here
.use 37300
>>Use your Levine Family Termites
.complete 12240,1
.mob Foreman Kaleiki
>>Kill Foreman Kaleiki
step
.goto Dragonblight,77,62.9
.target Apothecary Vicky Levine
.turnin 12240 >> Turn in A Means to an End
.accept 12243 >> Accept Fire Upon the Waters
step
.goto Dragonblight,76.7,63
>>Go inside the building to 76.7,63
.target Spy Mistress Repine
.turnin 12234 >> Turn in Need to Know
.accept 12239 >> Accept The Spy in New Hearthglen
step
.goto Dragonblight,77.5,62
.target Deathguard Molder
.turnin 12232 >> Turn in Bombard the Ballistae
step
.goto Dragonblight,73.6,73.5
.target Agent Skully
.turnin 12239 >> Turn in The Spy in New Hearthglen
.accept 12254 >> Accept Without a Prayer
step
.goto Dragonblight,69.2,76.7
.mob Bishop Street
>>Kill Bishop Street
.complete 12254,1
>>Collect Bishop Street's Prayer Book
step
.goto Dragonblight,73.6,73.5
.target Agent Skully
.turnin 12254 >> Turn in Without a Prayer
.accept 12260 >> Accept The Perfect Dissemblance
step
>>Run around this area and find an Onslaught Raven Priest
.use 37381
>>Use Banshee's Magic Mirror on an Onslaught Raven Priest
.complete 12260,1
>>Steal an Onslaught Raven Priest's image
step
.goto Dragonblight,73.6,73.5
.target Agent Skully
.turnin 12260 >> Turn in The Perfect Dissemblance
.accept 12274 >> Accept A Fall From Grace
step
.goto Dragonblight,72.9,73.5
>>Go to the top floor of the cathedral behind you to 72.9,73.5
>>Click the Abbey Bell Rope - It's a big rope hanging from the ceiling in the attic of the cathedral building
.complete 12274,1
>>Ring the Abbey Bell
step
.goto Dragonblight,73.5,74.3
>>Go downstairs to 73.5,74.3
.target High Abbot Landgren
>>Go to the entrance of the cathedral building
>>Follow the priest to a spot on a nearby cliff
.complete 12274,2
>>Speak with High Abbot Landgren
step
.goto Dragonblight,73.6,73.5
.target Agent Skully
.turnin 12274 >> Turn in A Fall From Grace
.accept 12283 >> Accept The Truth Will Out
step
.goto Dragonblight,68.3,77
>>Click The Diary of High General Abbendis - It's a purple book sitting on a nightstand between 2 beds, on the second floor of this house
.complete 12283,1
>>Collect The Diary of High General Abbendis
step
.goto Dragonblight,71.5,82.6
>>Go down the hill to the beach to 71.5,82.6
>>Stand on the plank
.use 37304
>>Use you Apothecary's Burning Water and throw it at the ship's sail
.complete 12243,1
>>Set the Sails of the Sinner's Folly afire
step
.goto Dragonblight,71.9,84
>>When the crew is distracted, go downstairs into the ship to 71.9,84
.mob Captain Shely
>>Kill Captain Shely
.complete 12243,2
>>Collect Captain Shely's Rutters
step
.goto Dragonblight,76.9,63.1,0.3
.hs >> Hearth to Venomspite
>>Hearth to Venomspite
step
.goto Dragonblight,76.8,63.3
.target High Executor Wroth
.turnin 12283 >> Turn in The Truth Will Out
step
.goto Dragonblight,77,62.9
.target Apothecary Vicky Levine
.turnin 12243 >> Turn in Fire Upon the Waters
step
.goto Dragonblight,48.5,74.4
.target Cid Flounderfix
.fp Moa'ki, Dragonblight >> Get the Moa'ki Harbor flight path
step
.home Moa'ki Harbor >> Set your Hearthstone to Moa'ki Harbor
step
.goto Dragonblight,48,74.9
.target Elder Ko'nani
.turnin 12117 >> Turn in Travel to Moa'ki Harbor
.accept 11958 >> Accept Let Nothing Go To Waste
step
.goto Dragonblight,48,74.8
.target Envoy Ripfang
.accept 11996 >> Accept Your Presence is Required at Agmar's Hammer
step
.goto Dragonblight,48.3,74.3
.target Trapper Mau'i
.accept 11960 >> Accept Planning for the Future
step
.goto Dragonblight,45.3,63.7
.mob Snowfall Glade mobs
>>Kill Snowfall Glade mobs
.complete 11958,1
>>Collect Stolen Moa'ki Goods
>>Click Snowfall Glade Pups - The Snowfall Glade Pups are small creatures in front of the houses
.complete 11960,1
>>Collect Snowfall Glade Pup
step
.goto Dragonblight,48.3,74.3
.target Trapper Mau'i
.turnin 11960 >> Turn in Planning for the Future
step
.goto Dragonblight,48,74.9
.target Elder Ko'nani
.turnin 11958 >> Turn in Let Nothing Go To Waste
.accept 11959 >> Accept Slay Loguhn
step
.goto Dragonblight,46.3,59.2
.mob Loguhn
>>Kill Loguhn
>>Collect Blood of Loguhn
.use 35688
>>Click the Blood of Loguhn
.complete 11959,1
>>Smear the Blood of Loguhn on yourself
step
.goto Dragonblight,48,74.9
.target Elder Ko'nani
.turnin 11959 >> Turn in Slay Loguhn
step
.goto Dragonblight,49.2,75.6
.target Toalu'u the Mystic
.accept 12028 >> Accept Spiritual Insight
step
.goto Dragonblight,48.9,75.8
.use 35907
>>Use Toalu'u's Spiritual Incense next to Toalu'u's Brazier
>>Watch yourself fly as a wisp
.complete 12028,1
>>Attain Spiritual Insight cocnerning Indu'le Village
step
.goto Dragonblight,49.2,75.6
.target Toalu'u the Mystic
.turnin 12028 >> Turn in Spiritual Insight
.accept 12030 >> Accept Elder Mana'loa
step
.goto Dragonblight,47.7,76.6
.target Tua'kea
.accept 12009 >> Accept Tua'kea's Crab Traps
step
.goto Dragonblight,46.6,77.5
>>Click Tua'kea's Crab Traps - They look like small cages on the ground underwater around this area
.complete 12009,1
>>Collect Tua'kea Crab Trap
step
.goto Dragonblight,47.7,80
>>Click the Wrecked Crab Trap - It looks like a broken version of Tue'kea's Crab Traps, on the ground underwater
.accept 12011 >> Accept Signs of Big Watery Trouble
step
.goto Dragonblight,47.7,76.6
.target Tua'kea
.turnin 12009 >> Turn in Tua'kea's Crab Traps
.turnin 12011 >> Turn in Signs of Big Watery Trouble
.accept 12016 >> Accept The Bait
step
.goto Dragonblight,43.7,82.3
.mob Kili'ua
>>Kill Kili'ua
.complete 12016,1
>>Collect The Flesh of "Two Huge Pincers"
step
.goto Dragonblight,47.7,76.6
.target Tua'kea
.turnin 12016 >> Turn in The Bait
.accept 12017 >> Accept Meat on the Hook
step
.goto Dragonblight,46.7,78.2
.use 35838
>>Use Tu'u'gwar's Bait next to Tua'kea's Fishing Hook
.complete 12017,1
.mob Tu'u'gwar
>>Kill Tu'u'gwar
step
.goto Dragonblight,47.7,76.6
.target Tua'kea
.turnin 12017 >> Turn in Meat on the Hook
step
.goto Dragonblight,36.4,65
.target Elder Mana'loa
.turnin 12030 >> Turn in Elder Mana'loa
.accept 12031 >> Accept Freedom for the Lingering
step
.goto Dragonblight,37.2,65.5
.mob Indu'le mobs
>>Kill Indu'le mobs
.complete 12031,1
>>Put 15 Indu'le spirits to rest
step
.goto Dragonblight,36.4,65
.target Elder Mana'loa
.turnin 12031 >> Turn in Freedom for the Lingering
.accept 12032 >> Accept Conversing With the Depths
step
.goto Dragonblight,34.3,79.9
.goto Dragonblight,34.3,79.9,0.3
>>The path up to Conversing With the Depths starts here
step
>>Follow the path up to 34,83.4
>>Click The Pearl of the Depths - It's a big white pearl sitting on a altar thing
>>Oacha'noa appears and tells you to jump in the water
>>Jump in the water when he tells you to
.complete 12032,1
>>Obey Oacha'noa's compulsion
step
.goto Dragonblight,48.2,74.7,0.3
.hs >> Hearth to Moa'ki Harbor
>>Hearth to Moa'ki Harbor
step
.goto Dragonblight,49.2,75.6
.target Toalu'u the Mystic
.turnin 12032 >> Turn in Conversing With the Depths
step
.xp 74
]]);
RXPGuides.RegisterGuide([[
#wotlk
#ac335
#version 1
#group RestedXP WotLK Guide (H)
#subgroup Northrend 70-80
<< Horde
#name 74-76 Northrend
#next 76-78 Northrend
step
.goto Dragonblight,36.1,48.9
.target Doctor Sintar Malefious
.turnin 12221 >> Turn in The Forsaken Blight
step
.goto Dragonblight,37.3,46.8
.target Messenger Torvus
.accept 12033 >> Accept Message from the West
step
.goto Dragonblight,37.4,46.7
>>Click the Burning Brazier - It looks like a bowl with fire in it, next to the mailbox
.complete 12033,1
>>Read and Destroy the Letter from Saurfang
step
.goto Dragonblight,37.3,46.8
.target Messenger Torvus
.turnin 12033 >> Turn in Message from the West
step
.goto Dragonblight,38.1,46.2
.target Image of Archmage Aethas Sunreaver
.turnin 11996 >> Turn in Your Presence is Required at Agmar's Hammer
.accept 11999 >> Accept Rifle the Bodies
.accept 12791 >> Accept The Magical Kingdom of Dalaran
step
.home Agmar's Hammer >> Set your Hearthstone to Agmar's Hammer
step
.goto Dragonblight,37.5,45.8
.target Narzun Skybreaker
.fp Agmar's Hammer, Dragonblight >> Get the Agmar's Hammer flight path
step
.goto Dragonblight,36.6,46.6
.target Senior Sergeant Juktok
.accept 11979 >> Accept The Taunka and the Tauren
step
.goto Dragonblight,26.2,50.8
.target Kilix the Unraveler
.accept 12040 >> Accept An Enemy in Arthas
step
.goto Dragonblight,26.1,49.6
.complete 12040,1
>>Kill 6 Anub'ar Underlords inside this cave
step
.goto Dragonblight,26.2,50.8
.target Kilix the Unraveler
.turnin 12040 >> Turn in An Enemy in Arthas
.accept 12041 >> Accept The Lost Empire
step
.goto Dragonblight,22.3,54.1
>>Go outside the cave and southwest to 22.3,54.1
>>Click the Dead Mage Hunter bodies on the ground
>>Collect Mage Hunter Personal Effects bags
.use 35792
>>Click the Mage Hunter Personal Effects bags
.complete 11999,1
>>Collect Moonrest Gardens Plans
step
.goto Dragonblight,36.3,45.6
.target Overlord Agmar
.turnin 12041 >> Turn in The Lost Empire
step
.goto Dragonblight,38.1,46.2
.target Image of Archmage Aethas Sunreaver
.turnin 11999 >> Turn in Rifle the Bodies
.accept 12005 >> Accept Prevent the Accord
step
.goto Dragonblight,18.4,58.9
.mob Wind Trader Mu'fah
>>Kill Wind Trader Mu'fah
.complete 12005,1
>>Collect Wind Trader Mu'fah's Remains
step
.goto Dragonblight,19.4,58.1
>>Go inside the building to 19.4,58.1
.mob Goramosh
>>Kill Goramosh
.complete 12005,2
>>Collect The Scales of Goramosh
>>Collect Goramosh's Strange Device
.use 36746
>>Click Goramosh's Strange Device
.accept 12059 >> Accept A Strange Device
step
.goto Dragonblight,38.1,46.2
.target Image of Archmage Aethas Sunreaver
.turnin 12005 >> Turn in Prevent the Accord
.turnin 12059 >> Turn in A Strange Device
.accept 12061 >> Accept Projections and Plans
step
.goto Dragonblight,22.2,54.8
.use 36747
>>Use your Surge Needle Teleporter anywhere inside Moonrest Gardens
>>Move toward the center of the platform you get teleported onto
.complete 12061,1
>>Observe the Object on the Surge Needle
step
.goto Dragonblight,22.6,57.0,0.3
.use 36747
>>Use your Surge Needle Teleporter to go back down to the ground
step
.goto Dragonblight,38.1,46.2
.target Image of Archmage Aethas Sunreaver
.turnin 12061 >> Turn in Projections and Plans
.accept 12066 >> Accept The Focus on the Beach
step
.goto Dragonblight,24.2,60.1
.target Ethenial Moonshadow
.accept 12006 >> Accept Avenge this Atrocity!
step
.goto Dragonblight,20.9,60.4
.complete 12006,1
.mob Blue Dragonflight forces at Moonrest Gardens
>>Kill Blue Dragonflight forces at Moonrest Gardens
step
.goto Dragonblight,24.2,60.1
.target Ethenial Moonshadow
.turnin 12006 >> Turn in Avenge this Atrocity!
.accept 12013 >> Accept End Arcanimus
step
.goto Dragonblight,20,59.7
.complete 12013,1
.mob Arcanimus
>>Kill Arcanimus
step
.goto Dragonblight,24.2,60.1
.target Ethenial Moonshadow
.turnin 12013 >> Turn in End Arcanimus
step
.goto Dragonblight,26.4,65
.mob Captain Emmy Malin
>>Kill Captain Emmy Malin
>>Collect Ley Line Focus Control Ring
.use 36751
>>Use the Ley Line Focus Control Ring next to the half-circle
.complete 12066,1
>>Retrieve ley line focus information
step
.goto Dragonblight,38.1,46.6,1
.hs >> Hearth to Agmar's Hammer
>>Hearth to Agmar's Hammer
step
.goto Dragonblight,38.1,46.2
.target Image of Archmage Aethas Sunreaver
.turnin 12066 >> Turn in The Focus on the Beach
.accept 12084 >> Accept Atop the Woodlands
step
.goto Dragonblight,36.5,47.9
.target Earthwarden Grife
.accept 12096 >> Accept Strengthen the Ancients
step
.goto Dragonblight,31.2,59.7
.target Woodlands Walker
.collect 36786,3,12096 >> Collect 3 Bark of the Walkers
step
.goto Dragonblight,30.6,63.4
.use 36786
>>Use your Bark of the Walkers on Lothalor Ancients
.complete 12096,1
>>Strengthen 3 Lothalor Ancients
step
.goto Dragonblight,32.2,70.6
.mob Lieutenant Ta'zinni
>>Kill Lieutenant Ta'zinni
>>Collect Ley Line Focus Amulet
>>Collect Lieutenant Ta'zinni's Letter
.use 36780
>>Click Lieutenant Ta'zinni's Letter
.accept 12085 >> Accept A Letter for Home
step
.goto Dragonblight,32.2,71.2
.use 36779
>>Use your Ley Line Focus Control Amulet on the Ley Line Focus
.complete 12084,1
>>Retrieve Ley Line Focus information
step
.goto Dragonblight,36.5,47.9
.target Earthwarden Grife
.turnin 12096 >> Turn in Strengthen the Ancients
step
.goto Dragonblight,38.1,46.2
.target Image of Archmage Aethas Sunreaver
.turnin 12084 >> Turn in Atop the Woodlands
.accept 12106 >> Accept Search Indu'le Village
step
.goto Dragonblight,36.3,45.6
.target Overlord Agmar
.turnin 12085 >> Turn in A Letter for Home
step
.goto Dragonblight,40.3,66.9
>>Click Mage-Commander Evenstar's body floating underwater
.turnin 12106 >> Turn in Search Indu'le Village
.accept 12110 >> Accept The End of the Line
step
.goto Dragonblight,39.8,66.9
.use 36815
>>Use your Ley Line Focus Control Talisman on the Ley Line Focus
.complete 12110,1
>>Retrieve Ley Line Focus information
step
.goto Dragonblight,53,66.4
.complete 12110,2
>>Go to this spot on the cliff to Observe Azure Dragonshrine
step
.goto Dragonblight,38.1,46.2
.target Image of Archmage Aethas Sunreaver
.turnin 12110 >> Turn in The End of the Line
.accept 12122 >> Accept Gaining an Audience
step
.goto Dragonblight,14.2,49.8
.target Blood Guard Roh'kill
.accept 11980 >> Accept Pride of the Horde
step
.goto Dragonblight,12.8,48.5
.target Emissary Brighthoof
.turnin 11979 >> Turn in The Taunka and the Tauren
.accept 11978 >> Accept Into the Fold
step
.goto Dragonblight,15.5,51.2
.complete 11980,1
.mob Anub'ar Ambusher
>>Kill Anub'ar Ambusher
>>Click Horde Armament crates - The Horde Armaments look like crates sitting on the ground around this area
.complete 11978,1
>>Collect Horde Armaments
step
.goto Dragonblight,14.2,49.8
.target Blood Guard Roh'kill
.turnin 11980 >> Turn in Pride of the Horde
step
.goto Dragonblight,12.8,48.5
.target Emissary Brighthoof
.turnin 11978 >> Turn in Into the Fold
.accept 11983 >> Accept Blood Oath of the Horde
step
.target Taunka'le Refugee
.complete 11983,1
>>Admit 5 Taunka Into the Horde
step
.goto Dragonblight,12.8,48.5
.target Emissary Brighthoof
.turnin 11983 >> Turn in Blood Oath of the Horde
.accept 12008 >> Accept Agmar's Hammer
step
.goto Dragonblight,38.1,46.6,1
.hs >> Hearth to Agmar's Hammer
>>Hearth to Agmar's Hammer
step
.goto Dragonblight,36.3,45.6
.target Overlord Agmar
.turnin 12008 >> Turn in Agmar's Hammer
.accept 12034 >> Accept Victory Nears...
step
.goto Dragonblight,36.6,46.6
.target Senior Sergeant Juktok
.turnin 12034 >> Turn in Victory Nears...
.accept 12036 >> Accept From the Depths of Azjol-Nerub
step
.goto Dragonblight,36.6,47.2
.target Borus Ironbender
.accept 12039 >> Accept Black Blood of Yogg-Saron
step
.goto Dragonblight,37.1,48.6
.target Soar Hawkfury
.accept 12100 >> Accept Containing the Rot
step
.goto Dragonblight,35.8,48.4
.target Captain Gort
.accept 12056 >> Accept Marked for Death: High Cultist Zangus
step
.goto Dragonblight,29,50.7
.mob Blighted Elk and Rabid Grizzlies
>>Kill Blighted Elk and Rabid Grizzlies
.complete 12100,1
.mob Infected Wildlife
>>Kill Infected Wildlife
.complete 12100,2
>>Collect Rot Resistant Organ
step
.goto Dragonblight,26.5,49.6
>>Click Black Blood of Yogg-Saron mining nodes - They look like green mining nodes inside this cave
.complete 12039,1
>>Collect Black Blood of Yogg-Saron Sample
step
.goto Dragonblight,28.9,49.7
>>Go down into the cave to 28.9,49.7
.mob High Cultist Zangus
>>Kill High Cultist Zangus
.complete 12056,1
>>Collect Head of High Cultist Zangus
step
.goto Dragonblight,26.2,50.4
>>Inside the cave, go to 26.2,50.4
.complete 12036,1
>>Explore the Pit of Narjun
step
.goto Dragonblight,35.8,48.4
>>Go outside the cave and east to 35.8,48.4
.target Captain Gort
.turnin 12056 >> Turn in Marked for Death: High Cultist Zangus
step
.goto Dragonblight,37.1,48.6
.target Soar Hawkfury
.turnin 12100 >> Turn in Containing the Rot
.accept 12101 >> Accept The Good Doctor...
step
.goto Dragonblight,36.1,48.9
.target Doctor Sintar Malefious
.turnin 12101 >> Turn in The Good Doctor...
.accept 12102 >> Accept In Search of the Ruby Lilac
step
.goto Dragonblight,36.6,47.2
.target Borus Ironbender
.turnin 12039 >> Turn in Black Blood of Yogg-Saron
.accept 12048 >> Accept Scourge Armaments
step
.goto Dragonblight,36.6,46.6
.target Senior Sergeant Juktok
.turnin 12036 >> Turn in From the Depths of Azjol-Nerub
.accept 12053 >> Accept The Might of the Horde
step
.goto Dragonblight,35.8,46.7
.target Greatmother Icemist
.accept 12063 >> Accept Strength of Icemist
step
.goto Dragonblight,26.9,43.3
.mob Anub'ar mobs
>>Kill Anub'ar mobs
.complete 12048,1
>>Collect Scourge Armament
>>Collect Flesh-bound Tome
.use 36744
>>Click the Flesh-bound Tome
.accept 12057 >> Accept The Flesh-Bound Tome
step
.goto Dragonblight,22.6,41.7
.target Banthok Icemist
.turnin 12063 >> Turn in Strength of Icemist
.accept 12064 >> Accept Chains of the Anub'ar
step
.goto Dragonblight,24.8,41.2
.use 36738
>>Use your Warsong Battle Standard in this spot
.complete 12053,1
>>Defend the Warsong Battle Standard
step
.goto Dragonblight,26.6,39.2
.mob Tivax the Breaker
>>Kill Tivax the Breaker
.complete 12064,2
>>Collect Tivax's Key Fragment
>>You can also find Tivax the Breaker in another big hut at 24.0,39.5
step
.goto Dragonblight,26.2,44.5
.mob Sinok the Shadowrager
>>Kill Sinok the Shadowrager
.complete 12064,3
>>Collect Sinok's Key Fragment
>>Sinok the Shadowrager will has several spawn points inside of the building
step
.goto Dragonblight,24.9,43.9
.mob Anok'ra the Manipulator
>>Kill Anok'ra the Manipulator
.complete 12064,1
>>Collect Anok'ra's Key Fragment
step
.goto Dragonblight,22.6,41.7
.target Banthok Icemist
.turnin 12064 >> Turn in Chains of the Anub'ar
.accept 12069 >> Accept Return of the High Chief
step
.goto Dragonblight,25.6,40.9
>>Click the Anub'ar Mechanism to free Roanauk Icemist - It's a floating purple crystal
>>Help him kill Under-king Anub'et'kan
>>Click Anub'et'kan's Carapace
.complete 12069,1
>>Collect Fragment of Anub'et'kan's Husk
step
.goto Dragonblight,38.1,46.6,1
.hs >> Hearth to Agmar's Hammer
>>Hearth to Agmar's Hammer
step
.goto Dragonblight,36.3,45.6
.target Overlord Agmar
.turnin 12069 >> Turn in Return of the High Chief
.accept 12140 >> Accept All Hail Roanauk!
step
.goto Dragonblight,36.6,46.6
.target Senior Sergeant Juktok
.turnin 12053 >> Turn in The Might of the Horde
.accept 12071 >> Accept Attack by Air!
step
.goto Dragonblight,36.6,47.2
.target Borus Ironbender
.turnin 12048 >> Turn in Scourge Armaments
step
.goto Dragonblight,35.8,48.4
.target Captain Gort
.turnin 12057 >> Turn in The Flesh-Bound Tome
.accept 12115 >> Accept Koltira and the Language of Death
step
.goto Dragonblight,37.1,46.5
.target Koltira Deathweaver
.turnin 12115 >> Turn in Koltira and the Language of Death
.accept 12125 >> Accept In Service of Blood
.accept 12126 >> Accept In Service of the Unholy
.accept 12127 >> Accept In Service of Frost
step
.goto Dragonblight,37.2,45.7
.target Valnok Windrager
.turnin 12071 >> Turn in Attack by Air!
.accept 12072 >> Accept Blightbeasts be Damned!
step
.goto Dragonblight,36.2,45.4
.target Roanauk Icemist
.complete 12140,1
>>Initiate Roanauk Icemist
step
.goto Dragonblight,36.3,45.6
.target Overlord Agmar
.turnin 12140 >> Turn in All Hail Roanauk!
step
.goto Dragonblight,37.5,64.1
>>Fight a Deranged Indu'le Villager
.use 36827
>>Use your Blood Gem on it when it is almost dead
.complete 12125,1
>>Collect Filled Blood Gem
step
.goto Dragonblight,27.5,44.8
.use 36774
>>Use Valnok's Flare Gun on this bridge to call a Kor'kron War Rider
.vehicle
>>Click the Kor'kron War Rider to ride it
step
.goto Dragonblight,27.8,38.9
>>Use the abilities on your action bar
.complete 12072,1
.mob Anub'ar Blightbeast
>>Kill Anub'ar Blightbeast
step
.goto Dragonblight,37.1,46.5
.target Koltira Deathweaver
.turnin 12125 >> Turn in In Service of Blood
step
.goto Dragonblight,37.2,45.7
.target Valnok Windrager
.turnin 12072 >> Turn in Blightbeasts be Damned!
step
.goto Dragonblight,47.7,49.1
.mob Dahlia Suntouch
>>Kill Dahlia Suntouch
>>Collect Ruby Brooch
.use 37833
>>Click the Ruby Brooch in your bags
.accept 12419 >> Accept The Fate of the Ruby Dragonshrine
>>Click the Ruby Lilac - The Ruby Lilac is a white flower plant inside the trunk of this huge tree
.complete 12102,1
>>Collect Ruby Lilac
step
.goto Dragonblight,46.9,50
>>Fight Duke Vallenhaal - He walks around this tree on a horse
.use 36835
>>Use your Unholy Gem on him when he's almost dead
.complete 12126,1
>>Collect Filled Unholy Gem
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.turnin 12122 >> Turn in Gaining an Audience
.accept 12767 >> Accept Speak with your Ambassador
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.goto Dragonblight,59.7,53.1,0.5
>>Tell him you need to go to the top of the temple
step
.goto Dragonblight,59.6,54.4
.target Lord Itharius
.accept 12458 >> Accept Seeds of the Lashers
step
.goto Dragonblight,59.8,54.7
.target Krasus
.turnin 12419 >> Turn in The Fate of the Ruby Dragonshrine
step
.goto Dragonblight,60,54.5
.target Chromie
.accept 12470 >> Accept Mystery of the Infinite
step
.goto Dragonblight,60.1,54.2
.target Nalice
.accept 12447 >> Accept The Obsidian Dragonshrine
step
.goto Dragonblight,59.5,53.3
.target Torastrasza
.goto Dragonblight,58.0,55.2,0.5
>>Tell him you want to go to the ground level of the temple
step
.goto Dragonblight,58,55.4
.target Golluck Rockfist
.turnin 12767 >> Turn in Speak with your Ambassador
.accept 12461 >> Accept Report to the Ruby Dragonshrine
step
.home Wyrmrest Temple >> Set your Hearthstone to Wyrmrest Temple
step
.goto Dragonblight,60.3,51.6
.target Nethestrasz
.fp Wyrmrest Temple, Dragonblight >> Get the Wyrmrest Temple flight path
step
.goto Dragonblight,66.2,52.9
>>Fight an Ice Revenant
.use 36847
>>Use your Frost Gem on it when it's almost dead
.complete 12127,1
>>Collect Filled Frost Gem
step
.goto Dragonblight,60.3,51.6
.fly Agmar's Hammer, Dragonblight >> Fly to Agmar's Hammer
>>Fly to Agmar's Hammer
step
.goto Dragonblight,37.1,46.5
.target Koltira Deathweaver
.turnin 12126 >> Turn in In Service of the Unholy
.turnin 12127 >> Turn in In Service of Frost
.accept 12132 >> Accept The Power to Destroy
step
>>He puts you in the world of shadows
>>They're all around town in Agmar's Hammer
.complete 12132,1
.mob Shadowy Tormentor
>>Kill Shadowy Tormentor
step
+Right click the World of Shadows buff at the top right of your screen to leave the world of shadows
step
.goto Dragonblight,37.1,46.5
.target Koltira Deathweaver
.turnin 12132 >> Turn in The Power to Destroy
.accept 12136 >> Accept The Translated Tome
step
.goto Dragonblight,36.1,48.9
.target Doctor Sintar Malefious
.turnin 12102 >> Turn in In Search of the Ruby Lilac
.accept 12104 >> Accept Return to Soar
step
.goto Dragonblight,35.8,48.4
.target Captain Gort
.turnin 12136 >> Turn in The Translated Tome
step
.goto Dragonblight,37.1,48.6
.target Soar Hawkfury
.turnin 12104 >> Turn in Return to Soar
.accept 12111 >> Accept Where the Wild Things Roam
step
.goto Dragonblight,38.4,48.3
.use 36818
>>Use your Pack of Vaccine and throw it at 5 Arctic Grizzlies and 5 Snowfall Elk
.complete 12111,1
>>Inoculate 5 Snowfall Elk
.complete 12111,2
>>Inoculate 5 Arctic Grizzlies
step
.goto Dragonblight,37.1,48.6
.target Soar Hawkfury
.turnin 12111 >> Turn in Where the Wild Things Roam
step
.goto Dragonblight,43,50.9
.target Vargastrasz
.turnin 12461 >> Turn in Report to the Ruby Dragonshrine
.accept 12448 >> Accept Heated Battle
step
.goto Dragonblight,42.8,51.4
>>Help kill the following:
.complete 12448,1
>>12 Frigid Ghoul Attackers
.complete 12448,2
>>8 Frigid Geist Attackers
.complete 12448,3
>>1 Frigid Abomination Attacker
step
.goto Dragonblight,43,50.9
>>Go up the hill to 43,50.9
.target Vargastrasz
.turnin 12448 >> Turn in Heated Battle
.accept 12449 >> Accept Return to the Earth
step
.goto Dragonblight,46.7,52.8
>>Click the Ruby Acorns - The Ruby Acorns look like red stones on the ground around this area
>>Collect Ruby Acorns
.use 37727
>>Use the Ruby Acorns on the Ruby Keeper corpses
.complete 12449,1
>>Return 6 Ruby Keepers to the Earth
step
.goto Dragonblight,43,50.9
>>Go out of the valley to 43,50.9
.target Vargastrasz
.turnin 12449 >> Turn in Return to the Earth
.accept 12450 >> Accept Through Fields of Flame
step
.goto Dragonblight,48.2,47.8
>>Go into the valley to 48.2,47.8
.complete 12450,1
.mob Frigid Necromancer
>>Kill Frigid Necromancer
step
.goto Dragonblight,47.7,49.1
>>Go into the tree trunk to 47.7,49.1
.mob Dahlia Suntouch
>>Kill Dahlia Suntouch
.complete 12450,2
>>Cleanse the Ruby Corruption
step
.goto Dragonblight,43.0,50.9
>>Go out of the valley to 43.0,50.9
.target Vargastrasz
.turnin 12450 >> Turn in Through Fields of Flame
.accept 12769 >> Accept The Steward of Wyrmrest Temple
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.turnin 12769 >> Turn in The Steward of Wyrmrest Temple
.accept 12124 >> Accept Informing the Queen
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.goto Dragonblight,59.7,53.1,0.5
>>Tell him you want to go to the top of the temple
step
.goto Dragonblight,59.8,54.7
.target Alexstrasza the Life-Binder
.turnin 12124 >> Turn in Informing the Queen
.accept 12435 >> Accept Report to Lord Afrasastrasz
step
.goto Dragonblight,59.5,53.3
.target Torastrasza
.goto Dragonblight,59.2,54.3,0.5
>>Tell him you want to go to Lord Afrasastrasz
step
.goto Dragonblight,59.2,54.3
.target Lord Afrasastrasz
.turnin 12435 >> Turn in Report to Lord Afrasastrasz
.accept 12372 >> Accept Defending Wyrmrest Temple
step
.xp 75
step
.goto Dragonblight,58.3,55.2
.target a Wyrmrest Defender
>>Tell him you are ready to get into the fight
>>Fly around Wyrmrest Temple fighting the blue dragons in the sky using your abilities on your hotbar
.complete 12372,1
.mob Azure Dragon
>>Kill Azure Dragon
.complete 12372,2
.mob Azure Drake
>>Kill Azure Drake
step
.goto Dragonblight,55.1,66.4
>>Fly southwest to 55.1,66.4
>>Fly into the huge purple swirling column
.macro Destabilize Azure Dragonshrine,134400 >>/cast Destabilize Azure Dragonshrine
>>Use your Destabilize Azure Dragonshrine ability
.complete 12372,3
>>Destabilize the Azure Dragonshrine
step
.goto Dragonblight,58.7,54.5
.exitvehicle
>>Click the red arrow to get off the dragon on the middle level of the temple
step
.goto Dragonblight,59.2,54.3
.target Lord Afrasastrasz
.turnin 12372 >> Turn in Defending Wyrmrest Temple
step
.goto Dragonblight,59.2,54.3
.target Lord Afrasastrasz
.goto Dragonblight,58.0,55.2,0.5
>>Tell him you want to go to the ground level
step
.goto Dragonblight,63.3,71
.mob Emerald Lashers
>>Kill Emerald Lashers
.complete 12458,1
>>Collect Lasher Seed
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.goto Dragonblight,59.7,53.1,0.5
>>Tell him you want to go to the top of the temple
step
.goto Dragonblight,59.6,54.4
.target Lord Itharius
.turnin 12458 >> Turn in Seeds of the Lashers
.accept 12459 >> Accept That Which Creates Can Also Destroy
step
.goto Dragonblight,59.5,53.3
.target Torastrasza
.goto Dragonblight,58.0,55.2,0.5
>>Tell him you want to go to the ground level of the temple
step
.goto Dragonblight,55.2,45.7
.use 37887
>>Use your Seeds of Nature's Wrath on a Reanimated Frost Wyrm to weaken it
.complete 12459,1
.mob Weakened Reanimated Frost Wyrm
>>Kill Weakened Reanimated Frost Wyrm
step
.goto Dragonblight,60.3,51.6
.fly Venomspite, Dragonblight >> Fly to Venomspite
>>Fly to Venomspite
step
.goto Dragonblight,87.2,57.4
.target Tilda Darathan
.accept 12542 >> Accept The Call Of The Crusade
step
.goto Dragonblight,86.2,47
.use 37887
>>Use your Seeds of Nature's Wrath on a Turgid the Vile to weaken him
.complete 12459,2
.mob Weakened Turgid the Vile
>>Kill Weakened Turgid the Vile
step
.goto Dragonblight,84,26.1
.target Crusader Valus
.turnin 12542 >> Turn in The Call Of The Crusade
.accept 12545 >> Accept The Cleansing Of Jintha'kalar
step
.goto Dragonblight,89.5,19.1
.use 37887
>>Use your Seeds of Nature's Wrath on Overseer Deathgaze to weaken him
.complete 12459,3
.mob Weakened Overseer Deathgaze
>>Kill Weakened Overseer Deathgaze
step
.goto Dragonblight,86.8,22.4
.mob undead mobs
>>Kill undead mobs
.complete 12545,1
>>Kill 15 Jintha'kalar Scourge
step
.goto Dragonblight,84,26.1
.target Crusader Valus
.turnin 12545 >> Turn in The Cleansing Of Jintha'kalar
.accept 12789 >> Accept Into the Breach!
step
.goto Dragonblight,71.7,38.9
.use 37923
>>Use your Hourglass of Eternity anywhere around this area
>>Fight the mobs that spawn
.complete 12470,1
>>Protect the Hourglass of Eternity
step
.goto Dragonblight,59.7,54.2,0.5
.hs >> Hearth to Wyrmrest Temple
>>Hearth to Wyrmrest Temple
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.goto Dragonblight,59.7,53.1,0.5
>>Tell him you want to go to the top of the temple
step
.goto Dragonblight,59.6,54.4
.target Lord Itharius
.turnin 12459 >> Turn in That Which Creates Can Also Destroy
step
.goto Dragonblight,60,54.5
.target Chromie
.turnin 12470 >> Turn in Mystery of the Infinite
step
.goto Dragonblight,59.5,53.3
.target Torastrasza
.goto Dragonblight,58.0,55.2,0.5
>>Tell him you want to go to the ground level of the temple
step
.goto Dragonblight,46.7,33.5
.target Kontokanis
.accept 12144 >> Accept Pest Control
step
.goto Dragonblight,37.2,31.8
.goto Dragonblight,37.2,31.8,0.3
>>The path to Serinar starts here
step
.goto Dragonblight,35.2,30.0
>>Go inside the cave to 35.2,30.0
.target Serinar
.turnin 12447 >> Turn in The Obsidian Dragonshrine
.accept 12262 >> Accept No One to Save You
.accept 12261 >> Accept No Place to Run
step
.goto Dragonblight,37.9,32.0
>>Go outside the cave to 37.9,32.0
.complete 12262,1
.mob Burning Depths Necrolyte
>>Kill Burning Depths Necrolyte
.complete 12262,2
.mob Smoldering Skeleton
>>Kill Smoldering Skeleton
step
.goto Dragonblight,42.1,32
.use 37445
>>Use your Destructive Wards in this spot
>>Defend the Destructive Ward from the mobs that spawn
.complete 12261,1
>>Fully Charge the Destructive Ward
step
.goto Dragonblight,35.2,30.0
>>Go west into the cave to 35.2,30.0
.target Serinar
.turnin 12262 >> Turn in No One to Save You
.turnin 12261 >> Turn in No Place to Run
.accept 12263 >> Accept The Best of Intentions
step
.goto Dragonblight,31.8,30.5
>>Follow the path in the cave while disguised as a cultist to 31.8,30.5
.complete 12263,1
>>Uncover the Magmawyrm Resurrection Chamber
step
.goto Dragonblight,35.2,30.0
>>Follow the path back down to 35.2,30.0
.target Serinar
.turnin 12263 >> Turn in The Best of Intentions
.accept 12264 >> Accept Culling the Damned
.accept 12265 >> Accept Defiling the Defilers
step
.goto Dragonblight,34.2,26.8
>>Follow the path in the cave to 34.2,26.8
.complete 12264,1
.mob Burning Depths Necromancer
>>Kill Burning Depths Necromancer
.complete 12264,2
.mob Smoldering Construct
>>Kill Smoldering Construct
.complete 12264,3
.mob Smoldering Geist
>>Kill Smoldering Geist
>>Click Necromantic Runes on the ground - The Necromantic Runes look like round purple symbols on the ground around this area in the cave
.complete 12265,1
>>Destroy 8 Necromantic Runes
step
.goto Dragonblight,35.2,30.0
>>Go back down in the cave to 35.2,30.0
.target Serinar
.turnin 12264 >> Turn in Culling the Damned
.turnin 12265 >> Turn in Defiling the Defilers
.accept 12267 >> Accept Neltharion's Flame
step
.goto Dragonblight,31.6,31.2
>>Follow the path in the cave to 31.6,31.2
.use 37539
>>Use Neltharion's Flame to Cleanse the Summoning Area
.complete 12267,2
.mob Rothin the Decaying
>>Kill Rothin the Decaying
step
.goto Dragonblight,35.2,30.0
>>Go back down in the cave to 35.2,30.0
.target Serinar
.turnin 12267 >> Turn in Neltharion's Flame
.accept 12266 >> Accept Tales of Destruction
step
.goto Dragonblight,59.7,54.2,0.3
.hs >> Hearth to Wyrmrest Temple
>>Hearth to Wyrmrest Temple
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.goto Dragonblight,59.7,53.1,0.5
>>Tell him you want to go to the top of the temple
step
.goto Dragonblight,60.1,54.2
.target Nalice
.turnin 12266 >> Turn in Tales of Destruction
step
.goto Dragonblight,59.5,53.3
.target Torastrasza
.goto Dragonblight,58.0,55.2,0.5
>>Tell him you want to go to the ground level of the temple
step
.goto Dragonblight,56.8,56.3
.complete 12144,2
>>Kill 3 Dragonblight Magnataurs
step
.goto Dragonblight,55.6,52.8
.complete 12144,1
>>Kill 10 Snowplain Snobolds
step
.goto Dragonblight,46.7,33.5
.target Kontokanis
.turnin 12144 >> Turn in Pest Control
.accept 12145 >> Accept Canyon Chase
step
.goto Dragonblight,42.4,38.9
>>Follow the running kobols to 42.4,38.9
.complete 12145,1
.mob Icefist
>>Kill Icefist
>>Collect Emblazoned Battle Horn
.use 36856
>>Click the Emblazoned Battle Horn
.accept 12147 >> Accept Disturbing Implications
step
.goto Dragonblight,46.7,33.5
.target Kontokanis
.turnin 12145 >> Turn in Canyon Chase
step
.goto Dragonblight,48.5,24.1
.target Nozzlerust Supply Runner
.accept 12469 >> Accept Return to Sender
step
.goto Dragonblight,54.5,23.6
.target Narf
.accept 12043 >> Accept Nozzlerust Defense
step
.goto Dragonblight,54.7,23.2
.target Zivlix
.accept 12045 >> Accept Shaved Ice
step
.goto Dragonblight,55,23.4
.target Xink
.turnin 12469 >> Turn in Return to Sender
.accept 12044 >> Accept Stocking Up
step
.goto Dragonblight,53.7,18.9
.mob Crystalline Ice Elementals
>>Kill Crystalline Ice Elementals
.complete 12045,1
>>Collect Ice Shard Cluster
step
.goto Dragonblight,54.7,23.2
.target Zivlix
.turnin 12045 >> Turn in Shaved Ice
.accept 12046 >> Accept Soft Packaging
step
.goto Dragonblight,53.7,25.4
.mob Jormungar Tunnelers
>>Kill Jormungar Tunnelers
.complete 12046,1
>>Collect Thin Animal Hide
step
.goto Dragonblight,54.7,23.2
.target Zivlix
.turnin 12046 >> Turn in Soft Packaging
.accept 12047 >> Accept Something That Doesn't Melt
step
.goto Dragonblight,55,23.4
.target Xink
.accept 12049 >> Accept Hard to Swallow
step
.goto Dragonblight,57.5,23.9
>>Click Splintered Bone Chunks - The Splintered Bone Chunks look like small white pointed bones on the ground next to the huge bones on the ground around this area
.complete 12047,1
>>Collect Splintered Bone Chunk
>>Fight a Hulking Jormungar
.use 36732
>>Use your Potent Explosive Charges on the Hulking Jormungar when he opens his mouth
>>Click the Jormungar Meat
.complete 12049,1
>>Collect Seared Jormungar Meat
step
.goto Dragonblight,55,23.4
.target Xink
.turnin 12049 >> Turn in Hard to Swallow
step
.goto Dragonblight,54.7,23.2
.target Zivlix
.turnin 12047 >> Turn in Something That Doesn't Melt
step
.goto Dragonblight,54.5,23.6
.target Narf
.accept 12052 >> Accept Harp on This!
step
.goto Dragonblight,55,23.4
.target Xink
.accept 12050 >> Accept Lumber Hack
step
.goto Dragonblight,53.1,19.5
>>Use Xink's Shredder Control Device
>>Click the shredder to ride it
.complete 12052,2
>>Kill 15 Coldwind Harpies
.macro Gather Lumber,134400 >>/cast Gather Lumber
>>Use your Gather Lumber ability next to Coldwind Trees
.complete 12050,1
>>Collect Coldwind Lumber
step
.goto Dragonblight,44.9,9.1
.complete 12052,1
.mob Mistress of the Coldwind
>>Kill Mistress of the Coldwind
step
.goto Dragonblight,54.5,23.6
.target Narf
.turnin 12052 >> Turn in Harp on This!
step
.goto Dragonblight,55,23.4
.target Xink
.turnin 12050 >> Turn in Lumber Hack
step
.goto Dragonblight,54.5,23.6
.target Narf
.accept 12112 >> Accept Stiff Negotiations
step
.goto Dragonblight,52.4,30.4
.complete 12043,2
.mob Wastes Digger
>>Kill Wastes Digger
.complete 12043,1
.mob Wastes Taskmaster
>>Kill Wastes Taskmaster
>>Click Composite Ore - They look like carts with ore piled in them
.complete 12044,1
>>Collect Composite Ore
>>You can find more of all of these at 56.5,28.1
step
.goto Dragonblight,54.5,23.6
.target Narf
.turnin 12043 >> Turn in Nozzlerust Defense
step
.goto Dragonblight,55,23.4
.target Xink
.turnin 12044 >> Turn in Stocking Up
step
.goto Dragonblight,59.4,18.2
.target Zort
.turnin 12112 >> Turn in Stiff Negotiations
.accept 12075 >> Accept Slim Pickings
step
.goto Dragonblight,56.2,12.0
>>Go into the cave to 56.2,12.0
>>Click the Ravaged Crystalline Ice Giant - It's an ice giant corpse laying inside this cave
.complete 12075,1
>>Collect Sample of Rockflesh
step
.goto Dragonblight,59.4,18.2
.target Zort
.turnin 12075 >> Turn in Slim Pickings
.accept 12076 >> Accept Messy Business
step
.goto Dragonblight,59,17.8
.target Ko'char the Unbreakable
.accept 12079 >> Accept Stomping Grounds
step
.goto Dragonblight,57.5,12.4
>>Fight Ice Heart Jormungar Feeders
>>They will cast a poison on you
.use 36775
>>Use Zort's Scraper when you are affected by the poison
.complete 12076,1
>>Collect Vial of Corrosive Spit
.complete 12079,1
.mob Ice Heart Jormungar Feeder
>>Kill Ice Heart Jormungar Feeder
step
.goto Dragonblight,59.4,18.2
>>Go outside the cave to 59.4,18.2
.target Zort
.turnin 12076 >> Turn in Messy Business
.accept 12077 >> Accept Apply This Twice A Day
step
.goto Dragonblight,59,17.8
.target Ko'char the Unbreakable
.turnin 12077 >> Turn in Apply This Twice A Day
.turnin 12079 >> Turn in Stomping Grounds
step
.goto Dragonblight,59.4,18.2
.target Zort
.accept 12078 >> Accept Worm Wrangler
step
.goto Dragonblight,55.3,11.0
>>Go into the cave to 55.3,11.0
.use 36771
>>Use your Sturdy Crates on Ice Heart Jormungar Spawns
>>Click the Captured Jormungar Spawn crates
.complete 12078,1
>>Collect Captured Jormungar Spawn
step
.goto Dragonblight,59.4,18.2
>>Go outside the cave to 59.4,18.2
.target Zort
.turnin 12078 >> Turn in Worm Wrangler
step
.goto Dragonblight,59.7,54.2,0.5
.hs >> Hearth to Wyrmrest Temple
>>Hearth to Wyrmrest Temple
step
.goto Dragonblight,60,55.2
.target Aurastasza
.turnin 12147 >> Turn in Disturbing Implications
step
.fly Agmar's Hammer, Dragonblight >> Fly to Agmar's Hammer
>>Fly to Agmar's Hammer
step
.goto Dragonblight,36.3,45.6
.target Overlord Agmar
.accept 12224 >> Accept The Kor'kron Vanguard!
step
.goto Dragonblight,40.7,18.1
.target Saurfang the Younger
.turnin 12224 >> Turn in The Kor'kron Vanguard!
.accept 12496 >> Accept Audience With The Dragon Queen
step
.goto Dragonblight,43.8,16.9
.target Numo Spiritbreeze
.fp Kor'kron Vanguard, Dragonblight >> Get the Kor'kron Vanguard flight path
step
.fly Wyrmrest Temple, Dragonblight >> Fly to Wyrmrest Temple
>>Fly to Wyrmrest Temple
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.goto Dragonblight,59.7,53.1,0.5
>>Tell him you want to go to the top of the temple
step
.goto Dragonblight,59.8,54.7
.target Alexstrasza the Life-Binder
.turnin 12496 >> Turn in Audience With The Dragon Queen
.accept 12497 >> Accept Galakrond and the Scourge
step
.goto Dragonblight,59.5,53.3
.target Torastrasza
.turnin 12497 >> Turn in Galakrond and the Scourge
.accept 12498 >> Accept On Ruby Wings
step
.use 38302
>>Use your Ruby Beacon of the Dragon Queen
.vehicle
>>Click the red dragon to ride it
step
.goto Dragonblight,57.2,33.1
>>Fly to 57.2,33.1
>>Use the abilities on your hotbar
.complete 12498,1
.mob Wastes Scavenger
>>Kill Wastes Scavenger
step
.goto Dragonblight,54.5,31.3
>>Fly to 54.5,31.3
>>Use the abilities on your hotbar
.mob Thiassi the Lightning Bringer
>>Kill Thiassi the Lightning Bringer
.exitvehicle
>>Jump off the dragon
.mob Grand Necrolord Antiok
>>Kill Grand Necrolord Antiok
>>Click the Scythe of Antiok
.complete 12498,2
>>Collect Scythe of Antiok
step
.use 38302
>>Use your Ruby Beacon of the Dragon Queen
.vehicle
>>Click the red dragon to ride it
step
.goto Dragonblight,59.8,54.7
>>Fly to 59.8,54.7
.exitvehicle
>>Jump off the dragon
.target Alexstrasza the Life-Binder
.turnin 12498 >> Turn in On Ruby Wings
.accept 12500 >> Accept Return To Angrathar
step
.goto Dragonblight,59.5,53.3
.target Torastrasza
.goto Dragonblight,58.0,55.2,0.5
>>Tell him you want to go to the ground level of the temple
step
.fly Kor'kron Vanguard, Dragonblight >> Fly to Kor'kron Vanguard
>>Fly to Kor'kron Vanguard
step
.goto Dragonblight,40.7,18.1
.target Saurfang the Younger
.turnin 12500 >> Turn in Return To Angrathar
step
.goto Dragonblight,38.5,19.3
.target Alexstrasza the Life-Binder
.accept 13242 >> Accept Darkness Stirs
step
.goto Dragonblight,38.2,18.7
>>Click Saurfang's Battle Armor - It's a tiny helmet on the ground, next to a bunch of flowers
.complete 13242,1
>>Collect Saurfang's Battle Armor
step
.goto Dragonblight,43.8,16.9
.target Numo Spiritbreeze
.fly Warsong Hold, Borean Tundra >> Fly to Warsong Hold
>>Fly to Warsong Hold
step
.goto Borean Tundra,41.4,53.7
>>Go downstairs to 41.4,53.7
.target High Overlord Saurfang
.turnin 13242 >> Turn in Darkness Stirs
.accept 13257 >> Accept Herald of War
step
.zone Durotar
>>Click the Portal to Orgrimmar that spawns in the middle of the room
step
.zone Orgrimmar
>>Go inside Orgrimmar
step
.goto Orgrimmar,31.8,37.8
.target Thrall
.turnin 13257 >> Turn in Herald of War
.accept 13266 >> Accept A Life Without Regret
step
.zone Tirisfal Glades
>>Click a Portal to Undercity that spawns in the middle of the room to go to Undercity
step
.goto Tirisfal Glades,61.7,62.7
.target Vol'jin
.turnin 13266 >> Turn in A Life Without Regret
.accept 13267 >> Accept The Battle For The Undercity
step
.goto Tirisfal Glades,62,62.7
.target Thrall
>>Tell him you are ready
>>Wait for the battle to begin
>>Help Thrall and Lady Sylvanas Windrunner take control of Undercity
>>After the battle, talk to Thrall
.turnin 13267 >> Turn in The Battle For The Undercity
step
.zone Borean Tundra
>>Ride the zeppelin to Borean Tundra
step
.fly Agmar's Hammer, Dragonblight >> Fly to Agmar's Hammer
>>Fly to Agmar's Hammer
step
.goto Dragonblight,38.1,46.2
.target Image of Archmage Aethas Sunreaver
.zone Dalaran
>>Teleport to Dalaran
step
.goto Dalaran,56.3,46.8
>>Go downstairs to 56.3,46.8
.target Archmage Celindra
.turnin 12791 >> Turn in The Magical Kingdom of Dalaran
.accept 12790 >> Accept Learning to Leave and Return: the Magical Way
step
.goto Dalaran,56.3,46.8
>>Click the Teleport to Violet Stand Crystal - Downstrairs in a small room. It's a blue floating trianglular jewel
.complete 12790,1
>>Use the Teleport to Violet Stand Crystal
step
.goto Crystalsong Forest,15.8,42.5
>>Click the Teleport to Dalaran Crystal - It's a blue triangular crystal floating about a blue and purple symbol on the ground
.complete 12790,2
>>Use the Teleport to Dalaran Crystal
step
.goto Dalaran,56.3,46.8
>>Go downstairs to 56.3,46.8
.target Archmage Celindra
.turnin 12790 >> Turn in Learning to Leave and Return: the Magical Way
step
.goto Dalaran,72.2,45.8
.target Aludane Whitecloud
.fp Dalaran >> Get the Dalaran flight path
step
.goto Dalaran,45.4,40.8
>>Go underground into the sewer to 45.4,40.8
.target Shifty Vickers
.accept 12974 >> Accept The Champion's Call!
step
.goto Dalaran,30.6,48.6
>>Go outside the sewer to 30.6,48.6
.target Rhonin
.accept 13158 >> Accept Discretion is Key
step
.goto Dalaran,61.3,63.7
.target Warden Alturas
.turnin 13158 >> Turn in Discretion is Key
step
.fly Venomspite, Dragonblight >> Fly to Venomspite
>>Fly to Venomspite
step
.zone Grizzly Hills
>>Go east to the Grizzly Hills
step
.goto Grizzly Hills,22.7,66.2
.target Provisioner Lorkran
.accept 12436 >> Accept Supplemental Income
step
.goto Grizzly Hills,22,65.1
.target Hidetrader Jun'ik
.accept 12175 >> Accept Gray Worg Hides
step
.goto Grizzly Hills,22,64.4
.target Kragh
.fp Conquest Hold, Grizzly Hills >> Get the Conquest Hold flight path
step
.home Conquest Hold >> Set your Hearthstone to Conquest Hold
step
.goto Grizzly Hills,20.7,64.2
.target Conqueror Krenna
.turnin 12487 >> Turn in To Conquest Hold, But Be Careful!
.accept 12468 >> Accept The Conqueror's Task
step
.goto Grizzly Hills,21,64.1
.target Sergeant Nazgrim
.turnin 12468 >> Turn in The Conqueror's Task
.accept 12257 >> Accept A Show of Strength
.accept 12256 >> Accept The Flamebinders' Secrets
step
.goto Grizzly Hills,24.7,66.9
.mob Graymist Hunters
>>Kill Graymist Hunters
.complete 12175,1
>>Collect Gray Worg Hide
step
.goto Grizzly Hills,24.4,60.7
.mob Tallhorn Stags
>>Kill Tallhorn Stags
.complete 12436,1
>>Collect Succulent Venison
step
.goto Grizzly Hills,22.7,66.2
.target Provisioner Lorkran
.turnin 12436 >> Turn in Supplemental Income
step
.goto Grizzly Hills,22,65.1
.target Hidetrader Jun'ik
.turnin 12175 >> Turn in Gray Worg Hides
.accept 12176 >> Accept A Minor Substitution
step
.goto Grizzly Hills,28.4,56.5
.mob Grizzly Bears
>>Kill Grizzly Bears
.complete 12176,1
>>Collect Grizzly Hide
step
.goto Grizzly Hills,22,65.1
.target Hidetrader Jun'ik
.turnin 12176 >> Turn in A Minor Substitution
.accept 12177 >> Accept Jun'ik's Coverup
step
.goto Grizzly Hills,22.7,66.2
.target Provisioner Lorkran
.complete 12177,2
>>Buy buy 5 Simple Flour
step
.goto Grizzly Hills,23.4,63.1
.target Smith Prigka
.complete 12177,1
>>Buy buy 1 Coal
step
.goto Grizzly Hills,22,65.1
.target Hidetrader Jun'ik
.turnin 12177 >> Turn in Jun'ik's Coverup
.accept 12178 >> Accept Delivery to Krenna
step
.goto Grizzly Hills,20.7,64.2
.target Conqueror Krenna
.turnin 12178 >> Turn in Delivery to Krenna
step
.goto Grizzly Hills,33.6,79
.complete 12257,1
.mob Dragonflayer Huscarl
>>Kill Dragonflayer Huscarl
.mob Dragonflayer Flamebinders
>>Kill Dragonflayer Flamebinders
.complete 12256,1
>>Collect Flame-Imbued Talisman
step
.goto Grizzly Hills,21,64.1
.target Sergeant Nazgrim
.turnin 12257 >> Turn in A Show of Strength
.turnin 12256 >> Turn in The Flamebinders' Secrets
.accept 12259 >> Accept The Thane of Voldrune
step
.goto Grizzly Hills,26.6,77.9
.target Flamebringer
.vehicle
>>Unchain and control Flamebringer
step
.goto Grizzly Hills,27.1,73.0
>>Fly to 27.1,73.0
>>Use the abilities on your hotbar
.complete 12259,1
.mob Thane Torvald Eriksson
>>Kill Thane Torvald Eriksson
step
.goto Grizzly Hills,21,64.1
.target Sergeant Nazgrim
.turnin 12259 >> Turn in The Thane of Voldrune
.accept 12451 >> Accept Onward to Camp Oneqwah
step
.goto Grizzly Hills,20.7,64.2
.target Conqueror Krenna
.accept 12412 >> Accept My Enemy's Friend
step
.goto Grizzly Hills,36.3,67.9
.complete 12412,2
.mob Vladek
>>Kill Vladek
>>Collect Mikhail's Journal
.use 37830
>>Click Mikhail's Journal
.accept 12423 >> Accept Mikhail's Journal
step
.goto Grizzly Hills,35.2,69.9
.complete 12412,1
.mob Silverbrook Hunter
>>Kill Silverbrook Hunter
step
.goto Grizzly Hills,20.7,64.2
.target Conqueror Krenna
.turnin 12412 >> Turn in My Enemy's Friend
.accept 12413 >> Accept Attack on Silverbrook
.turnin 12423 >> Turn in Mikhail's Journal
.accept 12424 >> Accept Gorgonna
step
.goto Grizzly Hills,21,64
.target Gorgonna
.turnin 12424 >> Turn in Gorgonna
.accept 12422 >> Accept Tactical Clemency
step
.goto Grizzly Hills,22.2,64.7
.target Sergeant Thurkin
.accept 12208 >> Accept Good Troll Hunting
step
.goto Grizzly Hills,22.5,62.8
.target Windseer Grayhorn
.accept 12453 >> Accept Eyes Above
step
.goto Grizzly Hills,16.2,47.6
.target Samir
.turnin 12208 >> Turn in Good Troll Hunting
.accept 11984 >> Accept Filling the Cages
step
.goto Grizzly Hills,16.4,48.3
.target Budd
>>Tell him it's time to play with the ice trolls
step
.goto Grizzly Hills,13.2,60.5
.macro Tag Troll,134400 >>/cast Tag Troll
>>Use Budd's pet bar skill Tag Troll to have him stun a troll
.use 35736
>>Use your Bounty Hunter's Cage on the stunned troll
.complete 11984,1
>>Capture a Live Ice Troll
step
.goto Grizzly Hills,16.2,47.6
.target Samir
.turnin 11984 >> Turn in Filling the Cages
step
.goto Grizzly Hills,16.4,47.8
.target Drakuru
.accept 11989 >> Accept Truce?
step
.goto Grizzly Hills,16.5,47.8
>>Click the Dull Carving Knife - It's a knife stuck in the side of this tree trunk
.collect 38083,1,11989 >> Collect 1 Dull Carving Knife
step
.goto Grizzly Hills,16.4,47.8
.use 38083
>>Use your Dull Carving Knife next to the yellow cage
.target Drakuru
>>Shake his hand
.complete 11989,1
>>Make a Blood Pact With Drakuru
step
.goto Grizzly Hills,16.4,47.8
.target Drakuru
.turnin 11989 >> Turn in Truce?
.accept 11990 >> Accept Vial of Visions
step
.goto Grizzly Hills,16,47.8
.target Ameenah
.complete 11990,1
>>Buy buy 1 Imbued Vial
step
.goto Grizzly Hills,14.6,45.3
>>Click the Hazewood Bushes - They look like small flower bushes on the ground around this area
.complete 11990,2
>>Collect Haze Leaf
step
.goto Grizzly Hills,15.2,40.3
>>Click a Waterweed - They look like big green bushes underwater around this area
.complete 11990,3
>>Collect Waterweed Frond
step
.goto Grizzly Hills,16.4,47.8
.target Drakuru
.turnin 11990 >> Turn in Vial of Visions
.accept 11991 >> Accept Subject to Interpretation
step
.goto Grizzly Hills,15.7,46.7
.target Prigmon
.accept 12484 >> Accept Scourgekabob
step
.goto Grizzly Hills,15.7,46.9
>>Click a Scourged Troll Mummy on the ground next to you
.collect 38149,1,12484 >> Collect 1 Scourged Troll Mummy
step
.goto Grizzly Hills,16.9,48.3
.use 38149
>>Use your Scourged Troll Mummy next to the burning pile of mummies
.complete 12484,1
>>Burn a Mummified Carcass
step
.goto Grizzly Hills,16.7,48.3
.target Mack Fearsen
.turnin 12484 >> Turn in Scourgekabob
.accept 12029 >> Accept Seared Scourge
step
.goto Grizzly Hills,15.7,46.7
.target Prigmon
.accept 12483 >> Accept Shimmercap Stew
step
.goto Grizzly Hills,11.1,61.8
>>Click the Shimmering Snowcaps - They look like blue glowing mushrooms on the ground at the base of the trees around this area
.complete 12483,2
>>Collect Shimmering Snowcap
step
.goto Grizzly Hills,13.3,58.5
.mob Ice Serpents
>>Kill Ice Serpents
.complete 12483,1
>>Collect Ice Serpent Eye
.mob trolls
>>Kill trolls
.collect 35799,5,11991 >> Collect 5 Frozen Mojo
step
.goto Grizzly Hills,13.2,60.9
.use 35797
>>Use Drakuru's Elixir next to Drakuru's Brazier
.target Image of Drakuru
.turnin 11991 >> Turn in Subject to Interpretation
.accept 12007 >> Accept Sacrifices Must be Made
step
.goto Grizzly Hills,18.4,38.5
>>Click the Sweetroot plants - They look like aloe vera plants around this area
.complete 12483,3
>>Collect Sweetroot
step
.goto Grizzly Hills,14.5,38
.mob Warlord Zim'bo
>>Kill Warlord Zim'bo
.collect 35836,1,12007 >> Collect 1 Zim'bo's Mojo
step
.goto Grizzly Hills,17.9,36.5
>>Go up the huge stairs to 17.9,36.5
>>Click the Seer of Zeb'Halak statue - It's a huge blue glowing statue at the top of the stairs
.complete 12007,1
>>Collect Eye of the Prophets
step
.goto Grizzly Hills,17.4,36.4
.use 35797
>>Use Drakuru's Elixir next to Drakuru's Brazier
.target Image of Drakuru
.turnin 12007 >> Turn in Sacrifices Must be Made
.accept 12042 >> Accept Heart of the Ancients
step
.goto Grizzly Hills,16,29.9
>>Jump on the big rock and stand on it
.use 35908
>>Use Mack's Dark Grog and throw it at the trolls running around to the north
.complete 12029,1
>>Burn 20 Scourge Trolls
step
.goto Grizzly Hills,21.9,29.9
.target Captured Trapper
.turnin 12422 >> Turn in Tactical Clemency
step
.goto Grizzly Hills,24,33.6
.complete 12413,1
.mob Silverbrook Defender
>>Kill Silverbrook Defender
step
.goto Grizzly Hills,36.9,32.4
>>Go on top of the control station to 36.9,32.4
>>Click the Heart of the Ancients - It's a small pointed stone laying on the floor at the top of this control station, in a small room, next to a dead goblin
.turnin 12042 >> Turn in Heart of the Ancients
.accept 12802 >> Accept My Heart is in Your Hands
step
.goto Grizzly Hills,44.2,30.4
.mob Drakkari Defenders
>>Kill Drakkari Defenders
.collect 36743,5,12802 >> Collect 5 Desperate Mojo
step
.goto Grizzly Hills,45,28.4
.use 35797
>>Use Drakuru's Elixir next to Drakuru's Brazier
.target Image of Drakuru
.turnin 12802 >> Turn in My Heart is in Your Hands
.accept 12068 >> Accept Voices From the Dust
step
.goto Grizzly Hills,20.9,64.5,0.5
.hs >> Hearth to Conquest Hold
>>Hearth to Conquest Hold
step
.goto Grizzly Hills,20.7,64.2
.target Conqueror Krenna
.turnin 12413 >> Turn in Attack on Silverbrook
step
.goto Grizzly Hills,22.5,62.8
.target Windseer Grayhorn
.accept 12207 >> Accept Vordrassil's Fall
.accept 12213 >> Accept The Darkness Beneath
step
.goto Grizzly Hills,16.7,48.3
.target Mack Fearsen
.turnin 12029 >> Turn in Seared Scourge
step
.goto Grizzly Hills,15.7,46.7
.target Prigmon
.turnin 12483 >> Turn in Shimmercap Stew
.accept 12190 >> Accept Say Hello to My Little Friend
step
.goto Grizzly Hills,26.5,46.6
.mob Entropic Oozes
>>Kill Entropic Oozes
.complete 12207,1
>>Collect Slime Sample
step
.goto Grizzly Hills,28.6,45.1
.goto Grizzly Hills,28.6,45.1,0.3
>>The path down to Vordrassil's Tears starts here
step
.goto Grizzly Hills,30.5,43.9
>>Go underground to 30.5,43.9
.use 37173
>>Use your Geomancer's Orb
.complete 12213,3
>>Use the Orb beneath Vordrassil's Tears
step
.goto Grizzly Hills,33.3,48.5
>>Go outside the tunnel to 33.3,48.5
.goto Grizzly Hills,33.3,48.5,0.3
>>The path down to Vordrassil's Limb starts here
step
.goto Grizzly Hills,32.2,45.8
>>Go underground to 32.2,45.8
.use 37173
>>Use your Geomancer's Orb
.complete 12213,2
>>Use the Orb beneath Vordrassil's Limb
step
.goto Grizzly Hills,40.7,52
>>Go outside the tunnel to 40.7,52
.goto Grizzly Hills,40.7,52,0.3
>>The path down to Vordrassil's Heart starts here
step
.goto Grizzly Hills,41.2,54.7
>>Go underground to 41.2,54.7
.use 37173
>>Use your Geomancer's Orb
.complete 12213,1
>>Use the Orb beneath Vordrassil's Heart
step
.goto Grizzly Hills,43.8,53.3
>>Go outside the tunnel to 43.8,53.3
.use 37877
>>Use your Silver Feather on Imperial Eagles
.complete 12453,1
>>Bind 6 Imperial Eagles' sight
step
.goto Grizzly Hills,65,46.9
.target Makki Wintergale
.fp Camp Oneqwah, Grizzly Hills >> Get the Camp Oneqwah flight path
step
.goto Grizzly Hills,65,47.9
.target Soulok Stormfury
.accept 12415 >> Accept The Horse Hollerer
step
.goto Grizzly Hills,65.2,47.7
.target Scout Vor'takh
.turnin 12451 >> Turn in Onward to Camp Oneqwah
.accept 12074 >> Accept An Expedient Ally
step
.goto Grizzly Hills,65.3,47.5
.target Tormak the Scarred
.accept 12195 >> Accept The Unexpected 'Guest'
step
.home Camp Oneqwah >> Set your Hearthstone to Camp Oneqwah
step
.fly Conquest Hold, Grizzly Hills >> Fly to Conquest Hold
>>Fly to Conquest Hold
step
.goto Grizzly Hills,21,64
.target Gorgonna
.accept 12425 >> Accept Ruuna the Blind
step
.goto Grizzly Hills,22.5,62.8
.target Windseer Grayhorn
.turnin 12207 >> Turn in Vordrassil's Fall
.turnin 12213 >> Turn in The Darkness Beneath
.turnin 12453 >> Turn in Eyes Above
.accept 12229 >> Accept A Possible Link
.accept 12231 >> Accept The Bear God's Offspring
step
.fly Camp Oneqwah, Grizzly Hills >> Fly to Camp Oneqwah
>>Fly to Camp Oneqwah
step
.goto Grizzly Hills,60.4,54.3
.mob Silvercoat Stags
>>Kill Silvercoat Stags
.complete 12195,1
>>Collect Mature Stag Horn
>>another spot where you can find them is at 57.3,48.2
step
.goto Grizzly Hills,66.9,62.4
.target Kodian
.complete 12231,2
>>Listen to Kodian's Story
step
.goto Grizzly Hills,63.6,57.9
.mob Redfang furbolgs
>>Kill Redfang furbolgs
.complete 12229,1
>>Collect Crazed Furbolg Blood
step
.goto Grizzly Hills,48.1,58.9
.target Orsonn
.complete 12231,1
>>Listen to Orsonn's Story
step
.goto Grizzly Hills,44,47.9
.target Ruuna the Blind
.turnin 12425 >> Turn in Ruuna the Blind
.accept 12328 >> Accept Ruuna's Request
step
.goto Grizzly Hills,46.8,35.7
.mob Fern Feeder Moths
>>Kill Fern Feeder Moths
.complete 12328,1
>>Collect Gossamer Dust
step
.goto Grizzly Hills,44,47.9
.target Ruuna the Blind
.turnin 12328 >> Turn in Ruuna's Request
.accept 12327 >> Accept Out of Body Experience
step
.use 37661
>>Drink the Gossamer Potion in your bags next to Ruuna's Crystal Ball right next to you
.complete 12327,1
>>See the Vision from the Past
step
.xp 76
]]);
RXPGuides.RegisterGuide([[
#wotlk
#ac335
#version 1
#group RestedXP WotLK Guide (H)
#subgroup Northrend 70-80
<< Horde
#name 76-78 Northrend
#next 78-80 Northrend
step
.goto Grizzly Hills,44,47.9
.target Ruuna the Blind
.turnin 12327 >> Turn in Out of Body Experience
.accept 12329 >> Accept Fate and Coincidence
step
.goto Grizzly Hills,57.5,41.3
.target Sasha
.turnin 12329 >> Turn in Fate and Coincidence
.accept 12134 >> Accept Sasha's Hunt
.accept 12330 >> Accept Anatoly Will Talk
step
.goto Grizzly Hills,60.4,40.2
.complete 12134,1
.mob Solstice Hunter
>>Kill Solstice Hunter
step
.goto Grizzly Hills,62.3,42
.use 37665
>>Use your Tranquilizer Dart on Tatjana
>>Click the horse to jump on it
.complete 12330,1
>>Deliver Tatjana
step
.goto Grizzly Hills,57.5,41.3
.target Sasha
.turnin 12134 >> Turn in Sasha's Hunt
.turnin 12330 >> Turn in Anatoly Will Talk
.accept 12411 >> Accept A Sister's Pledge
step
.goto Grizzly Hills,64.8,43.4
.target Anya
.turnin 12411 >> Turn in A Sister's Pledge
step
.goto Grizzly Hills,65.3,47.5
.target Tormak the Scarred
.turnin 12195 >> Turn in The Unexpected 'Guest'
.accept 12165 >> Accept An Intriguing Plan
step
.goto Grizzly Hills,69.1,40.1
.target Hugh Glass
.accept 12279 >> Accept A Bear of an Appetite
step
.goto Grizzly Hills,73.8,34
.target Harkor
.turnin 12190 >> Turn in Say Hello to My Little Friend
.accept 12113 >> Accept Nice to Meat You
.accept 12114 >> Accept Therapy
step
.goto Grizzly Hills,73.9,34.1
.target Kraz
.accept 12116 >> Accept It Takes Guts....
step
.goto Grizzly Hills,72.7,37.6
.mob Longhoof Grazers
>>Kill Longhoof Grazers
.complete 12113,2
>>Collect Shovelhorn Steak
.mob Duskhowl Prowlers
>>Kill Duskhowl Prowlers
.complete 12113,1
>>Collect Fibrous Worg Meat
step
.goto Grizzly Hills,61.6,32.6
.use 37716
>>Use your Flashbang Grenade on Highland Mustangs
.complete 12415,1
>>Frighten 15 Highland Mustangs
step
.goto Grizzly Hills,64.3,15.0
.goto Grizzly Hills,64.3,15.0,0.3
>>The path up to Kurun starts here
step
.goto Grizzly Hills,65.8,17.8
>>Follow the road into the mountains around to 65.8,17.8
.target Kurun
.turnin 12074 >> Turn in An Expedient Ally
.accept 11982 >> Accept Raining Down Destruction
step
.goto Grizzly Hills,66.1,13.8
>>Click the Boulders - The Boulders look like huge rocks on the ground around this area
.collect 35734,5,11982 >> Collect 5 Boulder
>>Walk over to the nearby trench cliff
.use 35734
>>Use your Boulders on Iron Rune mobs below
.complete 11982,1
>>Disrupt 5 Iron Dwarf Operations
step
.goto Grizzly Hills,65.8,17.8
.target Kurun
.turnin 11982 >> Turn in Raining Down Destruction
.accept 12070 >> Accept Rallying the Troops
step
.goto Grizzly Hills,68.3,10.1
.use 36764
>>Use your Shard of the Earth on Grizzly Hills Giants that are physically fighting another mob
.complete 12070,1
>>Rally 5 Grizzly Hills Giants
.complete 12070,2
>>Kill 5 Iron Rune Avengers that spawn
step
.goto Grizzly Hills,65.8,17.8
.target Kurun
.turnin 12070 >> Turn in Rallying the Troops
.accept 11985 >> Accept Into the Breach
step
.goto Grizzly Hills,64.3,19.8
>>Click the Battered Journal - It's a thick book sitting on the ground
.accept 12026 >> Accept The Damaged Journal
step
>>They look like torn pages that spawn all around this area on the ground
>>Click the Missing Journal Pages
.collect 35737,8,12026 >> Collect 8 Missing Journal Page
.use 35739
>>Click the Incomplete Journal in your bags
.complete 12026,1
>>Collect Brann Bronzebeard's Journal
step
.goto Grizzly Hills,70.2,13.0
>>Go into the building to 70.2,13.0
.complete 11985,1
.mob Iron Thane Argrum
>>Kill Iron Thane Argrum
step
.goto Grizzly Hills,65.8,17.8
>>Go out of the building and up the path to 65.8,17.8
.target Kurun
.turnin 11985 >> Turn in Into the Breach
.accept 12081 >> Accept Gavrock
step
.goto Grizzly Hills,70.5,27.4
.complete 12114,1
.mob Drakkari Protector
>>Kill Drakkari Protector
.complete 12114,2
.mob Drakkari Oracle
>>Kill Drakkari Oracle
.mob Drakkari mobs
>>Kill Drakkari mobs
.collect 36758,5,12068 >> Collect 5 Sacred Mojo
step
.goto Grizzly Hills,70.8,21.8
>>Go inside the underground crypt to 70.8,21.8
>>Click the Drakkari Canopic Jars - They look like small gray urns sitting against the walls inside this underground crypt
.complete 12116,1
>>Collect Drakkari Canopic Jar
step
.goto Grizzly Hills,69.4,18.2
>>Inside the crypt, go to 69.4,18.2
>>Click the Drakkari Tablets - It's a big stone tablet in the corner of a small room inside this underground crypt
.complete 12068,1
>>Collect Drakkari Tablets
step
.goto Grizzly Hills,69.5,17.5
>>Inside the crypt, go to 69.5,17.5
.target Harrison Jones
.accept 12082 >> Accept Dun-da-Dun-tah!
.complete 12082,1
>>Escort Harrison from the Drakil'jin Ruins
step
.goto Grizzly Hills,71.7,26.2
.use 35797
>>Use Drakuru's Elixir next to Drakuru's Brazier
.target Image of Drakuru
.turnin 12068 >> Turn in Voices From the Dust
step
.goto Grizzly Hills,75.5,26.9
.use 37542
>>Use your Fishing Net on Schools of Northern Salmon
.complete 12279,1
>>Collect Northern Salmon
step
.goto Grizzly Hills,79.8,33.6
.target Gavrock
.turnin 12081 >> Turn in Gavrock
.accept 12093 >> Accept Runes of Compulsion
step
.goto Grizzly Hills,79.1,43.3
.mob Iron Rune-Weavers
>>Kill Iron Rune-Weavers
.complete 12093,4
.mob Overseer Brunon
>>Kill Overseer Brunon
step
.goto Grizzly Hills,75.3,36.7
.mob Iron Rune-Weavers
>>Kill Iron Rune-Weavers
.complete 12093,3
.mob Overseer Lochli
>>Kill Overseer Lochli
step
.goto Grizzly Hills,73.9,34.1
.target Kraz
.turnin 12116 >> Turn in It Takes Guts....
.accept 12120 >> Accept Drak'aguul's Mallet
step
.goto Grizzly Hills,73.8,34
.target Harkor
.turnin 12113 >> Turn in Nice to Meat You
.turnin 12114 >> Turn in Therapy
.turnin 12082 >> Turn in Dun-da-Dun-tah!
step
.goto Grizzly Hills,72.1,33.9
.mob Iron Rune-Weavers
>>Kill Iron Rune-Weavers
.complete 12093,2
.mob Overseer Korgan
>>Kill Overseer Korgan
step
.goto Grizzly Hills,67.7,29.6
.mob Iron Rune-Weavers
>>Kill Iron Rune-Weavers
.complete 12093,1
.mob Overseer Durval
>>Kill Overseer Durval
step
.goto Grizzly Hills,71.6,28.1
.mob Drak'aguul
>>Kill Drak'aguul
.complete 12120,1
>>Collect Drakil'jin Mallet
step
.goto Grizzly Hills,73.9,34.1
.target Kraz
.turnin 12120 >> Turn in Drak'aguul's Mallet
.accept 12121 >> Accept See You on the Other Side
step
.goto Grizzly Hills,79.8,33.6
.target Gavrock
.turnin 12093 >> Turn in Runes of Compulsion
.accept 12094 >> Accept Latent Power
step
.goto Grizzly Hills,78.8,39.9
.use 36787
>>Use your Shard of Gavrock next to the Second Ancient Stone
.complete 12094,2
>>Draw Power from the Second Ancient Stone
step
.goto Grizzly Hills,74.1,44.3
.use 36787
>>Use your Shard of Gavrock next to the Third Ancient Stone
.complete 12094,3
>>Draw Power from the Third Ancient Stone
step
.goto Grizzly Hills,71.3,39.9
.use 36787
>>Use your Shard of Gavrock next to the First Ancient Stone
.complete 12094,1
>>Draw Power from the First Ancient Stone
step
.goto Grizzly Hills,71.5,24.7
.use 36834
>>Use your Charged Drakil'jin Mallet next to a gong
.complete 12121,1
>>Collect killed by Warlord Jin'arrak
>>STAY DEAD
step
.goto Grizzly Hills,69.4,19.5
>>While dead, go inside the crypt to 69.4,19.5
.target Gan'jo
.turnin 12121 >> Turn in See You on the Other Side
.accept 12137 >> Accept Chill Out, Mon
step
.goto Grizzly Hills,69.4,19.5
>>Click Gan'jo's Chest in the sink next to you - Gan'jo's Chest is sitting in the wall sink
.complete 12137,1
>>Collect Snow of Eternal Slumber
step
.goto Grizzly Hills,69.4,19.5
.target Gan'jo
>>Tell him you are ready to return to the realm of the living
step
.goto Grizzly Hills,70,20.4
.use 36859
>>Use your Snow of Eternal Slumber on Ancient Drakkari mobs
>>They run to nearby mummies on the ground, follow them
>>Click the Drakkari Spirit Particles
.complete 12137,2
>>Collect Drakkari Spirit Particles
step
.goto Grizzly Hills,73.9,34.1
>>Go outside to 73.9,34.1
.target Kraz
.turnin 12137 >> Turn in Chill Out, Mon
.accept 12152 >> Accept Jin'arrak's End
step
.goto Grizzly Hills,71.3,19.6
>>Go into the crypt to 71.3,19.6
>>Click the Sacred Drakkari Offering - It's a small fruit bowl on the ground inside the crypt, next to a skull statue
>>Collect Sacred Drakkari Offering
.use 36873
>>Use your Drakkari Spirit Dust
.collect 37063,1,12152 >> Collect 1 Infused Drakkari Offering
step
.goto Grizzly Hills,71.4,24.4
>>Go outside to 71.4,24.4
.use 37063
>>Use your Infused Drakkari Offering next to a gong
.complete 12152,1
>>Destroy Warlord Jin'arrak
step
.goto Grizzly Hills,73.9,34.1
.target Kraz
.turnin 12152 >> Turn in Jin'arrak's End
step
.goto Grizzly Hills,79.8,33.6
.target Gavrock
.turnin 12094 >> Turn in Latent Power
.accept 12099 >> Accept Free at Last
step
.goto Grizzly Hills,76.2,37.7
.use 36796
>>Use Gavrock's Runebreaker on Runed Giants
.complete 12099,1
>>Free 4 Runed Giants
step
.goto Grizzly Hills,79.8,33.6
.target Gavrock
.turnin 12099 >> Turn in Free at Last
step
.goto Grizzly Hills,65.4,47.0,0.5
.hs >> Hearth to Camp Oneqwah
>>Hearth to Camp Oneqwah
step
.goto Grizzly Hills,65.2,47.7
.target Sage Paluna
.turnin 12026 >> Turn in The Damaged Journal
.accept 12054 >> Accept Deciphering the Journal
step
.goto Grizzly Hills,65,47.9
.target Soulok Stormfury
.turnin 12415 >> Turn in The Horse Hollerer
step
.goto Grizzly Hills,69.1,40.1
.target Hugh Glass
.turnin 12279 >> Turn in A Bear of an Appetite
step
.goto Grizzly Hills,76.6,55.1
.mob Iron Rune-Smiths
>>Kill Iron Rune-Smiths
.collect 36849,1,12165 >> Collect 1 Golem Blueprint Section 1
.collect 36850,1,12165 >> Collect 1 Golem Blueprint Section 2
.collect 36851,1,12165 >> Collect 1 Golem Blueprint Section 3
.use 36849
>>Click the Golem Blueprint Section 1 in your bags
.complete 12165,1
>>Collect War Golem Blueprint
step
.goto Grizzly Hills,66.6,58.8
.mob Grumbald One-Eye
>>Kill Grumbald One-Eye
.complete 12054,1
>>Collect Spiritsbreath
step
.goto Grizzly Hills,65.2,47.7
.target Sage Paluna
.turnin 12054 >> Turn in Deciphering the Journal
.accept 12058 >> Accept The Runic Prophecies
step
.goto Grizzly Hills,65.2,47.7
.target Scout Vor'takh
.accept 12073 >> Accept Pounding the Iron
step
.goto Grizzly Hills,65,47
.target Prospector Rokar
.turnin 12165 >> Turn in An Intriguing Plan
.accept 12196 >> Accept From the Ground Up
step
.goto Grizzly Hills,76.6,54.8
.mob Iron Rune Overseer
>>Kill Iron Rune Overseer
>>Click the War Golem Parts - The War Golem Parts look like metal parts sitting around inside this room and buildings around this area
.complete 12196,1
>>Collect War Golem Part
>>You can find more Golem Parts around 75.3,57.3
step
.goto Grizzly Hills,65,47
.target Propector Rokar
.turnin 12196 >> Turn in From the Ground Up
.accept 12197 >> Accept We Have the Power
step
.goto Grizzly Hills,76.8,59.4
.mob Rune-Smith Kathorn
>>Kill Rune-Smith Kathorn
.complete 12197,2
>>Collect Kathorn's Power Cell
step
.goto Grizzly Hills,74.9,56.9
.mob Rune-Smith Durar
>>Kill Rune-Smith Durar
.complete 12197,1
>>Collect Durar's Power Cell
step
.goto Grizzly Hills,65,47
.target Prospector Rokar
.turnin 12197 >> Turn in We Have the Power
.accept 12198 >> Accept ... Or Maybe We Don't
step
.goto Grizzly Hills,73.7,51.4
.use 36936
>>Use your Golem Control Unit
.mob Lightning Sentries
>>Kill Lightning Sentries
.complete 12198,1
>>Collect Charge Level
step
.goto Grizzly Hills,65,47
.target Prospector Rokar
.turnin 12198 >> Turn in ... Or Maybe We Don't
.accept 12199 >> Accept Bringing Down the Iron Thane
step
.goto Grizzly Hills,76.2,63.2
>>Go into this building and downstairs to 76.2,63.2
.use 36865
>>Use your Golem Control Unit to ride in your War Golem
>>Use your EMP skill to stun The Anvil and remove Iron Thane Furyhammer's Shield
.complete 12199,1
.mob Iron Thane Furyhammer
>>Kill Iron Thane Furyhammer
step
.goto Grizzly Hills,65.3,47.5
.target Tormak the Scarred
.turnin 12199 >> Turn in Bringing Down the Iron Thane
step
.goto Grizzly Hills,65.2,19.4
.complete 12073,1
>>Kill 10 Iron Dwarf Defender
step
.goto Grizzly Hills,68.5,16.2
>>Click the Third Rune Plate - It looks like a brown strip across a metal door in the wall
.complete 12058,3
>>Decipher the Third Prophecy
step
.goto Grizzly Hills,69,14.4
>>Click the First Rune Plate - It looks like a brown strip across a metal door in the wall
.complete 12058,1
>>Decipher the First Prophecy
step
.goto Grizzly Hills,70.2,14.7
>>Click the Second Rune Plate - It looks like a brown strip across a metal door in the wall
.complete 12058,2
>>Decipher the Second Prophecy
step
.goto Grizzly Hills,65.4,47.0,0.5
.hs >> Hearth to Camp Oneqwah
>>Hearth to Camp Oneqwah
step
.goto Grizzly Hills,65.2,47.7
.target Scout Vor'takh
.turnin 12073 >> Turn in Pounding the Iron
step
.goto Grizzly Hills,65.2,47.7
.target Sage Paluna
.turnin 12058 >> Turn in The Runic Prophecies
step
.goto Grizzly Hills,65.2,47.7
.target Scout Vor'takh
.accept 12204 >> Accept In the Name of Loken
step
.goto Grizzly Hills,69.1,40.1
.target Hugh Glass
>>Talk to him about Loken
.complete 12204,1
>>Question Hugh Glass
step
.goto Grizzly Hills,79.8,33.6
.target Gavrock
>>Talk to him about Loken - He's a huge rock elemental standing on a small island
.complete 12204,2
>>Question Gavrock
step
.goto Grizzly Hills,65.2,47.7
.target Scout Vor'takh
.turnin 12204 >> Turn in In the Name of Loken
.accept 12201 >> Accept The Overseer's Shadow
step
.goto Grizzly Hills,76.6,54.8
.mob Iron Rune Overseer
>>Kill Iron Rune Overseer
.complete 12201,1
>>Collect Overseer's Uniform
step
.goto Grizzly Hills,65.2,47.7
.target Scout Vor'takh
.turnin 12201 >> Turn in The Overseer's Shadow
.accept 12202 >> Accept Cultivating an Image
step
.goto Grizzly Hills,76.2,53.4
.mob Iron dwarves
>>Kill Iron dwarves
.use 37125
>>Use Rokar's Camera on their corpses
.complete 12202,1
>>Capture 8 Iron Dwarf Images
step
.goto Grizzly Hills,65.2,47.7
.target Scout Vor'takh
.turnin 12202 >> Turn in Cultivating an Image
.accept 12203 >> Accept Loken's Orders
step
.goto Grizzly Hills,81.5,60.3
.use 37071
>>Use your Overseer Disguise Kit
>>Click Loken's Pedastal inside the building
.complete 12203,1
>>Receive the Message from Loken
step
.goto Grizzly Hills,65.2,47.7
.target Scout Vor'takh
.turnin 12203 >> Turn in Loken's Orders
step
.fly Conquest Hold, Grizzly Hills >> Fly to Conquest Hold
>>Fly to Conquest Hold
step
.goto Grizzly Hills,22.5,62.8
.target Windseer Grayhorn
.turnin 12229 >> Turn in A Possible Link
.turnin 12231 >> Turn in The Bear God's Offspring
.accept 12241 >> Accept Destroy the Sapling
.accept 12242 >> Accept Vordrassil's Seeds
step
.fly Camp Oneqwah, Grizzly Hills >> Fly to Camp Oneqwah
>>Fly to Camp Oneqwah
step
.goto Grizzly Hills,50.5,45.9
.goto Grizzly Hills,50.5,45.9,0.5
>>The path down to Destroy the Sapling starts here
step
.goto Grizzly Hills,50.8,42.6
>>Follow the path down to 50.8,42.6
.use 37306
>>Use your Verdant Torch next to the tall tree
.complete 12241,1
>>Collect Vordrassil's Ashes
step
.goto Grizzly Hills,51.5,47.1
>>Go outside to 51.5,47.1
>>Click Vordrassil's Seeds - They look like brown pinecones sitting on the ground around this area
.complete 12242,1
>>Collect Vordrassil's Seed
step
>>Go to Camp Oneqwah
.fly Conquest Hold, Grizzly Hills >> Fly to Conquest Hold
>>Fly to Conquest Hold
step
.goto Grizzly Hills,22.5,62.8
.target Windseer Grayhorn
.turnin 12241 >> Turn in Destroy the Sapling
.turnin 12242 >> Turn in Vordrassil's Seeds
step
.fly Dalaran >> Fly to Dalaran
>>Fly to Dalaran
step
.goto Dalaran,68.6,42
.target Archmage Pentarus
.accept 12521 >> Accept Where in the World is Hemet Nesingwary?
step
.fly Camp Oneqwah, Grizzly Hills >> Fly to Camp Oneqwah
>>Fly to Camp Oneqwah
step
.zone Zul'Drak
>>Go north to Zul'Drak
step
.goto Zul'Drak,60,56.7
.target Maaka
.fp Zim'Torga, Zul'Drak >> Get the Zim'Torga flight path
step
.goto Zul'Drak,60,57.9
.target Chronicler To'kini
.accept 13099 >> Accept Just Checkin'
step
.home Zim'Torga >> Set your Hearthstone to Zim'Torga
step
.goto Zul'Drak,48.4,56.4
.target Gurgthock
.turnin 12974 >> Turn in The Champion's Call!
step
.goto Zul'Drak,41.6,64.4
.target Gurric
.fp The Argent Stand, Zul'Drak >> Get the The Argent Stand flight path
step
.goto Zul'Drak,32.2,74.4
.target Danica Saint
.fp Light's Breach, Zul'Drak >> Get the Light's Breach flight path
step
.goto Zul'Drak,32,74.4
.target Sergeant Riannah
.turnin 12789 >> Turn in Into the Breach!
step
.goto Zul'Drak,32,75.6
.target Elder Shaman Moky
.accept 12859 >> Accept This Just In: Fire Still Hot!
step
.goto Zul'Drak,32.2,75.7
.target Crusader Lord Lantinga
.accept 12902 >> Accept In Search Of Answers
step
.goto Zul'Drak,32.2,75.7
.target Chief Rageclaw
.accept 12861 >> Accept Trolls Is Gone Crazy!
step
.goto Zul'Drak,34.9,83.9
>>Click the Orders From Drakuru - It looks like a floating scroll above a small pillar
.turnin 12902 >> Turn in In Search Of Answers
.accept 12883 >> Accept Orders From Drakuru
step
.goto Zul'Drak,34.9,81
.mob Drakuru mobs
>>Kill Drakuru mobs
>>Collect Drakuru "Lock Openers"
.use 41161
>>Use your Drakuru "Lock Openers" next to Captured Rageclaws
.complete 12861,1
>>Free 8 Captured Rageclaws
.use 41131
>>Use your Rageclaw Fire Extinguisher next to burning huts
.complete 12859,1
>>Douse 15 Hut Fires
step
.goto Zul'Drak,32.2,75.7
.target Crusader Lord Lantinga
.turnin 12883 >> Turn in Orders From Drakuru
.accept 12884 >> Accept The Ebon Watch
.accept 12894 >> Accept Crusader Forward Camp
step
.goto Zul'Drak,32.2,75.7
.target Chief Rageclaw
.turnin 12861 >> Turn in Trolls Is Gone Crazy!
step
.goto Zul'Drak,32,75.6
.target Elder Shaman Moky
.turnin 12859 >> Turn in This Just In: Fire Still Hot!
step
.goto Zul'Drak,14,73.6
.target Baneflight
.fp Ebon Watch, Zul'Drak >> Get the Ebon Watch flight path
step
.goto Zul'Drak,14.1,73.8
.target Stefan Vadu
.turnin 12884 >> Turn in The Ebon Watch
.accept 12630 >> Accept Kickin' Nass and Takin' Manes
step
.isQuestTurnedIn -12238
.goto Zul'Drak,15.5,69.8
.mob Withered Trolls
>>Kill Withered Trolls
.use 38659
>>Use Stefan's Steel Toed Boot on Nass
.complete 12630,1
>>Collect 10 Hair Samples
>>Collect Unliving Choker
.use 38660
>>Click the Unliving Choker in your bags
.accept 12631 >> Accept An Invitation, of Sorts...
step
.isQuestTurnedIn 12238
.goto Zul'Drak,15.5,69.8
.mob Withered Trolls
>>Kill Withered Trolls
.use 38659
>>Use Stefan's Steel Toed Boot on Nass
.complete 12630,1
>>Collect 10 Hair Samples
>>Collect Writhing Choker
.use 38673
>>Click the Writhing Choker in your bags
.accept 12633 >> Accept Darkness Calling
step
.isQuestTurnedIn -12238
.goto Zul'Drak,14.1,73.8
.target Stefan Vadu
.turnin 12630 >> Turn in Kickin' Nass and Takin' Manes
.turnin 12631 >> Turn in An Invitation, of Sorts...
.accept 12637 >> Accept Near Miss
step
.isQuestTurnedIn 12238
.goto Zul'Drak,14.1,73.8
.target Stefan Vadu
.turnin 12630 >> Turn in Kickin' Nass and Takin' Manes
.turnin 12633 >> Turn in Darkness Calling
.accept 12638 >> Accept Close Call
step
.isQuestTurnedIn -12238
.goto Zul'Drak,14.3,74
.target Bloodrose Datura
.accept 12795 >> Accept Taking a Stand
>>Tell her Stefan said she would demonstrate the item's purpose
.complete 12637,1
>>Expose the Choker's Purpose
step
.isQuestTurnedIn 12238
.goto Zul'Drak,14.3,74
.target Bloodrose Datura
.accept 12795 >> Accept Taking a Stand
>>Tell her Stefan said she would demonstrate the item's purpose
.complete 12638,1
>>Expose the Choker's Purpose
step
.isQuestTurnedIn -12238
.goto Zul'Drak,14.1,73.8
.target Stefan Vadu
.turnin 12637 >> Turn in Near Miss
.accept 12629 >> Accept You Can Run, But You Can't Hide
step
.isQuestTurnedIn 12238
.goto Zul'Drak,14.1,73.8
.target Stefan Vadu
.turnin 12638 >> Turn in Close Call
.accept 12643 >> Accept Silver Lining
step
.isQuestTurnedIn -12238
.goto Zul'Drak,20.6,73.0
.mob Putrid Abominations
>>Kill Putrid Abominations
.complete 12629,1
>>Collect Putrid Abomination Guts
>>Click the Gooey Ghoul Drool - The Gooey Ghoul Drool looks like jelly blobs on the ground around this area
.complete 12629,2
>>Collect Gooey Ghoul Drool
step
.isQuestTurnedIn 12238
.goto Zul'Drak,20.6,73.0
.mob Putrid Abominations
>>Kill Putrid Abominations
.complete 12643,1
>>Collect Putrid Abomination Guts
>>Click the Gooey Ghoul Drool - The Gooey Ghoul Drool looks like jelly blobs on the ground around this area
.complete 12643,2
>>Collect Gooey Ghoul Drool
step
.isQuestTurnedIn -12238
.goto Zul'Drak,14.1,73.8
.target Stefan Vadu
.turnin 12629 >> Turn in You Can Run, But You Can't Hide
.accept 12648 >> Accept Dressing Down
step
.isQuestTurnedIn 12238
.goto Zul'Drak,14.1,73.8
.target Stefan Vadu
.turnin 12643 >> Turn in Silver Lining
.accept 12649 >> Accept Suit Up!
step
.isQuestTurnedIn -12238
.goto Zul'Drak,19.9,75.5
.use 38699
>>Use the Ensorcelled Choker to wear a ghoul costume
.target Gristlegut
.accept 12652 >> Accept Feedin' Da Goolz
.complete 12648,1
>>Buy buy Bitter Plasma
step
.isQuestTurnedIn 12238
.goto Zul'Drak,19.9,75.5
.use 38699
>>Use the Ensorcelled Choker to wear a ghoul costume
.target Gristlegut
.accept 12652 >> Accept Feedin' Da Goolz
.complete 12649,1
>>Buy buy Bitter Plasma
step
.goto Zul'Drak,20.5,74.8
.use 38701
>>Use your Bowels and Brains Bowl near Decaying Ghouls
.complete 12652,1
>>Feed 10 Decaying Ghouls
step
.goto Zul'Drak,19.9,75.5
.target Gristlegut
.turnin 12652 >> Turn in Feedin' Da Goolz
step
.isQuestTurnedIn -12238
.goto Zul'Drak,14.1,73.8
.target Stefan Vadu
.turnin 12648 >> Turn in Dressing Down
.accept 12661 >> Accept Infiltrating Voltarus
step
.isQuestTurnedIn 12238
.goto Zul'Drak,14.1,73.8
.target Stefan Vadu
.turnin 12649 >> Turn in Suit Up!
.accept 12661 >> Accept Infiltrating Voltarus
step
.goto Zul'Drak,25.3,64
.target Crusader MacKellar
.turnin 12894 >> Turn in Crusader Forward Camp
.accept 12903 >> Accept That's What Friends Are For...
step
.goto Zul'Drak,25.3,64
.target Engineer Reed
.accept 12901 >> Accept Making Something Out Of Nothing
step
.goto Zul'Drak,19.4,61.4
>>Click the Scourge Scrap Metal - They look like big spiked metal stars and other metal pieces on the ground around this area
.complete 12901,1
>>Collect Scourge Scrap Metal
step
.goto Zul'Drak,17.6,57.6
.complete 12903,2
>>Find Gerk
.target Gerk
step
.goto Zul'Drak,15.7,59.4
.complete 12903,3
>>Find Burr
step
.goto Zul'Drak,19.7,56.4
.target Gymer
.accept 12912 >> Accept A Great Storm Approaches
step
.goto Zul'Drak,25.1,51.6
.complete 12903,1
>>Find Crusader Dargath
step
.goto Zul'Drak,28.4,44.9
.use 38699
>>Use your Ensorcelled Choker to become a ghoul
>>Stand on this green circle
.goto Zul'Drak,28.1,45.2,0.2
>>Get teleported up to Overlord Drakuru
step
.isQuestTurnedIn -12238
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.accept 12664 >> Accept Dark Horizon
step
.isQuestTurnedIn 12238
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.accept 12663 >> Accept Reunited
step
.isQuestTurnedIn -12238
.goto Zul'Drak,29.9,47.8
.target Gorebag
>>Go on the tour of Zul'Drak
.complete 12664,1
>>Complete the tour of Zul'Drak
step
.isQuestTurnedIn 12238
.goto Zul'Drak,29.9,47.8
.target Gorebag
>>Go on the tour of Zul'Drak
.complete 12663,1
>>Complete the tour of Zul'Drak
step
.isQuestTurnedIn -12238
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.turnin 12664 >> Turn in Dark Horizon
.complete 12661,1
>>Complete Overlord Drakuru's task
step
.isQuestTurnedIn 12238
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.turnin 12663 >> Turn in Reunited
.complete 12661,1
>>Complete Overlord Drakuru's task
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.0,44.9,0.2
>>Teleport back down to the ground
step
.use 41390
>>Use Stefan's Horn in your bags
.target Stefan Vadu
.turnin 12661 >> Turn in Infiltrating Voltarus
.accept 12669 >> Accept So Far, So Bad
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.1,45.2,0.2
>>Get teleported up to Overlord Drakuru
step
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.accept 12673 >> Accept It Rolls Downhill
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.0,44.9,0.2
>>Teleport back down to the ground
step
.goto Zul'Drak,27.2,45.1
.use 39157
>>Use your Scepter of Suggestion on Blight Geists
.macro Harvest Blight Crystal,134400 >>/cast Harvest Blight Crystal
>>Use the Harvest Blight Crystal ability near Crystallized Blight
>>Follow the Blight Geists back to the teleport pad
.complete 12673,1
>>Collect 7 Blight Crystals
step
.goto Zul'Drak,26.8,47
.use 39154
>>Use your Diluting Additive next to the big cauldron 5 times
.complete 12669,2
>>Dilute the Cauldron 5 times
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.1,45.2,0.2
>>Get teleported up to Overlord Drakuru
step
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.turnin 12673 >> Turn in It Rolls Downhill
.complete 12669,1
>>Complete Drakuru's task
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.0,44.9,0.2
>>Teleport back down to the ground
step
.use 41390
>>Use Stefan's Horn in your bags
.target Stefan Vadu
.turnin 12669 >> Turn in So Far, So Bad
.accept 12677 >> Accept Hazardous Materials
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.1,45.2,0.2
>>Get teleported up to Overlord Drakuru
step
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.accept 12686 >> Accept Zero Tolerance
step
.goto Zul'Drak,27.1,43.9
>>Click the Harvested Blight Crystal crates - They look like big wooden crates around this area in the halls and rooms
.complete 12677,2
>>Collect Harvested Blight Crystal
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.0,44.9,0.2
>>Teleport back down to the ground
step
.goto Zul'Drak,29.7,49.6
.use 39206
>>Use your Scepter of Empowerment on a Servant of Drakaru
>>Take control of a Servant of Drakaru
>>Use the abilities on your Servant of Drakaru's pet bar to fight Darmuk at 30.4,51.5 - He's a huge undead mob walking around on this platform
.complete 12686,1
>>Kill Darmuk
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.1,45.2,0.2
>>Get teleported up to Overlord Drakuru
step
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.turnin 12686 >> Turn in Zero Tolerance
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.0,44.9,0.2
>>Teleport back down to the ground
step
.use 41390
>>Use Stefan's Horn in your bags
.target Stefan Vadu
.turnin 12677 >> Turn in Hazardous Materials
.accept 12676 >> Accept Sabotage
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.1,45.2,0.2
>>Get teleported up to Overlord Drakuru
step
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.accept 12690 >> Accept Fuel for the Fire
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.0,44.9,0.2
>>Teleport back down to the ground
step
.goto Zul'Drak,32.1,40.6
.use 39238
>>Use your Scepter of Command on a Blaoted Abomination
>>Take control of the Bloated Abomination
>>Go up the hill
>>Send your Bloated Abomination into groups of Drakkari Skullcrushers
.macro Burst at the Seams,134400 >>/cast Burst at the Seams
>>Use the Burst at the Seams ability on your pet hotbar
.complete 12690,1
>>Kill 60 Drakkari Skullcrushers
.complete 12690,2
>>Lure 3 Drakkari Chieftains
step
.goto Zul'Drak,30.6,45.3
.use 39165
>>Use your Explosive Charges next to Scourgewagons
.complete 12676,1
>>Destroy 5 Scourgewagons
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.1,45.2,0.2
>>Get teleported up to Overlord Drakuru
step
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.turnin 12690 >> Turn in Fuel for the Fire
.accept 12710 >> Accept Disclosure
.complete 12676,2
>>Complete Drakuru's task
step
.goto Zul'Drak,28.4,44.9
>>Stand on this blue circle on the small platform above the green circle
.goto Zul'Drak,27.4,42.5,0.2
>>Teleport up to Drakuru's upper chamber
step
.goto Zul'Drak,27.2,42.3
>>Click the Musty Coffin - It's a brown coffin. Click on the Coffin again after he says "Ahh... there you are. The Master told us you'd be arriving soon." This will allow you to complete the exploration without doing the tour
.complete 12710,1
>>Explore Drakuru's upper chamber
step
.goto Zul'Drak,28.4,44.9
.goto Zul'Drak,28.1,45.2,0.2
>>Stand on this green circle to go to the bottom level of Voltarus
step
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.turnin 12710 >> Turn in Disclosure
.complete 12676,3
>>Learn Drakuru's secret
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.0,44.9,0.2
>>Teleport back down to the ground
step
.use 41390
>>Use Stefan's Horn in your bags
.target Stefan Vadu
.turnin 12676 >> Turn in Sabotage
step
.goto Zul'Drak,25.3,64
.target Engineer Reed
.turnin 12901 >> Turn in Making Something Out Of Nothing
.turnin 12912 >> Turn in A Great Storm Approaches
.accept 12914 >> Accept Gymer's Salvation
step
.goto Zul'Drak,25.3,64
.target Crusader MacKellar
.turnin 12903 >> Turn in That's What Friends Are For...
step
.goto Zul'Drak,17.6,57.6
.target Gerk
.accept 12904 >> Accept Light Won't Grant Me Vengeance
step
.goto Zul'Drak,16.9,58.7
.complete 12904,1
.mob Vargul
>>Kill Vargul
step
.goto Zul'Drak,17.6,57.6
.target Gerk
.turnin 12904 >> Turn in Light Won't Grant Me Vengeance
step
.goto Zul'Drak,23.9,62.4
.mob Banshee Soulclaimers
>>Kill Banshee Soulclaimers
.complete 12914,1
>>Collect Banshee Essence
step
.goto Zul'Drak,15.9,71.5
.mob Icetouched Earthragers
>>Kill Icetouched Earthragers
.complete 12914,2
>>Collect Diatomaceous Earth
step
.goto Zul'Drak,25.3,64
.target Engineer Reed
.turnin 12914 >> Turn in Gymer's Salvation
.accept 12916 >> Accept Our Only Hope
step
.xp 77
step
.goto Zul'Drak,19.7,56.4
>>Click the Scourge Enclosure - It's Gymer's huge cage
>>Blow Up the Scourge Enclosure
.target Gymer
.turnin 12916 >> Turn in Our Only Hope
step
.goto Zul'Drak,39.4,67
.target Commander Falstaav
.turnin 12795 >> Turn in Taking a Stand
.accept 12503 >> Accept Defend the Stand
.accept 12740 >> Accept Parachutes for the Argent Crusade
step
.home The Argent Stand >> Set your Hearthstone to The Argent Stand
step
.fly Dalaran >> Fly to Dalaran
>>Fly to Dalaran
step
.goto Dalaran,69.7,45.4
.target Hira Snowdawn
>>Collect your Expert Riding Training (if you don't already have it)
>>Collect your Cold Weather Flying Training
step
.fly The Argent Stand, Zul'Drak >> Fly to The Argent Stand
>>Fly to The Argent Stand
step
.goto Zul'Drak,40.5,65.6
.target Hexxer Ubungo
.accept 12565 >> Accept The Blessing of Zim'Abwa
step
.goto Zul'Drak,38.4,67.1
.complete 12503,1
>>Kill 10 Scourge
.use 39615
>>Use your Crusader Parachute on Argent Shieldmen and Argent Crusaders
.complete 12740,1
>>Equip 10 Argent forces with a parachute
.mob Scourge mobs
>>Kill Scourge mobs
.collect 38551,10,12565 >> Collect 10 Drakkari Offerings
step
.goto Zul'Drak,36.7,72.6
.target Zim'Abwa
.turnin 12565 >> Turn in The Blessing of Zim'Abwa
step
.goto Zul'Drak,39.4,67
.target Commander Falstaav
.turnin 12503 >> Turn in Defend the Stand
.turnin 12740 >> Turn in Parachutes for the Argent Crusade
step
.goto Zul'Drak,40.3,66.6
.target Commander Kunz
.accept 12505 >> Accept New Orders for Sergeant Stackhammer
.accept 12596 >> Accept Pa'Troll
step
.goto Zul'Drak,40.5,65.6
.target Hexxer Ubungo
.accept 12506 >> Accept Trouble at the Altar of Sseratus
step
.goto Zul'Drak,35.6,52.2
.target Captain Arnath
.accept 12799 >> Accept Siphoning the Spirits
step
.goto Zul'Drak,35,52.1
.target Alchemist Finklestein
.accept 12557 >> Accept Lab Work
step
>>Go into the 2 rooms next to you:
>>They are items on shelves that you can click
.complete 12557,1
>>Click a Muddy Mire Maggot and get it
.complete 12557,2
>>Click a Withered Batwing and get it
.complete 12557,4
>>Click a Chilled Serpent Mucus and get it
.complete 12557,3
>>Click an Amberseed and get it
step
.goto Zul'Drak,35,52.1
.target Alchemist Finklestein
.turnin 12557 >> Turn in Lab Work
.complete 12596,4
>>Complete Alchemist Finklestein's task
step
.goto Zul'Drak,36.6,60.5
.mob Lost Drakkari Spirits
>>Kill Lost Drakkari Spirits
.complete 12799,1
>>Collect Ancient Ectoplasm
step
.goto Zul'Drak,35.6,52.2
.target Captain Arnath
.turnin 12799 >> Turn in Siphoning the Spirits
.accept 12609 >> Accept Stocking the Shelves
.accept 12610 >> Accept Clipping Their Wings
step
.goto Zul'Drak,36.1,51.1
.mob Trapdoor Crawlers
>>Kill Trapdoor Crawlers
.complete 12609,1
>>Collect Fresh Spider Ichor
.mob Zul'Drak Bats
>>Kill Zul'Drak Bats
.complete 12610,1
>>Collect Unblemished Bat Wing
step
.goto Zul'Drak,35.6,52.2
.target Captain Arnath
.turnin 12609 >> Turn in Stocking the Shelves
.turnin 12610 >> Turn in Clipping Their Wings
step
.goto Zul'Drak,40.4,48.2
.target Sergeant Stackhammer
.turnin 12505 >> Turn in New Orders for Sergeant Stackhammer
.accept 12504 >> Accept Argent Crusade, We Are Leaving!
step
.goto Zul'Drak,40.4,48.2
.target Corporal Maga
.accept 12508 >> Accept Mopping Up
step
.goto Zul'Drak,40.4,47
.target Argent Soldier
.complete 12504,1
>>Tell 10 Argent Soldiers told to report back to the sergeant
.mob Sseratus mobs
>>Kill Sseratus mobs
.complete 12508,1
.mob Followers of Sseratus
>>Kill Followers of Sseratus
>>Collect Strange Mojo
.use 38321
>>Click the Strange Mojo
.accept 12507 >> Accept Strange Mojo
step
.goto Zul'Drak,40.3,39.3
>>Fly inside the building to 40.3,39.3
.complete 12506,1
>>Investigate the Main building at the Altar of Sseratus
step
.goto Zul'Drak,40.4,48.2
.target Sergeant Stackhammer
.turnin 12504 >> Turn in Argent Crusade, We Are Leaving!
step
.goto Zul'Drak,40.4,48.2
.target Corporal Maga
.turnin 12508 >> Turn in Mopping Up
step
.goto Zul'Drak,40.5,65.6
.target Hexxer Ubungo
.turnin 12506 >> Turn in Trouble at the Altar of Sseratus
.turnin 12507 >> Turn in Strange Mojo
.accept 12510 >> Accept Precious Elemental Fluids
step
.goto Zul'Drak,40.2,68.9
.target Sub-Lieutenant Jax
.accept 12562 >> Accept The Drakkari Do Not Need Water Elementals!
step
.goto Zul'Drak,40.2,73.6
.complete 12562,1
.mob Drakkari Water Binder
>>Kill Drakkari Water Binder
.mob Crazed Water Spirits
>>Kill Crazed Water Spirits
.collect 38323,3,12510 >> Collect 3 Water Elemental Links
.use 38323
>>Use the Water Elemental Links to create Tethers to the Plane of Water
.use 38324
>>Use the Tethers to the Plane of Water
.mob Watery Lords that spawn
>>Kill Watery Lords that spawn
.complete 12510,1
>>Collect Precious Elemental Fluids
step
.goto Zul'Drak,40.2,68.9
.target Sub-Lieutenant Jax
.turnin 12562 >> Turn in The Drakkari Do Not Need Water Elementals!
step
.goto Zul'Drak,40.5,65.6
.target Hexxer Ubungo
.turnin 12510 >> Turn in Precious Elemental Fluids
.accept 12514 >> Accept Mushroom Mixer
step
.goto Zul'Drak,41.3,65.1
.target Apprentice Pestlepot
.accept 12527 >> Accept Gluttonous Lurkers
step
.goto Zul'Drak,41.4,57.4
>>Click Zul'Drak Rats on the ground walking around this area
.collect 38380,25,12527 >> Collect 25 Zul'Drak Rat
.use 38380
>>Use the Zul'Drak Rats on Lurking Basilisks
>>Click the Gorged Lurking Basilisks
.complete 12527,1
>>Collect Basilisk Crystals
>>Click Muddlecap Fungus - The Muddlecap Fungus looks like groups of tall mushrooms around this area
.complete 12514,1
>>Collect Muddlecap Fungus
step
.goto Zul'Drak,40.5,65.6
.target Hexxer Ubungo
.turnin 12514 >> Turn in Mushroom Mixer
.accept 12516 >> Accept Too Much of a Good Thing
step
.goto Zul'Drak,35,52.1
.target Alchemist Finklestein
.turnin 12527 >> Turn in Gluttonous Lurkers
step
.goto Zul'Drak,40.2,42.6
.use 38332
>>Use your Modified Mojo on the Prophet of Sseratus
.complete 12516,1
.mob Muddled Prophet of Sseratus
>>Kill Muddled Prophet of Sseratus
step
.goto Zul'Drak,40.8,66.2,0.5
.hs >> Hearth to The Argent Stand
>>Hearth to The Argent Stand
step
.goto Zul'Drak,40.5,65.6
.target Hexxer Ubungo
.turnin 12516 >> Turn in Too Much of a Good Thing
.accept 12623 >> Accept To the Witch Doctor
step
.goto Zul'Drak,48.2,63.9
.target Captain Grondel
.accept 12599 >> Accept Creature Comforts
step
.goto Zul'Drak,46.9,61.4
>>Click Dead Thornwoods - They look like curved thorny roots coming out of the water around this area
.complete 12599,1
>>Collect Dead Thornwood
step
.goto Zul'Drak,48.2,63.9
.target Captain Grondel
.turnin 12599 >> Turn in Creature Comforts
.complete 12596,3
>>Complete Captain Grondel's Task
step
.goto Zul'Drak,48.8,78.9
.target Captain Brandon
.accept 12597 >> Accept Something for the Pain
step
.goto Zul'Drak,44.9,79.5
>>Click the Mature Water-Poppy plants - They look like tall white-leaved plants with purple bulbs at the top
.complete 12597,1
>>Collect Mature Water-Poppy
step
.goto Zul'Drak,48.8,78.9
.target Captain Brandon
.turnin 12597 >> Turn in Something for the Pain
.complete 12596,1
>>Complete Captain Brandon's Task
step
.goto Zul'Drak,58.1,72.4
.target Captain Rupert
.accept 12598 >> Accept Throwing Down
step
.goto Zul'Drak,58.7,72.5
.target Dr. Rogers
.accept 12512 >> Accept Leave No One Behind
step
.goto Zul'Drak,53.6,75
.use 38330
>>Use your Crusader's Bandage on Crusader Lamoof
>>Escort Crusader Lamoof back to Dr. Rogers at 58.1,72.4
.complete 12512,2
>>Save Crusader Lamoof
step
.goto Zul'Drak,49.4,74.7
.use 38330
>>Use your Crusader's Bandage on Crusader Josephine
>>Escort Crusader Josephine back to Dr. Rogers at 58.1,72.4
.complete 12512,3
>>Save Crusader Josephine
step
.goto Zul'Drak,53.4,68.7
.use 38574
>>Use your High Impact Grenade next to Nerubian Tunnels
.complete 12598,1
>>Seal 5 Nerubian Tunnels
step
.goto Zul'Drak,50.7,69.9
.use 38330
>>Use your Crusader's Bandage on Crusader Jonathan
>>Escort Crusader Jonathan back to Dr. Rogers at 58.1,72.4
.complete 12512,1
>>Save Crusader Jonathan
step
.goto Zul'Drak,58.1,72.4
.target Captain Rupert
.turnin 12598 >> Turn in Throwing Down
.accept 12606 >> Accept Cocooned!
.complete 12596,2
>>Complete Captain Rupert's Task
step
.goto Zul'Drak,58.7,72.5
.target Dr. Rogers
.turnin 12512 >> Turn in Leave No One Behind
step
.goto Zul'Drak,58.3,72
.target Specialist Cogwheel
.accept 12553 >> Accept Skimmer Spinnerets
step
.goto Zul'Drak,57.6,75.2
.mob Hath'ar Skimmers
>>Kill Hath'ar Skimmers
.complete 12553,1
>>Collect Intact Skimmer Spinneret
step
.goto Zul'Drak,58.3,72
.target Specialist Cogwheel
.turnin 12553 >> Turn in Skimmer Spinnerets
.accept 12583 >> Accept Crashed Sprayer
step
.goto Zul'Drak,58.1,72.4
.target Captain Rupert
.accept 12584 >> Accept Pure Evil
step
.goto Zul'Drak,56.7,69.7
>>Attack the Nerubian Cocoons - They look like squirming big white cocoons on the ground around this area
.complete 12606,1
>>Free 3 Captive Footmen
step
.goto Zul'Drak,48.8,75.6
>>Click the Crashed Plague Sprayer - It looks like a stone cube with 4 pillars in the corners, with skull designs on it
.complete 12583,1
>>Collect Plague Sprayer Parts
step
.goto Zul'Drak,58.1,72.4
.target Captain Rupert
.turnin 12606 >> Turn in Cocooned!
step
.goto Zul'Drak,58.3,72
.target Specialist Cogwheel
.turnin 12583 >> Turn in Crashed Sprayer
.accept 12555 >> Accept A Tangled Skein
step
.goto Zul'Drak,58.3,74.3
.use 38515
>>Use your Tangled Skein Thrower on Plague Sprayers
.complete 12555,1
>>Web and destroy 5 Plague Sprayers
step
.goto Zul'Drak,61,78.6
>>Click the Chunks of Saronite - They look like tiny green mining nodes inside this building
.complete 12584,1
>>Collect Chunk of Saronite
step
.goto Zul'Drak,58.3,72
.target Specialist Cogwheel
.turnin 12555 >> Turn in A Tangled Skein
step
#optional
+Make sure you have 10 Drakkari Offerings in your bags
>>If not, grind around this area until you do
step
.goto Zul'Drak,40.8,66.2,0.5
.hs >> Hearth to The Argent Stand
>>Hearth to The Argent Stand
step
.goto Zul'Drak,41,67
.target Eitrigg
.turnin 12584 >> Turn in Pure Evil
step
.goto Zul'Drak,40.3,66.6
.target Commander Kunz
.turnin 12596 >> Turn in Pa'Troll
step
.goto Zul'Drak,58.1,72
.target Sergeant Moonshard
.accept 12552 >> Accept Death to the Necromagi
step
.goto Zul'Drak,57.6,75.2
.complete 12552,1
.mob Hath'ar Necromagus
>>Kill Hath'ar Necromagus
step
.goto Zul'Drak,58.1,72
.target Sergeant Moonshard
.turnin 12552 >> Turn in Death to the Necromagi
step
.goto Zul'Drak,60,56.7 >> Ride to Zim'Torga
step
.goto Zul'Drak,59.5,58.1
.target Witch Doctor Khufu
.turnin 12623 >> Turn in To the Witch Doctor
.accept 12627 >> Accept Breaking Through Jin'Alai
.accept 12615 >> Accept The Blessing of Zim'Torga
step
.goto Zul'Drak,59.4,57.2
.target Zim'Torga
.turnin 12615 >> Turn in The Blessing of Zim'Torga
step
.home Zim'Torga >> Set your Hearthstone to Zim'Torga
step
.goto Zul'Drak,59.2,56.2
.target Scalper Ahunae
.accept 12622 >> Accept The Leaders at Jin'Alai
step
.goto Zul'Drak,57.6,61.7
>>Click the Purple Cauldron - It's a cauldron with purple smoke in it
.complete 12627,3
>>Disturb the Purple Cauldron
step
.goto Zul'Drak,55.7,64.3
>>Click the Green Cauldron - It's a cauldron with green smoke in it
.complete 12627,2
>>Disturb the Green Cauldron
step
.goto Zul'Drak,57.2,65.3
>>Click the Blue Cauldron - It's a cauldron with blue smoke in it
.complete 12627,1
>>Disturb the Blue Cauldron
step
.goto Zul'Drak,58.8,62.7
>>Click the Red Cauldron - It's a cauldron with red smoke in it
.complete 12627,4
>>Disturb the Red Cauldron
step
.mob Jin'Alai mobs around this area
>>Kill Jin'Alai mobs around this area
>>Chulo the Mad, Gawanil, and Kutube'sa will spawn randomly next to the big totems in this area
.mob them and click their Treasure boxes that spawn
>>Kill them and click their Treasure boxes that spawn
.complete 12622,1
>>Collect Treasure of Kutube'sa
.complete 12622,2
>>Collect Treasure of Gawanil
.complete 12622,3
>>Collect Treasure of Chulo the Mad
step
.goto Zul'Drak,59.5,58.1
.target Witch Doctor Khufu
.turnin 12627 >> Turn in Breaking Through Jin'Alai
.accept 12628 >> Accept To Speak With Har'koa
step
.goto Zul'Drak,60,57.9
.target Chronicler To'kini
.accept 12635 >> Accept Relics of the Snow Leopard Goddess
step
.goto Zul'Drak,59.2,56.2
.target Scalper Ahunae
.turnin 12622 >> Turn in The Leaders at Jin'Alai
.accept 12640 >> Accept Sealing the Rifts
step
.goto Zul'Drak,59.4,56.4
.target Element-Tamer Dagoda
.accept 12639 >> Accept The Frozen Earth
step
.goto Zul'Drak,63.8,70.5
.target Har'koa
.turnin 12628 >> Turn in To Speak With Har'koa
.accept 12632 >> Accept But First My Offspring
step
.goto Zul'Drak,62.9,70.6
>>Click the Har'koan Relics - The Har'koan Relics look like upright stone tablets on the ground around this area
.complete 12635,1
>>Collect Har'koan Relic
.mob Cursed Offsprings of Har'koa
>>Kill Cursed Offsprings of Har'koa
.use 38676
>>Use your Whisker of Har'koa on their corpses
.complete 12632,1
>>Resurrect 7 Cursed Offsprings of Har'koa
step
.goto Zul'Drak,63.8,70.5
.target Har'koa
.turnin 12632 >> Turn in But First My Offspring
.accept 12642 >> Accept Spirit of Rhunok
step
.goto Zul'Drak,60,57.9
.target Chronicler To'kini
.turnin 12635 >> Turn in Relics of the Snow Leopard Goddess
.accept 12650 >> Accept Plundering Their Own
.accept 13549 >> Accept Tails Up
step
.goto Zul'Drak,59.5,58.1
.target Witch Doctor Khufu
.accept 12655 >> Accept The Blessing of Zim'Rhuk
step
.goto Zul'Drak,56.4,52.8
.mob Frozen Earths
>>Kill Frozen Earths
.complete 12639,1
>>Collect Essence of the Frozen Earth
>>Fight the Elemental Rifts - The Elemental Rifts look like swirling lightning clouds around this area
.complete 12640,1
>>Seal 7 Elemental Rifts
.collect 38551,10,12655 >> Collect 10 Drakkari Offerings
step
.goto Zul'Drak,54,49.1
.mob Priests of Rhunok
>>Kill Priests of Rhunok
.complete 12650,1
>>Collect Rhunokian Artifact
step
.goto Zul'Drak,53.4,39.2
.target Spirit of Rhunok
.turnin 12642 >> Turn in Spirit of Rhunok
.accept 12646 >> Accept My Prophet, My Enemy
step
.goto Zul'Drak,54,47.3
.mob Prophet of Rhunok
>>Kill Prophet of Rhunok
.complete 12646,1
>>Collect Arctic Bear God Mojo
step
.goto Zul'Drak,53.4,39.2
.target Spirit of Rhunok
.turnin 12646 >> Turn in My Prophet, My Enemy
.accept 12647 >> Accept An End to the Suffering
step
.goto Zul'Drak,53.4,35.9
.mob Rhunok's Tormentor
>>Kill Rhunok's Tormentor
.collect 38696,1,12647 >> Collect 1 Tormentor's Incense
step
.goto Zul'Drak,53.5,34.5
.use 38696
>>Use your Tormentor's Incense next to Rhunok's body
.complete 12647,1
.mob Rhunok
>>Kill Rhunok
step
.goto Zul'Drak,53.4,39.2
.target Spirit of Rhunok
.turnin 12647 >> Turn in An End to the Suffering
.accept 12653 >> Accept Back to Har'koa
step
.goto Zul'Drak,59.3,44.5
.target Zim'Rhuk
.turnin 12655 >> Turn in The Blessing of Zim'Rhuk
step
.goto Zul'Drak,59.2,56.2
.target Scalper Ahunae
.turnin 12640 >> Turn in Sealing the Rifts
.accept 12659 >> Accept Scalps!
step
.goto Zul'Drak,59.4,56.4
.target Element-Tamer Dagoda
.turnin 12639 >> Turn in The Frozen Earth
.accept 12662 >> Accept Bringing Down Heb'Jin
step
.goto Zul'Drak,60,57.9
.target Chronicler To'kini
.turnin 12650 >> Turn in Plundering Their Own
step
.goto Zul'Drak,63.8,70.5
.target Har'koa
.turnin 12653 >> Turn in Back to Har'koa
.accept 12665 >> Accept I Sense a Disturbance
step
.goto Zul'Drak,63.8,70.5
.target Har'koa
>>Ask to call one of her children to carry you into the Altar of Quetz'lun
.complete 12665,1
>>Reveal Quetz'lun's fate
step
.goto Zul'Drak,63.8,70.5
>>When you return to 63.8,70.5
.target Har'koa
.turnin 12665 >> Turn in I Sense a Disturbance
.accept 12666 >> Accept Preparations for the Underworld
step
.goto Zul'Drak,64.1,69.9
.mob Har'koan Subduers
>>Kill Har'koan Subduers
.mob Claws of Har'koa
>>Kill Claws of Har'koa
.complete 12666,1
>>Collect Sacred Adornment
step
.goto Zul'Drak,63.8,70.5
.target Har'koa
.turnin 12666 >> Turn in Preparations for the Underworld
.accept 12667 >> Accept Seek the Wind Serpent Goddess
step
.goto Zul'Drak,74.3,66.7
.use 44890
>>Use To'kini's Blowgun on Frost Leopards and Icepaw Bears around this area
>>Click the mobs when they get knocked out and lift their tail to check if they are male or female
.complete 13549,1
>>Recover 3 Female Frost Leopards
.complete 13549,2
>>Recover 3 Female Icepaw Bears
step
.goto Zul'Drak,75.4,58.6
.target Quetz'lun's Spirit
.turnin 12667 >> Turn in Seek the Wind Serpent Goddess
.accept 12672 >> Accept Setting the Stage
step
.goto Zul'Drak,74.6,59.8
>>Click the Underworld Power Fragments - They look like brownish floating crystals
.complete 12672,1
>>Collect Underworld Power Fragment
step
.goto Zul'Drak,75.4,58.6
.target Quetz'lun's Spirit
.turnin 12672 >> Turn in Setting the Stage
.accept 12668 >> Accept Foundation for Revenge
step
>>They look like altars all around this whole area
.mob Quetz'lun Worshippers and Serpent-Touched Berserkers next to the Soul Fonts
>>Kill Quetz'lun Worshippers and Serpent-Touched Berserkers next to the Soul Fonts
.complete 12668,1
>>Kill 12 Trolls near a Soul Font
step
.goto Zul'Drak,75.4,58.6
.target Quetz'lun's Spirit
.turnin 12668 >> Turn in Foundation for Revenge
.accept 12674 >> Accept Hell Hath a Fury
step
.goto Zul'Drak,74.5,57.4
.use 39158
>>Use Quetz'lun's Hexxing Stick on High Priest Mu'funu
.mob High Priest Mu'funu
>>Kill High Priest Mu'funu
.complete 12674,1
>>Hex High Priest Mu'funu at death
step
.goto Zul'Drak,73.5,60.8
.use 39158
>>Use Quetz'lun's Hexxing Stick on High Priest Tua-Tua
.mob High Priest Tua-Tua
>>Kill High Priest Tua-Tua
.complete 12674,2
>>Hex High Priest Tua-Tua at death
step
.goto Zul'Drak,76,54.9
.use 39158
>>Use Quetz'lun's Hexxing Stick on High Priest Hawinni
.mob High Priest Hawinni
>>Kill High Priest Hawinni
.complete 12674,3
>>Hex High Priest Hawinni at death
step
.goto Zul'Drak,75.4,58.6
.target Quetz'lun's Spirit
.turnin 12674 >> Turn in Hell Hath a Fury
.accept 12675 >> Accept One Last Thing
step
.goto Zul'Drak,63.8,70.5
.target Har'koa
.turnin 12675 >> Turn in One Last Thing
.accept 12684 >> Accept Blood of a Dead God
step
.goto Zul'Drak,64.2,52.6
>>Click Heb'Jin's Drum - It's a big drum in the middle of the road
.use 39041
>>Use your Bat Net on Heb'Jin's Bat to pin it to the ground
.complete 12662,1
.mob Heb'Jin
>>Kill Heb'Jin
step
.goto Zul'Drak,64.6,57
.mob Heb'Drakkar trolls
>>Kill Heb'Drakkar trolls
.use 38731
>>Use Ahunae's Knife on their corpses to scalp them
.complete 12659,1
>>Scalp 10 Heb'Drakkar trolls
step
.goto Zul'Drak,70.5,50.4
.mob Bloods of Mam'toth
>>Kill Bloods of Mam'toth
.complete 12684,1
>>Collect Blood of Mam'toth
step
.goto Zul'Drak,59.3,57.2,0.5
.hs >> Hearth to Zim'Torga
>>Hearth to Zim'Torga
step
.goto Zul'Drak,59.4,56.4
.target Element-Tamer Dagoda
.turnin 12662 >> Turn in Bringing Down Heb'Jin
step
.goto Zul'Drak,59.2,56.2
.target Scalper Ahunae
.turnin 12659 >> Turn in Scalps!
step
.goto Zul'Drak,60,57.9
.target Chronicler To'kini
.turnin 13549 >> Turn in Tails Up
step
.goto Zul'Drak,63.8,70.5
.target Har'koa
.turnin 12684 >> Turn in Blood of a Dead God
.accept 12685 >> Accept You Reap What You Sow
step
.goto Zul'Drak,75.2,58.6
.use 39187
>>Use Quetz'lun's Ritual next to Quetz'lun's body
.complete 12685,1
.mob Drained Prophet of Quetz'lun
>>Kill Drained Prophet of Quetz'lun
step
.goto Zul'Drak,59.5,58.1
.target Witch Doctor Khufu
.turnin 12685 >> Turn in You Reap What You Sow
step
.goto Zul'Drak,60,57.9
.target Chronicler To'kini
.accept 12709 >> Accept Hexed Caches
step
.goto Zul'Drak,60.3,57.8
.target Har'koa
.accept 12712 >> Accept The Key of Warlord Zol'Maz
step
.goto Zul'Drak,59.4,56.4
.target Element-Tamer Dagoda
.accept 12708 >> Accept Enchanted Tiki Warriors
step
.goto Zul'Drak,59.2,56.2
.target Scalper Ahunae
.accept 12707 >> Accept Wooly Justice
step
.goto Zul'Drak,69.5,41.1
.use 39268
>>Use your Medallion of Mam'toth on Enraged Mammoths to ride them
>>Use the abilities on your mammoth hotbar
.complete 12707,1
>>Trample 12 Mam'toth Disciples to death
step
.goto Zul'Drak,68.2,35.3
.mob Drek'Maz
>>Kill Drek'Maz
.collect 39315,1,12712 >> Collect 1 Drek'Maz's Tiki
step
.goto Zul'Drak,67.9,32.8
.mob Yara
>>Kill Yara
.collect 39313,1,12712 >> Collect 1 Yara's Sword
step
.goto Zul'Drak,63.8,37.2
.mob Tiri
>>Kill Tiri
.collect 39316,1,12712 >> Collect 1 Tiri's Magical Incantation
step
.use 39316
>>Click Tiri's Magical Incantation in your bags
.collect 39314,1,12712 >> Collect 1 Tiki Dervish Ceremony
step
.goto Zul'Drak,69.2,35.9
.complete 12708,1
>>Kill 12 Enchanted Tiki Warrior
>>Click the Zol'Maz Stronghold Caches - The Zol'Maz Stronghold Caches look like bamboo boxes on the ground around this area
.complete 12709,1
>>Collect Zol'Maz Stronghold Cache
step
.goto Zul'Drak,66.2,33.4
.use 39314
>>Use your Tiki Dervish Ceremony in front of this huge metal gate
.mob Warlord Zol'Maz
>>Kill Warlord Zol'Maz
.complete 12712,1
>>Collect Key of Warlord Zol'Maz
step
.goto Zul'Drak,70.5,23.3
.target Rafae
.fp Gundrak, Zul'Drak >> Get the Gundrak flight path
step
.goto Zul'Drak,70.1,20.9
.target Chronicler Bah'Kini
.turnin 13099 >> Turn in Just Checkin'
step
.fly Zim'Torga, Zul'Drak >> Fly to Zim'Torga
>>Fly to Zim'Torga
step
.goto Zul'Drak,60.3,57.8
.target Har'koa
.turnin 12712 >> Turn in The Key of Warlord Zol'Maz
.accept 12721 >> Accept Rampage
step
.goto Zul'Drak,60,57.9
.target Chronicler To'kini
.turnin 12709 >> Turn in Hexed Caches
step
.goto Zul'Drak,59.4,56.4
.target Element-Tamer Dagoda
.turnin 12708 >> Turn in Enchanted Tiki Warriors
step
.goto Zul'Drak,59.2,56.2
.target Scalper Ahunae
.turnin 12707 >> Turn in Wooly Justice
step
.fly Gundrak, Zul'Drak >> Fly to Gundrak
>>Fly to Gundrak
step
.goto Zul'Drak,78.1,24.2
>>Click the 4 Akali Chain Anchors - They look like stone pillars with fire coming out of the top
.complete 12721,1
>>Unfetter Akali from his chains
step
.goto Zul'Drak,70.5,23.3
.target Rafae
.fly Zim'Torga, Zul'Drak >> Fly to Zim'Torga
>>Fly to Zim'Torga
step
.goto Zul'Drak,59.5,58.1
.target Witch Doctor Khufu
.turnin 12721 >> Turn in Rampage
step
.fly Bor'gorok Outpost, Borean Tundra >> Fly to Bor'gorok Outpost
>>Fly to Bor'gorok Outpost
step
.zone Sholazar Basin
>>Go north to Sholazar Basin
step
.goto Sholazar Basin,27.2,59.9
.target Debaar
.accept 12524 >> Accept Venture Co. Misadventure
step
.home Nesingwary Base Camp >> Set your Hearthstone to Nesingwary Base Camp
step
.goto Sholazar Basin,26.9,58.9
.target Chad
.accept 12624 >> Accept It Could Be Anywhere!
step
.goto Sholazar Basin,25.4,58.5
.target Weslex Quickwrench
.accept 12522 >> Accept Need an Engine, Take an Engine
step
.goto Sholazar Basin,38.7,56.7
>>Click the Flying Machine Engine - It's an engine sitting on the ground, next to a crashed plane
.complete 12522,1
>>Collect Flying Machine Engine
step
.goto Sholazar Basin,39.7,58.7
.target Monte Muzzleshot
.turnin 12521 >> Turn in Where in the World is Hemet Nesingwary?
.accept 12489 >> Accept Welcome to Sholazar Basin
step
.goto Sholazar Basin,35.5,47.4
.target Engineering Helice
.accept 12688 >> Accept Engineering a Disaster
.complete 12688,1
>>Escort Engineer Helice out of Swindlegrin's Dig
step
.goto Sholazar Basin,37.4,46.1
.complete 12524,1
>>Kill 15 Venture Company member
.mob Venture Company mobs
>>Kill Venture Company mobs
.complete 12624,1
>>Collect Golden Engagement Ring
step
.goto Sholazar Basin,27.2,59.9
.target Debaar
.turnin 12524 >> Turn in Venture Co. Misadventure
.accept 12525 >> Accept Wipe That Grin Off His Face
step
.goto Sholazar Basin,26.9,58.9
.target Chad
.turnin 12624 >> Turn in It Could Be Anywhere!
step
.goto Sholazar Basin,27.1,58.6
.target Hemet Nesingwary
.turnin 12489 >> Turn in Welcome to Sholazar Basin
.turnin 12688 >> Turn in Engineering a Disaster
step
.xp 78
]]);
RXPGuides.RegisterGuide([[
#wotlk
#ac335
#version 1
#group RestedXP WotLK Guide (H)
#subgroup Northrend 70-80
<< Horde
#name 78-80 Northrend
step
.goto Sholazar Basin,25.4,58.5
.target Weslex Quickwrench
.turnin 12522 >> Turn in Need an Engine, Take an Engine
.accept 12523 >> Accept Have a Part, Give a Part
step
.goto Sholazar Basin,32.7,46.9
>>Click the Venture Co. Spare Parts - They look like metal assorted parts on the ground around this area
.complete 12523,1
>>Collect Venture Co. Spare Parts
step
.goto Sholazar Basin,35.8,50.3
.complete 12525,2
.mob Meatpie
>>Kill Meatpie
.complete 12525,1
.mob Foreman Swindlegrin
>>Kill Foreman Swindlegrin
step
.goto Sholazar Basin,27.2,59.9
.target Debaar
.turnin 12525 >> Turn in Wipe That Grin Off His Face
step
.goto Sholazar Basin,25.4,58.5
.target Weslex Quickwrench
.turnin 12523 >> Turn in Have a Part, Give a Part
step
.goto Sholazar Basin,25.4,58.5
.target Professor Calvert
.accept 12696 >> Accept Aerial Surveillance
step
.goto Sholazar Basin,25.3,58.5
.target The Spirit of Gnomeregan
.fp Nesingwary Base Camp, Sholazar Basin >> Get the Nesingwary Base Camp flight path
step
.goto Sholazar Basin,26.7,59
.target Buck Cantwell
.accept 12549 >> Accept Dreadsaber Mastery: Becoming a Predator
step
.goto Sholazar Basin,27.1,58.6
.target Hemet Nesingwary
.accept 12520 >> Accept Rhino Mastery: The Test
step
.goto Sholazar Basin,27.1,59.9
.target Drostan
.accept 12589 >> Accept Kick, What Kick?
step
.use 38573
>>Use your RJR Rifle on the gnome close to you with an apple on his head
>>Keep using the rifle until you hit the apple
.complete 12589,1
>>Shoot the apple on Lucky Wilhelm's Head
step
.goto Sholazar Basin,27.1,59.9
.target Drostan
.turnin 12589 >> Turn in Kick, What Kick?
.accept 12592 >> Accept The Great Hunter's Challenge
step
.goto Sholazar Basin,28,56
.complete 12549,1
.mob Dreadsaber
>>Kill Dreadsaber
.complete 12520,1
.mob Shardhorn Rhino
>>Kill Shardhorn Rhino
.mob Dreadsabers and Shardhorn Rhinos
>>Kill Dreadsabers and Shardhorn Rhinos
.complete 12592,1
>>Kill 60 Game Animals
>>Another spot you can find Rhino's and Dreadsabers is at 38.2,45.3
step
.goto Sholazar Basin,26.7,59
.target Buck Cantwell
.turnin 12549 >> Turn in Dreadsaber Mastery: Becoming a Predator
.accept 12550 >> Accept Dreadsaber Mastery: Stalking the Prey
step
.goto Sholazar Basin,27.1,58.6
.target Hemet Nesingwary
.turnin 12520 >> Turn in Rhino Mastery: The Test
.accept 12526 >> Accept Rhino Mastery: The Chase
step
.goto Sholazar Basin,26.7,59.5
.target Korg the Cleaver
.accept 12804 >> Accept A Steak Fit for a Hunter
step
.goto Sholazar Basin,26.8,60.1
.target Grimbooze Thunderbrew
.accept 12634 >> Accept Some Make Lemonade, Some Make Liquor
step
.goto Sholazar Basin,27.1,59.9
.target Drostan
.turnin 12592 >> Turn in The Great Hunter's Challenge
step
.goto Sholazar Basin,27.2,59.9
.target Debaar
.accept 12551 >> Accept Crocolisk Mastery: The Trial
step
.goto Sholazar Basin,25.6,66.5
.target Oracle Soo-rahm
.turnin 12526 >> Turn in Rhino Mastery: The Chase
.accept 12543 >> Accept An Offering for Soo-rahm
step
.goto Sholazar Basin,29.5,66.4
.mob Longneck Grazers
>>Kill Longneck Grazers
.complete 12804,1
>>Collect Longneck Grazer Steak
step
.goto Sholazar Basin,29,62.5
.complete 12551,1
.mob Mangal Crocolisk
>>Kill Mangal Crocolisk
step
.goto Sholazar Basin,36.3,65.8
.mob Emperor Cobras
>>Kill Emperor Cobras
.complete 12543,1
>>Collect Intact Cobra Fang
step
.goto Sholazar Basin,37.6,61.8
>>Click the Sturdy Vines - They look like brown vines that hang from trees around this area. Sometimes a Dwarf will fall out and give you fruit you need
>>Click the fruit that falls to the ground or talk to the dwarf that falls
.complete 12634,1
>>Collect Orange
.complete 12634,2
>>Collect Banana Bunch
.complete 12634,3
>>Collect Papaya
step
.goto Sholazar Basin,50,61.5
.target Pilot Vic
.turnin 12696 >> Turn in Aerial Surveillance
.accept 12699 >> Accept An Embarassing Incident
.accept 12803 >> Accept Force of Nature
step
.goto Sholazar Basin,50.5,62.1
.target Tamara Wobblesprocket
.accept 12654 >> Accept The Part-time Hunter
step
.goto Sholazar Basin,48.6,64
>>Click the Raised Mud - They look like piles of dirt underwater in this lake
.complete 12699,1
>>Collect Vic's Keys
step
.goto Sholazar Basin,50,61.5
.target Pilot Vic
.turnin 12699 >> Turn in An Embarassing Incident
.accept 12671 >> Accept Reconnaissance Flight
step
.goto Sholazar Basin,50,61.5
>>You go flying in a plane
>>Use the abilities on your hotbar to fight the bats
>>The engine blows up and you have to fly back to Pilot Vic at 50.1,61.4
>>Land the plane inside the blue crystal circle
.macro Land Flying Machine,134400 >>/cast Land Flying Machine
>>Use the Land Flying Machine ability on your hotbar to land the plane
.complete 12671,1
>>Complete the Reconnaissance Flight
step
.goto Sholazar Basin,50,61.5
.target Pilot Vic
.turnin 12671 >> Turn in Reconnaissance Flight
step
.goto Sholazar Basin,39.9,43.7
>>Click the Dreadsaber Tracks - They look like brown paw prints on the ground around this area
.complete 12550,1
>>Identify 3 Shango Tracks
step
.goto Sholazar Basin,26.7,59
.target Buck Cantwell
.turnin 12550 >> Turn in Dreadsaber Mastery: Stalking the Prey
.accept 12558 >> Accept Dreadsaber Mastery: Ready to Pounce
step
.goto Sholazar Basin,26.7,59.5
.target Korg the Cleaver
.turnin 12804 >> Turn in A Steak Fit for a Hunter
step
.goto Sholazar Basin,26.8,60.1
.target Grimbooze Thunderbrew
.turnin 12634 >> Turn in Some Make Lemonade, Some Make Liquor
.accept 12644 >> Accept Still At It
step
.goto Sholazar Basin,26.7,60
.target "Tipsy" McManus
>>Tell him you are ready to start the distillation process
>>Click the items on the ground or on the machine that he yells at you during the process, it's random
>>Click the barrel on the ground when the process is done
.complete 12644,1
>>Collect Thunderbrew's Jungle Punch
step
.goto Sholazar Basin,26.8,60.1
.target Grimbooze Thunderbrew
.turnin 12644 >> Turn in Still At It
.accept 12645 >> Accept The Taste Test
step
.goto Sholazar Basin,27.2,59.9
.target Debaar
.turnin 12551 >> Turn in Crocolisk Mastery: The Trial
.accept 12560 >> Accept Crocolisk Mastery: The Plan
step
.goto Sholazar Basin,27.4,59.4
.use 38697
>>Use your Jungle Punch Sample on Hadrius Harlowe
.complete 12645,2
>>Complete Hadrius' taste test
step
.goto Sholazar Basin,27.1,58.6
.use 38697
>>Use your Jungle Punch Sample on Hemet Nesingwary
.complete 12645,1
>>Complete Hemet's taste test
step
.goto Sholazar Basin,25.6,66.5
.target Oracle Soo-rahm
.turnin 12543 >> Turn in An Offering for Soo-rahm
.accept 12544 >> Accept The Bones of Nozronn
step
.goto Sholazar Basin,26.1,71.6
.use 38519
>>Use Soo-rahm's Incense next to the Offering Bowl
.complete 12544,1
>>Reveal the Location of Farunn
step
.goto Sholazar Basin,27.1,58.6
.target Hemet Nesingwary
.turnin 12544 >> Turn in The Bones of Nozronn
.accept 12556 >> Accept Rhino Mastery: The Kill
step
.goto Sholazar Basin,33.4,34.7
.mob Shango
>>Kill Shango
.complete 12558,1
>>Collect Shango's Pelt
step
.goto Sholazar Basin,34.7,41.5
>>Click Sandferns - They look like ferns on the beach
.complete 12560,1
>>Collect Sandfern
step
.goto Sholazar Basin,47.4,43.9
.mob Farunn
>>Kill Farunn
.complete 12556,1
>>Collect Farunn's Horn
step
.goto Sholazar Basin,50.5,62.1
.use 38697
>>Use your Jungle Punch Sample on Tamara Wobblesprocket
.complete 12645,3
>>Complete Tamara's taste test
step
.fly Nesingwary Base Camp, Sholazar Basin >> Fly to Nesingwary Base Camp
>>Fly to Nesingwary Base Camp
step
.goto Sholazar Basin,27.1,58.6
.target Hemet Nesingwary
.turnin 12556 >> Turn in Rhino Mastery: The Kill
step
.goto Sholazar Basin,26.7,59
.target Buck Cantwell
.turnin 12558 >> Turn in Dreadsaber Mastery: Ready to Pounce
step
.goto Sholazar Basin,26.8,60.1
.target Grimbooze Thunderbrew
.turnin 12645 >> Turn in The Taste Test
step
.goto Sholazar Basin,27.2,59.9
.target Debaar
.turnin 12560 >> Turn in Crocolisk Mastery: The Plan
.accept 12569 >> Accept Crocolisk Mastery: The Ambush
step
.goto Sholazar Basin,46.3,63.4
.use 38564
>>Use your Sandfern Disguise next to this big log laying halfway in the water
.mob Bushwhacker that spawns
>>Kill Bushwhacker that spawns
.complete 12569,1
>>Collect Bushwhacker's Jaw
step
.goto Sholazar Basin,50.5,77.3
.mob Pitch
>>Kill Pitch
.complete 12654,1
>>Collect Pitch's Remains
step
.goto Sholazar Basin,50.5,76.6
.target Tracker Gekgek
.accept 12528 >> Accept Playing Along
step
.goto Sholazar Basin,55,69.1
.target High-Shaman Rakjak
.turnin 12528 >> Turn in Playing Along
.accept 12529 >> Accept The Ape Hunter's Slave
step
>>Talk to Goregek the Gorilla Hunter who is following you
.accept 12530 >> Accept Tormenting the Softknuckles
step
.goto Sholazar Basin,57.5,73.3
.complete 12529,1
.mob Hardknuckle Forager
>>Kill Hardknuckle Forager
step
.goto Sholazar Basin,61.1,71.7
.complete 12529,2
.mob Hardknuckle Charger
>>Kill Hardknuckle Charger
step
.goto Sholazar Basin,66.9,73.2
.use 38467
>>Use your Softknuckle Poker on Softknuckles
>>A Hardknuckle Matriarch will spawn eventually
.complete 12530,1
.mob Hardknuckle Matriarch
>>Kill Hardknuckle Matriarch
step
.goto Sholazar Basin,55,69.1
.target High-Shaman Rakjak
.turnin 12529 >> Turn in The Ape Hunter's Slave
.turnin 12530 >> Turn in Tormenting the Softknuckles
.accept 12533 >> Accept The Wasp Hunter's Apprentice
step
.goto Sholazar Basin,55.5,69.7
.target Elder Harkek
.accept 12534 >> Accept The Sapphire Queen
step
.goto Sholazar Basin,59.6,75.8
.complete 12533,1
.mob Sapphire Hive Wasp
>>Kill Sapphire Hive Wasp
.complete 12533,2
.mob Sapphire Hive Drone
>>Kill Sapphire Hive Drone
step
.goto Sholazar Basin,59.4,79.1
.goto Sholazar Basin,59.4,79.1,0.3
>>The path down to The Sapphire Queen starts here
step
.goto Sholazar Basin,57.1,79.3
>>Follow the path down to 57.1,79.3
.mob Sapphire Hive Queen
>>Kill Sapphire Hive Queen
.complete 12534,1
>>Collect Stinger of the Sapphire Queen
step
.goto Sholazar Basin,55.0,69.1
>>Go outside to 55.0,69.1
.target High-Shaman Rakjak
.turnin 12533 >> Turn in The Wasp Hunter's Apprentice
.turnin 12534 >> Turn in The Sapphire Queen
step
.goto Sholazar Basin,55.5,69.7
.target Elder Harkek
.accept 12532 >> Accept Flown the Coop!
step
>>They are all around the village
>>Click the Chicken Escapees
.complete 12532,1
>>Collect Captured Chicken
step
.goto Sholazar Basin,55.5,69.7
.target Elder Harkek
.turnin 12532 >> Turn in Flown the Coop!
.accept 12531 >> Accept The Underground Menace
step
.goto Sholazar Basin,55,69.1
.target High-Shaman Rakjak
.accept 12535 >> Accept Mischief in the Making
step
.goto Sholazar Basin,56.6,84.6
>>Click the Skyreach Crystal Formations - They look like white crystal cluster on the ground along the river bank
.complete 12535,1
>>Collect Skyreach Crystal Cluster
step
.goto Sholazar Basin,49.8,85
.mob Serfex the Reaver
>>Kill Serfex the Reaver
.complete 12531,1
>>Collect Claw of Serfex
step
.goto Sholazar Basin,55,69.1
.target High-Shaman Rakjak
.turnin 12531 >> Turn in The Underground Menace
.turnin 12535 >> Turn in Mischief in the Making
.accept 12536 >> Accept A Rough Ride
step
.goto Sholazar Basin,57.3,68.4
.target Captive Crocolisk
>>Tell him let's do this
.complete 12536,1
>>Travel to Mistwhisper Refuge
step
>>When you jump off the crocodile:
.target Zepik the Gorloc Hunter
.turnin 12536 >> Turn in A Rough Ride
.accept 12537 >> Accept Lightning Definitely Strikes Twice
.accept 12538 >> Accept The Mist Isn't Listening
step
.goto Sholazar Basin,45.4,37.2
.use 38510
>>Use your Skyreach Crystal Clusters next to the stone monument
>>Click the Arranged Crystal Formation that appears
.complete 12537,1
>>Sabotage the Mistwhisper Weather Shrine
step
.goto Sholazar Basin,45.5,39.8
.complete 12538,1
>>Kill 12 Mistwhisper Gorloc
step
.use 38512
>>Use Zepik's Hunting Horn if Zepik is not standing next to you:
.target Zepik the Gorloc Hunter
.turnin 12537 >> Turn in Lightning Definitely Strikes Twice
.turnin 12538 >> Turn in The Mist Isn't Listening
.accept 12539 >> Accept Hoofing It
step
.goto Sholazar Basin,55,69.1
.target High-Shaman Rakjak
.turnin 12539 >> Turn in Hoofing It
.accept 12540 >> Accept Just Following Orders
step
.goto Sholazar Basin,55.7,64.9
.target Injured Rainspeaker Oracle
>>Pull it to its feet
.mob the crocodile that spawns
>>Kill the crocodile that spawns
.complete 12540,1
>>Locate the Injured Rainspeaker Oracle
step
.goto Sholazar Basin,55.7,64.9
.target Injured Rainspeaker Oracle
.turnin 12540 >> Turn in Just Following Orders
.accept 12570 >> Accept Fortunate Misunderstandings
>>Tell him you are ready to travel to his village now
.complete 12570,1
>>Escort the Injured Rainspeaker Oracle to Rainspeaker Canopy
step
.goto Sholazar Basin,54.6,56.3
.target High-Oracle Soo-say
.turnin 12570 >> Turn in Fortunate Misunderstandings
.accept 12571 >> Accept Make the Bad Snake Go Away
step
.use 38622
>>Use Lafoo's Bug Bag if Lafoo is not standing next to you:
.target Lafoo
.accept 12572 >> Accept Gods like Shiny Things
step
.goto Sholazar Basin,57.5,52.4
.complete 12571,2
.mob Venomtip
>>Kill Venomtip
step
.goto Sholazar Basin,52.4,53.2
.use 38622
>>Use Lafoo's Bug Bag if Lafoo is not standing next to you:
>>Stand on top of the twinkles of light on the ground around this area
>>Lafoo will dig up the treasure
>>Click the random items that appear on the ground
.complete 12572,1
>>Collect Shiny Treasures
.complete 12571,1
.mob Emperor Cobra
>>Kill Emperor Cobra
step
.goto Sholazar Basin,54.6,56.3
.target High-Oracle Soo-say
.turnin 12571 >> Turn in Make the Bad Snake Go Away
.turnin 12572 >> Turn in Gods like Shiny Things
.accept 12573 >> Accept Making Peace
step
.goto Sholazar Basin,51.3,64.6
.target Shaman Vekjik
>>Tell him you brought an offering
.complete 12573,1
>>Extend the Peace Offering to Shaman Vekjik
step
.goto Sholazar Basin,50.5,62.1
.target Tamara Wobblesprocket
.turnin 12654 >> Turn in The Part-time Hunter
step
.goto Sholazar Basin,54.6,56.3
.target High-Oracle Soo-say
.turnin 12573 >> Turn in Making Peace
.accept 12574 >> Accept Back So Soon?
step
.goto Sholazar Basin,42.1,38.6
.target Mistcaller Soo-gan
.turnin 12574 >> Turn in Back So Soon?
.accept 12575 >> Accept The Lost Mistwhisper Treasure
.accept 12576 >> Accept Forced Hand
step
.goto Sholazar Basin,40.4,26.4
.complete 12576,1
.mob Frenzyheart Spearbearer
>>Kill Frenzyheart Spearbearer
.complete 12576,2
.mob Frenzyheart Scavenger
>>Kill Frenzyheart Scavenger
step
.goto Sholazar Basin,41.3,19.8
.complete 12575,1
.mob Warlord Tartek
>>Kill Warlord Tartek
step
.goto Sholazar Basin,41.6,19.5
>>Click the Mistwhisper Treasure - It's a yellow glowing floating orb, hovering over a tree stump altar
.complete 12575,2
>>Collect Mistwhisper Treasure
step
.goto Sholazar Basin,42.1,38.6
.target Mistcaller Soo-gan
.turnin 12575 >> Turn in The Lost Mistwhisper Treasure
.turnin 12576 >> Turn in Forced Hand
.accept 12577 >> Accept Home Time!
step
.goto Sholazar Basin,26.9,59.2,0.5
.hs >> Hearth to Nesingwary Base Camp
>>Hearth to Nesingwary Base Camp
step
.goto Sholazar Basin,27.2,59.9
.target Debaar
.turnin 12569 >> Turn in Crocolisk Mastery: The Ambush
step
.goto Sholazar Basin,27.1,58.6
.target Hemet Nesingwary
.accept 12595 >> Accept In Search of Bigger Game
step
.goto Sholazar Basin,42.3,28.7
.target Dorian Drakestalker
.turnin 12595 >> Turn in In Search of Bigger Game
.accept 12603 >> Accept Sharpening Your Talons
.accept 12605 >> Accept Securing the Bait
step
.goto Sholazar Basin,44.7,27.4
.complete 12603,1
.mob Primordial Drake
>>Kill Primordial Drake
>>Attack the Primordial Drake Eggs - The Primordial Drake Eggs look like white eggs next to trees around this area
>>Click the Primordial Hatchlings that spawn
.complete 12605,1
>>Collect Primordial Hatchling
step
.goto Sholazar Basin,42.3,28.7
.target Dorian Drakestalker
.turnin 12603 >> Turn in Sharpening Your Talons
.turnin 12605 >> Turn in Securing the Bait
step
.goto Sholazar Basin,42.1,28.7
.target Colvin Norrington
.accept 12683 >> Accept Burning to Help
step
.goto Sholazar Basin,39.7,38
>>Fight Bittertide Hydras. Use your Sample Container while affected by Hydra Sputum
.use 39164
.complete 12683,1
>>Collect 5 Sputum Samples
.complete 12683,2
.mob Bittertide Hydra
step
.goto Sholazar Basin,42.1,28.7
.target Colvin Norrington
.turnin 12683 >> Turn in Burning to Help
step
.goto Sholazar Basin,42.1,28.7
.target Colvin Norrginton
.accept 12681 >> Accept Reagent Agent
step
.goto Sholazar Basin,42.1,28.9
.target Zootfizzle
.accept 12607 >> Accept A Mammoth Undertaking
.accept 12658 >> Accept My Pet Roc
step
.goto Sholazar Basin,39.3,27.3
.use 38627
>>Use your Mammoth Harness on a Shattertusk Mammoth
>>Ride the mammoth back to Zootfizzle at 42.1,28.9
.macro Hand Over Mammoth,134400 >>/cast Hand Over Mammoth
>>Use the Hand Over Mammoth ability on your hotbar
.complete 12607,1
>>Deliver the Shattertusk Mammoth
step
.goto Sholazar Basin,42.1,28.9
.target Zootfizzle
.turnin 12607 >> Turn in A Mammoth Undertaking
step
.goto Sholazar Basin,54.5,27.9
.mob Goretalon Rocs
>>Kill Goretalon Rocs
.complete 12681,1
>>Collect Twisted Roc Talon
>>Click the Roc Eggs - The Roc Eggs look like white eggs in nests on the ground around this area
.complete 12658,1
>>Collect Roc Egg
step
.goto Sholazar Basin,42.1,28.7
.target Colvin Norrington
.turnin 12681 >> Turn in Reagent Agent
step
.goto Sholazar Basin,42.1,28.9
.target Zootfizzle
.turnin 12658 >> Turn in My Pet Roc
step
.goto Sholazar Basin,54.6,56.3
.target High-Oracle Soo-say
.turnin 12577 >> Turn in Home Time!
.accept 12578 >> Accept The Angry Gorloc
step
.goto Sholazar Basin,64.5,48.7
.target Avatar of Freya
.turnin 12803 >> Turn in Force of Nature
.accept 12561 >> Accept An Issue of Trust
step
.goto Sholazar Basin,67.3,51.4
.complete 12561,1
.mob Blighted Corpse
>>Kill Blighted Corpse
.complete 12561,2
.mob Bonescythe Ravager
>>Kill Bonescythe Ravager
step
.goto Sholazar Basin,64.5,48.7
.target Avatar of Freya
.turnin 12561 >> Turn in An Issue of Trust
.accept 12611 >> Accept Returned Sevenfold
step
.goto Sholazar Basin,66.5,44.2
>>Fight Thalgran Blightbringer - He's a tall undead standing on this small hill
.use 38657
>>Use Freya's Ward in your bags to reflect Thalgran Blightbringer's Deathbolts back at him
.complete 12611,1
.mob Thalgran Blightbringer
>>Kill Thalgran Blightbringer
step
.goto Sholazar Basin,64.5,48.7
.target Avatar of Freya
.turnin 12611 >> Turn in Returned Sevenfold
.accept 12612 >> Accept The Fallen Pillar
step
.goto Sholazar Basin,65.1,60.3
>>Click the Cultist Corpse - On the ground at the very top of the pillar, next to a huge red crystal
.turnin 12612 >> Turn in The Fallen Pillar
.accept 12608 >> Accept Cultist Incursion
step
.goto Sholazar Basin,64.5,48.7
.target Avatar of Freya
.accept 12805 >> Accept Salvaging Life's Strength
step
.goto Sholazar Basin,69.7,57.9
.mob Lifeblood Elementals
>>Kill Lifeblood Elementals
.use 40397
>>Use your Lifeblood Gem on their corpses
.complete 12805,1
>>Recover 8 Lifeblood Energy
step
.goto Sholazar Basin,75.3,54.1
.complete 12578,1
>>Travel to Mosswalker Village
step
.use 38624
>>Use Moodle's Stress Ball if Moodle is not standing next to you:
.target Moodle
.turnin 12578 >> Turn in The Angry Gorloc
.accept 12580 >> Accept The Mosswalker Savior
.accept 12579 >> Accept Lifeblood of the Mosswalker Shrine
step
.goto Sholazar Basin,75.4,52.4
.target Mosswalker Victim
.complete 12580,1
>>Rescue 6 Mosswalker Victims
step
.use 38624
>>Use Moodle's Stress Ball if Moodle is not standing next to you:
.target Moodle
.turnin 12580 >> Turn in The Mosswalker Savior
step
.goto Sholazar Basin,68.9,54.6
>>Click Lifeblood Shards on the ground - They look like small red crystals on the ground around this area
.complete 12579,1
>>Collect Lifeblood Shard
step
.use 38624
>>Use Moodle's Stress Ball if Moodle is not standing next to you:
.target Moodle
.turnin 12579 >> Turn in Lifeblood of the Mosswalker Shrine
step
.goto Sholazar Basin,64.5,48.7
.target Avatar of Freya
.turnin 12608 >> Turn in Cultist Incursion
.turnin 12805 >> Turn in Salvaging Life's Strength
.accept 12617 >> Accept Exterminate the Intruders
.accept 12660 >> Accept Weapons of Destruction
step
.goto Sholazar Basin,57.5,41.1
.complete 12617,1
.mob Cultist Infiltrator
>>Kill Cultist Infiltrator
>>Click the Unstable Explosives - The Unstable Explosives look like big metal spiked balls on the ground around this area
.complete 12660,1
>>Destroy 4 Unstable Explosives
step
.goto Sholazar Basin,64.5,48.7
.target Avatar of Freya
.turnin 12617 >> Turn in Exterminate the Intruders
.turnin 12660 >> Turn in Weapons of Destruction
.accept 12620 >> Accept The Lifewarden's Wrath
step
.goto Sholazar Basin,50.1,37.3
>>Fly to the very top of this tall pillar
>>Stand under the big floating structure
.use 38684
>>Use Freya's Horn
.complete 12620,1
>>Release The Lifewarden's Wrath
step
.goto Sholazar Basin,64.5,48.7
.target Avatar of Freya
.turnin 12620 >> Turn in The Lifewarden's Wrath
.accept 12621 >> Accept Freya's Pact
step
.goto Sholazar Basin,64.5,48.7
.target Avatar of Freya
>>Ask her how you can help
.complete 12621,1
>>Collect Freya's Pact
step
.goto Sholazar Basin,64.5,48.7
.target Avatar of Freya
.turnin 12621 >> Turn in Freya's Pact
.accept 12559 >> Accept Powering the Waygate - The Maker's Perch
step
.goto Sholazar Basin,26.9,59.2,0.5
.hs >> Hearth to Nesingwary Base Camp
>>Hearth to Nesingwary Base Camp
step
.goto Sholazar Basin,28.4,39.1
.goto Sholazar Basin,28.4,39.1,0.5
>>The path to Activation Switch Gamma starts here - It's a big balcony you'll have to fly to
step
.goto Sholazar Basin,26.2,35.5
.complete 12559,1
>>Click the Activations Switch Gamma
step
.goto Sholazar Basin,64.5,48.7
.target Avatar of Freya
.turnin 12559 >> Turn in Powering the Waygate - The Maker's Perch
.accept 12613 >> Accept Powering the Waygate - The Maker's Overlook
step
.goto Sholazar Basin,80.4,55.8
>>Click the Timeworn Coffer - It's a big stone box sitting on the big balcony
.accept 12691 >> Accept A Timeworn Coffer
step
.goto Sholazar Basin,89.1,52.9
.complete 12613,1
>>Click the Activation Switch Theta
step
.goto Sholazar Basin,80.3,54.9
.mob Sholazar Guardians
>>Kill Sholazar Guardians
.complete 12691,1
>>Collect Huge Stone Key
step
.goto Sholazar Basin,80.4,55.8
>>Click the Timeworn Coffer - It's a big stone box sitting on the big balcony
.turnin 12691 >> Turn in A Timeworn Coffer
step
.goto Sholazar Basin,64.5,48.7
.target Avatar of Freya
.turnin 12613 >> Turn in Powering the Waygate - The Maker's Overlook
.accept 12548 >> Accept The Etymidian
step
.goto Sholazar Basin,40.3,82.9
.zone Un'Goro Crater
>>Stand inside the light to go through the Waygate
step
.goto Un'Goro Crater,47.4,9.2
.target The Etymidian
.turnin 12548 >> Turn in The Etymidian
.accept 12547 >> Accept The Activation Rune
step
.goto Un'Goro Crater,48.2,2.5
>>Go up the steps and into the tunnel to 48.2,2.5
.mob High Cultist Herenn
>>Kill High Cultist Herenn
.complete 12547,1
>>Collect Omega Rune
step
.goto Un'Goro Crater,47.4,9.2
.target The Etymidian
.turnin 12547 >> Turn in The Activation Rune
.accept 12797 >> Accept Back Through the Waygate
step
.goto Un'Goro Crater,50.5,7.8
.zone Sholazar Basin
>>Stand inside the light to go through the Waygate
step
.goto Sholazar Basin,64.5,48.7
.target Avatar of Freya
.turnin 12797 >> Turn in Back Through the Waygate
step
.xp 79
step
.goto Sholazar Basin,26.9,59.2,0.5
.hs >> Hearth to Nesingwary Base Camp
>>Hearth to Nesingwary Base Camp
step
.fly Dalaran >> Fly to Dalaran
>>Fly to Dalaran
step
.goto Dalaran,35,45.3
.goto Dalaran,35,45.3,0.2
>>The path down to Rin Duoctane starts here
step
.goto Dalaran,30.9,50.2
>>Go into the sewer to 30.9,50.2
.target Rin Duoctane
.accept 12853 >> Accept Luxurious Getaway!
step
.goto Dalaran,56.3,46.8
>>Go back up to the top level of the city to 56.3,46.8
.goto Crystalsong Forest,15.8,42.8,0.5
>>Click the Teleport to Violet Stand Crystal - Downstrairs in a small room, it's a blue floating trianglular jewel
step
.zone The Storm Peaks
>>Go northeast to The Storm Peaks
step
.goto The Storm Peaks,41,86.4
.target Jeer Sparksocket
.turnin 12853 >> Turn in Luxurious Getaway!
.accept 12818 >> Accept Clean Up
step
.home K3 >> Set your Hearthstone to K3
step
.goto The Storm Peaks,41.1,86.1
.target Gretchen Fizzlespark
.accept 12843 >> Accept They Took Our Men!
.accept 12844 >> Accept Equipment Recovery
step
.goto The Storm Peaks,40.9,85.3
.target Ricket
.accept 12836 >> Accept Expression of Gratitude
step
.goto The Storm Peaks,40.8,84.5
.target Skizzle Slickslide
.fp K3, The Storm Peaks >> Get the K3 flight path
step
.goto The Storm Peaks,39.8,86.4
>>Click the Charred Wreckage - They look like various metal parts on the ground around this area
.complete 12818,1
>>Collect Charred Wreckage
step
.goto The Storm Peaks,30.3,85.7
.complete 12836,1
.mob Gnarlhide
>>Kill Gnarlhide
step
.goto The Storm Peaks,41,86.4
.target Jeer Sparksocket
.turnin 12818 >> Turn in Clean Up
.accept 12819 >> Accept Just Around the Corner
step
.goto The Storm Peaks,40.9,85.3
.target Ricket
.turnin 12836 >> Turn in Expression of Gratitude
.accept 12827 >> Accept Reclaimed Rations
step
.goto The Storm Peaks,35,83.8
.mob Savage Hill gnolls
>>Kill Savage Hill gnolls
>>Click Dried Gnoll Rations crates - The Dried Gnoll Rations crates look like wooden boxes sitting on the ground around this area
.complete 12827,1
>>Collect Dried Gnoll Rations
step
.goto The Storm Peaks,40.9,85.3
.target Ricket
.turnin 12827 >> Turn in Reclaimed Rations
.accept 12828 >> Accept Ample Inspiration
step
.goto The Storm Peaks,35.1,87.8
>>Click Sparksocket's Tools - They look like a box of tools in the middle of the mine field. Navigate carefully through the wide paths in the mine field to get here. You may get blown around in order to get to this spot, but just keep trying
.complete 12819,1
>>Collect Sparksocket's Tools
step
.goto The Storm Peaks,41,86.4
.target Jeer Sparksocket
.turnin 12819 >> Turn in Just Around the Corner
.accept 12826 >> Accept Slightly Unstable
step
.goto The Storm Peaks,40.9,85.3
.target Ricket
.turnin 12826 >> Turn in Slightly Unstable
.accept 12820 >> Accept A Delicate Touch
step
.goto The Storm Peaks,43.1,81.2
.use 40676
>>Use your Improved Land Mines to place mines on the ground close to each other
.complete 12820,1
.mob Garm Attackers
>>Kill Garm Attackers
step
.goto The Storm Peaks,41.7,80
.target Tore Rumblewrench
.accept 12829 >> Accept Moving In
.accept 12830 >> Accept Ore Repossession
step
.goto The Storm Peaks,41.7,80
>>Click the U.D.E.D. Dispenser next to Tore Rumblewrench
>>Retrieve a bomb from the dispenser
.collect 40686,1,12828 >> Collect 1 U.D.E.D.
step
.goto The Storm Peaks,43.9,79.0
>>HURRY HURRY to 43.9,79.0
.use 40686
>>Use your U.D.E.D. on an Ironwool Mammoth
>>Click the Mammoth Meat on the ground
.complete 12828,1
>>Collect Hearty Mammoth Meat
step
.goto The Storm Peaks,40.4,77.8
>>Go into the cave to 40.4,77.8
.complete 12829,1
.mob Crystalweb Spiders
>>Kill Crystalweb Spiders
step
.goto The Storm Peaks,41.5,74.9
.target Injured Goblin Miner
.accept 12831 >> Accept Only Partly Forgotten
step
.goto The Storm Peaks,44,75.9
.mob Snowblind Diggers
>>Kill Snowblind Diggers
.complete 12830,1
>>Collect Impure Saronite Ore
step
.goto The Storm Peaks,47.1,72.3
.mob Icetip Crawlers
>>Kill Icetip Crawlers
.complete 12831,1
>>Collect Icetip Venom Sac
step
.goto The Storm Peaks,43.5,75.2
.target Injured Goblin Miner
.turnin 12831 >> Turn in Only Partly Forgotten
.accept 12832 >> Accept Bitter Departure
step
.goto The Storm Peaks,43.5,75.2
.target Injured Goblin Miner
>>Tell the miner you're ready
.complete 12832,1
>>Escort the Injured Goblin Miner to K3
step
.goto The Storm Peaks,39.8,73.3
>>Fly up to 39.8,73.3
.mob Sifreldar Storm Maidens
>>Kill Sifreldar Storm Maidens
.collect 40641,5,12843 >> Collect 5 Cold Iron Key
>>Click the Rusty Cages
.complete 12843,1
>>Free 5 Goblin Prisoners
>>Click the K3 Equipment crates - The K3 Equipment crates look like wooden crates on the ground around town
.complete 12844,1
>>Collect K3 Equipment
step
.goto The Storm Peaks,41.7,80
.target Tore Rumblewrench
.turnin 12829 >> Turn in Moving In
.turnin 12830 >> Turn in Ore Repossession
step
.goto The Storm Peaks,40.9,85.3
.target Ricket
.turnin 12820 >> Turn in A Delicate Touch
.turnin 12828 >> Turn in Ample Inspiration
.turnin 12832 >> Turn in Bitter Departure
.accept 12821 >> Accept Opening the Backdoor
step
.goto The Storm Peaks,41.1,86.1
.target Gretchen Fizzlespark
.turnin 12843 >> Turn in They Took Our Men!
.accept 12846 >> Accept Leave No Goblin Behind
.turnin 12844 >> Turn in Equipment Recovery
step
.goto The Storm Peaks,45.1,82.4
>>Click the Transporter Power Cell - It looks like a small red barrel
.complete 12821,2
>>Collect Transporter Power Cell
step
.goto The Storm Peaks,50.7,81.9
.use 40731
>>Use your Transporter Power Cell next to the Teleportation Pad
.complete 12821,1
>>Activate the Garm Teleporter
step
.goto The Storm Peaks,40.9,85.3
.target Ricket
.turnin 12821 >> Turn in Opening the Backdoor
.accept 12822 >> Accept Know No Fear
step
.goto The Storm Peaks,48.1,81.9
>>Go inside the cave to 48.1,81.9
.complete 12822,1
.mob Garm Watcher
>>Kill Garm Watcher
.complete 12822,2
.mob Snowblind Devotee
>>Kill Snowblind Devotee
step
.goto The Storm Peaks,42.8,68.9
>>Go outside and fly up into the cave to 42.8,68.9
.target Lok'lira the Crone
.turnin 12846 >> Turn in Leave No Goblin Behind
.accept 12841 >> Accept The Crone's Bargain
step
.goto The Storm Peaks,44.2,68.9
.mob Overseer Syra
>>Kill Overseer Syra
.complete 12841,1
>>Collect Runes of the Yrkvinn
step
.goto The Storm Peaks,42.8,68.9
.target Lok'lira the Crone
.turnin 12841 >> Turn in The Crone's Bargain
.accept 12905 >> Accept Mildred the Cruel
step
.goto The Storm Peaks,44.4,68.9
.target Mildred the Cruel
.turnin 12905 >> Turn in Mildred the Cruel
.accept 12906 >> Accept Discipline
step
.goto The Storm Peaks,44.8,70.3
.use 42837
>>Use your Disciplining Rod on Exhausted Vrykul
.complete 12906,1
>>Discipline 6 Exhausted Vrykul
step
.goto The Storm Peaks,44.4,68.9
.target Mildred the Cruel
.turnin 12906 >> Turn in Discipline
.accept 12907 >> Accept Examples to be Made
step
.goto The Storm Peaks,45.4,69.1
.complete 12907,1
.mob Garhal
>>Kill Garhal
step
.goto The Storm Peaks,44.4,68.9
.target Mildred the Cruel
.turnin 12907 >> Turn in Examples to be Made
.accept 12908 >> Accept A Certain Prisoner
step
.goto The Storm Peaks,42.8,68.9
.target Lok'lira the Crone
.turnin 12908 >> Turn in A Certain Prisoner
.accept 12921 >> Accept A Change of Scenery
step
.goto The Storm Peaks,47.5,69.1
>>Follow the path in the mine east out to the other side to 47.5,69.1
.target Lok'lira the Crone
.turnin 12921 >> Turn in A Change of Scenery
.accept 12969 >> Accept Is That Your Goblin?
step
.goto The Storm Peaks,48.2,69.8
.target Agnetta Tyrsdottar
>>Tell her to skip the warmup
.complete 12969,1
.mob Agnetta Tyrsdottar
>>Kill Agnetta Tyrsdottar
step
.goto The Storm Peaks,47.5,69.1
.target Lok'lira the Crone
.turnin 12969 >> Turn in Is That Your Goblin?
.accept 12970 >> Accept The Hyldsmeet
step
.goto The Storm Peaks,47.5,69.1
.target Lok'lira the Crone
>>Ask her about her proposal
.complete 12970,1
>>Listen to Lok'lira's proposal
step
.goto The Storm Peaks,47.5,69.1
.target Lok'lira the Crone
.turnin 12970 >> Turn in The Hyldsmeet
.accept 12971 >> Accept Taking on All Challengers
step
.goto The Storm Peaks,51,66.4
.target Victorious Challenger
.complete 12971,1
.mob Victorious Challenger
>>Kill Victorious Challenger
step
.goto The Storm Peaks,47.5,69.1
.target Lok'lira the Crone
.turnin 12971 >> Turn in Taking on All Challengers
.accept 12972 >> Accept You'll Need a Bear
step
.goto The Storm Peaks,48.4,72.1
.target Iva the Vengeful
.accept 12942 >> Accept Off With Their Black Wings
.accept 12968 >> Accept Yulda's Folly
step
.goto The Storm Peaks,48.4,72.1
.target Thyra Kvinnshal
.accept 12925 >> Accept Aberrations
step
.goto The Storm Peaks,53.1,65.7
.target Brijana
.turnin 12972 >> Turn in You'll Need a Bear
.accept 12851 >> Accept Going Bearback
step
.goto The Storm Peaks,53.1,65.7
>>Click Icefang to ride him - Standing down the hill, Icefang is a white bear
.macro Flaming Arrow,134400 >>/cast Flaming Arrow
>>While riding Icefang, use the Flaming Arrow ability on your hotbar to shoot arrows at the Frostworgs and Frost Giants
.complete 12851,1
>>Burn 7 Frostworgs
.complete 12851,2
>>Burn 15 Frost Giants
step
.goto The Storm Peaks,53.1,65.7
.target Brijana
.turnin 12851 >> Turn in Going Bearback
.accept 12856 >> Accept Cold Hearted
step
.goto The Storm Peaks,63.9,62.5
>>Fly to 63.9,62.5
>>Click the Captive Proto-Drakes to ride them - The Captive Proto-Drakes are chained up flying in the sky
.macro Ice Shard,134400 >>/cast Ice Shard
>>Use your Ice Shard ability on the Brunnhildar Prisoners
>>When your Proto-Drake is holding 3 Brunnhildar Prisoners, start flying toward Brunnhildar Village, the drake will eventually go on autopilot. Repeat this process 2 more times
.complete 12856,1
>>Rescue 9 Brunnhildar Prisoners
.complete 12856,2
>>Free 3 Proto-Drakes
step
.goto The Storm Peaks,53.1,65.7
.target Brijana
.turnin 12856 >> Turn in Cold Hearted
.accept 13063 >> Accept Deemed Worthy
step
.goto The Storm Peaks,49.7,71.8
.target Astrid Bjornrittar
.turnin 13063 >> Turn in Deemed Worthy
.accept 12900 >> Accept Making a Harness
step
.goto The Storm Peaks,47.9,74.7
.mob Icemane Yetis
>>Kill Icemane Yetis
.complete 12900,1
>>Collect Icemane Yeti Hide
step
.goto The Storm Peaks,49.7,71.8
.target Astrid Bjornrittar
.turnin 12900 >> Turn in Making a Harness
.accept 12983 >> Accept The Last of Her Kind
.accept 12989 >> Accept The Slithering Darkness
step
.goto The Storm Peaks,55.8,63.9
.complete 12989,1
>>Kill 8 Ravenous Jormungar inside this cave
step
.goto The Storm Peaks,54.8,60.4
>>Follow the path in the cave to 54.8,60.4
>>Click the Injured Icemaw Matriarch - She's a big white bear laying on the ground inside this cave
>>The bear runs back to Brunnhildar Village
.complete 12983,1
>>Rescue the Icemaw Matriarch
step
.goto The Storm Peaks,49.7,71.8
.target Astrid Bjornrittar
.turnin 12983 >> Turn in The Last of Her Kind
.accept 12996 >> Accept The Warm-Up
.turnin 12989 >> Turn in The Slithering Darkness
step
.use 42481
.vehicle
>>Use your Reins of the Icemaw Matriarch outside the building to ride a bear
step
.goto The Storm Peaks,50.8,67.7
>>Use the abilities on your hotbar to fight Kirgaraak - He's a big white yeti
.complete 12996,1
>>Defeat Kirgaraak
step
.goto The Storm Peaks,49.7,71.8
.target Astrid Bjornrittar
.turnin 12996 >> Turn in The Warm-Up
.accept 12997 >> Accept Into the Pit
step
.exitvehicle
>>Click the red arrow to get off the bear
step
.goto The Storm Peaks,49.1,69.4
.use 42499
>>Use your Reins of the Icemaw Matriarch inside The Pit of the Fang to ride a bear
>>Use the abilities on your hotbar to fight Hyldsmeet Warbears
.complete 12997,1
.mob Hyldsmeet Warbear
>>Kill Hyldsmeet Warbear
step
.exitvehicle
>>Click the red arrow to get off the bear
step
.goto The Storm Peaks,49.7,71.8
.target Astrid Bjornrittar
.turnin 12997 >> Turn in Into the Pit
.accept 13061 >> Accept Prepare for Glory
step
.goto The Storm Peaks,47.5,69.1
.target Lok'lira the Crone
.turnin 13061 >> Turn in Prepare for Glory
.accept 13062 >> Accept Lok'lira's Parting Gift
step
.goto The Storm Peaks,50.9,65.6
.target Gretta the Arbiter
.turnin 13062 >> Turn in Lok'lira's Parting Gift
.accept 12886 >> Accept The Drakkensryd
step
>>You fly off on a drake and start flying in circles around a tower:
.use 41058
>>Use your Hyldnir Harpoon in your bags on Hyldsmeet Proto-Drakes to harpoon over to a new drake
.mob Hyldsmeet Drakeriders
>>Kill Hyldsmeet Drakeriders
>>Repeat this process 9 more times
.complete 12886,1
>>Defeat 10 Hyldsmeet Drakeriders
step
>>They look like light fixtures on the side of the stone columns
.use 41058
.exitvehicle
>>Use your Hyldnir Harpoon in your bags on a Column Ornament to get off the drake
step
.goto The Storm Peaks,33.4,58
.target Thorim
.turnin 12886 >> Turn in The Drakkensryd
.accept 13064 >> Accept Sibling Rivalry
step
.goto The Storm Peaks,33.4,58
.target Thorim
>>Ask him what became of Sif
.complete 13064,1
>>Hear Thorim's History
step
.goto The Storm Peaks,33.4,58
.target Thorim
.turnin 13064 >> Turn in Sibling Rivalry
.accept 12915 >> Accept Mending Fences
step
.goto The Storm Peaks,27.3,63.7
.complete 12942,1
.mob Nascent Val'kyr
>>Kill Nascent Val'kyr
.mob Valkyrion Aspirants
>>Kill Valkyrion Aspirants
.collect 41612,6,12925 >> Collect 6 Vial of Frost Oil
step
.goto The Storm Peaks,23.7,58.3
.use 41612
>>Use your Vials of Frost Oil on the Plagued Proto-Drake Eggs
>>Try to get 6 at a time
.complete 12925,1
>>Destroy 30 Plagued Proto-Drake Eggs
step
.goto The Storm Peaks,24,61.8
.complete 12968,1
.mob Yulda the Stormspeaker
>>Kill Yulda the Stormspeaker
>>Click the Harpoon Crate - The Harpoon Crate looks like a huge square chest
.accept 12953 >> Accept Valkyrion Must Burn
step
.goto The Storm Peaks,26,59.8
>>Click the Valkyrion Harpoon Guns - They look like bronze dragon guns
.macro Flaming Harpoon,134400 >>/cast Flaming Harpoon
>>Use the Flaming Harpoon abilitiy on your hotbar to shoot the tan bundles of straw near buildings and in wagons around this area
.complete 12953,1
>>Start 6 Fires
step
.exitvehicle
>>Click the red arrow to get off the gun
step
.goto The Storm Peaks,41.0,85.9,0.5
.hs >> Hearth to K3
>>Hearth to K3
step
.goto The Storm Peaks,40.9,85.3
.target Ricket
.turnin 12822 >> Turn in Know No Fear
step
.goto The Storm Peaks,48.4,72.1
.target Thyra Kvinnshal
.turnin 12925 >> Turn in Aberrations
step
.goto The Storm Peaks,48.4,72.1
.target Iva the Vengeful
.turnin 12942 >> Turn in Off With Their Black Wings
.turnin 12968 >> Turn in Yulda's Folly
.turnin 12953 >> Turn in Valkyrion Must Burn
step
.goto The Storm Peaks,75.8,63
>>Click the Granite Boulders and get them 1 at a time - The Granite Boulders look like big grey rocks on the ground around this area
.use 41505
>>Use Thorim's Charm of Earth on the Stormforged Iron Giants
>>Help the dwarves kill them
.complete 12915,2
.mob Stormforged Iron Giants
>>Kill Stormforged Iron Giants
>>Get Slag Covered Metal
.use 41556
>>Click the Slag Covered Metal in your bags
.accept 12922 >> Accept The Refiner's Fire
step
.goto The Storm Peaks,75.4,63.5
.mob Seething Revenants
>>Kill Seething Revenants
.complete 12922,1
>>Collect Furious Spark
step
.goto The Storm Peaks,77.2,62.9
>>Click a Granite Boulder and get one - The Granite Boulders look like big grey rocks on the ground around this area
.use 41505
>>Use Thorim's Charm of Earth on Fjorn
>>Help the dwarves kill him
.complete 12915,1
.mob Fjorn
>>Kill Fjorn
step
.goto The Storm Peaks,77.2,62.9
>>Click Fjorn's Anvil - Fjorn's Anvil is a huge anvil
.turnin 12922 >> Turn in The Refiner's Fire
.accept 12956 >> Accept A Spark of Hope
step
.goto The Storm Peaks,33.4,58
.target Thorim
.turnin 12956 >> Turn in A Spark of Hope
.turnin 12915 >> Turn in Mending Fences
.accept 12924 >> Accept Forging an Alliance
step
.goto The Storm Peaks,62.6,60.9
.target Halvdan
.fp Dun Niffelem, The Storm Peaks >> Get the Dun Niffelem flight path
step
.goto The Storm Peaks,65.4,60.2
.target King Jokkum
.accept 12966 >> Accept You Can't Miss Him
step
.goto The Storm Peaks,75.4,63.6
.target Njormeld
.turnin 12966 >> Turn in You Can't Miss Him
.accept 12967 >> Accept Battling the Elements
step
.goto The Storm Peaks,75.7,63.9
.vehicle
>>Click Snorri to accompany on him - Standing on the side of the road
step
.goto The Storm Peaks,76.7,63.4
.macro Gather Snow,134400 >>/cast Gather Snow
>>Use the Gather Snow ability on your hotbar to gather snow from Snowdrifts
.macro Throw Snowball,134400 >>/cast Throw Snowball
>>Use the Throw Snowball ability on your hotbar to throw the snow at Seething Revenants
.complete 12967,1
.mob Seething Revenants
>>Kill Seething Revenants
step
.exitvehicle
>>Click the red arrow on your hotbar to leave Snorri
step
.goto The Storm Peaks,75.4,63.6
.target Njormeld
.turnin 12967 >> Turn in Battling the Elements
step
.goto The Storm Peaks,63.2,63.2
.target Njormeld
.turnin 12924 >> Turn in Forging an Alliance
.accept 13009 >> Accept A New Beginning
step
.goto The Storm Peaks,63.2,62.9
>>Click Fjorn's Anvil - It's a huge anvil on an ice platform
.accept 12981 >> Accept Hot and Cold
step
.goto The Storm Peaks,65.4,60.2
.target King Jokkum
.accept 12975 >> Accept In Memoriam
step
.goto The Storm Peaks,69.7,60.2
.mob Brittle Revenants
>>Kill Brittle Revenants
.collect 42246,6,12981 >> Collect 6 Essence of Ice
step
.goto The Storm Peaks,75.3,62.8
.use 42246
>>Use your Essences of Ice next to Smoldering Scraps
>>Click the Frozen Iron Scraps
.complete 12981,1
>>Collect Frozen Iron Scrap
step
.goto The Storm Peaks,72.1,49.4
>>Click the Horn Fragments - The Horn Fragments look like grey scraps on the ground around this area
.complete 12975,1
>>Collect Horn Fragment
>>Kill mobs in the area
.collect 42780,10,12975 >> Collect 10 Relic of Ulduar
step
.goto The Storm Peaks,65.4,60.2
.target King Jokkum
.turnin 12975 >> Turn in In Memoriam
.accept 12976 >> Accept A Monument to the Fallen
step
.goto The Storm Peaks,63.2,63.2
.target Njormeld
.turnin 12976 >> Turn in A Monument to the Fallen
step
.goto The Storm Peaks,63.2,62.9
>>Click Fjorn's Anvil - It's a huge anvil on an ice platform
.turnin 12981 >> Turn in Hot and Cold
step
.goto The Storm Peaks,63.2,63.2
.target Njormeld
.accept 12985 >> Accept Forging a Head
step
.goto The Storm Peaks,64.1,65.1
>>Click Hodir's Horn - It's a huge bone war horn
.accept 12977 >> Accept Blowing Hodir's Horn
step
.goto The Storm Peaks,65.4,60.2
.target King Jokkum
.accept 13011 >> Accept Jormuttar is Soo Fat...
step
.goto The Storm Peaks,69.7,58.9
.use 42424
>>Use your Diamond Tipped Pick on Dead Iron Giants
.mob the Stormforged Ambushers that spawn
>>Kill the Stormforged Ambushers that spawn
.complete 12985,1
>>Collect Stormforged Eye
step
.goto The Storm Peaks,72.1,51.8
.mob Niffelem Forefathers and Restless Frostborn Ghosts
>>Kill Niffelem Forefathers and Restless Frostborn Ghosts
.use 42164
>>Use Hodir's Horn on their corpses
.complete 12977,1
>>Free 5 Niffelem Forefathers
.complete 12977,2
>>Free 5 Restless Frostborn
step
.goto The Storm Peaks,63.2,63.2
.target Njormeld
.turnin 12985 >> Turn in Forging a Head
.accept 12987 >> Accept Mounting Hodir's Helm
step
.goto The Storm Peaks,64.1,65.1
>>Click Hodir's Horn - It's a huge bone war horn
.turnin 12977 >> Turn in Blowing Hodir's Horn
step
.goto The Storm Peaks,64.3,59.2
>>Fly to the tip of this ice spike
.use 42442
>>Use the Tablets of Pronouncement in your bags
.complete 12987,1
>>Mount Hodir's Helm
step
.goto The Storm Peaks,63.2,63.2
.target Njormeld
.turnin 12987 >> Turn in Mounting Hodir's Helm
step
.goto The Storm Peaks,64.2,59.2
>>Click Hodir's Helm - It's a huge helm on the tip of this ice spike
.accept 13006 >> Accept Polishing the Helm
step
.goto The Storm Peaks,55.6,63.4
.mob Viscous Oils inside this cave
>>Kill Viscous Oils inside this cave
.complete 13006,1
>>Collect Viscous Oil
.use 42732
>>Use your Everfrost Razor on Dead Icemaw Bears
.collect 42733,1,13011 >> Collect 1 Icemaw Bear Flank
step
.goto The Storm Peaks,54.7,60.8
>>Follow the path inside the cave to this spot
.use 42733
>>Use your Icemaw Bear Flank while standing on the small frozen pond with a bunch of rocks on it
.complete 13011,1
.mob Jormuttar
>>Kill Jormuttar
step
.goto The Storm Peaks,33.4,58.0
>>Go outside and go to 33.4,58.0
.target Thorim
.turnin 13009 >> Turn in A New Beginning
.accept 13050 >> Accept Veranus
step
.goto The Storm Peaks,43.7,67.4
>>Click the Small Proto-Drake Eggs - They are big spiked brown eggs on top of this mountain in a nest
.complete 13050,1
>>Collect Small Proto-Drake Egg
>>You can find more Small Proto-Drake Eggs at 45.2,66.9
step
.goto The Storm Peaks,33.4,58
.target Thorim
.turnin 13050 >> Turn in Veranus
.accept 13051 >> Accept Territorial Trespass
step
.goto The Storm Peaks,38.7,65.6
>>Stand in this big nest
.use 42797
>>Click the Stolen Proto-Dragon Eggs in your bags
.complete 13051,1
>>Lure Veranus
step
.goto The Storm Peaks,33.4,58
.target Thorim
.turnin 13051 >> Turn in Territorial Trespass
.accept 13010 >> Accept Krolmir, Hammer of Storms
step
.goto The Storm Peaks,64.2,59.2
>>Click Hodir's Helm - It's a huge helm on the tip of this ice spike
.turnin 13006 >> Turn in Polishing the Helm
step
.goto The Storm Peaks,65.4,60.2
.target King Jokkum
.turnin 13011 >> Turn in Jormuttar is Soo Fat...
step
.goto The Storm Peaks,65.4,60.2
.target King Jokkum
>>Ask him what has become of Krolmir
.complete 13010,1
>>Discover Krolmir's Fate
step
.goto The Storm Peaks,71.4,48.8
.target Thorim
.turnin 13010 >> Turn in Krolmir, Hammer of Storms
.accept 13057 >> Accept The Terrace of the Makers
step
.goto The Storm Peaks,56.2,51.3
.target Thorim
.turnin 13057 >> Turn in The Terrace of the Makers
.accept 13005 >> Accept The Earthen Oath
.accept 13035 >> Accept Loken's Lackeys
step
.goto The Storm Peaks,57.3,46.7
.use 42840
>>Use your Horn of the Peaks to summon earthen helpers
>>Fight mobs around this area
.complete 13005,1
.mob Iron Sentinel
>>Kill Iron Sentinel
.complete 13005,2
.mob Iron Dwarf Assailant
>>Kill Iron Dwarf Assailant
step
.goto The Storm Peaks,55.3,43.3
>>Fly up into the building to 55.3,43.3
.use 42840
>>Use your Horn of the Peaks to summon earthen helpers
.complete 13035,1
.mob Eisenfaust
>>Kill Eisenfaust
step
.goto The Storm Peaks,48.6,45.6
.use 42840
>>Use your Horn of the Peaks to summon earthen helpers
.complete 13035,2
.mob Halefnir the Windborn
>>Kill Halefnir the Windborn
step
.goto The Storm Peaks,45,38.1
.use 42840
>>Use your Horn of the Peaks to summon earthen helpers
.complete 13035,3
.mob Duronn the Runewrought
>>Kill Duronn the Runewrought
step
.goto The Storm Peaks,56.3,51.4
.target Thorim
.turnin 13005 >> Turn in The Earthen Oath
.turnin 13035 >> Turn in Loken's Lackeys
step
.goto The Storm Peaks,36.2,49.4
.target Kabarg Windtamer
.fp Grom'arsh Crash-Site, The Storm Peaks >> Get the Grom'arsh Crash-Site flight path
step
.goto The Storm Peaks,36.4,49.1
.target Bloodguard Lorga
.accept 13054 >> Accept The Missing Tracker
.accept 13000 >> Accept Emergency Measures
step
.goto The Storm Peaks,37.0,49.5
.target Olut Alegut
.accept 12882 >> Accept Ancient Relics
step
.goto The Storm Peaks,37.3,49.7
.target Boktar Bloodfury
.accept 12895 >> Accept The Missing Bronzebeard
step
.home Grom'arsh Crash-Site >> Set your Hearthstone to Grom'arsh Crash-Site
step
.goto The Storm Peaks,48.5,54.3
>>Go inside the cave to 48.5,54.3
.target Tracker Val'zij
.turnin 13054 >> Turn in The Missing Tracker
.accept 13055 >> Accept Cave Medicine
step
.collect 42926,8,13055 >> Collect 8 Cave Mushroom
.mob Infesting Jormungars
>>Kill Infesting Jormungars
.collect 42927,1,13055 >> Collect 1 Toxin Gland
step
.goto The Storm Peaks,48.5,54.3
.target Tracker Val'zij
.turnin 13055 >> Turn in Cave Medicine
.accept 13056 >> Accept There's Always Time for Revenge
step
.goto The Storm Peaks,48.2,48.1
>>Go deeper into the cave to 48.2,48.1
.mob Ravaged Cavedweller Worgs
>>Kill Ravaged Cavedweller Worgs
.collect 42510,6,13056 >> Collect 6 Worg Fur
.complete 13056,1
.mob Gimorak
>>Kill Gimorak
step
.goto The Storm Peaks,48.5,54.3
.target Tracker Val'zij
.turnin 13056 >> Turn in There's Always Time for Revenge
step
.goto The Storm Peaks,36.1,64.1
>>Click the Disturbed Snow pile
.collect 40947,1,12895 >> Collect 1 Burlap-Wrapped Note
step
.goto The Storm Peaks,36.4,49.1
.target Bloodguard Lorga
.turnin 13000 >> Turn in Emergency Measures
step
.goto The Storm Peaks,37.3,49.7
.target Boktar Bloodfury
.turnin 12895 >> Turn in The Missing Bronzebeard
.accept 12909 >> Accept The Nose Knows
step
.goto The Storm Peaks,40.8,51.2
.target Khaliisi
.turnin 12909 >> Turn in The Nose Knows
.accept 12910 >> Accept Sniffing Out the Perpetrator
step
>>Click Frostbite to ride him
>>Use the abilities on your hotbar to keep the dwarves away from you
.complete 12910,1
>>Track scent to its source
step
.goto The Storm Peaks,48.5,60.8
.complete 12910,2
.mob Tracker Thulin
>>Kill Tracker Thulin
.collect 40971,1,12910 >> Collect 1 Brann's Communicator
step
.use 40971
>>Use Brann's Communicator in your bags
.target Brann Bronzebeard
.turnin 12910 >> Turn in Sniffing Out the Perpetrator
.accept 12913 >> Accept Speak Orcish, Man!
step
.goto The Storm Peaks,37.3,49.7
.target Moteha Windborn
.turnin 12913 >> Turn in Speak Orcish, Man!
.accept 12917 >> Accept Speaking with the Wind's Voice
step
.goto The Storm Peaks,28.5,48.5
>>Kill Stormriders around this area, they drop Voices of the Wind and Relics of Ulduar
.collect 41514,5,12917 >> Collect 5 Voice of the Wind
.collect 42780,10,12882 >> Collect 10 Relic of Ulduar
step
.goto The Storm Peaks,37.0,49.5
.target Olut Alegut
.turnin 12882 >> Turn in Ancient Relics
step
.goto The Storm Peaks,37.3,49.7
.target Moteha Windborn
.turnin 12917 >> Turn in Speaking with the Wind's Voice
step
.goto The Storm Peaks,37.3,49.7
.target Boktar Bloodfury
.accept 12920 >> Accept Catching up with Brann
step
.use 40971
>>Use Brann's Communicator in your bags
.target Brann Bronzebeard
.complete 12920,1
>>Complete Speak with Brann
step
.goto The Storm Peaks,37.3,49.7
.target Boktar Bloodfury
.turnin 12920 >> Turn in Catching up with Brann
.accept 12926 >> Accept Pieces of the Puzzle
step
.goto The Storm Peaks,37.9,43.9
>>Kill Library Guardians
.collect 41130,6,12926 >> Collect 6 Inventor's Disk Fragment
step
.use 41130
>>Click the Inventor's Disk Fragment
.complete 12926,1
>>Collect The Inventor's Disk
step
.use 40971
>>Click Brann's Communicator
.target Brann Bronzebeard
.turnin 12926 >> Turn in Pieces of the Puzzle
step
.xp 80
step
+Congratulations, you are now level 80!
]]);
