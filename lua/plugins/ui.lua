local logo = [[
                 __                
  ___    __  __ /\_\    ___ ___    
 / _ `\ /\ \/\ \\/\ \  / __` __`\  
/\ \/\ \\ \ \_/ |\ \ \/\ \/\ \/\ \ 
\ \_\ \_\\ \___/  \ \_\ \_\ \_\ \_\
 \/_/\/_/ \/__/    \/_/\/_/\/_/\/_/
]]
logo = string.rep("\n", 8) .. logo .. "\n\n"

return {
  {
    "uga-rosa/ccc.nvim",
    -- 只用来修改颜色
    event = { "LazyFile" },
    config = function()
      -- Enable true color
      vim.opt.termguicolors = true

      local ccc = require("ccc")
      -- local mapping = ccc.mapping

      ccc.setup({
        -- Your preferred settings
        -- Example: enable highlighter
        highlighter = {
          auto_enable = false,
          lsp = false,
        },
      })
    end,
  },
  {
    "brenoprata10/nvim-highlight-colors",
    -- 只用来颜色高亮
    event = { "LazyFile" },
    config = function()
      -- Ensure termguicolors is enabled if not already
      vim.opt.termguicolors = true
      require("nvim-highlight-colors").setup({})
    end,
  },
  {
    "hiphish/rainbow-delimiters.nvim",
    event = { "LazyFile" },
    config = function()
      require("rainbow-delimiters.setup").setup({})
    end,
  },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        style_preset = require("bufferline").style_preset.no_italic,
      },
    },
  },
  {
    "nvimdev/dashboard-nvim",
    opts = {
      config = {
        header = vim.split(logo, "\n"),
      },
    },
  },
}
