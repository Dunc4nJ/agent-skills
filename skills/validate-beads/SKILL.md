---
name: validate-beads
description: Decompose and validate an existing set of Beads against a plan or spec, including self-containment, coverage, and dependency correctness. Use after decompose-plan and before implementation.
---

# Validate Beads (Beads QA gate)

Quality gate between **planning** and **execution**.

## Hard rules

- **Do not spawn subagents automatically.** This skill is only the validation workflow.
- Validate inside the target repo that contains `.beads/`.
- Prefer fixing via `br update` when you can do so confidently.

## Inputs

- Path to the original plan/spec file.

## Workflow

### 1) Preflight

```bash
cd <target-repo>
br where
ls .beads/decomposition-logs || true
```

- Find the most recent decomposition log in `.beads/decomposition-logs/`.
- Extract bead IDs from the log.

### 2) Load current bead set

For each bead ID:

```bash
br show <id> --json
```

### 3) Run structural suggestions

```bash
bv --robot-suggest
bv --robot-suggest --suggest-type=dependency
bv --robot-suggest --suggest-type=cycle
bv --robot-suggest --suggest-type=duplicate
```

### 4) Validate self-containment

Each bead must contain, at minimum:
- clear Task
- capture reference (path)
- acceptance criteria

If missing and you can infer from the spec, fix with:

```bash
br update <id> --description "<improved description>"
```

(Use the template in `decompose-plan/references/bead-template.md` as a guide.)

### 5) Validate coverage (spec → beads)

- Break the spec into discrete requirements.
- For each requirement, find matching bead(s) using:

```bash
bv --search "<requirement>" --robot-search --search-limit=5
```

If a requirement is not covered:
- Do NOT decompose further unless asked.
- Either:
  - create a missing bead (if it’s clearly required), or
  - report the gap for user confirmation (if ambiguous scope).

### 6) Validate orphan work (beads → spec)

For each bead:
- If it doesn’t map to a requirement, confirm it’s a valid support task.
- If it’s scope creep, flag it (and optionally `br delete` only with explicit user approval).

### 7) Validate dependency correctness

- Fix reversed epic deps if found:

```bash
# remove wrong edge
br dep remove <child> <epic>
# add correct edge
br dep add <epic> <child>
```

- Add missing deps only when confident.
- Do **not** auto-fix cycles; report them.

### 8) Update the decomposition log

Append a “Validation pass” section to the decomposition log:
- what was found
- what was fixed
- what remains

## Output

- A short summary:
  - pass/fail
  - fixes applied
  - blockers for execution
