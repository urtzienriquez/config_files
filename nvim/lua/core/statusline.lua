-- Statusline

---@diagnostic disable: duplicate-set-field

-- --------------------------
-- Colors
-- --------------------------
local devicons = require("nvim-web-devicons")

local function define_highlights()
	local tokyonight = require("tokyonight.colors").setup()
	vim.api.nvim_set_hl(0, "SLFileName", { fg = tokyonight.blue })
	vim.api.nvim_set_hl(0, "SLGitAdd", { fg = tokyonight.git.add })
	vim.api.nvim_set_hl(0, "SLGitDelete", { fg = tokyonight.git.delete })
	vim.api.nvim_set_hl(0, "SLGitBranch", { fg = tokyonight.magenta })
	vim.api.nvim_set_hl(0, "SLDiagError", { fg = tokyonight.red1 })
	vim.api.nvim_set_hl(0, "SLDiagWarn", { fg = tokyonight.yellow })
	vim.api.nvim_set_hl(0, "SLDiagInfo", { fg = tokyonight.blue2 })
	vim.api.nvim_set_hl(0, "SLDiagHint", { fg = tokyonight.teal })
	vim.api.nvim_set_hl(0, "SLFileType", { bold = true })
	vim.api.nvim_set_hl(0, "StatusLineMinimal", { bg = tokyonight.bg, fg = tokyonight.bg })
end

define_highlights()

-- Cache for icon highlight groups
local icon_hl_cache = {}

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        icon_hl_cache = {}
        define_highlights()
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "#191B29", fg = "#737aa2" })
    end,
})

vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "background",
	callback = function()
		icon_hl_cache = {}
	end,
})

-- --------------------------
-- Git cache and pending updates
-- --------------------------
local git_cache = {}
local pending_updates = {}
local update_timers = {}

-- Get git root for buffer (cached per buffer)
local git_root_cache = {}
local function get_git_root(bufnr)
	if git_root_cache[bufnr] then
		return git_root_cache[bufnr]
	end

	local path = vim.api.nvim_buf_get_name(bufnr)
	if path == "" then
		return nil
	end

	local dir = vim.fn.fnamemodify(path, ":p:h")
	local handle = io.popen(string.format("git -C %s rev-parse --show-toplevel 2>/dev/null", vim.fn.shellescape(dir)))
	if not handle then
		return nil
	end

	local root = handle:read("*l")
	handle:close()

	git_root_cache[bufnr] = (root and root ~= "") and root or nil
	return git_root_cache[bufnr]
end

-- --------------------------
-- Async git status update
-- --------------------------
local function update_git_async(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
		return
	end

	if pending_updates[bufnr] then
		return
	end
	pending_updates[bufnr] = true

	local root = get_git_root(bufnr)
	if not root then
		git_cache[bufnr] = { branch = "", added = 0, removed = 0 }
		pending_updates[bufnr] = nil
		return
	end

	local cmd = string.format(
		[[cd %s 2>/dev/null && {
			git rev-parse --abbrev-ref HEAD 2>/dev/null
			echo "---"
			git diff --numstat HEAD 2>/dev/null
			echo "---"
			git status --porcelain 2>/dev/null
		}]],
		vim.fn.shellescape(root)
	)

	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			if not data or not vim.api.nvim_buf_is_valid(bufnr) then
				pending_updates[bufnr] = nil
				return
			end

			local output = table.concat(data, "\n")
			local parts = vim.split(output, "---", { plain = true })

			local branch = (parts[1] or ""):match("^%s*(.-)%s*$")

			local added = 0
			local removed = 0
			if parts[2] then
				for line in parts[2]:gmatch("[^\r\n]+") do
					local adds, dels = line:match("^(%d+)%s+(%d+)")
					if adds and dels then
						added = added + tonumber(adds)
						removed = removed + tonumber(dels)
					end
				end
			end

			local has_changes = parts[3] and parts[3]:match("%S") ~= nil
			if not has_changes then
				added = 0
				removed = 0
			end

			git_cache[bufnr] = {
				branch = branch,
				added = added,
				removed = removed,
			}

			pending_updates[bufnr] = nil
			vim.schedule(function()
				vim.cmd("redrawstatus")
			end)
		end,
		on_exit = function()
			pending_updates[bufnr] = nil
		end,
	})
end

local function update_git_debounced(bufnr, delay)
	delay = delay or 100

	if update_timers[bufnr] then
		update_timers[bufnr]:stop()
	end

	update_timers[bufnr] = vim.defer_fn(function()
		update_git_async(bufnr)
		update_timers[bufnr] = nil
	end, delay)
end

-- --------------------------
-- Git statusline functions
-- --------------------------

function _G.st_branch()
	local buf = vim.api.nvim_get_current_buf()
	local g = git_cache[buf]
	if not g or g.branch == "" then
		return ""
	end
	return " " .. g.branch .. " "
end

function _G.st_added()
	local buf = vim.api.nvim_get_current_buf()
	local g = git_cache[buf]
	if not g or g.added == 0 then
		return ""
	end
	return "+" .. g.added .. " "
end

function _G.st_removed()
	local buf = vim.api.nvim_get_current_buf()
	local g = git_cache[buf]
	if not g or g.removed == 0 then
		return ""
	end
	return "-" .. g.removed .. "  "
end

function _G.st_filetype_text()
	local path = vim.api.nvim_buf_get_name(0)
	local filename = vim.fn.fnamemodify(path, ":t")
	local extension = vim.fn.fnamemodify(path, ":e")
	local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or ""

	if filetype == "" then
		return ""
	end

	local icon, icon_color = devicons.get_icon_color(filename, extension:lower(), { default = true })

	if not icon then
		icon, icon_color = devicons.get_icon_color("", filetype, { default = true })
	end
	if not icon then
		icon, icon_color = devicons.get_icon_color("", string.lower(filetype), { default = true })
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
	return c > 0 and (" " .. c .. " ") or ""
end

function _G.st_warn()
	local c = diag_count(vim.diagnostic.severity.WARN)
	return c > 0 and (" " .. c .. " ") or ""
end

function _G.st_info()
	local c = diag_count(vim.diagnostic.severity.INFO)
	return c > 0 and ("󰋽 " .. c .. " ") or ""
end

function _G.st_hint()
	local c = diag_count(vim.diagnostic.severity.HINT)
	return c > 0 and (" " .. c .. " ") or ""
end

-- --------------------------
-- Position
-- --------------------------
function _G.st_position()
	local line = vim.fn.line(".")
	local total = vim.fn.line("$")

	if line == 1 then
		return "Top"
	elseif line == total then
		return "Bot"
	else
		local percent = math.floor((line / total) * 100)
		return string.format("%2d%%", percent)
	end
end

-- --------------------------
-- Refresh triggers
-- --------------------------
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function(args)
		update_git_debounced(args.buf, 100)
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function(args)
		update_git_debounced(args.buf, 0)
	end,
})

vim.api.nvim_create_autocmd("FocusGained", {
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		git_root_cache[bufnr] = nil
		update_git_debounced(bufnr, 0)
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "FugitiveChanged",
	callback = function()
		git_root_cache = {}
		for bufnr in pairs(git_cache) do
			update_git_debounced(bufnr, 0)
		end
	end,
})

vim.api.nvim_create_autocmd("ShellCmdPost", {
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		git_root_cache[bufnr] = nil
		update_git_debounced(bufnr, 0)
	end,
})

vim.api.nvim_create_user_command("GitStatusRefresh", function()
	update_git_debounced(vim.api.nvim_get_current_buf(), 0)
	vim.notify("Git status refreshed", vim.log.levels.INFO)
end, {})

-- --------------------------
-- Final statusline
-- --------------------------
vim.o.laststatus = 3

vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufModifiedSet" }, {
	callback = function()
		local is_oil = vim.bo.filetype == "oil"
		local bufname = vim.api.nvim_buf_get_name(0)
		local bt = vim.bo.buftype
		local modified = vim.bo.modified
		if is_oil or (bufname == "" and bt == "" and not modified) then
			vim.wo.statusline = "%#StatusLineMinimal# "
		else
			vim.wo.statusline = ""
		end
	end,
})

vim.o.statusline = table.concat({
	" %#SLFileName#%t %m%* ",
	"%#SLGitBranch#%{v:lua.st_branch()}%*",
	"%#SLGitAdd#%{v:lua.st_added()}%*",
	"%#SLGitDelete#%{v:lua.st_removed()}%*",
	"%#SLDiagError#%{v:lua.st_err()}%*",
	"%#SLDiagWarn#%{v:lua.st_warn()}%*",
	"%#SLDiagInfo#%{v:lua.st_info()}%*",
	"%#SLDiagHint#%{v:lua.st_hint()}%*",
	"%=",
	"%{%v:lua.st_filetype_text()%} ",
	"%4{v:lua.st_position()} ",
	"%5l:%-5c ",
})
