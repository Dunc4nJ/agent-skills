#!/usr/bin/env bash
# gpu-ssh — SSH into the Vast.ai GPU instance
set -euo pipefail

source "$(dirname "$0")/_resolve-instance.sh"

if [ "$VAST_STATUS" != "running" ]; then
    echo "Error: Instance $VAST_INSTANCE_ID is $VAST_STATUS. Run 'gpu-start' first."
    exit 1
fi

if [ $# -eq 0 ]; then
    exec ssh -o StrictHostKeyChecking=no -p "$VAST_SSH_PORT" "root@$VAST_SSH_HOST"
else
    exec ssh -o StrictHostKeyChecking=no -p "$VAST_SSH_PORT" "root@$VAST_SSH_HOST" "$@"
fi
