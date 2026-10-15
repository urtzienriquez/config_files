-- vim.keymap.set("n", "<leader>cc", function()
--   vim.cmd("compiler gcc")
--   vim.opt.makeprg = "g++ -g -O0 -o %:r %"
--   vim.cmd("make")
-- end, { desc = "Compile C++ file" })
vim.keymap.set("n", "<leader>cc", function()
  vim.opt.makeprg = "clang++ -g -O0 -fno-discard-value-names -o %:r %"
  vim.cmd("make")
end, { desc = "Compile C++ file with Clang" })
