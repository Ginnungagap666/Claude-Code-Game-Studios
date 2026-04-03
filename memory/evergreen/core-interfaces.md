# Core Interfaces

> **Owner**: technical-director
> **Tier**: Evergreen — always loaded, append-only, never delete
> **Modified by**: technical-director only
> **IMPORTANT**: Numeric values, signatures, and type names MUST be copied verbatim.
>   Never summarize or paraphrase entries in this file.

---

## Purpose

This file is the canonical registry of all cross-system seams — the interfaces
that two or more independent systems depend on. Agents read this file to:
- Understand what a system publishes and what it expects to receive
- Know which seam lock file to acquire before modifying an interface
- Ensure their implementation conforms to the agreed-upon contract

---

## Interface Registry

*(Add one section per seam as the project develops.)*

### [Seam Name]

```
Systems involved:  [System A] → [System B]
Event/function:    [EventType | FunctionName]
Defined in:        [filepath]
Lock file name:    [system-a]--[system-b]--[seam-name].lock

Signature:
  [exact signature — copy verbatim from source]

Data contract:
  [field]: [type]   // [constraints, e.g. "must be > 0"]
  [field]: [type]

State constraints:
  Valid in states:  [list from game-state-machine.md]
  Invalid in states: [list]

Notes:
  [Any invariants or ordering guarantees that consumers must rely on]
```

---

*Each entry must be added when a new seam is established. The technical-director
reviews this file at every milestone boundary to promote, deprecate, or update entries.*
