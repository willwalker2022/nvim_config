local enable_lsp = require("config.lsp_servers").enable

vim.filetype.add({
  extension = {
    glsl = "glsl",
    frag = "glsl",
    vert = "glsl",
    geom = "glsl",
    comp = "glsl",
    tesc = "glsl",
    tese = "glsl",
    fs = "glsl",
    vs = "glsl",
  },
})

enable_lsp("glsl_analyzer", {
  -- All shader extensions above resolve to the single Neovim filetype `glsl`.
  filetypes = { "glsl" },
})

return {
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "glsl_analyzer",
      },
    },
    opts_extend = { "ensure_installed" },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        glsl = { "clang-format" },
      },
    },
  },
}
