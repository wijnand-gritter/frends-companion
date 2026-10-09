#!/usr/bin/env python3
"""
Compare a tenant's Platform API OpenAPI document with the operations the companion was built
against (references/guides/platform-api-operations.txt), and list endpoints the scripts call that
the document no longer has.

USAGE
  python3 check_api_drift.py swagger.json            # report added, removed, broken script calls
  python3 check_api_drift.py swagger.json --write    # refresh the snapshot after reviewing the report

Get swagger.json from https://<tenant>.frendsapp.com/v1.0/swagger.json (the Swagger UI lists it).
Exit code 1 when a script calls an endpoint the document lacks.
"""
import argparse
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SNAPSHOT = os.path.normpath(os.path.join(HERE, "..", "references", "guides", "platform-api-operations.txt"))


def operations(doc):
    ops = set()
    for path, items in (doc.get("paths") or {}).items():
        for method, op in items.items():
            if isinstance(op, dict) and "responses" in op:
                ops.add(f"{method.upper()} {path}")
    return ops


def snapshot():
    with open(SNAPSHOT, encoding="utf-8") as f:
        return {l.strip() for l in f if l.strip() and not l.startswith("#")}


def script_paths():
    """Endpoint templates the frends-*.sh scripts call, normalised to /api/v1/... with {param}."""
    found = set()
    for sh in glob.glob(os.path.join(HERE, "frends-*.sh")):
        text = open(sh, encoding="utf-8").read()
        for m in re.finditer(r'frends_api(?: --out-file "[^"]*")? ("?\$?\w+"?) "([^"]+)"', text):
            method, ep = m.group(1).strip('"'), m.group(2)
            if not re.fullmatch(r"[A-Z]+", method):
                method = "*"
            ep = re.sub(r"\$\{\w+:[^}]*\}", "", ep)       # ${VAR:+...} query-string expansions
            ep = ep.split("?", 1)[0]
            if re.fullmatch(r"\$\{?\w+\}?", ep):              # endpoint held in a variable
                continue
            ep = re.sub(r"\$\{?(\w+)\}?", "{x}", ep)
            found.add((method, "/api/v1/" + ep.lstrip("/"), os.path.basename(sh)))
    return found


def matches(call, ops):
    method, path, _ = call
    pattern = "^" + re.sub(r"\\\{x\\\}", r"\\{[^/]+\\}", re.escape(path)) + "$"
    for op in ops:
        m, p = op.split(" ", 1)
        if (method == "*" or m == method) and re.match(pattern, p):
            return True
    return False


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.strip().splitlines()[0])
    ap.add_argument("swagger")
    ap.add_argument("--write", action="store_true", help="rewrite the snapshot from this document")
    args = ap.parse_args(argv)
    with open(args.swagger, encoding="utf-8-sig") as f:
        doc = json.load(f)
    live = operations(doc)
    known = snapshot()
    added, removed = sorted(live - known), sorted(known - live)
    print(f"document: {len(live)} operations, snapshot: {len(known)}")
    for op in added:
        print("  added   ", op)
    for op in removed:
        print("  removed ", op)
    broken = [c for c in sorted(script_paths()) if not matches(c, live)]
    for method, path, script in broken:
        print(f"  BROKEN   {script}: {method} {path}")
    if args.write:
        version = doc.get("info", {}).get("version", "?")
        with open(SNAPSHOT, "w", encoding="utf-8") as f:
            f.write(f"# Frends Platform API operations, OpenAPI document {version} ({len(live)} operations).\n")
            f.write("# Refresh with: python3 scripts/check_api_drift.py <swagger.json> --write\n")
            f.write("\n".join(sorted(live)) + "\n")
        print(f"snapshot rewritten: {SNAPSHOT}")
    return 1 if broken else 0


if __name__ == "__main__":
    raise SystemExit(main())
