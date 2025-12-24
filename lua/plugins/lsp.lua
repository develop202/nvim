local kulala_ls_cmd = { "kulala-ls", "--stdio" }
if OwnUtil.sys.is_termux() then
  table.insert(kulala_ls_cmd, 1, "nasl")
end
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "mason-org/mason.nvim",
        optional = true,
        opts = function(_, opts)
          if OwnUtil.sys.is_termux() then
            local mason_registry = require("mason-registry")
            -- termux上部分lsp不能直接安装，需要在本地安装后链接过去
            -- ruff 编译过慢
            OwnUtil.utils.termux_use_local_lsp(mason_registry, "ruff")
            -- clangd 不支持termux
            OwnUtil.utils.termux_use_local_lsp(mason_registry, "clangd")
            -- marksman 不支持termux
            OwnUtil.utils.termux_use_local_lsp(mason_registry, "marksman")
            -- lua-language-server编译失败，没搞懂，不过termux有佬编译好了
            OwnUtil.utils.termux_use_local_lsp(mason_registry, "lua-language-server")
            -- codelldb 不支持termux
            if not mason_registry.is_installed("codelldb") then
              -- 创建lsp目录
              vim.cmd("!mkdir -p " .. vim.fn.stdpath("data") .. "/mason/packages/codelldb")
              vim.notify("codelldb无法安装，仅提示操作成功！")
            end
            opts.ui = {
              -- 新版本不判断nil，会始终留边框距离
              border = "",
              -- termux 边距相同
              width = OwnUtil.utils.termux_dash_width(),
              -- 0.9最上面有个_，看着难受
              height = 0.8,
            }
          end
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
            "gradle-language-server",
            "npm-groovy-lint",
            "groovy-language-server",
            "vscode-spring-boot-tools",
            "vscode-java-dependency",
            "lemminx",
            "lemminx-maven",
            "kulala-fmt",
            "kulala-ls",
            "nginx-config-formatter",
            "lua-language-server",
            "basedpyright",
            "debugpy",
          })

          opts.registries = {
            -- 自定义注册表
            "github:develop202/mason-registry",
            "github:mason-org/mason-registry",
          }
        end,
      },
      {
        "mason-org/mason-lspconfig.nvim",
        event = "LazyFile",
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
        kulala_ls = {
          cmd = kulala_ls_cmd,
        },
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                -- basedpyright检查模式:常规
                typeCheckingMode = "standard",
              },
            },
          },
        },
        emmet_language_server = {
          filetypes = {
            "eruby",
            "html",
            "htmldjango",
            "javascriptreact",
            "pug",
            "typescriptreact",
            "htmlangular",
          },
        },
        vue_ls = {
          handlers = {
            -- NOTE: 多个lsp请求inlayHints异常
            ["textDocument/inlayHint"] = function()
              return nil
            end,
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
        ["python"] = { "ruff_format", "isort" },
        ["lua"] = { "stylua" },
        ["luau"] = { "stylua" },
        ["html"] = { "prettier" },
        ["http"] = { "kulala" },
        ["groovy"] = { "npmGroovyLint" },
        ["nginx"] = { "nginxfmt" },
      },
      formatters = {
        npmGroovyLint = {
          command = "npm-groovy-lint",
          args = { "-c", vim.fn.stdpath("config") .. "/after/ftplugin/groovy/lint.json", "--format", "$FILENAME" },
          exit_codes = { 0, 1 },
          stdin = false,
        },
        -- .http格式化工具
        kulala = {
          command = "kulala-fmt",
          args = { "format", "$FILENAME" },
          stdin = false,
        },
        sqlfluff = {
          -- 将方言改为mysql
          args = { "format", "--dialect=mysql", "-" },
        },
        php_cs_fixer = {
          args = {
            "fix",
            "$FILENAME",
            -- 缩进两个空格
            "--config="
              .. vim.fn.stdpath("config")
              .. "/after/ftplugin/php/phpCsFixerConfig.php",
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        --拼写检查
        markdown = { "cspell", "markdownlint-cli2" },
      },
      linters = {
        sqlfluff = {
          args = {
            "lint",
            "--format=json",
            -- 将方言改为mysql
            "--dialect=mysql",
          },
        },
        phpcs = {
          args = {
            -- 切换诊断宽松的规则
            "--standard=PSR1",
            -- "--exclude=PEAR.Commenting.ClassComment"
            "-q",
            "--report=json",
            function()
              return "--stdin-path=" .. vim.fn.expand("%:p:.")
            end,
            "-", -- need `-` at the end for stdin support
          },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "scss",
        "dart",
        "groovy",
      },
      indent = {
        -- 关闭指定文件缩进
        disable = {
          "xml",
        },
      },
    },
  },
}
