local function with_blink_capabilities(opts)
  opts = opts or {}
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    opts.capabilities = blink.get_lsp_capabilities(opts.capabilities)
  end
  return opts
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

  return nil
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
    "--background-index",
    "--header-insertion=never",
    "--completion-style=detailed",
    "--function-arg-placeholders=false",
    "--all-scopes-completion",
    "--pch-storage=memory",
  }

  local cc_dir = find_compile_commands_dir(root)
  if cc_dir then
    table.insert(cmd, "--compile-commands-dir=" .. cc_dir)
  end

  return cmd
end

local function clangd_root_dir(fname)
  local ok, util = pcall(require, "lspconfig.util")
  if ok then
    local root = util.root_pattern("compile_commands.json", ".clangd", ".clang-tidy", "CMakeLists.txt", "Makefile", ".git")(fname)
    if root then
      return root
    end
    return util.path.dirname(fname)
  end

  return vim.fn.getcwd()
end

local clangd_filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" }

local clangd_init_options = {
  clangdFileStatus = true,
  usePlaceholders = false,
  completeUnimported = true,
  fallbackFlags = { "-std=gnu++20" },
}

local function enable_lsp(server, opts)
  local function setup()
    local server_opts = with_blink_capabilities(opts)

    if vim.lsp and vim.lsp.config and vim.lsp.enable then
      vim.lsp.config(server, server_opts)
      vim.lsp.enable(server)
      return true
    end

    local ok, lspconfig = pcall(require, "lspconfig")
    if ok and lspconfig[server] then
      lspconfig[server].setup(server_opts)
      return true
    end
    return false
  end

  if setup() then
    return
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
      setup()
    end,
  })
end

enable_lsp("clangd", {
  cmd = make_clangd_cmd(vim.fn.getcwd()),
  root_dir = clangd_root_dir,
  on_new_config = function(new_config, new_root_dir)
    new_config.cmd = make_clangd_cmd(new_root_dir)
  end,
  filetypes = clangd_filetypes,
  init_options = clangd_init_options,
})

-- Fallback attach path: in case auto-enable misses a buffer, force-start clangd.
local clangd_attach_group = vim.api.nvim_create_augroup("UserEnsureClangd", { clear = true })
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  group = clangd_attach_group,
  pattern = clangd_filetypes,
  callback = function(args)
    local bufnr = args.buf
    if not (vim.lsp and vim.lsp.start) then
      return
    end
    if #vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" }) > 0 then
      return
    end

    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" then
      return
    end

    local root = clangd_root_dir(fname)
    local opts = with_blink_capabilities({
      name = "clangd",
      cmd = make_clangd_cmd(root),
      root_dir = root,
      init_options = clangd_init_options,
    })
    vim.lsp.start(opts, { bufnr = bufnr })
  end,
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
