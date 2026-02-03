---
name: create-global-skill
description: Create and publish global skills available to all local agents. Use when asked to "create a skill", "add a new skill", "write a skill", "make a global skill", or when setting up skill folder structure, writing SKILL.md, creating symlinks, or running OpenSkills sync. Covers both skill authoring best practices and deployment to ~/.agent/skills/.
---

# Create Global Skill

## Core Design Principles

### Conciseness

The context window is a public good. Skills share it with the system prompt, conversation history, other skills' metadata, and the user request.

**Default assumption: Claude is already very smart.** Only add context Claude doesn't already have. Challenge each piece of information: "Does Claude really need this?" and "Does this paragraph justify its token cost?"

Prefer concise examples over verbose explanations.

### Degrees of Freedom

Match specificity to the task's fragility and variability:

- **High freedom** (text-based instructions): Multiple approaches are valid, decisions depend on context.
- **Medium freedom** (pseudocode or scripts with parameters): A preferred pattern exists, some variation is acceptable.
- **Low freedom** (specific scripts, few parameters): Operations are fragile, consistency is critical, a specific sequence must be followed.

Think of Claude exploring a path: a narrow bridge needs guardrails (low freedom), an open field allows many routes (high freedom).

### Progressive Disclosure

Skills use a three-level loading system to manage context efficiently:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed (unlimited; scripts can execute without loading into context)

Keep SKILL.md body under 500 lines. Split content into separate files when approaching this limit. Reference split-out files from SKILL.md so the reader knows they exist and when to use them.

**Pattern 1: High-level guide with references**
```markdown
## Advanced features
- **Form filling**: See references/forms.md for complete guide
- **API reference**: See references/api.md for all methods
```

**Pattern 2: Domain-specific organization**
```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── references/
    ├── finance.md (revenue, billing)
    └── sales.md (pipeline, opportunities)
```
When a user asks about sales, Claude only reads sales.md.

**Pattern 3: Conditional details**
```markdown
For simple edits, modify the XML directly.
**For tracked changes**: See references/redlining.md
```

**Guidelines:**
- Keep references one level deep from SKILL.md
- For reference files >100 lines, include a table of contents at the top

## Skill Anatomy

```
skill-name/
├── SKILL.md           (required)
├── scripts/           (optional — executable code for deterministic tasks)
├── references/        (optional — docs loaded into context as needed)
└── assets/            (optional — files used in output: templates, images, fonts)
```

**SKILL.md** has two parts:
- **Frontmatter** (YAML): `name` and `description` only. This is what Claude reads to decide when to use the skill — make it clear and trigger-oriented.
- **Body** (Markdown): Instructions and guidance. Only loaded after the skill triggers.

**scripts/**: For code rewritten repeatedly or needing deterministic reliability (e.g., `scripts/rotate_pdf.py`). Token efficient — can execute without loading into context.

**references/**: For documentation Claude should reference while working (schemas, API docs, policies). Keeps SKILL.md lean; loaded only when needed. Avoid duplicating content between SKILL.md and references — information lives in one place.

**assets/**: For files used in output, not loaded into context (templates, images, boilerplate code, fonts).

**Do NOT include**: README.md, CHANGELOG.md, INSTALLATION_GUIDE.md, or other auxiliary documentation. A skill contains only what an AI agent needs to do the job.

## Writing Style

### Body: Imperative/Infinitive Form

Write using verb-first instructions, not second person:

```
# Correct (imperative):
Parse the frontmatter using sed.
Validate the input before processing.
Configure the server with authentication.

# Incorrect (second person):
You should parse the frontmatter.
You need to validate the input.
You can configure the server.
```

### Description: Third-Person with Trigger Phrases

The frontmatter description is the primary triggering mechanism. Include specific phrases users would say:

```yaml
# Good:
description: This skill should be used when the user asks to "create a hook",
  "add a PreToolUse hook", "validate tool use", or mentions hook events
  (PreToolUse, PostToolUse, Stop). Provides comprehensive hooks API guidance.

# Bad:
description: Provides guidance for working with hooks.
```

Include all "when to use" information in the description, not in the body. The body only loads after triggering — "When to Use This Skill" sections in the body are wasted.

## Creation Workflow

### Step 1: Understand with Concrete Examples

Clearly understand how the skill will be used. Ask targeted questions:

- "What functionality should this skill support?"
- "Can you give examples of how it would be used?"
- "What would a user say that should trigger this skill?"

Avoid asking too many questions at once. Conclude when there is a clear sense of what the skill should support.

### Step 2: Plan Reusable Resources

Analyze each concrete example:
1. Consider how to execute from scratch
2. Identify what scripts, references, and assets would help when executing repeatedly

Examples:
- PDF rotation requires rewriting the same code each time -> `scripts/rotate_pdf.py`
- Frontend webapps need the same boilerplate -> `assets/hello-world/` template
- BigQuery queries require rediscovering schemas -> `references/schema.md`

### Step 3: Create Folder Structure

```bash
mkdir -p ~/.agent/skills/<skill-name>/{references,scripts,assets}
```

Choose a skill name: lowercase letters, digits, hyphens. Keep it short and action-oriented.

### Step 4: Write SKILL.md

**Frontmatter**: `name` and `description` only. No other fields except optionally `license`.

**Body**: Write instructions for using the skill and its bundled resources. Remember the skill is for another instance of Claude — include information that is beneficial and non-obvious. Challenge whether Claude already knows something before including it.

For skills with structured output, see `references/output-patterns.md`.
For skills with multi-step processes, see `references/workflows.md`.

Start implementation with the reusable resources (scripts, references, assets), then write the SKILL.md body that ties them together. Test any scripts by actually running them.

Delete example/placeholder directories not needed — only create directories with actual content.

### Step 5: Validate

Run the bundled validation script:

```bash
python3 ~/.agent/skills/create-global-skill/scripts/quick_validate.py ~/.agent/skills/<skill-name>
```

This checks: SKILL.md exists, valid YAML frontmatter, required fields (name, description), naming conventions (hyphen-case), length constraints (name <= 64 chars, description <= 1024 chars), no angle brackets in description.

### Step 6: Deploy

**Expose to OpenClaw** (symlink):
```bash
mkdir -p ~/.openclaw/skills
ln -sfn ~/.agent/skills/<skill-name> ~/.openclaw/skills/<skill-name>
```

**Legacy compatibility (optional)** — keep old Clawdbot path working:
```bash
mkdir -p ~/.clawdbot/skills
ln -sfn ~/.agent/skills/<skill-name> ~/.clawdbot/skills/<skill-name>
```

**Refresh AGENTS.md skill table** (OpenSkills sync):
```bash
# IMPORTANT: Always pass -y to skip interactive selector
npx openskills sync -y -o ~/.agent/AGENTS.md
```

Notes:
- `-y` syncs all discovered skills automatically (without it, an interactive prompt blocks agents)
- OpenSkills discovers skills from `~/.agent/skills/` and `~/.claude/skills/` (symlinked to same dir)
- Sync writes metadata only (name + description) to the skill table

**Commit and push**:
```bash
cd ~/.agent && git add -A && git commit -m "Add skill <skill-name>" && git push
```

### Step 7: Iterate

1. Use the skill on real tasks
2. Notice struggles or inefficiencies
3. Update SKILL.md or bundled resources
4. Re-validate and re-deploy

## Architecture

```
~/.agent/                     <- git repo (source of truth)
  AGENTS.md                   <- agent instructions + skill table (synced by openskills)
  skills/                     <- all skill folders

~/.claude/skills              <- symlink -> ~/.agent/skills (Claude Code discovery)
~/.claude/CLAUDE.md           <- "@~/.agent/AGENTS.md" (Claude Code @import)
~/.codex/AGENTS.md            <- symlink -> ~/.agent/AGENTS.md (Codex reads directly)
~/.codex/skills               <- symlink -> ~/.agent/skills (Codex skill discovery)
~/.openclaw/skills/*          <- per-skill symlinks -> ~/.agent/skills/*
~/.clawdbot/skills/*          <- (legacy) per-skill symlinks -> ~/.agent/skills/*
```

- **One source of truth**: `~/.agent/` is the git repo
- **Claude Code** discovers via `~/.claude/skills` symlink and AGENTS.md skill table
- **Codex** reads `~/.agent/AGENTS.md` directly via symlink
- **OpenClaw** reads per-skill symlinks under `~/.openclaw/skills/`
- **Legacy Clawdbot** (optional) can still read per-skill symlinks under `~/.clawdbot/skills/`

## Common Mistakes

**Weak trigger description:**
```yaml
# Bad — vague, no trigger phrases:
description: Provides guidance for working with hooks.

# Good — specific triggers, third person:
description: This skill should be used when the user asks to "create a hook",
  "add a PreToolUse hook", or mentions hook events. Provides hooks API guidance.
```

**Too much in SKILL.md:**
```
# Bad — everything in one file:
skill-name/
└── SKILL.md  (8,000 words)

# Good — progressive disclosure:
skill-name/
├── SKILL.md  (1,800 words)
└── references/
    ├── patterns.md (2,500 words)
    └── advanced.md (3,700 words)
```

**Second person writing:**
```
# Bad: You should start by reading the configuration file.
# Good: Start by reading the configuration file.
```

**Missing resource references:**
```markdown
# Bad — SKILL.md never mentions references/:
[Core content with no pointers to supporting files]

# Good — explicit resource section:
## Additional Resources
- **references/patterns.md** — Detailed patterns
- **references/advanced.md** — Advanced techniques
```

## Quick Checklist

- [ ] Skill folder exists under `~/.agent/skills/<skill-name>`
- [ ] `SKILL.md` has YAML frontmatter with `name` and `description`
- [ ] Description is third-person with specific trigger phrases
- [ ] Body uses imperative/infinitive form (not second person)
- [ ] Body is lean (<500 lines); detailed content in `references/`
- [ ] All referenced files exist
- [ ] Scripts are tested and executable
- [ ] No auxiliary files (README, CHANGELOG, etc.)
- [ ] Symlink exists at `~/.openclaw/skills/<skill-name>`
- [ ] (Optional) Legacy symlink exists at `~/.clawdbot/skills/<skill-name>`
- [ ] OpenSkills `sync -y` run for `~/.agent/AGENTS.md`
- [ ] Changes committed and pushed in `~/.agent` repo

## Additional Resources

- **`references/output-patterns.md`** — Template and example patterns for skills producing structured output
- **`references/workflows.md`** — Sequential and conditional workflow patterns for multi-step skills
