vim.pack.add({ "https://github.com/mfussenegger/nvim-dap" })
vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/nvim-dapper") --[[@as string]])

local dap = require("dap")
local dapper = require("dapper")

dapper.setup({ size = 0.5 })

----------------------------------------
-- adapters (gdb's: dapper's, from setup()) and configurations

dap.adapters.python = { type = "executable", command = "python3", args = { "-m", "debugpy.adapter" } }

local gdb_configs = {
  require("build.dap").configuration(), -- "Build & debug": builds the debug target first
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
  },
  {
    name = "Attach to process",
    type = "gdb",
    request = "attach",
    pid = function()
      return require("dap.utils").pick_process()
    end,
  },
}
for _, ft in ipairs({ "c", "cpp", "fortran", "zig" }) do
  dap.configurations[ft] = gdb_configs
end

dap.configurations.python = {
  { name = "Launch file", type = "python", request = "launch", program = "${file}", console = "integratedTerminal" },
  {
    name = "Launch file with args",
    type = "python",
    request = "launch",
    program = "${file}",
    args = function()
      return vim.split(vim.fn.input("Arguments: "), " ", { trimempty = true })
    end,
    console = "integratedTerminal",
  },
}

----------------------------------------
-- keymaps

local function map(lhs, rhs, desc, mode)
  vim.keymap.set(mode or "n", lhs, rhs, { desc = desc })
end

map("<leader>dc", dap.continue, "Continue / start")
map("<leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
map("<leader>dD", dapper.clear_breakpoints, "Delete all breakpoints")
map("<leader>dB", dapper.conditional_breakpoint, "Conditional breakpoint")
map("<leader>dl", dapper.log_point, "Log point")
map("<leader>di", dap.step_into, "Step into")
map("<leader>do", dap.step_over, "Step over")
map("<leader>dO", dap.step_out, "Step out")
map("<leader>dC", dap.run_to_cursor, "Run to cursor")
map("<leader>dr", dap.restart, "Restart")
map("<leader>dt", dap.terminate, "Terminate")
map("<leader>dL", dap.run_last, "Run last")
map("<leader>dd", "<Cmd>Dapper<CR>", "Debug actions (pick one)")
map("<leader>dv", "<Cmd>Dapper toggle<CR>", "Toggle debug panes")
map("<leader>dw", "<Cmd>Dapper watch<CR>", "Watch expression", { "n", "x" })
map("<leader>dk", "<Cmd>Dapper hover<CR>", "Hover evaluate", { "n", "x" })
map("<leader>dm", "<Cmd>Dapper memory<CR>", "Memory (tab page)", { "n", "x" })
map("<leader>da", "<Cmd>Dapper disassembly<CR>", "Disassembly (tab page)")
