return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
	opts = {
		file_types = { "markdown", "rmd", "Rmd", "jmd", "Jmd", "quarto" },
		render_modes = { "n", "c", "t" },
		anti_conceal = { enabled = false },
		code_block = {
			style = "full",
			position = "left",
			language_pad = 0,
			language_name = true,
			left_pad = 0,
			right_pad = 0,
			width = "full",
			min_width = 0,
			border = "thin",
			above = "▄",
			below = "▀",
			highlight = "RenderMarkdownCodeBlock",
			enabled = false,
		},
		code = {
			enabled = false,
		},
	},
}
