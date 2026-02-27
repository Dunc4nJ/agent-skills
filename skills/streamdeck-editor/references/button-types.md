# Button Types Reference

## Text Button (Paste Prompt)

The primary button type. Pastes text into the focused application.

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
      "FontSize": 7,
      "FontStyle": "Regular",
      "FontUnderline": false,
      "Image": "Images/YOUR_IMAGE.png",
      "OutlineThickness": 2,
      "ShowTitle": true,
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
- `Settings.isTypingMode` — `true` types char-by-char (slower, more compatible); `false` clipboard paste
- `States[0].Image` — icon path (288×288 PNG, relative to page dir)
- `States[0].Title` — label text (only shown if `ShowTitle` is true)

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

KeyModifiers bitmask: 1=Shift, 2=Ctrl, 4=Option, 8=Cmd (sum for combos).

## Navigation Buttons

**Next Page:**
- `Plugin.UUID`: `com.elgato.streamdeck.page.next`
- `Settings`: `{}`

**Previous Page:**
- `Plugin.UUID`: `com.elgato.streamdeck.page.previous`
- `Settings`: `{}`

**Go to Page:**
- `Plugin.UUID`: `com.elgato.streamdeck.page.pop`
- `Settings.ProfileUUID`: target page UUID from top-level manifest `Pages.Pages` array

## Folder Button

Opens a nested sub-layout. Contents stored as a separate profile directory under `Profiles/`.

**Folder opener** (on main page):
- `Plugin.Name`: `"Create Folder"`
- `Plugin.UUID`: `com.elgato.streamdeck.profile.openchild`
- `UUID`: `com.elgato.streamdeck.profile.openchild`
- `Settings.ProfileUUID`: UUID of the folder's sub-profile directory name

**Back button** (at `0,0` inside the folder — must be added explicitly):
- `Plugin.Name`: `"Open Folder"`
- `Plugin.UUID`: `com.elgato.streamdeck.profile.backtoparent`
- `UUID`: `com.elgato.streamdeck.profile.backtoparent`
- `Settings`: `null`

⚠️ **WARNING:** Do NOT use `com.elgato.streamdeck.profile.folder` — that UUID does not work. The correct UUID is `openchild` (verified from reference implementation).

The folder's `manifest.json` uses the same `Controllers[0].Actions` structure with `row,col` keys.
