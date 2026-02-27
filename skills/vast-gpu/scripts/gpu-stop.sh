#!/usr/bin/env bash
# gpu-stop — Stop the Vast.ai GPU instance (preserves disk)
set -euo pipefail

INSTANCE_ID=32135400

status=$(vastai show instances --raw 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
inst = [x for x in data if x.get('id') == $INSTANCE_ID]
print(inst[0].get('actual_status', 'unknown') if inst else 'not_found')
" 2>/dev/null || echo "error")

if [ "$status" = "not_found" ]; then
    echo "Error: Instance $INSTANCE_ID not found."
    exit 1
fi

if [ "$status" != "running" ] && [ "$status" != "loading" ]; then
    echo "Instance $INSTANCE_ID is already stopped (status: $status)."
    exit 0
fi

echo "Stopping instance $INSTANCE_ID..."
vastai stop instance "$INSTANCE_ID" 2>&1

echo "Instance stopped. Disk state preserved."
echo "Storage cost: ~\$0.03/GB/month (currently 50 GB = ~\$1.50/mo)"
echo "Run 'gpu-start' to resume."
