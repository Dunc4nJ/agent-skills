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
    ap.add_argument("--to", required=True, help="cc_1|cc_2|cod_1|... or pane:<idx>")
    ap.add_argument("--message", required=True)
    ap.add_argument("--cc", type=int, default=2, help="auto-spawn claude count if session missing")
    ap.add_argument("--cod", type=int, default=1, help="auto-spawn codex count if session missing")
    args = ap.parse_args()

    out: Dict[str, Any] = {
        "ok": False,
        "timestamp": now_iso(),
        "session": args.session,
        "to": args.to,
        "message": args.message,
    }

    try:
        spawned, st = ensure_session(args.session, cc=args.cc, cod=args.cod)
        tgt = resolve_target(st, args.session, args.to)

        # Send via NTM
        import subprocess

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
