# RestedXP Guides — WotLK 3.3.5a

A standalone, community-maintained backport of **RestedXP Guides** for **World of Warcraft: Wrath of the Lich King 3.3.5a (build 12340)**.

Follow step-by-step Alliance and Horde leveling guides through level 80, with navigation, quest assistance and optional tools. Primarily developed and tested on **AzerothCore**; other WotLK servers may behave differently. This is not the official current RestedXP addon and does not require Questie, ElvUI, WeakAuras or other addons.

[![Download](https://img.shields.io/badge/Download-Latest_Release-2ea043?style=for-the-badge&labelColor=555555)](https://github.com/PottedSalame/RestedXP_RXPGuides-WotLK_3.3.5a/releases/latest)
[![Install](https://img.shields.io/badge/Install-Quickly-8250df?style=for-the-badge&labelColor=555555)](#quick-install-and-updates)

## Main features

- **Leveling guides:** Classic, TBC and WotLK progression, including Death Knight and boosted-character entry routes.
- **More activities:** dungeon quests, reputation, attunements, endgame chains, dailies, gathering and farming guides.
- **Navigation:** waypoint arrows, map pins, route lines and flight-path guidance.
- **Quest assistance:** configurable auto-accept, turn-in and reward handling, plus guide-related target and item buttons.
- **Character support:** talent guidance, equipment recommendations, quest-reward comparisons, junk management and vendor repairs.
- **Optional tools:** XP estimates, Attack Timer, leveling splits, Hunter assistance, speedrunning tools and more.
- **Personalization:** themes, fonts, window sizing, optional translations and separate guide progress for each character.

Enable only the extras you want in **Settings → Feature Tools**. Each tool's page explains its purpose and controls. See [the feature reference](FEATURES_335.md) for more tools and commands.

## Quick install and updates

1. Close World of Warcraft and open the [latest release](https://github.com/PottedSalame/RestedXP_RXPGuides-WotLK_3.3.5a/releases/latest).
2. Under **Assets**, download `RXPGuides-<version>.zip`. For translations, also download the matching language pack from that same release.
3. When updating, back up your `WTF` folder, then remove the old `RXPGuides` addon folder and any installed `RXPGuides_Locale_*` folders you are replacing. **Do not delete `WTF`: it contains your settings and character progress.**
4. Extract the ZIPs into `Interface\AddOns\`. Do not merge old and new addon files or introduce an extra enclosing folder.
5. Enable **RestedXP Guides** and your optional language pack on the character-selection **AddOns** screen. Enable **Load out of date AddOns** if needed.

Check that this exact path exists:

```text
Interface\AddOns\RXPGuides\RXPGuides.toc
```

> Download the packaged asset, **not** GitHub's automatic **Source code (zip)** or **Source code (tar.gz)** download.

### Optional language packs

English needs only the core addon. Other clients can install `RXPGuides_Locale_<locale>-<version>.zip`:

**German** `deDE` · **Spanish (Spain)** `esES` · **French** `frFR` · **Russian** `ruRU` · **Korean** `koKR` · **Simplified Chinese** `zhCN` · **Traditional Chinese** `zhTW`.

For example, the German pack belongs in `Interface\AddOns\RXPGuides_Locale_deDE\`, beside the core addon, not inside it. Update both together. Missing translations fall back to English; `[EN]` marks fallback text and `[MT]` marks machine-translated text. Translation affects display, not guide progress or quest actions.

## Getting started

1. Log in and choose a starting guide using the **guide-window cog** or **right-click minimap menu**. A fresh character intentionally begins with no guide selected.
2. Use `/rxp guides` to search guides, manage favorites and return to recent chapters. Your selection and progress are saved separately for each character.
3. Open `/rxp` to adjust settings, including quest automation, appearance and optional tools.

Left-clicking the minimap icon shows or hides enabled addon frames. The game's **Key Bindings** menu includes targeting, guide-item and other addon actions.

Useful commands:

- `/rxp` — settings.
- `/rxp guides` — searchable Guide Hub.
- `/rxp show` or `/rxp hide` — show or hide enabled frames.
- `/rxp browse` — pause or resume automatic progression while reviewing steps.
- `/rxp help` — command help.

### Choosing a guide collection

- **Validated & Fixed Guides:** routes maintained for this backport, including local quest-flow and travel corrections.
- **Original Upstream Guides:** alternative routes retaining upstream itineraries. These are separate from the locally curated routes, not automatically faster for every character.

Availability depends on faction, race, class, level and route conditions. **Show unused guides** can reveal filtered entries. Switching collections does not transfer progress between differently identified guides.

### Experimental Hardcore guides

Three optional level-1–60 families appear alongside the regular guides:

| Family | Guide collection | Routing |
| --- | --- | --- |
| **Curated Experimental** | Validated & Fixed Guides | All ten races; native Kalimdor progression for Orcs, Trolls and Tauren. Finishes in Azeroth. |
| **Upstream Classic** | Original Upstream Guides | Original eight races; Classic Survival itineraries adapted for 3.3.5. Finishes in Azeroth. |
| **Upstream TBC** | Original Upstream Guides | All ten races; TBC Survival itineraries adapted for 3.3.5, including Horde Eversong/Ghostlands transfers and Hellfire through level 60. |

Selecting a Hardcore guide requests confirmation to enable Hardcore mode. Families keep independent progress. Choose a non-Hardcore guide before disabling the mode while a Hardcore-only guide is active.

**These are experimental deathless-oriented routes, not enforced server rules or a guarantee of survival.** Later chapters have not all received complete gameplay testing. The normal Death Knight starter remains separate.

## Compatibility and troubleshooting

- **Using Questie?** Keep Questie's auto-accept and auto-turn-in disabled when RXPGuides quest automation is enabled. Questie tracking can remain on; avoid running both automation systems together.
- **Addon or translations missing?** Check the folder paths, character-selection AddOns list and matching core/language-pack versions.
- **Guide not advancing?** Check whether Browse Mode is active and whether the quest objective is actually complete. Report the guide and step if it remains stuck; do not skip required work just to clear the instruction.
- **Some actions remain manual.** Targeting and item buttons require player input. Flights, reward choices and scripted events may need manual interaction when the addon cannot safely determine the next action.
- **Targets or item details appear late?** Passive target discovery relies on visible nameplates, your target and mouseover. Item information can also take a moment to load; manual useful/junk choices take priority.
- **Server-specific quests:** custom servers can change requirements or remove content. Legacy Onyxia attunement needs Individual Progression or equivalent quest restoration; follow the guide's opening warning.

## Custom guides and support

In the library, choose **Type → Custom guides** to find your routes. Select an imported guide and **Delete import** to remove its saved source after confirmation; switch away first if it is active. Checkpoints are retained. Companion-addon files must be removed separately with the game closed.

Additional community routes live on the [custom-guides branch](https://github.com/PottedSalame/RestedXP_RXPGuides-WotLK_3.3.5a/tree/custom-guides) and are not bundled with the main download. Website-created guides can be pasted into `/rxp import` using **Website guide source**: confirm saving, reload when ready, then select the guide in the library. Use a distinct name under `RXPGuides Custom Guides`. Basic editor instructions are supported; executable Lua, macros and includes are rejected. Existing encoded imports have a separate format choice. Authors can also use the [custom-guide contribution instructions](https://github.com/PottedSalame/RestedXP_RXPGuides-WotLK_3.3.5a/blob/custom-guides/CustomGuides/README.md).

Report bugs or suggest features through [GitHub Issues](https://github.com/PottedSalame/RestedXP_RXPGuides-WotLK_3.3.5a/issues). For bugs, include:

- Addon version, server/core and character race, class and level.
- Guide collection, chapter, step and relevant quest ID.
- Reproduction steps, expected behavior and what actually happened.
- Complete BugGrabber/BugSack error text, if available, and whether it happens with other addons disabled.

Remove player names, account details and other private information from screenshots or logs. For feature requests, explain the player-facing problem and your suggested behavior.

Further reading: [features and tools](FEATURES_335.md) · [translation contributions](LOCALIZATION.md) · [changelog](CHANGELOG.md).

## Credits and license

Thanks to **RestedXP** and its contributors for the original addon and guides; **AzerothCore** for server references; **Zygor Guides Viewer** contributors and [Zygor Guides Viewer Remaster](https://github.com/ErebusAres/ZygorGuidesRemaster-3.3.5a_WOTLK) for converted WotLK route material; the bundled-library authors; and everyone testing and improving the project.

See [LICENSE](LICENSE). This is a mixed-license distribution: bundled libraries, assets and guide content retain their own licenses and attribution notices.

Favorites icons are adapted from [Tabler Icons](https://github.com/tabler/tabler-icons) by Paweł Kuna, under the [MIT license](Textures/Tabler/LICENSE.txt).
