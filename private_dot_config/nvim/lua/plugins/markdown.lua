return {
  -- The LazyVim markdown extra runs markdownlint-cli2 through nvim-lint. Its
  -- style rules (list indent, marker spacing, blank lines around headings)
  -- flag nearly every line of ordinary notes and bury the buffer in virtual
  -- text, so drop the linter for markdown. render-markdown and marksman stay.
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
      },
    },
  },
}
