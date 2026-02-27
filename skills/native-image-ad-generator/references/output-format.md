# Output Format & Asset Registration

## Output Structure

```
vault/Projects/Ecommerce/Business/{Brand}/Brand/ad-outputs/{Product}/
├── Concept1_{ShortName}.png
├── Concept2_{ShortName}.png
├── ...
└── Ad_Concepts_Summary.md
```

## Ad_Concepts_Summary.md Template

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

## Register in assets-registry.md

Append to brand's `assets-registry.md`:
```markdown
| {date} | ad-outputs/{Product}/Concept{N}_{Name}.png | {ad type}: {concept name} | gemini-chrome |
```

## Delivery Message

```
Done — 5 ad concepts generated for {Brand} {Product}.
✅ {N} images saved to vault
✅ Summary + prompts in Ad_Concepts_Summary.md
✅ Assets registered
Path: Projects/Ecommerce/Business/{Brand}/Brand/ad-outputs/{Product}/
```
