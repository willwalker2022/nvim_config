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
