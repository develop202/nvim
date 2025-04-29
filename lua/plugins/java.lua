local HOME = os.getenv("HOME")

local GC_type = "-XX:+UseZGC"
if OwnUtil.sys.is_termux() then
  -- termux不支持ZGC
  GC_type = "-XX:+UseG1GC"
end

local java_bin = OwnUtil.utils.cmd.java_bin()

return {
  -- Set up nvim-jdtls to attach to java files.
  {
    "mfussenegger/nvim-jdtls",
    -- jdtls要求最低Java21
    -- 需要配置JAVA21_HOME环境变量
    opts = function(_, opts)
      local mason_registry = require("mason-registry")

      local jdtls_config = {}
      local bundles = {}

      -- 开启inlay_hint
      local inlay_hint_enabled = "all"

      -- 添加dap扩展jar包
      if LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
        local java_dbg_pkg = mason_registry.get_package("java-debug-adapter")
        local java_dbg_path = java_dbg_pkg:get_install_path()
        local jar_patterns = {
          java_dbg_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
        }

        -- 添加test扩展jar包
        -- java-test also depends on java-debug-adapter.
        if mason_registry.is_installed("java-test") then
          local java_test_pkg = mason_registry.get_package("java-test")
          local java_test_path = java_test_pkg:get_install_path()
          vim.list_extend(jar_patterns, {
            java_test_path .. "/extension/server/*.jar",
          })
        end

        -- 添加到bundles
        for _, jar_pattern in ipairs(jar_patterns) do
          for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
            table.insert(bundles, bundle)
          end
        end
      end

      -- 添加spring-boot jdtls扩展jar包
      if require("jdtls.setup").find_root({ ".git/", "mvnw", "gradlew" }) then
        if mason_registry.is_installed("spring-boot-tools") then
          local spring_boot_pkg = mason_registry.get_package("spring-boot-tools")
          local jars = spring_boot_pkg:get_install_path() .. "/extension/jars/*.jar"
          -- 添加jars目录下所有的jar文件
          local bundle = vim.split(vim.fn.glob(jars), "\n")
          vim.list_extend(bundles, bundle)
        end
      end

      -- 添加Java-dep
      local java_dependency_path = nil
      local java_dependency_bundle = nil
      local path_prefix = ""
      -- 是否在mason安装
      if mason_registry.is_installed("java-project-manager") then
        local java_project_manager = mason_registry.get_package("java-project-manager"):get_install_path()
        java_dependency_path = java_project_manager
      else
        -- 默认使用vscode插件
        if (vim.uv or vim.loop).fs_stat(HOME .. "/.vscode/extensions") then
          java_dependency_path = HOME .. "/.vscode/extensions"
        end
        -- 使用code-server
        if (vim.uv or vim.loop).fs_stat(HOME .. "/.local/share/code-server/") then
          java_dependency_path = HOME .. "/.local/share/code-server/extensions"
        end
        path_prefix = "/vscjava.vscode-java-dependency-*/server"
      end

      if java_dependency_path then
        java_dependency_bundle =
          vim.split(vim.fn.glob(java_dependency_path .. path_prefix .. "/com.microsoft.jdtls.ext.core-*.jar"), "\n")
      end
      if java_dependency_bundle then
        if java_dependency_bundle[1] ~= "" then
          vim.list_extend(bundles, java_dependency_bundle)
        end
      end

      local jdtls = require("jdtls")

      -- 在Java-deps显示JavaSE版本
      local extendedClientCapabilities = jdtls.extendedClientCapabilities
      extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
      extendedClientCapabilities.progressReportProvider = false

      jdtls_config["init_options"] = {
        bundles = bundles,
        extendedClientCapabilities = extendedClientCapabilities,
      }

      ---@diagnostic disable-next-line: unused-local
      jdtls_config["on_attach"] = function(client, buffer)
        -- 添加命令
        local create_command = vim.api.nvim_buf_create_user_command
        create_command(buffer, "JavaProjects", require("java-deps").toggle_outline, {
          nargs = 0,
        })
      end

      opts.root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" })
          and function()
            return require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" })
          end
        ---@diagnostic disable-next-line: undefined-field
        or LazyVim.lsp.get_raw_config("jdtls").default_config.root_dir

      local function get_config_file()
        local sys = OwnUtil.sys
        if sys.is_linux() then
          return "/config_linux"
        elseif sys.is_macos() then
          return "/config_mac"
        elseif sys.is_windows() then
          return "/config_win"
        end
        error("未知系统")
      end
      -- jdtls目录
      local base_dir = mason_registry.get_package("jdtls"):get_install_path()
      local project_name = opts.project_name(opts.root_dir())
      -- 自定义启动命令
      local cmd = {
        java_bin,
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dosgi.checkConfiguration=true",
        "-Dosgi.sharedConfiguration.area=" .. base_dir .. get_config_file(),
        "-Dosgi.sharedConfiguration.area.readOnly=true",
        "-Dosgi.configuration.cascaded=true",
        "-Xms256M",
        "-Xmx256M",
        GC_type,
        "--enable-native-access=ALL-UNNAMED",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
      }

      -- lombok
      if mason_registry.is_installed("jdtls") then
        local lombok_jar = mason_registry.get_package("jdtls"):get_install_path() .. "/lombok.jar"
        table.insert(cmd, string.format("-javaagent:%s", lombok_jar))
      end

      table.insert(cmd, "-jar")
      table.insert(cmd, vim.fn.glob(base_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar"))
      table.insert(cmd, "-configuration")
      table.insert(cmd, opts.jdtls_config_dir(project_name))
      table.insert(cmd, "-data")
      table.insert(cmd, opts.jdtls_workspace_dir(project_name))
      opts.cmd = cmd

      opts.jdtls = jdtls_config
      opts.settings = {
        java = {
          configuration = {
            maven = {
              -- 将settings.xml复制到.m2目录下即可生效
              userSettings = HOME .. "/.m2/settings.xml",
              globalSettings = HOME .. "/.m2/settings.xml",
            },
          },
          inlayHints = {
            parameterNames = {
              enabled = inlay_hint_enabled,
            },
          },
        },
      }
    end,
  },
  {
    "JavaHello/spring-boot.nvim",
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-jdtls",
    },
    opts = function()
      if not require("jdtls.setup").find_root({ ".git/", "mvnw", "gradlew" }) then
        -- spring-boot.nvim使用环境变量获取路径
        -- 这里强制获取失败以停止spring-boot-ls的启动
        vim.env["VSCODE_EXTENSIONS"] = "手动关闭"
        return
      end
      -- 默认为vscode插件
      local ls_path = require("spring_boot.vscode").find_one("/language-server")

      local mason_registry = require("mason-registry")
      -- 判断mason是否安装了spring-boot
      if mason_registry.is_installed("spring-boot-tools") then
        local spring_boot_pkg = mason_registry.get_package("spring-boot-tools")
        ls_path = spring_boot_pkg:get_install_path() .. "/extension/language-server"
      else
        vim.env["VSCODE_EXTENSIONS"] = "手动关闭"
        return
      end

      local server_jar = vim.split(vim.fn.glob(ls_path .. "/spring-boot-language-server*.jar"), "\n")
      if #server_jar == 0 then
        vim.notify("Spring Boot LS jar not found", vim.log.levels.WARN)
        return
      end
      local cmd = {
        java_bin,
        "-XX:TieredStopAtLevel=1",
        "-Xms64m",
        "-Xmx64m",
        GC_type,
        "--enable-native-access=ALL-UNNAMED",
        "-Dsts.lsp.client=vscode",
        "-Dsts.log.file=/dev/null",
        "-jar",
        server_jar[1],
      }
      return {
        jdtls_name = "jdtls",
        exploded_ls_jar_data = false,
        autocmd = true,
        server = {
          cmd = cmd,
          handlers = {
            -- NOTE: 多个lsp请求inlay hints异常,推测nvim的问题，后续可能会修复
            -- 与jdtls的inlay hints存在冲突,故暂停
            ["textDocument/inlayHint"] = function()
              return nil
            end,
          },
        },
        ls_path = ls_path,
      }
    end,
  },
  {
    "JavaHello/java-deps.nvim",
    ft = "java",
    dependencies = "mfussenegger/nvim-jdtls",
    opts = function()
      local node_data = require("java-deps.java.nodeData")
      local PackageRootKind = require("java-deps.java.IPackageRootNodeData").PackageRootKind
      local NodeKind = node_data.NodeKind
      local TypeKind = node_data.TypeKind
      local M = require("java-deps.views.icons")

      -- 长见识了，居然还可以这样改
      -- 修改展开快捷键为回车
      local ConfigM = require("java-deps.config")
      ConfigM.options.keymaps.toggle_fold = "<cr>"
      -- 修改图标
      M.NodeKind = {
        [NodeKind.Workspace] = { icon = " ", hl = "@property" },
        [NodeKind.Project] = { icon = " ", hl = "@property" },
        [NodeKind.PackageRoot] = { icon = " ", hl = "@property" },
        [NodeKind.Package] = { icon = "󰅩 ", hl = "@property" },
        [NodeKind.PrimaryType] = { icon = " ", hl = "@type" },
        [NodeKind.CompilationUnit] = { icon = " ", hl = "@property" },
        [NodeKind.ClassFile] = { icon = "", hl = "@keyword" },
        [NodeKind.Container] = { icon = " ", hl = "@property" },
        [NodeKind.Folder] = { icon = "󰉋 ", hl = "@property" },
        [NodeKind.File] = { icon = "󰈙", hl = "@property" },
      }
      M.TypeKind = {
        [TypeKind.Class] = { icon = " ", hl = "@type" },
        [TypeKind.Interface] = { icon = " ", hl = "@constructor" },
        [TypeKind.Enum] = { icon = " ", hl = "@type" },
      }
      M.EntryKind = {
        [PackageRootKind.K_SOURCE] = { icon = " ", hl = "@property" },
        [PackageRootKind.K_BINARY] = { icon = " ", hl = "@property" },
      }

      -- 去空格
      -- 这个插件只能在这里执行
      OwnUtil.utils.termux_change_file_line(
        vim.fn.stdpath("data") .. "/lazy/java-deps.nvim/lua/java-deps/parser.lua",
        77,
        "    table.insert(lines, string_prefix .. icon .. node.label)"
      )

      -- 描述java-deps已经加载
      vim.g.java_deps_loaded = 1
    end,
  },
}
