return {
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    main = "dapui",
    -- stylua: ignore
    keys = {
      { "<leader>Du", function() require("dapui").toggle({reset = true}) end, desc = "[DAP ui] Toggle dapui" },
    },
    opts = {},

    config = function(_, opts)
      local dapui = require("dapui")
      dapui.setup(opts)

      local dap = require("dap")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
    end,
  },

  {
    -- Show variable values as virtual texts
    "theHamsta/nvim-dap-virtual-text",
    enabled = false, -- Disabled by default
    opts = {
      virt_text_pos = "eol",
    },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        -- Solve the display issue with lualine
        "nvim-lualine/lualine.nvim",
        optional = true,
        opts = { options = { disabled_filetypes = { winbar = { "dap-repl" } } } },
      },
    },
    -- stylua: ignore
    keys = {
      { "<F5>",       function() require("dap").continue() end,                                                        mode = "n",          desc = "[DAP] Continue" },
      { "<F6>",       function() require("dap").step_over() end,                                                       mode = "n",          desc = "[DAP] Step over" },
      { "<F7>",       function() require("dap").step_into() end,                                                       mode = "n",          desc = "[DAP] Step into" },
      { "<F8>",       function() require("dap").step_out() end,                                                        mode = "n",          desc = "[DAP] Step out" },
      { "<F9>",       function() require("dap").pause() end,                                                           mode = "n",          desc = "[DAP] Pause" },
      { "<F10>",      function() require("dap").terminate() end,                                                       mode = "n",          desc = "[DAP] Terminate" },
      { "<Leader>b",  function() require("dap").toggle_breakpoint() end,                                               mode = "n",          desc = "[DAP] Toggle breakpoint" },
      { "<Leader>B",  function() require("dap").set_breakpoint() end,                                                  mode = "n",          desc = "[DAP] Set breakpoint" },
      -- Remove the <leader>D binding in "x" mode
      { "<Leader>D" , mode = "x" },
      { "<Leader>Dr", function() require("dap").repl.open() end,                                                       mode = "n",          desc = "[DAP] Repl open" },
      { "<Leader>Dl", function() require("dap").run_last() end,                                                        mode = "n",          desc = "[DAP] Run last" },
      { "<Leader>Dd", function() require("dap.ui.widgets").hover() end,                                                mode = { "n", "v" }, desc = "[DAP] Widgets hover" },
      { "<Leader>Dp", function() require("dap.ui.widgets").preview() end,                                              mode = { "n", "v" }, desc = "[DAP] Widgets preview" },
      { "<Leader>Df", function() local widgets = require("dap.ui.widgets") widgets.centered_float(widgets.frames) end, mode = {"n"},        desc = "[DAP] Float frames" },
      { "<Leader>Ds", function() local widgets = require("dap.ui.widgets") widgets.centered_float(widgets.scopes) end, mode = {"n"},        desc = "[DAP] Float scopes" },
    },

    config = function()
      --stylua: ignore
      local dap_breakpoint = {
        breakpoint = { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }, -- Nerd font: nf-cod-activate_breakpoints
        condition  = { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" },
        rejected   = { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" },
        logpoint   = { text = "", texthl = "DapLogPoint",   linehl = "DapLogPoint",   numhl = "DapLogPoint"   },
        stopped    = { text = "", texthl = "DapStopped",    linehl = "DapStopped",    numhl = "DapStopped"    },
      }
      vim.fn.sign_define("DapBreakpoint", dap_breakpoint.breakpoint)
      vim.fn.sign_define("DapBreakpointCondition", dap_breakpoint.condition)
      vim.fn.sign_define("DapBreakpointRejected", dap_breakpoint.rejected)
      vim.fn.sign_define("DapLogPoint", dap_breakpoint.logpoint)
      vim.fn.sign_define("DapStopped", dap_breakpoint.stopped)
    end,
  },
}
