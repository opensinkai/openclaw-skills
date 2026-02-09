#!/usr/bin/env bash
# OpenSink Agent Manager — create, list, and get agents
# Usage:
#   agent.sh create <name> [description]  — create a new agent, print agent ID
#   agent.sh list                         — list all agents
#   agent.sh get <agent_id>               — get agent details
#
# Requires: OPENSINK_API_KEY

set -euo pipefail

: "${OPENSINK_API_KEY:?Set OPENSINK_API_KEY}"

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

cmd="${1:?Usage: agent.sh <create|list|get> ...}"
shift

case "$cmd" in
  create)
    name="${1:?create requires a name}"
    description="${2:-}"

    escaped_name=$(json_escape "$name")
    escaped_desc=$(json_escape "$description")

    if [ -n "$description" ]; then
      body="{\"name\": \"${escaped_name}\", \"description\": \"${escaped_desc}\"}"
    else
      body="{\"name\": \"${escaped_name}\"}"
    fi

    response=$(curl -sf -X POST "${BASE_URL}/agents" \
      -H "$AUTH" -H "$CT" \
      -d "$body")

    agent_id=$(echo "$response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -z "$agent_id" ]; then
      echo "❌ Failed to create agent"
      echo "$response"
      exit 1
    fi

    echo "$agent_id"
    ;;

  list)
    response=$(curl -sf -X GET "${BASE_URL}/agents" -H "$AUTH")

    if command -v python3 &>/dev/null; then
      echo "$response" | python3 -c "
import sys, json
data = json.loads(sys.stdin.read())
items = data if isinstance(data, list) else data.get('items', data.get('data', []))
for a in items:
    aid = a.get('id', '')
    name = a.get('name', '')
    desc = a.get('description', '') or ''
    print(f'{aid}  {name}  {desc}')
if not items:
    print('No agents found.')
"
    else
      echo "$response"
    fi
    ;;

  get)
    agent_id="${1:?get requires an agent ID}"

    response=$(curl -sf -X GET "${BASE_URL}/agents/${agent_id}" -H "$AUTH")

    if command -v python3 &>/dev/null; then
      echo "$response" | python3 -c "
import sys, json
a = json.loads(sys.stdin.read())
print(f\"ID:          {a.get('id', '')}\")
print(f\"Name:        {a.get('name', '')}\")
print(f\"Description: {a.get('description', '') or '(none)'}\")
print(f\"Created:     {a.get('created_at', '')}\")
"
    else
      echo "$response"
    fi
    ;;

  *)
    echo "Unknown command: $cmd"
    echo "Usage: agent.sh <create|list|get>"
    exit 1
    ;;
esac
