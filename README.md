# RXPGuides Custom Guides Repository

Community-contributed custom guide routes for RXPGuides on WoW 3.3.5a clients.

## What is this?

This branch hosts user-created guides that extend RXPGuides with custom routes for farming, leveling, professions, dungeons, and more. Guides here are **not** included in the main addon download — you import them individually via the in-game `/rxp import` command.

## How to Import a Guide

1. Browse the folders to find a guide you want
2. Open the `.lua` file and **copy its entire content**
3. In-game, type `/rxp import`
4. **Paste** the guide text into the import box
5. The guide appears under the **CustomGuides** category in your Guide Hub

## Directory Structure

Guides are organized by server realm, activity type, zone, and guide name:

```
CustomGuides/
  <Server-Realm>/         e.g. Warmane-Icecrown, AzerothCore-WoWCircle
    <Type>/               e.g. Experience, Gold, Professions, Dungeons, Reputation, Events, PvP, Achievement
      <Zone>/             e.g. Durotar, Elwynn Forest, Tanaris
        <GuideName>.lua   e.g. Durotar Copper Mining Rotation.lua
```

### Valid Types

| Type | Use For |
|------|---------|
| `Experience` | Leveling routes, XP grinding spots |
| `Gold` | Gold farming, material gathering |
| `Professions` | Mining, Herbalism, Skinning, Fishing routes |
| `Dungeons` | Dungeon guide routes, boss strategies |
| `Reputation` | Reputation grinding guides |
| `Events` | Holiday events, world events |
| `PvP` | Battlegrounds, world PvP routes |
| `Achievement` | Achievement hunting guides |

## How to Contribute a Guide

1. **Fork** this repository
2. Create your guide `.lua` file following the [GUIDE_AUTHORING.md](GUIDE_AUTHORING.md) DSL specification
3. Place it in the correct directory: `CustomGuides/<Server-Realm>/<Type>/<Zone>/<GuideName>.lua`
4. Open a **Pull Request** targeting the `custom-guides` branch
5. A maintainer will review and merge

### PR Checklist

- Guide uses `#group CustomGuides` header
- Guide includes a brief description (first few lines)
- File placed in the correct directory structure
- All quest, item, NPC IDs are verified on Wowhead Classic
- Guide tested in-game and imports correctly via `/rxp import`

## Requirements

- RXPGuides v4.8.25-335 or newer installed
- WoW 3.3.5a (Wrath of the Lich King) client