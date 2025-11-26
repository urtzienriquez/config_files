return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	config = function()
		require("fzf-lua").setup({
			defaults = {
				no_header_i = true,
			},
			keymap = {
				builtin = {
					true,
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
					["<S-down>"] = "preview-page-down",
					["<S-up>"] = "preview-page-up",
					["<M-S-down>"] = "preview-down",
					["<M-S-up>"] = "preview-up",
				},
				fzf = {
					true,
					["ctrl-z"] = "abort",
					["ctrl-u"] = "unix-line-discard",
					["ctrl-f"] = "half-page-down",
					["ctrl-b"] = "half-page-up",
					["ctrl-a"] = "toggle-all",
					["ctrl-t"] = "first",
					["ctrl-e"] = "last",
					["f3"] = "toggle-preview-wrap",
					["f4"] = "toggle-preview",
					["shift-down"] = "preview-page-down",
					["shift-up"] = "preview-page-up",
				},
			},
			actions = {
				files = {
					["enter"] = require("fzf-lua").actions.file_edit_or_qf,
					["ctrl-s"] = require("fzf-lua").actions.file_split,
					["ctrl-v"] = require("fzf-lua").actions.file_vsplit,
					["ctrl-q"] = require("fzf-lua").actions.file_sel_to_qf,
					["ctrl-Q"] = require("fzf-lua").actions.file_sel_to_ll,
					["ctrl-j"] = require("fzf-lua").actions.toggle_ignore,
					["ctrl-h"] = require("fzf-lua").actions.toggle_hidden,
					["ctrl-f"] = require("fzf-lua").actions.toggle_follow,
				},
			},
			grep = {
				actions = {
					["ctrl-f"] = { require("fzf-lua").actions.grep_lgrep },
					["ctrl-g"] = false,
				},
			},
			fzf_opts = {
				["--multi"] = true,
				["--bind"] = "tab:toggle+down,shift-tab:toggle+up",
			},
		})
	end,
}
