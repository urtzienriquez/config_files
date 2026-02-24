return {
	"urtzienriquez/replent.nvim",
	dev = true,
	ft = { "python", "julia", "matlab", "quarto" },
	dependencies = {
		{ "jpalardy/vim-slime" },
	},
	-- opts = {
	-- 	filetypes = { "python", "julia" }, -- remove matlab
	--
	-- 	keymaps = {
	-- 		start_python = "<leader>p", -- remap
	-- 		debug_block = false, -- disable
	-- 	},
	--
	-- 	repl_commands = {
	-- 		python = "python3", -- change launch command
	-- 	},
	-- },
}
