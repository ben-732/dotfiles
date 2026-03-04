return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons", "stevearc/dressing.nvim" },
  config = function()
    require("nvim-tree").setup({
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true
      },
      view = {
        width = 30
      },
      actions = {
        change_dir = {
          enable = false,
        },
        open_file = {
          quit_on_open = false
        }
      },
   })
    vim.keymap.set("n", "<leader>ee", ":NvimTreeFocus<CR>")
    vim.keymap.set("n", "<leader>ef", ":NvimTreeFindFile<CR>")
  end,

}


