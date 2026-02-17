return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- The new version doesn't require the .configs.setup call for basic use
      -- We just use the main module's setup
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "javascript",
          "typescript",
          "python",
          "terraform",
          "hcl",
          "vim",
          "vimdoc",
        },
        highlight = {
          enable = true,
          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set to `false` if you want only tree-sitter highlighting.
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },
}
