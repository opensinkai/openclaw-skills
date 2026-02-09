---
name: opensink-skills
displayName: OpenSink Skills
description: OpenSink integration tools for OpenClaw agents. Includes activity logging for audit trails and observability, with more integrations coming. Use when the agent needs to log actions, track progress, or interact with OpenSink's agent platform.
metadata: {"openclaw":{"emoji":"⚡","requires":{"bins":["curl"],"env":["OPENSINK_API_KEY"]}}}
---

# OpenSink Skills

A collection of OpenSink integrations for OpenClaw agents. One install, multiple tools.

## Setup

Requires:
- `OPENSINK_API_KEY` — API key from [app.opensink.com](https://app.opensink.com)

Some tools require additional env vars (see each section below).

---

## Activity Logger

Log significant agent actions to OpenSink as Activities. Creates an inspectable timeline visible in the OpenSink dashboard.

### Additional env vars
- `OPENSINK_AGENT_ID` — your agent's ID in OpenSink
- `OPENSINK_SESSION_ID` — the current session ID in OpenSink

### Log an activity

```bash
scripts/activity.sh log "Processed 12 emails, flagged 3 as urgent" "message"
```

### Log with structured payload

```bash
scripts/activity.sh log "Daily report complete" "message" '{"emails_processed": 12, "flagged": 3}'
```

### List recent activities

```bash
scripts/activity.sh list
scripts/activity.sh list --session SESSION_ID
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

## More coming soon

Future integrations planned:
- **Input Requests** — structured human-in-the-loop approval workflows
- **Knowledge Base** — read from curated Sinks as shared knowledge
- **Session Sync** — log OpenClaw conversations to OpenSink Sessions

## API Reference

See [references/api.md](references/api.md) for REST API details.
