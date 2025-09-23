-- Minimal yarepl.nvim configuration for Julia and Python
return {
	"milanglacier/yarepl.nvim",
	event = "VeryLazy",
	config = function()
		local yarepl = require("yarepl")
		yarepl.setup({
			-- How to open the REPL window - creates a horizontal split below with 15 lines
			wincmd = "vertical split",

			-- Configure specific REPLs
			metas = {
				-- Python with ipython (if available) or fallback to python
				python = {
					cmd = "python3",
					formatter = "trim_empty_lines",
				},
				-- Julia REPL
				julia = {
					cmd = "julia",
					formatter = "trim_empty_lines",
					source_syntax = "julia",
				},
				-- Matlab REPL
				matlab = {
					cmd = "matlab -nodesktop -nosplash",
					formatter = "trim_empty_lines",
					source_syntax = "matlab",
				},
			},
			-- Auto scroll to bottom after sending code
			scroll_to_bottom_after_sending = true,
			-- Close REPL window when process exits
			close_on_exit = true,
		})

		-- Custom commands that open/close REPL
		vim.api.nvim_create_user_command("REPLStartPython", function()
			vim.cmd("REPLStart python")
			vim.cmd("wincmd p") -- Jump back to previous window
		end, {})
		vim.api.nvim_create_user_command("REPLClosePython", function()
			vim.cmd("REPLClose python")
		end, {})

		vim.api.nvim_create_user_command("REPLStartJulia", function()
			vim.cmd("REPLStart julia")
			vim.cmd("wincmd p") -- Jump back to previous window
		end, {})
		vim.api.nvim_create_user_command("REPLCloseJulia", function()
			vim.cmd("REPLClose julia")
		end, {})

		vim.api.nvim_create_user_command("REPLStartMatlab", function()
			vim.cmd("REPLStart matlab")
			vim.cmd("wincmd p") -- Jump back to previous window
		end, {})
		vim.api.nvim_create_user_command("REPLCloseMatlab", function()
			vim.cmd("REPLExec exit()")
		end, {})

	end,
}
