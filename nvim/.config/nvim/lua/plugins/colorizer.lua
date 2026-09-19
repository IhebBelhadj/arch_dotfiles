return {
  "NvChad/nvim-colorizer.lua",
  event = "BufReadPre",
  opts = {
    user_default_options = {
      css = true,
      hsl_fn = true,
      mode = "background", -- or "foreground"
      names = false,
      tailwind = false,
    },
  },
}
