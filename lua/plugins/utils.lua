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
    "folke/persistence.nvim",
    keys = {
      {
        "<leader>qs",
        [[<cmd>lua require("persistence").load()<cr>]],
        desc = "加载工作区",
      },
      {
        "<leader>ql",
        [[<cmd>lua require("persistence").load({ last = true})<cr>]],
        desc = "加载上次工作区",
      },
      {
        "<leader>qd",
        [[<cmd>lua require("persistence").stop()<cr>]],
        desc = "停止工作区",
      },
    },
    -- config = true,
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
  -- 快速回到文件关闭前的位置,已经不再维护
  -- {
  --   "ethanholz/nvim-lastplace",
  --   config = true,
  -- },
  {
    "farmergreg/vim-lastplace",
    event = "LazyFile",
  },
  -- {
  --   "ggandor/leap.nvim",
  --   enabled = false
  -- },
  {
    "folke/flash.nvim",
    enabled = true,
    keys = {
      {
        "s",
        mode = {
          "n",
          "x",
          "o",
        },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "SS",
        mode = {
          "n",
          "o",
          "x",
        },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = {
          "o",
          "x",
        },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Flash Treesitter Search",
      },
      {
        "<c-s>",
        mode = {
          "c",
        },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
    -- config = true,
  },
  -- 拼写检查插件，很长时间没更新了
  -- {
  --   "kamykn/spelunker.vim",
  --   event = "VeryLazy",
  --   config = function()
  --     vim.g.spelunker_check_type = 2
  --   end,
  -- },
  {
    "ellisonleao/glow.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    -- dependencies = {
    --   "nvim-lua/plenary.nvim",
    --   "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    --   "MunifTanjim/nui.nvim",
    -- },
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
    -- event = {
    --   "BufReadPost",
    --   "BufNewFile",
    -- },
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
        ["python"] = { "black" },
        ["lua"] = { "stylua" },
        ["luau"] = { "stylua" },
      },
      formatters = {
        sql_formatter = {
          exe = "sql-formatter",
          stdin = true,
          -- args = { "-l", "sql" },
        },
      },
    },
  },
  -- {
  --   "lvimuser/lsp-inlayhints.nvim",
  --   event = 'LspAttach',
  --   config = function()
  --     require("lsp-inlayhints").setup()
  --     vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
  --     vim.api.nvim_create_autocmd("LspAttach", {
  --       group = "LspAttach_inlayhints",
  --       callback = function(args)
  --         if not (args.data and args.data.client_id) then
  --           return
  --         end
  --
  --         local bufnr = args.buf
  --         local client = vim.lsp.get_client_by_id(args.data.client_id)
  --         require("lsp-inlayhints").on_attach(client, bufnr)
  --       end,
  --     })
  --   end
  -- },
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
}
