# Research Methodology

This file is both the methodology for executing research on a target repository AND the template used by interview mode to generate `research_prompt.md`. There is one source of truth for the 4-phase process and output format.

## Prompt Template

The interview mode populates the placeholders below with project-specific content from the Q&A and landscape scan. In research mode, the agent reads the generated `research_prompt.md` (which was produced from this template) and follows the phases directly.

````markdown
# {PROJECT_NAME} Deep Research Prompt

Use this prompt to analyze any repository in the {PROJECT_NAME} collection. Replace `{REPO}` with the repository directory name.

---

## What We're Building

<!-- Generated from interview answers -->

**{PROJECT_NAME}** is a {language}-based {form_factor} with these defining characteristics:

- **{Characteristic 1}.** {Description from interview}
- **{Characteristic 2}.** {Description from interview}
- **Essential capabilities** (all priorities):
  1. **{Capability 1}** -- {Brief description}
  2. **{Capability 2}** -- {Brief description}
  [Add as many as identified in the interview]
- **Open technical decisions** (research should inform these):
  - {Decision 1}
  - {Decision 2}
  [Add as many as identified in the interview]

When evaluating features from `{REPO}`, ask: **"Would this make {PROJECT_NAME} better?"** -- {evaluation_criteria_from_interview}.

<!-- ALTERNATE FRAMING: For existing-project research, replace the section above with: -->
<!--
## What We're Improving

**{PROJECT_NAME}** is an existing {language}-based {form_factor}.

**Current state**: {Brief description of the project today — what it does, how it works}

**What's missing or weak**: {Capabilities or qualities the project lacks}

**Target state**: {What the project should become after incorporating research findings}

When evaluating features from `{REPO}`, ask: **"Does {PROJECT_NAME} already have this? If not, would adding it meaningfully improve {target_dimension}?"** -- {evaluation_criteria_from_interview}.
-->

---

## The Prompt

You are conducting deep research on `{REPO}` located at `{workspace_path}/{REPO}`. Your goal is to produce a self-contained research document at `{workspace_path}/research_docs/{REPO}_findings.md` that identifies the best, most impactful features -- features that {PROJECT_NAME} should consider adopting.

### Context

The other repositories in this collection are:

| Repo | Path | Description |
|------|------|-------------|
<!-- Populated from landscape.md -->
| {repo_name} | `{repo_path}` | {one-line description} |

Existing research docs (read these FIRST for context on what's already been discovered):
- Check `{workspace_path}/research_docs/` for any `*_findings.md` files
- These tell you what features have already been identified so you can focus on what makes THIS repo genuinely different
- If no other findings exist yet, that's fine -- you're the first

### Phase 1: Orientation

Before launching any deep exploration, ground yourself:

1. **Read existing research docs** in `research_docs/` to understand what features have already been identified. This is critical -- you need to know what's already been found to identify what makes THIS repo genuinely different.

2. **Read the target repo's README.md** and any project documentation (CLAUDE.md, AGENTS.md, CONTRIBUTING.md, .cursorrules). These tell you what the project claims to be and how it's organized.

3. **Map the directory structure** -- understand the top-level layout, where the core source code lives, what the module/package boundaries are.

4. Based on steps 1-3, identify 3 distinct exploration domains that cover the full surface area. Each domain should be explored by a separate agent in parallel.

### Phase 2: Deep Parallel Exploration

Launch up to 3 explore agents in parallel, each with a distinct focus area. Common domain splits (adapt based on repo structure):

- **Agent A: Core algorithms and data flow** -- How the main abstractions are defined, configured, and executed. The primary processing pipeline, state management, core algorithms.

- **Agent B: Data management and intelligence** -- Storage, retrieval, caching, learning, reasoning, context management, data processing. How the system manages and leverages its data.

- **Agent C: Infrastructure and extensibility** -- Abstraction layers, persistence, serving, observability, configuration, plugin/extension system, CLI/API experience.

Each explore agent should:
- Read actual source files, not just READMEs
- Trace the main execution path through the code
- Identify the key classes/structs/functions and their relationships
- Read 2-3 example files to see how the API is actually used
- Note file paths and line numbers for key implementations
- Focus on what seems novel, well-designed, or unusually thorough
- Investigate performance-relevant patterns: streaming, caching, concurrency, batching, and other optimizations

### Phase 3: Synthesis and Differentiation

After exploration results return, evaluate each feature or pattern:

1. **Document all significant features in Feature Analysis** -- even if another repo implements the same capability. Seeing HOW different repos solve the same problem reveals different approaches, trade-offs, and sometimes a superior implementation. Feature Analysis is a complete record of what this repo does.

2. **For the "adopt" section, filter for genuine novelty.** Check against existing research docs and the "What We're Building" section. If another repo already has a stronger version of the same approach, it's not this repo's gift. But if this repo has a meaningfully different approach to the same problem, that IS worth adopting -- note what makes the approach distinct.

3. **Is this well-implemented?** Look for sophistication -- edge case handling, extensibility, clean abstractions.

4. **Would this make {PROJECT_NAME} better?** Evaluate against the stated priorities.

Optional: briefly explore 1-2 other repos to confirm novelty.

### Phase 4: Write the Research Document

Write `research_docs/{REPO}_findings.md` following the exact structure below. **Do not deviate from this structure.** Every section is required. Do not add sections that aren't listed here.

```markdown
# {REPO} Findings (Deep Dive)

## Scope and Method
- What was explored, how, which agents were launched and what each covered
- Primary sources reviewed (README, docs, key source files with paths)

## README Alignment: What Is Unique About This Project
- What does the README claim this project is?
- For each major claim (3-5 claims), verify against actual code with file:line references
- What is the project's genuine identity/positioning? (2-3 sentences)

## Architecture Overview
- High-level architecture (3-5 sentences)
- Module/directory map with purposes
- Key abstractions and how they relate

## Feature Analysis

### 1. Feature Name (subsystem path)
**What it is**: One sentence.
**Key files**: file paths and approximate sizes
**How it works**: Implementation details with file:line code references. Describe the PATTERN and ALGORITHM, not a line-by-line walkthrough.
**Notable details**: Parameters, edge cases, design decisions that matter

[Repeat for each significant feature/subsystem.]

## What Our Project Should Adopt From {REPO}

These are {REPO}'s distinctive contributions -- features that represent genuine innovations or unusually strong implementations. Ranked by impact.

### 1. Feature Name (IMPACT LEVEL)

**The idea**: What is it in one sentence.

**Why this matters for {PROJECT_NAME}**: Why this is valuable. What problem does it solve. What happens if we don't have this.

**How it works** (language-agnostic pseudocode/pattern description):
- Core algorithm, data structures, and state transitions
- Key abstractions and their relationships
- Configuration model and API surface
- Enough detail to implement without reading the original source

**Source**: File paths with approximate sizes (for reference, not for copying)

[Repeat for each feature worth adopting. Rank by impact: HIGHEST, VERY HIGH, HIGH, MEDIUM-HIGH, MEDIUM.]

## Summary

{REPO}'s gifts to {PROJECT_NAME}, in order of impact:

1. **Feature** - One sentence on why
2. **Feature** - One sentence on why
[...]
```

### Quality Standards

These are hard requirements, not suggestions. Documents that violate these will be rejected and redone.

- **Self-contained**: The document must stand alone. Do not reference other findings docs in the body.

- **Code-grounded**: Every claim must trace to a file path. Use `path/to/file.ext` (approximate size) format. Do NOT copy large blocks of source code.

- **Pseudocode over source code**: Use language-agnostic pseudocode or pattern descriptions. Do NOT paste raw source code from the repo. Describe the PATTERN so it can be re-implemented.

- **Honest about impact**: A short "adopt" list with genuinely novel items is far more valuable than a padded list full of table-stakes features.

- **Implementation-focused**: Each "adopt" item needs algorithms, data structures, state machines, and integration points.

- **No comparison sections**: Do NOT include tables comparing repos, "weaknesses", "risks/tradeoffs", "practical blueprint", or "what to simplify" sections. Each doc is purely about what THIS repo contributes. Cross-repo synthesis happens separately.

- **Strict section structure**: Use ONLY the sections listed above. Do not add Table of Contents, Appendix, File Index, or any other sections.
````

## Customization Notes

The interview mode may adjust this template based on project-specific needs:

- **Section names**: The "What Our Project Should Adopt" section name should reference the actual project name
- **Agent exploration domains**: The 3-agent split may be adjusted based on the domain (e.g., for a UI framework: rendering, state management, developer tooling)
- **Evaluation criteria**: The synthesis questions should reflect the project's stated priorities
- **Language-specific quality standards**: If the project targets a specific language (e.g., Rust, Go), add language context to quality standards — e.g., "we're building in Rust, so Python snippets aren't directly useful; describe patterns as language-agnostic pseudocode" and "a Rust developer could implement it without reading the original source". This significantly improves the usefulness of the adopt section.
- **Domain-specific explore instructions**: Add performance patterns relevant to the domain in the explore agent checklist — e.g., for agent harnesses: "streaming/buffering semantics, prompt caching, concurrency/parallelism"; for web frameworks: "SSR hydration, bundle splitting, edge rendering"
- **Additional recommended sections**: If the interview reveals project-specific needs, additional sections may be added to the template (while keeping the 6 core sections as the baseline)
- **Existing-project research**: If the user is researching repos to improve an existing project (not building something new), replace the "What We're Building" section with the alternate "What We're Improving" framing provided in the template comments
