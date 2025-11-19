-- Statusline with colored filetype icons and improved git refresh

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
-- Git cache and root cache
-- --------------------------
local git_cache = {} -- cache per buffer
local git_root_cache = {} -- store .git root per buffer
local pending_updates = {} -- track pending async updates to avoid duplicate calls

-- Get git root for buffer (cached)
local function get_git_root(buf)
	local path = vim.api.nvim_buf_get_name(buf)
	if path == "" then
		return nil
	end
	if git_root_cache[path] then
		return git_root_cache[path]
	end
	local dir = vim.fn.fnamemodify(path, ":p:h")
	local root = vim.fn.finddir(".git", dir .. ";")
	git_root_cache[path] = root ~= "" and vim.fn.fnamemodify(root, ":h") or nil
	return git_root_cache[path]
end

-- --------------------------
-- Async Git runner
-- --------------------------
local function run_async(cmd, cwd, callback)
	local stdout = vim.loop.new_pipe(false)
	local handle

	handle = vim.loop.spawn("bash", {
		args = { "-c", cmd },
		stdio = { nil, stdout, nil },
		cwd = cwd,
	}, function()
		stdout:close()
		handle:close()
	end)

	if not handle then
		return
	end

	stdout:read_start(function(err, data)
		if err or not data then
			return
		end
		vim.schedule_wrap(callback)(data)
	end)
end

-- --------------------------
-- Update Git info with debouncing
-- --------------------------
local function update_git(buf, force)
	local root = get_git_root(buf)
	if not root then
		git_cache[buf] = { branch = "", added = "", changed = "", removed = "" }
		return
	end

	-- Prevent duplicate updates unless forced
	if not force and pending_updates[buf] then
		return
	end
	pending_updates[buf] = true

	git_cache[buf] = git_cache[buf] or {}

	-- Branch
	run_async("git rev-parse --abbrev-ref HEAD 2>/dev/null", root, function(data)
		git_cache[buf].branch = data:gsub("\n", "")
		pending_updates[buf] = nil
		vim.api.nvim_command("redrawstatus")
	end)

	-- Diff stats (both staged and unstaged)
	run_async("git diff --numstat HEAD 2>/dev/null", root, function(data)
		local added, removed = 0, 0
		for a, r in data:gmatch("(%d+)%s+(%d+)") do
			added = added + tonumber(a)
			removed = removed + tonumber(r)
		end
		git_cache[buf].added = added > 0 and ("+" .. added) or ""
		git_cache[buf].changed = (added + removed) > 0 and ("~" .. (added + removed)) or ""
		git_cache[buf].removed = removed > 0 and ("-" .. removed) or ""
		vim.api.nvim_command("redrawstatus")
	end)
end

-- --------------------------
-- Statusline functions
-- --------------------------

-- Git
function _G.st_branch()
	local buf = vim.api.nvim_get_current_buf()
	local g = git_cache[buf] or {}
	return (g.branch or "") ~= "" and " " .. g.branch or ""
end

function _G.st_added()
	local buf = vim.api.nvim_get_current_buf()
	local g = git_cache[buf] or {}
	return g.added or ""
end

function _G.st_changed()
	local buf = vim.api.nvim_get_current_buf()
	local g = git_cache[buf] or {}
	return g.changed or ""
end

function _G.st_removed()
	local buf = vim.api.nvim_get_current_buf()
	local g = git_cache[buf] or {}
	return g.removed or ""
end

-- Cache for icon highlight groups to avoid recreating them
local icon_hl_cache = {}

-- Filetype with colored icon - returns just the text parts
function _G.st_filetype_text()
	local path = vim.api.nvim_buf_get_name(0)
	local filename = vim.fn.fnamemodify(path, ":t")
	local extension = vim.fn.fnamemodify(path, ":e")

	local icon, icon_color = devicons.get_icon_color(filename, extension, { default = true })
	local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or ""

	if filetype == "" then
		return ""
	end

	-- Create/cache highlight group for this icon
	if icon and icon_color then
		local hl_name = "SLFileIcon_" .. icon_color:gsub("#", "")
		if not icon_hl_cache[hl_name] then
			vim.api.nvim_set_hl(0, hl_name, { fg = icon_color })
			icon_hl_cache[hl_name] = true
		end
		-- Return in a format that statusline can parse
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
-- Autocmd to refresh Git info
-- --------------------------

-- Update on buffer events
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
	callback = function()
		update_git(vim.api.nvim_get_current_buf())
	end,
})

-- Watch for git directory changes (commits, checkouts, pushes, etc.)
vim.api.nvim_create_autocmd("FocusGained", {
	callback = function()
		-- Force refresh when window regains focus (e.g., after git commands in terminal)
		update_git(vim.api.nvim_get_current_buf(), true)
	end,
})

-- Detect tmux pane focus changes (for lazygit popup workflows)
if vim.env.TMUX then
	local last_check_time = 0
	local check_interval = 500 -- Check every 500ms

	local function check_tmux_focus()
		local current_time = vim.loop.now()
		if current_time - last_check_time < check_interval then
			return
		end
		last_check_time = current_time

		-- Check if we're the active pane
		local handle = io.popen("tmux display-message -p '#{pane_active}'")
		if handle then
			local is_active = handle:read("*l")
			handle:close()
			
			if is_active == "1" then
				-- We just became active, refresh git status
				local buf = vim.api.nvim_get_current_buf()
				if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
					update_git(buf, true)
				end
			end
		end
	end

	-- Check on cursor movement (lightweight check)
	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
		callback = check_tmux_focus,
	})

	-- Also check on mode changes
	vim.api.nvim_create_autocmd("ModeChanged", {
		callback = check_tmux_focus,
	})
end

-- Fallback periodic refresh (every 3 seconds when idle)
local timer = vim.loop.new_timer()
timer:start(3000, 3000, vim.schedule_wrap(function()
	local buf = vim.api.nvim_get_current_buf()
	if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
		update_git(buf, true)
	end
end))

-- Add a user command to manually refresh git status
vim.api.nvim_create_user_command("GitStatusRefresh", function()
	local buf = vim.api.nvim_get_current_buf()
	pending_updates[buf] = nil -- Clear pending flag
	git_cache[buf] = nil -- Clear cache
	update_git(buf, true)
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
