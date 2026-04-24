# Skill: Lua Testing (agentic.nvim)

Load this skill before writing, modifying, or reviewing any test in this codebase.

## TDD is mandatory

For every bug fix or behavioral change:

1. **Write the failing test first.** If the required function/class doesn't exist yet,
   scaffold it with a stub body so the test fails on wrong behavior — not on
   `attempt to call a nil value`. A "missing symbol" failure means the test hasn't
   reached the logic it's supposed to exercise.
2. **Run the test, confirm it fails for the right reason.**
3. **Fix.** Minimal code to turn it green.
4. **`make validate`** — confirm nothing else broke.
5. **Mark count check** — verify the number of `it()` blocks matches the reported
   mark count. A mismatch means a test silently disappeared (usually from an assertion
   escaping via `vim.schedule`).

Exception: pure refactors, formatting, docs — state it explicitly.

## Running tests

```bash
# All tests
make test

# Single file (preferred during development)
make test-file FILE=lua/agentic/ui/message_writer.test.lua

# Full validation after any .lua change
make validate
```

## Delegating to a testing sub-agent

For non-trivial test writing, invoke the task agent:

```
agent_type: "task"
prompt: |
  Write a failing test for [behavior] in [file].
  Test file: [path].test.lua
  Framework: mini.test with emulate_busted = true
  Assert module: require('tests.helpers.assert') — NOT luassert
  Spy module: require('tests.helpers.spy')
  The test should fail on the ASSERTION (wrong output/state), not on a missing symbol.
  Run: make test-file FILE=[path].test.lua and confirm the failure message.
  [Paste relevant source file content for context]
```

## Framework: mini.test — non-obvious differences

These are the things that silently fail or confuse if you come from busted/luassert:

### Assert module (`tests/helpers/assert.lua`) — always read it before testing

```lua
local assert = require('tests.helpers.assert')

assert.equal(expected, actual)         -- basic equality
assert.same(expected, actual)          -- deep equality (same as equal here)
assert.is_nil(v) / assert.is_not_nil(v)
assert.is_true(v) / assert.is_false(v)
assert.truthy(v) / assert.is_falsy(v)
assert.has_no_errors(function() ... end)
assert.are.equal(expected, actual)
assert.are_not.equal(expected, actual)

-- For error pattern matching — use MiniTest directly:
MiniTest.expect.error(fn, 'pattern')
```

### Spy/stub module (`tests/helpers/spy.lua`) — always read it before testing

```lua
local spy = require('tests.helpers.spy')

-- Standalone spy
local s = spy.new(function() end)

-- Spy on existing method
local s = spy.on(vim.api, 'nvim_feedkeys')

-- Stub (replaces method)
local stub = spy.stub(vim.uv, 'fs_stat')
stub:returns({ type = 'file' })
stub:invokes(function(_path) return nil end)  -- prefix unused params with _
stub:reset()   -- clears call tracking only, NOT behavior
stub:revert()  -- ALWAYS call in after_each
```

**Critical differences from other frameworks:**

| What you might try | What actually works |
|--------------------|---------------------|
| `spy:call(1)` | `spy.calls[1]` — array, not method |
| `called_with(fn)` | Won't work — `vim.deep_equal` can't match functions; check manually |
| `assert.spy(s).was.called(0)` | Use `0`, not `nil`, to assert not-called |

When spying on a method called with `:`, `calls[1][1]` is `self`.

### Shared process — always clean up

All tests run in a **single Neovim process**. State leaks between tests.

In `after_each`, always:
- Delete buffers created: `vim.api.nvim_buf_delete(bufnr, { force = true })`
- Revert all stubs: `stub:revert()`
- Clear autocommands if created globally

### Async code — assertions inside `vim.schedule` are silently dropped

If an assertion runs inside `vim.schedule()` or `vim.wait()`, a failure will not
register — the test appears to pass. This is the most common cause of a mark count
mismatch. Keep assertions in synchronous code paths only.

## Mocking transport (ACP tests)

Never make real subprocess calls in tests. Stub the transport:

```lua
local transport = require('agentic.acp.transport')
local transport_stub = spy.stub(transport, 'send')
-- revert in after_each
```
