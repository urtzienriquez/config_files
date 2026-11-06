-- sources and executable for the no-Makefile case:
-- one .cpp in the dir -> build just it (exe named after the file)
-- several .cpp        -> build them all together into <dir>/main
local function target(dir)
  local sources = vim.fn.glob(dir .. "/*.cpp", false, true)
  if #sources <= 1 then
    return { vim.fn.expand("%:p") }, vim.fn.expand("%:p:r")
  end
  return sources, dir .. "/main"
end

-- shell-escape a path, then escape % and # so :make doesn't expand them
local function arg(path)
  return (vim.fn.shellescape(path):gsub("[%%#]", "\\%0"))
end

-- compile
local function build()
  local dir = vim.fn.expand("%:p:h")
  local has_makefile = vim.fn.filereadable(dir .. "/Makefile") == 1
  if has_makefile then
    vim.opt_local.makeprg = "make -C " .. vim.fn.shellescape(dir)
  else
    local sources, exe = target(dir)
    vim.opt_local.makeprg = "clang++ -std=c++20 -Wall -Wextra -g -O0 -fstandalone-debug -o "
      .. arg(exe) .. " " .. table.concat(vim.tbl_map(arg, sources), " ")
  end
  vim.cmd("make")
  return dir, has_makefile, vim.v.shell_error == 0
end

vim.keymap.set("n", "<leader>cc", build, { buffer = true, desc = "Compile C++ file" })

-- run
vim.keymap.set("n", "<leader>cr", function()
  local dir = vim.fn.expand("%:p:h")
  local cmd
  if vim.fn.filereadable(dir .. "/Makefile") == 1 then
    cmd = "make -C " .. vim.fn.shellescape(dir) .. " run"
  else
    local _, exe = target(dir)
    cmd = vim.fn.shellescape(exe)
  end
  vim.cmd("topleft split | terminal " .. cmd)
  vim.cmd("startinsert")
end, { buffer = true, desc = "Run C++ program" })

-- debug (cd changes directory... cv for "view"... horrible, but it is what it is)
vim.keymap.set("n", "<leader>cv", function()
  local dir, has_makefile, ok = build()
  if not ok then
    return -- build failed: errors are in the quickfix list
  end
  if has_makefile then
    vim.fn.jobstart({ "make", "-C", dir, "debug" }, { detach = true })
  else
    local _, exe = target(dir)
    vim.fn.jobstart({ "raddbg", exe }, { detach = true, cwd = dir })
  end
end, { buffer = true, desc = "Debug C++ program in RAD" })
