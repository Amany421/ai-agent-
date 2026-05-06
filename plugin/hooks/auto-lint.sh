#!/usr/bin/env bash
# PreToolUse on Write|Edit. Warn-only: never blocks the tool call.
# Detects ruff / eslint / prettier / shellcheck by config and runs the
# matching linter against the target file if it already exists.
set -uo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[[ -z "$file_path" ]] && exit 0

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
log_dir="$repo_root/.claude/logs"
mkdir -p "$log_dir"
log="$log_dir/lint.log"
ts=$(date -Iseconds)

# Walk upward from the file's directory looking for a known config.
find_up() {
  local needle="$1" dir
  dir=$(dirname "$file_path")
  while [[ "$dir" != "/" && "$dir" != "." ]]; do
    if compgen -G "$dir/$needle" > /dev/null; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

run_and_log() {
  local tool="$1"; shift
  if ! command -v "${1%% *}" >/dev/null 2>&1 && [[ "${1%% *}" != "npx" ]]; then
    echo "$ts  $tool  skipped (binary missing)  $file_path" >> "$log"
    return 0
  fi
  local out
  if out=$("$@" "$file_path" 2>&1); then
    echo "$ts  $tool  ok  $file_path" >> "$log"
  else
    echo "$ts  $tool  warn  $file_path" >> "$log"
    printf '%s\n' "$out" >> "$log"
    echo "auto-lint: $tool reported issues on $file_path (see .claude/logs/lint.log)" >&2
  fi
}

# Only lint files that already exist on disk (Edit, or repeated Write).
[[ -f "$file_path" ]] || { exit 0; }

case "$file_path" in
  *.py)
    if find_up "pyproject.toml" >/dev/null || find_up "ruff.toml" >/dev/null; then
      run_and_log ruff ruff check
    fi
    ;;
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs)
    if find_up ".eslintrc*" >/dev/null || find_up "eslint.config.*" >/dev/null; then
      run_and_log eslint npx --no-install eslint
    elif find_up ".prettierrc*" >/dev/null || find_up "prettier.config.*" >/dev/null; then
      run_and_log prettier npx --no-install prettier --check
    fi
    ;;
  *.sh|*.bash)
    if command -v shellcheck >/dev/null 2>&1; then
      run_and_log shellcheck shellcheck
    fi
    ;;
esac

exit 0
