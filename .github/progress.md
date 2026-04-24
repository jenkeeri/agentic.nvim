# agentic.nvim — Progress

Personal fork progress log. Updated after every significant task.

---

## Active work

- [ ] Phase 2: agentic.nvim visual improvements (pending user input on direction)

---

## Completed

### 2026-04-24 — Collaboration framework setup

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
| Flat skills structure | Personal project; dotfiles-style simpler than work-style subdirs |
| No upstream PR workflow | Solo personal fork; no CodeRabbit, no draft PR mandate |
| Rubber-duck before, code-review after | Catch design flaws early (cheap) not late (expensive) |
