#!/usr/bin/env bash
# PreToolUse on Bash. Blocks any rm -rf-style command and surfaces a
# message to the model on stderr.
set -uo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
[[ -z "$cmd" ]] && exit 0

shopt -s nocasematch

# Short flag forms: rm -rf, rm -fr, rm -Rf, rm -rfv, rm -vrf, etc.
if [[ "$cmd" =~ (^|[^[:alnum:]_])rm[[:space:]]+-[[:alnum:]]*(r[[:alnum:]]*f|f[[:alnum:]]*r) ]]; then
  echo "Blocked: rm -rf-style command. Ask the user before destructive deletes." >&2
  exit 2
fi

# Long flag forms in either order.
if [[ "$cmd" =~ rm[[:space:]]+--recursive[[:space:]]+--force ]] || \
   [[ "$cmd" =~ rm[[:space:]]+--force[[:space:]]+--recursive ]] || \
   [[ "$cmd" =~ rm[[:space:]]+-r[[:space:]]+--force ]] || \
   [[ "$cmd" =~ rm[[:space:]]+--recursive[[:space:]]+-f ]]; then
  echo "Blocked: rm -rf-style command. Ask the user before destructive deletes." >&2
  exit 2
fi

exit 0
