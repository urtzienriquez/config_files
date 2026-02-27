-- Auto-resize splits when terminal window changes size
vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("auto-resize", { clear = true }),
  pattern = "*",
  command = "wincmd =",
  desc = "Auto-resize windows on terminal resize",
})

-- Diff mode: center cursor on j/k
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("diff-center", { clear = true }),
  callback = function()
    if vim.wo.diff then
      vim.keymap.set("n", "j", "gjzz", { buffer = true, silent = true })
      vim.keymap.set("n", "k", "gkzz", { buffer = true, silent = true })
    end
  end,
  desc = "Center cursor when navigating in diff mode",
})

-- Better line wrapping for prose file types
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("prose-wrap", { clear = true }),
  pattern = {
    "markdown",
    "text",
    "rmd",
    "jmd",
    "quarto",
    "qmd",
    "org",
    "rst",
    "asciidoc",
    "adoc",
    "tex",
    "latex",
    "wiki",
    "textile",
    "mail",
    "gitcommit",
  },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.showbreak = "↳ "
  end,
  desc = "Better wrapping for prose files",
})

-- Set pandoc syntax for markdown-like files
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("pandoc-syntax", { clear = true }),
  pattern = { "*.Rmd", "*.rmd", "*.qmd", "*.Qmd", "*.jmd", "*.Jmd", "*.md" },
  callback = function()
    vim.schedule(function()
      local ft = vim.bo.filetype
      if ft == "rmd" or ft == "quarto" or ft == "markdown" then
        vim.cmd("setlocal syntax=pandoc")
      end
    end)
  end,
  desc = "Set pandoc syntax for markdown-like files",
})

-- Diagnostics: signs and virtual text
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("diagnostics-config", { clear = true }),
  callback = function()
    vim.diagnostic.config({
      virtual_text = true,
      update_in_insert = false,
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.INFO] = "󰋽",
          [vim.diagnostic.severity.HINT] = "",
        },
      },
    })
  end,
  desc = "Configure diagnostics signs and virtual text",
})

-- Man page: remove 'q' to close binding
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("man-page", { clear = true }),
  pattern = "man",
  callback = function()
    vim.keymap.del("n", "q", { buffer = true })
  end,
  desc = "Remove q-to-close in man pages",
})

-- Shell files: K shows man page or bash help
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("shell-help", { clear = true }),
  pattern = { "sh", "bash", "zsh" },
  callback = function()
    vim.keymap.set("n", "K", function()
      local word = vim.fn.expand("<cword>")
      local ok = pcall(vim.cmd.Man, word)
      if not ok then
        local help_output = vim.fn.system("bash -c 'help " .. word .. "' 2>&1")
        if vim.v.shell_error == 0 then
          vim.cmd("new")
          vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(help_output, "\n"))
          vim.bo.buftype = "nofile"
          vim.bo.bufhidden = "wipe"
          vim.bo.modifiable = false
        else
          vim.notify("No manual entry for '" .. word .. "'", vim.log.levels.WARN)
        end
      end
    end, { buffer = true, desc = "Show man page or bash help" })
  end,
  desc = "K shows man page or bash builtin help in shell files",
})

-- LSP progress in ui2
vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("lsp-progress", { clear = true }),
  callback = function(ev)
    local value = ev.data.params.value or {}
    local msg = value.message or "done"
    vim.api.nvim_echo({ { msg } }, false, {
      id = "lsp",
      kind = "progress",
      title = value.title,
      status = "running",
      percent = value.percentage,
    })
  end,
  desc = "Show LSP progress in ui2",
})

-- Highlight when yanking text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
  desc = "Highlight text on yank",
})

-- Visual line navigation for prose file types
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("prose-nav", { clear = true }),
  pattern = {
    "markdown",
    "text",
    "quarto",
    "rmd",
    "jmd",
    "qmd",
    "org",
    "rst",
    "asciidoc",
    "adoc",
    "tex",
    "latex",
    "wiki",
    "textile",
    "mail",
    "gitcommit",
  },
  callback = function()
    local opts = { buffer = true }
    vim.keymap.set("n", "j", "gj", vim.tbl_extend("force", opts, { desc = "Move down by visual line" }))
    vim.keymap.set("n", "k", "gk", vim.tbl_extend("force", opts, { desc = "Move up by visual line" }))
    vim.keymap.set("v", "j", "gj", vim.tbl_extend("force", opts, { desc = "Move down by visual line" }))
    vim.keymap.set("v", "k", "gk", vim.tbl_extend("force", opts, { desc = "Move up by visual line" }))
    vim.keymap.set("n", "gj", "j", vim.tbl_extend("force", opts, { desc = "Move down by logical line" }))
    vim.keymap.set("n", "gk", "k", vim.tbl_extend("force", opts, { desc = "Move up by logical line" }))
  end,
  desc = "Use visual-line navigation in prose files",
})
