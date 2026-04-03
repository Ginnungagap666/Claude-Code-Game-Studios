# Integration Notes

> **Owner**: lead-programmer (reviews); any agent (writes)
> **Cleared**: Each integration sprint — items either resolved or promoted to open-risks.md

---

## Purpose

This file is the living log of cross-system intersection issues. Any agent that
discovers a seam mismatch, a duplicate utility, a timing conflict between systems,
or any other cross-system integration concern — even mid-sprint — appends an entry
here immediately.

The integration sprint team uses this file as its primary work queue.

---

## Entry Format

```markdown
## [YYYY-MM-DD] [System A] × [System B]: [One-line description]

**Filed by**: [agent name]
**Sprint found**: [N]
**Integration sprint target**: [N+1 or N+2]
**Status**: Open | In Progress | Resolved

### Description
[What the intersection problem is. Be concrete: what does System A emit that
System B misinterprets?]

### Proposed Resolution
[How this should be fixed. Reference the seam in memory/evergreen/core-interfaces.md if applicable.]

### Resolution Notes
[Filled in when resolved: what was actually done, any follow-up tasks created.]
```

---

*(No integration issues filed yet.)*
