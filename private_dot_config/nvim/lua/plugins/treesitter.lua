return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      textobjects = {
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner", ["]u"] = "@call.outer", ["]m"] = "@function.outer"},
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner", ["]U"] = "@call.outer" , ["]M"] = "@function.outer"},
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner", ["[u"] = "@call.outer", ["[m"] = "@function.outer" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner", ["]U"] = "@call.outer", ["[M"] = "@function.outer" },
        },
      }
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    enabled = false,
  },
}
