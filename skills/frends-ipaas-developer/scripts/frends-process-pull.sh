#!/usr/bin/env bash
# Pull (export) a Process to a local file.
# GET /api/v1/processes/{processGuid}/versions/{processVersion}/export
#   (or GET /api/v1/processes/{id}/export when --id is used)
#
#   (or GET /api/v1/processes/batch-export?ids=..&ids=.. when --batch is used)
#
# Usage:
#   bash scripts/frends-process-pull.sh --guid <uuid> --version <n> [--out <file>]
#   bash scripts/frends-process-pull.sh --id <processVersionId> [--out <file>]
#   bash scripts/frends-process-pull.sh --batch --ids <id,id,...> [--out <file>]
#
# Process Variable values in the export are taken from the Development Agent Group.
# Default output dir: active-development/processes/
# STATUS: checked against the 6.3.2 OpenAPI document. Confirmed live on 6.3.2.5468
# (frends-smoke-test.sh, frends-write-test.sh): --guid/--version and --batch; --id not yet run.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"

GUID="" VERSION="" ID="" OUT="" BATCH="false" IDS=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --guid) GUID="$2"; shift 2;;
    --version) VERSION="$2"; shift 2;;
    --id) ID="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    --batch) BATCH="true"; shift;;
    --ids) IDS="$2"; shift 2;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

load_env
require_tools curl jq

if [[ "$BATCH" == "true" ]]; then
  [[ -z "$IDS" ]] && { echo "ERROR: --batch needs --ids <id,id,...>" >&2; exit 2; }
  QS=$(echo "$IDS" | tr ',' '\n' | sed '/^$/d' | sed 's/^/ids=/' | paste -sd'&' -)
  ENDPOINT="processes/batch-export?${QS}"
  BASENAME="processes_batch_$(date -u +%Y%m%dT%H%M%SZ).json"
elif [[ -n "$ID" ]]; then
  ENDPOINT="processes/${ID}/export"
  BASENAME="process_${ID}.json"
elif [[ -n "$GUID" && -n "$VERSION" ]]; then
  ENDPOINT="processes/${GUID}/versions/${VERSION}/export"
  BASENAME="process_${GUID}_v${VERSION}.json"
else
  echo "ERROR: provide either --id <n>, or --guid <uuid> --version <n>" >&2
  exit 2
fi

if [[ -z "$OUT" ]]; then
  mkdir -p active-development/processes
  OUT="active-development/processes/${BASENAME}"
fi

frends_api --out-file "$OUT" GET "$ENDPOINT"
if [[ ! "$RESPONSE_CODE" =~ ^2[0-9][0-9]$ ]]; then
  echo "ERROR: export failed (HTTP ${RESPONSE_CODE})" >&2
  head -c 500 "$OUT" >&2 2>/dev/null || true
  rm -f "$OUT"
  exit 1
fi
echo "Pulled Process export → ${OUT}"
echo "Tip: this is the proprietary full-Process JSON. See references/process-file-format/ to parse or regenerate it."
log_activity "process-pull" "success" "$RESPONSE_CODE" "$(jq -cn --arg o "$OUT" '{out:$o}')"
