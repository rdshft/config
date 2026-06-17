return {
    "neovim/nvim-lspconfig",
    config = function()
        local sev = vim.diagnostic.severity

        vim.diagnostic.config({
            severity_sort = true,
            virtual_text = true,
            signs = {
                text = {
                    [sev.ERROR] = '❌',
                    [sev.WARN] = '⚠️',
                    [sev.INFO] = 'ℹ️',
                    [sev.HINT] = '🏳️',
                },
            },
        })

        vim.lsp.enable({
            'lua_ls',
            'ruff',
            'pylsp',
            'gopls',
            'clangd'
        })

        vim.lsp.config('lua_ls', {
            on_init = function(client)
                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                    runtime = {
                        version = 'LuaJIT',
                        path = {
                            'lua/?.lua',
                            'lua/?/init.lua',
                        },
                    },
                    -- Make the server aware of Neovim runtime files
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME
                        }
                    }
                })
            end,
            settings = {
                Lua = {}
            }
        })
    end
}
