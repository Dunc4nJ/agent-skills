# AGENTS

<skills_system priority="1">

## Available Skills

<!-- SKILLS_TABLE_START -->
<usage>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke: `npx openskills read <skill-name>` (run in your shell)
  - For multiple: `npx openskills read skill-one,skill-two`
- The skill content will load with detailed instructions on how to complete the task
- Base directory provided in output for resolving bundled resources (references/, scripts/, assets/)

Usage notes:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already loaded in your context
- Each skill invocation is stateless
</usage>

<available_skills>

<skill>
<name>stripe-best-practices</name>
<description>Best practices for building a Stripe integrations</description>
<location>global</location>
</skill>

<skill>
<name>vercel-composition-patterns</name>
<description>React composition patterns that scale. Use when refactoring components with</description>
<location>global</location>
</skill>

<skill>
<name>upgrade-stripe</name>
<description>Guide for upgrading Stripe API versions and SDKs</description>
<location>global</location>
</skill>

<skill>
<name>ntm-prompt-palette-adder</name>
<description>Add a new prompt to the ntm command palette with deep thinking best practices</description>
<location>global</location>
</skill>

<skill>
<name>agent-browser</name>
<description>Automates browser interactions for web testing, form filling, screenshots, and data extraction. Use when the user needs to navigate websites, interact with web pages, fill forms, take screenshots, test web applications, or extract information from web pages.</description>
<location>global</location>
</skill>

<skill>
<name>twitter-bird-workflows</name>
<description>Read/search X (Twitter) and draft posts/replies using the bird CLI with safety guardrails. Use when you need to check timelines, read threads, search X, summarize findings, or prepare a tweet/reply draft. NEVER post without explicit user approval.</description>
<location>global</location>
</skill>

<skill>
<name>vercel-react-best-practices</name>
<description>React and Next.js performance optimization guidelines from Vercel Engineering. This skill should be used when writing, reviewing, or refactoring React/Next.js code to ensure optimal performance patterns. Triggers on tasks involving React components, Next.js pages, data fetching, bundle optimization, or performance improvements.</description>
<location>global</location>
</skill>

<skill>
<name>create-global-skill</name>
<description>Create and publish a “global” skill that is available to all local agents (Codex/Claude-style agents reading ~/.agents/skills) and to Clawdbot (via ~/.clawdbot/skills symlink). Use when asked to add a new skill for all agents, set up the folder structure for SKILL.md + resources, symlink into Clawdbot, and run OpenSkills sync commands (e.g. npx openskills sync) to refresh AGENTS.md skill tables.</description>
<location>global</location>
</skill>

<skill>
<name>nia-docs</name>
<description>Search library documentation and code examples via Nia (package semantic search, regex grep, and universal search). Use when you need API docs/code examples across npm, PyPI, crates, or Go modules. Requires NIA_API_KEY.</description>
<location>global</location>
</skill>

<skill>
<name>bd-to-br-migration</name>
<description>>-</description>
<location>global</location>
</skill>

<skill>
<name>zombie-killer</name>
<description>Detect and kill zombie processes on the VPS. Use when the user mentions zombies, defunct processes, slow VPS, high load average, stale agent sessions, or process cleanup. Triggers on "check zombies", "kill zombies", "why is my server slow", "clean up processes", "defunct processes".</description>
<location>global</location>
</skill>

<skill>
<name>perplexity-search</name>
<description>AI-powered web search and research via Perplexity (Sonar models), including ranked search results and AI-synthesized answers with citations. Use for up-to-date facts, source gathering, deep research, and reasoning. Requires PERPLEXITY_API_KEY.</description>
<location>global</location>
</skill>

<skill>
<name>vercel-react-native-skills</name>
<description>React Native and Expo best practices for building performant mobile apps. Use</description>
<location>global</location>
</skill>

<skill>
<name>aprx-iterate</name>
<description>Runs iterative APRX specification refinement until convergence. Executes APRX rounds, integrates GPT Pro suggestions into spec and README, commits changes, and tracks convergence. Use when user wants to refine a specification through multiple GPT Pro review cycles.</description>
<location>global</location>
</skill>

<skill>
<name>frontend-design</name>
<description>Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics.</description>
<location>global</location>
</skill>

<skill>
<name>web-design-guidelines</name>
<description>Review UI code for Web Interface Guidelines compliance. Use when asked to "review my UI", "check accessibility", "audit design", "review UX", or "check my site against best practices".</description>
<location>global</location>
</skill>

<skill>
<name>skill-creator</name>
<description>Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.</description>
<location>global</location>
</skill>

<skill>
<name>create-plan</name>
<description>Iterative planning skill that explores codebases, researches best practices via Perplexity/NIA, and creates comprehensive self-contained plans through multiple clarification rounds. Use when asked to create, design, or plan any feature, refactor, or implementation.</description>
<location>global</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>
