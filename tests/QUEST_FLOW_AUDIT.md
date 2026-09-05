# Validated-guide quest-flow checks

The Original guide snapshots remain unchanged. Structural validation covers
the whole 30300 manifest; quest-flow analysis deliberately excludes Original
snapshots and examines the Validated guides.

## Durotar and initial audit corrections

- **6-10 Durotar:** return quest 825 to Gar'Thok at the existing Razor Hill
  return visit; include Hunters in the normal-XP quest 831 accept. No Durotar
  steps were inserted, so existing step IDs remain unchanged.
  References: [From The Wreckage](https://www.wowhead.com/wotlk/quest=825/from-the-wreckage),
  [The Admiral's Orders, first part](https://www.wowhead.com/wotlk/quest=830/the-admirals-orders),
  [follow-up](https://www.wowhead.com/wotlk/quest=831/the-admirals-orders).
- **25-26 Stonetalon / 26-30 Ashenvale:** only accept Ordanus on the XP branch
  that hunts him; return his head in Sun Rock Retreat before the existing
  hearth/training leg. The return detour requires the completed quest.
  Reference: [Ordanus](https://www.wowhead.com/wotlk/quest=1088/ordanus).
- **Alliance and Horde Stratholme:** correct the final Smokey LaRue action
  from accepting quest 5214 again to turning it in. The source already placed
  this action at Smokey with `.isQuestComplete 5214`.
- **Horde Dire Maul:** correct the West return action to a turn-in; use the
  Horde quest, objective, NPC, and Camp Mojache location in North instead of
  the copied Alliance handoff.
  Reference: [Elven Legends](https://www.wowhead.com/wotlk/quest=7481/elven-legends).
- **Sha'tari Skyguard unlock:** return to Sky Commander Adaris after defeating
  Terokk, before announcing that the chain is finished.
  Reference: [Terokk's Downfall](https://www.wowhead.com/wotlk/quest=11073/terokks-downfall).
- **Fishing dailies:** use the respective quest IDs for the Ghostfish and
  Blood Is Thicker hand-ins, instead of the copied Dangerously Delicious ID.
  References: [The Ghostfish](https://www.wowhead.com/wotlk/quest=13830/the-ghostfish),
  [Blood Is Thicker](https://www.wowhead.com/wotlk/quest=13833/blood-is-thicker).

## Whole-inventory follow-up

The follow-up examined every Validated guide, including non-leveling guides,
and reviewed the reported lifecycle findings rather than limiting the work to
Durotar. Confirmed source defects were repaired as follows:

- **Human leveling:** align the Mage/Warlock Westfall accepts with their
  class-specific XP thresholds; guard the tree-collection quest work and
  hand-in when the accelerated branch omits its pickup.
- **Night Elf and Darkshore:** make existing conditional breadcrumb hand-ins
  optional when that character's branch did not accept the quest.
- **Troll Priest:** retain the Garments of Spirituality pickup at accelerated
  XP rates and keep that racial quest out of other Priest branches.
- **Azuremyst and Bloodmyst:** represent pre-looted meat as item collection,
  move the Sunhawk/Sun Gate objectives after their prerequisite turn-ins and
  accepts, and deliver Vindicator's Rest after its actual chain. Its earlier
  opportunistic hand-in remains optional.
  Reference: [Vindicator's Rest](https://www.wowhead.com/wotlk/quest=9760/vindicators-rest).
- **Ghostlands:** deliver The Stone before accepting The Rune of Summoning;
  collect and deliver the Ranger Valanna introduction before Dealing with
  Zeb'Sora.
  References: [The Stone](https://www.wowhead.com/wotlk/quest=9529/the-stone),
  [Help Ranger Valanna](https://www.wowhead.com/wotlk/quest=9145/help-ranger-valanna).
- **Alliance Dustwallow visit:** accept Jaina's final Missing Diplomat quest
  after Tervosh's turn-in, instead of attempting to turn it in unaccepted.
- **Both Zangarmarsh routes:** take Ysiel's Warden Hamoot introduction before
  visiting Hamoot, then turn it in before accepting A Warm Welcome.
  Reference: [Warden Hamoot](https://www.wowhead.com/wotlk/quest=9778/warden-hamoot).
- **Both Zul'Drak routes:** select the complete Drakuru quest-ID sequence
  according to completion of Cleansing Drak'Tharon (12238). This includes the
  choker item, initial invitation, follow-ups, disguise, and Dark Horizon or
  Reunited tour. Faction alone does not select the correct version.
  References: [An Invitation, of Sorts](https://www.wowhead.com/wotlk/quest=12631/an-invitation-of-sorts),
  [Darkness Calling](https://www.wowhead.com/wotlk/quest=12633/darkness-calling),
  [Reunited](https://www.wowhead.com/wotlk/quest=12663/reunited).
- **Horde Icecrown dailies unlock:** finish Before the Gate of Horror after
  its two prerequisites, unlocking Volatility before handing off to the
  daily route. The group encounter remains a player action.
  Reference: [Before the Gate of Horror](https://www.wowhead.com/wotlk/quest=13329/before-the-gate-of-horror).
- **TBC attunements and Netherwing:** add the auto-complete Mark of Vashj
  introduction, use Akama's Promise 10708 rather than 11052, and use Zuluhed
  10866 rather than the unlinked 10872 variant.
  References: [The Mark of Vashj](https://www.wowhead.com/wotlk/quest=10900/the-mark-of-vashj),
  [Akama's Promise](https://www.wowhead.com/wotlk/quest=10708/akamas-promise),
  [Zuluhed the Whacked](https://www.wowhead.com/wotlk/quest=10866/zuluhed-the-whacked).

Quest-link verification also used the public
[AzerothCore quest addon data](https://github.com/azerothcore/azerothcore-wotlk/blob/master/data/sql/base/db_world/quest_template_addon.sql).
This was offline evidence only; the addon does not read external SQL or another
addon at runtime. Old prerequisite metadata, current server data, and Wowhead
comments do not always agree, especially for optional breadcrumbs. Unverified
disagreements remain review notes rather than mandatory new detours.

## Routing and cache regression coverage

`guide-loading.lua` executes the actual Lua guide parser with inert directive
handlers. It checks Orc/Troll Hunter, Warrior, Shaman, Rogue, and Warlock
branches, normal/accelerated XP quest handoffs, and the absence of the
Undercity travel leg on the Durotar/Barrens branches. It also tests same-length
source edits, legacy metadata, disabled-cache entries, lazy parser replacement,
and preservation of character checkpoints.

Additional parser tests check Troll Priest and Human XP thresholds, the
Bloodmyst chain, Ghostlands handoffs, both Zangarmarsh routes, both Drakuru
quest-history branches, Icecrown prerequisites, Netherwing, and Black Temple.
These tests inspect source order with inert directive handlers: they do not
simulate NPC dialogs, loot, combat, or the full dynamic step evaluator.

Embedded metadata now uses a content signature as well as length. Cache
revision 34 triggers a rebuild without clearing guide progress. Updating addon
files requires `/reload` before an already-running client uses the new source.

## Running and interpreting the audit

```powershell
./tools/Validate-QuestFlow335.ps1 -ReportPath build/quest-flow335.json
```

```text
lua5.1 tests/run.lua .
```

Both GitHub workflows run the prerequisite pass again; they no longer pass
`-SkipQuestValidation`. The audit fails for existing internal prerequisite,
label, and route errors, and for accepted objective quests with neither a
reward nor an explicit abandonment anywhere in the Validated inventory.

Potential missing local accepts are reported separately. Optional pickups,
pre-looted items, sticky-step execution, conditional turn-ins, and manually
entering another race's guide cannot be proved invalid from a linear event
list. `-FailOnLifecycleWarnings` promotes those findings to errors for focused
review; `-FailOnEntryWarnings` does the same for cross-guide prerequisites.
These are **unresolved review items**, not an approved exception allowlist.

The final structural baseline is **50 files, 709 guides, 48,654 steps**.
Quest-flow validation examines **360 Validated guides**, with **17,361
class/race/XP branch runs** and **1,364 complete next-guide route-matrix runs**.
The latter check transitions, not a simulation of quest state through 1-80.

After these fixes the report has zero fatal errors, **17 lifecycle review
findings** (13 manual/off-route-entry contexts and four optional-pickup
contexts), and **184 entry-prerequisite notes**. Candidate authored hand-ins
exist for 129 of those entry notes; 55 have no authored provider in the
Validated inventory. A candidate provider does not prove a particular
character's route visited it. No finding is silently suppressed or certified
as resolved based on this classification.

Report schema 2 includes `entryReferences` and `lifecycleReviews`, with sorted
candidate source locations and optional-pickup/default-route context. XP
filters are retained in source order and selected per class/race profile;
negative optional turn-ins are distinguished from mandatory missing accepts.

The JSON report contains sorted relative source locations, quest IDs and
synthetic class/race/XP profiles, not player or machine information. It is an
offline artifact and is not loaded or shipped by the addon.

Passing these checks does not certify every quest against Wowhead or prove
every branch in-game. Cross-guide quest-state propagation, all dynamic guards,
and server-specific quest behavior still require further review and gameplay
verification. Do not automatically add quests or reroute players based only
on an audit warning.
