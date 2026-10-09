#!/usr/bin/env bash
# Read API specifications (Frends API Management) via the Frends Platform API.
# The MCP server has no API management tools; this script is the read route.
#
# Subcommands:
#   list                                 GET /api/v1/api-management/api-specifications
#   show   --id <specId>                 GET /api/v1/api-management/api-specifications/{id}
#   version --id <specId> --api-version <n> [--out <file>]
#                                        GET /api/v1/api-management/api-specifications/{id}/{apiVersion}
#
# Publishing, deploying and deleting API specifications change the tenant and are done in
# the Control Panel or by the person; deploy an API together with its linked Processes.
# STATUS: checked against the 6.3.2 OpenAPI document. Confirmed live on 6.3.2.5468
# (frends-smoke-test.sh, frends-write-test.sh): list. show and version not yet run: the test tenant
# still had no API specification on 2026-10-09.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"

CMD="${1:-}"; shift || true
ID="" APIVER="" OUT="" RAW="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --id) ID="$2"; shift 2;;
    --api-version) APIVER="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    --raw) RAW="true"; shift;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

load_env
require_tools curl jq

case "$CMD" in
  list)
    frends_api GET "api-management/api-specifications?PageSize=200"
    expect_ok "List API specifications" || exit 1
    if [[ "$RAW" == "true" ]]; then echo "$RESPONSE_BODY" | jq '.'; else
      echo "$RESPONSE_BODY" | jq -r '.data[] | "id=\(.id)\t\(.name)\tactiveVersion=\(.activeVersion)"'
    fi
    ;;
  show)
    [[ -z "$ID" ]] && { echo "ERROR: --id required" >&2; exit 2; }
    frends_api GET "api-management/api-specifications/${ID}"
    expect_ok "Get API specification" || exit 1
    echo "$RESPONSE_BODY" | jq '.'
    ;;
  version)
    [[ -z "$ID" || -z "$APIVER" ]] && { echo "ERROR: version requires --id and --api-version" >&2; exit 2; }
    if [[ -n "$OUT" ]]; then
      frends_api --out-file "$OUT" GET "api-management/api-specifications/${ID}/${APIVER}"
      [[ "$RESPONSE_CODE" =~ ^2[0-9][0-9]$ ]] || { echo "ERROR: HTTP ${RESPONSE_CODE}" >&2; rm -f "$OUT"; exit 1; }
      echo "Saved → ${OUT}"
    else
      frends_api GET "api-management/api-specifications/${ID}/${APIVER}"
      expect_ok "Get API specification version" || exit 1
      echo "$RESPONSE_BODY" | jq '.'
    fi
    ;;
  *)
    echo "Usage: frends-api-specs.sh <list|show|version> [options]" >&2
    exit 2
    ;;
esac
log_activity "api-specs-${CMD}" "success" "$RESPONSE_CODE"
