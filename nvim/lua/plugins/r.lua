return {
	{
		"R-nvim/R.nvim",
		lazy = false,
		config = function()
			local opts = {
				R_app = "R",
				external_term = "tmux split-window -d -h",
				bracketed_paste = true,
				R_args = { "--no-save --silent" },
				min_editor_width = 72,
				rconsole_width = 78,
				objbr_mappings = { -- Object browser keymap
					c = "class", -- Call R functions
					["<leader>gg"] = "head({object}, n = 15)", -- Use {object} notation to write arbitrary R code.
					v = function()
						-- Run lua functions
						require("r.browser").toggle_view()
					end,
				},
				disable_cmds = {
					"RClearConsole",
					"RCustomStart",
					"RSPlot",
					"RSaveClose",
					"RSeparatePath",
					"RFormatSubsetting",
					"RFormatNumbers",
					"RDputObj",
					"RSendChain",
					"RDSendCurrentFun",
					"RSendCurrentFun",
					"RSendAllFun",
					"RDSendMBlock",
					"RSendMBlock",
					"RSendMotion",
					"RDSendSelection",
					"RInsertLineOutput",
					"RInsertPipe",
					"RSendLine",
					"RDSendParagraph",
					"RSendParagraph",
					"RShowRout",
					"RMakeRmd",
					"RMakePDFKb",
					"RMakeHTML",
					"RMakeODT",
					"RMakePDFK",
					"RMakeWord",
					"RUndebug",
				},
			}
			if vim.env.R_AUTO_START == "true" then
				opts.auto_start = "on startup"
				opts.objbr_auto_start = true
			end
			require("r").setup(opts)

			-- Unified chunk highlighting for both rmarkdown and rnoweb
			local function set_chunk_highlights()
				local bg = (vim.o.background == "dark") and "#292e42" or "#c4c8da"
				local delimiter_fg = (vim.o.background == "dark") and "#7aa2f7" or "#5555ff"

				-- RMarkdown chunks
				vim.cmd("hi! link rmdChunk CodeBlock")
				vim.cmd("hi! RCodeBlock guibg=" .. bg .. " guifg=NONE")

				-- Rnoweb delimiter styling
				vim.cmd("hi! rnowebDelimiter guifg=" .. delimiter_fg .. " gui=bold guibg=" .. bg)
			end

			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = set_chunk_highlights,
			})

			vim.defer_fn(set_chunk_highlights, 100)

			-- Add this to your R.nvim config function
			vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
				pattern = "*.Rnw",
				callback = function()
					local ns = vim.api.nvim_create_namespace("rnoweb_chunk_bg")
					local buf = vim.api.nvim_get_current_buf()
					vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

					local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
					local in_chunk = false

					for i, line in ipairs(lines) do
						if line:match("^<<.*>>=") then
							in_chunk = true
						end

						if in_chunk then
							-- Set the entire line background
							vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
								line_hl_group = "RCodeBlock",
							})
						end

						if line:match("^@%s*$") then
							in_chunk = false
						end
					end
				end,
			})
		end,
	},
}
