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

Score each concept 1-5 on five criteria (max 25): trend alignment, brand fit, visual distinctiveness, platform suitability, refiner-readiness. Select top 3-5 with ≥2 different content types. Default to 3 unless observations are rich (then up to 5).

See `references/scoring-criteria.md` for the full rubric and selection rules.

## Step 6: Generate Images via Gemini Web UI

Generate images via Chrome MCP driving Gemini web UI. See `references/gemini-generation.md` for the full browser automation sequence (pre-flight, per-concept loop, failure handling).

## Step 7: Save & Register

Save images + per-image metadata JSON to vault, write generation run summary, register in assets-registry.md, and deliver summary message.

See `references/output-templates.md` for all output paths, JSON schema, run summary template, registry format, and delivery message.

## Reference Files

- `references/observation-schema.md` — Full JSON schema for observation files
- `references/concept-categories.md` — Organic content type categories and guidance
- `references/scoring-criteria.md` — Detailed scoring rubric for concept selection
