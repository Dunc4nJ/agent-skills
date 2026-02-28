#!/usr/bin/env bash
# verify-original-content.sh — Compare source content against what landed in the note
# Usage: verify-original-content.sh <note_path> <source_content_path>
# Exit 0 = OK, Exit 1 = significant divergence

set -euo pipefail

NOTE="$1"
SOURCE="$2"

if [[ ! -f "$NOTE" ]]; then echo "ERROR: Note not found: $NOTE"; exit 1; fi
if [[ ! -f "$SOURCE" ]]; then echo "ERROR: Source file not found: $SOURCE"; exit 1; fi

SOURCE_WORDS=$(wc -w < "$SOURCE" | tr -d ' ')
SOURCE_LINES=$(wc -l < "$SOURCE" | tr -d ' ')

# Extract everything after "## Original Content" until the next h2 or EOF
NOTE_CONTENT=$(sed -n '/^## Original Content/,/^## [^O]/p' "$NOTE" | sed '1d;$d')
if [[ -z "$NOTE_CONTENT" ]]; then
    # No next h2 — take everything after Original Content
    NOTE_CONTENT=$(sed -n '/^## Original Content/,$p' "$NOTE" | sed '1d')
fi

# Strip blockquote markers and callout syntax for fair word count
CLEAN_CONTENT=$(echo "$NOTE_CONTENT" | sed 's/^> *//g; s/^\[!quote\].*//g; s/^>//g')
NOTE_WORDS=$(echo "$CLEAN_CONTENT" | wc -w | tr -d ' ')
NOTE_LINES=$(echo "$CLEAN_CONTENT" | wc -l | tr -d ' ')

echo "Source: ${SOURCE_WORDS} words / ${SOURCE_LINES} lines"
echo "Note:   ${NOTE_WORDS} words / ${NOTE_LINES} lines"

# Calculate ratio
if [[ "$SOURCE_WORDS" -eq 0 ]]; then
    echo "WARNING: Source file is empty"
    exit 1
fi

RATIO=$(awk "BEGIN { printf \"%.0f\", ($NOTE_WORDS / $SOURCE_WORDS) * 100 }")
echo "Coverage: ${RATIO}%"

if [[ "$RATIO" -lt 80 ]]; then
    echo "FAIL: Original Content section has <80% of source words. Content was likely summarized or truncated."
    exit 1
elif [[ "$RATIO" -lt 90 ]]; then
    echo "WARNING: Original Content section has <90% of source words. Some content may be missing."
    exit 0
else
    echo "OK: Content coverage looks good."
    exit 0
fi
