# Vault Integration

How product research output integrates with the Obsidian vault structure, brand context files, and downstream skills.

## Table of Contents

1. [Output Path Patterns](#output-path-patterns)
2. [Frontmatter Conventions](#frontmatter-conventions)
3. [Brand Context File Updates](#brand-context-file-updates)
4. [Downstream Skill Integration](#downstream-skill-integration)
5. [Commit & Index Workflow](#commit--index-workflow)

---

## Output Path Patterns

### Base Path

```
/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Research/
```

- `{Brand}` — PascalCase brand name (e.g., `SnugglePaws`, `AquaGlow`)
- `{product-slug}` — lowercase, hyphenated product name (e.g., `weighted-plush-bear`, `vitamin-c-serum`)

### File Naming

```
{product-slug}-research-dossier.md
{product-slug}-copy-quotes.md
{product-slug}-market-landscape.md
{product-slug}-competitor-teardown.md
{product-slug}-voc-analysis.md
{product-slug}-objection-kill-sheet.md
{product-slug}-persona-positioning.md
{product-slug}-messaging-ad-angles.md
{product-slug}-pricing-bundling.md
```

### Directory Creation

```bash
BRAND="BrandName"
SLUG="product-slug"
RESEARCH_DIR="/data/projects/obsidian-vault/Projects/Ecommerce/Business/${BRAND}/Research"
mkdir -p "$RESEARCH_DIR"
```

### Brand Folder Structure (Context)

Product research files live alongside other brand files:

```
Business/{Brand}/
├── product-catalog.md          ← updated with researched product data
├── creative-kit.md             ← updated with ad angles and visual concepts
├── learnings-log.md            ← updated with key insights and objection reframes
├── brand-strategy.md           ← existing brand context (read, don't overwrite)
├── Research/
│   ├── {slug}-research-dossier.md
│   ├── {slug}-copy-quotes.md
│   └── ... (all research files)
├── Ads/                        ← downstream ad content
├── Content/                    ← downstream organic content
└── Images/                     ← downstream image assets
```

---

## Frontmatter Conventions

Every research output file includes YAML frontmatter:

```yaml
---
created: 2026-02-27
type: product-research
brand: BrandName
product: Product Name
description: Brief description of this file's contents
source: web-research
---
```

### Field Definitions

| Field | Description | Example |
|-------|-------------|---------|
| `created` | ISO date of creation | `2026-02-27` |
| `type` | Always `product-research` | `product-research` |
| `brand` | Brand name (PascalCase) | `SnugglePaws` |
| `product` | Human-readable product name | `Weighted Plush Bear` |
| `description` | What this specific file covers | `Voice of customer analysis from Amazon, Reddit, TikTok, YouTube` |
| `source` | Data origin | `web-research` |

---

## Brand Context File Updates

### product-catalog.md

After research, add/update the product entry:

```markdown
## {Product Name}

**Slug:** {product-slug}
**Category:** {category}
**Price:** {price}
**Status:** Researched

### Key Features
- {feature 1}
- {feature 2}

### Proof Points
- {proof point 1 with source}
- {proof point 2}

### Top Objections
1. {objection} → {reframe}
2. {objection} → {reframe}

### Best Angles
- {angle 1}
- {angle 2}

### Research
- [[{slug}-research-dossier|Full Research Dossier]]
```

### creative-kit.md

Append a section for the researched product:

```markdown
## {Product Name} — Research-Backed Creative Angles

### Ad Angles (from research)
- {angle 1}: {brief description}
- {angle 2}: {brief description}
- {angle 3}: {brief description}

### Visual Concepts
- {concept 1 — inspired by VoC}
- {concept 2}

### Hook Frameworks
- {hook 1}
- {hook 2}

See [[{slug}-messaging-ad-angles]] for full details.
```

### learnings-log.md

Append key research findings:

```markdown
## {Date} — Product Research: {Product Name}

### Key Objections Discovered
- {objection}: {insight about frequency/severity}

### VoC Surprises
- {unexpected finding from research}

### Competitive Intelligence
- {notable competitive insight}

### Implications
- {what this means for marketing/positioning}
```

---

## Downstream Skill Integration

### organic-content-generator

References research output for:
- **Content hooks** from `{slug}-messaging-ad-angles.md`
- **Customer language** from `{slug}-copy-quotes.md`
- **Persona targeting** from `{slug}-persona-positioning.md`
- **Objection handling** from `{slug}-objection-kill-sheet.md`

Path: read the research files directly or reference via creative-kit.md.

### image-refiner

References research output for:
- **Product positioning** to inform visual direction
- **Target persona** demographics and aesthetics
- **Competitive visual landscape** for differentiation
- **Ad angle concepts** that suggest specific visual treatments

### native-image-ad-generator

References research output for:
- **Ad angles** — each angle in `{slug}-messaging-ad-angles.md` can become an ad
- **Hooks** — copy-ready hooks for ad text overlays
- **Persona targeting** — which persona each ad should speak to
- **Objection handling** — ads that pre-empt specific objections
- **Proof points** — data and quotes to include in ads

### Usage Pattern

Downstream skills should:
1. Check if research exists: `ls Research/{product-slug}* 2>/dev/null`
2. Read relevant files for context
3. Reference specific quotes, angles, or personas in their output

---

## Commit & Index Workflow

After writing all research files and updating brand context files:

```bash
# Stage and commit all changes
cd /data/projects/obsidian-vault
git add -A
git commit -m "product-research: {Brand} {Product} dossier"
git push

# Refresh the search index
qmd update
```

### Commit Message Convention

```
product-research: {Brand} {Product} dossier
```

Examples:
- `product-research: SnugglePaws Weighted Plush Bear dossier`
- `product-research: AquaGlow Vitamin C Serum dossier`

### When Updating Existing Research

```
product-research: {Brand} {Product} — update {section}
```

Examples:
- `product-research: SnugglePaws Weighted Plush Bear — update competitor teardown`
- `product-research: AquaGlow Vitamin C Serum — add pricing analysis`
