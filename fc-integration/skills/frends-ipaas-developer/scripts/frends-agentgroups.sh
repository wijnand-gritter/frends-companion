#!/usr/bin/env bash
# Inspect Agent Groups via the Frends Platform API.
#
# Subcommands:
#   show --id <agentGroupId>   GET /api/v1/agent-groups/{agentGroupId}
#   list                       GET /api/v1/agent-groups   <-- TODO: confirm exact
#                              list path/shape against your tenant /swagger; the
#                              reference documents the single-group GET explicitly.
#
# An Agent Group belongs to exactly one Environment (group.environment), holds one
# or more Agents, and has a framework flag (isCrossPlatform). You need Agent Group
# IDs for deploys and for listing Process Instances.
# STATUS: scaffolded, not live-tested. See frends-common.sh header.
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
      echo "$RESPONSE_BODY" | jq -r '.data | "id=\(.id)\t\(.displayName)\tenv=\(.environment.displayName)\tcrossPlatform=\(.isCrossPlatform)\tagents=[\((.agents // [])|join(", "))]"'
    fi
    ;;
  list)
    # The published reference documents GET /agent-groups/{id}. A plain
    # GET /agent-groups list is the conventional companion route; confirm before use.
    frends_api GET "agent-groups"
    if [[ "$RESPONSE_CODE" == "404" || "$RESPONSE_CODE" == "405" ]]; then
      echo "NOTE: GET /agent-groups returned HTTP ${RESPONSE_CODE}. The list route may differ on your tenant." >&2
      echo "Open https://${FRENDS_TENANT:-<tenant>}.frendsapp.com/swagger and check the AgentGroups section for the correct list endpoint." >&2
      exit 1
    fi
    expect_ok "List Agent Groups" || exit 1
    echo "$RESPONSE_BODY" | jq '.'
    ;;
  *)
    echo "Usage: frends-agentgroups.sh <show --id <n> | list>" >&2
    exit 2
    ;;
esac
log_activity "agentgroups-${CMD}" "success" "$RESPONSE_CODE"
