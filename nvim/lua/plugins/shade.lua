return {
	{
		"urtzienriquez/shade.nvim",
		config = function()
			require("shade").setup({
				overlay_opacity = 40,
				opacity_step = 1,
			})
		end,
	},
}
