vim.opt.rtp:prepend(vim.fn.expand("~/Documents/GitHub/build.nvim") --[[@as string]])

vim.g.build = {
  cxx = "clang++",
  run_split = "topleft 15split", -- terminals open above, as everywhere in this config
  external_debugger = { "raddbg" },
}

-- only in the buffers :Build works in (C/C++, Makefiles, CMake, build.sh); debugging in nvim is
-- <leader>dc -> "Build & debug" (lua/plugins/dap.lua)
vim.api.nvim_create_autocmd("User", {
  pattern = "BuildAttach",
  callback = function(ev)
    local function map(lhs, cmd, desc)
      vim.keymap.set("n", lhs, "<Cmd>Build " .. cmd .. "<CR>", { buffer = ev.data.buf, desc = desc })
    end
    map("<leader>cc", "", "Build")
    map("<leader>ct", "target", "Choose build target")
    map("<leader>cr", "run", "Run program")
    map("<leader>cv", "debug-external", "Debug (RAD)")
  end,
})
