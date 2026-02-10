---
name: caam-expert
description: >-
  Explains caam (Coding Agent Account Manager) usage, account rotation,
  caam-switch OpenClaw sync, and the automated timer. Use when the user asks
  "how does caam work", "switch accounts", "rotate tokens", "caam-switch",
  "check caam status", "add a new account to caam", or mentions account
  limits, token rotation, or OpenClaw auth sync.
---

## What is caam

caam (Coding Agent Account Manager) manages auth files for AI coding CLIs — Claude Code, Codex CLI, and Gemini CLI. It enables instant account switching when usage limits are hit on subscription plans (Claude Max, GPT Pro, Gemini Ultra).

Binary: `~/.bun/bin/caam`

## Current accounts

**Claude** (3 profiles):
| Profile | Plan |
|---------|------|
| `duncanejurman@gmail.com` | Max 20x |
| `tableclayy@gmail.com` | Max 5x |
| `willzec@gmail.com` | Max 5x |

**Codex** (2 profiles):
| Profile | Plan |
|---------|------|
| `duncanfisherhq@gmail.com` | GPT Pro |
| `tuffhajj1@gmail.com` | GPT Pro |

## Essential commands

```bash
caam list                              # List all profiles with health
caam status                            # Show active profiles
caam activate claude <profile>         # Switch to specific profile
caam activate claude --auto            # Smart rotate (health/cooldown/usage)
caam backup claude <profile-name>      # Save current auth to vault
caam paths                             # Show auth file locations
caam cooldown set claude <profile> 1h  # Mark profile as rate-limited
```

### Adding a new account

1. Log in via the tool's normal flow (e.g., `claude` then `/login`)
2. `caam backup claude <email>` — saves credentials to vault
3. Verify: `caam list claude`

## Auth file locations

| Tool | File | Key fields |
|------|------|------------|
| Claude | `~/.claude/.credentials.json` | `.claudeAiOauth.accessToken`, `.refreshToken`, `.expiresAt` (unix ms) |
| Codex | `~/.codex/auth.json` | `.tokens.access_token`, `.refresh_token`, `.account_id` |
| OpenClaw agents | `~/.openclaw/agents/*/agent/auth-profiles.json` | `.profiles["anthropic:claude-cli"]`, `.profiles["openai-codex:codex-cli"]` |

Vault: `~/.local/share/caam/vault/<tool>/<profile>/`

## caam-switch

Unified token rotation that syncs caam credentials to all OpenClaw agents. OpenClaw runs 11 agents, each with independent auth — caam alone doesn't update them.

**What it does (5 steps):**
1. `caam activate claude --auto` + `caam activate codex --auto` — smart rotate
2. Extract fresh tokens from `~/.claude/.credentials.json` and `~/.codex/auth.json`
3. Update all `~/.openclaw/agents/*/agent/auth-profiles.json` via `jq` (only `.access`, `.refresh`, `.expires`, `.accountId` — preserves `anthropic:manual`, `lastGood`, `usageStats`)
4. `openclaw gateway restart` — gateway doesn't hot-reload, needs restart
5. Verify token match + `anthropic:manual` preserved

**Files:**
| File | Purpose |
|------|---------|
| `~/.local/bin/caam-switch` | Standalone bash script |
| `~/.zshrc.local` | Same logic as zsh function (for interactive use) |

Run manually: `caam-switch` (or `source ~/.zshrc.local && caam-switch`)

## Automated rotation (systemd timer)

Runs `caam-switch` every 2 hours to distribute usage across accounts.

**Systemd units:**
- `~/.config/systemd/user/caam-switch.timer` — fires every 2h + 5min after boot
- `~/.config/systemd/user/caam-switch.service` — oneshot, runs `~/.local/bin/caam-switch`

```bash
systemctl --user status caam-switch.timer     # Check timer state
systemctl --user list-timers caam-switch.timer # See next firing
journalctl --user -u caam-switch.service      # View logs
systemctl --user restart caam-switch.service   # Force immediate run
```

## Troubleshooting

- **"Warning" on codex profiles**: Normal if profile hasn't been used yet — clears after first use
- **Gateway restart interrupts agents**: Expected; agents recover on next spawn
- **Profile shows "no matching profile"**: Current auth wasn't backed up — run `caam backup <tool> <email>`
- **Token mismatch in verification**: Check if another process overwrote credentials between steps
