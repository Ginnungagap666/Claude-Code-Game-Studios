# Feel Review Workflow

## The Core Principle

**AI can verify logic. Only humans can verify feel.**

Agents are responsible for technical correctness: does the code compile, do the tests
pass, are the interfaces respected? Agents cannot judge whether a jump feels good,
whether an animation communicates the right emotion, or whether a level layout creates
the intended tension. That judgment belongs to the human developer.

This workflow creates a structured, file-based handoff — like a boss signing off on a
document — so that feel decisions are never skipped, never blocked waiting for a
synchronous conversation, and never confused with technical tasks.

---

## The Two Reports

Every time an agent completes work that a player will directly experience, it produces
**two separate output documents**:

### 1. `TECHNICAL_DONE.md`

Written by the agent. No human review needed unless a test fails.

Contains:
- What was implemented
- Test results (pass/fail with counts)
- Interface contracts verified
- Performance budget check
- No regressions confirmed

### 2. `FEEL_REVIEW_NEEDED.md`

Written by the agent. **Requires human sign-off before the feature is considered done.**

Contains:
- A plain-language description of the experience to evaluate
- Specific questions the human should answer while playing/reviewing
- The context of what "correct" feel means (reference games, design pillars)
- A sign-off block at the bottom for the human to fill in

---

## File Locations

```
production/
  feel-review/
    pending/        ← Agents write new FEEL_REVIEW_NEEDED.md files here
    signed/         ← Human moves files here after signing off
    rejected/       ← Human moves files here if rework is needed, with notes
```

No agent may mark a feature "complete" in the sprint plan while its feel review
file remains in `pending/`. The `producer` agent enforces this during sprint status.

---

## FEEL_REVIEW_NEEDED.md Template

```markdown
# Feel Review: [Feature Name]

**Filed by**: [agent name]
**Date**: YYYY-MM-DD
**Related task**: [sprint task ID]
**Related files**: [comma-separated list of files changed]

---

## What Was Built

[One paragraph describing the feature in non-technical language — what the player
experiences, not how the code works.]

---

## What to Evaluate

Please test the following and answer each question:

1. **[Question 1]**
   - What to look for: [specific behavior to observe]
   - Reference: [game or moment that captures correct feel, e.g., "Celeste coyote
     jump — the player should feel forgiven, not punished"]
   - ✅ / ❌ / Notes: _______________

2. **[Question 2]**
   - What to look for: [specific behavior]
   - Reference: [reference]
   - ✅ / ❌ / Notes: _______________

3. **[Question 3]**
   - What to look for: [specific behavior]
   - Reference: [reference]
   - ✅ / ❌ / Notes: _______________

---

## Pillar Alignment Check

- **Pillar [N]** ("[Pillar name]"): Does this feature serve the pillar?
  - Evaluation: _______________

---

## Sign-Off

**Decision**: ☐ Approved  ☐ Approved with minor notes  ☐ Rejected — rework needed

**Signed by**: _______________
**Date**: _______________

**Notes for rework** (if rejected):
[Human writes specific, actionable feedback here. Agents will read this to
understand exactly what to change.]
```

---

## Level Design and Layout Reviews

Level design documents are a special case. The `level-designer` agent designs
the spatial logic and encounter structure — but the human developer must review:

- Whether the intended emotional pacing is actually created by the layout
- Whether the visual language communicates the intended meaning
- Whether the difficulty curve matches the design doc target

After the level-designer produces a level document (`design/levels/[name].md`),
it automatically generates a feel review in `production/feel-review/pending/`
covering these three dimensions. The human approves or rejects the design rationale
before any implementation begins.

**The level designer explains the "why" of every design decision. The human approves
the reasoning, not just the result.** This is the equivalent of a creative director
signing off on a layout before a team of artists and programmers spend two weeks
building it.

---

## Aesthetic Agent

The `aesthetic-reviewer` agent runs on a recurring basis (configurable, default: end
of each sprint) and:

1. Scans all files in `production/feel-review/pending/`
2. Groups them by system (movement feel, audio feedback, visual effects, UI response)
3. Produces a consolidated **Aesthetic Health Report** at
   `production/feel-review/aesthetic-health-[sprint].md`
4. Posts a summary of pending feel reviews so the human can prioritize which to
   address first

The human does not need to process feel reviews one-by-one as they arrive.
The aesthetic agent batches and prioritizes them, presenting a clear queue.

---

## Rules for Agents

1. **Never skip the feel review file** for features involving: movement, combat timing,
   audio feedback, visual effects, UI transitions, camera behavior, or level layout.
2. **Do not block on feel review** — mark the technical task done and continue to the
   next task. The feel review queue is asynchronous.
3. **When rejected**, read the human's notes in `rejected/`, create a new task to
   address the specific feedback, and file a new feel review when the rework is done.
4. **Do not argue with feel feedback** — if the human says "this doesn't feel right,"
   that is the ground truth. Your job is to understand what they mean and iterate.
