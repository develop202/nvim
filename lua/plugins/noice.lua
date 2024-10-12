return {
  {
    "folke/noice.nvim",
    config = function(_, opts)
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      ---@diagnostic disable-next-line: assign-type-mismatch
      require("noice.config.preset").presets.command_palette.views.cmdline_popupmenu.size.width = 30
      require("noice").setup(opts)
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
            min_width = 30,
            -- height = "auto",
          },
        },
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
    },
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      stages = "fade_in_slide_out",
    },
  },
}
