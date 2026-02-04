# Current Work

> **Project**: {PROJECT_NAME}
> **Period**: {Start Date} - Ongoing (Continuous Flow)
> **Last Updated**: {YYYY-MM-DD HH:MM}

## Active Focus

This document contains items currently being worked on or ready to start. It is the primary document to consult before implementing anything.

> **AI Instruction**: ALWAYS read this document before starting any implementation work. Only work on items listed here. If asked to implement something not listed, first discuss adding it to this document.

## Quick Status

| Category | Count |
|----------|-------|
| 🔵 In Progress | {N} |
| ✅ Ready to Start | {N} |
| ⏸️ Paused | {N} |
| 🔴 Blocked | {N} |

## Current Priority Order

Work on items in this order (top = highest priority):

1. **Continue In Progress items** (don't start new work until these are done)
2. **Unblock blocked items** (if possible)
3. **Start Ready items** (in priority order below)

---

## 🔵 In Progress

Items actively being implemented. Complete these before starting new work.

### [COMP-001.2] {Task Title}

| Field | Value |
|-------|-------|
| **Status** | In Progress |
| **Priority** | High |
| **Started** | {YYYY-MM-DD} |
| **Component** | [{Component Name}](./components/COMP-001-name.md) |
| **Origin** | [ARCH-001](../architecture/ARCHITECTURE.md#section) |

**What's being implemented**:
{Brief description of what this task accomplishes}

**Current Progress**:
- [x] {Completed step 1}
- [x] {Completed step 2}
- [ ] {Next step to do}
- [ ] {Future step}

**Implementation Notes**:
{Any notes from the current implementation session - decisions made, issues encountered}

**Next Actions**:
1. {Specific next action to take}
2. {Following action}

---

### [COMP-003.1] {Task Title}

| Field | Value |
|-------|-------|
| **Status** | In Progress |
| **Priority** | Medium |
| **Started** | {YYYY-MM-DD} |
| **Component** | [{Component Name}](./components/COMP-003-name.md) |
| **Origin** | [ADR-005](../architecture/decisions/ADR-005.md) |

**What's being implemented**:
{Brief description}

**Current Progress**:
- [x] {Completed step}
- [ ] {Pending step}

**Next Actions**:
1. {Next action}

---

## 🔴 Blocked

Items that cannot proceed due to dependencies or external factors.

### [COMP-002.1] {Task Title}

| Field | Value |
|-------|-------|
| **Status** | Blocked |
| **Priority** | High |
| **Blocked Since** | {YYYY-MM-DD} |
| **Component** | [{Component Name}](./components/COMP-002-name.md) |

**Blocked By**: [COMP-001] Component must be complete first

**Unblock Criteria**:
- [ ] COMP-001.2 is Done
- [ ] COMP-001.3 is Done

**Workaround Available**: {Yes/No - if yes, describe}

---

## ⏸️ Paused

Items started but intentionally paused (not blocked).

### [TASK-005] {Task Title}

| Field | Value |
|-------|-------|
| **Status** | Paused |
| **Priority** | Low |
| **Paused Since** | {YYYY-MM-DD} |
| **Pause Reason** | {Why this was paused} |

**Resume When**: {Condition for resuming this work}

**Context to Remember**:
{Important context needed when resuming this work}

---

## ✅ Ready to Start

Items with all dependencies met, ready to begin. Start these in priority order after completing In Progress items.

### Priority 1 (Start First)

#### [COMP-001.3] {Task Title}

| Field | Value |
|-------|-------|
| **Status** | Ready |
| **Priority** | High |
| **Component** | [{Component Name}](./components/COMP-001-name.md) |
| **Origin** | [ARCH-001](../architecture/ARCHITECTURE.md#section) |
| **Dependencies** | COMP-001.2 ✅ (Done) |
| **Estimated Size** | S |

**What to implement**:
{Clear description of what needs to be done}

**Acceptance Criteria**:
- [ ] {Criterion 1}
- [ ] {Criterion 2}
- [ ] {Criterion 3}

**Getting Started**:
1. {First step to take}
2. {Second step}
3. {Third step}

**Files likely to touch**:
- `src/domain/{file}.py`
- `tests/unit/domain/test_{file}.py`

---

### Priority 2

#### [COMP-004.1] {Task Title}

| Field | Value |
|-------|-------|
| **Status** | Ready |
| **Priority** | Medium |
| **Component** | [{Component Name}](./components/COMP-004-name.md) |
| **Origin** | [ARCH-004](../architecture/ARCHITECTURE.md#section) |
| **Dependencies** | None |
| **Estimated Size** | M |

**What to implement**:
{Description}

**Acceptance Criteria**:
- [ ] {Criterion 1}
- [ ] {Criterion 2}

---

### Priority 3

#### [TASK-010] {Task Title}

| Field | Value |
|-------|-------|
| **Status** | Ready |
| **Priority** | Low |
| **Origin** | Technical improvement |
| **Dependencies** | None |
| **Estimated Size** | S |

**What to implement**:
{Description}

---

## Recently Completed

Items completed in the current period (for context and reference).

### [COMP-001.1] {Task Title} ✅

| Field | Value |
|-------|-------|
| **Completed** | {YYYY-MM-DD} |
| **Duration** | {N} days |
| **Component** | [{Component Name}](./components/COMP-001-name.md) |

**Summary**: {One-line summary of what was accomplished}

---

## Upcoming (Next in Queue)

Items that will become Ready soon. Helps with planning.

| Item | Waiting On | Expected Ready |
|------|------------|----------------|
| [COMP-002.1] | COMP-001 complete | ~{date} |
| [COMP-005.1] | COMP-002.1, COMP-003.1 | ~{date} |

---

## Session Log

Brief log of work sessions for continuity.

### {YYYY-MM-DD} - Session Summary

**Worked On**: [COMP-001.2]
**Accomplished**:
- {What was done}
- {What was done}

**Decisions Made**:
- {Decision and rationale}

**Next Session Should**:
- {Continue with X}
- {Start Y if X is complete}

---

### {YYYY-MM-DD} - Session Summary

**Worked On**: [COMP-001.1]
**Accomplished**:
- Completed implementation
- All tests passing

**Items Completed**: COMP-001.1 ✅

---

## Notes for AI Assistant

### Before Starting Work

1. Read this entire document to understand current state
2. Check if any In Progress items need completion first
3. Verify Ready items still have dependencies met
4. Select the highest priority Ready item if nothing is In Progress

### During Work

1. Update "Current Progress" checkboxes as you complete steps
2. Add "Implementation Notes" for important decisions
3. Update "Next Actions" if the plan changes

### After Completing Work

1. Move completed item to "Recently Completed"
2. Update status in BACKLOG.md
3. Update component record
4. Check if completion unblocks any Blocked items
5. Update any dependent items' status to Ready

### When Blocked

1. Move item to Blocked section
2. Clearly document what's blocking
3. Identify if workaround exists
4. Continue with other Ready items
