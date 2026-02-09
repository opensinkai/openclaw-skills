# opensink-skills

An [OpenClaw](https://github.com/openclaw/openclaw) skill pack with [OpenSink](https://opensink.com) integrations for AI agents.

> **Looking for agent memory?** See [opensink-openclaw-memory](https://github.com/opensinkai/opensink-openclaw-memory) — a dedicated skill for persistent, searchable agent memory.

## What's included

### 📋 Activity Logger
Log significant agent actions to OpenSink as Activities. Creates an inspectable timeline visible in the dashboard — audit trails, observability, and debugging without parsing logs.

*More integrations coming soon: Input Requests, Knowledge Base, Session Sync.*

## Install

### From ClawHub

```bash
clawhub install opensink-skills
```

### From GitHub

```bash
openclaw skills install github:opensinkai/opensink-openclaw-skills
```

### Manual (direct installation)

```bash
git clone https://github.com/opensinkai/opensink-openclaw-skills.git

# Per-agent (workspace only):
cp -r opensink-openclaw-skills <workspace>/skills/opensink-skills

# Or global (all agents):
cp -r opensink-openclaw-skills ~/.openclaw/skills/opensink-skills
```

OpenClaw picks up the skill automatically on the next session.

## Setup

1. **Get an OpenSink API key** at [app.opensink.com](https://app.opensink.com)
2. **Set environment variables** (varies by tool — see SKILL.md for details):
   ```bash
   export OPENSINK_API_KEY="your-api-key"
   export OPENSINK_AGENT_ID="your-agent-id"      # for activity logger
   export OPENSINK_SESSION_ID="your-session-id"   # for activity logger
   ```

## Usage

### Activity Logger

```bash
# Log an activity
bash scripts/activity.sh log "Processed 12 emails" "message"

# Log with structured payload
bash scripts/activity.sh log "Daily report complete" "message" '{"count": 12}'

# List recent activities
bash scripts/activity.sh list

# Filter by session or type
bash scripts/activity.sh list --session SESSION_ID
bash scripts/activity.sh list --type message
```

## Requirements

- `curl` (no other dependencies)
- An [OpenSink](https://opensink.com) account with API access

## License

MIT
