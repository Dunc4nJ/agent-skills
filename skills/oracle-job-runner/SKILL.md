---
name: oracle-job-runner
description: Use when the user asks to "run this through Oracle", "ask GPT 5.2 Pro", "submit a job", "bundle files for ChatGPT", "use oracle-pool", "queue oracle runs", or needs a reliable pattern to send a plan/spec/docs/question to Oracle and retrieve the result (oracle CLI, oracle-pool, aprx via pool). Covers prompts, file bundling, slugs, waiting/reattaching, and where outputs live.
---

# Oracle Job Runner

## Decide the execution path

Choose the path based on the task:

1) **oracle-pool (default; required)**
- Use for all Oracle runs. Provides queuing, slot isolation, and centralized auth.

2) **aprx (iterative rounds over a README/spec workflow)**
- Use when the task is multi-round refinement and you want round artifacts under `.apr/`.

**Do not use `oracle` CLI directly.** It is intentionally disallowed in this environment to avoid single-slot flakiness, auth drift, and loss of pooled observability.

## Inputs checklist (what to ask the user for)

Collect:
- The **question** / objective (what good output looks like).
- The **files/dirs** to attach (paths or glob patterns).
- The desired **model** and (if browser) **thinking-time**.
- Whether this is **one-shot** or **queued** (pool).

If file paths are unclear, request:
- repo root path
- exact file names
- whether to include whole directories

## Prompt pattern (recommended)

Use a short structure:

- 2–5 sentence context
- explicit task
- constraints (format, length, diff style, risk focus)
- “read these files first”

Example prompt:

"""
Read the attached README + spec first.
Task: review for correctness, missing edge cases, and operational concerns.
Output: (1) top risks, (2) suggested changes as patch-style bullets, (3) any questions.
Be concrete; avoid generic advice.
"""

## Slug rules (important)

- Oracle prefers a memorable **3–5 word slug**.
- For queued systems, include a unique suffix when rerunning to avoid confusion.

Examples:
- `release readiness audit`
- `aprx round 7`
- `pool smoke test 2026 02 01`

## Ensure the daemon is running (required)

Before submitting jobs, ensure `oracle-pool` is actually alive (socket responsive), not just that a pid/socket file exists.

1) Try:
```bash
oracle-pool status
```

2) If it fails:

- **If systemd unit exists** (preferred):
  ```bash
  sudo systemctl start oracle-pool
  sudo systemctl enable oracle-pool
  ```

- **Fallback (no systemd available):**
  ```bash
  nohup oracle-pool start --foreground > ~/.oracle-pool/daemon.out 2>&1 &
  ```

3) Re-check:
```bash
oracle-pool status
```

If it still fails, inspect:
- `~/.oracle-pool/daemon.out`
- stale files: `~/.oracle-pool/oracle-pool.sock`, `~/.oracle-pool/oracle-pool.pid`

## Run via oracle-pool (preferred)

Submit (non-blocking):

```bash
oracle-pool submit \
  -p "<prompt>" \
  --file <path-or-glob> \
  --slug "<3-5 words>" \
  --model gpt-5.2-pro \
  --timeout 4500 \
  --notify clawdbot \
  -- --browser-thinking-time extended
```

Submit + block (platform-native):

```bash
oracle-pool submit \
  -p "<prompt>" \
  --file <path-or-glob> \
  --slug "<3-5 words>" \
  --model gpt-5.2-pro \
  --timeout 4500 \
  --notify clawdbot \
  --wait --print \
  -- --browser-thinking-time extended
```

Wait on an existing job:

```bash
oracle-pool wait <job-id-or-slug> --print
```

Monitor:

```bash
oracle-pool status
oracle-pool list --state running
```

Fetch result:

```bash
oracle-pool result <job-id-or-slug>
```

Debug logs:

```bash
oracle-pool logs <job-id> --stderr
oracle-pool logs <job-id>
```

Key paths:
- Outputs: `~/.oracle-pool/jobs/<job-id>/output.md`

## Do not run via `oracle` CLI (disallowed)

Do not invoke `oracle` directly (even for one-offs).

If `oracle-pool` is unavailable:
- Fix the pool (start/restart/refresh-auth) rather than falling back to `oracle`.

## Run via aprx (iterative)

Use when a project has `.apr/` workflow config.

```bash
aprx run <N> --wait --force
```

Artifacts:
- Rounds: `.apr/rounds/<workflow>/round_N.md`

## Completion checklist

After a run completes:
- Summarize the result (key points + risks + TODOs).
- Provide the exact output file path(s).
- If failed, include:
  - job id / slug
  - `stderr.txt` tail (or `oracle-pool logs --stderr`)
  - likely remediation (auth refresh, rerun, reduce files, increase timeout)
