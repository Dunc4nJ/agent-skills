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
| 2 | Read metadata → identify product, brand, refiner_notes |
| 3 | Pull product reference images from S3 |
| 4 | Construct refinement prompt |
| 5 | Upload base image + references to Gemini, run edit |
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

## Workflow

1. **Load metadata** — Read the `.json` alongside the base image. See `references/metadata-schema.md` for required fields.

2. **Get product references** — Download hero.png + angle-1.png from S3. See `references/s3-asset-patterns.md` for paths and commands. Fallback: text-only refinement using product-catalog.md descriptions.

3. **Construct prompt** — See `references/refinement-prompts.md` for templates per scene type.

4. **Generate via Gemini** — Use agent-browser to drive Gemini web UI. See `references/gemini-browser-workflow.md` for the full upload + prompt + download pattern.

5. **QC gate** — Always present for human review (approve/reject/skip). See `references/qc-workflow.md` for detailed flow.

6. **Save & update metadata** — Save refined image with `-refined` suffix, update JSON. See `references/metadata-schema.md` for output schema.

## Brand Context

Load brand research from vault:
```
/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Brand/
```
Read `product-catalog.md` for product details and S3 slug mapping.

Brand discovery: `ls /data/projects/obsidian-vault/Projects/Ecommerce/Business/`

## Reference Files

- `references/gemini-browser-workflow.md` — Gemini web UI automation (upload, prompt, download)
- `references/refinement-prompts.md` — Prompt templates for different scene types
- `references/s3-asset-patterns.md` — S3 path patterns and download commands
- `references/qc-workflow.md` — QC gate presentation and response handling
- `references/metadata-schema.md` — Input/output metadata fields, output paths, failure handling
