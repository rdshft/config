return {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        local telescope = require("telescope")
        local builtin = require("telescope.builtin")
        local actions = require("telescope.actions")

        telescope.setup({
            defaults = {
                mappings = {
                    i = {
                        ["<esc>"] = actions.close,
                        -- For some reason I have these memorised now despite them
                        -- being annoying but it also kinda makes sense so whatever.
                        ["<C-j>"] = actions.file_split,
                        ["<C-l>"] = actions.file_vsplit,
                    }
                },
                layout_strategy = "center",
                layout_config = {
                    mirror = true
                },
                borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--hidden"
                }
            }
        })

        vim.keymap.set("n", "<leader>ff",
            function()
                builtin.find_files({
                    find_command = { 'bfs', '-type', 'f' },
                    hidden = true,
                })
            end,
            { desc = "find files" }
        )
        vim.keymap.set("n", "<leader>fg", function() builtin.git_files() end, { desc = "find git files" })
        vim.keymap.set("n", "<leader>fh", function() builtin.help_tags() end, { desc = "find nvim help" })
        vim.keymap.set("n", "<leader>fH", function() builtin.highlights() end, { desc = "find highlight groups" })
        vim.keymap.set("n", "<leader>fc", function() builtin.commands() end, { desc = "find commands" })
        vim.keymap.set("n", "<leader>fb", function() builtin.buffers() end, { desc = "find buffers" })
        vim.keymap.set("n", "<leader>ft", function() builtin.live_grep() end, { desc = "find text in current directory" })
        vim.keymap.set("n", "<leader>/", function() builtin.current_buffer_fuzzy_find() end, { desc = "find text in current buffer" })
    end
}
