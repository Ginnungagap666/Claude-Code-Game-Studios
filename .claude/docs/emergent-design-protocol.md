# Emergent Design Discovery Protocol

## What This Is

An emergent discovery is an **unscripted interaction between two or more systems**
that produces a player experience which feels more interesting, surprising, or alive
than anything the systems were explicitly designed to create individually.

Classic examples:
- Fire spreads to grass which ignites an enemy before a combat script runs (BotW physics)
- A music system reacts to the combat state which causes the UI animation timing to sync
  unexpectedly with the beat, creating a satisfying "lock-in" feeling
- An enemy patrol AI and a physics object left by the player combine to create an
  accidental puzzle the level designer never placed

These moments are the raw material of great game feel. They are also indistinguishable
from bugs without a human making a deliberate judgment call.

**This protocol ensures emergent discoveries are captured, evaluated, and either
confirmed as features or properly closed as bugs — never silently lost.**

---

## The Two Outcomes

Every emergent discovery has exactly two possible outcomes:

| Outcome | What it means | What happens |
|---------|--------------|--------------|
| **Feature** | The behavior is interesting and aligned with design intent | Logged, escalated to idea backlog (MINOR or MAJOR scope), possibly inducted into North Star |
| **Bug** | The behavior is confusing, harmful, or inconsistent with pillars | Closed normally in the bug tracker; no backlog entry needed |

The **human reviewer** makes this call. No agent decides unilaterally that an
emergent behavior is a feature.

---

## How to File an Emergent Discovery

When any agent encounters an unscripted cross-system interaction during testing,
playtesting review, or code inspection:

### Step 1 — Create the Discovery File

Create `EMERGENT_DISCOVERY_[NNNN].md` in `production/emergent-discoveries/pending/`:

```markdown
# Emergent Discovery: ED-NNN

**Filed by**: [agent name]
**Date**: YYYY-MM-DD
**Sprint**: [N]
**Status**: Pending Review

---

## What Was Observed

[Describe the interaction in plain language. What did the player or tester do?
What happened that was not explicitly scripted? Be concrete and specific.
"Fire from the torch spread to the tall grass, which reached the powder keg
the player had placed 30 seconds earlier, creating an explosion that solved
the puzzle without the player touching the keg directly."]

---

## Systems Involved

| System | What it contributed |
|--------|---------------------|
| [System A] | [Its role in the interaction] |
| [System B] | [Its role in the interaction] |
| [System C if applicable] | [Its role] |

---

## Why This Might Be a Feature

[What makes this interesting? What player experience does it enable?
How does it relate to the game's pillars?]

---

## Why This Might Be a Bug

[What could go wrong if this behavior persists? Does it break any balance
assumptions? Does it conflict with a Known Intentional Constraint?]

---

## Reproducibility

- **Reproducible**: Yes | No | Sometimes
- **Steps to reproduce**: [If yes]
- **Conditions required**: [What game state, player actions, or setup is needed]

---

## Related

- **Seams involved**: [SEAM-NNN if applicable]
- **Related DEC entries**: [If this touches a known design decision]
- **Similar past discoveries**: [ED-NNN if this echoes a previous discovery]
```

### Step 2 — Do Not Fix It Yet

If the behavior could be classified as a bug, **do not fix it until the human has
reviewed it**. File the discovery and leave the behavior in place. If it is clearly
harmful (crash, data corruption, softlock), fix the harmful aspect and note in the
discovery file that the behavior was partially changed.

### Step 3 — Notify the Aesthetic Reviewer

The `aesthetic-reviewer` batches emergent discoveries alongside feel reviews in the
sprint review queue. The human sees them grouped, not one-by-one.

---

## The Review Queue

Emergent discoveries live in:

```
production/
  emergent-discoveries/
    pending/         ← Agent files ED-NNN files here
    feature/         ← Human confirms: this is a feature
    bug/             ← Human confirms: this is a bug; fix normally
```

The `aesthetic-reviewer` adds a summary to the sprint's Aesthetic Health Report:

```markdown
## Emergent Discoveries This Sprint

| ID | Systems | One-line description | Recommendation |
|----|---------|----------------------|----------------|
| ED-004 | fire × physics | Torch fire spreads to barrel via grass | Looks like a feature — serves Pillar 2 |
| ED-005 | audio × combat | Beat sync with attack animation | Looks like a feature — investigate further |
| ED-006 | AI × inventory | Enemy picks up dropped items | Probably a bug — breaks balance |
```

---

## After Human Decision

### If Feature

1. Move file to `production/emergent-discoveries/feature/`
2. Update `Status` to `Confirmed Feature`
3. File a new entry in `production/idea-backlog.md`:
   - Scope: MINOR (if localised) or MAJOR (if systemic)
   - Note in the `Why Now` field: references the ED-NNN that surfaced it
4. Add to `Validation Notes` of any relevant DEC-NNNN entries
5. If this is the **third or more** confirmed discovery that follows the same
   underlying pattern → flag for North Star induction (see below)

### If Bug

1. Move file to `production/emergent-discoveries/bug/`
2. Create a normal bug fix task in the sprint
3. No backlog entry needed

---

## North Star Induction

When three or more confirmed feature discoveries share an underlying pattern, the
`creative-director` may propose inducting a new North Star principle:

1. Write a draft NS-NNN entry in `memory/evergreen/north-star.md`
2. File as a PILLAR-scope idea in the idea backlog — **human sign-off required**
3. If approved: finalize the principle, reference the source ED-NNN entries
4. Audit `memory/evergreen/core-interfaces.md` for seams that now need to add a
   `North Star alignment:` line to their contracts

---

## Discovery Register

`production/emergent-discoveries/README.md` maintains a running index:

| ID | Sprint | Systems | Outcome | Feature → IDEA-NNN |
|----|--------|---------|---------|-------------------|

---

## Rules for All Agents

1. **File before fixing.** An unscripted cross-system behavior must be logged as
   an emergent discovery before any agent decides its fate.
2. **Don't editorialize the outcome.** File the discovery neutrally — present both
   the "why feature" and "why bug" cases honestly. The human decides.
3. **Quantity matters for North Star.** A single interesting behavior is just a quirk.
   Three behaviors with the same pattern are a design principle waiting to be named.
4. **Low friction for filing.** The bar for filing a discovery is low. If you are
   unsure whether something is interesting enough to file, file it. The aesthetic
   reviewer's job includes filtering noise.

---

## Anti-Patterns

| Anti-Pattern | Why It Breaks Things |
|---|---|
| Fixing an emergent behavior without logging it | The discovery is lost; it may have been the seed of a North Star principle |
| Auto-classifying as feature without human review | Agents cannot judge whether emergent behaviors serve the pillars |
| Only filing "dramatic" discoveries | Small, subtle emergent behaviors are often more design-relevant than spectacular ones |
| Filing discoveries only during playtesting | Cross-system emergent behaviors surface during code review and integration too |
