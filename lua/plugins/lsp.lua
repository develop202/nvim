return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "williamboman/mason.nvim",
        optional = true,
        opts = function(_, opts)
          vim.list_extend(opts.ensure_installed, {
            "bash-language-server",
            "css-lsp",
            "cspell",
            "emmet-language-server",
            "html-lsp",
            "lemminx",
            "prettier",
            "shellcheck",
            "yamlfmt",
            -- 对Python导入包进行排序
            "isort",
          })
        end,
      },
    },
    opts = {
      -- document_highlight = { enabled = false },
      diagnostics = {
        -- insert模式下显示诊断信息
        -- 更新太频繁
        -- update_in_insert = true,
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
        ["markdown"] = { "cspell", "markdownlint-cli2" },
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
}
