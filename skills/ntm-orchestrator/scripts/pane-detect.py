#!/usr/bin/env python3
"""
pane-detect.py — Detect agent pane states from NTM tail output.

Inspired by ft/wezterm_automata pattern detection.
Parses `ntm --robot-tail` output and classifies each pane's state.

Usage:
    ntm --robot-tail=SESSION --lines=30 --panes=2,3,4 2>&1 | python3 pane-detect.py
    python3 pane-detect.py SESSION [--panes 2,3,4] [--lines 30]

Output: JSON array of pane states.
"""

import argparse
import json
import re
import subprocess
import sys


# --- Pattern definitions (ft-style) ---

PATTERNS = {
    # Claude Code patterns
    "claude": {
        "idle": [
            re.compile(r"❯\s*$"),                    # bare prompt
            re.compile(r"^\s*❯\s"),                   # prompt at line start
        ],
        "working": [
            re.compile(r"◐"),                          # spinner
            re.compile(r"⠋|⠙|⠹|⠸|⠼|⠴|⠦|⠧|⠇|⠏"),    # braille spinners
            re.compile(r"Running|Executing"),
            re.compile(r"Read\s|Write\s|Edit\s"),      # tool calls
            re.compile(r"searching|indexing", re.I),
        ],
        "question": [
            re.compile(r"\?\s*$"),                     # line ends with ?
            re.compile(r"Do you want to|Would you like|Shall I", re.I),
            re.compile(r"\(y/n\)|\(Y/N\)|\[y/N\]|\[Y/n\]"),
        ],
        "error": [
            re.compile(r"Error:", re.I),
            re.compile(r"permission.error", re.I),
            re.compile(r"not.logged.in", re.I),
            re.compile(r"OAuth.token", re.I),
            re.compile(r"FATAL|panic|Traceback"),
        ],
        "rate_limited": [
            re.compile(r"rate.limit", re.I),
            re.compile(r"cooldown", re.I),
            re.compile(r"429"),
            re.compile(r"quota.exceeded", re.I),
            re.compile(r"too.many.requests", re.I),
            re.compile(r"overloaded", re.I),
        ],
        "context_full": [
            re.compile(r"context.window", re.I),
            re.compile(r"conversation.too.long", re.I),
            re.compile(r"token.limit", re.I),
        ],
    },
    # Codex CLI patterns
    "codex": {
        "idle": [
            re.compile(r"›\s*$"),                      # bare prompt
            re.compile(r"^\s*›\s"),                     # prompt at line start
            re.compile(r"context left", re.I),          # idle status line
        ],
        "working": [
            re.compile(r"◦"),                           # codex spinner
            re.compile(r"Ran\s|Executed"),
            re.compile(r"Reading|Writing|Applying"),
        ],
        "question": [
            re.compile(r"\?\s*$"),
            re.compile(r"Do you want to|Would you like|Shall I", re.I),
            re.compile(r"\(y/n\)|\(Y/N\)|\[y/N\]|\[Y/n\]"),
        ],
        "error": [
            re.compile(r"Error:", re.I),
            re.compile(r"not.logged.in", re.I),
            re.compile(r"FATAL|panic|Traceback"),
        ],
        "rate_limited": [
            re.compile(r"rate.limit(?:ed|s?\s+exceed)", re.I),
            re.compile(r"cooldown", re.I),
            re.compile(r"\b429\b"),
            re.compile(r"quota.exceeded", re.I),
        ],
        "context_full": [
            re.compile(r"context left:\s*0", re.I),
        ],
    },
}


def detect_agent_type(lines: list[str]) -> str:
    """Guess whether pane is Claude or Codex from output."""
    text = "\n".join(lines)
    claude_signals = sum(1 for p in [r"❯", r"Claude", r"claude-code", r"◐"] if p in text)
    codex_signals = sum(1 for p in [r"›", r"Codex", r"codex", r"◦", r"context left"] if p.lower() in text.lower())
    if codex_signals > claude_signals:
        return "codex"
    return "claude"  # default


def classify_pane(lines: list[str], agent_type: str | None = None) -> dict:
    """Classify a pane's state from its tail lines."""
    if not agent_type:
        agent_type = detect_agent_type(lines)

    patterns = PATTERNS.get(agent_type, PATTERNS["claude"])
    detections = []

    # Check last 10 lines (most recent activity matters most)
    recent = lines[-10:] if len(lines) > 10 else lines

    for category, regexes in patterns.items():
        for regex in regexes:
            for line in recent:
                if regex.search(line):
                    detections.append(category)
                    break  # one match per regex is enough
            if category in detections:
                break  # one match per category from recent lines

    # Priority-based state determination
    # Higher priority states override lower ones
    if "error" in detections:
        state = "error"
    elif "rate_limited" in detections:
        state = "rate_limited"
    elif "context_full" in detections:
        state = "context_full"
    elif "question" in detections and "working" not in detections:
        state = "question"
    elif "working" in detections:
        state = "working"
    elif "idle" in detections:
        state = "idle"
    else:
        state = "unknown"

    return {
        "agent_type": agent_type,
        "state": state,
        "detections": sorted(set(detections)),
        "last_line": lines[-1].strip() if lines else "",
    }


def parse_robot_tail(raw: str) -> dict[str, list[str]]:
    """Parse ntm --robot-tail output into pane_id -> lines."""
    panes = {}
    current_pane = None
    current_lines = []

    for line in raw.splitlines():
        # NTM robot-tail format: "=== Pane N (type) ===" or similar header
        header = re.match(r"^[=\-]+\s*[Pp]ane\s+(\d+)", line)
        if header:
            if current_pane is not None:
                panes[current_pane] = current_lines
            current_pane = header.group(1)
            current_lines = []
        elif current_pane is not None:
            current_lines.append(line)

    if current_pane is not None:
        panes[current_pane] = current_lines

    # If no headers found, try JSON format (ntm --robot-tail outputs nested JSON)
    if not panes:
        try:
            data = json.loads(raw)
            if isinstance(data, dict):
                # ntm format: { "panes": { "2": { "type": "claude", "lines": [...] }, ... } }
                pane_data = data.get("panes", data)
                for k, v in pane_data.items():
                    if isinstance(v, dict) and "lines" in v:
                        panes[str(k)] = v["lines"]
                    elif isinstance(v, dict) and "output" in v:
                        panes[str(k)] = v["output"].splitlines()
                    elif isinstance(v, str):
                        panes[str(k)] = v.splitlines()
                    elif isinstance(v, list):
                        panes[str(k)] = v
        except (json.JSONDecodeError, TypeError):
            pass

    # Last resort: treat entire input as one pane
    if not panes:
        panes["0"] = raw.splitlines()

    return panes


def main():
    parser = argparse.ArgumentParser(description="Detect NTM agent pane states")
    parser.add_argument("session", nargs="?", help="NTM session name (omit to read stdin)")
    parser.add_argument("--panes", default=None, help="Comma-separated pane indices (e.g. 2,3,4)")
    parser.add_argument("--lines", type=int, default=30, help="Tail lines per pane")
    parser.add_argument("--compact", action="store_true", help="Compact JSON output")
    args = parser.parse_args()

    if args.session:
        cmd = ["ntm", f"--robot-tail={args.session}", f"--lines={args.lines}"]
        if args.panes:
            cmd.append(f"--panes={args.panes}")
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
        raw = result.stdout + result.stderr
    else:
        raw = sys.stdin.read()

    panes = parse_robot_tail(raw)
    results = []

    # Extract type hints from JSON if available
    type_hints = {}
    try:
        data = json.loads(raw)
        for k, v in data.get("panes", {}).items():
            if isinstance(v, dict) and "type" in v:
                t = v["type"].lower()
                if "codex" in t or "cod" in t:
                    type_hints[str(k)] = "codex"
                else:
                    type_hints[str(k)] = "claude"
    except Exception:
        pass

    for pane_id, lines in sorted(panes.items(), key=lambda x: x[0]):
        hint = type_hints.get(pane_id)
        state = classify_pane(lines, agent_type=hint)
        state["pane"] = pane_id
        results.append(state)

    indent = None if args.compact else 2
    print(json.dumps(results, indent=indent))


if __name__ == "__main__":
    main()
