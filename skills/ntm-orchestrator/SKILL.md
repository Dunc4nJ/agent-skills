---
name: ntm-orchestrator
description: Use when the user asks you to "send a message to an agent in another project", "spawn agents in a project", "check on agents", "watch progress", "see if any agent has questions", or mentions NTM/tmux agent orchestration across /data/projects/PROJECT. Provides a deterministic JSON-only workflow using NTM robot APIs plus bundled scripts.
---

# NTM Orchestrator (JSON-first)

Operate Claude Code + Codex agents inside NTM/tmux sessions where **session name == project name** and repo path is **/data/projects/<session>**.

## Quick recipes (copy/paste)

- Send a *new* task to all Claude panes (reset context first):
  - `python3 scripts/ntm_send.py --session <project> --new-task --to cc_all --message "..." `
- Send a follow-up to a specific pane (preserve context):
  - `python3 scripts/ntm_send.py --session <project> --to cc_1 --message "..." `
- Watch until an agent asks a question (JSONL stream; exits 2 on question):
  - `python3 scripts/ntm_watch.py --session <project> --interval 120 --lines 120`

## Non-negotiables

- Prefer **pane-targeted sends** for follow-ups.
- Use **JSON outputs only** (no human-formatted summaries).
- Do **not** rely on `ntm activity` for state; it may return `UNKNOWN`.
- Use `ntm --robot-status` + `ntm --robot-tail` as the source of truth.
- **Never send resets to the user/zsh pane**. Avoid `--all` for resets (it includes the user pane).
- For a **new task** (fresh work distribution), run the **reset workflow** below before sending instructions.

Definition: “new task” = the instruction is unrelated to the agent’s current thread; we prefer a clean context window.
Definition: “follow-up” = continuing the same thread; do NOT reset or you’ll lose useful context.

## Canonical workflow

### 1) Ensure session exists (auto-spawn)

If a session does not exist, spawn it automatically:

- Default spawn: `--cc=2 --cod=1`
- Session name equals project name (e.g. `polytrader`)

### 2) Resolve agent targets

Use aliases for reasoning; send by pane.

Alias mapping (recomputed on demand):
- `cc_1..cc_N` are Claude panes in ascending `pane_idx`
- `cod_1..cod_N` are Codex panes in ascending `pane_idx`

### 3) Reset panes (for new tasks)

When starting a **new task** (unrelated to the agent’s prior conversation), reset agent panes first so they don’t carry over stale context.

**Preferred**: use the bundled sender with `--new-task`:

- `python3 scripts/ntm_send.py --session <project> --new-task --to cod_1 --message "..."`
- `python3 scripts/ntm_send.py --session <project> --new-task --to cc_2 --message "..."`
- `python3 scripts/ntm_send.py --session <project> --new-task --to cc_all --message "..."`
- `python3 scripts/ntm_send.py --session <project> --new-task --to cod_all --message "..."`
- `python3 scripts/ntm_send.py --session <project> --new-task --to agents_all --message "..."`

If you are answering a question from the agent or continuing a long-running thread, omit `--new-task`.

Purpose: reset the agent’s context window so it can focus on the new task without being biased/distracted by prior chat.

Broadcast targets:
- `cc_all` = all Claude panes in the session
- `cod_all` = all Codex panes in the session
- `agents_all` = all agent panes (Claude + Codex). Never includes the user shell pane.

Under the hood, `--new-task` does:
1) `ntm interrupt <session>` (agents only)
2) Claude panes: `/clear`
3) Codex panes: `/new`

**Important:** do not use `--all` for resets; it includes the user shell pane.

### 4) Send tasks

Use bundled script (recommended):

- `python3 scripts/ntm_send.py --session <project> --to cod_1 --message "..."`
- `python3 scripts/ntm_send.py --session <project> --to cc_2 --message "..."`

This script:
- ensures the session exists (auto-spawn if missing)
- resolves `cc_*/cod_*` aliases to a tmux pane index
- performs `ntm send <session> --pane=<idx> ...`
- prints a single JSON object with what was sent and where

#### `ntm_send.py` flags (reference)

- `--session <name>`: NTM/tmux session name (project name)
- `--to <target>`:
  - Single target: `cc_1`, `cod_1`, `pane:<idx>`
  - Broadcast: `cc_all`, `cod_all`, `agents_all`
- `--message "<text>"`: the message to send
- `--new-task`: interrupt agents and reset context (Claude: `/clear`, Codex: `/new`) before sending message
- `--cc <n>` / `--cod <n>`: only used if the session must be auto-spawned (default 2/1)

### 5) Watch progress every 2 minutes

Run the watcher script:

- `python3 scripts/ntm_watch.py --session <project> --interval 120 --lines 120`

Watcher behavior:
- emits **JSONL** (one JSON object per tick)
- captures per-pane tails and computes `changed` by hashing tail text
- classifies each pane into:
  - `RUNNING`
  - `IDLE`
  - `WAITING_QUESTION`
  - `WAITING_USER_INSTRUCTION`
  - `ERROR`
  - `UNKNOWN`

#### `ntm_watch.py` flags (reference)

- `--session <name>`: NTM/tmux session name (project name)
- `--interval <sec>`: polling interval (default 120)
- `--lines <n>`: tail lines captured per pane (default 120)
- `--max-ticks <n>`: stop after N ticks (0 = forever)
- `--stop-on-question` / `--stop-on-error`: stop early when detected (note: script currently defaults these to True)

### 6) Auto-respond to questions (policy)

When watcher output indicates `WAITING_QUESTION`:

- Read the `question_excerpt` + `context_excerpt`
- If you can answer with **confidence >= 0.8**, respond immediately via `ntm send ... --pane=<idx>`
- If confidence < 0.8, ask the human (Droid Overlord) with:
  - session + alias/pane
  - question excerpt + minimal context
  - your recommended reply + what you need clarified

## Robot primitives (direct)

- `ntm --robot-status`
- `ntm --robot-tail=<session> --lines=<N> --panes=<comma list of pane_idx>`
- `ntm send <session> --pane=<pane_idx> "message"`
- `ntm spawn <session> --cc=2 --cod=1`
- `ntm add <session> --cc=N` / `--cod=N`
- `ntm interrupt <session>`

## Bundled scripts

- `scripts/ntm_send.py` — ensure session + resolve target + send (JSON)
- `scripts/ntm_watch.py` — poll tails + classify + JSONL ticks

## How the scripts tie together

Dispatch with `ntm_send.py` → observe/triage via `ntm_watch.py` → respond with `ntm_send.py` (follow-up, usually without `--new-task`).

## Reference

- `references/json-schema.md` — JSON shapes emitted by scripts and expected fields
