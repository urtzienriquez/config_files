vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/neoffice.nvim") --[[@as string]])

require("neoffice").setup({ author = "UEU" })

----------------------------------------
-- keymaps: <leader>w (Word documents), only in .docx/.odt/.doc buffers (the "neoffice" filetype)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "neoffice",
  callback = function(ev)
    local function map(lhs, cmd, desc, mode)
      vim.keymap.set(mode or "n", lhs, cmd, { buffer = ev.buf, desc = desc })
    end
    map("<leader>ww", "<Cmd>Neoffice <CR>", "Pick an action")
    -- comments
    map("<leader>wc", "<Cmd>Neoffice comments <CR>", "Comments panel")
    map("<leader>wa", "<Cmd>Neoffice comment <CR>", "Add comment", { "n", "x" })
    map("<leader>wr", "<Cmd>Neoffice reply <CR>", "Reply to comment")
    map("<leader>wx", "<Cmd>Neoffice resolve <CR>", "Resolve / reopen comment")
    map("<leader>wd", "<Cmd>Neoffice delete <CR>", "Delete comment")
    -- tracked changes
    map("<leader>wt", "<Cmd>Neoffice track <CR>", "Track changes on/off")
    map("<leader>wj", "<Cmd>Neoffice next <CR>", "Next change")
    map("<leader>wk", "<Cmd>Neoffice prev <CR>", "Previous change")
    map("<leader>wy", "<Cmd>Neoffice accept <CR>", "Accept change (or the selected part)", { "n", "x" })
    map("<leader>wn", "<Cmd>Neoffice reject <CR>", "Reject change (or the selected part)", { "n", "x" })
    map("<leader>wY", "<Cmd>Neoffice accept all <CR>", "Accept all changes")
    map("<leader>wN", "<Cmd>Neoffice reject all <CR>", "Reject all changes")
    map("<leader>wl", "<Cmd>Neoffice changes <CR>", "List changes")
    -- structure
    map("<leader>wh", "<Cmd>Neoffice numbers <CR>", "Heading numbers on/off")
    -- back into the LaTeX/Rnoweb sources (manuscript.nvim)
    map("<leader>wm", "<Cmd>Manuscript merge<CR>", "Merge into the sources")
  end,
})
