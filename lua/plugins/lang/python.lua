local enable_lsp = require("config.lsp_servers").enable

local function resolve_pyright_cmd(cwd)
  local project_server = cwd .. "/.venv/bin/pyright-langserver"
  if vim.fn.executable(project_server) == 1 then
    return { project_server, "--stdio" }
  end

  local from_path = vim.fn.exepath("pyright-langserver")
  if type(from_path) == "string" and from_path ~= "" then
    return { from_path, "--stdio" }
  end

  local mason_server = vim.fn.stdpath("data") .. "/mason/bin/pyright-langserver"
  if vim.fn.executable(mason_server) == 1 then
    return { mason_server, "--stdio" }
  end

  return { "pyright-langserver", "--stdio" }
end

local function python_lsp_opts()
  local analysis = {
    autoSearchPaths = true,
    useLibraryCodeForTypes = true,
    diagnosticMode = "openFilesOnly",
    typeCheckingMode = "basic",
  }

  local opts = {
    settings = {
      python = {
        analysis = analysis,
      },
      pyright = {
        analysis = analysis,
      },
    },
  }

  local function append_path(paths, value)
    if type(value) ~= "string" or value == "" then
      return
    end
    for _, existing in ipairs(paths) do
      if existing == value then
        return
      end
    end
    table.insert(paths, value)
  end

  local cwd = vim.fn.getcwd()
  opts.cmd = resolve_pyright_cmd(cwd)
  local extra_paths = {}
  append_path(extra_paths, cwd)

  local sample_torch = cwd .. "/samples/torch"
  if vim.fn.isdirectory(sample_torch) == 1 then
    append_path(extra_paths, sample_torch)
  end

  local project_venv = cwd .. "/.venv"
  local project_python = project_venv .. "/bin/python"
  if vim.fn.executable(project_python) == 1 then
    opts.settings.python.pythonPath = project_python
    opts.settings.python.venvPath = cwd
    opts.settings.python.venv = ".venv"
  else
    local conda_prefix = vim.env.CONDA_PREFIX
    if conda_prefix and conda_prefix ~= "" then
      local python_path = conda_prefix .. "/bin/python"
      if vim.fn.executable(python_path) == 1 then
        local env_name = vim.env.CONDA_DEFAULT_ENV
        if not env_name or env_name == "" then
          env_name = vim.fn.fnamemodify(conda_prefix, ":t")
        end
        opts.settings.python.pythonPath = python_path
        opts.settings.python.venvPath = vim.fn.fnamemodify(conda_prefix, ":h")
        opts.settings.python.venv = env_name
      end
    end
  end

  if #extra_paths > 0 then
    analysis.extraPaths = extra_paths
  end

  return opts
end

enable_lsp("pyright", python_lsp_opts())

local M = {
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
