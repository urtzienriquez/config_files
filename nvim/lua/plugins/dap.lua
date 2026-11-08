vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/igorlfs/nvim-dap-view",
})

local dap = require("dap")

require("dap-view").setup({
  auto_toggle = true,
  windows = {
    position = "right",
    size = 0.5,
    -- the terminal of programs that ask for one (Python): stacked under the panel
    terminal = { position = "below", size = 0.4 },
  },
})

-- the window under dap-view's panel: call stack, scopes, threads, REPL or program I/O
local panel = require("dap_panel")

-- where the code is shown when the program stops: a window already showing that file (in any
-- tab), else the previous window (never the debug windows: they have 'winfixbuf')
dap.defaults.fallback.switchbuf = "usetab,uselast"

----------------------------------------
-- adapters

-- gdb >= 14 speaks DAP natively; the program reads and writes the panel's "Program I/O" terminal
dap.adapters.gdb = function(callback, config)
  local args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
  if config.request == "launch" then
    vim.list_extend(args, { "--eval-command", "set inferior-tty " .. panel.program_terminal() })
  end
  callback({ type = "executable", command = "gdb", args = args })
end

-- gdb answers the breakpoints set before the program is loaded ("pending") without their line,
-- and nvim-dap, which finds a breakpoint's sign by its line, then gives every breakpoint of the
-- file the state of the last one: all but one stay marked rejected (✗), although they work.
-- The answer lists the breakpoints in the order they were asked for, so their lines are known.
dap.listeners.before.setBreakpoints["fill-lines"] = function(_, err, response, request)
  if err or not response or not request or not request.breakpoints then
    return
  end
  for i, bp in ipairs(response.breakpoints or {}) do
    if bp.line == nil and request.breakpoints[i] then
      bp.line = request.breakpoints[i].line
    end
  end
end

dap.adapters.python = {
  type = "executable",
  command = "python3",
  args = { "-m", "debugpy.adapter" },
}

----------------------------------------
-- configurations

local gdb_configs = {
  -- builds the project's debug target first (lua/build.lua), then debugs it
  require("build").dap_configuration(),
  {
    name = "Launch",
    type = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    env = require("build").debug_env,
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
  {
    name = "Launch file",
    type = "python",
    request = "launch",
    program = "${file}",
    console = "integratedTerminal",
  },
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
-- signs

for name, sign in pairs({
  DapBreakpoint = { text = "●", texthl = "DiagnosticError" },
  DapBreakpointCondition = { text = "◆", texthl = "DiagnosticWarn" },
  DapLogPoint = { text = "◉", texthl = "DiagnosticInfo" },
  DapStopped = { text = "→", texthl = "DiagnosticOk", linehl = "Visual" },
  DapBreakpointRejected = { text = "✗", texthl = "DiagnosticHint" },
}) do
  vim.fn.sign_define(name, sign)
end

----------------------------------------
-- keymaps

local map = function(lhs, rhs, desc, mode)
  vim.keymap.set(mode or "n", lhs, rhs, { desc = desc })
end

map("<leader>dc", dap.continue, "Continue / start")
map("<leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
map("<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Condition: "))
end, "Conditional breakpoint")
map("<leader>dl", function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log message: "))
end, "Log point")
map("<leader>di", dap.step_into, "Step into")
map("<leader>do", dap.step_over, "Step over")
map("<leader>dO", dap.step_out, "Step out")
map("<leader>dC", dap.run_to_cursor, "Run to cursor")
map("<leader>dr", dap.restart, "Restart")
map("<leader>dt", dap.terminate, "Terminate")
map("<leader>dL", dap.run_last, "Run last")
map("<leader>dv", panel.toggle, "Toggle debug windows")
map("<leader>dp", panel.toggle_lower, "Toggle the lower debug window")
map("<leader>dw", "<cmd>DapViewWatch<cr>", "Watch expression", { "n", "x" })
map("<leader>dk", function()
  require("dap.ui.widgets").hover()
end, "Hover evaluate", { "n", "x" })
