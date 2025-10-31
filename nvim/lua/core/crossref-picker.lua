-- Crossref picker with Telescope integration
local M = {}

---------------------------------------------------------------------
-- Parse R Markdown file for chunk labels
---------------------------------------------------------------------
local function parse_chunks(bufnr)
	local chunks = {}

	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	for line_num, line in ipairs(lines) do
		-- Match R Markdown chunk headers with labels, e.g. ```{r label, ...} or ```{r, label, ...}
		local label = line:match("^```{r%s+([^,}%s]+)") or line:match("^```{r,%s*([^,}%s]+)")
		if label then
			table.insert(chunks, {
				label = label,
				line = line_num,
				preview = line:gsub("^%s+", ""):gsub("%s+$", ""),
			})
		end
	end

	return chunks
end

---------------------------------------------------------------------
-- Format chunk for display in picker
---------------------------------------------------------------------
local function format_chunk_display(chunk)
	return string.format("%-30s │ Line %d", chunk.label, chunk.line)
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

	-- In normal mode, move cursor position one character to the right
	if not saved_context.was_insert_mode then
		col = col + 1
	end

	local ok = pcall(function()
		vim.api.nvim_buf_set_text(saved_context.buf, row - 1, col, row - 1, col, { crossref })
	end)

	if ok then
		-- Set cursor after inserted text
		local target_col = col + #crossref
		pcall(vim.api.nvim_win_set_cursor, saved_context.win or 0, { row, target_col })

		-- Re-enter insert mode if we were in insert mode
		if saved_context.was_insert_mode then
			vim.schedule(function()
				pcall(vim.api.nvim_set_current_win, saved_context.win or 0)
				pcall(vim.api.nvim_set_current_buf, saved_context.buf)
				pcall(vim.api.nvim_win_set_cursor, saved_context.win or 0, { row, target_col })
				local key = vim.api.nvim_replace_termcodes("a", true, false, true)
				pcall(vim.api.nvim_feedkeys, key, "n", true)
			end)
		end

		vim.notify("Inserted crossref: " .. crossref, vim.log.levels.INFO)
	else
		vim.notify("Failed to insert crossref", vim.log.levels.ERROR)
	end
end

---------------------------------------------------------------------
-- Generic picker for crossrefs
---------------------------------------------------------------------
local function create_crossref_picker(ref_type, chunks)
	if #chunks == 0 then
		vim.notify("No " .. ref_type .. " chunks found in current file", vim.log.levels.WARN)
		return
	end

	-- Save context
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

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	-- Create previewer that shows the chunk location
	local previewer = previewers.new_buffer_previewer({
		title = "Chunk Location",
		define_preview = function(self, entry)
			local bufnr = saved.buf
			local chunk = entry.value

			-- Get lines around the chunk for context
			local start_line = math.max(0, chunk.line - 5)
			local end_line = math.min(vim.api.nvim_buf_line_count(bufnr), chunk.line + 10)
			local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)

			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

			-- Highlight the chunk header line
			local highlight_line = chunk.line - start_line - 1
			if highlight_line >= 0 and highlight_line < #lines then
				vim.api.nvim_buf_add_highlight(self.state.bufnr, -1, "TelescopePreviewMatch", highlight_line, 0, -1)
			end

			-- Set filetype for syntax highlighting
			vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "rmd")
		end,
	})

	pickers
		.new({}, {
			prompt_title = "Select " .. ref_type:gsub("^%l", string.upper) .. " Reference",
			finder = finders.new_table({
				results = chunks,
				entry_maker = function(chunk)
					return {
						value = chunk,
						display = format_chunk_display(chunk),
						ordinal = chunk.label,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = previewer,
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						insert_crossref(ref_type, selection.value.label, saved)
					end
				end)
				return true
			end,
		})
		:find()
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

---------------------------------------------------------------------
-- Exports
---------------------------------------------------------------------
return M
