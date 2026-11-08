-- Build, run and debug C/C++ programs, whatever builds them:
--   build.sh        the targets of its `case` (./build.sh debug, ./build.sh release, ...)
--   Makefile        its targets (make -j, so builds use every core)
--   CMakeLists.txt  Debug / Release / RelWithDebInfo, each in build/<type>/
--   none            the file itself (or its folder), with a profile: debug, asan, release, ...
-- The nearest of these, walking up from the file, is the project (build.sh first, then a
-- Makefile, then CMake). Builds run in the background; their errors go to the quickfix list.
-- What you pick (build target, debug target, program, arguments) is remembered per project.

local M = {}

M.config = {
  cc = "gcc",
  cxx = "clang++",
  cstd = "c17",
  cxxstd = "c++20",
  warnings = { "-Wall", "-Wextra" },
  run_height = 15, -- of the terminal <leader>cr runs the program in
}

-- the profiles of a file without a build system (a custom one is your own flags)
local PROFILES = { "debug", "asan", "release", "release+symbols" }
local PROFILE_FLAGS = {
  debug = { "-O0", "-g3" },
  asan = { "-O0", "-g3", "-fsanitize=address,undefined", "-fno-omit-frame-pointer" },
  release = { "-O2", "-DNDEBUG" },
  ["release+symbols"] = { "-O2", "-g3", "-fno-omit-frame-pointer" }, -- for perf, or debugging optimised code
}
local CMAKE_TYPES = { "Debug", "Release", "RelWithDebInfo" }
local JOBS = vim.uv.available_parallelism()

-- under the debugger the sanitizers stop the program at the error (so gdb shows where it is)
-- instead of exiting; the leak check is off, as it does not work under a debugger
M.debug_env = {
  ASAN_OPTIONS = "abort_on_error=1:detect_leaks=0",
  UBSAN_OPTIONS = "print_stacktrace=1:halt_on_error=1:abort_on_error=1",
}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "build" })
end

----------------------------------------
-- coroutines: so prompts and builds read as straight-line code

local function resume(co, ...)
  local ok, err = coroutine.resume(co, ...)
  if not ok then
    notify(debug.traceback(co, tostring(err)), vim.log.levels.ERROR)
  end
end

local function async(fn)
  return function(...)
    resume(coroutine.create(fn), ...)
  end
end

-- waits for `start(callback)` to call back (at once or later), and returns what it got
local function await(start)
  local co = assert(coroutine.running(), "await outside a coroutine")
  local result, waiting
  start(function(...)
    result = { n = select("#", ...), ... }
    if waiting then
      resume(co)
    end
  end)
  if not result then
    waiting = true
    coroutine.yield()
  end
  return unpack(result, 1, result.n)
end

local function input(opts)
  return await(function(cb)
    vim.ui.input(opts, cb)
  end)
end

local function select_one(items, opts)
  return await(function(cb)
    vim.ui.select(items, opts, cb)
  end)
end

----------------------------------------
-- what is remembered, per project (its root folder)

local store_file = vim.fn.stdpath("data") .. "/build-projects.json"
local store

local function state(root)
  if not store then
    local ok, data = pcall(function()
      return vim.json.decode(table.concat(vim.fn.readfile(store_file), "\n"))
    end)
    store = ok and type(data) == "table" and data or {}
  end
  store[root] = store[root] or {}
  local s = store[root]
  s.programs = s.programs or {} -- per target
  s.args = s.args or {} -- per program in a folder of files, else one for the project ("*")
  s.custom = s.custom or {} -- targets typed by hand, the last first
  return s
end

local function save()
  vim.fn.writefile({ vim.json.encode(store) }, store_file)
end

----------------------------------------
-- the project

local function read(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  return ok and lines or {}
end

local function exists(path)
  return vim.uv.fs_stat(path) ~= nil
end

local function find_root(path)
  local home = vim.uv.os_homedir()
  local root = vim.fs.root(path, { "build.sh", "GNUmakefile", "makefile", "Makefile", "CMakeLists.txt" })
  if not root or root == home or root == "/" then -- a stray Makefile in ~ is no project
    return nil
  end
  if exists(root .. "/build.sh") then
    return root, "buildsh", "build.sh"
  end
  for _, file in ipairs({ "GNUmakefile", "makefile", "Makefile" }) do
    if exists(root .. "/" .. file) then
      return root, "make", file
    end
  end
  -- a CMake project's root is its topmost CMakeLists.txt
  while exists(vim.fs.dirname(root) .. "/CMakeLists.txt") do
    root = vim.fs.dirname(root)
  end
  return root, "cmake", "CMakeLists.txt"
end

---@return table?, string?
local function project(buf)
  buf = buf or 0
  local name = vim.api.nvim_buf_get_name(buf)
  local path = (vim.bo[buf].buftype == "" and name ~= "") and vim.fs.normalize(name) or vim.fn.getcwd()
  local root, kind, file = find_root(path)
  local ft = vim.bo[buf].filetype
  if not root then
    if ft ~= "c" and ft ~= "cpp" then
      return nil, "no build.sh, Makefile or CMakeLists.txt above " .. path
    end
    root, kind = vim.fs.dirname(path), "single"
  end
  return { root = root, kind = kind, file = file, path = path, lang = ft == "c" and "c" or "cpp", state = state(root) }
end

-- the targets to choose from, and the one used when none was chosen
local function targets(p)
  if p.kind == "single" then
    return vim.deepcopy(PROFILES), "debug"
  elseif p.kind == "cmake" then
    return vim.deepcopy(CMAKE_TYPES), "Debug"
  end
  local list, seen, default = {}, {}, nil
  local function add(t)
    if not seen[t] then
      seen[t] = true
      table.insert(list, t)
    end
  end
  for _, line in ipairs(read(p.root .. "/" .. p.file)) do
    if p.kind == "buildsh" then
      default = default or line:match("%${1:%-([%w_%-]+)}")
      local labels = line:match("^%s*([%w_%-|]+)%)")
      for t in (labels or ""):gmatch("[%w_%-]+") do
        add(t)
      end
    else
      local t, after = line:match("^([%w_][%w_%-%./]*)%s*:(.?)")
      if t and after ~= "=" and not t:find("%.o$") then -- not `VAR := value`, nor object files
        add(t)
      end
    end
  end
  if p.kind == "make" then
    default = list[1] -- what a bare `make` builds
  end
  if #list == 0 then
    return { "" }, "" -- a build.sh without targets: just run it
  end
  return list, default or list[1]
end

local function active_target(p)
  return p.state.target or select(2, targets(p))
end

local function is_debug_flags(t)
  return t == "debug" or t == "asan" or (not PROFILE_FLAGS[t] and t:find("%-g") ~= nil)
end

-- a folder of files: the file with main() (this one, or the folder's only one), with every
-- file of the folder that has no main()
local SOURCE_EXTS = { c = { c = true }, cpp = { cpp = true, cc = true, cxx = true } }

local function has_main(file)
  for _, line in ipairs(read(file)) do
    if line:match("^%s*int%s+main%s*%(") or line:match("^%s*auto%s+main%s*%(") then
      return true
    end
  end
  return false
end

local function single_sources(p)
  local files = {}
  for name, type in vim.fs.dir(p.root) do
    local ext = name:match("%.([^.]+)$")
    if type == "file" and ext and SOURCE_EXTS[p.lang][ext] then
      table.insert(files, p.root .. "/" .. name)
    end
  end
  table.sort(files)
  local mains, others = {}, {}
  for _, file in ipairs(files) do
    table.insert(has_main(file) and mains or others, file)
  end
  local main
  if vim.tbl_contains(mains, p.path) then
    main = p.path
  elseif #mains == 1 then
    main = mains[1]
  elseif #mains == 0 then
    return nil, "no main() in " .. p.root
  else
    return nil, "several files here have main(): open the one to build"
  end
  return { sources = vim.list_extend({ main }, others), program = (main:gsub("%.[^.]+$", "")) }
end

----------------------------------------
-- building

-- gcc's (and clang's) error format, which also follows make's "Entering directory"
local efm
local function errorformat()
  if not efm then
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("compiler gcc")
    end)
    efm = vim.bo[buf].errorformat
    vim.api.nvim_buf_delete(buf, { force = true })
  end
  return efm
end

local function sh(cmd, cwd, dir, label)
  return { cmd = { "sh", "-c", cmd }, cwd = cwd, dir = dir or cwd, title = cmd, label = label }
end

-- how to build `target`: { cmd, cwd, dir (that relative paths in errors are from), title, label }
local function build_command(p, target)
  if p.kind == "buildsh" then
    local script = vim.fn.executable(p.root .. "/build.sh") == 1 and "./build.sh" or "sh build.sh"
    return sh(vim.trim(script .. " " .. target), p.root, nil, "build.sh " .. target)
  elseif p.kind == "make" then
    return sh(vim.trim(("make -j%d -Otarget %s"):format(JOBS, target)), p.root, nil, "make " .. target)
  elseif p.kind == "cmake" then
    local dir = "build/" .. target
    local configure = ("cmake -S . -B %s -DCMAKE_BUILD_TYPE=%s -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"):format(dir, target)
    local cmd = ("[ -f %s/CMakeCache.txt ] || %s && cmake --build %s -j %d"):format(dir, configure, dir, JOBS)
    return sh(cmd, p.root, p.root .. "/" .. dir, "cmake " .. target)
  end
  local single, err = single_sources(p)
  if not single then
    return nil, err
  end
  local c = p.lang == "c"
  local compiler = c and M.config.cc or M.config.cxx
  local flags = PROFILE_FLAGS[target] or vim.split(target, "%s+", { trimempty = true })
  local cmd = { compiler, "-std=" .. (c and M.config.cstd or M.config.cxxstd) }
  vim.list_extend(cmd, M.config.warnings)
  vim.list_extend(cmd, flags)
  if compiler:find("clang") and is_debug_flags(target) then
    table.insert(cmd, "-fstandalone-debug") -- full debug info of the standard library's types
  end
  vim.list_extend(cmd, { "-o", single.program })
  vim.list_extend(cmd, single.sources)
  if c then
    table.insert(cmd, "-lm")
  end
  local shown = vim.tbl_map(function(a)
    return a:sub(1, #p.root + 1) == p.root .. "/" and a:sub(#p.root + 2) or a
  end, cmd)
  return {
    cmd = cmd,
    cwd = p.root,
    dir = p.root,
    title = table.concat(shown, " "),
    label = vim.fs.basename(single.program) .. " (" .. target .. ")",
    program = single.program,
  }
end

local job -- the build running

-- builds `target` in the background; calls back with (ok, command)
local function build(p, target, cb)
  local spec, err = build_command(p, target)
  if not spec then
    notify(err, vim.log.levels.WARN)
    return cb(false)
  end
  if job then
    job.cancelled = true
    job.handle:kill("sigterm")
  end
  local me, chunks, start = {}, {}, vim.uv.hrtime()
  local function collect(_, data)
    if data then
      table.insert(chunks, data)
    end
  end
  notify("Building " .. spec.label .. " …")
  local ok, handle = pcall(
    vim.system,
    spec.cmd,
    { cwd = spec.cwd, text = true, stdout = collect, stderr = collect },
    function(res)
      vim.schedule(function()
        if job == me then
          job = nil
        end
        if me.cancelled then
          notify("Build of " .. spec.label .. " cancelled", vim.log.levels.WARN)
          return cb(false)
        end
        local output = table.concat(chunks)
        local lines = vim.split(output, "\n", { trimempty = true })
        table.insert(lines, 1, ("build: Entering directory '%s'"):format(spec.dir))
        vim.fn.setqflist({}, " ", { title = spec.title, lines = lines, efm = errorformat() })
        local warnings = 0
        for _, item in ipairs(vim.fn.getqflist()) do
          if item.valid == 1 and item.type:lower() == "w" then
            warnings = warnings + 1
          end
        end
        local secs = (vim.uv.hrtime() - start) / 1e9
        if res.code == 0 then
          local note = (output == "" and not spec.program) and ", up to date" or "" -- compilers say nothing
          if warnings > 0 then
            note = note .. (", %d warning%s (:copen)"):format(warnings, warnings > 1 and "s" or "")
          end
          notify(("Built %s in %.1fs%s"):format(spec.label, secs, note))
          cb(true, spec)
        else
          vim.cmd("copen | wincmd p")
          notify(
            ("Build of %s failed (exit %d): see the quickfix list"):format(spec.label, res.code),
            vim.log.levels.ERROR
          )
          cb(false)
        end
      end)
    end
  )
  if not ok then
    notify("could not start the build: " .. tostring(handle), vim.log.levels.ERROR)
    return cb(false)
  end
  me.handle = handle
  job = me
end

----------------------------------------
-- choosing targets and programs (in a coroutine)

local CUSTOM = "\0custom"
local CUSTOM_PROMPT = {
  single = "Compiler flags (e.g. -O1 -g -DTRACE): ",
  buildsh = "build.sh arguments: ",
  make = "make arguments (e.g. -B CXXFLAGS='-O0 -g'): ",
  cmake = "CMake build type: ",
}

-- which: "target" (built by <leader>cc and run by <leader>cr) or "debug_target"
local function pick(p, which, current)
  local list = targets(p)
  for _, t in ipairs(p.state.custom) do
    if not vim.tbl_contains(list, t) then
      table.insert(list, t)
    end
  end
  table.insert(list, CUSTOM)
  local choice = select_one(list, {
    prompt = (which == "target" and "Build target" or "Debug target (built with debug info)") .. " — " .. p.root,
    format_item = function(t)
      if t == CUSTOM then
        return "other…"
      end
      return (t == "" and "(default)" or t) .. (t == current and "  ●" or "")
    end,
  })
  if choice == CUSTOM then
    choice = input({ prompt = CUSTOM_PROMPT[p.kind] })
    if not choice then
      return nil
    end
    choice = vim.trim(choice)
    p.state.custom = vim.tbl_filter(function(t)
      return t ~= choice
    end, p.state.custom)
    table.insert(p.state.custom, 1, choice)
    p.state.custom[9] = nil
  end
  if choice then
    p.state[which] = choice
    save()
  end
  return choice
end

local function debug_target(p)
  if p.state.debug_target then
    return p.state.debug_target
  elseif p.kind == "single" then
    local t = active_target(p)
    return is_debug_flags(t) and t or "debug"
  elseif p.kind == "cmake" then
    return "Debug"
  elseif vim.tbl_contains(targets(p), "debug") then
    return "debug"
  end
  notify("Which target builds this project with debug info (-g)? (asked once)")
  return pick(p, "debug_target")
end

local function absolute(p, path)
  return path:sub(1, 1) == "/" and path or vim.fs.normalize(p.root .. "/" .. path)
end

-- the program `target` makes, if it can be told from the build files
local function guess_program(p, target)
  if p.state.programs[target] then
    return absolute(p, p.state.programs[target])
  end
  local name = target
  if name == "" then
    name = select(2, targets(p))
  end
  if p.kind == "buildsh" then
    for _, line in ipairs(read(p.root .. "/build.sh")) do
      local out = line:match("^%s*" .. vim.pesc(name) .. "%)%s*build%s+(%S+)")
      if out then
        return absolute(p, out)
      end
    end
  elseif p.kind == "make" then
    if name:find("/") then -- the target is the program: `bin/stats: ...`
      return absolute(p, name)
    end
    -- a name for one program: `debug: bin/stats_debug`
    for _, line in ipairs(read(p.root .. "/" .. p.file)) do
      local out = line:match("^" .. vim.pesc(name) .. "%s*:%s*(%S+/%S+)%s*$")
      if out then
        return absolute(p, out)
      end
    end
  end
end

local function ask_program(p, target)
  local path = input({
    prompt = ("Program that '%s' builds: "):format(target == "" and "(default)" or target),
    default = guess_program(p, target) or (p.root .. "/"),
    completion = "file",
  })
  if not path or vim.trim(path) == "" then
    return nil
  end
  path = vim.fs.normalize(vim.fn.fnamemodify(vim.trim(path), ":p"))
  local rel = path:sub(1, #p.root + 1) == p.root .. "/" and path:sub(#p.root + 2) or path
  p.state.programs[target] = rel
  save()
  return path
end

local function program_for(p, target)
  if p.kind == "single" then
    local single, err = single_sources(p)
    if not single then
      notify(err, vim.log.levels.WARN)
    end
    return single and single.program
  end
  return guess_program(p, target) or ask_program(p, target)
end

local function args_key(p, program)
  return p.kind == "single" and program or "*"
end

-- "a 'b c' d" -> { "a", "b c", "d" }
local function split_args(s)
  local out, cur, quote = {}, nil, nil
  for ch in (s or ""):gmatch(".") do
    if quote then
      if ch == quote then
        quote = nil
      else
        cur = cur .. ch
      end
    elseif ch == "'" or ch == '"' then
      quote, cur = ch, cur or ""
    elseif ch:match("%s") then
      if cur then
        table.insert(out, cur)
        cur = nil
      end
    else
      cur = (cur or "") .. ch
    end
  end
  if cur then
    table.insert(out, cur)
  end
  return out
end

-- start of every command: save the files, find the project
local function begin()
  vim.cmd("silent! wall")
  local p, err = project()
  if not p then
    notify(err, vim.log.levels.WARN)
  end
  return p
end

----------------------------------------
-- running

local run_buf

local function run_in_terminal(cmd, cwd)
  local win = run_buf and vim.api.nvim_buf_is_valid(run_buf) and vim.fn.bufwinid(run_buf) or -1
  if win ~= -1 then
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd(("topleft %dsplit"):format(M.config.run_height))
  end
  local old = run_buf
  run_buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_win_set_buf(0, run_buf)
  vim.fn.jobstart(cmd, { term = true, cwd = cwd })
  if old and old ~= run_buf and vim.api.nvim_buf_is_valid(old) then
    vim.api.nvim_buf_delete(old, { force = true })
  end
  vim.cmd.startinsert()
end

----------------------------------------
-- the commands

M.build = async(function(target)
  local p = begin()
  if p then
    build(p, (target and target ~= "") and target or active_target(p), function() end)
  end
end)

M.run = async(function()
  local p = begin()
  if not p then
    return
  end
  local target = active_target(p)
  local program = program_for(p, target)
  if not program then
    return
  end
  -- runs what was built last: building is <leader>cc's job
  if not exists(program) then
    notify(vim.fs.basename(program) .. " is not built yet (<leader>cc)", vim.log.levels.WARN)
    return
  elseif vim.fn.executable(program) ~= 1 then
    notify(program .. " is not an executable (set the right one with :BuildProgram)", vim.log.levels.WARN)
    return
  end
  local args = p.state.args[args_key(p, program)] or ""
  run_in_terminal(vim.trim(vim.fn.shellescape(program) .. " " .. args), p.root)
end)

-- builds the debug target; returns the nvim-dap configuration that debugs it, or nil
function M.prepare_debug()
  local p = begin()
  if not p then
    return nil
  end
  local target = debug_target(p)
  if not target then
    return nil
  end
  local program = program_for(p, target)
  if not program then
    return nil
  end
  local ok = await(function(cb)
    build(p, target, cb)
  end)
  if not ok then
    return nil
  end
  if vim.fn.executable(program) ~= 1 then
    notify(program .. " is not an executable (fix it with :BuildProgram)", vim.log.levels.WARN)
    return nil
  end
  return {
    name = "Build & debug",
    type = "gdb",
    request = "launch",
    program = program,
    args = split_args(p.state.args[args_key(p, program)]),
    cwd = p.root,
    env = M.debug_env,
    stopAtBeginningOfMainSubprogram = false,
  }
end

-- an nvim-dap configuration that builds before each start (the build is part of starting)
function M.dap_configuration()
  return setmetatable({ name = "Build & debug", type = "gdb", request = "launch" }, {
    __call = function()
      return M.prepare_debug() or { name = "Build & debug", type = "gdb", program = require("dap").ABORT }
    end,
  })
end

function M.debug()
  require("dap").run(M.dap_configuration())
end

-- the RAD debugger, outside nvim
M.debug_rad = async(function()
  local config = M.prepare_debug()
  if not config then
    return
  end
  local cmd = vim.list_extend({ "raddbg", config.program }, config.args)
  vim.fn.jobstart(cmd, { detach = true, cwd = config.cwd })
end)

M.pick_target = async(function()
  local p = begin()
  if p then
    local t = pick(p, "target", active_target(p))
    if t then
      notify("Build target: " .. (t == "" and "(default)" or t))
    end
  end
end)

M.pick_debug_target = async(function()
  local p = begin()
  if p then
    local current = p.state.debug_target
    p.state.debug_target = nil -- what it would be on its own, marked
    local guess = (p.kind == "single" or p.kind == "cmake" or vim.tbl_contains(targets(p), "debug")) and debug_target(p)
      or nil
    p.state.debug_target = current
    local t = pick(p, "debug_target", current or guess)
    if t then
      notify("Debug target: " .. (t == "" and "(default)" or t))
    end
  end
end)

M.set_args = async(function()
  local p = begin()
  if not p then
    return
  end
  local program = program_for(p, active_target(p))
  if not program then
    return
  end
  local key = args_key(p, program)
  local args =
    input({ prompt = ("Arguments of %s: "):format(vim.fs.basename(program)), default = p.state.args[key] or "" })
  if args then
    p.state.args[key] = vim.trim(args)
    save()
  end
end)

M.set_program = async(function()
  local p = begin()
  if not p then
    return
  end
  if p.kind == "single" then
    notify("Here the program is the file with main() (" .. (program_for(p) or "none") .. ")")
    return
  end
  local target = active_target(p)
  ask_program(p, target)
  local dt = p.state.debug_target or (vim.tbl_contains(targets(p), "debug") and "debug")
  if dt and dt ~= target then
    ask_program(p, dt)
  end
end)

M.info = async(function()
  local p = begin()
  if not p then
    return
  end
  local target = active_target(p)
  local dt = p.state.debug_target
    or (p.kind ~= "make" and p.kind ~= "buildsh" and debug_target(p))
    or (vim.tbl_contains(targets(p), "debug") and "debug")
  local function name(t)
    return t == nil and "(asked on the first debug)" or t == "" and "(default)" or t
  end
  local program = p.kind == "single" and program_for(p) or guess_program(p, target)
  local lines = {
    "Project:  "
      .. p.root
      .. "  ["
      .. ({ single = "single file", buildsh = "build.sh", make = "Makefile", cmake = "CMake" })[p.kind]
      .. "]",
    "Build:    " .. name(target),
    "Debug:    " .. name(dt or nil),
    "Program:  " .. (program or "(asked on the first run)"),
    "Args:     " .. (p.state.args[args_key(p, program)] or ""),
  }
  if p.kind == "single" then
    local spec = build_command(p, target)
    if spec then
      table.insert(lines, "Command:  " .. spec.title)
    end
  end
  notify(table.concat(lines, "\n"))
end)

function M.cancel()
  if job then
    job.cancelled = true
    job.handle:kill("sigterm")
  else
    notify("No build running")
  end
end

M.forget = async(function()
  local p = begin()
  if p then
    store[p.root] = nil
    save()
    notify("Forgot the settings of " .. p.root)
  end
end)

----------------------------------------
-- keymaps and commands

function M.attach(buf)
  local function map(lhs, fn, desc)
    vim.keymap.set("n", lhs, function()
      fn()
    end, { buffer = buf, desc = desc })
  end
  map("<leader>cc", M.build, "Build")
  map("<leader>ct", M.pick_target, "Choose build target")
  map("<leader>cr", M.run, "Run program")
  map("<leader>cv", M.debug_rad, "Debug (RAD)")
  -- debugging in nvim is <leader>dc -> "Build & debug" (lua/plugins/dap.lua)
  -- the rest are commands: :BuildArgs :BuildDebugTarget :BuildProgram :BuildInfo :BuildCancel
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("build", { clear = true }),
    pattern = { "c", "cpp", "make", "cmake", "sh" },
    callback = function(ev)
      if ev.match ~= "sh" or vim.fs.basename(ev.file) == "build.sh" then
        M.attach(ev.buf)
      end
    end,
  })

  local function complete(lead)
    local p = project()
    if not p then
      return {}
    end
    local list = vim.list_extend(targets(p), p.state.custom)
    return vim.tbl_filter(function(t)
      return t ~= "" and t:find(lead, 1, true) == 1
    end, list)
  end
  local command = vim.api.nvim_create_user_command
  command("Build", function(o)
    M.build(o.args)
  end, { nargs = "*", complete = complete, desc = "Build (the given target, or the chosen one)" })
  command("BuildRun", M.run, { desc = "Run the program (as built last)" })
  command("BuildDebug", M.debug, { desc = "Build & debug in nvim" })
  command("BuildRad", M.debug_rad, { desc = "Build & debug in the RAD debugger" })
  command("BuildTarget", M.pick_target, { desc = "Choose the build target" })
  command("BuildDebugTarget", M.pick_debug_target, { desc = "Choose the debug target" })
  command("BuildArgs", M.set_args, { desc = "Set the program's arguments" })
  command("BuildProgram", M.set_program, { desc = "Set the program the targets build" })
  command("BuildInfo", M.info, { desc = "Show the project's build settings" })
  command("BuildCancel", M.cancel, { desc = "Cancel the running build" })
  command("BuildForget", M.forget, { desc = "Forget the project's build settings" })
end

return M
