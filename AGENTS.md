# AGENTS

# Global Agent Instructions

## REQUIRED: Session Initialization

At the START of every coding session (not if asked for planning, this is when any coding is about to begin), BEFORE any other work, call:

```
macro_start_session(
  human_key="<absolute path to current project>",
  program="<include claude or codex>",
  model="<include model name>,
  task_description="<brief description of your task>"
)
```

This registers your identity, checks for conflicts, and fetches your inbox.

**IMPORTANT:** The response contains `agent.name` (e.g., "GreenCastle"). Use this name for all subsequent Agent Mail calls (`sender_name`, `agent_name` parameters).

## Workflow

1. **Start session**: `macro_start_session(...)` — ALWAYS DO THIS FIRST
2. **Get rules**: `cm context "task" --json`
3. **Get skills**: `ms suggest`
4. **Past solutions**: `cass search "topic"` (if needed)

## Agent Mail

**Reserve files** before editing:
```
file_reservation_paths(project_key, agent_name, ["src/**/*.ts"], ttl_seconds=3600, exclusive=true, reason="task-id")
```

**Send messages** to coordinate:
```
send_message(project_key, sender_name, to=["AgentName"], subject="...", body_md="...", thread_id="task-id")
```

**Check inbox** when you see "INBOX REMINDER":
```
fetch_inbox(project_key, agent_name, include_bodies=true)
```

**Release** when done:
```
release_file_reservations(project_key, agent_name)
```

### Git commit/push guard (optional)

If the Agent Mail git guard is installed in a repo, it only enforces when gated.

Use the `agent.name` you got from `macro_start_session(...)` as `AGENT_NAME`:
```
AGENT_NAME="BlueLake" WORKTREES_ENABLED=1 GIT_IDENTITY_ENABLED=1 git commit -m "..."
AGENT_NAME="BlueLake" WORKTREES_ENABLED=1 GIT_IDENTITY_ENABLED=1 git push
```

Notes:
- `AGENT_NAME` must match your Agent Mail identity (adjective+noun).
- Set `AGENT_MAIL_GUARD_MODE=warn` for advisory (non-blocking) checks.
- Emergency bypass: `AGENT_MAIL_BYPASS=1` or Git `--no-verify`.

**Common errors:**
- "from_agent not registered" → call `macro_start_session` first
- "FILE_RESERVATION_CONFLICT" → coordinate with holder or wait

## Beads Integration

Use Beads task ID everywhere:
- `thread_id` = `br-###`
- Subject = `[br-###] ...`
- Reservation `reason` = `br-###`

Typical flow (agents)
1) **Pick ready work** (Beads)
   - `br ready --json` → choose one item (highest priority, no blockers)
2) **Claim atomically in Beads**
   - `br update br-123 --claim --actor <agent-id> --json` (sets `status=in_progress` and assignee)
3) **Reserve edit surface** (Mail)
   - `file_reservation_paths(project_key, agent_name, ["src/**"], ttl_seconds=3600, exclusive=true, reason="br-123")`
4) **Announce start** (Mail)
   - `send_message(..., thread_id="br-123", subject="[br-123] Start: <short title>", ack_required=true)`
5) **Work and update**
   - Reply in-thread with progress and attach artifacts/images; keep the discussion in one thread per issue id
6) **Complete and release**
   - `br close br-123 --reason "Completed"` (Beads is status authority)
   - `release_file_reservations(project_key, agent_name, paths=["src/**"])`
   - Final Mail reply: `[br-123] Completed` with summary and links

Mapping cheat-sheet
- **Mail `thread_id`** ↔ `br-###`
- **Mail subject**: `[br-###] …`
- **File reservation `reason`**: `br-###`
- **Commit messages (optional)**: include `br-###` for traceability

Event mirroring (optional automation)
- On `br update --status blocked`, send a high-importance Mail message in thread `br-###` describing the blocker.
- On Mail "ACK overdue" for a critical decision, add a Beads label (e.g., `needs-ack`) or bump priority to surface it in `br ready`.

Pitfalls to avoid
- Don't create or manage tasks in Mail; treat Beads as the single task queue.
- Always include `br-###` in message `thread_id` to avoid ID drift across tools.

**Task intelligence** (`bv` robot commands):
- `bv --robot-priority` — ranked tasks with impact scores and confidence
- `bv --robot-plan` — parallel tracks showing what can run concurrently
- `bv --robot-insights` — PageRank, critical path, cycle detection
- `bv --robot-diff --diff-since "1 hour ago"` — what changed recently

**Rule**: Use `br` for task CRUD, use `bv` for task intelligence.

### Coordinated Workflow (Agent Mail + Beads)

1. Run `bv --robot-priority` → identify highest-impact task (e.g., `br-42`)
2. Claim task in Beads: `br update br-42 --claim --actor <agent-id> --json`
3. Reserve files: `file_reservation_paths(..., reason="br-42")`
4. Announce: `send_message(..., thread_id="br-42", subject="[br-42] Starting...")`
5. Other agents see reservation + message, pick different tasks
6. Complete, run `bv --robot-diff` to report downstream unblocks

## Frontend Validation (Beads)

For beads with frontend/UI acceptance criteria, validate changes visually before closing.

### Pre-validation: Confirm Vercel Deploy

Vercel deployment is triggered automatically when you push changes. Before validating, confirm the deployment completed:
```bash
# Check Vercel deployment status (wait for "Ready" state)
vercel list --limit 1
# Or check the Vercel dashboard URL in the deploy output
```

**Note:** After `git push`, wait for Vercel to finish building and deploying before proceeding with validation.

### Validation Workflow

1. **Open deployed URL**:
   ```bash
   agent-browser open <vercel-preview-url>
   ```

2. **Validate acceptance criteria**:
   ```bash
   agent-browser snapshot -i  # Get interactive elements
   # Interact as needed to verify functionality
   ```

3. **On success, capture screenshot**:
   ```bash
   # Create screenshots folder if needed
   mkdir -p screenshots

   # Take screenshot with bead ID in filename
   agent-browser screenshot screenshots/br-###-description.png
   ```

4. **Close browser**:
   ```bash
   agent-browser close
   ```

### Example

```bash
# Verify deploy is ready
vercel list --limit 1

# Validate br-42 (new login button)
agent-browser open https://my-app-abc123.vercel.app
agent-browser snapshot -i
agent-browser click @e5  # Click login button
agent-browser wait --text "Welcome"
agent-browser screenshot screenshots/br-42-login-button-works.png
agent-browser close

# Now safe to close the bead
br close br-42 --reason "Validated: login button functional"
```

### Rules

- **MUST** confirm Vercel deploy completed before validation
- **MUST** take screenshot if acceptance criteria pass
- Screenshots saved to `screenshots/` at project root
- Screenshot filename format: `br-<id>-<short-description>.png`
- If validation fails, do NOT close the bead — report the issue instead

## CLI Tools

| Tool | Purpose | Command |
|------|---------|---------|
| cass | Search sessions | `cass search "query"` |
| cm | Get rules | `cm context "task" --json` |
| ms | Skills | `ms search "topic"` |

## Automated (no action needed)
- **UBS** — Bug scanner on file saves
- **DCG** — Destructive command guard
- **Inbox reminder** — Shows after Bash if you have mail

## Context7

ALWAYS proactively use Context7 MCP when you need library/API documentation, code generation, setup or configuration steps — without the user having to explicitly ask. External libraries, docs, and frameworks should be guided by Context7 and always used when creating an in-depth plan.

## Concurrent file changes (normal)
You will most likely notice modifications to files that you did not make. This is completely normal as other developers are concurrently working on the same project as you. Do not stop and ask how to continue, just continue and add/commit files relevant to your current bead. If it happens to be a file that was modified by another that is fine, continue working on your current bead and do NOT STOP and ask for instructions.

<skills_system priority="1">

## Available Skills

<!-- SKILLS_TABLE_START -->
<usage>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke: `npx openskills read <skill-name>` (run in your shell)
  - For multiple: `npx openskills read skill-one,skill-two`
- The skill content will load with detailed instructions on how to complete the task
- Base directory provided in output for resolving bundled resources (references/, scripts/, assets/)

Usage notes:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already loaded in your context
- Each skill invocation is stateless
</usage>

<available_skills>

<skill>
<name>agent-browser</name>
<description>Automates browser interactions for web testing, form filling, screenshots, and data extraction. Use when the user needs to navigate websites, interact with web pages, fill forms, take screenshots, test web applications, or extract information from web pages.</description>
<location>project</location>
</skill>

<skill>
<name>aprx-iterate</name>
<description>Runs iterative APRX specification refinement until convergence. Executes APRX rounds, integrates GPT Pro suggestions into spec and README, commits changes, and tracks convergence. Use when user wants to refine a specification through multiple GPT Pro review cycles.</description>
<location>project</location>
</skill>

<skill>
<name>bd-to-br-migration</name>
<description>>-</description>
<location>project</location>
</skill>

<skill>
<name>caam-expert</name>
<description>>-</description>
<location>project</location>
</skill>

<skill>
<name>create-global-skill</name>
<description>Create and publish global skills available to all local agents. Use when asked to "create a skill", "add a new skill", "write a skill", "make a global skill", or when setting up skill folder structure, writing SKILL.md, creating symlinks, or running OpenSkills sync. Covers both skill authoring best practices and deployment to ~/.agent/skills/.</description>
<location>project</location>
</skill>

<skill>
<name>create-plan</name>
<description>Iterative planning skill that explores codebases, researches best practices via Perplexity/NIA, and creates comprehensive self-contained plans through multiple clarification rounds. Use when asked to create, design, or plan any feature, refactor, or implementation.</description>
<location>project</location>
</skill>

<skill>
<name>decompose-plan</name>
<description>Decompose a written plan/spec into Beads (br issues) with correct granularity, self-contained descriptions, and a dependency graph (including epics). Use when the user says “decompose this plan”, “turn this into beads”, or “create a bead graph from this plan”.</description>
<location>project</location>
</skill>

<skill>
<name>frontend-design</name>
<description>Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics.</description>
<location>project</location>
</skill>

<skill>
<name>image-generator</name>
<description>Use this skill when the user asks to "generate an image", "create a logo", "make a mockup", "edit a photo", "remove a background", "iterate on an image", or otherwise wants image generation/editing via Gemini image models. Provides a safe, file-based curl workflow that avoids command-line length limits and requires GEMINI_API_KEY.</description>
<location>project</location>
</skill>

<skill>
<name>markdown-url</name>
<description>Route website visits through markdown.new for clean Markdown extraction. Use when reading docs, blog posts, changelogs, GitHub issues, or any web content where you need extractable text. Prefixes URLs with https://markdown.new/ automatically.</description>
<location>project</location>
</skill>

<skill>
<name>markitdown</name>
<description>Convert office documents and rich files to Markdown using markitdown. Use when reading, processing, or extracting text from .pptx, .docx, .xlsx, .xls, .pdf, .html, .csv, .json, .xml, .epub, .zip, images (EXIF/OCR), or audio files (transcription). Triggers on "read this PowerPoint", "extract text from Word doc", "convert spreadsheet", "parse this PDF", "read this presentation", or any task involving these file types where the Read tool cannot handle the format directly.</description>
<location>project</location>
</skill>

<skill>
<name>nia-docs</name>
<description>Search library documentation and code examples via Nia (package semantic search, regex grep, and universal search). Use when you need API docs/code examples across npm, PyPI, crates, or Go modules. Requires NIA_API_KEY.</description>
<location>project</location>
</skill>

<skill>
<name>ntm-orchestrator</name>
<description>Use when the user asks you to "send a message to an agent in another project", "spawn agents in a project", "check on agents", "watch progress", "see if any agent has questions", "reset agents", "send bead worker", "enter bead mode", "start bead supervisor", or mentions NTM/tmux agent orchestration across /data/projects/PROJECT.</description>
<location>project</location>
</skill>

<skill>
<name>ntm-prompt-palette-adder</name>
<description>Add a new prompt to the NTM command palette in ~/.config/ntm/config.toml (generates a [[palette]] TOML entry). Use when the user asks to “add a prompt to ntm palette”, “add to NTM command palette”, or “create a palette prompt”.</description>
<location>project</location>
</skill>

<skill>
<name>obsidian</name>
<description>Search and manage Obsidian vault notes using qmd (Markdown search engine). Use when the user asks about "notes", "Obsidian", "search my vault", "find in knowledge base", "what do I know about", or needs to create, read, or update vault content. Provides search commands, vault navigation, and note-writing conventions.</description>
<location>project</location>
</skill>

<skill>
<name>obsidian-edit</name>
<description>Process inline {edit annotations} in Obsidian vault notes. Use when the user says "edit my notes", "process annotations", "run edit", "fix my annotations", or has left {curly brace instructions} in markdown files for batch processing.</description>
<location>project</location>
</skill>

<skill>
<name>obsidian-reflect</name>
<description>Extract key learnings from recent work and persist them to the Obsidian vault as linked learning notes. Use when the user says "reflect on", "capture learnings", "what did we learn", "extract insights", "end of session", or when wrapping up a task with significant non-obvious discoveries worth preserving.</description>
<location>project</location>
</skill>

<skill>
<name>oracle-job-runner</name>
<description>Use when the user asks to "run this through Oracle", "ask GPT 5.2 Pro", "submit a job", "bundle files for ChatGPT", "use oracle-pool", "queue oracle runs", or needs a reliable pattern to send a plan/spec/docs/question to Oracle and retrieve the result (oracle CLI, oracle-pool, aprx via pool). Covers prompts, file bundling, slugs, waiting/reattaching, and where outputs live.</description>
<location>project</location>
</skill>

<skill>
<name>perplexity-search</name>
<description>AI-powered web search and research via Perplexity (Sonar models), including ranked search results and AI-synthesized answers with citations. Use for up-to-date facts, source gathering, deep research, and reasoning. Requires PERPLEXITY_API_KEY.</description>
<location>project</location>
</skill>

<skill>
<name>shaping</name>
<description>Shape Up methodology for product and feature development. Use when collaboratively shaping a solution — iterating on problem definition (requirements) and solution options (shapes), breadboarding systems into affordances and wiring, and slicing into vertical implementation increments. Triggers include "shape this feature", "breadboard the system", "let's shape", "slice this into increments", "fit check", "define requirements", or any product/feature scoping discussion using Shape Up methodology.</description>
<location>project</location>
</skill>

<skill>
<name>stripe-best-practices</name>
<description>Best practices for building a Stripe integrations</description>
<location>project</location>
</skill>

<skill>
<name>twitter-bird-workflows</name>
<description>Read/search X (Twitter) and draft posts/replies using the bird CLI with safety guardrails. Use when you need to check timelines, read threads, search X, summarize findings, or prepare a tweet/reply draft. NEVER post without explicit user approval.</description>
<location>project</location>
</skill>

<skill>
<name>upgrade-stripe</name>
<description>Guide for upgrading Stripe API versions and SDKs</description>
<location>project</location>
</skill>

<skill>
<name>url-to-obsidian</name>
<description>Capture knowledge from any URL or PDF into the Obsidian vault as a linked note. Use when the user says "save this URL", "capture this to vault", "add to obsidian", "save this tweet", "capture this article", "capture this PDF", or provides a URL/file path and asks to save, store, or capture it. Routes tweets (x.com, twitter.com) via bird CLI, PDFs via pdftotext, and any other web page via playbooks.</description>
<location>project</location>
</skill>

<skill>
<name>validate-beads</name>
<description>Decompose and validate an existing set of Beads against a plan or spec, including self-containment, coverage, and dependency correctness. Use after decompose-plan and before implementation.</description>
<location>project</location>
</skill>

<skill>
<name>vercel-composition-patterns</name>
<description>React composition patterns that scale. Use when refactoring components with</description>
<location>project</location>
</skill>

<skill>
<name>vercel-react-best-practices</name>
<description>React and Next.js performance optimization guidelines from Vercel Engineering. This skill should be used when writing, reviewing, or refactoring React/Next.js code to ensure optimal performance patterns. Triggers on tasks involving React components, Next.js pages, data fetching, bundle optimization, or performance improvements.</description>
<location>project</location>
</skill>

<skill>
<name>vercel-react-native-skills</name>
<description>React Native and Expo best practices for building performant mobile apps. Use</description>
<location>project</location>
</skill>

<skill>
<name>web-design-guidelines</name>
<description>Review UI code for Web Interface Guidelines compliance. Use when asked to "review my UI", "check accessibility", "audit design", "review UX", or "check my site against best practices".</description>
<location>project</location>
</skill>

<skill>
<name>x-research</name>
<description>></description>
<location>project</location>
</skill>

<skill>
<name>x-to-task-inbox</name>
<description>Capture an X (Twitter) post/thread into the Tooling task inbox (not Obsidian) and draft a first-iteration implementation plan. Use when the user says “capture this tweet”, “save this X post”, “add this to the task inbox”, or provides an x.com/twitter.com link for later implementation.</description>
<location>project</location>
</skill>

<skill>
<name>zombie-killer</name>
<description>Detect and kill zombie processes on the VPS. Use when the user mentions zombies, defunct processes, slow VPS, high load average, stale agent sessions, or process cleanup. Triggers on "check zombies", "kill zombies", "why is my server slow", "clean up processes", "defunct processes".</description>
<location>project</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>
