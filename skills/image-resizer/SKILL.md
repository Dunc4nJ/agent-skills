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

## Output

Create a `-variants/` subdirectory alongside each refined image with platform-specific PNGs and a `variants-manifest.json`. Update the source `.json` status to `ready`. See `references/output-format.md` for full schema, manifest format, and failure handling.

Compress variants with pngquant/optipng if available (see Post-Processing in `references/resize-strategies.md`).

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
- `references/resize-strategies.md` — Decision tree, ImageMagick commands, Gemini outpaint browser workflow and prompts
- `references/output-format.md` — Directory structure, manifest schema, source metadata updates, failure handling
