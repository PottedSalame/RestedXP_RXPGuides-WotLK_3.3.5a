# RXPGuides 3.3.5 features

Tools for standalone WoW 3.3.5a clients. Optional features can be managed through
the Guide Library's Feature Tools tab.

## Interface and custom guides

- The Guide Library contains Guides, Feature Tools, Settings and Import.
  `/rxp guides` opens Guides, with filters, favorites, recents, checkpoints,
  restart confirmation, step selection and catch-up preview.
- Right-click the minimap icon or guide-window cog to toggle the library.
  Shift-right-click opens the existing dropdown menu.
- Modern is the default interface; Legacy remains available. Changing the
  complete style requires a reload and preserves guide progress.
- Create routes with the [online Guide Editor](https://pottedsalame.github.io/RestedXP_RXPGuides-WotLK_3.3.5a/guide-editor/).
  Import exported text through **Import → Website guide source**, then select
  **Type → Custom guides**. **Delete import** removes a saved import after
  confirmation; switch away first if it is active. Checkpoints are retained.

## Gameplay and diagnostic tools

- Attack Timer is optional and off by default. It displays estimated melee/ranged
  basic-attack countdowns and live character-sheet damage ranges. It does not
  automate combat or guarantee attack readiness. Enable it through Feature Tools.
- `/rxp backup` exports or imports sanitized settings and current-character
  progress. Imports validate a checksum and schema; replace requires a second
  confirmation and can be undone until reload.
- `/rxp diagnose` opens Step Doctor. Reports exclude chat, player/realm names,
  account identifiers, Battle.net data, and full unit GUIDs.
- `/rxp supplies`, `/rxp gear`, and `/rxp dailies` open the class-supplies,
  complete-layout gear, and WotLK activity views.
- `/rxp preflight` checks 1-100 upcoming steps for known route blockers,
  conservative XP shortfalls, and item requirements. Reserved items are
  protected from automatic junk handling and receive a bag marker.
- `/rxp watch` explicitly arms or stops the current-step watchdog. It never
  starts on its own, so long rare-drop steps remain undisturbed unless watched.
- `/rxp archives` opens anonymous account-wide leveling archives and personal-
  best comparisons. Character names, realms, and GUIDs are not stored.
- `/rxp pet` opens the Hunter Pet Assistant for happiness, food, ammunition,
  talents, known skills, and upcoming stable/tame preparation.
- `/rxp perf` opens the Performance Inspector. Optional adaptive throttling is
  opt-in, changes only runtime scan rates, and restores them automatically.
- The independently toggleable Speedrunning Suite adds active/wall step splits,
  compatible personal-best comparisons, grind and pit-stop advice, confirmed
  route alternatives, safe deathwarp estimates, shadow segment practice,
  throttled audio cues, and anonymous run-integrity profiles. Use `/rxp coach`,
  `/rxp grind`, `/rxp pitstop`, `/rxp route`, `/rxp deathwarp`,
  `/rxp practice`, `/rxp audio`, or `/rxp rules` to open each enabled tool.
- Party synchronization and Guide Author recording are opt-in. Remote party
  suggestions always require confirmation, and recorder drafts are never
  registered automatically.
- Imported compatibility packs are data-only, limited to 256 KB, and cannot
  execute Lua. The bundled baseline targets AzerothCore 3.3.5a.

## Runtime safeguards

Optional-module initialization is supervised after the addon bootstrap. A
repeated runtime initialization failure disables only that subsystem on the
next login and leaves the guide window and Guide Hub available. A Lua syntax
error in a file loaded by the TOC occurs before the addon bootstrap and cannot
be recovered by this safe mode; repository validation and final in-game tests
remain required before publishing a release.
