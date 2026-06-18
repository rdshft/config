-- General Keybinds

-- Splits
vim.keymap.set("n", "<C-J>", "<C-W><C-J>")
vim.keymap.set("n", "<C-K>", "<C-W><C-K>")
vim.keymap.set("n", "<C-L>", "<C-W><C-L>")
vim.keymap.set("n", "<C-H>", "<C-W><C-H>")

-- Arrow keys
vim.keymap.set({"n", "i", "v"}, "<Up>", "<Nop>")
vim.keymap.set({"n", "i", "v"}, "<Down>", "<Nop>")
vim.keymap.set({"n", "i", "v"}, "<Left>", "<Nop>")
vim.keymap.set({"n", "i", "v"}, "<Right>", "<Nop>")

vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "git status" })

vim.keymap.set("n", "<esc>", "<cmd>nohl<cr>")

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "yank selection to clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "yank line to clipboard" })
