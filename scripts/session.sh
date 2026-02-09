#!/usr/bin/env bash
# OpenSink Session Manager — create, update, and get sessions
# Usage:
#   session.sh start [status_json]        — create a new session, print session ID
#   session.sh status <session_id> <status> — update session status (running|completed|failed)
#   session.sh get <session_id>           — get session details
#
# Requires: OPENSINK_API_KEY, OPENSINK_AGENT_ID

set -euo pipefail

: "${OPENSINK_API_KEY:?Set OPENSINK_API_KEY}"
: "${OPENSINK_AGENT_ID:?Set OPENSINK_AGENT_ID}"

BASE_URL="${OPENSINK_URL:-https://api.opensink.com/api/v1}"
AUTH="Authorization: Bearer ${OPENSINK_API_KEY}"
CT="Content-Type: application/json"

# JSON-escape a string (pure bash)
json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

cmd="${1:?Usage: session.sh <start|status|get> ...}"
shift

case "$cmd" in
  start)
    state="${1:-\{\}}"

    body=$(cat <<EOF
{
  "agent_id": "${OPENSINK_AGENT_ID}",
  "status": "running",
  "state": ${state}
}
EOF
)

    response=$(curl -sf -X POST "${BASE_URL}/agent-sessions" \
      -H "$AUTH" -H "$CT" \
      -d "$body")

    # Extract session ID
    session_id=$(echo "$response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -z "$session_id" ]; then
      echo "❌ Failed to create session"
      echo "$response"
      exit 1
    fi

    echo "$session_id"
    ;;

  status)
    session_id="${1:?status requires a session ID}"
    new_status="${2:?status requires a status (running|completed|failed)}"

    body="{\"status\": \"${new_status}\"}"

    curl -sf -X PATCH "${BASE_URL}/agent-sessions/${session_id}" \
      -H "$AUTH" -H "$CT" \
      -d "$body" > /dev/null

    echo "✅ Session ${session_id} → ${new_status}"
    ;;

  get)
    session_id="${1:?get requires a session ID}"

    response=$(curl -sf -X GET "${BASE_URL}/agent-sessions/${session_id}" -H "$AUTH")

    if command -v python3 &>/dev/null; then
      echo "$response" | python3 -c "
import sys, json
s = json.loads(sys.stdin.read())
print(f\"ID:      {s.get('id', '')}\")
print(f\"Status:  {s.get('status', '')}\")
print(f\"Agent:   {s.get('agent_id', '')}\")
print(f\"Created: {s.get('created_at', '')}\")
print(f\"Updated: {s.get('updated_at', '')}\")
state = s.get('state', {})
if state:
    print(f\"State:   {json.dumps(state, indent=2)}\")
"
    else
      echo "$response"
    fi
    ;;

  *)
    echo "Unknown command: $cmd"
    echo "Usage: session.sh <start|status|get>"
    exit 1
    ;;
esac
