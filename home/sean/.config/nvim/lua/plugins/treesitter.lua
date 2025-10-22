return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function ()
        local treesitter = require('nvim-treesitter.configs')

        treesitter.setup {
            ignore_install = {}, -- List of parsers to ignore installing
            highlight = {
                enable = true, -- `false` will disable the whole extension
                disable = {}, -- list of language that will be disabled
                additional_vim_regex_highlighting = false,
            },
            indent = {
                enable = true,
            },
            ensure_installed = {
                "lua",
                "vim",
                "vimdoc",
                "python",
                "html",
                "css",
                "bash",
                "markdown",
                "markdown_inline",
                "go",
                "zig",
                "regex"
                -- "javascript"
            },
            sync_install = true,
        }
    end
}
