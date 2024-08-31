return {
  {
    "neovim/nvim-lspconfig",
    -- event = {
    --   "BufReadPost",
    --   "BufNewFile",
    -- },
    -- init = function()
    --   local keys = require("lazyvim.plugins.lsp.keymaps").get()
    --   keys[#keys + 1] = { "gi", require("telescope.builtin").lsp_implementations }
    -- end,
    dependencies = {
      {
        "williamboman/mason.nvim",
        cmd = {
          "Mason",
        },
        opts = {
          ensure_installed = {
            "stylua",
            "shfmt",
            "bash-language-server",
            -- "beautysh",
            -- "black",
            "clangd",
            "css-lsp",
            "debugpy",
            "emmet-language-server",
            "html-lsp",
            "java-debug-adapter",
            "java-test",
            "jdtls",
            "js-debug-adapter",
            "json-lsp",
            "lemminx",
            "lua-language-server",
            "markdownlint",
            "marksman",
            "prettier",
            "basedpyright",
            "shellcheck",
            "sql-formatter",
            "sqlls",
            -- 使用vtsls代替typescript-language-server
            -- "typescript-language-server",
            "vtsls",
            "vue-language-server",
            -- "yaml-language-server",
            "yamlfmt",
            -- "flake8",
            -- ruff格式化Python更快
            "ruff",
            -- 对Python导入包进行排序
            "isort",
          },
        },
      },
      "williamboman/mason-lspconfig",
      -- {
      --   "folke/neoconf.nvim",
      --   cmd = {
      --     "Neoconf",
      --   },
      -- },
      -- "folke/neodev.nvim",
      -- {
      --   "j-hui/fidget.nvim",
      --   -- tag = "legacy",
      --   opts = {
      --     -- options
      --   },
      -- },

      -- {
      --   "nvimdev/lspsaga.nvim",
      --   event = "LspAttach",
      --   config = function()
      --     require("lspsaga").setup()
      --   end,
      -- },

      -- "lvimuser/lsp-inlayhints.nvim",
      -- "simrat39/symbols-outline.nvim",
    },
    opts = {
      -- document_highlight = { enabled = false },
      diagnostics = {
        virtual_text = false,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      },
      servers = {
        lua_ls = {
          -- settings = {
          --   diagnostics = {
          --     -- Get the language server to recognize the `vim` global
          --     globals = {
          --       "vim",
          --       "require",
          --     },
          --   },
          -- },
          settings = {
            Lua = {
              hint = {
                paramName = "All",
              },
            },
          },
        },
        -- sqlls = {
        --   sqlLanguageServer = {
        --     lint = {
        --       rules = {
        --         align_column_to_the_first = "off",
        --         column_new_line = "error",
        --         linebreak_after_clause_keyword = "error",
        --         reserved_word_case = "warn",
        --         space_surrounding_operators = "error",
        --         where_clause_new_line = "error",
        --         align_where_clause_to_the_first = "error",
        --       },
        --     },
        --   },
        -- },
      },
      setup = {
        jdtls = function()
          return true
        end,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- opts.ensure_installed = "all"
      opts.indent.enable = false
      -- vim.list_extend(opts, { autotag = { enable = false } })
      -- 删除treesitter-xml，安装后编辑xml会出现indent缩进异常
      -- 但是删除后没有很好的高亮显示，颜色单一
      -- table.remove(opts.ensure_installed, 22)
      table.insert(opts.ensure_installed, { "sql", "c", "cpp", "css", "scss" })
    end,
  },
  {
    "RRethy/vim-illuminate",
    -- vue文件的高亮显示有时会时亮时不亮
    ft = "vue",
  },
}
