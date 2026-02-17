local keymap = vim.keymap.set


keymap("n", "<Esc>", ":nohlsearch<CR>")

keymap("n", "<C-h>", "<C-w>h")
keymap("n", "<C-j>", "<C-w>j")
keymap("n", "<C-k>", "<C-w>k")
keymap("n", "<C-l>", "<C-w>l")

keymap("v", "<", "<gv")
keymap("v", ">", ">gv")
