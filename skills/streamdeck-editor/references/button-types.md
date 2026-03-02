# Button Types Reference (v3.0)

## Plugin.UUID vs UUID

Every button has two UUID fields:

| Field | Purpose |
|---|---|
| `Plugin.UUID` | The **plugin** that powers the button |
| `UUID` (top-level) | The specific **action variant** within that plugin |

For most types these are identical. The exception is **page navigation** — one plugin (`com.elgato.streamdeck.page`) provides three variants.

### Reference Table

| Plugin UUID | Action UUID (top-level) | Name | Purpose |
|---|---|---|---|
| `com.elgato.streamdeck.system.text` | (same) | Text | Pastes text |
| `com.elgato.streamdeck.system.hotkey` | (same) | Hotkey | Keyboard shortcut |
| `com.elgato.streamdeck.page` | `.page.next` | Next Page | Next page |
| `com.elgato.streamdeck.page` | `.page.previous` | Previous Page | Previous page |
| `com.elgato.streamdeck.page` | `.page.pop` | Go to Page | Jump to specific page |
| `com.elgato.streamdeck.profile.openchild` | (same) | Create Folder | Opens folder |
| `com.elgato.streamdeck.profile.backtoparent` | (same) | Back to Parent | Returns from folder |

> **RequiredPlugins** in `package.json` uses `Plugin.UUID` values only. For page nav, add `com.elgato.streamdeck.page` once — not each variant.

---

## Text Button

Pastes text into the focused application.

```json
{
  "ActionID": "<uuid-v4>",
  "LinkedTitle": true,
  "Name": "Text",
  "Plugin": {
    "Name": "Text",
    "UUID": "com.elgato.streamdeck.system.text",
    "Version": "1.0"
  },
  "Resources": null,
  "Settings": {
    "Hotkey": {
      "KeyModifiers": 0,
      "QTKeyCode": 33554431,
      "VKeyCode": -1
    },
    "isSendingEnter": false,
    "isTypingMode": false,
    "pastedText": "YOUR PROMPT TEXT"
  },
  "State": 0,
  "States": [
    {
      "FontFamily": "Verdana",
      "FontSize": 10,
      "FontStyle": "Regular",
      "FontUnderline": false,
      "Image": "Images/YOUR_IMAGE.png",
      "OutlineThickness": 2,
      "ShowTitle": true,
      "Title": "Button Label",
      "TitleAlignment": "top",
      "TitleColor": "#ffffff"
    }
  ],
  "UUID": "com.elgato.streamdeck.system.text"
}
```

Key fields:
- `Settings.pastedText` — text pasted on press
- `Settings.isSendingEnter` — `true` to auto-submit after paste
- `Settings.isTypingMode` — `true` types char-by-char; `false` clipboard paste
- `Resources` — always `null`

## Hotkey Button

Sends a keyboard shortcut.

```json
{
  "ActionID": "<uuid-v4>",
  "LinkedTitle": true,
  "Name": "Hotkey",
  "Plugin": {
    "Name": "Activate a Key Command",
    "UUID": "com.elgato.streamdeck.system.hotkey",
    "Version": "1.0"
  },
  "Resources": null,
  "Settings": {
    "Coalesce": true,
    "Hotkeys": [
      {
        "KeyCmd": false,
        "KeyCtrl": true,
        "KeyModifiers": 3,
        "KeyOption": false,
        "KeyShift": true,
        "NativeCode": 53,
        "QTKeyCode": 53,
        "VKeyCode": 53
      }
    ]
  },
  "State": 0,
  "States": [
    {
      "FontFamily": "",
      "FontSize": 9,
      "FontStyle": "",
      "FontUnderline": false,
      "OutlineThickness": 2,
      "ShowTitle": true,
      "Title": "Button Label",
      "TitleAlignment": "top",
      "TitleColor": "#ffffff"
    }
  ],
  "UUID": "com.elgato.streamdeck.system.hotkey"
}
```

KeyModifiers bitmask: 1=Shift, 2=Ctrl, 4=Option, 8=Cmd.

## Folder Opener

Opens a nested button group. `Settings.ProfileUUID` links to the folder directory (lowercase).

```json
{
  "ActionID": "<uuid-v4>",
  "LinkedTitle": true,
  "Name": "Create Folder",
  "Plugin": {
    "Name": "Create Folder",
    "UUID": "com.elgato.streamdeck.profile.openchild",
    "Version": "1.0"
  },
  "Resources": null,
  "Settings": {
    "ProfileUUID": "<folder-uuid-lowercase>"
  },
  "State": 0,
  "States": [
    {
      "FontFamily": "Verdana",
      "FontSize": 7,
      "FontStyle": "Regular",
      "FontUnderline": false,
      "Image": "Images/FOLDER_ICON.png",
      "OutlineThickness": 2,
      "ShowTitle": true,
      "Title": "Folder Name",
      "TitleAlignment": "top",
      "TitleColor": "#ffffff"
    }
  ],
  "UUID": "com.elgato.streamdeck.profile.openchild"
}
```

⚠️ Do NOT add folder UUIDs to `Pages.Pages`. Folders are linked only via `Settings.ProfileUUID`.

## Back Button (inside folder at 0,0)

Returns from folder to parent view.

```json
{
  "ActionID": "<uuid-v4>",
  "LinkedTitle": true,
  "Name": "Parent Folder",
  "Plugin": {
    "Name": "Open Parent Folder",
    "UUID": "com.elgato.streamdeck.profile.backtoparent",
    "Version": "1.0"
  },
  "Resources": null,
  "Settings": {},
  "State": 0,
  "States": [{}],
  "UUID": "com.elgato.streamdeck.profile.backtoparent"
}
```

Critical details:
- `Name`: `"Parent Folder"` (not "Back")
- `Plugin.Name`: `"Open Parent Folder"` (not "Open Folder" or "Back")
- `Settings`: `{}` (empty object, **NOT** `null`)
- `States`: `[{}]` (Stream Deck renders icon automatically)

## Page Navigation Buttons

All share `Plugin.UUID: "com.elgato.streamdeck.page"`. The variant goes in the top-level `UUID` field. All have `"Settings": {}` and `"States": [{}]`.

### Next Page

```json
{
  "ActionID": "<uuid-v4>",
  "LinkedTitle": true,
  "Name": "Next Page",
  "Plugin": {
    "Name": "Pages",
    "UUID": "com.elgato.streamdeck.page",
    "Version": "1.0"
  },
  "Resources": null,
  "Settings": {},
  "State": 0,
  "States": [{}],
  "UUID": "com.elgato.streamdeck.page.next"
}
```

### Previous Page

```json
{
  "ActionID": "<uuid-v4>",
  "LinkedTitle": true,
  "Name": "Previous Page",
  "Plugin": {
    "Name": "Pages",
    "UUID": "com.elgato.streamdeck.page",
    "Version": "1.0"
  },
  "Resources": null,
  "Settings": {},
  "State": 0,
  "States": [{}],
  "UUID": "com.elgato.streamdeck.page.previous"
}
```

### Go to Page

```json
{
  "ActionID": "<uuid-v4>",
  "LinkedTitle": true,
  "Name": "Go To Page",
  "Plugin": {
    "Name": "Pages",
    "UUID": "com.elgato.streamdeck.page",
    "Version": "1.0"
  },
  "Resources": null,
  "Settings": {
    "ProfileUUID": "<target-page-uuid-lowercase>"
  },
  "State": 0,
  "States": [{}],
  "UUID": "com.elgato.streamdeck.page.pop"
}
```

---

## Common Mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Using `com.elgato.streamdeck.page.next` as `Plugin.UUID` | Button doesn't work | Use `com.elgato.streamdeck.page` for `Plugin.UUID`; variant goes in top-level `UUID` |
| Adding folder UUID to `Pages.Pages` | Folder appears as a page | Remove from `Pages.Pages`; link via `Settings.ProfileUUID` only |
| UPPERCASE UUID in JSON references | Profile doesn't load | Use lowercase in all JSON fields; UPPERCASE for directory names only |
| Missing `"Resources": null` on buttons | May not import correctly | Always include `"Resources": null` on every button |
| `Settings: null` on Back button | Back button broken | Use `"Settings": {}` (empty object) |
| Wrong `Plugin.Name` on Back button | May not render correctly | Must be `"Open Parent Folder"` |
| Adding variant UUIDs to RequiredPlugins | May not import correctly | Use plugin-level UUIDs only (e.g., `com.elgato.streamdeck.page`) |
| `Pages.Pages` in wrong order | Wrong navigation sequence | Order determines Next/Previous navigation |
