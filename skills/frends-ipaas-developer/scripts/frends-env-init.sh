#!/usr/bin/env bash
# Create .env in the current folder from .env.example and fill in non-secret values.
# Never reads, writes or prints secrets: FRENDS_CLIENT_SECRET is always left to the user.
#
# Usage:
#   bash scripts/frends-env-init.sh                         # create .env if missing
#   bash scripts/frends-env-init.sh --set KEY=VALUE [...]   # fill non-secret keys
#   bash scripts/frends-env-init.sh --force --set KEY=VALUE # overwrite a key that already has a value
#
# A key is filled only when it is empty or still holds the .env.example placeholder,
# unless --force is given. Prints the key names it set, never the values.
set -euo pipefail

ENV_FILE=".env"
EXAMPLE=".env.example"
FORCE=0
SETS=()

ALLOWED="FRENDS_TENANT FRENDS_API_BASE_URL FRENDS_AZURE_TENANT FRENDS_CLIENT_ID FRENDS_APPLICATION_URI \
FRENDS_DEV_AGENT_GROUP_ID FRENDS_TEST_AGENT_GROUP_ID FRENDS_PROD_AGENT_GROUP_ID \
FRENDS_DEV_ENVIRONMENT_ID FRENDS_TEST_ENVIRONMENT_ID FRENDS_PROD_ENVIRONMENT_ID \
FRENDS_TARGET_FRAMEWORK FRENDS_VERIFY_SSL FRENDS_TIMEOUT"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --set) SETS+=("${2:?--set needs KEY=VALUE}"); shift 2 ;;
    --force) FORCE=1; shift ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "ERROR: unknown argument $1" >&2; exit 2 ;;
  esac
done

if [[ ! -f "$ENV_FILE" ]]; then
  if [[ ! -f "$EXAMPLE" ]]; then
    echo "ERROR: no $EXAMPLE in $(pwd); run this from the workspace or template root" >&2
    exit 1
  fi
  ( umask 077; cp "$EXAMPLE" "$ENV_FILE" )
  echo "created $ENV_FILE from $EXAMPLE (mode 600)"
fi
chmod 600 "$ENV_FILE"

placeholder() {  # value of KEY in .env.example, empty when absent
  [[ -f "$EXAMPLE" ]] || return 0
  grep -E "^$1=" "$EXAMPLE" | head -1 | cut -d= -f2- || true
}

for pair in "${SETS[@]+"${SETS[@]}"}"; do
  key="${pair%%=*}"
  value="${pair#*=}"
  case " $ALLOWED " in
    *" $key "*) ;;
    *) echo "ERROR: $key is not a non-secret key this script fills; edit $ENV_FILE yourself" >&2; exit 2 ;;
  esac
  if [[ "$value" == *$'\n'* ]]; then echo "ERROR: $key value contains a newline" >&2; exit 2; fi

  current="$(grep -E "^$key=" "$ENV_FILE" | head -1 | cut -d= -f2- || true)"
  if [[ -n "$current" && "$current" != "$(placeholder "$key")" && $FORCE -eq 0 ]]; then
    echo "kept    $key (already has a value; use --force to replace)"
    continue
  fi

  tmp="$(mktemp "${ENV_FILE}.XXXXXX")"
  if grep -qE "^#? ?$key=" "$ENV_FILE"; then
    KEY="$key" VALUE="$value" awk '
      BEGIN { k = ENVIRON["KEY"]; v = ENVIRON["VALUE"]; done = 0 }
      !done && ($0 ~ "^" k "=" || $0 ~ "^# ?" k "=") { print k "=" v; done = 1; next }
      { print }
    ' "$ENV_FILE" > "$tmp"
  else
    { cat "$ENV_FILE"; printf '%s=%s\n' "$key" "$value"; } > "$tmp"
  fi
  chmod 600 "$tmp"
  mv "$tmp" "$ENV_FILE"
  echo "set     $key"
done

echo "Add FRENDS_CLIENT_SECRET to $ENV_FILE yourself, then run frends-env-check.sh and frends-connection-test.sh."
