#!/usr/bin/env python3
"""Small helpers for NTM JSON-first orchestration.

All functions are designed to be deterministic and easy to parse.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional, Tuple


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def run_json(cmd: List[str]) -> Dict[str, Any]:
    """Run a command that prints JSON to stdout. Raise on failure."""
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if p.returncode != 0:
        raise RuntimeError(f"cmd failed ({p.returncode}): {' '.join(cmd)}\n{p.stderr.strip()}")
    try:
        return json.loads(p.stdout)
    except Exception as e:
        raise RuntimeError(
            f"failed to parse JSON from: {' '.join(cmd)}\nerror: {e}\nstdout: {p.stdout[:2000]}\nstderr: {p.stderr[:2000]}"
        )


def run_text(cmd: List[str]) -> str:
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if p.returncode != 0:
        raise RuntimeError(f"cmd failed ({p.returncode}): {' '.join(cmd)}\n{p.stderr.strip()}")
    return p.stdout


@dataclass
class AgentRef:
    alias: str
    agent_type: str  # 'claude' | 'codex' | 'unknown'
    pane_idx: int
    tmux_pane_id: Optional[str] = None


def robot_status() -> Dict[str, Any]:
    return run_json(["ntm", "--robot-status"])


def get_session(status: Dict[str, Any], session: str) -> Optional[Dict[str, Any]]:
    for s in status.get("sessions", []):
        if s.get("name") == session:
            return s
    return None


def ensure_session(session: str, cc: int = 2, cod: int = 1) -> Tuple[bool, Dict[str, Any]]:
    """Ensure session exists. Returns (spawned, latest_status_json)."""
    st = robot_status()
    sess = get_session(st, session)
    if sess and sess.get("exists"):
        return (False, st)

    # Spawn
    cmd = ["ntm", "spawn", session, f"--cc={cc}", f"--cod={cod}"]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    st2 = robot_status()
    return (True, st2)


def resolve_aliases(status: Dict[str, Any], session: str) -> List[AgentRef]:
    """Return AgentRef list with aliases cc_*/cod_* based on pane_idx ordering."""
    sess = get_session(status, session)
    if not sess or not sess.get("exists"):
        return []

    agents = list(sess.get("agents", []))
    # Only count real agent panes
    claudes = sorted([a for a in agents if a.get("type") == "claude"], key=lambda a: a.get("pane_idx", 0))
    codexes = sorted([a for a in agents if a.get("type") == "codex"], key=lambda a: a.get("pane_idx", 0))

    out: List[AgentRef] = []
    for i, a in enumerate(claudes, start=1):
        out.append(
            AgentRef(
                alias=f"cc_{i}",
                agent_type="claude",
                pane_idx=int(a.get("pane_idx")),
                tmux_pane_id=a.get("pane"),
            )
        )
    for i, a in enumerate(codexes, start=1):
        out.append(
            AgentRef(
                alias=f"cod_{i}",
                agent_type="codex",
                pane_idx=int(a.get("pane_idx")),
                tmux_pane_id=a.get("pane"),
            )
        )
    return out


def resolve_target(status: Dict[str, Any], session: str, to: str) -> AgentRef:
    """Resolve a target string to a concrete pane.

    Supported:
    - cc_1, cc_2, ...
    - cod_1, cod_2, ...
    - pane:4
    """
    m = re.match(r"^pane:(\d+)$", to)
    if m:
        pane_idx = int(m.group(1))
        # find type if present
        sess = get_session(status, session) or {}
        for a in sess.get("agents", []):
            if int(a.get("pane_idx", -1)) == pane_idx:
                t = a.get("type", "unknown")
                return AgentRef(alias=to, agent_type=t, pane_idx=pane_idx, tmux_pane_id=a.get("pane"))
        return AgentRef(alias=to, agent_type="unknown", pane_idx=pane_idx, tmux_pane_id=None)

    refs = resolve_aliases(status, session)
    for r in refs:
        if r.alias == to:
            return r
    raise ValueError(f"unknown target '{to}' (known: {[r.alias for r in refs]} plus pane:N)")


def robot_tail(session: str, panes: List[int], lines: int) -> Dict[str, Any]:
    panes_arg = ",".join(str(p) for p in panes)
    return run_json(["ntm", f"--robot-tail={session}", f"--lines={lines}", f"--panes={panes_arg}"])
