#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$HOME/.claude/skills/dual-claude"
CMD_DIR="$HOME/.claude/commands"

echo "dual-claude uninstall"
echo "====================="

# Remove symlinked commands (only if they point to dual-claude)
for cmd in workflow po review; do
  dst="$CMD_DIR/${cmd}.md"
  if [ -L "$dst" ]; then
    target="$(readlink "$dst")"
    if echo "$target" | grep -q "dual-claude"; then
      rm "$dst"
      echo "  /${cmd} -> removed"
    else
      echo "  /${cmd} -> skipped (points to $target)"
    fi
  fi
done

# Remove skill directory
if [ -d "$SKILL_DIR" ]; then
  rm -rf "$SKILL_DIR"
  echo "  skill directory -> removed"
fi

echo ""
echo "Done. dual-claude has been uninstalled."