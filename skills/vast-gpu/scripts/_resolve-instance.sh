#!/usr/bin/env bash
# _resolve-instance.sh — Find the best running Vast.ai instance
# Source this file; it exports VAST_INSTANCE_ID, VAST_STATUS, VAST_SSH_HOST, VAST_SSH_PORT
# Returns empty VAST_INSTANCE_ID if no instances exist (caller should create one)

set -euo pipefail

_resolve_output=$(vastai show instances --raw 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
if not data:
    print('|||')
    sys.exit(0)
# Prefer running > exited, then highest ID (newest)
running = sorted([x for x in data if x.get('actual_status') == 'running'], key=lambda x: x['id'], reverse=True)
exited = sorted([x for x in data if x.get('actual_status') == 'exited'], key=lambda x: x['id'], reverse=True)
best = (running + exited + data)[0]
ssh_host = best.get('ssh_host', '')
ssh_port = best.get('ssh_port', '')
status = best.get('actual_status', 'unknown')
print(f\"{best['id']}|{status}|{ssh_host}|{ssh_port}\")
" 2>/dev/null || echo "|||")

export VAST_INSTANCE_ID=$(echo "$_resolve_output" | cut -d'|' -f1)
export VAST_STATUS=$(echo "$_resolve_output" | cut -d'|' -f2)
export VAST_SSH_HOST=$(echo "$_resolve_output" | cut -d'|' -f3)
export VAST_SSH_PORT=$(echo "$_resolve_output" | cut -d'|' -f4)
