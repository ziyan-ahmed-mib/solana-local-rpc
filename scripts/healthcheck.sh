#!/bin/sh
set -eu
response=$(curl --fail --silent --show-error --max-time 3 \
  -H 'Content-Type: application/json' \
  --data '{"jsonrpc":"2.0","id":1,"method":"getHealth"}' \
  http://127.0.0.1:8899)
printf '%s' "$response" | jq -e '.result == "ok" and .error == null' >/dev/null
