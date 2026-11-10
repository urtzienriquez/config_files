vim.pack.add({ "https://github.com/mfussenegger/nvim-dap" })
vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/nvim-dapper") --[[@as string]])

local dap = require("dap")
local dapper = require("dapper")

dapper.setup({ size = 0.5 })

-- adapters and configurations: only R's here. dapper.setup() adds the gdb adapter and "Launch" /
-- "Attach to process" to <leader>dc's list, and build.nvim adds "Build & debug" (first) in the
-- buffers :Build works in

-- R: rdap (~/Documents/GitHub/rdap; make install), a debug adapter that runs R itself
vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/rdap") --[[@as string]])
require("rdap").setup()

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
