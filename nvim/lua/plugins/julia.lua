-- lua/plugins/julia.lua
return {
	"JuliaEditorSupport/julia-vim",
	lazy = false,
	init = function()
		-- for julia unicode symbols
		vim.g.latex_to_unicode_auto = 1
		-- Enable matchit for block-wise movements BEFORE plugin loads
		vim.cmd("runtime macros/matchit.vim")
	end,
	config = function()
		-- Enable julia-vim block mappings
		vim.g.julia_blocks = 1

		-- Optional: customize block mappings if desired
		-- vim.g.julia_blocks_mapping = {
		--     -- movements
		--     next_block_start = ']]',
		--     next_block_end = '][',
		--     prev_block_start = '[[',
		--     prev_block_end = '[]',
		--     -- text objects
		--     around_block = 'aj',
		--     inside_block = 'ij',
		-- }
	end,
}
