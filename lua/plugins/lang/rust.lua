local enable_lsp = require("config.lsp_servers").enable

enable_lsp("rust_analyzer")

return {
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "rust-analyzer",
      },
    },
    opts_extend = { "ensure_installed" },
  },
}
