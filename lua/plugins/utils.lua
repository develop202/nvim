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
    config = function()
      require("auto-save").setup({
        -- your config goes here
        -- or just leave it empty
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        -- ["*"] = { "prettier" },
        ["yaml"] = { "yamlfmt" },
        -- ["sh"] = { "beautysh" },
        ["sh"] = { "shfmt" },
        ["sql"] = { "sql_formatter" },
        ["mysql"] = { "sql_formatter" },
        ["python"] = { "ruff_format", "isort" },
        ["lua"] = { "stylua" },
        ["luau"] = { "stylua" },
      },
      formatters = {
        sql_formatter = {
          exe = "sql-formatter",
          -- stdin = true,
          args = { "--config", "/data/data/com.termux/files/home/.sql-formatter.json" },
        },
      },
    },
  },
  {
    "djoshea/vim-autoread",
    -- event = "LazyFile",
  },
  {
    "hedyhli/outline.nvim",
    opts = {
      symbol_folding = {
        markers = { " ", " " },
      },
      providers = {
        lsp = {
          -- Lsp client names to ignore
          -- 忽略lsp
          blacklist_clients = { "spring-boot", "ruff" },
        },
      },
      symbols = {
        icons = {
          File = { icon = " ", hl = "Identifier" },
          Module = { icon = " ", hl = "Include" },
          Namespace = { icon = " ", hl = "Include" },
          Package = { icon = "󰏗 ", hl = "Include" },
          Class = { icon = " ", hl = "Type" },
          Method = { icon = " ", hl = "Function" },
          Property = { icon = " ", hl = "Identifier" },
          Field = { icon = " ", hl = "Identifier" },
          Constructor = { icon = " ", hl = "Special" },
          Enum = { icon = " ", hl = "Type" },
          Interface = { icon = " ", hl = "Type" },
          Function = { icon = " ", hl = "Function" },
          Variable = { icon = " ", hl = "Constant" },
          Constant = { icon = " ", hl = "Constant" },
          String = { icon = " ", hl = "String" },
          Number = { icon = "󰎠 ", hl = "Number" },
          Boolean = { icon = " ", hl = "Boolean" },
          Array = { icon = " ", hl = "Constant" },
          Object = { icon = " ", hl = "Type" },
          Key = { icon = "󰌋 ", hl = "Type" },
          Null = { icon = " ", hl = "Type" },
          EnumMember = { icon = " ", hl = "Identifier" },
          Struct = { icon = " ", hl = "Structure" },
          Event = { icon = " ", hl = "Type" },
          Operator = { icon = " ", hl = "Identifier" },
          TypeParameter = { icon = " ", hl = "Identifier" },
          Component = { icon = "󰡀 ", hl = "Function" },
          Fragment = { icon = "󰅴 ", hl = "Constant" },
          -- ccls
          TypeAlias = { icon = " ", hl = "Type" },
          Parameter = { icon = " ", hl = "Identifier" },
          StaticMethod = { icon = " ", hl = "Function" },
          Macro = { icon = " ", hl = "Function" },
        },
      },
      keymaps = {
        goto_location = "o",
        fold_toggle = "<CR>",
        peek_location = "p",
      },
    },
  },
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
      layouts = {
        {
          elements = {
            {
              id = "scopes",
              size = 0.25,
            },
            {
              id = "breakpoints",
              size = 0.25,
            },
            {
              id = "stacks",
              size = 0.25,
            },
            {
              id = "watches",
              size = 0.25,
            },
          },
          position = "left",
          size = 5,
        },
        {
          elements = {
            {
              id = "repl",
              size = 0.4,
            },
            {
              id = "console",
              size = 0.6,
            },
          },
          position = "bottom",
          size = 10,
        },
      },
    },
  },
  {
    -- 使用gdb对c,cpp进行调试
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      require("dap").adapters["gdb"] = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }
      for _, lang in ipairs({ "c", "cpp" }) do
        dap.configurations[lang] = {
          {
            name = "Launch",
            type = "gdb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopAtBeginningOfMainSubprogram = false,
          },
        }
      end
    end,
  },
}
