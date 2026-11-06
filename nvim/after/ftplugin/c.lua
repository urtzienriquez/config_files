vim.bo.shiftwidth = 4

vim.keymap.set("n", "<leader>cc", function()
  vim.cmd("compiler gcc")
  vim.opt_local.makeprg = "gcc -o %:r %"
  vim.cmd("make")
end, { buffer = true, desc = "compile c program" })

-- run
vim.keymap.set("n", "<leader>cr", function()
  local exe = vim.fn.expand("%:p:r")
  vim.cmd("topleft split | terminal " .. vim.fn.shellescape(exe))
  vim.cmd("startinsert")
end, { buffer = true, desc = "Run C program" })-- run
