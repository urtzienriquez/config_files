
local M = {}

-- Helper function to start REPL in tmux pane
function M.start_tmux_repl(repl_type)
	if not vim.env.TMUX then
		vim.notify("Not in tmux session", vim.log.levels.ERROR)
		return
	end

	local commands = {
		python = "ipython --no-confirm-exit --no-banner --quiet",
		julia = "julia",
		matlab = "matlab -nodesktop -nosplash",
	}

	local cmd = commands[repl_type]
	if cmd then
		local tmux_cmd = string.format("tmux split-window -h -c '%s' %s && tmux select-pane -l", vim.fn.getcwd(), cmd)
		vim.fn.system(tmux_cmd)
		vim.schedule(function()
			vim.notify("Started " .. repl_type .. " REPL in tmux pane", vim.log.levels.INFO)
		end)
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
		vim.fn.system(string.format("tmux send-keys -t '{last}' %s Enter", vim.fn.shellescape(exit_cmd)))
		vim.schedule(function()
			vim.notify("Closed " .. repl_type .. " REPL", vim.log.levels.INFO)
		end)
	end
end

-- Check if there's actually a REPL process running in the target tmux pane
function M.has_active_repl()
	if not vim.env.TMUX then
		return false
	end

	local target_pane = "{last}"
	local handle = io.popen("tmux display-message -t '" .. target_pane .. "' -p '#{pane_current_command}' 2>/dev/null")
	if not handle then
		return false
	end

	local current_command = handle:read("*l")
	handle:close()

	if not current_command then
		return false
	end

	local repl_commands = { "python", "python3", "julia", "MATLAB" }
	for _, repl_cmd in ipairs(repl_commands) do
		if current_command:find(repl_cmd) then
			return true
		end
	end

	return false
end

-- Helper function to synchronize nvim-repl working directories
function M.sync_working_directory()
	if not vim.env.TMUX then
		vim.notify("Not in tmux session", vim.log.levels.ERROR)
		return
	end

	if not M.has_active_repl() then
		vim.notify("No active REPL found", vim.log.levels.WARN)
		return
	end

	local cwd = vim.fn.getcwd()
	local target_pane = "{last}"

	local handle = io.popen("tmux display-message -t '" .. target_pane .. "' -p '#{pane_current_command}' 2>/dev/null")
	if not handle then
		vim.notify("Could not detect REPL type", vim.log.levels.ERROR)
		return
	end

	local current_command = handle:read("*l")
	handle:close()

	if not current_command then
		vim.notify("Could not detect REPL type", vim.log.levels.ERROR)
		return
	end

	local cd_command = nil
	local repl_type = nil

	if current_command:find("python") then
		cd_command = string.format("import os; os.chdir('%s')", cwd)
		repl_type = "Python"
	elseif current_command:find("julia") then
		cd_command = string.format('cd("%s")', cwd)
		repl_type = "Julia"
	elseif current_command:find("MATLAB") then
		cd_command = string.format("cd '%s'", cwd)
		repl_type = "MATLAB"
	else
		vim.notify("Unknown REPL type: " .. current_command, vim.log.levels.ERROR)
		return
	end

	vim.fn.system(string.format("tmux send-keys -t '%s' %s Enter", target_pane, vim.fn.shellescape(cd_command)))
	vim.schedule(function()
		vim.notify("Synced " .. repl_type .. " REPL to: " .. cwd, vim.log.levels.INFO)
	end)
end

return M
