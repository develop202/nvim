---@class util.lang
local M = {}

M.java = {}

M.java.root_markers = {
  ".git", -- IDE
  ".idea",
  ".project",

  "mvnw", -- Maven
  "pom.xml",

  "gradlew", -- Gradle
  "settings.gradle",
  "settings.gradle.kts",

  "build.xml", -- Ant
}

M.java.is_spring_boot_project = function(dir)
  dir = dir or vim.fn.getcwd()
  local spring_boot_markers = {
    "application.yml",
    "application.yaml",
    "application.properties",
    "bootstrap.yml",
    "bootstrap.yaml",
    "bootstrap.properties",
  }

  local found = vim.fs.find(function(name, path)
    for _, marker in pairs(spring_boot_markers) do
      if name == marker then
        return path:match("src[/\\]main[/\\]resources$") ~= nil
      end
    end
    return false
  end, {
    path = dir,
    type = "file",
  })
  if #found > 0 then
    return true
  end
  return false
end

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

local HOME = vim.env["HOME"]
-- 开启inlay_hint
local inlay_hint_enabled = "all"

M.java.jdtls = {}

M.java.jdtls.full_cmd = function(options)
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

M.java.jdtls.get_config_file = function()
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

M.java.jdtls.settings = {
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

local vtsls_lang = {
  updateImportsOnFileMove = { enabled = "always" },
  suggest = {
    completeFunctionCalls = true,
  },
  inlayHints = {
    enumMemberValues = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    parameterNames = { enabled = "literals" },
    parameterTypes = { enabled = true },
    propertyDeclarationTypes = { enabled = true },
    variableTypes = { enabled = false },
  },
}
M.vtsls = {
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
  },
  settings = {
    complete_function_calls = true,
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        maxInlayHintLength = 30,
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
      tsserver = {
        globalPlugins = {
          {
            name = "@vue/typescript-plugin",
            location = vim.fn.expand("$MASON/packages/vue-language-server") .. "/node_modules/@vue/language-server",
            languages = { "vue" },
            configNamespace = "typescript",
            enableForWorkspaceTypeScriptVersions = true,
          },
        },
      },
    },
    typescript = vtsls_lang,
    javascript = vtsls_lang,
  },
}

M.lua_ls = {
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          "${3rd}/luv/library",
          "${3rd}/busted/library",
        },
      },
      codeLens = {
        enable = true,
      },
      completion = {
        callSnippet = "Replace",
      },
      doc = {
        privateName = { "^_" },
      },
      hint = {
        enable = true,
        setType = false,
        paramType = true,
        paramName = "Disable",
        semicolon = "Disable",
      },
    },
  },
}

M.clangd = {
  root_markers = {
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac", -- AutoTools
    "Makefile",
    "configure.ac",
    "configure.in",
    "config.h.in",
    "meson.build",
    "meson_options.txt",
    "build.ninja",
    ".git",
  },
  capabilities = {
    offsetEncoding = { "utf-16" },
  },
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
}
M.gopls = {
  settings = {
    gopls = {
      gofumpt = true,
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = {
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
      semanticTokens = true,
    },
  },
}

M.treesitter = {
  "bash",
  "c",
  "cpp",
  "css",
  "dart",
  "diff",
  "dockerfile",
  "dtd",
  "go",
  "gomod",
  "gosum",
  "gowork",
  "graphql",
  "groovy",
  "html",
  "http",
  "java",
  "javascript",
  "jsdoc",
  "json",
  "json5",
  "kotlin",
  "kulala_http",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "ninja",
  "php",
  "php_only",
  "printf",
  "python",
  "query",
  "regex",
  "rst",
  "scss",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "vue",
  "xml",
  "yaml",
}

return M
