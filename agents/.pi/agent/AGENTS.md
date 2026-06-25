# General Guidelines for Agent Behavior

## Mandatory Startup: Discover Your Model

**Before any task, read the session file to discover your model identifier.**
Do not use cached names — they will be wrong in every new session.

```bash
SESSION_FILE=$(ls -t /Users/user/.pi/agent/sessions/*/*.jsonl 2>/dev/null | head -1)
if [ -n "$SESSION_FILE" ]; then
  MY_MODEL=$(grep -o '"modelId":"[^"]*"' "$SESSION_FILE" | head -1 | sed 's/"modelId":"//;s/"//')
  # Store for use in all notify calls
  # Default: MY_MODEL="unknown-model"
fi
```

If the session file has no `model_change` entry, ask the user: "What model am I?"

## Bash Command Formatting

**The user's terminal is often narrow (~80 chars wide). Any bash command longer than ~80 characters must use `\` line continuations to break it into short lines.** This is critical — long commands get soft-wrapped in the terminal and break on copy-paste.

Rules:
- Keep each continued line under 80 characters
- Use `\` at the end of each line that continues
- Keep the logical structure of the command clear
- Never output a command that requires the user to type more than ~80 chars per line

### Good
```bash
npm install --save-dev \
  eslint \
  prettier \
  typescript && \
npx eslint --init
```

### Bad (will break on copy-paste)
```
npm install --save-dev eslint prettier typescript
```

---

## Notification System

Send notifications via `notify` at pause points — particularly before user-facing approvals, reviews, or long operations.

If none of the specific triggers below apply, send a fallback status notification:

```
notify(type="status", message="<what you're doing>", workspaceDir="<current working directory>", model="<your model identifier>")
```

---

### Model Name Discovery — READ THIS BEFORE EVERY NOTIFY CALL

**Never guess or reuse a cached model name.** Model names change between sessions and projects. Always read the actual session file and agent definition files at startup.

#### 1. Discover YOUR model (the agent reading this file)

Read the active session file to extract the `modelId` from the `model_change` event:

```bash
SESSION_FILE=$(ls -t /Users/user/.pi/agent/sessions/*/*.jsonl 2>/dev/null | head -1)
if [ -n "$SESSION_FILE" ]; then
  MODEL=$(grep -o '"modelId":"[^"]*"' "$SESSION_FILE" | head -1 | sed 's/"modelId":"//;s/"//')
  echo "My model: $MODEL"
fi
```

If the session file is unavailable, fall back to the project-level config or ask the user.

**Use this exact `$MODEL` value in every `notify` call you send as yourself.**

#### 2. Discover subagent models

When you dispatch a subagent, read its agent definition file to find its `model:` field:

```bash
AGENT_FILE="/Users/user/.pi/agent/skills/coder.md"  # example path
# Actually read from .pi/agents/<name>.md in the project directory
```

Subagent model is the value of `model:` in the agent's `.md` file (e.g. `qwen-coder:think`).

**When reporting on subagent activity** (via `agentRole` + `agentNumber`), use the subagent's model, not your own.

#### 3. The rule — strict, no exceptions

| Context | Model value | Source |
|---------|-------------|--------|
| Orchestrator notify | `modelId` from session file `model_change` event | Session JSONL |
| Subagent activity report | `model:` field from `.pi/agents/<name>.md` | Agent definition |
| Unknown / startup | Ask user: "What model am I?" | User input |

**Do not use `claude-sonnet-4`, `gpt-4`, or any other cached name.** It will be wrong. Read the files fresh every session.

### When to Notify

- **Before** any command that needs user approval → `type="permission"`
- **Before** code reviews or file changes that need review → `type="review"`
- **After** completing tasks → `type="done"`
- **When** asking the user questions → `type="question"`
- **During** long operations (file edits, multi-step tasks) → `type="status"`
- **When** errors occur → `type="error"`
- **When** waiting for processes → `type="waiting"`

### When NOT to Notify

- Reading files or exploring code to answer a simple question
- Explaining code or concepts
- Any response that is purely informational with no actions taken

### Notification Types

| Type         | Purpose                                      |
|--------------|----------------------------------------------|
| `done`       | Task completion                              |
| `question`   | Need user input                              |
| `permission` | Need mode changes or user approval           |
| `error`      | Errors blocking progress                     |
| `status`     | Progress updates                             |
| `waiting`    | Waiting for processes                        |
| `review`     | Code changes ready for review                |
| `message`    | Agent-to-agent conversation message          |

### Required Parameters

| Parameter      | Required | Description |
|----------------|----------|-------------|
| `type`         | Yes      | Notification type |
| `message`      | Yes      | Message to vocalize — keep it concise and specific |
| `workspaceDir` | No       | Full workspace path — identifies the project. Always include if known. |
| `model`        | No       | Your exact model identifier (e.g. "claude-opus-4-6"). Shown in console log. |

### Required Notification Triggers

#### Before proposing ANY command that requires user approval

```
notify(type="permission",
       message="Requesting approval for: [command description]",
       workspaceDir="<cwd>",
       model="<model>")
```

#### Before code reviews or file changes that need review

```
notify(type="review",
       message="Code changes ready for review: [description]",
       workspaceDir="<cwd>",
       model="<model>")
```

#### After completing tasks

```
notify(type="done",
       message="[Task description] completed",
       workspaceDir="<cwd>",
       model="<model>")
```

#### When asking questions

```
notify(type="question",
       message="[Question summary]",
       workspaceDir="<cwd>",
       model="<model>")
```

#### During long operations

```
notify(type="status",
       message="[Current operation]",
       workspaceDir="<cwd>",
       model="<model>")
```

#### When errors occur

```
notify(type="error",
       message="[Error description]",
       workspaceDir="<cwd>",
       model="<model>")
```

#### When waiting for processes

```
notify(type="waiting",
       message="[What we're waiting for]",
       workspaceDir="<cwd>",
       model="<model>")
```

### Critical Reminder

**Always notify BEFORE requesting permissions or reviews.**

This ensures you get audio alerts before:
- Approval dialogs appear
- Review dialogs are shown
- Any pause point that requires user interaction

---

### Notify Cadence Rule — ~1 Minute Heartbeat

**Send a notification at least once per minute during active work.** The agent must track elapsed time and heartbeat regularly.

#### Why
- Long silent spans make the user wonder if the agent is stuck or idle
- A periodic heartbeat lets the user follow progress without polling

#### When to send
- **During any continuous operation** (multi-step installs, test suites, file writes, page navigation loops)
- **Between sequential tasks** — if the previous step took <30 s, the next-notify acts as the 1-minute mark
- **During long waits** (e.g. `pagetest wait`, CI, network requests) — send a `status` at 30 s and again at 60 s

#### What to send
- `type="status"` with a concise summary of *what just happened and what's next*
- Example:
  ```
  notify(type="status",
         message="Installing deps (30s elapsed), next: verify build",
         workspaceDir="<cwd>",
         model="<model>")
  ```

#### Track time yourself
- **Do not rely on external timers.** Estimate elapsed time from your own thinking steps, tool call count, or wall-clock observation of `Date.now()` differences.
- If you cannot determine elapsed time, use rough estimation: "~20 steps into X", "halfway through Y test suite".
- **Respect the user's sense of time.** A 3-second gap between notifications is too fast; a 5-minute gap is too slow. Target 45–75 seconds between notifies during active work.

#### Exemptions
- Reading files, writing short code patches, answering a simple question — no busywork notify needed
- If you sent a notify less than 20 seconds ago and nothing significant changed, skip it
- During `pagetest wait` or other blocking calls, use the pre-wait notify and then one at 60 s if still waiting

## Readfile Symbols as HTML Entities — `<` / `>` / `&` Bug

### Symptom

When you read an `.html` file using the `read` tool, the tool **HTML-encodes** special characters:

| Actual file content | What `read` shows |
|---|---|
| `<` | `<` |
| `>` | `>` |
| `&` | `&` |

This means `edit` commands that copy-paste text from the `read` output **will fail** with `Could not find the exact text`, because the text is HTML-encoded in the tool output but stored as plain characters in the file.

Example: To find `if (Array.isArray(parsed) && parsed.length > 0)` in the file, the `read` tool shows:

```
if (Array.isArray(parsed) && parsed.length > 0)
```

But the file actually contains:

```js
if (Array.isArray(parsed) && parsed.length > 0)
```

### Workaround

**Option 1: Use `grep` instead of `read` to find exact text** — `grep` does NOT HTML-encode its output, so it shows the real file content. You can use it with `--context` or search for a unique substring to locate the line you need.

**Option 2: Edit with `grep`-revealed text** — Use `grep` to find the exact raw text, then pass that raw text (as typed, without HTML entities) to the `edit` tool as `oldText`.

**Option 3: Just type the raw characters directly in the edit call** — Even though `read` showed `&` and `>`, you can write `&&` and `>` directly in the `oldText`/`newText` fields. The parser handles the raw characters correctly.

**Option 4: Use `bash sed` to edit** — When all else fails:
```bash
sed -i '' 's/old-string/new-string/' index.html
```
(But prefer `edit` for tracked changes.)

### Root cause

The `read` tool appears to run HTML content through a decoder/encoder that escapes HTML entities. This is likely an unintended side effect of treating `.html` files as containing renderable HTML — but it obscures the actual bytes in the file, making `edit` operations error-prone.

**Tip:** Always verify your edit by re-reading the affected lines with `grep` or by running the app in a browser to confirm behavior.

## Git Commit on Goal Completion

**When completing any goal or significant task, commit the work to git before reporting done.**

Follow the instructions in the `git-commit` skill (`/skill:git-commit`).

If the skill is not available, run the steps inline using `cp-pi-conv`, `git diff`, and `git commit --author="sungunAgentic <agent@sungun.ai>"`.

