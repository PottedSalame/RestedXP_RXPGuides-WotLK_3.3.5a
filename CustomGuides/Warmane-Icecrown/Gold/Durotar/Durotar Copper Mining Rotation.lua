#name Durotar Copper Mining Rotation
#group CustomGuides
#version 1.0.0
#min 1
#max 60
#race Orc,Troll
#profession Mining

This is a copper mining rotation in Durotar for Horde characters. 
Requires Mining skill 1+.

.step
>> .goto 51.5,38.4
>> .skill Mining,1
'Collect your mining pick if needed'

.step Razor Hill Mine Entrance
>> .goto 52.2,40.1
'Talk to the guard at the entrance if needed'

.step Inside Mine - First Nodes
>> .goto 52.5,40.8
>> .target 3288 'Mine Copper Vein'
>> .collect 2770,10
'Mine all copper veins inside the cave'

.step Exit Mine - North Wall Nodes
>> .goto 52.8,39.5
>> .target 3288 'Mine Copper Vein'
'Check the northern cliff wall for surface copper deposits'

.step South Cliff Nodes
>> .goto 50.9,40.2
'Mine copper deposits along the southern cliffs'

.step East Ridge Nodes
>> .goto 54.1,40.5
'Check the eastern ridgeline for additional copper'

.step Return to Razor Hill
>> .goto 52.0,43.5
'Sell your copper ore at the inn or auction house'

.step Repeat Route
>> .goto 51.5,38.4
'Repeat the rotation as desired'