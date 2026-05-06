# .claude/ — local conventions

See `../CLAUDE.md` for full repo conventions. Quick index of what's here:

- `skills/`   — model-invoked SKILL.md scaffolders for this ADK
- `agents/`   — code-explorer, test-runner, doc-writer
- `hooks/`    — auto-lint (warn-only), block-rm-rf, session-log
- `settings.json` — wires PreToolUse and Stop hooks
- `logs/`     — runtime log output (lint.log, etc.)
- `commands/` — custom slash commands

The Stop hook here writes `../session-log.md` and is additive — the global
`~/.claude/stop-hook-git-check.sh` still runs.
