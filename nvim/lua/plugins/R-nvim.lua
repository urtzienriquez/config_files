vim.pack.add({ "https://github.com/R-nvim/R.nvim" })

local function set_rnvim_keymaps()
  local o = { noremap = true, silent = true, buffer = true }
  vim.keymap.set("n", "<leader>or", "<Plug>RStart", o)
  vim.keymap.set("n", "<leader>qr", "<Plug>RClose", o)
  vim.keymap.set("n", "<leader>cd", "<Plug>RSetwd", o)
  vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine", o)
  vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection", o)
  vim.keymap.set("n", "<leader>sb", "<Plug>RSendFile", o)
  vim.keymap.set("n", "<leader>rh", "<Plug>RHelp", o)
  vim.keymap.set("n", "<leader>ro", "<Plug>ROBToggle", o)
  vim.keymap.set("n", "<leader>cn", "<Plug>RNextRChunk", o)
  vim.keymap.set("n", "<leader>cN", "<Plug>RPreviousRChunk", o)
  vim.keymap.set("i", "<C-a>c", "`r<Space>`<Esc>i", o)
  vim.keymap.set("n", "<leader>ac", "i`r<Space>`<Esc>i", vim.tbl_extend("force", o, { desc = "Add inline code" }))
  if vim.bo.filetype == "rmd" then
    vim.keymap.set("n", "<leader>rr", function()
      local filename = vim.fn.input({ prompt = "Output filename (without extension): ", cancelreturn = "__CANCEL__" })
      vim.api.nvim_echo({}, false, {})
      if filename == "__CANCEL__" then
        return
      end
      vim.cmd('RSend if(exists("params")) rm(params)')
      local file = vim.fn.expand("%")
      if filename ~= "" then
        vim.cmd('RSend rmarkdown::render("' .. file .. '", output_file = "' .. filename .. '")')
      else
        vim.cmd('RSend rmarkdown::render("' .. file .. '")')
      end
    end, { desc = "Render R Markdown" })
  end
end

local r_opts = {
  R_app = "R",
  external_term = "tmux split-window -d -h",
  bracketed_paste = false,
  R_args = { "--no-save --silent" },
  user_maps_only = true,
  r_ls = {
    completion = true,
    hover = true,
    signature = true,
    implementation = false,
    definition = false,
    references = false,
  },
  objbr_mappings = {
    c = "class",
    ["<leader>gp"] = "head({object}, n = 15)",
    v = function()
      require("r.browser").toggle_view()
    end,
  },
  hook = {
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
