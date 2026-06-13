#!/usr/bin/env bash
# One-time script to register the Figma LIBRARY_PUBLISH webhook.
# Run this locally after setting env vars.
#
# Required env vars:
#   FIGMA_ACCESS_TOKEN  — your Figma Personal Access Token
#   FIGMA_TEAM_ID       — visible in figma.com/files/team/{TEAM_ID}/...
#   FIGMA_WEBHOOK_SECRET — the random passcode you set in Vercel env vars

set -euo pipefail

: "${FIGMA_ACCESS_TOKEN:?Set FIGMA_ACCESS_TOKEN}"
: "${FIGMA_TEAM_ID:?Set FIGMA_TEAM_ID}"
: "${FIGMA_WEBHOOK_SECRET:?Set FIGMA_WEBHOOK_SECRET}"

ENDPOINT="https://barion-design-system.vercel.app/api/figma-webhook"

echo "Registering Figma webhook..."
echo "  Team ID:  $FIGMA_TEAM_ID"
echo "  Endpoint: $ENDPOINT"

response=$(curl -s -w "\n%{http_code}" \
  -X POST https://api.figma.com/v2/webhooks \
  -H "X-Figma-Token: $FIGMA_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"event_type\": \"LIBRARY_PUBLISH\",
    \"team_id\": \"$FIGMA_TEAM_ID\",
    \"endpoint\": \"$ENDPOINT\",
    \"passcode\": \"$FIGMA_WEBHOOK_SECRET\"
  }")

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | head -n -1)

echo ""
echo "HTTP $http_code"
echo "$body" | python3 -m json.tool 2>/dev/null || echo "$body"

if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
  echo ""
  echo "Webhook registered. Run scripts/test-webhook.sh to verify the full chain."
else
  echo ""
  echo "Registration failed (HTTP $http_code). Check your token and team ID."
  exit 1
fi
