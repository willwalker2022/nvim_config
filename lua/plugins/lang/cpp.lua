local enable_lsp = require("config.lsp_servers").enable

local clangd_filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" }
local clangd_root_markers = {
  ".clangd",
  ".clang-tidy",
  ".clang-format",
  "compile_commands.json",
  "compile_flags.txt",
  "CMakeLists.txt",
  "Makefile",
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

local function find_compile_commands_dir(root)
  if type(root) ~= "string" or root == "" then
    return nil
  end

  local candidates = {
    root,
    root .. "/build",
    root .. "/cmake-build-debug",
    root .. "/cmake-build-release",
    root .. "/out/build",
  }

  for _, dir in ipairs(candidates) do
    if vim.fn.filereadable(dir .. "/compile_commands.json") == 1 then
      return dir
    end
  end
end

local function resolve_clangd_binary()
  local mason_clangd = vim.fn.stdpath("data") .. "/mason/bin/clangd"
  if vim.fn.executable(mason_clangd) == 1 then
    return mason_clangd
  end
  return "clangd"
end

local function make_clangd_cmd(root)
  local cmd = {
    resolve_clangd_binary(),
    "--enable-config",
    "--background-index",
    "--header-insertion=never",
    "--completion-style=detailed",
    "--function-arg-placeholders=false",
    "--all-scopes-completion",
    "--pch-storage=memory",
  }

  if vim.fn.has("mac") == 1 then
    table.insert(cmd, "--query-driver=/opt/homebrew/bin/riscv64-unknown-elf-*")
  end

  local cc_dir = find_compile_commands_dir(root)
  if cc_dir then
    table.insert(cmd, "--compile-commands-dir=" .. cc_dir)
  end

  return cmd
end

local function clangd_root_dir()
  if vim.lsp and vim.lsp.config then
    return function(bufnr, on_dir)
      local name = vim.api.nvim_buf_get_name(bufnr)
      local path = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
      on_dir(find_clangd_root(path))
    end
  end

  return function(fname)
    local path = fname ~= "" and vim.fs.dirname(fname) or vim.fn.getcwd()
    return find_clangd_root(path)
  end
end

local clangd_init_options = {
  clangdFileStatus = true,
  usePlaceholders = false,
  completeUnimported = true,
  fallbackFlags = { "-std=gnu++20" },
}

enable_lsp("clangd", {
  cmd = make_clangd_cmd(vim.fn.getcwd()),
  root_dir = clangd_root_dir(),
  filetypes = clangd_filetypes,
  init_options = clangd_init_options,
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = {
      ensure_installed = { "c", "cpp", "cuda", "cmake" },
    },
    opts_extend = { "ensure_installed" },
  },

  {
    "williamboman/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "clangd",
        "clang-format",
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
        cuda = { "clang-format" },
      },
    },
  },
}
