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
**Media folders**: `~/obsidian-vault/Knowledge/_media/` (public) and `~/obsidian-vault/Projects/_media/` (private)
**Collection**: `obsidian`

## Workflow

### 0. Early fork: GitHub repo → Resource fast-path

If the URL is a GitHub repository root (e.g. `github.com/org/repo`), treat it as a **resource capture** by default. Skip the full knowledge workflow and follow these steps:

1. **Fetch README** — `web_fetch` on `https://github.com/org/repo` (the rendered README is on the main page)
2. **Synthesize blurb** — Write 2-3 sentences for "What it is" and "Why it's interesting" from the README content
3. **Determine subfolder** — If the user specified a subfolder (e.g. "put this in Orchestration"), use it. If not, search the vault with `qmd vsearch` to find the best-matching `Knowledge/Agents/{subfolder}/resources/` folder and use that.
4. **Create note** — Use the resource template (`references/resource-template.md`). Title is the project/repo name, not a claim.
5. **Sync** — Commit, push, `qmd update` (same as step 8 of the main workflow)
6. **Report** — Note title, location, source URL

The user can override this by saying "capture this as a knowledge note" or similar — in that case, fall through to the full workflow below.

---

### 1. Classify and fetch content

Classify the input:
```bash
bash ~/.agent/skills/url-to-obsidian/scripts/detect-url-type.sh "<url-or-path>"
# Outputs: "pdf", "twitter", or "web"
```

**If pdf** (local file path or URL ending in `.pdf`):

For **research papers** (arXiv, academic PDFs with figures/tables): follow `references/research-paper-workflow.md` instead — it uses **marker-pdf on a Vast.ai GPU instance** (see `vast-gpu` skill) for best-in-class extraction: OCR, LaTeX equations, correct multi-column reading order, and inline figure extraction. Vision QC for figure filtering and a paper-specific note template. Rejoin this workflow at step 4.

For **simple PDFs** (reports, docs without important figures):
```bash
python ~/.agent/skills/url-to-obsidian/scripts/extract-pdf-pymupdf.py "<path-or-url>" > /tmp/content.md
```
Prerequisite: `pip install pymupdf pymupdf4llm` (~25MB, instant).
For `source` frontmatter: use the PDF filename (e.g., `Framework.pdf`), not the full path.

**If twitter**:
```bash
# Single tweet — always save to temp file
bird read <url> --plain > /tmp/source_content.md

# If output shows it is part of a thread, re-fetch the full thread
bird thread <url> --plain > /tmp/source_content.md
```

**If web**:
```bash
npx playbooks get "<url>" > /tmp/source_content.md
```

**All modes must save to `/tmp/source_content.md`** (PDF already saves to `/tmp/content.md`). This file is the ground truth for the Original Content section — the agent must read from it during note writing, never reproduce content from memory.

See `references/playbooks-usage.md` for detailed options and JSON output mode.

### 1b. Extract images (twitter and web)

For **twitter** URLs, extract all content images from the post:
```bash
# Route to the correct _media/ based on where the note will live (step 5)
# Public notes (Knowledge/):
bash ~/.agent/skills/url-to-obsidian/scripts/extract-tweet-images.sh "<url>" "<slug>" ~/obsidian-vault/Knowledge/_media/

# Private notes (Projects/):
bash ~/.agent/skills/url-to-obsidian/scripts/extract-tweet-images.sh "<url>" "<slug>" ~/obsidian-vault/Projects/_media/
```

**Slug convention**: `{author_handle}-{last_6_digits_of_tweet_id}`
- Example: URL `https://x.com/nicbstme/status/2021656728094617652` → slug `nicbstme-617652`

The script:
1. Opens the tweet in agent-browser
2. Scrolls to load all lazy images
3. Extracts `pbs.twimg.com/media/` URLs (filters out profile pics, emoji, icons)
4. Downloads at full resolution (`name=large`)
5. Returns a JSON array of filenames: `["slug-001.png", "slug-002.jpg", ...]`

Images are numbered in visual order (001 = first image in the article/thread).

For **web** URLs, the agent examines the page directly using agent-browser:
```bash
agent-browser open "<url>"
# Inspect the page — identify content images (diagrams, charts, tables, screenshots)
# Skip decoration (logos, icons, nav images, tracking pixels)
agent-browser eval 'JSON.stringify(Array.from(document.querySelectorAll("article img, main img, [role=main] img, .post img, .content img")).map(i=>({src:i.src,alt:i.alt,w:i.naturalWidth,h:i.naturalHeight})))'
# Use judgment: download images that carry information not in the text
# curl -sL -o ~/obsidian-vault/Knowledge/_media/slug-001.png "<image_url>"
agent-browser close
```
No generic script needed — the agent sees the page and decides which images matter.
Use the same slug convention: `{domain_or_author}-{short_id}-{NNN}.{ext}`

For **PDFs**, skip image extraction (text-only capture via pdftotext).

**Image storage convention**:
- Each top-level vault folder has its own `_media/` subfolder:
  - `Knowledge/_media/` — images for public Knowledge notes (ships with public repo)
  - `Projects/_media/` — images for private Projects notes
- This ensures images travel with their notes when folders are published separately

**Image embedding convention** (used in step 6):
- Embed with Obsidian wiki syntax: `![[slug-001.png]]`
- Obsidian resolves filenames globally, so embeds work regardless of `_media/` location
- Add a brief italic caption above each embed:
  ```markdown
  *Pricing comparison: cached vs uncached tokens*
  ![[nicbstme-617652-001.png]]
  ```
- Place embeds in the **Original Content** section near the text they illustrate
- Also reference key images in **Key Takeaways** if they contain data absent from the text

**Important**: Run image extraction AFTER determining folder placement (step 5) so you know which `_media/` folder to target. If folder placement is uncertain, default to `Knowledge/_media/` and move later if needed.

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
- **Resource** (repo, tool, library — reference material, not synthesized knowledge) → `Knowledge/Agents/{subfolder}/resources/`

Create a new subfolder under `Knowledge/` if no existing folder fits.

**Resource capture:** If you reach this step and realize the content is a repo/tool/library, use the resource fast-path in **step 0** above. GitHub repo URLs should have been caught there already — this is a fallback for non-GitHub tools discovered mid-analysis.

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
- **Original Content**: The **complete, unabridged, verbatim** source text. This is the most important rule in this entire skill: NEVER summarize, paraphrase, condense, or rewrite the original content.
  - **How to write it**: Open `/tmp/source_content.md` (or `/tmp/content.md` for PDFs) with the Read tool. Copy its contents line-by-line into the Original Content section. Do NOT retype from memory or context — always read from the temp file.
  - **Images**: Insert `![[slug-NNN.ext]]` embeds at their natural positions in the flow (where the image appeared in the source) with a brief italic caption above each.
  - **Formatting**: Tweets as standard blockquotes with author handle, date, and engagement stats header. Long web/PDF content in a collapsible Obsidian callout: `> [!quote]- Source Material`.
  - **The rule**: If a tweet has 15 paragraphs, all 15 go in. If an article is 5000 words, all 5000 words go in. The Original Content section is an archive — its job is to preserve the source exactly as written so we never need to visit the URL again.
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

### 8. Verify original content

Before committing, verify the Original Content section is complete:

```bash
bash ~/.agent/skills/url-to-obsidian/scripts/verify-original-content.sh "<note_path>" /tmp/source_content.md
```

- **OK (≥90%)** — proceed to sync.
- **WARNING (80-90%)** — review what's missing. Minor formatting differences are fine; missing paragraphs are not.
- **FAIL (<80%)** — content was summarized or truncated. Re-read `/tmp/source_content.md` and fix the Original Content section before proceeding. Do NOT report success to the user until this passes.

### 9. Sync

```bash
cd ~/obsidian-vault && git add -A && git commit -m "vault: capture [short description] from [source type]" && git push
qmd update
```

### 10. Report

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
- [ ] Original content is **verbatim** — verified by `verify-original-content.sh` (≥90% word coverage). Do not report success if verification fails.
- [ ] Link to original URL included
- [ ] Nearest MOC updated
- [ ] **Images captured** (if source had images): downloaded to `_media/`, embedded with `![[filename]]` and captions
- [ ] Changes committed, pushed, and qmd re-indexed
