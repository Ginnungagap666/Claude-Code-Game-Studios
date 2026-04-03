# Pillar Stress Test Protocol

## Purpose

Design pillars are written once and trusted implicitly. But over 30, 50, or 100
sprints, each individually reasonable design decision applies small pressure against
the pillars. No single decision breaks them. The accumulated effect of all of them
can leave you with a game that technically satisfies every decision log entry and
every snapshot — but no longer expresses the pillars it was built around.

A pillar stress test is a structured, periodic challenge that asks:
**"Does the current build still feel like it was made for these pillars?"**

It is not a feel review of a specific feature. It is a health check of the game as a
whole — conducted at every milestone, using repeatable test scenarios so results can
be compared across time.

---

## When Stress Tests Run

| Trigger | Action |
|---------|--------|
| End of every milestone | Producer schedules a stress test; aesthetic-reviewer prepares scenarios |
| After any PILLAR-scope idea is shipped | Immediate out-of-cycle stress test |
| After 3+ related hypothesis invalidations in one milestone | Producer may call an early stress test |
| Human requests one at any time | Runs within 1 sprint |

---

## The Three-Part Test

Each pillar stress test has three parts:

### Part 1 — Scenario Battery

The `aesthetic-reviewer` selects or writes **3 specific in-game scenarios per pillar**.
Scenarios are concrete actions the human can perform in the current build, not abstract
questions. Each scenario has a **reference baseline** — either the description from the
initial game state snapshot (SNAP-0001) or the last milestone's approved stress test.

**Example scenario format:**

```markdown
### Scenario [Pillar Name]-[N]: [Short title]

**What to do**: [Exact player actions to perform]
**What to observe**: [What should happen, and how it should feel]
**Reference baseline**: [What was observed/described in Milestone N-1 stress test,
  or SNAP-0001 experience target if this is the first test]
**Pillar statement being tested**: [Which specific part of the pillar this probes]
```

### Part 2 — Drift Score

After playing each scenario, the human rates each one:

| Rating | Meaning |
|--------|---------|
| **Strong** | The pillar feels clearly expressed in this scenario |
| **Present** | The pillar is there but diluted or competing with other signals |
| **Weak** | The pillar is hard to find in this scenario |
| **Absent** | This scenario actively contradicts the pillar |

The `aesthetic-reviewer` calculates a **drift score** per pillar across all three scenarios:
- Strong × 3: 100% — pillar fully intact
- 2× Strong, 1× Present: ~83%
- 1× Strong, 1× Present, 1× Weak: ~56%
- Any Absent: automatic flag regardless of other scores

### Part 3 — Trend Comparison

The drift score for each pillar is compared to the previous milestone's score.
A **declining trend** (two consecutive milestones of lower score) triggers a review,
even if the absolute score is still acceptable.

---

## Output: Pillar Stress Test Report

Filed at `production/pillar-stress-tests/PST-NNN-milestone-[N].md`:

```markdown
# Pillar Stress Test: PST-NNN

**Milestone**: [N]
**Date**: YYYY-MM-DD
**Conducted by**: aesthetic-reviewer + [human name]
**Previous test**: PST-[NNN-1]

---

## Results Summary

| Pillar | This milestone | Previous milestone | Trend |
|--------|---------------|--------------------|-------|
| [Pillar 1 name] | ___% | ___% | ↑ / → / ↓ |
| [Pillar 2 name] | ___% | ___% | ↑ / → / ↓ |
| [Pillar 3 name] | ___% | ___% | ↑ / → / ↓ |

**Overall health**: Strong | Stable | Declining | Critical

---

## Scenario Results

[One section per pillar, with sub-sections for each scenario]

### Pillar 1: [Name]

#### Scenario 1-A: [Title]
- Rating: Strong | Present | Weak | Absent
- Notes: [What specifically was observed]

#### Scenario 1-B: [Title]
- Rating: ___
- Notes: ___

#### Scenario 1-C: [Title]
- Rating: ___
- Notes: ___

---

## Flags and Follow-Up

### Absent Ratings (immediate action required)

[List any scenarios rated Absent, with notes on what contradicted the pillar]

### Declining Trends (monitor)

[List any pillars with two consecutive milestone declines]

---

## Recommended Actions

[Specific, scoped recommendations. Not "fix the feel" but "the jump system in the
forest level is creating a Weak rating on Pillar 2 because the camera lag obscures
the peak of the arc — this is a localized feel issue, file as IDEA-MINOR"]

---

## Human Sign-Off

**Assessment**: ☐ Game feels true to its pillars  ☐ Monitor trends  ☐ Rework needed

**Signed by**: _______________
**Date**: _______________
**Notes**: _______________
```

---

## Scenario Design Principles

The `aesthetic-reviewer` writes new scenarios at each milestone. Good scenarios:

1. **Are specific, not abstract.** "Run across the open field and jump onto the
   bridge" not "explore the environment."
2. **Test one pillar at a time.** A scenario that tests multiple pillars is hard
   to score.
3. **Are repeatable.** Another tester following the same instructions should reach
   the same part of the game.
4. **Include edge cases.** The pillar may hold in the central loop but fail at the
   margins — tutorial, failure states, late-game mechanics.
5. **Reference the snapshot.** Every scenario is anchored to an experience target
   from `game-state-snapshots.md`. The scenario tests whether that target is still
   being hit.

---

## Scenario Persistence

Scenarios are **not re-written from scratch** each milestone. The `aesthetic-reviewer`
reuses 2 out of 3 scenarios from the previous test and replaces 1 with a new scenario
that targets recently shipped systems. This persistence enables trend comparison.

The scenario library lives at `production/pillar-stress-tests/scenario-library.md`.

---

## Rules for All Agents

1. **Pillar stress tests are not feel reviews.** Do not conflate them. Feel reviews
   evaluate specific features. Stress tests evaluate the whole.
2. **A low drift score does not mean individual features are broken.** The issue
   may be feature density, pacing, or accumulated tone — a systemic pattern, not a
   localized bug.
3. **Declining trend is more serious than low absolute score.** A game at 60% that
   held 60% for three milestones is stable. A game at 75% that was 90% two milestones
   ago is in trouble.
4. **Absent ratings are emergencies.** An "Absent" means something in the current
   build actively contradicts a core pillar. This triggers an immediate MAJOR-scope
   idea entry and a creative-director review before the next sprint begins.
