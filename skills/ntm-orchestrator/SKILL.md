---
name: ntm-orchestrator
description: Use when the user asks you to "send a message to an agent in another project", "spawn agents in a project", "check on agents", "watch progress", "see if any agent has questions", or mentions NTM/tmux agent orchestration across /data/projects/PROJECT. Provides a deterministic JSON-only workflow using NTM robot APIs plus bundled scripts.
---

# NTM Orchestrator (JSON-first)

Operate Claude Code + Codex agents inside NTM/tmux sessions where **session name == project name** and repo path is **/data/projects/<session>**.

## Non-negotiables

- Prefer **pane-targeted sends** for follow-ups.
- Use **JSON outputs only** (no human-formatted summaries).
- Do **not** rely on `ntm activity` for state; it may return `UNKNOWN`.
- Use `ntm --robot-status` + `ntm --robot-tail` as the source of truth.

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

### 3) Send tasks

Use bundled script (recommended):

- `python3 scripts/ntm_send.py --session <project> --to cod_1 --message "..."`
- `python3 scripts/ntm_send.py --session <project> --to cc_2 --message "..."`

This script:
- ensures the session exists (auto-spawn if missing)
- resolves `cc_*/cod_*` aliases to a tmux pane index
- performs `ntm send <session> --pane=<idx> ...`
- prints a single JSON object with what was sent and where

### 4) Watch progress every 2 minutes

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

### 5) Auto-respond to questions

When watcher output indicates `WAITING_QUESTION`:

- Read the `question_excerpt` + `context_excerpt`
- If confident, respond via `ntm send ... --pane=<idx>`
- If unsure, ask the human (Droid Overlord) with:
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

## Reference

- `references/json-schema.md` — JSON shapes emitted by scripts and expected fields
