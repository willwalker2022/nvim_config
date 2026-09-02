local enable_lsp = require("config.lsp_servers").enable

local clangd_root_markers = {
  ".clangd",
  ".clang-tidy",
  ".clang-format",
  "compile_commands.json",
  "compile_flags.txt",
  "configure.ac",
}

local clangd_fallback_root_markers = {
  ".git",
}

local function find_root(path, markers)
  local match = vim.fs.find(markers, { path = path, upward = true })[1]
  if match then
    return vim.fs.dirname(match)
  end
end

local function find_clangd_root(path)
  return find_root(path, clangd_root_markers) or find_root(path, clangd_fallback_root_markers) or path
end

local function clangd_root_dir()
  if vim.lsp and vim.lsp.config then
    return function(bufnr, on_dir)
      local path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
      on_dir(find_clangd_root(path))
    end
  end

  return function(fname)
    return find_clangd_root(vim.fs.dirname(fname))
  end
end

enable_lsp("clangd", {
  cmd = {
    "clangd",
    "--log=error",
    "--enable-config",
    "--query-driver=/usr/bin/riscv64-unknown-elf-*,/usr/bin/riscv64-linux-gnu-*,/usr/local/bin/riscv64-unknown-elf-*",
  },
  root_dir = clangd_root_dir(),
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
