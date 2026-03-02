#!/usr/bin/env bash
# gpu-stop — Destroy the Vast.ai GPU instance (default: full teardown)
# Usage: gpu-stop          (destroy — no ongoing cost)
#        gpu-stop --pause  (stop only — preserves disk, pays storage)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_resolve-instance.sh"

if [ -z "$VAST_INSTANCE_ID" ]; then
    echo "No Vast.ai instances found. Nothing to stop."
    exit 0
fi

MODE="destroy"
if [ "${1:-}" = "--pause" ]; then
    MODE="stop"
fi

if [ "$MODE" = "destroy" ]; then
    echo "Destroying instance $VAST_INSTANCE_ID..."
    vastai destroy instance "$VAST_INSTANCE_ID" 2>/dev/null
    echo "Instance $VAST_INSTANCE_ID destroyed. No ongoing cost."
else
    echo "Pausing instance $VAST_INSTANCE_ID (disk preserved, storage cost continues)..."
    vastai stop instance "$VAST_INSTANCE_ID" 2>/dev/null
    echo "Instance $VAST_INSTANCE_ID stopped. Run 'gpu-start' to resume, 'gpu-stop' to destroy."
fi
