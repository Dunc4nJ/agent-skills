---
name: social-media-engagement
description: "Run social media engagement sessions on Instagram, TikTok, or Facebook via browser automation. Use when the user says 'run engagement', 'engage on instagram', 'social media session', 'like and follow', 'run a tiktok session', 'facebook engagement', or asks to engage with accounts in a brand's niche. Requires Chrome browser connection and logged-in social media accounts."
---

# Social Media Engagement

Automated engagement sessions: discover niche-relevant content, follow creators, like posts, and leave genuine comments — all via `agent-browser` on logged-in social accounts.

## Prerequisites

- `agent-browser` CLI available (see agent-browser skill)
- Chrome browser connected with the target social account logged in
- Brand context loaded (see Brand Context below)

## Brand Context

Before starting, load the brand's engagement context:

1. **Check for vault brand file first:** `Projects/Ecommerce/Business/{Brand}/Brand/audience.md` and `voice-profile.md`
2. **Check for skill-local brand file:** `references/brand-{brandname}.md`
3. Use whichever exists. Vault brand files take priority (they're the owned, up-to-date source per the [[PROTOCOL]]).

Extract from brand context:
- **Content themes** — what topics to engage with
- **Brand voice** — how comments should sound
- **Competitors** — accounts to be aware of (don't engage with direct competitors)
- **What to skip** — off-niche content categories

## Session Setup

1. Read the engagement log (`engagement-log.csv` in this skill's directory) and note all previously engaged handles for the target platform
2. Keep that list in memory for the entire session — do NOT re-read between engagements
3. Confirm platform and session targets with the user if not specified

## Platform Workflows

Each platform has its own discovery method, engagement flow, session limits, and pacing rules. Read the relevant reference before running a session:

- **Instagram:** `references/instagram-workflow.md` — Explore tab discovery, follow+like+comment in post modals
- **TikTok:** `references/tiktok-workflow.md` — Search (early) or FYP (established) discovery, watch-before-engage rule, stricter pacing
- **Facebook:** `references/facebook-workflow.md` — Reels-only discovery, Page-based engagement, reaction variety (Like/Love/Care)

Only read the workflow file for the platform being used in this session.

## Comment Writing

Read `references/comment-guide.md` before writing any comments. Key rules:

- React to SPECIFIC content (reference what you see/hear)
- Vary style: compliments, questions, relatable reactions, encouragement
- Match post energy — polished gets refined, messy gets warm
- 0-1 emoji per comment, never lead with emoji
- **Never** mention the brand's products (instant spam signal)
- **Never** repeat a comment within a session
- **Never** write generic comments ("Great post!", "Love this!")
- **Never** use emdashes in comments
- Post comments without asking permission — they're pre-approved when the session starts

## Session Limits (Summary)

| Platform | Follows | Likes/Reactions | Comments | Sessions/Day |
|----------|---------|-----------------|----------|--------------|
| Instagram | 15 | 15 | 5 | 2 |
| TikTok | 10 | 12 | 4 | 2 |
| Facebook | 8 | 12 | 4 | 2 |

## Engagement Logging

After each session, append to `engagement-log.csv`:

```
date,time,platform,account_id,display_name,follower_count,account_type,content_type,action_taken,comment_text,post_url,notes
```

One row per account per session. Consolidate actions: `follow+like+comment`, not separate rows.

## Safety — Stop Triggers

If ANY of these occur, **stop immediately** and inform the user:

- "Action Blocked" / "You're Going Too Fast" / "Try Again Later"
- CAPTCHA or phone verification
- Account restriction or checkpoint
- Repeated errors or unusual loading times
- Being logged out unexpectedly

**Cool-down:** 4-6 hours minimum after a flag. Flagged twice in one day — skip the rest of the day.

## Learning Loop Integration

After each session, if notable patterns emerged (content types that got reciprocal engagement, comment styles that got replies, accounts worth revisiting), append a brief entry to the brand's `learnings-log.md` in the vault per the [[PROTOCOL]]:

```
## YYYY-MM-DD | Social Engagement | {Platform} session
- Result: a (smooth) / b (minor issues) / c (flagged/blocked)
- Outcome: {follows/likes/comments count}, {any reciprocal follows or notable interactions}
- Lesson: {what worked or didn't}
- Tags: platform:{ig/tiktok/fb}, engagement
```
