-- Neovim LSP configuration using the new API (Neovim 0.10+)
-- This file explicitly defines and starts LSP servers without relying on lspconfig.setup()
-- Updated to work with blink.nvim instead of nvim-cmp
-- -------------------------------------------------------------------
-- Ensure the configs table exists
-- -------------------------------------------------------------------
vim.lsp.configs = vim.lsp.configs or {}

-- -------------------------------------------------------------------
-- Default LSP capabilities (integrates with blink.nvim)
-- -------------------------------------------------------------------
local default_opts = {
	capabilities = vim.tbl_deep_extend(
		"force",
		vim.lsp.protocol.make_client_capabilities(),
		require("blink.cmp").get_lsp_capabilities()
	),
}

-- -------------------------------------------------------------------
-- Helper: Define a config if it hasn't been created yet
-- -------------------------------------------------------------------
local function ensure_config(name, config)
	if not vim.lsp.configs[name] then
		vim.lsp.configs[name] = config
	end
end

-- -------------------------------------------------------------------
-- Helper: Find root directory with fallback
-- -------------------------------------------------------------------
local function find_root_dir(fname, patterns)
	local path = vim.fn.fnamemodify(fname, ":p:h")
	while path ~= "/" and path ~= "" do
		for _, pattern in ipairs(patterns) do
			local full_path = path .. "/" .. pattern
			if vim.fn.filereadable(full_path) == 1 or vim.fn.isdirectory(full_path) == 1 then
				return path
			end
		end
		local parent = vim.fn.fnamemodify(path, ":h")
		if parent == path then
			break
		end
		path = parent
	end
	-- Fallback to file directory - this is key for standalone files!
	return vim.fn.fnamemodify(fname, ":p:h")
end

-- -------------------------------------------------------------------
-- Track running servers to prevent duplicates
-- -------------------------------------------------------------------
local running_servers = {}

-- -------------------------------------------------------------------
-- Language server configurations
-- -------------------------------------------------------------------
local servers = {
	-- Go
	gopls = vim.tbl_extend("force", default_opts, {
		cmd = { "gopls" },
		filetypes = { "go", "gomod", "gowork", "gotmpl" },
		root_patterns = { "go.mod", ".git" },
	}),
	-- R
	r_language_server = vim.tbl_extend("force", default_opts, {
		cmd = { "R", "--slave", "-e", "languageserver::run()" },
		filetypes = { "r", "rmd", "quarto" },
		root_patterns = { ".git" },
	}),
	-- MATLAB
	matlab_language_server = vim.tbl_extend("force", default_opts, {
		cmd = {
			"matlab-language-server",
			"--stdio",
		},
		filetypes = { "matlab" },
		root_dir = function(fname)
			return find_root_dir(fname, { ".git" }) or vim.fn.getcwd()
		end,
		settings = {
			MATLAB = {
				indexWorkspace = true,
				matlabConnectionTiming = "onStart",
				telemetry = false,
			},
		},
	}),
	-- Python
	pyright = vim.tbl_extend("force", default_opts, {
		cmd = { "pyright-langserver", "--stdio" },
		filetypes = { "python" },
		root_patterns = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
		settings = {
			python = {
				analysis = {
					autoSearchPaths = true,
					diagnosticMode = "openFilesOnly", -- or "workspace"
					useLibraryCodeForTypes = true,
				},
			},
		},
	}),
	-- JavaScript / TypeScript
	ts_ls = vim.tbl_extend("force", default_opts, {
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		root_patterns = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	}),
	-- Julia
	julials = vim.tbl_extend("force", default_opts, {
		cmd = {
			"julia",
			"--project=@v1.11",
			"--startup-file=no",
			"--history-file=no",
			"-e",
			[[
      using Pkg
      Pkg.instantiate()
      using LanguageServer
      depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
      project_path = let
        dirname(something(
          ## 1. Finds an explicitly set project (JULIA_PROJECT)
          Base.load_path_expand((
            p = get(ENV, "JULIA_PROJECT", nothing);
            p === nothing ? nothing : isempty(p) ? nothing : p
          )),
          ## 2. Look for a Project.toml file in the current working directory,
          ##    or parent directories, with $HOME as an upper boundary
          Base.current_project(),
          ## 3. First entry in the load path
          get(Base.load_path(), 1, nothing),
          ## 4. Fallback to default global environment,
          ##    this is more or less unreachable
          Base.load_path_expand("@v#.#"),
        ))
      end
      @info "Running language server" VERSION pwd() project_path depot_path
      server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)
      server.runlinter = true
      run(server)
    ]],
		},
		filetypes = { "julia" },
		root_patterns = { "Project.toml", "JuliaProject.toml", ".git" },
		settings = {},
	}),
	-- Fortran
	fortls = vim.tbl_extend("force", default_opts, {
		cmd = {
			"fortls",
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
		root_patterns = { ".git" },
	}),
	-- Lua (for Neovim config development)
	lua_ls = vim.tbl_extend("force", default_opts, {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_patterns = {
			".luarc.json",
			".luarc.jsonc",
			".luacheckrc",
			".stylua.toml",
			"stylua.toml",
			"selene.toml",
			"selene.yml",
			".git",
		},
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = { globals = { "vim" } },
				workspace = {
					checkThirdParty = false,
					library = vim.api.nvim_get_runtime_file("", true),
				},
				telemetry = { enable = false },
			},
		},
	}),
	-- Markdown (including Quarto) - using Mason-installed marksman
	marksman = vim.tbl_extend("force", default_opts, {
		cmd = { vim.fn.stdpath("data") .. "/mason/bin/marksman", "server" },
		filetypes = { "markdown", "markdown.mdx", "quarto" },
		root_patterns = { ".marksman.toml", "_quarto.yml", ".git" },
		settings = {
			marksman = {
				-- Optional settings
				-- completion = {
				--     wiki = {
				--         style = "title"  -- or "file-stem"
				--     }
				-- }
			},
		},
	}),
}

-- -------------------------------------------------------------------
-- Setup function to register and start LSPs dynamically
-- -------------------------------------------------------------------
local function configure_lsp()
	for name, opts in pairs(servers) do
		-- Register the server if not already registered
		ensure_config(name, {
			default_config = opts,
		})
		-- Start the server when opening a matching filetype
		vim.api.nvim_create_autocmd("FileType", {
			pattern = opts.filetypes,
			callback = function(args)
				-- Get the filename for this buffer
				local fname = vim.api.nvim_buf_get_name(args.buf)
				if fname == "" then
					return -- Skip unnamed buffers
				end

				-- Calculate root directory with fallback
				local root_dir = find_root_dir(fname, opts.root_patterns or {})

				-- Create a unique key for this server/root combination
				local server_key = name .. ":" .. root_dir

				-- Check if we already have this exact server running for this root
				if running_servers[server_key] then
					-- Try to attach the existing client to this buffer
					local client_id = running_servers[server_key]
					local client = vim.lsp.get_client_by_id(client_id)
					if client and client.is_stopped() == false then
						vim.lsp.buf_attach_client(args.buf, client_id)
						return
					else
						-- Client is gone, remove from tracking
						running_servers[server_key] = nil
					end
				end

				-- Check for any existing clients with this name attached to this buffer
				local existing_clients = vim.lsp.get_clients({ bufnr = args.buf, name = name })
				if #existing_clients > 0 then
					return -- Already have a client of this type attached
				end

				-- Create config with root_dir and explicit name
				local config = vim.tbl_deep_extend("force", opts, {
					root_dir = root_dir,
					name = name, -- Ensure consistent naming
				})

				-- Start the LSP
				local client_id = vim.lsp.start(config, { bufnr = args.buf })

				-- Track the running server
				if client_id then
					running_servers[server_key] = client_id

					-- Clean up tracking when client stops
					local client = vim.lsp.get_client_by_id(client_id)
					if client then
						client.on_exit = function()
							running_servers[server_key] = nil
						end
					end
				end
			end,
		})
	end
end

-- -------------------------------------------------------------------
-- Plugin spec for lazy.nvim
-- -------------------------------------------------------------------
return {
	"neovim/nvim-lspconfig",
	config = configure_lsp,
}
