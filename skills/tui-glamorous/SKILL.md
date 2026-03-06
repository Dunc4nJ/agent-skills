---
name: tui-glamorous
description: >-
  Build beautiful terminal UIs with Charmbracelet. Use when shell scripts need
  prompts/spinners/selection (Gum), Go CLI apps need TUI (Bubble Tea), terminal
  dashboards, SSH apps (Wish), or recording demos (VHS).
---

# tui-glamorous — Charmbracelet TUI Toolkit

## Quick Router

| Context | Solution | Reference |
|---------|----------|-----------|
| **Shell/Bash script** | Gum, VHS, Mods, Freeze | [Shell Scripts](references/shell-scripts.md) |
| **Go CLI/TUI** | Bubble Tea + Lip Gloss | [Go TUI](references/go-tui.md) |
| **SSH-accessible app** | Wish + Bubble Tea | [Infrastructure](references/infrastructure.md) |
| **Recording demos** | VHS | [Shell Scripts](references/shell-scripts.md#vhs-terminal-recording) |
| **Pre-built components** | Bubbles library | [Component Catalog](references/component-catalog.md) |
| **Production architecture** | Patterns & layouts | [Advanced Patterns](references/advanced-patterns.md) |
| **Copy-paste snippets** | Quick patterns | [Quick Reference](references/QUICK-REFERENCE.md) |

---

## Decision Guide

```
Is it a shell script?
├─ Yes → Use Gum
│        Need recording? → VHS
│        Need AI? → Mods
│
└─ No (Go application)
   │
   ├─ Just styled output? → Lip Gloss only
   ├─ Simple prompts/forms? → Huh standalone
   ├─ Full interactive TUI? → Bubble Tea + Bubbles + Lip Gloss
   └─ Need SSH access? → Wish + Bubble Tea
```

---

## Shell Scripts (No Go Required)

```bash
brew install gum  # One-time install
```

```bash
# Input
NAME=$(gum input --placeholder "Your name")

# Selection
COLOR=$(gum choose "red" "green" "blue")

# Fuzzy filter from stdin
BRANCH=$(git branch | gum filter)

# Confirmation
gum confirm "Continue?" && echo "yes"

# Spinner
gum spin --title "Working..." -- long-command

# Styled output
gum style --border rounded --padding "1 2" "Hello"
```

**[Full Gum Reference →](references/shell-scripts.md#gum-the-essential-tool)**
**[VHS Recording →](references/shell-scripts.md#vhs-terminal-recording)**
**[Mods AI →](references/shell-scripts.md#mods-ai-in-terminal)**

---

## Go Applications

```bash
go get github.com/charmbracelet/bubbletea github.com/charmbracelet/lipgloss
```

### Minimal TUI (Copy & Run)

```go
package main

import (
    "fmt"
    tea "github.com/charmbracelet/bubbletea"
    "github.com/charmbracelet/lipgloss"
)

var highlight = lipgloss.NewStyle().Foreground(lipgloss.Color("212")).Bold(true)

type model struct {
    items  []string
    cursor int
}

func (m model) Init() tea.Cmd { return nil }

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        switch msg.String() {
        case "q", "ctrl+c":
            return m, tea.Quit
        case "up", "k":
            if m.cursor > 0 { m.cursor-- }
        case "down", "j":
            if m.cursor < len(m.items)-1 { m.cursor++ }
        case "enter":
            fmt.Printf("Selected: %s\n", m.items[m.cursor])
            return m, tea.Quit
        }
    }
    return m, nil
}

func (m model) View() string {
    s := ""
    for i, item := range m.items {
        if i == m.cursor {
            s += highlight.Render("▸ "+item) + "\n"
        } else {
            s += "  " + item + "\n"
        }
    }
    return s + "\n(↑/↓ move, enter select, q quit)"
}

func main() {
    m := model{items: []string{"Option A", "Option B", "Option C"}}
    tea.NewProgram(m).Run()
}
```

### Library Cheat Sheet

| Need | Library | Example |
|------|---------|---------|
| TUI framework | `bubbletea` | `tea.NewProgram(model).Run()` |
| Components | `bubbles` | `list.New()`, `textinput.New()` |
| Styling | `lipgloss` | `style.Foreground(lipgloss.Color("212"))` |
| Forms | `huh` | `huh.NewInput().Title("Name").Run()` |
| Markdown | `glamour` | `glamour.Render(md, "dark")` |
| Animation | `harmonica` | `harmonica.NewSpring()` |

**[Full Go TUI Guide →](references/go-tui.md)**
**[All Bubbles Components →](references/component-catalog.md)**
**[Layout & Animation Patterns →](references/advanced-patterns.md)**

---

## SSH Apps (Infrastructure)

```go
s, _ := wish.NewServer(
    wish.WithAddress(":2222"),
    wish.WithHostKeyPath(".ssh/key"),
    wish.WithMiddleware(
        bubbletea.Middleware(handler),
        logging.Middleware(),
    ),
)
s.ListenAndServe()
```

Connect: `ssh localhost -p 2222`

**[Full Infrastructure Guide →](references/infrastructure.md)**

---

## Pre-Flight Checklist

- [ ] Handles terminal resize (`tea.WindowSizeMsg`)
- [ ] Graceful `ctrl+c` exit (cleanup, restore terminal)
- [ ] Works when piped (`mytool | grep` → plain text)
- [ ] Tested on 80x24 minimum terminal size
- [ ] Has `--no-tui` flag for scripting

---

## When NOT to Use Charm

- **Output is piped:** `mytool | grep` → plain text
- **CI/CD:** No terminal → use flags/env vars
- **One simple prompt:** Maybe `fmt.Scanf` is fine

**Escape hatch:**
```go
if !term.IsTerminal(os.Stdin.Fd()) || os.Getenv("NO_TUI") != "" {
    runPlainMode()
    return
}
```

---

## All References

| Reference | Contents |
|-----------|----------|
| [Quick Reference](references/QUICK-REFERENCE.md) | Copy-paste patterns, one-liners |
| [Prompts](references/PROMPTS.md) | THE EXACT PROMPTS for common tasks |
| [Shell Scripts](references/shell-scripts.md) | Gum, VHS, Mods, Freeze, Glow - complete |
| [Go TUI](references/go-tui.md) | Bubble Tea patterns, debugging, anti-patterns |
| [Component Catalog](references/component-catalog.md) | All Bubbles components API |
| [Advanced Patterns](references/advanced-patterns.md) | Theming, layouts, production architecture |
| [Infrastructure](references/infrastructure.md) | Wish, Soft Serve, teatest, x/term |
