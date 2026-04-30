# agentic.nvim — Copilot Instructions

> Personal Neovim plugin owned and developed solo by `jenkeeri`. No
> external contribution intended.

---

## Agent Philosophy

### Load relevant skills before starting

| Task type | Skill(s) to load |
|-----------|-----------------|
| Writing or modifying any test | `skills/lua-testing.md` |
| Implementing a non-trivial change | `skills/qa-review.md` (rubber-duck before) |
| Reviewing a diff before commit | `skills/qa-review.md` (code-review after) |
| Changing theme / highlights / winbar | `skills/ui-theming.md` |
| After **every** completed task | `skills/self-improve.md` (always) |

Loading a skill means reading the file in full before proceeding.

### Agent delegation model

- **Rubber-duck** (`agent_type: "rubber-duck"`) — before implementing anything that
  touches 2+ files or any UI/buffer/window logic. Catches design flaws early.
- **Code-review** (`agent_type: "code-review"`) — after implementing, on the staged
  diff. Catches bugs, unintended scope, convention violations.
- **Task agent** (`agent_type: "task"`) — for test writing delegation; provide full
  context including expected failure reason (see `skills/lua-testing.md`).

### Self-improvement: after every task

After completing any task, consult `skills/self-improve.md` and decide whether
anything new was learned that warrants an update. Then update `.github/progress.md`.
Self-improvement commits are always separate from task work.

---

## Build, Test & Lint

```bash
# Run all validations (format + luals + selene + tests) — after any .lua change
make validate

# Run all tests
make test

# Run a single test file
make test-file FILE=lua/agentic/ui/message_writer.test.lua

# Individual tools
make format                        # Apply StyLua formatting
make format-file FILE=path/to.lua  # Format one file
make luals                         # LuaLS type check
make selene                        # Selene lint
```

`make validate` outputs 5-6 lines and manages its own log files in `.local/`.
**Never redirect its output.** On failure, read logs with targeted commands:

```bash
tail -n 10 .local/agentic_luals_output.log
grep -i "error" .local/agentic_selene_output.log
rg "error|fail" .local/agentic_test_output.log
```

---

## Architecture

### Component hierarchy

```
SessionRegistry          tab_page_id → SessionManager
  └─ SessionManager      1 per tabpage (ACP session ID, file list, code selection)
       └─ ChatWidget     1 per tabpage (all buffers, windows, status animation)
AgentInstance            single subprocess, shared across all tabpages
  └─ ACPClient
       └─ ACPTransport   newline-delimited JSON-RPC over stdio
```

### ACP event pipeline

```
Provider subprocess (external CLI)
  → ACPTransport   (parses JSON, calls on_message)
  → ACPClient      (routes by message type)
  → SessionManager (routes by sessionUpdate type)
  → MessageWriter  (writes to chat buffer, tracks tool call state)
  → PermissionManager / ChatHistory
```

`sessionUpdate` routing:

| Value | Handler |
|---|---|
| `tool_call` | `__handle_tool_call` → subscriber |
| `tool_call_update` | `__handle_tool_call_update` → subscriber |
| `agent_message_chunk` / `agent_thought_chunk` | `MessageWriter:write_message_chunk()` |
| `plan` | `TodoList.render()` |
| `request_permission` | `PermissionManager` (queued, sequential) |

### Tool call phases

1. **`tool_call`** — initial render + extmark anchor created
2. **`tool_call_update`** — partial merge via `tbl_deep_extend`; diffs are
   immutable after first render; body accumulates with `---` dividers
3. **Final `tool_call_update`** — status becomes `completed` or `failed`

### ACP providers

All providers use a single generic `ACPClient` — no per-provider adapter files.
Adding a new provider only requires a config entry in `config_default.lua` under
`acp_providers`. Provider quirks are handled inline in `ACPClient.__build_tool_call_message`.

---

## Critical Conventions

### Multi-tabpage safety — every feature must be tab-safe

- **Never use module-level shared state** for per-tab runtime data.
  Module-level constants are fine (`local CONFIG = {}`); mutable session state is not.
- Get tabpage ID: `self.tab_page_id` in instances; from buffer:
  `vim.api.nvim_win_get_tabpage(vim.fn.bufwinid(bufnr))`.
- List windows scoped to a tab: `vim.api.nvim_tabpage_list_wins(tab_page_id)`.
  Never use `vim.api.nvim_list_wins()` and assume the result belongs to the current session.
- Namespaces are global (idempotent by name). Isolation comes from buffer separation.

**Scoped storage:**

| Scope | Accessor | Use for |
|---|---|---|
| Buffer custom vars | `vim.b[bufnr]` | Custom state |
| Buffer options | `vim.bo[bufnr]` | Built-in opts (`:setlocal`) |
| Window custom vars | `vim.w[winid]` | Custom state |
| Window options | `vim.wo[winid]` | Built-in opts |
| Tabpage custom vars | `vim.t[tabpage]` | Custom state |

- Autocommands: prefer buffer-local (`{ buffer = bufnr }`).
- Keymaps: always buffer-local via `BufHelpers.keymap_set(bufnr, ...)`. No global keymaps.

### Logger

- **Never use `vim.notify` directly.** Always use `Logger.notify`.
- Available methods: `Logger.debug()`, `Logger.debug_to_file()`, `Logger.notify()`.
  There is no `warn()`, `error()`, or `info()`.

### LuaCATS annotations

```lua
--- @param winid number|nil      -- NOT winid? number
--- @field _state? string        -- NOT _state string|nil
--- @return string|nil result    -- NOT string?
--- @return boolean success      -- type first, then name
```

For complex return types, use a typed intermediate variable — LuaLS cannot
infer types from inline table returns:

```lua
--- @return MyModule.Block block
function M.create_block(lines)
    --- @type MyModule.Block
    local block = { start_line = 1, end_line = #lines, content = lines }
    return block
end
```

### Lua restrictions

**`goto`/`::label::` is FORBIDDEN** — Selene does not support it. Use inverted
conditions or `elseif` chains instead.

---

## Git Workflow

Branch name convention: `feat/`, `fix/`, `chore/`, `docs/`, `refactor/` + kebab-case.

**Creating PRs:** `gh` CLI is not installed and the remote uses SSH — there is no stored
HTTP token. PRs must be opened via the GitHub web UI at:
`https://github.com/jenkeeri/agentic.nvim/pull/new/<branch-name>`

---

## Testing

Framework: mini.test with `emulate_busted = true`. Tests co-located with source:
`lua/agentic/foo.test.lua` next to `lua/agentic/foo.lua`.

See `skills/lua-testing.md` for the full testing guide, TDD workflow, and
non-obvious API differences (custom assert module, spy/stub patterns).

---

## Documentation

`doc/agentic.txt` is manually maintained. Update the corresponding vimdoc section
when changing:

| Source file | Vimdoc section |
|---|---|
| `lua/agentic/init.lua` | Usage (public API) |
| `lua/agentic/config_default.lua` | Configuration, Customization |
| `lua/agentic/theme.lua` | Customization (highlight groups) |

After editing vimdoc: `timeout 5 nvim --headless -c "helptags doc/" -c "quit"`.

### Adding a highlight group

1. Add name to `Theme.HL_GROUPS`
2. Define default in `Theme.setup()`
3. Update README.md "Customization (Ricing)" section
