#!/usr/bin/env bash
# Read and change tags on Frends elements via the Frends Platform API.
# The MCP server has no tag tools; this script is the route for tags.
#
# Subcommands:
#   get    --guids <guid,guid,...>                       GET    /api/v1/tags?elementIdentifiers=..
#   all    --type <Process|ProcessTemplate|PrivateApplication|ApiPolicy>
#                                                        GET    /api/v1/tags/{elementType}
#   add    --type <t> --guids <guid,...> --tags <tag,...> PATCH  /api/v1/tags   (adds)
#   set    --type <t> --guids <guid,...> --tags <tag,...> PUT    /api/v1/tags   (overwrites)
#   remove --type <t> --guids <guid,...> --tags <tag,...> DELETE /api/v1/tags   (removes those tags)
#
# add, set and remove change the tenant: run them only on the person's confirmation.
# STATUS: checked against the 6.3.2 OpenAPI document. Confirmed live on 6.3.2.5468
# (frends-smoke-test.sh, frends-write-test.sh): all, get, add and remove. set confirmed live on
# 2026-10-09 (Frends 6.3.2): it replaces the element's tags; get returns {} once no tag is left.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"

CMD="${1:-}"; shift || true
TYPE="Process" GUIDS="" TAGS=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --type) TYPE="$2"; shift 2;;
    --guids) GUIDS="$2"; shift 2;;
    --tags) TAGS="$2"; shift 2;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

load_env
require_tools curl jq

body() {
  jq -cn --arg t "$TYPE" --arg g "$GUIDS" --arg tags "$TAGS" \
    '{elementType:$t, elementGuids:($g|split(",")|map(select(length>0))), tags:($tags|split(",")|map(select(length>0)))}'
}

case "$CMD" in
  get)
    [[ -z "$GUIDS" ]] && { echo "ERROR: --guids required" >&2; exit 2; }
    QS=$(echo "$GUIDS" | tr ',' '\n' | sed '/^$/d' | sed 's/^/elementIdentifiers=/' | paste -sd'&' -)
    frends_api GET "tags?${QS}"
    expect_ok "Get tags" || exit 1
    echo "$RESPONSE_BODY" | jq '.data'
    ;;
  all)
    frends_api GET "tags/${TYPE}"
    expect_ok "Get all tags for ${TYPE}" || exit 1
    echo "$RESPONSE_BODY" | jq '.data // .'
    ;;
  add|set|remove)
    [[ -z "$GUIDS" || -z "$TAGS" ]] && { echo "ERROR: ${CMD} requires --guids and --tags" >&2; exit 2; }
    METHOD=$([[ "$CMD" == "add" ]] && echo PATCH || ([[ "$CMD" == "set" ]] && echo PUT || echo DELETE))
    frends_api "$METHOD" "tags" -H "Content-Type: application/json" -d "$(body)"
    expect_ok "Tags ${CMD}" || exit 1
    echo "Tags ${CMD}: ${TAGS} on ${GUIDS} (${TYPE})."
    ;;
  *)
    echo "Usage: frends-tags.sh <get|all|add|set|remove> [--type <t>] [--guids <..>] [--tags <..>]" >&2
    exit 2
    ;;
esac
log_activity "tags-${CMD}" "success" "$RESPONSE_CODE"
