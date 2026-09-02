return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "auto",
      background = {
        light = "latte",
        dark = "mocha",
      },
      -- Let the host terminal provide the real background while Catppuccin colors syntax and UI.
      transparent_background = true,
      float = {
        transparent = true,
      },
      term_colors = true,

      custom_highlights = function(colors)
        -- stylua: ignore
        return {
          LineNr                       = { fg = colors.surface2 },
          Visual                       = { bg = colors.overlay0 },
          Search                       = { bg = colors.surface2 },
          IncSearch                    = { bg = colors.mauve },
          CurSearch                    = { bg = colors.mauve },
          MatchParen                   = { bg = colors.mauve, fg = colors.base, bold = true },
          HlSearchLensNear             = { fg = colors.mauve },
          ScrollbarSearchIndicator     = { fg = colors.mauve },
          SnacksPickerListCursorLine   = { bg = colors.surface0 },
        }
      end,
      integrations = {
        barbar = true,
        blink_cmp = true,
        gitsigns = true,
        mason = true,
        noice = true,
        nvimtree = true,
        rainbow_delimiters = true,
        snacks = {
          enabled = true,
          indent_scope_color = "flamingo", -- catppuccin color (eg. `lavender`) Default: text
        },
        which_key = true,
        flash = true,
        lsp_trouble = true,
        dap = true,
        dap_ui = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)

      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
