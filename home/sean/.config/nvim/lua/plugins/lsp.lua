return {
    "neovim/nvim-lspconfig",
    config = function()
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

        vim.diagnostic.config({
            virtual_text = true,
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '',
                    [vim.diagnostic.severity.WARN] = '',
                    [vim.diagnostic.severity.INFO] = '',
                    [vim.diagnostic.severity.HINT] = '',
                },
            },
        })

        -- TODO: fix this, not sure why it doesn't work sometimes
        -- vim.keymap.set("n", "<F2>", function ()
        --     local current_clients = #vim.lsp.get_clients({
        --         bufnr = vim.api.nvim_get_current_buf()
        --     })
        --
        --     if current_clients == 0 then
        --         local current_word = vim.fn.expand("<cword>")
        --         return ":%s/" .. current_word .. "/" .. current_word .. "/g"
        --     else
        --         vim.lsp.buf.rename()
        --     end
        -- end, {
        --     -- need this for the string above to actually be interpreted.
        --     -- see https://neovim.io/doc/user/lua-guide.html#_creating-mappings
        --     expr = true
        -- })
    end
}
