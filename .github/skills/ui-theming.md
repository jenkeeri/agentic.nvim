# Skill: UI Theming and Highlight Groups

## Key facts about this plugin's theme system

- All highlight groups are defined in `lua/agentic/theme.lua` (`Theme.HL_GROUPS` + `Theme.setup()`).
- `_create_hl_if_not_exists` only sets a group if it's not already defined — user's colorscheme
  definitions always win.
- `Theme.setup()` is called once in `lua/agentic/init.lua` on first `Agentic.setup()`.
- A `ColorScheme` autocmd (also in `init.lua`) calls `Theme.setup()` again after any theme
  change — this is required because `:colorscheme` calls `:hi clear`, wiping our groups.
  Without it, toggling themes leaves all plugin highlights unset.

## Do not use hardcoded hex colors

The plugin's default highlights must use **semantic links** (not hex) so they work on any
colorscheme (light, dark, or toggled mid-session).

| Role | Semantic link |
|------|--------------|
| Diff deleted word | `DiffText` |
| Diff added word | `DiffText` |
| Status: pending/in-progress | `DiagnosticWarn` |
| Status: completed | `DiagnosticOk` |
| Status: failed | `DiagnosticError` |
| Winbar title | `Title` |
| Spinner: generating | `Function` |
| Spinner: thinking | `Statement` |
| Spinner: searching | `WarningMsg` |
| Spinner: busy | `Comment` |

## `link` cannot be combined with other attrs

In `nvim_set_hl`, using `{ link = "Group" }` inherits ALL of the linked group's
attributes. You cannot do `{ link = "Group", bold = true }` — the `bold` is silently ignored.
If you need both a semantic color and additional style, you must read the fg from the source
group at setup time (but note: that freezes the color, not re-resolved on theme change).

## Winbar rendering format

The winbar template in `window_decoration.lua` is:
```lua
string.format(" %%#%s#%s%%#WinBar#", opts.hl, text)
```
- Starts with a single space (no padding inside the HL block)
- Applies `opts.hl` to the text only (not as a solid background block)
- Resets to `WinBar` at the end (use `WinBar`, not `Normal`, for proper theme integration)

Default alignment is `"left"` — suffix/hint text is deprioritized in narrow panes.

## User override pattern

Users can override individual HL groups before calling `require("agentic").setup()`:
```lua
vim.api.nvim_set_hl(0, "AgenticTitle", { fg = "#yourcolor", bold = true })
require("agentic").setup(...)
```
`_create_hl_if_not_exists` will see the group is already defined and skip it.

## Keymap config format — critical

`BufHelpers.multi_keymap_set` treats a **plain string** key as `{ key }` with mode `"n"` only.
For multi-mode keymaps, always use the table form:

```lua
-- WRONG: only binds in normal mode
change_mode = "<C-Tab>"

-- CORRECT: binds in i, n, v
change_mode = {
  { "<C-Tab>", mode = { "i", "n", "v" } },
}
```

This applies to: `widget.change_mode`, `prompt.accept_completion`, `prompt.paste_image`.
