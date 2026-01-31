#!/usr/bin/env bash
set -euo pipefail

# Classify a URL as "twitter" or "web"
# Usage: detect-url-type.sh <url>
# Output: "twitter" or "web" (single word to stdout)

URL="${1:-}"

if [[ -z "$URL" ]]; then
  echo "Usage: detect-url-type.sh <url>" >&2
  exit 1
fi

# Strip protocol and www prefix
NORMALIZED=$(echo "$URL" | sed -E 's|^https?://||; s|^www\.||')

# Match Twitter/X domains
if [[ "$NORMALIZED" =~ ^(x\.com|twitter\.com)/ ]]; then
  echo "twitter"
else
  echo "web"
fi
