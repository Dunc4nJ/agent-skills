# Gemini Browser Workflow (Image Refinement)

Uses `agent-browser` to drive Google Gemini's web interface for image editing. Same pattern as native-image-ad-generator.

## Pre-Flight

```bash
agent-browser open "https://gemini.google.com/app"
agent-browser wait 3000
agent-browser screenshot /tmp/gemini-preflight.png
```

Verify logged in. If not, STOP and ask user.

## Upload + Prompt Flow

1. Open new chat: `agent-browser open "https://gemini.google.com/app"` + wait 3000
2. Upload the base scene image via the attachment/upload button
3. Upload product reference image(s) (hero.png, optionally angle-1.png)
4. Insert the refinement prompt into the input field
5. Submit and wait (50s initial, max 90s)
6. Download result via hover → Download icon
7. Save to temp review path: `/tmp/refine-review-{slug}.png`

### Upload Pattern

```bash
# Click the attachment/upload button
agent-browser snapshot -i
# Find and click the upload/attach button
agent-browser click @e{upload_button_ref}
# Use the file input to upload
agent-browser eval "document.querySelector('input[type=\"file\"]').click()"
# For file dialog:
agent-browser upload /path/to/base-image.png
```

### Prompt Insertion (Gemini uses Quill.js)

```bash
# Try agent-browser fill first
agent-browser snapshot -i
agent-browser fill @e{N} "{refinement_prompt}"

# Fallback — execCommand:
agent-browser eval "const e=document.querySelector('.ql-editor.textarea'); e.focus(); document.execCommand('selectAll'); document.execCommand('delete'); document.execCommand('insertText',false,'{PROMPT}')"

# Submit:
agent-browser eval "document.querySelector('button[aria-label=\"Send message\"]').click()"

# Wait for generation:
agent-browser wait 50000
```

Adapt based on current Gemini UI. Take screenshots to verify state at each step.
