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
-- Format chunk for display
---------------------------------------------------------------------
local function format_chunk_display(chunk)
	return string.format("%-20s │ Line %d", chunk.label, chunk.line)
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
-- Crossref previewer with syntax highlighting
---------------------------------------------------------------------
local function create_crossref_previewer(chunks, source_buf)
	local Previewer = require("fzf-lua.previewer.builtin")
	local CrossrefPreviewer = Previewer.buffer_or_file:extend()

	function CrossrefPreviewer:new(o, opts, fzf_win)
		CrossrefPreviewer.super.new(self, o, opts, fzf_win)
		setmetatable(self, CrossrefPreviewer)
		return self
	end

	function CrossrefPreviewer:parse_entry(entry_str)
		local label = entry_str:match("^([^%s│]+)")
		return { path = label }
	end

	function CrossrefPreviewer:populate_preview_buf(entry_str)
		local label = entry_str:match("^([^%s│]+)")
		local chunk

		for _, c in ipairs(chunks) do
			if c.label == label then
				chunk = c
				break
			end
		end

		if not chunk then
			return false
		end

		-- Get the chunk content from start to end (including closing ```)
		local chunk_lines = vim.api.nvim_buf_get_lines(source_buf, chunk.line - 1, chunk.chunk_end, false)

		-- Create preview buffer if needed
		if not self.preview_bufnr or not vim.api.nvim_buf_is_valid(self.preview_bufnr) then
			self.preview_bufnr = vim.api.nvim_create_buf(false, true)
			vim.bo[self.preview_bufnr].bufhidden = "wipe"
			vim.bo[self.preview_bufnr].buftype = "nofile"
		end

		-- Set buffer content
		vim.api.nvim_buf_set_lines(self.preview_bufnr, 0, -1, false, chunk_lines)

		-- Detect language from chunk header
		local lang = "r" -- default
		local first_line = chunk_lines[1] or ""
		local detected_lang = first_line:match("^```{([^,}%s]+)")
		if detected_lang then
			lang = detected_lang:lower()
		end

		-- Set filetype and enable syntax highlighting
		vim.bo[self.preview_bufnr].filetype = lang
		vim.bo[self.preview_bufnr].syntax = lang

		-- Force treesitter to start
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(self.preview_bufnr) then
				pcall(vim.treesitter.start, self.preview_bufnr, lang)
			end
		end)

		self:set_preview_buf(self.preview_bufnr)
		self.preview_bufloaded = true

		return true
	end

	return CrossrefPreviewer
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

	local saved = {
		win = cur_win,
		buf = cur_buf,
		row = cur_row,
		col = cur_col,
		was_insert_mode = was_insert,
	}

	local chunk_lookup = {}
	for _, chunk in ipairs(chunks) do
		chunk_lookup[format_chunk_display(chunk)] = chunk
	end

	local fzf = require("fzf-lua")

	local title_str = "Figure"
	if ref_type:gsub("^%l", string.upper) == "Tab" then
		title_str = "Table"
	end

	fzf.fzf_exec(function(cb)
		for _, chunk in ipairs(chunks) do
			cb(format_chunk_display(chunk))
		end
		cb()
	end, {
		prompt = "Code Chunk> ",
		previewer = create_crossref_previewer(chunks, cur_buf),
		winopts = {
			title = title_str,
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
