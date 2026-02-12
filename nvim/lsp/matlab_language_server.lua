return {
    cmd = {
        vim.fn.stdpath('data') .. '/mason/bin/matlab-language-server',
        '--stdio'
    },
    filetypes = { 'matlab' },
    root_markers = { '.git' },
    settings = {
        MATLAB = {
            indexWorkspace = true,
            matlabConnectionTiming = 'onStart',
            telemetry = false,
        },
    },
}
