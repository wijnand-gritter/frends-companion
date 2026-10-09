#!/usr/bin/env bash
# Inspect Process Instances (execution logs) via the Frends Platform API.
#
# Subcommands:
#   list   --agent-group <id> [--guid <uuid>] [--state <filter>]
#               [--start <iso8601>] [--end <iso8601>] [--size <n>] [--token <continuationToken>] [--raw]
#               GET /api/v1/instances/{agentGroupId}
#   details --agent-group <id> --exec <executionGuid>
#               GET /api/v1/instances/{agentGroupId}/{executionIdentifier}/details
#   counts  --agent-group <id> [--guid <uuid>] [--start <iso8601>] [--end <iso8601>]
#               GET /api/v1/instances/counts/{agentGroupId}
#   acknowledge --agent-group <id> --guid <processGuid> --ids <instanceId,...> --reason "<text>"
#               POST /api/v1/instances/{agentGroupId}/{processGuid}/acknowledge
#               (changes instance state: run only on the person's confirmation)
#
# --state one of: ShowAll ShowRunning ShowFinished ShowSuccessful ShowFailed ShowFailedNotAcknowledged
# Paging uses a continuation token: pass the printed nextContinuationToken back via --token.
# WARNING: when paging, do not change any other filter between calls or results are invalid.
# STATUS: checked against the 6.3.2 OpenAPI document. Confirmed live on 6.3.2.5468
# (frends-smoke-test.sh, frends-write-test.sh): list, counts and acknowledge. details confirmed live
# on 2026-10-09 (Frends 6.3.2): steps is null; the step data sits behind stepDataUri.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"

CMD="${1:-}"; shift || true
AG="" GUID="" STATE="" START="" END="" SIZE="50" TOKEN="" EXEC="" RAW="false" IDS="" REASON=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent-group) AG="$2"; shift 2;;
    --guid) GUID="$2"; shift 2;;
    --state) STATE="$2"; shift 2;;
    --start) START="$2"; shift 2;;
    --end) END="$2"; shift 2;;
    --size) SIZE="$2"; shift 2;;
    --token) TOKEN="$2"; shift 2;;
    --exec) EXEC="$2"; shift 2;;
    --ids) IDS="$2"; shift 2;;
    --reason) REASON="$2"; shift 2;;
    --raw) RAW="true"; shift;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

load_env
require_tools curl jq
[[ -z "$AG" ]] && { echo "ERROR: --agent-group <id> is required" >&2; exit 2; }

case "$CMD" in
  list)
    QS="pageSize=${SIZE}"
    [[ -n "$GUID" ]] && QS="${QS}&processGuids=${GUID}"
    [[ -n "$STATE" ]] && QS="${QS}&stateFilter=${STATE}"
    [[ -n "$START" ]] && QS="${QS}&startTime=$(jq -rn --arg v "$START" '$v|@uri')"
    [[ -n "$END" ]] && QS="${QS}&endTime=$(jq -rn --arg v "$END" '$v|@uri')"
    [[ -n "$TOKEN" ]] && QS="${QS}&continuationToken=$(jq -rn --arg v "$TOKEN" '$v|@uri')"
    frends_api GET "instances/${AG}?${QS}"
    expect_ok "List instances" || exit 1
    if [[ "$RAW" == "true" ]]; then echo "$RESPONSE_BODY" | jq '.'; else
      echo "$RESPONSE_BODY" | jq -r '.data[] | "exec=\(.executionId)\t\(.state)\t\(.startTimeUtc // "-") → \(.endTimeUtc // "-")\tprocGuid=\(.processGuid)"'
      echo "----"
      echo "$RESPONSE_BODY" | jq -r 'if .nextContinuationToken then "nextContinuationToken: \(.nextContinuationToken)" else "(no more pages)" end'
    fi
    ;;
  details)
    [[ -z "$EXEC" ]] && { echo "ERROR: --exec <executionGuid> required" >&2; exit 2; }
    frends_api GET "instances/${AG}/${EXEC}/details"
    expect_ok "Instance details" || exit 1
    echo "$RESPONSE_BODY" | jq '.'
    ;;
  counts)
    QS=""
    [[ -n "$GUID" ]] && QS="ProcessUniqueIdentifiers=${GUID}"
    [[ -n "$START" ]] && QS="${QS:+$QS&}StartTime=$(jq -rn --arg v "$START" '$v|@uri')"
    [[ -n "$END" ]] && QS="${QS:+$QS&}EndTime=$(jq -rn --arg v "$END" '$v|@uri')"
    frends_api GET "instances/counts/${AG}${QS:+?$QS}"
    expect_ok "Instance counts" || exit 1
    echo "$RESPONSE_BODY" | jq '.'
    ;;
  acknowledge)
    [[ -z "$GUID" || -z "$IDS" || -z "$REASON" ]] && { echo "ERROR: acknowledge requires --guid, --ids, --reason" >&2; exit 2; }
    BODY=$(jq -cn --arg r "$REASON" --arg ids "$IDS" '{reason:$r, instanceIds:($ids|split(",")|map(select(length>0)|tonumber))}')
    frends_api POST "instances/${AG}/${GUID}/acknowledge" -H "Content-Type: application/json" -d "$BODY"
    expect_ok "Acknowledge instances" || exit 1
    echo "Acknowledged instances ${IDS} of ${GUID}."
    ;;
  *)
    echo "Usage: frends-instances.sh <list|details|counts|acknowledge> --agent-group <id> [options]" >&2
    exit 2
    ;;
esac
log_activity "instances-${CMD}" "success" "$RESPONSE_CODE"
