return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      -- 空文件夹折叠,缺点:在中间创建文件比较麻烦
      filesystem = {
        group_empty_dirs = true,
        scan_mode = "deep",
      },
    },
  },
  {
    "s1n7ax/nvim-window-picker",
    opts = {
      hint = "floating-big-letter",
      filter_rules = {
        include_current_win = true,
        bo = {
          filetype = {
            -- "fidget",
            "neo-tree",
          },
        },
      },
    },
    keys = {
      {
        "<c-w>p",
        function()
          local window_number = require("window-picker").pick_window()
          if window_number then
            vim.api.nvim_set_current_win(window_number)
          end
        end,
      },
    },
  },
  -- 自动保存插件
  {
    "Pocco81/auto-save.nvim",
    event = "LazyFile",
    opts = {
      execution_message = {
        message = "",
      },
    },
  },
  {
    "djoshea/vim-autoread",
    -- event = "LazyFile",
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    "echasnovski/mini.pairs",
    enabled = false,
  },
  {
    "mistweaverco/kulala.nvim",
    opts = function(_, opts)
      if os.getenv("HOME") == "/data/data/com.termux/files/home" then
        opts.split_direction = "horizontal"
      end
    end,
  },
  {
    "vim-test/vim-test",
    event = "LazyFile",
  },
  {
    "danymat/neogen",
    event = "LazyFile",
    config = true,
  },
}
