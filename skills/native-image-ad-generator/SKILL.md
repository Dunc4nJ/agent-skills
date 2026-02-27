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

Use `agent-browser` to drive Google Gemini's web interface. Uses existing subscription — no per-image API cost. **5 generations total — no more.**

> **Zero-Waste Rule:** Every generation uses subscription quota. No test images, no retries unless Gemini explicitly refuses.

### 6A. Pre-Flight (zero generations)

```bash
agent-browser open "https://gemini.google.com/app"
agent-browser wait 3000
agent-browser screenshot /tmp/gemini-preflight.png
```

Verify logged in (not a login page). If login required, STOP and ask user.

Verify the input field works (zero-cost check):
```bash
agent-browser eval "const e=document.querySelector('.ql-editor.textarea'); e!==null && e.getAttribute('contenteditable')==='true'"
```
Must return `true`. If not, try `agent-browser snapshot -i` and locate the input field by ref.

### 6B. Per-Concept Loop (5 iterations)

For each of the 5 selected concepts:

**1. New chat:**
```bash
agent-browser open "https://gemini.google.com/app"
agent-browser wait 3000
```

**2. Insert prompt** (Gemini uses Quill.js — standard fill may not work):
```bash
# Try agent-browser fill first
agent-browser snapshot -i
agent-browser fill @e{N} "Generate an image: {NANOBANANA_PROMPT}"

# If fill fails on contenteditable, use JavaScript:
agent-browser eval "const e=document.querySelector('.ql-editor.textarea'); e.focus(); document.execCommand('selectAll'); document.execCommand('delete'); document.execCommand('insertText',false,'Generate an image: {PROMPT}')"
```

**3. Submit:**
```bash
agent-browser eval "document.querySelector('button[aria-label=\"Send message\"]').click()"
```

**4. Wait + check** (images take 10-30s, max 90s):
```bash
agent-browser wait 50000
agent-browser screenshot /tmp/gemini-result-{N}.png
# If still loading, wait 20s more
```

**5. Download the image:**
- Scroll until generated image is visible
- Hover over image to reveal overlay icons (Share, Copy, Download)
- Click the Download icon (rightmost)
- **DO NOT** click "Save" (goes to Google Photos, not local)
- **DO NOT** use JavaScript fetch/blob (blocked by CORS)
```bash
agent-browser wait 5000
```
Verify file in `~/Downloads/` matching `Gemini_Generated_Image_*.png`.

**6. Copy to vault:**
```bash
cp ~/Downloads/Gemini_Generated_Image_LATEST.png \
  "/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Brand/ad-outputs/{Product}/Concept{N}_{ShortName}.png"
```

Create `ad-outputs/{Product}/` if it doesn't exist.

### 6C. Failure Handling

| Situation | Action |
|---|---|
| Safety refusal | Note, promote 6th concept |
| No image after 90s | Note timeout, promote next |
| Download fails | Try hover-download once more. If fails, note Gemini URL for manual download |
| Browser drops | Save completed images + `REMAINING_PROMPTS.md` |
| ≥3 concepts fail | Save successes + `FAILED_PROMPTS.md` |
| Input field not found | Output all prompts in `REMAINING_PROMPTS.md` |

**Never:** Generate test images. Retry a prompt that produced an image. Reuse a conversation between concepts. Use `innerHTML` on the editor (blocked by CSP).

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
