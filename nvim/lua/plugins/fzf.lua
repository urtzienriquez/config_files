return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = { "FzfLua" },
	keys = {
		{ "<leader>fp", desc = "Find picker" },
		{ "<leader>ff", desc = "Find files" },
		{ "<leader>f~", desc = "Find files in home directory" },
		{ "<leader>fg", desc = "Find with grep" },
		{ "<leader>fq", desc = "Find inside quickfix with grep" },
		{ "<leader>fb", desc = "Find buffers" },
		{ "<leader>fh", desc = "Find help tags" },
		{ "<leader>fk", desc = "Find keymaps" },
		{ "<leader>fw", desc = "Find current word" },
		{ "<leader>fd", desc = "Find diagnostics in current buffer" },
		{ "<leader>fD", desc = "Find diagnostics globally" },
		{ "<leader>fl", desc = "Find LSP definitions" },
		{ "<leader>fr", desc = "Find LSP references" },
		{ "<leader>fs", desc = "Find LSP document symbols" },
		{ "<leader>fS", desc = "Find LSP symbols (strings/headers)" },
		{ "<leader>ft", desc = "Find Treesitter symbols" },
		{ "<leader>fm", desc = "Find spell suggestions" },
		{ "<leader>f'", desc = "Find marks" },
		{ "<leader>f,", desc = "Resume last picker" },
		{ "<leader>f.", desc = "Find recent files" },
		{ "<leader>gb", desc = "Find git branches" },
		{ "<leader>gC", desc = "Find git commits" },
	},
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

		local fzf = require("fzf-lua")

		vim.keymap.set("n", "<leader>fp", function()
			fzf.builtin()
		end, { desc = "Find picker" })
		vim.keymap.set("n", "<leader>ff", function()
			fzf.files()
		end, { desc = "Find files" })
		vim.keymap.set("n", "<leader>f~", function()
			fzf.files({ cwd = vim.fn.expand("~"), prompt = "Home files❯ ", hidden = true })
		end, { desc = "Find files in home directory" })
		vim.keymap.set("n", "<leader>fg", function()
			fzf.live_grep()
		end, { desc = "Find with grep" })
		vim.keymap.set("n", "<leader>fq", function()
			fzf.grep_quickfix()
		end, { desc = "Find inside quickfix with grep" })
		vim.keymap.set("n", "<leader>fb", function()
			fzf.buffers()
		end, { desc = "Find buffers" })
		vim.keymap.set("n", "<leader>fh", function()
			fzf.help_tags()
		end, { desc = "Find help tags" })
		vim.keymap.set("n", "<leader>fk", function()
			fzf.keymaps()
		end, { desc = "Find keymaps" })
		vim.keymap.set("n", "<leader>fw", function()
			fzf.grep_cword()
		end, { desc = "Find current word" })
		vim.keymap.set("n", "<leader>fd", function()
			fzf.diagnostics_document()
		end, { desc = "Find diagnostics in current buffer" })
		vim.keymap.set("n", "<leader>fD", function()
			fzf.diagnostics_workspace()
		end, { desc = "Find diagnostics globally" })
		vim.keymap.set("n", "<leader>fl", function()
			fzf.lsp_definitions()
		end, { desc = "Find LSP definitions" })
		vim.keymap.set("n", "<leader>fr", function()
			fzf.lsp_references()
		end, { desc = "Find LSP references" })
		vim.keymap.set("n", "<leader>fs", function()
			fzf.lsp_document_symbols()
		end, { desc = "Find LSP document symbols" })
		vim.keymap.set("n", "<leader>fS", function()
			fzf.lsp_document_symbols({ regex_filter = "Str.*" })
		end, { desc = "Find LSP symbols (strings/headers)" })
		vim.keymap.set("n", "<leader>ft", function()
			fzf.treesitter()
		end, { desc = "Find Treesitter symbols" })
		vim.keymap.set("n", "<leader>fm", function()
			fzf.spell_suggest()
		end, { desc = "Find spell suggestions" })
		vim.keymap.set("n", "<leader>f'", function()
			fzf.marks()
		end, { desc = "Find marks" })
		vim.keymap.set("n", "<leader>f,", function()
			fzf.resume()
		end, { desc = "Resume last picker" })
		vim.keymap.set("n", "<leader>f.", function()
			fzf.oldfiles()
		end, { desc = "Find recent files" })
		vim.keymap.set("n", "<leader>gb", function()
			fzf.git_branches()
		end, { desc = "Find git branches" })
		vim.keymap.set("n", "<leader>gC", function()
			fzf.git_commits()
		end, { desc = "Find git commits" })
	end,
}
