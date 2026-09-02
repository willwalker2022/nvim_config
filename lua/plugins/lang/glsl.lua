vim.filetype.add({
  extension = {
    glsl = "glsl",
    frag = "glsl",
    vert = "glsl",
    geom = "glsl",
    comp = "glsl",
    tesc = "glsl",
    tese = "glsl",
    fs = "glsl",
    vs = "glsl",
  },
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserGlslLsp", { clear = true }),
  pattern = { "glsl", "vert", "tesc", "tese", "frag", "geom", "comp" },
  callback = function(args)
    if not (vim.lsp and vim.lsp.config and vim.lsp.config.glsl_analyzer) then
      return
    end

    local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "glsl_analyzer" })
    if #clients > 0 then
      return
    end

    pcall(vim.lsp.start, vim.lsp.config.glsl_analyzer, { bufnr = args.buf })
  end,
})

return {
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = {
      ensure_installed = {
        "glsl_analyzer",
      },
    },
    opts_extend = { "ensure_installed" },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        glsl = { "clang-format" },
      },
    },
  },
}
