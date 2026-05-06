---
name: adk-scaffold-agent
description: Scaffold a new subagent definition under .claude/agents/ with name/description/tools/model frontmatter. Use when the user asks to add, create, or bootstrap a subagent.
---

# adk-scaffold-agent

Create a new subagent definition in `.claude/agents/<slug>.md`.

## Steps

1. Ask the user for:
   - **slug** — kebab-case (becomes filename and `name:` field)
   - **purpose** — one sentence answering "when should the main agent
     delegate to this subagent?" Goes into `description:`.
   - **needed tools** — derive the minimum allowlist from the purpose:
     - read-only sweep → `Read, Grep, Glob`
     - run commands / tests → add `Bash`
     - write or edit files → add `Write, Edit`
     - **never** include `Agent` — subagents must not spawn subagents

2. Default `model: inherit` unless the user asks for a specific tier.

3. Write `.claude/agents/<slug>.md`:

   ```
   ---
   name: <slug>
   description: <purpose>
   tools: <comma-separated minimum allowlist>
   model: inherit
   ---

   Subagents run in an isolated context. Only the final message returns
   to the parent. Tool allowlist is intentionally minimum. `Agent` is
   excluded — subagents may not spawn subagents.

   # <slug>

   <body: detailed system prompt scoped to this role only — what to do,
   what to return, what NOT to do>

   ## Prohibited
   - <list anything the agent must not do, e.g. "do not edit files
     outside the directory the user asked about">
   ```

4. Confirm the file was created and remind the user to restart Claude
   Code so the subagent is registered.

## Notes
- The body should reinforce isolation: the agent does not see main-agent
  context, so all needed inputs must come through its prompt.
- Prefer narrow tool allowlists. Add tools later if needed; do not
  speculatively grant.
