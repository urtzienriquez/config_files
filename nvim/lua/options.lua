-- map leaders
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable mouse
vim.opt.mouse = ""

-- misc options
require("vim._core.ui2").enable({
  msg = {
    target = "msg",
  },
})
vim.opt.cmdheight = 0
vim.o.winborder = "rounded"
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 10
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.ignorecase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes:1"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block"

-- indentation
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- for diffing two files
-- wrap text and always center text: improves comparing markdown files
vim.opt.diffopt:append("followwrap")

-- code folding
vim.opt.foldcolumn = "0"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
function _G.custom_foldtext()
  local start_line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart + 1
  start_line = start_line:gsub("%s*$", "")
  if #start_line > 80 then
    start_line = start_line:sub(1, 80) .. "..."
  end
  return string.format("%s ···%d lines", start_line, line_count)
end
vim.opt.foldtext = "v:lua.custom_foldtext()"

-- More natural split directions
vim.opt.splitbelow = true
vim.opt.splitright = true

-- spelling
vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

vim.api.nvim_create_user_command("SpellEN", function()
  vim.opt.spelllang = { "en_us" }
  vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
  vim.notify("Spell: EN")
end, {})

vim.api.nvim_create_user_command("SpellES", function()
  vim.opt.spelllang = { "es_es" }
  vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/es.utf-8.add"
  vim.notify("Spell: ES")
end, {})
