---
name: perplexity-search
description: AI-powered web search and research via Perplexity (Sonar models), including ranked search results and AI-synthesized answers with citations. Use for up-to-date facts, source gathering, deep research, and reasoning. Requires PERPLEXITY_API_KEY.
allowed-tools: [Bash, Read]
---

# Perplexity AI Search

Run commands from this Skill folder (the directory that contains `SKILL.md`) so `scripts/...` paths resolve.

## Usage

### Quick question (AI answer)
```bash
uv run --with aiohttp python scripts/perplexity_search.py \
  --ask "What is the latest version of Python?"
```

### Direct web search (ranked results, no AI)
```bash
uv run --with aiohttp python scripts/perplexity_search.py \
  --search "SQLite graph database patterns" \
  --max-results 5 \
  --recency week
```

### AI-synthesized research
```bash
uv run --with aiohttp python scripts/perplexity_search.py \
  --research "compare FastAPI vs Django for microservices"
```

### Chain-of-thought reasoning
```bash
uv run --with aiohttp python scripts/perplexity_search.py \
  --reason "should I use Neo4j or SQLite for small graph under 10k nodes?"
```

### Deep comprehensive research
```bash
uv run --with aiohttp python scripts/perplexity_search.py \
  --deep "state of AI agent observability 2025"
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `--ask` | Quick question with AI answer (sonar) |
| `--search` | Direct web search - ranked results without AI synthesis |
| `--research` | AI-synthesized research (sonar-pro) |
| `--reason` | Chain-of-thought reasoning (sonar-reasoning-pro) |
| `--deep` | Deep comprehensive research (sonar-deep-research) |
| `--max-results N` | Number of results (1-20, default: 10) |
| `--recency` | Filter: `day`, `week`, `month`, `year` |
| `--domains` | Limit to specific domains (space-separated) |
| `--model` | Override model selection |

## API key

Set `PERPLEXITY_API_KEY` in your environment (already configured in ~/.bashrc).
