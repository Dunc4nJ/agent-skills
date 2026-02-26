# Auto-Engage: Autonomous Engagement Runner

This file is the **cron-mode prompt** for the social-media-engagement skill. When triggered by a cron job, the agent follows this protocol autonomously without human interaction.

## Input Parameters

The cron job message must specify:
- **brand** — which brand to engage as (e.g. `tableclay`, `preppack`)
- **platform** — which platform (`instagram` or `facebook`; `tiktok` when auth is ready)

Example cron message:
> Run autonomous engagement: brand=tableclay, platform=instagram

## Execution Protocol

### 1. Random Jitter Delay
Before doing anything, wait a random delay to avoid predictable timing:

```bash
# Generate random delay between 0-90 minutes in seconds
JITTER=$((RANDOM % 5400))
echo "Jitter delay: $((JITTER / 60)) minutes"
sleep $JITTER
echo "Jitter complete, starting session"
```

Run this shell command and **wait for it to complete** (it will block). Do NOT schedule wake events or try to resume later — just let `sleep` finish, then proceed to pre-flight checks immediately in the same session. The cron timeout is set high enough to accommodate the full jitter + session time.

### 2. Pre-Flight Checks

a) **Read the profile manifest** at `references/profile-manifest.yaml`
b) **Verify auth_status is `active`** for the brand+platform combo. If not → log skip reason and exit.
c) **Check Chrome is running:**
   ```bash
   systemctl is-active chrome-{brand}
   ```
   If not active → log error and exit. Do NOT try to start it.
d) **Check lock file** — if another session is running for this brand:
   ```bash
   /data/chrome-profiles/lock.sh check {brand}
   ```
   If locked → log skip and exit (another session is in progress).
e) **Acquire lock:**
   ```bash
   /data/chrome-profiles/lock.sh acquire {brand} {platform}
   ```

### 3. Load Brand Context
Follow Step 2 from the main SKILL.md — read vault brand files for audience, voice, etc.

### 4. Connect and Run
```bash
agent-browser connect {cdp_port}
```

**Facebook only:** Before navigating to Reels, follow the **Page Switching** section in `references/facebook-workflow.md`. Read `page_name` from the profile manifest and switch to that Page identity. Verify the switch before engaging. If switch fails → log error and exit.

Then follow the platform-specific workflow from `references/{platform}-workflow.md` exactly as written in SKILL.md Steps 3-4.

**Autonomous decisions (no human to ask):**
- If CAPTCHA appears → screenshot, log it, release lock, exit. Do NOT attempt to solve.
- If rate-limit warning appears → screenshot, log it, release lock, exit.
- If not logged in → log it, release lock, exit. Do NOT attempt login.
- If any unexpected error → screenshot, log it, release lock, exit.
- Comment text → generate autonomously using `references/comment-guide.md` + brand voice

### 5. Session Limits (Autonomous Mode)

Use the **same randomized ranges** as manual sessions. Pick a random target within each range at session start:

|  | Instagram | Facebook |
|---|-----------|----------|
| **Follows** | 7-12 | 5-8 |
| **Likes/Reactions** | 6-10 | 8-12 |
| **Comments** | 3-5 | 2-4 |
| **Saves** | 0-2 | — |

### 6. Post-Session

a) **Log to `engagement-log.csv`** per SKILL.md rules (one row per action)
b) **Append to vault `learnings-log.md`** if notable patterns
c) **Release lock:**
   ```bash
   /data/chrome-profiles/lock.sh release {brand}
   ```
d) **Disconnect browser:**
   ```bash
   agent-browser close
   ```
e) **Report summary** — the cron delivery will announce this to the originating channel

### 7. Error Summary Format

If the session fails at any point, report:
```
❌ Auto-engagement failed
Brand: {brand} | Platform: {platform}
Stage: {preflight/connect/engage/logging}
Reason: {what happened}
Action needed: {none/manual re-auth/check Chrome service/etc}
```

## Safety Rails

- **Never exceed conservative limits** — autonomous mode has no human override
- **Never attempt login or credential entry**
- **Never attempt CAPTCHA solving**
- **Always release lock on exit** (including error paths)
- **Minimum 4-hour gap (IG) / 6-hour gap (FB/TK)** between sessions on same brand+platform — check log timestamps
- **Follow the interval tables** in each platform workflow — randomize every delay within the stated ranges
