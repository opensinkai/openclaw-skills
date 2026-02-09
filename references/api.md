# OpenSink Activity API Reference

## Base URL

```
https://api.opensink.com/api/v1
```

## Authentication

All requests require a Bearer token:

```
Authorization: Bearer <OPENSINK_API_KEY>
```

## Create Activity

```
POST /agent-session-activities
```

### Request Body

| Field | Type | Required | Description |
|---|---|---|---|
| `session_id` | string (UUID) | ✅ | The session this activity belongs to |
| `agent_id` | string (UUID) | ✅ | The agent that owns this session |
| `type` | string | ✅ | Activity type (see below) |
| `source` | string | ✅ | Who created it: `system`, `agent`, or `user` |
| `message` | string | ✅ | Human-readable description |
| `payload` | object | ❌ | Optional structured data |
| `related_entity_id` | string (UUID) | ❌ | Link to another entity (e.g. sink item ID) |
| `links` | array | ❌ | Optional associated links |

### Activity Types

| Type | Description |
|---|---|
| `message` | Agent produced a human-readable message |
| `sink_item_created` | Agent wrote an item to a sink |
| `state_updated` | Session state was updated |
| `session_started` | Session began (system-generated) |
| `session_ended` | Session completed or failed (system-generated) |
| `input_request_created` | Agent requested human input (system-generated) |
| `input_request_resolved` | Human responded to input request (system-generated) |

### Example

```bash
curl -X POST https://api.opensink.com/api/v1/agent-session-activities \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "session_id": "SESSION_ID",
    "agent_id": "AGENT_ID",
    "type": "message",
    "source": "agent",
    "message": "Processed 12 emails, flagged 3 as urgent",
    "payload": {
      "emails_processed": 12,
      "flagged": 3
    }
  }'
```

## List Activities

```
GET /agent-session-activities
```

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `session_id` | string (UUID) | Filter by session |
| `agent_id` | string (UUID) | Filter by agent |
| `type` | string | Filter by activity type |
| `$limit` | integer | Max results to return (default: 20) |

### Example

```bash
curl "https://api.opensink.com/api/v1/agent-session-activities?session_id=SESSION_ID" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```
