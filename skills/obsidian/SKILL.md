---
name: obsidian
description: Search and manage Obsidian vault notes using qmd (Markdown search engine). Use when the user asks about "notes", "Obsidian", "search my vault", "find in knowledge base", "what do I know about", or needs to create, read, or update vault content. Provides search commands, vault navigation, and note-writing conventions.
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
---

# Obsidian Vault (qmd-indexed)

**Vault location**: `/data/projects/obsidian-vault` (symlinked at `~/obsidian-vault`)
**Collection name**: `obsidian`
**Sync**: Git-based (Obsidian Git plugin)

## Vault Philosophy

This vault is external knowledge infrastructure for AI agents. Agents do not run inside it — access it via this skill to read or write knowledge.

For deep understanding of vault conventions and architecture, read:
`Knowledge/Agentic Memory/Obsidian as Agentic Memory.md`

## Structure

```
obsidian-vault/
├── moc - Vault.md              # Root MOC — read this first
├── Projects/                    # Per-project knowledge (nestable)
│   └── [Project]/
│       ├── moc - [Project].md  # Project MOC: status, decisions, nav, questions
│       └── learning - *.md     # Project-specific learnings
├── Knowledge/                   # Cross-cutting knowledge
│   └── Agentic Memory/         # Vault philosophy + agent integration patterns
├── Daily Notes/                 # Daily journal
├── Templates/                   # Note templates
└── Archive/                     # Inactive content
```

## Navigation Protocol

When you need vault context:
1. **(Optional) Inject vault context** for the map before exploring:
   ```bash
   bash ~/.agent/skills/obsidian/scripts/inject-context.sh [path]
   ```
   Outputs vault tree + YAML descriptions. Pass a path to scope to a specific project (e.g., `Projects/App Creation`) or omit for the full vault. Use descriptions to decide which notes to open — most decisions can be made at the description level without reading full files.
2. Read `moc - Vault.md` (root MOC) for vault-wide orientation
3. Identify which project is relevant based on your current task
4. Read that project's MOC (`moc - [Project].md`) for status, decisions, and links
5. **Follow wiki links** using qmd to resolve them:
   ```bash
   qmd search "note title from wiki link" -c obsidian
   ```
6. **Use qmd for targeted lookups** when descriptions or MOCs point to something relevant:
   ```bash
   qmd search "exact term" -c obsidian        # keyword match
   qmd vsearch "concept description" -c obsidian  # semantic match
   qmd query "broad topic" -c obsidian         # hybrid + rerank
   ```

## Writing Notes

### Titles
Write titles as claims (readable prose), not keywords:
- GOOD: `quality is the hard part.md`
- BAD: `quality-notes.md`

### Structure
Every note must stand alone. A reader arriving via any wiki link should understand the note without reading 3 others first.

### Wiki Links
Weave `[[links]]` inline into sentences:
- GOOD: `because [[quality is the hard part]] we need to focus on curation`
- BAD: `Related: [[quality-note]]` (at the bottom)

### YAML Frontmatter
Every note needs:
```yaml
---
created: YYYY-MM-DD
description: One sentence describing the note (enables progressive disclosure)
---
```

Optional fields: `type` (e.g., decision, question, framework), `source` (where it came from)

### Prefixes
Only 3 prefixes are used:
- `meta - ` — system/workflow files
- `moc - ` — maps of content (navigation hubs)
- `learning - ` — extracted insights from agent work

All other notes use clean claim-based titles with `type` in YAML frontmatter.

### Learnings
When you discover something significant, create a learning note:
- Filename: `learning - [claim as readable prose].md`
- Place in relevant project folder if project-specific, `Knowledge/` if cross-cutting
- Densely linked: wiki links to source material and related vault notes woven inline
- Update the relevant MOC's Navigation section with a link to the new learning

## Meta Feedback Loop

When your behavior misses expectations while working with the vault:
1. Identify what rule is missing or unclear
2. Check if the rule exists in vault convention notes
3. Add or update the rule immediately
4. This compounds — every correction improves the system for all future sessions

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

Use the Write tool to create notes directly. Always include YAML frontmatter:

```bash
# Create a learning note in a project
Write to: /data/projects/obsidian-vault/Projects/[Project]/learning - [claim].md

# Create a knowledge note
Write to: /data/projects/obsidian-vault/Knowledge/[Domain]/[claim title].md
```

After creating or editing notes:
```bash
# Sync changes
cd /data/projects/obsidian-vault && git add -A && git commit -m "vault: description" && git push

# Re-index for search
qmd update
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
