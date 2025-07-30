return {
	{
		"JuliaEditorSupport/julia-vim",
		lazy = false,
	},
	{
		"andreypopp/julia-repl-vim",
		lazy = false,
		config = function()
			-- Helper: Check if a line is "code" (not empty, not a comment)
			local function is_code_line(lnum)
				local line = vim.fn.getline(lnum)
				return line:match("^%s*$") == nil and not line:match("^%s*#")
			end

			-- Helper: Find next code line from a starting line
			local function next_code_line(start)
				local last = vim.api.nvim_buf_line_count(0)
				for lnum = start + 1, last do
					if is_code_line(lnum) then
						return lnum
					end
				end
				return last
			end

			-- Set up keybindings only in Julia files
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "julia",
				callback = function()
					-- Send line & move to next code
					vim.keymap.set("n", "<CR>", function()
						local cur_line = vim.api.nvim_win_get_cursor(0)[1]
						vim.cmd("JuliaREPLSend")
						local next_line = next_code_line(cur_line)
						vim.api.nvim_win_set_cursor(0, { next_line, 0 })
					end, { buffer = true, silent = true })

					-- Send visual selection
					vim.keymap.set("x", "<CR>", function()
						local start_line = vim.fn.line("v")
						local end_line = vim.fn.line(".")
						if start_line > end_line then
							start_line, end_line = end_line, start_line
						end
						vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
						vim.cmd(start_line .. "," .. end_line .. "JuliaREPLSendRegion")
						local next_line = next_code_line(end_line)
						vim.api.nvim_win_set_cursor(0, { next_line, 0 })
					end, { buffer = true, silent = true })

					-- Auto-connect new buffers to running REPL
					vim.schedule(function()
						vim.cmd("silent! JuliaREPLConnect 2345")
					end)

					-- <localleader>jq: Quit Julia and kill tmux pane
					vim.keymap.set("n", "<localleader>jq", function()
						os.execute("tmux send-keys -t ! C-d")
						vim.defer_fn(function()
							os.execute("tmux kill-pane -t !")
						end, 200)
					end, { desc = "Close Julia REPL and kill tmux pane", buffer = true })
				end,
			})

			-- Keymap: open tmux pane, run 'julia', then connect to REPL
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "julia", "markdown" },
				callback = function()
					vim.keymap.set("n", "<localleader>jf", function()
						os.execute(
							"tmux split-window -v 'bash -c \"julia -i /home/urtzi/.julia_scripts/nvjulia.jl; exec bash\"'"
						)
						vim.defer_fn(function()
							vim.cmd("JuliaREPLConnect 2345")
						end, 2000)
					end, { desc = "Start [j]ulia server and connect [f]ile", buffer = true })
				end,
			})
		end,
	},
}
