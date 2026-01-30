---
name: nia-docs
description: Search library documentation and code examples via Nia (package semantic search, regex grep, and universal search). Use when you need API docs/code examples across npm, PyPI, crates, or Go modules. Requires NIA_API_KEY.
allowed-tools: [Bash, Read]
---

# Nia Documentation Search

Run commands from this Skill folder (the directory that contains `SKILL.md`) so `scripts/...` paths resolve.

## Usage

### Semantic search in a package
```bash
uv run --with aiohttp python scripts/nia_docs.py \
  search package fastapi --registry py_pi --query "dependency injection"
```

### Search with specific registry
```bash
uv run --with aiohttp python scripts/nia_docs.py \
  search package react --registry npm --query "hooks patterns"
```

### Grep search for specific patterns
```bash
uv run --with aiohttp python scripts/nia_docs.py \
  search package sqlalchemy --registry py_pi --grep "session.execute"
```

### Universal search across indexed sources
```bash
uv run --with aiohttp python scripts/nia_docs.py \
  search universal "error handling middleware" --limit 5
```

## Options (common)

| Option | Description |
|--------|-------------|
| `search package <package>` | Search within a package |
| `search universal <query>` | Universal search across indexed sources |
| `--registry` | `npm`, `py_pi`, `crates`, `go_modules` (default: `py_pi`) |
| `--query` | Semantic search query (for `search package`) |
| `--grep` | Regex pattern (for `search package`) |
| `--limit` | Max results (default varies by command) |

## API key

Set `NIA_API_KEY` in your environment (already configured in ~/.bashrc).
