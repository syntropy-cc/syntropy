# Implementation Backlog

> **Project**: {PROJECT_NAME}
> **Last Updated**: {YYYY-MM-DD}
> **Total Items**: {N} | **Done**: {N} | **In Progress**: {N} | **Ready**: {N} | **Backlog**: {N}

## Overview

This document contains ALL identified work items for the project. Items are organized by architectural component and prioritized for implementation. For items currently being worked on, see [CURRENT-WORK.md](./CURRENT-WORK.md).

## Quick Stats

| Status | Count | Percentage |
|--------|-------|------------|
| Done | {N} | {N}% |
| Review | {N} | {N}% |
| In Progress | {N} | {N}% |
| Ready | {N} | {N}% |
| Backlog | {N} | {N}% |
| **Total** | **{N}** | **100%** |

## Backlog by Component

Items are grouped by architectural component. Each component links to its detailed implementation record.

---

### {Component 1 Name}

**Architecture Reference**: [ARCHITECTURE.md#component-1](../architecture/ARCHITECTURE.md#component-1)
**Implementation Record**: [COMP-001-component-name.md](./components/COMP-001-component-name.md)
**Component Status**: 🔵 In Progress | **Coverage**: {N}%

#### [COMP-001.1] {Task Title}

| Field | Value |
|-------|-------|
| **Status** | Done ✅ |
| **Priority** | Critical |
| **Origin** | ARCH-001 |
| **Size** | S |
| **Created** | {YYYY-MM-DD} |
| **Completed** | {YYYY-MM-DD} |

{Brief description of the task}

**Acceptance Criteria**:
- [x] {Criterion 1}
- [x] {Criterion 2}

---

#### [COMP-001.2] {Task Title}

| Field | Value |
|-------|-------|
| **Status** | In Progress 🔵 |
| **Priority** | High |
| **Origin** | ARCH-001 |
| **Dependencies** | COMP-001.1 |
| **Size** | M |
| **Created** | {YYYY-MM-DD} |
| **Started** | {YYYY-MM-DD} |

{Brief description of the task}

**Acceptance Criteria**:
- [x] {Criterion 1 - completed}
- [ ] {Criterion 2 - pending}
- [ ] {Criterion 3 - pending}

---

#### [COMP-001.3] {Task Title}

| Field | Value |
|-------|-------|
| **Status** | Ready |
| **Priority** | Medium |
| **Origin** | ARCH-001 |
| **Dependencies** | COMP-001.2 |
| **Size** | S |
| **Created** | {YYYY-MM-DD} |

{Brief description of the task}

**Acceptance Criteria**:
- [ ] {Criterion 1}
- [ ] {Criterion 2}

---

### {Component 2 Name}

**Architecture Reference**: [ARCHITECTURE.md#component-2](../architecture/ARCHITECTURE.md#component-2)
**Implementation Record**: [COMP-002-component-name.md](./components/COMP-002-component-name.md)
**Component Status**: ⬜ Not Started | **Coverage**: 0%

#### [COMP-002.1] {Task Title}

| Field | Value |
|-------|-------|
| **Status** | Backlog |
| **Priority** | High |
| **Origin** | ARCH-002 |
| **Dependencies** | COMP-001 (component) |
| **Size** | M |
| **Created** | {YYYY-MM-DD} |

{Brief description of the task}

**Acceptance Criteria**:
- [ ] {Criterion 1}
- [ ] {Criterion 2}

---

## Cross-Cutting Items

Items that span multiple components or are not tied to a specific component.

### Technical Tasks

#### [TASK-001] {Task Title}

| Field | Value |
|-------|-------|
| **Status** | Backlog |
| **Priority** | Medium |
| **Origin** | ADR-005 |
| **Size** | S |
| **Created** | {YYYY-MM-DD} |

{Brief description}

---

### Technical Debt

#### [DEBT-001] {Debt Item Title}

| Field | Value |
|-------|-------|
| **Status** | Backlog |
| **Priority** | Low |
| **Origin** | Code Review / Implementation |
| **Size** | M |
| **Created** | {YYYY-MM-DD} |
| **Affected Components** | COMP-001, COMP-003 |

{Description of the technical debt and why it should be addressed}

**Impact if not addressed**: {What happens if we leave this debt}

---

### Documentation Tasks

#### [DOC-001] {Documentation Task Title}

| Field | Value |
|-------|-------|
| **Status** | Backlog |
| **Priority** | Low |
| **Origin** | {Source} |
| **Size** | S |
| **Created** | {YYYY-MM-DD} |

{Brief description of documentation needed}

---

## Dependency Graph

Visual representation of item dependencies:

```
COMP-001.1 (Done)
    │
    └──▶ COMP-001.2 (In Progress)
              │
              └──▶ COMP-001.3 (Ready)
                        │
                        └──▶ COMP-002.1 (Backlog)
                                  │
                                  └──▶ COMP-002.2 (Backlog)

COMP-003.1 (Backlog) ──▶ No dependencies, can start anytime
```

## Priority Matrix

| Priority | Criteria | Items |
|----------|----------|-------|
| **Critical** | Blocks other work, core functionality | {List item IDs} |
| **High** | Important for milestone, significant value | {List item IDs} |
| **Medium** | Should be done, not blocking | {List item IDs} |
| **Low** | Nice to have, can defer | {List item IDs} |

## Filters (for reference)

### Items Ready to Start (No Blockers)

Items that can be started immediately:
- [COMP-001.3] {Title} - Ready
- [COMP-003.1] {Title} - Backlog, no dependencies

### Blocked Items

Items waiting on dependencies:
- [COMP-002.1] Waiting on: COMP-001 component completion

### High Priority Not Started

High priority items still in backlog:
- [COMP-002.1] {Title}

---

## Maintenance Notes

### Adding New Items

When adding a new item:
1. Determine the parent component
2. Assign next available ID (COMP-XXX.N or TYPE-NNN)
3. Fill in all required fields
4. Add to component record if applicable
5. Update total counts at top of document

### Updating Status

When changing status:
1. Update the Status field
2. Add Started/Completed date as appropriate
3. Update acceptance criteria checkboxes
4. Update component record
5. Update counts at top of document

### Archiving

Completed items remain in this document for historical reference. They are marked with ✅ and have a completion date. Periodically, very old completed items may be moved to an archive file to keep this document manageable.
