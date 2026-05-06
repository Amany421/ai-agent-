---
name: adk-scaffold-hook
description: Scaffold a new Claude Code hook (shell + jq script under .claude/hooks/) and wire it into .claude/settings.json. Use when the user asks to add a PreToolUse, PostToolUse, Stop, or SessionStart hook.
---

# adk-scaffold-hook

Create a new deterministic hook and register it in
`.claude/settings.json`. No AI logic inside hooks — pure shell + `jq`.

## Steps

1. Ask the user for:
   - **event** — one of `PreToolUse`, `PostToolUse`, `Stop`,
     `SessionStart`, `Notification`, `SubagentStop`
   - **matcher** — for tool events: tool name regex, e.g. `Write|Edit`
     or `Bash`. For Stop/SessionStart: empty string.
   - **purpose** — what the hook should do (e.g. "block any command
     containing `curl | sh`", "log subagent stops to a file")
   - **name** — kebab-case slug for the script filename

2. Generate `.claude/hooks/<name>.sh`:

   ```sh
   #!/usr/bin/env bash
   set -uo pipefail
   input=$(cat)
   # Extract whatever fields you need with jq:
   #   tool_input.file_path  (Write/Edit)
   #   tool_input.command    (Bash)
   #   session_id, stop_hook_active (Stop)
   ...
   # Exit 0 = pass. Exit 2 = block (PreToolUse only); stderr is
   # surfaced to the model so write a clear message before exit 2.
   exit 0
   ```

3. `chmod +x` the script.

4. Merge into `.claude/settings.json` under `hooks.<event>`:

   ```json
   {
     "matcher": "<matcher>",
     "hooks": [{ "type": "command", "command": ".claude/hooks/<name>.sh" }]
   }
   ```

   Do not overwrite existing entries — append to the array for that
   event.

5. Test by triggering the event manually:
   - PreToolUse Write/Edit → ask Claude to write a small file
   - PreToolUse Bash → ask Claude to run a matching command
   - Stop → end the session

## Reference: exit codes
- `0` — pass, no message
- `2` — block (PreToolUse only), stderr returned to the model
- non-zero other — non-blocking error, logged to user

## Notes
- Always include a recursion guard for Stop hooks:
  `[[ $(jq -r '.stop_hook_active') == "true" ]] && exit 0`.
- Never call `Write`, `Edit`, or any AI model from inside a hook.
- Append-only logs go in `.claude/logs/<name>.log`.
