# OpenSink Skills API Reference

## Base URL

```
https://api.opensink.com/api/v1
```

## Authentication

All requests require a Bearer token:

```
Authorization: Bearer <OPENSINK_API_KEY>
```

---

## Sessions

### Create Session

```
POST /agent-sessions
```

| Field | Type | Required | Description |
|---|---|---|---|
| `agent_id` | string (UUID) | ✅ | Parent agent ID |
| `status` | string | ❌ | Initial status (default: `running`) |
| `state` | object | ❌ | Session state data |
| `metadata` | object | ❌ | Session metadata |

Status values: `running`, `waiting_for_input`, `processing_input`, `completed`, `failed`

### Update Session

```
PATCH /agent-sessions/{id}
```

| Field | Type | Description |
|---|---|---|
| `status` | string | New status |
| `state` | object | Updated state |
| `error_message` | string | Error message (for failed sessions) |

### Get Session

```
GET /agent-sessions/{id}
```

### List Sessions

```
GET /agent-sessions
```

---

## Activities

### Create Activity

```
POST /agent-session-activities
```

| Field | Type | Required | Description |
|---|---|---|---|
| `session_id` | string (UUID) | ✅ | The session this activity belongs to |
| `agent_id` | string (UUID) | ✅ | The agent that owns this session |
| `type` | string | ✅ | Activity type (see below) |
| `source` | string | ✅ | Who created it: `system`, `agent`, or `user` |
| `message` | string | ✅ | Human-readable description |
| `payload` | object | ❌ | Optional structured data |
| `related_entity_id` | string (UUID) | ❌ | Link to another entity |
| `links` | array | ❌ | Optional associated links |

Activity types: `message`, `sink_item_created`, `state_updated`, `session_started`, `session_ended`, `input_request_created`, `input_request_resolved`

### List Activities

```
GET /agent-session-activities
```

| Parameter | Type | Description |
|---|---|---|
| `session_id` | string (UUID) | Filter by session |
| `agent_id` | string (UUID) | Filter by agent |
| `type` | string | Filter by activity type |
| `$limit` | integer | Max results (default: 20) |
