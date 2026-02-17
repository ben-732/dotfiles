return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        -- Updated tsserver -> ts_ls
        ensure_installed = { "lua_ls", "ts_ls", "pyright", "terraformls" },
      })

      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      end

      -- New Neovim 0.11+ way to setup servers
      -- Use vim.lsp.config instead of require('lspconfig')
      vim.lsp.config("lua_ls", { on_attach = on_attach })
      vim.lsp.config("ts_ls", { on_attach = on_attach })
      vim.lsp.config("terraformls", { on_attach = on_attach })
    end,
  },
}
