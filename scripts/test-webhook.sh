#!/usr/bin/env bash
# Sends a mock LIBRARY_PUBLISH payload to the live webhook endpoint.
# Use this to verify the full chain: webhook → GitHub Issue, without touching Figma.
#
# Required env vars:
#   FIGMA_WEBHOOK_SECRET — must match what's set in Vercel

set -euo pipefail

: "${FIGMA_WEBHOOK_SECRET:?Set FIGMA_WEBHOOK_SECRET}"

ENDPOINT="${WEBHOOK_ENDPOINT:-https://barion-design-system.vercel.app/api/figma-webhook}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

PAYLOAD=$(cat <<EOF
{
  "event_type": "LIBRARY_PUBLISH",
  "file_key": "OmeynxsvYTEtnkZ4d6gWrR",
  "passcode": "$FIGMA_WEBHOOK_SECRET",
  "timestamp": "$TIMESTAMP",
  "description": "Test publish from scripts/test-webhook.sh",
  "triggered_by": { "name": "test-script" }
}
EOF
)

echo "Sending test payload to $ENDPOINT ..."

response=$(curl -s -w "\n%{http_code}" \
  -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | head -n -1)

echo "HTTP $http_code  —  $body"

if [ "$http_code" -eq 200 ]; then
  echo ""
  echo "Success. Check GitHub Issues for a new 'figma-update' issue."
  echo "https://github.com/kaliszkypeter/barion-design-system/issues?q=label%3Afigma-update"
else
  echo ""
  echo "Unexpected response. Check Vercel logs and ensure FIGMA_WEBHOOK_SECRET matches."
  exit 1
fi
