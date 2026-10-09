#!/usr/bin/env bash
# Everything CI would run, runnable on your own machine.
#
#   bash scripts/check.sh
#
# GitHub Actions calls this same script, so the two can never drift. Needs bash and
# python3, nothing else. Reports every failure rather than stopping at the first.

set -uo pipefail
cd "$(dirname "$0")/.."

fails=0
ok()   { printf '  ok    %s\n' "$1"; }
fail() { printf '  FAIL  %s\n' "$1"; fails=$((fails + 1)); }
step() { printf '\n%s\n' "$1"; }

json_ok() {
  python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$1" 2>/dev/null
}

step "JSON manifests parse"
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json template/.claude/settings.json; do
  json_ok "$f" && ok "$f" || fail "$f is not valid JSON"
done

step "Plugin version is SemVer"
v=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])" 2>/dev/null || echo "")
if printf '%s' "$v" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+([-+].*)?$'; then
  ok "version $v"
else
  fail "version '$v' is not SemVer"
fi

step "Marketplace lists this plugin"
if python3 - <<'PY' 2>/dev/null
import json
p = json.load(open(".claude-plugin/plugin.json"))
m = json.load(open(".claude-plugin/marketplace.json"))
entries = [e for e in m["plugins"] if e["name"] == p["name"]]
assert entries and entries[0]["source"] in ("./", ".")
PY
then
  ok "marketplace entry for the plugin points at the repo root"
else
  fail "marketplace.json has no entry for the plugin.json name with source ./"
fi

step "Shell scripts parse"
for f in skills/frends-ipaas-developer/scripts/*.sh scripts/*.sh; do
  [ -e "$f" ] || continue
  bash -n "$f" 2>/dev/null && ok "$f" || fail "$f has a syntax error"
done

step "Python compiles"
for f in skills/frends-ipaas-developer/scripts/generate_process.py skills/frends-ipaas-developer/scripts/check_api_drift.py skills/frends-reviewer/scripts/review_process.py scripts/check_links.py; do
  python3 -m py_compile "$f" 2>/dev/null && ok "$f" || fail "$f does not compile"
done

step "Relative Markdown links resolve"
if out=$(python3 scripts/check_links.py 2>&1); then
  ok "$(printf '%s' "$out" | head -1)"
else
  printf '%s\n' "$out" | sed 's/^/  /'
  fail "broken Markdown links"
fi

# Only where the CLI exists. The CI image has no npm, so this is skipped there.
step "Plugin manifest, per the runtime"
if command -v claude >/dev/null 2>&1; then
  if out=$(claude plugin validate . 2>&1); then
    ok "claude plugin validate"
    printf '%s\n' "$out" | grep -E "^\s+❯" | sed 's/^/  warn /' || true
  else
    printf '%s\n' "$out" | sed 's/^/  /'
    fail "claude plugin validate"
  fi
else
  printf '  skip  claude CLI not on PATH\n'
fi

printf '\n'
if [ "$fails" -eq 0 ]; then
  printf 'All checks passed.\n'
else
  printf '%d check(s) failed.\n' "$fails"
fi
exit $((fails > 0))
