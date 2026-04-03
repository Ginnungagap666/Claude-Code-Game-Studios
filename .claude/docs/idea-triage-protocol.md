# Idea Triage Protocol

## Purpose

Ideas enter a game project continuously and at wildly different scales — from a
single easter egg to a fundamental design philosophy shift. Without a triage system,
every idea competes for attention on the same channel, large ideas get treated as
small ones, and small ideas get buried under the weight of larger discussions.

This protocol gives every idea a **declared scope**, a **routing path**, and a
**scope-boundary check** before any design or implementation work begins.

---

## The Four Idea Scopes

Every idea filed in `production/idea-backlog.md` must be assigned one of four scopes:

| Scope | Label | Definition | Examples |
|-------|-------|------------|---------|
| **Micro** | `[MICRO]` | Self-contained; touches ≤ 1 system; ≤ 1 sprint; zero seam changes | Easter egg, dialogue tweak, secret room, cosmetic variant |
| **Minor** | `[MINOR]` | Touches 1–2 systems; 1–2 sprints; may add 1 new seam | 3D model viewer in UI, new item type, new enemy variant, new SFX category |
| **Major** | `[MAJOR]` | Touches 3+ systems; 2+ sprints; multiple new seams; design doc required | Landmark system, new-player tutorial, new progression axis, new biome |
| **Pillar** | `[PILLAR]` | Changes how all systems are designed or interact; affects game philosophy | BotW emergent physics, roguelite run structure, social sim layer, "fail forward" design |

**When in doubt, size up.** It is far better to treat a Minor idea as Major than
to discover mid-sprint that it touches six systems.

---

## Routing by Scope

### MICRO
1. File in `production/idea-backlog.md`
2. `creative-director` or `lead-programmer` approves verbally (task comment)
3. Assign to authoring agent; create sprint task
4. No feel review required unless player-facing animation/audio is involved
5. No DEC-NNNN entry required unless it touches a registered seam

### MINOR
1. File in `production/idea-backlog.md` with a one-paragraph design rationale
2. `creative-director` reviews against current game pillars (≤ 1 day)
3. Pillar alignment check required — idea must serve at least one pillar or be explicitly
   justified as infrastructure
4. If approved: create sprint task; if player-facing, follow feel review workflow
5. DEC-NNNN entry required if new seam is introduced

### MAJOR
1. File in `production/idea-backlog.md` with full triage entry (see format below)
2. **Scope boundary check**: compare against current milestone's `Explicitly Out of Scope`
   section in `game-state-snapshots.md`. If it conflicts, auto-defer to next milestone backlog.
3. `creative-director` + `technical-director` review (may take up to 1 sprint)
4. If approved: create a design doc (`design/[system-name].md`) before any implementation
5. Design doc requires human sign-off before implementation begins (feel review for level
   layout; design rationale review for systems)
6. DEC-NNNN entry required; seam lock required before implementation

### PILLAR
1. File in `production/idea-backlog.md` with full triage entry
2. **Mandatory human sign-off** — no agent can approve a Pillar idea unilaterally
3. If approved by human: `creative-director` creates a new Game State Snapshot that
   references the old snapshot and describes the philosophical shift
4. `technical-director` audits all registered seams in `memory/evergreen/core-interfaces.md`
   for compatibility with the new philosophy
5. Integration sprint is triggered immediately after snapshot creation
6. All active sprint tasks are paused and re-evaluated against the new snapshot

---

## Scope Boundary Check

Before any MAJOR or PILLAR idea is approved, it is checked against the current
milestone's scope boundary. The check asks three questions:

1. **Does this idea appear in the `Explicitly Out of Scope` section of the latest
   snapshot?** → If yes: auto-defer to next milestone. No discussion needed.

2. **Does this idea require modifying a `Known Intentional Constraint` from the
   latest snapshot?** → If yes: escalate to `creative-director` + human. Cannot
   proceed without a new snapshot.

3. **Does this idea require 3+ new seams that are not in the current integration plan?**
   → If yes: flag as integration-debt risk; `technical-director` must approve before
   design work begins.

---

## Idea Backlog File: `production/idea-backlog.md`

### Entry Format

```markdown
## IDEA-NNN: [One-line title]

**Scope**: MICRO | MINOR | MAJOR | PILLAR
**Filed by**: [agent name or "human"]
**Date**: YYYY-MM-DD
**Status**: Pending Triage | Approved | Deferred to Milestone N | Rejected | In Progress | Shipped

### What Is the Idea

[Plain language description of the idea. What would the player experience?
Not how it would be implemented.]

### Why Now

[Why is this idea being raised at this point in development? What prompted it?
Was it a feel review finding? A playtest observation? A reference game?]

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
- **Reversible if we don't like it?**: Yes (low cost to revert) | Partial | No (structural)

### Decision

**Outcome**: [Approved / Deferred to Milestone N / Rejected]
**Decided by**: [agent or human]
**Date**: YYYY-MM-DD
**Notes**: [Any conditions, scope limits, or follow-up tasks]
**Related DEC**: [DEC-NNNN if applicable]
```

---

## Deferral vs. Rejection

**Deferral** means: this idea is good but belongs in a later milestone. It stays in
the backlog with `Status: Deferred to Milestone N`. The `producer` reviews deferred
ideas at each milestone boundary and promotes eligible ones to `Pending Triage`.

**Rejection** means: this idea conflicts with a core pillar, introduces scope creep
that would destabilize the current milestone, or is superseded by a better idea.
Rejected ideas stay in the log but are never deleted — they are source material for
future design decisions and prevent the same idea from being re-proposed without context.

---

## Rules for All Agents

1. **Any agent may file an idea.** Ideas are not commitments. Filing is low-cost and
   encouraged. The triage process handles scope, not the filing process.
2. **No agent may begin design or implementation work on a MAJOR or PILLAR idea
   without the triage outcome being Approved.** MICRO and MINOR ideas may begin
   after the `creative-director` acknowledges the filing.
3. **Ideas discovered mid-sprint** (e.g., "I found this interesting emergent interaction")
   are filed immediately as ideas, not implemented unilaterally.
4. **The `producer` reviews `production/idea-backlog.md`** at each sprint review to
   move approved ideas into sprint planning and promote deferred ideas if their
   milestone has arrived.

---

## Anti-Patterns

| Anti-Pattern | Why It Breaks Things |
|---|---|
| Filing a Pillar-scope idea as Micro to avoid process | It gets implemented before anyone understands the downstream impact |
| Implementing an idea before triage completes | Scope creep enters the codebase before anyone can stop it |
| Rejecting ideas permanently because they're "too big right now" | Use Deferral — rejection loses good ideas; deferral preserves them |
| Filing ideas directly as sprint tasks | Sprint tasks must be approved, scoped, and have design docs. Ideas are pre-sprint. |
| Treating every Micro idea as requiring full triage | Micro ideas should flow fast. Over-processing kills creative energy. |
