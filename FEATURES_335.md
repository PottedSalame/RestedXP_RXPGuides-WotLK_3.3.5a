# RXPGuides 3.3.5 feature services

The WotLK manifest includes a set of stock-UI services designed for standalone
3.3.5a clients. Existing guide syntax and the legacy guide dropdown remain
unchanged.

- `/rxp guides` opens the Guide Hub, checkpoints, favorites, recent guides,
  filters, restart confirmation, step selection, and catch-up preview.
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

Optional-module initialization is supervised after the addon bootstrap. A
repeated runtime initialization failure disables only that subsystem on the
next login and leaves the guide window and Guide Hub available. A Lua syntax
error in a file loaded by the TOC occurs before the addon bootstrap and cannot
be recovered by this safe mode; repository validation and final in-game tests
remain required before publishing a release.

## Turn-ins outside the guide's reward transaction (2026-09-25)

Stock 3.3.5 emits no `QUEST_TURNED_IN`, and the completed-quest list is only fetched
from the server at login. Until now the compat layer marked a quest as turned in only
when RestedXP's own quest automation submitted the reward, so a manual "Complete Quest"
click, an auto turn-in addon (TurnIn calls `GetQuestReward` on `QUEST_COMPLETE`) or
another guide addon left the `.turnin` step unchecked until the next `/reload`
(observed on ChromieCraft). `Compat/Bootstrap.lua` now remembers every quest that
vanishes from the log on `QUEST_LOG_UPDATE`, calls `QueryQuestsCompleted()` (throttled
to one call per 1.5 s, half a second after the change) and, on `QUEST_QUERY_COMPLETE`,
marks the vanished quests the server reports as completed, refreshes the guide window
and prints a debug line when `/rxp debug` is on. Removals are detected against every
quest ever seen on the log (not only the previous enumeration), collapsed quest-log
headers are expanded for the enumeration and restored afterwards, and a pending quest
that reappears on the log is dropped; abandoned quests expire after two minutes.

`addon.comms.PrettyDebug` (the `/rxp debug` chat output) now stringifies its arguments
and never raises: the leveling tracker's "GUID changed" message formatted a nil player
GUID during ADDON_LOADED on 3.3.5 and aborted the initialize phase whenever debug mode
was on.
