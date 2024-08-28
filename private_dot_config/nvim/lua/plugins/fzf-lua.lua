local overrides = {
  "borderless",
  files = {
    cwd_prompt = true,
    cmd = [[rg --type all --files --color=never --hidden --glob '!tmp' --glob '!.git' ]]
      .. [[ --glob '!node_modules' --glob '!vendor' ]]
      .. [[--glob '!*.min.*' --glob '!*.map' --glob '!*.log' --glob '!*.cache' --glob ]]
      .. [['!*.tmp' --glob '!*.swp' --glob '!*.png' --glob '!*.jpeg' --glob '!*.jpg' ]]
      .. [[--glob '!*.rbi']],
  },
}

return {
  {
    "ibhagwan/fzf-lua",
    config = function(_, opts)
      local newopts = vim.tbl_deep_extend("force", opts, overrides)
      require("fzf-lua").setup(newopts)
    end,
  },
}
