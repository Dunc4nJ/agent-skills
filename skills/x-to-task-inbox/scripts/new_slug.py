#!/usr/bin/env python3
import re
import sys

def slugify(s: str) -> str:
    s = s.strip().lower()
    s = re.sub(r"https?://", "", s)
    s = re.sub(r"[^a-z0-9]+", "-", s)
    s = re.sub(r"-+", "-", s).strip("-")
    return s[:80] or "capture"

if __name__ == "__main__":
    text = " ".join(sys.argv[1:])
    print(slugify(text))
