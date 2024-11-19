local noice_cmdline_min_width = 60
local dashboard_width = 60
if os.getenv("HOME") == "/data/data/com.termux/files/home" then
  noice_cmdline_min_width = 30
  dashboard_width = 45
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
          header = [[
                 __                
  ___    __  __ /\_\    ___ ___    
 / _ `\ /\ \/\ \\/\ \  / __` __`\  
/\ \/\ \\ \ \_/ |\ \ \/\ \/\ \/\ \ 
\ \_\ \_\\ \___/  \ \_\ \_\ \_\ \_\
 \/_/\/_/ \/__/    \/_/\/_/\/_/\/_/
]],
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
