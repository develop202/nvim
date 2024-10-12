local HOME = os.getenv("HOME")
return {
  -- Set up nvim-jdtls to attach to java files.
  {
    "mfussenegger/nvim-jdtls",
    dependencies = "JavaHello/spring-boot.nvim",
    opts = function()
      local mason_registry = require("mason-registry")
      local lombok_jar = mason_registry.get_package("jdtls"):get_install_path() .. "/lombok.jar"

      local jdtls_config = {}
      local bundles = {}

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

      -- 添加 spring-boot jdtls 扩展 jar 包
      if require("jdtls.setup").find_root({ ".git/", "mvnw", "gradlew" }) then
        -- 若安装在mason/packages目录下
        if (vim.uv or vim.loop).fs_stat(HOME .. "/.local/share/nvim/mason/packages/spring-boot-ls") then
          vim.g.spring_boot.jdt_extensions_path = HOME .. "/.local/share/nvim/mason/packages/spring-boot-ls/jars"
        end
        vim.list_extend(bundles, require("spring_boot").java_extensions())
      end

      -- 添加Java-dep
      -- 默认使用vscode插件
      local java_dependency_path = HOME .. "/.vscode/extensions"
      -- 使用code-server
      if (vim.uv or vim.loop).fs_stat(HOME .. "/.local/share/code-server/") then
        java_dependency_path = HOME .. "/.local/share/code-server/extensions"
      end
      local java_dependency_bundle = vim.split(
        vim.fn.glob(
          java_dependency_path
            .. "/vscjava.vscode-java-dependency-*-universal/server/com.microsoft.jdtls.ext.core-*.jar"
        ),
        "\n"
      )

      if java_dependency_bundle[1] ~= "" then
        vim.list_extend(bundles, java_dependency_bundle)
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

      return {
        -- How to find the root dir for a given filename. The default comes from
        -- lspconfig which provides a function specifically for java projects.
        root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" })
            and function()
              return require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" })
            end
          ---@diagnostic disable-next-line: undefined-field
          or LazyVim.lsp.get_raw_config("jdtls").default_config.root_dir,

        -- How to find the project name for a given root dir.
        project_name = function(root_dir)
          return root_dir and vim.fs.basename(root_dir)
        end,

        -- Where are the config and workspace dirs for a project?
        jdtls_config_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
        end,
        jdtls_workspace_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
        end,

        -- How to run jdtls. This can be overridden to a full java command-line
        -- if the Python wrapper script doesn't suffice.
        cmd = {
          vim.fn.exepath("jdtls"),
          string.format("--jvm-arg=-javaagent:%s", lombok_jar),
        },
        full_cmd = function(opts)
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local cmd = vim.deepcopy(opts.cmd)
          if project_name then
            vim.list_extend(cmd, {
              "-configuration",
              opts.jdtls_config_dir(project_name),
              "-data",
              opts.jdtls_workspace_dir(project_name),
            })
          end
          return cmd
        end,
        dap = { hotcodereplace = "auto", config_overrides = {} },
        dap_main = {},
        test = true,

        jdtls = jdtls_config,
        settings = {
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
                enabled = "all",
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
      "ibhagwan/fzf-lua", -- 可选
    },
    config = function()
      if not require("jdtls.setup").find_root({ ".git/", "mvnw", "gradlew" }) then
        return
      end

      local installed_on_mason_packages = (vim.uv or vim.loop).fs_stat(
        HOME .. "/.local/share/nvim/mason/packages/spring-boot-ls"
      )

      -- 默认为vscodw插件
      local ls_path = require("spring_boot.vscode").find_one("/language-server")
      local GC_type = "-XX:+UseZGC"

      -- 判断packages是否安装了spring-boot
      if installed_on_mason_packages then
        ls_path = HOME .. "/.local/share/nvim/mason/packages/spring-boot-ls/language-server"
        GC_type = "-XX:+UseG1GC"
      end

      local util = require("spring_boot.util")

      local server_jar = vim.split(vim.fn.glob(ls_path .. "/spring-boot-language-server*.jar"), "\n")
      if #server_jar == 0 then
        vim.notify("Spring Boot LS jar not found", vim.log.levels.WARN)
        return
      end
      local cmd = {
        util.java_bin(),
        "-XX:TieredStopAtLevel=1",
        "-Xms128M",
        "-Xmx128M",
        GC_type,
        "-Dsts.lsp.client=vscode",
        "-Dsts.log.file=/dev/null",
        "-jar",
        server_jar[1],
      }

      require("spring_boot").setup({
        server = {
          cmd = cmd,
        },
        ls_path = ls_path,
      })
    end,
  },
  {
    "JavaHello/java-deps.nvim",
    ft = "java",
    dependencies = "mfussenegger/nvim-jdtls",
    config = function()
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
      require("java-deps").setup({})
    end,
  },
  {
    "javiorfo/nvim-springtime",
    lazy = true,
    cmd = { "Springtime", "SpringtimeUpdate" },
    dependencies = {
      "javiorfo/nvim-popcorn",
      "javiorfo/nvim-spinetta",
      "hrsh7th/nvim-cmp",
    },
    build = function()
      require("springtime.core").update()
    end,
    config = function()
      local SETTINGS = require("springtime").SETTINGS
      local util = require("springtime.util")
      local constants = require("springtime.constants")
      local generator = require("springtime.generator")

      local springtimeM = require("springtime")
      -- 自定义快捷键
      springtimeM.SETTINGS.dialog.generate_keymap = "<leader>gn"

      -- 判断生成项目类型
      local project_type = function(value)
        if value == constants.GRADLE_GROOVY then
          return "gradle-project"
        end
        if value == constants.GRADLE_KOTLIN then
          return "gradle-project-kotlin"
        end
        return "maven-project"
      end

      -- 分割依赖项
      local function split(str)
        local delimiter = ","
        local result = {}
        for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
          if match ~= "" then
            table.insert(result, match)
          end
        end

        local log = vim.inspect(result) or "NONE"
        util.logger:debug("split dependencies: " .. log)

        return result
      end

      -- 处理依赖
      local function validate_dependencies(dependencies)
        local _, libraries = pcall(dofile, util.lua_springtime_path .. "libraries.lua")
        local dependencies_to_tbl = split(dependencies)

        for _, v in pairs(dependencies_to_tbl) do
          local is_valid = false
          for _, library in ipairs(libraries) do
            if library.insertText:sub(1, -2) == v then
              is_valid = true
              util.logger:debug("Library: " .. library.label .. " Version range: " .. library.versionRange)
              break
            end
          end
          if not is_valid then
            return false, v .. " is not a valid library"
          end
        end

        return true, nil
      end

      -- 生成项目
      local function generateByMyself(input)
        local project_folder = string.format("%s/%s", input.workspace, input.project_name)
        local zip_file = string.format("%s.zip", project_folder)
        local command = string.format(
          [[curl -G %s/starter.zip -d type=%s -d language=%s -d packaging=%s -d bootVersion=%s -d javaVersion=%s -d groupId=%s -d artifactId=%s -d name=%s -d packageName=%s -d version=%s %s -o %s 2> >( while read line; do echo \[ERROR\]\[$(date '+%%m/%%d/%%Y %%T')\]: ${line}; done >> %s) %s; echo $?]],
          util.spring_url,
          input.project,
          input.language,
          input.packaging,
          input.spring_boot,
          input.java_version,
          input.project_group,
          input.project_artifact,
          input.project_name,
          input.project_package_name,
          input.project_version,
          input.dependencies ~= "" and "-d dependencies=" .. input.dependencies or "",
          zip_file,
          util.springtime_log_file,
          input.decompress and string.format("&& unzip -q %s -d %s && rm %s", zip_file, project_folder, zip_file) or ""
        )

        util.logger:debug("Curl generated: " .. command)

        local ok = vim.fn.system(command)

        return tonumber(ok) == 0
      end

      local generationM = require("springtime.generator")

      -- 创建项目
      ---@diagnostic disable-next-line: duplicate-set-field
      generationM.create_project = function(values)
        local input = {
          project = project_type(values[1]),
          language = tostring(values[2]):lower(),
          packaging = tostring(values[3]):lower(),
          spring_boot = values[4],
          java_version = values[5],
          project_group = util.trim(values[6]),
          project_artifact = util.trim(values[7]),
          project_name = util.trim(values[8]),
          project_package_name = util.trim(values[9]),
          project_version = SETTINGS.spring.project_metadata.version,
          dependencies = values[10],
          workspace = SETTINGS.workspace.path,
          decompress = SETTINGS.workspace.decompress,
        }

        if input.project_group == "" then
          return false, "Project Metadata Group could not be empty"
        end
        if input.project_artifact == "" then
          return false, "Project Metadata Artifact could not be empty"
        end
        if input.project_name == "" then
          return false, "Project Metadata Name could not be empty"
        end
        if input.project_package_name == "" then
          return false, "Project Metadata Package Name could not be empty"
        end

        if input.dependencies ~= "" then
          input.dependencies, _ = string.gsub(input.dependencies, " ", "")
          local is_valid, msg = validate_dependencies(input.dependencies)
          if is_valid then
            input.dependencies = util.remove_trailing_comma(util.trim(input.dependencies))
          else
            return false, msg
          end
        end

        return generateByMyself(input)
      end

      local coreM = require("springtime.core")

      -- 核心创建项目
      ---@diagnostic disable-next-line: duplicate-set-field
      coreM.generate = function(values)
        local user_input = "y"
        if SETTINGS.dialog.confirmation then
          -- user_input = vim.fn.input(string.format("Do you want to generate project [%s]? y/n: ", values[8]))
          user_input = vim.fn.input(string.format("确定生成项目[%s]? y/n: ", values[8]))
        end

        if tostring(user_input):lower() == "y" then
          vim.cmd([[redraw]])
          util.logger:debug("Values to generate project: " .. vim.inspect(values))

          local ok = generator.create_project(values)
          if ok then
            util.logger:info(
              string.format(
                "  [%s] generated correctly in workspace [%s]",
                util.trim(values[8]),
                SETTINGS.workspace.path
              )
            )
            if SETTINGS.workspace.open_auto then
              -- vim.cmd(string.format("e %s/%s", SETTINGS.workspace.path, util.trim(values[8])))
              -- vim.cmd(string.format("q"))
              vim.cmd("quit")
              vim.cmd(string.format("cd %s/%s", SETTINGS.workspace.path, util.trim(values[8])))
              vim.cmd("Neotree")
            end
          else
            util.logger:error("  Error generating project. Check the logs with :SpringtimeLogs command")
          end
        else
          vim.cmd([[redraw]])
        end
      end
    end,
  },
}
