-- Colorscheme tuned for code readability.
--
-- Chosen by measuring WCAG contrast of the treesitter capture groups
-- (@keyword/@function/@string/@variable/@type/@comment/@number/@operator/
-- @constant/@property) against the editor background:
--
--   catppuccin-mocha  avg 10.76  min 6.57  9 distinct hues   <- best balance
--   aurora            avg 10.03  min 5.04  10 hues
--   everforest        avg  8.71  min 5.71  9 hues
--   wallbash          avg 13.51  min 6.90  5 hues  <- high contrast, no distinction
--
-- The wallbash scheme is generated from ~4 wallpaper colors and defines no
-- treesitter groups at all, so code rendered almost monochrome.

---@type LazySpec
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      -- Opaque background: a transparent one puts the wallpaper behind the
      -- code, which destroys effective contrast no matter how good the palette.
      transparent_background = false,
      term_colors = true,
      styles = {
        comments = { "italic" },
        keywords = { "bold" },
        types = {},
        functions = { "bold" },
      },
      integrations = {
        treesitter = true,
        native_lsp = { enabled = true, inlay_hints = { background = true } },
        neotree = true,
        telescope = { enabled = true },
        which_key = true,
        gitsigns = true,
        mason = true,
        snacks = true,
        indent_blankline = { enabled = true },
        semantic_tokens = true, -- let the LSP refine treesitter's colors
      },
    },
  },
}
