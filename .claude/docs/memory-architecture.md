# Layered Memory Architecture

## Overview

At million-line scale, context windows become a scarce resource. This document defines
a four-tier memory system that keeps every agent operating on the smallest possible
relevant context without losing continuity across milestones.

The principle: **agents load O(current milestone), not O(entire project history.**

---

## Memory Tiers

### Tier 1 — Evergreen (always loaded)

**Location**: `memory/evergreen/`
**Size budget**: < 800 tokens combined
**Loaded by**: All agents, every session, unconditionally

| File | Contents |
|------|----------|
| `game-pillars.md` | Core design pillars — the non-negotiable experience targets |
| `core-interfaces.md` | Canonical cross-system interface contracts (seams) — types, signatures |
| `conventions.md` | Naming, file layout, code style rules that affect every file touched |

**Rules**:
- Evergreen files are append-only; deprecate, never delete.
- If an evergreen file exceeds its budget, split it and update this document.
- Only `creative-director` may modify `game-pillars.md`.
- Only `technical-director` may modify `core-interfaces.md`.
- Only `lead-programmer` may modify `conventions.md`.

---

### Tier 2 — Current Milestone (loaded when relevant)

**Location**: `memory/current-milestone/`
**Size budget**: < 3,000 tokens combined
**Loaded by**: Agents working on any task within the active milestone

| File | Contents |
|------|----------|
| `active-adrs.md` | ADRs opened this milestone — decisions still under active consideration |
| `sprint-decisions.md` | Key decisions made in the current sprint (rolled each sprint start) |
| `open-risks.md` | Known risks and unresolved questions for this milestone |

**Rules**:
- At milestone end, `producer` moves all three files to `memory/archive/milestone-N/`.
- Start fresh copies at `memory/current-milestone/` for the next milestone.
- Agents must check `open-risks.md` before beginning any task that touches a listed system.

---

### Tier 3 — Milestone Archive (loaded on-demand only)

**Location**: `memory/archive/milestone-N/`
**Loaded by**: Agents that explicitly need historical context (e.g., debugging a regression)

**Rules**:
- Never load archive memory by default.
- A task spec must explicitly list an archive file in its `## Context` section to justify loading it.
- Archive files are immutable. Corrections go into the current milestone's notes, not back into archive.

---

### Tier 4 — Session (scratch, never persisted)

**Location**: `memory/session/active.md`
**Loaded by**: The agent that creates it, for its own session only

**Rules**:
- Session files are wiped at session end.
- Never reference a session file from a task spec or another agent.
- Use session memory for intermediate working notes only.

---

## Loading Rules for Agents

```
BEFORE starting any task:
  1. Load ALL of memory/evergreen/ (always).
  2. If task is within the active milestone, load memory/current-milestone/.
  3. Load ONLY the files explicitly listed in the task spec's ## Context section.
  4. Do NOT speculatively load other files "just in case".
```

**What this prevents**: An agent working on UI code does not load the combat system's
300-file history. Each agent's working set stays bounded.

---

## Compression Rules

Memory files may be summarized, but the following fields must NEVER be compressed:

- Interface signatures (function names, parameter types, return types)
- State machine transition tables
- Numeric parameters (damage values, timing windows, probability weights)
- File paths and system ownership assignments
- Decision log IDs (DEC-NNNN) referenced by other decisions

Everything else — prose rationale, meeting notes, exploration history — may be
summarized to 1–3 bullet points without material information loss.

---

## Milestone Archive Procedure

At each milestone boundary, `producer` triggers the archive process:

```
1. producer:  Create memory/archive/milestone-N/ directory.
2. producer:  Move memory/current-milestone/*.md → memory/archive/milestone-N/.
3. producer:  Create new empty memory/current-milestone/ files from templates.
4. technical-director: Review memory/evergreen/core-interfaces.md — promote
              any seams that graduated from "current milestone" to "evergreen".
5. creative-director:  Review memory/evergreen/game-pillars.md — update if
              milestone produced any pillar refinements.
6. producer:  Record the archive event in .claude/docs/decision-log.md.
```

The archive hook at `.claude/hooks/milestone-archive.sh` automates step 1–3 when
invoked by `producer`.

---

## Anti-patterns

| Anti-pattern | Why it fails | Correct pattern |
|---|---|---|
| Loading all ADRs every session | O(N) context growth — breaks at milestone 10+ | Only load `active-adrs.md` |
| Editing an archive file to "fix" history | Destroys audit trail | Add a correction note to `sprint-decisions.md` |
| Putting interface contracts in session memory | Lost at session end, causes drift | Put them in `memory/evergreen/core-interfaces.md` |
| Summarizing numeric params for brevity | Wrong values propagate silently | Always copy numeric params verbatim |
