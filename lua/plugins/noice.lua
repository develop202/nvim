local noice_cmdline_min_width = 60
local dashboard_width = 60
if OwnUtil.sys.is_termux() then
  noice_cmdline_min_width = 30
  -- 减少启动页面整体宽度
  local width = vim.o.columns
  if width < 75 then
    dashboard_width = math.floor(0.8 * width)
    -- 让两边边距相同
    if (width - dashboard_width) % 2 == 1 then
      dashboard_width = dashboard_width + 1
    end
  end
end

return {
  {
    "folke/noice.nvim",
    opts = {
      views = {
        -- cmdline宽度
        cmdline_popup = {
          size = {
            min_width = noice_cmdline_min_width,
          },
        },
        -- cmdline补全框宽度
        cmdline_popupmenu = {
          size = {
            width = noice_cmdline_min_width,
          },
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        width = dashboard_width,
        preset = {
          header = OwnUtil.utils.dashboard.preset.header,
        },
      },
    },
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
