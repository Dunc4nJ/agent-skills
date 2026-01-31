---
name: obsidian-reflect
description: Extract key learnings from recent work and persist them to the Obsidian vault as linked learning notes. Use when the user says "reflect on", "capture learnings", "what did we learn", "extract insights", "end of session", or when wrapping up a task with significant non-obvious discoveries worth preserving.
user-invocable: true
argument-hint: "[topic, file, or 'recent work' to reflect on]"
allowed-tools:
  - Bash
  - Read
  - Write
---

# Obsidian Reflect

Extract key learnings from work and persist them to the vault as standalone, densely linked notes.

**Vault location**: `~/obsidian-vault`

## Workflow

### 1. Understand the input

Input types:
- A topic: "reflect on what we learned about caching"
- A file: "reflect on src/auth.ts changes"
- General: "reflect on recent work"

### 2. Search vault for related context

```bash
# Search for related notes
qmd search "topic keywords" -c obsidian -n 10

# Or semantic search for broader matches
qmd vsearch "topic description" -c obsidian -n 10
```

Read the relevant results to understand what the vault already knows about this topic.

### 3. Identify key learnings

Extract insights that are:
- Non-obvious or surprising
- Reusable across future work
- Worth preserving as standalone knowledge
- Different from what the vault already contains

Each learning should pass the test: "Would a future agent benefit from knowing this?"

### 4. Create learning notes

For each learning, create a file:

**Filename**: `learning - [claim as readable prose].md`

The claim should be a complete, assertive statement:
- GOOD: `learning - caching at the edge eliminates 90% of database load.md`
- BAD: `learning - caching-notes.md`

**Location**:
- Project-specific: `~/obsidian-vault/Projects/[Project]/learning - claim.md`
- Cross-cutting: `~/obsidian-vault/Knowledge/[Domain]/learning - claim.md`

**Template**:
```yaml
---
created: YYYY-MM-DD
description: One sentence that elaborates the title claim
source: What this was extracted from (task, file, conversation topic)
type: learning
---
```

Body: Write the insight as standalone prose. Weave `[[wiki links]]` inline to related vault notes discovered during the search step. Every learning note must be densely linked — links to source material, links to related concepts, links to notes that support or challenge the insight.

The note must stand alone. A reader arriving from any wiki link should understand the learning without needing other context.

### 5. Update MOCs

After creating learning notes, update the relevant MOC:
- Read the project MOC (e.g., `Projects/[Project]/moc - [Project].md`)
- Add `[[learning - claim]]` under the Navigation > Learnings section
- If the learning is cross-cutting, also add a link in `moc - Vault.md` under the relevant Knowledge section

### 6. Sync

```bash
cd ~/obsidian-vault && git add -A && git commit -m "vault: extract learnings from [topic]" && git push
qmd update
```

### 7. Report

Output a summary:
- Number of learnings extracted
- Each learning: filename, location, one-line description
- Which MOCs were updated

## Quality Checks

Before finishing, verify:
- [ ] Every learning title is a claim (readable prose, not keywords)
- [ ] Every learning has YAML frontmatter (created, description, source, type)
- [ ] Every learning contains inline `[[wiki links]]` to related vault notes
- [ ] Every learning stands alone (no required context from other notes)
- [ ] Relevant MOC(s) updated with links to new learnings
- [ ] Changes committed and pushed
- [ ] qmd index updated

## Example

Input: "Reflect on what we learned about auth implementation"

Output:
```
Extracted 2 learnings:

1. Projects/MyApp/learning - JWT refresh tokens need server-side revocation for security.md
   -> Linked to [[Framework]], [[moc - MyApp]]

2. Knowledge/Agentic Memory/learning - testing auth flows requires mocking time not just tokens.md
   -> Linked to [[ContextEngineering]], [[moc - Vault]]

Updated MOCs:
- Projects/MyApp/moc - MyApp.md (added 1 learning link)
- moc - Vault.md (added 1 cross-cutting learning)
```
