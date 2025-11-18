-- Statusline

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

local devicons = require('nvim-web-devicons')

-- Highlight groups
local function define_highlights()
	vim.api.nvim_set_hl(0, "SLGitAdd", { fg = colors.green })
	vim.api.nvim_set_hl(0, "SLGitChange", { fg = colors.blue })
	vim.api.nvim_set_hl(0, "SLGitDelete", { fg = colors.red })
	vim.api.nvim_set_hl(0, "SLGitBranch", { fg = colors.purple })
	vim.api.nvim_set_hl(0, "SLFileType", { fg = colors.fg, bold = true })

	-- Diagnostics
	vim.api.nvim_set_hl(0, "SLDiagError", { fg = colors.red })
	vim.api.nvim_set_hl(0, "SLDiagWarn", { fg = colors.yellow })
	vim.api.nvim_set_hl(0, "SLDiagInfo", { fg = colors.blue2 })
	vim.api.nvim_set_hl(0, "SLDiagHint", { fg = colors.teal })
end

define_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = define_highlights })

-- --------------------------
-- Git cache and root cache
-- --------------------------
local git_cache = {} -- cache per buffer
local git_root_cache = {} -- store .git root per buffer

-- Get git root for buffer (cached)
local function get_git_root(buf)
	local path = vim.api.nvim_buf_get_name(buf)
	if git_root_cache[path] then
		return git_root_cache[path]
	end
	local dir = vim.fn.fnamemodify(path, ":p:h")
	local root = vim.fn.finddir(".git", dir .. ";")
	git_root_cache[path] = root ~= "" and dir or nil
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

	stdout:read_start(function(err, data)
		if err or not data then
			return
		end
		vim.schedule_wrap(callback)(data)
	end)
end

-- --------------------------
-- Update Git info
-- --------------------------
local function update_git(buf)
	local root = get_git_root(buf)
	if not root then
		git_cache[buf] = { branch = "", added = "", changed = "", removed = "" }
		return
	end

	git_cache[buf] = git_cache[buf] or {}

	-- Branch
	run_async("git rev-parse --abbrev-ref HEAD 2>/dev/null", root, function(data)
		git_cache[buf].branch = data:gsub("\n", "")
		vim.api.nvim_command("redrawstatus")
	end)

	-- Diff
	run_async("git diff --numstat 2>/dev/null", root, function(data)
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
	return (g.branch or "") ~= "" and " " .. g.branch or ""
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

-- Filetype
function _G.st_filetype()
    -- Get the full file path of the current buffer
    local path = vim.api.nvim_buf_get_name(0)

    -- Get filename and extension for the devicons function
    -- :t extracts the tail (filename), :e extracts the extension
    local filename = vim.fn.fnamemodify(path, ":t")
    local extension = vim.fn.fnamemodify(path, ":e")

    -- Get the icon for the file, and fall back to the default icon if none is found
    -- We pass true for the `default` option to ensure an icon is always returned
    local icon = devicons.get_icon(filename, extension, { default = true })

    -- Get the filetype
    local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or ""

    -- If the icon is available, prepend it to the filetype.
    -- We add an extra space for separation.
    if filetype ~= "" then
        return (icon or "") .. " " .. filetype
    else
        -- Return filetype only if it's the only thing available (e.g., [No Name])
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
	return c > 0 and (" " .. c) or ""
end

function _G.st_warn()
	local c = diag_count(vim.diagnostic.severity.WARN)
	return c > 0 and (" " .. c) or ""
end

function _G.st_info()
	local c = diag_count(vim.diagnostic.severity.INFO)
	return c > 0 and ("󰋽 " .. c) or ""
end

function _G.st_hint()
	local c = diag_count(vim.diagnostic.severity.HINT)
	return c > 0 and (" " .. c) or ""
end

-- --------------------------
-- Autocmd to refresh Git info
-- --------------------------
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
	callback = function()
		update_git(vim.api.nvim_get_current_buf())
	end,
})

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
	"%#SLFileType#%{v:lua.st_filetype()}%*  ",
	" %l:%c ",
})
