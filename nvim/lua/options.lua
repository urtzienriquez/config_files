-- map leaders
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- spelling language
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

-- Disable mouse
vim.opt.mouse = ""

-- misc options
require('vim._core.ui2').enable({
msg = {
    target = 'msg',
  },
})
vim.opt.cmdheight = 0
vim.o.winborder = "rounded"
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 10
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.ignorecase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes:1"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block"

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

-- Auto-resize splits when terminal window changes size
vim.api.nvim_create_autocmd({ "VimResized" }, {
	pattern = "*",
	command = "wincmd =",
	desc = "Auto-resize windows on terminal resize",
})

-- Better line wrapping for text files
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"markdown",
		"text",
		"rmd",
		"jmd",
		"quarto",
		"qmd",
		"org",
		"rst",
		"asciidoc",
		"adoc",
		"tex",
		"latex",
		"wiki",
		"textile",
		"mail",
		"gitcommit",
	},
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.showbreak = "↳ "
	end,
	desc = "Better wrapping for prose files",
})

-- Set pandoc syntax for markdown files
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.Rmd", "*.rmd", "*.qmd", "*.Qmd", "*.jmd", "*.Jmd", "*.md" },
	callback = function()
		vim.schedule(function()
			if vim.bo.filetype == "rmd" or vim.bo.filetype == "quarto" or vim.bo.filetype == "markdown" then
				vim.cmd("setlocal syntax=pandoc")
			end
		end)
	end,
	desc = "Set pandoc syntax for markdown-like files",
})

-- Diagnostics
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.diagnostic.config({
			virtual_text = true,
			update_in_insert = false,
			severity_sort = true,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "",
					[vim.diagnostic.severity.WARN] = "",
					[vim.diagnostic.severity.INFO] = "󰋽",
					[vim.diagnostic.severity.HINT] = "",
				},
			},
		})
	end,
	desc = "Configure diagnostics signs and virtual text",
})

-- man page / help viewing for shell scripts
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "sh", "bash", "zsh" },
	callback = function()
		vim.keymap.set("n", "K", function()
			local word = vim.fn.expand("<cword>")

			-- Try :Man first (for actual man pages)
			local ok = pcall(vim.cmd.Man, word)

			-- If that fails, try bash help for builtins
			if not ok then
				local help_output = vim.fn.system("bash -c 'help " .. word .. "' 2>&1")

				if vim.v.shell_error == 0 then
					-- Open help in a split
					vim.cmd("new")
					vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(help_output, "\n"))
					vim.bo.buftype = "nofile"
					vim.bo.bufhidden = "wipe"
					vim.bo.modifiable = false
				else
					vim.notify("No manual entry for '" .. word .. "'", vim.log.levels.WARN)
				end
			end
		end, { buffer = true, desc = "Show man page or bash help" })
	end,
})

-- disable 'q' to close for man pages
vim.api.nvim_create_autocmd("FileType", {
	pattern = "man",
	callback = function()
		vim.keymap.del("n", "q", { buffer = true })
	end,
})

-- lsp message in ui2
vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    local value = ev.data.params.value or {}
    local msg = value.message or "done"
    vim.api.nvim_echo({ { msg } }, false, {
      id = "lsp",
      kind = "progress",
      title = value.title,
      status = value.kind ~= "end" and "running" or "success",
      percent = value.percentage,
    })
  end,
})
