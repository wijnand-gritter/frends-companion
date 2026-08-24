#!/usr/bin/env bash
# Show which .env variables are SET vs UNSET (never prints values).
# Usage: bash scripts/frends-env-check.sh
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"

load_env

echo "=== Frends .env Variable Status ==="
# Known variables the scripts care about, plus anything else present in .env.
KNOWN="FRENDS_TENANT FRENDS_API_BASE_URL FRENDS_AZURE_TENANT FRENDS_CLIENT_ID FRENDS_CLIENT_SECRET FRENDS_APPLICATION_URI FRENDS_DEV_AGENT_GROUP_ID FRENDS_TEST_AGENT_GROUP_ID FRENDS_PROD_AGENT_GROUP_ID FRENDS_DEV_ENVIRONMENT_ID FRENDS_TEST_ENVIRONMENT_ID FRENDS_PROD_ENVIRONMENT_ID FRENDS_TARGET_FRAMEWORK FRENDS_VERIFY_SSL"
for name in $KNOWN; do
  if [[ -n "${!name:-}" ]]; then echo "  $name=SET"; else echo "  $name=UNSET"; fi
done

echo "--- other variables found in .env ---"
grep -v '^\s*#' .env | grep -v '^\s*$' | while IFS='=' read -r name _rest; do
  name=$(echo "$name" | xargs)
  case " $KNOWN " in *" $name "*) ;; *)
    if [[ -n "${!name:-}" ]]; then echo "  $name=SET"; else echo "  $name=UNSET"; fi ;;
  esac
done
