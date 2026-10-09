#!/usr/bin/env bash
# Inspect Environments and Agent Groups via the Frends Platform API.
#
# Subcommands:
#   list                       GET /api/v1/environments, then
#                              GET /api/v1/environments/{environmentId}/agent-groups
#   show --id <agentGroupId>   GET /api/v1/agent-groups/{agentGroupId}
#
# The Platform API has no flat Agent Group list; groups are listed per Environment.
# An Agent Group belongs to exactly one Environment, holds one or more Agents, and has
# a framework flag (isCrossPlatform). Agent Group IDs are needed for deploys and for
# listing Process Instances. On the MCP route, get_overview returns the same data.
# STATUS: checked against the 6.3.2 OpenAPI document. Confirmed live on 6.3.2.5468
# (frends-smoke-test.sh, frends-write-test.sh): list and show.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"

CMD="${1:-}"; shift || true
ID="" RAW="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --id) ID="$2"; shift 2;;
    --raw) RAW="true"; shift;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

load_env
require_tools curl jq

case "$CMD" in
  show)
    [[ -z "$ID" ]] && { echo "ERROR: --id <agentGroupId> required" >&2; exit 2; }
    frends_api GET "agent-groups/${ID}"
    expect_ok "Get Agent Group" || exit 1
    if [[ "$RAW" == "true" ]]; then echo "$RESPONSE_BODY" | jq '.'; else
      echo "$RESPONSE_BODY" | jq -r '.data | "id=\(.id)\t\(.displayName)\tenv=\(.environment.displayName)\tmode=\(.agentRegistrationMode)\tcrossPlatform=\(.isCrossPlatform)\tagents=[\((.agents // [])|join(", "))]"'
    fi
    ;;
  list)
    frends_api GET "environments"
    expect_ok "List Environments" || exit 1
    ENVS="$RESPONSE_BODY"
    if [[ "$RAW" == "true" ]]; then echo "$ENVS" | jq '.'; exit 0; fi
    for ENV_ID in $(echo "$ENVS" | jq -r '.data[].id'); do
      ENV_NAME=$(echo "$ENVS" | jq -r --argjson id "$ENV_ID" '.data[] | select(.id == $id) | .displayName')
      frends_api GET "environments/${ENV_ID}/agent-groups"
      expect_ok "List Agent Groups for Environment ${ENV_ID}" || exit 1
      echo "$RESPONSE_BODY" | jq -r --arg env "$ENV_NAME" --arg envid "$ENV_ID" \
        '.data[] | "env=\($env) (\($envid))\tagentGroup=\(.displayName) (\(.id))\tmode=\(.agentRegistrationMode)\tcrossPlatform=\(.isCrossPlatform)"'
    done
    ;;
  *)
    echo "Usage: frends-agentgroups.sh <list | show --id <n>> [--raw]" >&2
    exit 2
    ;;
esac
log_activity "agentgroups-${CMD}" "success" "$RESPONSE_CODE"
