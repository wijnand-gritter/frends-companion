#!/usr/bin/env bash
# Manage Process deployments via the Frends Platform API.
#
# Subcommands:
#   list    [--agent-group <id>] [--name <substring>] [--guid <uuid>] [--raw]
#               GET  /api/v1/process-deployments
#   deploy  --agent-group <id> --guid <uuid> --version <n>
#               [--no-activate] [--description "<text>"]
#               POST /api/v1/process-deployments  (deploys up to 1 Process per call here)
#   show    --id <deploymentId>
#               GET  /api/v1/process-deployments/{id}
#   undeploy --id <deploymentId>
#               DELETE /api/v1/process-deployments/{id}   (not allowed for Development)
#   activate   --id <deploymentId>     PUT    /api/v1/process-deployments/{id}/activation
#   deactivate --id <deploymentId>     DELETE /api/v1/process-deployments/{id}/activation
#   run     --id <deploymentId> [--params '<json-object-of-strings>']
#               POST /api/v1/process-deployments/{id}/execute
#
# deploy, undeploy, activate, deactivate and run change the tenant: run them only on
# the person's explicit confirmation.
#
# Deploy validation rules (enforced by the platform): all used Environment
# Variables must have values in the target Environment; all used Subprocesses
# must already be deployed there; the Process target framework must match the
# Agent Group framework.
# STATUS: checked against the 6.3.2 OpenAPI document. Confirmed live on 6.3.2.5468
# (frends-smoke-test.sh, frends-write-test.sh): list, show, deploy, activate, deactivate and run.
# undeploy confirmed live on 2026-10-09 (Frends 6.3.2) on a Test Agent Group deployment; show on the
# removed id then returns HTTP 404. Development forbids undeploy.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"

CMD="${1:-}"; shift || true
AG="" GUID="" VERSION="" ID="" NAME="" DESC="" ACTIVATE="true" PARAMS="{}" RAW="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent-group) AG="$2"; shift 2;;
    --guid) GUID="$2"; shift 2;;
    --version) VERSION="$2"; shift 2;;
    --id) ID="$2"; shift 2;;
    --name) NAME="$2"; shift 2;;
    --description) DESC="$2"; shift 2;;
    --no-activate) ACTIVATE="false"; shift;;
    --params) PARAMS="$2"; shift 2;;
    --raw) RAW="true"; shift;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

load_env
require_tools curl jq

case "$CMD" in
  list)
    QS="PageSize=200"
    [[ -n "$AG" ]] && QS="${QS}&agentGroupId=${AG}"
    [[ -n "$NAME" ]] && QS="${QS}&processName=$(jq -rn --arg v "$NAME" '$v|@uri')"
    [[ -n "$GUID" ]] && QS="${QS}&processGuid=${GUID}"
    frends_api GET "process-deployments?${QS}"
    expect_ok "List deployments" || exit 1
    if [[ "$RAW" == "true" ]]; then echo "$RESPONSE_BODY" | jq '.'; else
      echo "$RESPONSE_BODY" | jq -r '.data[] | "id=\(.deploymentId)\t\(.processName)\tv\(.processVersion)\tAG:\(.agentGroup.displayName)\ttriggers:\(if .triggersActive then "active" else "inactive" end)"'
    fi
    ;;
  deploy)
    require_env_msg() { echo "ERROR: deploy requires --agent-group, --guid, --version" >&2; exit 2; }
    [[ -z "$AG" || -z "$GUID" || -z "$VERSION" ]] && require_env_msg
    BODY=$(jq -cn --argjson ag "$AG" --arg guid "$GUID" --argjson ver "$VERSION" \
      --argjson act "$ACTIVATE" --arg desc "$DESC" \
      '{agentGroupId:$ag, activateTriggers:$act, deploymentDescription:$desc,
        processes:[{processGuid:$guid, version:$ver}]}')
    frends_api POST "process-deployments" -H "Content-Type: application/json" -d "$BODY"
    expect_ok "Deploy Process" || exit 1
    echo "Deployed:"
    echo "$RESPONSE_BODY" | jq -r '.data[]? | "  id=\(.deploymentId)  \(.processName) v\(.processVersion) → \(.agentGroup.displayName)  triggers:\(if .triggersActive then "active" else "inactive" end)"' 2>/dev/null || echo "$RESPONSE_BODY"
    ;;
  show)
    [[ -z "$ID" ]] && { echo "ERROR: --id required" >&2; exit 2; }
    frends_api GET "process-deployments/${ID}"
    expect_ok "Get deployment" || exit 1
    echo "$RESPONSE_BODY" | jq '.'
    ;;
  undeploy)
    [[ -z "$ID" ]] && { echo "ERROR: --id required" >&2; exit 2; }
    frends_api DELETE "process-deployments/${ID}"
    expect_ok "Undeploy" || exit 1
    echo "Undeployed deployment ${ID}."
    ;;
  activate)
    [[ -z "$ID" ]] && { echo "ERROR: --id required" >&2; exit 2; }
    frends_api PUT "process-deployments/${ID}/activation"
    expect_ok "Activate triggers" || exit 1
    echo "Triggers activated for deployment ${ID}."
    ;;
  deactivate)
    [[ -z "$ID" ]] && { echo "ERROR: --id required" >&2; exit 2; }
    frends_api DELETE "process-deployments/${ID}/activation"
    expect_ok "Deactivate triggers" || exit 1
    echo "Triggers deactivated for deployment ${ID}."
    ;;
  run)
    [[ -z "$ID" ]] && { echo "ERROR: --id required" >&2; exit 2; }
    frends_api POST "process-deployments/${ID}/execute" -H "Content-Type: application/json" -d "$PARAMS"
    expect_ok "Run Process" || exit 1
    echo "Run requested (HTTP ${RESPONSE_CODE}). Poll the Location header / Process Instances for the result."
    [[ -n "$RESPONSE_BODY" ]] && echo "$RESPONSE_BODY"
    ;;
  *)
    echo "Usage: frends-deploy.sh <list|deploy|show|undeploy|activate|deactivate|run> [options]" >&2
    echo "See the header of this script for option details." >&2
    exit 2
    ;;
esac
log_activity "deploy-${CMD}" "success" "$RESPONSE_CODE"
