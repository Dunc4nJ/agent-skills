# Gemini Web UI — Browser Automation (Chrome MCP)

Use `agent-browser` to drive Google Gemini's web interface. Uses existing subscription — no per-image API cost. **5 generations total — no more.**

> **Zero-Waste Rule:** Every generation uses subscription quota. No test images, no retries unless Gemini explicitly refuses.

## Pre-Flight (zero generations)

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

## Per-Concept Loop (5 iterations)

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

## Failure Handling

| Situation | Action |
|---|---|
| Safety refusal | Note, promote 6th concept |
| No image after 90s | Note timeout, promote next |
| Download fails | Try hover-download once more. If fails, note Gemini URL for manual download |
| Browser drops | Save completed images + `REMAINING_PROMPTS.md` |
| ≥3 concepts fail | Save successes + `FAILED_PROMPTS.md` |
| Input field not found | Output all prompts in `REMAINING_PROMPTS.md` |

**Never:** Generate test images. Retry a prompt that produced an image. Reuse a conversation between concepts. Use `innerHTML` on the editor (blocked by CSP).
