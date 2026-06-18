local M = {}

local function start_for_loaded_buffers(server)
  if not (vim.lsp and vim.lsp.config and vim.lsp.start) then
    return
  end

  local config = vim.lsp.config[server]
  if not (config and config.filetypes) then
    return
  end

  vim.schedule(function()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) and vim.tbl_contains(config.filetypes, vim.bo[bufnr].filetype) then
        pcall(vim.lsp.start, config, { bufnr = bufnr })
      end
    end
  end)
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
          start_for_loaded_buffers(server)
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

return M
