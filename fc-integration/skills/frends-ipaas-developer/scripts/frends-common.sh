#!/usr/bin/env bash
# Shared utilities for Frends Platform API CLI tools.
# Sourced by all frends-*.sh tool scripts — not executed directly.
#
# STATUS: Scaffolded against the published Frends 6.2 Platform API reference
# (https://docs.frends.com/reference/frends-platform-api). NOT yet live-tested
# against a tenant. Validate endpoints against your own
# https://<tenant>.frendsapp.com/swagger before relying on these in automation.
#
# Auth model (differs from Boomi): the Frends Platform API uses OAuth2
# client-credentials against Microsoft Entra ID (Azure AD). We POST client
# credentials to the Azure token endpoint, receive a short-lived bearer token,
# cache it, and send it as `Authorization: Bearer <token>` on every API call.

set -euo pipefail

# --- Environment ---

load_env() {
  local env_file=".env"
  if [[ -f "$env_file" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$env_file"
    set +a
  else
    echo "ERROR: .env file not found in $(pwd)" >&2
    exit 1
  fi
}

require_env() {
  local missing=()
  for var in "$@"; do
    if [[ -z "${!var:-}" ]]; then
      missing+=("$var")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "ERROR: Missing required environment variables: ${missing[*]}" >&2
    echo "Check your .env file (copy .env.example and fill it in)." >&2
    exit 1
  fi
}

require_tools() {
  local missing=()
  for tool in "$@"; do
    if ! command -v "$tool" &>/dev/null; then
      missing+=("$tool")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "ERROR: Missing required tools: ${missing[*]}" >&2
    exit 1
  fi
}

# --- Version ---

_skill_version() {
  cat "$(dirname "${BASH_SOURCE[0]}")/../VERSION" 2>/dev/null || echo "unknown"
}

_skill_name() {
  basename "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" 2>/dev/null || echo "unknown"
}

FRENDS_SKILL_NAME="${FRENDS_SKILL_NAME:-$(_skill_name)}"
FRENDS_USER_AGENT="frends-companion/${FRENDS_SKILL_NAME}/$(_skill_version)"

# --- URLs ---

# Base URL for the Platform API on this tenant.
# Override with FRENDS_API_BASE_URL if your tenant URL is non-standard.
api_base() {
  if [[ -n "${FRENDS_API_BASE_URL:-}" ]]; then
    echo "${FRENDS_API_BASE_URL%/}/api/v1"
  else
    require_env FRENDS_TENANT
    echo "https://${FRENDS_TENANT}.frendsapp.com/api/v1"
  fi
}

# Azure AD token endpoint (v1 endpoint accepts a `resource` parameter).
token_url() {
  require_env FRENDS_AZURE_TENANT
  echo "https://login.microsoftonline.com/${FRENDS_AZURE_TENANT}/oauth2/token"
}

# --- Token handling ---
#
# Cache file holds: <epoch_expiry>\n<access_token>
# We refresh when within 60s of expiry. Cache is per-workspace and gitignored.

_token_cache_file() {
  echo "$(pwd)/.frends-token-cache"
}

# Prints a valid bearer token to stdout, fetching/refreshing as needed.
get_token() {
  require_env FRENDS_CLIENT_ID FRENDS_CLIENT_SECRET FRENDS_APPLICATION_URI
  local cache now exp tok
  cache="$(_token_cache_file)"
  now="$(date -u +%s)"

  if [[ -f "$cache" ]]; then
    exp="$(sed -n '1p' "$cache" 2>/dev/null || echo 0)"
    tok="$(sed -n '2p' "$cache" 2>/dev/null || echo "")"
    if [[ -n "$tok" && "$exp" =~ ^[0-9]+$ && $((exp - 60)) -gt "$now" ]]; then
      echo "$tok"
      return 0
    fi
  fi

  local ssl_flag=""
  [[ "${FRENDS_VERIFY_SSL:-true}" == "false" ]] && ssl_flag="-k"

  local resp
  resp="$(curl -s $ssl_flag --max-time "${FRENDS_TIMEOUT:-60}" \
    -A "$FRENDS_USER_AGENT" \
    -X POST "$(token_url)" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "client_id=${FRENDS_CLIENT_ID}" \
    --data-urlencode "client_secret=${FRENDS_CLIENT_SECRET}" \
    --data-urlencode "grant_type=client_credentials" \
    --data-urlencode "resource=${FRENDS_APPLICATION_URI}")"

  local access expires_on expires_in
  access="$(echo "$resp" | jq -r '.access_token // empty')"
  if [[ -z "$access" ]]; then
    echo "ERROR: Failed to obtain bearer token from Azure AD." >&2
    echo "$resp" | jq -r '.error_description // .error // .' >&2 2>/dev/null || echo "$resp" >&2
    echo "Stop and check FRENDS_CLIENT_ID / FRENDS_CLIENT_SECRET / FRENDS_APPLICATION_URI / FRENDS_AZURE_TENANT before retrying — repeated bad-auth calls can lock the account." >&2
    exit 1
  fi

  # v1 token endpoint returns both expires_on (epoch) and expires_in (seconds).
  expires_on="$(echo "$resp" | jq -r '.expires_on // empty')"
  expires_in="$(echo "$resp" | jq -r '.expires_in // empty')"
  if [[ "$expires_on" =~ ^[0-9]+$ ]]; then
    exp="$expires_on"
  elif [[ "$expires_in" =~ ^[0-9]+$ ]]; then
    exp=$(( now + expires_in ))
  else
    exp=$(( now + 3000 ))
  fi

  printf '%s\n%s\n' "$exp" "$access" > "$cache"
  chmod 600 "$cache" 2>/dev/null || true
  echo "$access"
}

# --- API helpers ---
#
# frends_api [--out-file <path>] <METHOD> <endpoint> [extra curl args...]
#   endpoint is relative to api_base(), e.g. "processes" or "process-deployments".
#   Sets globals RESPONSE_BODY and RESPONSE_CODE.
#   With --out-file, the response body is written to <path> and RESPONSE_BODY is empty.

RESPONSE_BODY=""
RESPONSE_CODE=""
frends_api() {
  local out_file=""
  if [[ "${1:-}" == "--out-file" ]]; then
    out_file="$2"; shift 2
  fi
  local method="$1"; shift
  local endpoint="$1"; shift

  local token base ssl_flag tmpfile
  token="$(get_token)"
  base="$(api_base)"
  ssl_flag=""
  [[ "${FRENDS_VERIFY_SSL:-true}" == "false" ]] && ssl_flag="-k"
  tmpfile="${out_file:-$(mktemp)}"

  RESPONSE_CODE=$(curl -s $ssl_flag \
    --max-time "${FRENDS_TIMEOUT:-120}" \
    -A "$FRENDS_USER_AGENT" \
    -H "Authorization: Bearer ${token}" \
    -H "Accept: application/json" \
    -X "$method" \
    -o "$tmpfile" -w "%{http_code}" \
    "${base}/${endpoint}" "$@")

  if [[ -z "$out_file" ]]; then
    RESPONSE_BODY=$(cat "$tmpfile")
    rm -f "$tmpfile"
  else
    RESPONSE_BODY=""
  fi
}

# Fail with a clear message if the last call was not a 2xx.
expect_ok() {
  local context="${1:-request}"
  if [[ ! "$RESPONSE_CODE" =~ ^2[0-9][0-9]$ ]]; then
    echo "ERROR: ${context} failed (HTTP ${RESPONSE_CODE})" >&2
    if [[ -n "$RESPONSE_BODY" ]]; then
      echo "$RESPONSE_BODY" | jq -r '.detail // .title // .' >&2 2>/dev/null || echo "$RESPONSE_BODY" >&2
    fi
    if [[ "$RESPONSE_CODE" == "401" || "$RESPONSE_CODE" == "403" ]]; then
      echo "Auth/permission error. Stop and verify Platform API enablement, the admin app role, IP allowlisting, and credentials before retrying." >&2
    fi
    return 1
  fi
  return 0
}

# --- Connection test ---

test_connection() {
  require_tools curl jq
  echo "Fetching bearer token from Azure AD..."
  get_token >/dev/null
  echo "Token OK. Calling GET $(api_base)/processes?PageSize=1 ..."
  frends_api GET "processes?PageSize=1"
  if expect_ok "List Processes"; then
    local total
    total=$(echo "$RESPONSE_BODY" | jq -r '.paging.totalCount // "?"')
    echo "Connection successful. Tenant reports ${total} Process(es)."
  else
    exit 1
  fi
}

# --- Activity logging (opt-in via FRENDS_COMPANION_LOG_ACTIVITY=1) ---

log_activity() {
  [[ "${FRENDS_COMPANION_LOG_ACTIVITY:-0}" == "1" ]] || return 0
  local operation="$1" result="$2" http_code="${3:-}" details="${4:-\{\}}"
  {
    local log_dir="$(pwd)/.activity-log"
    mkdir -p "$log_dir" 2>/dev/null || return 0
    local script_name
    script_name="$(basename "${BASH_SOURCE[1]:-unknown}" .sh)"
    jq -cn \
      --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --arg name "${FRENDS_SKILL_NAME:-unknown}" \
      --arg ver "$(_skill_version)" \
      --arg ws "$(basename "$(pwd)")" \
      --arg op "$operation" \
      --arg script "$script_name" \
      --arg tenant "${FRENDS_TENANT:-}" \
      --arg result "$result" \
      --arg http "$http_code" \
      --argjson details "$details" \
      '{timestamp:$ts, skill_name:$name, skill_version:$ver, workspace:$ws,
        operation:$op, script:$script, tenant:$tenant, result:$result,
        http_code:(if $http=="" then null else ($http|tonumber? // $http) end),
        details:$details}' >> "$log_dir/activity.jsonl"
  } 2>/dev/null || true
}
