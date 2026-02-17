return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons", "stevearc/dressing.nvim" },
  config = function()
    require("nvim-tree").setup({
      actions = {
        change_dir = {
          enable = false,
        },
      },
      view = {
        width = 30
      },
   })
    vim.keymap.set("n", "<leader>ee", ":NvimTreeFocus<CR>")
    vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>")
  end,

}


