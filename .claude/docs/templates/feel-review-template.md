# Feel Review: [Feature Name]

**Filed by**: [agent name]
**Date**: YYYY-MM-DD
**Sprint**: [N]
**Related task**: [sprint task ID]
**Related files**: [comma-separated list of files changed]

---

## What Was Built

[One paragraph describing the feature in plain language — what the player experiences,
not how the code works.]

---

## Quantitative Proxy Metrics

Before submitting this review, the authoring agent records the following measurable
values from the current build. These are **proxy metrics** — they do not replace human
feel judgment, but they give the reviewer a concrete baseline and help catch regressions
between rework iterations.

> **How to measure**: Run the game at the target frame rate (default: 60 fps).
> Record values using the in-engine profiler, debug overlay, or the timing utilities
> in `tools/feel-metrics/`. Leave a field blank ( `—` ) only if it is genuinely
> not applicable to this feature.

| Metric | Target Range | Measured Value | Notes |
|--------|-------------|----------------|-------|
| **Input → response latency** (ms) | < 50 ms ideal, < 83 ms acceptable | ___ ms | Frames from button press to first visible change × frame_ms |
| **Peak animation frame** (frame #) | [fill from design doc] | frame ___ | Frame at which the primary visual reaches its apex/peak |
| **Hold duration** (frames) | [fill from design doc] | ___ frames | Frames spent at the peak/hold phase before recovery |
| **Recovery duration** (frames) | [fill from design doc] | ___ frames | Frames from peak back to idle/neutral |
| **Audio cue offset** (ms) | ≤ 1 frame (≤ 17 ms at 60 fps) | ___ ms | Delay between triggering event and first audio sample |
| **Screen shake duration** (ms) | [fill from design doc] | ___ ms | If applicable |
| **Screen shake magnitude** (px) | [fill from design doc] | ___ px | Peak displacement at 1080p reference |
| **Camera lag** (frames) | [fill from design doc] | ___ frames | Frames before camera begins following target position |
| **VFX peak frame** (frame #) | [fill from design doc] | frame ___ | Frame at which particle/effect reaches visual peak |
| **UI transition duration** (ms) | < 200 ms (snappy) or [design target] | ___ ms | Full open/close animation wall-clock time |

> **Regression rule**: If a rework iteration changes any measured value by more than
> 20% from the previously approved baseline, note it explicitly in the Sign-Off Notes.
> The reviewer should re-evaluate that dimension even if everything else felt the same.

---

## What to Evaluate

Please test the following and answer each question. Play the feature, then fill in
the sign-off section at the bottom.

### Question 1: [Specific Feel Dimension]

- **What to do**: [Specific action to perform in-game]
- **What to look for**: [Specific behavior, timing, or sensation to observe]
- **Reference**: [Game or moment that captures the correct feel — e.g., "Celeste
  coyote jump: the player should feel forgiven, not punished"]
- **Design target**: [What the design doc or pillar says this should feel like]
- **Quantitative anchor**: [Which metric(s) above most closely track this feel —
  e.g., "Input latency < 50 ms + hold duration 3–5 frames"]
- ✅ / ❌ / Notes: _______________

### Question 2: [Specific Feel Dimension]

- **What to do**: [action]
- **What to look for**: [behavior]
- **Reference**: [reference]
- **Design target**: [target]
- **Quantitative anchor**: [metric(s)]
- ✅ / ❌ / Notes: _______________

### Question 3: [Specific Feel Dimension]

- **What to do**: [action]
- **What to look for**: [behavior]
- **Reference**: [reference]
- **Design target**: [target]
- **Quantitative anchor**: [metric(s)]
- ✅ / ❌ / Notes: _______________

---

## Pillar Alignment Check

| Pillar | How this feature serves it | Does it? |
|--------|---------------------------|----------|
| [Pillar 1 name] | [how] | ✅ / ❌ / ? |
| [Pillar 2 name] | [how] | ✅ / ❌ / ? |

---

## Sign-Off

**Decision**:
- ☐ **Approved** — ship as-is
- ☐ **Approved with minor notes** — notes below, no rework sprint needed
- ☐ **Rejected — rework needed** — see notes below

**Signed by**: _______________
**Date**: _______________

### Notes

[Write specific, actionable feedback here if rejected or if there are minor notes.
Agents will read this to understand exactly what to change. Be concrete: "the jump
arc peaks too early" is actionable; "doesn't feel right" is not.

If rejecting based on a quantitative metric, state the target explicitly:
"Input latency measured at 94 ms — must reach < 50 ms. Likely caused by the physics
step running one frame late."]

---

## Metric Baseline (Approved Builds Only)

*Filled in by `aesthetic-reviewer` when marking this review as Approved.
This baseline is used for regression comparison in future rework iterations.*

| Metric | Approved Value | Date |
|--------|---------------|------|
| Input → response latency | ___ ms | YYYY-MM-DD |
| Peak animation frame | frame ___ | YYYY-MM-DD |
| Hold duration | ___ frames | YYYY-MM-DD |
| Recovery duration | ___ frames | YYYY-MM-DD |
| Audio cue offset | ___ ms | YYYY-MM-DD |

---

*After signing: move this file to `production/feel-review/signed/` (approved) or
`production/feel-review/rejected/` (rejected). The `aesthetic-reviewer` agent will
route rejected reviews to new rework tasks.*
