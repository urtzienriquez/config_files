local M = {}

-- Helper function to start REPL in tmux pane
function M.start_tmux_repl(repl_type)
	if not vim.env.TMUX then
		vim.notify("Not in tmux session", vim.log.levels.ERROR)
		return
	end

	local commands = {
		python = "python3",
		julia = "julia",
		matlab = "matlab -nodesktop -nosplash",
	}

	local cmd = commands[repl_type]
	if cmd then
		local tmux_cmd = string.format("tmux split-window -h -c '%s' %s", vim.fn.getcwd(), cmd)
		vim.fn.system(tmux_cmd)
		vim.notify("Started " .. repl_type .. " REPL in tmux pane", vim.log.levels.INFO)
	end
end

-- Helper function to close tmux REPL
function M.close_tmux_repl(repl_type)
	if not vim.env.TMUX then
		return
	end

	local exit_commands = {
		python = "exit()",
		julia = "exit()",
		matlab = "exit",
	}

	local exit_cmd = exit_commands[repl_type]
	if exit_cmd then
		-- Send exit command to last pane
		vim.fn.system(string.format("tmux send-keys -t '{last}' %s Enter", vim.fn.shellescape(exit_cmd)))
	end
end

return M
