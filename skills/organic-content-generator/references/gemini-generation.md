# Gemini Web UI Image Generation

Use the EXACT same pattern as native-image-ad-generator Steps 6A-6C.

## 6A. Pre-Flight

```bash
agent-browser open "https://gemini.google.com/app"
agent-browser wait 3000
agent-browser screenshot /tmp/gemini-preflight.png
```

Verify logged in. If not, STOP and ask user.

## 6B. Per-Concept Loop

For each selected concept:

1. **New chat:** `agent-browser open "https://gemini.google.com/app"` + wait 3000
2. **Insert prompt:** Try `agent-browser fill` on input field. Fallback to JS execCommand on `.ql-editor.textarea`
3. **Submit:** Click send button via `agent-browser eval`
4. **Wait:** 50s initial + check, max 90s
5. **Download:** Hover image → click Download icon (NOT Save). Verify `~/Downloads/Gemini_Generated_Image_*.png`
6. **Copy to vault output folder**

## 6C. Failure Handling

Same as native-image-ad-generator:
- Safety refusal → promote next concept
- Timeout → skip
- ≥3 fails → save successes + `REMAINING_PROMPTS.md`

**Zero-Waste Rule:** No test images, no retries unless Gemini explicitly refuses.
