# Design Doc Staleness Detection

## Problem

In fast-moving development, code often evolves faster than design documentation.
An agent implements a new mechanic, adjusts a parameter, or refactors a system —
and the corresponding `design/` document is never updated. Over time, design docs
become "archaeological artifacts": they describe a game that no longer exists.
New agents reading stale docs make decisions based on wrong assumptions, and the
human reviewer approves feel reviews against criteria that were silently abandoned.

Design doc staleness detection makes this drift visible by CI and enforces a
versioning contract between code and documentation.

---

## Staleness Definition

A design document is **stale** when:

1. A source file in its `Covered paths:` list has been modified, AND
2. The design doc has not been updated within **14 calendar days** of that modification, AND
3. No open `staleness-waiver` entry exists for that doc in `production/design-doc-waivers.md`

The 14-day window exists so agents are not forced to update docs for every trivial
tweak. The window is enforced by `.claude/hooks/detect-design-staleness.sh`.

---

## Design Doc Header Format

Every file in `design/` must include a metadata header block. Without this block,
the staleness script treats the doc as unregistered and emits a warning.

```markdown
---
doc-id: DESIGN-NNN
title: [Human-readable title]
owner: [agent name]
version: N
last-reviewed: YYYY-MM-DD
covered-paths:
  - src/[system-a]/**
  - src/[system-b]/[specific-file].gd
staleness-threshold-days: 14
---
```

**Fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `doc-id` | Yes | Unique identifier, DESIGN-NNN format |
| `title` | Yes | Human-readable name |
| `owner` | Yes | Agent responsible for keeping this doc current |
| `version` | Yes | Integer; incremented each time the doc is materially updated |
| `last-reviewed` | Yes | ISO date of last human or agent review |
| `covered-paths` | Yes | Glob patterns; any change to matching files triggers staleness check |
| `staleness-threshold-days` | No | Override per-doc; defaults to 14 |

---

## Versioning Rules

### When to Increment Version

Increment `version` and update `last-reviewed` when any of the following change:

- A design parameter changes (numeric values, probability weights, timing windows)
- A mechanic is added, removed, or meaningfully altered
- The player-facing behavior described in the doc changes
- A feel review produces a signed rejection that leads to rework

**Do NOT increment version for:**
- Typo fixes
- Reformatting
- Adding code cross-references without changing design intent

### Version Log

Append an entry to the doc's `## Version Log` section on every version increment:

```markdown
## Version Log

| Version | Date | Author | Change summary |
|---------|------|--------|----------------|
| 1 | YYYY-MM-DD | [agent] | Initial draft |
| 2 | YYYY-MM-DD | [agent] | Adjusted jump_gravity after feel review rejection FR-007 |
| 3 | YYYY-MM-DD | [agent] | Added coyote-time mechanic per DEC-0042 |
```

### Major vs. Minor Changes

A design doc change is **major** if it alters the design target described in the latest
game state snapshot. A major change requires:
1. A new game state snapshot entry (see `.claude/docs/game-state-snapshots.md`)
2. A DEC-NNNN entry in `.claude/docs/decision-log.md`
3. `creative-director` must be notified before the version is committed

A design doc change is **minor** (parameter tuning, feel rework) if it does not alter
the Core Loop, Experience Target, or Known Intentional Constraints in the snapshot.
Minor changes require no escalation — update the version log and proceed.

---

## CI Hook: `detect-design-staleness.sh`

### Usage

```bash
# Full scan (CI — runs on push to main / integration):
./detect-design-staleness.sh --full

# Single doc (agent — before closing a task that touched covered paths):
./detect-design-staleness.sh --doc DESIGN-NNN
```

### Output

On success (no stale docs): exits `0`.

On stale docs found: exits `1` with a report:

```
STALENESS DETECTED: 2 design doc(s) out of date

  [DESIGN-004] movement-system.md
    Owner:        movement-programmer
    Last reviewed: 2024-01-10
    Days stale:   18 (threshold: 14)
    Triggered by: src/movement/jump_controller.gd modified 2024-01-28
    Action:       Update doc or file a staleness waiver

  [DESIGN-011] inventory-ui.md
    Owner:        ui-programmer
    Last reviewed: 2024-02-01
    Days stale:   15 (threshold: 14)
    Triggered by: src/ui/inventory_panel.gd modified 2024-02-16
    Action:       Update doc or file a staleness waiver
```

---

## Staleness Waivers

Sometimes a doc should legitimately remain unchanged even after covered code changes —
for example, when a code change was a pure refactor that did not alter player-facing
behavior. In that case, file a waiver rather than bumping the doc version.

### Waiver File: `production/design-doc-waivers.md`

```markdown
## WAIVER-NNN: [DESIGN-NNN] — [one-line reason]

**Filed by**: [agent name]
**Date**: YYYY-MM-DD
**Expires**: YYYY-MM-DD (max 30 days)
**Applies to**: DESIGN-NNN
**Reason**: [Why the code change did not affect the design doc]

> "The refactor of `hit_resolver.gd` was a pure extraction of a helper function.
>  No player-facing behavior changed. Design doc remains accurate."
```

If a waiver expires without the staleness being resolved, the CI check resumes
treating the doc as stale.

---

## Agent Response Protocol

When a staleness alert fires:

1. **Read the design doc** — is it actually out of date, or was the code change
   a refactor / implementation detail?
2. **If the doc is out of date**: update it, increment the version, update
   `last-reviewed`, append to Version Log. If the change is major, notify
   `creative-director` and create a game state snapshot entry.
3. **If the doc is accurate and the code change was non-behavioral**: file a
   waiver in `production/design-doc-waivers.md`.
4. **If you are unsure**: do not mark the task complete. Escalate to the doc owner
   listed in the header. Do not file a waiver speculatively.

---

## Design Doc Registry

`memory/evergreen/conventions.md` must include a table listing all DESIGN-NNN IDs and
their corresponding files. The `lead-programmer` updates this table when docs are added
or removed.

---

## Anti-Patterns

| Anti-Pattern | Why It Breaks Things |
|---|---|
| Filing a waiver for every staleness alert | Defeats the system; design rot becomes invisible |
| Bumping `version` without updating content | Version number is meaningless; CI passes but drift continues |
| No `covered-paths` in the header | Staleness detection blind to relevant code changes |
| Updating `last-reviewed` without reading the doc | Silences CI; creates false confidence |
| Major design change without a snapshot entry | Creative drift invisible across milestones |
