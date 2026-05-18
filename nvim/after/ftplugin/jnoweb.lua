local ns = vim.api.nvim_create_namespace("jnoweb_chunk")

local function hl_code()
  pcall(vim.api.nvim_buf_clear_namespace, 0, ns, 0, -1)

  local ok, parser = pcall(vim.treesitter.get_parser, 0, "jnoweb")
  if not ok or not parser then return end
  parser:parse(true)
  local tree = parser:parse()[1]
  if not tree then return end
  local root = tree:root()

  local query = vim.treesitter.query.parse("jnoweb", "(jchunk) @chunk")
  if not query then return end

  for _, match, _ in query:iter_matches(root, 0, 0, -1) do
    for _, nodes in pairs(match) do
      for _, node in ipairs(nodes) do
        local sr, _, er, _ = node:range()
        vim.api.nvim_buf_set_extmark(0, ns, sr, 0, {
          end_row = er + 1,
          end_col = 0,
          hl_group = "NightfoxCodeBlock",
          hl_eol = true,
        })
      end
    end
  end
end

local aug = vim.api.nvim_create_augroup("jnoweb_chunk", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = aug,
  buffer = 0,
  callback = hl_code,
})
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
  group = aug,
  buffer = 0,
  callback = hl_code,
})
