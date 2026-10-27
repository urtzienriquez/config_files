vim.bo.shiftwidth = 4

vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("compiler gcc")
  vim.opt_local.makeprg = "gcc -o %:r %"
  vim.cmd("make")
end, { buffer = true, desc = "compile c program" })
