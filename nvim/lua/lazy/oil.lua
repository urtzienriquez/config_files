local M = {}

M.loaded = false

M.setup = function()
  if M.loaded then
    return
  end

  pcall(vim.api.nvim_del_user_command, "Oil")

  require("oil").setup({
    default_file_explorer = true,
    use_default_keymaps = true,
    view_options = { show_hidden = true },
    keymaps = {
      ["<C-h>"] = { "actions.select", opts = { vertical = true } },
      ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
    },
  })

  M.loaded = true
end

vim.api.nvim_create_user_command("Oil", function(args)
  M.setup()
  vim.cmd("Oil" .. (args.args ~= "" and " " .. args.args or ""))
end, { nargs = "*", desc = "Open file explorer (lazy oil setup)" })

return M
