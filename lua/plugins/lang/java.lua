local HOME = vim.env["HOME"]

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
    -- 需要配置JAVA_21_HOME环境变量
    opts = function(_, opts)
      local mason_registry = require("mason-registry")

      local jdtls_config = {}
      local bundles = {}

      -- 开启inlay_hint
      local inlay_hint_enabled = "all"

      -- 添加dap扩展jar包
      if LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
        local java_dbg_path = vim.fn.expand("$MASON/packages/java-debug-adapter")
        local jar_patterns = {
          java_dbg_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
        }

        -- 添加test扩展jar包
        -- java-test also depends on java-debug-adapter.
        if mason_registry.is_installed("java-test") then
          local java_test_bundles =
            vim.split(vim.fn.glob(vim.fn.expand("$MASON/packages/java-test") .. "/extension/server/*.jar"), "\n")
          local excluded = {
            "com.microsoft.java.test.runner-jar-with-dependencies.jar",
            "jacocoagent.jar",
          }
          for _, java_test_jar in ipairs(java_test_bundles) do
            local fname = vim.fn.fnamemodify(java_test_jar, ":t")
            if not vim.tbl_contains(excluded, fname) then
              table.insert(jar_patterns, java_test_jar)
            end
          end
        end

        -- 添加到bundles
        for _, jar_pattern in ipairs(jar_patterns) do
          for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
            table.insert(bundles, bundle)
          end
        end
      end

      -- 添加spring-boot jdtls扩展jar包
      if OwnUtil.lsp.java.is_spring_boot_project() then
        if mason_registry.is_installed("vscode-spring-boot-tools") then
          -- 添加jars目录下所有的jar文件
          local java_spring_boot_bundles = vim.split(
            vim.fn.glob(vim.fn.expand("$MASON/packages/vscode-spring-boot-tools") .. "/extension/jars/*.jar"),
            "\n"
          )
          local excluded = {
            "commons-lsp-extensions.jar",
            "xml-ls-extension.jar",
          }
          for _, java_spring_boot_jar in ipairs(java_spring_boot_bundles) do
            local fname = vim.fn.fnamemodify(java_spring_boot_jar, ":t")
            if not vim.tbl_contains(excluded, fname) then
              table.insert(bundles, java_spring_boot_jar)
            end
          end
        end
      end

      -- 添加Java-dep
      local java_dependency_path = nil
      local java_dependency_bundle = nil
      local path_prefix = ""
      -- 是否在mason安装
      if mason_registry.is_installed("vscode-java-dependency") then
        java_dependency_path = vim.fn.expand("$MASON/packages/vscode-java-dependency/extension/server")
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

        -- JavaProject
        vim.keymap.set("n", "<leader>jp", "<cmd>JavaProject<CR>", { desc = "Java Projects", buffer = buffer })
        vim.keymap.set(
          "n",
          "<leader>jud",
          "<cmd>JdtUpdateDebugConfig<CR>",
          { desc = "Jdtls Update Debug Config", buffer = buffer }
        )
        vim.keymap.set(
          "n",
          "<leader>juc",
          "<cmd>JdtUpdateConfig<CR>",
          { desc = "Jdtls Update Config", buffer = buffer }
        )
      end

      jdtls_config.handlers = {}

      opts.root_dir = function()
        local root_dir = require("jdtls.setup").find_root(OwnUtil.lsp.java.root_markers, vim.fn.getcwd())
        if not root_dir then
          local path = vim.api.nvim_buf_get_name(0)

          root_dir = vim.fs.root(path, vim.lsp.config.jdtls.root_markers) or ""
        end
        return root_dir
      end

      local function get_config_file()
        local sys = OwnUtil.sys
        local file = ""
        if sys.is_linux() then
          file = "/config_linux"
        elseif sys.is_macos() then
          file = "/config_mac"
        elseif sys.is_windows() then
          file = "/config_win"
        end
        if file ~= "" then
          if sys.is_termux() then
            file = file .. "_arm"
          end
        else
          error("未知系统")
          return nil
        end
        return file
      end
      -- jdtls目录
      local base_dir = vim.fn.expand("$MASON/packages/jdtls")
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
        local lombok_jar = vim.fn.expand("$MASON/packages/jdtls/lombok.jar")
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
      local ExecutionEnvironment = {
        J2SE_1_5 = "J2SE-1.5",
        JavaSE_1_6 = "JavaSE-1.6",
        JavaSE_1_7 = "JavaSE-1.7",
        JavaSE_1_8 = "JavaSE-1.8",
        JavaSE_9 = "JavaSE-9",
        JavaSE_10 = "JavaSE-10",
        JavaSE_11 = "JavaSE-11",
        JavaSE_12 = "JavaSE-12",
        JavaSE_13 = "JavaSE-13",
        JavaSE_14 = "JavaSE-14",
        JavaSE_15 = "JavaSE-15",
        JavaSE_16 = "JavaSE-16",
        JavaSE_17 = "JavaSE-17",
        JavaSE_18 = "JavaSE-18",
        JavaSE_19 = "JavaSE-19",
        JAVASE_20 = "JavaSE-20",
        JAVASE_21 = "JavaSE-21",
        JAVASE_22 = "JavaSE-22",
        JAVASE_23 = "JavaSE-23",
        JAVASE_24 = "JavaSE-24",
        JAVASE_25 = "JavaSE-25",
      }
      local runtimes = (function()
        local result = {}
        for _, value in pairs(ExecutionEnvironment) do
          local version = vim.fn.split(value, "-")[2]
          if string.match(version, "%.") then
            version = vim.split(version, "%.")[2]
          end
          local java_home = os.getenv(string.format("JAVA_%s_HOME", version))
          local default_jdk = false
          if java_home then
            -- local java_sources = get_java_ver_sources(
            --   version,
            --   fglob(vim.fn.glob(vim.fs.joinpath(java_home, "src.zip")))
            --     or fglob(vim.fn.glob(vim.fs.joinpath(java_home, "lib", "src.zip")))
            -- )
            if ExecutionEnvironment.JavaSE_17 == value then
              default_jdk = true
            end
            table.insert(result, {
              name = value,
              path = java_home,
              -- sources = java_sources,
              default = default_jdk,
            })
          end
        end
        if #result == 0 then
          vim.notify("Please config Java runtimes (JAVA_17_HOME...)")
        end
        return result
      end)()
      opts.settings = {
        java = {
          configuration = {
            maven = {
              -- 将settings.xml复制到.m2目录下即可生效
              userSettings = HOME .. "/.m2/settings.xml",
              globalSettings = HOME .. "/.m2/settings.xml",
            },
            runtimes = runtimes,
          },
          inlayhints = {
            parameterNames = {
              enabled = inlay_hint_enabled,
            },
          },
          implementationCodeLens = "all",
          referenceCodeLens = { enabled = true },
          codeGeneration = {
            toString = {
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            },
            useBlocks = true,
          },
          templates = {
            typeComment = {
              "/**",
              " * ${type_name}.",
              " *",
              " * @author ${user}",
              " */",
            },
          },
          signatureHelp = {
            enabled = true,
          },
          completion = {
            maxResults = 20,
            favoriteStaticMembers = {
              "org.junit.Assert.*",
              "org.junit.Assume.*",
              "org.junit.jupiter.api.Assertions.*",
              "org.junit.jupiter.api.Assumptions.*",
              "org.junit.jupiter.api.DynamicContainer.*",
              "org.junit.jupiter.api.DynamicTest.*",
              "org.assertj.core.api.Assertions.assertThat",
              "org.assertj.core.api.Assertions.assertThatThrownBy",
              "org.assertj.core.api.Assertions.assertThatExceptionOfType",
              "org.assertj.core.api.Assertions.catchThrowable",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
              "org.mockito.Mockito.*",
            },
            filteredTypes = {
              "com.sun.*",
              "io.micrometer.shaded.*",
              "java.awt.*",
              "org.graalvm.*",
              "jdk.*",
              "sun.*",
            },
            importOrder = {
              "java",
              "javax",
              "org",
              "com",
            },
            matchCase = "off",
          },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          saveActions = {
            organizeImports = true,
          },
          jdt = {
            ls = {
              androidSupport = {
                enabled = true,
              },
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
      if not OwnUtil.lsp.java.is_spring_boot_project() then
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
        .. vim.fs.basename(vim.fs.root(vim.fn.getcwd(), OwnUtil.lsp.java.root_markers))
        .. "/spring_boot/log.txt"

      local cmd = {
        java_bin,
        "-XX:TieredStopAtLevel=1",
        "-Xms64M",
        "-Xmx64M",
        GC_type,
        -- "-Dspring.config.location=classpath:/application.properties",
        -- "-Dspring.main.web-application-type=NONE",
        -- "-Xlog:jni+resolve=off",
        "-Dsts.lsp.client=vscode",
        "-Dsts.log.file=" .. log_file,
        "-Dspring.profiles.active=file-logging",
        "-Dlogging.file.name=" .. log_file,
        "-Dlogging.level.root=info",
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
            -- NOTE: 多个lsp请求inlayHints异常
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
    lazy = true,
    ft = "java",
    dependencies = "mfussenegger/nvim-jdtls",
    opts = function()
      -- 去空格
      OwnUtil.utils.termux_change_file_line(
        vim.fn.stdpath("data") .. "/lazy/java-deps.nvim/lua/java-deps/parser.lua",
        88,
        "    table.insert(lines, string_prefix .. icon .. node.label)"
      )

      -- 去空格
      OwnUtil.utils.termux_change_file_line(
        vim.fn.stdpath("data") .. "/lazy/java-deps.nvim/lua/java-deps/parser.lua",
        80,
        '      local suffix = " " if line[index] == " " or line[index] == " " then suffix = "" end line[index] = line[index] .. suffix'
      )
      -- 描述java-deps已经加载
      vim.g.java_deps_loaded = 1

      local java_dep_width = "30%"
      if OwnUtil.sys.is_termux() then
        java_dep_width = "70%"
      end

      return {
        width = java_dep_width,
        fold_markers = { " ", " " },
        keymaps = {
          close = "q",
          toggle_fold = "<CR>",
        },
        symbols = {
          icons = {
            NodeKind = {
              Workspace = { icon = " ", hl = "@property" },
              Project = { icon = " ", hl = "@property" },
              PackageRoot = { icon = " ", hl = "@property" },
              Package = { icon = "󰅩 ", hl = "@property" },
              PrimaryType = { icon = " ", hl = "@type" },
              CompilationUnit = { icon = " ", hl = "@property" },
              ClassFile = { icon = " ", hl = "@keyword" },
              Container = { icon = " ", hl = "@property" },
              Folder = { icon = " ", hl = "@property" },
              File = { icon = " ", hl = "@property" },
            },
            TypeKind = {
              Class = { icon = " ", hl = "@type" },
              Interface = { icon = " ", hl = "@constructor" },
              Enum = { icon = " ", hl = "@type" },
            },
            EntryKind = {
              K_SOURCE = { icon = " ", hl = "@property" },
              K_BINARY = { icon = " ", hl = "@property" },
            },
          },
        },
      }
    end,
  },
}
