---
name: create-global-skill
description: Create and publish a "global" skill that is available to all local agents (Codex/Claude-style agents reading ~/.agent/skills) and to Clawdbot (via ~/.clawdbot/skills symlink). Use when asked to add a new skill for all agents, set up the folder structure for SKILL.md + resources, symlink into Clawdbot, and run OpenSkills sync commands (e.g. npx openskills sync) to refresh AGENTS.md skill tables.
---

# Create Global Skill (repo → ~/.agent/skills → Clawdbot)

## Goal
Create a skill once under `~/.agent/skills/<skill-name>/` and make it available everywhere:
- **Codex/Claude-style agents** that read skills from `~/.agent/skills`
- **Clawdbot agents** by symlinking into `~/.clawdbot/skills`
- **OpenSkills-indexed agents** by running the OpenSkills sync command to refresh the skills table in the canonical `AGENTS.md`

This skill defines the standard workflow.

---

## Workflow (create-global-skill)

### 0) Preconditions
- `~/.agent` is a git repo (commit after each change).
- Skills are stored as folders under `~/.agent/skills/`.

### 1) Choose a skill name
Rules:
- lowercase letters, digits, hyphens
- keep it short and action-oriented

Example: `obsidian-vault-keeper`.

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

- Target folder: `~/.clawdbot/skills/<skill-name>`
- Symlink source: `~/.agent/skills/<skill-name>`

Commands:
```bash
mkdir -p ~/.clawdbot/skills
ln -sfn ~/.agent/skills/<skill-name> ~/.clawdbot/skills/<skill-name>
```

Verification:
```bash
ls -la ~/.clawdbot/skills/<skill-name>
```

### 5) Run OpenSkills sync (to refresh AGENTS.md)
OpenSkills (per its README) uses `sync` to write/update the `<available_skills>` table.

Run (pick the canonical AGENTS.md you use):

```bash
# IMPORTANT: Always pass -y to skip the interactive selector
npx openskills sync -y -o ~/.agent/AGENTS.md
```

Notes:
- **Always use `-y`** — without it, `sync` opens an interactive multi-select prompt that blocks non-interactive agents.
- `-y` syncs all discovered skills automatically.
- OpenSkills default install locations are `.claude/skills` or `.agent/skills` depending on mode.
- This step is about keeping the skills *listing* in AGENTS.md current for ecosystems that rely on it.

### 6) Commit the change (rollback safety)
Commit after each skill add/update:
```bash
cd ~/.agent
git add -A
git commit -m "Add skill <skill-name>"
```

If vendor skills update creates noise, commit that separately:
```bash
git commit -m "Update vendor skills"
```

---

## Quick checklist
- [ ] Skill folder exists under `~/.agent/skills/<skill-name>`
- [ ] `SKILL.md` has correct frontmatter and lean body
- [ ] Symlink exists at `~/.clawdbot/skills/<skill-name>`
- [ ] OpenSkills `sync` run for the canonical `AGENTS.md`
- [ ] Changes committed in `~/.agent` repo
