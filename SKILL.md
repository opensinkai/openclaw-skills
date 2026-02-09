---
name: opensink-skills
displayName: OpenSink Skills
description: OpenSink integration tools for OpenClaw agents. Includes session management and activity logging for audit trails and observability, with more integrations coming. Use when the agent needs to log actions, track progress, or interact with OpenSink's agent platform.
metadata: {"openclaw":{"emoji":"⚡","requires":{"bins":["curl"],"env":["OPENSINK_API_KEY","OPENSINK_AGENT_ID"]}}}
---

# OpenSink Skills

A collection of OpenSink integrations for OpenClaw agents. One install, multiple tools.

## Setup

Requires:
- `OPENSINK_API_KEY` — API key from [app.opensink.com](https://app.opensink.com)
- `OPENSINK_AGENT_ID` — your agent's ID in OpenSink

---

## Session Manager

Create and manage OpenSink sessions. A session should be created at the start of a task and completed when done. The session ID is used by other tools (like the activity logger).

### Start a session

```bash
# Returns the session ID — store it for use with other tools
SESSION_ID=$(scripts/session.sh start)
```

### Update session status

```bash
scripts/session.sh status $SESSION_ID completed
scripts/session.sh status $SESSION_ID failed
```

### Get session details

```bash
scripts/session.sh get $SESSION_ID
```

---

## Activity Logger

Log significant agent actions to OpenSink as Activities. Creates an inspectable timeline visible in the OpenSink dashboard.

### Requires
- `OPENSINK_SESSION_ID` — set this after creating a session with `session.sh start`

### Log an activity

```bash
export OPENSINK_SESSION_ID=$(scripts/session.sh start)
scripts/activity.sh log "Processed 12 emails, flagged 3 as urgent" "message"
```

### Log with structured payload

```bash
scripts/activity.sh log "Daily report complete" "message" '{"emails_processed": 12, "flagged": 3}'
```

### List recent activities

```bash
scripts/activity.sh list
scripts/activity.sh list --session $SESSION_ID
scripts/activity.sh list --type message
```

### Activity types

| Type | When to use |
|---|---|
| `message` | Agent produced output or progress update |
| `sink_item_created` | Agent wrote data to a Sink |
| `state_updated` | Session state changed |

### When to log

Log when the agent:
- Completes a task
- Makes a decision
- Encounters something notable
- Produces output
- Interacts with external services

Don't log routine operations (reading files, internal reasoning). Activities are **high-level, meaningful events**.

---

## Typical workflow

1. **Start a session** → `SESSION_ID=$(scripts/session.sh start)`
2. **Set the session ID** → `export OPENSINK_SESSION_ID=$SESSION_ID`
3. **Log activities as you work** → `scripts/activity.sh log "..." "message"`
4. **Complete the session** → `scripts/session.sh status $SESSION_ID completed`

---

## More coming soon

Future integrations planned:
- **Input Requests** — structured human-in-the-loop approval workflows
- **Knowledge Base** — read from curated Sinks as shared knowledge

## API Reference

See [references/api.md](references/api.md) for REST API details.
