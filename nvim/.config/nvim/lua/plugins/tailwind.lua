return {
  "luckasRanarison/tailwind-tools.nvim",
  event = "VeryLazy",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter" },
    { "nvim-telescope/telescope.nvim", optional = true },
    { "neovim/nvim-lspconfig", optional = true },
  },
  build = ":UpdateRemotePlugins",
  opts = {
    -- tailwind-tools sets the tailwindcss server up through the old
    -- `require("lspconfig").tailwindcss.setup()` framework (init.lua:81 ->
    -- lsp.lua:147), which nvim-lspconfig deprecates and removes in v3.0.0.
    -- Upstream has no fix (latest commit is from May 2025), so turn its
    -- override off and let AstroLSP enable the server via vim.lsp.enable
    -- instead -- see `servers` in astrolsp.lua. Everything else the plugin
    -- provides (color hints, conceal, class sorting) is unaffected.
    server = { override = false },
  },
}
