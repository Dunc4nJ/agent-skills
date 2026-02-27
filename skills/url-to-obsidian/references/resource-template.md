# Resource Note Template

Lightweight template for repos, tools, libraries, and other reference material worth tracking but not yet synthesized into knowledge.

## Template

```markdown
---
created: YYYY-MM-DD
source: https://github.com/org/repo
type: resource
tags: [relevant, domain, tags]
status: unread
---

## What it is

2-3 sentences describing the project/repo at a high level.

## Why it's interesting

Why this caught your attention. What problem does it solve? What's novel about the approach? 2-3 sentences.

## How it works

Describe the architecture or mechanism in enough detail that a reader understands the approach without visiting the repo. Break into phases/steps if the system has a pipeline. Use bold labels for each stage. This section should answer "what's actually happening under the hood" — not just "it's fast and cheap." Skip this section only if the repo is a simple utility with no interesting internals.

## Key links

- [GitHub](https://github.com/org/repo)
- [Docs](https://docs-url) (if available)
- [Paper](https://arxiv-url) (if available)
- [Demo](https://demo-url) (if available)

## Notes

Any initial observations, questions, or things to explore later.
```

## Rules

- **Title:** Project or repo name (descriptive, not claim-based). e.g., `OpenClaw-RL.md`, `Unikraft Cloud.md`
- **Location:** `Knowledge/Agents/{subfolder}/resources/`
- **Status field:**
  - `unread` — bookmarked, not yet explored
  - `exploring` — actively looking into it
  - `captured` — insights extracted into a sibling knowledge note
- **No MOC entry** — resources don't go in the MOC. Only graduated knowledge notes do.
- **Graduation:** When you explore a resource and extract insights, write a proper claim-based knowledge note as a sibling (not inside `resources/`) and link back with `[[resources/project-name]]`
- **Images:** Only include if the repo README has a key architecture diagram worth preserving. Most resources won't need images.
- **Keep it light:** This is a bookmark with context, not an analysis. A few sentences is fine.
