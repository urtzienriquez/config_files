return {
	"refractalize/oil-git-status.nvim",

	dependencies = {
		"stevearc/oil.nvim",
	},

	config = true,
	opts = {
		show_ignored = true, -- show files that match gitignore with !!
		symbols = { -- customize the symbols that appear in the git status columns
			index = {
				["!"] = "", -- ignored
				["?"] = "", -- untracked
				["A"] = "", -- added
				["C"] = "", -- copied
				["D"] = "", -- deleted
				["M"] = "", -- modified
				["R"] = "", -- renamed
				["T"] = "", -- type changed
				["U"] = "", -- unmerged
				[" "] = " ",
			},
			working_tree = {
				["!"] = "", -- ignored
				["?"] = "", -- untracked
				["A"] = "", -- added
				["C"] = "", -- copied
				["D"] = "", -- deleted
				["M"] = "", -- modified
				["R"] = "", -- renamed
				["T"] = "", -- type changed
				["U"] = "", -- unmerged
				[" "] = " ",
			},
		},
	},
}
