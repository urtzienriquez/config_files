return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" }, -- if you prefer nvim-web-devicons
	opts = {
		file_types = { "markdown", "rmd", "Rmd", "jmd", "Jmd", "quarto" },
		render_modes = { "n", "c", "t" },
		code = { enabled = false },
		anti_conceal = { enabled = false },
		overrides = {
			buftype = {
				nofile = {
					code = { enabled = true },
				},
			},
		},
	},
}
