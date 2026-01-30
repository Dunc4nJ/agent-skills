# Plan Template

Use this template structure when creating implementation plans. All sections are required unless marked optional.

---

# [Plan Title]

> Auto-generated: [timestamp]
> Status: Draft | Ready for Implementation

## Overview

[One paragraph summary of what this plan accomplishes. Should answer: What are we building? Why? What's the expected outcome?]

## Context

### Background
[Business or technical context that motivated this work. Why is this needed now?]

### Current State
[Description of relevant existing functionality, if any. What does the system look like today?]

### Goals
- [ ] Goal 1
- [ ] Goal 2
- [ ] Goal 3

### Non-Goals (Out of Scope)
- Item explicitly excluded from this work
- Another excluded item

## Design Decisions

Document all significant decisions made during planning with their rationale.

### Decision 1: [Topic]

**Options Considered:**
1. Option A - [brief description]
2. Option B - [brief description]

**Chosen:** Option A

**Rationale:** [Why this option was selected given the requirements and constraints]

### Decision 2: [Topic]

**Options Considered:**
1. Option A
2. Option B

**Chosen:** Option B

**Rationale:** [Explanation]

## Implementation

### Phase 1: [Phase Name] (if multi-phase)

#### Step 1.1: [Step Name]

**Description:** What this step accomplishes

**Files to modify:**
- `path/to/file1.py` - [what changes]
- `path/to/file2.py` - [what changes]

**Files to create:**
- `path/to/new_file.py` - [purpose]

**Implementation details:**
```python
# Key code patterns or snippets to use
```

**Dependencies:** None / Step X.Y must be completed first

---

#### Step 1.2: [Step Name]

**Description:** ...

**Files to modify:**
- ...

---

### Phase 2: [Phase Name] (if needed)

[Repeat step structure]

---

## Files Summary

### Files to Create
| File | Purpose |
|------|---------|
| `path/to/new_file.py` | Brief description |

### Files to Modify
| File | Changes |
|------|---------|
| `path/to/existing.py` | What's being changed |

### Files to Delete (if any)
| File | Reason |
|------|--------|
| `path/to/old_file.py` | Replaced by X |

## Verification

### Acceptance Criteria

- [ ] Criterion 1: [Specific, testable condition]
- [ ] Criterion 2: [Specific, testable condition]
- [ ] Criterion 3: [Specific, testable condition]

### Test Commands

```bash
# Unit tests
pytest tests/unit/test_feature.py -v

# Integration tests
pytest tests/integration/test_feature_integration.py -v

# Manual verification
curl -X POST http://localhost:8000/api/endpoint -d '{"test": "data"}'
```

### Test Cases to Add

| Test | Description | File |
|------|-------------|------|
| `test_feature_happy_path` | Tests normal operation | `tests/test_feature.py` |
| `test_feature_error_handling` | Tests error conditions | `tests/test_feature.py` |

## Resources

### External Documentation
- [Link to relevant docs](url)
- [Library documentation](url)

### Research Findings

**From Perplexity Research:**
> Key findings from web research about best practices

**From NIA Documentation:**
> Relevant library patterns and examples discovered

### Related Code
- `path/to/related/implementation.py` - Similar pattern we can follow
- `path/to/tests/example.py` - Test patterns to emulate

## Open Questions (Optional)

[Any remaining uncertainties - should be minimal in a finalized plan]

- Question 1: [If unresolved, note who should answer]
- Question 2: [If unresolved, note who should answer]

## Appendix (Optional)

### Diagrams

[ASCII diagrams, mermaid diagrams, or references to external diagrams]

### Additional Context

[Any extra information that didn't fit elsewhere but is relevant]

---

## Checklist Before Implementation

- [ ] All design decisions documented with rationale
- [ ] All files to modify/create identified
- [ ] Acceptance criteria are specific and testable
- [ ] Test commands provided
- [ ] No unresolved blockers in Open Questions
- [ ] Plan is self-contained (another dev could execute without context)
