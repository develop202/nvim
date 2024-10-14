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
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- opts.ensure_installed = "all"
      opts.indent.enable = false
      -- vim.list_extend(opts, { autotag = { enable = false } })
      -- 删除treesitter-xml，安装后编辑xml会出现indent缩进异常
      -- 但是删除后没有很好的高亮显示，颜色单一
      -- table.remove(opts.ensure_installed, 22)
      table.insert(opts.ensure_installed, { "scss" })
    end,
  },
  {
    "RRethy/vim-illuminate",
    -- vue文件的高亮显示有时会时亮时不亮
    ft = "vue",
    config = function()
      require("illuminate").configure({
        filetypes_denylist = {},
        filetypes_allowlist = { "vue" },
      })
    end,
  },
}
