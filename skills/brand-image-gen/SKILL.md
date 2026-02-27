---
name: brand-image-gen
description: Generate or edit images for ecommerce brands via Chrome MCP (Gemini web UI) or API fallback, saving outputs to the correct brand vault path. Use when asked to "generate a product image", "create a mockup", "make a social post graphic", "edit a product photo", or any image generation/editing task tied to a specific brand.
---

# Brand Image Generator

Generate and edit images for ecommerce brands. Primary method: Chrome MCP (browser automation to Gemini web UI, uses subscription — no per-image cost). Fallback: Gemini API via nano-banana-pro skill.

## Required Inputs

- **brand**: Brand name (e.g., `TableClay`, `PrepPack`). Determines vault output path.
- **prompt**: Image generation or edit prompt.
- **Optional**: `--edit <path>` for editing an existing image, `--resolution` (1K/2K/4K, default 1K).

## Output Paths

All generated images save to the brand's vault assets folder and get registered:

```
/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Brand/assets/
```

Filename format: `YYYY-MM-DD-HH-MM-SS-{slug}.png`

After saving, append an entry to the brand's `assets-registry.md`:

```markdown
| YYYY-MM-DD | {filename} | {prompt summary} | {method} |
```

If `assets-registry.md` lacks a table header, prepend:

```markdown
| Date | File | Description | Method |
|------|------|-------------|--------|
```

## Method 1: Chrome MCP (Primary)

Use `agent-browser` to drive the Gemini web UI. No API key or per-image cost — uses existing subscription.

### Text-to-Image

1. Open Gemini:
   ```bash
   agent-browser open "https://gemini.google.com/app"
   ```
2. Snapshot and locate the prompt input:
   ```bash
   agent-browser snapshot -i
   ```
3. Fill the prompt and submit:
   ```bash
   agent-browser fill @e{N} "{prompt}"
   agent-browser press Enter
   ```
4. Wait for image generation (typically 10-30s):
   ```bash
   agent-browser wait 15000
   agent-browser snapshot -i
   ```
5. Locate the generated image, right-click or use download button to save.
6. If direct download isn't available, screenshot the image region or extract the image `src` URL:
   ```bash
   agent-browser eval "document.querySelector('img[data-generative]')?.src"
   ```
7. Download and move to vault path:
   ```bash
   curl -o /tmp/gen-image.png "{image_url}"
   cp /tmp/gen-image.png "/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Brand/assets/{filename}.png"
   ```

### Image Editing

1. Open Gemini and upload the source image using the attachment/upload button.
2. Type the edit instruction as the prompt.
3. Follow the same download flow as above.

### Tips

- If Gemini asks to sign in, the session may have expired. Notify the user.
- Re-snapshot after every major UI change (page load, image appears, dialog opens).
- If multiple images are generated, save all with sequential suffixes (`-01`, `-02`, etc.) and register each.

## Method 2: API Fallback (nano-banana-pro)

Use when Chrome MCP is unavailable (browser session expired, Gemini UI changed, etc.). Requires `GEMINI_API_KEY`.

```bash
uv run /usr/lib/node_modules/openclaw/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "{prompt}" \
  --filename "/data/projects/obsidian-vault/Projects/Ecommerce/Business/{Brand}/Brand/assets/{filename}.png" \
  --resolution 1K
```

For edits:
```bash
uv run /usr/lib/node_modules/openclaw/skills/nano-banana-pro/scripts/generate_image.py \
  --prompt "{edit instructions}" \
  --filename "{output_path}" \
  -i "{input_image_path}" \
  --resolution 2K
```

## Post-Generation (Both Methods)

1. **Register the asset** — append to `assets-registry.md` in the brand's vault folder.
2. **Report** — tell the user the saved path and method used. Do not read the image file back.
3. **Attach** — if the platform supports media, use `MEDIA: {path}` to display.

## Brand Discovery

If brand is not specified, check which agent is calling:
- `tableclay-manager` → TableClay
- `bananabanker` → ask which brand (manages multiple)
- Other brand-specific agents → infer from agent name

Vault brand folders: `ls /data/projects/obsidian-vault/Projects/Ecommerce/Business/`
