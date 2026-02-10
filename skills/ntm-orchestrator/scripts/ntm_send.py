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
from pathlib import Path
from typing import Any, Dict, List, Optional

try:
    import tomllib  # py>=3.11
except ModuleNotFoundError:  # pragma: no cover
    import tomli as tomllib  # type: ignore

from ntm_lib import ensure_session, now_iso, resolve_target, robot_status


def load_palette_prompt(key: str, *, config_path: Optional[str] = None) -> str:
    """Load a prompt from NTM's [[palette]] entries in config.toml by palette key."""
    cfg = Path(config_path or Path.home() / ".config" / "ntm" / "config.toml")
    data = tomllib.loads(cfg.read_text(encoding="utf-8"))
    palette = data.get("palette", [])
    if not isinstance(palette, list):
        raise RuntimeError("config.toml palette is not a list")
    for entry in palette:
        if isinstance(entry, dict) and entry.get("key") == key:
            prompt = entry.get("prompt")
            if isinstance(prompt, str) and prompt.strip():
                return prompt.strip()
            raise RuntimeError(f"palette entry '{key}' has no prompt")
    raise RuntimeError(f"palette key not found: {key}")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--session", required=True)
    ap.add_argument(
        "--to",
        required=True,
        help="cc_1|cc_2|cod_1|... | cc_all|cod_all|agents_all or pane:<idx>",
    )
    ap.add_argument("--message", help="message text to send (ignored if --palette is set)")
    ap.add_argument(
        "--palette",
        help="If set, load the message body from NTM config.toml [[palette]] by key (e.g. bead_worker)",
    )
    ap.add_argument(
        "--new-task",
        action="store_true",
        help="If set, interrupt agent panes and reset their context before sending the message (Claude: /clear, Codex: /new).",
    )
    ap.add_argument("--cc", type=int, default=2, help="auto-spawn claude count if session missing")
    ap.add_argument("--cod", type=int, default=1, help="auto-spawn codex count if session missing")
    args = ap.parse_args()

    if args.palette:
        message = load_palette_prompt(args.palette)
    elif args.message:
        message = args.message
    else:
        ap.error("must provide --message or --palette")

    out: Dict[str, Any] = {
        "ok": False,
        "timestamp": now_iso(),
        "session": args.session,
        "to": args.to,
        "message": message,
        "palette": args.palette,
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

        def panes_for_target(to: str) -> List[int]:
            # Broadcasters
            if to == "cc_all":
                return claude_panes
            if to == "cod_all":
                return codex_panes
            if to == "agents_all":
                return sorted(set(claude_panes) | set(codex_panes))
            return []

        def reset_scope_for_target(to: str) -> tuple[List[int], List[int]]:
            """Return (claude_panes_to_reset, codex_panes_to_reset) for --new-task.

            Important: reset only the targeted agent scope by default.
            This avoids clearing unrelated panes in mixed sessions.
            """
            if to == "cc_all":
                return (claude_panes, [])
            if to == "cod_all":
                return ([], codex_panes)
            if to == "agents_all":
                return (claude_panes, codex_panes)

            # Single-target aliases (cc_1/cod_1) and pane:<idx>
            try:
                tgt = resolve_target(st, args.session, to)
                if tgt.agent_type == "claude":
                    return ([tgt.pane_idx], [])
                if tgt.agent_type == "codex":
                    return ([], [tgt.pane_idx])
            except Exception:
                pass

            # Safe fallback: do not reset unrelated panes.
            return ([], [])

        reset_claude_panes, reset_codex_panes = reset_scope_for_target(args.to)

        # If this is a fresh/new task, reset *targeted* agent panes first to avoid stale context carryover.
        reset_info: Dict[str, Any] = {
            "ran": False,
            "interrupt": None,
            "scope": "targeted",
            "claude": {"panes": reset_claude_panes, "msg": "/clear", "sent": False},
            "codex": {"panes": reset_codex_panes, "msg": "/new", "sent": False},
        }

        import subprocess

        if args.new_task:
            reset_info["ran"] = True

            # 1) Interrupt agents only for full-session resets.
            # For targeted resets (e.g. --to cod_all), avoid disturbing unrelated panes.
            # NOTE: In practice, sending /new to Codex panes can land in the underlying shell
            # if Codex crashed/exited or isn't ready yet. To make "new task" reliable,
            # we respawn Codex panes instead of sending /new.
            if args.to == "agents_all":
                subprocess.run(
                    ["ntm", "interrupt", args.session],
                    check=True,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                reset_info["interrupt"] = "ok"
            else:
                reset_info["interrupt"] = "skipped_targeted_scope"

            # 2) Reset Claude panes via /clear (targeted scope only)
            if reset_claude_panes:
                panes_arg = ",".join(str(p) for p in reset_claude_panes)
                subprocess.run(
                    ["ntm", f"--robot-send={args.session}", "--msg", reset_info["claude"]["msg"], "--panes", panes_arg],
                    check=True,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                reset_info["claude"]["sent"] = True

            # 3) Respawn targeted Codex panes (fresh process) instead of sending /new
            if reset_codex_panes:
                # ntm respawn currently works by type (all codex panes in session), so only
                # use it when codex is the intended reset scope.
                subprocess.run(
                    ["ntm", "respawn", args.session, "--type=codex", "--force"],
                    check=True,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                reset_info["codex"]["sent"] = True

        # Send the actual message.
        # Supports single-target and broadcast targets.
        broadcast_panes = panes_for_target(args.to)

        if broadcast_panes:
            # Use per-pane `ntm send` instead of `--robot-send`.
            # Empirically, `--robot-send` can paste multiline text without reliably submitting it
            # inside some TUIs (notably Codex). Per-pane send is more consistent.
            for pidx in broadcast_panes:
                subprocess.run(
                    ["ntm", "send", args.session, f"--pane={pidx}", message],
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
                ["ntm", "send", args.session, f"--pane={tgt.pane_idx}", message],
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
