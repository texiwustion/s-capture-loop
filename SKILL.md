---
name: capture-loop
description: 扫描 _now.md 未处理节 → 跨参照项目文档 → 分类搬运策划方案 HTML。触发：/capture-loop 或 codex exec --yolo $capture-loop (cron 每日 21:00)
---

# Capture Loop

Scan `_now.md` for unprocessed sections, cross-reference project directories, and generate a classification plan HTML for human audit.

## Trigger

- **Manual**: `/capture-loop` in Claude Code
- **Scheduled**: `codex exec --yolo "$(cat ~/.claude/skills/capture-loop/SKILL.md)"` via cron

## Config

Read `config.toml` in the skill directory first. If not found, use defaults from `config.example.toml`.

Key config sections:
- `[paths]` — where _now.md, _what_how.md, inbox, box, review_queue, project_dir, output_dir live
- `[extraction]` — `project_code_regex` to pull the 3-letter project code from section headers
- `[routing]` — regex patterns for classifying content (command, sop, viewpoint, question)
- `[project_docs]` — which files/dirs to read for cross-referencing

## Execution

### Phase 1: Scan

1. Read `_now.md` from `[paths].now_file`.
2. Find all H1/H2 sections.
3. For each section:
   - If no `[processed:... hash:...]` marker → treat as unprocessed.
   - If marker exists, compute current content hash → compare with stored hash:
     - Hash match → skip (no new content).
     - Hash mismatch → process (new content added).
4. Use `[extraction].project_code_regex` to extract the project code from each section header.

### Phase 2: Cross-Reference

For each section with a valid project code:
1. Locate the project directory: `[paths].project_dir / <code>`.
2. Read files listed in `[project_docs].read_docs` (README.md, AGENTS.md, CLAUDE.md).
3. Read markdown files from `[project_docs].read_dirs` (docs/, m/).
4. Skip dirs in `[project_docs].skip_dirs`.

### Phase 3: Classify

For each section's content, apply routing regex from `[routing]`:

| Pattern | Match | Destination |
|---|---|---|
| `command_regex` | Bash/sh/zsh code blocks | `_what_how.md` (append with `# 目的:` comment) |
| `sop_regex` | Numbered steps, `# 目的:` headers | `_what_how.md` (append; if ≥3 related commands, wrap in `.sh` script) |
| `viewpoint_regex` | Invariants, methodology claims | `inbox/` new fleeting note (assertion title + inline wikilinks) |
| `question_regex` | Questions, TODOs, gaps | `inbox/` new fleeting note + `_review_queue.md` |
| (none of above) | Pure context / narrative | Leave in `_now.md` |

**Quality rules (硬规则):**
- Every command/SOP entry must include a `# 目的:` comment explaining what it does.
- Every wikilink in inbox notes must appear inline in a body sentence: `[[title|display-name]]`. No bare link lists in a "Links" section.
- If a group of commands forms a complete operation, wrap them in a standalone `.sh` script.

### Phase 4: Generate Plan HTML

Produce a self-contained HTML file at `[paths].output_dir/plan-YYYY-MM-DD.html`.

HTML structure:
1. **Meta**: generation time, source sections, project docs read
2. **Plan items**: each classified item shown with destination, full content (including `# 目的:` comments), reason for routing
3. **Link audit**: for each inbox note, show which wikilinks appear in body (green) vs. which are missing (red) — enforce "链在句子里，不在列表里"
4. **Staying put**: list content that remains in `_now.md`
5. **Post-execution markers**: the `[processed:YYYY-MM-DD hash:xxxx]` lines that will be written

### Phase 5: Output

1. Write the HTML file to `[paths].output_dir`.
2. On macOS, run `open <html-file>` to display in browser.
3. Print a summary to stdout: "N sections scanned, M need processing → plan written to <path>".

### Phase 6: Execute (manual trigger only, NOT cron)

After user audits the plan HTML and confirms via audio or text:
1. Write each classified item to its destination file.
2. Update `_now.md` section markers to `[processed:YYYY-MM-DD hash:xxxx]`.
3. Report: "Moved X items → _what_how.md, Y items → inbox, Z items → review queue."

## Anti-Patterns

- Do NOT modify `_now.md` during Phase 1-5 (scan/classify/generate). Only during Phase 6 (execute, after human audit).
- Do NOT write to `box/` directly. All permanent notes go through `inbox/` first.
- Do NOT create wikilinks that don't appear in body text.
- Do NOT skip cross-referencing project docs — `_now.md` content alone is insufficient.

## Config Reference

See `config.example.toml` for all options with comments. User copies to `config.toml` and edits.
