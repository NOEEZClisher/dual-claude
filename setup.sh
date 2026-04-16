#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
CMD_DIR="$HOME/.claude/commands"

echo "dual-claude setup"
echo "================="

# Create commands directory
mkdir -p "$CMD_DIR"

# Symlink slash commands
for cmd in workflow po review; do
  src="$SKILL_DIR/commands/${cmd}.md"
  dst="$CMD_DIR/${cmd}.md"

  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -f "$dst" ]; then
    echo "  WARNING: $dst already exists (not a symlink). Skipping."
    echo "           Remove it manually if you want dual-claude to manage it."
    continue
  fi

  ln -s "$src" "$dst"
  echo "  /${cmd} -> linked"
done

echo ""
echo "Done. Commands available: /workflow, /po, /review"
echo "Run 'claude' to start using dual-claude."