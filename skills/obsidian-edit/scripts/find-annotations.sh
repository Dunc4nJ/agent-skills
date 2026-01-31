#!/usr/bin/env bash
set -euo pipefail

VAULT="$HOME/obsidian-vault"

rg '\{[^}]+\}' --type md -l "$VAULT" \
  -g '!.obsidian/*' \
  -g '!Templates/*' \
  -g '!.claude/*' \
  2>/dev/null || echo "No annotations found"
