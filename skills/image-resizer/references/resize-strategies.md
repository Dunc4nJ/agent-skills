# Resize Strategies

## Decision Tree

```
source_ar = source_width / source_height
target_ar = target_width / target_height
diff = abs(source_ar - target_ar) / source_ar

IF diff <= 0.05:
  → SIMPLE RESIZE (ImageMagick)
ELIF target_ar > source_ar (target wider):
  → GEMINI OUTPAINT left/right
ELIF target_ar < source_ar (target taller):
  → GEMINI OUTPAINT top/bottom
IF target total pixels < source * 0.25:
  → SMART CROP + resize (ImageMagick)
```

## Method 1: Simple Resize (ImageMagick)

For same or near-same aspect ratio. Resize to fill, center-crop excess, sharpen.

```bash
convert input.png \
  -resize {W}x{H}^ \
  -gravity center \
  -extent {W}x{H} \
  -unsharp 0x0.5+0.5+0 \
  output.png
```

Examples:
- Source 4:5 → ig-feed 1080×1350 (4:5): direct resize
- Source 4:5 → fb-feed 1200×1500 (4:5): direct resize
- Source 1:1 → ig-square 1080×1080 (1:1): direct resize

## Method 2: Smart Crop + Resize (ImageMagick)

For significant downscaling where target is much smaller. Center on product.

```bash
convert input.png \
  -gravity center \
  -crop {crop_w}x{crop_h}+0+0 +repage \
  -resize {W}x{H} \
  -unsharp 0x0.5+0.5+0 \
  output.png
```

Compute crop dimensions to match target AR before resizing.

## Method 3: Gemini Outpaint

For AR changes requiring canvas extension with generated content.

### Wider Target (extend left/right)
Prompt:
```
Extend this image to a {target_ar_text} aspect ratio ({W}x{H} pixels) by naturally continuing the background and scene to the left and right. Keep the product and central composition completely unchanged. The extended areas should seamlessly blend with the existing edges — match lighting, color, texture, and perspective exactly. Output the final image at {W}x{H} pixels.
```

### Taller Target (extend top/bottom)
Prompt:
```
Extend this image to a {target_ar_text} aspect ratio ({W}x{H} pixels) by naturally continuing the background and scene above and below. Keep the product and central composition completely unchanged. The extended areas should seamlessly blend with the existing edges — match lighting, color, texture, and perspective exactly. Output the final image at {W}x{H} pixels.
```

### Common Outpaint Scenarios
| Source AR | Target | Direction | Example |
|---|---|---|---|
| 4:5 (0.80) | 9:16 (0.5625) | Extend top/bottom | ig-feed → ig-story |
| 4:5 (0.80) | 1.91:1 (1.91) | Extend left/right | ig-feed → fb-landscape |
| 4:5 (0.80) | 2.63:1 (2.63) | Extend left/right | ig-feed → fb-cover |
| 4:5 (0.80) | 1:1 (1.0) | Extend left/right (slight) | ig-feed → square |
| 2:3 (0.667) | 1:2.1 (0.476) | Extend top/bottom | standard → long pin |

## Post-Processing

After any method, optimize:
```bash
# pngquant (if available) — lossy, great compression
pngquant --quality=80-95 --force --output "$file" "$file"

# optipng (if available) — lossless
optipng -o2 "$file"
```

## Getting Source Dimensions

```bash
identify -format "%wx%h" input.png
```
