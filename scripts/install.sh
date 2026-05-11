#!/usr/bin/env bash
# install.sh — symlink skill + optionally install cron job
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CC_SKILLS_DIR="${CLAUDE_CODE_SKILLS_DIR:-$HOME/.claude/skills}"
TARGET="$CC_SKILLS_DIR/capture-loop"

echo "=== capture-loop installer ==="

# 1. Symlink skill
mkdir -p "$CC_SKILLS_DIR"
if [[ -L "$TARGET" || -d "$TARGET" ]]; then
  echo "[skip] $TARGET already exists"
else
  ln -s "$SKILL_DIR" "$TARGET"
  echo "[ok] symlinked $TARGET -> $SKILL_DIR"
fi

# 2. Check config
if [[ ! -f "$SKILL_DIR/config.toml" ]]; then
  echo "[!] config.toml not found. Copy and edit:"
  echo "    cp $SKILL_DIR/config.example.toml $SKILL_DIR/config.toml"
  echo "    vim $SKILL_DIR/config.toml"
else
  echo "[ok] config.toml found"
fi

# 3. Optionally install cron
read -p "Install daily cron job at 21:00? [y/N] " -r install_cron
if [[ "$install_cron" =~ ^[Yy]$ ]]; then
  SCRIPT="$SKILL_DIR/scripts/capture-loop.sh"
  chmod +x "$SCRIPT"
  CRON_ENTRY="0 21 * * * /bin/zsh -lc '$SCRIPT' >> /tmp/capture-loop-cron.log 2>&1 # capture-loop"
  # Avoid duplicate entries
  (crontab -l 2>/dev/null | grep -v '# capture-loop'; echo "$CRON_ENTRY") | crontab -
  echo "[ok] cron installed: 0 21 * * *"
else
  echo "[skip] cron not installed. Add manually:"
  echo "    0 21 * * * /bin/zsh -lc '$SKILL_DIR/scripts/capture-loop.sh' >> /tmp/capture-loop-cron.log 2>&1"
fi

echo "=== done ==="
