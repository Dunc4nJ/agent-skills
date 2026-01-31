# Note Template for URL Captures

Exact structure for vault notes created from URLs. Adapt each section to the content.

## Template

```markdown
---
created: YYYY-MM-DD
description: One sentence elaborating the title claim
source: https://original-url.com
type: framework
---

## Key Takeaways

Original analysis paragraph with [[Related Note]] woven inline. Each takeaway should
stand alone — a reader arriving via any wiki link understands the insight without
needing other context. Dense linking is expected: aim for at least one wiki link per
takeaway paragraph connecting to existing vault knowledge.

Second takeaway paragraph exploring a different angle. This connects to
[[Another Note]] because the underlying pattern is shared. Write in your own voice,
not copied text from the source.

## External Resources

- [Resource Title](https://url) — one-sentence description of what this links to
- [Another Resource](https://url) — brief description

Only include resources found within or referenced by the source content.

## Original Content

[Use one of the two formats below depending on source type]
```

## Format: Tweets (short content)

Use standard blockquotes with attribution:

```markdown
> @handle — YYYY-MM-DD
>
> Full tweet text here. For threads, include all tweets
> in the thread as a continuous blockquote with blank
> lines between each tweet.
>
> Engagement: 260 likes | 12 retweets | 18 replies
> [Original post](https://x.com/handle/status/id)
```

## Format: Web pages (long content)

Use a collapsible Obsidian callout:

```markdown
> [!quote]- Source Material
> Full article/page content here.
> Preserve headings and structure from the markdown.
> This collapses by default in Obsidian so it does not
> clutter the reading view but remains available for reference.
>
> [Original page](https://url)
```

## Rules

- Title is a claim, not a topic: "onboarding drives 70% of retention" not "onboarding-notes"
- Wiki links go inline in sentences, never in a "Related:" section at the bottom
- Description must be one sentence making the note discoverable without opening it
- The note must stand alone — a reader arriving from any wiki link understands it
- No emoji in headings or body
- Always include link to original URL in the Original Content section
