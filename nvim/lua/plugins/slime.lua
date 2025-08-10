return {
	{
		"jpalardy/vim-slime",
		lazy = false,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			vim.g.slime_target = "tmux"
			-- Fixed: Use {right} or remove target_pane to be prompted
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
				r = "radian",
				matlab = "matlab -nodesktop -nosplash",
			}

			-- Map REPL commands to their actual process names in tmux
			local repl_process_names = {
				python = "python3",
				julia = "julia",
				r = "python", -- radian shows up as python process
				matlab = "matlab",
			}

			-- Send with highlighting (using default vim highlight like yank)
			local function send_with_highlight(text, start_line, end_line)
				local ns = vim.api.nvim_create_namespace("slime_highlight")
				for i = start_line - 1, end_line - 1 do
					vim.api.nvim_buf_add_highlight(0, ns, "IncSearch", i, 0, -1)
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
					r = "r",
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

			-- Helper function to detect current language in markdown files
			local function get_markdown_language()
				-- For non-markdown files, return filetype directly
				if vim.bo.filetype ~= "markdown" then
					return vim.bo.filetype
				end

				-- First check file extension for default language
				local filename = vim.fn.expand("%:t")
				local default_lang = nil
				if filename:match("%.rmd$") or filename:match("%.Rmd$") then
					default_lang = "r"
				elseif filename:match("%.jmd$") then
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
							if lang == "python" or lang == "julia" or lang == "r" or lang == "matlab" then
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
						return lang == "r" and "r" or lang
					end
				end

				return "markdown" -- Final fallback
			end

			-- Language-specific block detection functions
			-- R detection
			local function is_r_function_start()
				local line = vim.api.nvim_get_current_line()
				return line:match("%w+%s*[<%-=]+%s*function%s*%(")
			end
			local function is_r_control_structure()
				local line = vim.api.nvim_get_current_line()
				return line:match("^%s*for%s*%(")
					or line:match("^%s*if%s*%(")
					or line:match("^%s*while%s*%(")
					or line:match("^%s*repeat%s*{")
					or line:match("^%s*{%s*$")
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
				-- Original logic for R and other languages
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

			-- Get R control structure range
			local function get_r_control_range()
				local start_line = vim.fn.line(".")
				local saved_pos = vim.api.nvim_win_get_cursor(0)
				local line_text = vim.api.nvim_get_current_line()
				-- Find the opening brace
				local brace_line = nil
				local brace_col = nil
				-- For most control structures, brace might be on same line or next line
				-- Check current line first
				local brace_pos = line_text:find("{")
				if brace_pos then
					brace_line = start_line
					brace_col = brace_pos
				else
					-- Check next few lines for opening brace
					for line_num = start_line + 1, math.min(start_line + 2, vim.fn.line("$")) do
						local next_line = vim.fn.getline(line_num)
						brace_pos = next_line:find("{")
						if brace_pos then
							brace_line = line_num
							brace_col = brace_pos
							break
						end
					end
				end
				if not brace_line then
					return nil
				end
				-- Move to the opening brace and find its match
				vim.api.nvim_win_set_cursor(0, { brace_line, brace_col - 1 })
				local ok = pcall(function()
					vim.cmd("normal! %")
				end)
				local end_line = start_line
				if ok then
					end_line = vim.api.nvim_win_get_cursor(0)[1]
				end
				-- Restore cursor position
				vim.api.nvim_win_set_cursor(0, saved_pos)
				if end_line > start_line then
					return { start_line = start_line, end_line = end_line }
				end
				return nil
			end

			-- Get R function range by finding matching braces
			local function get_r_function_range()
				local start_line = vim.fn.line(".")
				local saved_pos = vim.api.nvim_win_get_cursor(0)
				-- Search for the opening brace after function declaration
				local brace_line = nil
				local brace_col = nil
				-- First, find the closing parenthesis of function parameters
				local paren_closed = false
				local paren_depth = 0
				-- Search forward for opening brace, but be smart about function context
				for line_num = start_line, vim.fn.line("$") do
					local line_text = vim.fn.getline(line_num)
					-- Track parentheses to know when we're out of function parameters
					if not paren_closed then
						for i = 1, #line_text do
							local char = line_text:sub(i, i)
							if char == "(" then
								paren_depth = paren_depth + 1
							elseif char == ")" then
								paren_depth = paren_depth - 1
								if paren_depth == 0 then
									paren_closed = true
									break
								end
							end
						end
					end
					-- Look for opening brace
					local brace_pos = line_text:find("{")
					if brace_pos then
						brace_line = line_num
						brace_col = brace_pos
						break
					end
					-- Only stop for new assignments if we're past the function parameters
					if line_num > start_line and paren_closed then
						-- Check for new assignment at start of line (not indented)
						if line_text:match("^[%w%.]+%s*[<%-=]+%s*function") or line_text:match("^[%w%.]+%s*[<%-]+") then
							break
						end
					end
				end
				if not brace_line then
					-- No braces found - handle single-expression functions
					local end_line = start_line
					local paren_closed_single = false
					local paren_depth_single = 0
					for line_num = start_line, vim.fn.line("$") do
						local line_text = vim.fn.getline(line_num)
						-- Track when we exit function parameters
						if not paren_closed_single then
							for i = 1, #line_text do
								local char = line_text:sub(i, i)
								if char == "(" then
									paren_depth_single = paren_depth_single + 1
								elseif char == ")" then
									paren_depth_single = paren_depth_single - 1
									if paren_depth_single == 0 then
										paren_closed_single = true
										break
									end
								end
							end
						end
						-- After parameters closed, look for end of function
						if paren_closed_single and line_num > start_line then
							if line_text:match("^%s*$") or line_text:match("^[%w%.]+%s*[<%-=]+") then
								break
							end
						end
						end_line = line_num
					end
					return { start_line = start_line, end_line = end_line }
				end
				-- Move to the opening brace and find its match
				vim.api.nvim_win_set_cursor(0, { brace_line, brace_col - 1 })
				local ok = pcall(function()
					vim.cmd("normal! %")
				end)
				local end_line = start_line -- fallback
				if ok then
					end_line = vim.api.nvim_win_get_cursor(0)[1]
				end
				-- Restore cursor position
				vim.api.nvim_win_set_cursor(0, saved_pos)
				if end_line > start_line then
					return { start_line = start_line, end_line = end_line }
				end
				return nil
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
					if current_filetype == "r" then
						if is_r_function_start() then
							range = get_r_function_range()
							range_found = (range ~= nil)
						elseif is_r_control_structure() then
							range = get_r_control_range()
							range_found = (range ~= nil)
						end
					elseif current_filetype == "python" then
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

			local function open_repl()
				local current_filetype = get_markdown_language()
				local cmd = repls[current_filetype]
				if cmd then
					-- Don't switch focus to the new pane
					vim.fn.system("tmux split-window -d -h '" .. cmd .. "'")
					print("Opened " .. current_filetype .. " REPL")
				else
					print("No REPL for filetype: " .. current_filetype)
				end
			end

			local function close_repl()
				local current_filetype = get_markdown_language()
				local repl_cmd = repls[current_filetype]
				local process_name = repl_process_names[current_filetype]

				print("Debug: Filetype=" .. current_filetype .. ", Looking for process=" .. (process_name or "nil"))

				if repl_cmd and process_name then
					-- Use tmux list-panes to get pane IDs and commands
					local cmd = "tmux list-panes -F '#{pane_id} #{pane_current_command}'"
					local panes_output = vim.fn.system(cmd)

					local pane_id = nil
					local python_panes = {} -- Store python panes for R detection
					local matlab_panes = {} -- Store potential MATLAB panes

					for line in panes_output:gmatch("[^\r\n]+") do
						local id, command = line:match("^(%S+)%s+(.+)")
						if id and command then
							print("Debug: Checking pane " .. id .. " with command: " .. command)
							if current_filetype == "r" then
								if command:find("python", 1, true) then
									table.insert(python_panes, id)
									print("Debug: Found python pane " .. id)
								end
							elseif current_filetype == "matlab" then
								-- Handle MATLAB process name variations (case-insensitive)
								if command:lower():find("matlab", 1, true) then
									table.insert(matlab_panes, id)
									print("Debug: Found potential MATLAB pane " .. id)
								end
							else
								-- For other languages, match process name directly
								if command:find(process_name, 1, true) then
									pane_id = id
									print("Debug: Found matching pane " .. id .. " with command: " .. command)
									break
								end
							end
						end
					end

					-- Special handling for R (radian runs as python)
					if current_filetype == "r" and #python_panes > 0 then
						table.sort(python_panes, function(a, b)
							local num_a = tonumber(a:match("%%(%d+)"))
							local num_b = tonumber(b:match("%%(%d+)"))
							return (num_a or 0) > (num_b or 0)
						end)
						pane_id = python_panes[1]
						print("Debug: Selected python pane " .. pane_id .. " as radian")
					end

					-- Special handling for MATLAB
					if current_filetype == "matlab" and #matlab_panes > 0 then
						table.sort(matlab_panes, function(a, b)
							local num_a = tonumber(a:match("%%(%d+)"))
							local num_b = tonumber(b:match("%%(%d+)"))
							return (num_a or 0) > (num_b or 0)
						end)
						pane_id = matlab_panes[1]
						print("Debug: Selected MATLAB pane " .. pane_id)
					end

					if pane_id then
						local result = vim.fn.system("tmux kill-pane -t " .. pane_id)
						if vim.v.shell_error == 0 then
							print("Closed " .. current_filetype .. " REPL (pane " .. pane_id .. ")")
						else
							print("Error closing pane " .. pane_id .. ": " .. result)
						end
					else
						print("No " .. current_filetype .. " REPL found. Available panes:")
						local debug_cmd = "tmux list-panes -F 'Pane #{pane_id}: #{pane_current_command}'"
						local debug_output = vim.fn.system(debug_cmd)
						print(debug_output)
					end
				else
					print("No REPL for filetype: " .. current_filetype)
				end
			end

			-- Set cursor movement preference (0 = don't move, 1 = move)
			vim.g.slime_move_cursor = 1 -- Set to 1 to move cursor down after sending

			-- ========================================
			-- KEYBINDINGS (centralized for easy editing)
			-- ========================================
			-- Global keymaps
			vim.keymap.set("n", "<leader>or", open_repl, { desc = "Open REPL" })
			vim.keymap.set("n", "<leader>cr", close_repl, { desc = "Close REPL" })
			vim.keymap.set("n", "<leader>sc", "<Cmd>SlimeConfig<CR>", { desc = "Configure slime" })

			-- Language-specific keymaps
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "python", "julia", "r", "matlab", "markdown" },
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
				end,
			})

			-- Auto-start REPL if environment variable is set
			if vim.env.SLIME_AUTO_START == "true" then
				vim.api.nvim_create_autocmd("BufEnter", {
					pattern = { "*.py", "*.jl", "*.r", "*.R", "*.m", "*.rmd", "*.Rmd", "*.jmd" },
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
