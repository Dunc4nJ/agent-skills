---
name: engagement-intelligence
description: "Harvest and analyze social media engagement outcomes for TableClay. Use when the user says 'harvest engagement', 'check engagement results', 'run engagement analysis', 'who engaged back', 'engagement report', 'outcome check', 'review notifications', or before starting an engagement session. Scrapes IG/FB notification pages via Chrome to collect response data (comment likes, replies, follow-backs), builds account relationship profiles, and produces actionable reports. Also used by the engagement skill as a pre-session outcome check."
---

# Engagement Intelligence

## Modes

| User says | Mode | Reference |
|-----------|------|-----------|
| "harvest", "check notifications", "outcome check" | Harvest | `references/harvest-instagram.md`, `references/harvest-facebook.md` |
| "analyze", "engagement report", "what's working" | Analyze | `references/analysis-framework.md` |
| "full run", "harvest and analyze" | Both | Harvest first, then analyze |
| Starting an engagement session | Quick harvest | Run harvest, surface top signals, then proceed to engagement |

## Data Architecture

Two-layer system: raw events feed into account profiles.

### Layer 1: Response Events (append-only CSV)
**Path:** `data/responses.csv`

Raw notifications harvested from IG/FB. One row per event. Append-only, never edited.

```
harvested_at,platform,event_type,from_account,from_display_name,our_comment_snippet,their_response,post_url,event_age
```

Event types: `comment_like`, `comment_reply`, `follow_back`, `post_like`, `mention`, `story_like`

### Layer 2: Account Profiles (JSONL, rebuilt from events)
**Path:** `data/accounts.jsonl`

One JSON object per line, one line per account. Rebuilt/updated after each harvest by merging new events into existing profiles. See `references/account-schema.md` for full schema.

Key fields per account:
- `handle`, `platform`, `display_name`
- `first_interaction` / `last_interaction` (from engagement-log.csv)
- `our_actions` — what we did (follow, like, comment, save)
- `their_responses` — what they did back (comment_likes, replies, follow_back)
- `top_performing_comment` — our comment that got the most engagement from this account
- `relationship_tier` — computed: `cold` → `noticed` → `engaged` → `connected`
- `niche_relevance` — `high` / `medium` / `low` (ceramics/pottery = high)
- `notes` — freeform observations

### Tier Definitions

| Tier | Criteria |
|------|----------|
| `cold` | We engaged, no response detected |
| `noticed` | They liked one of our comments |
| `engaged` | They replied to a comment OR followed back |
| `connected` | Multiple reciprocal interactions (2+ replies, or follow-back + reply) |

### Watermark System
**Path:** `data/watermarks.json`

```json
{"instagram": "2026-02-27T07:20:00Z", "facebook": "2026-02-27T07:22:00Z"}
```

Store the timestamp of the most recent harvested notification per platform. On next harvest, stop scrolling when hitting a previously-seen notification. Keeps runs to ~2-3 minutes.

## Harvest Flow (Summary)

1. Connect to Chrome (`agent-browser connect 9222`)
2. Navigate to platform notifications page
3. Parse notification text via `snapshot` (not screenshot — text is structured)
4. Extract: event_type, from_account, our_comment_snippet, their_response, timestamp
5. Stop when hitting watermark timestamp
6. Append new events to `data/responses.csv`
7. Rebuild affected account profiles in `data/accounts.jsonl`
8. Update watermark

Platform-specific parsing instructions in `references/harvest-instagram.md` and `references/harvest-facebook.md`.

## Analysis Flow (Summary)

Read `references/analysis-framework.md` for the full framework. Core outputs:

1. **Comment Performance Report** — which comment styles generate responses
2. **High-Value Accounts** — sorted by relationship tier, flagged for priority engagement
3. **Recommendations** — concrete adjustments to comment style, timing, account targeting
4. **Weekly Report** — saved to `data/reports/YYYY-MM-DD-report.md`

## Integration with Engagement Skill

### Pre-Session Outcome Check
At the START of each engagement session (before new engagement), run a quick harvest:
1. Harvest IG or FB notifications (whichever platform the session targets)
2. Surface any new `engaged` or `connected` tier accounts
3. Note any accounts that replied with questions (opportunity for follow-up)
4. Load high-value accounts list so the engagement agent can prioritize re-encounters

### Post-Analysis Feedback
After weekly analysis, update:
- `references/comment-guide.md` in the engagement skill (if patterns suggest style changes)
- Brand learnings log in vault (`Projects/Ecommerce/Business/TableClay/Brand/learnings-log.md`)

## File Paths

| File | Purpose |
|------|---------|
| `data/responses.csv` | Raw harvested notification events |
| `data/accounts.jsonl` | Account relationship profiles |
| `data/watermarks.json` | Last-harvested timestamp per platform |
| `data/reports/YYYY-MM-DD-report.md` | Weekly analysis reports |
| `references/harvest-instagram.md` | IG notification parsing instructions |
| `references/harvest-facebook.md` | FB notification parsing instructions |
| `references/analysis-framework.md` | Analysis dimensions and report template |
| `references/account-schema.md` | Full account profile JSON schema |
