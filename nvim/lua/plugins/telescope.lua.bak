return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		keys = {
			{ "<leader>fp", "<cmd>Telescope builtin<cr>", desc = "Find picker" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{
				"<leader>f~",
				function()
					require("telescope.builtin").find_files({
						cwd = vim.fn.expand("~"),
						prompt_title = "Find files in home directory",
						hidden = true,
					})
				end,
				desc = "Find files in home directory",
			},
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Find with grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find help tags" },
			{ "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Find keymaps" },
			{ "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find word" },
			{ "<leader>fdg", "<cmd>Telescope diagnostics<cr>", desc = "Find diagnostics globally" },
			{
				"<leader>fdd",
				function()
					require("telescope.builtin").diagnostics({ bufnr = 0 })
				end,
				desc = "Find diagnostics in current buffer",
			},
			{ "<leader>fl", "<cmd>Telescope lsp_definitions<cr>", desc = "Find lsp definitions" },
			{ "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "Find lsp references" },
			{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Find lsp document symbols" },
			{ "<leader>ft", "<cmd>Telescope treesitter<cr>", desc = "Find treesitter symbols" },
			{ "<leader>fm", "<cmd>Telescope spell_suggest<cr>", desc = "Find spell suggestion" },
			{ "<leader>f'", "<cmd>Telescope marks<cr>", desc = "Find marks" },
			{ "<leader>f,", "<cmd>Telescope resume<cr>", desc = "Find resume" },
			{ "<leader>f.", "<cmd>Telescope oldfiles<cr>", desc = "Find recent files" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
			},
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			local telescope = require("telescope")

			-- Create backdrop window manager
			local backdrop_bufnr = nil
			local backdrop_winid = nil

			local function create_backdrop()
				if backdrop_winid and vim.api.nvim_win_is_valid(backdrop_winid) then
					return
				end

				backdrop_bufnr = vim.api.nvim_create_buf(false, true)
				vim.bo[backdrop_bufnr].bufhidden = "wipe"

				local width = vim.o.columns
				local height = vim.o.lines

				backdrop_winid = vim.api.nvim_open_win(backdrop_bufnr, false, {
					relative = "editor",
					width = width,
					height = height,
					col = 0,
					row = 0,
					style = "minimal",
					focusable = false,
					zindex = 1,
				})

				vim.wo[backdrop_winid].winhl = "Normal:TelescopeBackdrop"
				vim.wo[backdrop_winid].winblend = 40
			end

			local function remove_backdrop()
				if backdrop_winid and vim.api.nvim_win_is_valid(backdrop_winid) then
					vim.api.nvim_win_close(backdrop_winid, true)
					backdrop_winid = nil
				end
				if backdrop_bufnr and vim.api.nvim_buf_is_valid(backdrop_bufnr) then
					vim.api.nvim_buf_delete(backdrop_bufnr, { force = true })
					backdrop_bufnr = nil
				end
			end

			telescope.setup({
				defaults = {
					layout_strategy = "horizontal",
					layout_config = {
						prompt_position = "top",
					},
					sorting_strategy = "ascending",
				},
				pickers = {
					buffers = {
						show_all_buffers = true,
						sort_lastused = true,
						mappings = {
							i = {
								["<c-d>"] = "delete_buffer",
							},
						},
					},
					find_files = {
						hidden = true,
						no_ignore = true,
						file_ignore_patterns = { ".git/" },
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
				},
			})

			telescope.load_extension("ui-select")
			telescope.load_extension("fzf")

			vim.api.nvim_set_hl(0, "TelescopeBackdrop", { bg = "#000000" })

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "TelescopePrompt",
				callback = function()
					create_backdrop()
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "TelescopePrompt",
				callback = function(args)
					vim.api.nvim_create_autocmd("BufWinLeave", {
						buffer = args.buf,
						once = true,
						callback = function()
							vim.schedule(remove_backdrop)
						end,
					})
				end,
			})
		end,
	},
}
