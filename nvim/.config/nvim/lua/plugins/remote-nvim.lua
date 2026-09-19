---@type LazySpec
return {
  "amitds1997/remote-nvim.nvim",
  version = "*", -- Pin to GitHub releases
  dependencies = {
    "nvim-lua/plenary.nvim", -- For standard functions
    "MunifTanjim/nui.nvim", -- To build the plugin UI
    "nvim-telescope/telescope.nvim", -- For picking between different remote methods
  },
  opts = {}, -- If plugin uses `setup()` or internal config, replace with actual opts
  config = function(_, opts) require("remote-nvim").setup(opts) end,
}
