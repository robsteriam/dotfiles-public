return {
  {
  'neovim/nvim-lspconfig',
  dependencies = {
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },
  config = function()
    local servers = {
      "lua_ls",
      "ts_ls", -- JavaScript & TypeScript
      "gopls", -- Go
      "html", -- HTML
      "cssls", -- CSS
      "rust_analyzer", -- Rust
      "pyright", -- Python
      "intelephense", -- PHP
      "clangd", -- C/C++
    }

    require("mason").setup()

    require("mason-lspconfig").setup({
      ensure_installed = servers,
      handlers = {
        function(server_name)
          vim.lsp.config[server_name].setup({})
        end,
      },
    })
  end,
  }
}
