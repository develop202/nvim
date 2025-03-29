local lazygit_icons = "3"
if OwnUtil.sys.is_termux() then
  lazygit_icons = ""
end
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
      if OwnUtil.sys.is_termux() then
        opts.split_direction = "horizontal"
      end
    end,
  },
  {
    "vim-test/vim-test",
    event = "LazyFile",
  },
  {
    --生成文档注释
    "danymat/neogen",
    cmd = "Neogen",
    config = true,
    keys = {
      {
        "<leader>fn",
        function()
          require("neogen").generate()
        end,
        desc = "Generate Annotations (Neogen)",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      icons = {
        keys = {
          BS = "󰁮 ",
          F10 = "󱊴 ",
          F11 = "󱊵 ",
          F12 = "󱊶 ",
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        config = {
          gui = {
            -- 关闭图标字体
            nerdFontsVersion = lazygit_icons,
          },
        },
      },
    },
  },
  -- 注释插件
  {
    "numToStr/Comment.nvim",
    event = "LazyFile",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    opts = {},
  },
}
