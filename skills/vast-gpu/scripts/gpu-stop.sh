#!/usr/bin/env bash
# gpu-stop — Stop the Vast.ai GPU instance (preserves disk)
set -euo pipefail

source "$(dirname "$0")/_resolve-instance.sh"

if [ "$VAST_STATUS" != "running" ] && [ "$VAST_STATUS" != "loading" ]; then
    echo "Instance $VAST_INSTANCE_ID is already stopped (status: $VAST_STATUS)."
    exit 0
fi

echo "Stopping instance $VAST_INSTANCE_ID..."
vastai stop instance "$VAST_INSTANCE_ID" 2>&1

echo "Instance stopped. Disk state preserved."
echo "Storage cost: ~\$0.03/GB/month (currently 50 GB = ~\$1.50/mo)"
echo "Run 'gpu-start' to resume."
