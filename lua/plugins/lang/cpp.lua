local lsp_servers = require("config.lsp_servers")
local enable_lsp = lsp_servers.enable

local clangd_root_markers = {
  ".clangd",
  ".clang-tidy",
  ".clang-format",
  "compile_commands.json",
  "compile_flags.txt",
  "configure.ac",
  ".git",
}

enable_lsp("clangd", {
  cmd = {
    "/bin/zsh",
    "-c",
    'ulimit -n 65536; exec "$@"',
    "clangd-wrapper",
    "clangd",
    "--log=error",
    "--enable-config",
    "--query-driver=/opt/homebrew/bin/riscv64-unknown-elf-*",
  },
  root_dir = lsp_servers.root_dir(clangd_root_markers),
})

return {
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "clangd",
        "codelldb",
      },
    },
    opts_extend = { "ensure_installed" },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
    },
  },
}
