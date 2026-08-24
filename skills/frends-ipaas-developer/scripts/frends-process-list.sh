#!/usr/bin/env bash
# List Processes in the tenant (GET /api/v1/processes).
# Usage:
#   bash scripts/frends-process-list.sh [--name <substring>] [--guid <uuid>] [--page N] [--size N] [--raw]
#
# Prints a compact table (name, guid, latest version) unless --raw is given.
# STATUS: scaffolded, not live-tested. See frends-common.sh header.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"

NAME="" GUID="" PAGE="1" SIZE="50" RAW="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2;;
    --guid) GUID="$2"; shift 2;;
    --page) PAGE="$2"; shift 2;;
    --size) SIZE="$2"; shift 2;;
    --raw) RAW="true"; shift;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

load_env
require_tools curl jq

QS="PageNumber=${PAGE}&PageSize=${SIZE}"
[[ -n "$NAME" ]] && QS="${QS}&processName=$(jq -rn --arg v "$NAME" '$v|@uri')"
[[ -n "$GUID" ]] && QS="${QS}&processGuid=${GUID}"

frends_api GET "processes?${QS}"
expect_ok "List Processes" || exit 1

if [[ "$RAW" == "true" ]]; then
  echo "$RESPONSE_BODY" | jq '.'
else
  echo "$RESPONSE_BODY" | jq -r '
    "Total: \(.paging.totalCount)  (page \(.paging.currentPage), size \(.paging.pageSize))",
    "----",
    (.data[] | "\(.name)\t\(.uniqueIdentifier)\tv\(.majorVersion).\(.minorVersion) (build \(.version))\(if .isSubprocess then "  [subprocess]" else "" end)")
  '
fi
log_activity "process-list" "success" "$RESPONSE_CODE"
