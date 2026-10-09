#!/usr/bin/env bash
# Live test of the Platform API operations that change the tenant, on a throwaway Process only.
# Run it only after the person confirms; without --confirm it prints the plan and stops.
#
# Usage:
#   bash scripts/frends-write-test.sh                      # print the plan, change nothing
#   bash scripts/frends-write-test.sh --confirm --frends-version 6.3.2.5468
#        [--env-var-id <schemaId> --env-value '<json>']    # optional: set one test variable in Development
#
# Steps, all in the Development Environment:
#   1  generate "Test - Companion write check" (manual trigger, Code shape, Return) with
#      generate_process.py, using --frends-version and FRENDS_TARGET_FRAMEWORK; validate it
#   2  process-push --conflict Error              (new Process)
#   3  process-push --conflict NewVersion         (second version of the same Process)
#   4  tags add / get / remove "companion-test"
#   5  deploy to FRENDS_DEV_AGENT_GROUP_ID without activation, show, activate, deactivate
#   6  run, then list its instances, then acknowledge the newest instance
#   7  env-vars set (only with --env-var-id; Development Environment FRENDS_DEV_ENVIRONMENT_ID)
#
# Leaves the test Process in Development: the API does not undeploy from Development. Delete it
# in the Control Panel afterwards. Stops on 401, 403, a token error or an unreachable host.
# Log: active-development/feedback/api-write-<timestamp>.log
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
S="$SCRIPT_DIR"
CONFIRM="false" FV="" EVID="" EVAL=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --confirm) CONFIRM="true"; shift;;
    --frends-version) FV="$2"; shift 2;;
    --env-var-id) EVID="$2"; shift 2;;
    --env-value) EVAL="$2"; shift 2;;
    -h|--help) sed -n '2,22p' "$0"; exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done
if [[ "$CONFIRM" != "true" ]]; then sed -n '2,22p' "$0"; echo; echo "Nothing changed. Re-run with --confirm after the person agrees."; exit 0; fi

# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"
set +e
load_env
require_tools curl jq python3
require_env FRENDS_DEV_AGENT_GROUP_ID
[[ -z "$FV" ]] && { echo "ERROR: --frends-version is required (the tenant's FrendsVersion, e.g. from frends-smoke-test.sh)" >&2; exit 2; }
TF="${FRENDS_TARGET_FRAMEWORK:-}"
[[ -z "$TF" ]] && { echo "ERROR: set FRENDS_TARGET_FRAMEWORK in .env (net10.0 on 6.3)" >&2; exit 2; }
AG="$FRENDS_DEV_AGENT_GROUP_ID"

TS="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p active-development/feedback
LOG="active-development/feedback/api-write-$TS.log"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
RESULTS=()
report() {
  echo
  printf '%-5s | %-38s | %s\n' "RESULT" "STEP" "NOTE"
  printf '%s\n' "------+----------------------------------------+-------------------------------"
  for r in "${RESULTS[@]}"; do IFS='|' read -r a b c <<< "$r"; printf '%-5s | %-38s | %s\n' "$a" "$b" "$c"; done
  echo; echo "Log: $LOG"
  [[ -n "${GUID:-}" ]] && echo "Test Process guid ${GUID}: delete it in the Control Panel when done."
}
run() {
  local name="$1"; shift
  { echo; echo "=== $name"; echo "\$ $*"; } >> "$LOG"
  "$@" > "$WORK/last" 2>&1; local rc=$?
  cat "$WORK/last" >> "$LOG"
  if grep -qE "HTTP 40[13]|Failed to obtain bearer token|cannot reach" "$WORK/last"; then
    RESULTS+=("FAIL|$name|$(grep -m1 -E 'HTTP 40[13]|bearer token|cannot reach' "$WORK/last" | cut -c1-120)")
    report; echo "Stopped." >&2; exit 1
  fi
  if [[ $rc -eq 0 ]]; then RESULTS+=("PASS|$name|${NOTE:-}"); else RESULTS+=("FAIL|$name|$(grep -m1 -E 'ERROR|error' "$WORK/last" | cut -c1-120)"); fi
  NOTE=""; return $rc
}

# 1 generate and validate
cat > "$WORK/spec.json" <<JSON
{
  "name": "Test - Companion write check",
  "description": "Throwaway Process for the frends-companion write test. Delete after use.",
  "frendsVersion": "$FV",
  "targetFramework": "$TF",
  "trigger": { "type": "manual" },
  "steps": [ { "type": "codeTask", "name": "Build check message", "assignTo": "message",
               "code": "return \"companion write check \" + DateTime.UtcNow.ToString(\"o\");" } ],
  "return": { "type": "expression", "value": "#var.message" }
}
JSON
run "generate test Process" python3 "$S/generate_process.py" "$WORK/spec.json" -o "$WORK/test.json" || { report; exit 1; }
run "validate test Process" python3 "$S/generate_process.py" --validate "$WORK/test.json" || { report; exit 1; }

# 2 and 3 import, then import again as a new version
run "process-push --conflict Error" bash "$S/frends-process-push.sh" --file "$WORK/test.json" --conflict Error || { report; exit 1; }
GUID="$(grep -oE 'guid=[0-9a-fA-F-]{36}' "$WORK/last" | head -1 | cut -d= -f2)"
[[ -z "$GUID" ]] && GUID="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1],encoding='utf-8-sig')); p=d['Processes'][0] if 'Processes' in d else d; print(p['UniqueIdentifier'])" "$WORK/test.json")"
RESULTS[${#RESULTS[@]}-1]="PASS|process-push --conflict Error|guid $GUID"
run "process-push --conflict NewVersion" bash "$S/frends-process-push.sh" --file "$WORK/test.json" --conflict NewVersion
run "process-list --guid" bash "$S/frends-process-list.sh" --guid "$GUID" --raw
VER="$(jq -r '[.data[] | select(.isDeleted != true and .isNotLatestVersion != true)][0].version // empty' "$WORK/last")"

# 4 tags
run "tags add" bash "$S/frends-tags.sh" add --type Process --guids "$GUID" --tags companion-test
run "tags get" bash "$S/frends-tags.sh" get --guids "$GUID"
grep -q "companion-test" "$WORK/last" || RESULTS[${#RESULTS[@]}-1]="FAIL|tags get|tag companion-test not returned"
run "tags remove" bash "$S/frends-tags.sh" remove --type Process --guids "$GUID" --tags companion-test

# 5 deploy and activation
if [[ -n "$VER" ]]; then
  run "deploy (no activation)" bash "$S/frends-deploy.sh" deploy --agent-group "$AG" --guid "$GUID" --version "$VER" --no-activate --description "companion write test"
  # Match id= as a whole word, so the leading digits of a guid=... never count.
  DID="$(grep -oE '(^|[[:space:]])id=[0-9]+' "$WORK/last" | head -1 | cut -d= -f2)"
  if [[ -n "$DID" ]]; then
    run "deploy show" bash "$S/frends-deploy.sh" show --id "$DID"
    run "activate" bash "$S/frends-deploy.sh" activate --id "$DID"
    run "deactivate" bash "$S/frends-deploy.sh" deactivate --id "$DID"
    # 6 run, instances, acknowledge
    run "run" bash "$S/frends-deploy.sh" run --id "$DID"
    sleep 15
    run "instances list --guid" bash "$S/frends-instances.sh" list --agent-group "$AG" --guid "$GUID" --size 5 --raw
    IID="$(jq -r '.data[0].id // empty' "$WORK/last")"
    # The run call only says the request was accepted (HTTP 202); the instance state says how it ended.
    STATE="$(jq -r '.data[0].state // empty' "$WORK/last")"
    if [[ "$STATE" == "Finished" ]]; then RESULTS[${#RESULTS[@]}-1]="PASS|instances list --guid|instance $IID Finished"
    else RESULTS[${#RESULTS[@]}-1]="FAIL|instances list --guid|instance ${IID:-none} state ${STATE:-not found}"; fi
    if [[ -n "$IID" ]]; then run "instances acknowledge" bash "$S/frends-instances.sh" acknowledge --agent-group "$AG" --guid "$GUID" --ids "$IID" --reason "companion write test"
    else RESULTS+=("SKIP|instances acknowledge|no instance found yet"); fi
  else RESULTS+=("SKIP|deploy show, activation, run|no deployment id in the deploy output"); fi
else RESULTS+=("SKIP|deploy and run|no live version found for $GUID"); fi

# 7 optional Environment Variable value
if [[ -n "$EVID" ]]; then
  require_env FRENDS_DEV_ENVIRONMENT_ID
  run "env-vars set (Development)" bash "$S/frends-env-vars.sh" set --id "$EVID" --environment "$FRENDS_DEV_ENVIRONMENT_ID" --value "${EVAL:-\"companion-test\"}"
  run "env-vars show" bash "$S/frends-env-vars.sh" show --id "$EVID"
else RESULTS+=("SKIP|env-vars set|no --env-var-id given"); fi

report
