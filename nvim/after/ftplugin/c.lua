vim.o.shiftwidth = 4

vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("compiler gcc")
  vim.opt.makeprg = "gcc -o %:r %"
  vim.cmd("make")
end, { desc = "compile c program" })
