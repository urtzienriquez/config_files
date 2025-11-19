-- Statusline with colored filetype icons and reliable git status

-- --------------------------
-- Colors
-- --------------------------
local colors = {
	green = "#9ece6a",
	red = "#f7768e",
	blue = "#7aa2f7",
	purple = "#c099ff",
	blue2 = "#0db9d7",
	teal = "#4fd6be",
	yellow = "#ffc777",
	fg = "#c0caf5",
}

local devicons = require("nvim-web-devicons")

-- Highlight groups
local function define_highlights()
	vim.api.nvim_set_hl(0, "SLGitAdd", { fg = colors.green })
	vim.api.nvim_set_hl(0, "SLGitChange", { fg = colors.blue })
	vim.api.nvim_set_hl(0, "SLGitDelete", { fg = colors.red })
	vim.api.nvim_set_hl(0, "SLGitBranch", { fg = colors.purple })

	-- Diagnostics
	vim.api.nvim_set_hl(0, "SLDiagError", { fg = colors.red })
	vim.api.nvim_set_hl(0, "SLDiagWarn", { fg = colors.yellow })
	vim.api.nvim_set_hl(0, "SLDiagInfo", { fg = colors.blue2 })
	vim.api.nvim_set_hl(0, "SLDiagHint", { fg = colors.teal })

	-- Filetype text (non-icon part)
	vim.api.nvim_set_hl(0, "SLFileType", { fg = colors.fg, bold = true })
end

define_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = define_highlights })

-- --------------------------
-- Git cache
-- --------------------------
local git_cache = {}

-- Get git root for buffer
local function get_git_root(bufnr)
	local path = vim.api.nvim_buf_get_name(bufnr)
	if path == "" then
		return nil
	end
	local dir = vim.fn.fnamemodify(path, ":p:h")
	local cmd = string.format("git -C %s rev-parse --show-toplevel 2>/dev/null", vim.fn.shellescape(dir))
	local root = vim.fn.system(cmd):gsub("\n", "")
	return root ~= "" and root or nil
end

-- --------------------------
-- Simple synchronous git status update
-- --------------------------
local function update_git(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
		return
	end

	local root = get_git_root(bufnr)
	if not root then
		git_cache[bufnr] = { branch = "", added = 0, modified = 0, removed = 0 }
		return
	end

	-- Get branch name
	local branch_cmd = string.format("git -C %s rev-parse --abbrev-ref HEAD 2>/dev/null", vim.fn.shellescape(root))
	local branch = vim.fn.system(branch_cmd):gsub("\n", "")

	-- Get diff stats for uncommitted changes (staged + unstaged)
	-- This shows line insertions/deletions, not file counts
	local diff_cmd = string.format("git -C %s diff --numstat HEAD 2>/dev/null", vim.fn.shellescape(root))
	local diff_output = vim.fn.system(diff_cmd)

	local added = 0
	local removed = 0

	-- Parse numstat output: "additions deletions filename"
	for line in diff_output:gmatch("[^\r\n]+") do
		local adds, dels = line:match("^(%d+)%s+(%d+)")
		if adds and dels then
			added = added + tonumber(adds)
			removed = removed + tonumber(dels)
		end
	end

	-- Check if there are any uncommitted changes at all
	local status_cmd = string.format("git -C %s status --porcelain 2>/dev/null", vim.fn.shellescape(root))
	local status_output = vim.fn.system(status_cmd)
	local has_changes = status_output ~= ""

	-- If no changes reported by status, zero out the counts
	-- This handles the case where diff might show stale data
	if not has_changes then
		added = 0
		removed = 0
	end

	git_cache[bufnr] = {
		branch = branch,
		added = added,
		removed = removed,
	}
end

-- --------------------------
-- Statusline functions
-- --------------------------

function _G.st_branch()
	local buf = vim.api.nvim_get_current_buf()
	local g = git_cache[buf]
	if not g or g.branch == "" then
		return ""
	end
	return " " .. g.branch
end

function _G.st_added()
	local buf = vim.api.nvim_get_current_buf()
	local g = git_cache[buf]
	if not g or g.added == 0 then
		return ""
	end
	return "+" .. g.added
end

function _G.st_changed()
	local buf = vim.api.nvim_get_current_buf()
	local g = git_cache[buf]
	if not g then
		return ""
	end
	local total = g.added + g.removed
	if total == 0 then
		return ""
	end
	return "~" .. total
end

function _G.st_removed()
	local buf = vim.api.nvim_get_current_buf()
	local g = git_cache[buf]
	if not g or g.removed == 0 then
		return ""
	end
	return "-" .. g.removed
end

-- Cache for icon highlight groups
local icon_hl_cache = {}

function _G.st_filetype_text()
	local path = vim.api.nvim_buf_get_name(0)
	local filename = vim.fn.fnamemodify(path, ":t")
	local extension = vim.fn.fnamemodify(path, ":e")

	local icon, icon_color = devicons.get_icon_color(filename, extension, { default = true })
	local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or ""

	if filetype == "" then
		return ""
	end

	if icon and icon_color then
		local hl_name = "SLFileIcon_" .. icon_color:gsub("#", "")
		if not icon_hl_cache[hl_name] then
			vim.api.nvim_set_hl(0, hl_name, { fg = icon_color })
			icon_hl_cache[hl_name] = true
		end
		return string.format("%%#%s#%s %%#SLFileType#%s%%*", hl_name, icon, filetype)
	else
		return filetype
	end
end

-- --------------------------
-- Diagnostics
-- --------------------------
local function diag_count(sev)
	return #vim.diagnostic.get(0, { severity = sev })
end

function _G.st_err()
	local c = diag_count(vim.diagnostic.severity.ERROR)
	return c > 0 and (" " .. c) or ""
end

function _G.st_warn()
	local c = diag_count(vim.diagnostic.severity.WARN)
	return c > 0 and (" " .. c) or ""
end

function _G.st_info()
	local c = diag_count(vim.diagnostic.severity.INFO)
	return c > 0 and ("󰋽 " .. c) or ""
end

function _G.st_hint()
	local c = diag_count(vim.diagnostic.severity.HINT)
	return c > 0 and (" " .. c) or ""
end

-- --------------------------
-- Refresh triggers
-- --------------------------

-- Update on buffer enter and after writing
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained" }, {
	callback = function(args)
		update_git(args.buf)
		vim.cmd("redrawstatus")
	end,
})

-- Only refresh on CursorHold (when idle for 'updatetime' ms)
-- This is much less aggressive than a timer
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
			update_git(buf)
			vim.cmd("redrawstatus")
		end
	end,
})

-- Manual refresh command
vim.api.nvim_create_user_command("GitStatusRefresh", function()
	update_git(vim.api.nvim_get_current_buf())
	vim.cmd("redrawstatus")
	vim.notify("Git status refreshed", vim.log.levels.INFO)
end, {})

-- --------------------------
-- Final statusline
-- --------------------------
vim.o.laststatus = 3
vim.o.statusline = table.concat({
	" %t %m ",
	"%#SLGitBranch#%{v:lua.st_branch()}%*  ",
	"%#SLGitAdd#%{v:lua.st_added()}%* ",
	"%#SLGitChange#%{v:lua.st_changed()}%* ",
	"%#SLGitDelete#%{v:lua.st_removed()}%*  ",

	-- Diagnostics
	"%#SLDiagError#%{v:lua.st_err()}%* ",
	"%#SLDiagWarn#%{v:lua.st_warn()}%* ",
	"%#SLDiagInfo#%{v:lua.st_info()}%* ",
	"%#SLDiagHint#%{v:lua.st_hint()}%*  ",

	"%=",
	"%{%v:lua.st_filetype_text()%}  ",
	" %l:%c ",
})
