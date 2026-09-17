vim.pack.add({ "https://github.com/nvim-mini/mini.clue" })

local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    { mode = { "n", "x" }, keys = "<Leader>" },
    { mode = "n", keys = "<LocalLeader>" },
    { mode = { "n", "x" }, keys = "[" },
    { mode = { "n", "x" }, keys = "]" },
    { mode = "n", keys = "c" },
    { mode = "n", keys = "d" },
    { mode = "i", keys = "<C-x>" },
    { mode = { "n", "x" }, keys = "g" },
    { mode = { "n", "x" }, keys = "'" },
    { mode = { "n", "x" }, keys = "`" },
    { mode = { "n", "x" }, keys = '"' },
    { mode = { "i", "c" }, keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
    { mode = { "n", "x" }, keys = "z" },
  },

  window = {
    delay = 500,
    config = { width = 50 },
  },

  clues = {
    miniclue.gen_clues.g(),
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.square_brackets(),
    miniclue.gen_clues.z(),
    { mode = { "n", "x" }, keys = "go", desc = "Add range to opencode" },
    { mode = "n", keys = "<Leader>f", desc = "(Find commands)" },
    { mode = "n", keys = "<Leader>g", desc = "(Git commands)" },
    { mode = "n", keys = "<Leader>i", desc = "(opencode)" },
    { mode = "n", keys = "<Leader>u", desc = "(UI)" },
    { mode = "n", keys = "<Leader>b", desc = "(Buffer format)" },
    { mode = "n", keys = "<Leader>m", desc = "(Session)" },
    { mode = "n", keys = "<Leader>z", desc = "(Zotero)" },
  },
})
