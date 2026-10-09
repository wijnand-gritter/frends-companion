#!/usr/bin/env bash
# Push (import) one or more Processes from an export file.
# POST /api/v1/processes/batch-import   (multipart/form-data: file, importConflict)
#
# Usage:
#   bash scripts/frends-process-push.sh --file <export.json> [--conflict <mode>]
#
# importConflict modes (default Error, the API default; pass NewVersion to update a Process):
#   Error              - fail if the Process GUID already exists
#   UseExisting        - skip Processes that already exist
#   NewVersion         - update the existing Process to the imported one
#   NewActiveElement   - create a new Process with an Activated Trigger
#   NewInactiveElement - create a new Process with a Deactivated Trigger
#
# Run only on the person's explicit confirmation: an import changes the tenant.
# Importing only creates/updates the Process in Development; deploy separately
# with frends-deploy.sh. Import can be slow — timeout is raised accordingly.
# STATUS: checked against the 6.3.2 OpenAPI document; not yet run live. See frends-common.sh header.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"

FILE="" CONFLICT="Error"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file) FILE="$2"; shift 2;;
    --conflict) CONFLICT="$2"; shift 2;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

[[ -z "$FILE" ]] && { echo "ERROR: --file <export.json> is required" >&2; exit 2; }
[[ ! -f "$FILE" ]] && { echo "ERROR: file not found: $FILE" >&2; exit 2; }

load_env
require_tools curl jq

# Long timeout — batch import can be slow.
FRENDS_TIMEOUT="${FRENDS_TIMEOUT:-600}"
frends_api POST "processes/batch-import" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@${FILE}" \
  -F "importConflict=${CONFLICT}"

expect_ok "Import Process(es)" || exit 1
echo "Imported successfully:"
echo "$RESPONSE_BODY" | jq -r '.data | "  \(.name)  guid=\(.elementIdentifier)  id=\(.id)  v\(.version)"' 2>/dev/null || echo "$RESPONSE_BODY"
log_activity "process-push" "success" "$RESPONSE_CODE" "$(jq -cn --arg f "$FILE" --arg c "$CONFLICT" '{file:$f,conflict:$c}')"
