#!/usr/bin/env bash
# List Processes in the tenant (GET /api/v1/processes).
# Usage:
#   bash scripts/frends-process-list.sh [--name <substring>] [--guid <uuid>] [--page N] [--size N] [--all] [--raw]
#
# Prints a compact table (name, guid, latest version) unless --raw is given.
# The API returns every version, deleted and outdated ones included, with the full BPMN; the table
# shows only live latest versions unless --all is given. A deleted version cannot be exported (HTTP 400).
# STATUS: checked against the 6.3.2 OpenAPI document. Confirmed live on 6.3.2.5468
# (frends-smoke-test.sh, frends-write-test.sh): the whole script.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"

NAME="" GUID="" PAGE="1" SIZE="50" RAW="false" ALL="false" PAGE_SET="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2;;
    --guid) GUID="$2"; shift 2;;
    --page) PAGE="$2"; PAGE_SET="true"; shift 2;;
    --size) SIZE="$2"; shift 2;;
    --raw) RAW="true"; shift;;
    --all) ALL="true"; shift;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

load_env
require_tools curl jq

FILTER=""
[[ -n "$NAME" ]] && FILTER="${FILTER}&processName=$(jq -rn --arg v "$NAME" '$v|@uri')"
[[ -n "$GUID" ]] && FILTER="${FILTER}&processGuid=${GUID}"

fetch_page() {
  frends_api GET "processes?PageNumber=$1&PageSize=${SIZE}${FILTER}"
  expect_ok "List Processes" || exit 1
}

ROW='"\(.name)\t\(.uniqueIdentifier)\tv\(.majorVersion).\(.minorVersion) (build \(.version))\(if .isSubprocess then "  [subprocess]" else "" end)\(if .isDeleted then "  [deleted]" elif .isNotLatestVersion then "  [outdated]" else "" end)"'
LIVE='select(.isDeleted != true and .isNotLatestVersion != true)'

if [[ "$RAW" == "true" ]]; then
  fetch_page "$PAGE"
  echo "$RESPONSE_BODY" | jq '.'
elif [[ "$ALL" == "true" || "$PAGE_SET" == "true" ]]; then
  # One page as requested; --all shows every version on it.
  fetch_page "$PAGE"
  echo "$RESPONSE_BODY" | jq -r --argjson all "$ALL" "
    ([.data[] | if \$all then . else ${LIVE} end]) as \$rows |
    \"Total: \\(.paging.totalCount) versions (page \\(.paging.currentPage), size \\(.paging.pageSize)); shown: \\(\$rows | length)\",
    \"----\",
    (\$rows[] | ${ROW})"
else
  # Default: walk the pages (max 20) and show only live latest versions; deleted and
  # outdated versions fill the API's pages on tenants with history.
  fetch_page 1
  TOTAL="$(echo "$RESPONSE_BODY" | jq -r '.paging.totalCount // 0')"
  PAGES=$(( (TOTAL + SIZE - 1) / SIZE )); (( PAGES > 20 )) && PAGES=20
  ROWS="$(echo "$RESPONSE_BODY" | jq -r ".data[] | ${LIVE} | ${ROW}")"
  for (( n = 2; n <= PAGES; n++ )); do
    fetch_page "$n"
    MORE="$(echo "$RESPONSE_BODY" | jq -r ".data[] | ${LIVE} | ${ROW}")"
    [[ -n "$MORE" ]] && ROWS="${ROWS:+$ROWS$'\n'}$MORE"
  done
  COUNT=0; [[ -n "$ROWS" ]] && COUNT="$(printf '%s\n' "$ROWS" | wc -l | tr -d ' ')"
  echo "Live latest versions: ${COUNT} (of ${TOTAL} versions, ${PAGES} page(s) read; --all for every version)"
  echo "----"
  [[ -n "$ROWS" ]] && printf '%s\n' "$ROWS"
fi
log_activity "process-list" "success" "$RESPONSE_CODE"
