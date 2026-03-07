# dev4 Refactor Test Scenarios

Use a test project directory for all tests. Replace `/path/to/project` with a real path.

**Tip:** Hold **Option** while dragging to select/copy text inside tmux panes.

---

## Test 1: Ephemeral mode — basic launch

```bash
dev4 /path/to/project
```

A new maximized iTerm2 window should open with 7 panes. After ~1 second the panes should snap to their correct proportions.

In the **terminal pane** (middle-bottom, pane 3), run:

```bash
tmux ls
```

You should see PID-suffixed session names like:

```
agents-project-12345: 1 windows ...
dev-project-12345: 1 windows ...
```

The number at the end is the process ID — it will be different each time.

Kill it when done:

```bash
ks
```

The iTerm2 window should close.

---

## Test 2: Ephemeral mode — two independent sessions

Open two ephemeral sessions to the same directory:

```bash
dev4 /path/to/project
```

Wait for the first window to fully load, then from a **different terminal** (not inside tmux):

```bash
dev4 /path/to/project
```

In either window's terminal pane (pane 3), run:

```bash
tmux ls
```

You should see **four** sessions — two pairs with different PIDs:

```
agents-project-11111: 1 windows ...
agents-project-22222: 1 windows ...
dev-project-11111: 1 windows ...
dev-project-22222: 1 windows ...
```

Run `ks` in one window. It should close that window only. Run `tmux ls` in the surviving window — the killed session should be gone, yours should remain.

Run `ks` in the surviving window to clean up.

---

## Test 3: Shared mode — fresh launch

```bash
dev4 -s /path/to/project
```

Same as test 1 but session names should have **no PID suffix**. In pane 3:

```bash
tmux ls
```

Expected:

```
agents-project: 1 windows ...
dev-project: 1 windows ...
```

Leave this running for test 4.

---

## Test 4: Shared mode — grouped reattach

With the shared session from test 3 still running, open a **different terminal** (not inside tmux) and run:

```bash
dev4 -s /path/to/project
```

In either window's terminal pane (pane 3), run:

```bash
tmux ls
```

You should see a grouped session:

```
agents-project: 1 windows ...
dev-project: 1 windows ... (group dev-project)
dev-project-33333: 1 windows ... (group dev-project)
```

Both windows should show the same pane content — typing in one should appear in the other.

Leave both running for test 5 and 6.

---

## Test 5: Shared mode — resize hook

With two grouped sessions from test 4 still running:

First, verify the hook exists. In pane 3:

```bash
tmux show-hooks -t dev-project
```

You should see an `after-resize-window` hook with `run-shell` and resize commands.

Now **manually resize** the iTerm2 window (drag a corner to make it smaller, then bigger). The pane proportions should re-apply automatically after each resize — columns should stay at roughly 21%/47%/31%.

---

## Test 6: Kill commands in shared mode

With two grouped sessions still running:

**Test `ks` (kill single session):**

Run `ks` in one window. That window should close. The other window should survive. Verify in the surviving window:

```bash
tmux ls
```

Should show only `dev-project` and `agents-project` (the grouped session is gone).

**Test `kg` (kill group):**

First create another grouped session:

```bash
dev4 -s /path/to/project
```

Then in either window, run:

```bash
kg
```

All sessions in the group should be killed and the window should close. From any other terminal:

```bash
tmux ls
```

The `dev-project` sessions should all be gone. The `agents-project` inner session may still exist (it's a separate session) — that's expected.

---

## Test 7: Programs launch correctly

During any launch (test 1 or 3), visually confirm each pane:

| Pane | Position       | Expected program               |
|------|----------------|---------------------------------|
| 0    | top-left       | fstop (file tree watcher)       |
| 1    | bottom-left    | fzf loop (starts with .md query)|
| 2    | top-middle     | claude (inner tmux session)     |
| 3    | bottom-middle  | terminal (shell with ssh keys)  |
| 4    | top-right      | agent-notify                    |
| 5    | middle-right   | vim (with servername DEV)       |
| 6    | bottom-right   | airlock dash                    |

---

## Quick reference

| Command             | What it does                              |
|----------------------|------------------------------------------|
| `dev4 /path`         | Ephemeral session (fresh, PID-based)     |
| `dev4 -s /path`      | Shared session (stable, reattachable)    |
| `ks`                 | Kill current session, close window       |
| `kg`                 | Kill entire session group, close window  |
| `tmux ls`            | List all sessions                        |
| `tmux show-hooks -t NAME` | Show hooks on a session             |
