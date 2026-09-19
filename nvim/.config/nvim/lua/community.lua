-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.colorscheme.gruvbox-nvim" },
  { import = "astrocommunity.colorscheme.rose-pine" },
  { import = "astrocommunity.colorscheme.onedarkpro-nvim" },
  { import = "astrocommunity.colorscheme.vscode-nvim" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.colorscheme.cyberdream-nvim" },
  { import = "astrocommunity.colorscheme.everforest" },
  { import = "astrocommunity.colorscheme.aurora" },
  { import = "astrocommunity.colorscheme.github-nvim-theme" },
  { import = "astrocommunity.colorscheme.night-owl-nvim" },
  { import = "astrocommunity.colorscheme.hybrid-nvim" },
  -- import/override with your plugins folder
}
