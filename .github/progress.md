# agentic.nvim — Progress

Personal fork progress log. Updated after every significant task.

---

## Active work

- Branch `feat/ui-redesign` pushed to `jenkeeri/agentic.nvim` — PR needs to be opened manually:
  https://github.com/jenkeeri/agentic.nvim/pull/new/feat/ui-redesign

---

## Completed

### 2026-04-24 — UI redesign (Phase 2)

**What changed (plugin — `feat/ui-redesign` branch, commit `c6d395b`):**
- `lua/agentic/theme.lua`: replaced hardcoded dark hex `COLORS` table with semantic hl links
  (`DiffText`, `DiagnosticWarn/Ok/Error`, `Title`, `Function`, `Statement`, `WarningMsg`)
- `lua/agentic/init.lua`: added `ColorScheme` autocmd to re-apply highlights on theme toggle
- `lua/agentic/ui/window_decoration.lua`: minimal winbar (no colored block, left-aligned,
  uses `WinBar`/`Title` links instead of solid `AgenticTitle` background fill)

**What changed (dotfiles — `feature/agentic-nvim`, commit `2a6889d`):**
- `configs/agentic.lua`: `change_mode` → `<C-Tab>` (fixed conflict with `copilot#AcceptWord`)
- Icons: braille spinner chars, Nerd Font diagnostic/message icons (replaced emoji)
- Layout: width 45%, input height 6, todos panel hidden by default

**Validation:** `make validate` failures are pre-existing (unrelated `file_picker.test.lua` and
luals issues for mini.test child API) — no regressions introduced.



**What changed:**
- Created `.github/copilot-instructions.md` — personal fork framing, agent philosophy,
  skills loading table, build/test/lint commands, architecture, Lua conventions
- Created `.github/skills/self-improve.md` — conservative self-improvement protocol
- Created `.github/skills/lua-testing.md` — TDD mandate, mini.test gotchas, spy/stub API,
  delegation pattern for testing sub-agent
- Created `.github/skills/qa-review.md` — rubber-duck before / code-review after workflow,
  QA checklist (correctness, scope, multi-tab safety, conventions, tests)
- Created `.github/progress.md` (this file)

**Architectural decisions:**
- Skills are flat `.md` files (not subdirectory `SKILL.md`) — simpler for solo project
- Testing and QA agents invoked via Copilot CLI `task` tool — no custom agent definition
  files needed
- Self-improvement commits always separate from task work

---

## Architectural decisions

| Decision | Rationale |
|----------|-----------|
| Skills structure | `.github/skills/` uses flat `.md` files; `.claude/skills/` uses `SKILL.md` subdirectory pattern (Claude Code convention) |
| No upstream PR workflow | Solo personal fork; no CodeRabbit, no draft PR mandate |
| Rubber-duck before, code-review after | Catch design flaws early (cheap) not late (expensive) |
| Semantic hl links (not hex) | Plugin adapts to user's colorscheme; no hardcoded dark/light assumption |
| `ColorScheme` autocmd in `init.lua` | User toggles themes; highlights must re-apply after `:colorscheme` |
| `change_mode = <C-Tab>` | `<S-Tab>` conflicted with `copilot#AcceptWord` in insert mode |
