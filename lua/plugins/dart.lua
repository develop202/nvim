return {
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = function()
      local utils = require("flutter-tools.utils")
      require("flutter-tools.ui").notify = function(msg, level, opts)
        opts, level = opts or {}, level or require("flutter-tools.ui").INFO
        msg = type(msg) == "table" and utils.join(msg) or msg
        if msg == "" then
          return
        end
        local args = { title = "Flutter tools", timeout = opts.timeout, icon = " " }
        if opts.once then
          vim.notify_once(msg, level, args)
        else
          vim.notify(msg, level, args)
        end
      end
    end,
    config = true,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "sidlatau/neotest-dart",
    },
    opts = {
      adapters = {
        ["neotest-dart"] = {},
      },
    },
  },
}
