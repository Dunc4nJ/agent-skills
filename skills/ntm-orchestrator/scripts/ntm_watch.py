#!/usr/bin/env python3
"""Poll NTM pane output and emit JSONL ticks.

Design goals:
- JSON-only output (no human summary)
- Use --robot-status + --robot-tail
- Tail-based classification (activity may be UNKNOWN)

Usage:
  python3 scripts/ntm_watch.py --session polytrader --interval 120 --lines 120

Exit codes:
- 0: normal termination (max-ticks reached)
- 2: stopped because a WAITING_QUESTION was detected
- 3: stopped because an ERROR was detected
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import time
from dataclasses import asdict
from typing import Any, Dict, List, Optional, Tuple

from ntm_lib import now_iso, resolve_aliases, robot_status, robot_tail


def sha256_lines(lines: List[str]) -> str:
    h = hashlib.sha256()
    for ln in lines:
        h.update(ln.encode("utf-8", errors="replace"))
        h.update(b"\n")
    return "sha256:" + h.hexdigest()


def classify(agent_type: str, lines: List[str]) -> Tuple[str, float, Optional[str]]:
    """Return (classification, confidence, question_excerpt)."""
    tail_text = "\n".join(lines[-60:])

    # Universal error detection
    if re.search(r"\b(Error:|Traceback|panic:|FATAL|permission denied|No such file or directory)\b", tail_text, re.I):
        return ("ERROR", 0.85, None)

    # Codex interactive prompts/questions
    if agent_type == "codex":
        # Strong question signal (ends with '?')
        for ln in reversed(lines[-40:]):
            if re.match(r"^\s*›\s+.*\?\s*$", ln):
                return ("WAITING_QUESTION", 0.95, ln.strip())

        # Interactive questionnaire UI
        if re.search(r"Question\s+\d+/\d+", tail_text):
            # Prefer an actual question line, not the interactive prompt.
            for ln in reversed(lines[-80:]):
                if ln.strip().endswith("?"):
                    return ("WAITING_QUESTION", 0.9, ln.strip())
                if re.match(r"^\s*How should\b", ln):
                    return ("WAITING_QUESTION", 0.85, ln.strip())
            return ("WAITING_QUESTION", 0.75, "Questionnaire waiting for input")

        # Running signals
        if re.search(r"\bWorked for\b|\bRan\b|\bExecuting\b|\bExplored\b", tail_text):
            # Could be recently completed; still treat as RUNNING-ish unless we see a clear prompt.
            # If we see an interactive prompt (›) without ?, treat as waiting.
            for ln in reversed(lines[-20:]):
                if re.match(r"^\s*›\s+.+", ln):
                    return ("WAITING_USER_INSTRUCTION", 0.75, None)
            return ("RUNNING", 0.7, None)

        # Generic waiting prompt
        for ln in reversed(lines[-20:]):
            if re.match(r"^\s*›\s+.+", ln):
                return ("WAITING_USER_INSTRUCTION", 0.7, None)

        return ("UNKNOWN", 0.5, None)

    # Claude Code
    if agent_type == "claude":
        # Running tool indicators
        if re.search(r"\bRunning…\b|\bRunning\.\.\.\b|◐\s*Bash:|Running PreToolUse hook", tail_text):
            return ("RUNNING", 0.9, None)

        # If we see a prompt line, treat as idle unless a question is present
        # Claude prompt is usually "❯".
        # Prompt detection
        prompt_lines = [ln for ln in lines[-30:] if re.match(r"^\s*❯", ln)]
        if prompt_lines:
            # If the prompt line includes content, treat as waiting for instruction.
            # Examples: "❯ do X" or "❯ /command".
            for ln in reversed(prompt_lines):
                if re.match(r"^\s*❯\s+\S+", ln):
                    if re.match(r"^\s*❯\s+.*\?\s*$", ln):
                        return ("WAITING_QUESTION", 0.8, ln.strip())
                    return ("WAITING_USER_INSTRUCTION", 0.8, None)

            # Bare prompt
            return ("IDLE", 0.75, None)

        return ("UNKNOWN", 0.5, None)

    return ("UNKNOWN", 0.4, None)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--session", required=True)
    ap.add_argument("--interval", type=int, default=120)
    ap.add_argument("--lines", type=int, default=120)
    ap.add_argument("--max-ticks", type=int, default=0, help="0 = run forever")
    ap.add_argument("--stop-on-question", action="store_true", default=True)
    ap.add_argument("--stop-on-error", action="store_true", default=True)
    args = ap.parse_args()

    last_hash: Dict[str, str] = {}
    tick = 0

    while True:
        tick += 1
        st = robot_status()
        refs = resolve_aliases(st, args.session)
        panes = [r.pane_idx for r in refs]

        if not panes:
            obj = {
                "ok": False,
                "timestamp": now_iso(),
                "session": args.session,
                "error": "session not found or has no agents",
            }
            sys.stdout.write(json.dumps(obj, ensure_ascii=False) + "\n")
            sys.stdout.flush()
            return 1

        tail = robot_tail(args.session, panes=panes, lines=args.lines)

        agents_out: List[Dict[str, Any]] = []
        summary: Dict[str, int] = {"RUNNING": 0, "IDLE": 0, "WAITING_QUESTION": 0, "WAITING_USER_INSTRUCTION": 0, "ERROR": 0, "UNKNOWN": 0}

        # Convert pane map keys to ints
        pane_map: Dict[int, Dict[str, Any]] = {}
        for k, v in (tail.get("panes", {}) or {}).items():
            try:
                pane_map[int(k)] = v
            except Exception:
                continue

        stop_reason: Optional[str] = None

        for r in refs:
            p = pane_map.get(r.pane_idx, {})
            raw_lines = p.get("lines", []) or []
            h = sha256_lines(raw_lines)
            changed = last_hash.get(r.alias) != h
            last_hash[r.alias] = h

            cls, conf, qex = classify(r.agent_type, raw_lines)
            summary[cls] = summary.get(cls, 0) + 1

            ctx = raw_lines[-25:] if len(raw_lines) > 25 else raw_lines

            agent_obj: Dict[str, Any] = {
                "alias": r.alias,
                "pane_idx": r.pane_idx,
                "tmux_pane_id": r.tmux_pane_id,
                "agent_type": r.agent_type,
                "classification": cls,
                "confidence": conf,
                "changed": changed,
                "hash": h,
                "question_excerpt": qex,
                "context_excerpt": ctx,
                "raw_tail": raw_lines,
            }
            agents_out.append(agent_obj)

            if args.stop_on_error and cls == "ERROR" and stop_reason is None:
                stop_reason = f"ERROR:{r.alias}"
            if args.stop_on_question and cls == "WAITING_QUESTION" and stop_reason is None:
                stop_reason = f"QUESTION:{r.alias}"

        tick_obj: Dict[str, Any] = {
            "ok": True,
            "timestamp": now_iso(),
            "session": args.session,
            "interval_sec": args.interval,
            "lines": args.lines,
            "tick": tick,
            "agents": agents_out,
            "summary": summary,
        }

        if stop_reason:
            tick_obj["stop_reason"] = stop_reason

        sys.stdout.write(json.dumps(tick_obj, ensure_ascii=False) + "\n")
        sys.stdout.flush()

        if stop_reason:
            if stop_reason.startswith("QUESTION:"):
                return 2
            if stop_reason.startswith("ERROR:"):
                return 3

        if args.max_ticks and tick >= args.max_ticks:
            return 0

        time.sleep(args.interval)


if __name__ == "__main__":
    raise SystemExit(main())
