return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/texlab" },
  filetypes = { "tex", "plaintex", "bib" },
  root_markers = {
    ".latexmkrc",
    ".texlabroot",
    ".git",
  },
  settings = {
    texlab = {
      build = {
        executable = "sh",
        args = {
          "-c",
          [[
      latexmk -pdf -interaction=nonstopmode -synctex=1 "$1" &&
      latexmk -c "$1" &&
      find . -maxdepth 1 -name "*.synctex.gz" -delete
    ]],
          "sh",
          "%f",
        },
        onSave = true,
      },
      forwardSearch = {
        executable = "zathura",
        args = { "--synctex-forward", "%l:1:%f", "%p" },
      },
      chktex = {
        onOpenAndSave = true,
        onEdit = false,
      },
    },
  },
}
