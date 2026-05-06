# ai-agent- — Agent Development Kit (ADK)

## Repo purpose
This repository **is** a Claude Code Agent Development Kit, distributed as an
installable plugin. There is no separate application being built here. Every
artifact under `.claude/` and `plugin/` is itself the deliverable.

You are working ON the kit, not WITH it. When the kit is installed into
another project, the contents of `plugin/` are copied into that project's
`.claude/` tree.

## Layout
- `.claude/skills/`   — model-invoked skills (auto-matched on `description:`)
- `.claude/agents/`   — subagent definitions (isolated context, minimum tools)
- `.claude/hooks/`    — deterministic shell + jq hooks
- `.claude/settings.json` — wires hooks to events
- `plugin/`           — self-contained distributable copy of the above
- `session-log.md`    — append-only log written by the Stop hook

## Conventions

### Skills
`.claude/skills/<slug>/SKILL.md` with frontmatter:
```yaml
---
name: <slug>
description: <imperative WHEN-to-invoke sentence>
---
```
The `description` is matched against user intent — write trigger-oriented
verbs, not noun phrases.

### Subagents
`.claude/agents/<slug>.md` with frontmatter:
```yaml
---
name: <slug>
description: <when the main agent should delegate>
tools: <minimum allowlist; never include Agent>
model: inherit
---
```
Subagents run in an isolated context window. Only the final message returns
to the parent. They MUST NOT spawn other subagents.

### Hooks
Pure shell + `jq`. Read JSON event from stdin. Exit codes: `0` = pass,
`2` = block (stderr surfaces to the model). No AI logic — deterministic only.

### Branches
`claude/<topic>-<id>` (e.g. `claude/implement-adk-architecture-0VBAK`).

## Test / lint
Nothing is configured yet. The auto-lint hook (`.claude/hooks/auto-lint.sh`)
detects ruff / eslint / prettier / shellcheck by config file and runs the
matching tool; absent config, it is a silent no-op. Add a config file when
the kit grows real source code.
