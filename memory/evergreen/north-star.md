# North Star Document

> **Owner**: creative-director (writes and revises)
> **Tier**: Evergreen — always loaded, never deleted, append-only
> **Modified by**: creative-director only, with mandatory human sign-off
> **See also**: `memory/evergreen/game-pillars.md` (what the game is)
>
> This file answers a different question than game-pillars.md.
> Pillars describe **what the player experiences**.
> The North Star describes **how systems are designed to interact with each other**
> to produce that experience.

---

## What This File Is For

Some games feel "alive" in a way that is hard to articulate. Objects behave like
real objects. Systems respond to each other honestly. Players discover behaviors
the developers never explicitly scripted.

This happens when systems are designed from a shared philosophy — an implicit
agreement about *how systems should sense, respond to, and affect each other*.

The North Star captures that philosophy. It is not a feature list. It is not a
style guide. It is a set of **system interaction principles** that all agents
consult when designing seams, writing contracts, and making decisions about how
one system should respond to another.

---

## How These Principles Are Created

**North Star principles are never invented at project start.**

They are **discovered through iteration**: an agent or human notices that two
systems interacting in an unexpected way produced something genuinely interesting.
That observation becomes an `EMERGENT_DISCOVERY.md`. The human confirms it as a
feature, not a bug. When this happens three or more times with the same underlying
pattern, the creative-director extracts the pattern, names it, and promotes it to
this document.

This means the North Star is **inductively built**, not deductively designed.
It describes what the game has *revealed itself to want to be*.

---

## How These Principles Are Used

Every seam design (registered in `memory/evergreen/core-interfaces.md`) must
include a line in its `contract.md`:

```
North Star alignment: [Which principle(s) this seam upholds, or "N/A — infrastructure seam"]
```

When an agent is designing a new seam or reviewing a contract change request (CCR),
they check: does this seam design respect the principles below? A seam that actively
contradicts a North Star principle requires escalation to `creative-director` before
the seam is registered.

---

## Principle Format

```markdown
### NS-NNN: [Principle Name]

**Inducted**: YYYY-MM-DD
**Inducted from**: [EMERGENT-NNN, EMERGENT-NNN, ...] — the discoveries that produced this principle
**Status**: Active | Retired (YYYY-MM-DD, see NS-NNN)

**Statement**:
[One to three sentences. What must be true of every system interaction that falls
under this principle? Written as a design constraint, not a feature description.]

**What this enables**:
[What player experiences become possible when systems follow this principle?]

**What this prevents**:
[What design choices are incompatible with this principle? Be concrete.]

**Design test**:
[How do you know if a seam or system interaction upholds this principle?
One sentence that an agent can apply to their own work.]
```

---

## North Star Principles

*(No principles yet. The first principles will be inducted after the first three
confirmed emergent discoveries. See `production/emergent-discoveries/` and
`.claude/docs/emergent-design-protocol.md` for the discovery and induction process.)*

---

## Principle Retirement

A North Star principle is **retired** (never deleted) when:

1. The game's design philosophy has fundamentally shifted (PILLAR-scope change approved
   by human), OR
2. The principle has been superseded by a more precise formulation (new NS-NNN created
   that explicitly replaces it)

A retired principle has its `Status` field updated and is linked to its successor.
Future agents must not apply retired principles, but the record is preserved so the
reasoning behind past seam designs remains understandable.

---

## Relationship to Other Documents

| Document | What it captures |
|----------|-----------------|
| `game-pillars.md` | The player's *experience* — what they should feel |
| `north-star.md` (this file) | The *design philosophy* — how systems interact to produce that experience |
| `core-interfaces.md` | The *interface contracts* — the specific seams that implement the philosophy |
| `game-state-snapshots.md` | The *current state* — what the game is right now |
| `emergent-discoveries/` | The *raw material* — specific observed behaviors that may become principles |
