# Output Templates

## Output Structure

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

## Per-Image Metadata JSON

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

## Generation Run Summary

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

## Register in assets-registry.md

Append to brand's `assets-registry.md`:
```markdown
| {date} | ad-outputs/organic/{date}/{slug}.png | organic {content_type}: {concept_name} | gemini-chrome |
```

## Delivery Message

```
Done — organic content generated for {Brand}.
✅ {N} images saved to vault
✅ Metadata JSON per image (refiner-ready)
✅ Run summary in Content-Intelligence/organic/generation-runs/
Path: Projects/Ecommerce/Business/{Brand}/Brand/ad-outputs/organic/{date}/
```
