return {
	"kylechui/nvim-surround",
	event = "VeryLazy",
	config = function()
		require("nvim-surround").setup({
			move_cursor = false,
			surrounds = {
				["m"] = {
					add = { "*", "*" },
					find = "%*.-%*",
					delete = "^(%*)(.-)(%*)$",
				},
				["M"] = {
					add = { "**", "**" },
					find = "%*%*.-%*%*",
					delete = "^(%*%*)(.-)(%*%*)$",
				},
				["g"] = {
					add = { "***", "***" },
					find = "%*%*%*.-%*%*%*",
					delete = "^(%*%*%*)(.-)(%*%*%*)$",
				},
				["q"] = {
					add = { '"', '"' },
					find = '".-"',
					delete = '^(".)(.-)(")$',
				},
				["s"] = {
					add = { "'", "'" },
				},
			},
		})
	end,
}
