return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup()
      require("nvim-treesitter").install({
        "c",
        "cpp",
        "go",
        "gomod",
        "gosum",
        "gotmpl",
        "html",
        "json",
        "yaml",
        "toml",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "rust",
        "vim",
        "vimdoc",
        "javascript",
      })

      -- Neovim 0.12 built-in ftplugins do not auto-start treesitter.
      -- nvim-treesitter main branch also requires explicit enabling.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
