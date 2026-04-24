# Skill: QA Review

Load this skill before reviewing any implementation in this codebase.

## When to invoke QA

- **Before implementing** non-trivial changes (2+ files, any UI/buffer/window logic):
  → Use rubber-duck critique to validate the plan first
- **After implementing** any non-trivial change:
  → Use code-review agent on the staged diff

A task is **not done** until QA passes. Fix before committing.

## Rubber-duck: before implementing

Invoke with `agent_type: "rubber-duck"` when:

- The change touches more than one module
- Any buffer, window, or extmark logic is involved
- You're unsure about multi-tabpage safety
- The change involves the ACP pipeline (transport → client → session → writer)

Prompt template:

```
Here is my plan for [task].

[Paste plan / approach]

Relevant code:
[Paste key functions being modified]

Please critique for: correctness, blind spots, multi-tabpage safety, edge cases.
Focus on real bugs — skip style and formatting comments.
```

## Code-review: after implementing

Invoke with `agent_type: "code-review"` after implementation. The agent reviews
staged/unstaged changes automatically.

Ask it to focus on:
- Does the change actually solve the problem?
- Any unintended side effects?
- Multi-tabpage safety violations?
- Logger usage (never `vim.notify` directly)?
- LuaCATS annotation correctness?

## What QA checks (manual checklist)

### Correctness
- [ ] Does the change solve the stated problem?
- [ ] Are edge cases handled (nil values, empty tables, missing buffers)?

### Scope
- [ ] Only the intended code was changed — no unrelated edits

### Multi-tabpage safety
- [ ] No new module-level mutable state added
- [ ] Window lookups scoped to `self.tab_page_id`
- [ ] Keymaps are buffer-local (`BufHelpers.keymap_set`)
- [ ] Autocommands are buffer-local or filter by tabpage

### Lua conventions
- [ ] `Logger.notify` used — never `vim.notify` directly
- [ ] No `goto` / `::label::` syntax
- [ ] LuaCATS annotations: `@param type|nil` not `@param? type`
- [ ] Complex return types use typed intermediate variable before `return`

### Tests
- [ ] Failing test written first (if bug fix or behavioral change)
- [ ] `make validate` passes
- [ ] Mark count matches `it()` block count
- [ ] Stubs reverted in `after_each`
