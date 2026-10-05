#!/bin/bash
# Pre-commit hook: Ruby → RuboCop, TypeScript → Vitest

BLOCKED=false
REASON=""

if [ -f "Gemfile" ] || [ -f ".rubocop.yml" ]; then
  echo "Running RuboCop..." >&2
  if command -v rubocop &>/dev/null; then
    if ! rubocop --format progress 2>&1; then
      BLOCKED=true
      REASON="RuboCop が失敗しました。コードスタイルの問題を修正してからコミットしてください。"
    fi
  else
    echo "rubocop が見つかりません。スキップします。" >&2
  fi
elif [ -f "package.json" ] && grep -q '"vitest"' package.json 2>/dev/null; then
  echo "Running Vitest..." >&2
  if command -v pnpm &>/dev/null; then
    if ! pnpm run test --run 2>&1; then
      BLOCKED=true
      REASON="Vitest が失敗しました。テストを通してからコミットしてください。"
    fi
  elif command -v npx &>/dev/null; then
    if ! npx vitest run 2>&1; then
      BLOCKED=true
      REASON="Vitest が失敗しました。テストを通してからコミットしてください。"
    fi
  fi
fi

if [ "$BLOCKED" = true ]; then
  jq -n --arg r "$REASON" '{"continue": false, "stopReason": $r}'
  exit 1
fi
