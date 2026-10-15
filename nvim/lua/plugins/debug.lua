vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/rcarriga/nvim-dap-ui",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/rabrooks/nvim-dap-memview",
  "https://github.com/Jorenar/nvim-dap-disasm",
})

vim.api.nvim_create_autocmd("BufEnter", {
  once = true,
  callback = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    -- require("dap-memview").setup()
    require("dap-memview").setup({
      window = {
        position = "tab",
      },
    })

    -- Assembly / disassembly plugin.
    require("dap-disasm").setup({
      dapui_register = true,
      sign = "DapStopped",
      ins_before_memref = 16,
      ins_after_memref = 16,
      columns = {
        "address",
        "instructionBytes",
        "instruction",
      },
    })

    -- GDB with built-in DAP support.
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "--interpreter=dap" },
    }

    dap.defaults.fallback.terminal_win_cmd = "50vsplit new"

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

    -- Mixed C++ source and assembly window.
    local mixed_buf
    local mixed_win

    local function refresh_mixed_disasm(session)
      if not mixed_buf or not vim.api.nvim_buf_is_valid(mixed_buf) then
        return
      end

      if not session then
        return
      end

      session:request("evaluate", {
        expression = "disassemble /s",
        context = "repl",
      }, function(err, response)
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(mixed_buf) then
            return
          end

          local lines

          if err then
            lines = {
              "GDB disassembly error:",
              vim.inspect(err),
            }
          else
            local output = response and response.result or ""
            lines = vim.split(output, "\n", { plain = true })

            if #lines == 0 then
              lines = { "No disassembly output." }
            end
          end

          vim.bo[mixed_buf].modifiable = true
          vim.api.nvim_buf_set_lines(mixed_buf, 0, -1, false, lines)
          vim.bo[mixed_buf].modifiable = false
        end)
      end)
    end

    local function open_mixed_disasm()
      local session = dap.session()

      if not session then
        vim.notify("Start a debug session first.", vim.log.levels.WARN)
        return
      end

      if mixed_win and vim.api.nvim_win_is_valid(mixed_win) then
        vim.api.nvim_set_current_win(mixed_win)
      elseif mixed_buf and vim.api.nvim_buf_is_valid(mixed_buf) then
        vim.cmd("botright 60vsplit")
        vim.api.nvim_win_set_buf(0, mixed_buf)
        mixed_win = vim.api.nvim_get_current_win()
      else
        vim.cmd("botright 60vnew")
        mixed_buf = vim.api.nvim_get_current_buf()
        mixed_win = vim.api.nvim_get_current_win()

        vim.api.nvim_buf_set_name(mixed_buf, "DAP Mixed Disassembly")
        vim.bo[mixed_buf].buftype = "nofile"
        vim.bo[mixed_buf].bufhidden = "hide"
        vim.bo[mixed_buf].swapfile = false
        vim.bo[mixed_buf].filetype = "asm"
        vim.bo[mixed_buf].modifiable = false
      end

      refresh_mixed_disasm(session)
    end

    vim.api.nvim_create_user_command(
      "DapMixedDisasm",
      open_mixed_disasm,
      { desc = "Show mixed C++ source and assembly" }
    )

    -- Refresh when execution stops.
    dap.listeners.after.event_stopped["mixed_disasm"] = function(session)
      refresh_mixed_disasm(session)
    end

    -- Source-level debugging.
    vim.keymap.set("n", "<leader>ds", dap.continue, {
      desc = "Start / continue",
    })

    vim.keymap.set("n", "<leader>dp", dap.toggle_breakpoint, {
      desc = "Toggle breakpoint",
    })

    vim.keymap.set("n", "<leader>dc", dap.step_over, {
      desc = "Step over source line",
    })

    vim.keymap.set("n", "<leader>di", dap.step_into, {
      desc = "Step into source code",
    })

    vim.keymap.set("n", "<leader>do", dap.step_out, {
      desc = "Step out",
    })

    -- Assembly-level debugging.
    vim.keymap.set("n", "<leader>da", function()
      vim.cmd("DapDisasm")
    end, {
      desc = "Open disassembly view",
    })

    vim.keymap.set("n", "<leader>dC", function()
      dap.step_over({ granularity = "instruction" })
    end, {
      desc = "Step over one machine instruction",
    })

    vim.keymap.set("n", "<leader>dI", function()
      dap.step_into({ granularity = "instruction" })
    end, {
      desc = "Step into one machine instruction",
    })

    -- Mixed source and assembly.
    vim.keymap.set("n", "<leader>dM", open_mixed_disasm, {
      desc = "Show mixed source and assembly",
    })

    vim.keymap.set("n", "<leader>du", dapui.toggle, {
      desc = "Toggle debugger UI",
    })

    vim.keymap.set({ "n", "v" }, "<leader>de", function()
      dapui.eval(nil, { enter = true })
    end, {
      desc = "Evaluate expression",
    })

    vim.keymap.set("n", "<leader>dq", dap.terminate, {
      desc = "Terminate debugging",
    })

    vim.keymap.set("n", "<leader>dr", dap.restart, {
      desc = "Restart debugging",
    })

    vim.keymap.set("n", "<leader>df", function()
      dapui.float_element(nil, {
        enter = true,
        position = "center",
        width = math.floor(vim.o.columns * 0.85),
        height = math.floor(vim.o.lines * 0.80),
      })
    end, {
      desc = "Float a DAP UI element",
    })

    vim.keymap.set("n", "<leader>dm", function()
      require("dap-memview").open(vim.fn.expand("<cexpr>"))
    end, { desc = "Debug: Memory view (expression under cursor)" })
  end,
})
