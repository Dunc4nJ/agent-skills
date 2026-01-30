---
name: twitter-bird-workflows
description: Read/search X (Twitter) and draft posts/replies using the bird CLI with safety guardrails. Use when you need to check timelines, read threads, search X, summarize findings, or prepare a tweet/reply draft. NEVER post without explicit user approval.
---

# Twitter (X) via bird — Workflows + Guardrails

This skill standardizes how to use the **bird** CLI to read/search X/Twitter and prepare drafts.

## Guardrails (Non-Negotiable)

- **Reading/searching is always OK.**
- **Posting is NEVER automatic.** Before running `bird tweet` or `bird reply`, present the exact final text and ask for explicit approval.
- **Prefer links + short summaries** over long copied text.
- **If auth fails**, stop and ask for help configuring `AUTH_TOKEN` + `CT0` (or bird config).

## Setup / Sanity Check

Run:

```bash
command -v bird && bird --version
bird check
bird whoami
```

If `whoami` fails, authentication is not configured.

## Common Read Workflows

### Read a specific tweet

```bash
bird read <url-or-id>
```

### Read a full thread

```bash
bird thread <url-or-id>
```

### Search

```bash
bird search "<query>" -n 10
```

### User timeline

```bash
bird user-tweets @handle -n 20
```

## Output Patterns

### Summarize a thread

1. Fetch thread: `bird thread <url>`
2. Produce:
   - 1–2 sentence gist
   - Key points as bullets
   - Any claims that need verification
   - Link back to the source tweet

### Draft a reply (DO NOT POST)

1. Read context: `bird thread <url>` (and optionally `bird replies <url>`)
2. Draft 1–3 candidate replies with different tones:
   - neutral/helpful
   - concise/technical
   - friendly/light
3. Ask which one to post.

## Posting (Approval Required)

Only after explicit approval:

```bash
bird tweet "..."
# or
bird reply <url> "..."
```

## Troubleshooting

### Query IDs stale

```bash
bird query-ids --fresh
```

### Cookie/auth issues

- Ensure `AUTH_TOKEN` and `CT0` are set (or use bird's cookie-source options)
- Re-run: `bird check`
