-- Converted from the GPL-licensed ZygorGuidesViewerRM 3.3.5 leveling routes.
-- This guide-data file remains GPL-licensed; conversion is offline and creates no runtime dependency.
RXPGuides.RegisterGuide([[
#wotlk
#ac335
#version 1
#group RestedXP WotLK Guide (A)
#subgroup Northrend 70-80
<< Alliance
#name 70-72 Northrend
#next 72-74 Northrend
step
.zone Stormwind City
>>Go to Stormwind
step
>>Go to the Auction House or get an Engineer to make you one:
.collect 39682,1 >> Buy an Overcharged Capacitor
>>Buy 1 Overcharged Capacitor
step
.goto Stormwind City,18.2,25.5
.zone Borean Tundra
>>Ride the boat to Borean Tundra
step
.goto Borean Tundra,59,68.3
.target Tomas Riverwell
.fp Valiance Keep, Borean Tundra >> Get the Valiance Keep flight path
step
.home Valiance Keep >> Set your Hearthstone to Valiance Keep
step
.goto Borean Tundra,57.8,67.6
.target Recruitment Officer Blythe
.accept 11672 >> Accept Enlistment Day
step
.goto Borean Tundra,56.7,72.6
.target General Arlos
.turnin 11672 >> Turn in Enlistment Day
.accept 11727 >> Accept A Time for Heroes
step
.goto Borean Tundra,56.4,69.6
.target Sergeant Hammerhill
.turnin 11727 >> Turn in A Time for Heroes
.accept 11797 >> Accept The Siege
step
.goto Borean Tundra,55,68.9
.target Medic Hawthorn
.accept 11789 >> Accept A Soldier in Need
step
.goto Borean Tundra,54.4,69.6
.complete 11797,1
.mob Crypt Crawler
>>Kill Crypt Crawler
step
.goto Borean Tundra,56.4,69.6
.target Sergeant Hammerhill
.turnin 11797 >> Turn in The Siege
.accept 11889 >> Accept Death From Above
step
.goto Borean Tundra,57.5,69.3
>>Click the First Aid Supplies - It's a small brown chest, downstairs in this ship, next to a candle shrine
.complete 11789,1
>>Collect Hawthorn's Anti-Venom
step
.goto Borean Tundra,57.5,69.1
>>Click the Cultist Shrine - It looks like a small candle shrine on the ground downstairs in this ship, next to the wall
.accept 11920 >> Accept Cultists Among Us
step
.goto Borean Tundra,57.8,69.2
.target Captain "Lefty" Lugsail
.turnin 11920 >> Turn in Cultists Among Us
step
.goto Borean Tundra,57.8,69.2
.target Admiral Cantlebree
.accept 11791 >> Accept Notify Arlos
step
.goto Borean Tundra,56.7,72.6
.target General Arlos
.turnin 11791 >> Turn in Notify Arlos
step
.goto Borean Tundra,56.7,72.6
.target Counselor Talbot
.accept 12141 >> Accept A Diplomatic Mission
step
.goto Borean Tundra,56.6,72.5
.target Harbinger Vurenn
.accept 11792 >> Accept Enemies of the Light
step
.goto Borean Tundra,55,68.9
.target Medic Hawthorn
.turnin 11789 >> Turn in A Soldier in Need
step
.goto Borean Tundra,55,70.5
.use 35278
>>Use your Reinforced Net on Scourged Flamespitters flying next to the fortress wall
.complete 11889,1
.mob Scourged Flamespitter
>>Kill Scourged Flamespitter
step
.goto Borean Tundra,56.4,69.6
.target Sergeant Hammerhill
.turnin 11889 >> Turn in Death From Above
.accept 11897 >> Accept Plug the Sinkholes
step
.goto Borean Tundra,50.9,72.1
.use 35704
>>Click your Incendiary Explosives
.complete 11897,1
>>Set the Explosive at the Southern Sinkhole
step
.goto Borean Tundra,54.1,63.7
.use 35704
>>Click your Incendiary Explosives
.complete 11897,2
>>Set the Explosives at the Northern Sinkhole
step
.goto Borean Tundra,53.7,60.1
.mob Cultist Necrolytes
>>Kill Cultist Necrolytes
.complete 11792,1
>>Collect Cultist Communique
step
.goto Borean Tundra,56.4,69.6
.target Sergeant Hammerhill
.turnin 11897 >> Turn in Plug the Sinkholes
.accept 11928 >> Accept Farshire
step
.goto Borean Tundra,56.8,69.5
.target Mark Hanes
.accept 11927 >> Accept Word on the Street
step
.goto Borean Tundra,56.6,72.5
.target Harbinger Vurenn
.turnin 11792 >> Turn in Enemies of the Light
.accept 11793 >> Accept Further Investigation
step
.goto Borean Tundra,58.4,67.8
.target Midge
.accept 11575 >> Accept Nick of Time
step
.goto Borean Tundra,58.7,68.4
.target Leryssa
.turnin 11927 >> Turn in Word on the Street
.accept 11599 >> Accept Thassarian, My Brother
step
.goto Borean Tundra,58.6,67.3
.target Vindicator Yaala
.turnin 11793 >> Turn in Further Investigation
.accept 11794 >> Accept The Hunt is On
step
.goto Borean Tundra,58.6,67.1
.use 35125
>>Use your Oculus of the Exorcist on "Salty" John Thorpe
.target "Salty" John Thorpe
>>Tell him you have reason to believe he is involved in cultist activity
.mob "Salty" John Thorpe
>>Kill "Salty" John Thorpe
.complete 11794,3
>>Defeat the Cultist in the kitchen
step
.goto Borean Tundra,58.8,68.7
.target Airman Skyhopper
.accept 11707 >> Accept Distress Call
step
.goto Borean Tundra,59.2,68.3
.use 35125
>>Use your Oculus of the Exorcist on Tom Hegger
.target Tom Hegger
>>Ask him about the Cult of the Damed
.mob Tom Hegger
>>Kill Tom Hegger
.complete 11794,1
>>Defeat the Cultist on the docks
step
.goto Borean Tundra,56.7,71.8
.use 35125
>>Use your Oculus of the Exorcist on Guard Mitchells
.target Guard Mitchells
>>Ask him how long he has worked for the Cult of the Damned
.mob Guard Mitchells
>>Kill Guard Mitchells
.complete 11794,2
>>Defeat the Cultist in the jail
step
.goto Borean Tundra,58.6,67.3
.target Vindicator Yaala
.turnin 11794 >> Turn in The Hunt is On
step
.goto Borean Tundra,58.2,62.8
.target Gerald Green
.turnin 11928 >> Turn in Farshire
.accept 11901 >> Accept Military?  What Military?
step
.goto Borean Tundra,56.8,55.6
>>Go inside the mine to 56.8,55.6
>>Click the Plagued Grain - Inside the mine, it looks like a bag full of grain, next to a wheel barrow
.turnin 11901 >> Turn in Military? What Military?
.accept 11902 >> Accept Pernicious Evidence
step
.goto Borean Tundra,56,55.4
.target William Allerton
.turnin 11599 >> Turn in Thassarian, My Brother
.accept 11600 >> Accept The Late William Allerton
step
.goto Borean Tundra,58.2,62.8
.target Gerald Green
.turnin 11902 >> Turn in Pernicious Evidence
.accept 11903 >> Accept It's Time for Action
step
.goto Borean Tundra,58.3,62.8
.target Wendy Darren
.accept 11913 >> Accept Take No Chances
step
.goto Borean Tundra,58.2,63
.target Jeremiah Hawning
.accept 11908 >> Accept Reference Material
step
.goto Borean Tundra,57,61.7
.complete 11903,1
.mob Plagued Scavenger
>>Kill Plagued Scavenger
.use 35491
>>Use Wendy's Torch next to Farshire Grain bags
.complete 11913,1
>>Burn 8 Farshire Grain
step
.goto Borean Tundra,55.8,58.3
>>Click Fields, Factories and Workshops - It's a little red book lying inside the burning house
.complete 11908,1
>>Collect Fields, Factories and Workshops
step
.goto Borean Tundra,58.3,62.8
.target Wendy Darren
.turnin 11913 >> Turn in Take No Chances
step
.goto Borean Tundra,58.2,62.8
.target Gerald Green
.turnin 11903 >> Turn in It's Time for Action
.accept 11904 >> Accept Fruits of Our Labor
step
.goto Borean Tundra,58.2,63
.target Jeremiah Hawning
.turnin 11908 >> Turn in Reference Material
.accept 12035 >> Accept Repurposed Technology
step
.goto Borean Tundra,58.1,61.1
.mob Harvest Collectors
>>Kill Harvest Collectors
.use 35943
>>Use Jeremiahs Tools on their corpses
.complete 12035,1
>>Rewire 5 Harvest Collectors
step
.goto Borean Tundra,57.9,53.4
>>Go inside the cave to 57.9,53.4
.mob Captain Jacobs
>>Kill Captain Jacobs
.collect 35705,1,11904 >> Collect 1 Cart Release Key
step
.goto Borean Tundra,57.2,54.6
>>Click the Cart Release switch - It's a switch on the side of a cart with blue ore inside of it
.complete 11904,1
>>Release the Ore Cart
step
.goto Borean Tundra,58.2,62.8
>>Go outside to 58.2,62.8
.target Gerald Green
.turnin 11904 >> Turn in Fruits of Our Labor
.accept 11962 >> Accept One Last Delivery
step
.goto Borean Tundra,58.2,63
.target Jeremiah Hawning
.turnin 12035 >> Turn in Repurposed Technology
step
.goto Borean Tundra,57.3,66.6
.target Hilda Stoneforge
.turnin 11962 >> Turn in One Last Delivery
.accept 11963 >> Accept Weapons for Farshire
step
.goto Borean Tundra,58.7,68.4
.target Leryssa
.turnin 11600 >> Turn in The Late William Allerton
.accept 11601 >> Accept Lost and Found
step
.goto Borean Tundra,58.3,68
.target James Deacon
.turnin 11601 >> Turn in Lost and Found
.accept 11603 >> Accept In Wine, Truth
step
.goto Borean Tundra,58.2,62.8
.target Gerald Green
.turnin 11963 >> Turn in Weapons for Farshire
.accept 11965 >> Accept Call to Arms!
step
.goto Borean Tundra,57.3,59.4
>>Click the Bell Rope - It's a huge rope hanging up the stairs in the stairwell of the town hall building
.complete 11965,1
>>Ring the Farshire Bell
step
.goto Borean Tundra,58.2,62.8
.target Gerald Green
.turnin 11965 >> Turn in Call to Arms!
step
.goto Borean Tundra,61.9,65.7
>>Go underwater to 61.9,65.7
>>Click the Wine Crate underwater in the broken ship
.complete 11603,1
>>Collect Kul Tiras Wine
step
.goto Borean Tundra,58.5,68.1
.target Old Man Colburn
.turnin 11603 >> Turn in In Wine, Truth
.accept 11604 >> Accept A Deserter
step
.goto Borean Tundra,56.7,71.5
.target Private Brau
.turnin 11604 >> Turn in A Deserter
.accept 11932 >> Accept Cowards and Fools
step
.goto Borean Tundra,47.1,75.5
.target Karuk
.turnin 12141 >> Turn in A Diplomatic Mission
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
>>Go inside the cave to 46.4,78.2
.complete 11619,1
.mob Gamel the Cruel
>>Kill Gamel the Cruel
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
>>Go into the big building to 54.7,89.1
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
>>Swim underwater to the bubbling rock at the very bottom, so you don't run out of air
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
>>He walks around the small pond in the middle of the camp
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
+Make sure you don't have Animal Blood on you. If you do, go for a swim to wash it off, before approaching the druids
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
>>He walks around the small pond in the middle of the camp
.target Killinger the Den Watcher
.turnin 11884 >> Turn in Ned, Lord of Rhinos...
step
.goto Borean Tundra,56.8,44
.target Zaza
.turnin 11865 >> Turn in Unfit for Death
.accept 11868 >> Accept The Culler Cometh
step
.goto Borean Tundra,59.5,30.4
>>Deliver the Orphaned Mammoth Calf to Khu'nok
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
>>Kill Beryl Reclaimers all around this area:
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
>>Click the Tuskarr Ritual Objects - They look like small stone fish and blue smoking bowls on the ground around this area
.complete 11609,1
>>Collect Tuskarr Ritual Object
step
.goto Borean Tundra,50.1,32.6
>>Go up the hill to 50.1,32.6
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
.goto Borean Tundra,45.3,33.3
.target Librarian Donathan
.turnin 11575 >> Turn in Nick of Time
.accept 11587 >> Accept Prison Break
step
.goto Borean Tundra,45,33.4
.target Librarian Garren
.accept 11576 >> Accept Monitoring the Rift: Cleftcliff Anomaly
step
#sticky
.goto Borean Tundra,40.5,39.2
.mob Beryl Mage Hunters
>>Kill Beryl Mage Hunters
.collect 34688,1,11587 >> Collect 1 Beryl Prison Key
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
.goto Borean Tundra,45,33.4
.target Librarian Garren
.turnin 11576 >> Turn in Monitoring the Rift: Cleftcliff Anomaly
.accept 11582 >> Accept Monitoring the Rift: Sundered Chasm
step
.goto Borean Tundra,45.3,33.3
.target Librarian Donathan
.turnin 11587 >> Turn in Prison Break
.accept 11590 >> Accept Abduction
step
.goto Borean Tundra,46.8,29.3
.goto Borean Tundra,46.8,29.3,0.5
>>The path down to Monitoring the Rift: Sundered Chasm starts here
step
.goto Borean Tundra,44,28.6
>>Go down the path and underwater to 44,28.6
.use 34669
>>Use your Arcanometer next to the huge purple glowing crack underwater
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
>>The path down to Monitoring the Rift: Winterfin Cavern starts here
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
>>Use your Arcane Binder on him when you see the 'Beryl Sorcerer can now be captured' message in your chat
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
step
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
step
.goto Borean Tundra,45.3,34.5
.target Surristrasz
.fly Transitus Shield, Coldarra >> Fly to Transitus Shield, Coldarra
>>Fly to Transitus Shield, Coldarra
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
.goto Borean Tundra,35,28
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
.complete 11918,1
.mob Coldarra Spellweaver
>>Kill Coldarra Spellweaver
.mob Glacial Ancient
>>Kill Glacial Ancient
.complete 11910,1
>>Collect Glacial Splinter
.skill herbalism,<1,1
>>Herbalism
.mob Magic-Bound Ancient
>>Kill Magic-Bound Ancient
.complete 11910,2
>>Collect Magic-Bound Splinter
>>Click Frostberry Bushes
.complete 11912,1
>>Collect Frostberry
step
.goto Borean Tundra,32.9,34.4
.target Archmage Berinand
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
>>Skip to the next step in the guide
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
>>Click Blue Dragon Eggs - They look like big eggs with blue crystals on them on the ground
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
.goto Borean Tundra,24.6,27.1
.use 35506
>>Use your Raelorasz's Spear on a Nexus Drake Hatchling
.complete 11919,1
>>Do not kill it, let it hit you until it becomes friendly
step
.goto Borean Tundra,33.3,34.5
.complete 11919,1
>>Capture the Nexus Drake
.target Raelorasz
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
>>Wait for Saragosa to appear and become human
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
.goto Borean Tundra,33.3,34.5
.target Raelorasz
.turnin 11931 >> Turn in Cracking the Code
.turnin 11967 >> Turn in Mustering the Reds
.accept 11969 >> Accept Springing the Trap
step
.xp 71
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
.fly Amber Ledge, Borean Tundra >> Fly to Amber Ledge
>>Fly to Amber Ledge
step
.goto Borean Tundra,56.6,20.1
.target Kara Thricestar
.fp Fizzcrank Airstrip, Borean Tundra >> Get the Fizzcrank Airstrip flight path
step
.home Fizzcrank Airstrip >> Set your Hearthstone to Fizzcrank Airstrip
step
.goto Borean Tundra,57,18.7
.target Fizzcrank Fullthrottle
.turnin 11707 >> Turn in Distress Call
.accept 11708 >> Accept The Mechagnomes
.target Fizzcrank Fullthrottle
.complete 11708,1
>>Listen to Fizzcrank Fullthrottle's tale
step
.goto Borean Tundra,57.4,18.7
.target Jinky Wingnut
.turnin 11708 >> Turn in The Mechagnomes
.accept 11712 >> Accept Re-Cursive
step
.goto Borean Tundra,57.4,18.7
.target Mordle Cogspinner
.accept 11710 >> Accept What's the Matter with the Transmatter?
.accept 11704 >> Accept King Mrgl-Mrgl
step
.goto Borean Tundra,57.6,18.7
.target Crafty Wobblesprocket
.accept 11645 >> Accept Dirty, Stinkin' Snobolds!
step
.goto Borean Tundra,53.1,13.5
>>Click Crafty's Stuff - They look like wooden crates on the ground around this area
.complete 11645,1
>>Collect Crafty's Stuff
step
.goto Borean Tundra,54,13.5
.goto Borean Tundra,54,13.5,0.3
>>The path down to Bonker Togglevolt starts here
step
.goto Borean Tundra,55.6,12.6
>>Go inside the cave to 55.6,12.6
.target Bonker Togglevolt
.accept 11673 >> Accept Get Me Outa Here!
.complete 11673,1
>>Escort Bonker Togglevolt to safety
step
.goto Borean Tundra,57,18.7
>>Go outside the cave to 57,18.7
.target Fizzcrank Fullthrottle
.turnin 11673 >> Turn in Get Me Outa Here!
step
.goto Borean Tundra,57.6,18.7
.target Crafty Wobblesprout
.turnin 11645 >> Turn in Dirty, Stinkin' Snobolds!
.accept 11650 >> Accept Just a Few More Things...
step
.goto Borean Tundra,58.5,17.6
.mob Fizzcrank Mechagnomes
>>Kill Fizzcrank Mechagnomes
.use 34973
>>Use the Re-Cursive Transmatter Injection on their corpses
.complete 11712,1
>>Curse & port 6 Fizzcrank Gnomes
>>Click Fizzcrank Spare Parts
.complete 11710,1
>>Collect Fizzcrank Spare Parts
.skill engineering,<1,1
>>Engineering
step
.goto Borean Tundra,58.5,17.6
.mob mechanical mobs
>>Kill mechanical mobs
>>Collect The Ultrasonic Screwdriver
.use 34984
>>Click The Ultrasonic Screwdriver
.accept 11729 >> Accept The Ultrasonic Screwdriver
step
.goto Borean Tundra,57.6,18.7
.target Crafty Wobblesprout
.turnin 11729 >> Turn in The Ultrasonic Screwdriver
.accept 11730 >> Accept Master and Servant
step
.goto Borean Tundra,57.4,18.7
.target Mordle Cogspinner
.turnin 11710 >> Turn in What's the Matter with the Transmatter?
.accept 11692 >> Accept Check in With Bixie
step
.goto Borean Tundra,57.4,18.7
.target Jinky Wingnut
.turnin 11712 >> Turn in Re-Cursive
.accept 11788 >> Accept Lefty Loosey, Righty Tighty
step
.goto Borean Tundra,57,18.7
.target Fizzcrank Fullthrottle
.accept 11725 >> Accept Finding Pilot Tailspin
step
.goto Borean Tundra,58.7,18.5
.mob robots in this area
>>Kill robots in this area
.use 35116
>>Use the Ultrasonic Screwdriver on their corpses
.complete 11730,1
>>Reprogram 15 Robots
step
.goto Borean Tundra,60.2,20.4
>>Click the West Point Station Valve - It looks like a red round handle on the side of the metal pipe
.complete 11788,1
.mob Twonky
>>Kill Twonky
step
.goto Borean Tundra,65.4,17.4
>>Click the North Point Station Valve - It looks like a red round handle on the side of the metal pipe
.complete 11788,2
.mob ED-210
>>Kill ED-210
step
.goto Borean Tundra,63.7,22.5
>>Click the Mid Point Station Valve - It looks like a red round handle on the side of the metal pipe
.complete 11788,3
.mob Max Blasto
>>Kill Max Blasto
step
.goto Borean Tundra,64.4,23.1
>>Click Crafty's Tools - It looks like a small chest, next to some steel beams on the ground
.complete 11650,1
>>Collect Crafty's Tools
step
.goto Borean Tundra,65.2,28.8
>>Click the South Point Station Valve - It looks like a red round handle ont he side of the metal pipe
.complete 11788,4
.mob The Grinder
>>Kill The Grinder
step
.goto Borean Tundra,61.7,35.8
.target Iggy "Tailspin" Cogtoggle
.turnin 11725 >> Turn in Finding Pilot Tailspin
.accept 11726 >> Accept A Little Bit of Spice
step
.goto Borean Tundra,61.1,44.6
.mob Gorlocs
>>Kill Gorlocs
.complete 11726,1
>>Collect Gorloc Spice Pouch
step
.goto Borean Tundra,61.7,35.8
.target Iggy "Tailspin" Cogtoggle
.turnin 11726 >> Turn in A Little Bit of Spice
.accept 11728 >> Accept Lupus Pupus
step
>>All around this area:
.use 35121
>>Use your Wolf Bait on Oil-stained Wolves around this area
>>Click the Wolf Droppings that spawn
.complete 11728,1
>>Collect Microfilm
step
.goto Borean Tundra,61.7,35.8
.target Iggy "Tailspin" Cogtoggle
.turnin 11728 >> Turn in Lupus Pupus
.accept 11795 >> Accept Emergency Protocol: Section 8.2, Paragraph C
step
.goto Borean Tundra,61,37.8
.target Fizzcrank Recon Pilots
>>Search their bodies for their Insignia
.complete 11795,1
>>Collect Fizzcrank Pilot's Insignia
step
.goto Borean Tundra,61.7,35.8
.target Iggy "Tailspin" Cogtoggle
.turnin 11795 >> Turn in Emergency Protocol: Section 8.2, Paragraph C
.accept 11796 >> Accept Emergency Protocol: Section 8.2, Paragraph D
step
.goto Borean Tundra,59.7,39.2
.use 35224
>>Use your Emergency Torch next to the crashed plane
.complete 11796,2
>>Scuttle a Southern Wreck
step
.goto Borean Tundra,63.3,37
.use 35224
>>Use your Emergency Torch next to the crashed plane
.complete 11796,1
>>Scuttle a Eastern Wreck
step
.goto Borean Tundra,60.9,33.7
.use 35224
>>Use your Emergency Torch next to the crashed plane
.complete 11796,3
>>Scuttle a Northwestern Wreck
step
.goto Borean Tundra,61.7,35.8
.target Iggy "Tailspin" Cogtoggle
.turnin 11796 >> Turn in Emergency Protocol: Section 8.2, Paragraph D
.accept 11873 >> Accept Give Fizzcrank the News
step
.goto Borean Tundra,63.8,46.1
.target Ataika
.turnin 11932 >> Turn in Cowards and Fools
.accept 12086 >> Accept The Son of Karkut
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
>>Click Kaskala Supplies baskets - They look like wooden baskets on the ground
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
.goto Borean Tundra,82,46.4
.target Corporal Venn
.turnin 12086 >> Turn in The Son of Karkut
.accept 11944 >> Accept Surrounded!
step
.goto Borean Tundra,82,46.4
.target Private Casey
.accept 12157 >> Accept The Lost Courier
step
.goto Borean Tundra,81.5,42.5
.mob Rocknar
>>Kill Rocknar
.complete 11650,3
>>Collect A Handful of Rocknar's Grit
step
.goto Borean Tundra,82.2,44.8
.complete 11944,1
.mob Ziggurat Defender
>>Kill Ziggurat Defender
step
.goto Borean Tundra,82,46.4
.target Corporal Venn
.turnin 11944 >> Turn in Surrounded!
.accept 12088 >> Accept Thassarian, the Death Knight
step
.goto Borean Tundra,84.8,41.7
.target Thassarian
.turnin 12088 >> Turn in Thassarian, the Death Knight
.accept 11956 >> Accept Finding the Phylactery
step
.goto Borean Tundra,82.4,46.6
.vehicle
>>Click Dusk to ride him - He is a skeletal death knight mount with hooves that glow blue
step
.goto Borean Tundra,85.4,33.3
>>Click the Frozen Phylactery - It looks like a green canister with a purple top underwater
>>Kill Phylactery Guardian that spawns
.complete 11956,1
>>Collect Tanathal's Phylactery
step
.goto Borean Tundra,84.8,41.7
.target Thassarian
.turnin 11956 >> Turn in Finding the Phylactery
.accept 11938 >> Accept Buying Some Time
step
.goto Borean Tundra,84.4,31.4
.complete 11938,1
.mob En'kilah mob
>>Kill En'kilah mob
step
.goto Borean Tundra,84.8,41.7
.target Thassarian
.turnin 11938 >> Turn in Buying Some Time
.accept 11942 >> Accept Words of Power
step
.goto Borean Tundra,89.4,28.9
>>Kill 2 bug guards and kill the 2 cocoons next to High Priest Talet-Kha
.mob High Priest Talet-Kha
>>Kill High Priest Talet-Kha
.complete 11942,3
>>Collect High Priest Talet-Kha's Scroll
step
.goto Borean Tundra,88.1,20.9
.mob High Priest Andorath
>>Kill High Priest Andorath
.complete 11942,1
>>Collect High Priest Andorath's Scroll
step
.goto Borean Tundra,83.9,20.5
>>Kill the 3 guards
.mob High Priest Naferset
>>Kill High Priest Naferset
.complete 11942,2
>>Collect High Priest Naferset's Scroll
step
.goto Borean Tundra,84.8,41.7
.target Thassarian
.turnin 11942 >> Turn in Words of Power
step
.goto Borean Tundra,57.1,18.8,1
.hs >> Hearth to Fizzcrank Airstrip
>>Hearth to Fizzcrank Airstrip
step
.goto Borean Tundra,57,18.7
.target Fizzcrank Fullthrottle
.turnin 11873 >> Turn in Give Fizzcrank the News
step
.goto Borean Tundra,57.1,20.1
.target Abner Fizzletorque
.accept 11713 >> Accept Scouting the Sinkholes
step
.goto Borean Tundra,57.4,18.7
.target Jinky Wingnut
.turnin 11788 >> Turn in Lefty Loosey, Righty Tighty
.accept 11798 >> Accept The Gearmaster
step
.goto Borean Tundra,57.6,18.7
.target Crafty Wobblesprocket
.turnin 11650 >> Turn in Just a Few More Things...
.turnin 11730 >> Turn in Master and Servant
.accept 11653 >> Accept Hah... You're Not So Big Now!
step
.goto Borean Tundra,54.2,13
.goto Borean Tundra,54.2,13,0.3
>>The path down to Hah... You're Not So Big Now! starts here
step
.goto Borean Tundra,54.2,11.2
>>Go down into the cave to 54.2,11.2
.use 34812
>>Use Crafty's Ultra-Advanced Proto-Typical Shortening Blaster on Mates of Magmothregar
>>Kill them while the device's effects are still on them
.complete 11653,1
>>Test Crafty's Blaster 5 times
step
.goto Borean Tundra,57.6,18.7
>>Go outside to 57.6,18.7
.target Crafty Wobblesprocket
.turnin 11653 >> Turn in Hah... You're Not So Big Now!
.accept 11658 >> Accept Plan B
step
.goto Borean Tundra,47.9,21.3
>>Click Dead Caravan mob corpses
>>Take their clothing
.complete 11658,1
>>Collect Warsong Outfit
step
.goto Borean Tundra,49.6,26.7
>>Click the Warsong Banner - It's a tall red flag
.complete 11658,2
>>Collect Warsong Banner
step
.goto Borean Tundra,43.5,14
.target King Mrgl-Mrgl
.turnin 11704 >> Turn in King Mrgl-Mrgl
.accept 11571 >> Accept Learning to Communicate
step
.goto Borean Tundra,42.5,15.9
>>Go underwater to 42.5,15.9
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
.use 34620
.aura 45278
>>Use King Mrgl-Mrgl's Spare Suit
step
.goto Borean Tundra,37.6,27.4
>>Follow the path up and to the back of the cave to 37.6,27.4
.mob Claximus
>>Kill Claximus
.complete 11566,1
>>Collect Claw of Claximus
step
.use 34620
.complete 11569,1
.aura 45278
>>Use King Mrgl-Mrgl's Spare Suit
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
.goto Borean Tundra,57.6,18.7
.target Crafty Wobblesprocket
.turnin 11658 >> Turn in Plan B
.accept 11670 >> Accept It Was The Orcs, Honest!
step
.goto Borean Tundra,54,13.5
.goto Borean Tundra,54,13.5,0.5
>>The path down to It Was The Orcs, Honest! starts here
step
.goto Borean Tundra,54.9,12
>>Go down into the cave to 54.9,12
.use 34871
>>Open Crafty's Sack and get the Warsong Banner and Warsong Orc Disguise
.use 34870
>>Use your Warsong Orc Disguise
.mob Magmothregar
>>Kill Magmothregar
.use 34869
>>Use your Warsong Banner on Magmothregar's corpse
.complete 11670,1
>>Plant the Warson Banner in Magmothregar
step
.goto Borean Tundra,57.6,18.7
>>Go outside to 57.6,18.7
.target Crafty Wobblesprocket
.turnin 11670 >> Turn in It Was The Orcs, Honest!
step
.goto Borean Tundra,64.5,23.4
>>Go on top of the pump station to 64.5,23.4
>>Click The Gearmaster's Manual - It looks like a big closed book on the table in a small room at the very top of the pump station
.mob Gearmaster Mechazod
>>Kill Gearmaster Mechazod
.complete 11798,2
>>Collect Mechazod's Head
step
.goto Borean Tundra,66.4,32.9
.use 34920
>>Use your Map of the Geyser Fields next to the huge hole in the ground
.complete 11713,3
>>Mark the Location of the Northwest Sinkhole
step
.goto Borean Tundra,69.9,32.8
.use 34920
>>Use your Map of the Geyser Fields next to the huge hole in the ground
.complete 11713,2
>>Mark the Location of the Northeast Sinkhole
step
.goto Borean Tundra,70.6,36.9
.use 34920
>>Use your Map of the Geyser Fields next to the huge hole in the ground
.complete 11713,1
>>Mark the Location of the South Sinkhole
step
.goto Borean Tundra,73.4,18.8
.target Bixie Wrenchshanker
.turnin 11692 >> Turn in Check in With Bixie
.accept 11693 >> Accept Oh Great... Plagued Magnataur!
step
.goto Borean Tundra,73.3,19.6
.complete 11693,1
.mob Plagued Magnataur
>>Kill Plagued Magnataur
step
.goto Borean Tundra,73.4,18.8
.target Bixie Wrenchshanker
.turnin 11693 >> Turn in Oh Great... Plagued Magnataur!
.accept 11694 >> Accept There's Something Going On In Those Caves
step
.goto Borean Tundra,74.7,14.1
.use 34915
>>Use Bixie's Inhibiting Powder next to the Den of Dying Plague Cauldron
.complete 11694,1
>>Neutralize the Plague Cauldron
step
.goto Borean Tundra,73.4,18.8
.target Bixie Wrenchshanker
.turnin 11694 >> Turn in There's Something Going On In Those Caves
.accept 11697 >> Accept Rats, Tinky Went into the Necropolis!
.accept 11698 >> Accept Might As Well Wipe Out the Scourge
step
.goto Borean Tundra,68.2,17
.mob Undead mobs
>>Kill Undead mobs
.complete 11698,1
>>Destroy 20 Talramas Scourge
step
.goto Borean Tundra,69.9,14.7
>>Go inside the undead building to 69.9,14.7
.target Tinky Wickwhistle
.turnin 11697 >> Turn in Rats, Tinky Went into the Necropolis!
.accept 11699 >> Accept I'm Stuck in this Damned Cage... But Not For Long!
step
.goto Borean Tundra,68.6,17.5
>>Go outside to 68.6,17.5
.mob Festering Ghouls
>>Kill Festering Ghouls
.complete 11699,1
>>Collect Engine-Core Crystal
step
.goto Borean Tundra,69.7,13.9
>>Go around to the back of the building and up to 69.7,13.9
.mob Lich-Lord Chillwinter
>>Kill Lich-Lord Chillwinter
.complete 11699,3
>>Collect Piloting Scourgestone
step
.goto Borean Tundra,69.7,13
>>Jump down into the huge hole to 69.7,13
.mob Doctor Razorgrin
>>Kill Doctor Razorgrin
.complete 11699,2
>>Collect Magical Gyroscope
step
.goto Borean Tundra,69.9,14.7
>>Go inside the undead building to 69.9,14.7
.target Tinky Wickwhistle
.turnin 11699 >> Turn in I'm Stuck in this Damned Cage... But Not For Long!
.accept 11700 >> Accept Let Bixie Know
step
.goto Borean Tundra,73.4,18.8
>>Go outside to 73.4,18.8
.target Bixie Wrenchshanker
.turnin 11698 >> Turn in Might As Well Wipe Out the Scourge
.turnin 11700 >> Turn in Let Bixie Know
.accept 11701 >> Accept Back to the Airstrip
step
.goto Borean Tundra,57.1,20.1
.target Abner Fizzletorque
.turnin 11713 >> Turn in Scouting the Sinkholes
.accept 11715 >> Accept Fueling the Project
step
.goto Borean Tundra,57,18.7
.target Fizzcrank Fullthrottle
.turnin 11701 >> Turn in Back to the Airstrip
.turnin 11798 >> Turn in The Gearmaster
step
.goto Borean Tundra,57.6,23.7
.use 34975
>>Use your Portable Oil Collector next to the bubbling oil spots in the water
.complete 11715,1
>>Collect 8 Barrels of Oil
step
.goto Borean Tundra,57.1,20.1
.target Abner Fizzletorque
.turnin 11715 >> Turn in Fueling the Project
.accept 11718 >> Accept A Bot in Mammoth's Clothing
step
.goto Borean Tundra,56.9,29.1
.mob mammoths
>>Kill mammoths
.complete 11718,1
>>Collect Thick Mammoth Hide
step
.goto Borean Tundra,57.1,20.1
.target Abner Fizzletorque
.turnin 11718 >> Turn in A Bot in Mammoth's Clothing
.accept 11723 >> Accept Deploy the Shake-n-Quake!
step
.goto Borean Tundra,70.6,36.9
>>Stand next to the sinkhole - It's a huge hole in the ground
.use 34981
>>Use The Shake-n-Quake 5000 Control Unit in your bags
.complete 11723,1
.mob Lord Kryxix
>>Kill Lord Kryxix
step
.goto Borean Tundra,57.1,18.8,1
.hs >> Hearth to Fizzcrank Airstrip
>>Hearth to Fizzcrank Airstrip
step
.goto Borean Tundra,57.1,20.1
.target Abner Fizzletorque
.turnin 11723 >> Turn in Deploy the Shake-n-Quake!
step
.fly Valiance Keep, Borean Tundra >> Fly to Valiance Keep
>>Fly to Valiance Keep
step
.zone Stormwind City
>>Ride the boat to Stormwind City
step
.fly Menethil Harbor, Wetlands >> Fly to Menethil Harbor
>>Fly to Menethil Harbor
step
.goto Wetlands,4.6,57.2
.zone Howling Fjord
>>Ride the boat to Howling Fjord
step
.goto Howling Fjord,61.1,62.7
.target Macalroy
.accept 11228 >> Accept Hell Has Frozen Over...
step
.goto Howling Fjord,60.5,61.1
.target Vice Admiral Keller
.turnin 11228 >> Turn in Hell Has Frozen Over...
.accept 11243 >> Accept If Valgarde Falls...
step
.goto Howling Fjord,59.8,63.2
.target Pricilla Winterwind
.fp Valgarde Port, Howling Fjord >> Get the Valgarde flight path
step
.home Valgarde >> Set your Hearthstone to Valgarde
step
.goto Howling Fjord,58.9,59.6
.mob Dragonflayer Worgs
>>Kill Dragonflayer Worgs
.mob Dragonflayer Invaders
>>Kill Dragonflayer Invaders
.complete 11243,1
.mob Dragonflayer Invader
>>Kill Dragonflayer Invader
step
.goto Howling Fjord,60.5,61.1
.target Vice Admiral Keller
.turnin 11243 >> Turn in If Valgarde Falls...
.accept 11244 >> Accept Rescuing the Rescuers
step
.goto Howling Fjord,58.1,57
>>Click the Ceremonial Dragonflayer Harpoons - They look like poles sticking out of the ground, next to dead dwarf bodies around this area
.complete 11244,1
>>Rescue 8 Valgarde Scouts
step
.goto Howling Fjord,60.5,61.1
.target Vice Admiral Keller
.turnin 11244 >> Turn in Rescuing the Rescuers
.accept 11255 >> Accept Prisoners of Wyrmskull
step
.goto Howling Fjord,56,55.8
.target Scout Valory
.accept 11251 >> Accept Fresh Legs
step
.goto Howling Fjord,59.6,48.9
.target Defender Mordun
.turnin 11251 >> Turn in Fresh Legs
step
.goto Howling Fjord,60.2,61
.target Beltrand McSorf
.accept 11273 >> Accept The Human League
step
.goto Howling Fjord,59.8,61.5
.target Thoralius the Wise
.accept 11333 >> Accept Into the World of Spirits
step
.goto Howling Fjord,60.1,62.4
.target Guard Captain Zorek
.accept 11420 >> Accept The Path to Payback
step
.goto Howling Fjord,62.4,59.3
>>Go underwater to 62.4,59.3
>>Click the Reagent Pouch - It looks like a bag of green plants, sitting on the deck of this ship
.complete 11333,1
>>Collect Reagent Pouch
step
.goto Howling Fjord,63,60
.target Harold Lagras
.accept 11443 >> Accept Daggercap Divin'
step
.goto Howling Fjord,62.2,59.7
.use 34082
>>Equip your Diving Helm
>>Click the Valgarde Supply Crates - They look like crates all around this area underwater
.complete 11443,1
>>Collect Valgarde Supply Crate
step
.goto Howling Fjord,63,60
.target Harold Lagras
.turnin 11443 >> Turn in Daggercap Divin'
step
.goto Howling Fjord,59.2,54.6
>>Make sure to equip your real helmet again, so you don't accidentally sell it
.target Pulroy the Archaeologist
.turnin 11273 >> Turn in The Human League
.accept 11274 >> Accept Zedd's Probably Dead
step
.goto Howling Fjord,58.8,54.1
.mob Dragonflayer Tribesmen
>>Kill Dragonflayer Tribesmen
.mob Dragonflayer Death Weavers
>>Kill Dragonflayer Death Weavers
.mob Dragonflayer Thanes
>>Kill Dragonflayer Thanes
.collect 33308,3,0 >> Collect 3 Dragonflayer Cage Key
>>Click the Dragonflayer Cages
.complete 11255,1
>>Rescue 3 Captured Valgarde Prisoners
step
.goto Howling Fjord,56.6,52.4
.target Zedd
.turnin 11274 >> Turn in Zedd's Probably Dead
.accept 11276 >> Accept And Then There Were Two...
step
.goto Howling Fjord,56.6,49.6
.goto Howling Fjord,56.6,49.6,0.5
>>The entrance to the Utgarde Catacombs starts here
step
.goto Howling Fjord,56.9,53.8
>>Go inside the cave to 56.9,53.8
.target Glorenfeld
.turnin 11276 >> Turn in And Then There Were Two...
.accept 11277 >> Accept The Depths of Depravity
step
.goto Howling Fjord,57.3,54.5
>>Click the Wyrmskull Tablets - They look like broken stone tablets laying on the ground inside this cave
.complete 11277,1
>>Collect Wyrmskull Tablet
step
.goto Howling Fjord,59.3,55.4
>>Click the Harpoon Operation Manual - It's a book laying at the foot of this small altar
.complete 11420,1
>>Collect Harpoon Operation Manual
step
.goto Howling Fjord,59.3,55.4
.target Ares the Oathbound
.accept 11288 >> Accept The Shining Light
step
.goto Howling Fjord,56.6,53.4
>>Go downstairs into the ghoul pit to 56.6,53.4
>>The ghouls will die from your aura, so just run through them
>>Click the Sacred Artifact - It's downstairs in the ghoul pit, a sword stuck in the ground in a pillar of light
.complete 11288,1
>>Collect Sacred Artifact
step
.goto Howling Fjord,59.3,55.4
>>Go upstairs to 59.3,55.4
.target Ares the Oathbound
.turnin 11288 >> Turn in The Shining Light
.accept 11289 >> Accept Guided by Honor
step
.goto Howling Fjord,56.9,53.8
.target Glorenfeld
.turnin 11277 >> Turn in The Depths of Depravity
.accept 11299 >> Accept The Ring of Judgement
step
.goto Howling Fjord,55.7,57.4
>>Go downstairs to 55.7,57.4
.target Daegarn
.turnin 11299 >> Turn in The Ring of Judgement
.accept 11300 >> Accept Stunning Defeat at the Ring
step
.goto Howling Fjord,55,57.5
>>Kill gladiators, the named mobs
>>Kill Oluf the Violent when he runs out
>>Click the Ancient Cipher that falls to the ground
.complete 11300,1
>>Collect Ancient Cipher
step
.goto Howling Fjord,56.9,53.8
>>Go upstairs to 56.9,53.8
.target Glorenfeld
.turnin 11300 >> Turn in Stunning Defeat at the Ring
.accept 11278 >> Accept Return to Valgarde
step
.goto Howling Fjord,58.4,62.5,0.5
.hs >> Hearth to Valgarde
>>Hearth to Valgarde
step
.goto Howling Fjord,59.8,62.4
.target Lord Irulon Trueblade
.turnin 11289 >> Turn in Guided by Honor
step
.goto Howling Fjord,60.1,62.4
.target Guard Captain Zorek
.turnin 11420 >> Turn in The Path to Payback
.accept 11426 >> Accept Locating the Mechanism
step
.goto Howling Fjord,60.5,61.1
.target Vice Admiral Keller
.turnin 11255 >> Turn in Prisoners of Wyrmskull
.accept 11290 >> Accept Dragonflayer Battle Plans
step
.goto Howling Fjord,60.2,61
.target Beltrand McSorf
.turnin 11278 >> Turn in Return to Valgarde
.accept 11448 >> Accept The Explorers' League Outpost
step
.goto Howling Fjord,59.8,61.5
.target Thoralius the Wise
.turnin 11333 >> Turn in Into the World of Spirits
.accept 11343 >> Accept The Echo of Ymiron
step
.xp 72
]]);
RXPGuides.RegisterGuide([[
#wotlk
#ac335
#version 1
#group RestedXP WotLK Guide (A)
#subgroup Northrend 70-80
<< Alliance
#name 72-74 Northrend
#next 74-76 Northrend
step
.goto Howling Fjord,55.7,52.6
>>Click the Dragonflayer Battle Plans - It's a big scroll hanging on the wall inside this small cave
.complete 11290,1
>>Collect Dragonflayer Battle Plans
step
.goto Howling Fjord,60.2,51.7
>>Kill Dragonflayer Harpooners on this dock
.complete 11426,1
>>Collect Harpoon Control Mechanism
step
.goto Howling Fjord,60.1,50.8
.use 33637
>>Use your Incense Burner in your bags inside the doorway of this house
>>Watch the cutscene
.complete 11343,1
>>Uncover the Secrets of the Wyrmskull
step
.goto Howling Fjord,59.8,61.5
.target Thoralius the Wise
.turnin 11343 >> Turn in The Echo of Ymiron
.accept 11344 >> Accept Anguish of Nifflevar
step
.goto Howling Fjord,60.5,61.1
.target Vice Admiral Keller
.turnin 11290 >> Turn in Dragonflayer Battle Plans
.accept 11291 >> Accept To Westguard Keep!
step
.goto Howling Fjord,60.1,62.4
.target Guard Captain Zorek
.turnin 11426 >> Turn in Locating the Mechanism
.accept 11427 >> Accept Meet Lieutenant Icehammer...
step
.goto Howling Fjord,60.8,61.5
.target McGoyver
.goto Howling Fjord,74.7,65.3,1
>>Tell him to take you to the Explorers' League Outpost
step
.goto Howling Fjord,75,65.4
.target Stanwad
.turnin 11448 >> Turn in The Explorers' League Outpost
.accept 11474 >> Accept Problems on the High Bluff
step
.goto Howling Fjord,75.1,65.5
.target Walt
.turnin 11474 >> Turn in Problems on the High Bluff
.accept 11475 >> Accept Tools to Get the Job Done
step
.goto Howling Fjord,75.3,65
.target Hidalgo the Master Falconer
.accept 11460 >> Accept Trust is Earned
step
.goto Howling Fjord,75.5,66.8
>>Click the Loose Rocks - They are grey stones on the ground around this area
.collect 34102,1,11460 >> Collect 1 Fjord Grub
step
.goto Howling Fjord,75.3,65
.target a Rock Falcon
.complete 11460,1
>>Feed the grub to the rock falcon
step
.goto Howling Fjord,75.3,65
.target Hidalgo the Master Falconer
.turnin 11460 >> Turn in Trust is Earned
.accept 11465 >> Accept The Ransacked Caravan
step
.goto Howling Fjord,75.5,66.8
>>Click the Loose Rocks - They are grey stones on the ground around this area
.collect 34102,5,11465 >> Collect 5 Fjord Grub
step
.goto Howling Fjord,69.6,64.8
.collect 34102,5,0
>>Make sure you have 5 Fjord Grubs
.use 34111
>>Use your Trained Rock Falcon in your bags on Fjord Turkeys
.complete 11465,1
>>Collect Fjord Turkey
step
.goto Howling Fjord,75.3,65
.target Hidalgo the Master Falconer
.turnin 11465 >> Turn in The Ransacked Caravan
.accept 11468 >> Accept Falcon Versus Hawk
step
.goto Howling Fjord,75.5,66.8
>>Click the Loose Rocks - They are grey stones on the ground around this area
.collect 34102,10,11468 >> Collect 10 Fjord Grub
step
.goto Howling Fjord,72.2,64.1
.collect 34102,10,0
>>Make sure you have 10 Fjord Grubs
.use 34121
>>Use your Trained Rock Falcon in your bags on Fjord Hawks
.complete 11468,1
>>Collect Fjord Hawk
step
.goto Howling Fjord,75.3,65
.target Hidalgo the Master Falconer
.turnin 11468 >> Turn in Falcon Versus Hawk
.accept 11470 >> Accept There Exists No Honor Among Birds
step
.goto Howling Fjord,76.7,67.7
.use 34124
>>Use your Trained Rock Falcon in your bags next to the Vrykul Hawk Roost
.macro Scavenge,134400 >>/cast Scavenge
>>Use the Scavenge ability to steal the eggs in the nests on the side of the cliff in front of you
.complete 11470,1
>>Collect Fjord Hawk Egg
step
.goto Howling Fjord,75.3,65
.target Hidalgo the Master Falconer
.turnin 11470 >> Turn in There Exists No Honor Among Birds
step
.goto Howling Fjord,64.4,47
.target Lieutenant Icehammer
.turnin 11427 >> Turn in Meet Lieutenant Icehammer...
.accept 11429 >> Accept Drop It then Rock It!
step
.goto Howling Fjord,65,39.9
.use 34051
>>Use your Alliance Banner in your bags
>>Fight the defenders that come
.complete 11429,2
>>Place the Alliance Banner
.complete 11429,1
>>Defend the Alliance Banner
step
.goto Howling Fjord,64.4,47
.target Lieutenant Icehammer
.turnin 11429 >> Turn in Drop It then Rock It!
.accept 11430 >> Accept Harpoon Master Yavus
step
.goto Howling Fjord,65.1,56.6
.complete 11430,1
.mob Harpoon Master Yavus
>>Kill Harpoon Master Yavus
step
.goto Howling Fjord,69,54.7
.use 33774
>>Use your Incense Burner in your bags
>>Watch the cutscene
.complete 11344,1
>>Uncover the Secrets of Nifflevar
step
.goto Howling Fjord,64.4,47
.target Lieutenant Icehammer
.turnin 11430 >> Turn in Harpoon Master Yavus
.accept 11421 >> Accept It Goes to 11...
step
.goto Howling Fjord,64.8,52.7
.use 34032
>>Use your Harpoon Control Mechanism next to the big metal harpoon guns
>>Use the abilities on your hotbar to shoot the buildings across the water, on the water's edge, and shoot Dragonflayer Defenders
.complete 11421,2
>>Destroy the Dragonflayer Longhouse
.complete 11421,3
>>Destroy the Dragonflayer Dockhouse
.complete 11421,4
>>Destroy the Dragonflayer Storage Facility
.complete 11421,1
.mob Dragonflayer Defender
>>Kill Dragonflayer Defender
.exitvehicle
>>Click the red arrow on your action bar to get off the harpoon gun
step
.goto Howling Fjord,64.4,47
.target Lieutenant Icehammer
.turnin 11421 >> Turn in It Goes to 11...
.accept 11436 >> Accept Let's Go Surfing Now
step
.goto Howling Fjord,78.8,48.9
.target Donny
.accept 11477 >> Accept Out of My Element?
step
.goto Howling Fjord,79,47.6
.complete 11477,2
.mob Iron Rune Laborer
>>Kill Iron Rune Laborer
.complete 11477,3
.mob Iron Rune Sage
>>Kill Iron Rune Sage
step
.goto Howling Fjord,79,47.6
>>Click the Building Tools - They look like a small metal bucket of tools, sitting next to a wooden wheelbarrow
.complete 11475,1
>>Collect Building Tools
step
.goto Howling Fjord,78.4,45.9
.complete 11477,1
.mob Iron Rune Destroyer
>>Kill Iron Rune Destroyer
step
.goto Howling Fjord,78.8,48.9
.target Donny
.turnin 11477 >> Turn in Out of My Element?
step
.goto Howling Fjord,75.1,65.5
.target Walt
.turnin 11475 >> Turn in Tools to Get the Job Done
.accept 11483 >> Accept We Can Rebuild It
.accept 11484 >> Accept We Have the Technology
step
.goto Howling Fjord,75.4,63.3
.mob Shoveltusks
>>Kill Shoveltusks
.complete 11484,1
>>Collect Pristine Shoveltusk Hide
step
.goto Howling Fjord,64.8,40.9
>>Click the Industrial Strength Rope - It's a rope wound around a small wooden post
.complete 11483,2
>>Collect Industrial Strength Rope
step
.goto Howling Fjord,67.6,52.2
>>Click the Large Barrel - It looks like a barrel sitting next to this building
.complete 11483,1
>>Collect Large Barrel
step
.goto Howling Fjord,67.9,52.7
.mob Dragonflayer mobs
>>Kill Dragonflayer mobs
.complete 11484,2
>>Collect Steel Ribbing
step
.goto Howling Fjord,65.3,57.2
>>Click the Large Harpoon Lever - It looks like a metal lever on this wooden balcony
.complete 11436,1
>>Go Harpoon Surfing
step
.goto Howling Fjord,60.1,62.4
.target Guard Captain Zorek
.turnin 11436 >> Turn in Let's Go Surfing Now
step
.goto Howling Fjord,59.8,61.5
.target Thoralius the Wise
.turnin 11344 >> Turn in Anguish of Nifflevar
step
.goto Howling Fjord,60.8,61.5
.target McGoyver
>>Ask him for some dark iron ingots
.complete 11483,3
>>Collect Dark Iron Ingots
step
.goto Howling Fjord,60.8,61.5
.target McGoyver
.goto Howling Fjord,74.7,65.3,1
>>Tell him to take you to the Explorers' League Outpost
step
.goto Howling Fjord,75.1,65.5
.target Walt
.turnin 11483 >> Turn in We Can Rebuild It
.turnin 11484 >> Turn in We Have the Technology
.accept 11485 >> Accept Iron Rune Constructs and You: Rocket Jumping
step
.goto Howling Fjord,75.1,65.5
>>Click the Work Bench tablet next to the iron golem next to you
>>Get on the work bench and let Walt put you in the golem suit
.macro Rocket Jump,134400 >>/cast Rocket Jump
>>Use the Rocket Jump ability on your hotbar
.complete 11485,1
>>Master Rocket Jump
step
.exitvehicle
>>Click the red arrow on your hotbar to leave the golem suit
step
.goto Howling Fjord,75.1,65.5
.target Walt
.turnin 11485 >> Turn in Iron Rune Constructs and You: Rocket Jumping
.accept 11489 >> Accept Iron Rune Constructs and You: Collecting Data
step
>>Click the Work Bench tablet next to the iron golem next to you
.vehicle
>>Get on the work bench and let Walt put you in the golem suit
step
.goto Howling Fjord,74.8,65.7
.macro Collect Data,134400 >>/cast Collect Data
>>Use your Collect Data ability on your hotbar next to the blue crystal
>>Collect Test Data
step
.exitvehicle
>>Click the red arrow on your hotbar to leave the golem suit
step
.goto Howling Fjord,75.1,65.5
.target Walt
.turnin 11489 >> Turn in Iron Rune Constructs and You: Collecting Data
.accept 11491 >> Accept Iron Rune Constructs and You: The Bluff
step
>>Click the Work Bench tablet next to the iron golem next to you
.vehicle
>>Get on the work bench and let Walt put you in the golem suit
step
.goto Howling Fjord,74.8,65.3
>>Walk on Lebronski's Rug - It's a long rug on the ground
.macro Bluff,134400 >>/cast Bluff
>>Use your Bluff ability on your hotbar on Lebronski when he gets mad that you walked on his rug
.complete 11491,1
>>Bluff Lebronski
step
.exitvehicle
>>Click the red arrow on your hotbar to leave the golem suit
step
.goto Howling Fjord,75.1,65.5
.target Walt
.turnin 11491 >> Turn in Iron Rune Constructs and You: The Bluff
.accept 11494 >> Accept Lightning Infused Relics
.accept 11495 >> Accept The Delicate Sound of Thunder
step
>>Click the Work Bench tablet next to the iron golem next to you
.vehicle
>>Get on the work bench and let Walt put you in the golem suit
step
.goto Howling Fjord,74.3,70.8
>>Use the Rocket Jump ability on your hotbar on the middle rune on the wooden platform
.complete 11495,2
>>Rocket Jump to the Lower Level
>>Start collecting Lightning Infused Relics as you head toward the cave - They look like blue crystals on the ground around this area
step
.goto Howling Fjord,71.6,69.4
>>Investigate the Thundering Cave - This quest can be a little buggy. Run around inside the cave until the dialogue starts
>>Keep collecting Lightning Infused Relics around and inside the cave as you go
step
.goto Howling Fjord,72.7,67.3
.goto Howling Fjord,72.7,67.3,0.5
>>Follow the path down to finish collecting Lightning Infused Relics
step
.goto Howling Fjord,71.8,69.2
.macro Collect Data,134400 >>/cast Collect Data
>>Use your Collect Data ability next to the blue crystals
.macro Bluff,134400 >>/cast Bluff
>>Use your Bluff ability to get rid of suspicious dwarves
.complete 11494,1
>>Collect 15 Iron Rune Data
step
.exitvehicle
>>Get to a safe place, then click the red arrow on your hotbar to leave the golem suit
step
.goto Howling Fjord,75.1,65.5
.target Walt
.turnin 11494 >> Turn in Lightning Infused Relics
.turnin 11495 >> Turn in The Delicate Sound of Thunder
.accept 11501 >> Accept News From the East
step
.goto Howling Fjord,75.1,65.5
>>Tell Walt "I'm ready to go."
.vehicle
>>Begin Flying to Westguard Keep
step
.goto Howling Fjord,30.8,42.8
.exitvehicle
>>Fly to Westguard Keep
step
.goto Howling Fjord,40.3,60.3
.target Orfus of Kamagua
.accept 11504 >> Accept The Dead Rise!
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
.goto Howling Fjord,40.3,60.3
.target Orfus of Kamagua
.turnin 11504 >> Turn in The Dead Rise!
.accept 11507 >> Accept Elder Atuik and Kamagua
step
.goto Howling Fjord,25.0,57.0
>>Go across The Ancient Lift to 25.0,57.0
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
.mob Frostwing Chimaera
>>Kill Frostwing Chimaera
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
>>Tell him you want to collect a debt he owes
>>Fight him until he surrenders
.target "Silvermoon" Harry
>>Tell him to pay up
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
>>Go upstairs to the ship deck
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
.goto Howling Fjord,33.5,75.3
>>Go down the hill to 33.5,75.3
.goto Howling Fjord,32.3,78.7
>>Go into the cave to 32.3,78.7
>>Hug the wall to the left inside the cave to avoid fighting "Mad" Jonah Sterling
>>Follow the path around past the big white sleeping bear, he won't attack you if he's asleep
>>Click The Frozen Heart of Isuldof - Inside the cave, it looks like a big blue jewel on the ground
.complete 11512,1
>>Collect The Frozen Heart of Isuldof
step
.goto Howling Fjord,33.2,63.9
>>Leave the cave and go to 33.2,63.9
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
>>Click the mound of dirt - It looks like a huge pile of dirt
>>Kill Black Conrad's Ghost and his friends that spawn
.complete 11467,1
>>Collect Black Conrad's Treasure
step
.goto Howling Fjord,25,57
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
>>Keep doing this
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
.goto Howling Fjord,80.9,75.3,1
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
.goto Howling Fjord,36.1,81.7,1
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
.goto Howling Fjord,59.8,79.4
.use 34624
>>Use your Bundle of Vrykul Artifacts while standing near the skeleton
.complete 11568,3
>>Return the Frozen Heart of Isuldof
step
.goto Howling Fjord,62,80
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
.goto Howling Fjord,37.4,51.9
>>Go across the Ancient Lift to 37.4,51.9
.target Ember Clutch Ancient
.accept 11182 >> Accept Root Causes
step
.goto Howling Fjord,40.6,51.5
.complete 11182,1
.mob Dragonflayer Handler
>>Kill Dragonflayer Handler
step
.goto Howling Fjord,41.5,52.3
>>Go inside the small house to 41.5,52.3
.complete 11182,2
.mob Skeld Drakeson
>>Kill Skeld Drakeson
step
.goto Howling Fjord,37.4,51.9
.target Ember Clutch Ancient
.turnin 11182 >> Turn in Root Causes
step
.goto Howling Fjord,34,43.8
.target Cannoneer Ely
.accept 11190 >> Accept One Size Does Not Fit All
step
.goto Howling Fjord,31.3,44
.target Greer Orehammer
.fp Westguard Keep, Howling Fjord >> Get the Westguard Keep flight path
step
.home Westguard Keep >> Set your Hearthstone to Westguard Keep
step
.goto Howling Fjord,31.2,40.8
.target Chef Kettleblack
.accept 11155 >> Accept Shoveltusk Soup Again?
step
.goto Howling Fjord,29,41.9
.target Bombardier Petrov
.accept 11153 >> Accept Break the Blockade
step
.goto Howling Fjord,28.1,42.1
>>Wait for the zeppelin to come back, if it is there already, then get on it
.use 33098
>>Use Petrov's Cluster Bombs in your bags to throw them off the zeppelin at the pirates as you ride
.complete 11153,1
.mob Blockade Pirate
>>Kill Blockade Pirate
.complete 11153,2
>>Destroy 10 Blockade Cannons
step
.goto Howling Fjord,29,41.9
.target Bombardier Petrov
.turnin 11153 >> Turn in Break the Blockade
step
.goto Howling Fjord,28.8,44.1
>>Go inside the fort to 28.8,44.1
.target Captain Adams
.turnin 11291 >> Turn in To Westguard Keep!
.turnin 11501 >> Turn in News From the East
.accept 11157 >> Accept The Clutches of Evil
step
.goto Howling Fjord,35.6,40.6
>>Click the Westguard Cannonballs - They look like grey round rocks on the ground around this area
.complete 11190,1
>>Collect Westguard Cannonball
.mob Shoveltusks
>>Kill Shoveltusks
.complete 11155,1
>>Collect Shoveltusk Meat
step
.goto Howling Fjord,38.3,47.3
.complete 11157,1
>>Destroy 15 Proto-Drake Eggs
.complete 11157,2
.mob Proto-Whelp
>>Kill Proto-Whelp
step
.goto Howling Fjord,34,43.8
.target Cannoneer Ely
.turnin 11190 >> Turn in One Size Does Not Fit All
step
.goto Howling Fjord,31.2,40.8
.target Chef Kettleblack
.turnin 11155 >> Turn in Shoveltusk Soup Again?
step
.goto Howling Fjord,28.8,44.1
>>Go inside the fort to 28.8,44.1
.target Captain Adams
.turnin 11157 >> Turn in The Clutches of Evil
.accept 11187 >> Accept Mage-Lieutenant Malister
step
.goto Howling Fjord,28.9,44.2
.target Mage-Lieutenant Malister
.turnin 11187 >> Turn in Mage-Lieutenant Malister
.accept 11188 >> Accept Two Wrongs...
step
.goto Howling Fjord,36.1,47.6
.use 33119
>>Use Malister's Frost Wand on Proto-Drakes
.complete 11188,1
.mob Proto-Drake
>>Kill Proto-Drake
step
.goto Howling Fjord,28.9,44.2
>>Go inside the fort to 28.9,44.2
.target Mage-Lieutenant Malister
.turnin 11188 >> Turn in Two Wrongs...
step
.goto Howling Fjord,28.8,44.1
.target Captain Adams
.accept 11199 >> Accept Report to Scout Knowles
step
.goto Howling Fjord,29.1,41.8
.target Sapper Steelring
.accept 11218 >> Accept Danger! Explosives!
step
.goto Howling Fjord,31.6,41.5
.target Explorer Abigail
.accept 11224 >> Accept Send Them Packing
step
.goto Howling Fjord,33.8,34.0
.goto Howling Fjord,33.8,34.0,0.5
>>The path down into the canyon starts here
step
.goto Howling Fjord,33.5,36.1
.use 33190
>>Use Steelring's Foolproof Dynamite on the mining nodes
>>Click the Whisper Gulch Ore Fragments that spawn
.complete 11218,1
>>Collect Whisper Gulch Ore Fragment
>>Click the Whisper Gulch Ore Gems that spawn
.complete 11218,2
>>Collect Whisper Gulch Gem
>>Use the emote /raise on the Abandoned Pack Mules - They look like mules with a bunch of supplies tied to them around this area
.complete 11224,1
>>Send 10 Abandoned Pack Mules Packing
step
.goto Howling Fjord,31.6,41.5
>>Go out of the canyon to 31.6,41.5
.target Explorer Abigail
.turnin 11224 >> Turn in Send Them Packing
step
.goto Howling Fjord,29.1,41.8
.target Sapper Steelring
.turnin 11218 >> Turn in Danger! Explosives!
.accept 11240 >> Accept Leader of the Deranged
step
.goto Howling Fjord,33.8,34.0
.goto Howling Fjord,33.8,34.0,0.5
>>The path down into the canyon starts here
step
.goto Howling Fjord,31.6,34.8
.complete 11240,1
.mob Squeeg Idolhunter
>>Kill Squeeg Idolhunter
step
.goto Howling Fjord,29,41.9
>>Go out of the canyon to 29,41.9
.target Sapper Steelring
.turnin 11240 >> Turn in Leader of the Deranged
step
.goto Howling Fjord,31.7,42
.target Old Man Stonemantle
.accept 11175 >> Accept My Daughter
step
.goto Howling Fjord,44.5,57.6
.target Scout Knowles
.turnin 11199 >> Turn in Report to Scout Knowles
.accept 11202 >> Accept Mission: Eternal Flame
step
.goto Howling Fjord,48.4,55.8
.use 33164
>>Use your Ever-burning Torches next to the big shaking cart
.complete 11202,1
>>Destroy the Southwest Plague Tank
step
.goto Howling Fjord,48.2,52.9
.use 33164
>>Use your Ever-burning Torches next to the big shaking cart
.complete 11202,2
>>Destroy the Northwest Plague Tank
step
.goto Howling Fjord,51.2,50.2
.use 33164
>>Use your Ever-burning Torches next to the big shaking cart
.complete 11202,3
>>Destroy the Northeast Plague Tank
step
.goto Howling Fjord,51.5,57.7
.use 33164
>>Use your Ever-burning Torches next to the big shaking cart
.complete 11202,4
>>Destroy the Southeast Plague Tank
step
.goto Howling Fjord,44.5,57.6
.target Scout Knowles
.turnin 11202 >> Turn in Mission: Eternal Flame
.accept 11327 >> Accept Mission: Package Retrieval
step
.goto Howling Fjord,47.8,58.2
.goto Howling Fjord,47.8,58.2,0.5
>>The path down to Mission: Package Retrieval starts here
step
.goto Howling Fjord,50.8,53.9
>>Click the Apothecary's Package - It's a small tan package on the ground
.complete 11327,1
>>Collect Apothecary's Package
step
.goto Howling Fjord,44.5,57.6
.target Scout Knowles
.turnin 11327 >> Turn in Mission: Package Retrieval
.accept 11328 >> Accept Mission: Forsaken Intel
step
.goto Howling Fjord,30.8,41.6
.target Peppy Wrongnozzle
.turnin 11328 >> Turn in Mission: Forsaken Intel
.accept 11330 >> Accept Absholutely... Thish Will Work!
step
.goto Howling Fjord,29.3,44.1
.goto Howling Fjord,29.3,44.1,0.5
>>The path down to Absholutely... Thish Will Work! starts here
step
.goto Howling Fjord,29.5,43.4
.use 33627
>>Use Peppy's Special Mix on the Dragonflayer Vrykul Prisoner
.complete 11330,1
>>Administer Peppy's Mix To The Vrykul Prisoner
step
.goto Howling Fjord,30.8,41.6
.target Peppy Wrongnozzle
.turnin 11330 >> Turn in Absholutely... Thish Will Work!
.accept 11331 >> Accept You Tell Him ...Hic!
step
.goto Howling Fjord,28.8,44.1
>>Go into the fort to 28.8,44.1
.target Captain Adams
.turnin 11331 >> Turn in You Tell Him ...Hic!
.accept 11332 >> Accept Mission: Plague This!
step
.goto Howling Fjord,31.3,44
.target Greer Orehammer
>>Tell him you need a gryphon to ride
.use 33634
>>Use Orehammer's Precision Bombs in your bags on the big green carts as you fly over New Agamand
.complete 11332,1
>>Hit 5 Plague Tanks
step
.goto Howling Fjord,28.8,44.1
>>Go into the fort to 28.8,44.1
.target Captain Adams
.turnin 11332 >> Turn in Mission: Plague This!
.accept 11248 >> Accept Operation: Skornful Wrath
step
.goto Howling Fjord,30.2,28.7
.target Overseer Irena Stonemantle
.turnin 11175 >> Turn in My Daughter
.accept 11176 >> Accept See to the Operations
.accept 11393 >> Accept Where is Explorer Jaren?
step
.goto Howling Fjord,30.2,28.7
.target Engineer Feknut
.accept 11154 >> Accept Scare the Guano Out of Them!
step
.goto Howling Fjord,30.2,28.7
.target Watcher Moonleaf
.accept 11322 >> Accept The Cleansing
step
.goto Howling Fjord,30.8,28.6
.target Steel Gate Chief Archaeologist
.turnin 11176 >> Turn in See to the Operations
.accept 11390 >> Accept I've Got a Flying Machine!
step
.vehicle
>>Click the plane near you on the wooden platform to ride in it
step
>>Fly down into the valley below
>>They look like huge sacks with yellow stuff in them on the ground
.macro Grappling Hook,134400 >>/cast Grappling Hook
>>Use your Grappling Hook ability on your hotbar near a big sack on the ground
>>Fly back to the top of the valley and fly toward the red arrows on the big scale things to Deliver a Sack of Relics
>>Repeat this 2 more time
.complete 11390,1
>>Deliver 3 Sacks of Relics
step
.exitvehicle
>>Fly back to the wooden platform and click the red arrow button on your hotbar to get out of the plane
step
.goto Howling Fjord,30.8,28.6
.target Steel Gate Chief Archaeologist
.turnin 11390 >> Turn in I've Got a Flying Machine!
.accept 11391 >> Accept Steel Gate Patrol
step
.vehicle
>>Click the plane near you on the wooden platform to ride in it
step
>>Use the abilities on your hotbar as you fly around to fight the flying gargoyles
.complete 11391,1
.mob Gjalerbron Gargoyle
>>Kill Gjalerbron Gargoyle
step
.exitvehicle
>>Fly back to the wooden platform and click the red arrow button on your hotbar to get out of the plane
step
.goto Howling Fjord,30.8,28.6
.target Steel Gate Chief Archaeologist
.turnin 11391 >> Turn in Steel Gate Patrol
step
.goto Howling Fjord,27.4,32.2
.goto Howling Fjord,27.4,32.2,0.5
>>The path down to Explorer Jaren starts here
step
.goto Howling Fjord,24.2,32.5
.target Explorer Jaren
.turnin 11393 >> Turn in Where is Explorer Jaren?
.accept 11394 >> Accept And You Thought Murlocs Smelled Bad!
step
.goto Howling Fjord,22.6,28.6
.complete 11394,1
>>Kill 15 Scourge murlocs, humanoids, or ghosts
.mob Scourge mobs
>>Kill Scourge mobs
>>Collect Scourge Device
.use 33961
>>Click the Scourge Device in your bags
.accept 11395 >> Accept It's a Scourge Device
step
.goto Howling Fjord,19.8,22.2
.target Old Icefin
.accept 11422 >> Accept Trident of the Son
step
.goto Howling Fjord,24.2,32.5
.target Explorer Jaren
.turnin 11394 >> Turn in And You Thought Murlocs Smelled Bad!
.turnin 11395 >> Turn in It's a Scourge Device
.accept 11396 >> Accept Bring Down Those Shields
step
.goto Howling Fjord,23.7,35.2
.mob Rotgill
>>Kill Rotgill
.complete 11422,1
>>Collect Rotgill's Trident
step
.goto Howling Fjord,22.7,31.2
.use 33960
>>Use your Scourging Crystal Controller on the Scourge Crystal
>>Attack the Scourge Crystal when the purple bubble shield disappears
.complete 11396,1
>>Destroy 1 Scourge Crystal
step
.goto Howling Fjord,21.9,28.8
.use 33960
>>Use your Scourging Crystal Controller on the Scourge Crystal
>>Attack the Scourge Crystal when the purple bubble shield disappears
.complete 11396,1
>>Destroy 1 Scourge Crystal
step
.goto Howling Fjord,21.5,24.6
.use 33960
>>Use your Scourging Crystal Controller on the Scourge Crystal
>>Attack the Scourge Crystal when the purple bubble shield disappears
.complete 11396,1
>>Destroy 1 Scourge Crystal
step
.goto Howling Fjord,19.8,22.2
.target Old Icefin
.turnin 11422 >> Turn in Trident of the Son
step
.goto Howling Fjord,24.2,32.5
.target Explorer Jaren
.turnin 11396 >> Turn in Bring Down Those Shields
step
.goto Howling Fjord,25.1,32.6
.goto Howling Fjord,25.1,32.6,0.5
>>The path back up to the top of the cliff starts here
step
.goto Howling Fjord,30.8,20.9
>>Follow the path up to 30.8,20.9
.use 33129
>>Use Feknut's Firecrackers on the ground under Darkclaw Bats
>>Click the Darkclaw Guano that spawns
.complete 11154,1
>>Collect Darkclaw Guano
step
.goto Howling Fjord,30.2,28.7
.target Engineer Feknut
.turnin 11154 >> Turn in Scare the Guano Out of Them!
step
.goto Howling Fjord,44.4,26.4
.use 33311
>>Use your Westguard Command Insignia in your bags
.target Westguard Sergeant
.turnin 11248 >> Turn in Operation: Skornful Wrath
.accept 11245 >> Accept Towers of Certain Doom
.accept 11246 >> Accept Gruesome, But Necessary
.accept 11247 >> Accept Burn Skorn, Burn!
step
.goto Howling Fjord,45.3,27
.mob Winterskorn mobs
>>Kill Winterskorn mobs
.use 33310
>>Use The Sergeant's Machete on their corpses
.complete 11246,1
>>Dismember 20 Winterskorn Vrykul
>>Collect Vrykul Scroll of Ascension
.use 33314
>>Click the Vrykul Scroll of Ascension in your bags
.accept 11249 >> Accept Stop the Ascension!
step
.goto Howling Fjord,43.7,28.5
.use 33321
>>Use the Sergeant's Torch inside this house
.complete 11247,1
>>Set the Northwest Longhouse Ablaze
step
.goto Howling Fjord,43.6,30.3
.use 33323
>>Use the Sergeant's Flare next to this tower
.complete 11245,1
>>Target the Northwest Tower
step
.goto Howling Fjord,43.2,35.8
.use 33323
>>Use the Sergeant's Flare next to this tower
.complete 11245,3
>>Target the Southwest Tower
step
.goto Howling Fjord,44.9,35
.use 33339
>>Use your Vrykul Scroll of Ascension next to the bonfire
.complete 11249,1
.mob Halfdan the Ice-Hearted
>>Kill Halfdan the Ice-Hearted
step
.goto Howling Fjord,46.9,37.1
.use 33323
>>Use the Sergeant's Flare next to this tower
.complete 11245,4
>>Target the Southeast Tower
step
.goto Howling Fjord,46.5,33.2
.use 33323
>>Use the Sergeant's Flare next to this tower
.complete 11245,2
>>Target the East Tower
step
.goto Howling Fjord,46,30.7
.use 33321
>>Use the Sergeant's Torch inside this building
.complete 11247,3
>>Set the Barracks Ablaze
step
.goto Howling Fjord,46.4,28.2
.use 33321
>>Use the Sergeant's Torch inside this house
.complete 11247,2
>>Set the Northeast Longhouse Ablaze
step
.use 33311
>>Use your Westguard Command Insignia in your bags
.target Westguard Sergeant
.turnin 11245 >> Turn in Towers of Certain Doom
.turnin 11246 >> Turn in Gruesome, But Necessary
.turnin 11247 >> Turn in Burn Skorn, Burn!
.accept 11250 >> Accept All Hail the Conqueror of Skorn!
step
.goto Howling Fjord,28.8,44.1
>>Go inside the fort to 28.8,44.1
.target Captain Adams
.turnin 11250 >> Turn in All Hail the Conqueror of Skorn!
.accept 11235 >> Accept Dealing With Gjalerbron
step
.goto Howling Fjord,30.6,42.8
.target Quartermaster Brevin
.accept 11406 >> Accept Everything Must Be Ready
step
.goto Howling Fjord,28.9,44
.target Father Levariol
.turnin 11249 >> Turn in Stop the Ascension!
.accept 11231 >> Accept Of Keys and Cages
step
.xp 73
step
.goto Howling Fjord,60.3,18.7
.target Christopher Sloan
.accept 11329 >> Accept I'll Try Anything!
step
.goto Howling Fjord,61.5,18.8
>>Click the Water Plants - They look like tall bushy plants underwater around this area
.mob Northern Barbfish
>>Kill Northern Barbfish
.complete 11329,1
>>Collect Northern Barbfish
step
.goto Howling Fjord,60.3,18.7
.target Christopher Sloan
.turnin 11329 >> Turn in I'll Try Anything!
.accept 11410 >> Accept The One That Got Away
step
.goto Howling Fjord,64,19.6
.use 34013
>>Use your Fresh Barbfish Bait next to the Sunken Boat underwater
.complete 11410,1
.mob Frostfin
>>Kill Frostfin
step
.goto Howling Fjord,60.3,18.7
.target Christopher Sloan
.turnin 11410 >> Turn in The One That Got Away
step
.goto Howling Fjord,62.6,16.8
.target Gil Grisert
.turnin 11406 >> Turn in Everything Must Be Ready
.accept 11269 >> Accept Down to the Wire
step
.goto Howling Fjord,62.6,16.8
.target Trapper Jethan
.accept 11292 >> Accept Preying Upon the Weak
step
.goto Howling Fjord,60.1,16.1
.target James Ormsby
.fp Fort Wildervar, Howling Fjord >> Get the Fort Wildervar flight path
step
.goto Howling Fjord,60.2,15.6
.target Foreman Colbey
.accept 11284 >> Accept The Yeti Next Door
step
.goto Howling Fjord,57.3,18.6
.mob Frosthorn Rams
>>Kill Frosthorn Rams
.collect 33352,4,0 >> Collect 4 Tough Ram Meat
.use 33352
>>Click the Tough Ram Meat in your bags
.collect 33477,1,11284 >> Collect 1 Giant Yeti Meal
>>Click the Spotted Hippogryph Down feathers - They look like brown feathers on the ground around this area
.complete 11269,1
>>Collect Spotted Hippogryph Down
>>Click the Sprung Traps - They look like small animals stuck in traps on the ground around this area
.complete 11292,1
>>Collect Trapped Prey
step
.goto Howling Fjord,54.1,8.2
.goto Howling Fjord,54.1,8.2,0.5
>>The path up to The Cleansing starts here
step
.goto Howling Fjord,61.1,2
>>Follow the path up to 61.1,2
>>Click the Frostblade Shrine - It's a big blue glowing altar table thing
.mob Inner Turmoil that spawns
>>Kill Inner Turmoil that spawns
.complete 11322,1
>>Collect Cleansed of Your Inner Turmoil
step
.goto Howling Fjord,30.9,41.5,1
.hs >> Hearth to Westguard Keep
>>Hearth to Westguard Keep
step
.goto Howling Fjord,30.2,28.7
.target Watcher Moonleaf
.turnin 11322 >> Turn in The Cleansing
.accept 11325 >> Accept In Worg's Clothing
step
.goto Howling Fjord,29.7,5.7
.use 33618
>>Use your Worg Disguise to turn into a Worg
.target Ulfang
.turnin 11325 >> Turn in In Worg's Clothing
.accept 11414 >> Accept Brother Betrayers
step
.goto Howling Fjord,28.3,23.9
.complete 11414,1
.mob Bjomolf
>>Kill Bjomolf
step
.goto Howling Fjord,33.8,29.3
.complete 11414,2
.mob Varg
>>Kill Varg
step
.goto Howling Fjord,35.1,16
.complete 11235,1
.mob Gjalerbron Warrior
>>Kill Gjalerbron Warrior
.complete 11235,2
.mob Gjalerbron Rune-Caster
>>Kill Gjalerbron Rune-Caster
.complete 11235,3
.mob Gjalerbron Sleep-Watcher
>>Kill Gjalerbron Sleep-Watcher
.mob Gjalerbron mobs
>>Kill Gjalerbron mobs
.collect 33284,10,0 >> Collect 10 Gjalerbron Cage Key
.collect 33290,1,0 >> Collect 1 Large Gjalerbron Cage Key
>>Click Gjalerbron Cages
.complete 11231,1
>>Free 10 Gjalerbron Prisoners
>>Collect Gjalerbron Attack Plans
.use 33289
>>Click the Gjalerbron Attack Plans in your bags
.accept 11237 >> Accept Gjalerbron Attack Plans
step
.goto Howling Fjord,29.7,5.7
.use 33618
>>Use your Worg Disguise to turn into a Worg
.target Ulfang
.turnin 11414 >> Turn in Brother Betrayers
.accept 11416 >> Accept Eyes of the Eagle
step
.goto Howling Fjord,41.4,37.7
>>Click Talonshrike's Egg - It's an egg sitting in a nest with 2 other eggs at the base of this waterfall, in the water on a rock
.mob Talonshrike
>>Kill Talonshrike
.complete 11416,1
>>Collect Eyes of the Eagle
step
.goto Howling Fjord,29.7,5.7
.use 33618
>>Use your Worg Disguise to turn into a Worg
.target Ulfang
.turnin 11416 >> Turn in Eyes of the Eagle
.accept 11326 >> Accept Alpha Worg
step
.goto Howling Fjord,26.3,12.8
.complete 11326,1
.mob Garwal
>>Kill Garwal
step
.goto Howling Fjord,30.1,28.6
.target Watcher Moonleaf
.turnin 11326 >> Turn in Alpha Worg
step
.goto Howling Fjord,28.9,44.2
.target Mage-Lieutenant Malister
.turnin 11237 >> Turn in Gjalerbron Attack Plans
step
.goto Howling Fjord,28.8,44.1
.target Captain Adams
.turnin 11235 >> Turn in Dealing With Gjalerbron
.accept 11236 >> Accept Necro Overlord Mezhen
step
.goto Howling Fjord,28.9,44
.target Father Levariol
.turnin 11231 >> Turn in Of Keys and Cages
.accept 11239 >> Accept In Service to the Light
step
.goto Howling Fjord,35.7,15.8
>>Go up onto the platform to 35.7,15.8
.complete 11239,1
.mob Deathless Watcher
>>Kill Deathless Watcher
.complete 11239,3
.mob Putrid Wight
>>Kill Putrid Wight
.goto Howling Fjord,38.2,11.8
>>You can find another Putrid Wight and more Deathless Watchers at 38.2,11.8
step
.goto Howling Fjord,38.8,13
.complete 11236,1
.mob Necro Overlord Mezhen
>>Kill Necro Overlord Mezhen
>>Collect Mezhen's Writings
.use 34090
>>Click Mezhen's Writings
.accept 11452 >> Accept The Slumbering King
step
.goto Howling Fjord,39.8,7.6
.goto Howling Fjord,39.8,7.6,0.3
>>This is the entrance to The Slumbering King - Go up the big ramp to this spot
step
.goto Howling Fjord,40.9,6.5
>>Go inside and downstairs to 40.9,6.5
.complete 11452,1
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
.complete 11239,2
.mob Fearsome Horror
>>Kill Fearsome Horror
.mob Necrolords
>>Kill Necrolords
step
.goto Howling Fjord,30.9,41.5,0.5
.hs >> Hearth to Westguard Keep
>>Hearth to Westguard Keep
step
.goto Howling Fjord,28.8,44.1
.target Captain Adams
.turnin 11236 >> Turn in Necro Overlord Mezhen
.turnin 11452 >> Turn in The Slumbering King
step
.goto Howling Fjord,28.9,44
.target Father Levariol
.turnin 11239 >> Turn in In Service to the Light
step
.goto Howling Fjord,28.9,44.2
.target Mage-Lieutenant Malister
.accept 11432 >> Accept Sleeping Giants
step
.goto Howling Fjord,34.5,13.2,0.3
>>Return to the Walking Halls and collect Awakening Rods from the vrykul inside
.collect 34083,5,0 >> Collect 5 Awakening Rod
.use 34083
>>Use your Awakening Rods on Dormant Vrykul
.complete 11432,1
.mob Dormant Vrykul
step
.goto Howling Fjord,28.9,44.2
.target Mage-Lieutenant Malister
.turnin 11432 >> Turn in Sleeping Giants
step
.fly Fort Wildervar, Howling Fjord >> Fly to Fort Wildervar
>>Fly to Fort Wildervar
step
.goto Howling Fjord,59.7,13.8
.goto Howling Fjord,59.7,13.8,0.5
>>The path into the mine for The Yeti Next Door starts here
step
.goto Howling Fjord,60.5,11.9
.use 33477
>>Use your Giant Yeti Meal in your bags on Shatterhorn
.complete 11284,1
.mob Shatterhorn
>>Kill Shatterhorn
step
.goto Howling Fjord,60.2,15.6
>>Go outside to 60.2,15.6
.target Foreman Colbey
.turnin 11284 >> Turn in The Yeti Next Door
step
.goto Howling Fjord,61.8,17.2
.target Lieutenant Maeve
.accept 11302 >> Accept The Enigmatic Frost Nymphs
step
.goto Howling Fjord,62.3,17.2
.target Prospector Belvar
.accept 11346 >> Accept The Book of Runes
step
.goto Howling Fjord,62.6,16.8
.target Gil Grisert
.turnin 11269 >> Turn in Down to the Wire
.accept 11418 >> Accept We Call Him Steelfeather
step
.goto Howling Fjord,62.6,16.8
.target Trapper Jethan
.turnin 11292 >> Turn in Preying Upon the Weak
step
>>She flies in the sky above town
.use 34026
>>Use your Feathered Charm in your bags on Steelfeather
.complete 11418,1
>>Learn Steelfeather's Secret
step
.goto Howling Fjord,62.6,16.8
.target Gil Grisert
.turnin 11418 >> Turn in We Call Him Steelfeather
step
.goto Howling Fjord,61.5,22.8
.target Lurielle
.turnin 11302 >> Turn in The Enigmatic Frost Nymphs
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
>>Use Lurielle's Pendant on Chill Nymphs
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
.mob Spore
>>Kill Spore
.use 33607
>>Use your Enchanted Ice Core on Spore corpses
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
.collect 33778,1,0 >> Collect 1 Book of Runes - Chapter 1
.collect 33779,1,0 >> Collect 1 Book of Runes - Chapter 2
.collect 33780,1,0 >> Collect 1 Book of Runes - Chapter 3
.use 33778
>>Click a Book of Runes - Chapter in your bags
.complete 11346,1
>>Collect The Book of Runes
step
.goto Howling Fjord,62.3,17.2
.target Prospector Belvar
.turnin 11346 >> Turn in The Book of Runes
.accept 11349 >> Accept Mastering the Runes
step
.goto Howling Fjord,71.2,28.7
>>Click the Iron Rune Carving Tools - It looks like a small metal chest
.complete 11349,1
>>Collect Iron Rune Carving Tools
>>If they are not there, they can also spawn at the following 5 locations as well:
>>At 67.5,23.5
>>At 69.1,22.8
>>At 72.4,17.8
>>At 73.4,24.9
>>At 67.5,29.2
step
.goto Howling Fjord,62.3,17.2
.target Prospector Belvar
.turnin 11349 >> Turn in Mastering the Runes
.accept 11348 >> Accept The Rune of Command
step
.goto Howling Fjord,71.9,24.6
.use 33796
>>Use your Rune of Command on a Stone Giant around this area to control it
>>Once you are controlling the Stone Giant, come here
.complete 11348,2
.mob Binder Murdis
>>Kill Binder Murdis
step
.goto Howling Fjord,62.3,17.2
.target Prospector Belvar
.turnin 11348 >> Turn in The Rune of Command
step
.fly Valgarde Port, Howling Fjord >> Fly to Valgarde
>>Fly to Valgarde
step
.zone Wetlands
>>Ride the boat to Menethil Harbor
step
.fly Stormwind, Elwynn >> Fly to Stormwind
>>Fly to Stormwind
step
.zone Borean Tundra
>>Ride the boat to Borean Tundra
step
.zone Dragonblight
>>Go northeast to Dragonblight
step
.goto Dragonblight,29,55.5
.target Image of Archmage Modera
.accept 12000 >> Accept Rifle the Bodies
step
.goto Dragonblight,29.2,55.3
.target Palena Silvercloud
.fp Stars' Rest, Dragonblight >> Get the Stars' Rest flight path
step
.goto Dragonblight,29.2,55.6
.target Warden Jodi Moonsong
.accept 12166 >> Accept The Liquid Fire of Elune
step
.home Stars' Rest >> Set your Hearthstone to Stars' Rest
step
.goto Dragonblight,28.8,56.2
.target Courier Lanson
.turnin 12157 >> Turn in The Lost Courier
.accept 12171 >> Accept Of Traitors and Treason
step
.goto Dragonblight,29.2,55.3
>>She is the Flight Path Master
.target Palena Silvercloud
.turnin 12171 >> Turn in Of Traitors and Treason
step
.goto Dragonblight,26.3,52.3
.mob Blighted Elks
>>Kill Blighted Elks
.mob Rabid Grizzlies
>>Kill Rabid Grizzlies
.use 36956
>>Use your Liquid Fire of Elune on their corpses
.complete 12166,1
>>Cleanse 6 Blighted Elk corpses
.complete 12166,2
>>Cleanse 6 Rabid Grizzly corpses
step
.goto Dragonblight,24.1,53.7
>>Click the Dead Mage Hunter bodies on the ground
>>Collect Mage Hunter Personal Effects bags
.use 35792
>>Click the Mage Hunter Personal Effects bags in your bags
.complete 12000,1
>>Collect Moonrest Gardens Plans
step
.goto Dragonblight,29,55.5
.target Image of Archmage Modera
.turnin 12000 >> Turn in Rifle the Bodies
.accept 12004 >> Accept Prevent the Accord
step
.goto Dragonblight,29.2,55.6
.target Warden Jodi Moonsong
.turnin 12166 >> Turn in The Liquid Fire of Elune
.accept 12167 >> Accept Kill the Cultists
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
.goto Dragonblight,18.4,58.9
.mob Wind Trader Mu'fah
>>Kill Wind Trader Mu'fah
.complete 12004,1
>>Collect Wind Trader Mu'fah's Remains
step
.goto Dragonblight,19.4,58.1
>>Go inside the building to 19.4,58.1
.mob Goramosh
>>Kill Goramosh
.complete 12004,2
>>Collect The Scales of Goramosh
>>Collect Goramosh's Strange Device
.use 36742
>>Click Goramosh's Strange Device
.accept 12055 >> Accept A Strange Device
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
.goto Dragonblight,29,55.5
.target Image of Archmage Modera
.turnin 12004 >> Turn in Prevent the Accord
.turnin 12055 >> Turn in A Strange Device
.accept 12060 >> Accept Projections and Plans
step
.goto Dragonblight,24.2,55.6
.use 36747
>>Use your Surge Needle Teleporter
>>Walk around on the platform you get teleported onto
.complete 12060,1
>>Observe the Object on the Surge Needle
step
.goto Dragonblight,22.6,57.0,1.0
.use 36747
>>Use your Surge Needle Teleporter to go back down to the ground
step
.goto Dragonblight,29,55.5
.target Image of Archmage Modera
.turnin 12060 >> Turn in Projections and Plans
.accept 12065 >> Accept The Focus on the Beach
step
.goto Dragonblight,26.4,65
.mob Captain Emmy Malin
>>Kill Captain Emmy Malin
>>Collect Ley Line Focus Control Ring
.use 36751
>>Use the Ley Line Focus Control Ring next to the half-circle
.complete 12065,1
>>Retrieve ley line focus information
>>Collect Captain Malin's Letter
.use 36756
>>Click Captain Malin's Letter in your bags
.accept 12067 >> Accept A Letter for Home
step
.goto Dragonblight,29,55.5
.target Image of Archmage Modera
.turnin 12065 >> Turn in The Focus on the Beach
.accept 12083 >> Accept Atop the Woodlands
step
.goto Dragonblight,29,55.5
.target Commander Saia Azuresteel
.turnin 12067 >> Turn in A Letter for Home
step
.goto Dragonblight,28.7,57.1
.target Sarendryana
.accept 12092 >> Accept Strengthen the Ancients
step
.goto Dragonblight,31.2,59.7
.target Woodlands Walker
.collect 36786,3,12092 >> Collect 3 Bark of the Walkers
step
.goto Dragonblight,30.6,63.4
.use 36786
>>Use your Bark of the Walkers on Lothalor Ancients
.complete 12092,1
>>Strengthen 3 Lothalor Ancients
step
.goto Dragonblight,32.2,70.6
.mob Lieutenant Ta'zinni
>>Kill Lieutenant Ta'zinni
.collect 36779,1,12083 >> Collect 1 Ley Line Focus Control Amulet
step
.goto Dragonblight,32.2,71.2
.use 36779
>>Use your Ley Line Focus Control Amulet on the Ley Line Focus
.complete 12083,1
>>Retrieve ley line focus information
step
.goto Dragonblight,28.7,57.1
.target Sarendryana
.turnin 12092 >> Turn in Strengthen the Ancients
step
.goto Dragonblight,29,55.5
.target Image of Archmage Modera
.turnin 12083 >> Turn in Atop the Woodlands
.accept 12098 >> Accept Search Indu'le Village
step
.goto Dragonblight,26.4,45.7
.mob Anub'ar Cultist
>>Kill Anub'ar Cultist
.complete 12167,1
>>Collect Functional Cultist Suit
>>Collect The Favor of Zangus
.use 36958
>>Click the Favor of Zangus in your bags
.accept 12168 >> Accept The Favor of Zangus
step
.goto Dragonblight,29.2,55.6
.target Warden Jodi Moonsong
.turnin 12167 >> Turn in Kill the Cultists
.turnin 12168 >> Turn in The Favor of Zangus
.accept 12169 >> Accept The High Cultist
step
.goto Dragonblight,27.0,50.4
.goto Dragonblight,27.0,50.4,0.5
>>The path down to High Cultist Zangus starts here
step
.goto Dragonblight,28.9,49.7
>>Go down into the cave to 28.9,49.7
.complete 12169,1
.mob High Cultist Zangus
>>Kill High Cultist Zangus
step
.goto Dragonblight,29.2,55.6
>>Go out of the cave to 29.2,55.6
.target Warden Jodi Moonsong
.turnin 12169 >> Turn in The High Cultist
step
.goto Dragonblight,40.3,66.9
>>Click Mage-Commander Evenstar's body - His body is floating underwater here
.turnin 12098 >> Turn in Search Indu'le Village
.accept 12107 >> Accept The End of the Line
step
.goto Dragonblight,39.8,66.9
.use 36815
>>Use your Ley Line Focus Control Talisman on the Ley Line Focus
.complete 12107,1
>>Retrieve ley line focus information
step
.goto Dragonblight,53,66.4
.complete 12107,2
>>Go to this spot on the cliff to Observe Azure Dragonshrine
step
.goto Dragonblight,48.5,74.4
.target Cid Flounderfix
.fp Moa'ki, Dragonblight >> Get the Moa'ki flight path
step
.home Moa'ki Harbor >> Set your Hearthstone to Moa'ki Harbor
step
.goto Dragonblight,48,74.9
.target Elder Ko'nani
.turnin 12117 >> Turn in Travel to Moa'ki Harbor
.accept 11958 >> Accept Let Nothing Go To Waste
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
>>Click the Blood of Loguhn in your bags
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
>>Attain Spiritual Insight concerning Indu'le Village
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
>>Kill Tu'u'gwar when he comes
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
.goto Dragonblight,34.3,79.8
.goto Dragonblight,34.3,79.8,0.5
>>The path up to Conversing With the Depths starts here
step
.goto Dragonblight,34,83.4
>>Follow the path up to 34,83.4
>>Click The Pearl of the Depths - It's a big white pearl sitting on a altar thing
>>Oacha'noa appears and tells you to jump in the water
>>Jump in the water when he tells you to
.complete 12032,1
>>Obey Oacha'noa's compulsion
step
.goto Dragonblight,49.2,75.6
.target Toalu'u the Mystic
.turnin 12032 >> Turn in Conversing With the Depths
step
.fly Stars' Rest, Dragonblight >> Fly to Stars' Rest
>>Fly to Stars' Rest
step
.goto Dragonblight,29,55.5
.target Image of Archmage Modera
.turnin 12107 >> Turn in The End of the Line
.accept 12119 >> Accept Gaining an Audience
step
.goto Dragonblight,48.2,74.8,0.5
.hs >> Hearth to Moa'ki Harbor
>>Hearth to Moa'ki Harbor
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.turnin 12119 >> Turn in Gaining an Audience
.accept 12766 >> Accept Speak with your Ambassador
step
.home Wyrmrest Temple >> Set your Hearthstone to Wyrmrest Temple
step
.goto Dragonblight,60,55.1
.target Lauriel Trueblade
.turnin 12766 >> Turn in Speak with your Ambassador
.accept 12460 >> Accept Report to the Ruby Dragonshrine
step
.goto Dragonblight,60.3,51.6
.target Nethestrasz
.fp Wyrmrest Temple, Dragonblight >> Get the Wyrmrest Temple flight path
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.goto Dragonblight,59.7,53.1,0.1
>>Tell him you need to go to the top of the temple
step
.goto Dragonblight,59.6,54.4
.target Lord Itharius
.accept 12458 >> Accept Seeds of the Lashers
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
.goto Dragonblight,58.0,55.2,0.1
>>Tell him you want to go to the ground level of the temple
step
.goto Dragonblight,63.3,66.9
.goto Dragonblight,63.3,66.9,0.5
>>The path down to Seeds of the Lashers starts here
step
.goto Dragonblight,63.3,71
.mob Emerald Lashers
>>Kill Emerald Lashers
.complete 12458,1
>>Collect Lasher Seed
step
.goto Dragonblight,63.7,71.9
.target Nishera the Garden Keeper
.accept 12454 >> Accept Cycle of Life
step
>>They fly around over your head around the lake
.complete 12454,1
.mob Emerald Skytalon
>>Kill Emerald Skytalon
step
.goto Dragonblight,63.7,71.9
.target Nishera the Garden Keeper
.turnin 12454 >> Turn in Cycle of Life
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.goto Dragonblight,59.7,53.1,0.1
>>Tell him you need to go to the top of the temple
step
.goto Dragonblight,59.6,54.4
.target Lord Itharius
.turnin 12458 >> Turn in Seeds of the Lashers
.accept 12459 >> Accept That Which Creates Can Also Destroy
step
.goto Dragonblight,59.5,53.3
.target Torastrasza
.goto Dragonblight,58.0,55.2,0.1
>>Tell him you want to go to the ground level of the temple
step
.goto Dragonblight,52.2,50
.target Ceristrasz
.turnin 12460 >> Turn in Report to the Ruby Dragonshrine
.accept 12416 >> Accept Heated Battle
step
.goto Dragonblight,52.7,46.2
>>Help kill the following:
.complete 12416,1
>>12 Frigid Ghoul Attackers
.complete 12416,2
>>8 Frigid Geist Attackers
.complete 12416,3
>>1 Frigid Abomination Attacker
>>You can find more of these at 50.9,52.4
step
.goto Dragonblight,52.2,50
.target Ceristrasz
.turnin 12416 >> Turn in Heated Battle
.accept 12417 >> Accept Return to the Earth
step
.goto Dragonblight,46.7,52.8
>>Click the Ruby Acorns - The Ruby Acorns look like red stones on the ground around this area
.collect 37727,6,0 >> Collect 6 Ruby Acorn
.use 37727
>>Use the Ruby Acorns on the Ruby Keeper corpses
.complete 12417,1
>>Return 6 Ruby Keepers to the Earth
step
.goto Dragonblight,52.2,50
.target Ceristrasz
.turnin 12417 >> Turn in Return to the Earth
.accept 12418 >> Accept Through Fields of Flame
step
.goto Dragonblight,48.2,47.8
>>Go into the valley to 48.2,47.8
.complete 12418,1
.mob Frigid Necromancer
>>Kill Frigid Necromancer
step
.xp 74
]]);
RXPGuides.RegisterGuide([[
#wotlk
#ac335
#version 1
#group RestedXP WotLK Guide (A)
#subgroup Northrend 70-80
<< Alliance
#name 74-76 Northrend
#next 76-78 Northrend
step
.goto Dragonblight,47.6,49
>>Go into the tree trunk to 47.6,49
.mob Dahlia Suntouch
>>Kill Dahlia Suntouch
.complete 12418,2
>>Cleanse the Ruby Corruption
>>Collect Ruby Brooch
.use 37833
>>Click the Ruby Brooch in your bags
.accept 12419 >> Accept The Fate of the Ruby Dragonshrine
step
.goto Dragonblight,52.2,50
.target Ceristrasz
.turnin 12418 >> Turn in Through Fields of Flame
.accept 12768 >> Accept The Steward of Wyrmrest Temple
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.turnin 12768 >> Turn in The Steward of Wyrmrest Temple
.accept 12123 >> Accept Informing the Queen
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.goto Dragonblight,59.7,53.1,0.1
>>Tell him you need to go to the top of the temple
step
.goto Dragonblight,59.8,54.7
.target Alexstrasza the Life-Binder
.turnin 12123 >> Turn in Informing the Queen
.accept 12435 >> Accept Report to Lord Afrasastrasz
step
.goto Dragonblight,59.8,54.7
.target Krasus
.turnin 12419 >> Turn in The Fate of the Ruby Dragonshrine
step
.goto Dragonblight,59.5,53.3
.target Torastrasza
.goto Dragonblight,59.2,54.3,0.1
>>Tell him you want to go to Lord Afrasastrasz
step
.goto Dragonblight,59.2,54.3
.target Lord Afrasastrasz
.turnin 12435 >> Turn in Report to Lord Afrasastrasz
.accept 12372 >> Accept Defending Wyrmrest Temple
step
.goto Dragonblight,58.3,55.2
.target Wyrmrest Defender
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
.goto Dragonblight,58.0,55.2,0.1
>>Tell him you want to go to the ground level
step
.goto Dragonblight,55.2,45.7
.use 37887
>>Use your Seeds of Nature's Wrath on a Reanimated Frost Wyrm to weaken it
.complete 12459,1
.mob Weakened Reanimated Frost Wyrm
>>Kill Weakened Reanimated Frost Wyrm
step
.goto Dragonblight,29.2,55.4,0.1
>>Go to Wyrmrest Temple and fly to Stars' Rest
step
.goto Dragonblight,29,55.5
.target Image of Archmage Modera
.accept 12794 >> Accept The Magical Kingdom of Dalaran
step
.goto Dragonblight,29.2,55.3
>>She is the Flight Path Master
.target Palena Silvercloud
.accept 12174 >> Accept High Commander Halford Wyrmbane
step
.goto Dragonblight,77.1,49.8,0.1
>>You will fly to Wintergarde Keep
step
.goto Dragonblight,77,49.8
.target Rodney Wells
.fp Wintergarde Keep, Dragonblight >> Get the Wintergarde Keep flight path
step
.goto Dragonblight,78.61,48.2
.target High Commander Halford Wyrmbane
.turnin 12174 >> Turn in High Commander Halford Wyrmbane
.accept 12235 >> Accept Naxxramas and the Fall of Wintergarde
step
.goto Dragonblight,77.1,50.1
.target Gryphon Commander Urik
.turnin 12235 >> Turn in Naxxramas and the Fall of Wintergarde
.accept 12237 >> Accept Flight of the Wintergarde Defender
step
.use 37287
>>Use the Wintergarde Gryphon Whistle in your bags
.vehicle
>>Click the Wintergarde Gryphon to ride it
step
.goto Dragonblight,83.6,48.8
>>Fly to 83.6,48.8
.macro Rescue Villager,134400 >>/cast Rescue Villager
>>Use your Rescue Villager ability on your hotbar on Helpless Wintergarde Villagers on the ground around this area
.macro Soar,134400 >>/cast Soar
>>Fly them back to Gryphon Commander Urik at 77.1,50.1
.macro Drop Off Villager,134400 >>/cast Drop Off Villager
>>Use your Drop Off Villager ability on your hotbar
.complete 12237,1
>>Rescue 10 Helpless Villagers
step
.exitvehicle
>>Click the red arrow button on your hotbar to get off the gryphon
step
.goto Dragonblight,77.1,50.1
.target Gryphon Commander Urik
.turnin 12237 >> Turn in Flight of the Wintergarde Defender
.accept 12251 >> Accept Return to the High Commander
step
.goto Dragonblight,78.61,48.2
.target High Commander Halford Wyrmbane
.turnin 12251 >> Turn in Return to the High Commander
.accept 12253 >> Accept Rescue from Town Square
.accept 12275 >> Accept The Demo-gnome
step
.goto Dragonblight,78.6,48.2
.target Commander Lynore Windstryke
.accept 12258 >> Accept The Fate of the Dead
step
.goto Dragonblight,79.1,47.2
.target Zelig the Visionary
.accept 12282 >> Accept Imprints on the Past
step
.goto Dragonblight,77.8,50.3
.target Siege Engineer Quarterflash
.turnin 12275 >> Turn in The Demo-gnome
.accept 12276 >> Accept The Search for Slinkin
.accept 12272 >> Accept The Bleeding Ore
step
.goto Dragonblight,77.8,50.3
.target Highlord Leoric Von Zeldig
.accept 12269 >> Accept Not In Our Mine
step
.home Wintergarde Keep >> Set your Hearthstone to Wintergarde Keep
step
.goto Dragonblight,79.9,49.7
>>Kill Vengeful Geists next to Trapped Wintergarde Villagers - The Trapped Wintergarde Villagers looked like scared villagers getting harrassed by Vengeful Geists around this area and inside buildings
.complete 12253,1
>>Rescue 6 Trapped Wintergarde Villagers
.complete 12258,1
.mob Vengeful Geist
>>Kill Vengeful Geist
step
.goto Dragonblight,78.9,50.9
>>Go upstairs in this building to 78.9,50.9
>>Click the Scrying Orb - Upstairs in this building, in the back of the room, next to some boxes. It looks like a glowing ball with wings on it
.complete 12282,1
>>Collect Scrying Orb
step
.goto Dragonblight,78.6,48.2
.target Commander Lynore Windstryke
.turnin 12258 >> Turn in The Fate of the Dead
step
.goto Dragonblight,78.61,48.2
.target High Commander Halford Wyrmbane
.turnin 12253 >> Turn in Rescue from Town Square
.accept 12309 >> Accept Find Durkon!
step
.goto Dragonblight,79.1,47.2
.target Zelig the Visionary
.turnin 12282 >> Turn in Imprints on the Past
.accept 12287 >> Accept Orik Trueheart and the Forgotten Shore
step
.goto Dragonblight,79.1,53.2
.target Cavalier Durkon
.turnin 12309 >> Turn in Find Durkon!
.accept 12311 >> Accept The Noble's Crypt
step
.goto Dragonblight,78.6,52.4
>>Go inside the crypt to 78.6,52.4
.mob Necrolord Amarion
>>Kill Necrolord Amarion
>>Click the Flesh-bound Tome - The Flesh-bound Tome is a small red book on the floor
.accept 12312 >> Accept Secrets of the Scourge
step
.goto Dragonblight,79.1,53.2
>>Go outside the crypt to 79.1,53.2
.target Cavalier Durkon
.turnin 12311 >> Turn in The Noble's Crypt
.turnin 12312 >> Turn in Secrets of the Scourge
.accept 12319 >> Accept Mystery of the Tome
step
.goto Dragonblight,78.61,48.2
.target High Commander Halford Wyrmbane
.turnin 12319 >> Turn in Mystery of the Tome
.accept 12320 >> Accept Understanding the Language of Death
step
.goto Dragonblight,76.8,47.4
.target Inquisitor Hallard
.turnin 12320 >> Turn in Understanding the Language of Death
.accept 12321 >> Accept A Righteous Sermon
step
.goto Dragonblight,76.8,47.4
>>Watch the dialogue - Downstairs in the fort, in front of a jail cell
.complete 12321,1
>>Hear the Righteous Sermon
step
.goto Dragonblight,78.61,48.2
.target High Commander Halford Wyrmbane
.turnin 12321 >> Turn in A Righteous Sermon
step
.goto Dragonblight,80.4,45.1
>>Kill Risen Wintergarde Miners inside this mine
.complete 12269,1
>>Collect Wintergarde Miner's Card
>>Click the Strange Ore nodes - They look like green mining nodes
.complete 12272,1
>>Collect Strange Ore
step
.goto Dragonblight,81.5,42.2
.target Slinkin the Demo-gnome
.turnin 12276 >> Turn in The Search for Slinkin
.accept 12277 >> Accept Leave Nothing to Chance
step
.goto Dragonblight,80.7,41.3
>>Click the Wintergarde Mine Bomb - It looks like a bunch of big dymanite sticks on the ground, next to this wooden stage
.collect 37465,1,12277 >> Collect 1 Wintergarde Mine Bomb
step
.goto Dragonblight,80.4,44.8
>>Follow the path in the mine to 80.4,44.8
.use 37465
>>Use your Wintergarde Mine Bomb in the doorway
.complete 12277,2
>>Destroy the Lower Wintergarde Mine Shaft
step
.goto Dragonblight,80.2,45.3
>>Go outside and around to 80.2,45.3
.use 37465
>>Use your Wintergarde Mine Bomb in the doorway
.complete 12277,1
>>Destroy the Upper Wintergarde Mine Shaft
step
.goto Dragonblight,77.8,50.3
>>Follow the path up into town to 77.8,50.3
.target Siege Engineer Quarterflash
.turnin 12277 >> Turn in Leave Nothing to Chance
.turnin 12272 >> Turn in The Bleeding Ore
.accept 12281 >> Accept Understanding the Scourge War Machine
step
.goto Dragonblight,77.8,50.3
.target Highlord Leoric Von Zeldig
.turnin 12269 >> Turn in Not In Our Mine
step
.goto Dragonblight,78.61,48.2
.target High Commander Halford Wyrmbane
.turnin 12281 >> Turn in Understanding the Scourge War Machine
.accept 12325 >> Accept Into Hostile Territory
step
.goto Dragonblight,77.1,49.6
.vehicle
>>Click a Wintergarde Gryphon to ride it - They are standing here in a row
step
.goto Dragonblight,89.7,46.4
.target Duke August Foehammer
.turnin 12325 >> Turn in Into Hostile Territory
.accept 12326 >> Accept Steamtank Surprise
step
.goto Dragonblight,89.6,45.6
.vehicle
>>Click an Alliance Steam Tank to ride it - They look like big siege carts
step
.goto Dragonblight,88.8,46.8
.macro Drop Off Gnome,134400 >>/cast Drop Off Gnome
>>Use your Drop Off Gnome ability on your hotbar to drop off gnomes next to the Plague Wagons in this field
.complete 12326,1
>>Sabotage 6 Plague Wagons
step
.goto Dragonblight,85.6,49.8
.macro Drop Off Soldier,134400 >>/cast Drop Off Soldier
>>Use your Drop Off Soldier ability on your hotbar to drop off your soldiers in front of this crypt entrance
.complete 12326,2
>>Drop Off the 7th Legion Elite
step
.goto Dragonblight,85.9,50.9
>>Go inside the crypt to 85.9,50.9
.target Ambo Cash
.turnin 12326 >> Turn in Steamtank Surprise
.accept 12455 >> Accept Scattered To The Wind
step
.goto Dragonblight,85.9,51
.target Yord "Calamity" Icebeard
.accept 12462 >> Accept Breaking Off A Piece
step
.goto Dragonblight,85.1,49.5
>>Go outside of the crypt to 85.1,49.5
>>Click the Wintergarde Munitions Crates - They look like long wooden boxes on the ground around this area
.complete 12455,1
>>Collect Wintergarde Munitions
step
.goto Dragonblight,86.2,47
.use 37887
>>Use your Seeds of Nature's Wrath on a Turgid the Vile to weaken him
.complete 12459,2
.mob Weakened Turgid the Vile
>>Kill Weakened Turgid the Vile
step
.goto Dragonblight,85.9,50.9
>>Go into the crypt to 85.9,50.9
.target Ambo Cash
.turnin 12455 >> Turn in Scattered To The Wind
.accept 12457 >> Accept The Chain Gun And You
step
.goto Dragonblight,86.2,51
>>Click a 7th Legion Chain Gun to use it - They look like metal turrets
>>Use the abilities on your hotbar Call Out Injured Soldiers and clear a path for them
.complete 12457,1
>>Save 8 Injured 7th Legion Soldiers
step
.exitvehicle
>>Click the red arrow button on your hotbar to get off the gun
step
.goto Dragonblight,85.9,50.9
.target Ambo Cash
.turnin 12457 >> Turn in The Chain Gun And You
.accept 12463 >> Accept Plunderbeard Must Be Found!
step
.goto Dragonblight,84.4,51
>>Go downstairs to 84.4,51
.complete 12462,2
.mob Necrolord X'avius
>>Kill Necrolord X'avius
step
.goto Dragonblight,86.7,52.9
.complete 12462,1
.mob Necrolord Horus
>>Kill Necrolord Horus
step
.goto Dragonblight,85.6,52
.complete 12462,3
.mob Naxxramas Scourge
>>Kill Naxxramas Scourge
step
.goto Dragonblight,84.2,54.7
.target Plunderbeard
.turnin 12463 >> Turn in Plunderbeard Must Be Found!
.accept 12465 >> Accept Plunderbeard's Journal
step
.goto Dragonblight,83,55
>>Follow the tunnel to the other side to 83,55
.mob undead mobs
>>Kill undead mobs
.complete 12465,1
>>Collect Page 4 of Plunderbeard's Journal
.complete 12465,2
>>Collect Page 5 of Plunderbeard's Journal
.complete 12465,3
>>Collect Page 6 of Plunderbeard's Journal
.complete 12465,4
>>Collect Page 7 of Plunderbeard's Journal
step
.goto Dragonblight,85.9,51
>>Follow the tunnel back to the other side to 85.9,51
.target Yord "Calamity" Icebeard
.turnin 12462 >> Turn in Breaking Off A Piece
step
.goto Dragonblight,85.9,50.9
.target Ambo Cash
.turnin 12465 >> Turn in Plunderbeard's Journal
.accept 12466 >> Accept Chasing Icestorm: The 7th Legion Front
step
.goto Dragonblight,87.2,57.4
>>Go outside the crypt to 87.2,57.4
.target Orik Trueheart
.turnin 12287 >> Turn in Orik Trueheart and the Forgotten Shore
.accept 12290 >> Accept The Murkweed Elixir
step
.goto Dragonblight,87.2,57.4
.target Tilda Darathan
.accept 12542 >> Accept The Call Of The Crusade
step
.goto Dragonblight,90.8,64.4
>>Click the Murkweed plants - They look like little purple plants on the ground around this area
.complete 12290,1
>>Collect Murkweed
step
.goto Dragonblight,87.2,57.4
.target Orik Trueheart
.turnin 12290 >> Turn in The Murkweed Elixir
.accept 12291 >> Accept The Forgotten Tale
step
.goto Dragonblight,84.2,66.4
>>As a spirit, go to 84.2,66.4
.use 37570
>>Use the Murkweed Elixir in your bags
.target Forgotten Peasant
.complete 12291,1
>>Question a Forgotten Peasant
.target a Forgotten Rifleman
.complete 12291,2
>>Question a Forgotten Rifleman
.target a Forgotten Knight
.complete 12291,3
>>Question a Forgotten Knight
.target a Forgotten Footman
.complete 12291,4
>>Question a Forgotten Footman
step
.goto Dragonblight,87.2,57.4
.target Orik Trueheart
.turnin 12291 >> Turn in The Forgotten Tale
.accept 12301 >> Accept The Truth Shall Set Us Free
step
.goto Dragonblight,86.8,66.2
.use 37577
>>Use Orik's Crystalline Orb while standing on the Forgotten Ruins blue circle
>>Watch the cutscene
.complete 12301,1
>>Redeem the Forgotten
step
.goto Dragonblight,87.2,57.4
.target Orik Trueheart
.turnin 12301 >> Turn in The Truth Shall Set Us Free
.accept 12305 >> Accept Parting Thoughts
step
.goto Dragonblight,77.4,51.5,0.5
.hs >> Hearth to Wintergarde Keep
>>Hearth to Wintergarde Keep
step
.goto Dragonblight,79.1,47.2
.target Zelig the Visionary
.turnin 12305 >> Turn in Parting Thoughts
.accept 12475 >> Accept What Secrets Men Hide
step
.goto Dragonblight,78.6,48.2
.target Commander Lynore Windstryke
.accept 12476 >> Accept The Return of the Crusade?
step
.goto Dragonblight,78.61,48.2
.target High Commander Halford Wyrmbane
.accept 12477 >> Accept The Path of Redemption
step
.goto Dragonblight,71.7,38.9
.use 37923
>>Use your Hourglass of Eternity
>>Fight the mobs that spawn
.complete 12470,1
>>Protect the Hourglass of Eternity
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
.goto Dragonblight,87.6,38.1
>>Click the Onslaught Map - It looks like a map laid out on a table inside this broken tower
.complete 12475,1
>>Collect Onslaught Map
step
.goto Dragonblight,84.9,35.5
.mob Onslaught mobs
>>Kill Onslaught mobs
.complete 12477,1
>>Collect The Path of Redemption
.complete 12476,1
.mob Scarlet Onslaught
>>Kill Scarlet Onslaught
step
.goto Dragonblight,78.6,48.2
.target Commander Lynore Windstryke
.turnin 12476 >> Turn in The Return of the Crusade?
step
.goto Dragonblight,78.61,48.2
.target High Commander Halford Wyrmbane
.turnin 12477 >> Turn in The Path of Redemption
step
.goto Dragonblight,79.1,47.2
.target Zelig the Visionary
.turnin 12475 >> Turn in What Secrets Men Hide
.accept 12478 >> Accept Frostmourne Cavern
step
.goto Dragonblight,74.2,23.8
.goto Dragonblight,74.2,23.8,0.5
>>The path to Frostmourne Cavern starts here
step
.goto Dragonblight,75.1,20.2
>>Go inside the cave to 75.1,20.2
.use 37933
>>Use Zelig's Scrying Orb next to the Frostmourne Altar
.complete 12478,1
>>Reveal the Secrets of the Past
step
.goto Dragonblight,64.7,27.9
.target Legion Commander Tyralion
.turnin 12466 >> Turn in Chasing Icestorm: The 7th Legion Front
.accept 12467 >> Accept Chasing Icestorm: Thel'zan's Phylactery
step
.goto Dragonblight,64.4,26.9
.target Duane
.accept 12142 >> Accept Pest Control
step
.goto Dragonblight,64.6,27.5
.target "Wyrmbait"
>>Tell him to fetch Icestorm
>>He will bring Icestorm
.mob Icestorm
>>Kill Icestorm
>>Click Thel'zan's Phylactery that spawns
.complete 12467,1
>>Collect Thel'zan's Phylactery
step
.goto Dragonblight,68.1,33.1
.mob Magnataurs
>>Kill Magnataurs
.complete 12142,2
>>Kill 3 Dragonblight Magnataur
step
.goto Dragonblight,70.4,32
.mob Snowplain kobolds
>>Kill Snowplain kobolds
.complete 12142,1
>>Kill 10 Snowplain Snobolds
>>You can find more Snowplain Snobolds at 64.9,43.0
step
.goto Dragonblight,64.4,26.9
.target Duane
.turnin 12142 >> Turn in Pest Control
.accept 12143 >> Accept Canyon Chase
step
.goto Dragonblight,72.5,29.2
>>Follow the fleeing kobolds to 72.5,29.2
.complete 12143,1
.mob Chilltusk
>>Kill Chilltusk
>>Collect Emblazoned Battle Horn
.use 36855
>>Click the Emblazoned Battle Horn
.accept 12146 >> Accept Disturbing Implications
step
.goto Dragonblight,64.4,26.9
.target Duane
.turnin 12143 >> Turn in Canyon Chase
step
.goto Dragonblight,60,55.1
.target Aurastrasza
.turnin 12146 >> Turn in Disturbing Implications
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.goto Dragonblight,59.7,53.1,0.1
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
.goto Dragonblight,58.0,55.2,0.1
>>Tell him you want to go to the ground level of the temple
step
.home Wyrmrest Temple >> Set your Hearthstone to Wyrmrest Temple
step
.fly Wintergarde Keep, Dragonblight >> Fly to Wintergarde Keep
>>Fly to Wintergarde Keep
step
.goto Dragonblight,78.61,48.2
.target High Commander Halford Wyrmbane
.turnin 12467 >> Turn in Chasing Icestorm: Thel'zan's Phylactery
.accept 12472 >> Accept Finality
step
.goto Dragonblight,79.1,47.2
.target Zelig the Visionary
.turnin 12478 >> Turn in Frostmourne Cavern
step
.goto Dragonblight,82.0,50.6
.goto Dragonblight,82.0,50.6,0.5
>>The path down to Legion Commander Yorik starts here
step
.goto Dragonblight,81.2,50.7
.target Legion Commander Yorik
.turnin 12472 >> Turn in Finality
.accept 12473 >> Accept An End And A Beginning
step
>>Watch the dialogue
>>Help fight the battle
.complete 12473,1
>>Defeat Thel'zan the Duskbringer
step
.goto Dragonblight,78.61,48.2
>>Go outside the crypt to 78.61,48.2
.target High Commander Halford Wyrmbane
.turnin 12473 >> Turn in An End And A Beginning
.accept 12474 >> Accept To Fordragon Hold!
step
.fly Stars' Rest, Dragonblight >> Fly to Stars' Rest
>>Fly to Stars' Rest
step
.goto Dragonblight,37.2,31.8
.goto Dragonblight,37.2,31.8,0.5
>>The path to Serinar starts here
step
.goto Dragonblight,35.2,30.0
>>Go inside the cave to 35.2,30.0
.target Serinar
.turnin 12447 >> Turn in The Obsidian Dragonshrine
.accept 12262 >> Accept No One to Save You
.accept 12261 >> Accept No Place to Run
step
.goto Dragonblight,37.9,32
>>Go outside the cave to 37.9,32
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
.goto Dragonblight,35.2,30
>>Go into the cave to 35.2,30
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
.goto Dragonblight,35.2,30
>>Follow the path back down to 35.2,30
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
>>Click Necromantic Runes - They look like round purple symbols on the ground around this area in the cave
.complete 12265,1
>>Destroy 8 Necromantic Runes
step
.goto Dragonblight,35.2,30
>>Go back down in the cave to 35.2,30
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
.goto Dragonblight,35.2,30
>>Go back down in the cave to 35.2,30
.target Serinar
.turnin 12267 >> Turn in Neltharion's Flame
.accept 12266 >> Accept Tales of Destruction
step
.goto Dragonblight,48.5,24.1
>>Go outside to 48.5,24.1
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
>>Also to 55,23.4
.target Xink
.accept 12049 >> Accept Hard to Swallow
step
.goto Dragonblight,57.5,23.9
>>Click Splintered Bone Chunks - They look like small white pointed bones on the ground next to the huge bones on the ground around this area
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
.use 36734
>>Use Xink's Shredder Control Device
>>Click the shredder to ride it
.macro Gather Lumber,134400 >>/cast Gather Lumber
>>Use your Gather Lumber ability next to Coldwind Trees
.complete 12050,1
>>Collect Coldwind Lumber
.complete 12052,2
>>Kill 15 harpies
step
.goto Dragonblight,44.9,9.1
.complete 12052,1
>>Kill Mistress of the Coldwind using Xink's Shredder
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
.goto Dragonblight,56.2,12
>>Go into the cave to 56.2,12
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
.goto Dragonblight,55.3,11
>>Go into the cave to 55.3,11
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
.goto Dragonblight,39.5,25.9
.target Derek Rammel
.fp Fordragon Hold, Dragonblight >> Get the Fordragon Hold flight path
step
.goto Dragonblight,38.5,26.5
.goto Dragonblight,38.5,26.5,0.5
>>The path up to Highlord Bolvar Fordragon in the End Battle starts here
step
.goto Dragonblight,37.8,23.4
>>Follow the path up the mountain to 37.8,23.4
.target Highlord Bolvar Fordragon
.turnin 12474 >> Turn in To Fordragon Hold!
.accept 12495 >> Accept Audience With The Dragon Queen
step
.fly Wyrmrest Temple, Dragonblight >> Fly to Wyrmrest Temple
>>Fly to Wyrmrest Temple
step
.goto Dragonblight,57.9,54.2
.target Tariolstrasz
.goto Dragonblight,59.7,53.1,0.1
>>Tell him you want to go to the top of the temple
step
.goto Dragonblight,60.1,54.2
.target Nalice
.turnin 12266 >> Turn in Tales of Destruction
step
.goto Dragonblight,59.8,54.7
.target Alexstrasza the Life-Binder
.turnin 12495 >> Turn in Audience With The Dragon Queen
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
>>Click the red arrow on your hot bar to jump off the dragon
.target Alexstrasza the Life-Binder
.turnin 12498 >> Turn in On Ruby Wings
.accept 12499 >> Accept Return To Angrathar
step
.goto Dragonblight,59.5,53.3
.target Torastrasza
.goto Dragonblight,58.0,55.2,0.1
>>Tell him you want to go to the ground level of the temple
step
.fly Fordragon Hold, Dragonblight >> Fly to Fordragon Hold
>>Fly to Fordragon Hold
step
.goto Dragonblight,37.8,23.4
>>Follow the path up the mountain to 37.8,23.4
.target Highlord Bolvar Fordragon
.turnin 12499 >> Turn in Return To Angrathar
step
.goto Dragonblight,38.5,19.3
.target Alexstrasza the Life-Binder
.accept 13347 >> Accept Reborn From The Ashes
step
.goto Dragonblight,38,19.6
>>Click Fordragon's Shield - It looks like a small metal shield on the ground
.complete 13347,1
>>Collect Fordragon's Shield
step
.goto Dragonblight,39.5,25.9
.target Derek Rammel
.fly Valiance Keep, Borean Tundra >> Fly to Valiance Keep
>>Fly to Valiance Keep
step
.zone Stormwind City
>>Ride the boat to Stormwind City
step
.goto Stormwind City,80,38.4
.target King Varian Wrynn
.turnin 13347 >> Turn in Reborn From The Ashes
step
.goto Dragonblight,59.8,54.3,0.5
.hs >> Hearth to Wyrmrest Temple
>>Hearth to Wyrmrest Temple
step
.xp 75
step
.fly Stars' Rest, Dragonblight >> Fly to Stars' Rest
>>Fly to Stars' Rest
step
.goto Dragonblight,29,55.5
.target Image of Archmage Modera
.goto Dalaran,55.9,46.8,0.5
>>Teleport to Dalaran
step
.goto Dalaran,56.3,46.8
>>Go downstairs to 56.3,46.8
.target Archmage Celindra
.turnin 12794 >> Turn in The Magical Kingdom of Dalaran
.accept 12790 >> Accept Learning to Leave and Return: the Magical Way
step
.goto Dalaran,56.3,46.8
>>Click the Teleport to Violet Stand Crystal - Downstrairs in a small room. It's a blue floating trianglular jewel
.complete 12790,1
>>Use the Teleport to Violet Stand Crystal
step
.goto Crystalsong Forest,15.7,42.5
>>Click the Teleport to Dalaran Crystal
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
>>Go upstairs to 30.6,48.6
.target Rhonin
.accept 13158 >> Accept Discretion is Key
step
.goto Dalaran,61.3,63.7
.target Warden Alturas
.turnin 13158 >> Turn in Discretion is Key
step
.fly Wintergarde Keep, Dragonblight >> Fly to Wintergarde Keep
>>Fly to Wintergarde Keep
step
.goto Dragonblight,77.1,50.1
.target Gryphon Commander Urik
.accept 12511 >> Accept The Hills Have Us
step
.goto Grizzly Hills,31.3,59.1
.target Vana Grey
.fp Amberpine Lodge, Grizzly Hills >> Get the Amberpine Lodge flight path
step
.goto Grizzly Hills,31.8,59.6
>>Click the Amberseed - It's a small bucket with seeds in it, to left as you enter the door, under the stairs
.accept 12225 >> Accept Mmm... Amberseeds!
step
.goto Grizzly Hills,31.8,60.2
.target Lieutenant Dumont
.turnin 12511 >> Turn in The Hills Have Us
.accept 12292 >> Accept Local Support
step
.goto Grizzly Hills,32.1,60
.target Master Woodsman Anderhol
.turnin 12225 >> Turn in Mmm... Amberseeds!
.accept 12226 >> Accept Just Passing Through
.accept 12212 >> Accept Replenishing the Storehouse
.accept 12215 >> Accept Them or Us!
step
.home Amberpine Lodge >> Set your Hearthstone to Amberpine Lodge
step
.goto Grizzly Hills,33.3,58
.mob Tallhorn Stags
>>Kill Tallhorn Stags
.complete 12212,1
>>Collect Succulent Venison
step
.goto Grizzly Hills,32.1,60
.target Master Woodsman Anderhol
.turnin 12212 >> Turn in Replenishing the Storehouse
.accept 12216 >> Accept Take Their Rear!
step
.goto Grizzly Hills,31.8,60.2
.target Lieutenant Dumont
.accept 12210 >> Accept Troll Season!
step
.goto Grizzly Hills,30.6,53.4
>>Click the Blackroot plants - They look like grassy plants on the ground around this area
.complete 12226,1
>>Collect Blackroot Stalk
.mob Grizzly Bears
>>Kill Grizzly Bears
.complete 12216,1
>>Collect Grizzly Flank
step
.goto Grizzly Hills,32.1,60
.target Master Woodsman Anderhol
.turnin 12216 >> Turn in Take Their Rear!
.turnin 12226 >> Turn in Just Passing Through
.accept 12227 >> Accept Doing Your Duty
step
.goto Grizzly Hills,32.2,58.9
>>Click the Amberpine Outhouse - It looks like a wooden outhouse
>>Use the outhouse
.complete 12227,1
>>Collect Partially Processed Amberseeds
step
.goto Grizzly Hills,32.1,60
.target Master Woodsman Anderhol
.turnin 12227 >> Turn in Doing Your Duty
step
.goto Grizzly Hills,26,67.4
.complete 12215,1
.mob Graymist Hunter
>>Kill Graymist Hunter
step
.goto Grizzly Hills,15.9,65.3
>>Click the Cedar Chest - It's a small brown chest inside this tower
.complete 12292,1
>>Collect Cedar Chest
step
.goto Grizzly Hills,16.2,47.6
.target Samir
.turnin 12210 >> Turn in Troll Season!
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
>>Click a Scourged Troll Mummy on the ground next to you - They look like mummies laying on the ground
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
.goto Grizzly Hills,45.0,28.4
.use 35797
>>Use Drakuru's Elixir next to Drakuru's Brazier
.target Image of Drakuru
.turnin 12802 >> Turn in My Heart is in Your Hands
.accept 12068 >> Accept Voices From the Dust
step
.goto Grizzly Hills,32.0,60.3,0.1
.hs >> Hearth to Amberpine Lodge
>>Hearth to Amberpine Lodge
step
.goto Grizzly Hills,31.8,60.2
.target Lieutenant Dumont
.turnin 12292 >> Turn in Local Support
.accept 12293 >> Accept Close the Deal
step
.goto Grizzly Hills,32.1,60
.target Master Woodsman Anderhol
.turnin 12215 >> Turn in Them or Us!
.accept 12217 >> Accept Eagle Eyes
step
.goto Grizzly Hills,34.8,55.6
.target Ivan
.turnin 12293 >> Turn in Close the Deal
.accept 12294 >> Accept A Tentative Pact
step
.goto Grizzly Hills,31.8,60.2
.target Lieutenant Dumont
.turnin 12294 >> Turn in A Tentative Pact
.accept 12295 >> Accept An Exercise in Diplomacy
step
.goto Grizzly Hills,32.4,59.9
.target Woodsman Drake
.accept 12222 >> Accept Secrets of the Flamebinders
.accept 12223 >> Accept Thinning the Ranks
step
.goto Grizzly Hills,33.6,79
.complete 12223,1
.mob Dragonflayer Huscarl
>>Kill Dragonflayer Huscarl
.mob Dragonflayer Flamebinders
>>Kill Dragonflayer Flamebinders
.complete 12222,1
>>Collect Flame-Imbued Talisman
step
.goto Grizzly Hills,32.4,59.9
.target Woodsman Drake
.turnin 12222 >> Turn in Secrets of the Flamebinders
.turnin 12223 >> Turn in Thinning the Ranks
.accept 12255 >> Accept The Thane of Voldrune
step
.goto Grizzly Hills,26.6,77.9
.target Flamebringer
.vehicle
>>Unchain and control Flamebringer
step
.goto Grizzly Hills,27.1,73
>>Fly to 27.1,73
>>Use the abilities on your hotbar
.complete 12255,1
.mob Thane Torvald Eriksson
>>Kill Thane Torvald Eriksson
step
.goto Grizzly Hills,32.4,59.9
.target Woodsman Drake
.turnin 12255 >> Turn in The Thane of Voldrune
step
.goto Grizzly Hills,34.4,58.3
.complete 12217,1
.mob Imperial Eagle
>>Kill Imperial Eagle
step
.goto Grizzly Hills,32.1,60
.target Master Woodsman Anderhol
.turnin 12217 >> Turn in Eagle Eyes
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
.goto Grizzly Hills,26.4,35.7
.target Envoy Ducal
.turnin 12295 >> Turn in An Exercise in Diplomacy
step
.goto Grizzly Hills,25.6,33.3
.target Katja
.accept 12307 >> Accept Wolfsbane Root
step
.goto Grizzly Hills,28.6,35.1
>>Click the Wolfsbane Roots - They look like spiraling green roots on the ground around this area
.complete 12307,1
>>Uproot 8 Wolfsbane Roots
step
.goto Grizzly Hills,25.6,33.3
.target Katja
.turnin 12307 >> Turn in Wolfsbane Root
step
.goto Grizzly Hills,26.5,35.8
.target Sergei
.accept 12299 >> Accept Northern Hospitality
step
.goto Grizzly Hills,24.3,34.5
.complete 12299,1
.mob Conquest Hold Marauder
>>Kill Conquest Hold Marauder
step
.goto Grizzly Hills,26.5,35.8
.target Sergei
.turnin 12299 >> Turn in Northern Hospitality
.accept 12300 >> Accept Test of Mettle
step
.goto Grizzly Hills,21.9,29.9
.mob Sergeant Bonesnap
>>Kill Sergeant Bonesnap
.complete 12300,1
>>Do the Test of Mettle
step
.goto Grizzly Hills,21.9,29.9
.target Captured Trapper
.turnin 12300 >> Turn in Test of Mettle
.accept 12302 >> Accept Words of Warning
step
.goto Grizzly Hills,26.5,31.8
.target Caged Prisoner
.turnin 12302 >> Turn in Words of Warning
.accept 12308 >> Accept Escape from Silverbrook
step
>>Follow the Caged Prisoner to a horse, click the horse to ride it
>>As you ride, use the abilities on your hotbar to fight and slow down the zombies
.complete 12308,1
>>Escape from Silverbrook
step
.goto Grizzly Hills,31.8,60.2
.target Lieutenant Dumont
.turnin 12308 >> Turn in Escape from Silverbrook
.accept 12310 >> Accept A Swift Response
step
.goto Grizzly Hills,36.3,67.9
.complete 12310,2
.mob Vladek
>>Kill Vladek
step
.goto Grizzly Hills,37,66.5
.complete 12310,1
.mob Silverbrook Hunter
>>Kill Silverbrook Hunter
>>Collect Mikhail's Journal
.use 36940
>>Click Mikhail's Journal in your bags
.accept 12105 >> Accept Descent into Darkness
step
.goto Grizzly Hills,31.8,60.2
.target Lieutenant Dumont
.turnin 12310 >> Turn in A Swift Response
.turnin 12105 >> Turn in Descent into Darkness
.accept 12109 >> Accept Report to Gryan Stoutmantle... Again
step
.goto Grizzly Hills,31.2,59.5
.target Hierophant Thayreen
.accept 12219 >> Accept The Failed World Tree
.accept 12220 >> Accept A Dark Influence
step
.goto Grizzly Hills,28.5,45.0
.goto Grizzly Hills,28.5,45.0,0.5
>>The path down to Vordrassil's Tears starts here
step
.goto Grizzly Hills,30.5,43.9
>>Go underground to 30.5,43.9
.use 37173
>>Use your Geomancer's Orb
.complete 12220,3
>>Use the Orb beneath Vordrassil's Tears
step
.goto Grizzly Hills,33.3,48.5
>>Go outside the tunnel to 33.3,48.5
.goto Grizzly Hills,33.3,48.5,0.5
>>The path down to Vordrassil's Limb starts here
step
.goto Grizzly Hills,32.2,45.8
>>Go underground to 32.2,45.8
.use 37173
>>Use your Geomancer's Orb
.complete 12220,2
>>Use the Orb beneath Vordrassil's Limb
step
.goto Grizzly Hills,40.7,52
>>Go outside the tunnel to 40.7,52
.goto Grizzly Hills,40.7,52.0,0.5
>>The path down to Vordrassil's Heart starts here
step
.goto Grizzly Hills,41.2,54.7
>>Go underground to 41.2,54.7
.use 37173
>>Use your Geomancer's Orb
.complete 12220,1
>>Use the Orb beneath Vordrassil's Heart
step
.goto Grizzly Hills,40.4,50.6
>>Go outside the tunnel to 40.4,50.6
.mob Entropic Oozes
>>Kill Entropic Oozes
.complete 12219,1
>>Collect Slime Sample
step
.goto Grizzly Hills,32.0,60.3,0.1
.hs >> Hearth to Amberpine Lodge
>>Hearth to Amberpine Lodge
step
.goto Grizzly Hills,31.2,59.5
.target Hierophant Thayreen
.turnin 12219 >> Turn in The Failed World Tree
.turnin 12220 >> Turn in A Dark Influence
.accept 12246 >> Accept A Possible Link
.accept 12247 >> Accept Children of Ursoc
step
.goto Grizzly Hills,66.9,62.4
.target Kodian
.complete 12247,2
>>Listen to Kodian's Story
step
.goto Grizzly Hills,63.6,57.9
.mob Redfang furbolgs
>>Kill Redfang furbolgs
.complete 12246,1
>>Collect Crazed Furbolg Blood
step
.goto Grizzly Hills,48.1,58.9
.target Orsonn
.complete 12247,1
>>Listen to Orsonn's Story
step
.goto Grizzly Hills,49.2,34.1
.target Emily
.accept 12027 >> Accept Mr. Floppy's Perilous Adventure
>>Escort Emily and protect Mr. Floppy
.complete 12027,1
>>Help Emily and Mr. Floppy return to the camp
step
.goto Grizzly Hills,59.1,26.5
.target Squire Percy
.accept 12414 >> Accept Mounting Up
step
.goto Grizzly Hills,59.1,26.5
.target Squire Walter
.turnin 12027 >> Turn in Mr. Floppy's Perilous Adventure
step
.goto Grizzly Hills,59.4,26
.target Captain Gryan Stoutmantle
.turnin 12109 >> Turn in Report to Gryan Stoutmantle... Again
.accept 12158 >> Accept Hollowstone Mine
.accept 11998 >> Accept Softening the Blow
step
.home Westfall Brigade Encampment >> Set your Hearthstone to Westfall Brigade Encampment
step
.goto Grizzly Hills,59.9,26.7
.target Samuel Clearbook
.fp Westfall Brigade, Grizzly Hills >> Get the Westfall Brigade Encampment flight path
step
.goto Grizzly Hills,55.1,23.4
.target Petrov
.turnin 12158 >> Turn in Hollowstone Mine
.accept 12159 >> Accept Souls at Unrest
step
.goto Grizzly Hills,54.9,23
.mob Undead Miners
>>Kill Undead Miners
.use 37932
>>Use your Miner's Lantern on their corpses
.complete 12159,1
>>Put 8 Miners at Rest
step
.goto Grizzly Hills,55.1,23.4
.target Petrov
.turnin 12159 >> Turn in Souls at Unrest
.accept 12160 >> Accept A Name from the Past
step
.goto Grizzly Hills,59.4,26
.target Captain Gryan Stoutmantle
.turnin 12160 >> Turn in A Name from the Past
step
.goto Grizzly Hills,59.2,26.2
.target Private Arun
.accept 12161 >> Accept Ruuna the Blind
step
.fly Amberpine Lodge, Grizzly Hills >> Fly to Amberpine Lodge
>>Fly to Amberpine Lodge
step
.goto Grizzly Hills,31.2,59.5
.target Hierophant Thayreen
.turnin 12246 >> Turn in A Possible Link
.turnin 12247 >> Turn in Children of Ursoc
.accept 12248 >> Accept Vordrassil's Sapling
.accept 12250 >> Accept Vordrassil's Seeds
step
.goto Grizzly Hills,44,47.9
.target Ruuna the Blind
.turnin 12161 >> Turn in Ruuna the Blind
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
.goto Grizzly Hills,44,47.9
.target Ruuna the Blind
.turnin 12327 >> Turn in Out of Body Experience
.accept 12329 >> Accept Fate and Coincidence
step
.goto Grizzly Hills,50.5,46.0
.goto Grizzly Hills,50.5,46.0,0.5
>>The path down to Vordrassil's Sapling starts here
step
.goto Grizzly Hills,50.8,42.6
>>Follow the path down to 50.8,42.6
.use 37306
>>Use your Verdant Torch next to the tall tree
.complete 12248,1
>>Collect Vordrassil's Ashes
step
.goto Grizzly Hills,51.5,47.1
>>Go outside to 51.5,47.1
>>Click Vordrassil's Seeds - They look like brown pinecones sitting on the ground around this area
.complete 12250,1
>>Collect Vordrassil's Seed
step
.goto Grizzly Hills,57.5,41.3
>>Go outside to 57.5,41.3
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
.goto Grizzly Hills,69.1,40.1
.target Hugh Glass
.accept 12279 >> Accept A Bear of an Appetite
.complete 11998,1
>>Buy buy Howlin' Good Moonshine
step
.goto Grizzly Hills,61.6,32.8
>>Click the Wild Carrots on the ground
.collect 37707,5,12414 >> Collect 5 Wild Carrot
step
.goto Grizzly Hills,60.3,25.4
.use 37708
>>Use your Stick on Highland Mustangs to ride them
>>Ride them back to Squire Percy at 59.1,26.6
.macro Hand Over Reins,134400 >>/cast Hand Over Reins
>>Use the Hand Over Reins ability on your hotbar to return the horses
.complete 12414,1
>>Return 5 Highland Mustangs
step
.goto Grizzly Hills,59.1,26.5
.target Squire Percy
.turnin 12414 >> Turn in Mounting Up
step
.goto Grizzly Hills,59.8,27.5
.target Brugar Stoneshear
.turnin 11998 >> Turn in Softening the Blow
.accept 12002 >> Accept Brothers in Battle
step
.goto Grizzly Hills,63.7,23.2
.target Fallen Earthen Warrior
.accept 11981 >> Accept Find Kurun!
step
.goto Grizzly Hills,64.3,19.8
>>Click the Battered Journal - It's a thick book sitting on the ground
.accept 11986 >> Accept The Damaged Journal
step
>>They look like torn pages that spawn all around this area on the ground
>>Click the Missing Journal Pages
.collect 35737,8,0 >> Collect 8 Missing Journal Page
.use 35739
>>Click the Incomplete Journal in your bags
.complete 11986,1
>>Collect Brann Bronzebeard's Journal
step
.goto Grizzly Hills,63.1,24.1
.complete 12002,1
.mob Runic Battle Golem
>>Kill Runic Battle Golem
step
.goto Grizzly Hills,61.5,23.9,0.5
>>The path up to Kurun starts here
step
.goto Grizzly Hills,65.8,17.8
>>Follow the road into the mountains around to 66,18
.target Kurun
.turnin 11981 >> Turn in Find Kurun!
.accept 11982 >> Accept Raining Down Destruction
step
.goto Grizzly Hills,66.1,13.8
>>Click the Boulders - They look like huge rocks on the ground around this area
.collect 35734,5,11982 >> Collect 5 Boulder
step
.goto Grizzly Hills,66.9,14.9
.use 35734
>>Use your Boulders on Iron Rune Shapers below
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
.goto Grizzly Hills,70.2,13
>>Go down the hill and into the building to 70.2,13
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
.goto Grizzly Hills,59.8,27.5
.target Brugar Stoneshear
.turnin 12002 >> Turn in Brothers in Battle
.accept 12003 >> Accept Uncovering the Tunnels
step
.goto Grizzly Hills,59.8,27.5
.target Torthen Deepdig
.turnin 11986 >> Turn in The Damaged Journal
.accept 11988 >> Accept The Runic Keystone
step
.goto Grizzly Hills,62.7,20.8
.complete 12003,1
>>Investigate the North Building
step
.goto Grizzly Hills,63.5,28.2
.complete 12003,3
>>Investigate the South Building
step
.goto Grizzly Hills,66.6,24.3
.complete 12003,2
>>Investigate the East Building
step
.goto Grizzly Hills,65.1,19.3
.mob iron dwarves
>>Kill iron dwarves
.complete 11988,1
>>Collect Runic Keystone Fragment
step
.goto Grizzly Hills,59.8,27.5
.target Brugar Stoneshear
.turnin 12003 >> Turn in Uncovering the Tunnels
.accept 12010 >> Accept The Fate of Orlond
step
.goto Grizzly Hills,59.8,27.5
.target Torthen Deepdig
.turnin 11988 >> Turn in The Runic Keystone
.accept 11993 >> Accept The Runic Prophecies
step
.goto Grizzly Hills,67.5,15.3
.target Surveyor Orlond
.turnin 12010 >> Turn in The Fate of Orlond
.accept 12014 >> Accept Steady as a Rock?
step
.goto Grizzly Hills,67.8,15.5
.mob Subterranean Threshers in the water
>>Kill Subterranean Threshers in the water
.complete 12014,2
>>Collect Portable Seismograph
step
.goto Grizzly Hills,68.5,16.2
>>Click the Third Rune Plate - It looks like a brown strip across a metal door in the wall
.complete 11993,3
>>Decipher the Third Prophecy
step
.goto Grizzly Hills,69,14.4
>>Click the First Rune Plate - It looks like a brown strip across a metal door in the wall
.complete 11993,1
>>Decipher the First Prophecy
step
.goto Grizzly Hills,70.2,14.7
>>Click the Second Rune Plate - It looks like a brown strip across a metal door in the wall
.complete 11993,2
>>Decipher the Second Prophecy
step
.goto Grizzly Hills,70.6,13.4
.use 35837
>>Use your Portable Seismograph next to this bridge in this spot
>>Click the Portable Seismograph that appears
.complete 12014,1
>>Collect Thor Modan Stability Profile
step
.goto Grizzly Hills,59.8,27.5
.target Brugar Stoneshear
.turnin 12014 >> Turn in Steady as a Rock?
.accept 12128 >> Accept Check Up on Raegar
step
.goto Grizzly Hills,59.8,27.5
.target Torthen Deepdig
.turnin 11993 >> Turn in The Runic Prophecies
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
.goto Grizzly Hills,73.8,34
.target Harkor
.turnin 12113 >> Turn in Nice to Meat You
step
.goto Grizzly Hills,70.5,27.4
.complete 12114,1
.mob Drakkari Protector
>>Kill Drakkari Protector
.complete 12114,2
.mob Drakkari Oracle
>>Kill Drakkari Oracle
.mob Drakkari Protector+, Drakkari Oracle
>>Kill Drakkari Protector+, Drakkari Oracle
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
.turnin 12082 >> Turn in Dun-da-Dun-tah!
.turnin 12114 >> Turn in Therapy
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
.xp 76
]]);
RXPGuides.RegisterGuide([[
#wotlk
#ac335
#version 1
#group RestedXP WotLK Guide (A)
#subgroup Northrend 70-80
<< Alliance
#name 76-78 Northrend
#next 78-80 Northrend
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
>>Click Gan'jo's Chest in the sink next to you
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
>>Use your Drakkari Spirit Dust in your bags
.collect 37063,1,12152 >> Collect 1 Infused Drakkari Offering
step
.goto Grizzly Hills,71.4,24.4
>>Go outside to 71.4,24.4
.use 37063
>>Use your Infused Drakkari Offering next to a gong
>>Destroy Warlord Jin'arrak
.complete 12152,1
>>Complete Warlord Jin'arrak Destroyed
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
.goto Grizzly Hills,69.1,40.1
.target Hugh Glass
.turnin 12279 >> Turn in A Bear of an Appetite
step
.goto Grizzly Hills,77,48.4
.target Mountaineer Kilian
.accept 12180 >> Accept The Captive Prospectors
step
.goto Grizzly Hills,77.1,48.6
.target Raegar Breakbrow
.turnin 12128 >> Turn in Check Up on Raegar
.accept 12129 >> Accept The Perfect Plan
step
.goto Grizzly Hills,76.6,55.1
.mob Iron Rune-Smiths
>>Kill Iron Rune-Smiths
.collect 37013,3,12180 >> Collect 3 Dun Argol Cage Key
.collect 36849,1,0 >> Collect 1 Golem Blueprint Section 1
.collect 36850,1,0 >> Collect 1 Golem Blueprint Section 2
.collect 36851,1,0 >> Collect 1 Golem Blueprint Section 3
.use 36849
>>Click the Golem Blueprint Section 1 in your bags
.complete 12129,1
>>Collect War Golem Blueprint
step
.goto Grizzly Hills,76.5,55.4
>>Click the Dun Argol Cage - Inside this building, locked in a metal cage
.complete 12180,1
>>Rescue Prospector Gann
step
.goto Grizzly Hills,76.3,58.5
>>Click the Dun Argol Cage - On the side of this building, locked in a metal cage
.complete 12180,2
>>Rescue Prospector Torgan
step
.goto Grizzly Hills,76,61
>>Click the Dun Argol Cage - On the side of this building, locked in a metal cage
.complete 12180,3
>>Rescue Prospector Varana
step
.goto Grizzly Hills,77.1,48.6
.target Raegar Breakbrow
.turnin 12129 >> Turn in The Perfect Plan
.accept 12130 >> Accept Why Fabricate When You Can Appropriate?
step
.goto Grizzly Hills,77,48.4
.target Mountaineer Kilian
.turnin 12180 >> Turn in The Captive Prospectors
.accept 12183 >> Accept Looking the Part
step
.goto Grizzly Hills,76.6,54.8
.mob Iron Rune Overseer
>>Kill Iron Rune Overseer
.complete 12183,1
>>Collect Overseer's Uniform
>>Click the War Golem Parts - They look like metal parts sitting around inside this room and buildings around this area
.complete 12130,1
>>Collect War Golem Part
step
.goto Grizzly Hills,77.1,48.6
.target Raegar Breakbrow
.turnin 12130 >> Turn in Why Fabricate When You Can Appropriate?
.accept 12131 >> Accept We Have the Power
step
.goto Grizzly Hills,77,48.4
.target Mountaineer Kilian
.turnin 12183 >> Turn in Looking the Part
.accept 12184 >> Accept Cultivating an Image
step
.goto Grizzly Hills,76.1,56.4
.mob Iron dwarves
>>Kill Iron dwarves
.use 37045
>>Use Kilian's Camera on their corpses
.complete 12184,1
>>Capture 8 Iron Dwarf Images
step
.goto Grizzly Hills,76.8,59.4
.mob Rune-Smith Kathorn
>>Kill Rune-Smith Kathorn
.complete 12131,2
>>Collect Kathorn's Power Cell
step
.goto Grizzly Hills,74.9,56.9
.mob Rune-Smith Durar
>>Kill Rune-Smith Durar
.complete 12131,1
>>Collect Durar's Power Cell
step
.goto Grizzly Hills,77.1,48.6
.target Raegar Breakbrow
.turnin 12131 >> Turn in We Have the Power
.accept 12138 >> Accept ... Or Maybe We Don't
step
.goto Grizzly Hills,77,48.4
.target Mountaineer Kilian
.turnin 12184 >> Turn in Cultivating an Image
.accept 12185 >> Accept Put on Your Best Face for Loken
step
.goto Grizzly Hills,76.6,51.4
.use 36936
>>Use your Golem Control Unit
.mob Lightning Sentries
>>Kill Lightning Sentries
.complete 12138,1
>>Collect Charge Level
step
.goto Grizzly Hills,81.5,60.3
.use 37071
>>Use your Overseer's Disguise Kit
>>Click Loken's Pedastal - Go up the hill into this building at the end of the path. It's a big sqaure stone altar thing inside this building
.complete 12185,1
>>Receive the Message from Loken
step
.goto Grizzly Hills,77.1,48.6
.target Raegar Breakbrow
.turnin 12138 >> Turn in ... Or Maybe We Don't
.accept 12153 >> Accept The Iron Thane and His Anvil
.accept 12154 >> Accept Blackout
step
.goto Grizzly Hills,77,48.4
.target Mountaineer Kilian
.turnin 12185 >> Turn in Put on Your Best Face for Loken
step
.goto Grizzly Hills,76.5,63.2
>>Go into this building and downstairs to 77,63
.use 36935
>>Use Raegar's Explosives next to the Dun Argol Power Core
.complete 12154,1
>>Destroy the Dun Argol Power Crystal
step
.goto Grizzly Hills,76.2,63.2
.use 36865
>>Use your Golem Control Unit to ride in your War Golem
.macro EMP,134400 >>/cast EMP
>>Use your EMP skill to stun The Anvil and remove Iron Thane Furyhammer's Shield
.complete 12153,1
.mob Iron Thane Furyhammer
>>Kill Iron Thane Furyhammer
step
.exitvehicle
>>Click the Leave Vehicle button to stop controlling the golem
step
.goto Grizzly Hills,77.1,48.6
.target Raegar Breakbrow
.turnin 12153 >> Turn in The Iron Thane and His Anvil
.turnin 12154 >> Turn in Blackout
step
.goto Grizzly Hills,59.5,26.3,0.5
.hs >> Hearth to Westfall Brigade Encampment
>>Hearth to Westfall Brigade Encampment
step
.fly Amberpine Lodge, Grizzly Hills >> Fly to Amberpine Lodge
>>Fly to Amberpine Lodge
step
.goto Grizzly Hills,31.2,59.5
.target Hierophant Thayreen
.turnin 12248 >> Turn in Vordrassil's Sapling
.turnin 12250 >> Turn in Vordrassil's Seeds
step
.fly Westfall Brigade, Grizzly Hills >> Fly to Westfall Brigade Encampment
>>Fly to Westfall Brigade Encampment
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
>>Use your Drakuru "Lock Openers next to Captured Rageclaws
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
>>Collect a Unliving Choker
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
>>Collect a Writhing Choker
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
.goto Zul'Drak,19.9,73.5
.mob Putrid Abominations
>>Kill Putrid Abominations
.complete 12629,1
>>Collect Putrid Abomination Guts
>>Click the Gooey Ghoul Drool on the ground - They look like jelly blobs on the ground around this area
.complete 12629,2
>>Collect Gooey Ghoul Drool
step
.isQuestTurnedIn 12238
.goto Zul'Drak,19.9,73.5
.mob Putrid Abominations
>>Kill Putrid Abominations
.complete 12643,1
>>Collect Putrid Abomination Guts
>>Click the Gooey Ghoul Drool on the ground - They look like jelly blobs on the ground around this area
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
>>Buy buy 1 Bitter Plasma
step
.isQuestTurnedIn 12238
.goto Zul'Drak,19.9,75.5
.use 38699
>>Use the Ensorcelled Choker to wear a ghoul costume
.target Gristlegut
.accept 12652 >> Accept Feedin' Da Goolz
.complete 12649,1
>>Buy buy 1 Bitter Plasma
step
.goto Zul'Drak,20.5,74.8
.use 38701
>>Use your Bowels and Brains Bowel near Decaying Ghouls
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
.goto Zul'Drak,28.0,44.9,0.1
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
.goto Zul'Drak,28.1,45.2,0.1
>>Get teleported up to Overlord Drakuru
step
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.accept 12673 >> Accept It Rolls Downhill
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.0,44.9,0.1
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
.goto Zul'Drak,28.1,45.2,0.1
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
.goto Zul'Drak,28.0,44.9,0.1
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
.goto Zul'Drak,28.1,45.2,0.1
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
.goto Zul'Drak,28.0,44.9,0.1
>>Teleport back down to the ground
step
.goto Zul'Drak,29.7,49.6
.use 39206
>>Use your Scepter of Empowerment on a Servant of Drakaru
>>Take control of a Servant of Drakaru
>>Use the abilities on your Servant of Drakaru's pet bar to fight Darmuk at 30.4,51.5
.complete 12686,1
>>Kill Darmuk
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.1,45.2,0.1
>>Get teleported up to Overlord Drakuru
step
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.turnin 12686 >> Turn in Zero Tolerance
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.0,44.9,0.1
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
.goto Zul'Drak,28.1,45.2,0.1
>>Get teleported up to Overlord Drakuru
step
.goto Zul'Drak,27.1,46.2
.target Overlord Drakuru
.accept 12690 >> Accept Fuel for the Fire
step
.goto Zul'Drak,28.4,44.9
>>Stand on this green circle
.goto Zul'Drak,28.0,44.9,0.1
>>Teleport back down to the ground
step
.goto Zul'Drak,32.1,40.6
.use 39238
>>Use your Scepter of Command on a Bloated Abomination
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
.goto Zul'Drak,28.1,45.2,0.1
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
.goto Zul'Drak,27.4,42.5,0.1
>>Teleport up to Drakuru's upper chamber
step
.goto Zul'Drak,27.2,42.3
>>Click the Musty Coffin - It's a brown coffin
.complete 12710,1
>>Explore Drakuru's upper chamber
step
.goto Zul'Drak,28.4,44.9
.goto Zul'Drak,28.1,45.2,0.1
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
.goto Zul'Drak,28.0,44.9,0.1
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
.mob Banshee Soulclaimer
>>Kill Banshee Soulclaimer
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
.goto Zul'Drak,19.7,56.4
>>Click the Scourge Enclosure, it's Gymer's huge cage
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
.goto Zul'Drak,40.5,65.6
.target Hexxer Ubungo
.accept 12565 >> Accept The Blessing of Zim'Abwa
step
.goto Zul'Drak,38.4,67.1
.complete 12503,1
>>Kill 10 Scourge
.use 39615
>>Use your Crusader Parachute on Argent Shieldmen and Argent Crusaders
>>It won't work on all of them
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
>>Collect a Strange Mojo
.use 38321
>>Click the Strange Mojo in your bags
.accept 12507 >> Accept Strange Mojo
step
.goto Zul'Drak,40,39
>>Go inside the building to 40,39
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
.collect 38323,3,0 >> Collect 3 Water Elemental Link
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
.collect 38380,25,0 >> Collect 25 Zul'Drak Rat
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
.goto Zul'Drak,40.8,66.3,0.5
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
.xp 77
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
>>Collect Chunks of Saronite
step
.goto Zul'Drak,58.3,72
.target Specialist Cogwheel
.turnin 12555 >> Turn in A Tangled Skein
step
#optional
.collect 38551,10,12565
>>Make sure you have 10 Drakkari Offerings in your bags
>>If not, grind around this area until you do
step
.goto Zul'Drak,40.8,66.3,0.1
.hs >> Hearth to The Argent Stand
>>Hearth to The Argent Stand
step
.fly Dalaran >> Fly to Dalaran
>>Fly to Dalaran
step
.goto Dalaran,69.7,45.4
.target Hira Snowdawn
>>Collect your Expert Riding Training (if you don't already have it)
>>Collect your Cold Weather Flying Training
>>Skip to the next step of the guide
step
.goto Dalaran,68.6,42
.target Archmage Pentarus
.accept 12521 >> Accept Where in the World is Hemet Nesingwary?
step
.fly The Argent Stand, Zul'Drak >> Fly to The Argent Stand
>>Fly to The Argent Stand
step
.goto Zul'Drak,40.8,66.6
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
.goto Zul'Drak,59.3,57.3
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
.fly Fizzcrank Airstrip, Borean Tundra >> Fly to Fizzcrank Airstrip
>>Fly to Fizzcrank Airstrip
step
.zone Sholazar Basin
>>Go north to Sholazar Basin
step
.goto Sholazar Basin,27.1,59.9
.target Debaar
.accept 12524 >> Accept Venture Co. Misadventure
step
.home Nesingwary Base Camp >> Set your Hearthstone to Nesingwary Base Camp
step
.goto Sholazar Basin,26.9,58.9
.target Chad
.accept 12624 >> Accept It Could Be Anywhere!
step
.goto Sholazar Basin,25.3,58.5
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
>>Click the Raised Mud underwater - They look like piles of dirt underwater in this lake
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
.xp 78
]]);
RXPGuides.RegisterGuide([[
#wotlk
#ac335
#version 1
#group RestedXP WotLK Guide (A)
#subgroup Northrend 70-80
<< Alliance
#name 78-80 Northrend
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
>>The path down to The Sapphire Queen starts here
step
>>Follow the path down to 57.1,79.3
.mob Sapphire Hive Queen
>>Kill Sapphire Hive Queen
.complete 12534,1
>>Collect Stinger of the Sapphire Queen
step
.goto Sholazar Basin,55,69.1
>>Go outside to 55,69.1
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
>>He travels up and down the river bank, so you may need to search for him
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
.goto Sholazar Basin,26.8,59.2,0.5
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
.mob Bittertide Hydra
>>Kill Bittertide Hydra. Use your Sample Container while affected by Hydra Sputum
.use 39164
.complete 12683,1
>>Collect 5 Sputum Samples
.complete 12683,2
step
.goto Sholazar Basin,42.1,28.7
.target Colvin Norrington
.turnin 12683 >> Turn in Burning to Help
step
.goto Sholazar Basin,42.1,28.7
.target Colvin Norrington
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
>>Click Lifeblood Shards - They look like small red crystals on the ground around this area
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
.goto Sholazar Basin,26.8,59.2,0.5
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
.goto Sholazar Basin,26.8,59.2,0.1
.hs >> Hearth to Nesingwary Base Camp
>>Hearth to Nesingwary Base Camp
step
.fly Dalaran >> Fly to Dalaran
>>Fly to Dalaran
step
.goto Dalaran,35,45.3
.goto Dalaran,35,45.3,0.4
>>The path down to Rin Duoctane starts here
step
.goto Dalaran,30.9,50.2
>>Go into the sewer to 30.9,50.2
.target Rin Duoctane
.accept 12853 >> Accept Luxurious Getaway!
step
.goto Dalaran,56.3,46.8
>>Go back up to the top level of the city
.goto Crystalsong Forest,15.8,42.8,0.1
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
>>Click Dried Gnoll Rations - The Dried Gnoll Rations crates look like wooden boxes sitting on the ground around this area
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
>>Click the U.D.E.D. Dispenser next to Tore Rumblewrench - Standing next to some debris
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
.mob Icetip Crawler
>>Kill Icetip Crawler
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
.collect 40641,5,0 >> Collect 5 Cold Iron Key
>>Click the Rusty Cages
.complete 12843,1
>>Free 5 Goblin Prisoners
>>Click the K3 Equipment - The K3 Equipment looks like wooden crates on the ground around town
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
.complete 12822,1
.mob Garm Watcher
>>Kill Garm Watcher
.complete 12822,2
.mob Snowblind Devotee
>>Kill Snowblind Devotee
step
.goto The Storm Peaks,40.9,85.3
.target Ricket
.turnin 12822 >> Turn in Know No Fear
step
.goto The Storm Peaks,50.0,81.8
.target Gino
.accept 12823 >> Accept A Flawless Plan
step
.goto The Storm Peaks,50.5,77.8
>>Go inside the cave to 50.5,77.8
.use 41431
>>Use your Hardpacked Explosive Bundle next to Frostgut's Altar
.complete 12823,2
.mob Tormar Frostgut
>>Kill Tormar Frostgut
step
.goto The Storm Peaks,50.0,81.8
>>Go outside and go to 50.0,81.8
.target Gino
.turnin 12823 >> Turn in A Flawless Plan
.accept 12824 >> Accept Demolitionist Extraordinaire
step
.goto The Storm Peaks,42.8,68.9
>>Fly up into the cave to 42.8,68.9
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
.xp 79
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
>>Use your Reins of the Warbear Matriarch outside the building to ride a bear
step
.goto The Storm Peaks,50.8,67.7
>>Use the abilities on your hotbar to fight Kirgaraak - He's a big white yeti
.complete 12996,1
>>Defeat Kirgaraak
step
.exitvehicle
>>Click the red arrow to get off the bear
step
.goto The Storm Peaks,49.7,71.8
.target Astrid Bjornrittar
.turnin 12996 >> Turn in The Warm-Up
.accept 12997 >> Accept Into the Pit
step
.goto The Storm Peaks,49.1,69.4
.use 42499
>>Use your Reins of the Warbear Matriarch inside The Pit of the Fang to ride a bear
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
.turnin 12824 >> Turn in Demolitionist Extraordinaire
.accept 12833 >> Accept Overstock
step
.goto The Storm Peaks,43.1,81.2
.use 40676
>>Use your Improved Land Mines to place mines on the ground close to each other
.complete 12833,1
.mob Garm Invader
>>Kill Garm Invader
step
.goto The Storm Peaks,40.9,85.3
.target Ricket
.turnin 12833 >> Turn in Overstock
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
#optional
.goto The Storm Peaks,75.8,63
>>Click the Granite Boulders and get them 1 at a time - The Granite Boulders look like big grey rocks on the ground around this area
.use 41505
>>Use Thorim's Charm of Earth on the Stormforged Iron Giants
>>Help the dwarves kill them
.complete 12915,2
.mob Stormforged Iron Giant
>>Kill Stormforged Iron Giant
.collect 41556,1,12922 >> Collect 1 Slag Covered Metal
.use 41556
.accept 12922 >> Accept The Refiner's Fire
step
.goto The Storm Peaks,75.4,63.5
.mob Seething Revenants
>>Kill Seething Revenants
.complete 12922,1
>>Collect Furious Spark
step
.goto The Storm Peaks,77.2,62.9
>>Click a Granite Boulder and get one
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
.mob Seething Revenant
>>Kill Seething Revenant
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
>>Click the Frozen Iron Scraps - The Smoldering Scraps look like small smoking pieces of metal on the ground around this area
.complete 12981,1
>>Collect Frozen Iron Scrap
step
.goto The Storm Peaks,72.1,49.4
>>Click the Horn Fragments - The Horn Fragments look like grey scraps on the ground around this area
.complete 12975,1
>>Collect Horn Fragment
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
.goto The Storm Peaks,64.1,65.1
>>Click Hodir's Horn - It's a huge bone war horn
.accept 12977 >> Accept Blowing Hodir's Horn
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
.goto The Storm Peaks,64.1,65.1
>>Click Hodir's Horn - It's a huge bone war horn
.turnin 12977 >> Turn in Blowing Hodir's Horn
step
.goto The Storm Peaks,63.2,63.2
.target Njormeld
.accept 12985 >> Accept Forging a Head
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
.goto The Storm Peaks,63.2,63.2
.target Njormeld
.turnin 12985 >> Turn in Forging a Head
.accept 12987 >> Accept Mounting Hodir's Helm
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
.goto The Storm Peaks,33.4,58
>>Go outside and go to 33.4,58
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
.goto The Storm Peaks,56.3,51.4
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
.accept 13047 >> Accept The Reckoning
step
.goto The Storm Peaks,35.9,31.5
.target Thorim
>>Tell him you are with him
.complete 13047,1
>>Witness the Reckoning
step
.goto The Storm Peaks,65.4,60.2
.target King Jokkum
.turnin 13047 >> Turn in The Reckoning
step
.goto The Storm Peaks,40.9,85.3
.target Ricket
.accept 12862 >> Accept When All Else Fails
step
.goto The Storm Peaks,40.9,85.3
.target Ricket
>>Tell her you are ready to head further into Storm Peaks
.goto The Storm Peaks,28.6,74.6,0.5
>>You will fly to Frosthold
step
.goto The Storm Peaks,29.5,74.3
.target Faldorf Bitterchill
.fp Frosthold, The Storm Peaks >> Get the Frosthold flight path
step
.goto The Storm Peaks,29.5,74.1
.target Archaeologist Andorin
.accept 12854 >> Accept On Brann's Trail
step
.goto The Storm Peaks,29.4,73.8
.target Lagnus
.accept 12863 >> Accept Offering Thanks
step
.goto The Storm Peaks,28.8,74.1
.target Rork Sharpchin
.turnin 12862 >> Turn in When All Else Fails
.accept 12870 >> Accept Ancient Relics
step
.goto The Storm Peaks,28.7,74.4
.home Frosthold >> Set your Hearthstone to Frosthold
step
.goto The Storm Peaks,29.2,74.9
.target Glorthal Stiffbeard
.turnin 12863 >> Turn in Offering Thanks
.accept 12864 >> Accept Missing Scouts
step
.goto The Storm Peaks,29.8,75.7
.target Fjorlin Frostbrow
.accept 12865 >> Accept Loyal Companions
step
.goto The Storm Peaks,36.4,77.3
.target the Frostborn Scout
>>Ask him if he is okay
.complete 12864,1
>>Locate the Missing Scout
step
.goto The Storm Peaks,46.5,68.3
.mob Vrykuls
>>Kill Vrykuls
.complete 12870,1
>>Get 10 Relics of Ulduar
step
.goto The Storm Peaks,44.5,60.4
>>Go outside to 44.5,60.4
.mob Ice Steppe Rhinos
>>Kill Ice Steppe Rhinos
.collect 41340,8,12865 >> Collect 8 Fresh Ice Rhino Meat
step
.goto The Storm Peaks,36.1,64.1
>>Click the Disturbed Snow - It's a pile of snow on the ground
.complete 12854,1
>>Collect Burlap-Wrapped Note
step
.goto The Storm Peaks,33.2,73.7
.use 41340
>>Use your Fresh Ice Rhino Meat on Stormcrest Eagles at the top of this mountain
.complete 12865,1
>>Feed 8 Stormcrest Eagles
step
.goto The Storm Peaks,29.5,74.1
.target Archaeologist Andorin
.turnin 12854 >> Turn in On Brann's Trail
.accept 12855 >> Accept Sniffing Out the Perpetrator
step
.goto The Storm Peaks,28.8,74.1
.target Rork Sharpchin
.turnin 12870 >> Turn in Ancient Relics
step
.goto The Storm Peaks,29.2,74.9
.target Glorthal Stiffbeard
.turnin 12864 >> Turn in Missing Scouts
.accept 12866 >> Accept Stemming the Aggressors
step
.goto The Storm Peaks,29.8,75.7
.target Fjorlin Frostbrow
.turnin 12865 >> Turn in Loyal Companions
.accept 12867 >> Accept Baby Stealers
step
.goto The Storm Peaks,33,66.8
>>Click Eagle Eggs on the ground - They look like white eggs sitting on the ground around this area, usually next to trees
.complete 12867,1
>>Collect Stormcrest Eagle Egg
.complete 12866,1
.mob Frostfeather Screecher
>>Kill Frostfeather Screecher
.complete 12866,2
.mob Frostfeather Witch
>>Kill Frostfeather Witch
step
.goto The Storm Peaks,36.4,64.1
.use 41430
>>Use the Frosthound's Collar in your bags next to this broken down tent
>>Use the abilities on your hotbar to keep the dwarves away from you
.complete 12855,1
>>Track down the thief
step
.goto The Storm Peaks,48.5,60.8
.complete 12855,2
.mob Tracker Thulin
>>Kill Tracker Thulin
.collect 40971,1,12871 >> Collect 1 Brann's Communicator
step
.use 40971
>>Use Brann's Communicator in your bags
.target Brann Bronzebeard
.turnin 12855 >> Turn in Sniffing Out the Perpetrator
.accept 12858 >> Accept Pieces to the Puzzle
step
.goto The Storm Peaks,37.6,43.5
.mob Library Guardians
>>Kill Library Guardians
.collect 41130,6,0 >> Collect 6 Inventor's Disk Fragment
.use 41130
>>Click the Inventor's Disk Fragments in your bags to combine them
.complete 12858,1
>>Collect The Inventor's Disk
step
.use 40971
>>Use Brann's Communicator in your bags
.target Brann Bronzebeard
.turnin 12858 >> Turn in Pieces to the Puzzle
.accept 12860 >> Accept Data Mining
step
.goto The Storm Peaks,38.5,44.2
.use 41179
>>Use The Inventor's Disk on Databanks
.complete 12860,1
>>Gather 7 Hidden Data
step
.use 40971
>>Use Brann's Communicator in your bags
.target Brann Bronzebeard
.turnin 12860 >> Turn in Data Mining
.accept 13415 >> Accept The Library Console
step
.goto The Storm Peaks,37.4,46.8
>>Click the Inventor's Library Console - Inside the building, all the way at the end of the hall
.turnin 13415 >> Turn in The Library Console
.accept 12872 >> Accept Norgannon's Shell
step
.use 44704
>>Click the Charged Disk in your bags
.mob Archivist Mechaton that spawns
>>Kill Archivist Mechaton that spawns
.complete 12872,1
>>Collect Norgannon's Shell
step
.use 40971
>>Use Brann's Communicator in your bags
.target Brann Bronzebeard
.turnin 12872 >> Turn in Norgannon's Shell
.accept 12871 >> Accept Aid from the Explorers' League
.accept 12885 >> Accept The Exiles of Ulduar
step
.goto The Storm Peaks,30.6,36.3
.target Breck Rockbrow
.fp Bouldercrag's Refuge, The Storm Peaks >> Get the Bouldercrag's Refuge flight path
step
.goto The Storm Peaks,31.4,38.1
>>Go inside the building to 31.4,38.1
.target Bouldercrag the Rockshaper
.turnin 12885 >> Turn in The Exiles of Ulduar
.accept 12930 >> Accept Rare Earth
step
.goto The Storm Peaks,28.7,74.4,0.5
.hs >> Hearth to Frosthold
>>Hearth to Frosthold
step
.goto The Storm Peaks,29.4,73.8
.target Lagnus
.turnin 12871 >> Turn in Aid from the Explorers' League
.accept 12873 >> Accept The Frostborn King
step
.goto The Storm Peaks,29.2,74.9
.target Glorthal Stiffbeard
.turnin 12866 >> Turn in Stemming the Aggressors
step
.goto The Storm Peaks,29.8,75.7
.target Fjorlin Frostbrow
.turnin 12867 >> Turn in Baby Stealers
step
.goto The Storm Peaks,30.31,74.8
.target Yorg Stormheart
.turnin 12873 >> Turn in The Frostborn King
.accept 12874 >> Accept Fervor of the Frostborn
step
.goto The Storm Peaks,29.8,75.7
.target Fjorlin Frostbrow
.goto The Storm Peaks,53.5,35.1,0.5
>>Tell him you are ready for your test
step
.goto The Storm Peaks,53.6,35.1
>>Click the Battered Storm Hammer - It's a big hammer on the ground next to a dead body
.collect 42624,1,12874 >> Collect 1 Battered Storm Hammer
step
.goto The Storm Peaks,53.5,37.9
.use 42624
>>Use your Battered Storm Hammer on The Iron Watcher repeatedly
>>While he is stuned, run away so the Hammer can recharge
>>When his health is low enough, he will run to the end of the bridge. Throw your hammer one last time and he will fall off
.complete 12874,1
.mob The Iron Watcher
>>Kill The Iron Watcher
step
.goto The Storm Peaks,30.31,74.8
.target Yorg Stormheart
.turnin 12874 >> Turn in Fervor of the Frostborn
.accept 12875 >> Accept An Experienced Guide
step
.goto The Storm Peaks,29.8,75.7
.target Fjorlin Frostbrow
.accept 12876 >> Accept Unwelcome Guests
step
.goto The Storm Peaks,27.0,66.9
.goto The Storm Peaks,27.0,66.9,0.2
>>The path to An Experienced Guide and Unwelcome Guests starts here
step
.goto The Storm Peaks,26.3,66.7
.mob Stormforged mobs inside this cave
>>Kill Stormforged mobs inside this cave
.complete 12876,1
.mob Stormforged Invaders
>>Kill Stormforged Invaders
.complete 12930,2
>>Collect Frostweave Cloth
step
.goto The Storm Peaks,25.2,68.5
.target Drom Frostgrip
.turnin 12875 >> Turn in An Experienced Guide
.accept 12877 >> Accept The Lonesome Watcher
step
.goto The Storm Peaks,27.1,67.3
>>Go outside to 27.1,67.3
.mob the Stormforged Monitor
>>Kill the Stormforged Monitor
.complete 12877,1
>>Collect Frostgrip's Signet Ring
step
.goto The Storm Peaks,39.6,59.8
.target Creteus
.turnin 12877 >> Turn in The Lonesome Watcher
.accept 12986 >> Accept Fate of the Titans
step
.goto The Storm Peaks,52.6,56.9
>>Fly to the top of this temple to 52.6,56.9
.use 42679
>>Use Creteus's Mobile Databank at the top of this temple
.complete 12986,2
>>Investigate the Temple of Winter
step
.goto The Storm Peaks,64.3,46.7
.use 42679
>>Use Creteus's Mobile Databank in this broken temple
.complete 12986,3
>>Investigate the Temple of Life
step
.goto The Storm Peaks,53.5,42.3
>>Fly to the top of this temple to 53.5,42.3
.use 42679
>>Use Creteus's Mobile Databank Databank at the top of this temple
.complete 12986,4
>>Investigate the Temple of Order
step
.goto The Storm Peaks,45.6,49.2
>>Fly to the top of this temple to 45.6,49.2
.use 42679
>>Use Creteus's Mobile Databank Databank at the top of this temple
.complete 12986,1
>>Investigate the Temple of Invention
step
.goto The Storm Peaks,39.6,59.8
.target Creteus
.turnin 12986 >> Turn in Fate of the Titans
.accept 12878 >> Accept The Hidden Relic
step
.goto The Storm Peaks,41.5,62.1
.goto The Storm Peaks,41.5,62.1,0.2
>>The path to The Hidden Relic starts here
step
.goto The Storm Peaks,44.5,64.5
>>Go inside the cave to 44.5,64.5
>>Click The Guardian's Charge - It's at the very lowest level of the cave
.turnin 12878 >> Turn in The Hidden Relic
.accept 12879 >> Accept Fury of the Frostborn King
step
.goto The Storm Peaks,38.2,61.7
>>Go outside the cave to 38.2,61.7
.target Creteus
.turnin 12879 >> Turn in Fury of the Frostborn King
.accept 12880 >> Accept The Master Explorer
step
.goto The Storm Peaks,39.6,56.4
.target Brann Bronzebeard
.turnin 12880 >> Turn in The Master Explorer
.accept 12973 >> Accept The Brothers Bronzebeard
step
>>Click Brann's Flying Machine next to you
.mob the dwarves that jump on the plane as you fly
>>Kill the dwarves that jump on the plane as you fly
.complete 12973,1
>>Accompany Brann Bronzebeard to Frosthold
step
.goto The Storm Peaks,30.3,74.8
.target Velog Icebellow
.turnin 12973 >> Turn in The Brothers Bronzebeard
step
.goto The Storm Peaks,29.8,75.7
.target Fjorlin Frostbrow
.turnin 12876 >> Turn in Unwelcome Guests
.accept 12869 >> Accept Pushed Too Far
step
.goto The Storm Peaks,44.6,59.8
>>Use the abilities on your hotbar to fight Stormpeak Wyrms flying in the air around this area
.complete 12869,1
.mob Stormpeak Wyrm
>>Kill Stormpeak Wyrm
step
.goto The Storm Peaks,29.8,75.7
.exitvehicle
>>Click the red arrow on your hotbar to get off the eagle
.target Fjorlin Frostbrow
.turnin 12869 >> Turn in Pushed Too Far
step
.goto The Storm Peaks,28.3,29.4
>>Click the Enchanted Earth - They look like big black spikes of rock coming out of the ground at the bottom of this cliff, near the water and all along the cliffside
.complete 12930,1
>>Collect Enchanted Earth
step
.goto The Storm Peaks,31.4,38.1
>>Go inside the building to 31.4,38.1
.target Bouldercrag the Rockshaper
.turnin 12930 >> Turn in Rare Earth
.accept 12931 >> Accept Fighting Back
.accept 12937 >> Accept Relief for the Fallen
step
.home Bouldercrag's Refuge >> Set your Hearthstone to Bouldercrag's Refuge
step
.goto The Storm Peaks,28.1,36.7
.mob Stormforged Raiders and Stormforged Reavers
>>Kill Stormforged Raiders and Stormforged Reavers
.complete 12931,1
.mob Stormforged Attacker
>>Kill Stormforged Attacker
.use 41988
>>Use your Telluric Poultice on Fallen Earthen Defenders
.complete 12937,1
>>Heal 8 Fallen Earthen Defenders
step
.goto The Storm Peaks,31.4,38.1
>>Go inside the building to 31.4,38.1
.target Bouldercrag the Rockshaper
.turnin 12931 >> Turn in Fighting Back
.turnin 12937 >> Turn in Relief for the Fallen
.accept 12957 >> Accept Slaves of the Stormforged
.accept 12964 >> Accept The Dark Ore
step
.goto The Storm Peaks,27.5,49.7
>>Go inside the mine to 27.5,49.7
.complete 12957,2
.mob Stormforged Taskmaster
>>Kill Stormforged Taskmaster
.target Captive Mechagnome
.complete 12957,1
>>Attempt to free 8 Captive Mechagnomes
>>Click Ore Carts - They look like carts with ore in them
.complete 12964,1
>>Collect Dark Ore Sample
step
.goto The Storm Peaks,31.4,38.1
>>Go outside and inside the building to 31.4,38.1
.target Bouldercrag the Rockshaper
.turnin 12957 >> Turn in Slaves of the Stormforged
.turnin 12964 >> Turn in The Dark Ore
.accept 12965 >> Accept The Gifts of Loken
step
.goto The Storm Peaks,31.3,38.2
.target Bruor Ironbane
.accept 12978 >> Accept Facing the Storm
step
.goto The Storm Peaks,24,42.6
>>Right-click Loken's Fury - It looks like a glowing ball on a pedestal inside this building
.complete 12965,1
>>Destroy Loken's Fury
step
.goto The Storm Peaks,26.2,47.7
>>Right-click Loken's Power - It looks like a glowing ball on a pedestal inside this building
.complete 12965,2
>>Destroy Loken's Power
step
.goto The Storm Peaks,24.6,48.4
>>Right-click Loken's Favor - It looks like a glowing ball on a pedestal inside this building
.complete 12965,3
>>Destroy Loken's Favor
step
.goto The Storm Peaks,25,42.9
.mob Stormforged mobs
>>Kill Stormforged mobs
.complete 12978,1
.mob Nidavelir Stormforged
>>Kill Nidavelir Stormforged
step
.goto The Storm Peaks,31.4,38.1
>>Go inside the building to 31.4,38.1
.target Bouldercrag the Rockshaper
.turnin 12965 >> Turn in The Gifts of Loken
step
.goto The Storm Peaks,31.3,38.2
.target Bruor Ironbane
.turnin 12978 >> Turn in Facing the Storm
step
.xp 80
step
+Congratulations, you are now level 80!
step
.fly Area 52, Netherstorm >> Fly to Area 52
>>Fly to Area 52
]]);
