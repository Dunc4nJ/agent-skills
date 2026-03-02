---
name: franken-research
description: "This skill should be used when the user says 'franken-research', 'research these repos', 'extract features from repos', 'build a franken project', 'compare repositories', or wants to create a project by combining the best features from multiple existing codebases. Multi-repo comparative research for building best-of-breed projects — explores repositories, interviews the user about what they're building, and generates a research prompt for deep feature extraction."
---

# Franken-Research

Extract the best features from multiple related repositories and stitch them into a unified design for a new project. Two modes: **interview** (explore repos + Q&A to generate a research prompt) and **research** (deep-dive a single repo using that prompt).

## Mode Routing

Determine which mode to run:

**User describes a project or says "research these repos"?** → Interview mode. Route to `references/interview-guide.md`
**User says "review repo X" or references an existing research prompt?** → Research mode. Read `research_docs/research_prompt.md` (or the @-referenced prompt) and follow its phases directly. A `research_docs/research_prompt.md` must exist in the workspace.

## Interview Mode (Overview)

Generate a tailored research prompt by exploring what's available and understanding what the user wants to build.

1. **Auto-detect repositories** in the workspace — scan for directories containing `.git`, `README.md`, or language markers (`Cargo.toml`, `package.json`, `go.mod`, `pyproject.toml`, `setup.py`, `pom.xml`, `build.gradle`, etc.)
2. **Explore all repos** at medium depth — launch explore agents (2 per repo if ≤4 repos, 1 per repo if 5+, batches of 3)
3. **Write `research_docs/landscape.md`** — summarize each repo's purpose, size, language, and key feature categories
4. **Multi-round Q&A** — ask informed questions about what the user is building, their priorities, and open decisions. Continue until the user signals done.
5. **Generate `research_docs/research_prompt.md`** — populate the template from `references/research-methodology.md` with interview answers and landscape data

See `references/interview-guide.md` for the full methodology.

## Research Mode (Overview)

Deep-dive a single repository to extract its most impactful, distinctive features.

1. Read `research_docs/research_prompt.md` (or the @-referenced prompt)
2. Read existing `*_findings.md` files for differentiation context
3. Execute the 4-phase methodology on the target repo
4. Write `research_docs/{repo}_findings.md`

The research prompt contains the full 4-phase methodology. See `references/research-methodology.md` for the template source used to generate it.

## Output Conventions

All outputs go in `research_docs/` at the project root:
- `research_docs/landscape.md` — repo landscape summary (interview mode)
- `research_docs/research_prompt.md` — generated research prompt (interview mode)
- `research_docs/{repo}_findings.md` — per-repo findings (research mode)

## References

- **`references/interview-guide.md`** — Detailed interview methodology: repo detection, agent launch strategy, landscape format, Q&A question categories, convergence signals
- **`references/research-methodology.md`** — Template source for generating research prompts (used by interview mode). Contains the 4-phase methodology, output format, and quality standards that get embedded into `research_prompt.md`
