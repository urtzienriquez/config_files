vim.pack.add({ "https://github.com/R-nvim/R.nvim" })

local function set_rnvim_keymaps()
  local o = { noremap = true, silent = true, buffer = true }
  local function opts(desc)
    return vim.tbl_extend("force", o, { desc = desc })
  end
  vim.keymap.set("n", "<leader>or", "<Plug>RStart", opts("Start R"))
  vim.keymap.set("n", "<leader>qr", "<Plug>RClose", opts("Close R"))
  vim.keymap.set("n", "<leader>cd", "<Plug>RSetwd", opts("Set working directory"))
  vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine", opts("Send line to R"))
  vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection", opts("Send selection to R"))
  vim.keymap.set("n", "<leader>sb", "<Plug>RSendFile", opts("Send buffer to R"))
  vim.keymap.set("n", "<leader>rh", "<Plug>RHelp", opts("R help"))
  vim.keymap.set("n", "<leader>ro", "<Plug>ROBToggle", opts("Toggle object browser"))
  vim.keymap.set("n", "]]", "<Plug>RNextRChunk", opts("Next R chunk"))
  vim.keymap.set("n", "[[", "<Plug>RPreviousRChunk", opts("Previous R chunk"))
  if vim.bo.filetype == "rnoweb" then -- (inline code in the file's syntax)
    vim.keymap.set("i", "<C-a>c", "\\Sexpr{}<Left>", opts("Add inline R code"))
    vim.keymap.set("n", "<leader>cc", "i\\Sexpr{}<Left>", opts("Add inline R code"))
  else
    vim.keymap.set("i", "<C-a>c", "`r<Space>`<Esc>i", opts("Add inline R code"))
    vim.keymap.set("n", "<leader>cc", "i`r<Space>`<Esc>i", opts("Add inline R code"))
  end

  -- (rendering R Markdown and Rnoweb: manuscript.nvim, see plugins/manuscript.lua)
end

local r_opts = {
  R_app = "R",
  bracketed_paste = false,
  R_args = { "--no-save --silent" },
  buffer_opts = "winfixwidth winfixheight",
  user_maps_only = true,
  -- (language servers: R.nvim's own for completion, hover, definition...; languageserver only for
  -- document symbols and lintr's diagnostics, see languageserver.server_capabilities in ~/.Rprofile)
  chunk_hl = { highlight = false }, -- (chunks are painted by nightfox, in every Noweb/Markdown file)
  objbr_mappings = {
    c = "class",
    ["<leader>gp"] = "head({object}, n = 15)",
    v = function()
      require("r.browser").toggle_view()
    end,
  },
  hook = {
    after_R_start = function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" and buf ~= vim.api.nvim_get_current_buf() then
          pcall(vim.api.nvim_buf_set_name, buf, "R-console")
          break
        end
      end
    end,
    on_filetype = function()
      if vim.bo.filetype ~= "quarto" then
        set_rnvim_keymaps()
        return
      end
      for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, 100, false)) do
        local lang = line:match("^```{(%w+)")
        if lang and lang:lower() == "r" then
          set_rnvim_keymaps()
          return
        end
      end
    end,
  },
}
if vim.env.R_AUTO_START == "true" then
  r_opts.auto_start = "on startup"
  r_opts.objbr_auto_start = true
end

require("r").setup(r_opts)
