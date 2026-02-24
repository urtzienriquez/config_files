return {
	cmd = {
		vim.fn.stdpath("data") .. "/mason/bin/fortls",
		"--lowercase_intrinsics",
		"--notify_init",
		"--hover_signature",
		"--hover_language=fortran",
		"--use_signature_help",
		"--symbol_skip_mem",
		"--autocomplete_no_prefix",
		"--autocomplete_name_only",
		"--variable_hover",
	},
	filetypes = { "fortran" },
	root_markers = { ".git" },
}
