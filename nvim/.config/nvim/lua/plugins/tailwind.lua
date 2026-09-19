return {
  "luckasRanarison/tailwind-tools.nvim",
  event = "VeryLazy",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter" },
    { "nvim-telescope/telescope.nvim", optional = true },
    { "neovim/nvim-lspconfig", optional = true },
  },
  build = ":UpdateRemotePlugins",
  opts = {}, -- Add your configuration here if needed
}
