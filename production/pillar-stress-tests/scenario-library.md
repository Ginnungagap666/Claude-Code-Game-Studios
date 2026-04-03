# Pillar Stress Test Scenario Library

This file is the persistent scenario library for all pillar stress tests.
The `aesthetic-reviewer` maintains this library across milestones.

See `.claude/docs/pillar-stress-test-protocol.md` for scenario design principles
and the milestone test format.

---

## Scenario Persistence Rules

- Each milestone test reuses 2 of 3 scenarios from the previous test per pillar
- 1 scenario per pillar is replaced each milestone to target recently shipped systems
- Scenarios are never deleted — retired scenarios stay here tagged with the last
  milestone they were used, so trend data remains interpretable

---

## Active Scenarios

*(No scenarios yet. Scenarios are written when the game has its first playable build
and the first pillar stress test is scheduled. See SNAP-0001 for the initial
experience targets that will anchor the first scenario set.)*

---

## Retired Scenarios

*(Scenarios retired from active rotation are listed here with their last-used milestone.)*
