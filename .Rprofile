options(
    languageserver.server_capabilities = list(
        completionProvider = FALSE,
        completionItemResolve = FALSE,
        hoverProvider = FALSE,
        signatureHelpProvider = FALSE,
        implementationProvider = TRUE,
        definitionProvider = TRUE,
        referencesProvider = TRUE
    )
)

options(lintr.linter_file = "~/.lintr")

if (interactive() || isatty(stdout())) {
    options(
        colorout.verbose = 0
    )
    if (require("colorout", quietly = TRUE)) {
        # Nightfox
        colorout::setOutputColors(
            index    = "\x1b[38;2;113;131;155m",
            normal   = "\x1b[38;2;79;214;190m",
            number   = "\x1b[38;2;113;156;214m",
            negnum   = "\x1b[38;2;201;79;109m",
            zero     = "\x1b[38;2;99;205;207m",
            infinite = "\x1b[38;2;244;162;97m",
            string   = "\x1b[38;2;129;178;154m",
            date     = "\x1b[38;2;219;192;116m",
            const    = "\x1b[38;2;244;162;97m",
            true     = "\x1b[38;2;129;178;154m",
            false    = "\x1b[38;2;201;79;109m",
            warn     = "\x1b[38;2;219;192;116m",
            stderror = "\x1b[38;2;157;121;214m",
            error    = "\x1b[38;2;201;79;109m",
            verbose  = FALSE
        )
    }
}
