return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    enabled = true,
    init = false,
    dependencies = {
      "ahmedkhalf/project.nvim",
      event = "VeryLazy",
      config = function()
        require("project_nvim").setup({
          -- patterns = { "src" }
        })
      end,
      keys = {
        { "<leader>p", "<Cmd>Telescope projects<CR>", desc = "Projects" },
      },
    },
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      local logo = {
        [[                 __]],
        [[  ___    __  __ /\_\    ___ ___]],
        [[ / _ `\ /\ \/\ \\/\ \  / __` __`\]],
        [[/\ \/\ \\ \ \_/ |\ \ \/\ \/\ \/\ \]],
        [[\ \_\ \_\\ \___/  \ \_\ \_\ \_\ \_\]],
        [[ \/_/\/_/ \/__/    \/_/\/_/\/_/\/_/]],
      }
      -- dashboard.section.header.val = vim.split(logo, "\n")
      dashboard.section.header.val = logo
      local button = dashboard.button("p", " " .. " Projects", "<cmd>Telescope projects<CR>")
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
      table.insert(dashboard.section.buttons.val, 4, button)
      return dashboard
    end,
  },
}
