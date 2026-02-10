---
name: decompose-plan
description: Decompose a written plan/spec into Beads (br issues) with correct granularity, self-contained descriptions, and a dependency graph (including epics). Use when the user says “decompose this plan”, “turn this into beads”, or “create a bead graph from this plan”.
---

# Decompose Plan (Beads)

Turn a **plan file** into a set of Beads (`br` issues) that multiple agents can execute in parallel.

## Hard rules

- **Do not spawn subagents automatically.** This skill is only the decomposition workflow.
- **Work inside the target repo** (the repo that will contain `.beads/`).
- **Every bead must be self-contained** (a dev can implement it without reading the original plan).
- **Epic dependency direction:** epics depend on children (children READY, epic BLOCKED).

## Inputs

- A path to a plan/spec file (markdown recommended).
- Target repo directory (where the code will be implemented). If unclear, stop and ask.

## Workflow

### 1) Preflight

```bash
cd <target-repo>
br where || br init
```

- Confirm `.beads/` exists.
- If the repo already has a `.beads/` workspace, keep using it.

### 2) Read and understand the plan

- Read the entire plan/spec.
- Identify:
  - phases/milestones (candidate epics)
  - work units (candidate tasks)
  - sequential blockers (dependencies)
  - parallelizable lanes

### 3) Decide granularity (judgment call)

Guideline:
- Tiny: 1 bead
- Small: 2–3 beads
- Medium: 4–8 beads
- Large: 8+ beads (multiple epics)

Too big:
- touches many unrelated files/concerns
- unclear acceptance criteria

Too small:
- “one-line change” / no verifiable outcome

### 4) Create an epic structure (optional)

Create epics for phases (only if it clarifies the graph):

```bash
br create --title "Phase 1: <name>" --type epic --priority 1 --description "<self-contained epic context>"
```

### 5) Create task beads (self-contained)

For each task bead, write a full description using the template:
- `references/bead-template.md`

Create bead:

```bash
br create \
  --title "<concise title>" \
  --type task \
  --priority <0-4> \
  --description "<full description>"
```

### 6) Add dependencies

- If B requires A:

```bash
br dep add <B> <A>
```

- If epic E contains child C (epic depends on child):

```bash
br dep add <E> <C>
```

### 7) Write a decomposition log

Write:
`.beads/decomposition-logs/<timestamp>-<plan-slug>.md`

Include:
- source plan path
- beads created (IDs)
- epics created (IDs)
- why you chose the granularity
- any existing beads reused
- the dependency tree

### 8) Quick sanity checks

```bash
br ready
bv --robot-suggest
```

- Ensure at least some child tasks are READY.
- Ensure epics are BLOCKED (waiting on children) — not the other way around.

## Priority rubric (quick)

- P0: foundations that unblock everything
- P1/P2: core feature path
- P3/P4: polish/nice-to-have

## Notes

- If a bead references an external capture file, include the **capture path** in the bead description.
