#!/usr/bin/env bash
# gpu-status — Show Vast.ai GPU instance status
set -euo pipefail

source "$(dirname "$0")/_resolve-instance.sh"

vastai show instances --raw 2>/dev/null | python3 -c "
import sys, json, time

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
disk = i.get('disk_space', 0)
disk_used = i.get('disk_util', 0)
ssh_host = i.get('ssh_host', 'N/A')
ssh_port = i.get('ssh_port', 'N/A')

start_date = i.get('start_date', 0) or 0
if start_date and status == 'running':
    uptime = time.time() - start_date
else:
    uptime = 0

hours = uptime / 3600
if hours < 1:
    uptime_str = f'{uptime/60:.0f} min'
elif hours < 24:
    uptime_str = f'{hours:.1f} hours'
else:
    uptime_str = f'{hours/24:.1f} days'

session_cost = dph * hours if status == 'running' else 0

print(f'Instance:  {$VAST_INSTANCE_ID}')
print(f'Status:    {status}')
print(f'GPU:       {gpu} ({gpu_ram:.0f} MB VRAM)')
print(f'Cost:      \${dph:.4f}/hr')
if status == 'running':
    print(f'Uptime:    {uptime_str}')
    print(f'Session:   ~\${session_cost:.2f} so far')
    print(f'SSH:       ssh -p {ssh_port} root@{ssh_host}')
print(f'Disk:      {disk_used:.0f}/{disk:.0f} GB')
" 2>/dev/null
