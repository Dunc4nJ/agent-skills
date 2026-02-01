# ntm-orchestrator JSON schema (informal)

## ntm_send.py output (single JSON object)

```json
{
  "ok": true,
  "session": "polytrader",
  "to": "cod_1",
  "resolved": {
    "pane_idx": 4,
    "tmux_pane_id": "%109",
    "agent_type": "codex"
  },
  "message": "...",
  "spawned": false,
  "timestamp": "2026-02-01T02:50:00Z"
}
```

On error:

```json
{
  "ok": false,
  "session": "polytrader",
  "error": "...",
  "timestamp": "..."
}
```

## ntm_watch.py JSONL tick object

Emitted every interval.

```json
{
  "ok": true,
  "session": "polytrader",
  "timestamp": "2026-02-01T02:50:00Z",
  "interval_sec": 120,
  "lines": 120,
  "agents": [
    {
      "alias": "cc_1",
      "pane_idx": 2,
      "tmux_pane_id": "%107",
      "agent_type": "claude",
      "classification": "WAITING_QUESTION",
      "confidence": 0.9,
      "changed": true,
      "hash": "sha256:...",
      "question_excerpt": "...",
      "context_excerpt": ["...", "..."],
      "raw_tail": ["...", "..."]
    }
  ],
  "summary": {
    "RUNNING": 1,
    "IDLE": 2,
    "WAITING_QUESTION": 1,
    "WAITING_USER_INSTRUCTION": 0,
    "ERROR": 0,
    "UNKNOWN": 0
  }
}
```

Notes:
- `raw_tail` is the exact lines returned by NTM for the pane (truncated to `lines`).
- `context_excerpt` is a small subset (e.g. last ~25 lines) intended for decision-making.
- `question_excerpt` may be null.
