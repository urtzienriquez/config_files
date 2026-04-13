local set = vim.api.nvim_set_hl

set(0, "@markup.heading.1.markdown", { link = "WarningMsg", bold = true })
set(0, "@markup.heading.2.markdown", { link = "WarningMsg", bold = true })
set(0, "@markup.heading.3.markdown", { link = "WarningMsg", bold = true })
set(0, "@markup.heading.4.markdown", { link = "WarningMsg" })
set(0, "@markup.heading.5.markdown", { link = "WarningMsg" })
set(0, "@markup.heading.6.markdown", { link = "WarningMsg" })
set(0, "@markup.math.latex", { link = "Function" })
set(0, "@operator.latex", { link = "Function" })
set(0, "texOnlyMath", { link = "Function" })


set(0, "NormalFloat", { link = "Normal" })
set(0, "BlinkCmpMenu", { link = "Normal" })
set(0, "BlinkCmpMenuBorder", { link = "Normal" })


set(0, "@variable.parameter", { link = "Identifier" })


set(0, "pandocCiteKey", { link = "Special", underline = false})
set(0, "pandocCiteAnchor", { link = "Special" })
set(0, "pandocCiteLocator", { link = "Special" })
set(0, "pandocPCite", { link = "Special" })
set(0, "texRefZone", { link = "Special" })
set(0, "texStatement", { link = "Special" })
set(0, "texDelimiter", { link = "Special" })
set(0, "markdownCode", { link = "Special" })
set(0, "@markup.link.label.markdown_inline", { underline = false})
set(0, "@markup.link.markdown_inline", { underline = false})
