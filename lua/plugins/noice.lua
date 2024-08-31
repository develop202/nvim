return {
  {
    "folke/noice.nvim",
    init = function()
      -- 设置补全框宽度
      ---@diagnostic disable-next-line: assign-type-mismatch
      require("noice.config.preset").presets.command_palette.views.cmdline_popupmenu.size.width = "63%"
    end,
    opts = {
      --   presets = {
      --     command_palette = false,
      --   },
      cmdline = {
        format = {
          lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = " ", lang = "lua" },
          calculator = { pattern = "^=", icon = " ", lang = "vimnormal" },
        },
      },
      views = {
        cmdline_popup = {
          -- position = {
          --   row = 5,
          --   col = "50%",
          -- },
          size = {
            width = "60%",
            -- height = "auto",
          },
        },
        -- cmdline补全列表宽度
        -- 修改源码noice/config/preset.lua:85
        -- 60->"65%"
        -- presets = {
        --   command_palette = {
        --     cmdline_popupmenu = {
        --       size = {
        --         width = "60%",
        --       },
        --     },
        --   },
        -- },
        -- popupmenu = {
        -- relative = "editor",
        -- position = {
        --   row = 8,
        --   col = "50%",
        -- },
        -- size = {
        --   width = "65%",
        --   height = 5,
        -- },
        -- border = {
        --   style = "rounded",
        --   padding = {
        --     0,
        --     1,
        --   },
        -- },
        -- },
      },
    },
    keys = {
      {
        "<Esc>",
        function()
          -- vim.cmd.Noice("dismiss")
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Clear Notifications",
      },
      -- {
      --   "<D-0>",
      --   function()
      --     vim.cmd.Noice("dismiss")
      --     vim.cmd.Noice("history")
      --   end,
      --   mode = {
      --     "n",
      --     "x",
      --     "i",
      --   },
      --   desc = "Notification Log",
      -- },
    },
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      stages = "fade_in_slide_out",
    },
  },
}
