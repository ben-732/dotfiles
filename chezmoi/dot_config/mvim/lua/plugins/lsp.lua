return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "saghen/blink.cmp",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "pyright", "terraformls" },
      })

      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      end

      local capabilities = require("blink.cmp").get_lsp_capabilities() -- :contentReference[oaicite:1]{index=1}

      -- Neovim 0.11+ API
      vim.lsp.config("lua_ls", {
        on_attach = on_attach,
        capabilities = capabilities,
      })

      vim.lsp.config("ts_ls", {
        on_attach = on_attach,
        capabilities = capabilities,
      })

      vim.lsp.config("pyright", {
        on_attach = on_attach,
        capabilities = capabilities,
      })

      vim.lsp.config("terraformls", {
        on_attach = on_attach,
        capabilities = capabilities,
        -- optional: constrain/expand filetypes if you want
        filetypes = { "terraform", "terraform-vars", "hcl" },
      })
   end,
  },
}
