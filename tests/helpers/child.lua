-- Helper to create isolated child Neovim instances with plugin loaded

local MiniTest = require("mini.test")

--- @class tests.helpers.Child : MiniTest.child
--- @field setup fun() Restart child and load plugin and run agentic.setup() to run auto commands and configurations
--- @field flush fun() Flush pending scheduled callbacks in child neovim and wait a bit to ensure they are processed
--- Fields below are re-declared from MiniTest.child because deps/ is in
--- LuaLS ignoreDir, so parent class fields are not resolved.
--- @field start fun(args?: table, opts?: table) Start child process
--- @field stop fun() Stop child process
--- @field restart fun(args?: table, opts?: table) Restart child process
--- @field type_keys fun(...) Emulate typing keys
--- @field cmd fun(code: string) Execute Vimscript
--- @field cmd_capture fun(code: string): string Execute Vimscript and capture output
--- @field lua fun(code: string, args?: table) Execute Lua code
--- @field lua_notify fun(code: string, args?: table) Execute Lua code without waiting
--- @field lua_get fun(code: string, args?: table): any Execute Lua code and return result
--- @field lua_func fun(fn: function, ...): any Execute Lua function and return result
--- @field is_blocked fun(): boolean Check whether child process is blocked
--- @field is_running fun(): boolean Check whether child process is currently running
--- @field ensure_normal_mode fun() Ensure normal mode
--- @field get_screenshot fun(opts?: table): table Get screenshot
--- @field job table|nil Information about current job
--- @field api table Redirection table for vim.api
--- @field api_notify table Redirection table for vim.api via rpcnotify
--- @field diagnostic table Redirection table for vim.diagnostic
--- @field fn table Redirection table for vim.fn
--- @field highlight table Redirection table for vim.highlight
--- @field hl table Redirection table for vim.hl
--- @field json table Redirection table for vim.json
--- @field loop table Redirection table for vim.loop
--- @field lsp table Redirection table for vim.lsp
--- @field mpack table Redirection table for vim.mpack
--- @field spell table Redirection table for vim.spell
--- @field treesitter table Redirection table for vim.treesitter
--- @field ui table Redirection table for vim.ui
--- @field fs table Redirection table for vim.fs
--- @field g table Redirection table for vim.g
--- @field b table Redirection table for vim.b
--- @field w table Redirection table for vim.w
--- @field t table Redirection table for vim.t
--- @field v table Redirection table for vim.v
--- @field env table Redirection table for vim.env
--- @field o table Redirection table for vim.o
--- @field go table Redirection table for vim.go
--- @field bo table Redirection table for vim.bo
--- @field wo table Redirection table for vim.wo

--- @class tests.helpers.ChildModule
local M = {}

--- Create a new child Neovim instance with the plugin pre-loaded
--- @return tests.helpers.Child child Child Neovim instance with setup() method
function M.new()
    local child = MiniTest.new_child_neovim() --[[@as tests.helpers.Child]]
    local root_dir = vim.fn.getcwd()

    function child.setup()
        child.restart({ "-u", "NONE" })
        child.lua("vim.opt.rtp:prepend(...)", { root_dir })

        child.lua([[
            local ACPTransportMock = require("tests.mocks.acp_transport_mock")
            package.loaded["agentic.acp.acp_transport"] = ACPTransportMock
        ]])

        child.lua([[
            local ACPHealthMock = require("tests.mocks.acp_health_mock")
            package.loaded["agentic.acp.acp_health"] = ACPHealthMock
        ]])

        child.lua([[
            require("agentic").setup()
        ]])
    end

    function child.flush()
        child.lua([[
          vim.cmd("redraw")
        ]])

        child.api.nvim_eval("1")
    end

    return child
end

return M
