vim.pack.add({ "https://github.com/mason-org/mason.nvim" })

vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
  once = true,
  callback = function()
    ---@diagnostic disable-next-line: param-type-mismatch, missing-fields
    require("mason").setup({
      ui = {
        border = "none",
        backdrop = 40,
        icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    })
  end,
})
