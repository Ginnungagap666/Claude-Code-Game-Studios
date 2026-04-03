# Agent Coordination Rules

1. **Vertical Delegation**: Leadership agents delegate to department leads, who
   delegate to specialists. Never skip a tier for complex decisions.
2. **Horizontal Consultation**: Agents at the same tier may consult each other
   but must not make binding decisions outside their domain.
3. **Conflict Resolution**: When two agents disagree, escalate to the shared
   parent. If no shared parent, escalate to `creative-director` for design
   conflicts or `technical-director` for technical conflicts.
4. **Change Propagation**: When a design change affects multiple domains, the
   `producer` agent coordinates the propagation.
5. **No Unilateral Cross-Domain Changes**: An agent must never modify files
   outside its designated directories without explicit delegation.

---

## Decision Persistence (Evolution 1)

6. **Log Before Implementing**: Before implementing any non-trivial architectural
   or design decision, the responsible agent must check `.claude/docs/decision-log.md`
   for existing entries that affect the same systems.
7. **Record After Deciding**: After making any significant decision, append an
   entry to `.claude/docs/decision-log.md` using the format defined in that file.
8. **No Contradictions**: If a proposed decision contradicts an Active entry in
   the decision log, the agent must stop and escalate — not proceed unilaterally.

## System Impact Awareness (Evolution 2)

9. **Consult the Impact Map**: Before modifying any system, read
   `.claude/docs/system-impact-map.md` to identify downstream systems that may
   be affected.
10. **Update the Impact Map**: When a new cross-system dependency is introduced,
    update the map before the task is marked complete.
11. **Downstream Notification**: If a change alters an interface that downstream
    systems depend on, notify the responsible agents or create tasks for them
    before proceeding.

## Feel and Logic Separation (Evolution 3)

12. **Two Reports Required**: Any feature that a player will directly experience
    (movement, combat, audio, UI transitions, camera, level layout) must produce
    both a `TECHNICAL_DONE.md` and a `FEEL_REVIEW_NEEDED.md` on completion.
    See `.claude/docs/feel-review-workflow.md` for format and file locations.
13. **Feel Reviews Are Async**: Agents do not block on feel review sign-off.
    Mark the technical task done and continue. The `producer` tracks feel review
    status during sprint reviews.
14. **Human Sign-Off Is Final**: Agents do not argue with feel feedback. If
    rejected, read the human's notes and create a specific rework task.
15. **Level Design Rationale First**: Level layout implementation cannot begin
    until the human has approved the design rationale via a feel review.
    The `aesthetic-reviewer` manages this queue.

## Command Pipeline Integrity (Evolution 4)

16. **Register Before Implementing**: Any new command, event, trigger, or
    modifier that participates in the game's event bus must be registered with
    `command-pipeline-guardian` before implementation. File a request in
    `production/pipeline-requests/pending/`.
17. **Pipeline Guardian Authority**: No agent may bypass the command pipeline
    review. If the guardian rejects a request, escalate to `technical-director`
    — do not implement and work around the objection.
18. **State Machine Consistency**: All commands must be valid only in explicitly
    registered game states. See `design/systems/game-state-machine.md`.

## Game State Snapshot Discipline (Evolution 5)

19. **Read Snapshot Before Major Work**: Before any major system refactor, read
    the most recent entry in `.claude/docs/game-state-snapshots.md`. If your
    work would change a Core Loop, Experience Target, or Known Intentional
    Constraint, raise the question with `creative-director` before proceeding.
20. **Snapshot at Milestones**: The `producer` requests a new snapshot from
    `creative-director` and `technical-director` at the start of every milestone.
21. **Snapshots Are Append-Only**: Never edit a past snapshot. Record changes
    in a new entry that explicitly references what it supersedes.

## Layered Memory (Evolution 6)

22. **Always Load Evergreen**: Every agent loads all files in `memory/evergreen/`
    at session start, unconditionally. These files define the project vocabulary.
23. **Load Current Milestone When Active**: When working on a task within the
    active milestone, also load `memory/current-milestone/`. Do not load archive.
24. **Task Spec Is the Context Authority**: An agent must not load any file that
    is not listed in the task spec's `## Context` section (other than evergreen).
    If a new file is needed, add it to the spec with a justification first.
25. **Never Compress Precision Data**: When summarizing memory, never compress
    interface signatures, state machine transition tables, numeric parameters,
    file paths, or decision log IDs. These must be copied verbatim.
26. **Archive at Milestone Boundary**: The `producer` runs `.claude/hooks/milestone-archive.sh`
    at each milestone end to move current-milestone files to `memory/archive/milestone-N/`.

## Seam Lock and Integration Sprint (Evolution 7)

27. **Lock Before Modifying a Seam**: Before modifying any cross-system interface
    registered in `memory/evergreen/core-interfaces.md`, acquire a lock file in
    `production/seam-locks/` per the protocol in `.claude/docs/seam-lock-protocol.md`.
28. **Lock Implementations Are Free**: Seam locks apply only to interface contracts,
    not to internal implementations. Multiple agents may implement different systems
    simultaneously without locks.
29. **File Integration Issues Immediately**: Any cross-system intersection concern
    discovered during normal work must be appended to `production/integration-notes.md`
    immediately — not deferred to integration sprint.
30. **Integration Sprint Every 2–3 Sprints**: The `producer` calls an integration
    sprint when `production/integration-notes.md` has 5+ open items, or every
    2–3 feature sprints. See `.claude/docs/integration-sprint.md`.

## On-Demand Context Loading (Evolution 8)

31. **Grep Before Load**: Before loading a large file, use grep to locate the
    specific section needed. Load only the relevant line range, not the full file.
32. **Explicit Exclusions**: Task specs must include an "explicitly excluded" section
    listing files that an agent might speculatively load but should not.
33. **Budget in Task Specs**: Every non-trivial task spec must include a token
    budget estimate using the guidelines in `.claude/docs/context-loading-protocol.md`.
34. **Decompose High-Context Tasks**: Any task requiring more than 50,000 tokens
    of context must be decomposed into smaller tasks before implementation begins.

## Seam Drift Detection (Evolution 9)

35. **Run Drift Check Before Lock Release**: Before releasing any seam lock, run
    `./detect-seam-drift.sh --seam SEAM-NNN`. It must exit `0`. If drift is detected,
    resolve it using the protocol in `.claude/docs/seam-drift-detection.md` before releasing.
36. **Formal Seam Update for Intentional Drift**: When drift is intentional (the seam
    was deliberately changed), follow the six-step formal seam update: acquire lock →
    update `core-interfaces.md` verbatim → update downstream consumers → log DEC-NNNN →
    verify drift check passes → release lock.
37. **File Legacy Drift as Integration Note**: If drift predates your work, append it
    to `production/integration-notes.md` tagged `legacy-drift`. Never fix it unilaterally.
38. **Archive Drift Reports**: The CI full scan writes reports to
    `production/drift-reports/`. Keep the last 5 reports. The `lead-programmer` reviews
    the report at integration sprint start.

## Test Layering and Regression Isolation (Evolution 10)

39. **Tag Every Test File**: Every test file must include the `TEST TAGS:` header block
    before committing. Untagged tests are not selectively triggered and may be silently
    skipped. See `.claude/docs/test-layering-protocol.md` for the tag format.
40. **Run Triggered Tests Only on Feature Branch**: On a feature branch, run only the
    tests mapped to your changed files in `production/test-impact-map.md`. Unit + Seam
    layers must pass before PR creation. System + Integration run on integration branch.
41. **Run Seam + System Tests Before Lock Release**: Before releasing a seam lock,
    run all `seam:` tests for the changed seam and all `system:` tests for its consumers.
    These must pass before the lock is released.
42. **Update Test Impact Map on New System or Seam**: When a new system or seam is
    created, add its entry to `production/test-impact-map.md` before the task is closed.

## Design Doc Staleness Detection (Evolution 11)

43. **Include Front-Matter Header in All Design Docs**: Every file in `design/` must
    include the standard front-matter block (doc-id, owner, version, last-reviewed,
    covered-paths). Docs without it are unregistered and generate CI warnings.
44. **Increment Version on Material Change**: Increment the `version` field and update
    `last-reviewed` whenever a parameter, mechanic, or player-facing behavior described
    in the doc changes. Do not increment for typo fixes or reformatting.
45. **Major Changes Require Snapshot Entry**: A design doc change that alters the
    Core Loop, Experience Target, or Known Intentional Constraints in the latest game
    state snapshot is a major change. Notify `creative-director` and create a new
    snapshot entry before committing the version bump.
46. **File Waivers for Non-Behavioral Code Changes**: If a code change was a pure
    refactor that did not alter player-facing behavior, file a waiver in
    `production/design-doc-waivers.md` instead of bumping the doc version. Waivers
    expire after 30 days maximum.

## Contract Testing (Evolution 12)

47. **Write Contract Tests for Every Seam**: When a new seam is registered in
    `memory/evergreen/core-interfaces.md`, create a contract test directory in
    `production/contract-tests/` with `contract.md`, `test_provider.[ext]`, and at
    least one `test_consumer_[name].[ext]`. See `.claude/docs/contract-testing-protocol.md`.
48. **Contract Tests Must Pass Before Seam Lock Release**: After any seam change,
    all contract tests for that seam must pass before the seam lock is released.
    This is non-negotiable — do not release the lock with failing contract tests.
49. **Consumer Cannot Read Undeclared Fields**: A consumer test must verify that
    the consumer accesses only fields declared in `contract.md`. Reading undeclared
    fields is a contract violation and must be treated as a failing test.
50. **Contract Change Requires CCR**: Any change to a seam contract (additive,
    breaking, or narrowing) requires a Contract Change Request in the contract test
    directory. Breaking and narrowing changes require `technical-director` approval
    and a DEC-NNNN entry before implementation begins.

## Idea Triage (Evolution 13)

51. **All Ideas Enter the Backlog First**: No design or implementation work begins
    on a new idea without a filed entry in `production/idea-backlog.md`. Ideas are
    not commitments; the backlog is a low-friction inbox, not a sprint queue.
52. **Assign a Scope to Every Idea**: Every backlog entry must be labeled MICRO,
    MINOR, MAJOR, or PILLAR. When in doubt, size up. See
    `.claude/docs/idea-triage-protocol.md` for scope definitions and routing rules.
53. **MAJOR and PILLAR Ideas Require Scope Boundary Check**: Before approving a
    MAJOR or PILLAR idea, verify it does not conflict with the current milestone's
    `Explicitly Out of Scope` list or `Known Intentional Constraints` in the latest
    game state snapshot. Conflicting ideas are auto-deferred to the next milestone.
54. **PILLAR Ideas Require Human Sign-Off**: No agent may approve a PILLAR-scope idea.
    Human approval is mandatory. Approval triggers a new Game State Snapshot and an
    immediate integration sprint.
55. **Defer, Do Not Reject Prematurely**: Ideas that are out of scope for the current
    milestone are deferred (Status: Deferred to Milestone N), not rejected. Rejected
    status is reserved for ideas that are structurally incompatible with the game's
    pillars. Deferred ideas are re-evaluated at every milestone boundary.

## Design Hypothesis Validation (Evolution 14)

56. **Every Player-Facing DEC Requires a Hypothesis**: Any DEC-NNNN entry for a
    decision that changes what the player directly experiences must include a
    `Hypothesis` field ("If X, then player will experience Y") and a
    `Validation Criteria` field. Technical/infrastructure decisions may mark these N/A.
57. **Hypothesis Scan at Every Milestone**: The `producer` triggers a hypothesis scan
    at each milestone end. All DEC entries with `Validation Status: Pending` that are
    older than 1 sprint are queued for validation. See
    `.claude/docs/design-hypothesis-protocol.md` for the full scan protocol.
58. **Agents Do Not Validate Their Own Hypotheses**: The agent that filed the DEC
    entry must not determine whether the hypothesis was correct. The `aesthetic-reviewer`
    mediates; the human reviewer has final authority.
59. **Invalidation Is Information, Not Failure**: An invalidated hypothesis means the
    design reasoning was incorrect — not that the implementation was wrong. Mark it
    clearly as `Invalidated` with a date and notes. Future agents must not build on
    invalidated reasoning. Automatically file a new IDEA-NNN for rework.
60. **Superseded Decisions Inherit Deferred Validation**: If a DEC entry is superseded
    before its hypothesis is validated, set `Validation Status: Deferred` on the old
    entry and ensure the new DEC entry carries forward the relevant hypothesis (updated
    to reflect the new decision).

## Scope Declaration in Snapshots (Evolution 15)

61. **Every Snapshot Must Include Explicitly Out of Scope**: When the `producer` or
    `creative-director` creates a new Game State Snapshot, the `Explicitly Out of Scope`
    section is mandatory — not optional. An empty list is acceptable; an absent section
    is not.
62. **Out-of-Scope Items Block MAJOR and PILLAR Ideas**: Before approving any MAJOR or
    PILLAR scope idea, verify it does not require implementing a system listed under
    `Explicitly Out of Scope` in the current snapshot. Conflicting ideas are auto-deferred
    to the next milestone and must reference the snapshot ID that deferred them.
63. **Scope Declarations Are Milestone-Scoped**: An item listed as out-of-scope in
    SNAP-NNN is not permanently excluded — it is excluded for that milestone. Agents must
    not treat scope declarations as permanent rejections. Each new snapshot re-evaluates
    the list.

## Emergent Design Discovery (Evolution 16)

64. **File Before Fixing**: Any unscripted cross-system behavior that a player could
    experience — whether discovered during testing, code review, or integration —
    must be filed as an `EMERGENT_DISCOVERY_[NNNN].md` in
    `production/emergent-discoveries/pending/` before any agent decides its fate.
    See `.claude/docs/emergent-design-protocol.md`.
65. **Humans Classify, Agents Observe**: No agent may classify an emergent behavior as
    a confirmed feature. Agents file the discovery with both the "why feature" and
    "why bug" case presented neutrally. The human reviewer decides.
66. **Three Confirmed Features of the Same Pattern → North Star Candidate**: When the
    `aesthetic-reviewer` identifies three or more confirmed emergent discoveries that
    share an underlying system interaction pattern, flag the pattern to `creative-director`
    for potential North Star induction. See `memory/evergreen/north-star.md`.

## North Star Principles (Evolution 17)

67. **North Star Is Inductively Built**: The `creative-director` may not author North
    Star principles speculatively. Every NS-NNN entry must reference at minimum three
    `EMERGENT_DISCOVERY` files that produced it. Principles written without this basis
    are invalid.
68. **Seam Contracts Must Declare North Star Alignment**: Every seam contract
    (`contract.md`) registered in `memory/evergreen/core-interfaces.md` must include
    a `North Star alignment:` line. Use "N/A — infrastructure seam" if no principle
    applies. Absence of this line is an incomplete contract.
69. **Seams That Contradict a North Star Principle Require Escalation**: If, during
    seam design or a CCR, an agent identifies that a proposed seam design contradicts
    an Active North Star principle, they must escalate to `creative-director` before
    the seam is registered. Do not implement and note the contradiction afterward.

## Pillar Stress Tests (Evolution 18)

70. **Stress Tests Run at Every Milestone**: The `producer` schedules a pillar stress
    test at the end of every milestone. The `aesthetic-reviewer` prepares scenarios.
    A milestone is not complete until the stress test report (PST-NNN) is filed.
    See `.claude/docs/pillar-stress-test-protocol.md`.
71. **Absent Rating Is an Emergency**: Any scenario rated Absent in a pillar stress test
    triggers an immediate MAJOR-scope idea entry and a `creative-director` review before
    the next sprint begins. The sprint does not start until the review is complete.
72. **Declining Trend Is More Serious Than Low Score**: Two consecutive milestone declines
    on the same pillar require a dedicated rework review, even if the absolute score is
    still above 60%. Stable low scores are acceptable; declining trends are not.

## Evergreen Audit (Evolution 19)

73. **Audit Every Two Milestones**: The `producer` triggers an evergreen audit every
    second milestone, and immediately after any PILLAR-scope idea is approved.
    See `.claude/docs/evergreen-audit-protocol.md`.
74. **Every Evergreen Addition Requires a Justification Sentence**: When adding any
    content to `memory/evergreen/`, the proposing agent must write: "This belongs in
    evergreen because agents need it in every session because ___." If this sentence
    cannot be completed honestly, the content does not belong in evergreen.
75. **Flag Zombie Knowledge Immediately**: If any agent reads an evergreen entry that
    appears outdated or no longer applicable, they must append a note to
    `production/integration-notes.md` tagged `evergreen-suspect: [file]:[section]`.
    Do not silently ignore stale evergreen content.
76. **One-In-One-Out Above 800 Tokens**: If `memory/evergreen/` exceeds 800 tokens,
    no new entry may be added without retiring an existing entry of equal or greater
    size. The `producer` enforces this limit at each audit.

