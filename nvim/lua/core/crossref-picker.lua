-- Crossref picker

local M = {}

---------------------------------------------------------------------
-- Parse R Markdown file for chunk labels
---------------------------------------------------------------------
local function parse_chunks(bufnr)
	local chunks = {}
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	for line_num, line in ipairs(lines) do
		-- Detect labels in ```{r label} or ```{r, label}
		local label = line:match("^```{r%s+([^,}%s]+)") or line:match("^```{r,%s*([^,}%s]+)")
		if label then
			-- Find the end of this chunk (next line starting with ```)
			local chunk_end = line_num
			for i = line_num + 1, #lines do
				if lines[i]:match("^```%s*$") then
					chunk_end = i
					break
				end
			end

			table.insert(chunks, {
				label = label,
				line = line_num,
				chunk_end = chunk_end,
				preview = line:gsub("^%s+", ""):gsub("%s+$", ""),
			})
		end
	end

	return chunks
end

---------------------------------------------------------------------
-- Format chunk for display with line number embedded for preview
---------------------------------------------------------------------
local function format_chunk_display(chunk, filename)
	-- Embed the filename and line number in a format fzf-lua can parse
	return string.format("%s:%d: %-20s", filename, chunk.line, chunk.label)
end

---------------------------------------------------------------------
-- Cursor helpers
---------------------------------------------------------------------
local function set_cursor_after_inserted_text(buf, win, row, start_col, inserted_text)
	if not vim.api.nvim_buf_is_valid(buf) then
		return nil
	end
	local winid = (win and vim.api.nvim_win_is_valid(win)) and win or 0
	local target_col = start_col + #inserted_text
	pcall(vim.api.nvim_set_current_win, winid)
	pcall(vim.api.nvim_set_current_buf, buf)
	pcall(vim.api.nvim_win_set_cursor, winid, { row, target_col })
	return target_col
end

local function reenter_insert_mode_at_cursor_for_buffer(win, buf, row, col, inserted_text_len)
	local winid = (win and vim.api.nvim_win_is_valid(win)) and win or 0
	pcall(vim.api.nvim_set_current_win, winid)
	pcall(vim.api.nvim_set_current_buf, buf)
	pcall(vim.api.nvim_win_set_cursor, winid, { row, col + inserted_text_len })
	local key = vim.api.nvim_replace_termcodes("a", true, false, true)
	pcall(vim.api.nvim_feedkeys, key, "n", true)
end

---------------------------------------------------------------------
-- Insert crossref at cursor
---------------------------------------------------------------------
local function insert_crossref(ref_type, label, saved_context)
	if not saved_context or not label then
		return
	end

	local crossref = string.format("\\@ref(%s:%s)", ref_type, label)

	if not vim.api.nvim_buf_is_valid(saved_context.buf) then
		return
	end

	if saved_context.win and vim.api.nvim_win_is_valid(saved_context.win) then
		pcall(vim.api.nvim_set_current_win, saved_context.win)
	end
	pcall(vim.api.nvim_set_current_buf, saved_context.buf)

	local row, col = saved_context.row, saved_context.col

	if not saved_context.was_insert_mode then
		local line = vim.api.nvim_buf_get_lines(saved_context.buf, row - 1, row, false)[1] or ""
		if col < #line then
			col = col + 1
		end
	end

	local ok = pcall(function()
		vim.api.nvim_buf_set_text(saved_context.buf, row - 1, col, row - 1, col, { crossref })
	end)

	if ok then
		set_cursor_after_inserted_text(saved_context.buf, saved_context.win, row, col, crossref)
		if saved_context.was_insert_mode then
			reenter_insert_mode_at_cursor_for_buffer(saved_context.win, saved_context.buf, row, col, #crossref)
		end
		vim.schedule(function()
			vim.notify("Inserted crossref: " .. crossref, vim.log.levels.INFO)
		end)
	else
		vim.notify("Failed to insert crossref", vim.log.levels.ERROR)
	end
end

---------------------------------------------------------------------
-- Generic crossref picker
---------------------------------------------------------------------
local function create_crossref_picker(ref_type, chunks)
	if #chunks == 0 then
		vim.notify("No " .. ref_type .. " chunks found in current file", vim.log.levels.WARN)
		return
	end

	local cur_win = vim.api.nvim_get_current_win()
	local cur_buf = vim.api.nvim_get_current_buf()
	local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
	local was_insert = vim.api.nvim_get_mode().mode:find("i") ~= nil
	local filename = vim.api.nvim_buf_get_name(cur_buf)

	local saved = {
		win = cur_win,
		buf = cur_buf,
		row = cur_row,
		col = cur_col,
		was_insert_mode = was_insert,
	}

	local chunk_lookup = {}
	for _, chunk in ipairs(chunks) do
		local display = format_chunk_display(chunk, filename)
		chunk_lookup[display] = chunk
	end

	local fzf = require("fzf-lua")

	local title_str = ref_type == "fig" and "Figure" or "Table"

	fzf.fzf_exec(function(cb)
		for _, chunk in ipairs(chunks) do
			cb(format_chunk_display(chunk, filename))
		end
		cb()
	end, {
		prompt = "Code Chunk> ",
		-- Use builtin previewer which handles file:line format automatically
		previewer = "builtin",
		winopts = {
			title = title_str .. " Crossref",
			preview = {
				layout = "vertical",
				vertical = "right:70%",
				wrap = "wrap",
			},
		},

		actions = {
			["default"] = function(selected)
				if #selected == 0 then
					return
				end
				local chunk = chunk_lookup[selected[1]]
				if chunk then
					insert_crossref(ref_type, chunk.label, saved)
				end
			end,
		},
	})
end

---------------------------------------------------------------------
-- Figure crossref picker
---------------------------------------------------------------------
function M.figure_picker()
	local chunks = parse_chunks()
	create_crossref_picker("fig", chunks)
end

---------------------------------------------------------------------
-- Table crossref picker
---------------------------------------------------------------------
function M.table_picker()
	local chunks = parse_chunks()
	create_crossref_picker("tab", chunks)
end

return M
