# Custom guide authoring

Use the [website Guide Editor](https://github.com/PottedSalame/RestedXP_RXPGuides-WotLK_3.3.5a/tree/website#local-preview), or edit plain source. This reference covers the editor's basic instructions accepted by **Website guide source** import—not every directive supported by trusted bundled guides.

## Working template

Save this as plain text, even when the contribution filename ends in `.lua`:

```text
#wotlk
#ac335
#version 1
#group RXPGuides Custom Guides
#name Durotar Practice Walk
-- Server-Realm: YourServer-YourRealm
-- Purpose: Experience
-- Zone: Durotar
-- Description: Short walking route for testing.
-- Requirements: Access to Durotar.

step
    .goto Durotar,44.31,68.20,15
step
    .goto Durotar,45.76,68.27,15
step
    +Route complete. Check this instruction when finished.
```

Use `step`, **not** `.step`. Instructions begin with a dot; `>>` begins display text, not an executable directive.

## Guide properties

| Field | Source | Meaning |
|---|---|---|
| Name | `#name` | Distinct guide name |
| Group | `#group RXPGuides Custom Guides` | Import-compatible custom namespace |
| Subgroup | `#subgroup` | Optional browser grouping |
| Version | `#version 1` | Revision label |
| Server / realm | `-- Server-Realm:` | Intended server and realm |
| Purpose | `-- Purpose:` | Contribution category |
| Zone | `-- Zone:` | Main route location |
| Description | `-- Description:` | Short summary |
| Requirements | `-- Requirements:` | Recommended level, faction, class, profession or supplies |

Keep `#wotlk` and `#ac335` in new guides. Use one unconditional name/group/subgroup before the steps. A subgroup difference alone does not make two identically named guides independent; use distinct names.

Purpose must be **Experience, Gold, Professions, Dungeons, Reputation, Events, PvP or Achievement**. The contribution path is:

```text
CustomGuides/<Server-Realm>/<Purpose>/<Zone>/<GuideName>.lua
```

Comments are descriptive only: “Mining 1+” does not check a learned skill, and a server name does not restrict loading. Do not substitute unsupported `#min`, `#max`, `#race`, `#class`, `#faction` or `#profession` headers.

## Instructions

| Syntax | Behavior |
|---|---|
| `.goto Durotar,44.31,68.20,15` | Travel objective; completes within 15 yards |
| `.goto Durotar,44.31,68.20` | Navigation marker only; pair with another objective |
| `.accept 4641 >>Accept Your Place In The World` | Tracks quest acceptance; automation obeys user settings |
| `.complete 788,1 >>Kill Mottled Boars` | Tracks objective 1 of quest 788 |
| `.turnin 4641 >>Turn in Your Place In The World` | Tracks the quest's turn-in |
| `.collect 2770,10 >>Collect Copper Ore` | Tracks the required item quantity |
| `.use 6948` | Item-button helper, not automatic use or completion detection |
| `.target 10176` | NPC targeting helper, not proof of interaction |
| `.mob 3098` | Creature targeting helper, not a kill counter |
| `>>Read this note.` | Display-only instruction |
| `+Check this when finished.` | Manually checked objective |

Coordinates require a zone/map token and percentages from 0 to 100. For a walking route, use a separate step per destination with a positive arrival radius. A radius-free waypoint alone does not hold the step open.

The editor defaults new travel objectives to 15 yards. Importing an existing waypoint does not change its behavior. Notes, target/mob helpers and item-use buttons also need a completion objective if the step should wait.

`.complete` requires the **client quest-log objective index**; do not infer it from database slot order. Optional third arguments set a partial amount. `.turnin` may take a reward-choice index as its second argument. Verify both in-game.

## Conditions and advanced source

Use supported conditions after `<<`, for example:

```text
step << Hunter
    +Check that your pet is ready.
```

For a Horde-only guide, place `<< ac335 Horde` before the headers. Conditions are evaluated by the addon, not simulated by the website. Use actual runtime tokens; prose requirements are not substitutes.

The basic importer accepts only the eight dot-directives listed above. Macros, includes, executable Lua and database expressions are rejected. Other advanced source needs separate compatibility review; opening it in the editor does not make it importable.

Raw source and literal `RXPGuides.RegisterGuide([[...]])` wrappers are supported. The editor generates companion files when needed; do not paste executable setup code into the import box.

## Verify and share

1. Use **Check source**; review errors and warnings. Look up IDs using the editor's Wowhead WotLK lookup; check availability on the intended server.
2. Export guide text. Follow the [README import steps](README.md#import-into-the-addon), or install the exported companion files as instructed by the editor.
3. Test on a disposable character: travel stops, quest IDs, counters, rewards, conditions and reload restoration. Keep your source and SavedVariables backups.
4. Submit to **custom-guides** at the suggested path, with test results and limitations.

Keep operational names in English. Saving metadata does not add gameplay restrictions. Editing names or step layout can affect saved-progress restoration; do not overwrite an unrelated guide's identity.

Older files using `#group CustomGuides`, `.step`, quoted narrative lines or `>> .goto` need manual correction. The website preserves imported text rather than silently converting it.
