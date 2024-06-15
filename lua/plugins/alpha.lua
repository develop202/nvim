return {
  {
    "goolord/alpha-nvim",
    -- event = "VimEnter",
    -- enabled = true,
    -- init = false,
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
      -- LazyVim.pick用不了
      dashboard.section.buttons.val = {
        dashboard.button("f", " " .. " Find file", "<cmd> Telescope find_files <cr>"),
        dashboard.button("n", " " .. " New file", [[<cmd> ene <BAR> startinsert <cr>]]),
        dashboard.button("r", " " .. " Recent files", "<cmd> Telescope oldfiles <cr>"),
        dashboard.button("g", " " .. " Find text", "<cmd> Telescope live_grep <cr>"),
        dashboard.button("c", " " .. " Config", "<cmd> cd ~/.config/nvim | Telescope find_files <cr>"),
        dashboard.button("s", " " .. " Restore Session", [[<cmd> lua require("persistence").load() <cr>]]),
        dashboard.button("x", " " .. " Lazy Extras", "<cmd> LazyExtras <cr>"),
        dashboard.button("l", "󰒲 " .. " Lazy", "<cmd> Lazy <cr>"),
        dashboard.button("q", " " .. " Quit", "<cmd> qa <cr>"),
      }
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end
      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"
      dashboard.opts.layout[1].val = 8
      local button = dashboard.button("p", " " .. " Projects", "<cmd>Telescope projects<CR>")
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
      table.insert(dashboard.section.buttons.val, 4, button)
      return dashboard
    end,
  },
}
