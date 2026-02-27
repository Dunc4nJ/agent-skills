---
name: product-research
description: Deep product research dossier builder. Use when asked to "research a product", "build a product dossier", "competitive analysis", "product teardown", "voice of customer analysis", "objection kill sheet", "market landscape", or any request for comprehensive product intelligence. Produces structured markdown files in the Obsidian vault covering market landscape, competitive teardown, VoC analysis, objection handling, persona positioning, messaging, ad angles, and pricing strategy.
---

# Product Research Dossier Builder

## Overview

Build a comprehensive product research dossier from web research. Takes as little as a product name and produces 9 interlinked markdown files in the brand's vault folder covering every angle needed for marketing, advertising, and positioning.

### Output Files

All files written to `/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Research/`:

| File | Content |
|------|---------|
| `{slug}-research-dossier.md` | Executive summary + [[wiki links]] to all sub-files |
| `{slug}-copy-quotes.md` | Top 25 copy-ready verbatim customer quotes |
| `{slug}-market-landscape.md` | Market size, trends, key players, category dynamics |
| `{slug}-competitor-teardown.md` | 8-12 competitor analysis with positioning matrix |
| `{slug}-voc-analysis.md` | Voice of customer synthesis from Amazon, Reddit, TikTok, YouTube |
| `{slug}-objection-kill-sheet.md` | 12-15 objections with reframes, proof points, copy angles |
| `{slug}-persona-positioning.md` | 3-5 data-driven personas with messaging per persona |
| `{slug}-messaging-ad-angles.md` | Messaging hierarchy + 10-15 ad angle concepts |
| `{slug}-pricing-bundling.md` | Pricing analysis, bundling strategies, tier architecture |

Each file includes Obsidian frontmatter. See `references/vault-integration.md` for details.

## Workflow

### Step 1: Gather Inputs

Ask for:
- **Required:** Product name/description, brand name
- **Helpful:** Target audience, product URL, competitor URLs, photos, price point
- **Optional:** Existing research, specific angles to prioritize

Can work with just a product name — research fills in the rest.

Generate `{product-slug}` (lowercase, hyphenated) from the product name.

### Step 2: Check Existing Research

```bash
BRAND_DIR="/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}"
ls "$BRAND_DIR/Research/{product-slug}"* 2>/dev/null
cat "$BRAND_DIR/product-catalog.md" 2>/dev/null | head -100
```

If prior research exists, build on it rather than starting from scratch. Note gaps to fill.

### Step 3: Conduct Deep Web Research

Use `web_search` and `web_fetch` aggressively across all research phases:

1. **Market landscape** — category size, growth trends, key players, market dynamics
2. **Competitor analysis** — 8-12 competitors: pricing, positioning, unique mechanisms, weaknesses
3. **VoC mining** — Amazon reviews, Reddit threads, TikTok comments, YouTube reviews
4. **Objection identification** — negative reviews, complaints, purchase hesitations
5. **Persona research** — who buys, why, what triggers purchase
6. **Pricing intelligence** — price points, bundles, perceived value drivers

See `references/search-strategies.md` for query templates and source-specific mining strategies.
See `references/research-methodology.md` for detailed phase-by-phase guidance.

**Minimum research depth:** 30+ sources, 25+ verbatim quotes, 8+ competitors.

### Step 4: Synthesize into Dossier

Follow `references/dossier-template.md` for exact section structure and content expectations per file.

Apply strategic frameworks from `references/belief-chains-and-positioning.md`:
- **Necessary Beliefs Framework** — map the belief chain from unaware to purchase
- **Customer Awareness Levels** — classify target audience and adapt messaging
- **Market Sophistication** — determine stage and appropriate positioning strategy
- **Unique Mechanism** — identify/create the product's unique mechanism (UMP + UMS)
- **Offer Architecture** — design tier strategy (entry → core → premium)

### Step 5: Write to Vault

Write all 9 files to the brand's Research/ folder:

```bash
RESEARCH_DIR="/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Research"
mkdir -p "$RESEARCH_DIR"
```

Every file gets frontmatter:
```yaml
---
created: YYYY-MM-DD
type: product-research
brand: {Brand}
product: {product-name}
description: {section description}
source: web-research
---
```

The main dossier links to all sub-files with `[[{slug}-section-name]]` wiki links.

### Step 6: Update Brand Context

**product-catalog.md** — Add/update product entry with:
- Features, specs, proof points
- Top objections and best angles
- Price point and positioning
- Link to research dossier

**creative-kit.md** — Append:
- Best ad angles from messaging file
- Visual concepts suggested by research
- Hook frameworks specific to product

**learnings-log.md** — Append:
- Key objections discovered and reframes
- Surprising VoC insights
- Competitive intelligence highlights

### Step 7: Commit & Index

```bash
cd /data/projects/obsidian-vault && git add -A && git commit -m "product-research: {Brand} {Product} dossier" && git push
qmd update
```

## Quality Standards

- **25+ verbatim customer quotes** with source attribution
- **8-12 competitors** analyzed with specific positioning details
- **12-15 objections** with full kill sheet treatment (reframe + proof + copy angle)
- **3-5 data-driven personas** grounded in actual VoC data
- **10-15 ad angle concepts** with hook, angle, and CTA
- **Every claim sourced** with URL references
- **No generic filler** — every insight specific to THIS product in THIS market
- **Belief chain mapped** from unaware → purchase for each persona
- **Total depth:** 11,700-18,300 words across all files

## References

- **`references/dossier-template.md`** — Exact section structure, content expectations, and word count targets for each output file
- **`references/belief-chains-and-positioning.md`** — Strategic frameworks: Necessary Beliefs, Awareness Levels, Market Sophistication, Unique Mechanism, Offer Architecture, Discovery Story, Funnel Mapping
- **`references/search-strategies.md`** — Query templates for 7 research categories, source-specific mining (Amazon, Reddit, TikTok, YouTube), depth guidelines
- **`references/research-methodology.md`** — Phase-by-phase research guidance, VoC mining strategies, persona development, messaging development, quality rubric
- **`references/vault-integration.md`** — Output paths, frontmatter conventions, brand context file updates, downstream skill integration, commit/index workflow
