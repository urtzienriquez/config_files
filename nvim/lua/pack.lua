-- hooks
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
    if name == "blink.cmp" and (kind == "install" or kind == "update") then
      vim.system({ "cargo", "build", "--release" }, { cwd = ev.data.path }):wait()
    end
    if name == "LuaSnip" and (kind == "install" or kind == "update") then
      vim.system({ "make", "install_jsregexp" }, { cwd = ev.data.path }):wait()
    end
  end,
})

----------------------------------------
-- builtin plugins

vim.cmd("packadd nvim.undotree")

----------------------------------------
-- plugins

for _, name in ipairs({
  "dirvish",
  "mini-clue",
  "nvim-surround",
  "gitsigns",
  "fzf-lua",
  "treesitter",
  "plenary",
  "blink-cmp",
  "mason",
  "conform",
  "vim-slime",
  "quicker",
  "fugitive",
  "diffs",
  "guh",
  "r-nvim",
  "opencode",
  "nightfox",
  "zotero",
  "citeref",
  "replent",
  "sessman",
  "bs",
}) do
  require("plugins." .. name)
end
