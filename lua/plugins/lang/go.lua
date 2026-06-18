local enable_lsp = require("config.lsp_servers").enable

enable_lsp("gopls")

return {
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "gopls",
      },
    },
    opts_extend = { "ensure_installed" },
  },
}
