vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/manuscript.nvim") --[[@as string]])

----------------------------------------
-- keymaps: <leader>r, in Rnoweb, jnoweb, LaTeX and R Markdown buffers (the merge, <leader>wm, is in
-- neoffice.lua: it runs in Word documents)

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("manuscript-keymaps", { clear = true }),
  pattern = { "rnoweb", "jnoweb", "tex", "plaintex", "rmd" },
  callback = function(ev)
    local function map(lhs, cmd, desc)
      vim.keymap.set("n", lhs, cmd, { buffer = ev.buf, desc = desc })
    end
    -- (as vim-fugitive's: the command on the command line, to run with <CR> or complete first)
    local function prompt(lhs, cmd, desc)
      map(lhs, ":" .. cmd .. " ", desc)
    end
    -- the PDF
    map("<leader>rr", "<Cmd>Manuscript build<CR>", "Build this part")
    map("<leader>rR", "<Cmd>Manuscript build all<CR>", "Build the whole manuscript")
    prompt("<leader>rb", "Manuscript build", "Build... (a part, all, watch; a variant: anon, review...; name.pdf)")
    map("<leader>rw", "<Cmd>Manuscript build watch<CR>", "Build on save on/off")
    map("<leader>rc", "<Cmd>Manuscript clean<CR>", "Clean the build")
    -- the round trip with Word
    map("<leader>re", "<Cmd>Manuscript export<CR>", "Export to Word")
    prompt("<leader>rd", "Manuscript diff", "Changes as a PDF... (<CR>: since the last export or submission)")
    map("<leader>rv", "<Cmd>Manuscript versions<CR>", "Exports and submissions")
    -- the journal
    prompt("<leader>rs", "Manuscript submit", "Submit... (a variant: anon, a journal's; anonymous, named)")
    map("<leader>rp", "<Cmd>Manuscript respond<CR>", "Response to the reviewers")
    map("<leader>ra", "<Cmd>Manuscript archive<CR>", "Archive the code and data")
  end,
})

-- a new manuscript, from anywhere (a template, then a folder)
vim.keymap.set("n", "<leader>rn", ":Manuscript new ", { desc = "New manuscript... (template, folder)" })

-- pdfLaTeX: ~20% faster than LuaLaTeX; the templates' preambles load fontenc T1 for it. (A paper
-- that needs LuaLaTeX, with fontspec: `return { latex = "lualatex" }` in its .manuscript.lua.)
require("manuscript").setup({ templates = "~/Templates", latex = "pdflatex" })
