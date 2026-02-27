# Account Profile Schema

Each line in `data/accounts.jsonl` is one JSON object representing a single account relationship.

## Full Schema

```json
{
  "handle": "@sincerelysydceramics",
  "platform": "instagram",
  "display_name": "Sydney | Slow Made Ceramics",
  "first_interaction": "2026-02-26",
  "last_interaction": "2026-02-27",
  "our_actions": {
    "follow": true,
    "follow_date": "2026-02-26",
    "likes": 1,
    "comments": 1,
    "saves": 0,
    "comment_texts": [
      "one throw for the lip is so smart, way less risk of cracking than attaching separately"
    ]
  },
  "their_responses": {
    "followed_back": true,
    "follow_back_date": "2026-02-27",
    "comment_likes": 1,
    "comment_replies": [
      {
        "date": "2026-02-27",
        "text": "my separate attached ones crack like 60% of the time 😂😂😂🫠",
        "to_our_comment": "one throw for the lip is so smart..."
      }
    ],
    "post_likes": 0,
    "mentions": 1
  },
  "top_performing_comment": {
    "text": "one throw for the lip is so smart, way less risk of cracking than attaching separately",
    "likes": 1,
    "replies": 1,
    "total_engagement": 2
  },
  "relationship_tier": "connected",
  "niche_relevance": "high",
  "niche_tags": ["ceramics", "wheel-throwing", "small-studio"],
  "notes": "Small studio potter. Followed back within 24h. Started real conversation about technique. Conference potential.",
  "last_harvested": "2026-02-27T07:20:00Z"
}
```

## Field Reference

### Identity
| Field | Type | Description |
|-------|------|-------------|
| `handle` | string | Account handle with @ prefix for IG, page name for FB |
| `platform` | string | `instagram` or `facebook` |
| `display_name` | string | Human-readable name from notification text |

### Our Actions (from engagement-log.csv)
| Field | Type | Description |
|-------|------|-------------|
| `our_actions.follow` | bool | Whether we followed them |
| `our_actions.follow_date` | string | Date of follow |
| `our_actions.likes` | int | Number of posts we liked |
| `our_actions.comments` | int | Number of comments we posted |
| `our_actions.saves` | int | Number of posts we saved |
| `our_actions.comment_texts` | string[] | Full text of comments we posted |

### Their Responses (from harvested notifications)
| Field | Type | Description |
|-------|------|-------------|
| `their_responses.followed_back` | bool | Whether they followed us |
| `their_responses.follow_back_date` | string | Date of follow-back |
| `their_responses.comment_likes` | int | How many of our comments they liked |
| `their_responses.comment_replies` | object[] | Their replies to our comments |
| `their_responses.post_likes` | int | How many of our posts they liked |
| `their_responses.mentions` | int | Times they mentioned @table.clay |

### Computed Fields
| Field | Type | Description |
|-------|------|-------------|
| `top_performing_comment` | object | Our comment with highest engagement from this account |
| `relationship_tier` | string | `cold`, `noticed`, `engaged`, `connected` |
| `niche_relevance` | string | `high`, `medium`, `low` |
| `niche_tags` | string[] | Content categories observed |

## Tier Computation

```
if comment_replies >= 2 OR (followed_back AND comment_replies >= 1):
    tier = "connected"
elif comment_replies >= 1 OR followed_back:
    tier = "engaged"  
elif comment_likes >= 1 OR post_likes >= 1:
    tier = "noticed"
else:
    tier = "cold"
```

## Merging Rules

When new events arrive for an existing account:
1. Increment counters (comment_likes, etc.)
2. Append new replies to `comment_replies` array
3. Update `followed_back` if a follow-back event appears
4. Recalculate `relationship_tier`
5. Recalculate `top_performing_comment` based on combined likes + replies
6. Update `last_interaction` and `last_harvested`

Never overwrite existing data — only add or increment. If a field conflict occurs, keep the higher/more-recent value.
