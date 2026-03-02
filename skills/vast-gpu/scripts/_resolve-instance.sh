#!/usr/bin/env bash
# _resolve-instance.sh — Shared helper to dynamically resolve the best Vast.ai instance
# Source this from other scripts: source "$(dirname "$0")/_resolve-instance.sh"

_resolve_output=$(vastai show instances --raw 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
if not data:
    print('NONE')
    sys.exit(0)

# Sort: running first, then exited, then others; within same status prefer highest ID
priority = {'running': 0, 'exited': 1, 'loading': 2}
data.sort(key=lambda x: (priority.get(x.get('actual_status',''), 99), -x.get('id', 0)))
i = data[0]
status = i.get('actual_status', 'unknown')
print(f\"{i['id']} {status} {i.get('ssh_host', 'N/A')} {i.get('ssh_port', 'N/A')}\")
" 2>/dev/null)

if [ "$_resolve_output" = "NONE" ] || [ -z "$_resolve_output" ]; then
    echo "No Vast.ai instances found."
    echo "Create one with:"
    echo "  vastai search offers 'gpu_name=RTX_3090 num_gpus=1 reliability>0.95 dph<0.20' -o 'dph' --limit 5"
    echo "  vastai create instance <offer_id> --image pytorch/pytorch:2.1.0-cuda12.1-cudnn8-devel --disk 50 --ssh"
    exit 1
fi

export VAST_INSTANCE_ID=$(echo "$_resolve_output" | cut -d' ' -f1)
export VAST_STATUS=$(echo "$_resolve_output" | cut -d' ' -f2)
export VAST_SSH_HOST=$(echo "$_resolve_output" | cut -d' ' -f3)
export VAST_SSH_PORT=$(echo "$_resolve_output" | cut -d' ' -f4)
unset _resolve_output
