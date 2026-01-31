#!/usr/bin/env bash
set -euo pipefail

VAULT="/data/projects/obsidian-vault"

# Optional path argument — scope to subdirectory
if [[ -n "${1:-}" ]]; then
  # Resolve relative paths against vault root
  if [[ "$1" = /* ]]; then
    TARGET="$1"
  else
    TARGET="$VAULT/$1"
  fi
else
  TARGET="$VAULT"
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Error: $TARGET is not a directory" >&2
  exit 1
fi

echo "# Vault Structure"
echo ""
tree -L 3 -a -I '.git|.obsidian|.ntm|.vscode|.claude' --noreport "$TARGET"

echo ""
echo "# Note Descriptions"
echo ""
rg "^description:" "$TARGET" --type md --no-heading --with-filename -m 1 \
  | sed "s|^$VAULT/||" \
  | sed 's/:description: /: /' \
  | sort
