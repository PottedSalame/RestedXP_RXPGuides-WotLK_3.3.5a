# RestedXP Guides — WotLK 3.3.5a Backport

Step-by-step leveling and quest guides for **World of Warcraft 3.3.5a (build 12340)**, with navigation, gear advice, and optional speedrunning tools.

This community backport is primarily tested on **AzerothCore** and runs standalone—no other addons are required. It is not the current official RestedXP release or an addon for modern Classic/Retail.

[**Download the latest release**](https://github.com/PottedSalame/RestedXP_RXPGuides-WotLK_3.3.5a/releases/latest)

## Features

- Alliance and Horde leveling routes through level 80, plus dungeon, attunement, reputation, daily, and farming guides.
- Waypoint arrows, map routes, Active Targets, and configurable quest automation.
- Equipment comparisons, junk management, repairs, talent guidance, and class supplies.
- XP estimates, leveling reports, personal-best archives, and optional speedrunning tools.
- Per-character progress, customizable windows, and optional translated guides.

Use the **Validated** routes for normal play. Separate **Original** groups preserve upstream routes for comparison. Some content depends on your character or server.

## Quick Install

1. Close World of Warcraft and open the [latest release](https://github.com/PottedSalame/RestedXP_RXPGuides-WotLK_3.3.5a/releases/latest).
2. Under **Assets**, download `RXPGuides-<version>.zip`. Use this packaged asset, **not** GitHub's automatic **Source code** download.
3. For translated guides, also download the matching language pack from the same release (see below).
4. Extract the ZIP files into `Interface\AddOns\` in your WoW installation.
5. Start the client and enable **RestedXP Guides** in the character-selection **AddOns** menu. Enable **Load out of date AddOns** if needed.

The core addon must be at this exact path, without an extra enclosing folder:

```text
Interface\AddOns\RXPGuides\RXPGuides.toc
```

**Updating:** while the client is closed, replace the old addon folder with the new release instead of merging files. Replace any language packs too. Settings and progress live separately under `WTF`; keep that folder, and back it up before updating if desired.

### Optional language packs

English clients need only the core ZIP. For another supported language, download `RXPGuides_Locale_<locale>-<version>.zip` using the code below:

| Language | Locale code |
| --- | --- |
| German | `deDE` |
| Spanish (Spain) | `esES` |
| French | `frFR` |
| Russian | `ruRU` |
| Korean | `koKR` |
| Simplified Chinese | `zhCN` |
| Traditional Chinese | `zhTW` |

Extract the language pack **beside** the core addon, not inside it. For example:

```text
Interface\AddOns\RXPGuides\RXPGuides.toc
Interface\AddOns\RXPGuides_Locale_zhCN\RXPGuides_Locale_zhCN.toc
```

Enable the companion addon; RXPGuides loads the pack matching your client. Choose **Translated** or **Original English** in the guide menu or Look and Feel settings. `[MT]` marks machine-assisted translations; `[EN]` marks English fallback text. Language selection does not change guide progress.

## Getting Started

A fresh character starts with an empty guide window. Use `/rxp guides` to choose a starting guide; your selection and progress are then saved for that character.

- `/rxp` opens settings; `/rxp help` lists commands.
- Right-click the minimap icon or click the guide's cog to open its menu.
- Open optional tools from **Feature Tools** and configure them in the addon settings.
- `/rxp browse` pauses or resumes automatic step progression for browsing.
- Assign targeting and Active Item shortcuts in the game's **Key Bindings** menu.

If you use Questie alongside RXPGuides quest automation, disable Questie's auto-accept and auto-turn-in options.

## Troubleshooting and Feedback

- **Addon missing:** check the folder path above and that the addon is enabled for your character.
- **Translations missing:** check that the matching language pack is enabled, sits beside the core folder, and comes from the same release.
- **Guide stuck:** check Browse Mode, then use `/rxp diagnose` to inspect the step. Custom server quests or scripted events may require manual interaction.

Report problems in the [Issues tab](https://github.com/PottedSalame/RestedXP_RXPGuides-WotLK_3.3.5a/issues), using **`bug`** for errors or **`enhancement`** for feature suggestions. Search existing issues first.

For a bug report, include your addon version, client language, server core, character race/class/level, guide name and step, and how to reproduce it. Add the complete Lua error from BugGrabber/BugSack if available, and note whether it happens with other addons disabled. Remove personal information from screenshots and logs.

## More Information

- [Feature details](FEATURES_335.md)
- [Localization and translation contributions](LOCALIZATION.md)
- Development references: [load order](RXPGuides.toc) and [validation checks](.github/workflows/validation.yml)

## Credits and License

Thanks to **RestedXP** and its contributors, **AzerothCore**, the **Zygor Guides Viewer** contributors and [Zygor Guides Remaster](https://github.com/ErebusAres/ZygorGuidesRemaster-3.3.5a_WOTLK) for converted WotLK route material, the bundled library authors, and everyone testing and improving this backport.

See [LICENSE](LICENSE) for the top-level license. Bundled libraries, assets, upstream guides, and converted content retain their own licenses and attribution notices.
