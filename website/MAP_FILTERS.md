# Map filters

The legend controls roles. **Calendar events** controls individual festivals,
their preparation stages, and fishing events. Calendar events start hidden;
**Other world events** start visible. Choices last for this page session only.
These are snapshot previews, not today's calendar or live server availability.
The role and event filters apply together to map markers, cluster counts,
the visible-location list and quest actions. They never change authored waypoints.

## Exclusions

The extractor removes only:

- Creatures with AzerothCore's `CREATURE_FLAG_EXTRA_TRIGGER` (`0x80`). These
  are non-selectable server helpers, not ordinary critters. See
  `src/server/game/Entities/Creature/CreatureData.h` and `Creature.cpp` in the
  source revision recorded in the overlay manifest.
- Explicit placeholder/unused template names.
- The reviewed objects `2558: Test` and `3523: TEST Circle of Flame`.

It does not infer unused content from absent quests, rarity, an expired event,
or the words “Bunny”, “Dummy” or “Test Subject”. Critters, usable training
dummies, seasonal NPCs and objects remain. The overlay manifest records every
excluded template, reason and removed spawn count; the server files are untouched.

## Event data

The read-only generator retains signed `game_event_creature` and
`game_event_gameobject` links. Positive links enable a spawn when any linked
event is selected; negative links suppress it during that event. Nested
event-controlled pools retain their gates, so seasonal objects such as
Noblegarden eggs are filtered too. Pooled positions are still possible spawn
locations, not a claim that all pool members appear simultaneously.

`game_event_creature_quest`, `game_event_gameobject_quest` and
`game_event_npcflag` add event-dependent quest-starter/service roles without
removing permanent NPCs or their ordinary quests. Existing turn-in relations
are preserved; they are not assumed to disappear when an event ends.

Zoomed-out summaries retain role/event combinations, so filtering does not
count a multi-role spawn twice or borrow an icon from a disabled event.
Map filtering cannot model scripted summons, live phases, event dependencies
or server overrides. The manifest identifies the offline base SQL snapshot.

Regenerate overlays into a new directory using `website/tools/map_overlays.py`
with explicit `--acore-source` and `--output` arguments and `RXP_ADDON_ROOT`
pointing to the addon checkout for its SQL reader. Never regenerate terrain
just to update these filters. Run `test_overlays.py`, the browser tests and
`test_maps.py --assets website/map-assets-local` before publishing the output.
