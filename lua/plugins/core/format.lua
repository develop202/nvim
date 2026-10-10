return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    lazy = true,
    cmd = "ConformInfo",
    -- optional  = true,
    opts = {
      default_format_opts = {
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        -- ["*"] = { "prettier" },
        ["yaml"] = { "yamlfmt" },
        ["sh"] = { "shfmt" },
        ["python"] = { "ruff_format", "isort" },
        ["lua"] = { "stylua" },
        ["luau"] = { "stylua" },
        ["html"] = { "prettier" },
        ["http"] = { "kulala" },
        ["nginx"] = { "nginxfmt" },
        ["sql"] = { "sqlfluff" },
      },
      formatters = {
        -- .http格式化工具
        kulala = {
          command = "kulala-fmt",
          args = { "format", "$FILENAME" },
          stdin = false,
        },
        sqlfluff = {
          -- 将方言改为mysql
          args = { "format", "--dialect=mysql", "-" },
        },
        php_cs_fixer = {
          args = {
            "fix",
            "$FILENAME",
            -- 缩进两个空格
            "--config=" .. vim.fn.stdpath("config") .. "/after/ftplugin/asset/php/phpCsFixerConfig.php",
          },
        },
      },
    },
    keys = {
      {
        "<leader>fd",
        function()
          require("conform").format()
        end,
        desc = "Format Document",
      },
      {
        "<leader>cF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "x" },
        desc = "Format Injected Langs",
      },
    },
  },
}
