# QC Gate Workflow

## Presentation Format

After each refinement, present to the human:

```
🖼️ Image Refinement Review ({N} of {total})

📁 Base:     {base_image_path}
📁 Refined:  /tmp/refine-review-{slug}.png
📁 Product ref: /tmp/product-ref-hero.png

🎨 Prompt: {refinement_prompt}
🔄 Attempt: {attempt_number}/3

Approve (a) | Reject with notes (r) | Skip (s)
```

Display both images so the user can compare. Use canvas `present` if available, or provide file paths.

## Response Handling

### Approve (a)
1. Copy `/tmp/refine-review-{slug}.png` → `{base_dir}/{slug}-refined.png`
2. Update metadata JSON:
   - `status` → `refined`
   - `refined_at` → current ISO timestamp
   - `product_reference_used` → S3 paths used
   - `refinement_prompt` → prompt text
   - `refinement_attempts` → attempt count
   - `approved_by` → `human`
3. Move to next image in batch

### Reject with notes (r)
1. Ask: "What should change? (e.g., product too large, wrong angle, lighting mismatch)"
2. Incorporate feedback into prompt adjustments (see refinement-prompts.md multi-attempt section)
3. Re-run generation (max 3 total attempts per image)
4. If 3 attempts exhausted without approval, treat as skip

### Skip (s)
1. Update metadata JSON:
   - `status` → `rejected`
   - `refined_at` → current ISO timestamp
   - `rejection_reason` → `skipped by human`
2. Clean up temp files
3. Move to next image in batch

## Batch Progress

Track and display batch progress:
```
Progress: {completed}/{total} | ✅ {approved} approved | ❌ {rejected} skipped
```

## End of Batch Summary

```
🏁 Refinement Complete

✅ Approved: {N} images
❌ Skipped: {N} images
🔄 Total attempts: {N}

Refined images saved to: {output_directory}
```
