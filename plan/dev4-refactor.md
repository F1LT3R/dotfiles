# dev4 Refactor Plan: Ephemeral + Shared Modes

## Current State

### Files
- `bin/shell/dev4` — main IDE launcher
- `bin/shell/ks` — kill current tmux session
- `bin/shell/kg` — kill current tmux session group
- `~/.tmux.conf` — prefix: Ctrl+Space, mouse on, heavy borders, escape-time 0

### Current dev4 behavior
- Always opens new maximized iTerm2 window (DEV4_READY env var prevents recursion)
- If session `dev-<dirname>` exists → creates grouped session, resizes, attaches
- If not → creates new session with 7 panes, starts programs, resizes after attach
- Inner claude session (`agents-<dirname>`) persists via attach-or-create logic
- `exec tmux attach` so window closes when session dies
- Resize via background subshell (sleep 1 then resize) — hooks don't resolve pane targets

### Pane layout (7 panes, 3 columns)
```
┌─────────────┬───────────────────┬──────────────┐
│ 0 fstop 21% │ 2 claude   47%   │ 4 notify 31% │
│        h:78%│           h:69%  │        h:31% │
├─────────────┤                   ├──────────────┤
│ 1 fzf   21% │                   │ 5 vim    31% │
│        h:20%├───────────────────┤        h:37% │
│             │ 3 terminal 47%   ├──────────────┤
│             │           h:29%  │ 6 airlock 31%│
│             │                   │        h:29% │
└─────────────┴───────────────────┴──────────────┘
```

### Programs per pane
- 0: fstop (file tree watcher)
- 1: fzf loop → vim --remote to pane 5 (starts with `.md` query)
- 2: claude (inner tmux session `agents-<dirname>`)
- 3: terminal (ssh keys, env vars loaded)
- 4: agent-notify
- 5: vim --servername DEV .
- 6: airlock dash

---

## Refactor: Two Modes

### 1. Ephemeral Mode (default): `dev4 /path`

- Session name: `dev-<dirname>-$$` (unique per launch, PID-based)
- Inner claude: `agents-<dirname>-$$` (also unique — fresh claude)
- NO reattach logic — always creates fresh
- `exec tmux attach` → window closes when session dies
- `ks` kills session + window closes, everything gone
- No grouped sessions, no sharing

### 2. Shared Mode: `dev4 -s /path`

- Session name: `dev-<dirname>` (stable, directory-based)
- Inner claude: `agents-<dirname>` (stable — preserves conversation)
- If session exists → create grouped session `dev-<dirname>-$$`, attach
- If not → create base session, attach
- Set `window-size latest` on the session (most recent client controls size)
- **Auto-resize hook**: `after-resize-window` hook on the session that
  re-applies percentage-based pane sizes whenever window dimensions change
  (handles switching between different screen sizes)
- `ks` kills your grouped session only (others survive)
- `kg` kills everything

### Resize hook (shared mode)
```bash
# Set on the base session — fires when any client causes a resize
# Uses percentage targets calculated from new window dimensions
tmux set-hook -t "$OUTER" after-resize-window \
    "run-shell 'W=#{window_width}; H=#{window_height}; \
     tmux resize-pane -t 0.0 -x $((W*21/100)); \
     tmux resize-pane -t 0.4 -x $((W*31/100)); \
     tmux resize-pane -t 0.1 -y $((H*20/100)); \
     tmux resize-pane -t 0.3 -y $((H*29/100)); \
     tmux resize-pane -t 0.4 -y $((H*31/100)); \
     tmux resize-pane -t 0.6 -y $((H*29/100))'"
```
Note: hook runs inside tmux so can use `run-shell` with format vars.
Need to test if `#{window_width}` expands inside `run-shell` in hooks.

---

## Implementation Steps

1. Parse `-s` flag and shift args in dev4
2. Branch session naming:
   - Ephemeral: `OUTER="dev-$(basename "$DIR")-$$"`, `INNER="agents-$(basename "$DIR")-$$"`
   - Shared: `OUTER="dev-$(basename "$DIR")"`, `INNER="agents-$(basename "$DIR")"`
3. Branch reattach logic:
   - Ephemeral: skip reattach check entirely (unique name guarantees no conflict)
   - Shared: keep grouped session + resize logic
4. Add `after-resize-window` hook in shared mode
5. Add `window-size latest` in shared mode
6. Update `ks`/`kg` — no changes needed (already auto-detect current session)
7. Update DEV4_READY relaunch to pass `-s` flag through

## Already Completed (this session)

- Ctrl+Space prefix (replaced Ctrl+B)
- Mouse support (click to select pane, drag borders to resize, scroll)
- escape-time 0 (vim Esc fix)
- Heavy pane border lines
- Prefix + Shift+Arrow: resize pane by 5
- Prefix + f: jump to fzf pane (1)
- Prefix + c: jump to claude pane (2)
- Prefix + Arrow: switch pane (default)
- Prefix + z: zoom (default)
- Prefix + [: scroll/copy mode with vi keys (default)
- `ks` / `kg` auto-detect current session, close iTerm2 window via osascript
- `exec tmux attach` in dev4 so window closes when session dies
- vim --servername DEV in pane 5, fzf uses --remote to open files
- fzf starts with `.md` query, focuses vim pane after selection
- Session created with `-x $COLS -y $ROWS` to prevent split failures

## Open Questions

- Should ephemeral mode kill an existing `dev-<dirname>-*` on launch? (Probably not)
- Should fzf `.md` default query be configurable? (Low priority)
- Linux support: replace osascript block with xdotool/wmctrl (separate task)
- Resize hook: need to test if `#{window_width}` expands inside `run-shell` in hooks
