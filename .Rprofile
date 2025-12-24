options(lintr.linter_file = "~/.lintr")

# options(
#     languageserver.server_capabilities = list(
#         hoverProvider = FALSE,
#         signatureHelpProvider = FALSE,
#         completionProvider = FALSE,
#         completionItemResolve = FALSE
#     )
# )

if (interactive() || isatty(stdout())) {
    options(
        colorout.verbose = 0
    )
    if (require("colorout", quietly = TRUE)) {
        # Tokyonight moon
        colorout::setOutputColors(
            index    = "\x1b[38;2;115;122;162m",
            normal   = "\x1b[38;2;79;214;190m",
            number   = "\x1b[38;2;130;170;255m",
            negnum   = "\x1b[38;2;255;150;108m",
            zero     = "\x1b[38;2;69;133;136m",
            infinite = "\x1b[38;2;250;189;47m",
            string   = "\x1b[38;2;195;232;141m",
            date     = "\x1b[38;2;255;150;108m",
            const    = "\x1b[38;2;250;189;47m",
            true     = "\x1b[38;2;79;214;190m",
            false    = "\x1b[38;2;219;75;75m",
            warn     = "\x1b[38;2;255;150;108m",
            stderror = "\x1b[38;2;192;153;255m",
            error    = "\x1b[38;2;219;75;75m",
            verbose  = FALSE
        )
    }
}
