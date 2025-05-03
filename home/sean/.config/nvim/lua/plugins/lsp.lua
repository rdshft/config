return {
    "neovim/nvim-lspconfig",
    dependencies = {
        'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'
    },
    config = function()
        local lsp_zero = require('lsp-zero')
        local lspconfig = require('lspconfig')

        lsp_zero.set_preferences({ suggest_lsp_servers = false })

        lsp_zero.on_attach(
            ---@diagnostic disable-next-line: unused-local
            function(client, bufnr)
                lsp_zero.default_keymaps({ buffer = bufnr })
            end
        )

        lspconfig.lua_ls.setup(
            lsp_zero.nvim_lua_ls()
        )

        lsp_zero.setup_servers({
            'ruff',
            'pylsp',
            'gopls',
        })

        lsp_zero.set_sign_icons({
            error = '',
            warn = '',
            hint = '',
            info = ''
        })

        lsp_zero.setup()

        vim.keymap.set("n", "<F2>", function ()
            local current_clients = #vim.lsp.get_clients({
                bufnr = vim.api.nvim_get_current_buf()
            })

            if current_clients == 0 then
                local current_word = vim.fn.expand("<cword>")
                return ":%s/" .. current_word .. "/" .. current_word .. "/g"
            else
                vim.lsp.buf.rename()
            end
        end, {
            -- need this for the string above to actually be interpreted.
            -- see https://neovim.io/doc/user/lua-guide.html#_creating-mappings
            expr = true
        })
    end
}
