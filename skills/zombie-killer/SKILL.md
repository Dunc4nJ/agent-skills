---
name: zombie-killer
description: Detect and kill zombie processes on the VPS. Use when the user mentions zombies, defunct processes, slow VPS, high load average, stale agent sessions, or process cleanup. Triggers on "check zombies", "kill zombies", "why is my server slow", "clean up processes", "defunct processes".
allowed-tools: Bash(zombie-killer:*)
---

# Zombie Process Killer

Detects zombie (defunct) processes, identifies their parent processes, kills stale parents to reap them, and optionally installs a cron job for ongoing monitoring.

## Quick Reference

```bash
# Scan for zombies (default)
~/.agents/skills/zombie-killer/scripts/zombie-killer.sh scan

# Kill parent processes holding zombies
~/.agents/skills/zombie-killer/scripts/zombie-killer.sh kill

# Install cron monitoring (every 30 min)
~/.agents/skills/zombie-killer/scripts/zombie-killer.sh install-cron

# Remove cron monitoring
~/.agents/skills/zombie-killer/scripts/zombie-killer.sh uninstall-cron

# Check config, cron status, recent alerts
~/.agents/skills/zombie-killer/scripts/zombie-killer.sh status
```

## Commands

| Command | What it does |
|---------|-------------|
| `scan` | Lists all zombies, groups by parent PID, shows parent command |
| `kill` | Sends SIGTERM (then SIGKILL) to parent processes holding zombies. Skips init and own process tree. |
| `install-cron` | Adds a cron entry that checks every 30 minutes and logs alerts to `~/.zombie-alerts.log` when count exceeds threshold |
| `uninstall-cron` | Removes the cron entry |
| `status` | Shows threshold, cron state, current zombie count, and recent alerts |

## Configuration

- **Threshold**: Set `ZOMBIE_THRESHOLD=N` (default: 5) to control when alerts fire
- **Alert log**: Written to `~/.zombie-alerts.log`

## How It Works

Zombie processes are children that have exited but whose parent hasn't called `wait()` to collect the exit status. They consume no CPU/memory but occupy PID table entries. The fix is to kill the parent process — `init` then adopts and reaps the orphaned zombies.

Common causes on this VPS:
- **Codex CLI** doesn't properly reap bash subprocesses during long sessions
- **Stale agent sessions** (Claude/Codex) running for days accumulate zombies

## Workflow

1. Run `scan` to see current state
2. Run `kill` to clean up (safe — skips init and own process tree)
3. Run `install-cron` for ongoing monitoring
4. Check `status` or `~/.zombie-alerts.log` periodically
