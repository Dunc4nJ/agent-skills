# Research Paper Workflow

Detailed procedure for capturing academic papers (arXiv, PDFs with figures/tables) into the vault. This extends the main url-to-obsidian workflow.

**All research papers use marker-pdf on a Vast.ai GPU instance** for best-in-class extraction — OCR, LaTeX equations, correct reading order for multi-column layouts, and inline figure extraction. See the `vast-gpu` skill (`~/.agent/skills/vast-gpu/SKILL.md`) for full instance management details.

## When to use

- URL points to an arXiv paper (arxiv.org/abs/... or arxiv.org/pdf/...)
- Any PDF that contains figures, tables, or diagrams worth preserving
- User explicitly asks to capture a "paper" or "research paper"

## 1. Download the PDF

```bash
# arXiv: always use the /pdf/ URL
curl -sL "https://arxiv.org/pdf/XXXX.XXXXX" -o /tmp/paper.pdf

# Verify it's a valid PDF
file /tmp/paper.pdf
```

For arXiv URLs in `/abs/` format, convert to `/pdf/` (replace `abs` with `pdf`).

## 2. Extract with marker-pdf (GPU)

Research papers **always** use marker-pdf via the Vast.ai GPU instance. This gives us:
- OCR for scanned pages
- LaTeX equation conversion
- Correct reading order for multi-column layouts
- Extracted figures/images with page position metadata

### 2a. Start the GPU and convert

```bash
# Start the Vast.ai GPU instance (RTX 3090, ~$0.11/hr)
gpu-start

# Convert PDF → markdown + images
gpu-marker /tmp/paper.pdf /tmp/paper-output/

# Stop immediately after conversion to save cost
gpu-stop
```

This produces:
```
/tmp/paper-output/
├── paper.md              # Structured markdown with LaTeX equations
├── paper_meta.json       # Metadata (page count, timing)
├── _page_0_Picture_1.jpeg   # Extracted figures
└── _page_5_Figure_1.jpeg    # More figures
```

**Cost**: ~$0.01-0.02 per paper (2-3 min runtime). First run after instance restart may take ~8 min extra for model download.

**If gpu-start fails** (instance destroyed, SSH timeout): refer to the `vast-gpu` skill for troubleshooting and instance recreation steps.

### 2b. Image filtering

Filter extracted images by size — discard anything too small to be meaningful:
- **Minimum dimensions**: 200×200 px
- **Minimum file size**: 5 KB

```bash
# List images with dimensions
for img in /tmp/paper-output/_page_*.{png,jpeg,jpg}; do
  [ -f "$img" ] && identify -format "%f %wx%h %b\n" "$img"
done
```

### 2c. Vision QC

Review each surviving image using the vision model. For each image, classify as:
- **figure** — charts, plots, graphs, results visualizations
- **table** — tabular data rendered as an image
- **diagram** — architecture diagrams, flow charts, system designs
- **junk** — logos, watermarks, repeated headers, LaTeX artifacts, decorative elements

Keep only `figure`, `table`, and `diagram` images. Generate a one-line caption for each keeper.

**Delegation rule:** If more than 10 images survive the size filter, spawn a sub-agent for the vision QC pass to avoid context bloat in the main session. The sub-agent should:
1. Review each image
2. Return a JSON report: `[{file, classification, caption, keep: bool}]`

### 2d. Rename and store

Rename keepers with the slug convention:
```
{first-author-surname}-{arxiv-id-last-5}-fig-{NNN}.{ext}
```

Example: `smith-04261-fig-001.png`, `smith-04261-fig-002.jpg`

Copy to the appropriate section's `_media/` folder:
- `Knowledge/Agents/_media/` for Agents notes (most research papers)
- `Knowledge/{Section}/_media/` for other Knowledge sections
- `Projects/_media/` for Projects notes

**No orphans**: Extract all figures aggressively, then review. Delete non-content artifacts (cover pages, decorative headers, publisher logos) before committing. Every remaining image must be embedded in the note.

## 3. Read the extracted markdown

```bash
cat /tmp/paper-output/paper.md
```

From the markdown, extract:
1. **Core claim** — a single assertive sentence capturing the main insight. This becomes the note title.
2. **Abstract** — the paper's abstract, lightly cleaned up.
3. **Key takeaways** — 3-7 insights in your own words (not copied text).
4. **Authors** — author names for frontmatter.
5. **External links** — URLs found in the content (GitHub repos, datasets, tools).

## 4. Build the note

Use the research paper note template (see `references/note-template.md`, "Format: Research Papers" section).

### Frontmatter

```yaml
---
created: YYYY-MM-DD
description: One sentence — the paper's core claim
source: https://arxiv.org/abs/XXXX.XXXXX
type: paper
authors:
  - First Author
  - Second Author
arxiv: "XXXX.XXXXX"
---
```

### Structure

```markdown
## Abstract

The paper's abstract, lightly cleaned up for readability.

## Key Takeaways

Original analysis (your own words, not copied). Weave [[wiki links]] inline.
Reference figures inline where they support a point:

*Caption describing what the figure shows*
![[slug-fig-001.png]]

## External Resources

- [Resource](url) — description

## Original Content

> [!quote]- Full Paper Text
> FULL marker-pdf markdown output here — include ALL extracted text, never summarize or abbreviate.
> The collapsed callout keeps it out of reading view but preserves the complete source.
> Figures are embedded inline at their approximate reference points:
>
> *Figure 1: System architecture*
> ![[slug-fig-001.png]]
>
> Continuing text...
>
> [Source: paper.pdf](https://arxiv.org/pdf/XXXX.XXXXX)
```

### Inline image placement

Images go at the point in the text where they're referenced, not in a separate section. In the **Original Content** callout, place each figure embed right after the paragraph that references it (e.g., after "as shown in Figure 3"). In **Key Takeaways**, reference key figures that contain data not captured in the text.

## 5. Continue with main workflow

After building the note, rejoin the main SKILL.md workflow at step 4 (find related vault notes) and continue through MOC update, commit, and push.

## Quick Reference: Full Pipeline

```
1. curl PDF → /tmp/paper.pdf
2. gpu-start
3. gpu-marker /tmp/paper.pdf /tmp/paper-output/
4. gpu-stop
5. Filter images (size gate → vision QC → rename to slug)
6. Copy images to vault _media/
7. Read /tmp/paper-output/paper.md
8. Synthesize note (frontmatter, abstract, key takeaways, original content)
9. Find related vault notes (qmd vsearch)
10. Write note to vault
11. Update nearest MOC
12. git add -A && git commit && git push && qmd update
```
