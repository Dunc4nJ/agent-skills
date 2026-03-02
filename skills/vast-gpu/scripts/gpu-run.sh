#!/usr/bin/env bash
# gpu-run — Run a command on the GPU instance via SSH
# Usage: gpu-run 'pip install something'
set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: gpu-run 'command'"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_resolve-instance.sh"

if [ -z "$VAST_INSTANCE_ID" ] || [ "$VAST_STATUS" != "running" ]; then
    echo "No running GPU instance. Run 'gpu-start' first."
    exit 1
fi

exec ssh -o StrictHostKeyChecking=no -p "$VAST_SSH_PORT" "root@$VAST_SSH_HOST" "$@"
