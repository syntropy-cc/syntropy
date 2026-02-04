# {Component Name} Implementation Record

> **Component ID**: COMP-{XXX}
> **Architecture Reference**: [ARCHITECTURE.md#{section}](../../architecture/ARCHITECTURE.md#{section})
> **Status**: ⬜ Not Started | 🔵 In Progress | ✅ Complete
> **Created**: {YYYY-MM-DD}
> **Last Updated**: {YYYY-MM-DD}

## Component Overview

### Architecture Summary

{Copy or summarize the component description from the architecture document. This provides quick context without needing to navigate to the architecture.}

**Responsibilities**:
- {Primary responsibility 1}
- {Primary responsibility 2}
- {Primary responsibility 3}

**Key Interfaces**:
- {Interface 1}: {Brief description}
- {Interface 2}: {Brief description}

### Implementation Scope

**In Scope**:
- {What this component implementation includes}
- {What this component implementation includes}

**Out of Scope**:
- {What is NOT part of this component}
- {Handled by other components: reference them}

---

## Work Items

### Summary

| Status | Count |
|--------|-------|
| ✅ Done | {N} |
| 🔵 In Progress | {N} |
| ⬜ Ready/Backlog | {N} |
| **Total** | **{N}** |

**Component Coverage**: {N}%

### Item List

#### [COMP-{XXX}.1] {First Task Title}

| Field | Value |
|-------|-------|
| **Status** | ✅ Done |
| **Size** | S |
| **Started** | {YYYY-MM-DD} |
| **Completed** | {YYYY-MM-DD} |

**Description**: {What was implemented}

**Acceptance Criteria**:
- [x] {Criterion 1}
- [x] {Criterion 2}

**Files Created/Modified**:
- `src/domain/{file}.py` - Created
- `tests/unit/domain/test_{file}.py` - Created

---

#### [COMP-{XXX}.2] {Second Task Title}

| Field | Value |
|-------|-------|
| **Status** | 🔵 In Progress |
| **Size** | M |
| **Started** | {YYYY-MM-DD} |

**Description**: {What is being implemented}

**Acceptance Criteria**:
- [x] {Criterion 1 - completed}
- [ ] {Criterion 2 - pending}
- [ ] {Criterion 3 - pending}

**Current Progress**:
{Description of current state and what remains}

---

#### [COMP-{XXX}.3] {Third Task Title}

| Field | Value |
|-------|-------|
| **Status** | ⬜ Ready |
| **Size** | S |
| **Dependencies** | COMP-{XXX}.2 |

**Description**: {What needs to be implemented}

**Acceptance Criteria**:
- [ ] {Criterion 1}
- [ ] {Criterion 2}

---

## Dependencies

### This Component Requires

Components/services that must be available for this component to function.

| Dependency | Type | Status | Notes |
|------------|------|--------|-------|
| {Component A} | Internal | ✅ Available | Used for {purpose} |
| {Component B} | Internal | 🔵 In Progress | Needed for {feature} |
| {External Service} | External | ✅ Available | API for {purpose} |

### Required By (Dependents)

Components/services that depend on this component.

| Dependent | Relationship | Impact if Delayed |
|-----------|--------------|-------------------|
| {Component X} | Uses {interface} | Blocks {feature} |
| {Component Y} | Consumes events | Delays {capability} |

---

## Implementation Decisions

Decisions made during implementation that aren't captured in ADRs. These are typically smaller, tactical decisions.

### Decision 1: {Decision Title}

**Date**: {YYYY-MM-DD}
**Context**: {Why this decision was needed}
**Decision**: {What was decided}
**Rationale**: {Why this choice was made}
**Alternatives Considered**:
- {Alternative 1}: Rejected because {reason}
- {Alternative 2}: Rejected because {reason}

---

### Decision 2: {Decision Title}

**Date**: {YYYY-MM-DD}
**Context**: {Context}
**Decision**: {Decision}
**Rationale**: {Rationale}

---

## Technical Details

### File Structure

```
src/
└── {layer}/
    └── {component}/
        ├── __init__.py
        ├── {entity}.py          # Domain entity
        ├── {service}.py         # Domain service
        ├── {repository}.py      # Repository interface
        └── exceptions.py        # Component-specific exceptions

tests/
└── {layer}/
    └── {component}/
        ├── test_{entity}.py
        ├── test_{service}.py
        └── conftest.py          # Component-specific fixtures
```

### Key Classes/Functions

| Name | Type | Purpose |
|------|------|---------|
| `{ClassName}` | Entity | {Purpose} |
| `{ServiceName}` | Service | {Purpose} |
| `{RepositoryName}` | Interface | {Purpose} |

### API/Interface Summary

```python
# Key public interface
class {ComponentName}Service:
    def {method_1}(self, ...) -> ...:
        """Brief description."""
    
    def {method_2}(self, ...) -> ...:
        """Brief description."""
```

---

## Testing

### Test Coverage

| Type | Files | Coverage |
|------|-------|----------|
| Unit Tests | {N} | {N}% |
| Integration Tests | {N} | {N}% |
| Total | {N} | {N}% |

### Key Test Scenarios

1. **{Scenario 1}**: {What is tested and why}
2. **{Scenario 2}**: {What is tested and why}
3. **{Scenario 3}**: {What is tested and why}

### Test Files

- `tests/unit/{component}/test_{entity}.py`
- `tests/unit/{component}/test_{service}.py`
- `tests/integration/{component}/test_{repository}.py`

---

## Implementation Log

Chronological log of significant implementation events. This provides context for future work on this component.

### {YYYY-MM-DD} - Component Created

- Created initial implementation record
- Extracted {N} work items from architecture
- Identified dependencies: {list}

### {YYYY-MM-DD} - Started COMP-{XXX}.1

- Beginning implementation of {task}
- Approach: {brief description of approach}

### {YYYY-MM-DD} - Completed COMP-{XXX}.1

- Successfully implemented {feature}
- Tests passing: {N} unit tests
- Decision made: {reference to decision above}

### {YYYY-MM-DD} - Architecture Update Impact

- Architecture updated via ADR-{XXX}
- Impact on this component: {description}
- New work items created: COMP-{XXX}.{N}

### {YYYY-MM-DD} - Blocker Encountered

- **Issue**: {Description of blocker}
- **Cause**: {Why this happened}
- **Resolution**: {How it was resolved}
- **Lesson**: {What to do differently next time}

---

## Lessons Learned

Insights gained during implementation that may help future development.

### What Worked Well

- {Thing that worked well and why}
- {Another success and why}

### What Could Be Improved

- {Challenge encountered and how to avoid it}
- {Improvement suggestion for future}

### Recommendations for Similar Components

- {Advice for implementing similar components}
- {Patterns that should be reused}

---

## Evolution History

Record of how this component has evolved. Component records are permanent and track the full lifecycle.

### v1.0 - Initial Implementation

**Date**: {YYYY-MM-DD}
**Milestone**: {Milestone name}

- Initial implementation complete
- Core functionality: {list}
- Tests: {coverage}%

### v1.1 - {Enhancement Name}

**Date**: {YYYY-MM-DD}
**Trigger**: ADR-{XXX} / RFC-{XXX} / Bug fix

- {What changed}
- {Why it changed}
- New work items: {list}

### v2.0 - {Major Change Name}

**Date**: {YYYY-MM-DD}
**Trigger**: RFC-{XXX}

- **Breaking Changes**: {list}
- **Migration Required**: {Yes/No}
- **Migration Guide**: [Link to guide]

---

## References

### Architecture Documents

- [Component Specification](../../architecture/ARCHITECTURE.md#{section})
- [Domain Architecture](../../architecture/domains/{domain}/ARCHITECTURE.md)

### Related ADRs

| ADR | Title | Relevance |
|-----|-------|-----------|
| [ADR-{XXX}](../../architecture/decisions/ADR-{XXX}.md) | {Title} | {How it relates} |

### Related Components

| Component | Relationship |
|-----------|--------------|
| [COMP-{YYY}](./COMP-{YYY}-name.md) | {Relationship description} |

### External Documentation

- {Link to relevant external docs}
- {Link to API documentation}
