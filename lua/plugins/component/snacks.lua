return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {

      bigfile = { enabled = true },
      quickfile = { enabled = true },
      words = { enabled = true },

      notifier = {
        margin = { top = 1, right = 1, bottom = 0 },
        icons = {
          -- 解决光标行图标显示问题
          error = " ",
          warn = " ",
          info = " ",
          debug = " ",
          trace = " ",
        },
      },

      lazygit = {
        config = {
          gui = {
            -- 关闭图标字体
            nerdFontsVersion = not OwnUtil.sys.is_termux() and "3" or "",
          },
        },
      },

      dashboard = {
        width = OwnUtil.sys.is_termux() and OwnUtil.utils.termux_dash_width() or 60,
        preset = {
          pick = "fzf-lua",
          header = OwnUtil.utils.dashboard.preset.header,
        },
      },
    },
    -- stylua: ignore
    keys = {
      -- buffer
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
      { "<leader>bD", "<cmd>:bd<cr>", desc = "Delete Buffer and Window" },
      -- notify
      { "<Esc>", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "<leader>n", function()
          Snacks.notifier.show_history()
        end, desc = "Notification History" },

      -- floating terminal
      { "<leader>fT", function() Snacks.terminal() end, mode = "n", desc = "Terminal (cwd)" },
      { "<leader>ft", function() Snacks.terminal(nil, { cwd = vim.fn.getcwd() }) end, mode = "n", desc = "Terminal (Root Dir)" },
      { "<c-/>", function() Snacks.terminal.focus(nil, { cwd = vim.fn.getcwd() }) end, mode = { "n", "t" }, desc = "Terminal (Root Dir)" },
      { "<c-_>", function() Snacks.terminal.focus(nil, { cwd = vim.fn.getcwd() }) end, mode = { "n", "t" }, desc = "which_key_ignore" },
    },
  },
}
