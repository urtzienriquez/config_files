-- Citation picker
local bib_file = vim.fn.expand("~/Documents/zotero.bib")

---------------------------------------------------------------------
-- Parse .bib file and extract citation keys with titles
---------------------------------------------------------------------
local function parse_bib_file(file_path)
	local citations = {}
	local file = io.open(file_path, "r")
	if not file then
		return citations
	end

	local current_entry = {}
	local in_entry = false

	for line in file:lines() do
		local entry_type, key = line:match("^%s*@(%w+)%s*{%s*([^,%s]+)")
		if entry_type and key then
			if current_entry.key then
				table.insert(citations, current_entry)
			end
			current_entry = {
				key = key,
				type = entry_type,
				title = "",
				author = "",
				year = "",
			}
			in_entry = true
		elseif in_entry then
			local title = line:match('%s*title%s*=%s*[{"](.-)[}",]*$')
			if title then
				current_entry.title = current_entry.title .. " " .. title
				current_entry.title = current_entry.title:gsub("[{}]", ""):gsub("^%s+", ""):gsub("%s+$", "")
			end
			local author = line:match('%s*author%s*=%s*[{"](.-)[}",]*$')
			if author then
				current_entry.author = author:gsub("[{}]", "")
			end
			local year = line:match('%s*year%s*=%s*[{"]*(%d+)[}",]*')
			local date = line:match('%s*date%s*=%s*[{"]*(%d+)[}",]*')
			if year then
				current_entry.year = year
			elseif date then
				current_entry.year = date
			end
			if line:match("^%s*}%s*$") then
				in_entry = false
			end
		end
	end

	if current_entry.key then
		table.insert(citations, current_entry)
	end

	file:close()
	return citations
end

---------------------------------------------------------------------
-- Format citation entries for display: key | title only
---------------------------------------------------------------------
local function format_citation_entry(entry)
	local display = entry.key
	if entry.title and entry.title ~= "" then
		display = display .. " | " .. entry.title:sub(1, 60)
		if #entry.title > 60 then
			display = display .. "..."
		end
	end
	return display
end

---------------------------------------------------------------------
-- Helper function to detect if cursor is on a citation
---------------------------------------------------------------------
local function get_citation_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]

	local pos = 1
	for citation in line:gmatch("@([%w_%-:%.]+)") do
		local start_pos, end_pos = line:find("@" .. citation, pos, true)
		if start_pos and col >= start_pos - 1 and col <= end_pos then
			return {
				key = citation,
				start_col = start_pos - 1,
				end_col = end_pos,
				full_match = "@" .. citation,
			}
		end
		pos = end_pos and end_pos + 1 or pos + 1
	end
	return nil
end

---------------------------------------------------------------------
-- Helpers: cursor management
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

	-- Get current line after insertion
	local ok, lines = pcall(vim.api.nvim_buf_get_lines, buf, row - 1, row, false)
	local line = (ok and lines and #lines > 0) and lines[1] or ""

	-- Determine cursor column after insertion
	local cursor_col = col + inserted_text_len
	pcall(vim.api.nvim_win_set_cursor, winid, { row, cursor_col })

	-- Feed "i" if there is text after the inserted citation, "a" if at end of line
	local key
	if cursor_col >= #line then
		key = vim.api.nvim_replace_termcodes("a", true, false, true)
	else
		key = vim.api.nvim_replace_termcodes("i", true, false, true)
	end
	pcall(vim.api.nvim_feedkeys, key, "n", true)
end

---------------------------------------------------------------------
-- Insert citation
---------------------------------------------------------------------
local function apply_insert_at_saved_context(saved, citation_key)
	if not saved or not citation_key then
		return
	end
	local insert_text = "@" .. citation_key

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
end

---------------------------------------------------------------------
-- Replace citation
---------------------------------------------------------------------
local function replace_citation_at_cursor(saved, new_citation_key, citation_info)
	if not saved or not new_citation_key or not citation_info then
		return
	end

	local new_text = "@" .. new_citation_key

	if not vim.api.nvim_buf_is_valid(saved.buf) then
		return
	end

	if saved.win and vim.api.nvim_win_is_valid(saved.win) then
		pcall(vim.api.nvim_set_current_win, saved.win)
	end
	pcall(vim.api.nvim_set_current_buf, saved.buf)

	local row = saved.row

	local ok = pcall(function()
		vim.api.nvim_buf_set_text(
			saved.buf,
			row - 1,
			citation_info.start_col,
			row - 1,
			citation_info.end_col,
			{ new_text }
		)
	end)

	if ok then
		set_cursor_after_inserted_text(saved.buf, saved.win, row, citation_info.start_col, new_text)
		if saved.was_insert_mode then
			reenter_insert_mode_at_cursor_for_buffer(saved.win, saved.buf, row, citation_info.start_col, #new_text)
		end
		vim.notify("Replaced citation: " .. citation_info.key .. " → " .. new_citation_key, vim.log.levels.INFO)
	else
		vim.notify("Failed to replace citation", vim.log.levels.ERROR)
	end
end

---------------------------------------------------------------------
-- Picker for inserting new citations
---------------------------------------------------------------------
local function citation_picker()
	local citations = parse_bib_file(bib_file)
	if #citations == 0 then
		vim.notify("No citations found in " .. bib_file, vim.log.levels.WARN)
		return
	end

	local items = {}
	for _, e in ipairs(citations) do
		table.insert(items, { display = format_citation_entry(e), key = e.key, entry = e })
	end

	local cur_win = vim.api.nvim_get_current_win()
	local cur_buf = vim.api.nvim_get_current_buf()
	local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
	local was_insert = vim.api.nvim_get_mode().mode:find("i") ~= nil
	local saved = { win = cur_win, buf = cur_buf, row = cur_row, col = cur_col, was_insert_mode = was_insert }

	vim.ui.select(items, {
		prompt = "Citations 󱔗 ",
		format_item = function(item)
			return item.display
		end,
	}, function(choice)
		if choice then
			apply_insert_at_saved_context(saved, choice.key)
		end
	end)
end

---------------------------------------------------------------------
-- Picker for replacing citations
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

	local items = {}
	for _, e in ipairs(citations) do
		local display = format_citation_entry(e)
		if e.key == citation_info.key then
			display = display .. " (current)"
		end
		table.insert(items, { display = display, key = e.key, entry = e })
	end

	local cur_win = vim.api.nvim_get_current_win()
	local cur_buf = vim.api.nvim_get_current_buf()
	local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
	local saved = { win = cur_win, buf = cur_buf, row = cur_row, col = cur_col, was_insert_mode = vim.api.nvim_get_mode().mode:find("i") ~= nil }

	vim.ui.select(items, {
		prompt = "Replace citation @" .. citation_info.key .. " with: ",
		format_item = function(item)
			return item.display
		end,
	}, function(choice)
		if choice then
			if choice.key ~= citation_info.key then
				replace_citation_at_cursor(saved, choice.key, citation_info)
			else
				vim.notify("Same citation selected, no replacement needed", vim.log.levels.INFO)
			end
		end
	end)
end

---------------------------------------------------------------------
-- Exports
---------------------------------------------------------------------
return {
	citation_picker = citation_picker,
	citation_replace = citation_replace,
	parse_bib_file = parse_bib_file,
}

