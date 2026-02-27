# NanoBanana Prompt Engineering Guide

Write text-to-image prompts for Google Gemini that produce high-quality, brand-accurate static ad images.

## Prompt Structure (order matters — Gemini weighs earlier descriptions more)

### 1. Scene & Setting
Anchor with overall scene type and mood.
```
Commercial product photography of [product] on [surface/setting].
[Background]. [Atmosphere in 5-10 words].
```

### 2. Product Description (CRITICAL)
Pull physical descriptions directly from the product spec sheet. AI hallucinations are prevented by specificity.

**Must include:** exact dimensions/scale, material + finish (matte/glossy), specific color ("soft sage green with fine speckled texture" not "green"), form factor, accessories.

**Must include "NOT" descriptions:** what the product must NOT look like, common wrong interpretations to exclude.

### 3. Scene Elements
Supporting props described after the product. Keep secondary — support, don't compete.

### 4. Text Overlays
- Max 3-5 words per text element, ≤3 elements total
- Specify exact copy, font style, relative size, placement, color
- Use descriptive terms: "bold condensed sans-serif", "thin elegant serif", "handwritten script"

### 5. Photography Style
```
Commercial lifestyle photography with warm, editorial styling. Premium DTC brand aesthetic.
```

### 6. Lighting
Be specific: direction, color temperature, key/fill/rim, natural vs. studio.

### 7. Camera & Composition
Eye-level/elevated/overhead, depth of field, shot type, lens feel.

### 8. Layout
Where elements sit in frame. Rule of thirds, percentage-based positioning.

### 9. Color Specs
Include hex codes from brand guidelines.

### 10. Aspect Ratio
End every prompt with `--ar 4:5` (Meta/Instagram feed standard).

### 11. Negative Prompts
Explicit exclusions to prevent AI mistakes:
```
Do not include: [common hallucinations], [wrong features], [misspelled text], [mass-produced look]
```

## Concept-Specific Patterns

- **Before & After**: Split-screen. Cool/harsh left, warm/inviting right. Product on "after" side.
- **Comparison**: Two products side by side — generic cold left, your warm product right.
- **Big Benefit Statement**: Dominant bold headline (top 30-40%), hero product below.
- **Value Triptych**: Three circular icon badges with value props, product below, dark moody background.
- **Testimonial**: Customer quote as dominant text, product alongside, warm personal lighting.
- **UGC-Style**: Slightly imperfect framing, natural lighting, casual setting. Authentic, not polished.
- **Lifestyle**: Person using product in aspirational setting. Lifestyle is hero, product is present.

## Quality Checklist

- [ ] Product description matches spec sheet exactly
- [ ] "Must NOT" exclusions included
- [ ] Text overlays ≤5 words each, ≤3 total
- [ ] Lighting matches concept emotional intent
- [ ] Hex codes included where available
- [ ] Ends with `--ar 4:5`
- [ ] Negative prompts cover hallucination risks
- [ ] Reads as natural English paragraphs, not bullet lists
