return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    lazy = false,
    opts = {
      auto_install = true,
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "cuda",
        "rust",
        "go",
        "gomod",
        "gosum",
        "gotmpl",
        "html",
        "markdown",
        "markdown_inline",
        "json",
        "jsonc",
        "yaml",
        "toml",
        "vim",
        "vimdoc",
        "query",
        "elixir",
        "heex",
        "javascript",
        "lua",
        "python",
        "dockerfile",
        "cmake",
      },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        vim.notify("nvim-treesitter.configs not found. Run :Lazy sync to install the legacy branch.", vim.log.levels.WARN)
        return
      end
      configs.setup(opts)
    end,
    opts_extend = { "ensure_installed" },
  },
}
