---
name: native-image-ad-generator
description: |
  End-to-end native image ad creator for ecommerce brands. Takes a brand name and product, pulls brand research from the Obsidian vault, generates 10-20 ad concepts with NanoBanana prompts, auto-selects top 5, generates 5 images via Chrome MCP (agent-browser driving Gemini web UI — uses subscription, no per-image API cost), and saves to the brand's vault ad-outputs folder. Fully autonomous — no mid-workflow approval.

  TRIGGERS: native image ads, static image ads, ad concepts, NanoBanana, image ad generator, generate ads, create ad images, ad variations, text to image ads, run ad generator, image ads for [brand], generate image ads

  Do NOT use for: Meta Ad Library research, ad copy/scripts without images, competitor ad analysis, video ad production, email marketing.
---

# Native Image Ad Generator

Fully autonomous: brand + product in → 5 finished ad images out. No mid-workflow approval gates.

## Pipeline

| Step | What | User Action |
|---|---|---|
| 1 | Receive brand + product | User provides |
| 2 | Load brand research from vault (.md) | Auto |
| 3 | Analyze for strategy inputs | Auto |
| 4 | Generate 10-20 concepts with NanoBanana prompts | Auto |
| 5 | Auto-select top 5 (score + rank) | Auto |
| 6 | Generate 5 images via Gemini web UI (Chrome MCP) | Auto |
| 7 | Save to vault + register assets | Auto |

## Autonomy Rules

Run fully autonomously after receiving brand + product. Do not stop for approval or show progress. Deliver final output only.

**Stop and ask only when:**
- Research files not found in vault
- Brand has multiple products and user didn't specify
- Gemini is not logged in (ask user to log in manually)

## Step 1: Input

Required: **brand name** + **product name**. If only brand given, list available products from vault and auto-select if exactly one.

## Step 2: Load Brand Research (Vault)

All research lives in the Obsidian vault as `.md` files:

```
/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Brand/
├── product-catalog.md
├── voice-profile.md
├── positioning.md
├── audience.md
├── creative-kit.md
└── learnings-log.md
```

Read all relevant files. Match product name to entries in `product-catalog.md`.

**If vault files are empty/missing:** Check GitHub repo as fallback — `github.com/Nsf34/claude-skills/Brands/{Brand}/research/`. Convert any `.docx` with `python3 -m markitdown file.docx`.

## Step 3: Analyze Research

Internalize silently (do not output):

1. Product spec sheet — physical description, dimensions, colors, materials, must-NOT-look-like
2. Emotional drivers — ranked purchase motivations
3. Customer voice — verbatim quotes
4. Competitive landscape + gaps
5. Target personas
6. Brand voice + visual identity (hex codes, tone, photography style)
7. Messaging frameworks — positioning angles, proof points

Compile internal product spec sheet using `assets/product-spec-template.md`.

## Step 4: Generate 10-20 Ad Concepts

Each concept gets a complete NanoBanana prompt ending with `--ar 4:5` (Meta/IG feed format).

**Categories** (aim for variety): Before & After, Nightmare Scenario, Comparison, Big Benefit Statement, Offer Heavy, Authority, Reasons Why, Features & Benefits, Testimonial, Humor, Lifestyle, UGC-Style, Pain Agitation, Seasonal, Value Triptych, Unboxing, Gift Angle

**Per concept:** Name, Ad Type, Strategic Rationale, Ad Copy Elements, NanoBanana Prompt

**Dedup against prior runs:** Before generating, check for existing `Ad_Concepts_Summary.md` files in the product's `ad-outputs/` folder. Extract the ad types and concept names already used. Pass them as a constraint: "Do NOT generate concepts using these types/angles: [list]. Prioritize unexplored categories from the list above." If all categories have been used, allow repeats but require a substantially different angle, scene, or emotional hook.

Read `references/nanobanana-prompt-guide.md` for prompt engineering rules.

## Step 5: Auto-Select Top 5

Score 1-5 on: Emotional Resonance, Scroll-Stop Power, Brand Alignment, Strategic Differentiation, Prompt Feasibility (max 25). See `references/concept-scoring-rubric.md`.

**Rules:** Rank by score. Top 5 must include ≥3 different ad types. ≥1 each for awareness, consideration, conversion. Tiebreaker: higher Scroll-Stop Power.

## Step 6: Generate Images via Gemini Web UI (Chrome MCP)

Generate 5 images using `agent-browser` to drive Gemini's web UI. Uses existing subscription — no per-image API cost.

> **Zero-Waste Rule:** Every generation uses subscription quota. No test images, no retries unless Gemini explicitly refuses.

See `references/gemini-browser-automation.md` for complete pre-flight checks, per-concept loop commands, download procedure, and failure handling.

## Step 7: Save & Register

### Output structure
```
vault/Projects/Ecommerce/Business/{Brand}/Brand/ad-outputs/{Product}/
├── Concept1_{ShortName}.png
├── Concept2_{ShortName}.png
├── ...
└── Ad_Concepts_Summary.md
```

### Ad_Concepts_Summary.md

```markdown
# {Brand} — {Product} Ad Concepts
Generated: {Date}

## Summary
- Concepts generated: {N} → Top 5 selected
- Format: 4:5 (Meta/Instagram feed)

## Selected Concepts

### Concept 1: {Name}
- **Type:** {Ad Type}
- **Score:** {N}/25
- **Rationale:** {Why}
- **Ad Copy:** {Text overlays}
- **File:** {filename}
- **NanoBanana Prompt:** {full prompt}

[repeat for all 5]

## Failed Generations (if any)

## Research Source
{vault files used}
```

### Register in assets-registry.md

Append to brand's `assets-registry.md`:
```markdown
| {date} | ad-outputs/{Product}/Concept{N}_{Name}.png | {ad type}: {concept name} | gemini-chrome |
```

### Delivery message
```
Done — 5 ad concepts generated for {Brand} {Product}.
✅ {N} images saved to vault
✅ Summary + prompts in Ad_Concepts_Summary.md
✅ Assets registered
Path: Projects/Ecommerce/Business/{Brand}/Brand/ad-outputs/{Product}/
```

## Brand Discovery

Infer from calling agent: `tableclay-manager` → TableClay, `bananabanker` → ask.
List brands: `ls /data/projects/obsidian-vault/Projects/Ecommerce/Business/`

## Reference Files

- `references/nanobanana-prompt-guide.md` — Prompt engineering for Gemini image generation
- `references/concept-scoring-rubric.md` — Scoring criteria for concept selection
- `assets/product-spec-template.md` — Product spec extraction template
