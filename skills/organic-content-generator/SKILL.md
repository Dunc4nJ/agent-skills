---
name: organic-content-generator
description: |
  Daily organic content generation pipeline for ecommerce brands. Reads content observations from engagement runs (IG, FB, TikTok), loads brand research from the Obsidian vault, generates 3-5 organic static image concepts with NanoBanana prompts, generates images via Chrome MCP (agent-browser driving Gemini web UI), and saves outputs with structured metadata. Images include a described product placeholder for downstream image-refiner swap.

  TRIGGERS: organic content, generate organic content for [brand], run organic generator, organic content run, daily content generation, organic images, social content ideas, organic post ideas

  Do NOT use for: paid ad generation (use native-image-ad-generator), engagement/commenting runs, observation capture, video content, ad copy without images.
---

# Organic Content Generator

Fully autonomous: brand in → 3-5 organic content images out. No mid-workflow approval.

## Pipeline

| Step | What |
|---|---|
| 1 | Receive brand (+ optional platform target) |
| 2 | Load observations from Content-Intelligence/organic/observations/ |
| 3 | Load brand research from vault |
| 4 | Synthesize trends + generate 8-12 concepts with NanoBanana prompts |
| 5 | Score and select top 3-5 |
| 6 | Generate images via Gemini web UI (Chrome MCP) |
| 7 | Save images + metadata to vault |

## Step 1: Input

Required: **brand name**. Optional: platform target (instagram-feed, instagram-stories, tiktok, facebook), product focus, content type preference.

Default platform: instagram-feed (4:5). Stories/reels: 9:16.

Brand discovery: `ls /data/projects/obsidian-vault/Projects/Ecommerce/Business/`

## Step 2: Load Observations

```
/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Content-Intelligence/organic/observations/
```

Files: `{YYYY-MM-DD}-{platform}.json` — arrays of observation objects.

Load last 7 days of observations. Sort by `relevance_to_brand: high` first. See `references/observation-schema.md` for full schema.

**If no observations exist:** Skip to Step 3 — fall back to brand research only. Note "no observations available" in output metadata.

Extract trend signals:
- Most frequent `content_type` values
- Recurring `visual_elements` across posts
- High-engagement patterns (`likes_estimate: high|viral`)
- Common `hashtags_noted`

## Step 3: Load Brand Research

```
/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Brand/
```

Load **full**: audience.md, creative-kit.md, learnings-log.md, product-catalog.md
Load **summary** (skim for key points): positioning.md, voice-profile.md

Follow the context-manifest.yaml pattern if present.

If user specified a product, match to `product-catalog.md`. Otherwise, select the primary/featured product.

Build internal product spec: physical description, dimensions, colors, materials, textures — enough detail for image generation AND downstream image-refiner product swap.

## Step 4: Generate 8-12 Concepts

Each concept gets a complete NanoBanana prompt. See `references/concept-categories.md` for organic content types.

**Key difference from ads:** Organic content is NOT sales-focused. It's aspirational, relatable, aesthetic, or educational. No CTAs, no offer text, no urgency.

**Product inclusion rule:** Every image includes the brand's product rendered from catalog descriptions (shape, color, material, scale). Place it naturally in the scene — on a shelf, in hands, on a table, in-use. The product should be clearly identifiable but not dominate. This enables the downstream image-refiner to swap in the real product photo.

**Per concept produce:**
- Concept name
- Content type (from categories)
- Scene description (50-100 words)
- Platform target
- Inspired-by observations (if available)
- NanoBanana prompt ending with `--ar 4:5` (feed) or `--ar 9:16` (stories/reels)

**Dedup against prior runs:** Check for existing generation run files in:
```
{Brand}/Content-Intelligence/organic/generation-runs/
```
Avoid repeating recent concept types and scenes.

Read `references/nanobanana-prompt-guide.md` from the native-image-ad-generator skill:
```
~/.agent/skills/native-image-ad-generator/references/nanobanana-prompt-guide.md
```

## Step 5: Score & Select Top 3-5

Score each concept 1-5 on five criteria (max 25). See `references/scoring-criteria.md`.

1. **Trend alignment** — matches current observations
2. **Brand fit** — matches voice/positioning/visual identity
3. **Visual distinctiveness** — different from recent outputs
4. **Platform suitability** — would perform on target platform
5. **Refiner-readiness** — product placement allows clean swap

**Rules:**
- Top 3-5 must include ≥2 different content types
- Default to 3 concepts unless observations are rich (then up to 5)
- Tiebreaker: higher refiner-readiness score

## Step 6: Generate Images via Gemini Web UI

Use the EXACT same pattern as native-image-ad-generator Steps 6A-6C. The process is identical:

### 6A. Pre-Flight
```bash
agent-browser open "https://gemini.google.com/app"
agent-browser wait 3000
agent-browser screenshot /tmp/gemini-preflight.png
```
Verify logged in. If not, STOP and ask user.

### 6B. Per-Concept Loop

For each selected concept:

1. **New chat:** `agent-browser open "https://gemini.google.com/app"` + wait 3000
2. **Insert prompt:** Try `agent-browser fill` on input field. Fallback to JS execCommand on `.ql-editor.textarea`
3. **Submit:** Click send button via `agent-browser eval`
4. **Wait:** 50s initial + check, max 90s
5. **Download:** Hover image → click Download icon (NOT Save). Verify `~/Downloads/Gemini_Generated_Image_*.png`
6. **Copy to vault output folder**

### 6C. Failure Handling

Same as native-image-ad-generator: safety refusal → promote next concept, timeout → skip, ≥3 fails → save successes + `REMAINING_PROMPTS.md`.

**Zero-Waste Rule:** No test images, no retries unless Gemini explicitly refuses.

## Step 7: Save & Register

### Output Structure

Images:
```
/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Brand/ad-outputs/organic/{YYYY-MM-DD}/
├── {concept_name_slug}.png
├── {concept_name_slug}.json      # per-image metadata
└── ...
```

Generation run summary:
```
{Brand}/Content-Intelligence/organic/generation-runs/{YYYY-MM-DD}-run.md
```

### Per-Image Metadata JSON

Save as `{concept_name_slug}.json` alongside each image:

```json
{
  "generated_at": "ISO timestamp",
  "brand": "BrandName",
  "concept_name": "Morning Studio Light",
  "content_type": "lifestyle",
  "inspired_by": ["2026-02-25-instagram.json#3"],
  "product_described": "Product name + brief physical description",
  "prompt_used": "full NanoBanana prompt",
  "aspect_ratio": "4:5",
  "platform_target": "instagram-feed",
  "score": 4.2,
  "status": "base-generated",
  "tags": ["morning-light", "studio", "ceramic"],
  "trend_signals_used": ["natural lighting", "earth tones"],
  "refiner_notes": {
    "product_location": "center-right, on wooden table",
    "product_scale": "occupies ~20% of frame",
    "lighting_direction": "soft left, warm",
    "background_complexity": "medium"
  }
}
```

**Status lifecycle:** `base-generated` → `refined` (image-refiner swaps product) → `resized` (image-resizer) → `ready`

The `refiner_notes` object enables the downstream image-refiner skill to accurately place the real product photo.

### Generation Run Summary

```markdown
# Organic Content Run — {Brand}
Date: {YYYY-MM-DD}
Platform: {target}

## Observations Used
- {N} observations from last 7 days ({platforms})
- Top trends: {list}

## Concepts Generated: {N} → Top {M} selected

### Concept 1: {Name}
- **Type:** {content_type}
- **Score:** {N}/25
- **Inspired by:** {observation refs or "brand research only"}
- **File:** {filename}
- **Prompt:** {full prompt}

[repeat]

## Failed Generations (if any)

## Sources
{vault files + observation files used}
```

### Register in assets-registry.md

Append to brand's `assets-registry.md`:
```markdown
| {date} | ad-outputs/organic/{date}/{slug}.png | organic {content_type}: {concept_name} | gemini-chrome |
```

### Delivery Message
```
Done — organic content generated for {Brand}.
✅ {N} images saved to vault
✅ Metadata JSON per image (refiner-ready)
✅ Run summary in Content-Intelligence/organic/generation-runs/
Path: Projects/Ecommerce/Business/{Brand}/Brand/ad-outputs/organic/{date}/
```

## Reference Files

- `references/observation-schema.md` — Full JSON schema for observation files
- `references/concept-categories.md` — Organic content type categories and guidance
- `references/scoring-criteria.md` — Detailed scoring rubric for concept selection
