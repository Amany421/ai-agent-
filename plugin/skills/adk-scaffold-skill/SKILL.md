---
name: adk-scaffold-skill
description: Scaffold a new Claude Code skill (creates SKILL.md with frontmatter and body under .claude/skills/<slug>/). Use when the user asks to add, create, or bootstrap a skill.
---

# adk-scaffold-skill

Create a new skill in this project (or any target project that has a
`.claude/skills/` directory).

## Steps

1. Ask the user for two things if not already provided:
   - **slug** — kebab-case, used as the directory name and `name:` field
   - **trigger sentence** — imperative WHEN-to-invoke description, e.g.
     "Use when the user asks to lint markdown files." This goes verbatim
     into the `description:` field. Trigger-oriented verbs, not noun
     phrases — Claude Code matches user intent against this string.

2. Confirm the target directory. Default: `.claude/skills/<slug>/SKILL.md`
   in the current project root.

3. Write `SKILL.md` with this structure:

   ```
   ---
   name: <slug>
   description: <trigger sentence>
   ---

   # <slug>

   <one-paragraph summary of what the skill does>

   ## Steps
   1. ...
   2. ...

   ## Notes
   - any reference docs, templates, or commands the skill uses
   ```

4. If the skill needs supporting files (templates, reference docs, helper
   scripts), place them alongside `SKILL.md` inside `<slug>/` so the skill
   is loadable in an isolated context fork — never reach outside its own
   directory.

5. Confirm the file was created and remind the user to restart Claude
   Code (or start a new session) for auto-invocation matching to pick it
   up.

## Notes
- Keep the body short. Skills are loaded into isolated context — every
  line costs tokens.
- Do not include emojis.
- Do not write a comment block at the top of supporting scripts unless
  the WHY is non-obvious.
