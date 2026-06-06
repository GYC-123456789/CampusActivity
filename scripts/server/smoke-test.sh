#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-${PUBLIC_BASE_URL:-http://124.220.81.104}}"
BASE_URL="${BASE_URL%/}"
API_URL="$BASE_URL/api/v1/orders?page=1&size=1"

echo "Checking $BASE_URL/"
curl -fsSI --max-time 15 "$BASE_URL/" >/dev/null

echo "Checking $API_URL"
API_RESPONSE="$(curl -fsS --max-time 15 "$API_URL")"
case "$API_RESPONSE" in
  *'"code":200'*)
    echo "Smoke test passed: $BASE_URL"
    ;;
  *)
    echo "Unexpected API response: $API_RESPONSE" >&2
    exit 1
    ;;
esac
