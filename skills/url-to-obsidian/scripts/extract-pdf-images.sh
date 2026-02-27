#!/usr/bin/env bash
set -euo pipefail

# Extract and filter images from a PDF.
# Usage: extract-pdf-images.sh <pdf-path> <output-dir>
#
# 1. Runs pdfimages -all to dump all embedded images
# 2. Converts PPM/PBM/PGM to PNG via ImageMagick
# 3. Drops images under 150x150px or 5KB
# 4. Outputs JSON array of surviving files with dimensions
#
# Requires: poppler-utils, imagemagick (optional, for PPM conversion)

PDF="${1:?Usage: extract-pdf-images.sh <pdf-path> <output-dir>}"
OUTDIR="${2:?Usage: extract-pdf-images.sh <pdf-path> <output-dir>}"

mkdir -p "$OUTDIR"

# Extract all images
pdfimages -all "$PDF" "$OUTDIR/img"

# Convert any PPM/PBM/PGM to PNG
for f in "$OUTDIR"/img-*.ppm "$OUTDIR"/img-*.pbm "$OUTDIR"/img-*.pgm; do
  [[ -f "$f" ]] || continue
  png="${f%.*}.png"
  if command -v convert &>/dev/null; then
    convert "$f" "$png" && rm -f "$f"
  else
    echo "Warning: ImageMagick not found, skipping PPM conversion for $f" >&2
  fi
done

# Filter by size and dimensions, output JSON
echo "["
first=true
for f in "$OUTDIR"/img-*.*; do
  [[ -f "$f" ]] || continue

  # Skip files under 5KB
  size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f" 2>/dev/null)
  [[ "$size" -lt 5120 ]] && rm -f "$f" && continue

  # Get dimensions via identify or file
  dims=""
  if command -v identify &>/dev/null; then
    dims=$(identify -format "%wx%h" "$f" 2>/dev/null || true)
  fi

  if [[ -n "$dims" ]]; then
    w="${dims%x*}"
    h="${dims#*x}"
    # Drop images under 150x150
    if [[ "$w" -lt 150 && "$h" -lt 150 ]]; then
      rm -f "$f"
      continue
    fi
  else
    w="unknown"
    h="unknown"
  fi

  filename=$(basename "$f")
  if $first; then
    first=false
  else
    echo ","
  fi
  printf '  {"file": "%s", "width": "%s", "height": "%s", "bytes": %s}' \
    "$filename" "$w" "$h" "$size"
done
echo ""
echo "]"
