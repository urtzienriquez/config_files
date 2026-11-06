local function julia_root_dir(fname)
  local dir = vim.fs.dirname(fname)
  local root = vim.fs.find({ "Project.toml", "JuliaProject.toml", ".git" }, { upward = true, path = dir })[1]

  if root then
    return vim.fs.dirname(root)
  end

  -- fallback: use the current file's directory
  return dir
end

return {
  cmd = {
    "julia",
    "--startup-file=no",
    "--history-file=no",
    "-e",
    [[
            # LanguageServer is in the environment @lang_serv, which is put on the load path only
            # to load it: with --project=@lang_serv, the server would index that environment
            # instead of the one the code uses (the default @v#.#, or the project of the file)
            ls_env = joinpath(get(DEPOT_PATH, 1, joinpath(homedir(), ".julia")), "environments", "lang_serv")
            pushfirst!(LOAD_PATH, ls_env)
            using LanguageServer
            popfirst!(LOAD_PATH)
            depot_path = get(ENV, "JULIA_DEPOT_PATH", joinpath(homedir(), ".julia"))
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
        server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path)
        run(server)
        ]],
  },
  filetypes = { "julia" },
  root_dir = julia_root_dir(vim.api.nvim_buf_get_name(0)),
  -- LanguageServer 6 shows packages added with `] dev` only when their source is part of the
  -- workspace: every dev'd package of the project's Manifest.toml (its `path = "..."` entries)
  -- becomes a workspace folder too
  before_init = function(params, config)
    local root = config.root_dir
    if not root then
      return
    end
    local manifest = io.open(root .. "/Manifest.toml", "r")
    if not manifest then
      return
    end
    for line in manifest:lines() do
      local path = line:match('^path%s*=%s*"(.-)"')
      if path then
        if path:sub(1, 1) ~= "/" then
          path = vim.fs.normalize(root .. "/" .. path)
        end
        if vim.fn.isdirectory(path) == 1 then
          params.workspaceFolders = params.workspaceFolders or {}
          table.insert(params.workspaceFolders, { uri = vim.uri_from_fname(path), name = vim.fs.basename(path) })
        end
      end
    end
    manifest:close()
  end,
}
