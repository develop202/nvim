return {
  {
    "folke/tokyonight.nvim",
    enabled = false,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    enabled = false,
  },

  -- add gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      italic = {
        strings = false,
        emphasis = false,
        comments = false,
        operators = false,
        folds = false,
      },
      overrides = {
        GruvboxRedSign = { fg = "#fb4934", bg = "NONE" },
        GruvboxGreenSign = { fg = "#b8bb26", bg = "NONE" },
        GruvboxBlueSign = { fg = "#83a598", bg = "NONE" },
        GruvboxYellowSign = { fg = "#fabd2f", bg = "NONE" },
        GruvboxAquaSign = { fg = "#8ec07c", bg = "NONE" },

        SignColumn = { bg = "NONE" },
        -- 去除光标所在行行号的背景颜色
        CursorLineNr = { fg = "#fabd2f", bg = "NONE" },
      },
    },
  },
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
