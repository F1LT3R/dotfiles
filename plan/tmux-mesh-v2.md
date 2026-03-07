# Tmux Mesh v2: SSH Mode, Linux Support, List Layouts

## Context

Tmux Mesh is a system for saving, loading, and sharing multi-pane tmux
workspaces from yaml layout files. The core scripts are:

| Script | Location | Purpose |
|--------|----------|---------|
| `ts` | `bin/shell/ts` | Interactive export of live tmux session to yaml |
| `tl` | `bin/shell/tl` | Build tmux session from yaml layout |
| `ks` | `bin/shell/ks` | Kill current tmux session + close terminal window |
| `kg` | `bin/shell/kg` | Kill session group + close terminal window |
| `dev4` | `bin/shell/dev4` | Standalone IDE launcher (predates tl/ts) |

Layout files live in `layouts/*.yaml`. Documentation is in `TMUX-MESH.md`.

### OS detection

The dotfiles use `$OS_MODE` (set by `bin/system/detect-os-mode`, sourced
from `.bashrc`). Possible values:

- `MACOS` — macOS (Darwin)
- `UBUNTU` — native Ubuntu Linux
- `WSL2` — Windows Subsystem for Linux 2
- `TERMUX` — Android Termux

The variable is exported and available in all shell scripts.

### Current platform-specific code

Three things are macOS/iTerm2-specific:

1. **Window launch** (`dev4`, `tl`): osascript creates a new maximized
   iTerm2 window, then runs the script inside it with an env flag
   (`DEV4_READY=1` or `TL_READY=1`) to prevent recursion.

2. **Window close** (`ks`, `kg`): After killing the tmux session,
   osascript closes the iTerm2 window. Currently checks
   `uname = Darwin` instead of `$OS_MODE`.

3. **No Linux or SSH path at all**: On non-macOS systems, scripts
   either do nothing or fail silently.

---

## Terminal Modes

The system operates in four modes, detected automatically:

| Mode | Detection | Window launch | Window close | Attach style | Delays |
|------|-----------|--------------|--------------|-------------|--------|
| **macOS** | `OS_MODE=MACOS` + no `$SSH_TTY` | New maximized iTerm2 window via osascript | osascript closes iTerm2 window | `exec tmux attach` (window closes on exit) | 0.5s for window animation |
| **Linux desktop** | `OS_MODE=UBUNTU` + `$DISPLAY` set + no `$SSH_TTY` | New maximized terminal via gnome-terminal/xdotool | xdotool closes window | `exec tmux attach` | 0.5s for window animation |
| **SSH** | `$SSH_TTY` is set (any OS) | Skip — already in a terminal | Skip — just return to shell | `tmux attach` (no `exec`, return to shell on detach) | No delays |
| **Basic** | Everything else (TERMUX, unknown) | Skip — run in current terminal | Skip | `tmux attach` (no `exec`) | No delays |

### SSH mode details

SSH is a **first-class mode**, not a fallback. ~60% of development
happens over SSH. The workflow:

```bash
# From any machine:
ssh shield
dev4 -s ~/repos/airlock        # start or join shared session

# Disconnect (close laptop, wifi drops, ctrl+b d)
# Session keeps running on shield

# Reconnect from anywhere:
ssh shield
dev4 -s ~/repos/airlock        # rejoins the same session

# Second screen (from another SSH connection):
ssh shield
dev4 -s ~/repos/airlock        # grouped session, both screens live
```

Key SSH mode behaviors:
- **No window management** — you're already in a terminal, skip it
- **No `exec`** — `tmux attach` without `exec` so detaching returns
  you to your SSH shell instead of disconnecting
- **No delays** — the 0.5s sleeps exist for iTerm2 window animation,
  unnecessary over SSH
- **No window close on kill** — `ks`/`kg` kill the tmux session(s)
  at full power (including group kills), but don't try to close a
  terminal window. You stay in your SSH shell.
- **Reattach hint** — after detach, print `tmux attach -t <name>`
  as a reminder

Detection: `$SSH_TTY` is set automatically by sshd. No config needed.
Works regardless of `$OS_MODE`.

---

## Task 1: Shared Helpers with Mode Detection

### Goal

Replace hardcoded osascript blocks with two shared helpers that
handle all four modes. Each tmux mesh script calls these instead
of inlining platform-specific code.

### 1a. Create `bin/shell/tmux-window`

Opens a new maximized terminal window and runs a command inside it.
In SSH/basic mode, skips window management entirely.

```bash
#!/usr/bin/env bash
# tmux-window — open a maximized terminal window running a command
# Usage: tmux-window <command-string>
#
# Modes:
#   macOS desktop  → new maximized iTerm2 window
#   Linux desktop  → new maximized gnome-terminal / xterm
#   SSH            → skip window, run command directly
#   Basic          → skip window, run command directly

source ~/bin/system/detect-os-mode 2>/dev/null

CMD="$1"

# SSH mode: skip window management entirely
if [ -n "$SSH_TTY" ]; then
    eval "$CMD"
    exit $?
fi

case "$OS_MODE" in
    MACOS)
        osascript <<EOF
tell application "iTerm2"
    create window with default profile
end tell
delay 0.5
tell application "System Events"
    tell process "iTerm2"
        click menu item "Zoom" of menu "Window" \
            of menu bar 1
    end tell
end tell
delay 0.5
tell application "iTerm2"
    tell current window
        tell current session of current tab
            write text "$CMD"
        end tell
    end tell
end tell
EOF
        ;;
    UBUNTU|WSL2)
        if [ -z "$DISPLAY" ]; then
            # No display server — headless, run directly
            eval "$CMD"
            exit $?
        fi
        # Try gnome-terminal first, fall back to xterm
        if command -v gnome-terminal >/dev/null 2>&1; then
            gnome-terminal --maximize -- \
                bash -c "$CMD; exec bash"
        elif command -v xterm >/dev/null 2>&1; then
            xterm -maximized -e "$CMD" &
        else
            eval "$CMD"
        fi
        # Backup maximize with xdotool
        if command -v xdotool >/dev/null 2>&1; then
            sleep 0.5
            xdotool key super+Up 2>/dev/null
        fi
        ;;
    *)
        # Unknown OS — run directly
        eval "$CMD"
        ;;
esac
```

**Notes for implementer:**
- The `$SSH_TTY` check comes BEFORE the OS_MODE case — SSH overrides
  everything, even on a macOS host accessed via SSH.
- The macOS/Linux paths exit after launching the window. The calling
  script (dev4/tl) does `exit 0` after calling `tmux-window`.
- In SSH/basic mode, the command runs directly via `eval`, so the
  calling script should NOT `exit 0` — it needs to handle the case
  where `tmux-window` returns instead of launching a new window.
  See Task 1c/1d for how this changes the READY flag logic.
- Make executable: `chmod +x bin/shell/tmux-window`

### 1b. Create `bin/shell/tmux-close-window`

Closes the current terminal window. No-op in SSH/basic mode.

```bash
#!/usr/bin/env bash
# tmux-close-window — close the current terminal window
# Usage: tmux-close-window
# No-op in SSH mode (you stay in your shell)

source ~/bin/system/detect-os-mode 2>/dev/null

# SSH mode: don't close anything
if [ -n "$SSH_TTY" ]; then
    exit 0
fi

case "$OS_MODE" in
    MACOS)
        osascript -e \
            'tell application "iTerm2" to close current window' \
            2>/dev/null &
        ;;
    UBUNTU|WSL2)
        if command -v xdotool >/dev/null 2>&1; then
            xdotool getactivewindow windowclose \
                2>/dev/null &
        fi
        ;;
esac
```

### 1c. Update `dev4` to use the helpers

Current `dev4` has an inline osascript block (lines 8-30). The
READY flag pattern needs to change for SSH mode.

**Read the current `bin/shell/dev4` first.**

Current pattern:
```bash
if [ "$DEV4_READY" != "1" ]; then
    # osascript opens window and runs:
    #   exec env DEV4_READY=1 dev4 -s '/path'
    exit 0
fi
sleep 0.5
# ... rest of script
```

New pattern:
```bash
if [ "$DEV4_READY" != "1" ]; then
    SFLAG=""
    [ "$SHARED" = "1" ] && SFLAG="-s "

    # SSH/basic mode: tmux-window runs the command
    # directly and returns. Desktop mode: tmux-window
    # opens a new window and the command runs there.
    if [ -n "$SSH_TTY" ] || \
       [ "$OS_MODE" != "MACOS" -a -z "$DISPLAY" ]; then
        # Direct mode — no new window, skip READY flag
        DEV4_READY=1
    else
        tmux-window \
            "exec env DEV4_READY=1 dev4 ${SFLAG}'$DIR'"
        exit 0
    fi
fi

# Only sleep in desktop mode (window animation)
if [ -z "$SSH_TTY" ]; then
    sleep 0.5
fi
```

Also change the final attach from `exec tmux attach` to:
```bash
if [ -n "$SSH_TTY" ]; then
    tmux attach -t "$OUTER"
    echo "Detached. Reattach: tmux attach -t $OUTER"
else
    exec tmux attach -t "$OUTER"
fi
```

Apply the same pattern to the shared-mode reattach block
(the `if tmux has-session` section).

### 1d. Update `tl` to use the helpers

Same pattern as dev4. **Read the current `bin/shell/tl` first** —
it's the more complex script.

Replace the osascript block (~line 82-106) with the same
SSH-aware pattern from 1c, using `TL_READY` instead of `DEV4_READY`.

Update the final `exec tmux attach` and the shared-mode reattach
block with the SSH-aware attach pattern.

### 1e. Update `ks` to use the helpers

Current `ks` (lines 10-14) checks `uname = Darwin` and runs
osascript. Replace with:

```bash
tmux kill-session -t "$TARGET"
tmux-close-window
```

`tmux-close-window` handles mode detection internally — it kills
the window on desktop, does nothing on SSH (you stay in your shell).

The kill itself (`tmux kill-session`) always runs at full power
regardless of mode.

### 1f. Update `kg` to use the helpers

Same as `ks`. Current `kg` (lines 19-23) checks `uname = Darwin`.

The group kill logic stays identical — kill all grouped sessions,
then kill the target. After that:

```bash
tmux-close-window
```

`kg` always kills everything regardless of mode. Only the
window-close step is mode-aware.

### 1g. Verify

Test matrix:

| Command | macOS desktop | SSH into macOS | Ubuntu desktop | SSH into Ubuntu |
|---------|--------------|----------------|----------------|-----------------|
| `dev4 ~/repos/x` | New iTerm2 window | Direct attach, no window | New gnome-terminal | Direct attach |
| `dev4 -s ~/repos/x` | Same + grouped | Same + grouped | Same + grouped | Same + grouped |
| `tl dev4 ~/repos/x` | New iTerm2 window | Direct attach | New gnome-terminal | Direct attach |
| `ks` | Kill session + close window | Kill session, stay in shell | Kill + close | Kill, stay in shell |
| `kg` | Kill group + close window | Kill group, stay in shell | Kill + close | Kill, stay in shell |
| Detach (ctrl+b d) | Window stays open | Returns to SSH shell | Window stays open | Returns to SSH shell |

---

## Task 2: List Layouts Command (`tls`)

### Goal

Add a `tls` command that lists all available layouts with a summary.

### Output format

```
$ tls
dev4        3 cols  7 panes   IDE workflow with claude, vim, file tree
test1       3 cols  7 panes   (no description)
```

### Implementation

Create `bin/shell/tls`:

```bash
#!/usr/bin/env bash
# tls — list available tmux layouts

LAYOUTS_DIR="$HOME/repos/dotfiles/layouts"

if [ ! -d "$LAYOUTS_DIR" ]; then
    echo "No layouts directory: $LAYOUTS_DIR"
    exit 1
fi

FOUND=0
for f in "$LAYOUTS_DIR"/*.yaml; do
    [ -f "$f" ] || continue
    FOUND=1
    NAME=$(basename "$f" .yaml)

    # Parse description
    DESC=$(awk '/^description:/ {
        sub(/^description: */, ""); print; exit
    }' "$f")
    [ -z "$DESC" ] && DESC="(no description)"

    # Count columns and panes
    NUM_COLS=$(grep -c '^ *- width:' "$f")
    NUM_PANES=$(grep -c '^ *- height:' "$f")

    printf "%-12s %d cols  %d panes   %s\n" \
        "$NAME" "$NUM_COLS" "$NUM_PANES" "$DESC"
done

if [ "$FOUND" = "0" ]; then
    echo "No layouts found in $LAYOUTS_DIR"
fi
```

Make executable: `chmod +x bin/shell/tls`

### Verify

- `tls` lists all yaml files in `layouts/`
- Each entry shows name, column count, pane count, description
- Missing description shows `(no description)`
- No layouts → helpful message

---

## Task 3: Update Documentation

### 3a. Update `TMUX-MESH.md`

- Add `tls` to the Commands section
- Add a "Platform Support" section explaining the four modes
  (macOS, Linux desktop, SSH, basic) with the detection logic
- Document the SSH workflow (connect, start session, disconnect,
  reconnect from anywhere)
- Mention `tmux-window` and `tmux-close-window` helpers in the
  File Structure section

### 3b. Update plan files

Mark completed items in `plan/dev4-refactor.md` and
`plan/tmux-layout-system.md` as done.

---

## File Reference

Scripts the implementer MUST read before making changes:

| File | Why |
|------|-----|
| `bin/shell/dev4` | Has osascript block to replace (lines ~8-30), attach logic at end |
| `bin/shell/tl` | Has osascript block to replace (lines ~82-106), attach logic at end |
| `bin/shell/ks` | Has uname check + osascript (lines 10-14) |
| `bin/shell/kg` | Has uname check + osascript (lines 19-23) |
| `bin/shell/ts` | No changes needed, but read for context |
| `bin/system/detect-os-mode` | Sets `$OS_MODE` env var |
| `.rc/.bashrc` | Sources detect-os-mode, shows OS_MODE usage patterns |
| `TMUX-MESH.md` | Documentation to update |

## Order of Operations

1. Create `bin/shell/tmux-window` helper
2. Create `bin/shell/tmux-close-window` helper
3. Update `dev4` to use `tmux-window` + SSH-aware attach
4. Update `tl` to use `tmux-window` + SSH-aware attach
5. Update `ks` to use `tmux-close-window`
6. Update `kg` to use `tmux-close-window`
7. Test on macOS desktop (should behave identically to current)
8. Test SSH mode: `ssh <host>`, then `dev4 -s ~/repos/x`,
   detach, reattach — verify no window management, clean shell return
9. Create `bin/shell/tls`
10. Update `TMUX-MESH.md`
11. Commit
