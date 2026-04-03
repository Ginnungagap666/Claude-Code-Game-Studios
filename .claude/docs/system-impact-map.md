# System Impact Map

The System Impact Map is a **living dependency graph** that describes which game systems
affect which other systems. Unlike static architecture diagrams, this file is updated
by agents whenever they discover or create a cross-system dependency.

Every agent must consult this file before starting work on any task that touches
more than one system. Every agent must update this file when they introduce a new
cross-system call or data dependency.

---

## How to Use This File

### Before starting a task
1. Find your target system(s) in the index below.
2. Read its `Upstream` (what it depends on) and `Downstream` (what depends on it).
3. Any system in `Downstream` is **potentially affected by your change**. Review
   those systems' owners and, if your change alters an interface, notify them via
   a `FEEL_REVIEW_NEEDED.md` entry or a new task for the responsible agent.

### After implementing a new dependency
Append or update the relevant system entry. Use the format in the template below.

---

## Map Format

```markdown
### [SystemName]

- **Owner Agent**: [agent responsible for this system]
- **Source Path**: `src/path/to/system/`
- **Upstream** (this system reads from / calls):
  - `SystemA` — [what data or calls flow from A into this system]
  - `SystemB` — [what data or calls flow from B into this system]
- **Downstream** (systems that read from / call into this system):
  - `SystemC` — [what data or calls this system exposes to C]
  - `SystemD` — [what data or calls this system exposes to D]
- **Shared State**: [any global state, singletons, or event buses this system
  reads or writes that are not covered by the above]
- **Interface Contracts**: [link to relevant ADR or interface definition file]
- **Known Cross-System Risks**:
  - [Risk 1: describe what breaks and under what condition]
```

---

## System Entries

<!-- Populate this section as systems are built. One entry per major system. -->

### [Template — replace with your first real system]

- **Owner Agent**: `gameplay-programmer`
- **Source Path**: `src/gameplay/template/`
- **Upstream**: *(none yet)*
- **Downstream**: *(none yet)*
- **Shared State**: *(none yet)*
- **Interface Contracts**: *(none yet)*
- **Known Cross-System Risks**: *(none yet)*

---

## Change History

| Date | Editor | Change Summary |
|------|--------|----------------|
| *(project start)* | — | File initialized |
