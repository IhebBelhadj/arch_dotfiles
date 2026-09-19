-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- NOTE: "lua", "vim", "c", "markdown", "query" and "vimdoc" are intentionally
    -- omitted. Neovim 0.12 ships those parsers itself, matched to its own
    -- runtime queries. Installing them here shadows the bundled pair and breaks
    -- highlighting with: Query error ... Invalid field name "operator".
    ensure_installed = {
      "astro",
      "bash",
      "css",
      "regex",
      "sql",
      "toml",
      "yaml",
      "dockerfile",
      "json",
      "jsdoc",
      "java",
      "javascript",
      "python",
      "tsx",
      "typescript",
      "latex",
      "html",
      -- add more arguments for adding more treesitter parsers
    },
  },
}
