return {
  {
    -- "mistweaverco/kulala.nvim",
    "dont-be-evil-company/kulala.nvim",
    -- pin = true,
    -- brains = "main",
    -- tag = "v5.3.4",
    -- ft = { "http", "rest" },
    ft = {
      "http",
      "rest" --[[ , "javascript", "lua" ]],
    },

    event = function()
      return {}
    end,

    opts = function(_, opts)
      -- vim.env.KULALA_CORE_PATH = vim.env["HOME"] .. "/.bin/kulala-core/packages/core/dist/kulala-core"
      vim.env.KULALA_CORE_PATH = vim.env["HOME"] .. "/.bin/kulala-core"

      opts.kulala_core = {
        path = OwnUtil.sys.is_termux() and vim.env["HOME"] .. "/.bin/kulala-core" or nil,
      }

      opts.lsp = {
        filetypes = {
          "http",
          "rest",
          "javascript",
          "typescript",
          "lua",
        },
      }

      opts.ui = {
        max_response_size = 1048576,
        max_request_size = 32768,
      }
      if OwnUtil.sys.is_termux() then
        opts.ui.split_direction = "horizontal"
      end
    end,
    keys = {
      { "<leader>R", "", desc = "+Rest" },
      { "<leader>Rb", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "Open scratchpad" },
      { "<leader>Rc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy as cURL", ft = "http" },
      { "<leader>RC", "<cmd>lua require('kulala').from_curl()<cr>", desc = "Paste from curl", ft = "http" },
      { "<leader>Re", "<cmd>lua require('kulala').set_selected_env()<cr>", desc = "Set environment", ft = "http" },
      {
        "<leader>Rg",
        "<cmd>lua require('kulala').download_graphql_schema()<cr>",
        desc = "Download GraphQL schema",
        ft = "http",
      },
      { "<leader>Ri", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect current request", ft = "http" },
      { "<leader>Rn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "Jump to next request", ft = "http" },
      { "<leader>Rp", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "Jump to previous request", ft = "http" },
      { "<leader>Rq", "<cmd>lua require('kulala').close()<cr>", desc = "Close window", ft = "http" },
      { "<leader>Rr", "<cmd>lua require('kulala').replay()<cr>", desc = "Replay the last request" },
      { "<leader>Rs", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request", ft = "http" },
      { "<leader>RS", "<cmd>lua require('kulala').show_stats()<cr>", desc = "Show stats", ft = "http" },
      { "<leader>Rt", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "Toggle headers/body", ft = "http" },
    },
  },
}
