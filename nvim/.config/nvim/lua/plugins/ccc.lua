return {
  "uga-rosa/ccc.nvim",
  event = "BufReadPre", -- lazy load on file open
  opts = {
    highlighter = {
      auto_enable = true, -- automatically highlight colors
      lsp = true, -- works with LSP
    },
    input = {
      hex = true, -- support hex colors (#fff, #ffffff)
      rgb = true, -- support rgb()
      hsl = true, -- support hsl() AND raw HSL numbers
    },
    user_default_options = {
      mode = "background", -- can also use "foreground" or "virtualtext"
    },
  },
}
