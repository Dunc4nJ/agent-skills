#!/usr/bin/env python3
"""Spawn an NTM session for a tooling slug and kick off autonomous bead work.

V1 behavior (as requested):
- Create/ensure repo folder: /data/projects/tooling/<slug>/
- Create/ensure symlink:     /data/projects/tooling-<slug> -> /data/projects/tooling/<slug>
  (This makes NTM spawn into the correct CWD because NTM uses projects_base=/data/projects.)
- Spawn the session:         ntm spawn tooling-<slug> --cc=N --cod=M
- Broadcast palette prompt:  bead_worker to ALL agent panes (no per-bead assignment)

Outputs a single JSON object to stdout.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any, Dict


def run(cmd: list[str]) -> None:
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--slug", required=True, help="tooling project slug (folder name under /data/projects/tooling)")
    ap.add_argument("--cc", type=int, default=2)
    ap.add_argument("--cod", type=int, default=1)
    ap.add_argument(
        "--palette",
        default="bead_worker",
        help="NTM palette key to broadcast to all agents (default: bead_worker)",
    )
    ap.add_argument(
        "--no-spawn",
        action="store_true",
        help="Do not spawn session (only broadcast if it exists).",
    )
    args = ap.parse_args()

    slug = args.slug.strip().strip("/")
    if not slug or slug.startswith("."):
        ap.error("invalid --slug")

    repo = Path("/data/projects/tooling") / slug
    session = f"tooling-{slug}"
    link = Path("/data/projects") / session

    out: Dict[str, Any] = {
        "ok": False,
        "slug": slug,
        "repo": str(repo),
        "session": session,
        "link": str(link),
        "spawned": None,
        "broadcast": None,
        "palette": args.palette,
    }

    try:
        repo.mkdir(parents=True, exist_ok=True)
        if not (repo / "README.md").exists():
            (repo / "README.md").write_text(f"# {slug}\n\nDispatched via TaskMaster/NTM.\n", encoding="utf-8")

        # Ensure /data/projects/<session> symlink -> /data/projects/tooling/<slug>
        if link.exists() or link.is_symlink():
            # If it's already correct, ok; otherwise fail loudly.
            rp = os.path.realpath(link)
            if rp != str(repo):
                raise RuntimeError(f"session link exists but points elsewhere: {link} -> {rp} (expected {repo})")
            out["link_ok"] = True
        else:
            link.symlink_to(repo)
            out["link_created"] = True

        # Spawn session (fresh) if requested.
        if not args.no_spawn:
            # If session exists, NTM may error; treat as non-fatal and continue to broadcast.
            try:
                run(["ntm", "spawn", session, f"--cc={args.cc}", f"--cod={args.cod}"])
                out["spawned"] = True
            except subprocess.CalledProcessError:
                out["spawned"] = False

        # Broadcast bead worker palette prompt to all agents.
        scripts_dir = Path(__file__).resolve().parent
        ntm_send = scripts_dir / "ntm_send.py"
        p = subprocess.run(
            [
                sys.executable,
                str(ntm_send),
                "--session",
                session,
                "--to",
                "agents_all",
                "--palette",
                args.palette,
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        if p.returncode != 0:
            raise RuntimeError(f"ntm_send failed: {p.stderr.strip()[:400]}")
        out["broadcast"] = json.loads(p.stdout)

        out["ok"] = True
        sys.stdout.write(json.dumps(out, ensure_ascii=False) + "\n")
        return 0

    except Exception as e:
        out["error"] = str(e)
        sys.stdout.write(json.dumps(out, ensure_ascii=False) + "\n")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
