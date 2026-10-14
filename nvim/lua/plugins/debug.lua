vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/rcarriga/nvim-dap-ui",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/rabrooks/nvim-dap-memview",
})

vim.api.nvim_create_autocmd("BufEnter", {
  once = true,
  callback = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    require("dap-memview").setup()

    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "--interpreter=dap" },
    }

    -- Debug the executable produced by <leader>cc.
    dap.configurations.cpp = {
      {
        name = "Debug current C++ file",
        type = "gdb",
        request = "launch",
        program = function()
          return vim.fn.expand("%:p:r")
        end,
        cwd = "${fileDirname}",
        stopOnEntry = false,
        args = {},
      },
    }

    dap.configurations.c = dap.configurations.cpp

    -- Automatically show the debugger UI.
    dap.listeners.after.event_initialized["debug_ui"] = function()
      dapui.open()
    end

    -- keymaps
    vim.keymap.set("n", "<leader>ds", dap.continue, {
      desc = "start / continue",
    })
    vim.keymap.set("n", "<leader>dp", dap.toggle_breakpoint, {
      desc = "toggle breakpoint",
    })
    vim.keymap.set("n", "<leader>dc", dap.step_over, {
      desc = "step over",
    })
    vim.keymap.set("n", "<leader>di", dap.step_into, {
      desc = "step into",
    })
    vim.keymap.set("n", "<leader>do", dap.step_out, {
      desc = "step out",
    })
    vim.keymap.set("n", "<leader>du", dapui.toggle, {
      desc = "toggle UI",
    })
    vim.keymap.set({ "n", "v" }, "<leader>de", function()
      dapui.eval(nil, { enter = true })
    end, {
      desc = "evaluate expression",
    })
    vim.keymap.set("n", "<leader>dq", dap.terminate, {
      desc = "terminate",
    })
    vim.keymap.set("n", "<leader>dr", dap.restart, {
      desc = "restart",
    })

    -- Inspect raw memory.
    vim.keymap.set("n", "<leader>dm", function()
      vim.ui.input({ prompt = "Memory expression: " }, function(expr)
        if expr and expr ~= "" then
          require("dap-memview").open(expr)
        end
      end)
    end, {
      desc = "inspect raw memory",
    })
  end,
})
