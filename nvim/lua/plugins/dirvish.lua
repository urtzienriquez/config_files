vim.pack.add({
  "https://github.com/justinmk/vim-dirvish",
})

vim.g.dirvish_mode = ":sort | sort ,^.*[\\/],"

local M = {}

local function refresh()
  vim.cmd.Dirvish()
end

function M.mkfile()
  local name = vim.trim(vim.fn.input("New file: "))
  if name == "" then
    return
  end
  vim.cmd.edit(vim.fn.expand("%") .. name)
  vim.cmd.write()
  refresh()
end

function M.mkdir()
  local name = vim.trim(vim.fn.input("New directory: "))
  if name == "" then
    return
  end
  vim.fn.mkdir(vim.fn.expand("%") .. name, "p")
  refresh()
end

function M.rename()
  local old = vim.trim(vim.fn.getline("."))
  local new = vim.trim(vim.fn.input("Rename to: ", vim.fs.basename((old:gsub("/$", "")))))
  if new == "" then
    return
  end
  vim.fn.rename(old, vim.fs.dirname((old:gsub("/$", ""))) .. "/" .. new)
  refresh()
end

local function delete(path)
  vim.fn.delete(path, vim.fn.isdirectory(path) == 1 and "rf" or "")
end

function M.remove()
  local path = vim.trim(vim.fn.getline("."))
  if vim.fn.confirm("Delete " .. path .. "?", "&Yes\n&No", 2) ~= 1 then
    return
  end
  delete(path)
  refresh()
end

function M.remove_visual()
  local first = vim.fn.getpos("v")[2]
  local last = vim.fn.getpos(".")[2]
  if first > last then
    first, last = last, first
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  local paths = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  if #paths == 0 then
    return
  end
  if vim.fn.confirm("Delete\n" .. table.concat(paths, "\n"), "&Yes\n&No", 2) ~= 1 then
    return
  end
  for _, path in ipairs(paths) do
    delete(vim.trim(path))
  end
  refresh()
end

function M.copy()
  local dest = vim.fn.expand("%")
  for _, path in ipairs(vim.fn.getreg('"', 1, true)) do
    if path ~= "" then
      vim.fn.system({ "cp", "-r", path, dest })
    end
  end
  refresh()
end

function M.move()
  local dest = vim.fn.expand("%")
  for _, path in ipairs(vim.fn.getreg('"', 1, true)) do
    if path ~= "" then
      vim.fn.system({ "mv", path, dest })
    end
  end
  refresh()
end

return M
