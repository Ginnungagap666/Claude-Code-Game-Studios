# Pipeline Registration Request: [Feature Name]

**Requesting agent**: [agent name]
**Date**: YYYY-MM-DD
**Sprint**: [N]
**Related task**: [sprint task ID]

---

## What is Being Added

[One paragraph describing the new command, event, trigger, or modifier in plain
language. What does it do from the player's perspective? What does it do technically?]

---

## Execution Timing

| Field | Value |
|-------|-------|
| **When should this fire** | [before damage / after scoring / on card played / on turn start / etc.] |
| **Priority tier requested** | [see `design/systems/command-pipeline.md` for tier definitions] |
| **Game states where valid** | [list of states from `design/systems/game-state-machine.md`] |
| **What this reads from game state** | [list of state fields accessed — be specific] |
| **What this writes to game state** | [list of state fields modified — be specific] |

---

## Trigger Analysis

**Can this trigger itself (direct loop)?**
- [ ] Yes — [explain the exact path and proposed guard]
- [ ] No — [explain why not]

**Can this trigger another effect that could re-trigger this (indirect loop)?**
- [ ] Yes — [explain the path and proposed guard]
- [ ] No — [explain why not]

**Maximum expected chain depth**: [N steps]
**Worst-case chain scenario**: [Describe the longest realistic trigger chain this
could be part of, including all known participating effects]

---

## Interaction Survey

List any existing registered effects that fire at the same priority tier or hook
point, and describe whether their interaction is intentional:

| Existing Effect | Interaction | Intended? |
|-----------------|-------------|-----------|
| [effect name] | [what happens when both fire] | Yes / No / Unknown |

---

## Alternatives Considered

**Why this timing over other timing options?**
[Explain why this hook point and priority tier were chosen. What breaks if this fires
earlier? What breaks if it fires later?]

---

## Checklist (filled by `command-pipeline-guardian`)

- [ ] No priority collision with existing effects at this tier
- [ ] No direct infinite loop path identified
- [ ] No indirect infinite loop path identified
- [ ] Valid in all declared game states
- [ ] State writes do not conflict with other effects at this hook point
- [ ] `design/systems/command-pipeline.md` updated with this registration
- [ ] `design/systems/game-state-machine.md` updated if new state transitions needed

**Guardian decision**:
- ☐ **Approved** — move to `approved/`
- ☐ **Rejected** — see notes below, move to `rejected/`
- ☐ **Escalated to `technical-director`** — reason below

**Notes**: _______________
**Date reviewed**: _______________

---

*Submit this file to `production/pipeline-requests/pending/` before implementing
the feature. Do not implement until the guardian approves.*
