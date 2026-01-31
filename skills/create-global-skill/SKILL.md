---
name: create-global-skill
description: Create and publish a "global" skill that is available to all local agents (Codex/Claude-style agents reading ~/.agent/skills) and to Clawdbot (via ~/.clawdbot/skills symlink). Use when asked to add a new skill for all agents, set up the folder structure for SKILL.md + resources, symlink into Clawdbot, and run OpenSkills sync commands (e.g. npx openskills sync) to refresh AGENTS.md skill tables.
---

# Create Global Skill

## Architecture

```
~/.agent/                     ← git repo (origin: GitHub)
  AGENTS.md                   ← agent instructions + skill table (synced by openskills)
  skills/                     ← all skill folders live here

~/.claude/skills              ← symlink → ~/.agent/skills (OpenSkills Claude Code path)
~/.claude/CLAUDE.md           ← "@~/.agent/AGENTS.md" (Claude Code @import)
~/.codex/AGENTS.md            ← symlink → ~/.agent/AGENTS.md (Codex reads directly)
~/.clawdbot/skills/*          ← per-skill symlinks → ~/.agent/skills/*
```

- **One source of truth**: `~/.agent/` is the git repo containing skills and AGENTS.md
- **Claude Code** discovers skills natively via `~/.claude/skills` symlink AND via the AGENTS.md skill table (@import)
- **Codex** reads `~/.agent/AGENTS.md` directly via symlink (Codex does NOT support `@` imports)
- **Clawdbot** reads per-skill symlinks under `~/.clawdbot/skills/`

## Workflow

### 0) Preconditions
- `~/.agent` is a git repo with remote `origin` (commit and push after each change).
- Skills are stored as folders under `~/.agent/skills/`.

### 1) Choose a skill name
Rules:
- lowercase letters, digits, hyphens
- keep it short and action-oriented

Example: `zombie-killer`.

### 2) Create the skill folder
Create:
```
~/.agent/skills/<skill-name>/
  SKILL.md
  references/   (optional)
  scripts/      (optional)
  assets/       (optional)
```

### 3) Write SKILL.md correctly
In `SKILL.md` frontmatter, include ONLY:
- `name`
- `description`

Guidance:
- Make `description` highly trigger-oriented (include example prompts and contexts).
- Keep body concise; move bulk to `references/`.
- Put deterministic/reused code into `scripts/`.

### 4) Expose the skill to Clawdbot (symlink)
Create/update symlink:

```bash
mkdir -p ~/.clawdbot/skills
ln -sfn ~/.agent/skills/<skill-name> ~/.clawdbot/skills/<skill-name>
```

Verification:
```bash
ls -la ~/.clawdbot/skills/<skill-name>
```

### 5) Run OpenSkills sync (to refresh AGENTS.md skill table)
This updates the `<available_skills>` XML block in AGENTS.md with metadata (name + description) for all discovered skills.

```bash
# IMPORTANT: Always pass -y to skip the interactive selector
npx openskills sync -y -o ~/.agent/AGENTS.md
```

Notes:
- **Always use `-y`** — without it, `sync` opens an interactive multi-select prompt that blocks non-interactive agents.
- `-y` syncs all discovered skills automatically.
- OpenSkills discovers skills from both `~/.agent/skills/` (universal path) and `~/.claude/skills/` (Claude Code path, which symlinks to the same directory).
- The sync writes metadata only (name + description) to the skill table. Full SKILL.md content loads on-demand via `npx openskills read <skill-name>`.

### 6) Commit and push
```bash
cd ~/.agent
git add -A
git commit -m "Add skill <skill-name>"
git push
```

---

## Quick checklist
- [ ] Skill folder exists under `~/.agent/skills/<skill-name>`
- [ ] `SKILL.md` has correct frontmatter and lean body
- [ ] Symlink exists at `~/.clawdbot/skills/<skill-name>`
- [ ] OpenSkills `sync -y` run for `~/.agent/AGENTS.md`
- [ ] Changes committed and pushed in `~/.agent` repo
