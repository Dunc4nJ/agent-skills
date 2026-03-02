#!/usr/bin/env bash
# gpu-ssh — SSH into the Vast.ai GPU instance
# Usage: gpu-ssh              (interactive shell)
#        gpu-ssh 'command'    (run single command)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_resolve-instance.sh"

if [ -z "$VAST_INSTANCE_ID" ] || [ "$VAST_STATUS" != "running" ]; then
    echo "No running GPU instance. Run 'gpu-start' first."
    exit 1
fi

if [ -z "$VAST_SSH_HOST" ] || [ -z "$VAST_SSH_PORT" ]; then
    echo "Instance $VAST_INSTANCE_ID is $VAST_STATUS but SSH details not available."
    exit 1
fi

if [ $# -eq 0 ]; then
    exec ssh -o StrictHostKeyChecking=no -p "$VAST_SSH_PORT" "root@$VAST_SSH_HOST"
else
    exec ssh -o StrictHostKeyChecking=no -p "$VAST_SSH_PORT" "root@$VAST_SSH_HOST" "$@"
fi
