---
name: image-generator
description: Use this skill when the user asks to "generate an image", "create a logo", "make a mockup", "edit a photo", "remove a background", "iterate on an image", or otherwise wants image generation/editing via Gemini image models. Provides a safe, file-based curl workflow that avoids command-line length limits and requires GEMINI_API_KEY.
---

# Dair Image Generator (Gemini)

Generate and edit images via Google Gemini’s image generation endpoint (`gemini-3-pro-image-preview`).

## Setup (required)

- Require `GEMINI_API_KEY` to be set in the environment.
- If missing, stop and ask the user to set it (do not proceed).

Pre-flight check:
```bash
if [ -z "${GEMINI_API_KEY:-}" ]; then
  echo "ERROR: GEMINI_API_KEY is not set." >&2
  exit 1
fi
```

## Core workflow (file-based; avoids argument-too-long)

### A) Text → image
1) Write request JSON to `/tmp/gemini_request.json`.
2) `curl` the `:generateContent` endpoint.
3) Decode `inlineData.data` (base64) into an output image.

### B) Edit an existing image
1) Base64-encode the input image.
2) Create a JSON request file with both `{ "text": <edit prompt> }` and `{ "inline_data": ... }`.
3) Call the endpoint.
4) Decode and save the returned image.

## References

- Full upstream skill text (vendored): `references/upstream-image-generator-skill.md`
- Upstream repo: https://github.com/dair-ai/dair-academy-plugins/tree/main/plugins/image-generator
