# Integration Sprint Protocol

## What Is an Integration Sprint?

An integration sprint is a dedicated sprint whose sole purpose is to resolve
cross-system intersections that accumulated during normal feature sprints. No new
features are added during an integration sprint.

**Cadence**: Every 2–3 normal feature sprints, `producer` calls an integration sprint.
The exact trigger depends on the health of `production/integration-notes.md` — if
open intersection items exceed 5, an integration sprint is mandatory regardless of cadence.

---

## Why Integration Sprints Exist

When many parallel agents work simultaneously across different systems, each agent
correctly implements their own slice. But the seams between slices accumulate:

- System A's output format slightly differs from what System B expects
- Two systems each implemented a "shared" utility independently
- A timing assumption in Combat is violated by a new Animation event order
- Three systems all read the same config file with slightly different interpretations

These are not bugs in any one system — they are integration debt. Normal sprints
push this debt forward. Integration sprints pay it down.

---

## Integration Sprint Scope

During an integration sprint, the team works ONLY on:

1. **Seam reconciliation** — resolve any mismatch between what a system publishes
   and what downstream systems expect. Update `memory/evergreen/core-interfaces.md`.

2. **Duplicate elimination** — find utility functions or data structures independently
   implemented by multiple agents; consolidate to a canonical version.

3. **Pipeline health** — `command-pipeline-guardian` runs a full pipeline audit,
   verifying every registered command against `design/systems/command-pipeline.md`.

4. **State machine alignment** — verify that all systems agree on the set of valid
   game states and transition triggers. Update `design/systems/game-state-machine.md`.

5. **Open risk resolution** — work through `memory/current-milestone/open-risks.md`
   items that were deferred during feature sprints.

6. **Integration notes closure** — every open item in `production/integration-notes.md`
   must be either resolved or promoted to a tracked risk with a named owner.

---

## Integration Sprint Workflow

```
1. producer          -- Declares integration sprint; freezes feature work.
2. lead-programmer   -- Reads production/integration-notes.md; triages all open items.
3. command-pipeline-guardian -- Runs pipeline audit; files results as a task.
4. technical-director -- Reviews open ADRs; closes or escalates each one.
5. [specialist programmers] -- Execute assigned reconciliation tasks.
6. qa-lead           -- Runs cross-system regression suite.
7. lead-programmer   -- Reviews all seam changes from the sprint.
8. producer          -- Verifies integration-notes.md is fully closed.
9. producer          -- Updates memory/current-milestone/open-risks.md.
10. producer         -- Declares integration sprint complete; resumes feature work.
```

---

## Integration Notes File

`production/integration-notes.md` is the living log of known cross-system
intersection issues. Any agent who discovers an integration concern — even mid-sprint —
appends an entry immediately. Do not wait for the integration sprint.

### Entry Format

```markdown
## [YYYY-MM-DD] [System A] × [System B]: [One-line description]

**Filed by**: [agent name]
**Sprint found**: [N]
**Integration sprint target**: [N+1 or N+2]
**Status**: Open / In Progress / Resolved

### Description
[What the intersection problem is. Be concrete: what does System A emit that
System B misinterprets?]

### Proposed Resolution
[How this should be fixed. Reference the seam in core-interfaces.md if applicable.]

### Resolution Notes
[Filled in when resolved: what was actually done, any follow-up tasks created.]
```

---

## Integration Sprint Checklist (producer runs this)

- [ ] All open seam locks released or documented as blocked
- [ ] `production/integration-notes.md` — every item resolved or owned
- [ ] `memory/evergreen/core-interfaces.md` — reflects actual current seams
- [ ] `design/systems/game-state-machine.md` — all systems agree on state transitions
- [ ] `command-pipeline-guardian` pipeline audit report filed and reviewed
- [ ] `qa-lead` cross-system regression pass complete
- [ ] `memory/current-milestone/open-risks.md` updated

---

## Anti-patterns

| Anti-pattern | Why it fails |
|---|---|
| Skipping integration sprint to ship faster | Debt compounds; the next cross-system bug costs 3× more |
| Doing feature work during integration sprint | Integration work requires full focus; split attention means neither gets done properly |
| Resolving integration issues in a normal sprint without logging | Creates invisible debt; next integration sprint starts blind |
| Merging a seam change without notifying downstream owners | Silent incompatibility — surfaces as a mystery bug at runtime |
