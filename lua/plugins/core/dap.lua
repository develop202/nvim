local dap_ui_layouts = nil
if OwnUtil.sys.is_termux() then
  dap_ui_layouts = {
    {
      elements = {
        { id = "scopes", size = 0.25 },
        { id = "breakpoints", size = 0.25 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      position = "left",
      size = 5,
    },
    {
      elements = {
        { id = "repl", size = 0.4 },
        { id = "console", size = 0.6 },
      },
      position = "bottom",
      size = 10,
    },
  }
end
return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = "mason.nvim",
    cmd = { "DapInstall", "DapUninstall" },
    -- mason-nvim-dap is loaded when nvim-dap loads
    config = function() end,
  },
  {
    "mfussenegger/nvim-dap",
    recommended = true,
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        opts = {
          icons = { expanded = " ", collapsed = "", current_frame = "" },
          controls = {
            icons = {
              pause = "",
              play = "",
              step_into = "",
              step_over = " ",
              step_out = "",
              step_back = " ",
              run_last = " ",
              terminate = " ",
              disconnect = " ",
            },
          },
          layouts = dap_ui_layouts,
        },

        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({})
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({})
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({})
          end
        end,
        keys = {
          {
            "<leader>du",
            function()
              require("dapui").toggle({})
            end,
            desc = "Dap UI",
          },
          {
            "<leader>dE",
            function()
              require("dapui").eval()
            end,
            desc = "Dap UI Eval",
            mode = { "n", "x" },
          },

          {
            "<leader>d1",
            function()
              require("dapui").toggle({ layout = 1 })
            end,
            desc = "Dap UI: Toggle other(except REPL and Console)",
            mode = { "n" },
          },
          {
            "<leader>d2",
            function()
              require("dapui").toggle({ layout = 2 })
            end,
            desc = "Dap UI: Toggle REPL and Console",
            mode = { "n" },
          },
        },
      },
      -- virtual text for the debugger
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
    },

    config = function()
      -- load mason-nvim-dap here, after all adapters have been setup
      require("mason-nvim-dap").setup({
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please don't ask me how to install them :)
        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
        },
      })

      -- vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
      --
      for name, sign in pairs(OwnUtil.icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      -- setup dap config by VsCode launch.json file
      local vscode = require("dap.ext.vscode")
      local json = require("plenary.json")
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end
    end,

    keys = {
      -- dap按键映射
      -- ==============================
      -- 运行控制
      -- ==============================
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "DAP: Continue / Start",
      },
      {
        "<leader>dp",
        function()
          require("dap").pause()
        end,
        desc = "DAP: Pause",
      },
      {
        "<leader>dr",
        function()
          require("dap").run_last()
        end,
        desc = "DAP: Run Last",
      },
      {
        "<leader>dR",
        function()
          require("dap").restart()
        end,
        desc = "DAP: Restart Session",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "DAP: Terminate",
      },
      {
        "<leader>dq",
        function()
          require("dap").disconnect()
        end,
        desc = "DAP: Disconnect",
      },

      -- ==============================
      -- 单步调试
      -- ==============================
      {
        "<leader>dn",
        function()
          require("dap").step_over()
        end,
        desc = "DAP: Step Over",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "DAP: Step Into",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "DAP: Step Out",
      },
      {
        "<leader>dk",
        function()
          require("dap").step_back()
        end,
        desc = "DAP: Step Back",
      },
      {
        "<leader>dK",
        function()
          require("dap").reverse_continue()
        end,
        desc = "DAP: Reverse Continue",
      },
      {
        "<leader>dg",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "DAP: Run to Cursor",
      },
      {
        "<leader>dG",
        function()
          require("dap").goto_()
        end,
        desc = "DAP: Jump to Cursor",
      },
      {
        "<leader>dX",
        function()
          require("dap").restart_frame()
        end,
        desc = "DAP: Restart Frame",
      },

      -- 调用栈
      {
        "<leader>d[",
        function()
          require("dap").up()
        end,
        desc = "DAP: Previous Stack Frame",
      },
      {
        "<leader>d]",
        function()
          require("dap").down()
        end,
        desc = "DAP: Next Stack Frame",
      },
      {
        "<leader>dF",
        function()
          require("dap").focus_frame()
        end,
        desc = "DAP: Focus Current Frame",
      },

      -- ==============================
      -- 断点
      -- ==============================
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "DAP: Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint()
        end,
        desc = "DAP: Set Breakpoint",
      },
      {
        "<leader>dC",
        function()
          local condition = vim.fn.input("Breakpoint condition: ")
          if condition ~= "" then
            require("dap").set_breakpoint(condition)
          end
        end,
        desc = "DAP: Conditional Breakpoint",
      },
      {
        "<leader>dH",
        function()
          local hit_condition = vim.fn.input("Hit condition: ")
          if hit_condition ~= "" then
            require("dap").set_breakpoint(nil, hit_condition)
          end
        end,
        desc = "DAP: Hit Conditional Breakpoint",
      },
      {
        "<leader>dL",
        function()
          local message = vim.fn.input("Log point message: ")
          if message ~= "" then
            require("dap").set_breakpoint(nil, nil, message)
          end
        end,
        desc = "DAP: Log Point",
      },
      {
        "<leader>dx",
        function()
          require("dap").clear_breakpoints()
        end,
        desc = "DAP: Clear All Breakpoints",
      },
      {
        "<leader>ds",
        function()
          require("dap").list_breakpoints(true)
        end,
        desc = "DAP: List Breakpoints",
      },
      {
        "<leader>dE",
        function()
          require("dap").set_exception_breakpoints()
        end,
        desc = "DAP: Exception Breakpoints",
      },

      -- ==============================
      -- 查看变量和调试信息
      -- ==============================
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        mode = { "n", "v" },
        desc = "DAP: Hover Variable",
      },
      {
        "<leader>dP",
        function()
          require("dap.ui.widgets").preview()
        end,
        mode = { "n", "v" },
        desc = "DAP: Preview Variable",
      },
      {
        "<leader>df",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.frames)
        end,
        desc = "DAP: Show Frames",
      },
      {
        "<leader>dv",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.scopes)
        end,
        desc = "DAP: Show Scopes",
      },
      {
        "<leader>dT",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.threads)
        end,
        desc = "DAP: Show Threads",
      },

      -- ==============================
      -- REPL 和日志
      -- ==============================
      {
        "<leader>de",
        function()
          require("dap").repl.open()
        end,
        desc = "DAP: Open REPL",
      },
      {
        "<leader>dM",
        function()
          vim.cmd("DapShowLog")
        end,
        desc = "DAP: Show Debug Log",
      },
    },
  },
}
