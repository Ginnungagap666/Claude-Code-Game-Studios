# Design Doc Waivers

> **Owner**: lead-programmer (reviews); any agent (writes)
> **Cleared**: Waivers expire automatically on their Expires date.
>   Expired waivers stay in this file for audit; do not delete them.
>
> Protocol: `.claude/docs/design-doc-staleness.md`

---

## Purpose

A staleness waiver temporarily suspends the staleness check for a specific design doc.
File a waiver when a code change was a pure refactor or implementation detail that did
not alter any player-facing behavior described in the doc.

**Waivers are not a way to avoid updating design docs.** If the code change altered
design intent, update the doc. Waivers are only for non-behavioral code changes.

---

## Waiver Format

```markdown
## WAIVER-NNN: [DESIGN-NNN] — [one-line reason]

**Filed by**: [agent name]
**Date**: YYYY-MM-DD
**Expires**: YYYY-MM-DD (max 30 days from filing date)
**Applies to**: DESIGN-NNN
**Status**: Active | Expired

**Reason**: [Why the code change did not affect the design doc. Be specific:
name the files changed and explain why the change was non-behavioral.]
```

---

*(No waivers filed yet.)*
