return {
  {
    "AlexandrosAlexiou/intellij-server.nvim",
    -- enabled = vim.g.intellij_java,
    ft = vim.g.intellij == true and { "java", "kotlin" } or "abcdef",
    dependencies = {
      "mfussenegger/nvim-dap",
      { "stevearc/oil.nvim", opts = {} },
    }, -- optional
    opts = function()
      local server_path = nil
      local server_java_home = nil
      local mason_registry = require("mason-registry")
      if mason_registry.is_installed("intellij-server") then
        local install_path = vim.fn.expand("$MASON/packages/intellij-server/intellij-server-*")

        if OwnUtil.sys.is_termux() then
          OwnUtil.utils.lsp.intellij_termux_adapted(install_path)

          vim.fn.setenv("LD_PRELOAD", "")
        end
        server_path = install_path .. "/bin/intellij-server"

        server_java_home = install_path .. "/jbr"
      end
      return {
        filetypes = { "java", "kotlin" },
        server_path = server_path,

        default_sdk = vim.env["$JAVA_17_HOME"] or nil,
        java_home = server_java_home,
        connection = { mode = "socket" },

        on_attach = function(client, bufnr)
          if not vim.g.spring_boot_ls_enabled then
            if require("spring_boot.util").has_spring_boot_dependency(client.root_dir) then
              vim.notify(client.name .. " attached buffer " .. bufnr)
              vim.lsp.enable("spring-boot")
              vim.g.spring_boot_ls_enabled = true
            end
          end
        end,
      }
    end,
    keys = vim.g.intellij == true and {
      -- =========================
      -- 运行 / 调试
      -- =========================
      {
        "<leader>jr",
        "<cmd>IntellijServerRun<cr>",
        desc = "IntelliJ: Run main class",
      },
      {
        "<leader>jR",
        "<cmd>IntellijServerRun!<cr>",
        desc = "IntelliJ: Debug main class",
      },

      -- =========================
      -- 单元测试
      -- =========================
      {
        "<leader>jtc",
        "<cmd>IntellijServerTest cursor<cr>",
        desc = "IntelliJ: Run test at cursor",
      },
      {
        "<leader>jtC",
        "<cmd>IntellijServerTest! cursor<cr>",
        desc = "IntelliJ: Debug test at cursor",
      },
      {
        "<leader>jtf",
        "<cmd>IntellijServerTest file<cr>",
        desc = "IntelliJ: Run tests in file",
      },
      {
        "<leader>jtF",
        "<cmd>IntellijServerTest! file<cr>",
        desc = "IntelliJ: Debug tests in file",
      },
      {
        "<leader>jtm",
        "<cmd>IntellijServerTest module<cr>",
        desc = "IntelliJ: Run tests in module",
      },
      {
        "<leader>jtM",
        "<cmd>IntellijServerTest! module<cr>",
        desc = "IntelliJ: Debug tests in module",
      },

      -- =========================
      -- 编辑 / 重构辅助
      -- =========================
      {
        "<leader>jf",
        "<cmd>IntellijServerFormat<cr>",
        desc = "IntelliJ: Format buffer",
      },
      {
        "<leader>jn",
        "<cmd>IntellijServerNewFile<cr>",
        desc = "IntelliJ: Create file from template",
      },
      {
        "<leader>jx",
        "<cmd>IntellijServerLibraries<cr>",
        desc = "IntelliJ: Browse external libraries",
      },

      -- =========================
      -- LSP 服务器管理
      -- =========================
      {
        "<leader>ji",
        "<cmd>IntellijServerStart<cr>",
        desc = "IntelliJ: Start server",
      },
      {
        "<leader>js",
        "<cmd>IntellijServerStop<cr>",
        desc = "IntelliJ: Stop server",
      },
      {
        "<leader>jS",
        "<cmd>IntellijServerRestart<cr>",
        desc = "IntelliJ: Restart server",
      },
      {
        "<leader>jC",
        "<cmd>IntellijServerClean<cr>",
        desc = "IntelliJ: Clean project caches",
      },
      {
        "<leader>jv",
        "<cmd>IntellijServerVersion<cr>",
        desc = "IntelliJ: Show server version",
      },

      -- =========================
      -- 日志 / 诊断
      -- =========================
      {
        "<leader>jB",
        "<cmd>IntellijServerBuildLog<cr>",
        desc = "IntelliJ: Open build log",
      },
      {
        "<leader>jL",
        "<cmd>IntellijServerLogs<cr>",
        desc = "IntelliJ: Open server and LSP logs",
      },

      -- =========================
      -- 调试器 / 许可证
      -- =========================
      {
        "<leader>ja",
        "<cmd>IntellijServerAttach<cr>",
        desc = "IntelliJ: Attach debugger (5005)",
      },
      {
        "<leader>jA",
        "<cmd>IntellijServerLicense<cr>",
        desc = "IntelliJ: Show license status",
      },
    } or {},
  },
  {
    "JetBrains/intellij-lsp.nvim",
    ft = vim.g.intellij == "official" and { "java", "kotlin" } or "abcdef",
    dependencies = { "mfussenegger/nvim-dap" }, -- optional: run and debug
    opts = function()
      local server_path = nil
      local mason_registry = require("mason-registry")
      if mason_registry.is_installed("intellij-server") then
        local install_path = vim.fn.expand("$MASON/packages/intellij-server/intellij-server-*")

        if OwnUtil.sys.is_termux() then
          OwnUtil.utils.lsp.intellij_termux_adapted(install_path)

          vim.fn.setenv("LD_PRELOAD", "")
        end
        server_path = install_path .. "/bin/intellij-server"
      end
      return {
        server_download = false,

        autotrigger = false, -- open the completion menu on "."
        word_triggers = false,

        accept_eula = true, -- read EULA.txt in the downloaded bundle first
        single_key_select = false,

        keymaps = false,
        rename_files = true,

        server_path = server_path, -- use your own bundle instead of downloading
        default_sdk = vim.env["$JAVA_17_HOME"] or nil, -- JDK for projects that do not configure their own

        on_attach = function(client, bufnr)
          if not vim.g.spring_boot_ls_enabled then
            if require("spring_boot.util").has_spring_boot_dependency(client.root_dir) then
              vim.notify(client.name .. " attached buffer " .. bufnr)
              vim.lsp.enable("spring-boot")
              vim.g.spring_boot_ls_enabled = true
            end
          end
        end,
      }
    end,
    keys = vim.g.intellij == "official" and {
      -- =========================
      -- 运行 / 调试
      -- =========================
      {
        "<leader>jr",
        "<cmd>IntellijLspRun<cr>",
        desc = "IntelliJ: Run main class",
      },
      {
        "<leader>jR",
        function()
          require("intellij-lsp.run").run_at_cursor(false)
        end,
        desc = "IntelliJ: Debug main class",
      },
      {
        "<leader>j0",
        "<cmd>IntellijLspRun!<cr>",
        desc = "IntelliJ: Run without building",
      },

      -- =========================
      -- 格式化 / 文件模板
      -- =========================
      {
        "<leader>jf",
        "<cmd>IntellijLspFormat<cr>",
        desc = "IntelliJ: Format buffer",
      },
      {
        "<leader>jn",
        "<cmd>IntellijLspFileTemplate<cr>",
        desc = "IntelliJ: Create file from template",
      },

      -- =========================
      -- 服务器 / 项目管理
      -- =========================
      {
        "<leader>ji",
        "<cmd>IntellijLspReload<cr>",
        desc = "IntelliJ: Reload server configuration",
      },
      {
        "<leader>js",
        "<cmd>IntellijLspRunStop<cr>",
        desc = "IntelliJ: Stop running program or build",
      },
      {
        "<leader>jS",
        "<cmd>IntellijLspRestart<cr>",
        desc = "IntelliJ: Restart language server",
      },
      {
        "<leader>jC",
        "<cmd>IntellijLspClearCache<cr>",
        desc = "IntelliJ: Clear index cache and restart",
      },
      {
        "<leader>jA",
        "<cmd>IntellijLspLicense<cr>",
        desc = "IntelliJ: License management",
      },

      -- =========================
      -- 构建输出 / 编译错误
      -- =========================
      {
        "<leader>jB",
        "<cmd>IntellijLspOutput<cr>",
        desc = "IntelliJ: Open build and run output",
      },
      {
        "<leader>jE",
        "<cmd>IntellijLspCompilationErrors<cr>",
        desc = "IntelliJ: Show compiler errors",
      },

      -- =========================
      -- 类型层级 / 调用层级
      -- =========================
      {
        "<leader>jh",
        "<cmd>IntellijLspTypeHierarchy subtypes<cr>",
        desc = "IntelliJ: Show subtypes",
      },
      {
        "<leader>jH",
        "<cmd>IntellijLspTypeHierarchy supertypes<cr>",
        desc = "IntelliJ: Show supertypes",
      },
      {
        "<leader>jI",
        "<cmd>IntellijLspCallHierarchy incoming<cr>",
        desc = "IntelliJ: Show incoming calls",
      },
      {
        "<leader>jO",
        "<cmd>IntellijLspCallHierarchy outgoing<cr>",
        desc = "IntelliJ: Show outgoing calls",
      },

      -- =========================
      -- 工作区
      -- =========================
      {
        "<leader>jw",
        "<cmd>IntellijLspSymbols<cr>",
        desc = "IntelliJ: Search workspace symbols",
      },
      {
        "<leader>jX",
        "<cmd>IntellijLspExportWorkspace<cr>",
        desc = "IntelliJ: Export workspace model",
      },

      -- =========================
      -- Git
      -- =========================
      {
        "<leader>jg",
        "<cmd>IntellijGitStatus<cr>",
        desc = "IntelliJ: Git status",
      },
      {
        "<leader>jd",
        "<cmd>IntellijGitDiff<cr>",
        desc = "IntelliJ: Git diff",
      },
      {
        "<leader>jG",
        "<cmd>IntellijGitLog<cr>",
        desc = "IntelliJ: Git log",
      },
      {
        "<leader>jb",
        "<cmd>IntellijGitBranches<cr>",
        desc = "IntelliJ: Git branches",
      },

      -- =========================
      -- 健康检查
      -- =========================
      {
        "<leader>j?",
        "<cmd>checkhealth intellij-lsp<cr>",
        desc = "IntelliJ: Check health",
      },
    } or {},
  },
}
