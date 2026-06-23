return {
  -- Treesitter motion keymaps live on nvim-treesitter-textobjects (main branch).
  -- These merge with LazyVim's defaults (]f/]c/]a) rather than replacing them.
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = {
      move = {
        keys = {
          goto_next_start = { ["]u"] = "@call.outer", ["]m"] = "@function.outer" },
          goto_next_end = { ["]U"] = "@call.outer", ["]M"] = "@function.outer" },
          goto_previous_start = { ["[u"] = "@call.outer", ["[m"] = "@function.outer" },
          goto_previous_end = { ["[U"] = "@call.outer", ["[M"] = "@function.outer" },
        },
      },
    },
  },
}
