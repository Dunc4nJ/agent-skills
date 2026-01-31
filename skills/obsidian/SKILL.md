---
name: obsidian
description: Search and manage Obsidian vault notes using qmd (Markdown search engine). Use when user asks about notes, Obsidian, searching knowledge base, or finding information in their vault.
user_invocable: true
tools:
  - Bash
  - Read
  - Write
---

# Obsidian Vault (qmd-indexed)

**Vault location**: `/data/projects/obsidian-vault`
**Collection name**: `obsidian`
**Sync**: Git-based (Obsidian Git plugin)

## Structure

```
obsidian-vault/
├── Daily Notes/    # Daily journal entries
├── Projects/       # Project-specific notes
├── Archive/        # Old/completed stuff
└── Templates/      # Note templates
```

## Searching Notes (use qmd, not grep!)

**Why qmd**: 96% token savings — get snippets instead of full files.

### Search Modes

| Command | Type | Use Case |
|---------|------|----------|
| `qmd search "x" -c obsidian` | BM25 (keyword) | Exact terms, fast |
| `qmd vsearch "x" -c obsidian` | Vector (semantic) | Meaning-based |
| `qmd query "x" -c obsidian` | Hybrid + rerank | Best quality (slower) |

### Common Commands

```bash
# Text search (BM25) - fast, keyword-based
qmd search "query" -c obsidian

# Vector search (semantic) - understands meaning
qmd vsearch "query" -c obsidian

# List all notes
qmd ls obsidian

# Get a specific file
qmd get qmd://obsidian/path/to/note.md

# Update index after changes
qmd update
```

### Output Options

| Flag | Description |
|------|-------------|
| `-n 10` | Number of results |
| `--full` | Full document instead of snippet |
| `--json` | JSON output |
| `-c obsidian` | Filter to obsidian collection |

## Creating/Editing Notes

```bash
# Create note (direct file write)
cat > /data/projects/obsidian-vault/Folder/note.md << 'EOF'
# Title
Content here
EOF

# Or use Write tool to create/edit directly
```

## Syncing Changes

```bash
cd /data/projects/obsidian-vault && git add -A && git commit -m "msg" && git push
```

## When to Use What

| Task | Method |
|------|--------|
| Finding info in notes | `qmd search` (not grep/cat) |
| Full note content | `qmd get qmd://obsidian/path.md` |
| Creating/editing notes | Direct file write + git push |
| Re-index after changes | `qmd update` |

## Collection Management

```bash
# List collections
qmd collection list

# Add new collection
qmd collection add /path/to/folder --name myname --mask "**/*.md"

# Remove collection
echo "y" | qmd collection remove "name"

# Re-index everything
qmd update

# Re-embed after index update
qmd embed
```
