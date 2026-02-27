---
name: vast-gpu
description: "Cloud GPU access via Vast.ai for marker-pdf, embeddings, and ML workloads. Convenience scripts for instance management (start, stop, status, SSH) and PDF-to-markdown conversion. Use when the user says 'run on gpu', 'use gpu', 'marker-pdf', 'convert pdf', 'gpu status', 'start gpu', 'stop gpu', 'vast', or needs GPU acceleration from this CPU-only VPS."
---

# Vast.ai Cloud GPU

RTX 3090 (24 GB VRAM) accessible from this CPU-only VPS via SSH. Instance ID: `32135400`. Cost: ~$0.11/hr running, ~$0.03/GB/mo storage when stopped.

## Quick Reference

```bash
# Instance management
gpu-start                        # Start instance, wait for SSH
gpu-stop                         # Stop instance (preserves disk)
gpu-status                       # Show status, uptime, cost
gpu-ssh                          # Interactive SSH session
gpu-ssh 'nvidia-smi'             # Run single command

# PDF conversion
gpu-marker paper.pdf             # Convert PDF to markdown via GPU
gpu-marker paper.pdf ./output    # Specify output directory

# Arbitrary commands
gpu-run 'pip install something'  # Install packages
gpu-run 'python3 script.py'      # Run scripts
```

All scripts live at `~/.agent/skills/vast-gpu/scripts/` and are symlinked to `~/.local/bin/`.

## Architecture

```
VPS (CPU-only)                    Vast.ai (GPU)
+-----------------+    SSH     +----------------------+
| ubuntu@vps      | --------> | root@ssh3.vast.ai    |
| gpu-marker      |  port     | RTX 3090 (24 GB)     |
| gpu-start/stop  |  15400    | PyTorch 2.10 + CUDA  |
| vastai CLI      |           | marker-pdf 1.10.2    |
+-----------------+           | surya-ocr 0.17.1     |
                              +----------------------+
```

## Instance Management

### Start

```bash
gpu-start
# Starts instance, waits for SSH (up to 3 min), prints status
```

Cold start takes 30-60 seconds. SSH becomes available 10-30 seconds after that.

### Stop (save money)

```bash
gpu-stop
# Stops instance, preserves disk state
# Only pays storage (~$0.03/GB/mo) while stopped
```

Always stop when not actively using GPU. At $0.11/hr, leaving it running overnight costs ~$1.

### Status

```bash
gpu-status
# Shows: status, GPU, uptime, hourly cost, SSH command
```

### SSH

```bash
gpu-ssh                          # Interactive shell
gpu-ssh 'nvidia-smi'             # Single command
gpu-ssh 'pip list | grep torch'  # Pipe-friendly
```

## Running marker-pdf

Convert any PDF to clean markdown with GPU-accelerated OCR:

```bash
gpu-marker document.pdf              # Output to ./document/
gpu-marker document.pdf ./my-output  # Custom output dir
```

What happens:
1. Uploads PDF to GPU box via SCP
2. Runs `marker_single` with GPU acceleration
3. Downloads markdown + extracted images back to VPS
4. Prints output location

First run after instance restart downloads OCR models (~2 GB, takes ~8 min). Subsequent runs process at ~2-3 pages/second.

### Batch conversion

```bash
for pdf in *.pdf; do
  gpu-marker "$pdf" ./converted/
done
```

### Output structure

```
output-dir/
├── document.md              # Markdown with inline image refs
├── document_meta.json       # Metadata (page count, timing)
├── _page_0_Picture_1.jpeg   # Extracted figures
└── _page_5_Figure_1.jpeg
```

## Installing Additional Tools

SSH in and install anything:

```bash
gpu-ssh 'pip install sentence-transformers'
gpu-ssh 'pip install vllm'
gpu-ssh 'apt-get update && apt-get install -y ffmpeg'
```

Installations persist as long as the instance is not **destroyed** (only stopped). Stopping preserves disk; destroying deletes everything.

## Running Embeddings

Example: run a HuggingFace TEI embedding server on the GPU box:

```bash
gpu-ssh 'pip install text-embeddings-inference'
# Or use the Docker image:
gpu-ssh 'docker run --gpus all -p 8080:80 ghcr.io/huggingface/text-embeddings-inference:cuda-1.9 --model-id BAAI/bge-base-en-v1.5'
```

Then from VPS, forward the port:
```bash
ssh -L 8080:localhost:8080 -p 15400 root@ssh3.vast.ai
# Now localhost:8080 serves embeddings
```

## Cost Management

| State | Cost | What persists |
|-------|------|---------------|
| **Running** | ~$0.11/hr | Everything |
| **Stopped** | ~$0.03/GB/mo (50 GB = ~$1.50/mo) | Disk, installed packages, cached models |
| **Destroyed** | $0 | Nothing (must re-create and re-install) |

Rules:
- Stop after every use session
- Never destroy unless you want to switch GPUs or regions
- Check `gpu-status` before starting work to avoid surprise charges

### Check spending

```bash
vastai show invoices
```

## Changing Instance

To switch to a different GPU or cheaper instance:

```bash
# Search for alternatives
vastai search offers 'gpu_name=RTX_4090 num_gpus=1 reliability>0.95 dph<0.50' -o 'dph' --limit 10

# Create new instance (update instance ID in scripts afterward)
vastai create instance <OFFER_ID> --image pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel --disk 50 --ssh --direct

# Update scripts
sed -i 's/INSTANCE_ID=.*/INSTANCE_ID=<NEW_ID>/' ~/.agent/skills/vast-gpu/scripts/gpu-*.sh
```

After creating a new instance, re-install marker-pdf:
```bash
gpu-ssh 'pip install marker-pdf && pip install --upgrade torchvision'
```

## Troubleshooting

**"Connection refused" on SSH** — Instance is stopped. Run `gpu-start`.

**"Model downloading" on first marker-pdf run** — Normal. Surya OCR models (~2 GB) download on first use after instance creation. Takes ~8 min. Cached afterward.

**torchvision errors** — If marker-pdf fails with `torchvision::nms` error, the base Docker image's torchvision is outdated:
```bash
gpu-ssh 'pip install --upgrade torchvision'
```

**Instance destroyed / need to recreate** — Search for a new offer, create instance, reinstall:
```bash
gpu-ssh 'pip install marker-pdf && pip install --upgrade torchvision'
```

**Slow network transfer** — Use rsync with compression for large files:
```bash
rsync -avzP -e 'ssh -p 15400' large-file.pdf root@ssh3.vast.ai:/tmp/
```
