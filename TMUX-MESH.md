# Tmux Mesh

A system for building, saving, and restoring multi-pane tmux workspaces from yaml layout files.

## Why This Exists

AI-assisted development is multi-process. A single terminal isn't enough when you're running Claude Code, file watchers, notification streams, vim with a remote server, fzf pipelines, and a working shell all at once. You need a cockpit, not a window.

The problem is that building these layouts by hand is tedious, and losing them is painful. Tmux solves the multiplexing, but it doesn't solve the orchestration — creating the right splits, sizing them proportionally, launching the right programs in the right panes, and being able to do it all again in one command.

Tmux Mesh makes layouts portable and repeatable. Experiment with a pane arrangement manually, export it to yaml with `ts`, then replay it anywhere with `tl`. Register it as a named command and it becomes a one-word launcher. Share a session across multiple screens for streaming or pair programming. Kill everything cleanly when you're done.

The goal: zero friction between "I want this workspace" and having it.

## Global Tmux Config

`~/.tmux.conf`:

```
# Prefix: Ctrl+Space (ergonomic, cross-platform)
unbind C-b
set -g prefix C-Space
bind C-Space send-prefix

# Mouse: click to select pane, drag borders to resize, scroll
set -g mouse on

# Vi mode for copy/scroll (Prefix + [ to enter, y to copy)
setw -g mode-keys vi

# Copy to system clipboard (macOS)
set -g set-clipboard on
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"
bind -T copy-mode-vi Enter send -X copy-pipe-and-cancel "pbcopy"
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "pbcopy"

# No escape delay (fixes vim Esc responsiveness)
set -sg escape-time 0

# Heavy pane borders
set -g pane-border-lines heavy

# Show pane title in terminal/tab title
set -g set-titles on
set -g set-titles-string '#T'
set -g allow-rename off

# Prefix + Shift+Arrow: resize pane by 5
bind -r S-Left resize-pane -L 5
bind -r S-Right resize-pane -R 5
bind -r S-Up resize-pane -U 5
bind -r S-Down resize-pane -D 5

# Quick pane jumps
bind f select-pane -t 1    # fzf
bind c select-pane -t 2    # claude
```

**Tip:** Hold **Option** while clicking/dragging in iTerm2 to bypass tmux mouse capture for native text selection.

## Pane Titles

Pane titles render in iTerm2 tabs using Unicode Bold Sans-Serif glyphs:

```
📁 𝗢𝗥𝗕𝗜𝗧-𝗙𝗫  🖥  𝗖𝗟𝗔𝗨𝗗𝗘 [𝟬.𝟮]  🆔 𝟲𝟲𝟭𝟱𝟭
```

Format: `📁 <dir>  🖥  <pane> [<window>.<index>]  🆔 <pid>`

Text is converted to styled glyphs by `unichar`. Each pane also stores a plain name in the tmux user option `@pane_name`, which `creload`, `treload`, and `ts` use for matching.

### `unichar [-f font] [text]` — Unicode Glyph Converter

Converts ASCII text to Unicode styled characters. Unmapped characters pass through as-is.

| Font | Flag | Example |
|------|------|---------|
| **sansbold** (default) | `-f sansbold` | `Hello` → `𝗛𝗲𝗹𝗹𝗼` |
| **super** | `-f super` | `(0.2)` → `⁽⁰·²⁾` |
| **blocks** | `-f blocks` | `ABC` → `🅰🅱🅲` |

```bash
unichar "HELLO"              # 𝗛𝗘𝗟𝗟𝗢
unichar -f super "(3.1)"     # ⁽³·¹⁾
echo "test" | unichar        # 𝘁𝗲𝘀𝘁
```

## Commands

### `ts <name> [description]` — Tmux Save

Exports the current tmux session layout to `layouts/<name>.yaml`.

Run this inside any tmux session. It walks each pane in order:
1. Highlights the pane so you can see which one it's asking about
2. Detects the running process as a pre-fill guess
3. Prompts you to confirm, edit, or clear the command
4. Launches `color-pick` for pane background color (Esc to skip)
5. Asks which pane should receive focus on restore
6. Writes the yaml file
7. Offers to register the layout as a named shell command

```
$ ts dev4 "IDE workflow with claude, vim, file tree"

Session: dev-airlock-1036  Window: 231x57
Panes: 7

--- Pane 0 (12x43, 5%x77%) ---
  Detected: fstop
  Command (enter=shell, type to override): cd $DIR && fstop

--- Pane 1 (12x11, 5%x20%) ---
  Detected: fzf
  Command (enter=shell, type to override): cd $DIR && fzf
...

Saved to layouts/dev4.yaml
Register as command? (name or enter=skip): dev4
Created bin/shell/dev4
```

### `tl [-s] <name> [path]` — Tmux Load

Builds a tmux session from a layout yaml file.

```bash
tl dev4 ~/repos/my-project        # ephemeral session
tl -s dev4 ~/repos/my-project     # shared session
```

What it does:
1. Parses `layouts/<name>.yaml`
2. Opens a new maximized terminal window (desktop) or runs directly (SSH)
3. Creates the tmux session with correct dimensions
4. Builds the pane structure (columns, then rows)
5. Expands variables (`$DIR`, `${SESSION}`, `${INNER}`) in commands
6. Sends startup commands to each pane
7. Resizes panes to percentage targets
8. Attaches with the focus pane selected

### `tls` — List Layouts

Lists all available layouts with a summary.

```
$ tls
dev4         3 cols  7 panes   IDE workflow with claude, vim, file tree
test1        3 cols  7 panes   (no description)
```

### `tp` — Tmux Pick

Interactive fzf picker for running tmux sessions. Shows the active pane's info in plain text and focuses the selected session's window on enter.

```
$ tp
tp> 📁 dotfiles  🖥  claude [0.2]  🆔 15876
    📁 airlock   🖥  claude [0.2]  🆔 13224
    📁 fstop     🖥  claude [0.2]  🆔 56487
```

- Filters out inner `agents-*` sessions (top-level only)
- Only shows sessions with styled pane titles
- Skips fzf if only one session is running
- Focuses window via AppleScript/iTerm2 (macOS) or bspwm/wmctrl (Linux)

### `ks` — Kill Session

Kills the current tmux session and closes the terminal window (desktop) or returns to shell (SSH).

```bash
ks              # kill current session
ks dev-airlock  # kill a named session
```

### `kg` — Kill Group

Kills all sessions in the current session's group, then closes the terminal window (desktop) or returns to shell (SSH). Use this to tear down shared-mode sessions.

```bash
kg              # kill current group
kg dev-airlock  # kill a named group
```

## Ephemeral vs Shared Mode

### Ephemeral (default)

Every launch creates a completely independent session with a PID-based name:

```
dev4-airlock-12345    (outer session)
agents-airlock-12345  (inner claude session)
```

- `tl dev4 /path` twice = two independent workspaces
- Each has its own Claude Code instance, vim, everything
- `ks` kills one without affecting the other
- Sessions persist if you close the window (tmux detaches, doesn't die)

### Shared (`-s` flag)

Uses a stable, directory-based session name:

```
dev4-airlock          (base session)
agents-airlock        (inner claude session)
```

- `tl -s dev4 /path` twice = two views of the same session (grouped)
- Both windows show the same panes and content
- `window-size latest` makes the most recent client control dimensions
- An `after-resize-window` hook re-applies percentage-based pane sizes when switching between screens
- `ks` kills your view only; `kg` kills everything

**Use case:** Run shared mode on your work monitor and an external monitor. One screen for streaming/presenting, one for actually working. Both show the same session, each sized to its own display.

## Layout File Format

Layouts live in `layouts/<name>.yaml`:

```yaml
name: dev4
description: IDE workflow with claude, vim, file tree
focus: [1, 0]  # column 1, pane 0

columns:
  - width: 21%
    panes:
      - height: 78%
        name: fstop
        bg: "#0b0514"
        cmd: "cd $DIR && fstop"
      - height: 20%
        name: fzf
        bg: "#000000"
        cmd: "cd $DIR && fzf"

  - width: 47%
    panes:
      - height: 69%
        name: claude
        bg: "#1f0410"
        cmd: "cd $DIR && unset TMUX && { tmux attach -t ${INNER} 2>/dev/null || tmux new-session -s ${INNER} 'claude --resume 2>/dev/null || claude'; }"
      - height: 29%
        name: terminal
        bg: "#08020c"
        cmd: "cd $DIR && source ~/.secrets/llms/OPENROUTER_API_KEY && ssh-f1lt3r && clear && ll"

  - width: 31%
    panes:
      - height: 31%
        name: notify
        bg: "#060427"
        cmd: "cd $DIR && agent-notify"
      - height: 37%
        name: vim
        bg: "#000000"
        cmd: "cd $DIR && vim --servername ${SESSION} ."
      - height: 29%
        name: airlock
        bg: "#000000"
        cmd: "cd $DIR && airlock dash"
```

### Variables

Expanded at load time by `tl`:

| Variable | Expands to | Example |
|----------|-----------|---------|
| `$DIR` | Target directory | `/Users/user/repos/airlock` |
| `${SESSION}` | Session name | `dev4-airlock-12345` |
| `${INNER}` | Inner session name | `agents-airlock-12345` |

### Pane Fields

| Field | Required | Description |
|-------|----------|-------------|
| `height` | yes | Pane height as percentage of window |
| `name` | no | Pane name (stored in `@pane_name`, formatted into styled title via `unichar`) |
| `bg` | no | Background color as `#rrggbb` hex (applied via `select-pane -P`) |
| `cmd` | no | Command to run on startup (variables expanded) |

**Note:** Transparency is handled by the terminal emulator (e.g., iTerm2 global setting), not by tmux. The `bg` field sets the pane's background color which combines with any terminal transparency.

### Why YAML

- Human-readable and hand-editable
- Easy to tweak percentages or swap commands
- Comments allowed (unlike JSON)
- Parsed with awk (no external dependencies)

## Platform Support

Tmux Mesh detects four terminal modes automatically:

| Mode | Detection | Window launch | Attach style | `tp` WM |
|------|-----------|--------------|-------------|---------|
| **macOS** | `OS_MODE=MACOS` + no `$SSH_TTY` | New maximized iTerm2 window | `exec tmux attach` | AppleScript |
| **Linux desktop** | `OS_MODE=UBUNTU` + `$DISPLAY` set + no `$SSH_TTY` | New maximized gnome-terminal | `exec tmux attach` | bspwm+wmctrl |
| **SSH** | `$SSH_TTY` is set (any OS) | Skip — already in a terminal | `tmux attach` (no exec) | — |
| **Basic** | Everything else (TERMUX, unknown) | Skip — run in current terminal | `tmux attach` (no exec) | — |

### Session Lifecycle

| Mode | Session names | On detach/close | Reattach |
|------|--------------|-----------------|----------|
| **Ephemeral** (default) | `dev-foo-12345` | Auto-destroyed (`destroy-unattached`) | N/A — launch again |
| **Shared** (`-s`) | `dev-foo` | Persists | `dev4 -s path` rejoins |

Ephemeral sessions auto-clean on detach. Inner `agents-*` sessions are cleaned via a `session-closed` hook. Use `tclean` to manually kill any leftover unattached sessions.

### SSH Workflow

SSH is a first-class mode. Sessions persist on the remote host:

```bash
# From any machine:
ssh myhost
dev4 -s ~/repos/project        # start or join shared session

# Disconnect (close laptop, wifi drops, ctrl+b d)
# Session keeps running on the host

# Reconnect from anywhere:
ssh myhost
dev4 -s ~/repos/project        # rejoins the same session
```

Key SSH behaviors:
- No window management — you're already in a terminal
- No `exec` — detaching returns you to your SSH shell
- No delays — the 0.5s sleeps are for desktop window animation
- `ks`/`kg` kill sessions at full power but don't close the terminal

## Tmux Popup Shortcuts

Popup overlays for file picking (fzf) and content search (ripgrep). All bound to `Ctrl+Space` (prefix).

### File Picker (fzf → vim)

| Binding | Directory | Script |
|---------|-----------|--------|
| `prefix + o` | Current pane dir | `fzf-edit` |
| `` prefix + ` `` | `$HOME` | `fzf-home` |
| `prefix + D` | `/Volumes/DATA` | `fzf-data` |

Selecting a file opens it in a vim popup. Markdown files open in a split window: vim (left) + carbonyl/markserv preview (right) with synthwave theme. Markserv hot-reloads on `:w`.

### Content Search (ripgrep → vim)

| Binding | Directory | Script |
|---------|-----------|--------|
| `prefix + f` | Current pane dir | `fzf-grep` |
| `prefix + P` | `/Volumes/DATA/PLANS` | `fzf-grep` |
| `prefix + C` | `/Volumes/DATA/CONVERSATIONS` | `fzf-grep` |
| `prefix + N` | `~/Notes` | `fzf-grep` |

Live ripgrep-as-you-type with preview context. Selecting a match opens vim at that line in a popup.

### Other Bindings

| Binding | Action |
|---------|--------|
| `prefix + r` | Reload `~/.tmux.conf` |
| `prefix + h` | Pulse (project activity history) |
| `prefix + p` | Session picker (`tp`) |
| `prefix + c` | Select claude pane |

## File Structure

```
dotfiles/
  bin/shell/
    tp               # tmux pick (fzf session picker + window focus)
    ts               # tmux save (export layout to yaml)
    tl               # tmux load (build session from yaml)
    tls              # list available layouts
    tclean           # kill all unattached sessions
    treload          # restart tool panes (fstop, fzf, etc.)
    creload          # restart claude in current workspace
    ks               # kill session
    kg               # kill session group
    tmux-window      # helper: open maximized terminal window
    tmux-close-window # helper: close terminal window
    color-pick       # interactive hex color picker
    unichar          # Unicode glyph converter (sansbold, super, blocks)
    dev              # standalone IDE launcher (original)
    fzf-edit         # fzf file picker → vim (markdown: vim + carbonyl)
    fzf-grep         # fzf + ripgrep live search → vim at match
    fzf-home         # fzf from $HOME → vim
    fzf-data         # fzf from /Volumes/DATA → vim
  layouts/
    dev4.yaml        # exported layout files
    ...
```
