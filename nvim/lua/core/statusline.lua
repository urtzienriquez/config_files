--------------------------------------------------------------
-- ASYNC GIT STATUSLINE + FILETYPE
--------------------------------------------------------------

local colors = {
  green   = "#9ece6a",
  red     = "#f7768e",
  blue    = "#7aa2f7",
  purple  = "#bb9af7",
  fg      = "#c0caf5",
}

-- Highlight groups
local function define_highlights()
  vim.api.nvim_set_hl(0, "SLGitAdd",    { fg = colors.green })
  vim.api.nvim_set_hl(0, "SLGitChange", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "SLGitDelete", { fg = colors.red })
  vim.api.nvim_set_hl(0, "SLGitBranch", { fg = colors.purple })
  vim.api.nvim_set_hl(0, "SLFileType",  { fg = colors.fg, bold = true })
end

define_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = define_highlights })

-- Git cache
local git_cache = {
  branch = "",
  added = "",
  changed = "",
  removed = "",
}

-- Async runner
local function run_async(cmd, callback)
  local stdout = vim.loop.new_pipe(false)
  local handle

  handle = vim.loop.spawn("bash", {
    args = { "-c", cmd },
    stdio = { nil, stdout, nil },
  }, function()
    stdout:close()
    handle:close()
  end)

  stdout:read_start(function(err, data)
    if err or not data then return end
    callback(data)
  end)
end

-- Update Git info
local function update_branch()
  run_async("git rev-parse --abbrev-ref HEAD 2>/dev/null", function(data)
    git_cache.branch = data:gsub("\n", "")
  end)
end

local function update_diff()
  run_async("git diff --numstat 2>/dev/null", function(data)
    local added, removed = 0, 0
    for a, r in data:gmatch("(%d+)%s+(%d+)") do
      added = added + tonumber(a)
      removed = removed + tonumber(r)
    end

    git_cache.added   = added   > 0 and ("+" .. added) or ""
    git_cache.changed = (added + removed) > 0 and ("~" .. (added + removed)) or ""
    git_cache.removed = removed > 0 and ("-" .. removed) or ""
  end)
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  callback = function()
    if vim.fn.finddir(".git", vim.fn.expand("%:p:h") .. ";") ~= "" then
      update_branch()
      update_diff()
    else
      git_cache.branch = ""
      git_cache.added = ""
      git_cache.changed = ""
      git_cache.removed = ""
    end
  end,
})

-- Functions return only text
function _G.st_branch()  return git_cache.branch ~= "" and " " .. git_cache.branch or "" end
function _G.st_added()   return git_cache.added end
function _G.st_changed() return git_cache.changed end
function _G.st_removed() return git_cache.removed end
function _G.st_filetype() return vim.bo.filetype ~= "" and vim.bo.filetype or "" end

-- Final statusline
vim.o.laststatus = 3
vim.o.statusline = table.concat({
  " %t %m ",
  "%#SLGitBranch#%{v:lua.st_branch()}%*  ",
  "%#SLGitAdd#%{v:lua.st_added()}%* ",
  "%#SLGitChange#%{v:lua.st_changed()}%* ",
  "%#SLGitDelete#%{v:lua.st_removed()}%*  ",
  "%=",
  "%#SLFileType#%{v:lua.st_filetype()}%*  ",
  " %l:%c ",
})

