-- lua/core/repl_utils.lua
-- Unified REPL utilities that dispatch to language-specific implementations

local M = {}

-- Get the appropriate language-specific utility module
local function get_lang_utils(filetype)
	if filetype == "julia" then
		return require("core.julia_utils")
	elseif filetype == "python" then
		return require("core.python_utils")
	else
		return nil
	end
end

-- Get text to send to REPL (language-aware)
function M.get_send_text()
	local filetype = vim.bo.filetype
	local lang_utils = get_lang_utils(filetype)

	if lang_utils then
		if filetype == "julia" then
			return lang_utils.get_julia_send_text()
		elseif filetype == "python" then
			return lang_utils.get_python_send_text()
		end
	end

	-- Fallback for unsupported languages (MATLAB, etc.)
	-- Return current line only
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines = vim.api.nvim_buf_get_lines(bufnr, cursor_line - 1, cursor_line, false)
	local current_line = lines[1] or ""

	if current_line:match("^%s*$") then
		return nil, cursor_line, cursor_line
	end

	return current_line, cursor_line, cursor_line
end

-- Debug block detection (language-aware)
function M.debug_block_detection()
	local filetype = vim.bo.filetype
	local lang_utils = get_lang_utils(filetype)

	if lang_utils and lang_utils.debug_block_detection then
		lang_utils.debug_block_detection()
	else
		vim.notify("Block detection not supported for " .. filetype, vim.log.levels.WARN)
	end
end

-- Check if current filetype has smart block detection
function M.has_smart_blocks()
	local filetype = vim.bo.filetype
	return filetype == "julia" or filetype == "python"
end

return M
