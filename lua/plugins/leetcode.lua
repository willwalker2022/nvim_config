return {
  {
    "kawre/leetcode.nvim",
    build = function()
      pcall(vim.cmd, "TSUpdate html")
    end,
    cmd = "Leet",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lang = "cpp",
      cn = {
        enabled = true,
        translator = true,
        translate_problems = true,
      },
      picker = {
        provider = "snacks-picker",
      },
      plugins = {
        non_standalone = true,
      },
    },
  },
}
