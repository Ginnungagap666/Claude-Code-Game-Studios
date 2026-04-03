# Design Hypothesis Validation Protocol

## Problem

The current workflow records *what was decided* (decision-log.md) and *what was built*
(TECHNICAL_DONE.md), and even asks humans to judge *how it feels* (feel-review). But
it never asks: **did this design decision achieve what it was supposed to achieve?**

A design hypothesis is the assumption embedded in every non-trivial design decision:
"If we do X, the player will experience Y." Without a protocol to revisit and test that
assumption, the team accumulates decisions that passed feel review but never got
validated against their original intent — especially as the game grows and context
changes around them.

This is not about whether the feature works. It is about whether **the design reasoning
was correct**.

---

## Hypothesis Lifecycle

```
FILE (with DEC-NNNN)  →  IMPLEMENT  →  FEEL REVIEW  →  HYPOTHESIS SCAN  →  VALIDATE / INVALIDATE
```

Every DEC-NNNN that carries a `Hypothesis` field enters this lifecycle. The hypothesis
scan runs at each milestone boundary. Validation is handled by the `aesthetic-reviewer`
in coordination with the human reviewer.

---

## Adding a Hypothesis to a Decision Entry

Any DEC-NNNN entry for a player-facing design decision **must** include two new fields:

```markdown
### DEC-[NNNN]: [Short Title]

- **Date**: YYYY-MM-DD
- **Agent**: [agent name]
- **Status**: Active | Superseded by DEC-XXXX | Reverted
- **Affects**: [systems]
- **Reversible**: Yes | No
- **Decision**: [The specific choice, one sentence.]
- **Reason**: [Why this choice was made.]
- **Constraints Respected**: [Pillars, ADRs, interfaces honored.]
- **Watch For**: [Risks to monitor.]
- **Hypothesis**: [The assumption this decision rests on. Format:
  "If [design choice], then [player will experience/feel/do X]."
  Example: "If jump hold duration is 3–5 frames, then players will feel
  forgiven for mistimed jumps rather than punished."]
- **Validation Criteria**: [How to know the hypothesis is true or false.
  Must be specific and testable — not "feels good" but measurable proxies
  and observable player behaviors.
  Example: "Feel review passes the 'forgiven vs punished' question AND
  measured retry rate after failure < baseline from SNAP-0001 balance state."]
- **Validation Status**: Pending | Validated (YYYY-MM-DD) | Invalidated (YYYY-MM-DD) | Deferred
- **Validation Notes**: [Filled in after validation scan. What was observed?
  If invalidated, what was the actual player experience?]
```

---

## Hypothesis Scan Protocol

The `producer` triggers a Hypothesis Scan at the end of every milestone.

### Step 1 — Build the Scan List

The `producer` queries `decision-log.md` for all entries where:
- `Validation Status` is `Pending`, AND
- The DEC entry is older than 1 sprint (recently filed decisions get one sprint of
  operational time before hypothesis testing begins)

### Step 2 — Triage Scan Items

For each Pending entry, classify:

| Classification | Criteria | Action |
|---------------|----------|--------|
| **Active** | The system is still in the game as designed | Schedule for validation this milestone |
| **Superseded** | The system has been replaced or significantly changed | Mark `Deferred` — validate the new decision instead |
| **Micro-scope** | The decision was architectural / non-player-facing | Mark `Deferred` — no hypothesis to validate |

### Step 3 — Assign Validation Tasks

For each Active item, the `aesthetic-reviewer` creates a `HYPOTHESIS_VALIDATION_NEEDED.md`
file in `production/feel-review/pending/`:

```markdown
# Hypothesis Validation: DEC-[NNNN] — [Title]

**Filed by**: aesthetic-reviewer
**Date**: YYYY-MM-DD
**Sprint / Milestone**: [N]
**Decision**: [Copy the Decision field verbatim]
**Hypothesis**: [Copy the Hypothesis field verbatim]
**Validation Criteria**: [Copy the Validation Criteria field verbatim]

---

## How to Validate

[Specific steps: what to do in-game, what to measure, what to look for.
Authored by aesthetic-reviewer based on the Validation Criteria.]

## Quantitative Checks (if applicable)

| Metric | Target from DEC entry | Measured value | Pass? |
|--------|----------------------|----------------|-------|
| [e.g., retry rate] | [e.g., < baseline] | ___ | ✅ / ❌ |

## Qualitative Check

[The specific feel question to answer — maps to the Hypothesis statement.]

- ✅ / ❌ / Notes: _______________

---

## Outcome

**Hypothesis**: ☐ Validated  ☐ Invalidated  ☐ Partially validated (see notes)

**Signed by**: _______________
**Date**: _______________

### Notes

[If invalidated: what was the actual experience? Be concrete. The agent responsible
for the original decision will use this to create a rework task.]
```

### Step 4 — Update Decision Log

After human sign-off, the `aesthetic-reviewer` updates the originating DEC-NNNN entry:
- Set `Validation Status` to `Validated` or `Invalidated` with the date
- Add a summary to `Validation Notes`
- If invalidated: file a new IDEA-NNN in the idea backlog (scope MINOR or MAJOR)
  describing the rework needed

---

## What Invalidation Means

Invalidation is not failure. It is information.

An invalidated hypothesis means the design reasoning was incorrect. The implementation
may have been technically perfect. The player experience may even have been acceptable.
But the *reason* the decision was made turned out to be wrong.

This matters for the long-term health of the codebase because:
- Future agents will read the DEC entry and believe the reasoning is sound
- They may make new decisions that depend on that reasoning
- If the reasoning was wrong, dependent decisions inherit the error

**An invalidated hypothesis must be marked clearly so future agents do not
build on a false premise.**

---

## Hypothesis Quality Guidelines

### Good Hypotheses

- Specific: "players will feel X" not "the game will be better"
- Falsifiable: there exists a possible observation that would prove it wrong
- Anchored: references a feel anchor game, a pillar, or a snapshot experience target
- Bounded: applies to a specific system or interaction, not the whole game

### Bad Hypotheses (do not accept these)

| Bad | Problem | Better |
|-----|---------|--------|
| "This will feel good" | Not falsifiable | "Players will choose to use this mechanic voluntarily after learning it" |
| "This is the right design" | Circular | "Players will feel powerful without feeling unfairly disadvantaged" |
| "Trust me, it works" | Not a hypothesis at all | Write the actual assumption |
| "The player will probably enjoy it" | No validation criteria possible | "In playtesting, players will express surprise-delight, not frustration" |

---

## Integration with Other Protocols

- **Decision Log**: Hypothesis fields are added to DEC-NNNN entries. This file defines
  the fields and lifecycle; `decision-log.md` is the storage.
- **Feel Review**: Hypothesis validation uses the same human sign-off queue and file
  format as feel reviews, but the question is "was the design reasoning correct?"
  rather than "does this feel good right now?"
- **Idea Triage**: Invalidated hypotheses automatically generate IDEA-NNN entries in
  the triage backlog. The scope of the new idea is determined by the severity of
  the invalidation.
- **Game State Snapshots**: If a hypothesis invalidation reveals that a Core Loop or
  Experience Target was based on a wrong assumption, the `creative-director` must
  create a new snapshot before rework begins.

---

## Rules for All Agents

1. **Every player-facing DEC-NNNN entry must include a Hypothesis and Validation
   Criteria.** Entries without these fields are incomplete. The `producer` will
   return them for completion before the sprint closes.
2. **Do not validate your own hypothesis.** The agent that filed the DEC entry
   should not be the one determining whether the hypothesis was correct. The
   `aesthetic-reviewer` mediates; the human reviewer has final say.
3. **Invalidation is not a blame event.** Design hypotheses fail. This is normal.
   Do not soften or hedge invalidation findings to protect the original decision.
   Future agents depend on honest records.
4. **Deferred hypotheses are not forgotten.** The `producer` reviews all Deferred
   entries at each milestone boundary and promotes them to Active if the system
   has stabilized enough to be testable.
