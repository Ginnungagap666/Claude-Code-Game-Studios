# Claude Code Game Studios -- Game Studio Agent Architecture

Indie game development managed through 48 coordinated Claude Code subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

## Technology Stack

- **Engine**: [CHOOSE: Godot 4 / Unity / Unreal Engine 5]
- **Language**: [CHOOSE: GDScript / C# / C++ / Blueprint]
- **Version Control**: Git with trunk-based development
- **Build System**: [SPECIFY after choosing engine]
- **Asset Pipeline**: [SPECIFY after choosing engine]

> **Note**: Engine-specialist agents exist for Godot, Unity, and Unreal with
> dedicated sub-specialists. Use the set matching your engine.

## Project Structure

@.claude/docs/directory-structure.md

## Engine Version Reference

@docs/engine-reference/godot/VERSION.md

## Technical Preferences

@.claude/docs/technical-preferences.md

## Coordination Rules

@.claude/docs/coordination-rules.md

## Decision Persistence

Before and after any significant decision, consult and update:
@.claude/docs/decision-log.md

## System Impact Awareness

Before modifying any system, consult:
@.claude/docs/system-impact-map.md

## Feel Review Workflow

For any player-facing feature, follow the two-report protocol:
@.claude/docs/feel-review-workflow.md

## Command Pipeline

For any new command, event, or modifier, register with `command-pipeline-guardian` first.

## Game State Snapshots

Before major refactors, read the latest snapshot:
@.claude/docs/game-state-snapshots.md

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
- Agents MUST show drafts or summaries before requesting approval
- Multi-file changes require explicit approval for the full changeset
- No commits without user instruction

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

> **First session?** If the project has no engine configured and no game concept,
> run `/start` to begin the guided onboarding flow.

## Coding Standards

@.claude/docs/coding-standards.md

## Context Management

@.claude/docs/context-management.md

## Layered Memory

All agents load `memory/evergreen/` unconditionally every session.
For memory tier rules and milestone archiving:
@.claude/docs/memory-architecture.md

## Seam Locks

Before modifying any cross-system interface, acquire a lock:
@.claude/docs/seam-lock-protocol.md

## Integration Sprints

Cross-system intersection workflow and integration notes:
@.claude/docs/integration-sprint.md

## On-Demand Context Loading

Task specs define exact context load lists and token budgets:
@.claude/docs/context-loading-protocol.md

## Seam Drift Detection

Before releasing any seam lock, run the drift check:
@.claude/docs/seam-drift-detection.md

## Test Layering

Every test file must be tagged; run only triggered tests on feature branches:
@.claude/docs/test-layering-protocol.md

## Design Doc Staleness

Design docs must stay in sync with their covered source paths:
@.claude/docs/design-doc-staleness.md

## Contract Testing

Every registered seam must have a contract test that passes before merge:
@.claude/docs/contract-testing-protocol.md

## Idea Triage

All ideas — from easter eggs to design philosophy shifts — enter the backlog first:
@.claude/docs/idea-triage-protocol.md

## Design Hypothesis Validation

Every player-facing decision must declare a hypothesis and be validated at milestone end:
@.claude/docs/design-hypothesis-protocol.md

## Scope Declaration

Every game state snapshot must declare what is explicitly out of scope for the milestone:
@.claude/docs/game-state-snapshots.md

## Emergent Design Discovery

Unscripted cross-system interactions must be filed before being fixed or ignored:
@.claude/docs/emergent-design-protocol.md

## North Star Principles

System interaction philosophy, inductively built from confirmed emergent discoveries:
@memory/evergreen/north-star.md

## Pillar Stress Tests

Whole-game pillar health checks run at every milestone:
@.claude/docs/pillar-stress-test-protocol.md

## Evergreen Audit

Periodic review to retire zombie knowledge from the evergreen memory layer:
@.claude/docs/evergreen-audit-protocol.md
