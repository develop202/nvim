return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      {
        "mason-org/mason-lspconfig.nvim",
        config = function() end,
      },
    },
    opts = function()
      vim.diagnostic.config(vim.deepcopy({
        -- insert模式下显示诊断信息
        -- 更新太频繁
        -- update_in_insert = true,
        virtual_text = false,
        -- 悬浮窗显示来源
        float = {
          source = "always",
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = OwnUtil.icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = OwnUtil.icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = OwnUtil.icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = OwnUtil.icons.diagnostics.Info,
          },
        },
      }))

      return {
        servers = {
          gopls = OwnUtil.lang.gopls,
          marksman = {},
          markdown_ls = {},
          jdtls = {},
          lua_ls = OwnUtil.lang.lua_ls,
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
          clangd = OwnUtil.lang.clangd,

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
          yamlls = {},
          vtsls = OwnUtil.lang.vtsls,
          kotlin_lsp = {},
          taplo = {},
          gradle_ls = {
            cmd = { "python3", vim.fn.stdpath("config") .. "/scripts/gradle-language-server-stdio.py" },
          },
        },
        setup = {
          jdtls = function()
            return true
          end,
          kotlin_lsp = function()
            return true
          end,
          markdown_ls = function()
            return true
          end,
          -- Keep gradle_ls out of mason-lspconfig automatic enablement.
          gradle_ls = function(_, opts)
            vim.lsp.config("gradle_ls", opts)
            vim.lsp.enable("gradle_ls")
            return true
          end,
        },
      }
    end,
    config = function(_, opts)
      vim.lsp.config("*", {
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
      })

      -- get all the servers that are available through mason-lspconfig
      local mason_all = vim.tbl_keys(require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package) or {} --[[ @as string[] ]]
      local mason_exclude = {} ---@type string[]

      ---@return boolean? exclude automatic setup
      local function configure(server)
        if server == "*" then
          return false
        end
        local sopts = opts.servers[server]
        sopts = sopts == true and {} or (not sopts) and { enabled = false } or sopts

        if sopts.enabled == false then
          mason_exclude[#mason_exclude + 1] = server
          return
        end

        local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_all, server)
        local setup = opts.setup[server] or opts.setup["*"]
        if setup and setup(server, sopts) then
          mason_exclude[#mason_exclude + 1] = server
        else
          vim.lsp.config(server, sopts) -- configure the server
          if not use_mason then
            vim.lsp.enable(server)
          end
        end
        return use_mason
      end
      local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))

      -- :e刷新文件不显示inlay hints,这里强制全部开启
      if vim.fn.has("nvim-0.10") == 1 then
        vim.lsp.inlay_hint.enable()
        vim.lsp.codelens.enable()
      end

      require("mason-lspconfig").setup({
        ensure_installed = install,
        automatic_enable = { exclude = mason_exclude },
      })
    end,
    -- stylua: ignore
    keys = {
      { "<leader>cl", function() Snacks.picker.lsp_config() end, desc = "Lsp Info" },
      -- { "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
      -- { "gr", vim.lsp.buf.references, desc = "References", nowait = true },
      -- { "gi", vim.lsp.buf.implementation, desc = "Goto Implementation" },
      -- { "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
      { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
      { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
      { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help" },
      { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help" },
      { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "x" } },
      { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "x" } },
      { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode = { "n" } },
      { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },
      { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
      { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
      { "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, desc = "Next Reference" },
      { "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, desc = "Prev Reference" },

      -- lsp快捷键
      {"<leader>m",vim.diagnostic.open_float,desc = "显示诊断消息",mode={"n"}},
    },
  },

  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    dependencies = "ibhagwan/fzf-lua",
    keys = {
      { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
    },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = function()
      local ensure_installed = {
        -- python
        "basedpyright",
        "debugpy",
        "ruff",
        "isort",
        -- shell
        "bash-language-server",
        "shellcheck",
        "shfmt",
        --c/c+
        "clangd",
        "codelldb",
        --拼写检查
        "cspell",
        --前端其他
        "html-lsp",
        "css-lsp",
        "json-Lsp",
        "emmet-language-server",
        "prettier",
        "oxfmt",
        --前端语言相关
        "vtsls",
        "vue-language-server",
        "js-debug-adapter",
        -- Lua
        "lua-language-server",
        "stylua",
        --go
        "delve",
        "gofumpt",
        "goimports",
        "golangci-lint",
        "gopls",
        -- docker
        "docker-compose-language-service",
        "dockerfile-language-server",
        "hadolint",
        -- java
        "jdtls",
        "java-test",
        "java-debug-adapter",
        "vscode-java-dependency",
        "vscode-spring-boot-tools",
        "gradle-language-server",
        "groovy-language-server",
        "npm-groovy-lint",
        -- kotlin
        "kotlin-lsp",
        "ktlint",
        --http
        "kulala-fmt",
        -- "kulala-ls",
        -- xml
        "Lemminx",
        "emminx-maven",
        -- markdown
        "markdown-toc",
        "markdownlint-cli2",
        "marksman",
        "markdown-lsp",
        --php
        "php-cs-fixer",
        "php-debug-adapter",
        "phpactor",
        "phpcs",
        --sql
        "sqlfLuff",
        -- yaml
        "yaml-language-server",
        "yamlfmt",
        --nginx配置
        "nginx-config-formatter",
        -- toml
        "taplo",
        -- intellij-server
        "intellij-server",
      }
      local opts = {
        registries = {
          -- "file:~/project/Other/mason-registry",
          -- 自定义注册表
          "github:develop202/mason-registry",
          "github:mason-org/mason-registry",
        },
        ui = {
          -- 新版本不判断nil，会始终留边框距离
          border = "",
          -- 0.9最上面有个_，看着难受
          height = 0.8,
        },
        ensure_installed = ensure_installed,
      }
      if OwnUtil.sys.is_termux() then
        -- termux 边距相同
        opts.ui.width = OwnUtil.utils.termux_dash_width()

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
      end

      return opts
    end,
  },
}
