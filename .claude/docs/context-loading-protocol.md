# On-Demand Context Loading Protocol

## The Problem

At million-line scale, no agent can or should load the entire codebase into context.
Loading files speculatively wastes tokens on irrelevant code, pushes relevant context
out of the window, and makes session costs unpredictable.

**The solution**: Every task spec explicitly declares its context budget and the exact
files to load. Agents load nothing beyond what the task spec authorizes.

---

## The Rule

> An agent MUST NOT open any file that is not listed in the task spec's `## Context` section,
> unless that file is in `memory/evergreen/` (which is always loaded unconditionally).

If an agent discovers mid-task that it needs an unlisted file, it must:
1. Stop.
2. Add the file to the task spec's `## Context` section with a one-line justification.
3. Note the addition in the task's progress notes.

This creates an audit trail of exactly why each file was accessed.

---

## Task Spec Context Budget

Every task spec includes:

```markdown
## Context

**Token budget**: [estimated tokens for this context load]

### Always-load (from memory/evergreen/)
- memory/evergreen/game-pillars.md
- memory/evergreen/core-interfaces.md
- memory/evergreen/conventions.md

### Task-specific loads
| File | Reason |
|------|--------|
| [filepath] | [one sentence: why this specific file is needed] |

### Explicitly excluded
| File | Reason excluded |
|------|----------------|
| [filepath] | [why an agent might expect to load this but shouldn't] |
```

The "explicitly excluded" section prevents an agent from loading a large file
that might seem relevant but is not necessary for the task at hand.

---

## Token Budget Guidelines

| Task type | Typical context budget |
|-----------|----------------------|
| Single-function bug fix | 2,000 – 5,000 tokens |
| Feature implementation (single system) | 5,000 – 15,000 tokens |
| Cross-system integration task | 10,000 – 25,000 tokens |
| Architecture review | 15,000 – 30,000 tokens |
| Full pipeline audit | 30,000 – 50,000 tokens |

If a task requires more than 50,000 tokens of context, it should be decomposed into
smaller tasks. A task requiring that much context is doing too many things at once.

---

## Context Hygiene Rules

### What to load

- The specific files that define the system being modified
- The specific files that define the seams this task touches
- The relevant section of `memory/current-milestone/active-adrs.md`
- The relevant decision-log entries (by DEC-NNNN ID, not the entire log)

### What NOT to load

- The entire decision log (use grep to find relevant DEC-NNNN entries first)
- Unrelated system files "for context"
- Archive memory unless the task spec explicitly justifies it
- Test files unless the task involves writing or fixing tests
- Documentation files that explain something already known

### Grepping before loading

Before loading a large file, search it first:

```
1. Use Grep to find the specific function/class/section needed.
2. Load only the relevant lines using offset+limit parameters.
3. Justify the line range in the task spec's ## Context section.
```

This technique can reduce a 500-line file to a 30-line load.

---

## Safe vs. Unsafe Compression

When a file must be summarized to fit the budget, follow these rules:

### SAFE to compress (prose context)
- Design rationale paragraphs → 1 bullet point
- Meeting notes → decision outcome only
- Exploration history → final conclusion only
- Lengthy code comments → one-sentence summary

### NEVER compress (precision-critical data)
- Function signatures (name, parameter types, return type)
- State machine transition tables (complete table, not a subset)
- Numeric parameters (all values verbatim — damage, timing, probability)
- File paths and ownership assignments
- Decision log IDs (DEC-NNNN) that are referenced by other entries
- Event/command type names used across system boundaries

Compressing precision-critical data is the primary cause of silent divergence in
large AI-assisted codebases. When in doubt, copy verbatim.

---

## On-Demand Loading Workflow

```
1. producer / lead assigns task → writes full task spec including ## Context section.
2. Agent reads ONLY memory/evergreen/ + files listed in ## Context.
3. Agent discovers a needed file not listed → adds to ## Context + notes why.
4. Agent completes task → task spec (with final ## Context) is archived with the task.
5. producer reviews task specs at sprint end to calibrate future budget estimates.
```

---

## Context Load Anti-patterns

| Anti-pattern | Cost | Fix |
|---|---|---|
| Loading the full decision-log.md every session | ~8,000 tokens wasted | Grep for relevant DEC-NNNN first |
| Loading all ADRs "for context" | ~12,000 tokens wasted | Load only active-adrs.md |
| Loading a system's entire file tree to find one function | ~20,000+ tokens wasted | Grep for the function name first |
| Not listing exclusions in the task spec | Agents silently re-load excluded files | Always write the "explicitly excluded" section |
| Treating evergreen files as optional | Seam drift | Always load all three evergreen files |
