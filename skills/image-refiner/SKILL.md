---
name: image-refiner
description: |
  Refine base scene images by compositing real product photos into AI-generated scenes. Takes output from organic-content-generator or native-image-ad-generator (base image + metadata JSON with refiner_notes), downloads product reference photos from S3, and uses Gemini web UI (Chrome MCP / agent-browser) to edit the image with photorealistic product placement. Includes human QC gate for approve/reject/skip.

  TRIGGERS: refine images, run image refiner, refine organic content, swap products in, product composite, refine for [brand], image refinement run, refine base images, product placement
---

# Image Refiner

Composites real product photos into AI-generated scene images for photorealistic product placement.

## Pipeline

| Step | What |
|---|---|
| 1 | Receive base image path + metadata JSON (or batch directory) |
| 2 | Read metadata: product_described, refiner_notes, brand, scene context |
| 3 | Pull product reference images from S3 (hero.png + angle-1.png) |
| 4 | Construct refinement prompt for Gemini |
| 5 | Upload base image + product references to Gemini, run edit |
| 6 | QC gate — present for human review |
| 7 | Save approved image + update metadata |

## Input Modes

**Single image:**
```
Refine image: ad-outputs/organic/2026-02-27/morning-studio-1.png
```

**Batch (all from a run):**
```
Refine all images in: ad-outputs/organic/2026-02-27/
```
Process each `.png` that has a matching `.json` with `"status": "base-generated"`.

## Step 1: Load Metadata

Read the `.json` file alongside the base image. Required fields:
- `brand` — brand name
- `product_described` — what product is depicted
- `refiner_notes` — object with `product_location`, `product_scale`, `lighting_direction`, `background_complexity`
- `prompt_used` — original generation prompt

## Step 2: Get Product Reference Images

See `references/s3-asset-patterns.md` for S3 path patterns.

1. Read `product-catalog.md` from vault to find product line + slug
2. Download hero.png + angle-1.png from S3:
   ```bash
   aws s3 cp s3://bananabank-media-lake/{brand_lower}/catalog/products/{line}/{slug}/hero.png /tmp/product-ref-hero.png --profile polytrader --region eu-west-1
   aws s3 cp s3://bananabank-media-lake/{brand_lower}/catalog/products/{line}/{slug}/angle-1.png /tmp/product-ref-angle1.png --profile polytrader --region eu-west-1
   ```
3. **Fallback:** If S3 download fails, use text-only refinement with detailed product description from product-catalog.md.

## Step 3: Construct Refinement Prompt

See `references/refinement-prompts.md` for templates per scene type.

Base template:
```
Edit this image. Replace the [product_described] with the product shown in the reference image(s). Match the lighting ({lighting_direction}), shadows, perspective, and scale of the original scene. The product should look naturally placed in the environment. Product is at {product_location}, occupying roughly {product_scale} of the frame. Background complexity: {background_complexity}. {additional refiner_notes if any}
```

For text-only fallback (no S3 images), replace "product shown in the reference image(s)" with a detailed physical description from product-catalog.md.

## Step 4: Generate via Gemini Web UI

Use the same Chrome MCP / agent-browser pattern as native-image-ad-generator.

### Pre-Flight
```bash
agent-browser open "https://gemini.google.com/app"
agent-browser wait 3000
agent-browser screenshot /tmp/gemini-preflight.png
```
Verify logged in. If not, STOP and ask user.

### Upload + Prompt

1. Open new chat: `agent-browser open "https://gemini.google.com/app"` + wait 3000
2. Upload the base scene image via the attachment/upload button
3. Upload product reference image(s) (hero.png, optionally angle-1.png)
4. Insert the refinement prompt into the input field (same fill/execCommand pattern)
5. Submit and wait (50s initial, max 90s)
6. Download result via hover → Download icon
7. Save to temp review path: `/tmp/refine-review-{slug}.png`

### Upload Pattern
```bash
# Click the attachment/upload button
agent-browser snapshot -i
# Find and click the upload/attach button
agent-browser click @e{upload_button_ref}
# Use the file input to upload
agent-browser eval "document.querySelector('input[type=\"file\"]').click()"
# For file dialog, use agent-browser upload if available, otherwise:
agent-browser upload /path/to/base-image.png
```

Adapt based on current Gemini UI. Take screenshots to verify state at each step.

## Step 5: QC Gate

**Critical — always present for human review.**

See `references/qc-workflow.md` for detailed instructions.

After downloading the refined image:

1. Present to user:
   ```
   🖼️ Image Refinement Review
   
   Base image: {base_path}
   Refined image: /tmp/refine-review-{slug}.png
   Product reference: /tmp/product-ref-hero.png
   
   Prompt used: {refinement_prompt}
   Attempt: {N}
   
   Approve (a), Reject with notes (r), or Skip (s)?
   ```

2. Show both images (use canvas or file paths the user can open)

3. **On approve (a):** Copy to final path, update metadata
4. **On reject (r):** Ask for feedback, incorporate into prompt, re-run (max 3 attempts)
5. **On skip (s):** Mark as `rejected` in metadata, move to next image

## Step 6: Save & Update Metadata

### Output Path
Same directory as base image, with `-refined` suffix:
- Base: `ad-outputs/organic/2026-02-27/morning-studio-1.png`
- Refined: `ad-outputs/organic/2026-02-27/morning-studio-1-refined.png`

### Update Metadata JSON
Add/update these fields in the existing `.json`:
```json
{
  "status": "refined",
  "refined_at": "ISO timestamp",
  "product_reference_used": ["s3://bananabank-media-lake/.../hero.png", "s3://...angle-1.png"],
  "refinement_prompt": "the prompt used",
  "refinement_attempts": 1,
  "approved_by": "human"
}
```

For skipped images:
```json
{
  "status": "rejected",
  "refined_at": "ISO timestamp",
  "rejection_reason": "skipped by human"
}
```

## Brand Context

Load brand research from vault:
```
/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Brand/
```
Read `product-catalog.md` for product details and S3 slug mapping.

Brand discovery: `ls /data/projects/obsidian-vault/Projects/Ecommerce/Business/`

## Failure Handling

| Situation | Action |
|---|---|
| S3 images unavailable | Text-only refinement using product-catalog.md descriptions |
| Gemini safety refusal | Note, skip image or retry with adjusted prompt |
| No result after 90s | Skip, note timeout |
| Browser drops mid-batch | Save progress, output remaining list |
| Product not in catalog | Ask user for product details |

## Reference Files

- `references/refinement-prompts.md` — Prompt templates for different scene types
- `references/s3-asset-patterns.md` — S3 path patterns per brand
- `references/qc-workflow.md` — Detailed QC gate instructions
