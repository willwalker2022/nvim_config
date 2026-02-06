local function enable_lsp(server, opts)
  local function setup()
    if vim.lsp and vim.lsp.config then
      if vim.lsp.config[server] then
        if opts then
          vim.lsp.config(server, opts)
        end
        if vim.lsp.enable then
          vim.lsp.enable(server)
          return true
        end
      end
      return false
    end

    local ok, lspconfig = pcall(require, "lspconfig")
    if ok and lspconfig[server] then
      lspconfig[server].setup(opts or {})
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

enable_lsp("basedpyright")

local M = {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = {
      ensure_installed = { "python" },
    },
    opts_extend = { "ensure_installed" },
  },

  {
    "williamboman/mason.nvim",
    optional = true,
    opts_extend = { "ensure_installed" },
    opts = { ensure_installed = { "ruff", "pyright", "basedpyright" } },
  },

  -- formatter
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
      },
    },
  },

  -- linter
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        python = { "ruff" },
      },
    },
  },

  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "mfussenegger/nvim-dap" },
    cmd = "VenvSelect",
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
      },
    },
    --  Call config for python files and load the cached venv automatically
    ft = "python",
    keys = { { "<leader>cv", "<CMD>VenvSelect<CR>", desc = "Select VirtualEnv", ft = "python" } },
  },

  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")

      -- See `https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation`
      dap.adapters.python = function(cb, config)
        if config.request == "attach" then
          ---@diagnostic disable-next-line: undefined-field
          local port = (config.connect or config).port
          ---@diagnostic disable-next-line: undefined-field
          local host = (config.connect or config).host or "127.0.0.1"
          cb({
            type = "server",
            port = assert(port, "`connect.port` is required for a python `attach` configuration"),
            host = host,
            options = {
              source_filetype = "python",
            },
          })
        else
          cb({
            type = "executable",
            command = "python",
            args = { "-m", "debugpy.adapter" },
            options = {
              source_filetype = "python",
            },
          })
        end
      end

      dap.configurations.python = {
        {
          -- The first three options are required by nvim-dap
          type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
          request = "launch",
          name = "[Python] Launch file",

          -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
          program = "${file}", -- This configuration will launch the current file if used.
          -- You can also dynamically get arguments, e.g., from user input:
          args = function()
            local args_str = vim.fn.input("Commandline args: ")
            return vim.split(args_str, " ", { plain = true })
          end,
        },
      }
    end,
  },
}

return M
