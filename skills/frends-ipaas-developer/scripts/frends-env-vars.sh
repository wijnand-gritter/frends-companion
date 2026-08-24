#!/usr/bin/env bash
# Manage Environment Variables via the Frends Platform API.
#
# Subcommands:
#   list   [--name <substring>] [--raw]    GET /api/v1/environment-variables
#   show   --id <schemaId>                 GET /api/v1/environment-variables/{id}
#   set    --id <schemaId> --environment <environmentId> --value '<json>'
#               PUT /api/v1/environment-variables/{schemaId}/values/{environmentId}
#
# Notes:
# - The PUT body is a JSON array; the value type must match the variable's schema
#   type (String/Number/Boolean/Array/Secret/Object). For a plain string value
#   pass e.g. --value '["my-value"]'. Confirm the exact shape in /swagger.
# - Deploy validation requires every used Environment Variable to have a value in
#   the target Environment, so set values before deploying to Test/Production.
# STATUS: scaffolded, not live-tested. See frends-common.sh header.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"

CMD="${1:-}"; shift || true
NAME="" ID="" ENVID="" VALUE="" RAW="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2;;
    --id) ID="$2"; shift 2;;
    --environment) ENVID="$2"; shift 2;;
    --value) VALUE="$2"; shift 2;;
    --raw) RAW="true"; shift;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

load_env
require_tools curl jq

case "$CMD" in
  list)
    QS="PageSize=200"
    [[ -n "$NAME" ]] && QS="${QS}&environmentVariableName=$(jq -rn --arg v "$NAME" '$v|@uri')"
    frends_api GET "environment-variables?${QS}"
    expect_ok "List environment variables" || exit 1
    if [[ "$RAW" == "true" ]]; then echo "$RESPONSE_BODY" | jq '.'; else
      echo "$RESPONSE_BODY" | jq -r '.data[] | "id=\(.id)\t\(.name)\t(\(.type))\tenvs:[\((.values // [])|map(.environment.displayName)|join(", "))]"'
    fi
    ;;
  show)
    [[ -z "$ID" ]] && { echo "ERROR: --id required" >&2; exit 2; }
    frends_api GET "environment-variables/${ID}"
    expect_ok "Get environment variable" || exit 1
    echo "$RESPONSE_BODY" | jq '.'
    ;;
  set)
    [[ -z "$ID" || -z "$ENVID" || -z "$VALUE" ]] && { echo "ERROR: set requires --id, --environment, --value '<json-array>'" >&2; exit 2; }
    # Validate the value is JSON before sending.
    echo "$VALUE" | jq -e . >/dev/null 2>&1 || { echo "ERROR: --value must be valid JSON (e.g. '[\"my-value\"]')" >&2; exit 2; }
    frends_api PUT "environment-variables/${ID}/values/${ENVID}" -H "Content-Type: application/json" -d "$VALUE"
    expect_ok "Update environment variable value" || exit 1
    echo "Updated env-var ${ID} value in environment ${ENVID}."
    ;;
  *)
    echo "Usage: frends-env-vars.sh <list|show|set> [options]" >&2
    exit 2
    ;;
esac
log_activity "envvars-${CMD}" "success" "$RESPONSE_CODE"
