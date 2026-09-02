local enable_lsp = require("config.lsp_servers").enable

vim.filetype.add({
  extension = {
    slang = "shaderslang",
    slangh = "shaderslang",
  },
})

-- nvim-lspconfig calls the filetype `shaderslang`, while the Tree-sitter
-- parser is named `slang`.
vim.treesitter.language.register("slang", "shaderslang")

enable_lsp("slangd", {
  cmd = { vim.fn.expand("~/.local/bin/slangd") },
  settings = {
    slang = {
      additionalSearchPaths = { "src/gpu" },
      searchInAllWorkspaceDirectories = true,
      inlayHints = {
        deducedTypes = true,
        parameterNames = true,
      },
      format = {
        clangFormatLocation = "/opt/homebrew/bin/clang-format",
        clangFormatStyle = "file",
      },
    },
  },
})

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        shaderslang = { "clang-format" },
      },
    },
  },
}
