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
# - The PUT body is the JSON value itself, in the same shape `show` returns in
#   values[].value, and of the variable's type (String, Number, Boolean, Array,
#   Secret, Object): --value '"my-value"', --value '30', --value '["a","b"]'.
#   Confirmed live with a String value: --value '"companion-test"' stores companion-test.
# - Setting a value changes the tenant: run `set` only on the person's confirmation.
#   Never pass a secret on the command line in a shared session; set secrets in the
#   Control Panel.
# - Deploy validation requires every used Environment Variable to have a value in
#   the target Environment, so set values before deploying to Test/Production.
# STATUS: checked against the 6.3.2 OpenAPI document. Confirmed live on 6.3.2.5468
# (frends-smoke-test.sh, frends-write-test.sh): list, show and set (a String value in Development).
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
    [[ -z "$ID" || -z "$ENVID" || -z "$VALUE" ]] && { echo "ERROR: set requires --id, --environment, --value '<json-value>'" >&2; exit 2; }
    # Validate the value is JSON before sending.
    echo "$VALUE" | jq -e . >/dev/null 2>&1 || { echo "ERROR: --value must be valid JSON (e.g. '\"my-value\"')" >&2; exit 2; }
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
