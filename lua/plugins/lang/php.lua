local lsp = "phpactor"

return {

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        phpactor = {
          enabled = lsp == "phpactor",
        },
        intelephense = {
          enabled = lsp == "intelephense",
        },
        [lsp] = {
          enabled = true,
        },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "phpcs",
        "php-cs-fixer",
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      dap.adapters.php = {
        type = "executable",
        command = "php-debug-adapter",
        args = {},
      }
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        php = { "php_cs_fixer" },
      },
    },
  },

  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "V13Axel/neotest-pest",
      "olimorris/neotest-phpunit",
    },
    opts = {
      adapters = {
        "neotest-pest",
        ["neotest-phpunit"] = {
          root_ignore_files = { "tests/Pest.php" },
        },
      },
    },
  },
}
