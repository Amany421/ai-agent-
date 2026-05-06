---
description: Report which ADK layers are installed in the current project
---

Audit the current project's `.claude/` tree and report which ADK layers
are present.

For each of the following, list what was found and flag what's missing:

1. **Memory** — does `./CLAUDE.md` exist? Does `./.claude/CLAUDE.md` exist?
   Does `~/.claude/CLAUDE.md` exist?
2. **Skills** — list every `./.claude/skills/*/SKILL.md`. Show the slug
   and the first line of `description:` for each.
3. **Hooks** — list every `./.claude/hooks/*.sh`. Show whether each is
   executable. Confirm `./.claude/settings.json` references each one.
4. **Subagents** — list every `./.claude/agents/*.md`. Show the `tools:`
   line for each.
5. **Plugin** — does a `./plugin/` directory exist? If so, this project
   is the kit itself, not a consumer.

Report format: a markdown table with one row per layer. Status column =
"installed", "partial", or "missing".

Use Bash to enumerate files. Do not modify anything.
