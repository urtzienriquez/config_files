return {
	"urtzienriquez/nightfox.nvim",
	-- dir = "/home/urtzi/Documents/GitHub/nightfox.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		-- require("nightfox").setup({
		--           dim_inactive = true, -- defaults to 0.4
		-- 	on_load = function(spec, palette)
		-- 		-- highlight overrides
		-- 		vim.api.nvim_set_hl(0, "NormalNC", { fg = spec.fg1, bg = spec.bg1 })
		-- 		vim.api.nvim_set_hl(0, "WinSeparator", { fg = palette.blue.base, bg = "none" })
		--
		-- 		-- style overrides
		-- 		vim.api.nvim_set_hl(0, "Comment", { fg = spec.syntax.comment, italic = true })
		-- 		vim.api.nvim_set_hl(0, "Keyword", { fg = spec.syntax.keyword, bold = true })
		-- 		vim.api.nvim_set_hl(0, "@markup.strong", { bold = true })
		-- 	end,
		-- })
		vim.cmd.colorscheme("nightfox")
	end,
}
