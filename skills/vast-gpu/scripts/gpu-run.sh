#!/usr/bin/env bash
# gpu-run — Run an arbitrary command on the Vast.ai GPU instance
# Usage: gpu-run 'pip install something'
#        gpu-run 'python3 -c "import torch; print(torch.cuda.is_available())"'
set -euo pipefail

INSTANCE_ID=32135400

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

# Get SSH details
ssh_info=$(vastai show instances --raw 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
inst = [x for x in data if x.get('id') == $INSTANCE_ID]
if not inst:
    print('error not_found')
    sys.exit(0)
i = inst[0]
status = i.get('actual_status', 'unknown')
if status != 'running':
    print(f'error {status}')
    sys.exit(0)
print(f\"{i.get('ssh_host', '')} {i.get('ssh_port', '')}\")
" 2>/dev/null)

ssh_host=$(echo "$ssh_info" | cut -d' ' -f1)
ssh_port=$(echo "$ssh_info" | cut -d' ' -f2)

if [ "$ssh_host" = "error" ]; then
    echo "Error: Instance is $ssh_port. Run 'gpu-start' first."
    exit 1
fi

exec ssh -o StrictHostKeyChecking=no -p "$ssh_port" "root@$ssh_host" "$@"
