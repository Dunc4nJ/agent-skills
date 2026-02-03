---
name: telegram-send-as-self
description: Use when the user wants strict per-agent Telegram identity, or asks to "send a Telegram message as this agent", "enforce accountId", "multi-account Telegram", or fix "Telegram bot token missing" errors. Ensures every Telegram send includes the agent's own accountId.
---

# Telegram Send As Self (Strict)

## Rule
For Telegram sends, ALWAYS call the `message` tool with:
- `channel: "telegram"`
- `target: "telegram:<chatId>"`
- `accountId: "<this agent's accountId>"`

Never send Telegram without `accountId`.
If `accountId` is missing, STOP and fix the call.

## This deployment
- Default token (`channels.telegram.botToken`) is intentionally **unset**.
- Valid accountIds:
  - rust-monkey, tin-skin, plutus, polygod, delphi, athena, bananabanker, tableclay-manager
- Overlord chatId:
  - `telegram:6198871780`

## Examples
Send to Overlord:
- accountId must equal the current agent’s Telegram accountId.

If you are **Plutus**:
- `accountId: "plutus"`

If you are **Tin Skin**:
- `accountId: "tin-skin"`
