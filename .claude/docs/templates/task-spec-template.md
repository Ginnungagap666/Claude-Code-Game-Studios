# Task Specification Template

Use this template for every non-trivial task. Small tasks (single-line fixes,
typo corrections) may use a shortened version — but all tasks involving more than
one file MUST use the full template.

---

# Task: [Task Title]

**Task ID**: [sprint-N-taskXX]
**Sprint**: [N]
**Assigned to**: [agent name]
**Filed by**: [agent name]
**Date**: YYYY-MM-DD
**Priority**: [P1 Critical / P2 High / P3 Normal / P4 Low]
**Estimate**: [hours or story points]

---

## Objective

[One paragraph. What does "done" look like from the player's perspective or the
codebase's perspective? Do not describe implementation steps here — describe the
outcome.]

---

## Acceptance Criteria

- [ ] [Specific, testable criterion 1]
- [ ] [Specific, testable criterion 2]
- [ ] [Specific, testable criterion 3]

---

## Implementation Notes

[Optional. Key constraints, approaches to consider, or things to avoid.
If the approach is fully specified, put it here. If open, leave blank and let
the agent propose an approach before implementing.]

---

## Context

**Token budget**: [N tokens — see .claude/docs/context-loading-protocol.md for guidelines]

> The agent MUST NOT load files not listed here (except memory/evergreen/).
> If a new file is needed, add it here with a justification before loading it.

### Always-load (memory/evergreen/)
- memory/evergreen/game-pillars.md
- memory/evergreen/core-interfaces.md
- memory/evergreen/conventions.md

### Task-specific loads

| File | Lines (optional) | Reason |
|------|-----------------|--------|
| [filepath] | [all / L50–L120] | [why this file is needed for this task] |

### Relevant decision-log entries

| ID | Summary |
|----|---------|
| DEC-NNNN | [one-line summary of why this decision is relevant] |

### Explicitly excluded

| File | Reason excluded |
|------|----------------|
| [filepath] | [e.g., "full ADR archive — only active-adrs.md needed"] |

---

## Dependencies

**Blocked by**: [task IDs that must complete first, or "none"]
**Blocks**: [task IDs that cannot start until this completes, or "none"]
**Seam locks required**: [list seams that need a lock, or "none"]

---

## Outputs

On completion, this task must produce:

- [ ] Code changes in `[path]`
- [ ] Updated `memory/current-milestone/sprint-decisions.md` (if a significant decision was made)
- [ ] Updated `production/integration-notes.md` (if a cross-system intersection was found)
- [ ] `TECHNICAL_DONE.md` in `production/feel-review/pending/` (if player-facing)
- [ ] Pipeline registration request (if new commands/events introduced)
- [ ] Seam lock released (if a seam lock was held)

---

## Progress Notes

[The assigned agent fills this section during execution. Record key findings,
decisions made mid-task, files added to context, and any blockers encountered.]

| Date | Note |
|------|------|
| YYYY-MM-DD | [note] |

---

*File this spec in `production/tasks/sprint-N/` before beginning work.*
