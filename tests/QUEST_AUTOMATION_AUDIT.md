# Quest automation audit and Durotar checklist

## Follow-up fixes: manual rewards and headers

The baseline findings below are historical. The tester subsequently reproduced
manual Cutting Teeth (788) and Sarkoth (804) turn-ins staying incomplete in the
guide, and a Valley of Trials header which would not expand until reload.

The follow-up fix observes the stock reward button's PreClick and securely
post-hooks GetQuestReward without replacing it or making an extra reward call.
The transaction barrier preserves quest identity through synchronous events.
Manual completion can settle through verified log disappearance or a server
completion query without requiring QUEST_TURNED_IN. A query fallback supports
alternate/expensive confirmation buttons, but does not claim the stock button's
pre-call barrier for those alternate paths.

Visible headers are no longer expanded by ordinary guide-data reads, and hidden
rows cannot prove that a quest was removed. The exact in-game header symptom
still needs a retest; the regression covers concrete interference paths.

Related safety changes resolve QA-01/QA-02/QA-03: live controls are rechecked,
reward-cache retries are bounded, context-checked and cancelled at reset, and
QUEST_FINISHED alone is not completion evidence. QA-04 and QA-05 remain separate
outstanding acceptance findings. The standalone audit now passes 84 assertions
and reproduces only those two findings (strict mode deliberately still fails).

[Manual reward/header tests](quest-manual-turnin.lua) are included in the normal
Lua suite. They cover missing modern events, automation off, companion post-hook
ordering, same-NPC continuation, failed rewards, cancellation, shutdown, completed
queries and collapsed headers. Stock UI behavior was checked against the public
3.3.5 [quest frame](https://github.com/wowgaming/3.3.5-interface-files/blob/main/QuestFrame.lua)
and [quest log](https://github.com/wowgaming/3.3.5-interface-files/blob/main/QuestLogFrame.lua)
sources. No Questie, server, guide-content or SavedVariables edits, commits or
pushes were made.

Retest the manual Gornek rewards on a fresh Orc Warrior with calculated rewards
off, then collapse/expand Valley of Trials. Check both turn-in rows BEFORE any
reload; reload should no longer be necessary for completion. Conversational test
numbers can differ from the longer checklist below; identify quests by ID.

## Scope and status

Original audit baseline: `7c776a9`. This was a preventive audit, not a PR integration or a
runtime fix. Only this report and the standalone audit harness were added.
No guide, Questie, server, database, SavedVariables, or production Lua was changed.

The [audit harness](quest-automation-audit.lua) loads the complete production
[coordinator](../Core/Addon.lua), scheduler, ordering, acceptance, and reward
transaction modules into isolated Lua environments. It also loads the complete
directive implementation and executes the exact event-dispatch function extracted
from the guide window. Extraction strips a UTF-8 BOM where necessary, but does
not rewrite the function. Timers preserve next-cycle semantics.

Client APIs, UI visibility, quest-log state, item data, and server events are
mocked. The quest-choice evaluator is real; the full ItemUpgrades solver is not
under test here. Guide progression and UI refresh sinks are recorded rather than
rendering the full interface. The settings-off case invokes the same
`ResetTransient` contract as the actual settings callback; it does not load
AceConfig. The reward wrapper models secure post-hook ordering, not Questie's
implementation. This cannot certify actual server event order or client visuals.

Run with Lua 5.1 from the repository root:

```sh
lua5.1 tests/quest-automation-audit.lua .
lua5.1 tests/quest-automation-audit.lua . --strict
```

Ordinary mode fails on unexpected regressions and prints each reproduced
baseline defect explicitly. Strict mode also fails if any known defect is
reproduced; this is deliberate, not a clean bill of health. It is not wired into
CI as a permanently failing test. After fixes are authorized, convert defect
probes into ordinary required assertions and integrate the relevant tests.

Current result: **72 passing assertions, five distinct defects reproduced in
14 variants**. These are coordinator-level reproductions, not fresh in-game
reproductions. The existing core Lua suite remains a separate validation.

Validation completed for this audit:

- Existing Lua 5.1 suite: passed, including source filtering, startup, quest-chain,
  and performance regressions.
- Runtime/manifest surface: passed (243 resources, 150 directives, 10 modules).
- Guide validator: passed (50 files, 711 guides, 48,799 steps).
- Quest-flow validator: passed (362 guides, 17,485 branch runs, 1,364 route-matrix
  runs). Its 17 conditional/optional lifecycle notices and 182 entry dependencies
  still require route/server context; they are not new findings from this audit.
- Privacy validator: passed (529 tracked/candidate files).
- Audit strict mode: intentionally rejected the reproduced baseline defects.
- Worktree review: only the new audit test and report; no tracked runtime edits.
- In-game checklist: **not yet performed**. The running server configuration and
  actual Questie/client behavior remain to be verified by the tester.

## Confirmed code-path findings

### QA-01 - Deferred rewards do not recheck temporary automation controls

Severity: medium. Location: `SubmitAutomatedQuestReward` and
`IsRewardTransactionContextCurrent` in `Core/Addon.lua`.

Reproduction: dispatch `QUEST_COMPLETE` for a valid no-choice guide turn-in,
then hold Ctrl, hide the guide, or activate practice before the next scheduler
turn. Each variant still calls `GetQuestReward` once. Direct event dispatch with
these controls already active is correctly blocked.

The submission callback checks guide/step/element/title/panel identity but not
the current automation eligibility. Disabling the master option through the
normal reset path does cancel an already-created transaction; that case passes.

Proposed repair: recheck live eligibility immediately before submission and
cancel only the matching queued transaction if eligibility has changed. Do not
discard authoritative confirmations for a reward already submitted. Revalidate
the originating reward-selection policy as well.

### QA-02 - Item-cache reward retries outlive automation shutdown

Severity: high. Location: `handleQuestComplete` item-data retry in
`Core/Addon.lua`, and reset contracts in `Guide/QuestAutomation.lua`.

Reproduction: open a two-choice reward whose item links are not cached. The
handler schedules a 0.20-second retry before creating a reward transaction.
Disable quest automation and call its normal reset contract, let item data
arrive, then run the retry and following scheduler turn. The reward is submitted
despite the disabled setting. Ctrl, hidden-guide, and practice variants also
reproduce this.

The raw timer calls `handleQuestComplete` directly instead of entering the
central eligibility gate. Its local serial is not invalidated by reset when no
reward transaction exists. The callback also has no captured guide/quest/panel
identity: it evaluates whichever reward panel is visible when it runs.

Guide-reset, zoning, leaving-world, and logout-handler probes show the pending
retry survives those boundaries if a reward panel remains visible. These prove
missing cancellation, not that a real client always preserves the panel or runs
another timer after logout. Actual client teardown can mask the defect.

Proposed repair: make reward-cache retry work keyed and owner-cancelled; capture
the exact interaction identity and recheck controls, choice policy, and context
on every retry. Invalidate it unconditionally on all reset paths, even before a
transaction exists. Preserve the existing finite cache-retry limit.

### QA-03 - Closing a submitted reward interaction can falsely confirm it

Severity: high. Locations: `Observe`/`HasAuthoritativeConfirmation` in
`Guide/QuestRewardTransaction.lua` and settlement reconciliation in `Core/Addon.lua`.

Reproduction: submit a reward, leave the exact quest present in the mocked log,
hide the reward panel, and dispatch `QUEST_FINISHED` without `QUEST_TURNED_IN`.
Reconciliation completes the element and calls `MarkQuestTurnedIn335` anyway.

Every `QUEST_FINISHED` during submission/settlement is considered confirmation.
The coordinator does not reject that signal when refreshed log evidence still
says the quest is active. A rejected reward followed by closing the dialog is
therefore an important real-client scenario to verify; it has not been reproduced
in game in this audit.

Proposed repair: treat `QUEST_FINISHED` as a reconciliation trigger, not sufficient
success evidence by itself. Require the exact turned-in ID, completed-quest
evidence, or validated refreshed disappearance of the submitted quest. If the
quest remains active or evidence is uncertain, retain bounded reconciliation
and leave recovery manual at timeout. Preserve the post-hook event barrier.

### QA-04 - A failed accept can retain an indefinite reservation

Severity: medium. Locations: `ClearExpiredPendingAccept`/`ReconcilePendingAccept`
in `Core/Addon.lua`, acceptance state, and `AutomationOrder:GetQuestReservation`.

Reproduction: select a guide quest through gossip, submit its acceptance, but
provide no acceptance event or matching quest-log entry. After six seconds and
a log refresh, the pending accept expires. Offer a different eligible guide
quest: automatic selection remains blocked by the original submitted reservation.

Unsubmitted selections expire after five seconds; submitted reservations are
retained for explicit coordinator settlement. The acceptance timeout clears its
pending state but not its corresponding submitted reservation. A successful
manual acceptance or full transient reset can clear it.

Proposed repair: add bounded acceptance reconciliation which releases only its
own matching reservation after failed/uncertain acceptance. Do not mark the
quest accepted or skip its guide element, and do not replace a newer interaction.

### QA-05 - Acceptance requests are not deduplicated while unconfirmed

Severity: medium. Location: the `QUEST_DETAIL` branch in `Core/Addon.lua`.

Reproduction: dispatch the same eligible `QUEST_DETAIL` twice before any
acceptance event/log confirmation. The live accept-button callback is invoked
twice. Confirmation deduplication exists, but request deduplication does not.

Proposed repair: suppress another accept request for the same active pending
interaction until it confirms, expires, or is cancelled. Couple this with QA-04
so a failed request cannot permanently suppress a legitimate retry.

## Passing behavior and remaining uncertainty

- Direct automation-off, Ctrl, hidden-guide, and practice gates pass for detail,
  progress, reward, and gossip dispatch.
- Authoritative manual acceptance/turn-in updates guide elements with automation
  disabled. Duplicate acceptance confirmations do not duplicate completion.
- Acceptance index/ID normalization and log-only acceptance reconciliation pass.
- No-choice, single-choice, authored-choice, and calculated vendor-value rewards
  use the expected paths. Disabled reward choice waits for manual input.
- Missing item links do not cause partial reward selection; cache retries stop.
- Nested quest events do not escape the reward barrier. The simulated post-hook
  sees the original title, and both central-first and directive-first event order
  pass using the real directive callback and event barrier.
- Wrong-ID turn-ins and gossip alone do not settle a reward. Log-only disappearance
  and matching-ID confirmation settle it; silent failure times out without
  completing it. API exceptions cancel transaction ownership before propagating.
- Queued transactions cancel on stale title/guide/step/panel and tested lifecycle
  resets. This does not cover the separate pre-transaction retry defect QA-02.
- Reversed NPC offer lists still select the authored Gornek order; the greeting
  selector also selects the turn-in before the following accept.

A deliberately injected nil `IsOnQuest` result also settles as absence. The stock
compatibility facade returns booleans, so this is an uncertain/foreign-API
robustness probe, **not a sixth confirmed stock-client defect**. Empty/stale log
snapshots and collapsed-header behavior still need real-client observation.
The baseline cache validates numeric indices and treats index zero as missing;
that alone does not establish how every server/client UI exposes hidden entries.

Remaining integration checks: actual multi-quest dialog continuation, reward
button visuals, full ItemUpgrades scoring, both addon load orders, localized
dialogs, server animations, and effective server configuration. Do not interpret
mocked success as completion of those checks.

## Fresh Orc Warrior manual checklist

### 0. Prepare without losing progress

1. Use the normal baseline addon, not a staged PR build. These audit files do not
   change its behavior. Create a new Orc Warrior; do not reset an existing run.
2. Enable only RXPGuides, BugGrabber, and BugSack for the first pass. Disable other
   quest helpers. Record client locale, addon revision, and server XP rate.
3. Confirm the server operator's effective `Quests.IgnoreAutoAccept` is `1`.
   Its documented meaning is to suppress database auto-accept flags. No active
   `worldserver.conf` was found beneath the available server source root during
   this audit, so the running value is **not verified**. The previously reported
   change to `1` must not be assumed to persist. Do not change server settings
   merely to hide a failing addon test; establish and record a controlled baseline.
4. If uncertain, use another fresh character with all addons disabled to check
   Kaltunk first. If the quest accepts automatically there, stop the addon-off
   comparison and resolve the server baseline with its operator.
5. Choose **Validated -> RestedXP Horde 1-30 -> 1-6 Durotar**. The loaded source is
   [RestedXP Horde 1-13 Troll-Orc.lua](../Guides/RestedXP%20Horde%201-13%20Troll-Orc.lua),
   not the dormant Classic Durotar source or Original snapshot.
6. Keep Lore mode off, the guide visible, practice off, and quest automation in
   the state requested below. Leave trainer/flight/vendor automation off to reduce
   unrelated activity. Do not manually skip or complete guide elements to make
   a failed test pass.

Relevant English setting labels (localized clients translate them):

| Location | Setting | Purpose |
|---|---|---|
| General -> Automation | Quest auto accept/turn in | Master quest-dialog automation |
| General -> Automation | Quest auto rewards | Reward choices explicitly authored in `.turnin` |
| Tips | Enable Tips | Enables the recommendations system |
| Tips -> Item Upgrade | Enable Item Upgrade | Label combines the client's Enable and Item Upgrade strings |
| Tips -> Item Upgrade | Quest Reward Recommendation | Enables the calculated-choice control in the UI |
| Tips -> Item Upgrade | Quest Reward Automation | Automatically chooses the calculated reward |

The two reward-automation controls are different. The Orc Warrior's tested
Cutting Teeth and Sarkoth directives do **not** specify an authored reward index.
The General reward option alone does not enable automatic calculated selection.

### 1. Kaltunk: disabled, Ctrl, then enabled

1. Turn **Quest auto accept/turn in** off. Leave both reward automation options off.
2. Right-click Kaltunk once. Inspect **Your Place In The World (4641)**.
3. Expected: Accept remains available, quest 4641 is absent from the quest log,
   and its guide accept element remains incomplete. Close with Escape, without
   accepting.
4. Enable the master option. Hold Ctrl continuously while right-clicking Kaltunk
   and inspecting the dialog. Expect the same manual state. Close it before
   releasing Ctrl; releasing Ctrl while it stays open can permit automation.
5. With Ctrl released, right-click again. Expect 4641 to appear in the log and its
   guide accept element to complete once. Record whether the dialog closes or
   changes normally; a stale enabled Accept button is a failure to record.

### 2. Gornek: first turn-in and follow-up

1. Follow the guide to Gornek; keep the master option on. Ignore numeric step
   numbering differences caused by XP/class branches.
2. Right-click once and allow roughly one second for ordinary deferred work.
3. Expected sequence: 4641 turns in, then **Cutting Teeth (788)** is accepted if
   the server keeps/reopens a usable same-NPC dialog. The log loses 4641, gains
   788, and both guide elements complete correctly.
4. If the entire NPC window closes, record that before another click. If it
   remains open with an actionable quest, record what it shows before clicking.
   These distinguish server-required reinteraction from missed continuation.
5. Do not call a manual requirement a reward-choice bug here: no multi-choice
   ItemUpgrades decision is needed for this initial handoff.

### 3. Hana'zua: two different quests called Sarkoth

1. Follow the guide to Hana'zua and accept **Sarkoth (790)**.
2. Kill Sarkoth and loot the required claw. Confirm 790 is ready in the quest log.
3. Right-click Hana'zua once with the master option on.
4. Expect 790 to turn in, followed by acceptance of **Sarkoth (804)**. The title
   remains the same, but the quest ID must change. The 804 quest sends you back
   to Gornek; retain it for the next test.
5. Record stale buttons, missed acceptance, extra clicks, wrong checkmarks, or
   Lua errors before any manual recovery.

### 4. Gornek: mixed order and manual reward control

1. Finish Cutting Teeth's boar objective and retain Sarkoth 804. Follow any other
   intervening guide instructions until the Gornek block is active.
2. Keep master quest automation on, but turn **Quest Reward Automation** off.
   Leave **Quest auto rewards** off too, for an unambiguous manual-choice test.
3. Right-click Gornek. With multiple rewards, Cutting Teeth must wait for your
   selection. Waiting here is correct, not failed quest automation.
4. Choose a reward and click Complete Quest manually. Do not mark the guide row
   complete yourself. Expected: 788 leaves the quest log and its turn-in row
   completes from actual quest confirmation.
5. Observe continuation before touching the NPC again. The exact authored order
   for this character is:
   1. Turn in Cutting Teeth **788**.
   2. Accept Sting of the Scorpid **789**.
   3. Accept Simple Parchment **2383**.
   4. Turn in Sarkoth **804**.
6. Auto-accepts must occur in that order when their dialogs are available. Sarkoth's
   multi-choice reward must still wait for manual choice. Complete it manually and
   verify its guide row updates. Do not demand a single uninterrupted dialog if
   the server actually closes the NPC interaction.

### 5. Fully automatic reward pass and quest-log headers

Use a second fresh Orc Warrior for the full mixed sequence; completed starter
quests cannot simply be repeated. Alternatively test automatic reward selection
on the still-unturned-in 804 from test 4, but that is narrower coverage.

1. Enable the master option plus **Enable Tips**, **Enable Item Upgrade**,
   **Quest Reward Recommendation**, and **Quest Reward Automation**. The separate
   General **Quest auto rewards** option may remain off for this non-authored case.
2. Before the final Gornek visit, open the quest log. Collapse Valley of Trials,
   expand it again, and verify that quests return immediately. Then collapse it
   again and keep it collapsed for the interaction test.
3. Right-click Gornek with both 788 and 804 ready. Expect the same authored order
   as test 4, now with calculated rewards selected when data is ready and a valid
   recommendation exists. Uncached or genuinely uncertain data may require waiting
   or manual choice; record that state rather than forcing a guide checkmark.
4. Reopen the quest log and expand the header. Verify both turn-ins are absent and
   both accepts are present. Record any stuck plus sign, stale rows, or missing
   guide completion independently of the dialog outcome.

### 6. Reload and Questie comparison

1. Between completed NPC interactions, use `/reload`. Confirm the same guide,
   active step, and quest state are restored. A reload must not manufacture another
   reward or acceptance. Do not reload during an outstanding transaction merely
   to hide a failure; first capture its state.
2. Repeat the key sequence on a fresh character with Questie tracking enabled,
   but Questie's own auto-accept and auto-turn-in disabled by the user.
3. Verify Questie's tracker removes turned-in quests and adds accepted ones.
   Record any divergence before closing/reopening dialogs or reloading.
4. A normal installed client provides one actual load order; both load orders
   are not certified merely by this pass. Do not rename addons or alter either
   addon to force a load order without a separate test setup.

### What to send back after each test

```text
Test/checkpoint:
Baseline revision and client locale:
Standalone or Questie tracking:
Master automation / authored rewards / calculated rewards:
Quest log before -> after (IDs):
Guide checkmarks before -> after:
NPC dialog stayed open, changed, or closed:
Additional clicks and what each one did:
Lua errors:
```

Optional read-only diagnostic while a quest panel is open:

```lua
/run print("QID",GetQuestID and GetQuestID(),"TITLE",GetTitleText and GetTitleText(),"CHOICES",GetNumQuestChoices and GetNumQuestChoices())
```

Stock 3.3.5 does not natively provide every modern quest-ID API; the compatibility
ID can be missing or ambiguous, especially for same-title quests. Record it as
evidence, not as proof overriding the quest log and observed handoff. Never share
account names, passwords, full SavedVariables, or unsanitized logs.

## Repair recommendation (not applied)

Address QA-02 and QA-03 first, then QA-01 and the paired acceptance changes
QA-04/QA-05. Keep changes local to ownership, eligibility, confirmation, and
deduplication; do not rewrite guide content or reorder its quest instructions.
Retain all passing transaction/post-hook and manual-progress cases. After an
authorized repair, turn the relevant probes into regression assertions and repeat
the Durotar checklist before claiming the issue resolved in game.
