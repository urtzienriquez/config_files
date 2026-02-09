local M = {}

-- Helper function to escape strings for different REPL types
local function escape_for_repl(path, repl_type)
	if repl_type == "python" then
		-- Python: escape backslashes and single quotes
		return path:gsub("\\", "\\\\"):gsub("'", "\\'")
	elseif repl_type == "julia" then
		-- Julia: escape backslashes and double quotes
		return path:gsub("\\", "\\\\"):gsub('"', '\\"')
	elseif repl_type == "matlab" then
		-- MATLAB: escape single quotes by doubling them
		return path:gsub("'", "''")
	end
	return path
end

-- Get installed Julia channels from juliaup
local function get_julia_versions()
	local handle = io.popen("juliaup status 2>/dev/null")
	if not handle then
		return {}
	end

	local output = handle:read("*a")
	handle:close()

	local channels = {}
	local in_table = false

	-- Parse juliaup status output
	for line in output:gmatch("[^\r\n]+") do
		-- Check if we're at the header line
		if line:match("Default%s+Channel") then
			in_table = true
		-- If we're in the table and the line has content
		elseif in_table and not line:match("^%-+$") and not line:match("^%s*$") then
			-- Extract the channel name (second column)
			-- Format: "       *  1.11     1.11.9+0.x64.linux.gnu"
			-- or:     "          release  1.12.4+0.x64.linux.gnu"
			local channel = line:match("%s+%*?%s+(%S+)%s+")
			if channel then
				table.insert(channels, channel)
			end
		end
	end

	-- If no channels found, try to at least get the default
	if #channels == 0 then
		local default_handle = io.popen("julia +default --version 2>/dev/null")
		if default_handle then
			local default_output = default_handle:read("*a")
			default_handle:close()

			if default_output:match("julia version") then
				table.insert(channels, "default")
			end
		end
	end

	return channels
end

-- Helper function to start REPL in tmux pane with version selection for Julia
function M.start_tmux_repl_with_version(repl_type)
	if not vim.env.TMUX then
		vim.notify("Not in tmux session", vim.log.levels.ERROR)
		return
	end

	if repl_type == "julia" then
		local channels = get_julia_versions()

		if #channels == 0 then
			-- Debug: show the actual output from juliaup
			local debug_handle = io.popen("juliaup status 2>&1")
			local debug_output = debug_handle and debug_handle:read("*a") or "Could not run juliaup"
			if debug_handle then
				debug_handle:close()
			end

			vim.notify("No Julia channels found. juliaup status output:\n" .. debug_output, vim.log.levels.WARN)

			-- Try to start default julia anyway
			vim.notify("Attempting to start default Julia...", vim.log.levels.INFO)
			M.start_tmux_repl("julia")
			return
		elseif #channels == 1 then
			-- Only one channel, use it directly
			local cmd = string.format("julia +%s", channels[1])
			local tmux_cmd =
				string.format("tmux split-window -h -c '%s' %s && tmux select-pane -l", vim.fn.getcwd(), cmd)
			vim.fn.system(tmux_cmd)
			vim.schedule(function()
				vim.notify("Started Julia +" .. channels[1] .. " REPL in tmux pane", vim.log.levels.INFO)
			end)
		else
			-- Multiple channels, show picker
			local fzf = require("fzf-lua")

			fzf.fzf_exec(channels, {
				prompt = "Julia Channel> ",
				winopts = {
					title = " Select Julia Channel ",
					height = 0.4,
					width = 0.5,
				},
				actions = {
					["default"] = function(selected)
						if #selected == 0 then
							return
						end

						local channel = selected[1]
						local cmd = string.format("julia +%s", channel)
						local tmux_cmd = string.format(
							"tmux split-window -h -c '%s' %s && tmux select-pane -l",
							vim.fn.getcwd(),
							cmd
						)
						vim.fn.system(tmux_cmd)
						vim.schedule(function()
							vim.notify("Started Julia +" .. channel .. " REPL in tmux pane", vim.log.levels.INFO)
						end)
					end,
				},
			})
		end
	else
		-- Fall back to regular start for other REPLs
		M.start_tmux_repl(repl_type)
	end
end

-- Helper function to start REPL in tmux pane (original function)
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

	-- Handle empty string case
	if not current_command or current_command == "" then
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

	if not current_command or current_command == "" then
		vim.notify("Could not detect REPL type", vim.log.levels.ERROR)
		return
	end

	local cd_command = nil
	local repl_type = nil

	if current_command:find("python") then
		local escaped_path = escape_for_repl(cwd, "python")
		cd_command = string.format("import os; os.chdir('%s')", escaped_path)
		repl_type = "Python"
	elseif current_command:find("julia") then
		local escaped_path = escape_for_repl(cwd, "julia")
		cd_command = string.format('cd("%s")', escaped_path)
		repl_type = "Julia"
	elseif current_command:find("MATLAB") then
		local escaped_path = escape_for_repl(cwd, "matlab")
		cd_command = string.format("cd '%s'", escaped_path)
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
