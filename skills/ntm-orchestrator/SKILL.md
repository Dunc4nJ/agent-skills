---
name: ntm-orchestrator
description: Use when the user asks you to "send a message to an agent in another project", "spawn agents in a project", "check on agents", "watch progress", "see if any agent has questions", "reset agents", "send bead worker", "enter bead mode", "start bead supervisor", or mentions NTM/tmux agent orchestration across /data/projects/PROJECT.
---

# NTM Orchestrator v2

Operate Claude Code + Codex agents inside NTM/tmux sessions where **session name == project name** and repo path is **/data/projects/<session>**.

## Core Primitives (tested, reliable)

### Session Management

```bash
# Spawn a new session (2 Claude + 1 Codex default)
ntm spawn <session> --cc=2 --cod=1

# Kill entire session
ntm kill <session> --force

# Full reset (kill + respawn)
ntm kill <session> --force && ntm spawn <session> --cc=2 --cod=1
```

### Check Session State

```bash
# JSON status of all sessions
ntm --robot-status

# Get pane output (last N lines)
ntm --robot-tail=<session> --lines=N --panes=2,3,4
```

### Send Prompts

```bash
# Short prompt to specific pane
ntm send <session> --pane=N "message text"

# Long/multiline prompt from file
ntm send <session> --pane=N --file=/path/to/prompt.txt

# Broadcast to all Claude panes
ntm send <session> --cc --file=/path/to/prompt.txt

# Broadcast to all Codex panes
ntm send <session> --cod --file=/path/to/prompt.txt
```

### Reset Agent Context (without killing)

```bash
# Clear all Claude panes (resets context window)
ntm send <session> --cc --no-cass-check "/clear"

# New session all Codex panes (resets context window)
ntm send <session> --cod --no-cass-check "/new"

# Wait for reset to take effect
sleep 5
```

**`--no-cass-check` is REQUIRED** for `/clear` and `/new` — otherwise CASS duplicate detection intercepts with an interactive prompt that blocks.

### Send Palette Prompts (e.g. bead_worker)

Palette prompts are stored in `~/.config/ntm/config.toml` under `[[palette]]` entries.

```bash
# Extract a palette prompt
ntm --robot-palette | jq -r '.commands[] | select(.key=="bead_worker") | .prompt' > /tmp/prompt.txt

# Send to all agents
ntm send <session> --cc --file=/tmp/prompt.txt
ntm send <session> --cod --file=/tmp/prompt.txt
```

Available palette keys: `bead_worker`, `tableclay_bead_worker`, `fresh_review`, `fix_bug`, `git_commit`, `run_tests`, etc.

### Targeted Agent Type Reset (e.g. Codex in cooldown)

When one agent type needs to be replaced (auth issues, rate limits, cooldowns):

```bash
# 1. Find pane indices for the type
ntm --robot-status  # check which panes are codex/claude

# 2. Kill specific panes
tmux kill-pane -t <session>:.N   # for each affected pane

# 3. (Optional) Rotate account if auth/cooldown issue
caam activate codex --auto    # or: caam activate claude --auto

# 4. Add fresh agent panes
ntm add <session> --cod=1     # or --cc=1 for Claude
```

### Add More Agents to Existing Session

```bash
ntm add <session> --cc=1      # add 1 Claude pane
ntm add <session> --cod=2     # add 2 Codex panes
```

## Workflows

### New Task (fresh context + prompt)

When starting unrelated work — reset context first, then send the new task:

```bash
# 1. Reset all agent contexts
ntm send <session> --cc --no-cass-check "/clear"
ntm send <session> --cod --no-cass-check "/new"
sleep 5

# 2. Send new task
ntm send <session> --cc "Your task description here"
ntm send <session> --cod "Your task description here"
```

### Bead Worker Dispatch

Reset context and send the bead worker prompt to all agents:

```bash
ntm send <session> --cc --no-cass-check "/clear"
ntm send <session> --cod --no-cass-check "/new"
sleep 5
ntm --robot-palette | jq -r '.commands[] | select(.key=="bead_worker") | .prompt' > /tmp/bw.txt
ntm send <session> --cc --file=/tmp/bw.txt
ntm send <session> --cod --file=/tmp/bw.txt
```

### Follow-up (preserve context)

When continuing the same thread — do NOT reset:

```bash
ntm send <session> --pane=N "Your follow-up message"
```

### Monitor Progress

```bash
# Quick check — tail all agent panes
ntm --robot-tail=<session> --lines=20 --panes=2,3,4

# Check specific pane
ntm --robot-tail=<session> --lines=50 --panes=N
```

#### Structured State Detection (ft-style patterns)

Use `scripts/pane-detect.py` for reliable, structured state classification:

```bash
# Auto-fetch tail and classify all panes
python3 ~/.openclaw/skills/ntm-orchestrator/scripts/pane-detect.py <session> --panes=2,3,4

# Or pipe from stdin
ntm --robot-tail=<session> --lines=30 --panes=2,3,4 2>&1 | python3 ~/.openclaw/skills/ntm-orchestrator/scripts/pane-detect.py
```

**Output:** JSON array with per-pane state:
```json
[
  {"pane": "2", "agent_type": "claude", "state": "idle", "detections": ["idle"], "last_line": "❯"},
  {"pane": "3", "agent_type": "claude", "state": "working", "detections": ["working"], "last_line": "◐ Running bash..."},
  {"pane": "4", "agent_type": "codex", "state": "rate_limited", "detections": ["rate_limited"], "last_line": "Rate limit exceeded"}
]
```

**Detected states:** `idle`, `working`, `question`, `error`, `rate_limited`, `context_full`, `unknown`

**Patterns detected per agent type:**

| State | Claude signals | Codex signals |
|-------|---------------|---------------|
| idle | `❯` prompt | `›` prompt, `context left` |
| working | `◐`, `Running`, tool calls | `◦`, `Ran`, `Executed` |
| question | `?` at end, `Do you want to`, `(y/n)` | same |
| error | `Error:`, `permission_error`, `not logged in` | same |
| rate_limited | `rate limit`, `cooldown`, `429`, `overloaded` | same |
| context_full | `context window`, `token limit` | `context left: 0` |

### Handle Cooldown / Auth Errors

When you see auth errors or rate limits in the tail:

```bash
# 1. Kill affected panes
tmux kill-pane -t <session>:.N

# 2. Rotate account
caam activate claude --auto   # or codex
caam status                   # verify

# 3. Add fresh panes
ntm add <session> --cc=1      # or --cod=1

# 4. Re-send task
ntm send <session> --pane=<new_pane_idx> --file=/tmp/prompt.txt
```

### Full Session Reset (nuclear option)

When everything is broken — kill and start over:

```bash
caam activate claude --auto
caam activate codex --auto
ntm kill <session> --force
ntm spawn <session> --cc=2 --cod=1
sleep 15  # wait for agents to boot
ntm --robot-palette | jq -r '.commands[] | select(.key=="bead_worker") | .prompt' > /tmp/bw.txt
ntm send <session> --cc --file=/tmp/bw.txt
ntm send <session> --cod --file=/tmp/bw.txt
```

## Important Notes

### What DOESN'T work reliably
- `ntm respawn` — kills agent process but drops to bare shell, does NOT relaunch the agent
- `ntm --robot-send --msg-file` — pastes multiline text but does NOT press Enter (prompt never submitted)
- `ntm --robot-is-working` — unreliable state detection (returns UNKNOWN for idle Claude, RATE_LIMITED for idle Codex when they're fine)
- `ntm wait --until=idle` — times out even when agents are clearly idle and ready

### Agent startup time
After `ntm spawn` or `ntm add`, agents take **10-20 seconds** to fully initialize. Preferred: poll the tail for the prompt character. Fallback: `sleep 15`.

**Readiness polling (preferred over hardcoded sleep):**
```bash
# Poll until Claude prompt appears (max 30s)
for i in $(seq 1 15); do
  ntm --robot-tail=<session> --lines=5 --panes=N 2>&1 | grep -q '❯' && break
  sleep 2
done

# Poll until Codex prompt appears (max 30s)
for i in $(seq 1 15); do
  ntm --robot-tail=<session> --lines=5 --panes=N 2>&1 | grep -q '›' && break
  sleep 2
done
```

**⚠️ MCP server startup delay:** The prompt (`❯`/`›`) appears BEFORE MCP servers finish loading. If the project uses MCP tools (agent-mail, etc.), wait for them to initialize before sending work:
- **Claude:** Poll tail for `N MCPs` in status bar (e.g. `1 MCPs`)
- **Codex:** Poll tail for `Use /skills to list available skills`
- **Fallback:** `sleep 30` after prompt appears

### Pane layout
- **Pane 1:** Always the user shell (type: `unknown`) — never send resets to this
- **Panes 2+:** Agent panes (Claude and Codex)
- Use `ntm --robot-status` to confirm pane indices and types

## Bead Mode (Heartbeat-Driven Supervisor)

**Any agent** can enter bead mode. It's a heartbeat-driven pattern — you temporarily increase your heartbeat to 10m, add a supervisor checklist to HEARTBEAT.md, and each heartbeat runs one check cycle.

**Full playbook:** See `bead-mode.md` in this skill directory for the complete step-by-step instructions (enter, check cycle, exit, best practices).

**Detection script:** See `scripts/pane-detect.py` for structured pane state classification.

**Supervisor logic:** See `bead-supervisor.md` for the detailed check cycle procedure.

### Quick Reference

```
Enter:  caam status → ntm spawn → send bead_worker → create state file → patch heartbeat to 10m → write HEARTBEAT.md
Check:  read state → br list → pane-detect.py → act on states → update state → report if needed
Exit:   update state → revert heartbeat to 1h → clear HEARTBEAT.md → report summary
```

### Key Rules
- One project per agent at a time
- Use `--no-cass-check` for `/clear`, `/new`, and short utility commands
- Answer agent questions yourself before escalating
- Don't reset context unless actually needed (context_full or confused)
- Auto-stops on: all beads closed, 60min stall, all accounts exhausted
