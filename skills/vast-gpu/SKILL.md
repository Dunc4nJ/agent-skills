---
name: vast-gpu
description: "Cloud GPU access via Vast.ai for marker-pdf, embeddings, and ML workloads. Convenience scripts for instance management (start, stop, status, SSH) and PDF-to-markdown conversion. Use when the user says 'run on gpu', 'use gpu', 'marker-pdf', 'convert pdf', 'gpu status', 'start gpu', 'stop gpu', 'vast', or needs GPU acceleration from this CPU-only VPS."
---

# Vast.ai Cloud GPU

On-demand cloud GPU from Vast.ai marketplace. Instances are **ephemeral** — created when needed, destroyed after use. No persistent instances, no idle storage costs.

`gpu-marker` is fully self-contained: if no GPU is running, it searches for one, creates an instance, installs marker-pdf, processes the PDF, and returns results. For batch work (multiple PDFs), call `gpu-start` first to avoid repeated setup, then `gpu-stop` when done.

## Quick Reference

```bash
# Self-contained PDF conversion (handles everything automatically)
gpu-marker paper.pdf             # Find/create GPU, install marker, convert, return results
gpu-marker paper.pdf ./output    # Specify output directory

# Explicit instance management (for batch work)
gpu-start                        # Search marketplace, create instance, install marker
gpu-stop                         # DESTROY instance (default — no ongoing cost)
gpu-stop --pause                 # Stop only (preserves disk, pays storage)
gpu-status                       # Show current instance status
gpu-ssh                          # Interactive SSH session
gpu-ssh 'nvidia-smi'             # Run single command
gpu-run 'pip install something'  # Run arbitrary commands
```

All scripts live at `~/.agent/skills/vast-gpu/scripts/` and are symlinked to `~/.local/bin/`.

## Architecture

```
VPS (CPU-only)                    Vast.ai (GPU)
+-----------------+    SSH     +----------------------+
| ubuntu@vps      | --------> | root@sshN.vast.ai    |
| gpu-marker      |  auto     | RTX 3090+ (24 GB)    |
| gpu-start/stop  |  resolved | PyTorch + CUDA       |
| vastai CLI      |           | marker-pdf           |
+-----------------+           | surya-ocr            |
                              +----------------------+
```
Instance ID, SSH host, and port are resolved dynamically by `_resolve-instance.sh`.

## Instance Management

### Start

```bash
gpu-start
# Starts instance, waits for SSH (up to 3 min), prints status
```

Cold start takes 30-60 seconds. SSH becomes available 10-30 seconds after that.

### Stop (destroy by default)

```bash
gpu-stop              # Destroy instance — no ongoing cost
gpu-stop --pause      # Stop only — preserves disk, pays ~$0.03/GB/mo storage
```

**Default is destroy.** Instances are ephemeral — `gpu-start` creates a fresh one in ~1-2 minutes. Use `--pause` only during multi-session batch work where you want to preserve cached models between runs.

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
| **Running** | ~$0.11-0.20/hr | Everything |
| **Stopped** (`--pause`) | ~$0.03/GB/mo (50 GB = ~$1.50/mo) | Disk, installed packages, cached models |
| **Destroyed** (default) | $0 | Nothing — `gpu-start` creates fresh next time |

Rules:
- Default to destroy after every use (`gpu-stop`)
- `gpu-marker` is self-contained — just call it, it handles the rest
- For batch work: `gpu-start` → multiple `gpu-marker` calls → `gpu-stop`

### Check spending

```bash
vastai show invoices
```

## Changing Instance / Instance Gone

Scripts auto-resolve the best instance — no hardcoded IDs to update. If your instance was destroyed or you want a different GPU:

```bash
# Search for alternatives
vastai search offers 'gpu_name=RTX_3090 num_gpus=1 reliability>0.95 dph<0.20' -o 'dph' --limit 10

# Create new instance (scripts will auto-detect it)
vastai create instance <OFFER_ID> --image pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel --disk 50 --ssh --direct

# Verify scripts pick it up
gpu-status
```

No need to edit any scripts — `_resolve-instance.sh` finds the newest running or exited instance automatically.

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

**Instance destroyed / need to recreate** — Scripts will report "No instances found." Search for a new offer, create one, and scripts auto-detect it:
```bash
vastai search offers 'gpu_name=RTX_3090 num_gpus=1 reliability>0.95 dph<0.20' -o 'dph' --limit 5
vastai create instance <OFFER_ID> --image pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel --disk 50 --ssh --direct
gpu-status  # Should now find the new instance
gpu-ssh 'pip install marker-pdf && pip install --upgrade torchvision'
```

**Slow network transfer** — Use rsync with compression for large files:
```bash
rsync -avzP -e 'ssh -p 15400' large-file.pdf root@ssh3.vast.ai:/tmp/
```
