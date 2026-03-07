# Tmux Mesh: Mobile Mode

## Problem

On mobile (Termux, small SSH terminal), a 7-pane grid is unusable.
Panes are too narrow to read. Zoom (`prefix + z`) affects all clients
in a grouped session — zooming on mobile zooms on desktop too, because
zoom is a window-level flag and grouped sessions share windows.

Creating new windows in a grouped session also adds them to ALL
sessions in the group — desktop would see mobile's windows appear.

## Solution: Independent Session, Shared Inner Sessions

Mobile gets its own independent session (NOT grouped) that renders
each layout pane as a separate fullscreen tmux window. The connection
point is the inner `agents-*` session — both desktop and mobile
attach to the same claude instance.

```
Desktop                          Mobile
─────────────────────            ─────────────────────
Session: dev-airlock             Session: dev-airlock-mobile-12345
Window 0: 7-pane grid            Window 0: "claude" (fullscreen)
  ┌─────┬────────┬──────┐        │ attaches to agents-airlock
  │fstop│ claude │notify│        │ (same claude as desktop)
  │     │        │      │        └─────────────────────
  ├─────┤        ├──────┤        Window 1: "shell" (fullscreen)
  │ fzf ├────────┤ vim  │        │ cd ~/repos/airlock && ...
  │     │terminal├──────┤        └─────────────────────
  │     │        │airlock│       Window 2: "vim" (fullscreen)
  └─────┴────────┴──────┘        │ vim --servername ... .
                                 └─────────────────────
Shared: agents-airlock           Window 3: "notify" (fullscreen)
  (inner tmux session)           │ agent-notify
  (claude process lives here)    └─────────────────────
```

### What's shared between desktop and mobile

- **Claude** — both attach to `agents-<dirname>`. Same conversation,
  same context. This is the main thing you want shared.
- **Working directory** — both operate on the same `$DIR`.
- **Files on disk** — vim on mobile edits the same files. Changes
  are visible to desktop vim on reload.

### What's independent

- **Vim instances** — separate processes, separate servernames. Mobile
  vim is its own instance. Files are shared (same disk), but undo
  history and buffers are not.
- **Shell sessions** — independent shells in the same directory.
- **fstop, agent-notify, airlock** — independent instances.
- **Zoom state** — mobile is always fullscreen per window. Desktop
  grid is unaffected.
- **Window navigation** — completely independent.

### Why not grouped sessions?

Grouped sessions share windows. This means:
1. Zoom on mobile → zoom on desktop (window-level flag)
2. New windows created for mobile appear on desktop too
3. `window-size latest` resizes all windows to the smallest client,
   or the latest client — either way, one screen suffers

Independent sessions avoid all of this. The inner session pattern
(`agents-*`) provides the shared state where it matters most (claude).

---

## Design

### Flag: `-m` (mobile mode)

```bash
dev4 -m ~/repos/airlock           # mobile ephemeral
dev4 -m -s ~/repos/airlock        # mobile + shared inner session
tl -m dev4 ~/repos/airlock        # mobile via tl
```

`-m` changes the rendering mode:
- **Without `-m`** (desktop): all panes in one window as a grid
- **With `-m`** (mobile): each pane becomes its own tmux window

`-m` and `-s` are orthogonal:
- `-m` alone: ephemeral mobile session, ephemeral inner session
- `-m -s`: ephemeral mobile session, **stable** inner session name
  (so mobile's claude attaches to the same `agents-<dirname>` as
  desktop)

Note: mobile's outer session is always ephemeral (PID-based) because
there's no reason to reattach to a mobile layout — it's disposable.
The valuable state lives in the inner session.

### Session naming

| Mode | Outer session | Inner session |
|------|--------------|---------------|
| Desktop ephemeral | `dev-airlock-$$` | `agents-airlock-$$` |
| Desktop shared | `dev-airlock` | `agents-airlock` |
| Mobile | `dev-airlock-mobile-$$` | `agents-airlock` (always stable) |

Mobile always uses stable inner session names regardless of `-s`
flag — the whole point of mobile is connecting to existing processes.

### Window-per-pane rendering

When `-m` is active, `tl` reads the same yaml layout but renders
differently:

**Desktop rendering (current):**
1. Create one window
2. Split into columns and rows
3. Resize to percentages
4. Send commands to panes

**Mobile rendering (new):**
1. Create session with window 0, name it after first pane
2. For each additional pane in the yaml, create a new window
   (`tmux new-window`) and name it after the pane's `name:` field
3. Send each pane's command to its window's single pane
4. Switch to the focus window
5. No resizing needed — each window is fullscreen

### Navigation

Mobile users navigate between windows (not panes):

| Key | Action |
|-----|--------|
| `prefix + n` | Next window (built-in tmux) |
| `prefix + p` | Previous window (built-in tmux) |
| `prefix + 0-9` | Jump to window by number (built-in) |

These are default tmux bindings — no custom config needed.

### Status bar

Set per-session status bar format for mobile sessions to show
window names prominently:

```bash
tmux set-option -t "$SESSION" status-format \
    "[#I:#W]"
```

Or use `automatic-rename off` and name windows explicitly:

```bash
tmux new-window -t "$SESSION" -n "claude"
tmux new-window -t "$SESSION" -n "shell"
tmux new-window -t "$SESSION" -n "vim"
```

The status bar then shows: `0:claude  1:shell  2:vim  3:notify`

The user always knows where they are and can jump by number.

### Detection (auto-mobile)

In addition to the `-m` flag, `tl` could auto-detect mobile:

```bash
# Auto-detect mobile if terminal is very small
COLS=$(tput cols)
ROWS=$(tput lines)
if [ "$COLS" -lt 80 ] || [ "$ROWS" -lt 24 ]; then
    MOBILE=1
fi

# Or check OS_MODE
if [ "$OS_MODE" = "TERMUX" ]; then
    MOBILE=1
fi
```

Auto-detection should be overridable: `-m` forces mobile,
`--no-mobile` or `-M` forces desktop even on small screens.

---

## Implementation

### Files to modify

| File | Change |
|------|--------|
| `bin/shell/tl` | Add `-m` flag, mobile rendering path |
| `bin/shell/dev4` | Add `-m` flag, pass through to session logic |
| `bin/shell/ts` | No changes (yaml format unchanged) |

### Changes to `tl`

**Read `bin/shell/tl` before implementing.** The script currently:
1. Parses flags (`-s`)
2. Parses yaml into COL/PANE variables
3. Opens iTerm2 window (or SSH direct)
4. Creates session, splits panes, sends commands, resizes, attaches

Add `-m` to getopts:

```bash
SHARED=0
MOBILE=0
while getopts "sm" opt; do
    case $opt in
        s) SHARED=1 ;;
        m) MOBILE=1 ;;
        *) echo "Usage: tl [-s] [-m] <name> [path]"
           exit 1 ;;
    esac
done
```

Add auto-detection after terminal size is known:

```bash
COLS=$(tput cols)
ROWS=$(tput lines)

# Auto-detect mobile
if [ "$MOBILE" = "0" ]; then
    if [ "$COLS" -lt 80 ] || [ "$ROWS" -lt 24 ]; then
        MOBILE=1
    fi
    if [ "$OS_MODE" = "TERMUX" ]; then
        MOBILE=1
    fi
fi
```

Mobile session naming (after SHARED/session name logic):

```bash
if [ "$MOBILE" = "1" ]; then
    SESSION="${NAME}-${DIRNAME}-mobile-$$"
    # Inner session always stable for mobile
    INNER="agents-${DIRNAME}"
fi
```

Mobile rendering (new code path, after session creation):

```bash
if [ "$MOBILE" = "1" ]; then
    # Flatten panes into windows
    # First pane uses window 0 (created with session)
    PI=0
    FOCUS_WIN=0
    for ci in $(seq 0 $((NUM_COLS - 1))); do
        eval "PC=\$COL${ci}_PANE_COUNT"
        for ri in $(seq 0 $((PC - 1))); do
            eval "CMD=\$COL${ci}_PANE${ri}_CMD"
            eval "PNAME=\$COL${ci}_PANE${ri}_NAME"
            [ -z "$PNAME" ] && PNAME="pane-$PI"

            if [ "$PI" = "0" ]; then
                # Rename window 0
                tmux rename-window -t "$SESSION:0" \
                    "$PNAME"
            else
                # Create new window
                tmux new-window -t "$SESSION" \
                    -n "$PNAME" -c "$DIR"
            fi

            # Expand variables and send command
            if [ -n "$CMD" ]; then
                CMD=$(echo "$CMD" | sed \
                    -e "s|\\\$DIR|$DIR|g" \
                    -e "s|\${DIR}|$DIR|g" \
                    -e "s|\\\$SESSION|$SESSION|g" \
                    -e "s|\${SESSION}|$SESSION|g" \
                    -e "s|\\\$INNER|$INNER|g" \
                    -e "s|\${INNER}|$INNER|g")
                tmux send-keys \
                    -t "$SESSION:$PI" \
                    "$CMD" Enter
            fi

            # Track focus
            if [ "$ci" = "$FOCUS_COL" ] && \
               [ "$ri" = "$FOCUS_ROW" ]; then
                FOCUS_WIN=$PI
            fi

            PI=$((PI + 1))
        done
    done

    # Disable automatic window renaming
    tmux set-option -t "$SESSION" \
        automatic-rename off

    # Select focus window
    tmux select-window -t "$SESSION:$FOCUS_WIN"

    # Attach (SSH-aware, from tmux-mesh-v2 plan)
    if [ -n "$SSH_TTY" ]; then
        tmux attach -t "$SESSION"
        echo "Detached. Reattach:"
        echo "  tmux attach -t $SESSION"
    else
        exec tmux attach -t "$SESSION"
    fi
fi
```

The desktop rendering path (existing code) runs only when
`MOBILE=0`. Wrap it in:

```bash
if [ "$MOBILE" = "0" ]; then
    # ... existing split/resize/command logic ...
fi
```

### Changes to `dev4`

Add `-m` to getopts and pass through:

```bash
SHARED=0
MOBILE=0
while getopts "sm" opt; do
    case $opt in
        s) SHARED=1 ;;
        m) MOBILE=1 ;;
        *) echo "Usage: dev4 [-s] [-m] [path]"
           exit 1 ;;
    esac
done
```

Pass `-m` through the READY relaunch:

```bash
SFLAG=""
[ "$SHARED" = "1" ] && SFLAG+="-s "
[ "$MOBILE" = "1" ] && SFLAG+="-m "
```

Mobile session naming and rendering follow the same pattern
as `tl`. Since `dev4` has hardcoded pane commands (not from yaml),
the mobile path creates one window per pane with the same commands.

### Changes to `ts` (yaml format)

No changes. The yaml format already has `name:` per pane, which
mobile mode uses for window titles. The same yaml works for both
desktop and mobile rendering.

### Summary table for mobile rendering

This shows how `tl` reads the same dev4.yaml in each mode:

```
dev4.yaml defines:
  Col 0: fstop (78%), fzf (20%)
  Col 1: claude (69%), terminal (29%)
  Col 2: notify (31%), vim (37%), airlock (29%)

Desktop rendering:         Mobile rendering:
┌─────┬────────┬──────┐    Window 0: "fstop"    (fullscreen)
│fstop│ claude │notify│    Window 1: "fzf"      (fullscreen)
├─────┤        ├──────┤    Window 2: "claude"   (fullscreen)
│ fzf ├────────┤ vim  │    Window 3: "terminal" (fullscreen)
│     │terminal├──────┤    Window 4: "notify"   (fullscreen)
│     │        │airlock│   Window 5: "vim"      (fullscreen)
└─────┴────────┴──────┘    Window 6: "airlock"  (fullscreen)
                           Status: [2:claude]
```

---

## Testing

### Test 1: Mobile flag

```bash
tl -m dev4 ~/repos/airlock
```

Verify:
- 7 windows created (one per pane from yaml)
- Each window is named (fstop, fzf, claude, etc.)
- Status bar shows window names
- `prefix + n` / `prefix + p` cycles windows
- `prefix + 2` jumps to claude window
- Focus window matches yaml focus field

### Test 2: Mobile + shared inner session

Desktop already running `dev4 -s ~/repos/airlock`.

```bash
tl -m -s dev4 ~/repos/airlock
```

Verify:
- Mobile's claude window attaches to same `agents-airlock`
  inner session as desktop
- Typing in mobile claude appears in desktop's claude pane
- Desktop grid layout is completely unaffected
- Mobile zoom/window navigation doesn't affect desktop

### Test 3: Auto-detection

On a small terminal (resize to < 80 cols):

```bash
tl dev4 ~/repos/airlock
```

Verify:
- Auto-detects mobile mode
- Creates windows instead of grid

### Test 4: Termux

On Android Termux:

```bash
ssh shield
tl -m dev4 ~/repos/airlock
```

Verify:
- SSH mode (no window launch)
- Mobile mode (windows not grid)
- Claude shared with any desktop session

### Test 5: Kill

```bash
ks    # from mobile session
```

Verify:
- Mobile session killed
- Desktop session unaffected
- Inner `agents-airlock` session survives

---

## Open Questions

- Should mobile skip certain panes? (e.g., fstop is less useful on
  mobile — maybe yaml could have `mobile: false` per pane)
- Should `prefix + f` and `prefix + c` bindings be remapped in mobile
  to select-window instead of select-pane?
- Should there be a `tm` command (tmux mobile) as shorthand for
  `tl -m`?
- Should mobile auto-detect trigger a confirmation prompt?
  "Small terminal detected. Use mobile mode? [Y/n]"
- How to handle pane commands that reference other pane indices?
  (e.g., fzf does `tmux select-pane -t 5` — this breaks in mobile
  because there are no panes, only windows)

---

## Dependencies

This plan depends on:
- **tmux-mesh-v2.md** (SSH mode, Linux support) — the SSH-aware
  attach pattern is used by mobile mode
- **Existing yaml format** — `name:` field per pane is required
  for window titles. Layouts saved with older `ts` that lack
  `name:` fields will show "pane-N" as window titles.

## Order of Operations

1. Read `bin/shell/tl` and `bin/shell/dev4`
2. Add `-m` flag parsing to both scripts
3. Add auto-detection logic (terminal size, TERMUX)
4. Add mobile session naming
5. Add mobile rendering path to `tl` (window-per-pane)
6. Add mobile rendering path to `dev4` (hardcoded commands)
7. Test on macOS with small terminal window
8. Test mobile + shared with desktop
9. Test over SSH
10. Update `TMUX-MESH.md` with mobile mode docs
11. Commit
