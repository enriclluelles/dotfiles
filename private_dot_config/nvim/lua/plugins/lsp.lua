return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      autoformat = false,
      servers = {
        ruby_lsp = { enabled = true },
        sorbet = { enabled = true },
        rubocop = { enabled = false },
        standardrb = { enabled = false },
        clangd = { mason = false },
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    enabled = false,
  },
}
