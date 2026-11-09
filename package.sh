#!/bin/bash
# Build one zip per skill for uploading to claude.ai (Settings > Capabilities > Skills).
# Usage: ./package.sh [out dir]   (default: dist/)
set -euo pipefail
out="${1:-dist}"
mkdir -p "$out"
out="$(cd "$out" && pwd)"
tmp="$(mktemp -d)"
for dir in plugins/*/skills/*/; do
  name="$(basename "$dir")"
  cp -R "$dir" "$tmp/$name"
  # claude.ai has no slash commands, so drop the Claude Code-only flag that hides a skill from the model.
  sed -i.bak '/^disable-model-invocation:/d' "$tmp/$name/SKILL.md" && rm "$tmp/$name/SKILL.md.bak"
  rm -f "$out/$name.zip"
  (cd "$tmp" && zip -qr "$out/$name.zip" "$name" -x '*.DS_Store')
  echo "$out/$name.zip"
done
rm -rf "$tmp"
