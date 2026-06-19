local symbol_file = vim.fn.stdpath("config") .. "/snippets/julia_latex.tsv"

local function load_symbols()
  local t = {}
  local f = io.open(symbol_file, "r")
  if not f then
    vim.notify("[julia_latex] symbol file not found: " .. symbol_file, vim.log.levels.WARN)
    return t
  end
  for line in f:lines() do
    local k, v = line:match("^(\\%S+)\t(.+)$")
    if k and v then t[k] = v end
  end
  f:close()
  return t
end

local symbols = load_symbols()

local function latex_expand()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local before = line:sub(1, col)
  local seq = before:match("(\\%S+)$")

  if seq and symbols[seq] then
    local uni = symbols[seq]
    local start_col = col - #seq
    vim.api.nvim_set_current_line(
      line:sub(1, start_col) .. uni .. line:sub(col + 1)
    )
    vim.api.nvim_win_set_cursor(0, { row, start_col + #uni })
    return true
  end
  return false
end

local M = {}

function M.setup(bufnr)
  bufnr = bufnr or 0
  vim.keymap.set("i", "<Tab>", function()
    if not latex_expand() then
      local key = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
      vim.api.nvim_feedkeys(key, "n", false)
    end
  end, { buffer = bufnr, desc = "LaTeX → Unicode (or Tab)" })
end

return M
