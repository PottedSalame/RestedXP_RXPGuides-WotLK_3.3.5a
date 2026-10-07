# RXPGuides Custom Guide DSL Reference

This document describes how to write custom guide files for RXPGuides. Each guide is a `.lua` file containing guide headers and steps with directives.

## Quick Start Template

```lua
#name My Custom Guide
#group CustomGuides
#version 1.0.0
#min 10
#max 30
#race Orc,Troll
#class Warrior
#profession Mining

Brief description of what this guide does.

.step First Step
>> .goto 51.5,38.4
'Go to the starting location'

.step
>> .accept 784

.step Kill Boars
>> .target 113 'Mottled Boar'
>> .collect 769,6
'Kill and collect from boars until you have 6 Chunks of Boar Meat'

.step
>> .turnin 784
'Return to the quest giver'
```

## Headers

Headers are placed at the top of the file, before any steps. Each starts with `#`.

| Header | Required | Description |
|--------|----------|-------------|
| `#name` | **Yes** | Guide name displayed in the hub |
| `#group` | **Yes** | Must be `CustomGuides` to appear under the custom section |
| `#version` | **Yes** | Semantic version e.g. `1.0.0` |
| `#min` | Recommended | Minimum level required |
| `#max` | Optional | Maximum level cap |
| `#race` | Optional | Comma-separated races e.g. `Orc,Troll` |
| `#class` | Optional | Class restriction e.g. `Warrior` |
| `#profession` | Optional | Required profession e.g. `Mining` |
| `#faction` | Optional | `Alliance` or `Horde` |

## Steps

Each step starts with `.step` on its own line. An optional label can follow:

```lua
.step My Step Name
```

Descriptive text for the player can be placed as a quoted string:

```lua
'Kill boars until you have 6 Chunks of Boar Meat'
```

## Directives

Directives start with `>>` and tell the addon what action to perform or condition to check.

### Navigation

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.goto` | `.goto X, Y` | Navigate to map coordinates |
| `.waypoint` | `.waypoint X, Y` | Set a waypoint pin |
| `.questgoto` | `.questgoto X, Y` | Quest-specific navigation step |
| `.questwaypoint` | `.questwaypoint X, Y` | Quest-specific waypoint |
| `.pin` | `.pin X, Y` | Place a map pin |
| `.line` | `.line X1,Y1,X2,Y2` | Draw a line on the map |
| `.loop` | `.loop` | Loop back to a previous step |
| `.zone` | `.zone ZoneName` | Require being in a specific zone |
| `.zoneskip` | `.zoneskip ZoneName` | Skip if in a specific zone |
| `.subzone` | `.subzone SubzoneName` | Require being in a subzone |
| `.subzoneskip` | `.subzoneskip SubzoneName` | Skip if in a subzone |
| `.target` | `.target NPC_ID` | Target a specific mob or NPC, optional label in quotes |
| `.mob` | `.mob NPC_ID` | Track and mark a specific mob |
| `.unitscan` | `.unitscan NPC_ID` | Scan for nearby units |
| `.rare` | `.rare NPC_ID` | Scan for a rare mob |
| `.treasure` | `.treasure` | Scan for nearby treasure |
| `.openmap` | `.openmap` | Open the world map |

### Quest

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.accept` | `.accept QUEST_ID` | Accept a quest |
| `.turnin` | `.turnin QUEST_ID` | Turn in a quest |
| `.complete` | `.complete QUEST_ID` | Mark a quest as complete |
| `.daily` | `.daily QUEST_ID` | Accept a daily quest |
| `.dailyturnin` | `.dailyturnin QUEST_ID` | Turn in a daily quest |
| `.abandon` | `.abandon QUEST_ID` | Abandon a quest |
| `.disablequestautomation` | `.disablequestautomation` | Disable auto-accept/turn-in |

### Quest Conditions

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.isOnQuest` | `.isOnQuest QUEST_ID` | Check if on this quest |
| `.isNotOnQuest` | `.isNotOnQuest QUEST_ID` | Check if not on this quest |
| `.isQuestComplete` | `.isQuestComplete QUEST_ID` | Check if quest completed |
| `.isQuestNotComplete` | `.isQuestNotComplete QUEST_ID` | Check if quest not completed |
| `.isQuestTurnedIn` | `.isQuestTurnedIn QUEST_ID` | Check if quest turned in |
| `.isQuestAvailable` | `.isQuestAvailable QUEST_ID` | Check if quest is available |
| `.questcount` | `.questcount N` | Require N quests in log |
| `.hideifcomplete` | `.hideifcomplete QUEST_ID` | Hide step if quest completed |
| `.skipOnQuest` | `.skipOnQuest QUEST_ID` | Skip step if on quest |
| `.questitemcount` | `.questitemcount ITEM_ID,N` | Require N of a quest item |

### Travel

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.fly` | `.fly` | Take a flight path |
| `.fp` | `.fp LocationName` | Take flight to location |
| `.home` | `.home` | Set hearthstone location |
| `.hs` | `.hs` | Use hearthstone |
| `.hsbatching` | `.hsbatching` | Use hearthstone with macro batching |
| `.hastyhearth` | `.hastyhearth` | Quick hearthstone macro |
| `.deathskip` | `.deathskip` | Die and respawn to skip travel |
| `.bindlocation` | `.bindlocation` | Bind at an innkeeper |
| `.flyable` | `.flyable` | Require flying skill |
| `.noflyable` | `.noflyable` | Require no flying |
| `.vehicle` | `.vehicle` | Enter a vehicle |
| `.exitvehicle` | `.exitvehicle` | Exit a vehicle |

### Inventory

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.collect` | `.collect ITEM_ID,N` | Collect N of an item |
| `.addquestitem` | `.addquestitem ITEM_ID` | Add a quest item |
| `.itemcount` | `.itemcount ITEM_ID,N` | Require N of an item |
| `.equip` | `.equip ITEM_ID` | Equip an item |
| `.use` | `.use ITEM_ID` | Use an item |
| `.destroy` | `.destroy ITEM_ID` | Destroy an item |
| `.buy` | `.buy ITEM_ID,N` | Buy N of an item from a vendor |
| `.buyAll` | `.buyAll ITEM_ID` | Buy all of an item |
| `.buyUntilBroke` | `.buyUntilBroke` | Buy until out of gold |
| `.vendor` | `.vendor ITEM_ID` | Sell item to vendor |
| `.openitem` | `.openitem ITEM_ID` | Open a container item |
| `.bankdeposit` | `.bankdeposit ITEM_ID` | Deposit to bank |
| `.bankwithdraw` | `.bankwithdraw ITEM_ID,N` | Withdraw from bank |
| `.scrap` | `.scrap ITEM_ID` | Scrap/delete an item |
| `.totalbagslots` | `.totalbagslots N` | Require N total bag slots |
| `.bronzetube` | `.bronzetube` | Use a bronze tube item |

### Character

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.xp` | `.xp` | Show XP progress |
| `.skill` | `.skill SkillName,Level` | Require a skill level |
| `.train` | `.train SpellID` | Train a spell/ability |
| `.trainer` | `.trainer` | Visit a class trainer |
| `.spellmissing` | `.spellmissing SpellID` | Check if a spell is not learned |
| `.tradeskill` | `.tradeskill ProfessionName` | Open tradeskill window |
| `.reputation` | `.reputation FactionName,Level` | Require reputation level |
| `.level` | `.level` | Check player level |
| `.maxlevel` | `.maxlevel` | Check if at max level |
| `.istrained` | `.istrained SpellID` | Check if a spell is trained |
| `.tame` | `.tame NPC_ID` | Tame a hunter pet |
| `.stable` | `.stable` | Visit a stable master |
| `.petfamily` | `.petfamily FamilyName` | Require a specific pet family |
| `.mountcount` | `.mountcount N` | Require N mounts collected |
| `.showtotalxp` | `.showtotalxp` | Display total XP earned |

### Group & Dungeon

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.group` | `.group` | Require being in a group |
| `.solo` | `.solo` | Require being solo |
| `.dungeon` | `.dungeon DungeonName` | Require being in a dungeon |

### Gossip

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.gossip` | `.gossip` | Interact with gossip |
| `.gossipoption` | `.gossipoption N` | Select gossip option N |
| `.skipgossip` | `.skipgossip` | Skip gossip interaction |

### Casting & Items

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.cast` | `.cast SpellID` | Cast a spell |
| `.usespell` | `.usespell SpellID` | Use a spell/item |
| `.macro` | `.macro MacroText` | Run a macro |
| `.link` | `.link ItemID` | Link an item in chat |

### Events & World

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.dmf` | `.dmf` | Darkmoon Faire requirements |
| `.holiday` | `.holiday` | Holiday event requirements |
| `.isInScenario` | `.isInScenario` | Check if in a scenario |
| `.enterScenario` | `.enterScenario` | Enter a scenario |
| `.countdown` | `.countdown N` | Start a countdown timer |
| `.timer` | `.timer N` | Set a timer for N seconds |
| `.cooldown` | `.cooldown SpellID` | Wait for cooldown |
| `.logout` | `.logout` | Trigger a logout |
| `.rescue` | `.rescue` | Rescue a player |
| `.ironchain` | `.ironchain` | Iron chain item event |
| `.bombdispenser` | `.bombdispenser` | Bomb dispenser event |
| `.niffelen` | `.niffelen` | Niffelen event |
| `.emote` | `.emote EmoteName` | Perform an emote |
| `.clicknext` | `.clicknext` | Click the next available object |

### PvP

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.pvp` | `.pvp` | PvP flag check |
| `.pve` | `.pve` | PvE flag check |

### Talents & Spec

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.spec` | `.spec SpecName` | Require a talent spec |
| `.dualspec` | `.dualspec` | Require dual spec |

### Collection

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.achievement` | `.achievement ACHIEVEMENT_ID` | Track an achievement |
| `.achievementComplete` | `.achievementComplete ACHIEVEMENT_ID` | Check if achievement is complete |
| `.achievementIncomplete` | `.achievementIncomplete ACHIEVEMENT_ID` | Check if achievement is incomplete |
| `.achievementskip` | `.achievementskip ACHIEVEMENT_ID` | Skip if achievement complete |
| `.collectmount` | `.collectmount MOUNT_ID` | Collect a mount |
| `.collectpet` | `.collectpet PET_ID` | Collect a pet |
| `.collecttoy` | `.collecttoy TOY_ID` | Collect a toy |
| `.collectcurrency` | `.collectcurrency CURRENCY_ID,N` | Collect N currency |

### Miscellaneous

| Directive | Syntax | Description |
|-----------|--------|-------------|
| `.next` | `.next` | Force next step |
| `.choose` | `.choose` | Player choice point |
| `.skipto` | `.skipto STEP_INDEX` | Skip to a specific step |
| `.disablecheckbox` | `.disablecheckbox` | Disable the step checkbox |
| `.addtoquestdb` | `.addtoquestdb QUEST_ID` | Add a quest to the internal DB |
| `.mirrorquest` | `.mirrorquest QUEST_ID` | Mirror a quest ID |
| `.convertquest` | `.convertquest QUEST_ID` | Convert a quest ID |
| `.blastedLands` | `.blastedLands` | Blasted Lands zone check |
| `.vale` | `.vale` | Vale of Eternal Blossoms check |
| `.landfall` | `.landfall` | Landfall event check |
| `.klaxxi` | `.klaxxi` | Klaxxi faction check |
| `.celestial` | `.celestial` | Celestial event check |
| `.beta` | `.beta` | Beta event check |
| `.chromietime` | `.chromietime` | Chromie Time check |
| `.skyriding` | `.skyriding` | Skyriding check |
| `.noskyriding` | `.noskyriding` | No skyriding check |
| `.aura` | `.aura SpellID` | Check for an aura/buff |
| `.itemStat` | `.itemStat ITEM_ID Stat,N` | Check item stats |
| `.money` | `.money Amount` | Require gold amount |
| `.wpbuff` | `.wpbuff SpellID` | Waypoint buff check |
| `.wptimer` | `.wptimer N` | Waypoint timer |
| `.profession` | `.profession Name` | Profession check |
| `.engrave` | `.engrave` | Engraving check |
| `.maxskill` | `.maxskill SkillName` | Check max skill level |
| `.wpradius` | `.wpradius N` | Waypoint radius |
| `.show25quests` | `.show25quests` | Show 25 quest log entries |
| `.neutralzonefinished` | `.neutralzonefinished` | Neutral zone completion |

## Finding IDs

All quest, item, NPC, and spell IDs are numeric values. Use these resources:

- **Quests**: [Wowhead Classic Quests](https://www.wowhead.com/classic/quests) — the ID is in the URL
- **Items**: [Wowhead Classic Items](https://www.wowhead.com/classic/items)
- **NPCs**: [Wowhead Classic NPCs](https://www.wowhead.com/classic/npcs)
- **Spells**: [Wowhead Classic Spells](https://www.wowhead.com/classic/spells)
- **Achievements**: [Wowhead WotLK Achievements](https://www.wowhead.com/wotlk/achievements)

## Testing

1. Copy your guide `.lua` file content
2. In-game: `/rxp import`
3. Paste into the import box
4. Verify the guide appears under **CustomGuides** in your Guide Hub
5. Walk through the steps to validate quest/coordinate accuracy

## Tips

- Keep step descriptions concise (one line)
- Use quoted strings `'...'` for player-facing text, comments `-- ...` for author notes
- Test coordinates before submitting — use an in-game coordinate addon
- Quest IDs are realm-specific. Verify on the target server/realm
- Use `.goto` for navigation, `.target` with optional label for mobs", "filePath": "E:\\PersonalStuff\\GamesUtils\\Games\\World of Warcraft Azerothcore\\Interface\\AddOns\\RXPGuides\\CustomGuides\\GUIDE_AUTHORING.md"}