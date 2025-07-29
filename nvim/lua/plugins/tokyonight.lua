return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		-- Default style
		vim.g.tokyonight_style = "night"
		vim.cmd.colorscheme("tokyonight-" .. vim.g.tokyonight_style)

		-- Define global toggle function
		function _G.toggle_tokyonight_style()
			if vim.g.tokyonight_style == "night" then
				vim.g.tokyonight_style = "day"
			else
				vim.g.tokyonight_style = "night"
			end
			vim.cmd("colorscheme tokyonight-" .. vim.g.tokyonight_style)
			print("TokyoNight style: " .. vim.g.tokyonight_style)
		end
	end,
}
