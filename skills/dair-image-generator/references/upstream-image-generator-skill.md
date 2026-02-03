# Upstream: dair-ai/dair-academy-plugins/plugins/image-generator/skills/image-generator/SKILL.md

Vendored copy for reference.

---

---
name: Image Generator
description: Generate and edit images using Gemini's Nano Banana Pro model (gemini-3-pro-image-preview). Use this skill when the user asks you to generate images, create visuals, edit photos, create logos, generate product mockups, or perform any image generation/editing task.
allowed-tools: Read, Write, Bash, WebFetch
---

# Image Generator

This skill generates and edits images using Google's Gemini Nano Banana Pro model (`gemini-3-pro-image-preview`).

## IMPORTANT: Setup Required

Before using this skill, the user must set the `GEMINI_API_KEY` environment variable:

1. Get a free API key from [Google AI Studio](https://aistudio.google.com/)
2. Export the key in your shell profile (`~/.zshrc`, `~/.bashrc`, etc.):
   ```bash
   export GEMINI_API_KEY="your_api_key_here"
   ```
3. Restart your terminal or run `source ~/.zshrc` (or `~/.bashrc`)

**The skill will not work without this configuration.**

## Pre-flight Check

Before making any API call, verify the key is set:

```bash
if [ -z "$GEMINI_API_KEY" ]; then
  echo "ERROR: GEMINI_API_KEY is not set. Please export it in your shell profile."
  exit 1
fi
```

If the key is missing, stop and tell the user to set it using the instructions above.

## Configuration

**Model**: `gemini-3-pro-image-preview`

**API Key**: Read from the `GEMINI_API_KEY` environment variable

## Iterating on User-Provided Images

When the user provides a path to an image they want to edit or iterate on, use this workflow:

### Step 1: Read and encode the image to base64

```bash
# Get the image path from user
IMG_PATH="/path/to/user/image.png"

# Detect mime type
if [[ "$IMG_PATH" == *.png ]]; then
    MIME_TYPE="image/png"
elif [[ "$IMG_PATH" == *.jpg ]] || [[ "$IMG_PATH" == *.jpeg" ]]; then
    MIME_TYPE="image/jpeg"
elif [[ "$IMG_PATH" == *.webp ]]; then
    MIME_TYPE="image/webp"
else
    MIME_TYPE="image/png"
fi

# Encode to base64 (works on both macOS and Linux)
if [[ "$(uname)" == "Darwin" ]]; then
    IMG_BASE64=$(base64 -i "$IMG_PATH")
else
    IMG_BASE64=$(base64 -w0 "$IMG_PATH")
fi
```

### Step 2: Send image with edit prompt (File-Based Approach)

**IMPORTANT:** Always use a file-based approach for the request body. Base64-encoded images are too large for command-line arguments and will cause "argument list too long" errors.

```bash
# User's edit request
EDIT_PROMPT="Add a santa hat to the person in this image"

# Write request to a JSON file (avoids command line length limits)
cat > /tmp/gemini_request.json << JSONEOF
{
  "contents": [{
    "parts": [
      {"text": "$EDIT_PROMPT"},
      {
        "inline_data": {
          "mime_type": "$MIME_TYPE",
          "data": "$IMG_BASE64"
        }
      }
    ]
  }],
  "generationConfig": {
    "responseModalities": ["TEXT", "IMAGE"]
  }
}
JSONEOF

# Call the API using the file
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent" \
  -H "x-goog-api-key: $GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d @/tmp/gemini_request.json > /tmp/gemini_response.json
```

### Step 3: Extract and save the edited image

```bash
# Extract image from response and save
python3 -c "
import json
import base64

with open('/tmp/gemini_response.json') as f:
    data = json.load(f)

for part in data['candidates'][0]['content']['parts']:
    if 'inlineData' in part:
        img_data = part['inlineData']['data']
        mime = part['inlineData']['mimeType']
        ext = 'png' if 'png' in mime else 'jpg'
        with open('edited_image.' + ext, 'wb') as out:
            out.write(base64.b64decode(img_data))
        print(f'Saved: edited_image.{ext}')
    elif 'text' in part:
        print(part['text'])
"
```

(Additional upstream sections omitted here for brevity in this vendored copy header; refer to the upstream repo for the full canonical text.)
