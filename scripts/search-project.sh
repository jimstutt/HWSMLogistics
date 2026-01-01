#!/usr/bin/env bash
# ~/Dev/NGOLogisticsD/scripts/search-project.sh
# Usage: ./search-project.sh "search term"

set -euo pipefail

SEARCH_TERM="${1:-}"
if [[ -z "$SEARCH_TERM" ]]; then
  echo "Usage: $0 \"search term\"" >&2
  exit 1
fi

ROOT="${PWD}"
EXCLUDE_DIRS=(
  "node_modules"
  "data"
  ".git"
)

# Build --exclude-dir args safely (no injection)
EXCLUDE_ARGS=()
for d in "${EXCLUDE_DIRS[@]}"; do
  EXCLUDE_ARGS+=(--exclude-dir="$d")
done

# Use ripgrep if available (highly recommended)
if command -v rg >/dev/null 2>&1; then
  echo "🔍 Using ripgrep (fast, respects .gitignore + custom exclusions)"
  # Exclude store paths via glob (ripgrep supports !pattern)
  rg --smart-case \
     --type-add 'nix:*.nix' \
     --glob='!/**/node_modules/**' \
     --glob='!/**/data/**' \
     --glob='!/**/.git/**' \
     --glob='!/nix/store/**' \
     "$SEARCH_TERM" "$ROOT"
else
  echo "🔍 Using grep (GNU)"
  # GNU grep: --exclude-dir only matches basename, not full path —
  # so /nix/store exclusion must be done via find + grep
  find "$ROOT" \
    -type d \( \
        -name "node_modules" -o \
        -name "data" -o \
        -name ".git" -o \
        -path "/nix/store/*" \
      \) -prune -o \
    -type f -print0 \
  | xargs -0 grep -HnI --color=auto "$SEARCH_TERM"
fi
