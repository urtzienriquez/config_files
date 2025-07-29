-- escape as jj or jk
vim.keymap.set("i", "jj", "<Esc>", { desc = "Esc using jj" })
-- vim.keymap.set("i", "jk", "<Esc>", { desc = "Esc using jk" })

-- word suggestions in normal mode
vim.keymap.set("n", "<C-x><C-s>", "i<C-X><C-S>", { desc = "Spelling suggestion in normal mode" })
vim.keymap.set("n", "<C-x><C-n>", "i<C-X><C-N>", { desc = "Next word suggestion in normal mode" })
vim.keymap.set("n", "<C-x><C-p>", "i<C-X><C-P>", { desc = "Previous word suggestion in normal mode" })
vim.keymap.set("n", "<C-x><C-x>", "i<C-X><C-O>", { desc = "Omni suggestion in normal mode" })
vim.keymap.set("n", "<C-x><C-k>", "i<C-X><C-K>", { desc = "Dictionary suggestion in normal mode" })

-- open oil
vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })

-- connect to opened julia session in another terminal (only available when filetype = julia)
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "julia", "markdown" },
	callback = function()
		vim.keymap.set(
			"n",
			"<localleader>jf",
			"<cmd>JuliaREPLConnect 2345<CR>",
			{ desc = "Connect [j]ulia [f]ile to server running in opened terminal" }
		)
	end,
})

-- escape terminal mode with Control-c + Control-d
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- keymaps for fuzzy finding with Snacks.picker
vim.keymap.set("n", "<leader>fs", function()
	Snacks.picker.smart()
end, { desc = "picker [f]ind [s]mart files" })
vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.files()
end, { desc = "picker [f]ind [f]iles" })
vim.keymap.set("n", "<leader>fb", function()
	Snacks.picker.buffers({
		win = { input = { keys = { ["<C-d>"] = { "bufdelete", mode = { "i", "n" } } } } },
	})
end, { desc = "picker [f]ind [b]uffers" })
vim.keymap.set("n", "<leader>fg", function()
	Snacks.picker.grep()
end, { desc = "picker [f]ind [g]rep" })
vim.keymap.set("n", "<leader>fG", function()
	Snacks.picker.grep_buffers()
end, { desc = "picker [f]ind [g]rep in buffers" })
vim.keymap.set("n", "<leader>fd", function()
	Snacks.picker.diagnostics_buffer()
end, { desc = "picker [f]ind [d]iagnostics in buffers" })
vim.keymap.set("n", "<leader>fk", function()
	Snacks.picker.keymaps()
end, { desc = "picker [f]ind [k]eymaps" })

-- resize windows
vim.keymap.set("n", "<C-Left>", ":vertical resize +2<CR>", { silent = true, desc = "Resize vertically split window" })
vim.keymap.set("n", "<C-Right>", ":vertical resize -2<CR>", { silent = true, desc = "Resize vertically split window" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { silent = true, desc = "Resize horizontally split window" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { silent = true, desc = "Resize horizontally split window" })

-- split windows
vim.keymap.set("n", "<C-w>v", ":split<CR>", { desc = "Vertically split window as in i3" })
vim.keymap.set("n", "<C-w>h", ":vs<CR>", { desc = "Horizontally split window as in i3" })

-- Using ufo provider need remap `zR` and `zM`
vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

-- remap half page up/down to center cursor in the screen
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, desc = "Jump half page down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, desc = "Jump half page up" })

-- clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- toggle rendering in render-markdown
vim.keymap.set("n", "<leader>a", require("render-markdown").toggle, { desc = "render markdown toogle" })

-- toggle colorscheme
vim.keymap.set("n", "<leader>cc", toggle_tokyonight_style, { desc = "Toggle TokyoNight style" })
