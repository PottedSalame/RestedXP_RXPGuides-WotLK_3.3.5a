# RestedXP Guides — WotLK 3.3.5a Backport

A standalone community backport of **RestedXP Guides** for **World of Warcraft: Wrath of the Lich King 3.3.5a (build 12340)**.

This project adapts the RestedXP guide engine, interface, automation, navigation, talent guides, and supporting tools to the original 3.3.5a API. It is primarily developed and tested against AzerothCore and does not require Questie, ElvUI, WeakAuras, or another addon to run.

[![Download](https://img.shields.io/badge/Download-Latest_Release-2ea043?style=for-the-badge&labelColor=555555)](https://github.com/Kryastorm/RestedXP_RXPGuides-WotLK_3.3.5a/releases/latest)
[![Install](https://img.shields.io/badge/Install-Quickly-8250df?style=for-the-badge&labelColor=555555)](#quick-install)

![Version](https://img.shields.io/badge/Version-v4.8.25--335-1f6feb)
![Client](https://img.shields.io/badge/Client-WotLK_3.3.5a-blue)
![Build](https://img.shields.io/badge/Build-12340-yellow)
![Runtime](https://img.shields.io/badge/Runtime-Standalone-brightgreen)

## Version

- Addon version: **v4.12.1**
- Intended client: **WotLK 3.3.5a / build 12340**
- Primary server target: **AzerothCore**
- Interface number: **30300**

## Who This Is For

This addon is intended for:

- Players using a World of Warcraft **3.3.5a (12340)** client.
- AzerothCore and compatible WotLK private-server environments.
- Players who want step-by-step Alliance and Horde leveling routes through level 80.
- Players who want RestedXP-style navigation, quest automation, targeting, talent guidance, and gear assistance on the legacy client.
- Developers and guide authors maintaining or testing 3.3.5a routes.

The supported target is the stock 3.3.5a API. Custom clients and other server cores may work, but can expose different quest, map, taxi, item, or event behavior.

## What You Get

- Step-by-step leveling and quest guidance for both factions.
- Classic, TBC, and WotLK leveling progression through level 80.
- Death Knight and boosted-character entry routes.
- TBC dungeon quest, reputation, and attunement guides.
- WotLK daily quest guides, gathering guides, and farming guides.
- Waypoint arrows, world-map pins, route lines, and flight-path support.
- Automatic quest acceptance, turn-in, reward handling, quest sharing, and supported confirmation interactions.
- Per-character guide selection and exact step restoration.
- Active Targets with friendly and hostile target lists, portraits, secure target buttons, and visible-nameplate discovery.
- Active Item buttons for guide-related items and actions.
- Talent guides with automatic active-spec selection where supported.
- Leveling splits, played-time tracking, XP reports, and flight timers.
- Item-upgrade scoring, upgrade prompts, quest-reward recommendations, junk management, quiver handling, and a legacy Auction House upgrade scanner.
- Automatic vendor repair using personal or guild funds when enabled.
- Vendor Treasure pins on supported world maps.
- Bundled 3.3.5-compatible libraries for standalone operation.

## What Stayed the Same

The established RestedXP workflow remains familiar:

- Guide parsing and step progression.
- Guide groups, chapters, conditions, and imported-guide support.
- Current-step and step-list presentation.
- Waypoint arrow and map-pin navigation.
- Quest, item, target, flight, hearthstone, and travel directives.
- Themes, font sizing, window scaling, and frame locking.
- Character-specific guide and step progress.
- Account and character settings stored through WoW SavedVariables.

Existing guide keys and save structures are retained wherever possible so updates do not unnecessarily reset character progress.

## What's New in the 3.3.5a Backport

- A broad compatibility layer for modern `C_*`, `Enum`, map, quest, taxi, action-bar, death, and interaction APIs used by the RestedXP runtime.
- Standalone bundled Ace3, LibDataBroker, LibDBIcon, HereBeDragons/Astrolabe, serialization, communication, timer, and UI dependencies.
- Legacy quest automation designed around 3.3.5a's title-based gossip and quest events, including same-NPC turn-in/follow-up acceptance handling.
- A flattened legacy guide picker with faction, race, class, XP-rate, and guide-profile filtering.
- Validated Classic, TBC, and converted WotLK routes with repaired quest dependencies, transitions, coordinates, targets, and flight names.
- A stock-client nameplate scanner and secure targeting controls without runtime dependence on ElvUI or WeakAuras.
- Client-local target markers and an Active Targets window that persists for the current step.
- Live legacy settings for guide font size, targeting frequency, target range, repairs, vendor pins, and other 3.3.5a features.
- A legacy talent-guide interface and class/spec guide selection.
- 3.3.5-aware item parsing, weapon and armor proficiency checks, two-hand/off-hand comparisons, reward selection, and upgrade prompts.
- Protected consumables, equipment-aware junk classification, manual junk overrides, Soul Shard limits, and ammunition/quiver management.
- Legacy group communications, quest sharing, corpse navigation, emergency-action detection, hearthstone batching, and taxi timers.
- World-map UI coordination so the guide, Active Targets, level splits, menus, and vendor pins behave correctly on the fullscreen legacy map.
- Offline validators for guide structure, quest flow, and talent plans.

## Key Controls

### Minimap and world map

- **Minimap icon, left-click:** toggle enabled RestedXP frames.
- **Minimap icon, right-click:** open the RestedXP menu.
- **World-map RestedXP icon:** open or close the map-safe RestedXP menu.
- **Guide footer cog:** open guide selection and step controls.

### Keybindings

The following actions can be assigned under the game's **Key Bindings** menu:

- Cycle RestedXP targeting.
- Delete the cheapest junk item.
- Use Active Item buttons 1–4.
- Target Friendly Target buttons 1–4.
- Target Enemy Target buttons 1–4.

Targeting actions use secure buttons and still require a physical key or mouse press, as required by the 3.3.5a client.

### Slash commands

- `/rxp` — open addon settings.
- `/rxp import` — open the guide import page.
- `/rxp debug` — toggle debug output.
- `/rxp splits` — toggle the Level Splits window.
- `/rxp show`, `/rxp hide`, or `/rxp toggle` — toggle enabled addon frames.
- `/rxp next` — move to the next guide step.
- `/rxp prev` — move to the previous guide step.
- `/rxp step <number>` or `/rxp goto <number>` — move to a specific step.
- `/rxp browse` — freeze or resume automatic step progression while reviewing a guide.
- `/rxp preview` — preview movable addon frames.
- `/rxp bug` or `/rxp feedback` — open the feedback form.
- `/rxp help` — show command help.

Roadmap tools are also available directly:

- `/rxp guides` opens the searchable Guide Hub.
- `/rxp backup` opens sanitized backup export/import.
- `/rxp diagnose` opens Step Doctor for the current step.
- `/rxp supplies` opens the class-supplies merchant checklist.
- `/rxp gear` opens the complete-layout Gear Advisor.
- `/rxp dailies` opens the WotLK daily and weekly planner.
- `/rxp record` opens the opt-in Guide Author recorder.
- `/rxp preflight` opens upcoming route, XP-shortfall, and item-reservation checks.
- `/rxp watch` explicitly arms or stops the watchdog for the current step.
- `/rxp archives` opens anonymous account-wide personal-best archives.
- `/rxp pet` opens the Hunter Pet Assistant.
- `/rxp perf` opens the Performance Inspector and sanitized capture tools.

The aliases `/rxpg` and `/rxpguides` are also registered. See
[FEATURES_335.md](FEATURES_335.md) for the roadmap services, privacy boundaries,
and safe-mode behavior.

## Quick Install

### Installation overview

1. Open the [latest GitHub Release](https://github.com/Kryastorm/RestedXP_RXPGuides-WotLK_3.3.5a/releases/latest).
2. Under **Assets**, download `RXPGuides-<version>.zip`.
3. Extract the ZIP directly into your WoW `Interface\AddOns\` directory.
4. Launch the game and enable **RestedXP Guides**.

> [!IMPORTANT]
> Download the `RXPGuides-<version>.zip` file listed under **Assets**. Do **not** use GitHub's automatically generated **Source code (zip)** or **Source code (tar.gz)** downloads: those use the repository name as their outer folder and will not produce the required addon path automatically.

### Detailed steps

1. Close World of Warcraft.
2. Visit the repository's [Releases page](https://github.com/Kryastorm/RestedXP_RXPGuides-WotLK_3.3.5a/releases).
3. Open the newest release and expand **Assets** if necessary.
4. Download the packaged release asset. Its name follows this format:

   ```text
   RXPGuides-v4.8.25-335.zip
   ```

5. Open your WoW installation and navigate to:

   ```text
   Interface\AddOns\
   ```

6. If an older `RXPGuides` folder exists, remove or rename that addon folder before extracting the update. Do not merge releases file by file, because obsolete Lua or XML files can remain loaded.
7. Extract the downloaded ZIP directly into `Interface\AddOns\`. The release workflow already places every addon file beneath the correct `RXPGuides` directory.
8. Confirm this exact path exists:

   ```text
   Interface\AddOns\RXPGuides\RXPGuides.toc
   ```

9. Start the game, open **AddOns** on the character-selection screen, and enable **RestedXP Guides**.
10. Enable **Load out of date AddOns** if your custom client reports the addon as outdated.

The finished installation must not contain an extra folder level such as:

```text
Interface\AddOns\RestedXP_RXPGuides-WotLK_3.3.5a-v4.8.25-335\RXPGuides\
```

## Common Issues

### Addon not appearing in-game

- Confirm the folder path is `Interface\AddOns\RXPGuides\RXPGuides.toc`.
- Make sure you downloaded the packaged `RXPGuides-<version>.zip` release asset, not GitHub's source archive.
- Remove accidental double-folder nesting created during extraction.
- Enable **Load out of date AddOns**.
- Check that the addon is enabled for the current character.
- Avoid merging a new release into an older addon folder.

### A new character shows an empty guide window

This is intentional. New characters begin without a selected guide so one character cannot inherit another character's route and step. Open the guide picker and choose the appropriate starting chapter.

Characters that already selected a guide should restore their own guide and step after `/reload`, logout, or character switching.

### Some guides are hidden or disabled

The picker filters guides by faction, race, class, level, XP rate, prerequisites, and route conditions. Enable **Show unused guides** to inspect incompatible or currently filtered entries.

Some mutually exclusive routes, such as Aldor and Scryer chapters, remain unavailable until their conditions are satisfied.

### A guide does not progress

- Make sure `/rxp browse` is not enabled.
- Confirm the quest ID and objective state match the server.
- Use `/rxp next` only as a temporary workaround.
- Record the guide name, step number, quest ID, and any BugGrabber stack trace when reporting the problem.

Custom server quest chains can differ from AzerothCore's reference data and may require a server-specific guide correction.

### Active Targets does not discover a distant unit automatically

The stock 3.3.5a API does not provide a general list of every rendered unit. Passive discovery uses visible stock nameplates plus target and mouseover information. Enable the relevant nameplates or use the secure RestedXP targeting keybinding for targets that are not represented by a visible nameplate.

### Item information or junk overlays appear late

The legacy client can deliver item data asynchronously. Bag, loot, item-info, equipment, skill, and spellbook events trigger rescans, but an uncached item may require a short moment or a tooltip query before all comparison data is available.

Manual useful/junk choices take priority over automatic classification.

## Reporting Issues and Suggesting Features

Please use the repository's [Issues tab](https://github.com/Kryastorm/RestedXP_RXPGuides-WotLK_3.3.5a/issues) for reproducible problems and feature proposals. Search the open and closed issues first to avoid creating a duplicate.

### Bug reports

Create a new issue and apply the **`bug`** label. Include as much of the following information as possible:

- A short, specific description of what went wrong.
- The addon version and confirmation that the client is WotLK 3.3.5a build 12340.
- The server core and revision, when known.
- The character's faction, race, class, level, and relevant profession or weapon training.
- The guide group, chapter, and exact step number.
- Relevant quest, item, spell, NPC, map, or flight-node IDs.
- Clear steps that reproduce the problem.
- What you expected to happen and what happened instead.
- The complete BugGrabber/BugSack stack trace, not only the first error line.
- Whether the problem still occurs with every other addon disabled.
- Screenshots or SavedVariables excerpts when they materially help reproduce the issue. Remove account names, character names, server addresses, and other private information first.

One issue should normally describe one problem. If several guide steps fail for the same underlying reason, they may be reported together with every affected step listed.

### Feature suggestions

Create a new issue and apply the **`enhancement`** label. Describe:

- The problem or limitation the feature would address.
- The proposed behavior from a player's point of view.
- Where it should appear in the interface or settings, if applicable.
- Any relevant 3.3.5a API or protected-action restrictions.
- How it should interact with existing guides, settings, SavedVariables, and standalone operation.
- Examples from newer RestedXP versions or other addons, with links and licensing information where relevant.

Feature suggestions are evaluated against stock 3.3.5a client capabilities, AzerothCore compatibility, runtime safety, guide-data quality, maintenance cost, and the requirement that RXPGuides remain standalone.

## Updating

1. Open the [latest release](https://github.com/Kryastorm/RestedXP_RXPGuides-WotLK_3.3.5a/releases/latest) and download its `RXPGuides-<version>.zip` asset.
2. Close World of Warcraft.
3. Back up your `WTF` folder if you want an external copy of your settings and character progress.
4. Remove the old `Interface\AddOns\RXPGuides` addon folder. This does not remove SavedVariables, which are stored under `WTF`.
5. Extract the new ZIP directly into `Interface\AddOns\`.
6. Verify that `Interface\AddOns\RXPGuides\RXPGuides.toc` exists, then start the game.

For development changes, `/reload` is normally sufficient for Lua-only edits. Fully restart the client after changing TOC files, XML manifests, bundled libraries, fonts, or textures.

## Guide Profiles

Two broad guide profiles are included:

### Validated 3.3.5a routes

These are the default backport routes. They include local fixes for legacy quest flow, prerequisites, coordinates, targets, map names, taxi destinations, route transitions, and unsupported modern content.

### Original upstream snapshots

Original guide snapshots are exposed in isolated **Original** guide groups for comparison and fallback use. Their guide keys are separate from the validated routes, so switching profiles does not overwrite the corresponding progress record.

Original snapshots intentionally retain more upstream behavior and may be less suitable for a particular 3.3.5a server than the validated routes.

Guide availability always depends on the current character's faction, race, class, level, XP rate, and route conditions.

## Notes

- The supported target is **WotLK 3.3.5a (12340)**.
- The backport is primarily validated on **AzerothCore**.
- Other 3.3.5a cores may differ in quest prerequisites, localized names, events, taxi data, item metadata, or custom content.
- The addon does not force friendly or hostile nameplates on.
- Automatic taxi selection is deliberately skipped when a destination cannot be resolved uniquely.
- Protected targeting, item use, equipment, and other secure actions remain subject to normal combat and hardware-input restrictions.
- Static guide validation catches structural problems, but every route still benefits from in-game testing with BugGrabber enabled.

## Known Issues

- Passive target discovery is limited to visible nameplates, the current target, and mouseover units because the stock client cannot enumerate arbitrary rendered entities.
- Localized or custom taxi-node names may require manual selection when no unique destination can be resolved.
- Custom server quest chains can diverge from the AzerothCore data used for offline validation.
- Converted or original guide routes may contain encounters that require manual vehicle, gossip, or scripted-event interaction.
- Other map and waypoint addons can compete for arrows, pins, or fullscreen-map anchors.
- Original upstream snapshots receive compatibility guards, but are not as heavily corrected as the validated 3.3.5a routes.

## Q&A

**Is this the official current RestedXP addon?**

No. This is a community-maintained compatibility backport targeting the original WotLK 3.3.5a client.

**Where should I download it?**

Use the versioned `RXPGuides-<version>.zip` asset from the [latest GitHub Release](https://github.com/Kryastorm/RestedXP_RXPGuides-WotLK_3.3.5a/releases/latest). Do not use the automatically generated source archives for a normal addon installation.

**Does it require Questie, ElvUI, WeakAuras, or Details?**

No. The 3.3.5a runtime and its required libraries are bundled. Other addons may be used alongside it, but they are not dependencies.

**Does it include leveling routes through level 80?**

Yes. The loaded guide set includes Alliance and Horde Classic, TBC, and WotLK progression, subject to the character and route filters described above.

**Why does a fresh character not automatically select a guide?**

The blank state prevents progress from another character being copied accidentally. Select a guide once and that character's guide and step will be restored afterward.

**Can I use the original routes instead of the corrected routes?**

Yes. They are available under separate Original guide groups, although the validated routes are recommended for normal 3.3.5a play.

**Can the addon automatically target every rendered creature?**

No. The legacy API does not expose arbitrary rendered creatures as addressable units. Visible nameplates can be scanned passively; other targets require a secure player-activated targeting button or macro.

**Why was a quest, flight, reward, or item not handled automatically?**

The addon avoids guessing when the legacy client returns ambiguous or incomplete data. Manual interaction remains available, and a reproducible report with the guide step and server details can be used to improve the backport.

## Development

The first-party runtime is organized by compatibility, core, guide, UI, and
feature domains. See [`ARCHITECTURE.md`](ARCHITECTURE.md) for load-order rules,
internal service contracts, extension guidance, upstream mapping, and the
required validation suite.

## Credits

- **RestedXP** and its contributors for the original addon, guide engine, interface, and guide content on which this backport is based.
- **AzerothCore** and its contributors for the open WotLK server and database references used during compatibility testing and offline validation.
- **Zygor Guides Viewer** contributors and the [Zygor Guides Viewer Remaster](https://github.com/ErebusAres/ZygorGuidesRemaster-3.3.5a_WOTLK) project for GPL-licensed WotLK route material converted into native RestedXP guide syntax.
- The authors and maintainers of Ace3, LibStub, CallbackHandler, LibDataBroker, LibDBIcon, HereBeDragons, Astrolabe, LibCandyBar, LibDeflate, and the other bundled libraries.
- Everyone who tests routes in-game and provides actionable guide names, step numbers, quest IDs, and error traces.

## License

The top-level project license is provided in [`LICENSE`](LICENSE).

This is a mixed-license distribution. Bundled libraries, imported assets, upstream guide content, and converted WotLK guide files retain their respective licenses and attribution notices. The repository-level license does not replace those component-specific terms.
