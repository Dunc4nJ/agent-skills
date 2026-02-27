# Output Format

## Directory Structure

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

## variants-manifest.json

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

## Update Source Metadata

After all variants generated, update the source `.json`:
```json
{
  "status": "ready",
  "resized_at": "ISO timestamp",
  "variants_dir": "morning-studio-1-refined-variants/",
  "variants_count": 3
}
```

## Failure Handling

| Situation | Action |
|---|---|
| ImageMagick not installed | Stop, offer install command |
| Gemini not logged in | Stop, ask user to log in |
| Outpaint fails/times out | Skip that variant, note in manifest |
| No refined images found | Report "no refined images found" |
| Browser drops mid-batch | Save completed variants, list remaining |
