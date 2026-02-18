# Bead Mode — Any-Agent Playbook

Any OpenClaw agent can enter "bead mode" to supervise NTM coding agents working through beads on a project. This is a heartbeat-driven supervisor pattern — no separate cron agent needed.

## Prerequisites

- The project must exist at `/data/projects/<project>`
- The project must have beads (`br list` works)
- NTM must be available (`ntm --version`)
- caam must be available for auth rotation (`caam status`)

## Enter Bead Mode

When a user says "enter bead mode for <project>", follow these steps:

### Step 1: Verify auth

```bash
caam status
# If needed:
caam activate claude --auto
caam activate codex --auto
```

### Step 2: Spawn the NTM session (if not running)

```bash
ntm --robot-status 2>&1 | jq -r '.sessions[]?.name' | grep -q "^<project>$"
# If not found:
ntm spawn <project> --cc=2 --cod=1
```

Wait for agents to boot (verify they're not bare shells):
```bash
for i in $(seq 1 15); do
  output=$(ntm --robot-tail=<project> --lines=5 --panes=2 2>&1)
  echo "$output" | grep -q '❯\|›' && break
  # If pane shows just a shell prompt ($ or %) after 30s, the agent didn't launch
  sleep 2
done

# Verify agents are actually running (not bare zsh/bash)
python3 ~/.openclaw/skills/ntm-orchestrator/scripts/pane-detect.py <project> --panes=2,3,4
# If any pane shows "unknown" with a bare shell prompt, kill and re-add:
# tmux kill-pane -t <project>:.N && ntm add <project> --cc=1 (or --cod=1)
```

**IMPORTANT: Wait for MCP servers to load before sending prompts!**

The `❯`/`›` prompt appears BEFORE MCP servers (agent-mail, etc.) finish initializing. If you send the bead_worker prompt too early, the agent will try MCP calls that timeout.

```bash
# After prompt appears, wait for MCP servers to load:
# - Claude: look for "X MCPs" in the status bar
# - Codex: look for "Use /skills to list available skills" or MCP ready messages
# Safe default: wait 30s after prompt appears before sending work
sleep 30
```

### Step 3: Send bead worker prompt

```bash
ntm --robot-palette | jq -r '.commands[] | select(.key=="bead_worker") | .prompt' > /tmp/bw-<project>.txt
ntm send <project> --cc --file=/tmp/bw-<project>.txt
ntm send <project> --cod --file=/tmp/bw-<project>.txt
```

### Step 4: Create state file

```bash
cd /data/projects/<project> && br list --json --all 2>&1
```

Write initial state to `/tmp/bead-supervisor-<project>.json`:
```json
{
  "session": "<project>",
  "project_path": "/data/projects/<project>",
  "started_at": "<ISO timestamp>",
  "last_check": "<ISO timestamp>",
  "checks": 0,
  "beads": { "open": 0, "in_progress": 0, "closed": 0, "total": 0 },
  "prev_beads": null,
  "beads_unchanged_count": 0,
  "stall_threshold": 6,
  "rotations": [],
  "exhausted_types": [],
  "status": "running",
  "stop_reason": null
}
```

### Step 5: Set heartbeat to 10m

Use the OpenClaw gateway config patch to set YOUR agent's heartbeat interval:

```
gateway config.patch → agents.list[<your_agent_index>].heartbeat.every = "10m"
```

This triggers a restart. Your next heartbeat fires in ~10 minutes.

### Step 6: Write HEARTBEAT.md

Add the supervisor checklist to your workspace's `HEARTBEAT.md`:

```markdown
# HEARTBEAT.md

## Bead Supervisor: <project>

Run the bead supervisor check cycle. Follow `~/.openclaw/skills/ntm-orchestrator/bead-supervisor.md` for the full procedure.

State file: `/tmp/bead-supervisor-<project>.json`
Session: `<project>`
Palette key: `bead_worker`

### Quick reference:
1. Read state file — if stopped, do nothing
2. Check bead progress: `cd /data/projects/<project> && br list --json --all`
3. Detect pane states: `python3 ~/.openclaw/skills/ntm-orchestrator/scripts/pane-detect.py <project> --panes=2,3,4`
4. Act: re-send work to idle panes, answer questions, rotate auth on errors
5. Update state file
6. Report only on stops/escalations
```

### Step 7: Confirm to user

Tell the user bead mode is active. Include:
- Session name and pane count
- Current bead counts (open/in_progress/closed)
- Heartbeat interval (10m)
- How to stop ("say 'stop bead mode' or 'exit bead mode'")

---

## Check Cycle (runs every heartbeat)

Each heartbeat, when HEARTBEAT.md contains the bead supervisor section:

1. **Read state file** → if `status: "stopped"`, skip (tell user if they haven't been told)
2. **Check beads** → `cd /data/projects/<project> && br list --json --all`
3. **Compare to last check** → increment `beads_unchanged_count` if no change, reset if changed
4. **Check stop conditions:**
   - All beads closed → stop, report success 🎉
   - `beads_unchanged_count >= stall_threshold` (6 checks = ~60min no progress) → stop, report stall ⚠️
5. **Detect pane states** → `python3 ~/.openclaw/skills/ntm-orchestrator/scripts/pane-detect.py <project>`
6. **Act on states:**

| Pane State | Action |
|-----------|--------|
| **idle** | Re-send bead worker: `ntm send <project> --pane=N --file=/tmp/bw-<project>.txt` |
| **working** | Leave alone |
| **question** | Read tail, answer if confident, else escalate to user |
| **error** | Kill pane → `caam activate <type> --auto` → `ntm add` → re-send work |
| **rate_limited** | Same as error (kill → rotate → add → send) |
| **context_full** | Reset context: `ntm send <project> --pane=N --no-cass-check "/clear"` (or `/new` for Codex), then re-send work |
| **unknown** | Tail more lines, try to classify manually |

7. **Update state file**
8. **Report only when needed** (stops, escalations, account exhaustion)

---

## Exit Bead Mode

When the user says "stop/exit bead mode" OR the supervisor auto-stops:

### Step 1: Update state file
Set `status: "stopped"` and `stop_reason` in the state file.

### Step 2: Revert heartbeat
Patch your agent's heartbeat back to the default:

```
gateway config.patch → agents.list[<your_agent_index>].heartbeat.every = "1h"
```

### Step 3: Clear HEARTBEAT.md
Remove the bead supervisor section from your `HEARTBEAT.md`. Replace with:
```markdown
# HEARTBEAT.md
# Keep this file empty (or with only comments) to skip heartbeat API calls.
```

### Step 4: (Optional) Kill NTM session
Only if the user wants — agents might still be finishing work:
```bash
ntm kill <project> --force
```

### Step 5: Report final summary
Tell the user:
- Total beads: open/in_progress/closed
- Duration (started_at → now)
- Auth rotations performed
- Stop reason

---

## Best Practices

1. **Don't reset context unless needed.** An agent that just finished a bead and is idle doesn't need `/clear` — just re-send the bead worker prompt. Only reset if context is full or the agent is confused.

2. **Answer questions yourself.** You have access to the project files. Read the code, check the beads, look at git history. Only escalate questions you genuinely can't answer.

3. **One project at a time per agent.** Don't enter bead mode for two projects simultaneously — the heartbeat can only drive one supervisor loop. Use different agents for different projects.

4. **Watch for the slash-command trap.** If a pane shows "Esc to cancel" or a slash-command menu, the agent typed `/` and got stuck. Send `Escape` via tmux: `tmux send-keys -t <project>:.N Escape` then re-send the prompt.

5. **Log rotations.** Every time you rotate auth via caam, log it in the state file. This helps debug if the same account keeps failing.

6. **Stall detection is conservative.** 6 checks × 10 min = 60 min with zero bead progress before auto-stop. This is intentional — some beads take a while. Adjust `stall_threshold` in the state file if needed.

7. **Use `--no-cass-check`** for ALL short utility commands (`/clear`, `/new`, single-word messages). CASS intercepts them otherwise.
