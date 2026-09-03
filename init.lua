-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number = true
vim.wo.cursorline = true
-- Display tabs and trailing spaces
vim.opt.list = true
vim.opt.listchars = { tab = "  ", trail = "-" }
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.clipboard = "unnamedplus"

vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 10
vim.opt.startofline = false

vim.opt.conceallevel = 2

vim.o.signcolumn = "yes:1"

vim.wo.wrap = false

-- Visually wrap prose, but keep source code on a single screen line.
-- BufWinEnter also handles switching an existing window between buffer types.
local wrapped_filetypes = {
  markdown = true,
}

local function apply_filetype_line_wrap(win, buf)
  if not (vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(buf)) then
    return
  end

  local wrap = wrapped_filetypes[vim.bo[buf].filetype] or false
  vim.api.nvim_set_option_value("wrap", wrap, { win = win })
  vim.api.nvim_set_option_value("linebreak", wrap, { win = win })
  vim.api.nvim_set_option_value("breakindent", wrap, { win = win })
end

local function apply_buffer_line_wrap(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    apply_filetype_line_wrap(win, buf)
  end
end

local line_wrap_group = vim.api.nvim_create_augroup("UserFiletypeLineWrap", { clear = true })

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
  group = line_wrap_group,
  callback = function(args)
    apply_buffer_line_wrap(args.buf)
  end,
})

vim.api.nvim_create_autocmd("SessionLoadPost", {
  group = line_wrap_group,
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      apply_filetype_line_wrap(win, vim.api.nvim_win_get_buf(win))
    end
  end,
})

-- Also make `:source $MYVIMRC` update windows that are already open.
for _, win in ipairs(vim.api.nvim_list_wins()) do
  apply_filetype_line_wrap(win, vim.api.nvim_win_get_buf(win))
end

-- Enables project-local `.nvim.lua` configuration file
vim.o.exrc = true

-- Tab related options
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.splitbelow = true
vim.opt.splitright = true

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local user_shell = vim.env.SHELL
vim.opt.shell = user_shell and vim.fn.executable(user_shell) == 1 and user_shell or "sh"

if vim.fn.exists("&winborder") == 1 then
  vim.o.winborder = "rounded"
end

require("config.lazy") -- Import `./lua/config/lazy.lua`

require("keymapping")

-- Snacks profiler
if vim.env.PROF then
  -- example for lazy.nvim
  -- change this to the correct path for your plugin manager
  local snacks = vim.fn.stdpath("data") .. "/lazy/snacks.nvim"
  vim.opt.rtp:append(snacks)
  require("snacks.profiler").startup({
    startup = {
      event = "VimEnter", -- stop profiler on this event. Defaults to `VimEnter`
      -- event = "UIEnter",
      -- event = "VeryLazy",
    },
  })
end
