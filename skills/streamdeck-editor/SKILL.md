---
name: streamdeck-editor
description: Edit Elgato Stream Deck XL profile buttons — change prompts, icons, labels, or add/remove buttons. Use when the user says "edit stream deck", "change a button", "replace button", "update stream deck profile", "add a stream deck button", "swap prompt", or mentions the Stream Deck profile. Includes validation and layout dump scripts.
---

# Stream Deck Profile Editor

## Profile Location

- **Repo:** `/data/projects/streamdeck/`
- **File:** `vibecoding_profile.streamDeckProfile` (ZIP archive)
- **Format version:** 3.0 (Stream Deck app 7.2+)

## File Format (v3.0)

The `.streamDeckProfile` ZIP contains at root level:

```
package.json                    # App version, device model, required plugins
Profiles/
  268CEC16-E96D-45BB-B272-71BF8C5AB763.sdProfile/
    manifest.json               # Top-level profile metadata (device, pages)
    Profiles/
      69504FFB-41E2-410D-A4E3-A35D76040128/   # Page 1
        manifest.json
        Images/
      AC1E1595-5240-46C5-8FEF-A7FE83A80058/   # Page 2
        manifest.json
        Images/
      2EEB9127-1957-4BA5-A04B-F65584EFC1FE/   # Dueling Wizards folder
        manifest.json
        Images/
```

> **UUID Case Convention:** Directory names are **UPPERCASE**, JSON references are **lowercase**. This is critical.

> **Resources field:** Every button must include `"Resources": null`.

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

### 2. Locate Key Files

```
package.json                                                                              # Root metadata
Profiles/268CEC16-E96D-45BB-B272-71BF8C5AB763.sdProfile/manifest.json                    # Profile config
Profiles/268CEC16-E96D-45BB-B272-71BF8C5AB763.sdProfile/Profiles/69504FFB-41E2-410D-A4E3-A35D76040128/manifest.json  # Page 1
Profiles/268CEC16-E96D-45BB-B272-71BF8C5AB763.sdProfile/Profiles/AC1E1595-5240-46C5-8FEF-A7FE83A80058/manifest.json  # Page 2
Profiles/268CEC16-E96D-45BB-B272-71BF8C5AB763.sdProfile/Profiles/2EEB9127-1957-4BA5-A04B-F65584EFC1FE/manifest.json  # Dueling Wizards folder
```

Read a specific button (e.g. row 2, col 1 on Page 1):
```bash
python3 -c "
import json
with open('Profiles/268CEC16-E96D-45BB-B272-71BF8C5AB763.sdProfile/Profiles/69504FFB-41E2-410D-A4E3-A35D76040128/manifest.json') as f:
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

**Icons:** Must be **144×144 PNG**. Place in `Images/` directory next to the manifest.

**New buttons:** Add a new entry under `Controllers[0].Actions` with a unique UUID v4 as `ActionID`. Always include `"Resources": null`. See `references/button-types.md` for all supported types.

### 4. Repackage

```bash
cd /tmp/sd-edit
zip -r profile.streamDeckProfile package.json Profiles/
cp profile.streamDeckProfile /data/projects/streamdeck/vibecoding_profile.streamDeckProfile
```

**Critical:** The ZIP root must contain `package.json` and `Profiles/` directly — not nested in extra folders.

### 5. Validate

Run the validation script before committing:

```bash
bash /data/projects/streamdeck/validate-profile.sh /data/projects/streamdeck/vibecoding_profile.streamDeckProfile
```

**Only proceed to commit if validation passes with 0 errors.**

### 6. Commit and Push

```bash
cd /data/projects/streamdeck
git add -A
git commit -m "Descriptive message about the change"
git push
```

The user re-imports the `.streamDeckProfile` on their Mac to apply changes.

### 7. Update Layout Reference

After any edit, regenerate the layout dump:

```bash
bash /path/to/skills/streamdeck-editor/scripts/dump-layout.sh
```

Defaults to the standard profile and output paths. Override with positional args:
```bash
bash scripts/dump-layout.sh [profile-path] [output-path]
```

## Additional Resources

- **references/button-types.md** — All supported button types with full JSON examples and common mistakes
- **references/layout.md** — Current button layout grid
