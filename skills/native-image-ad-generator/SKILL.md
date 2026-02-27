---
name: native-image-ad-generator
description: |
  End-to-end native image ad creator for ecommerce brands. Takes a brand name and product, pulls brand research from the Obsidian vault, generates 10-20 ad concepts with NanoBanana prompts, auto-selects top 5, generates 5 images via Gemini API (curl, no browser needed), and saves to the brand's vault ad-outputs folder. Fully autonomous — no mid-workflow approval. Works in cron jobs.

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
| 6 | Generate 5 images via Gemini API | Auto |
| 7 | Save to vault + register assets | Auto |

## Autonomy Rules

Run fully autonomously after receiving brand + product. Do not stop for approval or show progress. Deliver final output only.

**Stop and ask only when:**
- Research files not found in vault
- Brand has multiple products and user didn't specify
- `GEMINI_API_KEY` is not set

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

Read `references/nanobanana-prompt-guide.md` for prompt engineering rules.

## Step 5: Auto-Select Top 5

Score 1-5 on: Emotional Resonance, Scroll-Stop Power, Brand Alignment, Strategic Differentiation, Prompt Feasibility (max 25). See `references/concept-scoring-rubric.md`.

**Rules:** Rank by score. Top 5 must include ≥3 different ad types. ≥1 each for awareness, consideration, conversion. Tiebreaker: higher Scroll-Stop Power.

## Step 6: Generate Images via Gemini API

Use the `image-generator` skill's curl-based approach. No browser needed — works headless, in cron jobs, anywhere.

**Pre-flight:**
```bash
if [ -z "${GEMINI_API_KEY:-}" ]; then
  echo "ERROR: GEMINI_API_KEY is not set." >&2; exit 1
fi
```

**Per-concept generation** (5 total — no more):

```bash
# 1. Write request JSON
cat > /tmp/gemini_request.json << 'JSONEOF'
{
  "contents": [{
    "parts": [{"text": "Generate an image: {NANOBANANA_PROMPT}"}]
  }],
  "generationConfig": {
    "responseModalities": ["TEXT", "IMAGE"]
  }
}
JSONEOF

# 2. Call API
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent" \
  -H "x-goog-api-key: $GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d @/tmp/gemini_request.json > /tmp/gemini_response.json

# 3. Extract and save image
python3 -c "
import json, base64
with open('/tmp/gemini_response.json') as f:
    data = json.load(f)
for part in data['candidates'][0]['content']['parts']:
    if 'inlineData' in part:
        img = base64.b64decode(part['inlineData']['data'])
        with open('OUTPUT_PATH', 'wb') as out:
            out.write(img)
        print('Saved: OUTPUT_PATH')
"
```

**Output path per image:**
```
/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Brand/ad-outputs/{Product}/Concept{N}_{ShortName}.png
```

Create the `ad-outputs/{Product}/` directory if it doesn't exist.

### Failure Handling

| Situation | Action |
|---|---|
| API error / safety refusal | Note, promote 6th concept |
| No image in response | Note, promote next |
| ≥3 concepts fail | Save successes + `FAILED_PROMPTS.md` with remaining prompts |
| API key missing | Stop, ask user to set `GEMINI_API_KEY` |

**Never:** Generate test images. Retry a prompt that produced an image. Use more than 5 API calls.

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
| {date} | ad-outputs/{Product}/Concept{N}_{Name}.png | {ad type}: {concept name} | gemini-api |
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
