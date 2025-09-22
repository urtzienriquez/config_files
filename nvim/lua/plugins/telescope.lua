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
			local actions = require("telescope.actions")
			local action_layout = require("telescope.actions.layout")

			telescope.setup({
				defaults = {
					layout_strategy = "horizontal",
					layout_config = {
						prompt_position = "top",
					},
					sorting_strategy = "ascending",
					-- mappings = {
					-- 	i = {
					-- 		["<C-j>"] = actions.move_selection_next,
					-- 		["<C-k>"] = actions.move_selection_previous,
					-- 		["<C-p>"] = action_layout.toggle_preview,
					-- 		["<C-h>"] = actions.which_key,
					-- 		["<C-s>"] = actions.cycle_previewers_next,
					-- 	},
					-- 	n = {
					-- 		["<C-j>"] = actions.move_selection_next,
					-- 		["<C-k>"] = actions.move_selection_previous,
					-- 		["<C-p>"] = action_layout.toggle_preview,
					-- 		["<C-h>"] = actions.which_key,
					-- 		["<C-s>"] = actions.cycle_previewers_next,
					-- 	},
					-- },
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
		end,
	},
}
