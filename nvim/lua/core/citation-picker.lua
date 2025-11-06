-- Citation picker with Telescope integration

-- Path to main zotero.bib
local zotero_bib = vim.fn.expand("~/Documents/zotero.bib")

-- Find local .bib files (in current working directory)
local local_bibs = vim.fn.globpath(vim.fn.getcwd(), "*.bib", false, true)

-- Combine all bib files into one list
local bib_file = { zotero_bib }
for _, b in ipairs(local_bibs) do
	if b ~= zotero_bib then
		table.insert(bib_file, b)
	end
end

---------------------------------------------------------------------
-- Parse one or more .bib files and extract citation keys with titles
---------------------------------------------------------------------
local function parse_bib_file(file_paths)
	-- Allow either a string or a table
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
				-- Detect new entry
				local entry_type, key = line:match("^%s*@(%w+)%s*{%s*([^,%s]+)")
				if entry_type and key then
					if current_entry.key then
						table.insert(citations, current_entry)
					end
					current_entry = {
						key = key,
						type = entry_type,
						title = "",
						shorttitle = "",
						author = "",
						year = "",
						journaltitle = "",
						abstract = "",
					}
					in_entry = true
					current_field = nil
				elseif in_entry then
					-- Field assignment
					local field, value = line:match('%s*(%w+)%s*=%s*[{"](.-)[}",]*$')
					if field and value then
						field = field:lower()
						value = value:gsub("[{}]", ""):gsub("^%s+", ""):gsub("%s+$", "")
						if field == "title" then
							current_entry.title = value
							current_field = "title"
						elseif field == "shorttitle" then
							current_entry.shorttitle = value
							current_field = "shorttitle"
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
						-- Handle multiline continuation
						if current_field and line:match("^[^%s]+") == nil then
							local continued = line:gsub("[{}]", ""):gsub("^%s+", ""):gsub("%s+$", "")
							if current_field == "author" then
								continued = continued:gsub("%s+and%s+", "; ")
							end
							current_entry[current_field] = current_entry[current_field] .. " " .. continued
						end
					end

					-- End of entry
					if line:match("^%s*}%s*$") then
						in_entry = false
						current_field = nil
					end
				end
			end

			-- Save last entry
			if current_entry.key then
				table.insert(citations, current_entry)
			end

			file:close()

			-- Merge citations from this file
			vim.list_extend(all_citations, citations)
		end
	end

	return all_citations
end

---------------------------------------------------------------------
-- Format citation for display in main picker
---------------------------------------------------------------------
local function format_citation_display(entry)
	local display = entry.key

	-- Add title if available
	if entry.title and entry.title ~= "" then
		local title = entry.title
		if #title > 40 then -- Reduced from 50 to make room for authors
			title = title:sub(1, 37) .. "..."
		end
		display = display .. " │ " .. title
	end

	-- Add authors if available
	if entry.author and entry.author ~= "" then
		local authors = entry.author
		if #authors > 30 then -- Truncate long author lists
			authors = authors:sub(1, 27) .. "..."
		end
		display = display .. " │ " .. authors
	end

	return display
end

---------------------------------------------------------------------
-- Wrap text to preview width
---------------------------------------------------------------------
local function wrap_text_to_width(text, width)
	local lines = {}
	while #text > 0 do
		local break_point = width
		local space_pos = text:sub(1, width):match(".*%s()")
		if space_pos then
			break_point = space_pos - 1
		end
		table.insert(lines, text:sub(1, break_point))
		text = text:sub(break_point + 1):gsub("^%s+", "")
	end
	return lines
end

---------------------------------------------------------------------
-- Create preview content (compact single-line labels)
---------------------------------------------------------------------
local function create_preview_content(entry, winid)
	local lines = {}

	local width = 80
	if winid and vim.api.nvim_win_is_valid(winid) then
		width = vim.api.nvim_win_get_width(winid) - 10
	end

	local function wrap_field(label, text)
		if not text or text == "" then
			return
		end
		local line_prefix = label .. ": "
		local first_line_width = width - #line_prefix
		local wrapped = wrap_text_to_width(text, first_line_width)
		if #wrapped > 0 then
			lines[#lines + 1] = line_prefix .. table.remove(wrapped, 1)
			for _, l in ipairs(wrapped) do
				lines[#lines + 1] = string.rep(" ", #line_prefix) .. l
			end
		end
	end

	wrap_field("Title", entry.title)
	wrap_field("Author", entry.author)
	wrap_field("Year", entry.date ~= "" and entry.date or entry.year)
	wrap_field("Journal", entry.journaltitle)
	wrap_field("Abstract", entry.abstract)

	return lines
end

---------------------------------------------------------------------
-- Calculate match score
---------------------------------------------------------------------
local function calculate_match_score(entry, query)
	if not query or query == "" then
		-- When no query, return 0 so all entries have the same score
		-- We'll handle default sorting in the sorter setup
		return 0
	end
	local score = 0
	local query_lower = query:lower()
	local searchable_text = (entry.key .. " " .. (entry.title or "") .. " " .. (entry.author or "")):lower()

	if entry.key:lower() == query_lower then
		score = score + 1000
	end
	if entry.key:lower():find("^" .. vim.pesc(query_lower)) then
		score = score + 500
	end
	local key_match = entry.key:lower():find(vim.pesc(query_lower))
	if key_match then
		score = score + 300 - key_match
	end
	if entry.title and entry.title:lower() == query_lower then
		score = score + 800
	end
	if entry.title and entry.title:lower():find("^" .. vim.pesc(query_lower)) then
		score = score + 400
	end
	if entry.title then
		local title_match = entry.title:lower():find(vim.pesc(query_lower))
		if title_match then
			score = score + 200 - (title_match / 2)
		end
	end
	if entry.author then
		local author_match = entry.author:lower():find(vim.pesc(query_lower))
		if author_match then
			score = score + 100 - (author_match / 2)
		end
	end

	local longest_match = 0
	for word in query_lower:gmatch("%S+") do
		local match_start, match_end = searchable_text:find(vim.pesc(word))
		if match_start then
			longest_match = math.max(longest_match, match_end - match_start + 1)
		end
	end
	score = score + longest_match * 10
	return score
end

---------------------------------------------------------------------
-- Helpers for inserting/replacing citations
---------------------------------------------------------------------

-- Detect citation under cursor (Markdown @key or LaTeX \cite{key,...})
local function get_citation_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] -- 0-based

	-- --- Markdown-style: @key ---
	local pos = 1
	while true do
		local s, e = line:find("@[%w_%-:%.]+", pos)
		if not s then
			break
		end
		local key = line:sub(s + 1, e) -- without the @
		local start0 = s - 1 -- convert to 0-based
		local end0 = e - 1 -- convert to 0-based
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

	-- --- LaTeX-style: \cmd{...} (may contain multiple comma-separated keys) ---
	local search_pos = 1
	while true do
		-- find next \cmd{...} block (simple pattern matching)
		local s, e = line:find("\\%a+%s*{%s*[^{}]-%s*}", search_pos)
		if not s then
			break
		end
		local capture = line:sub(s, e)
		local cmd, inside = capture:match("\\(%a+)%s*{%s*([^{}]-)%s*}")
		if cmd and inside then
			-- find positions of the braces
			local brace_open = line:find("{", s, true)
			local brace_close = line:find("}", brace_open, true)
			if brace_open and brace_close then
				-- iterate keys inside the braces and locate their absolute positions
				local inner_search_pos = 1
				while true do
					local ks, ke = inside:find("[^,%s]+", inner_search_pos)
					if not ks then
						break
					end
					-- absolute 1-based positions on the line for this key:
					local abs_start_1 = brace_open + ks -- brace_open is pos of '{', inside starts at brace_open+1
					local abs_end_1 = brace_open + ke
					local abs_start0 = abs_start_1 - 1
					local abs_end0 = abs_end_1 - 1
					local key = inside:sub(ks, ke)

					if col >= abs_start0 and col <= abs_end0 then
						-- Found the key under cursor
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

-- Modified function with format parameter
local function apply_insert_at_saved_context(saved, citation_keys, format)
	if not saved or not citation_keys or #citation_keys == 0 then
		return
	end

	-- Default to markdown format if not specified
	format = format or "markdown"

	local insert_text
	if format == "latex" then
		insert_text = "\\cite{" .. table.concat(citation_keys, ", ") .. "}"
	else -- markdown format
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

	-- In normal mode, move cursor position one character to the right
	-- so text is inserted after the cursor character, not before it
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
	vim.notify("Inserted citation" .. (#citation_keys > 1 and "s" or "") .. ": " .. insert_text, vim.log.levels.INFO)
end

-- Replace citation under cursor (Markdown or LaTeX)
local function replace_citation_at_cursor(saved, new_citation_key, citation_info)
  if not saved or not new_citation_key or not citation_info then
    return
  end

  -- replacement string depends on style:
  -- - LaTeX: replace only the key inside the braces (keep commas/spaces)
  -- - Markdown: replace whole "@key" with "@newkey"
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
  -- nvim_buf_set_text uses end column as *exclusive*, so add 1 to the inclusive end_col
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
    -- Move cursor after inserted text. set_cursor_after_inserted_text expects inserted_text (string).
    set_cursor_after_inserted_text(saved.buf, saved.win, row, citation_info.start_col, replacement)
    if saved.was_insert_mode then
      reenter_insert_mode_at_cursor_for_buffer(saved.win, saved.buf, row, citation_info.start_col, #replacement)
    end
    vim.notify("Replaced citation: " .. citation_info.key .. " → " .. new_citation_key, vim.log.levels.INFO)
  else
    vim.notify("Failed to replace citation", vim.log.levels.ERROR)
  end
end

---------------------------------------------------------------------
-- Telescope picker for inserting new citations with multi-select
-- Modified to accept format parameter
---------------------------------------------------------------------
local function citation_picker(format)
	-- Support multiple bib files
	local citations = {}
	for _, path in ipairs(bib_file) do
		local parsed = parse_bib_file(path)
		vim.list_extend(citations, parsed)
	end
	if #citations == 0 then
		vim.notify("No citations found in " .. bib_file, vim.log.levels.WARN)
		return
	end

	local cur_win = vim.api.nvim_get_current_win()
	local cur_buf = vim.api.nvim_get_current_buf()
	local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
	local was_insert = vim.api.nvim_get_mode().mode:find("i") ~= nil
	local saved = { win = cur_win, buf = cur_buf, row = cur_row, col = cur_col, was_insert_mode = was_insert }

	-- Determine prompt title based on format
	local prompt_title
	if format == "latex" then
		prompt_title = "Citations 󱔗 [LaTeX]"
	else
		prompt_title = "Citations 󱔗 [Markdown]"
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")
	local multi_select = require("telescope.actions.mt").transform_mod({
		toggle_selection = function(prompt_bufnr)
			actions.toggle_selection(prompt_bufnr)
			local picker = action_state.get_current_picker(prompt_bufnr)
			picker:reset_prompt()
			actions.move_selection_next(prompt_bufnr)
		end,
	})

	local custom_sorter = conf.generic_sorter({})
	local original_scoring_function = custom_sorter.scoring_function
	custom_sorter.scoring_function = function(self, prompt, line, entry)
		if not entry or not entry.value then
			return original_scoring_function(self, prompt, line, entry)
		end

		-- If no prompt (empty search), sort alphabetically by citation key
		if not prompt or prompt == "" then
			-- Create a numeric score based on alphabetical order
			-- Use character codes to create proper alphabetical ordering
			local key = entry.value.key:lower()
			local score = 0
			-- Use first few characters to create ordering
			for i = 1, math.min(#key, 8) do
				local char_code = key:byte(i)
				score = score + (char_code * math.pow(256, 8 - i))
			end
			return score
		end

		-- Otherwise use our custom scoring
		return -calculate_match_score(entry.value, prompt)
	end

	local previewer = previewers.new_buffer_previewer({
		title = "Citation Details",
		define_preview = function(self, entry)
			local content = create_preview_content(entry.value, self.state.winid)
			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content)
			vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "text")
			vim.api.nvim_buf_set_option(self.state.bufnr, "wrap", true)
		end,
	})

	pickers
		.new({}, {
			prompt_title = prompt_title,
			finder = finders.new_table({
				results = citations,
				entry_maker = function(entry)
					return {
						value = entry,
						display = format_citation_display(entry),
						ordinal = entry.key .. " " .. (entry.title or "") .. " " .. (entry.author or ""),
					}
				end,
			}),
			sorter = custom_sorter,
			previewer = previewer,
			attach_mappings = function(prompt_bufnr, map)
				map({ "i", "n" }, "<Tab>", multi_select.toggle_selection)
				actions.select_default:replace(function()
					local selections = {}
					local picker = action_state.get_current_picker(prompt_bufnr)
					for entry in picker.manager:iter() do
						if picker:is_multi_selected(entry) then
							table.insert(selections, entry.value.key)
						end
					end
					if #selections == 0 then
						local current_entry = action_state.get_selected_entry()
						if current_entry then
							table.insert(selections, current_entry.value.key)
						end
					end
					actions.close(prompt_bufnr)
					if #selections > 0 then
						table.sort(selections)
						apply_insert_at_saved_context(saved, selections, format)
					end
				end)
				return true
			end,
		})
		:find()
end

---------------------------------------------------------------------
-- Wrapper functions for different formats
---------------------------------------------------------------------
local function citation_picker_markdown()
	citation_picker("markdown")
end

local function citation_picker_latex()
	citation_picker("latex")
end

---------------------------------------------------------------------
-- Telescope picker for replacing citations (single selection)
---------------------------------------------------------------------
local function citation_replace()
	local citation_info = get_citation_under_cursor()
	if not citation_info then
		vim.notify("Cursor is not on a citation", vim.log.levels.WARN)
		return
	end

	local citations = parse_bib_file(bib_file)
	if #citations == 0 then
		vim.notify("No citations found in " .. bib_file, vim.log.levels.WARN)
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

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	local custom_sorter = conf.generic_sorter({})
	local original_scoring_function = custom_sorter.scoring_function
	custom_sorter.scoring_function = function(self, prompt, line, entry)
		if not entry or not entry.value then
			return original_scoring_function(self, prompt, line, entry)
		end

		-- If no prompt (empty search), sort alphabetically by citation key
		if not prompt or prompt == "" then
			-- Create a numeric score based on alphabetical order
			local key = entry.value.key:lower()
			local score = 0
			-- Use first few characters to create ordering
			for i = 1, math.min(#key, 8) do
				local char_code = key:byte(i)
				score = score + (char_code * math.pow(256, 8 - i))
			end
			return score
		end

		-- Otherwise use our custom scoring
		return -calculate_match_score(entry.value, prompt)
	end

	local previewer = previewers.new_buffer_previewer({
		title = "Citation Details",
		define_preview = function(self, entry)
			local content = create_preview_content(entry.value, self.state.winid)
			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content)
			vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "text")
			vim.api.nvim_buf_set_option(self.state.bufnr, "wrap", true)
		end,
	})

	pickers
		.new({}, {
			prompt_title = "Replace citation @" .. citation_info.key .. " with:",
			finder = finders.new_table({
				results = citations,
				entry_maker = function(entry)
					local display = format_citation_display(entry)
					if entry.key == citation_info.key then
						display = display .. " (current)"
					end
					return {
						value = entry,
						display = display,
						ordinal = entry.key .. " " .. (entry.title or "") .. " " .. (entry.author or ""),
					}
				end,
			}),
			sorter = custom_sorter,
			previewer = previewer,
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection and selection.value.key ~= citation_info.key then
						replace_citation_at_cursor(saved, selection.value.key, citation_info)
					else
						vim.notify("Same citation selected, no replacement needed", vim.log.levels.INFO)
					end
				end)
				return true
			end,
		})
		:find()
end

---------------------------------------------------------------------
-- Exports
---------------------------------------------------------------------
return {
	citation_picker = citation_picker_markdown, -- default to markdown
	citation_picker_markdown = citation_picker_markdown,
	citation_picker_latex = citation_picker_latex,
	citation_replace = citation_replace,
	parse_bib_file = parse_bib_file,
}
