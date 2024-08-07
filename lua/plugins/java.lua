-- This is the same as in lspconfig.server_configurations.jdtls, but avoids
-- needing to require that when this module loads.
local java_filetypes = { "java" }

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
  {
    "mfussenegger/nvim-jdtls",
    dependencies = { "folke/which-key.nvim" },
    ft = java_filetypes,
    opts = function()
      return {
        -- How to find the root dir for a given filename. The default comes from
        -- lspconfig which provides a function specifically for java projects.
        root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" })
            and function()
              return require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" })
            end
          or require("lspconfig.server_configurations.jdtls").default_config.root_dir,
        --   function()
        --   if require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }) ~= nil then
        --     return require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' })
        --   end
        --   return require("lspconfig.server_configurations.jdtls").default_config.root_dir
        -- end,

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
        cmd = { vim.fn.exepath("jdtls") },
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
              "--jvm-arg=-javaagent:/data/data/com.termux/files/home/.local/share/nvim/mason/packages/jdtls/lombok.jar",
            })
          end
          return cmd
        end,

        -- These depend on nvim-dap, but can additionally be disabled by setting false here.
        dap = { hotcodereplace = "auto", config_overrides = {} },
        test = true,
      }
    end,
    config = function()
      local opts = LazyVim.opts("nvim-jdtls") or {}

      -- Find the extra bundles that should be passed on the jdtls command-line
      -- if nvim-dap is enabled with java debug/test.
      local mason_registry = require("mason-registry")
      local bundles = {} ---@type string[]
      if opts.dap and LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
        local java_dbg_pkg = mason_registry.get_package("java-debug-adapter")
        local java_dbg_path = java_dbg_pkg:get_install_path()
        local jar_patterns = {
          java_dbg_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
        }
        -- java-test also depends on java-debug-adapter.
        if opts.test and mason_registry.is_installed("java-test") then
          local java_test_pkg = mason_registry.get_package("java-test")
          local java_test_path = java_test_pkg:get_install_path()
          vim.list_extend(jar_patterns, {
            java_test_path .. "/extension/server/*.jar",
          })
        end
        for _, jar_pattern in ipairs(jar_patterns) do
          for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
            table.insert(bundles, bundle)
          end
        end
      end

      -- 添加 spring-boot jdtls 扩展 jar 包
      if require("jdtls.setup").find_root({ ".git/", "mvnw", "gradlew" }) then
        vim.list_extend(bundles, require("spring_boot").java_extensions())
      end
      -- 添加Java-dep
      local java_dependency_bundle = vim.split(
        vim.fn.glob(
          "/data/data/com.termux/files/home/.local/share/code-server/extensions/vscjava.vscode-java-dependency-*-universal/server/com.microsoft.jdtls.ext.core-*.jar"
        ),
        "\n"
      )

      if java_dependency_bundle[1] ~= "" then
        vim.list_extend(bundles, java_dependency_bundle)
      end

      local function attach_jdtls()
        local fname = vim.api.nvim_buf_get_name(0)
        local jdtls = require("jdtls")

        local extendedClientCapabilities = jdtls.extendedClientCapabilities
        extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
        extendedClientCapabilities.progressReportProvider = false

        -- Configuration can be augmented and overridden by opts.jdtls
        local config = extend_or_override({
          cmd = opts.full_cmd(opts),
          settings = {
            java = {
              configuration = {
                maven = {
                  -- TODO:这个配置时灵时不灵，很奇怪
                  userSettings = "/data/data/com.termux/files/usr/opt/maven/conf/settings.xml",
                  globalSettings = "/data/data/com.termux/files/usr/opt/maven/conf/settings.xml",
                },
              },
              inlayHints = {
                parameterNames = {
                  enabled = "all",
                },
              },
            },
          },
          root_dir = opts.root_dir(fname),
          init_options = {
            bundles = bundles,
            extendedClientCapabilities = extendedClientCapabilities,
          },
          on_attach = function(client, buffer)
            require("java-deps").attach(client, buffer)
            -- 添加命令
            local create_command = vim.api.nvim_buf_create_user_command
            create_command(buffer, "JavaProjects", require("java-deps").toggle_outline, {
              nargs = 0,
            })
            --
            --   -- Java编译
            --   local function with_compile(fn)
            --     return function()
            --       if vim.bo.modified then
            --         vim.cmd("w")
            --       end
            --       client.request_sync("java/buildWorkspace", false, 5000, buffer)
            --       fn()
            --     end
            --   end
            --
            --   -- 运行Java main方法
            --   vim.api.nvim_buf_create_user_command(
            --     buffer,
            --     "JdtRun",
            --     with_compile(function()
            --       local main_config_opts = {
            --         verbose = false,
            --         on_ready = require("dap")["continue"],
            --       }
            --       require("jdtls.dap").setup_dap_main_class_configs(main_config_opts)
            --     end),
            --     {
            --       nargs = 0,
            --     }
            --   )
          end,
          -- enable CMP capabilities
          capabilities = LazyVim.has("cmp-nvim-lsp") and require("cmp_nvim_lsp").default_capabilities() or nil,
        }, opts.jdtls)

        -- Existing server will be reused if the root_dir matches.
        require("jdtls").start_or_attach(config)
        -- not need to require("jdtls.setup").add_commands(), start automatically adds commands
      end

      -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
      -- depending on filetype, so this autocmd doesn't run for the first file.
      -- For that, we call directly below.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = java_filetypes,
        callback = attach_jdtls,
      })

      -- Setup keymap and dap after the lsp is fully attached.
      -- https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
      -- https://neovim.io/doc/user/lsp.html#LspAttach
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
                { "gs", require("jdtls").super_implementation, desc = "Goto Super" },
                { "gS", require("jdtls.tests").goto_subjects, desc = "Goto Subjects" },
                { "<leader>co", require("jdtls").organize_imports, desc = "Organize Imports" },
              },
            })
            wk.add({
              {
                mode = "v",
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
            if opts.dap and LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
              -- custom init for Java debugger
              require("jdtls").setup_dap(opts.dap)
              require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)

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
    "JavaHello/spring-boot.nvim",
    -- 目前0.9版本必须用旧版本才可以正常启动
    -- fix: 添加安装提示
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-jdtls",
      "ibhagwan/fzf-lua", -- 可选
    },
    config = function()
      if not require("jdtls.setup").find_root({ ".git/", "mvnw", "gradlew" }) then
        return
      end
      require("spring_boot").setup({})
    end,
  },
  {
    "JavaHello/java-deps.nvim",
    -- lazy = true,
    ft = "java",
    dependencies = "mfussenegger/nvim-jdtls",
    -- options = {
    --   fold_markers = { " ", " " },
    --   symbols = {
    --     Workspace = { icon = " ", hl = "@text.uri" },
    --     Project = { icon = " ", hl = "@text.uri" },
    --     PackageRoot = { icon = " ", hl = "@text.uri" },
    --     Package = { icon = "󰅩 ", hl = "@namespace" },
    --     PrimaryType = { icon = " ", hl = "@type" },
    --     CompilationUnit = { icon = " ", hl = "@text.uri" },
    --     ClassFile = { icon = " ", hl = "@text.uri" },
    --     Container = { icon = " ", hl = "@text.uri" },
    --     Folder = { icon = " ", hl = "@method" },
    --     File = { icon = " ", hl = "@method" },
    --
    --     CLASS = { icon = " ", hl = "@class" },
    --     ENUM = { icon = " ", hl = "@enum" },
    --     INTERFACE = { icon = " ", hl = "@interface" },
    --     JAR = { icon = " ", hl = "@conditional" },
    --   },
    -- },
    config = function()
      require("java-deps").setup({})
    end,
  },
  -- Java彩虹括号
  -- {
  --   "HiPhish/nvim-ts-rainbow2",
  --   ft = { "java" },
  --   -- event = "lazyfile",
  --   lazy = true,
  --   dependencies = { "nvim-treesitter/nvim-treesitter" },
  --   config = function()
  --     local parsers = require("nvim-treesitter.parsers")
  --     local enabled_list = { "java" }
  --     require("nvim-treesitter.configs").setup({
  --       rainbow = {
  --         enable = true,
  --         -- Enable only for lisp like languages
  --         disable = vim.tbl_filter(function(p)
  --           local disable = true
  --           for _, lang in pairs(enabled_list) do
  --             if p == lang then
  --               disable = false
  --             end
  --           end
  --           return disable
  --         end, parsers.available_parsers()),
  --       },
  --     })
  --   end,
  -- },
  -- {
  --   "niT-Tin/springboot-start.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-telescope/telescope.nvim",
  --     "MunifTanjim/nui.nvim",
  --   },
  --   config = function()
  --     require("springboot-start").setup({
  --       -- your configuration comes here
  --       -- or leave it empty to use the default settings
  --       -- refer to the configuration section below
  --     })
  --   end,
  -- },
  {
    "chaosystema/nvim-springtime",
    lazy = true,
    cmd = { "Springtime", "SpringtimeUpdate" },
    dependencies = {
      "chaosystema/nvim-popcorn",
      "chaosystema/nvim-spinetta",
      "hrsh7th/nvim-cmp",
    },
    build = function()
      require("springtime.core").update()
    end,
    opts = {
      -- This section is optional
      -- If you want to change default configurations
      -- In packer.nvim use require'springtime'.setup { ... }

      -- Springtime popup section
      spring = {
        -- Project: Gradle, Gradle Kotlin and Maven (Gradle default)
        project = {
          selected = 1,
        },
        -- Language: Java, Kotlin and Groovy (Java default)
        language = {
          selected = 1,
        },
        -- Packaging: Jar and War (Jar default)
        packaging = {
          selected = 1,
        },
        -- Project Metadata defaults:
        -- Change the default values as you like
        -- This can also be edited in the popup
        project_metadata = {
          group = "com.example",
          artifact = "demo",
          name = "demo",
          package_name = "com.example.demo",
          version = "0.0.1-SNAPSHOT",
        },
        -- 自定义Java和spring boot的版本
        -- spring_boot = {
        --   selected = 3,
        --   values = {
        --     "3.2.5",
        --     "3.1.11",
        --     "2.7.18",
        --   },
        -- },
        -- java_version = {
        --   selected = 2,
        --   values = { 17, 11, 8 },
        -- },
      },

      -- Some popup options
      dialog = {
        -- The keymap used to select radio buttons (normal mode)
        selection_keymap = "<C-Space>",

        -- The keymap used to generate the Spring project (normal mode)
        generate_keymap = "<leader>gn",

        -- If you want confirmation before generate the Spring project
        confirmation = true,

        -- Highlight links to Title and sections for changing colors
        style = {
          title_link = "Boolean",
          section_link = "Type",
        },
      },

      -- Workspace is where the generated Spring project will be saved
      workspace = {
        -- Default where Neovim is open
        path = vim.fn.expand("%:p:h"),

        -- Spring Initializr generates a zip file
        -- Decompress the file by default
        decompress = true,

        -- If after generation you want to open the folder
        -- Opens the generated project in Neovim by default
        open_auto = true,
      },

      -- This could be enabled for debugging purposes
      -- Generates a springtime.log with debug and errors.
      internal = {
        log_debug = false,
      },
    },
  },
}
