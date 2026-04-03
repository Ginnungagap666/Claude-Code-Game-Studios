# Cross-System Contract Testing Protocol

## Problem

Seam locks prevent two agents from modifying a shared interface simultaneously, but
they do not verify that each system *correctly implements* the interface it promises to
expose. Without an automated check, an agent can "pass" a seam lock review while
subtly violating the contract — wrong field types, missing required fields, incorrect
event ordering — and the violation only surfaces at integration time.

Contract testing (inspired by consumer-driven contract testing / Pact) solves this by
encoding the exact terms of each seam as an executable test that runs independently
of the full integration suite.

---

## Core Concept

Each registered seam has exactly one contract test file. The contract test verifies:

1. **Provider side**: The system that emits/exposes the seam produces output that
   matches the registered signature in `memory/evergreen/core-interfaces.md`.
2. **Consumer side**: The system that receives/calls the seam can correctly process
   the output from the provider, using only the fields and types the contract defines.

Contract tests are **narrow by design**. They test the boundary, not the behavior
inside either system. If a consumer needs a new field, the consumer files a contract
change request — the provider does not add fields unilaterally.

---

## Contract Test File Format

Contract tests live in `production/contract-tests/[seam-id]/`.

### Directory Structure

```
production/
  contract-tests/
    SEAM-001--combat--animation--hit-event/
      contract.md          ← Human-readable contract spec (the source of truth)
      test_provider.gd     ← Provider-side test (combat emits correct HitEvent)
      test_consumer_animation.gd  ← Consumer test (animation reads HitEvent correctly)
      test_consumer_vfx.gd        ← Consumer test (vfx reads HitEvent correctly)
    SEAM-004--inventory--ui--item-selected/
      contract.md
      test_provider.gd
      test_consumer_ui.gd
```

### `contract.md` Format

```markdown
# Contract: [SEAM-ID] [System A] → [System B]: [Seam Name]

**Seam ID**: SEAM-NNN
**Provider**: [system that emits/exposes this seam]
**Consumers**: [comma-separated list of systems that depend on this seam]
**Registered**: YYYY-MM-DD
**Version**: N (must match `memory/evergreen/core-interfaces.md` SEAM-NNN version)

---

## Provider Obligations

The provider MUST:
- [Specific, testable obligation — e.g., "Emit `hit_event_emitted` exactly once per
  successful hit resolution, never on a blocked or dodged hit"]
- [e.g., "The `damage` field MUST be a non-negative integer"]
- [e.g., "The `hit_type` field MUST be one of: Normal, Critical, Blocked"]

The provider MUST NOT:
- [Negative obligation — e.g., "Add fields to HitEvent without updating this contract"]

---

## Consumer Rights

Every consumer listed in this contract is guaranteed:
- [What the consumer can rely on — e.g., "All fields in HitEvent are always populated;
  no field will ever be null/nil on a valid emission"]
- [e.g., "Event ordering: `hit_event_emitted` always fires before `death_event_emitted`
  in the same frame"]

---

## Contract Change Protocol

See `.claude/docs/contract-testing-protocol.md` — "Changing a Contract" section.
```

---

## Changing a Contract

Changing a contract is a two-phase operation, protected by the seam lock.

### Phase 1 — Proposal

1. Acquire the seam lock for the seam (`production/seam-locks/[lock-file].lock`)
2. Open a Contract Change Request (CCR) in `production/contract-tests/[seam-id]/ccr.md`:
   ```markdown
   # CCR: [SEAM-ID] — [Change summary]
   **Requested by**: [agent]
   **Date**: YYYY-MM-DD
   **Change type**: Additive | Breaking | Narrowing
   **Proposed change**: [Exact description of what changes in contract.md]
   **Reason**: [Why this change is needed]
   **Affected consumers**: [List of consumers that must update]
   ```
3. Notify all `Consumers` agents (create blocking tasks for each).

**Change types:**

| Type | Definition | Approval required |
|------|-----------|-------------------|
| **Additive** | New optional field added to provider output | `lead-programmer` |
| **Breaking** | Existing field removed, renamed, or type-changed | `technical-director` |
| **Narrowing** | Contract becomes more restrictive (new obligation) | `technical-director` |

### Phase 2 — Implementation

1. All `technical-director`-level changes require a DEC-NNNN entry in decision-log.md
2. Update `contract.md` — increment `Version` field
3. Update all provider test files (`test_provider.gd`)
4. Update all consumer test files for affected consumers
5. Run all contract tests for this seam: **must pass before releasing the seam lock**
6. Update `memory/evergreen/core-interfaces.md` SEAM-NNN entry (version + signature)
7. Run `detect-seam-drift.sh --seam SEAM-NNN` — must exit `0`
8. Release the seam lock; notify consumers

---

## When Contract Tests Must Run

| Trigger | Required tests |
|---------|---------------|
| Any file under the seam's `Covered paths` changes | All contract tests for that seam |
| `memory/evergreen/core-interfaces.md` changes | All contract tests for affected seams |
| Seam lock is about to be released | All contract tests for the locked seam — **must pass** |
| Integration sprint | Full contract test suite — all seams |
| New consumer added to a seam | New consumer contract test must be written and pass before merge |

---

## Writing Contract Tests

### Provider Test Checklist

A provider test must verify:
- [ ] The emitted payload includes every field listed in the contract
- [ ] Each field matches the declared type (no implicit conversions)
- [ ] Required invariants hold (e.g., `damage >= 0`)
- [ ] Ordering obligations hold if specified (e.g., event X before event Y)
- [ ] The provider does NOT emit fields that are not in the contract (no hidden state leakage)

### Consumer Test Checklist

A consumer test must verify:
- [ ] Consumer correctly reads every field it uses from the payload
- [ ] Consumer does NOT access fields outside the contract (future-proofing)
- [ ] Consumer handles the boundary values declared in the contract (min/max, null-safety)
- [ ] Consumer behaves correctly if optional fields are absent

### Test Isolation Rule

Contract tests must use mocks or minimal stubs — **never real game scenes**.
A contract test must be runnable in isolation with zero engine state (no active
SceneTree, no singletons). If it cannot run in isolation, it is an integration test,
not a contract test.

---

## Contract Test Registry

`production/contract-tests/README.md` maintains an index of all contract test directories:

```markdown
# Contract Test Registry

| Seam ID | Contract File | Provider | Consumers | Version | Last Run |
|---------|--------------|----------|-----------|---------|----------|
| SEAM-001 | SEAM-001--combat--animation--hit-event/contract.md | combat | animation, vfx, audio | 2 | YYYY-MM-DD |
```

The `lead-programmer` updates this table when seams are added or removed.

---

## Anti-Patterns

| Anti-Pattern | Why It Breaks Things |
|---|---|
| Contract test that imports real game scenes | Test is no longer isolated; engine state bleeds in |
| Provider adding undocumented fields "just in case" | Hidden coupling; consumers start depending on undeclared fields |
| Consumer reading fields not in the contract | Contract becomes meaningless; breaking changes go undetected |
| Skipping contract tests on "minor" seam changes | "Minor" changes cause the most insidious regressions |
| Single contract test file for multiple seams | Failures are hard to isolate; lock granularity breaks |
| Updating contract.md version without updating tests | Version number is decorative; tests still verify old behavior |
