---
name: social-media-engagement
description: "Automated social media engagement workflow across Instagram, Facebook, and TikTok. Finds relevant accounts, follows/likes them, reacts to posts, drafts natural comments, and occasionally saves/bookmarks standout content -- all via browser automation. Supports any brand with swappable brand context files. Instagram: Explore-based discovery, follows, likes, comments, saves. Facebook: Reels-based discovery, Page follows, reactions, comments. TikTok: FYP-based discovery, follows, likes, comments, saves. Use when user says 'run engagement', 'Instagram engagement', 'Facebook engagement', 'TikTok engagement', 'social media engagement', 'daily engagement run', 'run IG session', 'run FB session', 'run TikTok session', 'run TK session', 'run engagement on all', 'all platforms', or 'engagement for [brand name]'. Runs via browser automation. Does NOT post original content -- only engages with others' content."
---

# Social Media Engagement

## Overview

Run engagement sessions on Instagram, Facebook, and/or TikTok. The goal is organic community growth by genuinely engaging with accounts in the brand's niche. Every action should feel like a real person — a small brand owner — naturally participating in a community they care about.

Brand-agnostic: brand context is loaded from vault brand files or swappable reference files.

**Supported platforms:** Instagram, Facebook (Business Page), TikTok
**Session time:** ~8-25 minutes per platform (TikTok runs longer due to watch-time requirements)
**Frequency:** Up to 2 sessions per platform per day (morning + evening)

## Step 1: Platform Selection

| User says | Action |
|-----------|--------|
| "Instagram", "IG", "Insta" | Run Instagram workflow |
| "Facebook", "FB" | Run Facebook workflow |
| "TikTok", "TK" | Run TikTok workflow |
| "run engagement" (no platform) | Ask the user which platform |
| "both", "IG and FB", etc. | Run sequentially with **15-minute gap** |
| "all", "all platforms" | Instagram → Facebook → TikTok, each with **15-minute gap** |

**Never run multiple platforms simultaneously.** Sequential with gaps only.

## Step 2: Load Brand Context

1. **Check vault first:** Read `Projects/Ecommerce/Business/{Brand}/Brand/audience.md` and `voice-profile.md` for the latest brand context (these are the owned, canonical sources per [[PROTOCOL]])
2. **Fall back to skill reference:** If vault files don't exist, read `references/brand-{name}.md`
3. **Default brand:** Table Clay (if no brand specified)
4. If a brand has no context file anywhere, ask the user to provide details first.

Extract from brand context:
- **Content themes** — what topics to engage with
- **Brand voice** — how comments should sound
- **Products** — what NOT to mention in comments (instant spam signal)
- **Competitors** — awareness only (don't engage with direct competitors)

## Step 3: Open the Platform

**Instagram:** `https://www.instagram.com/`
**Facebook:** `https://www.facebook.com/`
**TikTok:** `https://www.tiktok.com/`

Rules:
1. Whatever account is signed into the browser is correct. Do NOT verify or ask confirmation. The browser is the source of truth.
2. If not logged in, ask the user to log in. Never enter credentials.
3. If CAPTCHA/verification appears, pause and ask the user.
4. If any rate-limiting or suspicious activity warning appears, **STOP immediately**.

## Step 4: Discover and Engage

Read the appropriate platform-specific reference file — it contains the complete workflow:

- **Instagram:** `references/instagram-workflow.md`
- **Facebook:** `references/facebook-workflow.md`
- **TikTok:** `references/tiktok-workflow.md`

For writing comments: `references/comment-guide.md`

### Pre-Session: Load Engagement History

Read `engagement-log.csv` once and keep in memory. Do NOT re-read between engagements.
- Same platform match → skip the account
- Different platform match → don't skip, but note in the `notes` column

### Engagement Principles

- **Follows are the primary growth action.** Follow most accounts. Likes and comments support the follow.
- **Vary patterns.** No two consecutive engagements should look identical.
- **Engage based on content, not account evaluation.** No profile visits or follower checks needed.
- **Only soft-skip** obviously massive accounts (100K+ at a glance).
- **Never** mention brand products, write generic comments, use hashtags, or comment on drama.
- **Never exceed session limits.**

## Browser Interaction Patterns

These universal patterns apply across all platforms.

### Element Targeting
**Always prefer `find` over coordinate-based clicks.** Social media layouts shift between sessions and A/B tests. Use `find` queries like "Follow button", "Like button", "comment input". Fall back to coordinates only when `find` fails, after a fresh screenshot.

### Stale References
Re-query with `find` when:
- A new post modal opens or reel advances
- A popup opens/closes over content

Don't re-query between actions on the same piece of content (refs stay valid while same content is visible).

### Focus Management
After interacting with text inputs (comment boxes), keyboard navigation often breaks. After submitting a comment:
1. Click outside or press `Escape` to release focus
2. Verify focus is cleared before keyboard navigation
3. Fall back to button-based navigation if keyboard still broken

**Facebook-specific:** Enter triggers the keyboard shortcuts overlay, not submit. Always use the send button.

### Fallback: Direct URL Navigation
If feed navigation becomes unreliable (cycling same content, freezing):
- **Instagram:** `https://www.instagram.com/explore/`
- **Facebook:** `https://www.facebook.com/reel/`
- **TikTok:** `https://www.tiktok.com/foryou`

### Popup and Modal Handling
1. Look for X / "Not Now" / "Close" via `find`
2. If none, press `Escape`
3. Screenshot to verify dismissed before continuing
4. Never interact with content behind a popup

### When to Screenshot
**Do screenshot:** First page load, unexpected events, `find` failures, post-troubleshoot verification.
**Don't screenshot:** Between actions on same content, before every follow/like, after each navigation advance, between react and follow on same Reel.

### Pacing Strategy
Natural scrolling/finding/assessing time is sufficient spacing. Only explicit pause: **15-30 seconds after posting comments.**

**TikTok exception:** Watch at least **10-15 seconds** of each video before engaging (watch time is a bot-detection signal).

## Step 5: Session Logging and Summary

### A. Show the User a Summary
```
Session Summary -- [Date, Time]
Platform: [Instagram / Facebook / TikTok]
Accounts followed: [count]
Posts liked/reacted to: [count]
Comments posted: [count]
Posts saved/bookmarked: [count, or "0"]
Notable accounts found: [standouts worth revisiting]
Any issues: [rate limiting, CAPTCHAs, errors, or "none"]
```

### B. Append to Engagement Log
Save to `engagement-log.csv` in this skill's directory.

```
date,time,platform,account_id,display_name,follower_count,account_type,content_type,action_taken,comment_text,post_url,notes
```

Rules:
1. **One row per account per session.** Consolidate: `follow+like+comment`, not separate rows.
2. **Always include time (HH:MM).** Never leave blank.
3. **Consistent format** across all platforms.

### C. Learning Loop (Vault Integration)
After each session, if notable patterns emerged, append to the brand's vault `learnings-log.md` per [[PROTOCOL]]:

```
## YYYY-MM-DD | Social Engagement | {Platform} session
- Result: a (smooth) / b (minor issues) / c (flagged/blocked)
- Outcome: {follows/likes/comments count}, {reciprocal follows or notable interactions}
- Lesson: {what worked or didn't}
- Tags: platform:{ig/tiktok/fb}, engagement
```

## Safety and Rate Limiting

### Universal Rules
1. **Never exceed session limits.**
2. **Always pace actions** per platform-specific rules.
3. **Vary patterns.** Don't repeat the same sequence every time.
4. **Stop on any warning** — blocking message, CAPTCHA, verification, unusual behavior.
5. **Cool-down:** Instagram 4-6 hours, Facebook 6-12 hours, TikTok 6-12 hours.
6. **Daily max:** 2 sessions per platform per day.

### Platform-Specific Safety
See "Safety and Stop Triggers" in each platform's workflow file.

## First-Run Setup

On the very first run for a platform:
1. Open the platform (whatever is signed in is correct)
2. Run a **half-limits test session:**
   - Instagram: 5-6 follows, 5 likes, 2 comments
   - Facebook: 4 Page follows, 6 reactions, 2 comments
   - TikTok: 5-6 follows, 5 likes, 2 comments
3. Review summary with user — ask if engagement style feels right
4. Verify `engagement-log.csv` has correct headers
5. Adjust based on feedback before full sessions

## Quick Reference: Session Limits

|  | Instagram | Facebook | TikTok |
|---|-----------|----------|--------|
| **Follows** | 10-12 | 8 | 10-12 |
| **Likes/Reactions** | 10 | 12 | 10 |
| **Comments** | 5 | 4 | 5 |
| **Saves/Bookmarks** | 0-2 | — | 0-2 |
| **Sessions/day** | 2 max | 2 max | 2 max |
| **Cool-down** | 4-6h | 6-12h | 6-12h |
