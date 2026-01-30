# APRX Workflow Reference

Quick reference for APRX commands used in the iterate workflow.

## Status & Validation

```bash
# Check APRX configuration and Oracle status
aprx robot status
# Returns: data.configured, data.oracle_available, data.default_workflow

# Get round history and count
aprx robot history
# Returns: data.count (number of rounds), data.rounds[]

# Validate before running a round
aprx robot validate N
# Returns: data.valid, data.errors[], data.warnings[]
```

## Running Rounds

```bash
# Run round N (blocking, waits for completion)
aprx run N --force --wait

# First round with manual login (if needed)
aprx run 1 --headed --login --wait
```

**Note**: Implementation inclusion is handled automatically via `impl_every_n` in workflow YAML.

## Viewing Output

```bash
# Read round output (robot mode - JSON)
aprx robot show N
# Returns: data.content (full GPT Pro output text)

# Read round output (human-readable)
aprx show N

# Compare rounds
aprx diff N        # Compare N with N-1
aprx diff N M      # Compare N with M
```

## Analytics

```bash
# Generate/update metrics from rounds (required before stats)
aprx backfill

# Get convergence stats (JSON)
aprx robot stats
# Returns: data.convergence.confidence, data.convergence.detected, data.convergence.reason

# Human-readable stats
aprx stats
aprx stats --detailed
```

**Note**: `aprx backfill` must run after each round to generate metrics. Without it, `aprx robot stats` returns `code: "not_found"`.

## Workflow Configuration

Located at `.apr/workflows/<name>.yaml`:

```yaml
name: default
description: "Workflow description"

documents:
  readme: "README.md"
  spec: "SPECIFICATION.md"
  implementation: "src/main.rs"  # Optional

oracle:
  model: "gpt-5.2-pro"

rounds:
  output_dir: ".apr/rounds/default"
  impl_every_n: 4  # Optional: auto-include impl every N rounds
```

**Key fields**:
- `documents.readme` - Path to README file
- `documents.spec` - Path to specification file
- `documents.implementation` - Path to implementation doc (optional)
- `rounds.impl_every_n` - Auto-include impl every N rounds (optional)

## Robot Mode Response Format

```json
{
  "ok": true,
  "code": "success_code",
  "data": { /* command-specific */ },
  "hint": "human_readable_message",
  "meta": { "v": "1.2.2", "ts": "ISO_TIMESTAMP" }
}
```

## Error Codes

| Code | Meaning | Action |
|------|---------|--------|
| `ok` | Success | Continue |
| `not_configured` | APRX not set up | Run `aprx setup` |
| `not_found` | Resource missing | Check paths |
| `validation_failed` | Pre-flight failed | Review errors |
| `oracle_error` | Oracle failed | Retry or re-auth |

## Convergence Thresholds

| Score | Status | Action |
|-------|--------|--------|
| < 0.40 | LOW | Continue iterating |
| 0.40-0.74 | MODERATE | Continue, watch trend |
| >= 0.75 | HIGH | Safe to stop |
