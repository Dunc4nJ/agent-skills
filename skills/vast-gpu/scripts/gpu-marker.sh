#!/usr/bin/env bash
# gpu-marker — Convert PDF to markdown via GPU-accelerated marker-pdf
# Usage: gpu-marker document.pdf [output-dir]
# Self-contained: will start a GPU instance if none is running, installs marker-pdf if needed.
set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: gpu-marker <pdf-file> [output-dir]"
    exit 1
fi

PDF_PATH="$1"
OUTPUT_DIR="${2:-.}"
PDF_NAME=$(basename "$PDF_PATH" .pdf)

if [ ! -f "$PDF_PATH" ]; then
    echo "Error: File not found: $PDF_PATH"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_resolve-instance.sh"

# Auto-start if no running instance
if [ -z "$VAST_INSTANCE_ID" ] || [ "$VAST_STATUS" != "running" ]; then
    echo "No running GPU instance. Starting one..."
    "$SCRIPT_DIR/gpu-start.sh"
    # Re-resolve after start
    source "$SCRIPT_DIR/_resolve-instance.sh"
    if [ -z "$VAST_INSTANCE_ID" ] || [ "$VAST_STATUS" != "running" ]; then
        echo "ERROR: Failed to start GPU instance."
        exit 1
    fi
fi

SSH_CMD="ssh -o StrictHostKeyChecking=no -p $VAST_SSH_PORT root@$VAST_SSH_HOST"
SCP_CMD="scp -o StrictHostKeyChecking=no -P $VAST_SSH_PORT"

# Check if marker-pdf is installed, install if not
if ! $SSH_CMD 'command -v marker_single' &>/dev/null; then
    echo "Installing marker-pdf..."
    $SSH_CMD 'pip install marker-pdf 2>&1 | tail -1 && pip install --upgrade torchvision 2>&1 | tail -1'
fi

# Push cached models if available locally and not yet on GPU
LOCAL_MODEL_CACHE="$HOME/.cache/datalab"
if [ -d "$LOCAL_MODEL_CACHE/models" ]; then
    REMOTE_CACHE_SIZE=$($SSH_CMD 'du -sb /root/.cache/datalab/models 2>/dev/null | cut -f1' 2>/dev/null || echo "0")
    LOCAL_CACHE_SIZE=$(du -sb "$LOCAL_MODEL_CACHE/models" | cut -f1)
    # Push if remote cache is less than 80% of local (i.e. missing/incomplete)
    if [ "${REMOTE_CACHE_SIZE:-0}" -lt $((LOCAL_CACHE_SIZE * 80 / 100)) ]; then
        echo "Pushing cached models to GPU (~$(du -sh "$LOCAL_MODEL_CACHE/models" | cut -f1))..."
        $SSH_CMD 'mkdir -p /root/.cache/datalab'
        rsync -az --info=progress2 -e "ssh -o StrictHostKeyChecking=no -p $VAST_SSH_PORT" \
            "$LOCAL_MODEL_CACHE/models/" "root@$VAST_SSH_HOST:/root/.cache/datalab/models/"
        echo "Model cache pushed."
    fi
fi

# Upload PDF
echo "Uploading $PDF_PATH..."
$SCP_CMD "$PDF_PATH" "root@$VAST_SSH_HOST:/tmp/$PDF_NAME.pdf"

# Run marker
echo "Running marker-pdf on GPU..."
$SSH_CMD "mkdir -p /tmp/marker-output && marker_single /tmp/$PDF_NAME.pdf --output_dir /tmp/marker-output" 2>&1

# Download results
mkdir -p "$OUTPUT_DIR"
echo "Downloading results..."

# Find the output directory (marker creates a subdirectory)
REMOTE_OUT=$($SSH_CMD "ls -d /tmp/marker-output/$PDF_NAME/ 2>/dev/null || ls -d /tmp/marker-output/*/ 2>/dev/null | head -1" 2>/dev/null)

if [ -z "$REMOTE_OUT" ]; then
    echo "ERROR: No marker output found on GPU."
    exit 1
fi

$SCP_CMD -r "root@$VAST_SSH_HOST:$REMOTE_OUT" "$OUTPUT_DIR/"
echo "Done. Output in: $OUTPUT_DIR/$PDF_NAME/"

# List output files
ls -la "$OUTPUT_DIR/$PDF_NAME/" 2>/dev/null || ls -la "$OUTPUT_DIR/" 2>/dev/null
