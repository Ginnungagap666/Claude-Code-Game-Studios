# Evergreen Audit Protocol

## What This Is

Every file in `memory/evergreen/` is loaded unconditionally at the start of
every agent session. This is the right default — agents need shared vocabulary
and invariants. But over 30, 50, or 100 sprints, the evergreen layer accumulates
**zombie knowledge**: facts that were once true, decisions that have since been
superseded, constraints that no longer apply, and principles that drifted from
practice so long ago that agents no longer recognize them as relevant.

Zombie knowledge is not harmless. It costs tokens in every session. More
importantly, it misleads agents: a constraint that was lifted in Milestone 4
but is still in the evergreen layer will cause agents in Milestone 8 to work
around a ghost wall.

An Evergreen Audit is a structured, periodic review that asks:
**"Is every fact in `memory/evergreen/` still true and actively used?"**

---

## When Audits Run

| Trigger | Action |
|---------|--------|
| End of every second milestone | Producer schedules an evergreen audit |
| After any PILLAR-scope idea is approved | Immediate audit of affected evergreen files |
| After a Game State Snapshot is superseded | Audit any evergreen entries that referenced the old snapshot |
| Total size of `memory/evergreen/` exceeds 1,200 tokens | Producer calls an early audit |
| Human requests one | Runs within 1 sprint |

> **Why 1,200 tokens?** The evergreen layer is designed to stay under 800 tokens.
> 1,200 is the hard ceiling: above this, session startup context consumption
> measurably degrades agent reasoning quality.

---

## Audit Scope

The audit covers all files in `memory/evergreen/`:

| File | What to check |
|------|--------------|
| `game-pillars.md` | Are the pillars still the pillars? Any PILLAR-scope changes since last audit? |
| `north-star.md` | Are all Active principles still reflected in actual seam designs? Any retired but not marked? |
| `core-interfaces.md` | Are all registered seams still in use? Any signatures that have drifted? |
| `game-state-snapshots.md` | Is the current snapshot still current? Is a superseded snapshot referenced as if active? |
| Any other evergreen files | Does each file still accurately describe the current state of the project? |

---

## The Three Audit Questions

For every entry, section, or principle in every evergreen file, ask:

### Question 1 — Is it still true?
Has the underlying fact, decision, or constraint changed since this was last
written? If a DEC-NNNN entry superseded it, if a PILLAR-scope approval changed
it, or if actual game code diverged from it, the entry is stale.

### Question 2 — Is it still used?
Do agents actively consult this fact? An entry that has never been referenced
in a task spec, a seam design, or an agent decision in the last two milestones
is a candidate for retirement — not because it is wrong, but because it is
not earning its context cost.

### Question 3 — Is it in the right tier?
Some evergreen facts belong in `memory/current-milestone/` — they are true
now but will change soon. Some facts that were demoted to archive have become
universally applicable again. Tier membership should be re-evaluated at each audit.

---

## Output: Evergreen Audit Report

Filed at `production/evergreen-audits/EAR-NNN-milestone-[N].md`:

```markdown
# Evergreen Audit Report: EAR-NNN

**Milestone**: [N]
**Date**: YYYY-MM-DD
**Conducted by**: producer + creative-director
**Previous audit**: EAR-[NNN-1] | (none — first audit)
**Evergreen token count before audit**: [estimated tokens]
**Evergreen token count after audit**: [estimated tokens]

---

## Summary

| File | Status | Action Taken |
|------|--------|-------------|
| game-pillars.md | ✅ Current | No changes |
| north-star.md | ⚠️ Stale entry | NS-002 retired (see below) |
| core-interfaces.md | ⚠️ Zombie seam | SEAM-004 removed (decommissioned) |
| game-state-snapshots.md | ✅ Current | No changes |

---

## Retired Entries

### [Entry ID or section title]

**File**: [which evergreen file]
**Reason for retirement**: [still true but unused / superseded by DEC-NNNN / PILLAR change / etc.]
**Action**: Moved to `memory/archive/evergreen-retired/[filename]` section tagged `RETIRED-MILESTONE-N`
**Was referenced by**: [any task specs, seam contracts, or DEC entries that pointed to this]
**Follow-up needed**: [Yes — update SEAM-NNN contract / No]

---

## Tier Changes

### [Entry ID or section title]

**From**: evergreen
**To**: current-milestone | archive
**Reason**: [Why this fact no longer needs to be in evergreen]

---

## Entries Confirmed Current

[List entries verified as accurate and actively relevant — one line each]

---

## Human Sign-Off

**Assessment**: ☐ Evergreen layer is clean  ☐ Monitor growth  ☐ Further pruning needed

**Signed by**: _______________
**Date**: _______________
**Notes**: _______________
```

---

## Retirement Procedure

When an entry is retired:

1. **Do not delete it.** Move the content to `memory/archive/evergreen-retired/`
   in a file named `[source-file]-retired-entries.md`. Append to this file;
   do not overwrite.
2. **Tag the archived entry** with `<!-- RETIRED: Milestone N, YYYY-MM-DD, Reason: [one line] -->`.
3. **Update any references.** Search all task specs and agent instructions that
   reference the retired entry. Update them to reflect the new state.
4. **Log in EAR-NNN.** The audit report is the permanent record of what was
   retired and why.

> **Retirement is not deletion.** A retired evergreen principle may be reinstated
> if circumstances change. The archive preserves the reasoning so future agents
> can understand why the principle existed and why it was retired.

---

## Growth Prevention Rules

These rules apply at all times — not just during audits:

1. **New evergreen entries require justification.** When adding anything to
   `memory/evergreen/`, the proposing agent must write a one-sentence justification:
   "This belongs in evergreen because agents need it in every session because ___."
   If the sentence cannot be completed honestly, the entry does not belong in evergreen.

2. **Evergreen is for invariants, not current state.** Facts that will change
   within two milestones do not belong in evergreen. They belong in
   `memory/current-milestone/`.

3. **Summaries live in current-milestone, details in archive.** Evergreen entries
   should be summaries or pointers, not full specifications. If an evergreen file
   is growing with details, the details belong in a design doc or in archive.

4. **One-in-one-out rule during high-token periods.** If the evergreen layer is
   above 800 tokens, no new entry may be added without retiring an existing entry
   of equal or greater size.

---

## Rules for All Agents

1. **Never add to evergreen without the justification sentence.** The friction
   is intentional. Evergreen is not a scratch pad.
2. **Flag zombie knowledge when you encounter it.** If, during normal work, you
   read an evergreen entry and think "this doesn't seem right anymore," append
   a note to `production/integration-notes.md` tagged `evergreen-suspect: [file]:[section]`.
   The next audit will resolve it.
3. **Do not wait for the audit to retire obvious zombies.** If an evergreen entry
   references a system that no longer exists, the `technical-director` may retire
   it immediately. Record the retirement in `production/integration-notes.md`.
4. **Audit reports are not optional.** If a milestone ends and no audit report
   has been filed in the last two milestones, the producer must call an audit
   before the next milestone begins.

---

## Anti-Patterns

| Anti-Pattern | Why It Breaks Things |
|---|---|
| Using evergreen as a project-wide reference library | Evergreen is loaded every session; reference docs belong in `design/` or `memory/archive/` |
| Retiring entries during active sprints | Wait for the audit cycle; premature retirement during a sprint can break in-progress task specs |
| Adding temporary sprint notes to evergreen | Sprint notes belong in `memory/current-milestone/`; they are not invariants |
| Auditing only the content, not the token count | An entry can be accurate and still too expensive; size is a valid retirement reason |
