# Metadata Schema

## Input Metadata (from base generator)

Required fields in the `.json` alongside the base image:
- `brand` — brand name
- `product_described` — what product is depicted
- `refiner_notes` — object with `product_location`, `product_scale`, `lighting_direction`, `background_complexity`
- `prompt_used` — original generation prompt

## Output: Approved Image

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

## Output: Skipped/Rejected Image

```json
{
  "status": "rejected",
  "refined_at": "ISO timestamp",
  "rejection_reason": "skipped by human"
}
```

## Output Path Convention

Same directory as base image, with `-refined` suffix:
- Base: `ad-outputs/organic/2026-02-27/morning-studio-1.png`
- Refined: `ad-outputs/organic/2026-02-27/morning-studio-1-refined.png`

## Failure Handling

| Situation | Action |
|---|---|
| S3 images unavailable | Text-only refinement using product-catalog.md descriptions |
| Gemini safety refusal | Note, skip image or retry with adjusted prompt |
| No result after 90s | Skip, note timeout |
| Browser drops mid-batch | Save progress, output remaining list |
| Product not in catalog | Ask user for product details |
