#!/usr/bin/env bash
# Test Frends Platform API connectivity: fetch a bearer token and list 1 Process.
# Usage: bash scripts/frends-connection-test.sh
#
# STATUS: checked against the 6.3.2 OpenAPI document. Confirmed live on 6.3.2.5468
# (frends-smoke-test.sh, frends-write-test.sh): the whole script.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/frends-common.sh"

load_env
require_env FRENDS_AZURE_TENANT FRENDS_CLIENT_ID FRENDS_CLIENT_SECRET FRENDS_APPLICATION_URI
test_connection
log_activity "connection-test" "success" "$RESPONSE_CODE"
