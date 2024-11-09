local width = 60
if os.getenv("HOME") == "/data/data/com.termux/files/home" then
  width = 30
end

return {
  {
    "folke/noice.nvim",
    opts = {
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
  },
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<Esc>",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
    },
  },
}
