# Idea Backlog

> **Owner**: producer (reviews, triages); any agent or human (files)
> **Reviewed**: At every sprint review and milestone boundary.
>
> Protocol: `.claude/docs/idea-triage-protocol.md`

---

## Purpose

This is the single entry point for all ideas, regardless of scope. An idea is not
a commitment. Filing is cheap and encouraged. The triage process determines scope,
routing, and timing — not the filing process.

**Do not implement an idea before its triage outcome is Approved.**

---

## Quick Scope Reference

| Scope | What it means | Approval needed |
|-------|--------------|-----------------|
| `[MICRO]` | ≤ 1 system, ≤ 1 sprint, no seam changes | creative-director acknowledges |
| `[MINOR]` | 1–2 systems, 1–2 sprints, ≤ 1 new seam | creative-director reviews pillar alignment |
| `[MAJOR]` | 3+ systems, 2+ sprints, multiple seams | creative-director + technical-director; scope boundary check |
| `[PILLAR]` | Changes design philosophy for all systems | Human sign-off mandatory; triggers new snapshot |

---

## Pending Triage

*(Ideas filed but not yet reviewed. Producer triages at each sprint review.)*

---

## Approved

*(Triage complete; assigned to a milestone or sprint.)*

---

## Deferred

*(Good idea; wrong milestone. Producer re-evaluates at each milestone boundary.)*

---

## Rejected

*(Conflicts with pillars, duplicates a better idea, or structurally incompatible.
Never deleted — preserved as design memory.)*

---

## Shipped

*(Implemented and validated. Kept for reference.)*

---

## Entry Template

```markdown
## IDEA-NNN: [One-line title]

**Scope**: MICRO | MINOR | MAJOR | PILLAR
**Filed by**: [agent name or "human"]
**Date**: YYYY-MM-DD
**Status**: Pending Triage | Approved | Deferred to Milestone N | Rejected | In Progress | Shipped

### What Is the Idea

[Plain language. What would the player experience?]

### Why Now

[What prompted this? Feel review finding, playtest, reference game, emergent discovery?]

### Pillar Alignment

| Pillar | Does this idea serve it? |
|--------|--------------------------|
| [Pillar 1] | ✅ / ❌ / Neutral — [one sentence] |
| [Pillar 2] | ✅ / ❌ / Neutral — [one sentence] |

### Scope Boundary Check (MAJOR and PILLAR only)

- Conflicts with Out of Scope? ☐ Yes → auto-defer  ☐ No
- Requires modifying Intentional Constraints? ☐ Yes → escalate  ☐ No
- Requires 3+ new seams? ☐ Yes → flag  ☐ No

### Estimated Impact

- **Systems touched**: [list]
- **New seams required**: [count and names]
- **Sprints estimated**: [N]
- **Reversible?**: Yes | Partial | No

### Decision

**Outcome**: [Approved / Deferred to Milestone N / Rejected]
**Decided by**: [agent or human]
**Date**: YYYY-MM-DD
**Notes**: [Conditions, scope limits, follow-up tasks]
**Related DEC**: [DEC-NNNN if applicable]
```
