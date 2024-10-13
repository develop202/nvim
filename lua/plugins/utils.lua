return {
  {
    "rhysd/accelerated-jk",
    keys = {
      {
        "j",
        "<Plug>(accelerated_jk_gj)",
      },
      {
        "k",
        "<Plug>(accelerated_jk_gk)",
      },
    },
  },
  {
    -- 需要开启，关闭后不知道为什么HTML，xml双标签缩进有问题
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    -- opts = {
    --   enable_check_bracket_line = false,
    -- },
    config = true,
  },
  {
    "farmergreg/vim-lastplace",
    event = "LazyFile",
  },
  {
    "ellisonleao/glow.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          ["z"] = "none",
          -- ["zo"] = neotree_zo,
          ["<tab>"] = function(states)
            local renderer = require("neo-tree.ui.renderer")

            -- Expand a node and load filesystem info if needed.
            local function open_dir(state, dir_node)
              local fs = require("neo-tree.sources.filesystem")
              fs.toggle_directory(state, dir_node, nil, true, false)
            end

            -- Expand a node and all its children, optionally stopping at max_depth.
            local function recursive_open(state, node, max_depth)
              local max_depth_reached = 1
              local stack = {
                node,
              }
              while next(stack) ~= nil do
                node = table.remove(stack)
                if node.type == "directory" and not node:is_expanded() then
                  open_dir(state, node)
                end

                local depth = node:get_depth()
                max_depth_reached = math.max(depth, max_depth_reached)

                if not max_depth or depth < max_depth - 1 then
                  local children = state.tree:get_nodes(node:get_id())
                  for _, v in ipairs(children) do
                    table.insert(stack, v)
                  end
                end
              end

              return max_depth_reached
            end

            --- Open the fold under the cursor, recursing if count is given.
            local function neotree_zo(state, open_all)
              local node = state.tree:get_node()

              if open_all then
                recursive_open(state, node)
              else
                recursive_open(state, node, node:get_depth() + vim.v.count1)
              end

              renderer.redraw(state)
            end

            --- Recursively open the current folder and all folders it contains.
            local function neotree_zO(state)
              neotree_zo(state, true)
            end
            neotree_zO(states)
          end,
        },
      },
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
  -- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
  {
    "numToStr/Comment.nvim",
    event = "LazyFile",
    opts = {
      -- add any options here
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
