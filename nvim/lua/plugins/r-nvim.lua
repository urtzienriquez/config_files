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
  vim.keymap.set("i", "<C-a>c", "`r<Space>`<Esc>i", opts("Add inline R code"))
  vim.keymap.set("n", "<leader>cc", "i`r<Space>`<Esc>i", opts("Add inline R code"))

  if vim.bo.filetype == "rmd" then
    vim.keymap.set("n", "<leader>rr", function()
      local filename = vim.fn.input({ prompt = "Output filename (without extension): ", cancelreturn = "__CANCEL__" })
      vim.api.nvim_echo({ { "" } }, false, {})
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
    end, opts("Render R Markdown"))
  elseif vim.bo.filetype == "rnoweb" then
    -- Ask for an output name; nil if cancelled, "" for the default
    local function ask_filename()
      local filename = vim.fn.input({ prompt = "Output filename (without extension): ", cancelreturn = "__CANCEL__" })
      vim.api.nvim_echo({ { "" } }, false, {})
      if filename == "__CANCEL__" then
        return nil
      end
      return filename
    end
    -- The current file, or the root given by a "% !TeX root = ..." line
    local function root_file()
      local file = vim.fn.expand("%")
      ---@cast file string
      local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
      for _, line in ipairs(lines) do
        local root = line:match("^%% *!%a+ *root *= *(%S+)")
        if root then
          return root
        end
      end
      return file
    end
    vim.keymap.set("n", "<leader>rr", function()
      local filename = ask_filename()
      if not filename then
        return
      end
      local file = root_file()
      local tex_file, r_cmd
      if filename ~= "" then
        tex_file = filename .. ".tex"
        r_cmd = string.format('knitrmini::knit("%s", output = "%s", engine = "lualatex")', file, tex_file, tex_file)
      else
        tex_file = file:gsub(".Rnw$", ".tex")
        r_cmd = string.format('knitrmini::knit("%s", engine = "lualatex")', file, tex_file)
      end
      vim.cmd("RSend " .. r_cmd)
      vim.api.nvim_echo({ { "Compiling with latexmk using root: " .. file, "Normal" } }, false, {})
    end, opts("Render Rnoweb with latexmk"))
    vim.keymap.set("n", "<leader>rc", function()
      local filename = ask_filename()
      if not filename then
        return
      end
      local base
      if filename ~= "" then
        base = filename
      else
        base = (root_file():gsub("%.Rnw$", ""))
      end
      -- clean_aux() only removes what latexmk recorded as generated for <base>
      local r_cmd = string.format(
        'knitrmini::clean_aux("%s.tex"); invisible(file.remove(Filter(file.exists, "%s-tikzDictionary")))',
        base,
        base
      )
      vim.cmd("RSend " .. r_cmd)
      vim.api.nvim_echo({ { "Cleaning auxiliary files of: " .. base, "Normal" } }, false, {})
    end, opts("Clean LaTeX/Rnoweb auxiliary files"))
  end
end

local r_opts = {
  R_app = "R",
  bracketed_paste = false,
  R_args = { "--no-save --silent" },
  buffer_opts = "winfixwidth winfixheight",
  user_maps_only = true,
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
      if vim.bo.filetype ~= "quarto" and vim.bo.filetype ~= "jnoweb" then
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
