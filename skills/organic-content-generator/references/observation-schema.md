# Observation Schema

Observation files live at:
```
/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Content-Intelligence/organic/observations/
```

Filename format: `{YYYY-MM-DD}-{platform}.json` (e.g., `2026-02-25-instagram.json`)

Each file contains a JSON array of observation objects.

## Schema

```json
{
  "observed_at": "2026-02-25T14:30:00Z",
  "platform": "instagram|facebook|tiktok",
  "account": "@handle",
  "content_type": "flat-lay|lifestyle|behind-the-scenes|educational|mood-board|ugc-style|product-showcase|seasonal|humor|trending-format",
  "description": "Brief description of what the post shows — scene, composition, mood",
  "engagement_signals": {
    "likes_estimate": "low|medium|high|viral",
    "comments_estimate": "low|medium|high",
    "saves_noted": true
  },
  "why_notable": "Brief reason this content stood out during the engagement run",
  "visual_elements": ["natural lighting", "earth tones", "hands in frame", "minimal props"],
  "format": "square|portrait|landscape|story|reel-cover",
  "hashtags_noted": ["#pottery", "#handmade"],
  "relevance_to_brand": "high|medium|low"
}
```

## Field Notes

| Field | Required | Notes |
|---|---|---|
| observed_at | yes | ISO 8601 timestamp |
| platform | yes | One of: instagram, facebook, tiktok |
| account | yes | The @handle where content was seen |
| content_type | yes | Primary content category |
| description | yes | 1-3 sentences describing the visual |
| engagement_signals | yes | All three sub-fields required |
| why_notable | yes | Why the engagement agent flagged this |
| visual_elements | yes | Array of visual descriptors (≥1) |
| format | yes | Aspect ratio / placement format |
| hashtags_noted | no | Empty array if none noted |
| relevance_to_brand | yes | How relevant to the brand's niche |

## Referencing Observations

When a generated concept is inspired by an observation, reference it as:
```
{filename}#{index}
```
Example: `2026-02-25-instagram.json#3` (4th item, zero-indexed)
