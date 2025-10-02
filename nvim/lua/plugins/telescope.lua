return {
	{
		"nvim-telescope/telescope.nvim",
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

				-- Create backdrop buffer
				backdrop_bufnr = vim.api.nvim_create_buf(false, true)
				vim.bo[backdrop_bufnr].bufhidden = "wipe"

				-- Get screen dimensions
				local width = vim.o.columns
				local height = vim.o.lines

				-- Create fullscreen backdrop window
				backdrop_winid = vim.api.nvim_open_win(backdrop_bufnr, false, {
					relative = "editor",
					width = width,
					height = height,
					col = 0,
					row = 0,
					style = "minimal",
					focusable = false,
					zindex = 1, -- Below Telescope windows
				})

				-- Set backdrop highlight
				vim.wo[backdrop_winid].winhl = "Normal:TelescopeBackdrop"
				vim.wo[backdrop_winid].winblend = 40 -- Transparency level (0-100)
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

			-- Set up backdrop highlight
			vim.api.nvim_set_hl(0, "TelescopeBackdrop", { bg = "#000000" })

			-- Auto-create backdrop when Telescope opens
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "TelescopePrompt",
				callback = function()
					create_backdrop()
				end,
			})

			-- Auto-remove backdrop when Telescope closes
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
