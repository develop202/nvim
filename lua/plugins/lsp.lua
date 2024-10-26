return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = {
          ensure_installed = {
            "stylua",
            "shfmt",
            "bash-language-server",
            "clangd",
            "css-lsp",
            "cspell",
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
            -- 使用vtsls代替typescript-language-server
            "vtsls",
            "vue-language-server",
            "yamlfmt",
            -- ruff格式化Python更快
            "ruff",
            -- 对Python导入包进行排序
            "isort",
          },
        },
      },
    },
    opts = {
      -- document_highlight = { enabled = false },
      diagnostics = {
        -- insert模式下显示诊断信息
        update_in_insert = true,
        virtual_text = false,
        -- 悬浮窗显示来源
        float = {
          source = "always",
        },
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
          settings = {
            Lua = {
              hint = {
                paramName = "All",
              },
            },
          },
        },
      },
      setup = {
        -- jdtls = function()
        --   return true
        -- end,
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        -- ["*"] = { "prettier" },
        ["yaml"] = { "yamlfmt" },
        ["sh"] = { "shfmt" },
        ["sql"] = { "sqlfluff" },
        ["mysql"] = { "sqlfluff" },
        ["python"] = { "ruff_format", "isort" },
        ["lua"] = { "stylua" },
        ["luau"] = { "stylua" },
        ["html"] = { "prettier" },
        ["http"] = { "kulala" },
      },
      formatters = {
        -- .http格式化工具
        kulala = {
          command = "kulala-fmt",
          args = { "$FILENAME" },
          stdin = false,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = {
        -- 拼写检查
        ["markdown"] = { "cspell" },
      }
      return opts
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- 关闭指定文件缩进
      opts.indent.disable = { "xml" }
      table.insert(opts.ensure_installed, { "scss" })
    end,
  },
  {
    "RRethy/vim-illuminate",
    ft = "vue",
    config = function()
      require("illuminate").configure({
        filetypes_denylist = {},
        filetypes_allowlist = { "vue" },
      })
    end,
  },
}
