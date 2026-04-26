local dap_ui_layouts = nil
if not OwnUtil.sys.is_termux() then
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
    "rcarriga/nvim-dap-ui",
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
  },
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>dc",
        function()
          if vim.o.filetype == "java" then
            vim.cmd.edit()
            vim.cmd("JdtUpdateDebugConfig")
            vim.wait(200)
          end
          require("dap").continue()
        end,
        desc = "Run/Continue",
      },
    },
  },

  {
    "vim-test/vim-test",
    event = "BufReadPre",
  },
}
