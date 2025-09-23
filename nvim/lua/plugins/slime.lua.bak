return {
	{
		"jpalardy/vim-slime",
		lazy = false,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			-- ADDED: Set up filetype detection for .jmd files
			vim.filetype.add({
				extension = {
					jmd = "markdown", -- Set .jmd files to use markdown filetype
				},
			})
			vim.g.slime_target = "tmux"
			-- Use {right} or remove target_pane to be prompted
			vim.g.slime_default_config = { socket_name = "default", target_pane = "{right}" }
			vim.g.slime_dont_ask_default = 1
			vim.g.slime_python_ipython = 0 -- Disable IPython-specific features for standard Python
			vim.g.slime_bracketed_paste = 0 -- Disable bracketed paste globally
			-- Bracketed paste wrapper
			local function bracketed_wrap(text, filetype)
				if filetype == "python" then
					-- For Python, never use bracketed paste - just return the text as-is
					return text
				end
				return "\027[200~" .. text .. "\027[201~"
			end
			-- REPL commands with their actual process names for detection
			local repls = {
				python = "python3",
				julia = "julia",
				matlab = "matlab -nodesktop -nosplash",
			}
			-- Map REPL commands to their actual process names in tmux
			local repl_process_names = {
				python = "python3",
				julia = "julia",
				matlab = "matlab",
			}
			--- Send with highlighting (using default vim highlight like yank)
			local function send_with_highlight(text, start_line, end_line)
				local ns = vim.api.nvim_create_namespace("slime_highlight")
				for i = start_line - 1, end_line - 1 do
					local line_text = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1] or ""
					local line_length = #line_text
					if line_length > 0 then
						vim.api.nvim_buf_set_extmark(0, ns, i, 0, {
							end_col = line_length,
							hl_group = "IncSearch",
						})
					else
						-- For empty lines, just highlight the line break
						vim.api.nvim_buf_set_extmark(0, ns, i, 0, {
							end_col = 0,
							hl_group = "IncSearch",
							hl_eol = true, -- Highlight end of line
						})
					end
				end
				vim.defer_fn(function()
					vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
				end, 150)
				-- Special handling for Python
				if vim.bo.filetype == "python" or (vim.bo.filetype == "markdown" and text:match("```python")) then
					-- Check if this is a complete block with proper indentation
					local lines = vim.split(text:gsub("\n$", ""), "\n") -- Remove final newline for processing
					local has_indented_block = false
					-- Check if we have an indented block
					for i, line in ipairs(lines) do
						if i > 1 and line:match("^%s+") then
							has_indented_block = true
							break
						end
					end
					if has_indented_block then
						-- For indented blocks, send as complete text with proper formatting
						local formatted_text = table.concat(lines, "\n") .. "\n\n" -- Add two newlines at end
						vim.fn["slime#send"](formatted_text)
					else
						-- Single line or simple statements
						vim.fn["slime#send"](text)
					end
					return
				end
				-- Default behavior for other languages
				local wrapped = bracketed_wrap(text, vim.bo.filetype)
				vim.fn["slime#send"](wrapped)
			end
			-- Check if cursor is at start of a code block
			local function is_at_block_start()
				local buf = vim.api.nvim_get_current_buf()
				local row = vim.api.nvim_win_get_cursor(0)[1] - 1
				local filetype = vim.bo.filetype
				local lang_map = {
					python = "python",
					julia = "julia",
					matlab = "matlab",
				}
				local lang = lang_map[filetype]
				if not lang then
					return false
				end
				local ok, parser = pcall(vim.treesitter.get_parser, buf, lang)
				if not ok or not parser then
					return false
				end
				local ok2, trees = pcall(parser.parse, parser)
				if not ok2 or not trees or #trees == 0 then
					return false
				end
				local root = trees[1]:root()
				-- Block types that should be sent as whole units
				local block_types = {
					function_definition = true,
					async_function_definition = true,
					["function"] = true,
					for_statement = true,
					while_statement = true,
					if_statement = true,
					class_definition = true,
					struct_definition = true,
					module_definition = true,
					begin_block = true,
					let_block = true,
					with_statement = true,
					try_statement = true,
				}
				-- Find if current line starts a block
				local function check_node(node)
					if not node then
						return false
					end
					for child in node:iter_children() do
						if block_types[child:type()] then
							local start_row = child:range()
							if start_row == row then
								return true
							end
						end
						if check_node(child) then
							return true
						end
					end
					return false
				end
				return check_node(root)
			end
			-- Get textobject range safely
			local function get_textobject_range(textobj)
				-- Clear any existing visual selection and marks
				vim.cmd("normal! \27") -- Escape to ensure normal mode
				local saved_pos = vim.api.nvim_win_get_cursor(0)
				-- Try to select textobject
				local ok = pcall(function()
					vim.cmd("normal! v" .. textobj)
				end)
				if not ok then
					vim.api.nvim_win_set_cursor(0, saved_pos)
					return nil
				end
				-- Get selection bounds immediately
				local start_pos = vim.fn.getpos("'<")
				local end_pos = vim.fn.getpos("'>")
				-- Clear visual mode and restore position
				vim.cmd("normal! \27")
				vim.api.nvim_win_set_cursor(0, saved_pos)
				-- Validate selection - ensure it's a real textobject selection
				local current_line = vim.fn.line(".")
				if
					start_pos[2] > 0
					and end_pos[2] > 0
					and (start_pos[2] ~= end_pos[2] or start_pos[3] ~= end_pos[3])
					-- Ensure the selection includes or is near the current line
					and (current_line >= start_pos[2] and current_line <= end_pos[2])
				then
					return {
						start_line = math.min(start_pos[2], end_pos[2]),
						end_line = math.max(start_pos[2], end_pos[2]),
					}
				end
				return nil
			end
			-- FIXED: Helper function to detect current language in markdown files
			local function get_markdown_language()
				-- For non-markdown files, check if it's a known markdown variant
				if vim.bo.filetype ~= "markdown" then
					return vim.bo.filetype
				end
				-- First check file extension for default language
				local filename = vim.fn.expand("%:t")
				local default_lang = nil
				if filename:match("%.qmd$") or filename:match("%.Qmd$") then -- ADDED .qmd support
					default_lang = "python" -- Default to python for Quarto
				elseif filename:match("%.jmd$") then -- ADDED .jmd support
					default_lang = "julia"
				end
				-- If we have a default language, look for code fences
				if default_lang then
					local line = vim.fn.line(".")
					-- Look backwards for code fence
					for i = line, 1, -1 do
						local text = vim.fn.getline(i)
						local lang = text:match("^```(%w+)")
						if lang then
							-- Use the fence language if it matches our supported languages
							if lang == "python" or lang == "julia" or lang == "matlab" then
								return lang
							end
						elseif text:match("^```%s*$") then
							-- Empty code fence, use file default
							return default_lang
						end
					end
					-- No code fence found, use file default
					return default_lang
				end
				-- Fallback for other markdown files
				local line = vim.fn.line(".")
				for i = line, 1, -1 do
					local text = vim.fn.getline(i)
					local lang = text:match("^```(%w+)")
					if lang then
						return lang
					end
				end
				return "markdown" -- Final fallback
			end
			-- Python detection
			local function is_python_block_start()
				local line = vim.api.nvim_get_current_line()
				return line:match("^%s*def%s+") -- function
					or line:match("^%s*class%s+") -- class
					or line:match("^%s*if%s+.*:") -- if statement
					or line:match("^%s*elif%s+.*:") -- elif
					or line:match("^%s*else%s*:") -- else
					or line:match("^%s*for%s+.*:") -- for loop
					or line:match("^%s*while%s+.*:") -- while loop
					or line:match("^%s*with%s+.*:") -- with statement
					or line:match("^%s*try%s*:") -- try block
					or line:match("^%s*except.*:") -- except block
					or line:match("^%s*finally%s*:") -- finally block
			end
			-- Julia detection - FIXED to handle single-line constructs properly
			local function is_julia_block_start()
				local line = vim.api.nvim_get_current_line()
				-- Multi-line blocks that need special handling
				local is_multiline_block = line:match("^%s*function%s+") -- function
					or line:match("^%s*macro%s+") -- macro
					or line:match("^%s*struct%s+") -- struct (multiline)
					or line:match("^%s*mutable%s+struct%s+") -- mutable struct
					or line:match("^%s*module%s+") -- module
					or line:match("^%s*if%s+") -- if statement
					or line:match("^%s*for%s+") -- for loop
					or line:match("^%s*while%s+") -- while loop
					or line:match("^%s*try%s*$") -- try block
					or line:match("^%s*begin%s*$") -- begin block
					or line:match("^%s*let%s+") -- let block
					or line:match("^%s*quote%s*$") -- quote block
				-- Multi-line abstract/primitive types (without 'end' on same line)
				local is_multiline_type = (line:match("^%s*abstract%s+type%s+") and not line:match("end%s*$"))
					or (line:match("^%s*primitive%s+type%s+") and not line:match("end%s*$"))
				-- Return true only for constructs that should be treated as blocks
				return is_multiline_block or is_multiline_type
			end
			-- Helper function to check if Julia line is a single-line construct
			local function is_julia_single_line()
				local line = vim.api.nvim_get_current_line()
				return line:match("^%s*abstract%s+type%s+.*end%s*$") -- abstract type Animal end
					or line:match("^%s*primitive%s+type%s+.*end%s*$") -- primitive type
					or (line:match("^%s*const%s+") and not line:match("=.*function")) -- const declarations
					or (line:match("^%s*[%w_!]+%s*=") and not line:match("function") and not line:match("->")) -- simple assignments
			end
			-- Matlab detection
			local function is_matlab_block_start()
				local line = vim.api.nvim_get_current_line()
				return line:match("^%s*function%s+") -- function
					or line:match("^%s*classdef%s+") -- class definition
					or line:match("^%s*methods%s*") -- methods block
					or line:match("^%s*properties%s*") -- properties block
					or line:match("^%s*events%s*") -- events block
					or line:match("^%s*enumeration%s*") -- enumeration block
					or line:match("^%s*if%s+") -- if statement
					or line:match("^%s*for%s+") -- for loop
					or line:match("^%s*while%s+") -- while loop
					or line:match("^%s*switch%s+") -- switch statement
					or line:match("^%s*try%s*$") -- try block
					or line:match("^%s*parfor%s+") -- parallel for loop
			end
			-- Generic block range detection using indentation
			local function get_indented_block_range()
				local start_line = vim.fn.line(".")
				local start_text = vim.api.nvim_get_current_line()
				local current_filetype = get_markdown_language()
				-- Special handling for Python - make sure we get the complete for loop
				if current_filetype == "python" then
					-- Get the indentation of the starting line
					local start_indent = start_text:match("^(%s*)")
					local start_indent_len = #start_indent
					-- Find the end of the block by looking for lines with same or less indentation
					local end_line = start_line
					for line_num = start_line + 1, vim.fn.line("$") do
						local line_text = vim.fn.getline(line_num)
						-- Skip completely empty lines
						if line_text:match("^%s*$") then
							-- Continue, but don't update end_line yet
						else
							local line_indent = line_text:match("^(%s*)")
							local line_indent_len = #line_indent
							-- If this line has same or less indentation than start, we've found the end
							if line_indent_len <= start_indent_len then
								-- Check if it's a continuation (elif, else, except, finally)
								if
									line_text:match("^%s*elif%s+")
									or line_text:match("^%s*else%s*:")
									or line_text:match("^%s*except")
									or line_text:match("^%s*finally%s*:")
								then
									-- This is a continuation, keep going
								else
									-- End of block found
									break
								end
							end
						end
						end_line = line_num
					end
					return { start_line = start_line, end_line = end_line }
				end
				-- FIXED: Special handling for Julia/Matlab to include 'end' keyword
				if current_filetype == "julia" or current_filetype == "matlab" then
					local start_indent = start_text:match("^(%s*)")
					local start_indent_len = #start_indent
					local end_line = start_line
					-- Look for the matching 'end' keyword
					for line_num = start_line + 1, vim.fn.line("$") do
						local line_text = vim.fn.getline(line_num)
						-- Skip empty lines
						if not line_text:match("^%s*$") then
							local line_indent = line_text:match("^(%s*)")
							local line_indent_len = #line_indent
							-- Found 'end' at the same indentation level
							if line_indent_len == start_indent_len and line_text:match("^%s*end[%s;]*$") then
								end_line = line_num
								break
							end
							-- If we find something at same or less indentation that's not 'end', stop
							if line_indent_len <= start_indent_len then
								-- Check for continuations
								local is_continuation = false
								if current_filetype == "julia" then
									is_continuation = line_text:match("^%s*elseif%s+")
										or line_text:match("^%s*else%s*$")
										or line_text:match("^%s*catch")
										or line_text:match("^%s*finally")
								elseif current_filetype == "matlab" then
									is_continuation = line_text:match("^%s*elseif%s+")
										or line_text:match("^%s*else%s*$")
										or line_text:match("^%s*case%s+")
										or line_text:match("^%s*otherwise%s*$")
										or line_text:match("^%s*catch")
								end
								if not is_continuation then
									-- We've gone too far, previous line was the end
									end_line = line_num - 1
									break
								end
							end
						end
						end_line = line_num
					end
					return { start_line = start_line, end_line = end_line }
				end
				-- Original logic for other languages
				local start_indent = start_text:match("^(%s*)")
				local start_indent_len = #start_indent
				local end_line = start_line
				for line_num = start_line + 1, vim.fn.line("$") do
					local line_text = vim.fn.getline(line_num)
					-- Skip empty lines
					if not line_text:match("^%s*$") then
						local line_indent = line_text:match("^(%s*)")
						local line_indent_len = #line_indent
						-- If this line has same or less indentation than start, we've found the end
						if line_indent_len <= start_indent_len then
							break
						end
					end
					end_line = line_num
				end
				return { start_line = start_line, end_line = end_line }
			end
			-- Main smart send function
			local function smart_send(mode)
				local range
				local current_filetype = get_markdown_language()
				if mode == "v" then
					-- Visual mode: capture selection WHILE in visual mode
					-- Get the actual visual selection bounds
					local start_line = vim.fn.line("v") -- start of visual selection
					local end_line = vim.fn.line(".") -- current cursor position
					-- Ensure proper order
					if start_line > end_line then
						start_line, end_line = end_line, start_line
					end
					range = { start_line = start_line, end_line = end_line }
					-- Now exit visual mode
					vim.cmd("normal! \27")
				else
					-- Normal mode: language-specific detection
					local range_found = false
					if current_filetype == "python" then
						if is_python_block_start() then
							range = get_indented_block_range()
							range_found = (range ~= nil)
						end
					elseif current_filetype == "julia" then
						-- Check for single-line constructs first
						if is_julia_single_line() then
							-- Send just the current line for single-line constructs
							local line = vim.fn.line(".")
							range = { start_line = line, end_line = line }
							range_found = true
						elseif is_julia_block_start() then
							range = get_indented_block_range()
							range_found = (range ~= nil)
						end
					elseif current_filetype == "matlab" then
						if is_matlab_block_start() then
							range = get_indented_block_range()
							range_found = (range ~= nil)
						end
					end
					-- Fallback to treesitter if language-specific detection didn't work
					if not range_found and is_at_block_start() then
						range = get_textobject_range("af") or get_textobject_range("ab")
					end
					-- Final fallback to current line
					if not range then
						local line = vim.fn.line(".")
						range = { start_line = line, end_line = line }
					end
				end
				-- Send the text
				if range then
					local lines = vim.api.nvim_buf_get_lines(0, range.start_line - 1, range.end_line, false)
					local text = table.concat(lines, "\n") .. "\n"
					send_with_highlight(text, range.start_line, range.end_line)
					-- FIXED: Make cursor movement optional and safer
					if mode ~= "v" and vim.g.slime_move_cursor ~= 0 and range.end_line < vim.fn.line("$") then
						vim.api.nvim_win_set_cursor(0, { range.end_line + 1, 0 })
					end
				end
			end
			-- Utility functions
			local function send_cell()
				local delimiter = vim.b.slime_cell_delimiter or "# %%"
				local start = vim.fn.search(delimiter, "bnW")
				start = start == 0 and 1 or start + 1
				local end_line = vim.fn.search(delimiter, "nW")
				end_line = end_line == 0 and vim.fn.line("$") or end_line - 1
				local lines = vim.api.nvim_buf_get_lines(0, start - 1, end_line, false)
				local text = table.concat(lines, "\n") .. "\n"
				send_with_highlight(text, start, end_line)
				-- FIXED: Make cursor movement conditional
				if vim.g.slime_move_cursor ~= 0 and end_line < vim.fn.line("$") then
					vim.api.nvim_win_set_cursor(0, { end_line + 2, 0 })
				end
			end
			-- change dir in repl
			local function sync_working_directory()
				local current_dir = vim.fn.getcwd()
				-- Get the appropriate language
				local ft
				if vim.bo.filetype == "markdown" then
					ft = get_markdown_language() -- Use your existing function for markdown
				else
					-- For direct language files, use filetype directly
					ft = vim.bo.filetype
				end
				local cd_commands = {
					python = string.format("import os; os.chdir('%s')", current_dir),
					julia = string.format('cd("%s")', current_dir),
					matlab = string.format("cd '%s'", current_dir),
				}
				local cmd = cd_commands[ft]
				if cmd then
					vim.fn["slime#send"](cmd .. "\n")
					vim.notify("Synced REPL directory to: " .. current_dir, vim.log.levels.INFO)
				else
					vim.notify("No directory sync command for filetype: " .. tostring(ft), vim.log.levels.WARN)
				end
			end
			-- ENHANCED: Render functions for markdown documents
			-- Render Julia Markdown (.jmd) using Weave.jl
			local function render_jmarkdown()
				local filename = vim.fn.expand("%:p")
				if not filename:match("%.jmd$") then
					return -- silently do nothing if it's not a .jmd file
				end
				vim.cmd("write") -- Save before rendering
				local julia_cmd = string.format('using Weave; weave("%s")', filename)
				local cmd = { "julia", "-e", julia_cmd }
				-- Run silently without notifications
				vim.fn.jobstart(cmd, { detach = true })
			end
			-- Render Quarto document (.qmd or .Qmd)
			local function render_quarto()
				local filename = vim.fn.expand("%:p")
				if not filename:match("%.qmd$") and not filename:match("%.Qmd$") then
					return -- silently do nothing if it's not a .qmd file
				end
				vim.cmd("write") -- Save before rendering
				local cmd = { "quarto", "render", filename }
				-- Run silently without notifications
				vim.fn.jobstart(cmd, { detach = true })
			end
			-- Language-specific wrappers
			local function open_python_repl()
				local cmd = repls["python"]
				if not cmd then
					vim.notify("No REPL for Python", vim.log.levels.WARN)
					return
				end
				-- Split a pane and run the command
				vim.fn.system("tmux split-window -d -h '" .. cmd .. "'")
				-- Find the most recently created pane (highest %number)
				local panes_output = vim.fn.system("tmux list-panes -F '#{pane_id} #{pane_current_command}'")
				local max_num, max_id = -1, nil
				for line in panes_output:gmatch("[^\r\n]+") do
					local id = line:match("^(%%[%d]+)")
					if id then
						local num = tonumber(id:match("%%(%d+)"))
						if num and num > max_num then
							max_num, max_id = num, id
						end
					end
				end
				if max_id then
					vim.notify("Opened Python REPL in pane " .. max_id, vim.log.levels.INFO)
				else
					vim.notify("Opened Python REPL (pane id not detected)", vim.log.levels.WARN)
				end
			end

			local function open_julia_repl()
				local cmd = repls["julia"]
				if not cmd then
					vim.notify("No REPL for Julia", vim.log.levels.WARN)
					return
				end
				-- Split a pane and run the command
				vim.fn.system("tmux split-window -d -h '" .. cmd .. "'")
				-- Find the most recently created pane (highest %number)
				local panes_output = vim.fn.system("tmux list-panes -F '#{pane_id} #{pane_current_command}'")
				local max_num, max_id = -1, nil
				for line in panes_output:gmatch("[^\r\n]+") do
					local id = line:match("^(%%[%d]+)")
					if id then
						local num = tonumber(id:match("%%(%d+)"))
						if num and num > max_num then
							max_num, max_id = num, id
						end
					end
				end
				if max_id then
					vim.notify("Opened Julia REPL in pane " .. max_id, vim.log.levels.INFO)
				else
					vim.notify("Opened Julia REPL (pane id not detected)", vim.log.levels.WARN)
				end
			end

			local matlab_pane_id = nil

			local function open_matlab_repl()
				local cmd = repls["matlab"]
				if not cmd then
					vim.notify("No REPL for MATLAB", vim.log.levels.WARN)
					return
				end
				-- Split a pane and run MATLAB
				vim.fn.system("tmux split-window -d -h '" .. cmd .. "'")

				-- Find the most recently created pane
				local panes_output = vim.fn.system("tmux list-panes -F '#{pane_id} #{pane_current_command}'")
				local max_num, max_id = -1, nil
				for line in panes_output:gmatch("[^\r\n]+") do
					local id = line:match("^(%%[%d]+)")
					if id then
						local num = tonumber(id:match("%%(%d+)"))
						if num and num > max_num then
							max_num, max_id = num, id
						end
					end
				end

				if max_id then
					matlab_pane_id = max_id
					vim.notify("Opened MATLAB REPL in pane " .. max_id, vim.log.levels.INFO)
				else
					vim.notify("Opened MATLAB REPL (pane id not detected)", vim.log.levels.WARN)
				end
			end

			-- Generic open depending on buffer (still supported)
			local function open_repl()
				local ft = get_markdown_language()
				if ft == "python" then
					open_python_repl()
				elseif ft == "julia" then
					open_julia_repl()
				elseif ft == "matlab" then
					open_matlab_repl()
				else
					vim.notify("No REPL for filetype: " .. ft, vim.log.levels.WARN)
				end
			end

			-- Set cursor movement preference (0 = don't move, 1 = move)
			vim.g.slime_move_cursor = 1 -- Set to 1 to move cursor down after sending
			-- ========================================
			-- KEYBINDINGS (centralized for easy editing)
			-- ========================================
			-- Global keymaps - REPL opening
			vim.keymap.set("n", "<leader>op", open_python_repl, { desc = "Open Python REPL" })
			vim.keymap.set("n", "<leader>oj", open_julia_repl, { desc = "Open Julia REPL" })
			vim.keymap.set("n", "<leader>om", open_matlab_repl, { desc = "Open MATLAB REPL" })

			-- Quick quit keymaps for specific REPLs
			--
			vim.keymap.set("n", "qp", function()
				-- Close Python REPL specifically
				local panes_output = vim.fn.system("tmux list-panes -F '#{pane_id} #{pane_current_command}'")
				for line in panes_output:gmatch("[^\r\n]+") do
					if line:match("python3?") then
						local pane_id = line:match("^(%%[%d]+)")
						if pane_id then
							vim.fn.system("tmux kill-pane -t " .. pane_id)
							vim.notify("Closed Python REPL (pane " .. pane_id .. ")", vim.log.levels.INFO)
							return
						end
					end
				end
				vim.notify("No Python REPL found to close", vim.log.levels.WARN)
			end, { desc = "Quit Python REPL" })

			vim.keymap.set("n", "qj", function()
				-- Close Julia REPL specifically
				local panes_output = vim.fn.system("tmux list-panes -F '#{pane_id} #{pane_current_command}'")
				for line in panes_output:gmatch("[^\r\n]+") do
					if line:match("julia") then
						local pane_id = line:match("^(%%[%d]+)")
						if pane_id then
							vim.fn.system("tmux kill-pane -t " .. pane_id)
							vim.notify("Closed Julia REPL (pane " .. pane_id .. ")", vim.log.levels.INFO)
							return
						end
					end
				end
				vim.notify("No Julia REPL found to close", vim.log.levels.WARN)
			end, { desc = "Quit Julia REPL" })

			vim.keymap.set("n", "qm", function()
				if matlab_pane_id then
					vim.fn.system("tmux kill-pane -t " .. matlab_pane_id)
					vim.notify("Closed MATLAB REPL (pane " .. matlab_pane_id .. ")", vim.log.levels.INFO)
					matlab_pane_id = nil
				else
					vim.notify("No MATLAB REPL found to close", vim.log.levels.WARN)
				end
			end, { desc = "Quit MATLAB REPL" })

			-- Add a keymap for manual sync of directory (cd)
			vim.keymap.set("n", "<leader>sd", sync_working_directory, { desc = "Sync REPL directory" })
			-- ENHANCED: Global render keybinds with better file type detection
			vim.keymap.set("n", "<leader>rr", function()
				local filename = vim.fn.expand("%:t")
				if filename:match("%.jmd$") then
					render_jmarkdown()
				elseif filename:match("%.qmd$") or filename:match("%.Qmd$") then
					render_quarto()
				else
					vim.notify("Not a renderable markdown file (.jmd or .qmd)", vim.log.levels.WARN)
				end
			end, { desc = "Render markdown document" })
			-- FIXED: Language-specific keymaps - Added quarto filetypes
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "python", "julia", "matlab", "markdown", "quarto" },
				callback = function()
					local current_ft = vim.bo.filetype
					if current_ft == "matlab" then
						vim.b.slime_cell_delimiter = "%% "
					else
						vim.b.slime_cell_delimiter = "# %%"
					end
					local opts = { buffer = true, silent = true }
					-- Main smart send - Enter key
					vim.keymap.set("n", "<Enter>", function()
						smart_send("n")
					end, vim.tbl_extend("force", opts, { desc = "Smart send" }))
					vim.keymap.set("v", "<Enter>", function()
						smart_send("v")
					end, vim.tbl_extend("force", opts, { desc = "Send selection" }))
					-- -- Alternative keybinds
					-- vim.keymap.set("n", "<C-c><C-c>", function()
					-- 	smart_send("n")
					-- end, vim.tbl_extend("force", opts, { desc = "Smart send" }))
					-- vim.keymap.set("v", "<C-c><C-c>", function()
					-- 	smart_send("v")
					-- end, vim.tbl_extend("force", opts, { desc = "Send selection" }))
					-- Send cell
					vim.keymap.set("n", "<leader>sx", send_cell, vim.tbl_extend("force", opts, { desc = "Send cell" }))
					-- Send buffer
					vim.keymap.set(
						"n",
						"<leader>sb",
						"<Cmd>%SlimeSend<CR>",
						vim.tbl_extend("force", opts, { desc = "Send buffer" })
					)
					-- ENHANCED: Render keybinds for markdown files with file-specific functions
					local filename = vim.fn.expand("%:t")
					if filename:match("%.jmd$") then
						vim.keymap.set(
							"n",
							"<leader>rr",
							render_jmarkdown,
							vim.tbl_extend("force", opts, { desc = "Render Julia Markdown" })
						)
					elseif filename:match("%.qmd$") or filename:match("%.Qmd$") then
						vim.keymap.set(
							"n",
							"<leader>rr",
							render_quarto,
							vim.tbl_extend("force", opts, { desc = "Render Quarto" })
						)
					end
				end,
			})
			-- FIXED: Auto-start REPL if environment variable is set - Added .qmd support
			if vim.env.SLIME_AUTO_START == "true" then
				vim.api.nvim_create_autocmd("BufEnter", {
					pattern = { "*.py", "*.jl", "*.m", "*.qmd", "*.Qmd", "*.jmd" },
					callback = function()
						local current_filetype = get_markdown_language()
						local repl = repls[current_filetype]
						if repl then
							local process_name = repl_process_names[current_filetype] or current_filetype
							local panes = vim.fn.system("tmux list-panes -F '#{pane_current_command}'")
							if not panes:find(process_name) then
								vim.defer_fn(open_repl, 1000)
							end
						end
					end,
				})
			end
		end,
	},
}
