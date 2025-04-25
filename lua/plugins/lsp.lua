local kulala_ls_cmd = { "kulala-ls", "--stdio" }
if OwnUtil.sys.is_termux() then
  table.insert(kulala_ls_cmd, 1, "nasl")
end
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "williamboman/mason.nvim",
        optional = true,
        opts = function(_, opts)
          if OwnUtil.sys.is_termux() then
            local mason_registry = require("mason-registry")
            -- termux上部分lsp不能直接安装，需要在本地安装后链接过去
            -- ruff 编译过慢
            OwnUtil.utils.termux_use_local_lsp(mason_registry, "ruff")
            -- clangd 不支持termux
            OwnUtil.utils.termux_use_local_lsp(mason_registry, "clangd")
            -- codelldb 不支持termux
            if not mason_registry.is_installed("codelldb") then
              -- 创建lsp目录
              vim.cmd("!mkdir -p " .. vim.fn.stdpath("data") .. "/mason/packages/codelldb")
              vim.notify("codelldb无法安装，仅提示操作成功！")
            end
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
            "spring-boot-tools",
            "java-project-manager",
            "lemminx",
            "lemminx-maven",
            "kulala-fmt",
            "kulala-ls",
          })

          opts.registries = {
            -- 自定义注册表
            "github:develop202/mason-registry",
            "github:mason-org/mason-registry",
          }
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
        volar = {
          handlers = {
            -- NOTE: 多个lsp请求inlay hints异常,推测nvim的问题，后续可能会修复
            -- 与vtsls的inlay hints存在冲突,故暂停
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
        marksman = function()
          return OwnUtil.sys.is_termux()
        end,
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
      },
      formatters = {
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
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "scss",
        "dart",
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
