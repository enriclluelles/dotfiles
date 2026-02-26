return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          mason = false,
          root_dir = function(bufnr, on_dir)
            -- Walk up to find the top-level Gemfile, not a nested component one
            local fname = vim.api.nvim_buf_get_name(bufnr)
            local dir = vim.fn.fnamemodify(fname, ":p:h")
            local root = nil
            while dir ~= "/" do
              if vim.uv.fs_stat(dir .. "/Gemfile") then
                root = dir
              end
              dir = vim.fn.fnamemodify(dir, ":h")
            end
            if root then
              on_dir(root)
            end
          end,
        },
        sorbet = {
          enabled = true,
        },
        clangd = { mason = false },
        rubocop = { enabled = false },
        standardrb = { enabled = false },
      },
    },
  },
}
