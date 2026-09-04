local parsers = {
  -- Primary languages.
  "c",
  "cpp",
  "glsl",
  "python",
  "slang",

  -- Configuration, documentation, and existing auxiliary languages.
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
  "query",
  "rust",
  "vim",
  "vimdoc",
  "javascript",
}

local managed_parsers = {}
for _, parser in ipairs(parsers) do
  managed_parsers[parser] = true
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup()
      require("nvim-treesitter").install(parsers)

      local function start_treesitter(buf)
        local filetype = vim.bo[buf].filetype
        local language = vim.treesitter.language.get_lang(filetype) or filetype
        if not managed_parsers[language] then
          return
        end

        local ok, err = pcall(vim.treesitter.start, buf)
        if not ok then
          vim.schedule(function()
            vim.notify_once(("Tree-sitter could not start for %s: %s"):format(filetype, err), vim.log.levels.WARN)
          end)
        end
      end

      -- Neovim 0.12 built-in ftplugins do not auto-start treesitter.
      -- nvim-treesitter main branch also requires explicit enabling.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true }),
        callback = function(args)
          start_treesitter(args.buf)
        end,
      })
    end,
  },
}
