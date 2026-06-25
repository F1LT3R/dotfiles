---
name: git-commit
description: Commit work to git with session file backup and formatted commit messages. Use when completing goals, finishing features, fixing bugs, refactoring, or when the user asks to commit.
---

# Git Commit

## Step 0 — Initialize Git if Needed

```bash
git init
git add .
git commit -m "initial commit" --allow-empty
```

## Step 1 — Copy Session Files into Repo

Save the current Pi Coding Agent conversation history into the repository so it is tracked alongside the code.

Run the `cp-pi-conv` command (installed in `~/repos/dotfiles/bin/ai/` and auto-added to PATH):

```bash
cp-pi-conv
```

This command:
- Derives the session directory name from the current working directory
  (e.g. `/Users/user/repos/ctx2loc` → `--Users-user-repos-ctx2loc--`)
- Finds all `.jsonl` files in `~/.pi/agent/sessions/<encoded-cwd>/`
- Copies them into `./pi/agent/sessions/<encoded-cwd>/`

## Step 2 — Inspect Git Changes

Review all changes:

```bash
git diff --stat
git diff
```

Note all files added, modified, or deleted. This forms the basis for the commit message.

## Step 3 — Write a Detailed Commit Message

Compose a commit message that is:
- **Descriptive** — explains *what* changed and *why*, not just *that* it changed
- **Structured** — use a short subject line (< 50 chars), a blank line, then a body with details
- **Action-oriented** — start the subject with an imperative verb (e.g. "add", "fix", "refactor", "update", "implement")

## Step 4 — Commit as @sungunAgentic

Stage all changes and commit:

```bash
git add -A
git commit \
  --author="sungunAgentic <agent@sungun.ai>" \
  -m "subject line" \
  -m "body text with details"
```

If only session files changed (no code):

```bash
git add -A
git commit \
  --author="sungunAgentic <agent@sungun.ai>" \
  -m "update session files" \
  -m "$(date '+%Y-%m-%d %H:%M:%S') — Pi Coding Agent conversation backup"
```

## When to Commit

| Scenario | Action |
|----------|--------|
| Goal completed | Always commit |
| Task finished (add feature, fix bug, refactor) | Always commit |
| Multiple small tasks in one session | Commit at each logical boundary |
| No meaningful changes | Skip commit (but still copy session files) |

## When NOT to Commit

- The user explicitly asks to defer or skip committing
- The working tree has untracked files the user wants to keep private
- The user asks you to explain or review without making changes
