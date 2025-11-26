return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- or if using mini.icons/mini.nvim
	-- dependencies = { "nvim-mini/mini.icons" },
	opts = {},
	config = function()
		require("fzf-lua").setup({
			defaults = {
				no_header_i = true, -- hide interactive header?
			},
			actions = {
				files = {
					["enter"] = FzfLua.actions.file_edit_or_qf,
					["ctrl-s"] = FzfLua.actions.file_split,
					["ctrl-v"] = FzfLua.actions.file_vsplit,
					["ctrl-t"] = FzfLua.actions.file_tabedit,
					["ctrl-q"] = FzfLua.actions.file_sel_to_qf,
					["ctrl-Q"] = FzfLua.actions.file_sel_to_ll,
					["ctrl-i"] = FzfLua.actions.toggle_ignore,
					["ctrl-h"] = FzfLua.actions.toggle_hidden,
					["ctrl-f"] = FzfLua.actions.toggle_follow,
				},
			},
			grep = {
				actions = {
					["ctrl-f"] = { FzfLua.actions.grep_lgrep },
					["ctrl-g"] = false,
					["ctrl-r"] = { FzfLua.actions.toggle_ignore },
				},
			},
		})
	end,
}
