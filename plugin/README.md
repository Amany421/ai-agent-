# Claude Code ADK plugin

A self-contained Agent Development Kit for Claude Code. Drops three
skills, three subagents, three deterministic hooks, and one slash command
into any project's `.claude/` tree.

## What this is

Five layers wired together:

1. **Memory** — global defaults at `~/.claude/CLAUDE.md` (see
   `global-CLAUDE.md.example`).
2. **Skills** — three model-invoked scaffolders (`adk-scaffold-skill`,
   `adk-scaffold-agent`, `adk-scaffold-hook`) for growing the kit
   without leaving Claude Code.
3. **Hooks** — `auto-lint` (warn-only, language-agnostic),
   `block-rm-rf`, `session-log`. Pure shell + `jq`. No AI inside.
4. **Subagents** — `code-reviewer`, `test-runner`, `explorer`. Each
   runs in an isolated context with a minimum tool allowlist.
   `Agent` is never granted, so subagents cannot spawn subagents.
5. **Slash command** — `/adk-status` reports which layers are
   installed in the current project.

## What's inside

```
plugin/
├── skills/                       # adk-scaffold-{skill,agent,hook}/SKILL.md
├── agents/                       # code-reviewer.md, explorer.md, test-runner.md
├── hooks/                        # auto-lint.sh, block-rm-rf.sh, session-log.sh
├── commands/                     # adk-status.md
├── settings.snippet.json         # hook wiring — MERGE, do not overwrite
├── global-CLAUDE.md.example      # optional: copy to ~/.claude/CLAUDE.md
└── README.md
```

## Install (project scope)

Run from inside the target project's repo root:

```bash
mkdir -p .claude/{skills,agents,hooks,commands,logs}

# Copy the four sub-trees.
cp -r path/to/plugin/skills/.   .claude/skills/
cp -r path/to/plugin/agents/.   .claude/agents/
cp -r path/to/plugin/hooks/.    .claude/hooks/
cp -r path/to/plugin/commands/. .claude/commands/
chmod +x .claude/hooks/*.sh

# Merge hook wiring. If .claude/settings.json already exists, copy the
# "hooks" entries from settings.snippet.json into the existing file by
# hand (jq merge below if no other PreToolUse/Stop entries are set).
if [ -f .claude/settings.json ]; then
  echo "settings.json exists — open both files and merge .hooks manually"
else
  cp path/to/plugin/settings.snippet.json .claude/settings.json
fi
```

If your existing `.claude/settings.json` has no `hooks` block at all, the
following is safe:

```bash
jq -s '.[0] * .[1]' .claude/settings.json path/to/plugin/settings.snippet.json \
  > .claude/settings.json.tmp && mv .claude/settings.json.tmp .claude/settings.json
```

Restart Claude Code after install for skills, agents, and hooks to load.

## Install (global scope)

```bash
cp path/to/plugin/global-CLAUDE.md.example ~/.claude/CLAUDE.md   # if it doesn't already exist
```

The other layers (skills, agents, hooks) are intentionally project-scoped —
install per project so each repo can opt in.

## Verification

After install, in a fresh Claude Code session inside the target repo:

| Layer    | Check                                                                               |
|----------|-------------------------------------------------------------------------------------|
| Memory   | Ask "summarize this repo"; confirms project `CLAUDE.md` is in context.              |
| Skills   | Say "scaffold a new skill called demo"; tool stream shows `Skill(adk-scaffold-skill)`. |
| Hooks    | Ask Claude to run `rm -rf /tmp/demo`; Bash returns blocked, model adapts.           |
| Agents   | Say "use explorer to summarize this directory"; subagent invocation appears.        |
| Command  | Run `/adk-status`; table lists every layer present.                                 |
| Stop     | End the session; new entry appended to `session-log.md` at repo root.               |

## Environment / secrets

None required. The hooks are pure shell. `jq` must be on `$PATH` (it is
on every standard Claude Code container).

Optional, for `auto-lint` to do real work:
- `ruff` (Python — detected by `pyproject.toml [tool.ruff]` or `ruff.toml`)
- `eslint` and/or `prettier` via `npx` (JS/TS — detected by `.eslintrc*`,
  `eslint.config.*`, `.prettierrc*`)
- `shellcheck` (shell — auto-runs on `*.sh` files when installed)

Without any of these the lint hook silently no-ops. It never blocks.

## Uninstall

```bash
rm -r .claude/skills/adk-scaffold-{skill,agent,hook}
rm    .claude/agents/{code-reviewer,explorer,test-runner}.md
rm    .claude/hooks/{auto-lint,block-rm-rf,session-log}.sh
rm    .claude/commands/adk-status.md
# Then remove the matching entries from .claude/settings.json by hand.
```

## Layer rules (kit invariants)

- **Hooks contain no AI logic.** Pure shell + `jq`. Deterministic only.
- **Subagents do not spawn subagents.** `Agent` is never in any
  subagent's `tools:` allowlist.
- **Auto-lint is warn-only.** It never returns exit 2; failures are
  logged to `.claude/logs/lint.log` and echoed to stderr.
- **Stop hook is additive.** It coexists with any global Stop hook
  (e.g. `~/.claude/stop-hook-git-check.sh`); both run.
