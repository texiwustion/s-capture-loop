# capture-loop

Daily classification plan generator for the capture-subsystem closed loop.

Scans `_now.md` for unprocessed sections, cross-references project directories, and generates a self-contained HTML classification plan for human audit.

## Install

```bash
git clone https://github.com/706lab/s-capture-loop ~/.agents/capture-loop
cp ~/.agents/capture-loop/config.example.toml ~/.agents/capture-loop/config.toml
vim ~/.agents/capture-loop/config.toml
bash ~/.agents/capture-loop/scripts/install.sh
```

## Usage

- **Manual**: `/capture-loop` in Claude Code
- **Scheduled**: cron at 21:00 daily via `scripts/capture-loop.sh`

## Config

See `config.example.toml`. All paths and routing regex are customizable.

## Files

```
SKILL.md              — skill definition + execution prompt
config.example.toml   — config template (safe to share)
scripts/
  capture-loop.sh     — cron entry point (calls codex exec)
  install.sh          — symlink + cron installer
templates/
  plan-template.html  — HTML skeleton for generated plans
```
