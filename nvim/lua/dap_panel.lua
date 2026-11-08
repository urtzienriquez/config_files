-- A second debug window, under dap-view's panel, showing one view at a time:
--   C call stack (the default)   S scopes   T threads   R REPL   O program I/O
-- Those letters switch it (in the window), q closes it. It opens and closes with the session.
-- (dap-view keeps a single window, so these are nvim-dap's own views; Watches and Breakpoints
-- stay in dap-view's panel.)

local M = {}

local api = vim.api
local dap = require("dap")
local widgets = require("dap.ui.widgets")

local DEFAULT = "stack" -- the view each session starts with
local ORDER = { "stack", "scopes", "threads", "repl", "io" }
local VIEWS = {
  stack = { label = "Call stack", key = "C" },
  scopes = { label = "Scopes", key = "S" },
  threads = { label = "Threads", key = "T" },
  repl = { label = "REPL", key = "R" },
  io = { label = "Program I/O", key = "O" },
}

local win -- the window
local current = DEFAULT
local io_buf -- the terminal of the program being debugged
local io_unseen -- it printed while another view was shown

local function is_open()
  return win ~= nil and api.nvim_win_is_valid(win)
end

local function dap_view_win()
  for _, w in ipairs(api.nvim_tabpage_list_wins(0)) do
    if vim.bo[api.nvim_win_get_buf(w)].filetype == "dap-view" then
      return w
    end
  end
end

-- nvim-dap's widgets, drawn in this window (each refreshes when the program stops)
local function widget_view(widget)
  return widgets
    .builder(widget)
    .new_win(function()
      return win
    end)
    .new_buf(widgets.with_refresh(widget.new_buf, widget.refresh_listener or "event_stopped"))
    .build()
end
local widget_views = {
  stack = widget_view(widgets.frames),
  scopes = widget_view(widgets.scopes),
  threads = widget_view(widgets.threads),
}

local function refresh_winbar()
  if not is_open() then
    return
  end
  local parts = {}
  for _, name in ipairs(ORDER) do
    local hl = name == current and "NvimDapViewTabSelected" or "NvimDapViewTab"
    local new = (name == "io" and io_unseen) and " •" or ""
    table.insert(parts, ("%%#%s# %s [%s]%s %%*"):format(hl, VIEWS[name].label, VIEWS[name].key, new))
  end
  vim.wo[win].winbar = table.concat(parts) .. "%#NvimDapViewTabFill#"
end

-- puts view `name` in the window
local function set_view(name)
  if name == "io" then
    io_unseen = false
    if not (io_buf and api.nvim_buf_is_valid(io_buf)) then
      io_buf = api.nvim_create_buf(false, true)
      api.nvim_buf_set_lines(io_buf, 0, -1, false, { "The program's input and output show here when you debug." })
    end
    api.nvim_win_set_buf(win, io_buf)
  elseif name == "repl" then
    local repl = vim.tbl_filter(function(b)
      return api.nvim_buf_is_loaded(b) and vim.bo[b].filetype == "dap-repl"
    end, api.nvim_list_bufs())[1]
    if repl then
      api.nvim_win_set_buf(win, repl)
    else -- not made yet: let nvim-dap make it, in this window
      dap.repl.open({}, ("lua vim.api.nvim_set_current_win(%d)"):format(win))
    end
  else
    local view = widget_views[name]
    if view.buf and api.nvim_buf_is_valid(view.buf) then
      api.nvim_win_set_buf(win, view.buf)
      view.refresh() -- from scratch: open() adds to what is there (the stack would repeat)
    else
      view.open()
    end
  end
end

function M.show(name)
  if not is_open() then
    return M.open(name)
  end
  current = name
  -- the window keeps 'winfixbuf' (as dap-view's do), so that nvim-dap never shows the code in it
  -- when the program stops; it is lifted only here, to switch views
  vim.wo[win].winfixbuf = false
  local ok, err = pcall(set_view, name)
  vim.wo[win].winfixbuf = true
  if not ok then
    vim.notify("debug window: " .. tostring(err), vim.log.levels.WARN)
    return
  end
  local buf = api.nvim_win_get_buf(win)
  if vim.bo[buf].buftype == "" then
    return -- a file: never give it these keys (C, S, R, O and q edit text there)
  end
  for _, other in ipairs(ORDER) do
    vim.keymap.set("n", VIEWS[other].key, function()
      M.show(other)
    end, { buffer = buf, nowait = true, desc = "Debug window: " .. VIEWS[other].label })
  end
  vim.keymap.set("n", "q", M.close, { buffer = buf, nowait = true, desc = "Close the debug window" })
  refresh_winbar()
end

-- under dap-view's panel (opened too, if it is not)
function M.open(name)
  if is_open() then
    return M.show(name or current)
  end
  local anchor = dap_view_win()
  if not anchor then
    require("dap-view").open()
    return vim.schedule(function()
      if dap_view_win() then
        M.open(name)
      end
    end)
  end
  local prev = api.nvim_get_current_win()
  api.nvim_set_current_win(anchor)
  vim.cmd("belowright split")
  win = api.nvim_get_current_win()
  for option, value in pairs({ number = false, relativenumber = false, signcolumn = "no", spell = false }) do
    vim.wo[win][option] = value
  end
  api.nvim_set_current_win(prev)
  M.show(name or current)
end

function M.close()
  if is_open() then
    api.nvim_win_close(win, true)
  end
  win = nil
end

-- <leader>dv: both debug windows
function M.toggle()
  if dap_view_win() then
    M.close()
    require("dap-view").close()
  else
    M.open()
  end
end

-- <leader>dp: this window (on the view it showed last)
function M.toggle_lower()
  if is_open() then
    M.close()
  else
    M.open()
  end
end

-- The terminal the program being debugged reads and writes (gdb's DAP gives it none, so
-- scanf() would read nothing): made without a window, shown by "Program I/O", kept after the
-- session (to read its output) and replaced by the next one. Returns its tty, for gdb.
function M.program_terminal()
  if io_buf and api.nvim_buf_is_valid(io_buf) then
    api.nvim_buf_delete(io_buf, { force = true })
  end
  io_buf = api.nvim_create_buf(false, true)
  local chan
  api.nvim_buf_call(io_buf, function()
    chan = vim.fn.jobstart({ "sleep", "infinity" }, { term = true }) -- keeps it open, reads nothing
  end)
  pcall(api.nvim_buf_set_name, io_buf, "program I/O")
  io_unseen = false
  api.nvim_buf_attach(io_buf, false, {
    on_lines = function()
      if not io_unseen and not (is_open() and current == "io") then
        io_unseen = true
        vim.schedule(refresh_winbar)
      end
    end,
  })
  if is_open() and current == "io" then
    vim.schedule(function()
      M.show("io")
    end)
  end
  return api.nvim_get_chan_info(chan).pty
end

-- with the session: open (on the default view) when it starts, close when it ends
for _, event in ipairs({ "launch", "attach" }) do
  dap.listeners.after[event]["dap-panel"] = function()
    current = DEFAULT
    vim.schedule(M.open) -- after dap-view has opened its panel
  end
end
for _, event in ipairs({ "event_terminated", "disconnect" }) do
  dap.listeners.before[event]["dap-panel"] = function()
    if vim.tbl_count(dap.sessions()) <= 1 then
      M.close()
    end
  end
end

return M
