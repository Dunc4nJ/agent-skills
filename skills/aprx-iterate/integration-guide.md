# Integration Guide

How to integrate GPT Pro suggestions into spec and README documents.

## Critical Rule: File Scope

**You may ONLY modify the files specified in the workflow configuration:**
- The spec file (`documents.spec`)
- The README file (`documents.readme`)
- The implementation file (`documents.implementation`) if configured

**When GPT Pro suggests creating new files:**
- Do NOT create the files
- Instead, **incorporate the content into the spec document** as a new section
- Example: If GPT Pro suggests `docs/ARCHITECTURE.md` with architecture content, add an "Architecture" section to the spec with that content
- This keeps all planned work in the spec where it belongs

## GPT Pro Output Format

Round outputs contain suggestions in this structure:

```
## N) [Suggestion Title]

### What's weak/risky now
[Description of current issue]

### Proposed revision
[Detailed changes to make]

### Why it improves the project
[Rationale and benefits]

### Diff patch
```diff
--- a/SPEC.md
+++ b/SPEC.md
@@ ...
 [context lines]
-[removed lines]
+[added lines]
```
```

## Integration Process

### Step 1: Read Round Output

```bash
aprx robot show N
```

Parse the JSON response to extract `data.content` which contains the full GPT Pro output text.

### Step 2: Parse Suggestions

For each numbered suggestion:
1. Read the "What's weak/risky now" section
2. Understand the "Proposed revision"
3. Evaluate the rationale in "Why it improves"
4. Extract the diff patch if provided

### Step 3: Evaluate Each Suggestion

GPT Pro suggestions are recommendations, not commands. Evaluate:

| Factor | Accept If | Skip If |
|--------|-----------|---------|
| Relevance | Addresses real issue | Solves non-existent problem |
| Scope | Fits project goals | Adds unnecessary complexity |
| Conflict | No prior implementation | Already addressed in earlier round |
| Quality | Clear improvement | Marginal or debatable benefit |

**New file suggestions**: If GPT Pro suggests creating new files, incorporate the content into the spec document instead of creating the files.

### Step 4: Apply to Spec

For accepted suggestions:

1. **If diff provided**: Apply the patch to the Spec file
2. **If no diff**: Manually implement the described changes
3. **Preserve structure**: Maintain document formatting
4. **Add context**: Include brief comments for non-obvious changes

### Step 5: Update README

Keep README synchronized with Spec:

1. Update feature descriptions to match new spec
2. Reflect architectural changes in overview
3. Update command examples if behavior changed
4. Ensure "Quick Start" stays accurate

### Step 6: Update Implementation (When Applicable)

APRX handles implementation inclusion automatically via `impl_every_n` in workflow YAML. When implementation was included in the round:

1. Review code-level suggestions in `data.content`
2. Update implementation doc to match spec
3. Note any spec-implementation gaps
4. Flag items for future code changes

## Handling Conflicts

### Suggestion Already Applied

If a suggestion addresses something fixed in a prior round:

```
Skipped: [Suggestion title] - Already addressed in round N
```

### Contradictory Suggestions

If a suggestion contradicts an earlier accepted change:

1. Evaluate which approach is better
2. If new is better: Apply and note the change
3. If old is better: Skip with explanation

```
Skipped: [Suggestion title] - Conflicts with round N decision to [reason]
```

### Partial Application

If only part of a suggestion applies:

1. Apply the relevant portions
2. Document what was skipped and why

```
Partially applied: [Suggestion title]
- Applied: [what was used]
- Skipped: [what was omitted] - [reason]
```

## Integration Summary Format

After integrating all suggestions:

```
Round N integration complete.

Changes made:
- [Change 1]: [Brief description]
- [Change 2]: [Brief description]
- [Change 3]: [Brief description]

New file suggestions incorporated into spec:
- [Suggested file]: Added as "[Section Name]" in spec

Skipped:
- [Suggestion]: [Reason]

Files modified: SPEC.md, README.md
```

**Note**: Only list the actual workflow document files in "Files modified".

## Quality Checklist

Before committing integration:

- [ ] Spec document is internally consistent
- [ ] README reflects all spec changes
- [ ] No duplicate sections introduced
- [ ] Formatting preserved
- [ ] Links still valid
- [ ] Examples still accurate
