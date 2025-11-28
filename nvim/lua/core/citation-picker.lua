-- Citation picker

local zotero_bib = vim.fn.expand("~/Documents/zotero.bib")
local local_bibs = vim.fn.globpath(vim.fn.getcwd(), "*.bib", false, true)

local bib_file = { zotero_bib }
for _, b in ipairs(local_bibs) do
	if b ~= zotero_bib then
		table.insert(bib_file, b)
	end
end

---------------------------------------------------------------------
-- Parse .bib files and extract citation keys with metadata
---------------------------------------------------------------------
local function parse_bib_file(file_paths)
	if type(file_paths) == "string" then
		file_paths = { file_paths }
	end

	local all_citations = {}

	for _, file_path in ipairs(file_paths) do
		local file = io.open(file_path, "r")
		if not file then
			vim.notify("Could not open bib file: " .. file_path, vim.log.levels.WARN)
		else
			local citations = {}
			local current_entry = {}
			local in_entry = false
			local current_field = nil

			for line in file:lines() do
				local entry_type, key = line:match("^%s*@(%w+)%s*{%s*([^,%s]+)")
				if entry_type and key then
					if current_entry.key then
						table.insert(citations, current_entry)
					end
					current_entry = {
						key = key,
						title = "",
						author = "",
						year = "",
						journaltitle = "",
						abstract = "",
					}
					in_entry = true
					current_field = nil
				elseif in_entry then
					local field, value = line:match('%s*(%w+)%s*=%s*[{"](.-)[}",]*$')
					if field and value then
						field = field:lower()
						value = value:gsub("[{}]", ""):gsub("^%s+", ""):gsub("%s+$", "")
						if field == "title" then
							current_entry.title = value
							current_field = "title"
						elseif field == "author" then
							current_entry.author = value:gsub("%s+and%s+", "; ")
							current_field = "author"
						elseif field == "year" then
							current_entry.year = value
							current_field = "year"
						elseif field == "date" and current_entry.year == "" then
							current_entry.year = value
							current_field = "date"
						elseif field == "journaltitle" then
							current_entry.journaltitle = value
							current_field = "journaltitle"
						elseif field == "abstract" then
							current_entry.abstract = value
							current_field = "abstract"
						else
							current_field = nil
						end
					else
						if current_field and line:match("^[^%s]+") == nil then
							local continued = line:gsub("[{}]", ""):gsub("^%s+", ""):gsub("%s+$", "")
							if current_field == "author" then
								continued = continued:gsub("%s+and%s+", "; ")
							end
							current_entry[current_field] = current_entry[current_field] .. " " .. continued
						end
					end

					if line:match("^%s*}%s*$") then
						in_entry = false
						current_field = nil
					end
				end
			end

			if current_entry.key then
				table.insert(citations, current_entry)
			end

			file:close()
			vim.list_extend(all_citations, citations)
		end
	end

	return all_citations
end

---------------------------------------------------------------------
-- Format citation for display
---------------------------------------------------------------------
local function format_citation_display(entry)
	local display = entry.key

	if entry.title and entry.title ~= "" then
		local title = entry.title
		display = display .. " │ " .. title
	end

	if entry.author and entry.author ~= "" then
		local authors = entry.author
		display = display .. " │ " .. authors
	end

	return display
end

---------------------------------------------------------------------
-- Create preview content as a string
---------------------------------------------------------------------
local function format_preview_content(entry)
	local lines = {}

	if entry.title and entry.title ~= "" then
		table.insert(lines, "Title: " .. entry.title)
		table.insert(lines, "")
	end

	if entry.author and entry.author ~= "" then
		table.insert(lines, "Author: " .. entry.author)
		table.insert(lines, "")
	end

	if entry.year and entry.year ~= "" then
		table.insert(lines, "Year: " .. entry.year)
		table.insert(lines, "")
	end

	if entry.journaltitle and entry.journaltitle ~= "" then
		table.insert(lines, "Journal: " .. entry.journaltitle)
		table.insert(lines, "")
	end

	if entry.abstract and entry.abstract ~= "" then
		table.insert(lines, "Abstract: " .. entry.abstract)
	end

	return table.concat(lines, "\n")
end

---------------------------------------------------------------------
-- Detect citation under cursor
---------------------------------------------------------------------
local function get_citation_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]

	-- Markdown-style: @key
	local pos = 1
	while true do
		local s, e = line:find("@[%w_%-:%.]+", pos)
		if not s then
			break
		end
		local key = line:sub(s + 1, e)
		local start0 = s - 1
		local end0 = e - 1
		if col >= start0 and col <= end0 then
			return {
				key = key,
				start_col = start0,
				end_col = end0,
				full_match = "@" .. key,
				style = "markdown",
			}
		end
		pos = e + 1
	end

	-- LaTeX-style: \cmd{...}
	local search_pos = 1
	while true do
		local s, e = line:find("\\%a+%s*{%s*[^{}]-%s*}", search_pos)
		if not s then
			break
		end
		local capture = line:sub(s, e)
		local cmd, inside = capture:match("\\(%a+)%s*{%s*([^{}]-)%s*}")
		if cmd and inside then
			local brace_open = line:find("{", s, true)
			local brace_close = line:find("}", brace_open, true)
			if brace_open and brace_close then
				local inner_search_pos = 1
				while true do
					local ks, ke = inside:find("[^,%s]+", inner_search_pos)
					if not ks then
						break
					end
					local abs_start_1 = brace_open + ks
					local abs_end_1 = brace_open + ke
					local abs_start0 = abs_start_1 - 1
					local abs_end0 = abs_end_1 - 1
					local key = inside:sub(ks, ke)

					if col >= abs_start0 and col <= abs_end0 then
						return {
							key = key,
							start_col = abs_start0,
							end_col = abs_end0,
							full_match = key,
							cmd = cmd,
							style = "latex",
							all_keys = (function()
								local t = {}
								for k in inside:gmatch("[^,%s]+") do
									table.insert(t, k)
								end
								return t
							end)(),
							cmd_start = s - 1,
							cmd_end = e - 1,
							brace_open = brace_open - 1,
							brace_close = brace_close - 1,
						}
					end

					inner_search_pos = ke + 1
				end
			end
		end
		search_pos = e + 1
	end

	return nil
end

---------------------------------------------------------------------
-- Cursor management helpers
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
-- Insert citation
---------------------------------------------------------------------
local function apply_insert_at_saved_context(saved, citation_keys, format)
	if not saved or not citation_keys or #citation_keys == 0 then
		return
	end

	format = format or "markdown"

	local insert_text
	if format == "latex" then
		insert_text = "\\cite{" .. table.concat(citation_keys, ", ") .. "}"
	else
		insert_text = table.concat(
			vim.tbl_map(function(k)
				return "@" .. k
			end, citation_keys),
			"; "
		)
	end

	if not vim.api.nvim_buf_is_valid(saved.buf) then
		return
	end
	if saved.win and vim.api.nvim_win_is_valid(saved.win) then
		pcall(vim.api.nvim_set_current_win, saved.win)
	end
	pcall(vim.api.nvim_set_current_buf, saved.buf)

	local row, col = saved.row, saved.col

	if not saved.was_insert_mode then
		col = col + 1
	end

	local ok = false
	if vim.api.nvim_buf_set_text then
		ok = pcall(function()
			vim.api.nvim_buf_set_text(saved.buf, row - 1, col, row - 1, col, { insert_text })
		end)
	end
	if not ok then
		pcall(vim.api.nvim_put, { insert_text }, "c", false, true)
	end

	set_cursor_after_inserted_text(saved.buf, saved.win, row, col, insert_text)
	if saved.was_insert_mode then
		reenter_insert_mode_at_cursor_for_buffer(saved.win, saved.buf, row, col, #insert_text)
	end

	vim.schedule(function()
		local msg = "Inserted citation" .. (#citation_keys > 1 and "s" or "") .. ": " .. insert_text
		vim.notify(msg, vim.log.levels.INFO)
	end)
end

---------------------------------------------------------------------
-- Replace citation under cursor
---------------------------------------------------------------------
local function replace_citation_at_cursor(saved, new_citation_key, citation_info)
	if not saved or not new_citation_key or not citation_info then
		return
	end

	local replacement
	if citation_info.style == "latex" then
		replacement = new_citation_key
	else
		replacement = "@" .. new_citation_key
	end

	if not vim.api.nvim_buf_is_valid(saved.buf) then
		return
	end
	if saved.win and vim.api.nvim_win_is_valid(saved.win) then
		pcall(vim.api.nvim_set_current_win, saved.win)
	end
	pcall(vim.api.nvim_set_current_buf, saved.buf)

	local row = saved.row
	local end_col_exclusive = citation_info.end_col + 1

	local ok = pcall(function()
		vim.api.nvim_buf_set_text(
			saved.buf,
			row - 1,
			citation_info.start_col,
			row - 1,
			end_col_exclusive,
			{ replacement }
		)
	end)

	if ok then
		set_cursor_after_inserted_text(saved.buf, saved.win, row, citation_info.start_col, replacement)
		if saved.was_insert_mode then
			reenter_insert_mode_at_cursor_for_buffer(saved.win, saved.buf, row, citation_info.start_col, #replacement)
		end
		vim.schedule(function()
			vim.notify("Replaced citation: " .. citation_info.key .. " → " .. new_citation_key, vim.log.levels.INFO)
		end)
	else
		vim.notify("Failed to replace citation", vim.log.levels.ERROR)
	end
end

---------------------------------------------------------------------
-- Custom previewer that inherits fzf-lua's styling
---------------------------------------------------------------------
local function create_citation_previewer(citations)
	local Previewer = require("fzf-lua.previewer.builtin")

	local MyPreviewer = Previewer.buffer_or_file:extend()

	function MyPreviewer:new(o, opts, fzf_win)
		MyPreviewer.super.new(self, o, opts, fzf_win)
		setmetatable(self, MyPreviewer)
		return self
	end

	function MyPreviewer:parse_entry(entry_str)
		-- Extract the citation key from the display string
		local key = entry_str:match("^([^%s│]+)")
		return { path = key }
	end

	function MyPreviewer:populate_preview_buf(entry_str)
		local key = entry_str:match("^([^%s│]+)")
		key = key:gsub(" %(current%)$", "")

		local citation = nil
		for _, cite in ipairs(citations) do
			if cite.key == key then
				citation = cite
				break
			end
		end

		if citation then
			local preview_lines = vim.split(format_preview_content(citation), "\n")

			-- Create buffer if it doesn't exist
			if not self.preview_bufnr or not vim.api.nvim_buf_is_valid(self.preview_bufnr) then
				self.preview_bufnr = vim.api.nvim_create_buf(false, true)
				vim.bo[self.preview_bufnr].bufhidden = "wipe"
			end

			-- Clear and populate buffer
			vim.api.nvim_buf_set_lines(self.preview_bufnr, 0, -1, false, preview_lines)
			self:set_preview_buf(self.preview_bufnr)
			self.preview_bufloaded = true
			return true
		end

		return false
	end

	return MyPreviewer
end

---------------------------------------------------------------------
-- fzf-lua picker for inserting citations
---------------------------------------------------------------------
local function citation_picker(format)
	local citations = {}
	for _, path in ipairs(bib_file) do
		local parsed = parse_bib_file(path)
		vim.list_extend(citations, parsed)
	end
	if #citations == 0 then
		vim.notify("No citations found in bib files", vim.log.levels.WARN)
		return
	end

	local cur_win = vim.api.nvim_get_current_win()
	local cur_buf = vim.api.nvim_get_current_buf()
	local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
	local was_insert = vim.api.nvim_get_mode().mode:find("i") ~= nil
	local saved = { win = cur_win, buf = cur_buf, row = cur_row, col = cur_col, was_insert_mode = was_insert }

	local prompt_title = format == "latex" and "Citations 󱔗 [LaTeX]" or "Citations 󱔗 [Markdown]"

	-- Create a lookup table for citations
	local citation_lookup = {}
	for _, entry in ipairs(citations) do
		citation_lookup[format_citation_display(entry)] = entry
	end

	local fzf = require("fzf-lua")

	fzf.fzf_exec(function(fzf_cb)
		for _, entry in ipairs(citations) do
			fzf_cb(format_citation_display(entry))
		end
		fzf_cb()
	end, {
		prompt = "> ",
		previewer = create_citation_previewer(citations),
		winopts = {
			title = prompt_title,
			preview = {
				layout = "vertical",
				vertical = "down:50%",
				wrap = "wrap",
				scrollbar = "border",
			},
		},
		actions = {
			["default"] = function(selected)
				if #selected == 0 then
					return
				end
				local keys = {}
				for _, line in ipairs(selected) do
					local entry = citation_lookup[line]
					if entry then
						table.insert(keys, entry.key)
					end
				end
				if #keys > 0 then
					table.sort(keys)
					apply_insert_at_saved_context(saved, keys, format)
				end
			end,
		},
	})
end

---------------------------------------------------------------------
-- Wrapper functions
---------------------------------------------------------------------
local function citation_picker_markdown()
	citation_picker("markdown")
end

local function citation_picker_latex()
	citation_picker("latex")
end

---------------------------------------------------------------------
-- Replace citation
---------------------------------------------------------------------
local function citation_replace()
	local citation_info = get_citation_under_cursor()
	if not citation_info then
		vim.notify("Cursor is not on a citation", vim.log.levels.WARN)
		return
	end

	local citations = parse_bib_file(bib_file)
	if #citations == 0 then
		vim.notify("No citations found in bib files", vim.log.levels.WARN)
		return
	end

	local cur_win = vim.api.nvim_get_current_win()
	local cur_buf = vim.api.nvim_get_current_buf()
	local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
	local saved = {
		win = cur_win,
		buf = cur_buf,
		row = cur_row,
		col = cur_col,
		was_insert_mode = vim.api.nvim_get_mode().mode:find("i") ~= nil,
	}

	local fzf = require("fzf-lua")

	fzf.fzf_exec(function(fzf_cb)
		for _, entry in ipairs(citations) do
			local display = format_citation_display(entry)
			if entry.key == citation_info.key then
				display = display .. " (current)"
			end
			fzf_cb(display)
		end
		fzf_cb()
	end, {
		prompt = "with> ",
		previewer = create_citation_previewer(citations),
		winopts = {
			title = "Replace citation @" .. citation_info.key,
			preview = {
				layout = "vertical",
				vertical = "up:50%",
				wrap = "wrap",
				scrollbar = "border",
			},
		},
		actions = {
			["default"] = function(selected)
				if #selected == 0 then
					return
				end
				local selected_line = selected[1]:gsub(" %(current%)$", "")
				for _, entry in ipairs(citations) do
					if format_citation_display(entry) == selected_line then
						if entry.key ~= citation_info.key then
							replace_citation_at_cursor(saved, entry.key, citation_info)
						else
							vim.schedule(function()
								vim.notify("Same citation selected, no replacement needed", vim.log.levels.INFO)
							end)
						end
						break
					end
				end
			end,
		},
	})
end

---------------------------------------------------------------------
-- Exports
---------------------------------------------------------------------
return {
	citation_picker = citation_picker_markdown,
	citation_picker_markdown = citation_picker_markdown,
	citation_picker_latex = citation_picker_latex,
	citation_replace = citation_replace,
	parse_bib_file = parse_bib_file,
}
