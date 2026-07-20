local ensure_installed = {
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
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = function()
      require("nvim-treesitter").install(ensure_installed):wait(300000)
      vim.cmd.TSUpdate()
    end,
    lazy = false,
    config = function()
      local ok, treesitter = pcall(require, "nvim-treesitter")
      if not ok then
        vim.notify("nvim-treesitter not found. Run :Lazy sync.", vim.log.levels.WARN)
        return
      end

      treesitter.setup()
      -- Neovim 0.12 built-in ftplugins do not auto-start treesitter.
      -- nvim-treesitter main branch also requires explicit enabling.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
        callback = function(args)
          local ok_start = pcall(vim.treesitter.start, args.buf)
          if ok_start then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
