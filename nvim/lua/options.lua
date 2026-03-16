-- map leaders
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- misc options
vim.o.shell = "/usr/bin/zsh"
require("vim._core.ui2").enable({ msg = { target = "msg" } })
-- vim.o.cmdheight = 0
vim.o.winborder = "rounded"
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 10
vim.o.backspace = "indent,eol,start"
vim.o.ignorecase = true
vim.o.clipboard = "unnamedplus"
vim.o.termguicolors = true
vim.o.signcolumn = "yes:1"
vim.o.cursorline = true
vim.o.cursorlineopt = "number"
vim.o.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block"

-- indentation
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

-- for diffing two files
-- wrap text and always center text: improves comparing markdown files
vim.opt.diffopt:append("followwrap")

-- code folding
vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
function _G.custom_foldtext()
  local start_line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart + 1
  start_line = start_line:gsub("%s*$", "")
  if #start_line > 80 then
    start_line = start_line:sub(1, 80) .. "..."
  end
  return string.format("%s ···%d lines", start_line, line_count)
end
vim.o.foldtext = "v:lua.custom_foldtext()"

-- More natural split directions
vim.o.splitbelow = true
vim.o.splitright = true

-- spelling
vim.o.spell = true
vim.o.spelllang = "en_us"
vim.o.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

vim.api.nvim_create_user_command("SpellEN", function()
  vim.o.spelllang = "en_us"
  vim.o.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
  vim.notify("Spell: EN")
end, {})

vim.api.nvim_create_user_command("SpellES", function()
  vim.o.spelllang = "es_es"
  vim.o.spellfile = vim.fn.stdpath("config") .. "/spell/es.utf-8.add"
  vim.notify("Spell: ES")
end, {})
