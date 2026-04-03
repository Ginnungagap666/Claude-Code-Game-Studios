# Test Layering and Regression Isolation Protocol

## Problem

In a large parallel-agent codebase, running the full regression suite on every change
is prohibitively slow and encourages agents to skip tests entirely. Conversely, running
too few tests after a seam change causes silent regressions across downstream systems.

Test layering solves this with a tagging protocol that maps every test to exactly the
systems and seams it exercises. When a system or seam changes, only its tagged tests
(and the tagged tests of its downstream consumers) are required to pass before merge.
The full suite runs on integration branch, not on every feature branch.

---

## Test Layers

Tests are organized into four layers. Each layer has a distinct scope, run frequency,
and ownership:

| Layer | Tag Prefix | Scope | When to Run | Owner |
|-------|-----------|-------|-------------|-------|
| **Unit** | `unit:` | One function / class, no cross-system calls | Every commit | authoring agent |
| **Seam** | `seam:` | Exactly one seam contract; mocks all consumers | On seam file change | `lead-programmer` |
| **System** | `system:` | One full system end-to-end, mocked boundaries | On system file change | `lead-programmer` |
| **Integration** | `integration:` | Multiple real systems together | On integration branch / sprint | `producer` |

---

## Test Impact Map

The test impact map lives at `production/test-impact-map.md`. It declares which tests
are triggered by changes to each system or seam.

### Format

```markdown
## [SYSTEM or SEAM ID]: [Name]

**Type**: System | Seam
**Changed paths**: [glob patterns for files that, when changed, trigger this entry]

### Triggered Tests

| Layer | Tag | Test file(s) |
|-------|-----|-------------|
| Unit | `unit:combat:hit-resolver` | `tests/unit/combat/test_hit_resolver.gd` |
| Seam | `seam:SEAM-001:hit-event` | `tests/seam/test_hit_event_contract.gd` |
| System | `system:combat` | `tests/system/test_combat_system.gd` |
| Integration | `integration:combat-animation` | `tests/integration/test_combat_animation.gd` |

### Downstream Triggers

When this entry's tests run, also run:
- [Seam ID or system name that consumes this seam's output]
```

### Example Entry

```markdown
## SEAM-001: combat--animation--hit-event

**Type**: Seam
**Changed paths**: `src/combat/**`, `memory/evergreen/core-interfaces.md` (SEAM-001 block)

### Triggered Tests

| Layer | Tag | Test file(s) |
|-------|-----|-------------|
| Seam | `seam:SEAM-001` | `tests/seam/test_hit_event_contract.gd` |
| Integration | `integration:combat-animation` | `tests/integration/test_combat_animation.gd` |
| Integration | `integration:combat-audio` | `tests/integration/test_combat_audio.gd` |
| Integration | `integration:combat-vfx` | `tests/integration/test_combat_vfx.gd` |

### Downstream Triggers

When SEAM-001 tests run, also run:
- `system:animation` (animation-system consumes hit_event_emitted)
- `system:audio` (audio-system plays on hit_event_emitted)
- `system:vfx` (vfx-system triggers on hit_event_emitted)
```

---

## Test Tagging Convention

Every test file must declare its tags in a header comment block. Agents writing tests
must tag every test file before submitting.

### GDScript Example

```gdscript
# TEST TAGS: seam:SEAM-001:hit-event, system:combat
# LAYER: seam
# SEAM: SEAM-001
# SYSTEM: combat
# DESCRIPTION: Verifies that HitEvent emitted by combat matches the SEAM-001 contract.

extends GutTest

func test_hit_event_has_required_fields() -> void:
    ...
```

### C# Example

```csharp
// TEST TAGS: seam:SEAM-001:hit-event, system:combat
// LAYER: seam
// SEAM: SEAM-001
// SYSTEM: combat
// DESCRIPTION: Verifies that HitEvent emitted by combat matches the SEAM-001 contract.

public class HitEventContractTest { ... }
```

### Tag Format

`[layer]:[system-or-seam-id]:[optional-sub-topic]`

Examples:
- `unit:combat:damage-calculator`
- `seam:SEAM-001:hit-event`
- `system:combat`
- `integration:combat-animation`

---

## Selective Run Rules

### On a Feature Branch (Agent Work)

Run only the tests triggered by the files changed in the branch:

1. Identify changed files
2. Look up matching entries in `production/test-impact-map.md`
3. Collect all `Triggered Tests` and `Downstream Triggers` for those entries
4. Run only those tests

**Required to pass before PR creation**: Unit + Seam layers only.
System and Integration layers are not required on feature branches.

### On Seam Change (Seam Lock Release)

Before releasing a seam lock, run:
1. All `seam:` tests for the changed seam
2. All `system:` tests for every system listed in the seam's `Consumers:` field
3. **Must pass before the lock is released.** If they fail, fix before releasing.

### On Integration Branch

Run the full suite:
```
run_tests --tag integration
run_tests --tag system
run_tests --tag seam
run_tests --tag unit
```

Integration layer failures block the integration sprint from closing.

---

## Maintaining the Test Impact Map

| Event | Action |
|-------|--------|
| New system created | Add a system entry to `production/test-impact-map.md` |
| New seam registered in `core-interfaces.md` | Add a seam entry to `production/test-impact-map.md` |
| Seam consumer added | Add the consumer to the seam entry's `Downstream Triggers` |
| Seam removed | Remove the seam entry and all tags referencing it |
| System removed | Remove the system entry; update all seam entries that listed it as downstream |

The `lead-programmer` reviews `production/test-impact-map.md` at each integration sprint
to confirm it is accurate.

---

## Agent Responsibilities

| Role | Responsibility |
|------|----------------|
| Any agent writing a new test | Tag the file before committing; add to `test-impact-map.md` if new system/seam |
| Any agent modifying a seam | Run seam + system tests before releasing the lock |
| `lead-programmer` | Owns `test-impact-map.md`; audits at integration sprint |
| `command-pipeline-guardian` | Ensures pipeline event tests are tagged and registered |
| `producer` | Triggers full integration suite at integration sprint |

---

## Anti-Patterns

| Anti-Pattern | Why It Breaks Things |
|---|---|
| No tags on a test file | Test is never selectively triggered; may be silently skipped |
| Tagging a test with the wrong layer | Unit test tagged as integration runs too rarely; regressions go undetected |
| Updating `test-impact-map.md` after the fact | Agents merge without running downstream tests first |
| Running full suite on every feature branch commit | Slow CI discourages test running; agents skip |
| Integration tests as the only test for a seam | Seam contract failures only caught late; expensive to fix |
