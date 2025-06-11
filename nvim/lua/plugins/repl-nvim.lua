return {
	"pappasam/nvim-repl",
	lazy = false,
	keys = {
		{ "<Leader>pf", ":Repl<CR>", mode = "n", desc = "Open Repl" },
		{ "<Leader>pq", ":ReplClose<CR>", mode = "n", desc = "Open Repl" },
		{ "<Leader>sc", "<Plug>(ReplSendCell)", mode = "n", desc = "Send Repl Cell" },
		{ "<Leader><CR>", "<Plug>(ReplSendLine)", mode = "n", desc = "Send Repl Line" },
		{ "<Leader><CR>", "<Plug>(ReplSendVisual)", mode = "x", desc = "Send Repl Visual Selection" },
	},
}
