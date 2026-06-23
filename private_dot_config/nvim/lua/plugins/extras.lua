return {
  -- Languages
  { import = "lazyvim.plugins.extras.lang.ruby" },
  { import = "lazyvim.plugins.extras.lang.go" },
  { import = "lazyvim.plugins.extras.lang.clangd" },
  { import = "lazyvim.plugins.extras.lang.rust" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.toml" },
  { import = "lazyvim.plugins.extras.lang.yaml" },
  { import = "lazyvim.plugins.extras.lang.markdown" },

  -- Editor
  { import = "lazyvim.plugins.extras.editor.fzf" },
  { import = "lazyvim.plugins.extras.editor.inc-rename" },

  -- Coding
  { import = "lazyvim.plugins.extras.coding.mini-surround" },
  { import = "lazyvim.plugins.extras.coding.yanky" },

  -- Testing & Debugging
  { import = "lazyvim.plugins.extras.test.core" },
  { import = "lazyvim.plugins.extras.dap.core" },

  -- AI
  { import = "lazyvim.plugins.extras.ai.avante" },

  -- Linting
  { import = "lazyvim.plugins.extras.linting.eslint" },

  -- Drive avante with the local Claude Code CLI (ACP provider), using the
  -- Claude Code subscription/auth instead of Copilot or an API key. This must
  -- come after the avante extra import above so it wins the opts merge; the
  -- extra otherwise forces provider = "copilot".
  {
    "yetone/avante.nvim",
    opts = { provider = "claude-code" },
  },
}
