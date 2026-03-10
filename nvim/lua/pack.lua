-- Build hooks (must be before vim.pack.add)
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
  end,
})

-- external plugins
local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"
for _, file in ipairs(vim.fn.readdir(plugin_dir)) do
  local plugin = file:match("^(.+)%.lua$")
  if plugin then
    require("plugins." .. plugin)
  end
end

-- my plugins
local dev = vim.fn.expand("~/Documents/GitHub")
local my_packs = {
  "nightfox.nvim",
  "citeref.nvim",
  "replent.nvim",
  "learnlua.nvim",
}
for _, name in ipairs(my_packs) do
  vim.opt.rtp:prepend(dev .. "/" .. name)
end

-- colorscheme: nightfox
vim.cmd.colorscheme("nightfox")

-- citeref
require("citeref").setup({
  backend = "fzf",
  bib_files = { "~/Documents/zotero.bib" },
})
