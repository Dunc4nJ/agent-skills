# Research Paper Workflow

Detailed procedure for capturing academic papers (arXiv, PDFs with figures/tables) into the vault. This extends the main url-to-obsidian workflow.

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

## 2. Extract text with markitdown

```bash
markitdown /tmp/paper.pdf -o /tmp/paper-text.md
```

Why markitdown over pdftotext: preserves headings, renders tables as markdown tables, handles multi-column layouts better.

If markitdown produces poor output (garbled tables, missing sections), fall back to:
```bash
pdftotext -layout /tmp/paper.pdf /tmp/paper-text.txt
```

## 3. Extract images with pdfimages

```bash
mkdir -p /tmp/paper-images
pdfimages -all /tmp/paper.pdf /tmp/paper-images/img
```

This dumps every embedded image as a separate file (PNG, JPG, PPM, etc.).

### 3a. Size filter

Drop images that are clearly not figures:

```bash
bash scripts/extract-pdf-images.sh /tmp/paper.pdf /tmp/paper-images/
```

The script:
1. Runs `pdfimages -all`
2. Converts any PPM/PBM files to PNG via `convert` (ImageMagick)
3. Drops images under 150x150px (icons, bullets, logos)
4. Drops images under 5KB (decorative noise)
5. Outputs a JSON array of surviving filenames with dimensions

### 3b. Vision QC

Review each surviving image using the vision model. For each image, classify as:
- **figure** — charts, plots, graphs, results visualizations
- **table** — tabular data rendered as an image
- **diagram** — architecture diagrams, flow charts, system designs
- **junk** — logos, watermarks, repeated headers, LaTeX artifacts, decorative elements

Keep only `figure`, `table`, and `diagram` images. Generate a one-line caption for each keeper.

**Delegation rule:** If more than 10 images survive the size filter, spawn a sub-agent for the vision QC pass to avoid context bloat in the main session. The sub-agent should:
1. Review each image
2. Return a JSON report: `[{file, classification, caption, keep: bool}]`

### 3c. Rename and store

Rename keepers with the slug convention:
```
{first-author-surname}-{arxiv-id-last-5}-fig-{NNN}.{ext}
```

Example: `smith-04261-fig-001.png`, `smith-04261-fig-002.jpg`

Copy to the appropriate `_media/` folder:
- `Knowledge/_media/` for Knowledge notes
- `Projects/_media/` for Projects notes

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
> Markitdown output here (collapsed by default).
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
