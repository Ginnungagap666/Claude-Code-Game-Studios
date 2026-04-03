# Seam Drift Detection

## Problem

`memory/evergreen/core-interfaces.md` is the canonical registry of all cross-system
interface contracts. As the codebase grows, agent implementations can silently diverge
from the registered signatures — parameter types change, return types are widened,
event payloads gain undocumented fields. This "seam drift" accumulates invisibly until
integration sprint, when it is expensive to untangle.

Seam drift detection is a CI-side check that compares actual code signatures against
the registry and alerts agents before drift causes a merge conflict or runtime failure.

---

## What Gets Checked

Any entry in `memory/evergreen/core-interfaces.md` that includes a `Signature:` block
is eligible for drift detection. The CI script extracts the registered signature and
greps for the corresponding definition in the source tree.

**Items the script checks:**
- Function/method signatures (name, parameters, return type)
- Event schema field names and types
- Exported struct / data class fields that cross a seam
- State machine transition tables referenced in `design/systems/game-state-machine.md`

**Items the script does NOT check:**
- Internal (non-seam) implementations
- Comments, docs, or whitespace
- Anything not registered in `memory/evergreen/core-interfaces.md`

---

## How It Works

### Script: `.claude/hooks/detect-seam-drift.sh`

The script runs in two modes:

**Mode 1 — Full scan** (called by CI on every push to main / integration branch):
```
./detect-seam-drift.sh --full
```

**Mode 2 — Single seam** (called by an agent before releasing a seam lock):
```
./detect-seam-drift.sh --seam <seam-id>
```

### Output

On success (no drift): exits `0`, prints `OK: N seams checked, 0 drift items`.

On drift detected: exits `1`, prints a drift report:
```
DRIFT DETECTED: 2 seam(s) out of sync with core-interfaces.md

  [SEAM-001] combat--animation--hit-event
    Registry:   emit(HitEvent { target_id: EntityId, damage: int, hit_type: HitType })
    Found:      emit(HitEvent { target_id: EntityId, damage: float, hit_type: HitType })
    File:       src/combat/systems/hit_resolver.gd:44
    Delta:      `damage` changed from int → float

  [SEAM-004] inventory--ui--item-selected
    Registry:   signal item_selected(item: ItemData)
    Found:      signal item_selected(item: ItemData, source_slot: int)
    File:       src/inventory/inventory_manager.gd:112
    Delta:      undocumented parameter `source_slot` added
```

---

## CI Integration

Add to your CI pipeline (GitHub Actions, GitLab CI, etc.):

```yaml
# In your CI config:
- name: Check seam drift
  run: bash .claude/hooks/detect-seam-drift.sh --full
```

The check runs:
1. On every push to `main` or `integration` branch
2. On every pull request that touches `memory/evergreen/core-interfaces.md`
3. On every pull request that touches files registered as seam implementations

If the check fails, the PR is blocked. The author must either:
- Update `memory/evergreen/core-interfaces.md` to reflect the intended change (acquire
  a seam lock first, per `.claude/docs/seam-lock-protocol.md`), OR
- Revert the code change to match the registry

---

## Agent Response Protocol

When an agent receives a drift alert (from CI or from running the script manually):

### Step 1 — Classify

| Scenario | Action |
|----------|--------|
| I changed the seam intentionally | Proceed to Step 2 (formal seam update) |
| I changed the seam accidentally | Revert the code; do not touch `core-interfaces.md` |
| Someone else changed the seam | File an integration note; notify the lock holder |
| Drift predates my work (legacy) | File an integration note tagged `legacy-drift`; do not fix unilaterally |

### Step 2 — Formal Seam Update (intentional change only)

1. Acquire a seam lock: `production/seam-locks/[system-a]--[system-b]--[seam-name].lock`
2. Update the `Signature:` block in `memory/evergreen/core-interfaces.md` (verbatim copy
   of the new signature — never paraphrase)
3. Update all downstream systems listed under that seam's `Consumers:` section
4. Append a DEC-NNNN entry to `.claude/docs/decision-log.md` (reason, affected systems)
5. Run `./detect-seam-drift.sh --seam <seam-id>` locally — must exit `0`
6. Release the lock
7. Notify `NOTIFY` agents listed in the lock file

### Step 3 — Verify

Run the full scan before merging:
```
./detect-seam-drift.sh --full
```
Must exit `0`. If not, resolve remaining items before merge.

---

## `core-interfaces.md` Signature Block Format

Every seam entry in `memory/evergreen/core-interfaces.md` must include a `Signature:`
block for drift detection to work. Example:

```markdown
### SEAM-001: combat--animation--hit-event

**Owner**: lead-programmer
**Consumers**: animation-system, vfx-system, audio-system
**Registered**: YYYY-MM-DD

#### Signature

```gdscript
signal hit_event_emitted(event: HitEvent)

class HitEvent:
    var target_id: EntityId
    var damage: int
    var hit_type: HitType
    var position: Vector2
```

#### Notes

[Any context about why this seam exists and what it must guarantee]
```

If a seam entry has no `Signature:` block, the drift detection script logs a warning
(`WARN: SEAM-XXX has no Signature block — skipped`) but does not fail the build.
This allows gradual onboarding of existing seams.

---

## Maintenance

- **Who runs the full scan**: CI (automated) and `lead-programmer` at sprint start
- **Who owns `core-interfaces.md`**: `technical-director`
- **Who resolves legacy drift**: `lead-programmer` during integration sprint
- **Drift report archive**: `production/drift-reports/YYYY-MM-DD-full-scan.txt`
  (created by `--full` mode; keep last 5 reports)

---

## Anti-Patterns

| Anti-Pattern | Why It Breaks Things |
|---|---|
| Updating `core-interfaces.md` without acquiring a seam lock | Concurrent agents still see old registry; race condition |
| Paraphrasing a signature in the registry | Drift detection relies on exact token matching; paraphrase causes false positives |
| Fixing drift in a consumer without updating the registry | Registry still shows old signature; next scan still fails |
| Suppressing CI drift failure without filing an integration note | Debt becomes invisible; integration sprint has no record of it |
| Bulk-updating all seams in one PR | Blocks all parallel agents; decompose into per-seam PRs |
