# Local editor acceptance

Automated checks establish source preservation and structural compatibility, not
quest availability or gameplay correctness. No deliberate character deaths are
needed. All work remains local until publication is separately authorized.

1. Start the loopback server from the README. Open the tools hub, follow Guide
   Editor and Help, and return to the hub. Repeat at the repository-prefix URL.
2. Create a custom Horde Durotar guide. Add travel, accept 4641, a note and its
   turn-in. Look up quest 4641 and NPC 10176, then use them in instructions.
   Search a name on Wowhead and paste a WotLK result link back. Verify failed
   lookups leave editing available and .complete indices remain author-entered.
3. Change a coordinate, text and condition through forms; inspect Source. Edit
   Source and check the form/preview. Typing must update the selected instruction
   immediately without moving the caret. New instruction drafts require Add;
   Cancel leaves source unchanged. Duplicate/reorder/delete steps, then Undo/Redo.
   Test keyboard focus, grouped toolbar controls and a narrow window.
4. Import a real multiguide file. Select a chapter, edit one line and download the
   original file. Check that other chapters, conditions, comments and outer Lua
   are intact. Guards must block isolated companion export, not disappear.
5. Import/export an unchanged CRLF/BOM file. Compare bytes. Try malformed source,
   an encoded import string, advanced instructions and delimiter collisions;
   errors must be explained and source saving must remain available.
6. Save a draft, reload and explicitly restore it. Download a backup. Try denied
   browser storage; the editor must explain the failure without losing the open
   document. Local drafts are not shared between browser origins.
7. For a self-contained custom guide, download both companion files. Close WoW,
   place them in the exact displayed folder, restart and enable the companion.
   Use a disposable Orc Warrior; do not overwrite bundled guide files. Check
   acceptance, objectives, turn-in, conditions, travel and reload restoration.
8. Check that your normal guide identities and existing progress are unchanged.
   If testing with Questie, use its tracking without its quest automation.
9. Try a large existing guide file and rapid reference searches. Source edits,
   selection and scrolling should remain usable. Missing data must not prevent
   manual authoring. Do not interpret a static preview as a gameplay simulation.

Record browser/version, tested files and any failed case. Real GitHub deployment
and in-game outcomes remain separate from automated results.

## Local map acceptance

Before map testing, try the new workspace:

- Switch Write / Map / Source with an unfinished instruction. It must remain a
  draft until Add; switching views must not alter source or Undo history.
- Find a step by text or number; clear the search and verify its position.
- Use Check source on an invalid coordinate. Select its problem, correct the
  highlighted line, and verify the form error clears.
- Try File / Export, Escape, and keyboard tab navigation. At a narrow width,
  use Steps to open the outline; the inspector should stack below the editor.
- Check guide headers under Guide properties and instruction conditions under
  Conditions. Download a full-file backup before closing the page.

1. Choose Map. Check Durotar, Elwynn Forest, Hellfire Peninsula and a Northrend
   zone, then Eversong Woods and Azuremyst Isle. Pan, zoom and resize. Coastlines
   and markers must move together; expansion starters belong to EK/Kalimdor.
   Confirm the viewport stays square on wide and narrow screens. Try slow wheel
   input and rapid direction changes: zoom should stay under the pointer without
   abrupt jumps. With reduced motion enabled, zoom should respond immediately.
2. In Durotar, inspect Kaltunk (10176), Gornek (3143) and Hana'zua (3287).
   Compare snapshot coordinates with an authored waypoint and the game. Zoom in
   for exact markers rather than low-zoom cluster centroids. Check zone edges.
3. Toggle every legend layer. Open a crowded cluster, then a specific location.
   Check multi-role NPCs and conditional-spawn notes. Use the Visible locations
   list and Location details with the keyboard. No Wowhead request should happen
   until its explicit details action is chosen.
4. Select a waypoint, drag it, Undo and Redo. Drag again and press Escape: source
   must not change. Try manual X/Y entry and Add/Replace. Conditions, radius,
   optional arguments and other guides in an imported file must remain intact.
5. Edit the same waypoint through its form and Source. Verify the marker follows.
   Switch continents/documents rapidly, collapse while loading, and reopen. Old
   markers must not reappear. Check a narrow display and keyboard pan/zoom.
6. With no local imagery available in a separate source-only checkout, editing,
   drafts, downloads and companion exports must still work. Do not delete your
   generated artwork to test this; automated tests cover the missing-file case.
7. Export a small custom Durotar route and test it on a disposable Orc Warrior.
   Compare its in-game waypoint with the editor, then check normal guides and
   existing progress. This remains user acceptance, not automated certification.

8. Check the client quest/vendor/trainer/repair icons in both legend and map.
   Creatures use green circles with gold borders; objects use purple circles
   with gold borders. Enable these normally hidden layers to inspect them.
   Disable Repairs and confirm repair-only NPCs disappear; ordinary vendors
   must not gain a repair role. Missing icons must retain readable symbols.
9. Build the static-site payload and test it under a repository-style URL.
   Terrain and icons must appear without access to the client or source checkout.

No in-game testing, endorsement or grant of artwork redistribution rights is
implied by passing the offline/browser checks. Deployment is a separate action.
## Event filters

1. Open Map → Calendar events. Enable Winter Veil or Hallow's End; check
   markers with Quest starters/turn-ins and Objects enabled. Turn the event
   off and verify its markers disappear at both zone and continent zoom.
2. Check Noblegarden with Objects enabled; its pooled egg locations should
   follow the event toggle. Critters and training dummies must remain under
   Creatures. Other world events have separate switches.
3. Toggle events with a location popup open: old quest-action buttons must
   disappear. Collapse/reopen the map: choices remain, guide source and Undo
   history are unchanged. Reloading the page restores filter defaults.

## Profession filters

1. Open Map → Professions. All 14 switches should be off, with client icons.
2. Enable Mining, Herbalism and Fishing separately. Check ore, herbs and
   pools, then enable a crafting profession and find its trainers in a town.
3. Disable generic Trainers/Objects/Creatures to isolate profession markers.
   Toggle a calendar event with Fishing enabled; seasonal pools must still
   obey the event filter. Check continent-level counts as well as close zoom.
4. Verify source text, selected guide and Undo history remain unchanged.
5. Compare a profession trainer (trainer symbol + profession badge), a class
   trainer (trainer symbol + class badge), and a gathering node (plain icon).
   Check their type descriptions in Location details and the location list.
6. With generic Trainers/Creatures/Objects disabled, select Mining and toggle
   Include trainers / Include gathering locations separately. Check both close
   zoom and continent counts. Unknown trainers must not acquire a guessed badge.

## Ghostlands edge cleanup

1. Open Eastern Kingdoms and inspect the Ghostlands / Eastern Plaguelands border.
2. Zoom out and back in, pan away and return. The white strip and large navy
   placeholder blocks should stay absent; a thin original terrain seam can remain.
3. Select a Ghostlands waypoint, move it, then Undo. Marker coordinates and source
   edits should behave as before. Check Outland and Azuremyst remain unchanged.

## Interior references

1. Open Map → Regions → Dungeons. Select Wailing Caverns, then change the
   view/section. Pan, zoom and use the keyboard; no guide instructions should change.
2. Search the entity list, select an NPC and click Entity details → Add target.
   Check the new instruction, then Undo and Redo. Try a quest or interaction note.
3. Check Blackrock Depths, Icecrown Citadel and Deeprun Tram. Lists describe the
   entire instance, not the displayed room. No NPCs should appear as mapped pins.
4. Select a shared cave/crypt under Underground locations. Without a verified
   spawn association, its entity list must stay empty. Reference lookup still works.
5. Toggle an event, switch regions quickly, then collapse/reopen the panel.
   Stale entity actions must not edit a different guide. Check a narrow window too.
6. Return to Continents. Existing outdoor waypoint creation, drag/Undo, legends
   and coordinate readouts should behave as before. Download and reopen the guide.
