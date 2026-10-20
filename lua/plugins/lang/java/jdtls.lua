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

return {
  -- Set up nvim-jdtls to attach to java files.
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

    opts.root_dir = function()
      local root_dir = require("jdtls.setup").find_root(OwnUtil.lang.java.root_markers, vim.fn.getcwd())
      if not root_dir then
        local path = vim.api.nvim_buf_get_name(0)

        root_dir = vim.fs.root(path, vim.lsp.config.jdtls.root_markers) or ""
      end
      return root_dir
    end

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
    -- if OwnUtil.lang.java.is_spring_boot_project() then
    if require("spring_boot.util").has_spring_boot_dependency(opts.root_dir()) then
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
      vim.keymap.set("n", "<leader>juc", "<cmd>JdtUpdateConfig<CR>", { desc = "Jdtls Update Config", buffer = buffer })
    end

    jdtls_config.handlers = {}
    opts.project_name = function(root_dir)
      return root_dir and vim.fs.basename(root_dir)
    end

    opts.jdtls_config_dir = function(project_name)
      return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
    end
    opts.jdtls_workspace_dir = function(project_name)
      return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
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
      "-Dosgi.sharedConfiguration.area=" .. base_dir .. OwnUtil.lang.java.jdtls.get_config_file(),
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
    opts.settings = OwnUtil.lang.java.jdtls.settings
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
        cmd = OwnUtil.lang.java.jdtls.full_cmd(opts),
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
}
