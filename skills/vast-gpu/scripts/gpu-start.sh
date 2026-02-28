#!/usr/bin/env bash
# gpu-start — Start the Vast.ai GPU instance and wait for SSH
set -euo pipefail

INSTANCE_ID=32143253
MAX_WAIT=180  # seconds

# Check current status
status=$(vastai show instances --raw 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
inst = [x for x in data if x.get('id') == $INSTANCE_ID]
print(inst[0].get('actual_status', 'unknown') if inst else 'not_found')
" 2>/dev/null || echo "error")

if [ "$status" = "running" ]; then
    echo "Instance $INSTANCE_ID is already running."
    # Print SSH info
    vastai show instances --raw 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
inst = [x for x in data if x.get('id') == $INSTANCE_ID][0]
print(f\"SSH: ssh -p {inst.get('ssh_port', 'N/A')} root@{inst.get('ssh_host', 'N/A')}\")
print(f\"GPU: {inst.get('gpu_name', 'N/A')}\")
" 2>/dev/null
    exit 0
fi

if [ "$status" = "not_found" ]; then
    echo "Error: Instance $INSTANCE_ID not found. It may have been destroyed."
    echo "Search for a new instance: vastai search offers 'gpu_name=RTX_3090 num_gpus=1 reliability>0.95 dph<0.50' -o 'dph' --limit 10"
    exit 1
fi

echo "Starting instance $INSTANCE_ID..."
vastai start instance "$INSTANCE_ID" 2>&1

echo "Waiting for instance to boot..."
elapsed=0
while [ "$elapsed" -lt "$MAX_WAIT" ]; do
    status=$(vastai show instances --raw 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
inst = [x for x in data if x.get('id') == $INSTANCE_ID]
print(inst[0].get('actual_status', 'unknown') if inst else 'not_found')
" 2>/dev/null || echo "error")

    if [ "$status" = "running" ]; then
        echo "Instance is running. Waiting for SSH..."
        break
    fi
    sleep 10
    elapsed=$((elapsed + 10))
    echo "  Status: $status ($elapsed/${MAX_WAIT}s)"
done

if [ "$status" != "running" ]; then
    echo "Error: Instance did not start within ${MAX_WAIT}s. Status: $status"
    exit 1
fi

# Get SSH details
ssh_info=$(vastai show instances --raw 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
inst = [x for x in data if x.get('id') == $INSTANCE_ID][0]
print(f\"{inst.get('ssh_host', '')} {inst.get('ssh_port', '')}\")
" 2>/dev/null)
ssh_host=$(echo "$ssh_info" | cut -d' ' -f1)
ssh_port=$(echo "$ssh_info" | cut -d' ' -f2)

# Wait for SSH
ssh_elapsed=0
while [ "$ssh_elapsed" -lt 120 ]; do
    if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p "$ssh_port" "root@$ssh_host" 'echo ok' &>/dev/null; then
        echo ""
        echo "GPU instance ready!"
        echo "  SSH: ssh -p $ssh_port root@$ssh_host"
        # Show GPU info
        ssh -o StrictHostKeyChecking=no -p "$ssh_port" "root@$ssh_host" 'nvidia-smi --query-gpu=name,memory.total --format=csv,noheader' 2>/dev/null || true
        exit 0
    fi
    sleep 10
    ssh_elapsed=$((ssh_elapsed + 10))
    echo "  Waiting for SSH... ($ssh_elapsed/120s)"
done

echo "Error: SSH not available after 120s. Instance is running but SSH may still be starting."
echo "Try manually: ssh -p $ssh_port root@$ssh_host"
exit 1
