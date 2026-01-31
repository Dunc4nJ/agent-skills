---
name: obsidian-edit
description: Process inline {edit annotations} in Obsidian vault notes. Use when the user says "edit my notes", "process annotations", "run edit", "fix my annotations", or has left {curly brace instructions} in markdown files for batch processing.
user-invocable: true
argument-hint: "[file path(s) or blank to search vault]"
allowed-tools:
  - Bash
  - Read
  - Edit
---

# Obsidian Edit

Process `{inline annotations}` in Obsidian vault notes. Leave edit instructions where they belong; resolve them in place.

**Vault location**: `~/obsidian-vault`

## Concept

Spatial editing inverts the normal flow. Instead of copying text to the agent with instructions, annotations are left inline. Each `{annotation}` applies to its surrounding text. Position IS context — the annotation knows what it refers to because of where it lives.

## Workflow

### 1. Identify target files

**With arguments**: Use the specified file path(s).

**Without arguments**: Discover all files with annotations:

```bash
bash ~/.agent/skills/obsidian-edit/scripts/find-annotations.sh
```

If no annotations found, report and exit.

### 2. Process each file

For each target file:

1. Read the full file
2. Identify all `{...}` annotations — **skip** those inside code blocks (between ``` markers) and YAML frontmatter (between --- markers at file start)
3. For each annotation, working top to bottom:
   - The text inside `{...}` is the edit instruction
   - The surrounding paragraph is the context to edit
   - **If the annotation references other content** (e.g., `{link to X}`, `{cite source}`, `{connect to related concept}`), use qmd to find the relevant note:
     ```bash
     qmd search "concept name" -c obsidian
     qmd vsearch "what the annotation is asking about" -c obsidian
     ```
     Use the found note's title to create a proper `[[wiki link]]` woven into the text.
   - Apply the instruction: improve the surrounding text accordingly
   - Remove the `{...}` annotation
4. Write the edited file using the Edit tool

### 3. Sync

After all files processed:

```bash
cd ~/obsidian-vault && git add -A && git commit -m "vault: process spatial edits" && git push
qmd update
```

### 4. Report

Output a summary per file:

```
Processed spatial edits:

Knowledge/Agentic Memory/example.md (3 annotations):
1. "{feels abstract}" -> added concrete mechanism
2. "{expand this}" -> added supporting examples
3. "{too technical}" -> simplified language

Total: 1 file, 3 annotations processed
```

## Skip rules

- `{text}` inside fenced code blocks -> skip (likely an example)
- `{text}` inside YAML frontmatter -> skip
- Empty `{}` -> skip
- `{unclosed` or `unopened}` -> treat as literal text, skip

## Examples

**Example 1: Clarity**

Input:
```
vaults give claude memory
{feels abstract -- what kind of memory?}
```

Output:
```
vaults give claude persistent memory across sessions by storing context in files it can read and write
```

**Example 2: Strengthening**

Input:
```
without persistent storage claude forgets everything between sessions
{this is the key point, make it hit harder}
```

Output:
```
without persistent storage claude starts fresh every conversation -- you re-explain the same context, rebuild the same understanding, lose the compound effect of accumulated knowledge
```

**Example 3: Showing instead of telling**

Input:
```
the solution is simple
{dont say simple, show}
```

Output:
```
the solution: store everything in markdown files that claude can traverse
```

**Example 4: Link resolution (uses qmd)**

Input:
```
the vault uses progressive disclosure to filter what agents read
{link to the note about this}
```

Process:
```bash
qmd search "progressive disclosure" -c obsidian
# -> finds: Knowledge/Agentic Memory/ContextEngineering.md
```

Output:
```
the vault uses [[ContextEngineering|progressive disclosure]] to filter what agents read
```

## Quality checks

- [ ] All annotations in target files processed (run find-annotations.sh to confirm none remain)
- [ ] Code blocks and YAML frontmatter unchanged
- [ ] Changes committed and pushed
- [ ] qmd index updated
- [ ] Report shows file, count, and description for each edit
