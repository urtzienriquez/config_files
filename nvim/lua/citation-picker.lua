-- Citation picker
-- Path to your .bib file (adjust as needed)
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
		-- Match entry start: @article{key, @book{key, etc.
		local entry_type, key = line:match("^%s*@(%w+)%s*{%s*([^,%s]+)")
		if entry_type and key then
			-- Save previous entry if exists
			if current_entry.key then
				table.insert(citations, current_entry)
			end
			-- Start new entry
			current_entry = {
				key = key,
				type = entry_type,
				title = "",
				author = "",
				year = "",
			}
			in_entry = true
		elseif in_entry then
			-- Extract title (handle multi-brace and quoted forms)
			local title = line:match('%s*title%s*=%s*[{"](.-)[}",]*$')
			if title then
				current_entry.title = current_entry.title .. " " .. title
				current_entry.title = current_entry.title:gsub("[{}]", ""):gsub("^%s+", ""):gsub("%s+$", "")
			end

			-- Extract author
			local author = line:match('%s*author%s*=%s*[{"](.-)[}",]*$')
			if author then
				current_entry.author = author:gsub("[{}]", "")
			end

			-- Extract year (or date if year missing)
			local year = line:match('%s*year%s*=%s*[{"]*(%d+)[}",]*')
			local date = line:match('%s*date%s*=%s*[{"]*(%d+)[}",]*')
			if year then
				current_entry.year = year
			elseif date then
				current_entry.year = date
			end

			-- End of entry
			if line:match("^%s*}%s*$") then
				in_entry = false
			end
		end
	end

	-- Add last entry
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
-- Robust insertion helper
---------------------------------------------------------------------
local function apply_insert_at_saved_context(saved, citation_key)
	if not saved or not citation_key then
		return
	end
	local insert_text = "@" .. citation_key

	if not vim.api.nvim_buf_is_valid(saved.buf) then
		vim.notify("Buffer for citation insertion is no longer valid", vim.log.levels.WARN)
		return
	end

	if saved.win and vim.api.nvim_win_is_valid(saved.win) then
		pcall(vim.api.nvim_set_current_win, saved.win)
	end
	pcall(vim.api.nvim_set_current_buf, saved.buf)

	local row, col = saved.row, saved.col

	-- Normal mode adjustment: move col after cursor for proper insertion
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
		-- fallback using nvim_put
		pcall(vim.api.nvim_put, { insert_text }, "c", false, true)
	end

	-- Set cursor after inserted text
	local line = vim.api.nvim_buf_get_lines(saved.buf, row - 1, row, false)[1] or ""
	local start_pos = line:find(insert_text, col + 1, true)
	local new_col0 = start_pos and (start_pos - 1 + #insert_text) or (col + #insert_text)
	pcall(vim.api.nvim_win_set_cursor, 0, { row, new_col0 })

	if saved.was_insert_mode then
		vim.cmd("startinsert!")
	end
end

---------------------------------------------------------------------
-- Simple picker wrapper
---------------------------------------------------------------------
local function simple_citation_picker()
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
-- Exports
---------------------------------------------------------------------
return {
	simple_citation_picker = simple_citation_picker,
	parse_bib_file = parse_bib_file,
}
