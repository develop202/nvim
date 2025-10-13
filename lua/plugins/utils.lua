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
    "nvim-mini/mini.pairs",
    enabled = false,
  },
  {
    "mistweaverco/kulala.nvim",
    brains = "main",
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
    },
  },
  -- 注释插件
  {
    "numToStr/Comment.nvim",
    event = "LazyFile",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      -- 使用opts设置enable_autocmd会导致插件无效
    },
    opts = function()
      -- 不知道为什么只能用function
      return {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },
  {
    "folke/persistence.nvim",
    opts = function()
      if not vim.g.persistence_loaded then
        OwnUtil.utils.termux_change_file_line(
          vim.fn.stdpath("data") .. "/lazy/persistence.nvim/lua/persistence/init.lua",
          106,
          "local function handle_selected(opts)"
        )
        OwnUtil.utils.termux_change_file_line(
          vim.fn.stdpath("data") .. "/lazy/persistence.nvim/lua/persistence/init.lua",
          125,
          "    prompt = opts.prompt,"
        )

        OwnUtil.utils.termux_change_file_line(
          vim.fn.stdpath("data") .. "/lazy/persistence.nvim/lua/persistence/init.lua",
          131,
          "      opts.handler(item)"
        )

        OwnUtil.utils.termux_change_file_line(
          vim.fn.stdpath("data") .. "/lazy/persistence.nvim/lua/persistence/init.lua",
          132,
          ""
        )
        -- 选择
        OwnUtil.utils.termux_change_file_line(
          vim.fn.stdpath("data") .. "/lazy/persistence.nvim/lua/persistence/init.lua",
          136,
          'function M.select() handle_selected({ prompt = "Select a session: ", handler = function(item) local ok, _ = pcall(function() vim.fn.chdir(item.dir) M.load() end) if not ok then os.remove(item.session) print("Delete not exist directory session " .. item.dir .. ".") end end, }) end'
        )
        -- 删除
        OwnUtil.utils.termux_change_file_line(
          vim.fn.stdpath("data") .. "/lazy/persistence.nvim/lua/persistence/init.lua",
          145,
          'function M.delete() handle_selected({ prompt = "Delete a session: ", handler = function(item) os.remove(item.session) print("Deleted " .. item.session) end, }) end'
        )
        vim.g.persistence_loaded = 1
      end
    end,
    keys = {
      -- 删除选择会话
      {
        "<leader>qD",
        function()
          require("persistence").delete()
        end,
        desc = "Delete Select Session",
      },
    },
  },
}
