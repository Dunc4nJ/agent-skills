#!/usr/bin/env bash
# gpu-status — Show Vast.ai GPU instance status
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_resolve-instance.sh"

if [ -z "$VAST_INSTANCE_ID" ]; then
    echo "No Vast.ai instances found."
    echo "Run 'gpu-start' to search for and create a new GPU instance."
    exit 0
fi

vastai show instances --raw 2>/dev/null | python3 -c "
import sys, json

data = json.load(sys.stdin)
inst = [x for x in data if x.get('id') == $VAST_INSTANCE_ID]

if not inst:
    print('Instance $VAST_INSTANCE_ID not found.')
    sys.exit(1)

i = inst[0]
status = i.get('actual_status', 'unknown')
gpu = i.get('gpu_name', 'N/A')
gpu_ram = i.get('gpu_ram', 0)
dph = i.get('dph_total', 0)
disk_used = i.get('disk_util', 0)
disk_total = i.get('disk_space', 0)

print(f'Instance:  {i[\"id\"]}')
print(f'Status:    {status}')
print(f'GPU:       {gpu} ({int(gpu_ram)} MB VRAM)')
print(f'Cost:      \${dph:.4f}/hr')
print(f'Disk:      {disk_used}/{int(disk_total)} GB')

if status == 'running':
    ssh_host = i.get('ssh_host', '')
    ssh_port = i.get('ssh_port', '')
    if ssh_host and ssh_port:
        print(f'SSH:       ssh -p {ssh_port} root@{ssh_host}')
"
