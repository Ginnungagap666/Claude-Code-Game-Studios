# Test Impact Map

> **Owner**: lead-programmer
> **Updated**: At every integration sprint and whenever a new system or seam is added.
>
> This file maps source paths to the tests that must pass when those paths change.
> It enables selective test runs on feature branches and seam lock releases.
>
> Protocol: `.claude/docs/test-layering-protocol.md`

---

## How to Use

1. Identify which files your branch changes.
2. Find the matching entries below (by `Changed paths` glob).
3. Collect all rows in `Triggered Tests` for those entries.
4. Also collect all entries listed under `Downstream Triggers`.
5. Run only those tests before creating your PR.

**Required to pass before PR creation**: Unit + Seam layers.
System + Integration layers run on the integration branch only.

---

## Entry Format

```markdown
## [SYSTEM or SEAM ID]: [Name]

**Type**: System | Seam
**Changed paths**: [glob patterns]

### Triggered Tests

| Layer | Tag | Test file(s) |
|-------|-----|-------------|
| Unit | `unit:[system]:[topic]` | `tests/unit/...` |
| Seam | `seam:[SEAM-ID]:[name]` | `tests/seam/...` |
| System | `system:[name]` | `tests/system/...` |
| Integration | `integration:[a]-[b]` | `tests/integration/...` |

### Downstream Triggers

When this entry's tests run, also run:
- [Seam ID or system name]
```

---

*(No entries yet — add an entry when you create your first system or register your
first seam in `memory/evergreen/core-interfaces.md`.)*

---

## Full Suite Trigger

The full suite (`unit:` + `seam:` + `system:` + `integration:`) runs when any of these
paths change:

- `memory/evergreen/core-interfaces.md`
- `design/systems/game-state-machine.md`
- `.claude/docs/coordination-rules.md`
- Any file in `production/contract-tests/`
