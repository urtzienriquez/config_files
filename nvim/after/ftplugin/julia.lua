local symbol_file = vim.fn.stdpath("config") .. "/snippets/julia_latex.tsv"

-- Load symbols once per buffer
local latex_symbols = (function()
  local t = {}
  local f = io.open(symbol_file, "r")
  if not f then
    vim.notify("[julia] symbol file not found: " .. symbol_file, vim.log.levels.WARN)
    return t
  end
  for line in f:lines() do
    local k, v = line:match("^(\\%S+)\t(.+)$")
    if k and v then t[k] = v end
  end
  f:close()
  return t
end)()

local function latex_expand()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line     = vim.api.nvim_get_current_line()
  local before   = line:sub(1, col)         -- text left of cursor
  local seq      = before:match("(\\%S+)$") -- trailing \sequence

  if seq and latex_symbols[seq] then
    local uni       = latex_symbols[seq]
    local start_col = col - #seq
    vim.api.nvim_set_current_line(
      line:sub(1, start_col) .. uni .. line:sub(col + 1)
    )
    vim.api.nvim_win_set_cursor(0, { row, start_col + #uni })
    return true
  end
  return false
end

vim.keymap.set("i", "<Tab>", function()
  if not latex_expand() then
    -- pass through to whatever else Tab does (cmp, snippets, literal tab…)
    local key = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
    vim.api.nvim_feedkeys(key, "n", false)
  end
end, { buffer = true, desc = "LaTeX → Unicode (or Tab)" })
