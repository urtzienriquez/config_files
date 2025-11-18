-- lua/core/python_utils.lua
local M = {}

-- Python block start patterns (lines that start blocks with colons)
local PYTHON_BLOCK_START = {
	"^%s*def%s+",
	"^%s*class%s+",
	"^%s*if%s+",
	"^%s*elif%s+",
	"^%s*else%s*:",
	"^%s*for%s+",
	"^%s*while%s+",
	"^%s*try%s*:",
	"^%s*except",
	"^%s*finally%s*:",
	"^%s*with%s+",
	"^%s*match%s+", -- Python 3.10+
	"^%s*case%s+", -- Python 3.10+
	"^%s*@", -- decorators
}

-- Check if a line starts a Python block
local function is_block_start(line)
	-- Check for colon at end (main indicator of block start in Python)
	if line:match(":%s*$") or line:match(":%s*#") then
		for _, pattern in ipairs(PYTHON_BLOCK_START) do
			if line:match(pattern) then
				return true
			end
		end
	end
	return false
end

-- Get the indentation level of a line
local function get_indent_level(line)
	local indent = line:match("^(%s*)")
	return #indent
end

-- Check if line is empty or only whitespace
local function is_empty_line(line)
	return line:match("^%s*$") ~= nil
end

-- Check if line is a comment
local function is_comment_line(line)
	return line:match("^%s*#") ~= nil
end

-- Find the complete block containing the cursor
function M.get_python_block_range(bufnr, start_line)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	start_line = start_line or vim.api.nvim_win_get_cursor(0)[1]

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local current_line = lines[start_line]

	-- Skip empty lines and comments
	if is_empty_line(current_line) or is_comment_line(current_line) then
		return start_line, start_line
	end

	local current_indent = get_indent_level(current_line)

	-- Check if we're on a block start
	if is_block_start(current_line) then
		local block_indent = current_indent
		local end_line = start_line

		-- Find all lines that belong to this block
		for i = start_line + 1, #lines do
			local line = lines[i]

			-- Skip empty lines and comments - they're part of the block
			if is_empty_line(line) or is_comment_line(line) then
				end_line = i
			else
				local line_indent = get_indent_level(line)
				-- If indented more than block start, it's part of the block
				if line_indent > block_indent then
					end_line = i
				else
					-- We've left the block
					break
				end
			end
		end

		return start_line, end_line
	end

	-- We're inside a block - find the start by going backwards
	local block_start = start_line

	-- Search backwards for a line with less indentation that starts a block
	for i = start_line - 1, 1, -1 do
		local line = lines[i]

		if not is_empty_line(line) and not is_comment_line(line) then
			local line_indent = get_indent_level(line)

			-- Found a line with less indentation
			if line_indent < current_indent then
				if is_block_start(line) then
					block_start = i
					break
				else
					-- This is a line with less indentation but not a block start
					-- The current line must be at top level
					break
				end
			end
		end
	end

	-- If we found a block start, find its end
	if block_start < start_line then
		local block_indent = get_indent_level(lines[block_start])
		local end_line = block_start

		for i = block_start + 1, #lines do
			local line = lines[i]

			if is_empty_line(line) or is_comment_line(line) then
				end_line = i
			else
				local line_indent = get_indent_level(line)
				if line_indent > block_indent then
					end_line = i
				else
					break
				end
			end
		end

		return block_start, end_line
	end

	-- Not in a block - return just the current line
	return start_line, start_line
end

-- Get text to send to REPL
function M.get_python_send_text()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local current_line = lines[cursor_line]

	-- If line is empty or only whitespace or comment, skip it
	if is_empty_line(current_line) or is_comment_line(current_line) then
		return nil, cursor_line, cursor_line
	end

	-- Check if we're in or at the start of a block
	local start_line, end_line = M.get_python_block_range(bufnr, cursor_line)

	if start_line == end_line then
		-- Single line - just send it
		return current_line, start_line, end_line
	else
		-- Multi-line block - send entire block
		local block_lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
		return table.concat(block_lines, "\n"), start_line, end_line
	end
end

-- Debug function to test block detection
function M.debug_block_detection()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local current_line = lines[cursor_line]

	print("Current line " .. cursor_line .. ": " .. current_line)
	print("Indent level: " .. get_indent_level(current_line))
	print("Is block start: " .. tostring(is_block_start(current_line)))
	print("Is empty: " .. tostring(is_empty_line(current_line)))
	print("Is comment: " .. tostring(is_comment_line(current_line)))

	local start_line, end_line = M.get_python_block_range(bufnr, cursor_line)
	print("Block range: " .. start_line .. " to " .. end_line)

	if start_line ~= end_line then
		print("\nBlock content:")
		local block_lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
		for i, line in ipairs(block_lines) do
			print(string.format("  %d: %s", start_line + i - 1, line))
		end
	end
end

return M
