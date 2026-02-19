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
					completion = true,
					hover = true,
					signature = true,
					implementation = false,
					definition = false,
					references = false,
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
		end,
	},
}
