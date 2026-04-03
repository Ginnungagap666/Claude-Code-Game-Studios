# Decision Log

The Decision Log is the project's **persistent memory for architectural and design choices**.
Every significant decision made by any agent must be recorded here before implementation begins.

This file survives session crashes, compactions, and agent context resets.
**The log is the authority. The conversation is ephemeral.**

---

## Why This Exists

Without a decision log, agents:
- Repeat the same debates already settled
- Make contradictory choices across sessions (additive stacking vs. multiplicative stacking)
- Lose the *why* behind a design, leaving only the *what*
- Cannot detect when a new change reverses a deliberate past decision

## Log Format

Each entry uses this structure:

```markdown
### DEC-[NNNN]: [Short Title]

- **Date**: YYYY-MM-DD
- **Agent**: [which agent made this decision]
- **Status**: Active | Superseded by DEC-XXXX | Reverted
- **Affects**: [comma-separated list of systems or files]
- **Reversible**: Yes | No
- **Decision**: [The specific choice made, in one sentence.]
- **Reason**: [Why this choice was made over alternatives.]
- **Constraints Respected**: [Which pillars, ADRs, or interfaces this decision honors.]
- **Watch For**: [Specific risks or failure modes to monitor after this decision.]
- **Hypothesis**: [For player-facing decisions: "If [design choice], then [player will
  experience/feel/do X]." Leave blank for purely technical/architectural decisions.]
- **Validation Criteria**: [How to know the hypothesis is true or false. Must be
  specific and testable. Leave blank for non-player-facing decisions.]
- **Validation Status**: Pending | Validated (YYYY-MM-DD) | Invalidated (YYYY-MM-DD) | Deferred | N/A
- **Validation Notes**: [Filled in after hypothesis scan. What was observed?]
```

> **Note on Hypothesis fields**: Required for any decision that changes what the player
> directly experiences (movement, combat, audio, UI, level design, progression).
> Optional (N/A) for purely technical decisions (refactors, tooling, pipeline changes).
> See `.claude/docs/design-hypothesis-protocol.md` for the full validation lifecycle.

---

## Rules for All Agents

1. **Before implementing anything non-trivial**, search this file for entries
   that `Affects` the same systems you are about to touch.
2. **If your change contradicts an Active entry**, stop and escalate to
   `technical-director` (technical) or `creative-director` (design). Do not
   proceed unilaterally.
3. **After each significant implementation decision**, append a new entry.
   Small refactors do not need entries; architectural choices always do.
4. **Superseded entries must never be deleted** — update their `Status` field
   only. History is more valuable than cleanliness.

---

## Decision Entries

<!-- Append new entries below. Newest at the bottom. -->
