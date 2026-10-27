-- compile
vim.keymap.set("n", "<leader>cc", function()
  local dir = vim.fn.expand("%:p:h")
  if vim.fn.filereadable(dir .. "/Makefile") == 1 then
    vim.opt_local.makeprg = "make -C " .. vim.fn.shellescape(dir)
  else
    vim.opt_local.makeprg = "clang++ -std=c++20 -Wall -Wextra -g -O0 -fstandalone-debug -o %:r %"
  end
  vim.cmd("make")
end, { buffer = true, desc = "Compile C++ file" })

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
