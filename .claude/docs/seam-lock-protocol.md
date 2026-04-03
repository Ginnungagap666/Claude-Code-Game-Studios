# Seam Lock Protocol

## Problem

In a large parallel-agent codebase, two agents can simultaneously modify the same
cross-system interface (a "seam") and produce a merge conflict that is expensive to
untangle — or worse, a silent incompatibility that only surfaces at integration time.

A seam is any interface that two or more systems depend on:
- A function signature called across system boundaries
- A data schema read by multiple agents
- An event type published by one system and consumed by another
- A state machine transition that triggers side effects in another system

**Seam locks prevent two agents from modifying the same seam simultaneously.**

---

## Seam Lock Files

A lock file is a plain text file placed in `production/seam-locks/`.

**Filename convention**: `[system-a]--[system-b]--[seam-name].lock`

**Example**: `combat--animation--hit-event.lock`

### Lock File Format

```
LOCKED BY:   [agent name]
DATE:        YYYY-MM-DD
TASK:        [sprint task ID]
SEAM:        [brief description of the interface being modified]
EXPIRES:     [expected completion date, max 5 days]
NOTIFY:      [comma-separated list of agents that must be notified on unlock]
```

---

## Lock Rules

### Acquiring a Lock

1. Check `production/seam-locks/` for any existing lock on the target seam.
2. If no lock exists, create the lock file before modifying any seam-related code.
3. If a lock exists and is not expired:
   - Do NOT modify the seam.
   - Contact the lock holder (tag them in a task comment or create a blocking task).
   - Wait for the lock to be released.
4. If a lock exists but is past its `EXPIRES` date:
   - Escalate to `lead-programmer`, who decides whether to break the lock.
   - Document the broken lock in `production/integration-notes.md`.

### Releasing a Lock

1. Delete the lock file.
2. Notify all agents listed in the `NOTIFY` field — create tasks for them if needed.
3. Update `memory/current-milestone/active-adrs.md` if the seam change produced
   a new architecture decision.

### Lock Scope

- One lock per seam per task. Do not use a single lock to block an entire subsystem.
- If a task modifies three seams, acquire three separate lock files.
- Locks are not recursive — you cannot re-lock a seam you already hold.

---

## Seam vs. Implementation

**Seam**: The public interface contract — types, signatures, event schemas.
Design seams early; lock them while changing them.

**Implementation**: Everything behind the interface. Multiple agents can work
on implementations of different systems simultaneously without locks, as long as
they do not touch the seam.

This is the fundamental rule that enables parallelism:
> **Design seams first. Lock seams during change. Never lock implementations.**

---

## Cross-System Seam Registry

All canonical seams are documented in `memory/evergreen/core-interfaces.md`.

Before creating a new seam, check whether an existing seam covers the need. Seam
proliferation is a code smell — fewer, well-designed seams are better than many
narrow ones.

When a new seam is established:
1. Document it in `memory/evergreen/core-interfaces.md`.
2. Register any commands/events it introduces with `command-pipeline-guardian`.
3. Create a lock file during the initial implementation.

---

## Escalation

| Situation | Escalate To |
|-----------|-------------|
| Two agents want the same lock | lead-programmer decides priority |
| Lock holder is unresponsive for 2+ days | lead-programmer breaks the lock |
| Seam change requires modifying 5+ downstream systems | technical-director must approve before lock is acquired |
| Seam change contradicts an Active decision-log entry | Stop; escalate to technical-director |
