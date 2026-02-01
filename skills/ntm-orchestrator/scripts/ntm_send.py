#!/usr/bin/env python3
"""Ensure an NTM session exists, resolve a target alias, and send a message.

Always prints a single JSON object to stdout.

Examples:
  python3 scripts/ntm_send.py --session polytrader --to cod_1 --message "Do X"
  python3 scripts/ntm_send.py --session oracle-pool --to pane:4 --message "Reply"
"""

from __future__ import annotations

import argparse
import json
import sys
from typing import Any, Dict

from ntm_lib import ensure_session, now_iso, resolve_target, robot_status


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--session", required=True)
    ap.add_argument(
        "--to",
        required=True,
        help="cc_1|cc_2|cod_1|... | cc_all|cod_all|agents_all or pane:<idx>",
    )
    ap.add_argument("--message", required=True)
    ap.add_argument(
        "--new-task",
        action="store_true",
        help="If set, interrupt agent panes and reset their context before sending the message (Claude: /clear, Codex: /new).",
    )
    ap.add_argument("--cc", type=int, default=2, help="auto-spawn claude count if session missing")
    ap.add_argument("--cod", type=int, default=1, help="auto-spawn codex count if session missing")
    args = ap.parse_args()

    out: Dict[str, Any] = {
        "ok": False,
        "timestamp": now_iso(),
        "session": args.session,
        "to": args.to,
        "message": args.message,
        "new_task": bool(args.new_task),
    }

    try:
        spawned, st = ensure_session(args.session, cc=args.cc, cod=args.cod)

        # Compute agent pane indices from robot status so we never touch the user shell pane.
        sess = None
        for s in st.get("sessions", []):
            if s.get("name") == args.session:
                sess = s
                break
        agents = list((sess or {}).get("agents", []))

        claude_panes = sorted({int(a.get("pane_idx")) for a in agents if a.get("type") == "claude" and a.get("pane_idx") is not None})
        codex_panes = sorted({int(a.get("pane_idx")) for a in agents if a.get("type") == "codex" and a.get("pane_idx") is not None})

        # If this is a fresh/new task, reset agent panes first to avoid stale context carryover.
        reset_info: Dict[str, Any] = {
            "ran": False,
            "interrupt": None,
            "claude": {"panes": claude_panes, "msg": "/clear", "sent": False},
            "codex": {"panes": codex_panes, "msg": "/new", "sent": False},
        }

        def panes_for_target(to: str) -> List[int]:
            # Broadcasters
            if to == "cc_all":
                return claude_panes
            if to == "cod_all":
                return codex_panes
            if to == "agents_all":
                return sorted(set(claude_panes) | set(codex_panes))
            return []

        import subprocess

        if args.new_task:
            reset_info["ran"] = True

            # 1) Interrupt agents (NTM defaults to agent panes only).
            subprocess.run(
                ["ntm", "interrupt", args.session],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            reset_info["interrupt"] = "ok"

            # 2) Reset per agent type. Use robot-send with explicit pane list.
            if claude_panes:
                panes_arg = ",".join(str(p) for p in claude_panes)
                subprocess.run(
                    ["ntm", f"--robot-send={args.session}", "--msg", reset_info["claude"]["msg"], "--panes", panes_arg],
                    check=True,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                reset_info["claude"]["sent"] = True

            if codex_panes:
                panes_arg = ",".join(str(p) for p in codex_panes)
                subprocess.run(
                    ["ntm", f"--robot-send={args.session}", "--msg", reset_info["codex"]["msg"], "--panes", panes_arg],
                    check=True,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                reset_info["codex"]["sent"] = True

        # Send the actual message.
        # Supports single-target and broadcast targets.
        broadcast_panes = panes_for_target(args.to)

        if broadcast_panes:
            panes_arg = ",".join(str(p) for p in broadcast_panes)
            subprocess.run(
                ["ntm", f"--robot-send={args.session}", "--msg", args.message, "--panes", panes_arg],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

            out.update(
                {
                    "ok": True,
                    "spawned": spawned,
                    "reset": reset_info,
                    "broadcast": {
                        "to": args.to,
                        "panes": broadcast_panes,
                        "count": len(broadcast_panes),
                    },
                }
            )
        else:
            tgt = resolve_target(st, args.session, args.to)
            subprocess.run(
                ["ntm", "send", args.session, f"--pane={tgt.pane_idx}", args.message],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

            out.update(
                {
                    "ok": True,
                    "spawned": spawned,
                    "reset": reset_info,
                    "resolved": {
                        "pane_idx": tgt.pane_idx,
                        "tmux_pane_id": tgt.tmux_pane_id,
                        "agent_type": tgt.agent_type,
                    },
                }
            )

    except Exception as e:
        out["error"] = str(e)

    sys.stdout.write(json.dumps(out, ensure_ascii=False) + "\n")
    return 0 if out.get("ok") else 1


if __name__ == "__main__":
    raise SystemExit(main())
