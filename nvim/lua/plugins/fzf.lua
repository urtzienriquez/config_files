return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = { "FzfLua" },
	keys = { { "<leader>f", desc = "Find" } }, -- triggers on any <leader>f
	opts = {},
	config = function()
		local actions = require("fzf-lua").actions
		require("fzf-lua").setup({
			defaults = {
				no_header_i = true,
				actions = {
					["ctrl-q"] = actions.file_sel_to_qf,
				},
			},
			keymap = {
				builtin = {
					false,
					["<M-Esc>"] = "hide",
					["<F1>"] = "toggle-help",
					["<F2>"] = "toggle-fullscreen",
					["<F3>"] = "toggle-preview-wrap",
					["<F4>"] = "toggle-preview",
					["<F5>"] = "toggle-preview-cw",
					["<F6>"] = "toggle-preview-behavior",
					["<F7>"] = "toggle-preview-ts-ctx",
					["<F8>"] = "preview-ts-ctx-dec",
					["<F9>"] = "preview-ts-ctx-inc",
					["<S-Left>"] = "preview-reset",
					["<M-S-j>"] = "preview-down",
					["<M-S-k>"] = "preview-up",
					["ctrl-q"] = false,
				},
				fzf = {
					false,
					["ctrl-z"] = "abort",
					["ctrl-u"] = "unix-line-discard+first",
					["ctrl-a"] = "toggle-all",
					["ctrl-t"] = "first",
					["ctrl-b"] = "last",
					["ctrl-q"] = false,
				},
			},
			actions = {
				files = {
					["enter"] = actions.file_edit_or_qf,
					["ctrl-s"] = actions.file_split,
					["ctrl-v"] = actions.file_vsplit,
					["ctrl-j"] = actions.toggle_ignore,
					["ctrl-h"] = actions.toggle_hidden,
					["ctrl-f"] = actions.toggle_follow,
				},
			},
			grep = {
				actions = {
					["ctrl-f"] = { actions.grep_lgrep },
					["ctrl-g"] = false,
				},
			},
			buffers = {
				actions = {
					["ctrl-d"] = { fn = actions.buf_del, reload = true },
					["ctrl-x"] = false,
				},
			},
			fzf_opts = {
				["--multi"] = true,
				["--bind"] = "tab:toggle+down,shift-tab:toggle+up",
			},
			fzf_colors = {
				["fg"] = { "fg", "Normal" },
				["bg"] = { "bg", "Normal" },
				["fg+"] = { "fg", "Normal" },
				["bg+"] = { "bg", "CursorLine" },
				["hl"] = { "fg", "Comment" },
				["hl+"] = { "fg", "Statement" },
				["gutter"] = { "bg", "Normal" },
			},
		})
	end,
}
