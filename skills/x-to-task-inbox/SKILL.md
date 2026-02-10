---
name: x-to-task-inbox
description: Capture an X (Twitter) post/thread into the Tooling task inbox (not Obsidian) and draft a first-iteration implementation plan. Use when the user says “capture this tweet”, “save this X post”, “add this to the task inbox”, or provides an x.com/twitter.com link for later implementation.
---

# X → Tooling Task Inbox

Capture an X post (preferably the full thread) into the **Tooling monorepo task system** and produce a **first-iteration plan**.

## Hard rules
- **Do NOT create beads.** Only capture + plan.
- **Do NOT spawn subagents automatically.**
- Write only into:
  - `/data/projects/tooling/_task-system/inbox/`
  - `/data/projects/tooling/_task-system/tasks/`

## Inputs
- X URL (x.com or twitter.com)
- Optional: a short note from the user about what they want to do with it

## Workflow

### 1) Fetch the post/thread
Prefer the `bird` CLI (best fidelity for threads):

```bash
bird thread <url>
```

Fallbacks:
- `bird read <url>` if thread fails
- If bird fails entirely, capture just the URL + a note and mark as `NEEDS_MANUAL_CAPTURE`.

### 2) Create capture file (inbox)
Write a new markdown file:

- Path: `/data/projects/tooling/_task-system/inbox/YYYY-MM-DD--<slug>.md`

Include:
- Title line
- Captured at timestamp
- Source URL
- Full captured content (thread)
- Any user note

### 3) Create companion plan file (tasks)
Write:
- Path: `/data/projects/tooling/_task-system/tasks/YYYY-MM-DD--<slug>.md`

Include:
- Summary (1–5 bullets)
- “What implementing this likely means” (first-iteration plan)
- Suggested target location:
  - default: `/data/projects/tooling/<slug>/`
- Risks / unknowns
- Questions for Overlord (only if truly blocking)

### 4) Stop
Do not decompose into beads unless explicitly asked.

## Utilities
A helper script exists at `scripts/new_slug.py` to generate safe slugs if needed.
