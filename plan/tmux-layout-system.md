# Tmux Layout System Plan

## Overview

A bash-based system for saving, restoring, and registering tmux layouts.
Experiment with pane arrangements manually, export to a layout file,
then replay it anywhere with a single command.

## Commands

### `ts <name>` — tmux save
Export current tmux session layout to a yaml file.

**Flow:**
1. Detect current session, get window dimensions
2. Walk each pane in order:
   a. Select/highlight the pane so user can see which one
   b. Detect running process via `ps` as pre-fill guess
   c. Prompt: `Pane N (WxH) [guess]> ` — user confirms, edits, or skips
   d. Empty input = plain shell (no startup command)
3. Write `layouts/<name>.yaml`
4. Ask: "Register as command? [y/N]"
   - If yes: create `bin/shell/<name>` → calls `tr <name>`
   - Make executable

**Getting process guess:**
```bash
# Get PID of pane's active process
PID=$(tmux display-message -t "$pane" -p '#{pane_pid}')
# Get the command (child of the shell, not the shell itself)
CMD=$(ps -o command= -p $(pgrep -P $PID) 2>/dev/null | head -1)
```

### `tr <name>` — tmux restore
Build a tmux session from a layout yaml file.

**Flow:**
1. Read `layouts/<name>.yaml`
2. Open new maximized iTerm2 window (reuse dev4 pattern, or skip if not macOS)
3. Create tmux session with `-x $COLS -y $ROWS`
4. Build pane structure: columns first (horizontal splits), then rows (vertical splits)
5. Resize panes to percentage targets (via background subshell after attach)
6. Send startup commands to each pane
7. Select the pane marked as `focus: true` (or first pane)
8. `exec tmux attach`

### `tl` — tmux layouts (optional nice-to-have)
List available layouts:
```
$ tl
dev4        3 cols, 7 panes    IDE workflow
dev5        2 cols, 4 panes    LLM debates
imggen      2 cols, 3 panes    Image generation
```

## Layout File Format

`layouts/<name>.yaml`

```yaml
name: dev4
description: IDE workflow with claude, vim, file tree
focus: [1, 0]  # column 1, pane 0 (claude pane)

columns:
  - width: 21%
    panes:
      - height: 78%
        cmd: "cd $DIR && fstop"
      - height: 20%
        cmd: "cd $DIR && while true; do f=$(fzf -q '.md') && vim --servername ${SESSION} --remote \"$f\" && tmux select-pane -t 5; done"

  - width: 47%
    panes:
      - height: 69%
        cmd: "cd $DIR && unset TMUX && { tmux attach -t ${INNER} 2>/dev/null || tmux new-session -s ${INNER} 'claude --resume 2>/dev/null || claude'; }"
      - height: 29%
        cmd: "cd $DIR && source ~/.secrets/llms/OPENROUTER_API_KEY && ssh-f1lt3r && clear && ll"

  - width: 31%
    panes:
      - height: 31%
        cmd: "cd $DIR && agent-notify"
      - height: 37%
        cmd: "cd $DIR && vim --servername ${SESSION} ."
      - height: 29%
        cmd: "cd $DIR && airlock dash"
```

### Variable expansion
These variables expand at `tr` launch time:
- `$DIR` — target directory (first arg to `tr` or pwd)
- `${SESSION}` — unique session name (e.g. `dev4-12345`)
- `${INNER}` — inner session name for nested tmux (e.g. `agents-dev4-12345`)

### Why YAML
- Human-readable and hand-editable
- Easy to tweak pane commands or percentages
- Comments allowed (unlike JSON)
- Parse with `yq` or simple awk/sed for minimal deps

## File Structure

```
dotfiles/
  bin/
    shell/
      ts          # tmux save (export layout)
      tr          # tmux restore (build from layout)
      tl          # tmux list layouts (optional)
      ks          # kill session (exists)
      kg          # kill group (exists)
      dev4        # becomes: tr dev4 (or kept as-is for now)
  layouts/
    dev4.yaml
    dev5.yaml
    ...
```

## Implementation Notes

### Parsing YAML in bash
Options (pick one):
1. `yq` — proper yaml parser, installable via brew/apt
2. Simple line-by-line awk parser — no deps, handles flat yaml
3. Convert yaml to bash vars with sed — fragile but zero deps

Recommend `yq` — it's lightweight, cross-platform, and handles
edge cases. Fall back to awk parser if yq not installed.

### Building panes from yaml
The `tr` script needs to:
1. Count columns, create horizontal splits
2. For each column, count panes, create vertical splits
3. Track pane index mapping (splits shift indices — same challenge as dev4)

**Strategy:** build all splits first, then resize, then send commands.
Use the same background-subshell resize pattern from dev4.

### Cross-platform window management
- macOS: osascript + iTerm2 (current approach)
- Linux: xdotool or wmctrl for window maximize
- Detect with `uname` and branch

### Session naming
- Ephemeral (default): `<layout>-$$` (PID-based, unique)
- Shared (`tr -s`): `<layout>` (stable, supports grouped sessions)
- Carries over from dev4-refactor.md plan

## Migration Path

1. Build `ts` and `tr` as new commands
2. Export current dev4 layout to `layouts/dev4.yaml` using `ts`
3. Verify `tr dev4` reproduces the same result
4. Keep `dev4` script as-is until `tr` is proven
5. Eventually `dev4` becomes a thin wrapper: `exec tr dev4 "$@"`

## Open Questions

- Should `ts` save tmux options (mouse, prefix, etc.) per layout? Probably not — that's global config
- Should `tr` support `--dry-run` to preview what it would do?
- Should layouts support conditional panes? (e.g. only include airlock if installed) — probably over-engineering for now
- How to handle pane commands that need interactive input (e.g. passphrase prompts)?
