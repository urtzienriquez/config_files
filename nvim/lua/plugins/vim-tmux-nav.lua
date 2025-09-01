return {
	"christoomey/vim-tmux-navigator",
	lazy = false, -- Changed to load immediately so commands are available
	cmd = {
		"TmuxNavigateLeft",
		"TmuxNavigateDown",
		"TmuxNavigateUp",
		"TmuxNavigateRight",
		"TmuxNavigatePrevious",
		"TmuxNavigatorProcessList",
	},
}
