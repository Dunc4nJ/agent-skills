---
name: image-resizer
description: |
  Resize and reformat refined images for social media platforms. Takes refined images (status=refined from image-refiner) and creates platform-specific variants using ImageMagick for simple resizes (similar aspect ratio) or Gemini web UI outpainting (Chrome MCP / agent-browser) when aspect ratio changes require extending the canvas.

  TRIGGERS: resize images, run image resizer, resize for platforms, create platform variants, optimize for instagram, optimize for facebook, resize for Instagram, resize for all platforms, image resizer run, resize for TikTok, resize for Pinterest, platform variants
---

# Image Resizer

Create platform-specific image variants from refined images. Prefer ImageMagick (fast, deterministic, free) over Gemini outpainting (only when AR change needs content generation).

## Pipeline

| Step | What |
|---|---|
| 1 | Receive refined image path + metadata, or batch (all refined from a run) |
| 2 | Determine target platforms from user input or defaults |
| 3 | For each target, decide: simple resize or intelligent outpaint |
| 4 | Simple resize → ImageMagick |
| 5 | AR change needing canvas extension → Gemini outpaint via Chrome MCP |
| 6 | Save variants + manifest, update source metadata status to `ready` |

## Input Modes

**Single image:**
```
Resize image: ad-outputs/organic/2026-02-27/morning-studio-1-refined.png
```

**Batch (default):**
```
Resize all refined images from: ad-outputs/organic/2026-02-27/
```
Process each `.png` that has a matching `.json` with `"status": "refined"`.

## Prerequisites

Verify before running:
```bash
which convert || which magick   # ImageMagick required
which pngquant                  # optional optimization
which optipng                   # optional optimization
```
If ImageMagick missing, offer: `sudo apt install imagemagick`.

## Target Platform Defaults

When user doesn't specify platforms, generate these 3 (covers ~80% of use cases):
- **ig-feed** — 1080×1350 (4:5)
- **ig-story** — 1080×1920 (9:16)
- **fb-feed** — 1200×1500 (4:5)

See `references/platform-specs.md` for all supported platforms and dimensions.

## Resize Strategy

See `references/resize-strategies.md` for the full decision tree, ImageMagick commands, and Gemini outpaint prompt templates.

**Summary:**
1. Compute source AR and target AR
2. If ARs within 5% → ImageMagick simple resize
3. If target wider → Gemini outpaint left/right
4. If target taller → Gemini outpaint top/bottom
5. If target much smaller → ImageMagick smart crop + resize

## Gemini Outpainting (Chrome MCP)

Same agent-browser pattern as native-image-ad-generator and image-refiner:

1. `agent-browser open "https://gemini.google.com/app"` + wait 3000
2. Verify logged in (screenshot check). If not, STOP and ask user.
3. Upload the refined image via attachment button
4. Prompt: "Extend this image to {W}x{H} ({target_ar}) aspect ratio by naturally continuing the background/scene. Keep the product and central composition unchanged. Extend the {direction} edges seamlessly. Output exactly {W}x{H} pixels."
5. Submit, wait 50s (max 90s), download via hover → Download icon
6. Copy to variants directory
7. Open new chat for each outpaint operation

**Zero-Waste Rule:** Only use Gemini when AR change genuinely needs content generation. Never for same-AR resizes.

## Output Structure

For each refined image, create a `-variants/` subdirectory alongside it:
```
ad-outputs/organic/2026-02-27/
├── morning-studio-1-refined.png
├── morning-studio-1-refined.json
└── morning-studio-1-refined-variants/
    ├── ig-feed-4x5.png
    ├── ig-story-9x16.png
    ├── fb-feed-4x5.png
    └── variants-manifest.json
```

### variants-manifest.json
```json
{
  "source": "morning-studio-1-refined.png",
  "generated_at": "ISO timestamp",
  "variants": [
    {
      "filename": "ig-feed-4x5.png",
      "platform": "instagram",
      "placement": "feed",
      "dimensions": "1080x1350",
      "aspect_ratio": "4:5",
      "method": "simple-resize|gemini-outpaint|smart-crop",
      "file_size_kb": 245
    }
  ]
}
```

### Update Source Metadata

After all variants generated, update the source `.json`:
```json
{
  "status": "ready",
  "resized_at": "ISO timestamp",
  "variants_dir": "morning-studio-1-refined-variants/",
  "variants_count": 3
}
```

## Compression

After generating each variant:
```bash
# If pngquant available:
pngquant --quality=80-95 --force --output OUTPUT OUTPUT
# Elif optipng available:
optipng -o2 OUTPUT
# Else: ImageMagick quality is sufficient
```

## Failure Handling

| Situation | Action |
|---|---|
| ImageMagick not installed | Stop, offer install command |
| Gemini not logged in | Stop, ask user to log in |
| Outpaint fails/times out | Skip that variant, note in manifest |
| No refined images found | Report "no refined images found" |
| Browser drops mid-batch | Save completed variants, list remaining |

## Batch Summary

After processing, report:
```
✅ Image Resizer Complete
- Processed: {N} refined images
- Variants created: {total}
- Methods: {X} simple resize, {Y} Gemini outpaint
- Path: {output_dir}
```

## Reference Files

- `references/platform-specs.md` — All platform dimensions, aspect ratios, and format requirements
- `references/resize-strategies.md` — Decision tree, ImageMagick commands, Gemini outpaint prompts
