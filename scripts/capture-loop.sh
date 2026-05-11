#!/usr/bin/env bash
# capture-loop.sh — daily 21:00 cron entry point
# Invokes codex in non-interactive mode to run the capture loop skill.
set -euo pipefail

SKILL_DIR="${CAPTURE_LOOP_DIR:-$HOME/.agents/capture-loop}"
CONFIG="${SKILL_DIR}/config.toml"
SKILL_MD="${SKILL_DIR}/SKILL.md"

if [[ ! -f "$CONFIG" ]]; then
  echo "Config not found: $CONFIG" >&2
  echo "Copy config.example.toml to config.toml and edit." >&2
  exit 1
fi

if [[ ! -f "$SKILL_MD" ]]; then
  echo "SKILL.md not found: $SKILL_MD" >&2
  exit 1
fi

# Resolve output_dir from config (expand ~)
output_dir=$(grep -E '^output_dir\s*=' "$CONFIG" | head -1 | sed 's/.*=\s*"\(.*\)"/\1/' | sed "s|^~|$HOME|")
if [[ -z "$output_dir" ]]; then
  output_dir="$HOME/w/tmp/o36/plans"
fi
mkdir -p "$output_dir"

echo "[capture-loop] $(date '+%Y-%m-%d %H:%M:%S') — starting scan"

# Run codex in non-interactive mode with the skill prompt
# codex exec reads the SKILL.md as its task prompt
codex exec --yolo "$(cat "$SKILL_MD")"

# Open the latest generated plan HTML
latest=$(ls -t "$output_dir"/plan-*.html 2>/dev/null | head -1)
if [[ -n "$latest" ]]; then
  echo "[capture-loop] opening $latest"
  open "$latest"
else
  echo "[capture-loop] no plan generated" >&2
fi

echo "[capture-loop] $(date '+%Y-%m-%d %H:%M:%S') — done"
