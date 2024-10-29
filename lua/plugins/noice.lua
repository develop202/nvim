local width = 60
if os.getenv("HOME") == "/data/data/com.termux/files/home" then
  width = 30
end

return {
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        format = {
          lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = " ", lang = "lua" },
          calculator = { pattern = "^=", icon = " ", lang = "vimnormal" },
        },
      },
      views = {
        -- cmdline宽度
        cmdline_popup = {
          size = {
            min_width = width,
          },
        },
        -- cmdline补全框宽度
        cmdline_popupmenu = {
          size = {
            width = width,
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
