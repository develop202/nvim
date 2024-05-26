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
            "black",
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
            "pyright",
            "shellcheck",
            "sql-formatter",
            "sqlls",
            "typescript-language-server",
            "vue-language-server",
            -- "yaml-language-server",
            "yamlfmt",
            -- "flake8",
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
      {
        "j-hui/fidget.nvim",
        tag = "legacy",
      },

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
      diagnostics = {
        virtual_text = false,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      },
      servers = {
        lua_ls = {
          settings = {
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = {
                "vim",
                "require",
              },
            },
          },
        },

        volar = {
          init_options = {
            typescript = {
              tsdk = os.getenv("HOME")
                .. "/.local/share/nvim/mason/packages/typescript-language-server/node_modules/typescript/lib/",
            },
          },
          filetypes = {
            "vue",
          },
        },

        tsserver = {
          init_options = {
            plugins = {
              {
                name = "@vue/typescript-plugin",
                location = "/data/data/com.termux/files/usr/lib/node_modules/@vue/typescript-plugin/",
                languages = { "javascript", "typescript", "vue" },
              },
            },
          },
          filetypes = {
            "vue",
            "typescript",
            "javascript",
          },
        },
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
      table.remove(opts.ensure_installed, 22)
    end,
  },
}
