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
		-- Detect labels in ```{r label, ...} format (label comes right after r)
		local label = line:match("^```{r%s+([^,}%s]+)")

		-- If no label found but it's an r chunk with comma, mark as unnamed
		if not label and line:match("^```{r,%s*") then
			label = "unnamed"
		end

		if label then
			table.insert(chunks, {
				label = label,
				line = line_num,
			})
		end
	end

	return chunks
end

---------------------------------------------------------------------
-- Parse chunks from a file path
---------------------------------------------------------------------
local function parse_chunks_from_file(filepath)
	local chunks = {}
	local file = io.open(filepath, "r")
	if not file then
		return chunks
	end

	local line_num = 0
	for line in file:lines() do
		line_num = line_num + 1
		-- Detect labels in ```{r label, ...} format (label comes right after r)
		local label = line:match("^```{r%s+([^,}%s]+)")

		-- If no label found but it's an r chunk with comma, mark as unnamed
		if not label and line:match("^```{r,%s*") then
			label = "unnamed"
		end

		if label then
			table.insert(chunks, {
				label = label,
				line = line_num,
				file = filepath,
			})
		end
	end

	file:close()
	return chunks
end

---------------------------------------------------------------------
-- Get all chunks from current file and other Rmd files in directory
---------------------------------------------------------------------
local function get_all_chunks()
	local all_chunks = {}
	local cur_buf = vim.api.nvim_get_current_buf()
	local cur_file = vim.api.nvim_buf_get_name(cur_buf)
	local cur_dir = vim.fn.fnamemodify(cur_file, ":h")

	-- Parse current buffer first
	local cur_chunks = parse_chunks(cur_buf)
	for _, chunk in ipairs(cur_chunks) do
		chunk.file = cur_file
		chunk.is_current = true
		table.insert(all_chunks, chunk)
	end

	-- Find all Rmd/qmd files in the same directory
	local rmd_files = vim.fn.globpath(cur_dir, "*.{rmd,Rmd,qmd,Qmd}", false, true)

	for _, file in ipairs(rmd_files) do
		-- Skip current file (already parsed from buffer)
		if file ~= cur_file then
			local chunks = parse_chunks_from_file(file)
			for _, chunk in ipairs(chunks) do
				chunk.is_current = false
				table.insert(all_chunks, chunk)
			end
		end
	end

	return all_chunks
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
-- Custom previewer for chunks
---------------------------------------------------------------------
local function create_chunk_previewer(chunks)
	local Previewer = require("fzf-lua.previewer.builtin")

	local ChunkPreviewer = Previewer.buffer_or_file:extend()

	function ChunkPreviewer:new(o, opts, fzf_win)
		ChunkPreviewer.super.new(self, o, opts, fzf_win)
		setmetatable(self, ChunkPreviewer)
		return self
	end

	function ChunkPreviewer:parse_entry(entry_str)
		-- Extract label (everything before the optional file indicator)
		local label = entry_str:match("^(.-)%s*%(") or entry_str

		-- Find the chunk by label
		for _, chunk in ipairs(chunks) do
			if chunk.label == label then
				return {
					path = chunk.file,
					line = chunk.line,
					col = 1,
				}
			end
		end
		return { path = "" }
	end

	return ChunkPreviewer
end

---------------------------------------------------------------------
-- Generic crossref picker
---------------------------------------------------------------------
local function create_crossref_picker(ref_type, chunks)
	if #chunks == 0 then
		vim.notify("No " .. ref_type .. " chunks found in current file or directory", vim.log.levels.WARN)
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
		chunk_lookup[chunk.label] = chunk
	end

	local fzf = require("fzf-lua")

	local title_str = ref_type == "fig" and " Figure " or " Table "

	fzf.fzf_exec(function(cb)
		for _, chunk in ipairs(chunks) do
			-- Show label with file indicator for non-current files
			local display = chunk.label
			if not chunk.is_current then
				local filename = vim.fn.fnamemodify(chunk.file, ":t")
				display = display .. " (" .. filename .. ")"
			end
			cb(display)
		end
		cb()
	end, {
		prompt = "Code Chunk> ",
		previewer = create_chunk_previewer(chunks),
		winopts = {
			title = title_str .. "Crossref ",
			preview = {
				layout = "vertical",
				vertical = "right:65%",
				wrap = "wrap",
			},
		},

		actions = {
			["default"] = function(selected)
				if #selected == 0 then
					return
				end
				-- Extract just the label (before any file indicator)
				local label = selected[1]:match("^(.-)%s*%(") or selected[1]
				local chunk = chunk_lookup[label]
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
	local chunks = get_all_chunks()
	create_crossref_picker("fig", chunks)
end

---------------------------------------------------------------------
-- Table crossref picker
---------------------------------------------------------------------
function M.table_picker()
	local chunks = get_all_chunks()
	create_crossref_picker("tab", chunks)
end

return M
