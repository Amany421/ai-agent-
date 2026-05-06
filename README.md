# ai-agent-

A reusable **Agent Development Kit (ADK)** for [Claude Code](https://claude.ai/code),
distributed as an installable plugin. The repository's deliverable IS the
plugin — there is no separate application being built here.

## What's inside

Five layers wired together under `.claude/` (and mirrored under `plugin/`):

1. **Memory** — `CLAUDE.md` (project root) + `.claude/CLAUDE.md` (local index).
2. **Skills** — model-invoked scaffolders in `.claude/skills/`:
   - `adk-scaffold-skill` — bootstrap a new SKILL.md
   - `adk-scaffold-agent` — bootstrap a new subagent
   - `adk-scaffold-hook` — bootstrap a new hook + wire it
3. **Hooks** — deterministic shell + `jq` in `.claude/hooks/`:
   - `auto-lint.sh` — warn-only, detects ruff/eslint/prettier/shellcheck
   - `block-rm-rf.sh` — blocks `rm -rf` (short and long flag forms)
   - `session-log.sh` — appends a Stop summary to `session-log.md`
4. **Subagents** — isolated-context delegates in `.claude/agents/`:
   - `code-reviewer`, `explorer`, `test-runner` (none can spawn subagents)
5. **Plugin** — `plugin/` packages all of the above for `cp`-install into
   any other project. See `plugin/README.md` for install steps.

## Install (this repo into another project)

```bash
git clone <this repo> /tmp/ai-agent-
cd /path/to/your/project
mkdir -p .claude/{skills,agents,hooks,commands,logs}
cp -r /tmp/ai-agent-/plugin/skills/.   .claude/skills/
cp -r /tmp/ai-agent-/plugin/agents/.   .claude/agents/
cp -r /tmp/ai-agent-/plugin/hooks/.    .claude/hooks/
cp -r /tmp/ai-agent-/plugin/commands/. .claude/commands/
chmod +x .claude/hooks/*.sh
# Merge plugin/settings.snippet.json into your .claude/settings.json
```

Restart Claude Code so the new skills, agents, and hooks load.

Full instructions, including how to merge `settings.json` safely, live in
`plugin/README.md`.

## Layout

```
.
├── CLAUDE.md                 # project memory (root)
├── .claude/
│   ├── CLAUDE.md             # local index
│   ├── skills/               # 3 scaffold skills
│   ├── agents/               # 3 subagents
│   ├── hooks/                # 3 deterministic hooks
│   ├── commands/             # custom slash commands
│   ├── logs/                 # runtime logs (lint.log, ...)
│   └── settings.json         # wires hooks to events
├── plugin/                   # distributable copy of the above + README
└── session-log.md            # append-only, written by Stop hook
```

## Keys & Configuration

The kit itself requires **no API keys, no secrets, no environment
variables**. Hooks are pure shell + `jq`; subagents inherit the parent
session's model and credentials.

Optional, only if you want `auto-lint` to do real work:

| Tool       | When it runs                                         | Install            |
|------------|------------------------------------------------------|--------------------|
| `ruff`     | `*.py` files when `pyproject.toml [tool.ruff]` exists | `pip install ruff` |
| `eslint`   | `*.{js,ts,jsx,tsx}` when `.eslintrc*` exists          | `npm i -D eslint`  |
| `prettier` | same as above when `.prettierrc*` exists              | `npm i -D prettier`|
| `shellcheck` | `*.sh` files always (skipped if not on PATH)        | OS package         |

If you need to add a real secret to a project that uses this kit:

- **Never** commit secrets to this README, to `.claude/settings.json`,
  or to any tracked file.
- Put them in `.env` (and add `.env` to `.gitignore`), or in your shell
  profile, or in your platform's secret manager.
- Reference them inside hooks/agents via `$ENV_VAR` — the shell already
  has them in scope.

> _Add per-project keys here if your fork of this kit needs them. List
> the variable name, what it's for, and where to obtain it. Do not paste
> the value._

## Branches

`claude/<topic>-<id>` — current development branch is
`claude/implement-adk-architecture-0VBAK`.

## License

Not yet specified.
