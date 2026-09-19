return {
  "github/copilot.vim",
  options = {
    mappings = {
      i = {
        ["<Tab>"] = { 'copilot#Accept("<Tab>")', expr = true, silent = true, noremap = true },
      },
    },
  },
}
