#!/usr/bin/env bash
# OpenSink Activity Logger — log and list agent activities
# Usage:
#   opensink-activity.sh log <message> [type] [payload_json]
#   opensink-activity.sh list [--session SESSION_ID] [--limit N] [--type TYPE]
#
# Requires: OPENSINK_API_KEY, OPENSINK_AGENT_ID, OPENSINK_SESSION_ID

set -euo pipefail

: "${OPENSINK_API_KEY:?Set OPENSINK_API_KEY}"
: "${OPENSINK_AGENT_ID:?Set OPENSINK_AGENT_ID}"

BASE_URL="${OPENSINK_URL:-https://api.opensink.com/api/v1}"
AUTH="Authorization: Bearer ${OPENSINK_API_KEY}"
CT="Content-Type: application/json"

cmd="${1:?Usage: opensink-activity.sh <log|list> ...}"
shift

# JSON-escape a string (pure bash, no python)
json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

case "$cmd" in
  log)
    message="${1:?log requires a message}"
    type="${2:-message}"
    payload="${3:-null}"
    session_id="${OPENSINK_SESSION_ID:?Set OPENSINK_SESSION_ID}"

    escaped_msg=$(json_escape "$message")

    # Build JSON payload
    if [ "$payload" = "null" ] || [ -z "$payload" ]; then
      payload_field="null"
    else
      payload_field="$payload"
    fi

    body=$(cat <<EOF
{
  "session_id": "${session_id}",
  "agent_id": "${OPENSINK_AGENT_ID}",
  "type": "${type}",
  "source": "agent",
  "message": "${escaped_msg}",
  "payload": ${payload_field}
}
EOF
)

    response=$(curl -sf -X POST "${BASE_URL}/agent-session-activities" \
      -H "$AUTH" -H "$CT" \
      -d "$body")

    echo "✅ Activity logged: ${message}"
    ;;

  list)
    session_id="${OPENSINK_SESSION_ID:-}"
    limit=20
    type_filter=""

    while [ $# -gt 0 ]; do
      case "$1" in
        --session) session_id="$2"; shift 2 ;;
        --limit) limit="$2"; shift 2 ;;
        --type) type_filter="$2"; shift 2 ;;
        *) shift ;;
      esac
    done

    # Build query params
    params="\$limit=${limit}"
    if [ -n "$session_id" ]; then
      params="${params}&session_id=${session_id}"
    fi
    if [ -n "${OPENSINK_AGENT_ID:-}" ]; then
      params="${params}&agent_id=${OPENSINK_AGENT_ID}"
    fi
    if [ -n "$type_filter" ]; then
      params="${params}&type=${type_filter}"
    fi

    response=$(curl -sf -X GET "${BASE_URL}/agent-session-activities?${params}" -H "$AUTH")

    # Parse with bash-friendly approach — fall back to raw output
    if command -v python3 &>/dev/null; then
      echo "$response" | python3 -c "
import sys, json
data = json.loads(sys.stdin.read())
items = data if isinstance(data, list) else data.get('items', data.get('data', []))
for a in items:
    src = a.get('source', '-')
    atype = a.get('type', '-')
    msg = a.get('message', '')
    ts = a.get('created_at', '')[:16]
    print(f'[{ts}] ({src}/{atype}) {msg}')
if not items:
    print('No activities found.')
"
    else
      echo "$response"
    fi
    ;;

  *)
    echo "Unknown command: $cmd"
    echo "Usage: opensink-activity.sh <log|list>"
    exit 1
    ;;
esac
