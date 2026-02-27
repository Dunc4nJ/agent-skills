---
name: native-image-ad-generator
description: |
  End-to-end native image ad creator for ecommerce brands. Takes a brand name and product, pulls brand research from the vault or GitHub repo, generates 10-20 ad concepts with NanoBanana prompts, auto-selects top 5, then generates 5 final images via Gemini web UI (Chrome MCP / agent-browser) and saves to the brand's vault assets folder. Fully autonomous — no mid-workflow approval needed.

  TRIGGERS: native image ads, static image ads, ad concepts, NanoBanana, image ad generator, generate ads, create ad images, ad variations, text to image ads, run ad generator, image ads for [brand], generate image ads

  Do NOT use for: Meta Ad Library research, ad copy/scripts without images, competitor ad analysis, video ad production, email marketing.
---

# Native Image Ad Generator

Fully autonomous pipeline: brand + product in → finished ad images out. Fetches brand research, generates concepts, scores top 5, generates one image per concept via Gemini (4:5 ratio), saves everything to the vault. No mid-workflow approval gates.

## Quick Reference

| Step | What | User Action |
|---|---|---|
| 1 | Receive brand + product | User provides |
| 2 | Fetch research dossier | Auto |
| 3 | Analyze dossier for strategy inputs | Auto |
| 4 | Generate 10-20 concepts with NanoBanana prompts | Auto |
| 5 | Auto-select top 5 (score + rank) | Auto |
| 6 | Generate images via Gemini browser automation | Auto |
| 7 | Save to vault + register assets | Auto |

## Autonomy Rules

Run fully autonomously after receiving brand + product. Do not stop for approval, confirmation, or review. Work silently and deliver final output.

**Stop and ask only when:**
- Research dossier not found
- Brand has multiple products and user didn't specify
- Gemini is not logged in (ask user to log in manually)

## Step 1: Receive Input

Required: **brand name** + **product name**. If only brand is given, check available dossiers and auto-select if exactly one exists.

## Step 2: Fetch Research Dossier

Check these sources in order:

1. **Vault** (preferred): `/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Brand/` — look for product-catalog.md, voice-profile.md, positioning.md, audience.md, creative-kit.md
2. **GitHub repo**: `github.com/Nsf34/claude-skills/Brands/{Brand}/research/` — `.docx` files containing "Deep Research Dossier"
3. **Local clone**: check if repo already cloned at `/tmp/claude-skills/`

For GitHub `.docx` files, extract with:
```bash
python3 -c "from docx import Document; d=Document('/path/to/file.docx'); print('\n'.join(p.text for p in d.paragraphs))"
```
Fallback: `python3 -m markitdown file.docx`

## Step 3: Analyze Research Dossier

Internalize silently (do not output):
1. Product spec sheet — physical description, dimensions, colors, materials, textures, must-NOT-look-like
2. Emotional drivers — ranked purchase motivations
3. Customer voice — verbatim quotes
4. Objections + rebuttals
5. Competitive landscape + gaps
6. Target personas + psychographics
7. Brand voice + visual identity (hex codes, tone, photography style)
8. Messaging frameworks — positioning angles, proof points
9. Pricing context

Compile an internal product spec sheet using `assets/product-spec-template.md`.

## Step 4: Generate 10-20 Ad Concepts

Each concept gets a complete NanoBanana prompt with `--ar 4:5`.

**Concept categories** (aim for variety):
Before & After, Nightmare Scenario, Comparison / Us vs. Them, Big Benefit Statement, Offer Heavy, Media / Press / Authority, Reasons Why, Features & Benefits, Testimonial / Review, Humor / Fun, Lifestyle / Aspirational, UGC-Style, Pain Agitation, Seasonal / Contextual, Value Triptych, Unboxing / First Impression, Gift Angle

**Per concept:**
1. Concept Name
2. Ad Type (category)
3. Strategic Rationale (1-2 sentences grounded in research)
4. Ad Copy Elements (text overlays)
5. NanoBanana Prompt (complete, ending with `--ar 4:5`)

Read `references/nanobanana-prompt-guide.md` for prompt engineering rules.

## Step 5: Auto-Select Top 5

Score all concepts (1-5 each, max 25):
1. Emotional Resonance
2. Scroll-Stop Power
3. Brand Alignment
4. Strategic Differentiation
5. Prompt Feasibility

See `references/concept-scoring-rubric.md` for detailed rubric.

**Selection rules:**
- Rank by total score
- Diversity: top 5 must include ≥3 different ad types
- Funnel coverage: ≥1 each for awareness, consideration, conversion
- Tiebreaker: prefer higher Scroll-Stop Power

## Step 6: Generate Images via Gemini (Chrome MCP)

Use `agent-browser` to drive Google Gemini web UI. **5 generations total — no more.**

> **CRITICAL — Zero-Waste Rule:** Every generation uses subscription quota. Exactly 5 generations for 5 concepts. No test images, no retries unless Gemini explicitly refuses.

### 6A. Pre-Flight Check (zero generations used)

```bash
agent-browser open "https://gemini.google.com/app"
agent-browser screenshot /tmp/gemini-preflight.png
```

Verify: logged in, input field visible. If login page shows, STOP and ask user.

```bash
agent-browser snapshot -i
```

Locate the prompt input field and send button refs.

### 6B. Per-Concept Generation Loop

For each of the 5 concepts:

```
1. NEW CHAT
   agent-browser open "https://gemini.google.com/app"
   agent-browser wait 3000

2. INSERT PROMPT
   agent-browser snapshot -i
   # Find the input field ref
   agent-browser fill @e{N} "Generate an image: {NanoBanana prompt}"
   # If fill doesn't work on contenteditable, use eval:
   agent-browser eval "const e=document.querySelector('.ql-editor.textarea'); e.focus(); document.execCommand('selectAll'); document.execCommand('delete'); document.execCommand('insertText',false,'Generate an image: {prompt}')"

3. SUBMIT
   agent-browser eval "document.querySelector('button[aria-label=\"Send message\"]').click()"

4. WAIT + CHECK
   agent-browser wait 50000
   agent-browser screenshot /tmp/gemini-check-{N}.png
   # If still loading, wait 20s more. Max total: 90s.

5. DOWNLOAD
   # Scroll to image, hover to reveal overlay icons, click download (rightmost)
   agent-browser snapshot -i
   # Find the generated image element, hover over it
   # Click download icon
   agent-browser wait 5000
   # Verify file in ~/Downloads/

6. COPY TO VAULT
   cp ~/Downloads/Gemini_Generated_Image_*.png \
     "/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Brand/assets/Concept{N}_{ShortName}.png"
```

### 6C. Failure Handling

| Situation | Action |
|---|---|
| Safety refusal | Note, promote 6th concept |
| No image after 90s | Note timeout, promote next |
| Download fails | Try once more, then note Gemini URL for manual download |
| Browser drops | Save completed images + `REMAINING_PROMPTS.md` |
| ≥3 concepts fail | Save successes + `FAILED_PROMPTS.md` |
| Input field not found | Output all prompts in `REMAINING_PROMPTS.md` |

**Never:**
- Generate test images
- Retry a prompt that already produced an image
- Reuse a conversation between concepts

## Step 7: Save & Register

### Output location

Primary: vault brand assets folder
```
/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Brand/assets/
  Concept1_{ShortName}.png
  Concept2_{ShortName}.png
  ...
  Ad_Concepts_Summary.md
```

### Register in assets-registry.md

Append one row per image to the brand's `assets-registry.md`:

```markdown
| {date} | Concept{N}_{ShortName}.png | {ad type}: {concept name} | gemini-chrome |
```

### Ad_Concepts_Summary.md

Create in the same assets folder:

```markdown
# {Brand} — {Product} Ad Concepts
Generated: {Date}

## Summary
- Concepts generated: {N}
- Top 5 selected by score
- Format: 4:5 (Meta/Instagram feed)

## Selected Concepts

### Concept 1: {Name}
- **Type:** {Ad Type}
- **Score:** {N}/25
- **Strategic Rationale:** {Why}
- **Ad Copy:** {Text overlays}
- **File:** {filename}
- **NanoBanana Prompt:** {full prompt}

[repeat for all 5]

## Failed Generations (if any)
{notes}

## Research Source
{dossier file/path used}
```

### Delivery message

```
Done — 5 ad concepts generated in 4:5 format for {Brand} {Product}.

✅ {N} images saved to vault
✅ Summary + prompts in Ad_Concepts_Summary.md
✅ Assets registered

Vault: Projects/Ecommerce/Business/{Brand}/Brand/assets/
```

## Brand Discovery

If brand not specified, infer from calling agent:
- `tableclay-manager` → TableClay
- `bananabanker` → ask (manages multiple)

Available brands: `ls /data/projects/obsidian-vault/Projects/Ecommerce/Business/`

## Reference Files

- `references/nanobanana-prompt-guide.md` — Prompt engineering for Gemini image generation
- `references/concept-scoring-rubric.md` — Scoring criteria for concept selection
- `assets/product-spec-template.md` — Product spec extraction template
