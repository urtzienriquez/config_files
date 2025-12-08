return {
	{
		"R-nvim/R.nvim",
		ft = { "r", "rmd", "rnoweb", "quarto" },
		config = function()
			local opts = {
				R_app = "R",
				external_term = "tmux split-window -d -h",
				bracketed_paste = true,
				R_args = { "--no-save --silent" },
				r_ls = {
					completion = false,
					hover = false,
					signature = false,
				},
				objbr_mappings = {
					c = "class",
					["<leader>gp"] = "head({object}, n = 15)",
					v = function()
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

			local function set_chunk_highlights()
				local bg = (vim.o.background == "dark") and "#292e42" or "#c4c8da"

				-- RMarkdown chunks
				vim.cmd("hi! link rmdChunk CodeBlock")
				vim.cmd("hi! RCodeBlock guibg=" .. bg .. " guifg=NONE")
			end

			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = set_chunk_highlights,
			})

			vim.api.nvim_create_autocmd("OptionSet", {
				pattern = "background",
				callback = set_chunk_highlights,
			})

			vim.defer_fn(set_chunk_highlights, 100)
		end,
	},
}
