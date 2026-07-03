#!/usr/bin/env python3
"""Validate that every relative Markdown link in the repo points at a real file.

Skips external links (http/https/mailto), pure anchors, and the intentional `../`
placeholders in references/_TEMPLATE.md. Exits non-zero if any link is broken.
"""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LINK_RE = re.compile(r"\]\(([^)]+)\)")
TEMPLATE = os.path.normpath(os.path.join(ROOT, "fc-integration/skills/frends-ipaas-developer/references/_TEMPLATE.md"))

broken, checked = [], 0
for dp, _, files in os.walk(ROOT):
    if os.sep + ".git" in dp:
        continue
    for fn in files:
        if not fn.endswith(".md"):
            continue
        fp = os.path.join(dp, fn)
        with open(fp, encoding="utf-8") as f:
            text = f.read()
        for m in LINK_RE.finditer(text):
            tgt = m.group(1).strip()
            if tgt.startswith(("http://", "https://", "#", "mailto:")):
                continue
            tgt = tgt.split("#")[0].strip()
            if not tgt:
                continue
            checked += 1
            cand = os.path.normpath(os.path.join(dp, tgt))
            ok = os.path.isdir(cand) if tgt.endswith("/") else os.path.exists(cand)
            if not ok and os.path.normpath(fp) != TEMPLATE:
                broken.append((os.path.relpath(fp, ROOT), tgt))

print(f"checked {checked} internal Markdown links")
for fp, tgt in broken:
    print(f"  BROKEN: {fp} -> {tgt}")
print("ALL OK" if not broken else f"{len(broken)} BROKEN")
sys.exit(1 if broken else 0)
