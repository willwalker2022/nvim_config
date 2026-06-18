local enable_lsp = require("config.lsp_servers").enable

enable_lsp("html")
enable_lsp("jsonls")
enable_lsp("yamlls")
enable_lsp("taplo")
enable_lsp("marksman")

enable_lsp("vtsls")

return {
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "html-lsp",
        "json-lsp",
        "yaml-language-server",
        "taplo",
        "marksman",
        "vtsls",
      },
    },
    opts_extend = { "ensure_installed" },
  },
}
