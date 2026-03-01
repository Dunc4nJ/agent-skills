# ExampleProject Deep Research Prompt

<!--
  This is an example of what the interview mode produces.
  It shows the structure and level of detail expected in a generated research prompt.
  Domain-specific content has been replaced with generic examples.
-->

Use this prompt to analyze any repository in the ExampleProject collection. Replace `{REPO}` with the repository directory name (e.g., `repo-alpha`, `repo-beta`, `repo-gamma`).

---

## What We're Building

<!-- This section was generated from interview answers -->

**ExampleProject** is a Rust-based CLI tool with these defining characteristics:

- **CLI-first product with library-quality internals.** Users run `exampleproject` directly as an interactive tool. But the core is a library crate with clean public APIs so developers can also import it to build their own systems.
- **General-purpose but domain-optimized.** The framework doesn't assume a specific use case, but the default toolset and experience are optimized for the primary domain.
- **Essential capabilities** (all day-one priorities):
  1. **Security/safety** -- Defense-in-depth: sandboxing, input validation, capability-based access control. Non-negotiable for a tool that executes external operations.
  2. **Extension/plugin system** -- Hybrid/layered extensibility. Users can add custom components and behaviors.
  3. **Multi-agent coordination** -- Subagent spawning, team coordination, task delegation.
  4. **Learning/memory across sessions** -- Persistent memory, learned patterns, user preferences that carry across sessions.
  5. **Multi-provider support** -- Clean abstraction supporting multiple backends. Users choose their provider.
- **Open technical decisions** (research should inform these):
  - Context management strategy (compaction vs. eviction vs. hybrid)
  - Session persistence model (file-based vs. database vs. hybrid)
  - Extension architecture specifics (which tiers, what sandboxing model)

When evaluating features from `{REPO}`, ask: **"Would this make ExampleProject better?"** -- considering all dimensions equally: reliability/safety, developer experience, performance/efficiency, and capability breadth.

---

## The Prompt

You are conducting deep research on `{REPO}` located at `/path/to/workspace/{REPO}`. Your goal is to produce a self-contained research document at `/path/to/workspace/research_docs/{REPO}_findings.md` that identifies the best, most impactful features -- features that ExampleProject should consider adopting.

### Context

The other repositories in this collection are:

| Repo | Path | Description |
|------|------|-------------|
| repo-alpha | `/path/to/workspace/repo-alpha` | Alpha framework (large codebase, extensive provider support, layered security) |
| repo-beta | `/path/to/workspace/repo-beta` | Beta tool (Python, serving layer, learning system, team coordination) |
| repo-gamma | `/path/to/workspace/repo-gamma` | Gamma framework (middleware composition, context management) |
| repo-delta | `/path/to/workspace/repo-delta` | Delta CLI (lightweight, focused feature set) |

Existing research docs (read these FIRST for context on what's already been discovered):
- Check `/path/to/workspace/research_docs/` for any `*_findings.md` files
- These tell you what features have already been identified so you can focus on what makes THIS repo genuinely different
- If no other findings exist yet, that's fine -- you're the first

### Phase 1: Orientation

Before launching any deep exploration, ground yourself:

1. **Read existing research docs** in `research_docs/` to understand what features have already been identified. This is critical -- you need to know what's already been found to identify what makes THIS repo genuinely different.

2. **Read the target repo's README.md** and any project documentation. These tell you what the project claims to be and how it's organized.

3. **Map the directory structure** -- understand the top-level layout, where the core source code lives, what the module/package boundaries are.

4. Based on steps 1-3, identify 3 distinct exploration domains that cover the full surface area. Each domain should be explored by a separate agent in parallel.

### Phase 2: Deep Parallel Exploration

Launch up to 3 explore agents in parallel, each with a distinct focus area. Common domain splits (adapt based on repo structure):

- **Agent A: Core execution architecture** -- How the main abstractions are defined, configured, and executed. The main loop, state management, core algorithms.

- **Agent B: Intelligence and data layer** -- Knowledge, memory, learning, reasoning, context management, data processing.

- **Agent C: Infrastructure and extensions** -- Abstraction layers, persistence, serving, observability, configuration, plugin/extension system, CLI/API experience.

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

1. **Is this genuinely novel?** Check against existing research docs. If another repo already has a stronger version, it's not this repo's gift.

2. **Is this well-implemented?** Look for sophistication -- edge case handling, extensibility, clean abstractions.

3. **Would this make ExampleProject better?** Evaluate against all stated priorities equally.

4. **Is this table stakes or genuinely distinctive?** Common features are table stakes. Do NOT promote to the "adopt" section unless genuinely superior.

### Phase 4: Write the Research Document

Write `research_docs/{REPO}_findings.md` following the exact structure below. **Do not deviate from this structure.**

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
**How it works**: Describe the PATTERN and ALGORITHM, not a line-by-line walkthrough.
**Notable details**: Parameters, edge cases, design decisions that matter

[Repeat for each significant feature/subsystem.]

## What Our Project Should Adopt From {REPO}

### 1. Feature Name (IMPACT LEVEL)

**The idea**: What is it in one sentence.

**Why this matters for ExampleProject**: Why this is valuable. What problem does it solve.

**How it works** (language-agnostic pseudocode/pattern description):
- Core algorithm, data structures, and state transitions
- Key abstractions and their relationships
- Configuration model and API surface
- Enough detail to implement without reading the original source

**Source**: File paths with approximate sizes

[Rank by impact: HIGHEST, VERY HIGH, HIGH, MEDIUM-HIGH, MEDIUM.]

## Summary

{REPO}'s gifts to ExampleProject, in order of impact:

1. **Feature** - One sentence on why
2. **Feature** - One sentence on why
```

### Quality Standards

- **Self-contained**: The document must stand alone.
- **Code-grounded**: Every claim must trace to a file path.
- **Pseudocode over source code**: Describe PATTERNS, not raw source code.
- **Honest about impact**: Don't pad the "adopt" list.
- **Implementation-focused**: Algorithms, data structures, state machines.
- **No comparison sections**: No cross-repo comparisons, weaknesses, risks, or blueprints.
- **Strict section structure**: Use ONLY the sections listed above.
