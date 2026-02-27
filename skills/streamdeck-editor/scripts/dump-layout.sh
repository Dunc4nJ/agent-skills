#!/usr/bin/env bash
# Generate LAYOUT.md from a .streamDeckProfile file
# Usage: bash dump-layout.sh [profile-path] [output-path]
set -uo pipefail

PROFILE="${1:-/data/projects/streamdeck/vibecoding_profile.streamDeckProfile}"
OUTPUT="${2:-/data/projects/streamdeck/LAYOUT.md}"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

cp "$PROFILE" "$TMPDIR/archive.zip"
cd "$TMPDIR"
unzip -q archive.zip

# Find the main page manifest (largest one with most actions)
MANIFEST=$(find . -path '*/Profiles/*/manifest.json' -exec wc -c {} + | sort -rn | head -2 | tail -1 | awk '{print $2}')

python3 << PYEOF
import json

with open("$MANIFEST") as f:
    d = json.load(f)
actions = d.get("Controllers", [{}])[0].get("Actions") or {}

lines = ["# Stream Deck XL — Button Layout & Prompts\n"]
lines.append("8 rows × 4 columns. Position format: \`row,col\` (0,0 = top-left)\n")

for row in range(8):
    lines.append(f"---\n\n## Row {row}\n")
    for col in range(4):
        key = f"{row},{col}"
        btn = actions.get(key)
        if not btn:
            lines.append(f"### [{key}] — EMPTY\n")
            continue
        title = btn.get("States", [{}])[0].get("Title", "").strip() or "(no title)"
        plugin = btn.get("Plugin", {}).get("Name", "?")
        prompt = btn.get("Settings", {}).get("pastedText", "").strip()

        if "hotkey" in plugin.lower():
            lines.append(f"### [{key}] {title} — ⌨️ Hotkey\n")
        else:
            lines.append(f"### [{key}] {title}\n")
            if prompt:
                lines.append(f"\`\`\`\n{prompt}\n\`\`\`\n")

with open("$OUTPUT", "w") as f:
    f.write("\n".join(lines))
print(f"✅ Layout written to $OUTPUT")
PYEOF
