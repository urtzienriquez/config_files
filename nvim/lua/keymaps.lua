-- escape as jj or jk
vim.keymap.set("i", "jj", "<Esc>", { desc = "Esc using jj" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Esc using jk" })

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

-- keymaps for fuzzy finding with telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope [f]ind [f]iles" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope [f]ind with [g]rep inside the file" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope [f]ind [b]uffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope [f]ind [h]elp tags" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[f]ind [k]eymaps" })
vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[f]ind [s]elect Telescope" })
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[f]ind current [w]ord" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[f]ind [d]iagnostics" })
vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[f]ind [r]esume" })
vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[f]ind Recent Files ("." for repeat)' })

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
		vim.highlight.on_yank()
	end,
})
