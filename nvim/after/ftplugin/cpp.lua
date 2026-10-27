-- compile
local function build()
  local dir = vim.fn.expand("%:p:h")
  local has_makefile = vim.fn.filereadable(dir .. "/Makefile") == 1
  if has_makefile then
    vim.opt_local.makeprg = "make -C " .. vim.fn.shellescape(dir)
  else
    vim.opt_local.makeprg = "clang++ -std=c++20 -Wall -Wextra -g -O0 -fstandalone-debug -o %:r %"
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
    cmd = vim.fn.shellescape(vim.fn.expand("%:p:r"))
  end
  vim.cmd("botright split | terminal " .. cmd)
end, { buffer = true, desc = "Run C++ program" })

-- debug
vim.keymap.set("n", "<leader>cd", function()
  local dir, has_makefile, ok = build()
  if not ok then
    return -- build failed: errors are in the quickfix list
  end
  if has_makefile then
    vim.fn.jobstart({ "make", "-C", dir, "debug" }, { detach = true })
  else
    vim.fn.jobstart({ "raddbg", vim.fn.expand("%:p:r") }, { detach = true, cwd = dir })
  end
end, { buffer = true, desc = "Debug C++ program in RAD" })
