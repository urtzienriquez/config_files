vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("compiler gcc")
  vim.opt.makeprg = "g++ -o %:r %"
  vim.cmd("make")
end, { desc = "compile c program" })
