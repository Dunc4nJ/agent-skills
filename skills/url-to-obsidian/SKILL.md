---
name: url-to-obsidian
description: Capture knowledge from any URL or PDF into the Obsidian vault as a linked note. Use when the user says "save this URL", "capture this to vault", "add to obsidian", "save this tweet", "capture this article", "capture this PDF", or provides a URL/file path and asks to save, store, or capture it. Routes tweets (x.com, twitter.com) via bird CLI, PDFs via pdftotext, and any other web page via playbooks.
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Task
---

# URL to Obsidian

Capture knowledge from a URL and create a linked vault note.

**Vault location**: `~/obsidian-vault`
**Collection**: `obsidian`

## Workflow

### 1. Classify and fetch content

Classify the input:
```bash
bash ~/.agent/skills/url-to-obsidian/scripts/detect-url-type.sh "<url-or-path>"
# Outputs: "pdf", "twitter", or "web"
```

**If pdf** (local file path or URL ending in `.pdf`):
```bash
bash ~/.agent/skills/url-to-obsidian/scripts/fetch-pdf.sh "<path-or-url>" /tmp/content.md
# File output: collapsible callout with full extracted text
# Stdout: JSON metadata { title, filename, description, url }
```
Prerequisite: `poppler-utils` (`sudo apt install poppler-utils`).
For `source` frontmatter: use the PDF filename (e.g., `Framework.pdf`), not the full path.

**If twitter**:
```bash
# Single tweet
bird read <url> --plain

# If output shows it is part of a thread, re-fetch the full thread
bird thread <url> --plain
```

**If web**:
```bash
npx playbooks get "<url>"
```

See `references/playbooks-usage.md` for detailed options and JSON output mode.

### 2. Analyze content

From the fetched content, extract:
1. **Core claim** — a single assertive sentence capturing the main insight. This becomes the note title.
2. **Key takeaways** — 3-7 insights in your own words (not copied text).
3. **External links** — URLs found in the content (GitHub repos, blog posts, tools, papers).
4. **Domain/topic** — what knowledge area this belongs to.

For tweets with embedded links, fetch brief context about each linked resource:
```bash
npx playbooks get "<linked-url>" --json
```
Extract only the title and a one-sentence description. Do not create separate notes.

### 3. Determine note title

Write a claim-based title in readable prose:
- GOOD: `onboarding is 70 percent of app success.md`
- GOOD: `playbooks get fetches any URL as clean markdown.md`
- BAD: `playbooks-notes.md`
- BAD: `tweet-about-tools.md`

The title should be an assertion a reader can evaluate as true or false.

### 4. Find related vault notes

Dispatch a Task subagent (subagent_type: Explore) to search the vault. This keeps search results out of main context.

Task prompt:
```
Search the Obsidian vault for notes related to: [core claim from step 2]

Run these searches and return the top 3-7 most relevant results:

qmd vsearch "[core claim]" -c obsidian -n 10
qmd search "[2-3 key terms]" -c obsidian -n 10

For each result: file path, title, one-line relevance note.
Deduplicate across both searches. Only genuinely related notes, not tangential matches.
```

Use the returned note titles as `[[wiki link]]` targets in step 6.

### 5. Determine folder placement

Analyze the content domain and suggest a folder:
- **Project-specific** (about a specific vault project) → `Projects/[Project]/`
- **Cross-cutting knowledge** (general frameworks, tools, patterns) → `Knowledge/[Domain]/`

Create a new subfolder under `Knowledge/` if no existing folder fits.

Present the suggestion to the user via AskUserQuestion:
```
Suggested location: Knowledge/[Domain]/[title].md
```
Wait for confirmation. Adjust if redirected.

### 6. Create the note

Write the note following the template in `references/note-template.md`.

Key rules:
- **Frontmatter**: `created` (today YYYY-MM-DD), `description` (one sentence elaborating the title claim), `source` (original URL), `type` (optional: framework, learning, synthesis)
- **Key Takeaways**: Original analysis in your own words. Weave `[[wiki links]]` from step 4 inline into sentences. Aim for at least one wiki link per takeaway paragraph.
- **External Resources**: URLs found in the content with one-line descriptions.
- **Original Content**: Tweets as standard blockquotes with author handle, date, and engagement stats. Long web content in a collapsible Obsidian callout: `> [!quote]- Source Material`
- Always include a link back to the original URL.
- No emoji in headings or body.
- No "Related:" section at the bottom. All links woven inline.

### 7. Update the nearest MOC

Find and update the relevant MOC:
- For `Knowledge/` notes: update `moc - Vault.md` under the matching Knowledge subsection
- For `Projects/` notes: update the project MOC (`moc - [Project].md`)

If adding to a new Knowledge subfolder, create a new subsection in `moc - Vault.md`:
```markdown
- **[New Domain]** — one-line description
  - [[note title]]
```

### 8. Sync

```bash
cd ~/obsidian-vault && git add -A && git commit -m "vault: capture [short description] from [source type]" && git push
qmd update
```

### 9. Report

Output a summary:
```
Captured: [note title]
Location: [full file path]
Source: [URL]
Related notes linked: [[note1]], [[note2]], ...
MOC updated: [which MOC]
```

## Quality Checks

Before finishing, verify:
- [ ] Title is a claim (readable prose assertion, not keywords)
- [ ] YAML frontmatter has `created`, `description`, `source`
- [ ] Key Takeaways contains original analysis, not copied text
- [ ] 3-7 `[[wiki links]]` woven inline into sentences
- [ ] External links listed with brief descriptions
- [ ] Original content preserved (blockquote or collapsible callout)
- [ ] Link to original URL included
- [ ] Nearest MOC updated
- [ ] Changes committed, pushed, and qmd re-indexed
