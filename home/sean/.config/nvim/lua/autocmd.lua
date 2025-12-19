vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = "%s/\\s\\+$//e",
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = vim.fn.expand("~") .. "/.config/waybar/*",
    -- command = "!killall -SIGUSR2 waybar",
    callback = function()
        vim.system({"killall", "-SIGUSR2", "waybar"})
    end
})

-- It seems that if we have a nix buffer open then jump to another file the tab
-- settings don't default to what is set in set.lua
-- This makes sure that even if it does do this the cases where it doesn't are covered.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt.tabstop = 4
        vim.opt.shiftwidth = 4
        vim.opt.softtabstop = 4
    end
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "nix", "yaml" },
    callback = function()
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.softtabstop = 2
    end
})

-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = "*",
--     command = "set colorcolumn=80"
-- })

vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = '*',
    callback = function()
        vim.hl.on_yank({
            higroup = 'IncSearch',
            timeout = 100,
        })
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)

        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})
