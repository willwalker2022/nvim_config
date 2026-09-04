local function lsp_supports(method)
  local bufnr = vim.api.nvim_get_current_buf()

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client:supports_method(method, bufnr) then
      return true
    end
  end

  return false
end

local function notify_unsupported(feature)
  vim.notify(feature .. " is not supported by the language server for this buffer", vim.log.levels.INFO)
end

local function lsp_picker(method, picker, opts)
  return function()
    if not lsp_supports(method) then
      notify_unsupported(opts and opts.feature or picker)
      return
    end

    require("snacks").picker[picker](opts and opts.picker or nil)
  end
end

local function references()
  if lsp_supports("textDocument/references") then
    require("snacks").picker.lsp_references()
    return
  end

  vim.notify("LSP references are unavailable; searching for this word as text", vim.log.levels.INFO)
  require("snacks").picker.grep_word()
end

local function document_symbols()
  local opts = {
    layout = { preset = "telescope", reverse = true },
    icons = { tree = { last = "┌╴" } },
  }

  if lsp_supports("textDocument/documentSymbol") then
    require("snacks").picker.lsp_symbols(opts)
    return
  end

  local has_parser = pcall(vim.treesitter.get_parser, 0)
  if has_parser then
    vim.notify("LSP symbols are unavailable; using Tree-sitter symbols", vim.log.levels.INFO)
    require("snacks").picker.treesitter(opts)
    return
  end

  notify_unsupported("Document symbols")
end

return {

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      -- Generated/amalgamated headers around 1 MiB can make Treesitter, LSP,
      -- and folding noticeably sluggish. Use Snacks' lightweight filetype
      -- before those features attach.
      bigfile = {
        enabled = true,
        size = 800 * 1024,
      },
      dashboard = { enabled = true },
      explorer = { enabled = false },
      image = {
        enabled = true,
        doc = { inline = false, float = false, max_width = 80, max_height = 40 },
        math = { latex = { font_size = "small" } },
      },
      indent = {
        enabled = true,
        animate = {
          enabled = false,
        },
        indent = {
          only_scope = true,
        },
        scope = {
          enabled = true, -- enable highlighting the current scope
          underline = true, -- underline the start of the scope
        },
        chunk = {
          -- when enabled, scopes will be rendered as chunks, except for the top-level scope which will be rendered as a scope.
          enabled = true,
        },
      },
      input = { enabled = true },
      lazygit = {
        enabled = true,
        configure = false,
      },
      notifier = {
        enabled = true,
        style = "notification",
      },
      picker = {
        enabled = true,
        previewers = {
          diff = {
            builtin = false, -- use Neovim for previewing diffs (true) or use an external tool (false)
            cmd = { "delta" }, -- example to show a diff with delta
          },
          git = {
            builtin = false, -- use Neovim for previewing git output (true) or use git (false)
            args = {}, -- additional arguments passed to the git command. Useful to set pager options using `-c ...`
          },
        },
        sources = {
          spelling = {
            layout = { preset = "select" },
          },
        },
        win = {
          input = {
            keys = {
              ["<Tab>"] = { "select_and_prev", mode = { "i", "n" } },
              ["<S-Tab>"] = { "select_and_next", mode = { "i", "n" } },
              ["<A-Up>"] = { "history_back", mode = { "n", "i" } },
              ["<A-Down>"] = { "history_forward", mode = { "n", "i" } },
              ["<A-j>"] = { "list_down", mode = { "n", "i" } },
              ["<A-k>"] = { "list_up", mode = { "n", "i" } },
              ["<C-u>"] = { "preview_scroll_up", mode = { "n", "i" } },
              ["<C-d>"] = { "preview_scroll_down", mode = { "n", "i" } },
              ["<A-u>"] = { "list_scroll_up", mode = { "n", "i" } },
              ["<A-d>"] = { "list_scroll_down", mode = { "n", "i" } },
              ["<c-j>"] = {},
              ["<c-k>"] = {},
            },
          },
        },
        layout = {
          preset = "telescope",
        },
      },
      quickfile = { enabled = true },
      scroll = { enabled = false },
      -- Create keymappings of `ii` and `ai` for textobjects, and `[i` and `]i` for jumps
      scope = {
        enabled = true,
        cursor = false,
      },

      statuscolumn = {
        enabled = true,
        left = { "mark", "sign" }, -- priority of signs on the left (high to low)
        right = { "fold", "git" }, -- priority of signs on the right (high to low)
        folds = {
          open = true, -- show open fold icons
          git_hl = false, -- use Git Signs hl for fold icons
        },
        refresh = 50, -- refresh at most every 50ms
      },

      terminal = {
        enabled = true,
      },
      words = { enabled = true },
      styles = {
        terminal = {
          relative = "editor",
          border = "rounded",
          position = "float",
          backdrop = 60,
          height = 0.9,
          width = 0.9,
          zindex = 50,
        },
      },
    },

    -- stylua: ignore
    keys = {
      { "<A-w>", function() require("snacks").bufdelete() end, desc = "[Snacks] Delete buffer" },
      { "<leader>si", function() require("snacks").image.hover() end, desc = "[Snacks] Display image" },
      { "<A-i>", function() require("snacks").terminal() end, desc = "[Snacks] Toggle terminal", mode = {"n",  "t"} },
      -- Notification
      { "<leader>n", function() require("snacks").notifier.show_history() end, desc = "[Snacks] Notification history" },
      { "<leader>un", function() require("snacks").notifier.hide() end, desc = "[Snacks] Dismiss all notifications" },
      -- Top Pickers & Explorer
      { "<leader><space>", function() require("snacks").picker.smart() end, desc = "[Snacks] Smart find files" },
      { "<leader>,", function() require("snacks").picker.buffers() end, desc = "[Snacks] Buffers" },
      { "<leader>sn", function() require("snacks").picker.notifications() end, desc = "[Snacks] Notification history" },
      -- find
      { "<leader>sb", function() require("snacks").picker.lines() end, desc = "[Snacks] Buffer lines" },
      { "<leader>sf", function() require("snacks").picker.files() end, desc = "[Snacks] Find files" },
      { "<leader>sp", function() require("snacks").picker.projects() end, desc = "[Snacks] Projects" },
      { "<leader>sr", function() require("snacks").picker.recent() end, desc = "[Snacks] Recent" },
      -- git
      { "<C-g>", function() require("snacks").lazygit() end, desc = "[Snacks] Lazygit" },
      { "<leader>ggl", function() require("snacks").picker.git_log() end, desc = "[Snacks] Git log" },
      { "<leader>ggd", function() require("snacks").picker.git_diff() end, desc = "[Snacks] Git diff" },
      { "<leader>ggb", function() require("snacks").git.blame_line() end, desc = "[Snacks] Git blame line" },
      { "<leader>ggB", function() require("snacks").gitbrowse() end, desc = "[Snacks] Git browse" },
      -- Grep
      -- { "<leader>sB", function() require("snacks").picker.grep_buffers() end, desc = "[Snacks] Grep open buffers" },
      { "<leader>sg", function() require("snacks").picker.grep() end, desc = "[Snacks] Grep" },
      { "<leader>sw", function() require("snacks").picker.grep_word() end, desc = "[Snacks] Search word or selection", mode = { "n", "x" } },
      -- search
      { '<leader>s"', function() require("snacks").picker.registers() end, desc = "[Snacks] Registers" },
      { '<leader>s/', function() require("snacks").picker.search_history() end, desc = "[Snacks] Search history" },
      { "<leader>sa", function() require("snacks").picker.spelling() end, desc = "[Snacks] Spelling" },
      { "<leader>sA", function() require("snacks").picker.autocmds() end, desc = "[Snacks] Autocmds" },
      { "<leader>s:", function() require("snacks").picker.command_history() end, desc = "[Snacks] Command history" },
      { "<leader>sc", function() require("snacks").picker.commands() end, desc = "[Snacks] Commands" },
      { "<leader>sd", function() require("snacks").picker.diagnostics() end, desc = "[Snacks] Diagnostics" },
      { "<leader>sD", function() require("snacks").picker.diagnostics_buffer() end, desc = "[Snacks] Diagnostics buffer" },
      { "<leader>sH", function() require("snacks").picker.help() end, desc = "[Snacks] Help pages" },
      { "<leader>sh", function() require("snacks").picker.highlights() end, desc = "[Snacks] Highlights" },
      { "<leader>sI", function() require("snacks").picker.icons() end, desc = "[Snacks] Icons" },
      { "<leader>sj", function() require("snacks").picker.jumps() end, desc = "[Snacks] Jumps" },
      { "<leader>sk", function() require("snacks").picker.keymaps() end, desc = "[Snacks] Keymaps" },
      { "<leader>sl", function() require("snacks").picker.loclist() end, desc = "[Snacks] Location list" },
      { "<leader>sm", function() require("snacks").picker.marks() end, desc = "[Snacks] Marks" },
      { "<leader>sM", function() require("snacks").picker.man() end, desc = "[Snacks] Man pages" },
      { "<leader>sP", function() require("snacks").picker.lazy() end, desc = "[Snacks] Search for plugin spec" },
      { "<leader>sq", function() require("snacks").picker.qflist() end, desc = "[Snacks] Quickfix list" },
      { "<leader>sR", function() require("snacks").picker.resume() end, desc = "[Snacks] Resume" },
      { "<leader>su", function() require("snacks").picker.undo() end, desc = "[Snacks] Undo history" },
      -- LSP
      { "gd", lsp_picker("textDocument/definition", "lsp_definitions", { feature = "Definition", picker = { unique_lines = true } }), desc = "[Snacks] Goto definition" },
      { "gD", lsp_picker("textDocument/declaration", "lsp_declarations", { feature = "Declaration" }), desc = "[Snacks] Goto declaration" },
      { "gr", references, nowait = true, desc = "[Snacks] References" },
      { "gI", lsp_picker("textDocument/implementation", "lsp_implementations", { feature = "Implementation" }), desc = "[Snacks] Goto implementation" },
      { "gy", lsp_picker("textDocument/typeDefinition", "lsp_type_definitions", { feature = "Type definition" }), desc = "[Snacks] Goto type definition" },
      { "<leader>ci", lsp_picker("textDocument/prepareCallHierarchy", "lsp_incoming_calls", { feature = "Incoming calls" }), desc = "[Snacks] Incoming calls" },
      { "<leader>co", lsp_picker("textDocument/prepareCallHierarchy", "lsp_outgoing_calls", { feature = "Outgoing calls" }), desc = "[Snacks] Outgoing calls" },
      { "<leader>ss", document_symbols, desc = "[Snacks] Document symbols" },
      { "<leader>sS", lsp_picker("workspace/symbol", "lsp_workspace_symbols", { feature = "Workspace symbols" }), desc = "[Snacks] Workspace symbols" },
      -- Words
      { "]]", function() require("snacks").words.jump(vim.v.count1) end, desc = "[Snacks] Next Reference", mode = { "n", "t" } },
      { "[[", function() require("snacks").words.jump(-vim.v.count1) end, desc = "[Snacks] Prev Reference", mode = { "n", "t" } },
      -- Zen mode
      { "<leader>z", function() require("snacks").zen() end, desc = "[Snacks] Toggle Zen Mode" },
      { "<leader>Z", function() require("snacks").zen.zoom() end, desc = "[Snacks] Toggle Zoom" },
    },

    init = function()
      local Snacks = require("snacks")

      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for `:=` command

          Snacks.toggle
            .new({
              id = "Animation",
              name = "Animation",
              get = function()
                return Snacks.animate.enabled()
              end,
              set = function(state)
                vim.g.snacks_animate = state
              end,
            })
            :map("<leader>ta")

          Snacks.toggle
            .new({
              id = "scroll_anima",
              name = "Scroll animation",
              get = function()
                return Snacks.scroll.enabled
              end,
              set = function(state)
                if state then
                  Snacks.scroll.enable()
                else
                  Snacks.scroll.disable()
                end
              end,
            })
            :map("<leader>tS")

          -- Create some toggle mappings
          Snacks.toggle.dim():map("<leader>tD")

          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>ts")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>tw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>tL")
          Snacks.toggle.diagnostics():map("<leader>td")
          Snacks.toggle.line_number():map("<leader>tl")
          Snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map("<leader>tc")
          Snacks.toggle.treesitter():map("<leader>tT")
          Snacks.toggle
            .option("background", { off = "light", on = "dark", name = "Neovim Dark Palette" })
            :map("<leader>tb")
          Snacks.toggle.inlay_hints():map("<leader>th")
          Snacks.toggle.indent():map("<leader>tg")
          Snacks.toggle.dim():map("<leader>tD")
          -- Toggle the profiler
          Snacks.toggle.profiler():map("<leader>tpp")
          -- Toggle the profiler highlights
          Snacks.toggle.profiler_highlights():map("<leader>tph")

          -- This configuration uses the concise Snacks navigation scheme. Remove
          -- Neovim's overlapping `gr*` defaults so `gr` is immediate and there is
          -- only one discoverable key for each operation.
          for _, lhs in ipairs({ "grn", "gra", "grr", "gri", "grt", "grx" }) do
            pcall(vim.keymap.del, "n", lhs)
          end
        end,
      })
    end,
  },
}
