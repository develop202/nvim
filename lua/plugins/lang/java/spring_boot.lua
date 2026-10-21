return {
  {
    "JavaHello/spring-boot.nvim",
    ft = "java",
    opts = function()
      if not require("spring_boot.util").has_spring_boot_dependency(vim.fn.getcwd()) then
        -- spring-boot.nvim使用环境变量获取路径
        -- 这里强制获取失败以停止spring-boot-ls的启动
        vim.env["VSCODE_EXTENSIONS"] = "手动关闭"
        return
      end
      -- 默认为vscode插件
      local ls_path = require("spring_boot.vscode").find_one("/language-server")

      local mason_registry = require("mason-registry")
      -- 判断mason是否安装了spring-boot
      if mason_registry.is_installed("vscode-spring-boot-tools") then
        ls_path = vim.fn.expand("$MASON/packages/vscode-spring-boot-tools/extension/language-server")
      elseif ls_path == "" or ls_path == nil then
        vim.env["VSCODE_EXTENSIONS"] = "手动关闭"
        return
      end

      local server_jar = vim.split(vim.fn.glob(ls_path .. "/spring-boot-language-server*.jar"), "\n")
      if #server_jar == 0 then
        vim.notify("Spring Boot LS jar not found", vim.log.levels.WARN)
        return
      end

      local log_file = vim.fn.stdpath("cache")
        .. "/jdtls/"
        .. vim.fs.basename(vim.fs.root(vim.fn.getcwd(), OwnUtil.lang.java.root_markers))
        .. "/spring_boot/log.txt"

      local GC_type = "-XX:+UseZGC"
      if OwnUtil.sys.is_termux() then
        -- termux不支持ZGC
        GC_type = "-XX:+UseG1GC"
      end

      local java_bin = OwnUtil.utils.cmd.java_bin(21)

      local cmd = {
        java_bin,
        "-XX:TieredStopAtLevel=1",
        "-Xms64M",
        "-Xmx64M",
        GC_type,
        "-Dspring.config.location=classpath:/application.properties",
        "-Djdk.util.zip.disableZip64ExtraFieldValidation=true",
        "-Dspring.main.web-application-type=NONE",
        "-Xlog:jni+resolve=off",
        "-Dsts.lsp.client=vscode",
        "-Dsts.log.file=" .. log_file,
        "-Dspring.profiles.active=file-logging",
        "-Dlogging.file.name=" .. log_file,
        "-Dlogging.level.root=warn",
        "-jar",
        server_jar[1],
      }

      local jdtls_name = "jdtls"
      if vim.g.intellij == true then
        jdtls_name = "intellij-server"
      elseif vim.g.intellij == "official" then
        jdtls_name = "intellij"
      end

      return {
        jdtls_name = jdtls_name,
        server = {
          cmd = cmd,
          handlers = {
            -- NOTE: 多个lsp请求inlayHints异常
            ["textDocument/inlayHint"] = function()
              return nil
            end,
          },
        },
        ls_path = ls_path,
        project_filter = function(root_dir)
          return require("spring_boot.util").has_spring_boot_dependency(root_dir)
        end,
        auto_enable = not vim.g.intellij and true or false,
      }
    end,
  },
  {
    "jkeresman01/spring-initializr.nvim",
    cmd = { "SpringInitializr", "SpringGenerateProject" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",

      {
        "nvim-telescope/telescope.nvim",
        cmd = "SpringInitializr",
        opts = {
          defaults = {
            -- 将文件名提到开头，路径颜色变暗
            path_display = {
              filename_first = {
                reverse_directories = false,
              },
            },
            -- 显示右侧预览，不过在手机上很窄，不美观
            -- layout_strategy = "horizontal",
            -- layout_config = {
            --   width = 0.8,
            --   preview_cutoff = 1,
            -- },
            layout_strategy = "vertical",
            layout_config = {
              vertical = {
                preview_cutoff = 20,
                preview_height = 0.6,
                -- mirror = true,
              },
              -- height = { padding = 0 },
              -- width = { padding = 0 },
            },
          },
          -- 预览和搜索结果上下分布，看着有些怪，但是搜索结果显示完整一些
          -- pickers = {
          --   find_files = {
          --     theme = "dropdown",
          --   },
          -- },
        },
      },
    },
    config = function()
      vim.g.spring_initializr_log_file = true
      -- vim.g.spring_initializr_log_level = "trace"
      require("spring-initializr").setup()
    end,
    keys = {

      {
        "<leader>si",
        "<cmd>SpringInitializr<cr>",
        desc = "[S]pring [I]nitializr (spring initializr)",
      },
      {
        "<leader>sp",
        "<cmd>SpringGenerateProject<cr>",
        desc = "[S]pring Generate [P]roject (spring initializr)",
      },
      {
        "<leader>ad",
        function()
          require("spring-initializr.telescope.telescope").pick_dependencies(
            {},
            require("spring-initializr.ui.components.dependencies.dependencies_display").update_display
          )
        end,
        desc = "[A]dd [D]ependency (spring initializr)",
      },
    },
  },
}
