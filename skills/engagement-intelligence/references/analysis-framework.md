# Analysis Framework

## Data Sources

1. **responses.csv** — harvested notification events (what others did in response to us)
2. **accounts.jsonl** — account relationship profiles (built from events + engagement log)
3. **engagement-log.csv** — our outbound actions (from `~/.openclaw/skills/social-media-engagement/`)

Load all three. Cross-reference by account handle and platform.

## Analysis Dimensions

### 1. Comment Performance

**Goal:** Identify which comment styles generate the most engagement.

**Method:**
1. From responses.csv, count `comment_like` and `comment_reply` events per `our_comment_snippet`
2. Match snippets back to full comment text in engagement-log.csv
3. Categorize each comment by style:
   - **Technique reference** — mentions a specific process (glazing, wheel throwing, kiln, etc.)
   - **Genuine question** — asks about materials, process, or experience
   - **Specific compliment** — praises a particular visual detail
   - **Relatable reaction** — expresses a feeling the post evoked
   - **Encouragement** — validates progress or effort
4. Calculate response rate per category: (comments with any response) / (total comments in category)
5. Calculate average engagement per category: mean(likes + replies) per comment

**Output:** Ranked list of comment styles by effectiveness. Flag any style with 0 responses.

### 2. Relationship Mapping

**Goal:** Identify high-value accounts and relationship trajectories.

**Method:**
1. From accounts.jsonl, group by `relationship_tier`
2. For each tier, list accounts sorted by total reciprocal engagement
3. Flag accounts showing upward trajectory (e.g., went from `noticed` to `engaged` between harvests)
4. Flag accounts with unanswered questions (they replied asking something — we should respond)

**Output:**
- Tier distribution: how many accounts at each level
- Top 10 highest-engagement accounts with full interaction history
- "Action needed" list: accounts with pending conversations or questions

### 3. Timing & Platform Patterns

**Goal:** Identify when and where engagement generates the best responses.

**Method:**
1. Cross-reference engagement-log.csv timestamps with responses.csv
2. Calculate response rate by: time of day (morning/afternoon/evening), day of week, platform
3. Calculate average time-to-response (engagement time → notification time)

**Output:** Best performing time slots and platform comparison.

### 4. Niche Segment Analysis

**Goal:** Which sub-niches within ceramics respond best?

**Method:**
1. From accounts.jsonl `niche_tags` and `notes`, group accounts by sub-niche
2. Calculate response rate per sub-niche
3. Identify which content types (wheel throwing, handbuilding, glazing, kiln work, studio setup, product photography) correlate with higher reciprocal engagement

**Output:** Ranked sub-niches by engagement quality.

### 5. Actionable Recommendations

Synthesize dimensions 1-4 into concrete action items:

- **Comment style adjustments** — "Increase technique questions from 30% to 40% of comments based on 2x higher reply rate"
- **Timing shifts** — "Morning sessions (before 10am) show 30% higher response rate"
- **Account targeting** — "Prioritize re-engagement with these 5 accounts showing upward trajectory"
- **Platform focus** — "IG generates 3x more reciprocal engagement than FB per action"
- **Conversation opportunities** — "These 3 accounts asked questions in replies — follow up"

## Report Template

Save to `data/reports/YYYY-MM-DD-report.md`:

```markdown
# Engagement Intelligence Report — YYYY-MM-DD

## Summary
- Total accounts engaged: X (IG: X, FB: X)
- Response rate: X% of accounts showed any reciprocal engagement
- New this period: X comment likes, X replies, X follow-backs

## Relationship Tiers
| Tier | Count | Change |
|------|-------|--------|
| Connected | X | +X |
| Engaged | X | +X |
| Noticed | X | +X |
| Cold | X | -X |

## Top Performing Comments
1. "[comment text]" → X likes, X replies
2. ...

## High-Value Accounts
[accounts at engaged/connected tier with notes]

## Action Items
1. [specific recommendation]
2. ...

## Comment Style Performance
| Style | Count | Response Rate | Avg Engagement |
|-------|-------|--------------|----------------|
| Technique reference | X | X% | X |
| Genuine question | X | X% | X |
| ... | | | |

## Pending Conversations
[accounts that asked questions we haven't responded to]
```

## Quick Analysis (Pre-Session)

For the 2-3 minute pre-session check, skip the full report. Output only:
1. New `engaged` or `connected` accounts since last harvest
2. Any pending conversations (unanswered questions)
3. Top 3 accounts to watch for in today's session
4. One-line comment style reminder based on latest performance data
