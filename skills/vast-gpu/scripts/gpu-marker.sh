#!/usr/bin/env bash
# gpu-marker — Convert PDF to markdown using marker-pdf on GPU
# Usage: gpu-marker input.pdf [output-dir]
set -euo pipefail

INSTANCE_ID=32135400

if [ $# -lt 1 ]; then
    echo "Usage: gpu-marker <input.pdf> [output-dir]"
    echo ""
    echo "Converts a PDF to markdown using marker-pdf on the Vast.ai GPU."
    echo "Output includes markdown file and extracted images."
    exit 1
fi

INPUT_PDF="$1"
OUTPUT_DIR="${2:-.}"

if [ ! -f "$INPUT_PDF" ]; then
    echo "Error: File not found: $INPUT_PDF"
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

SSH_CMD="ssh -o StrictHostKeyChecking=no -p $ssh_port root@$ssh_host"
SCP_CMD="scp -o StrictHostKeyChecking=no -P $ssh_port"

BASENAME=$(basename "$INPUT_PDF" .pdf)
REMOTE_DIR="/tmp/marker-jobs/$$"

echo "Uploading $INPUT_PDF to GPU..."
$SSH_CMD "mkdir -p $REMOTE_DIR" 2>/dev/null
$SCP_CMD "$INPUT_PDF" "root@$ssh_host:$REMOTE_DIR/" 2>/dev/null

echo "Running marker-pdf on GPU (this may take a few minutes)..."
$SSH_CMD "marker_single '$REMOTE_DIR/$(basename "$INPUT_PDF")' --output_dir '$REMOTE_DIR/output' --output_format markdown" 2>&1 | \
    grep -E '(Recognizing|Detecting|Running|Saved|Total time|Downloading)' || true

# Find output directory (marker creates a subdirectory named after the file)
REMOTE_OUTPUT=$($SSH_CMD "ls -d $REMOTE_DIR/output/*/ 2>/dev/null | head -1" 2>/dev/null || echo "")

if [ -z "$REMOTE_OUTPUT" ]; then
    # Try without subdirectory
    REMOTE_OUTPUT="$REMOTE_DIR/output/"
fi

echo "Downloading results..."
mkdir -p "$OUTPUT_DIR/$BASENAME"
$SCP_CMD -r "root@$ssh_host:${REMOTE_OUTPUT%/}/*" "$OUTPUT_DIR/$BASENAME/" 2>/dev/null

# Clean up remote
$SSH_CMD "rm -rf $REMOTE_DIR" 2>/dev/null &

# Count output files
md_file=$(find "$OUTPUT_DIR/$BASENAME" -name "*.md" -type f | head -1)
img_count=$(find "$OUTPUT_DIR/$BASENAME" -name "*.jpeg" -o -name "*.png" -type f 2>/dev/null | wc -l)

echo ""
echo "Done!"
echo "  Markdown: $md_file"
echo "  Images:   $img_count extracted"
echo "  Output:   $OUTPUT_DIR/$BASENAME/"
