return {
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
    },
  },
  {
    "artur-shaik/jc.nvim",
    ft = vim.g.intellij and "abcdef" or "java",
    dependencies = {
      "nvim-java/nvim-jdtls",
      {
        "nvim-neotest/neotest",
        optional = true,
        dependencies = { "nvim-neotest/nvim-nio", "nvim-lua/plenary.nvim" },
        opts = function(_, opts)
          opts.adapters = opts.adapters or {}
          table.insert(opts.adapters, require("jc").neotest_adapter())
          -- optional: auto-close the summary on an all-green focused run
          opts.consumers = opts.consumers or {}
          opts.consumers.jc = require("jc").neotest_consumer()
        end,
      },
    },
    opts = { keys_prefix = "<leader>j" },
  },
}
