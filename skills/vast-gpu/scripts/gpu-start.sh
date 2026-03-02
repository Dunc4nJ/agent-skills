#!/usr/bin/env bash
# gpu-start — Find or create a Vast.ai GPU instance, wait for SSH
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_resolve-instance.sh"

MAX_WAIT=180

# If we have a running instance, just report it
if [ -n "$VAST_INSTANCE_ID" ] && [ "$VAST_STATUS" = "running" ]; then
    echo "Instance $VAST_INSTANCE_ID is already running."
    echo "SSH: ssh -o StrictHostKeyChecking=no -p $VAST_SSH_PORT root@$VAST_SSH_HOST"
    exit 0
fi

# If we have an exited instance, try to start it
if [ -n "$VAST_INSTANCE_ID" ] && [ "$VAST_STATUS" = "exited" ]; then
    echo "Starting existing instance $VAST_INSTANCE_ID..."
    vastai start instance "$VAST_INSTANCE_ID" 2>/dev/null
    
    # Wait for SSH
    elapsed=0
    while [ $elapsed -lt $MAX_WAIT ]; do
        source "$SCRIPT_DIR/_resolve-instance.sh"
        if [ "$VAST_STATUS" = "running" ] && [ -n "$VAST_SSH_HOST" ]; then
            if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p "$VAST_SSH_PORT" "root@$VAST_SSH_HOST" 'echo ok' &>/dev/null; then
                echo "Instance $VAST_INSTANCE_ID is running."
                echo "SSH: ssh -o StrictHostKeyChecking=no -p $VAST_SSH_PORT root@$VAST_SSH_HOST"
                exit 0
            fi
        fi
        sleep 5
        elapsed=$((elapsed + 5))
        echo "Waiting for SSH... (${elapsed}s / ${MAX_WAIT}s)"
    done
    
    echo "Warning: Existing instance $VAST_INSTANCE_ID failed to start. Searching for a new GPU..."
    vastai destroy instance "$VAST_INSTANCE_ID" 2>/dev/null || true
fi

# No instance available — search and create
echo "Searching for available GPUs..."
OFFER_ID=$(vastai search offers 'gpu_name=RTX_3090 num_gpus=1 reliability>0.90 dph<0.25 inet_down>100' -o 'dph' --raw 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data:
    print(data[0]['id'])
else:
    print('')
" 2>/dev/null)

if [ -z "$OFFER_ID" ]; then
    # Broaden search to any good GPU
    echo "No RTX 3090 available, searching broader..."
    OFFER_ID=$(vastai search offers 'gpu_ram>=20 num_gpus=1 reliability>0.90 dph<0.35 inet_down>100' -o 'dph' --raw 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data:
    print(data[0]['id'])
else:
    print('')
" 2>/dev/null)
fi

if [ -z "$OFFER_ID" ]; then
    echo "ERROR: No suitable GPU offers found. Try again later or adjust search criteria."
    exit 1
fi

echo "Creating instance from offer $OFFER_ID..."
CREATE_OUTPUT=$(vastai create instance "$OFFER_ID" --image pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel --disk 50 --ssh --direct 2>&1)
echo "$CREATE_OUTPUT"

# Extract new instance ID
NEW_ID=$(echo "$CREATE_OUTPUT" | grep -oP 'new contract is \K[0-9]+' || echo "")
if [ -z "$NEW_ID" ]; then
    NEW_ID=$(echo "$CREATE_OUTPUT" | grep -oP '[0-9]+' | tail -1)
fi

if [ -z "$NEW_ID" ]; then
    echo "ERROR: Could not determine new instance ID from: $CREATE_OUTPUT"
    exit 1
fi

echo "Instance $NEW_ID created. Waiting for SSH..."

# Wait for SSH
elapsed=0
while [ $elapsed -lt $MAX_WAIT ]; do
    source "$SCRIPT_DIR/_resolve-instance.sh"
    if [ "$VAST_STATUS" = "running" ] && [ -n "$VAST_SSH_HOST" ]; then
        if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p "$VAST_SSH_PORT" "root@$VAST_SSH_HOST" 'echo ok' &>/dev/null; then
            echo "Instance $VAST_INSTANCE_ID is running."
            echo "SSH: ssh -o StrictHostKeyChecking=no -p $VAST_SSH_PORT root@$VAST_SSH_HOST"
            
            # Install marker-pdf on fresh instance
            echo "Installing marker-pdf (fresh instance)..."
            ssh -o StrictHostKeyChecking=no -p "$VAST_SSH_PORT" "root@$VAST_SSH_HOST" \
                'pip install marker-pdf 2>&1 | tail -1 && pip install --upgrade torchvision 2>&1 | tail -1 && echo "marker-pdf ready"'
            exit 0
        fi
    fi
    sleep 5
    elapsed=$((elapsed + 5))
    echo "Waiting for SSH... (${elapsed}s / ${MAX_WAIT}s)"
done

echo "ERROR: Instance created but SSH not available after ${MAX_WAIT}s."
exit 1
