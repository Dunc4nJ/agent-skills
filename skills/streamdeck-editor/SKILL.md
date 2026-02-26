---
name: streamdeck-editor
description: Edit Elgato Stream Deck XL profile buttons — change prompts, icons, labels, or add/remove buttons. Use when the user says "edit stream deck", "change a button", "replace button", "update stream deck profile", "add a stream deck button", "swap prompt", or mentions the Stream Deck profile. Includes a validation script to verify profile integrity before committing.
---

# Stream Deck Profile Editor

## Profile Location

- **Repo:** `/data/projects/streamdeck/`
- **File:** `vibecoding_profile.streamDeckProfile` (ZIP archive)
- **Format:** ZIP containing `AFBA0E43-48AA-48AC-958A-81E928D63A81.sdProfile/`

## Grid Layout

Stream Deck XL: **8 rows × 4 columns**. Positions keyed as `"row,col"` (e.g. `"0,0"` = top-left, `"7,3"` = bottom-right).

## Edit Workflow

### 1. Extract

```bash
mkdir -p /tmp/sd-edit
cp /data/projects/streamdeck/vibecoding_profile.streamDeckProfile /tmp/sd-edit/profile.zip
cd /tmp/sd-edit
unzip -q profile.zip
```

### 2. Locate the Manifest

Main button config:
```
AFBA0E43-48AA-48AC-958A-81E928D63A81.sdProfile/Profiles/BRMVM6VC1P1AP3DRJG6D7SSB2KZ/manifest.json
```

Read a specific button (e.g. row 2, col 1):
```bash
python3 -c "
import json
with open('AFBA0E43-48AA-48AC-958A-81E928D63A81.sdProfile/Profiles/BRMVM6VC1P1AP3DRJG6D7SSB2KZ/manifest.json') as f:
    d = json.load(f)
print(json.dumps(d['Controllers'][0]['Actions']['2,1'], indent=2))
"
```

### 3. Make Edits

Use Python to load, modify, and write back the manifest JSON. Common edits:

| Change | Field |
|--------|-------|
| Prompt text | `Settings.pastedText` |
| Button label | `States[0].Title` |
| Button icon | `States[0].Image` (path relative to page dir) |
| Auto-send Enter | `Settings.isSendingEnter` (bool) |
| Show/hide label | `States[0].ShowTitle` (bool) |

**Icons:** Must be **288×288 PNG** (@2x for the XL's 144×144 logical grid). Place in `Images/` directory next to the manifest. Use ImageMagick to resize:
```bash
convert input.jpg -resize 288x288! Images/MY_ICON.png
```

**New buttons:** Add a new entry under `Controllers[0].Actions` with a unique UUID v4 as `ActionID`. See `references/button-types.md` for all supported types.

### 4. Repackage

```bash
cd /tmp/sd-edit
zip -r vibecoding_profile.streamDeckProfile AFBA0E43-48AA-48AC-958A-81E928D63A81.sdProfile/
cp vibecoding_profile.streamDeckProfile /data/projects/streamdeck/
```

**Critical:** The ZIP root must be the `.sdProfile` directory — not nested in extra folders.

### 5. Validate

Run the validation script before committing:

```bash
bash /data/projects/streamdeck/validate-profile.sh /data/projects/streamdeck/vibecoding_profile.streamDeckProfile
```

This checks:
- Valid ZIP with `.sdProfile` root directory
- All manifest.json files are valid JSON
- Grid positions within bounds (0-7 rows, 0-3 cols)
- No duplicate ActionIDs
- All referenced images exist
- Required fields present (ActionID, UUID)

**Only proceed to commit if validation passes with 0 errors.**

### 6. Commit and Push

```bash
cd /data/projects/streamdeck
git add -A
git commit -m "Descriptive message about the change"
git push
```

The user re-imports the `.streamDeckProfile` on their Mac to apply changes.

## Additional Resources

- **references/button-types.md** — All supported button types (Text, Hotkey, Next/Prev Page, Go to Page, Folder) with full JSON examples
- **references/layout.md** — Current button layout grid
