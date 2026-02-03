---
name: agent-conference
description: "Start a multi-agent discussion visible in a Telegram group. Orchestrator (main) facilitates rounds of conversation between agents, each posting as their own bot identity. Use when user says 'discuss with', 'conference', 'talk to agents', 'agent meeting', or wants agents to collaborate visibly."
user-invocable: true
---

# Agent Conference Room

Run a visible multi-agent conversation in a Telegram group chat.

## Why This Exists

Telegram bots can't see each other's messages in groups. So agent-to-agent chat
can't happen natively. Instead, the orchestrator (main / Chief Rust Monkey) runs
the conversation loop internally via `sessions_send`, and each agent posts their
messages to the group using their own `accountId`.

## Architecture

```
User triggers: "discuss X with Athena"
    │
    ▼
┌─────────────────────┐
│  Orchestrator (main) │  ← runs the loop
│  - sends context to  │
│    each agent via     │
│    sessions_send      │
│  - receives replies   │
└──────┬──────┬────────┘
       │      │
  ┌────▼──┐ ┌─▼─────┐
  │Athena │ │Agent B │  ← each agent replies internally
  └───┬───┘ └──┬────┘
      │        │
      ▼        ▼
  Posts to group with own accountId
```

## How to Use

### 1. Setup: Get the Group Chat ID

Create a Telegram group and add the relevant bots. Have the user send a message
in the group. The group `chatId` will appear in the incoming message metadata.
Store it for routing.

### 2. Start a Conference

When the user asks to discuss something with agents:

```
# Step 1: Frame the topic as a prompt for each agent
TOPIC = user's discussion topic

# Step 2: Send to first agent via sessions_send
sessions_send(agentId="athena", message="[CONFERENCE] Overlord wants to discuss: {TOPIC}. Share your perspective. Keep it concise (2-4 paragraphs max). This will be posted to a group chat.")

# Step 3: Post agent's response to group
message(action="send", channel="telegram", target="{GROUP_CHAT_ID}", accountId="athena", message="{athena_response}")

# Step 4: Send next agent the context + previous responses
sessions_send(agentId="next-agent", message="[CONFERENCE] Topic: {TOPIC}. Athena said: {athena_response}. Your turn — respond/add your perspective.")

# Step 5: Post to group
message(action="send", channel="telegram", target="{GROUP_CHAT_ID}", accountId="next-agent", message="{next_agent_response}")

# Repeat rounds as needed
```

### 3. Conference Rounds

A conference runs in **rounds**:
- **Round 1**: Each agent gives their initial take on the topic
- **Round 2+**: Agents respond to each other's points (orchestrator feeds previous messages as context)
- **Wrap-up**: Orchestrator summarizes or asks a final question

Default: 2-3 rounds unless the user asks for more.

### 4. Conference Etiquette (injected into agent prompts)

When sending to agents, prefix with `[CONFERENCE]` so they know:
- Keep responses concise (group chat, not essays)
- Address other agents by name when responding to their points
- Stay in their lane (Athena → knowledge/vault perspective, Plutus → financial, etc.)
- No internal coordinator jargon — this is visible to the user

### 5. Orchestrator Posts

The orchestrator (main) can also post to the group to:
- Introduce the topic
- Steer the conversation
- Summarize conclusions
- Ask follow-up questions

Use `accountId: "rust-monkey"` for orchestrator posts.

## Group Config Requirements

Each bot account in the group needs:
1. Privacy mode disabled in BotFather (`/setprivacy` → Disabled)
2. Group `chatId` added to the account's group allowlist in gateway config

Example config patch for a group:
```json
{
  "channels": {
    "telegram": {
      "accounts": {
        "rust-monkey": { "groups": { "<chatId>": { "enabled": true } } },
        "athena": { "groups": { "<chatId>": { "enabled": true } } }
      }
    }
  }
}
```

## Quick-Start Template

User says: "Discuss X with Athena"

1. Post to group: "🏛️ **Conference Room** — Topic: X" (as rust-monkey)
2. sessions_send to athena: "[CONFERENCE] Topic: X. Share your take."
3. Post athena's reply to group (as athena)
4. Post your own response to group (as rust-monkey)
5. sessions_send to athena with your response as context
6. Post athena's reply
7. Summarize if needed

## Supported Agents

| Agent | accountId | Role in conferences |
|-------|-----------|-------------------|
| Chief Rust Monkey (main) | rust-monkey | Orchestrator, technical lead |
| Athena | athena | Knowledge/vault librarian, research |
| Tin Skin | tin-skin | Methodical analysis, second opinion |
| Plutus | plutus | Financial/trading perspective |
| Delphi | delphi | Oracle/predictions |
| Polygod | polygod | Blockchain/web3 |
| BananaBanker | bananabanker | Marketing/content |
| TableClay Manager | tableclay-manager | Business ops |

## Important Notes

- **Telegram limitation**: Bots can't see each other's messages. ALL routing goes through the orchestrator via sessions_send.
- **Don't flood**: Wait for each agent's response before sending the next. Respect rate limits.
- **Group chatId**: Must be stored and known. Negative number for groups (e.g., `-100123456789`).
- **accountId is mandatory**: Every group post must include the correct `accountId`.
