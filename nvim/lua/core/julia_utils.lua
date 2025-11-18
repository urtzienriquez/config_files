-- lua/core/julia_utils.lua
local M = {}

-- Julia block patterns
local JULIA_BLOCK_START = {
	"^%s*function%s+",
	"^%s*function%s*%(", -- anonymous functions
	"^%s*macro%s+",
	"^%s*for%s+",
	"^%s*while%s+",
	"^%s*if%s+",
	"^%s*begin", -- Changed: removed %s*$ to match "begin" anywhere on line
	"^%s*let%s+",
	"^%s*let%s*$", -- let without arguments
	"^%s*module%s+",
	"^%s*struct%s+",
	"^%s*mutable%s+struct%s+",
	"^%s*abstract%s+type%s+",
	"^%s*quote%s*$",
	"^%s*try%s*$",
	"^%s*@testset", -- test blocks
}

local JULIA_BLOCK_END = "^%s*end" -- Changed: removed %s*$ to match "end" at start

-- Check if a line starts a Julia block
local function is_block_start(line)
	for _, pattern in ipairs(JULIA_BLOCK_START) do
		if line:match(pattern) then
			return true
		end
	end
	return false
end

-- Check if a line ends a Julia block
local function is_block_end(line)
	return line:match(JULIA_BLOCK_END) ~= nil
end

-- Find the complete block containing the cursor
function M.get_julia_block_range(bufnr, start_line)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	start_line = start_line or vim.api.nvim_win_get_cursor(0)[1]

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local current_line = lines[start_line]

	-- Check if we're on a block start
	if is_block_start(current_line) then
		-- Find matching end
		local depth = 1
		for i = start_line + 1, #lines do
			local line = lines[i]
			if is_block_start(line) then
				depth = depth + 1
			elseif is_block_end(line) then
				depth = depth - 1
				if depth == 0 then
					return start_line, i
				end
			end
		end
		-- If we didn't find a matching end, just return the start line
		return start_line, start_line
	end

	-- Check if we're on a block end - just return this line
	if is_block_end(current_line) then
		return start_line, start_line
	end

	-- We might be inside a block - search backwards for start
	-- But we need to track depth to avoid matching already-closed blocks
	local block_start = nil
	local depth = 0

	-- First, scan from current line backwards, tracking depth
	for i = start_line - 1, 1, -1 do
		local line = lines[i]

		-- When going backwards, we increment depth when we see 'end'
		-- and decrement when we see a block start
		if is_block_end(line) then
			depth = depth + 1
		elseif is_block_start(line) then
			if depth == 0 then
				-- Found an unmatched block start - we're inside this block
				block_start = i
				break
			else
				-- This block start matches an end we saw earlier
				depth = depth - 1
			end
		end
	end

	if block_start then
		-- Find the matching end for this block start
		depth = 1
		for i = block_start + 1, #lines do
			local line = lines[i]
			if is_block_start(line) then
				depth = depth + 1
			elseif is_block_end(line) then
				depth = depth - 1
				if depth == 0 then
					-- Check if current line is inside this block
					if start_line >= block_start and start_line <= i then
						return block_start, i
					else
						-- Current line is after this block ended
						break
					end
				end
			end
		end
	end

	-- Not in a block - return just the current line
	return start_line, start_line
end

-- Get text to send to REPL
function M.get_julia_send_text()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local current_line = lines[cursor_line]

	-- If line is empty or only whitespace, skip it
	if current_line:match("^%s*$") then
		return nil, cursor_line, cursor_line
	end

	-- Check if we're in or at the start of a block
	local start_line, end_line = M.get_julia_block_range(bufnr, cursor_line)

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
	print("Is block start: " .. tostring(is_block_start(current_line)))
	print("Is block end: " .. tostring(is_block_end(current_line)))

	local start_line, end_line = M.get_julia_block_range(bufnr, cursor_line)
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
