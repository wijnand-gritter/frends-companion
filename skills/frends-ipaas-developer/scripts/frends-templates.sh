#!/usr/bin/env bash
# Work with Process Templates via the Frends Platform API.
# The MCP server has no template tools; this script is the route for templates.
#
# Subcommands:
#   list   [--name <substring>] [--type All|ProcessTemplatesOnly|SubprocessTemplatesOnly] [--raw]
#              GET  /api/v1/process-templates
#   export --ids <templateId,...> [--out <file>]
#              GET  /api/v1/process-templates/export?templateIds=..
#   create-process --id <templateId> --name "<process name>" [--description "<text>"]
#                  [--variables '<json array of ProcessVariable>']
#              POST /api/v1/process-templates/{templateId}/create-process
#
# create-process changes the tenant: run it only on the person's confirmation.
# A template is portable when its configuration is in Process Variables (#var) rather
# than Environment Variables (#env); see references/process-file-format/templates-and-imports.md.
# STATUS: checked against the 6.3.2 OpenAPI document. Confirmed live on 6.3.2.5468
# (frends-smoke-test.sh, frends-write-test.sh): list; export and create-process not yet run (no Process Template on the test tenant).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"

CMD="${1:-}"; shift || true
NAME="" TYPE="" IDS="" ID="" OUT="" DESC="" VARS="null" RAW="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2;;
    --type) TYPE="$2"; shift 2;;
    --ids) IDS="$2"; shift 2;;
    --id) ID="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    --description) DESC="$2"; shift 2;;
    --variables) VARS="$2"; shift 2;;
    --raw) RAW="true"; shift;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

load_env
require_tools curl jq

case "$CMD" in
  list)
    QS="PageSize=200"
    [[ -n "$NAME" ]] && QS="${QS}&processTemplateName=$(jq -rn --arg v "$NAME" '$v|@uri')"
    [[ -n "$TYPE" ]] && QS="${QS}&templateType=${TYPE}"
    frends_api GET "process-templates?${QS}"
    expect_ok "List Process Templates" || exit 1
    if [[ "$RAW" == "true" ]]; then echo "$RESPONSE_BODY" | jq '.'; else
      echo "$RESPONSE_BODY" | jq -r '.data[] | "id=\(.id)\t\(.name)\tv\(.majorVersion).\(.minorVersion)\tguid=\(.uniqueIdentifier)\(if .isSubprocess then "  [subprocess]" else "" end)"'
    fi
    ;;
  export)
    [[ -z "$IDS" ]] && { echo "ERROR: --ids required" >&2; exit 2; }
    QS=$(echo "$IDS" | tr ',' '\n' | sed '/^$/d' | sed 's/^/templateIds=/' | paste -sd'&' -)
    if [[ -z "$OUT" ]]; then mkdir -p active-development/templates; OUT="active-development/templates/templates_$(date -u +%Y%m%dT%H%M%SZ).json"; fi
    frends_api --out-file "$OUT" GET "process-templates/export?${QS}"
    [[ "$RESPONSE_CODE" =~ ^2[0-9][0-9]$ ]] || { echo "ERROR: export failed (HTTP ${RESPONSE_CODE})" >&2; rm -f "$OUT"; exit 1; }
    echo "Exported templates → ${OUT}"
    ;;
  create-process)
    [[ -z "$ID" || -z "$NAME" ]] && { echo "ERROR: create-process requires --id and --name" >&2; exit 2; }
    echo "$VARS" | jq -e . >/dev/null 2>&1 || { echo "ERROR: --variables must be valid JSON" >&2; exit 2; }
    BODY=$(jq -cn --arg n "$NAME" --arg d "$DESC" --argjson v "$VARS" '{name:$n, description:$d, ignoreProcessTags:false, processVariables:$v}')
    frends_api POST "process-templates/${ID}/create-process" -H "Content-Type: application/json" -d "$BODY"
    expect_ok "Create Process from Template" || exit 1
    echo "$RESPONSE_BODY" | jq '.'
    ;;
  *)
    echo "Usage: frends-templates.sh <list|export|create-process> [options]" >&2
    exit 2
    ;;
esac
log_activity "templates-${CMD}" "success" "$RESPONSE_CODE"
