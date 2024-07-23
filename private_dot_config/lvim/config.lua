--[[
 THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
 `lvim` is the global options object
]]

-- vim options
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"

-- general
lvim.log.level = "info"
lvim.format_on_save = {
  enabled = true,
  pattern = "*.lua",
  timeout = 1000,
}
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

lvim.keys.normal_mode["<C-l>"] = ":BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<C-h>"] = ":BufferLineCyclePrev<CR>"

lvim.lsp.buffer_mappings.normal_mode["gd"] = {
  function()
    require("telescope.builtin").lsp_definitions()
  end,
  "Goto definition"
}

lvim.lsp.buffer_mappings.normal_mode["gD"] = {
  function()
    vim.lsp.buf.definition()
  end,
  "Goto definition"
}

lvim.lsp.buffer_mappings.normal_mode["gr"] = {
  function()
    require("telescope.builtin").lsp_references()
  end,
  "Goto definition"
}

lvim.builtin.which_key.mappings["f"] = {
  function()
    require("telescope.builtin").find_files()
  end,
  "Find File",
}
lvim.builtin.which_key.mappings["g"]["f"] = {
  function()
    require("lvim.core.telescope.custom-finders").find_project_files({ previewer = true })
  end,
  "Find git files",
}

lvim.builtin.telescope.defaults.file_ignore_patterns = {
  "vendor/cache",
  "tmp"
}

lvim.builtin.telescope.pickers.find_files.find_command = { "rg", "--files", "--color", "never", "--type", "all" }

-- -- Change theme settings
-- lvim.colorscheme = "lunar"

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.terminal.shell = "fish"
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.update_cwd = false
lvim.builtin.project.active = false
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- Automatically install missing parsers when entering buffer
lvim.builtin.treesitter.auto_install = true


-- lvim.builtin.treesitter.ignore_install = { "haskell" }

-- -- generic LSP settings <https://www.lunarvim.org/docs/languages#lsp-support>

-- --- disable automatic installation of servers
lvim.lsp.installer.setup.automatic_installation = false

-- ---configure a server manually. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---see the full default list `:lua =lvim.lsp.automatic_configuration.skipped_servers`
lvim.lsp.automatic_configuration.skipped_servers = { "solargraph", "rubocop", "standardrb", "harper_ls" }
-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- local allowed_lsps = { ruby_lsp = true, sorbet = true }
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return allowed_lsps(server)
--   return server ~= "sorbet"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- linters and formatters <https://www.lunarvim.org/docs/languages#lintingformatting>
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--   { command = "stylua" },
--   {
--     command = "prettier",
--     extra_args = { "--print-width", "100" },
--     filetypes = { "typescript", "typescriptreact" },
--   },
-- }
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
--   {
--     command = "shellcheck",
--     args = { "--severity", "warning" },
--   },
-- }

-- -- Additional Plugins <https://www.lunarvim.org/docs/plugins#user-plugins>
lvim.plugins = {
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit"
    },
    ft = { "fugitive" }
  },
  {
    "ray-x/go.nvim",
    ft = "go",
    config = true
  },
  {
    "enriclluelles/telescope.nvim",
    branch = "lsp_multi_client",
  },
  { "nushell/tree-sitter-nu" },
}

-- -- Autocommands (`:help autocmd`) <https://neovim.io/doc/user/autocmd.html>
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })
