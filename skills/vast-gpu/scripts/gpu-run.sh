#!/usr/bin/env bash
# gpu-run — Run an arbitrary command on the Vast.ai GPU instance
set -euo pipefail

source "$(dirname "$0")/_resolve-instance.sh"

if [ $# -eq 0 ]; then
    echo "Usage: gpu-run <command>"
    echo ""
    echo "Run any command on the Vast.ai GPU instance."
    echo "Examples:"
    echo "  gpu-run 'nvidia-smi'"
    echo "  gpu-run 'pip install sentence-transformers'"
    echo "  gpu-run 'python3 script.py'"
    exit 1
fi

if [ "$VAST_STATUS" != "running" ]; then
    echo "Error: Instance $VAST_INSTANCE_ID is $VAST_STATUS. Run 'gpu-start' first."
    exit 1
fi

exec ssh -o StrictHostKeyChecking=no -p "$VAST_SSH_PORT" "root@$VAST_SSH_HOST" "$@"
