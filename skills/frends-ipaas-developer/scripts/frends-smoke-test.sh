#!/usr/bin/env bash
# Read-only smoke test of every Platform API script against the tenant in ./.env.
# Changes nothing in the tenant. Prints a PASS/FAIL/SKIP table; full output goes to
# active-development/feedback/api-smoke-<timestamp>.log (no secrets: the scripts never print tokens).
#
# Usage: bash scripts/frends-smoke-test.sh
#
# Stops at the first 401, 403 or token error: repeated bad-auth calls can lock the account.
# Also exports one Process, validates it with generate_process.py --validate, reviews it with
# frends-reviewer, prints its FrendsVersion and TargetFramework, and runs check_api_drift.py
# against the tenant's live OpenAPI document.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REVIEWER="$SCRIPT_DIR/../../frends-reviewer/scripts/review_process.py"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"
set +e   # frends-common.sh sets -e; this script records failures instead of stopping on them
load_env
require_tools curl jq python3

TS="$(date -u +%Y%m%dT%H%M%SZ)"
OUTDIR="active-development/feedback"
mkdir -p "$OUTDIR"
LOG="$OUTDIR/api-smoke-$TS.log"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
RESULTS=()

run() {  # run <step name> <command...>; output to $WORK/last and the log
  local name="$1"; shift
  { echo; echo "=== $name"; echo "\$ $*"; } >> "$LOG"
  "$@" > "$WORK/last" 2>&1
  local rc=$?
  cat "$WORK/last" >> "$LOG"
  if grep -qE "HTTP 40[13]|Failed to obtain bearer token" "$WORK/last"; then
    RESULTS+=("FAIL|$name|$(grep -m1 -E 'HTTP 40[13]|bearer token' "$WORK/last")")
    report; echo "Stopped: authentication or permission error. Check the Platform API setup before retrying." >&2
    exit 1
  fi
  if grep -qE "cannot reach" "$WORK/last"; then
    RESULTS+=("FAIL|$name|$(grep -m1 'cannot reach' "$WORK/last" | cut -c1-140)")
    report; echo "Stopped: the tenant or the token endpoint is unreachable from this machine." >&2
    exit 1
  fi
  if [[ $rc -eq 0 ]]; then
    RESULTS+=("PASS|$name|${NOTE:-}")
  else
    RESULTS+=("FAIL|$name|$(grep -m1 -E 'ERROR|error|Unknown' "$WORK/last" | cut -c1-140)")
  fi
  NOTE=""
  return $rc
}
skip() { RESULTS+=("SKIP|$1|$2"); }
first_id() { jq -r "[.. | objects | select(has(\"$1\")) | .$1][0] // empty" "$WORK/last" 2>/dev/null; }
report() {
  echo
  printf '%-5s | %-38s | %s\n' "RESULT" "STEP" "NOTE"
  printf '%s\n' "------+----------------------------------------+-------------------------------"
  for r in "${RESULTS[@]}"; do IFS='|' read -r a b c <<< "$r"; printf '%-5s | %-38s | %s\n' "$a" "$b" "$c"; done
  echo; echo "Log: $LOG"
}

S="$SCRIPT_DIR"
AG="${FRENDS_DEV_AGENT_GROUP_ID:-}"

run "connection test" bash "$S/frends-connection-test.sh"
run "agentgroups list" bash "$S/frends-agentgroups.sh" list
if [[ -n "$AG" ]]; then run "agentgroups show" bash "$S/frends-agentgroups.sh" show --id "$AG" --raw
else skip "agentgroups show" "FRENDS_DEV_AGENT_GROUP_ID unset"; fi

DGUID=""
if [[ -n "$AG" ]]; then
  run "deploy list" bash "$S/frends-deploy.sh" list --agent-group "$AG" --raw
  # Deployments carry deploymentId; first_id would pick up the nested agentGroup.id.
  DID="$(jq -r '.data[0].deploymentId // empty' "$WORK/last" 2>/dev/null)"
  DGUID="$(jq -r '.data[0].processGuid // empty' "$WORK/last" 2>/dev/null)"
  if [[ -n "$DID" ]]; then run "deploy show" bash "$S/frends-deploy.sh" show --id "$DID"
  else skip "deploy show" "no deployment"; fi
else for s in "deploy list" "deploy show"; do skip "$s" "FRENDS_DEV_AGENT_GROUP_ID unset"; done; fi

# The list holds every version, deleted ones included; a deleted version cannot be exported.
LIVE='[.data[] | select(.isDeleted == false and .isNotLatestVersion == false)][0]'
pick_live() {
  PGUID="$(jq -r "$LIVE.uniqueIdentifier // empty" "$WORK/last" 2>/dev/null)"
  PVER="$(jq -r "$LIVE.version // empty" "$WORK/last" 2>/dev/null)"
  PID="$(jq -r "$LIVE.id // empty" "$WORK/last" 2>/dev/null)"
}
run "process-list" bash "$S/frends-process-list.sh" --size 50 --raw
pick_live
# A tenant with many deleted versions can fill the first page with them; fall back to a deployed Process.
if [[ -z "$PGUID" && -n "$DGUID" ]]; then
  NOTE="deployed Process $DGUID"
  run "process-list --guid (deployed)" bash "$S/frends-process-list.sh" --guid "$DGUID" --raw
  pick_live
fi

if [[ -n "$PGUID" && -n "$PVER" ]]; then
  if run "process-pull (guid, version)" bash "$S/frends-process-pull.sh" --guid "$PGUID" --version "$PVER" --out "$WORK/export.json"; then
    FV="$(python3 - "$WORK/export.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8-sig"))
p = d["Processes"][0] if isinstance(d, dict) and d.get("Processes") else d
print(f'FrendsVersion {p.get("FrendsVersion")}, TargetFramework {p.get("TargetFramework")}')
PY
)"
    RESULTS+=("INFO|export versions|$FV")
    run "generate_process.py --validate" python3 "$S/generate_process.py" --validate "$WORK/export.json"
    if [[ -f "$REVIEWER" ]]; then
      python3 "$REVIEWER" "$WORK/export.json" >> "$LOG" 2>&1
      rc=$?; [[ $rc -le 1 ]] && RESULTS+=("PASS|review_process.py on export|exit $rc (1 = findings)") || RESULTS+=("FAIL|review_process.py on export|exit $rc")
    fi
  fi
else skip "process-pull (guid, version)" "no live Process found"; fi
if [[ -n "$PID" ]]; then run "process-pull --batch" bash "$S/frends-process-pull.sh" --batch --ids "$PID" --out "$WORK/batch.json"
else skip "process-pull --batch" "no Process id"; fi

if [[ -n "$AG" ]]; then
  run "instances list" bash "$S/frends-instances.sh" list --agent-group "$AG" --size 5 --raw
  run "instances counts" bash "$S/frends-instances.sh" counts --agent-group "$AG"
else for s in "instances list" "instances counts"; do skip "$s" "FRENDS_DEV_AGENT_GROUP_ID unset"; done; fi

run "env-vars list" bash "$S/frends-env-vars.sh" list --raw
EID="$(first_id id)"
if [[ -n "$EID" ]]; then run "env-vars show" bash "$S/frends-env-vars.sh" show --id "$EID"
else skip "env-vars show" "no Environment Variable"; fi

run "tags all (Process)" bash "$S/frends-tags.sh" all --type Process
if [[ -n "$PGUID" ]]; then run "tags get" bash "$S/frends-tags.sh" get --guids "$PGUID"
else skip "tags get" "no Process guid"; fi

run "templates list" bash "$S/frends-templates.sh" list --raw
TID="$(first_id id)"
if [[ -n "$TID" ]]; then run "templates export" bash "$S/frends-templates.sh" export --ids "$TID" --out "$WORK/template.json"
else skip "templates export" "no Process Template"; fi

run "api-specs list" bash "$S/frends-api-specs.sh" list --raw
SID="$(first_id id)"
if [[ -n "$SID" ]]; then run "api-specs show" bash "$S/frends-api-specs.sh" show --id "$SID"
else skip "api-specs show" "no API specification"; fi

BASE="${FRENDS_API_BASE_URL:-https://${FRENDS_TENANT}.frendsapp.com}"; BASE="${BASE%/}"
SSL=""; [[ "${FRENDS_VERIFY_SSL:-true}" == "false" ]] && SSL="-k"
if curl -s $SSL --max-time 60 -o "$WORK/swagger.json" -H "Authorization: Bearer $(get_token)" "$BASE/v1.0/swagger.json" && jq -e .paths "$WORK/swagger.json" >/dev/null 2>&1; then
  run "check_api_drift.py (live OpenAPI)" python3 "$S/check_api_drift.py" "$WORK/swagger.json"
else skip "check_api_drift.py (live OpenAPI)" "could not fetch /v1.0/swagger.json"; fi

report
