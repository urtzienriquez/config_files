options(
  languageserver.server_capabilities = list(
    hoverProvider = FALSE,
    signatureHelpProvider = FALSE,
    completionProvider = FALSE,
    completionItemResolve = FALSE,
    definitionProvider = FALSE,
    referencesProvider = FALSE,
    implementationProvider = FALSE,
    documentHighlightProvider = FALSE,
    documentSymbolProvider = FALSE
  )
)

options(lintr.linter_file = "~/.lintr")

if (interactive() || isatty(stdout())) {
  options(
    colorout.verbose = 0
  )
  if (require("colorout", quietly = TRUE)) {
    colorout::setOutputColors(
      index = 8, # gray
      normal = 7, # text
      number = 4, # blue
      negnum = 1, # red
      zero = 6,
      zero.limit = 1, # light blue
      infinite = 5, # pink
      string = 2, # green
      date = 7, # text
      const = 3, # yellow,
      true = 2, # green
      false = 1, # red
      warn = 3, # yellow
      stderror = 1, # red
      error = 1, # red
      verbose = FALSE
    )
  }
}
