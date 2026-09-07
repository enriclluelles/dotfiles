-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_picker = "fzf"
vim.g.autoformat = false

-- Omarchy (Linux) ships lua/config/remote_clipboard.lua and calls this from its
-- own options.lua, which this file replaces. The module is not managed by
-- chezmoi, so guard the call -- it is a silent no-op on machines without it.
pcall(function()
  require("config.remote_clipboard").setup()
end)
