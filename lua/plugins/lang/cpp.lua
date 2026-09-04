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
    "clangd",
    "--log=error",
    "--enable-config",
    "--query-driver=/usr/bin/g++,/usr/bin/gcc,/usr/bin/riscv64-unknown-elf-*,/usr/bin/riscv64-linux-gnu-*,/usr/local/bin/riscv64-unknown-elf-*",
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
