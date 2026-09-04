local M = {}

local function find_root(path, markers)
  local match = vim.fs.find(markers, { path = path, upward = true })[1]
  return match and vim.fs.dirname(match) or path
end

function M.root_dir(markers)
  if vim.lsp and vim.lsp.config then
    return function(bufnr, on_dir)
      local name = vim.api.nvim_buf_get_name(bufnr)
      local path = name ~= "" and vim.fs.dirname(name) or vim.uv.cwd()
      on_dir(find_root(path, markers))
    end
  end

  return function(fname)
    local path = fname and fname ~= "" and vim.fs.dirname(fname) or vim.uv.cwd()
    return find_root(path, markers)
  end
end

function M.enable(server, opts)
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
    pattern = "LazyDone",
    once = true,
    callback = function()
      setup()
    end,
  })
end

return M
