-- A second debug window, under dap-view's panel, showing one view at a time:
--   C call stack (the default)   S scopes   T threads   R REPL   O program I/O
-- Those letters switch it (in the window), q closes it, and <leader>dp opens/closes it. dap-view
-- keeps a single window, so these are nvim-dap's own views; Watches and Breakpoints stay in
-- dap-view's panel. It opens and closes with dap-view.

local M = {}

M.default = "stack" -- the view each debug session starts with

local api = vim.api
local dap = require("dap")
local widgets = require("dap.ui.widgets")

local ORDER = { "stack", "scopes", "threads", "repl", "io" }
local VIEWS = {
  stack = { label = "Call stack", key = "C" },
  scopes = { label = "Scopes", key = "S" },
  threads = { label = "Threads", key = "T" },
  repl = { label = "REPL", key = "R" },
  io = { label = "Program I/O", key = "O" },
}

local win -- the window
local current = M.default
local io_buf -- the terminal of the program being debugged
local io_unseen -- it printed while another view was shown

local function is_open()
  return win ~= nil and api.nvim_win_is_valid(win)
end

function M.dap_view_win()
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

local function winbar()
  local parts = {}
  for _, name in ipairs(ORDER) do
    local view = VIEWS[name]
    local hl = name == current and "NvimDapViewTabSelected" or "NvimDapViewTab"
    local new = (name == "io" and io_unseen) and " •" or ""
    table.insert(parts, ("%%#%s# %s [%s]%s %%*"):format(hl, view.label, view.key, new))
  end
  return table.concat(parts) .. "%#NvimDapViewTabFill#"
end

local function refresh_winbar()
  if is_open() then
    vim.wo[win].winbar = winbar()
  end
end

local function placeholder(text)
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, { text })
  vim.bo[buf].bufhidden = "wipe"
  return buf
end

function M.show(name)
  if not is_open() then
    return M.open(name)
  end
  current = name
  -- the window keeps 'winfixbuf' (as dap-view's do), so nvim-dap never shows the code in it when
  -- the program stops; only here, while switching views, is it lifted
  vim.wo[win].winfixbuf = false
  local ok, err = pcall(function()
    if name == "io" then
      io_unseen = false
      local buf = (io_buf and api.nvim_buf_is_valid(io_buf)) and io_buf
        or placeholder("The program's input and output show here when you debug a C/C++ program.")
      api.nvim_win_set_buf(win, buf)
    elseif name == "repl" then
      local repl_buf
      for _, b in ipairs(api.nvim_list_bufs()) do
        if api.nvim_buf_is_loaded(b) and vim.bo[b].filetype == "dap-repl" then
          repl_buf = b
        end
      end
      if repl_buf then
        api.nvim_win_set_buf(win, repl_buf)
      else -- not made yet: let nvim-dap make it, in this window
        dap.repl.open({}, ("lua vim.api.nvim_set_current_win(%d)"):format(win))
      end
    else
      local view = widget_views[name]
      if view.buf and api.nvim_buf_is_valid(view.buf) then
        -- shown before: draw it again from scratch (open() would add to what is there, and the
        -- call stack would repeat itself)
        api.nvim_win_set_buf(win, view.buf)
        view.refresh()
      else
        view.open()
      end
    end
  end)
  if is_open() then
    vim.wo[win].winfixbuf = true
  end
  if not ok then
    vim.notify("debug window: " .. tostring(err), vim.log.levels.WARN)
    return
  end
  local buf = api.nvim_win_get_buf(win)
  if vim.bo[buf].buftype == "" then
    return -- a file: never give its buffer these keys (C, S, R, O, q are editing commands there)
  end
  for _, other in ipairs(ORDER) do
    vim.keymap.set("n", VIEWS[other].key, function()
      M.show(other)
    end, { buffer = buf, nowait = true, desc = "Debug window: " .. VIEWS[other].label })
  end
  vim.keymap.set("n", "q", M.close, { buffer = buf, nowait = true, desc = "Close the debug window" })
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].spell = false
  refresh_winbar()
end

-- opens it under dap-view's panel (if that is open)
function M.open(name)
  if is_open() then
    return M.show(name or current)
  end
  local anchor = M.dap_view_win()
  if not anchor then
    return
  end
  local prev = api.nvim_get_current_win()
  api.nvim_set_current_win(anchor)
  vim.cmd("belowright split")
  win = api.nvim_get_current_win()
  api.nvim_set_current_win(prev)
  M.show(name or current)
end

function M.close()
  if is_open() then
    api.nvim_win_close(win, true)
  end
  win = nil
end

-- <leader>dv: dap-view's panel and this window together
function M.toggle()
  if M.dap_view_win() then
    M.close()
    require("dap-view").close()
  else
    require("dap-view").open()
    vim.schedule(M.open)
  end
end

-- <leader>dp: this window alone (on the view it showed last), opening dap-view if need be
function M.toggle_lower()
  if is_open() then
    M.close()
  elseif M.dap_view_win() then
    M.open()
  else
    require("dap-view").open()
    vim.schedule(M.open)
  end
end

-- The terminal the program being debugged reads and writes (gdb's DAP gives it none, so
-- scanf() would read nothing): made without a window, shown by the "Program I/O" view, kept
-- after the session (to read its output) and replaced by the next one. Returns its tty.
function M.program_terminal()
  if io_buf and api.nvim_buf_is_valid(io_buf) then
    api.nvim_buf_delete(io_buf, { force = true })
  end
  io_buf = api.nvim_create_buf(false, true)
  local chan
  api.nvim_buf_call(io_buf, function()
    -- a process that keeps the terminal open without reading from it
    chan = vim.fn.jobstart({ "sleep", "infinity" }, { term = true })
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
    current = M.default
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
