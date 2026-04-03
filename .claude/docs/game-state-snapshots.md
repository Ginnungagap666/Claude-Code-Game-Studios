# Game State Snapshots

A Game State Snapshot captures the **current design intent and experiential targets**
of the game at a point in time. It is not a git tag or a build artifact — it is
a structured record of what the game is *supposed to feel like* and what the known
state of its systems is.

Snapshots prevent "design drift": the gradual process by which agent optimizations,
bug fixes, and feature additions incrementally shift the game away from its intended
experience without anyone noticing.

---

## When to Create a Snapshot

- At the start of the project (initial snapshot)
- At each milestone (Alpha, Beta, Release Candidate)
- Before any major system refactor
- Whenever the `creative-director` or `technical-director` issues a significant
  direction change

Snapshots are **append-only**. Never edit a past snapshot. If the game's direction
changes, create a new snapshot that explicitly references what it supersedes.

---

## Snapshot Format

```markdown
# Snapshot: [Name]

**ID**: SNAP-[NNNN]
**Date**: YYYY-MM-DD
**Created by**: [agent or human]
**Supersedes**: SNAP-[previous ID] | (none — initial snapshot)
**Milestone**: [Alpha / Beta / Sprint N / etc.]

---

## Core Loop

[One paragraph describing the primary loop in experiential terms — what the player
DOES and what they FEEL doing it. No feature lists. No technical terms.]

Example: "The player plants crops in the morning, tends to relationships in the
afternoon, and processes the day's results in the evening. The loop should feel
like a gentle rhythm with occasional moments of meaningful surprise — finding
a new recipe, receiving an unexpected letter, discovering a secret path."

---

## Experience Targets

[2-5 concrete, testable experience targets. These are moments, not features.]

1. **[Target Name]**: [Specific moment the player should have. "After the first
   30 minutes, the player should feel like they belong in this world, not like
   they are learning a tutorial."]
2. **[Target Name]**: [etc.]

---

## Feel Anchors

[Reference games or moments that define correct feel for key systems. Agents
use these when writing feel review questions.]

| System | Feel Anchor | What to Capture |
|--------|-------------|-----------------|
| [System] | [Game/moment] | [Specific quality] |

---

## Balance State

[Current numeric targets for key balance parameters. These are design intents,
not hard constraints — they help agents avoid making changes that silently break
balance.]

| Parameter | Current Target | Acceptable Range | Notes |
|-----------|---------------|-----------------|-------|

---

## Known Intentional Constraints

[Things that must NOT change without a new snapshot. These are the "sacred cows"
of the current design phase.]

- [Constraint 1: what it is and why it must be preserved]
- [Constraint 2]

---

## Known Open Issues

[Issues that are known, accepted for now, and should not be accidentally "fixed"
in a way that causes other problems.]

- [Issue 1: what it is and why it is deferred]

---

## Explicitly Out of Scope

[Features, systems, and directions that are **intentionally excluded** from this
milestone. This is not a list of bad ideas — it is a boundary declaration. Items
here may be revisited in a future milestone. Agents must not begin work on any
item listed here without first escalating to the `producer`.]

**Format**: Each entry states what is excluded and why — whether the reason is
timing, resource constraints, design uncertainty, or deliberate deferral.

- [Item 1: what is excluded, and why it is out of scope for this milestone]
- [Item 2]

**Effect on Idea Triage**: Any MAJOR or PILLAR scope idea that requires implementing
a system listed here is automatically deferred to the next milestone, regardless of
other merits. See `.claude/docs/idea-triage-protocol.md` for the scope boundary
check procedure.

---

## Diff from Previous Snapshot

[Only for non-initial snapshots. What changed from SNAP-[previous] and why.]

- **Changed**: [What is different and the reason for the change]
- **Removed**: [What was intentionally removed from the design]
- **Added**: [What new targets or constraints were introduced]
```

---

## Rules for All Agents

1. **Before any major refactor**, read the most recent snapshot. If your work
   would alter a Core Loop, Experience Target, or Known Intentional Constraint,
   stop and raise the question with `creative-director` before proceeding.

2. **After any milestone**, the `producer` requests a new snapshot from
   `creative-director` and `technical-director` before the next milestone work begins.

3. **The snapshot is not a straitjacket** — games evolve. But evolution should
   be deliberate and recorded, not accidental.

---

## Snapshot Index

| ID | Name | Date | Milestone | Supersedes |
|----|------|------|-----------|------------|
| SNAP-0001 | Initial | *(project start)* | Pre-Alpha | — |

---

## Snapshot Entries

<!-- Append new snapshots below. Oldest first. -->
