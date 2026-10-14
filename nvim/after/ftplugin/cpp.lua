vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("compiler gcc")
  vim.opt.makeprg = "g++ -g -O0 -o %:r %"
  vim.cmd("make")
end, { desc = "Compile C++ file" })
