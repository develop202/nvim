local HOME = vim.env["HOME"]

local GC_type = "-XX:+UseZGC"
if OwnUtil.sys.is_termux() then
  -- termux不支持ZGC
  GC_type = "-XX:+UseG1GC"
end

local java_bin = OwnUtil.utils.cmd.java_bin()

local function extend_or_override(config, custom, ...)
  if type(custom) == "function" then
    config = custom(config, ...) or config
  elseif custom then
    config = vim.tbl_deep_extend("force", config, custom) --[[@as table]]
  end
  return config
end

vim.g.intellij = false

return {
  -- Set up nvim-jdtls to attach to java files.
  {
    "mfussenegger/nvim-jdtls",
    -- enabled = not vim.g.intellij_java,
    ft = vim.g.intellij and "abcdef" or "java",
    -- jdtls要求最低Java21
    -- 需要配置JAVA_21_HOME环境变量
    opts = function()
      local opts = {}
      local mason_registry = require("mason-registry")

      local jdtls_config = {}
      local bundles = {}

      -- 开启inlay_hint
      local inlay_hint_enabled = "all"

      -- 添加dap扩展jar包
      if mason_registry.is_installed("java-debug-adapter") then
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
      if OwnUtil.lang.java.is_spring_boot_project() then
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
      opts.project_name = function(root_dir)
        return root_dir and vim.fs.basename(root_dir)
      end
      opts.root_dir = function()
        local root_dir = require("jdtls.setup").find_root(OwnUtil.lang.java.root_markers, vim.fn.getcwd())
        if not root_dir then
          local path = vim.api.nvim_buf_get_name(0)

          root_dir = vim.fs.root(path, vim.lsp.config.jdtls.root_markers) or ""
        end
        return root_dir
      end

      opts.jdtls_config_dir = function(project_name)
        return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
      end
      opts.jdtls_workspace_dir = function(project_name)
        return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
      end

      opts.full_cmd = function(options)
        local fname = vim.api.nvim_buf_get_name(0)
        local root_dir = options.root_dir(fname)
        local project_name = options.project_name(root_dir)
        local cmd = vim.deepcopy(options.cmd)
        if project_name then
          vim.list_extend(cmd, {
            "-configuration",
            options.jdtls_config_dir(project_name),
            "-data",
            options.jdtls_workspace_dir(project_name),
          })
        end
        return cmd
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
      opts.dap = { hotcodereplace = "auto", config_overrides = {} }
      -- Can set this to false to disable main class scan, which is a performance killer for large project
      opts.test = true
      return opts
    end,
    config = function(_, opts)
      local function attach_jdtls()
        local fname = vim.api.nvim_buf_get_name(0)

        -- Configuration can be augmented and overridden by opts.jdtls
        local config = extend_or_override({
          cmd = opts.full_cmd(opts),
          root_dir = opts.root_dir(fname),
          settings = opts.settings,
          -- enable CMP capabilities
          capabilities = require("blink.cmp").get_lsp_capabilities() or nil,
        }, opts.jdtls)

        -- Existing server will be reused if the root_dir matches.
        require("jdtls").start_or_attach(config)
        -- not need to require("jdtls.setup").add_commands(), start automatically adds commands
      end

      -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
      -- depending on filetype, so this autocmd doesn't run for the first file.
      -- For that, we call directly below.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = attach_jdtls,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "jdtls" then
            local wk = require("which-key")
            wk.add({
              {
                mode = "n",
                buffer = args.buf,
                { "<leader>cx", group = "extract" },
                { "<leader>cxv", require("jdtls").extract_variable_all, desc = "Extract Variable" },
                { "<leader>cxc", require("jdtls").extract_constant, desc = "Extract Constant" },
                { "<leader>cgs", require("jdtls").super_implementation, desc = "Goto Super" },
                { "<leader>cgS", require("jdtls.tests").goto_subjects, desc = "Goto Subjects" },
                { "<leader>co", require("jdtls").organize_imports, desc = "Organize Imports" },
              },
            })
            wk.add({
              {
                mode = "x",
                buffer = args.buf,
                { "<leader>cx", group = "extract" },
                {
                  "<leader>cxm",
                  [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
                  desc = "Extract Method",
                },
                {
                  "<leader>cxv",
                  [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
                  desc = "Extract Variable",
                },
                {
                  "<leader>cxc",
                  [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
                  desc = "Extract Constant",
                },
              },
            })

            local mason_registry = require("mason-registry")
            if opts.dap and mason_registry.is_installed("java-debug-adapter") then
              -- custom init for Java debugger
              require("jdtls").setup_dap(opts.dap)
              if opts.dap_main then
                require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)
              end

              -- Java Test require Java debugger to work
              if opts.test and mason_registry.is_installed("java-test") then
                -- custom keymaps for Java test runner (not yet compatible with neotest)
                wk.add({
                  {
                    mode = "n",
                    buffer = args.buf,
                    { "<leader>t", group = "test" },
                    {
                      "<leader>tt",
                      function()
                        require("jdtls.dap").test_class({
                          config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
                        })
                      end,
                      desc = "Run All Test",
                    },
                    {
                      "<leader>tr",
                      function()
                        require("jdtls.dap").test_nearest_method({
                          config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
                        })
                      end,
                      desc = "Run Nearest Test",
                    },
                    { "<leader>tT", require("jdtls.dap").pick_test, desc = "Run Test" },
                  },
                })
              end
            end

            -- User can set additional keymaps in opts.on_attach
            if opts.on_attach then
              opts.on_attach(args)
            end
          end
        end,
      })

      -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
      attach_jdtls()
    end,
  },

  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      if not vim.g.intellij then
        local dap = require("dap")
        dap.configurations.java = {
          {
            type = "java",
            request = "attach",
            name = "Debug (Attach) - Remote",
            hostName = "127.0.0.1",
            port = 5005,
          },
        }
      end
    end,
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "java-debug-adapter", "java-test" } },
      },
    },
  },
  {
    "JavaHello/spring-boot.nvim",
    -- enabled = not vim.g.intellij_java,
    ft = vim.g.intellij and "abcdef" or "java",
    dependencies = {
      "mfussenegger/nvim-jdtls",
    },
    opts = function()
      if not OwnUtil.lang.java.is_spring_boot_project() then
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

  {
    "JavaHello/java-deps.nvim",
    -- enabled = not vim.g.intellij_java,
    lazy = true,
    ft = vim.g.intellij and "abcdef" or "java",
    dependencies = "mfussenegger/nvim-jdtls",
    opts = {
      width = OwnUtil.sys.is_termux() and "70%" or "30%",
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
    },
  },

  {
    "AlexandrosAlexiou/intellij-server.nvim",
    -- enabled = vim.g.intellij_java,
    ft = vim.g.intellij and { "java", "kotlin" } or "abcdef",
    dependencies = { "mfussenegger/nvim-dap" }, -- optional
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
      }
    end,
  },
}
