local M = {}

M.loaded = false

M.setup = function()
  if M.loaded then
    return
  end

  require("lazy.fzf").setup()

  pcall(vim.api.nvim_del_user_command, "Octo")

  require("octo").setup({
    picker = "fzf-lua",
    mappings_disable_default = false,
    enable_builtin = true,
  })

  M.loaded = true
end

vim.api.nvim_create_user_command("Octo", function(args)
  M.setup()
  vim.cmd("Octo" .. (args.args ~= "" and " " .. args.args or ""))
end, { nargs = "*", desc = "Open GitHub (lazy octo setup)" })

return M
