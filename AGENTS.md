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
2) **Reserve edit surface** (Mail)
   - `file_reservation_paths(project_key, agent_name, ["src/**"], ttl_seconds=3600, exclusive=true, reason="br-123")`
3) **Announce start** (Mail)
   - `send_message(..., thread_id="br-123", subject="[br-123] Start: <short title>", ack_required=true)`
4) **Work and update**
   - Reply in-thread with progress and attach artifacts/images; keep the discussion in one thread per issue id
5) **Complete and release**
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
2. Reserve files: `file_reservation_paths(..., reason="br-42")`
3. Announce: `send_message(..., thread_id="br-42", subject="[br-42] Starting...")`
4. Other agents see reservation + message, pick different tasks
5. Complete, run `bv --robot-diff` to report downstream unblocks

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
<name>stripe-best-practices</name>
<description>Best practices for building a Stripe integrations</description>
<location>global</location>
</skill>

<skill>
<name>vercel-composition-patterns</name>
<description>React composition patterns that scale. Use when refactoring components with</description>
<location>global</location>
</skill>

<skill>
<name>upgrade-stripe</name>
<description>Guide for upgrading Stripe API versions and SDKs</description>
<location>global</location>
</skill>

<skill>
<name>obsidian-edit</name>
<description>Process inline {edit annotations} in Obsidian vault notes. Use when the user says "edit my notes", "process annotations", "run edit", "fix my annotations", or has left {curly brace instructions} in markdown files for batch processing.</description>
<location>global</location>
</skill>

<skill>
<name>ntm-prompt-palette-adder</name>
<description>Add a new prompt to the ntm command palette with deep thinking best practices</description>
<location>global</location>
</skill>

<skill>
<name>agent-browser</name>
<description>Automates browser interactions for web testing, form filling, screenshots, and data extraction. Use when the user needs to navigate websites, interact with web pages, fill forms, take screenshots, test web applications, or extract information from web pages.</description>
<location>global</location>
</skill>

<skill>
<name>twitter-bird-workflows</name>
<description>Read/search X (Twitter) and draft posts/replies using the bird CLI with safety guardrails. Use when you need to check timelines, read threads, search X, summarize findings, or prepare a tweet/reply draft. NEVER post without explicit user approval.</description>
<location>global</location>
</skill>

<skill>
<name>obsidian</name>
<description>Search and manage Obsidian vault notes using qmd (Markdown search engine). Use when the user asks about "notes", "Obsidian", "search my vault", "find in knowledge base", "what do I know about", or needs to create, read, or update vault content. Provides search commands, vault navigation, and note-writing conventions.</description>
<location>global</location>
</skill>

<skill>
<name>vercel-react-best-practices</name>
<description>React and Next.js performance optimization guidelines from Vercel Engineering. This skill should be used when writing, reviewing, or refactoring React/Next.js code to ensure optimal performance patterns. Triggers on tasks involving React components, Next.js pages, data fetching, bundle optimization, or performance improvements.</description>
<location>global</location>
</skill>

<skill>
<name>create-global-skill</name>
<description>Create and publish global skills available to all local agents. Use when asked to "create a skill", "add a new skill", "write a skill", "make a global skill", or when setting up skill folder structure, writing SKILL.md, creating symlinks, or running OpenSkills sync. Covers both skill authoring best practices and deployment to ~/.agent/skills/.</description>
<location>global</location>
</skill>

<skill>
<name>nia-docs</name>
<description>Search library documentation and code examples via Nia (package semantic search, regex grep, and universal search). Use when you need API docs/code examples across npm, PyPI, crates, or Go modules. Requires NIA_API_KEY.</description>
<location>global</location>
</skill>

<skill>
<name>bd-to-br-migration</name>
<description>>-</description>
<location>global</location>
</skill>

<skill>
<name>zombie-killer</name>
<description>Detect and kill zombie processes on the VPS. Use when the user mentions zombies, defunct processes, slow VPS, high load average, stale agent sessions, or process cleanup. Triggers on "check zombies", "kill zombies", "why is my server slow", "clean up processes", "defunct processes".</description>
<location>global</location>
</skill>

<skill>
<name>perplexity-search</name>
<description>AI-powered web search and research via Perplexity (Sonar models), including ranked search results and AI-synthesized answers with citations. Use for up-to-date facts, source gathering, deep research, and reasoning. Requires PERPLEXITY_API_KEY.</description>
<location>global</location>
</skill>

<skill>
<name>vercel-react-native-skills</name>
<description>React Native and Expo best practices for building performant mobile apps. Use</description>
<location>global</location>
</skill>

<skill>
<name>aprx-iterate</name>
<description>Runs iterative APRX specification refinement until convergence. Executes APRX rounds, integrates GPT Pro suggestions into spec and README, commits changes, and tracks convergence. Use when user wants to refine a specification through multiple GPT Pro review cycles.</description>
<location>global</location>
</skill>

<skill>
<name>frontend-design</name>
<description>Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics.</description>
<location>global</location>
</skill>

<skill>
<name>obsidian-reflect</name>
<description>Extract key learnings from recent work and persist them to the Obsidian vault as linked learning notes. Use when the user says "reflect on", "capture learnings", "what did we learn", "extract insights", "end of session", or when wrapping up a task with significant non-obvious discoveries worth preserving.</description>
<location>global</location>
</skill>

<skill>
<name>web-design-guidelines</name>
<description>Review UI code for Web Interface Guidelines compliance. Use when asked to "review my UI", "check accessibility", "audit design", "review UX", or "check my site against best practices".</description>
<location>global</location>
</skill>

<skill>
<name>create-plan</name>
<description>Iterative planning skill that explores codebases, researches best practices via Perplexity/NIA, and creates comprehensive self-contained plans through multiple clarification rounds. Use when asked to create, design, or plan any feature, refactor, or implementation.</description>
<location>global</location>
</skill>

<skill>
<name>bird</name>
<description>X/Twitter CLI for reading, searching, posting, and engagement. Use when user asks about Twitter, tweets, timelines, posting to X, or social media engagement.</description>
<location>project</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>
