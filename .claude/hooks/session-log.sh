#!/usr/bin/env bash
# Stop hook. Appends a session summary to session-log.md in the repo root.
# Coexists additively with the global ~/.claude/stop-hook-git-check.sh.
set -uo pipefail

input=$(cat)
stop_active=$(printf '%s' "$input" | jq -r '.stop_hook_active // "false"')
[[ "$stop_active" == "true" ]] && exit 0

session_id=$(printf '%s' "$input" | jq -r '.session_id // "unknown"')
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
log="$repo_root/session-log.md"

ts=$(date -Iseconds)
branch=$(git -C "$repo_root" branch --show-current 2>/dev/null || echo "no-branch")
head=$(git -C "$repo_root" rev-parse --short HEAD 2>/dev/null || echo "no-commits")
changed=$(git -C "$repo_root" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

{
  echo ""
  echo "## $ts — session $session_id"
  echo "- cwd: $repo_root"
  echo "- branch: $branch"
  echo "- HEAD: $head"
  echo "- changed files: $changed"
} >> "$log"

exit 0
