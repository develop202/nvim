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

        -- lsp document_highlight高亮组
        LspReferenceWrite = { bg = "#900C3F" },
        LspReferenceRead = { bg = "#597266" },
        LspReferenceText = { bg = "#4c6280" },

        -- lsp inlayhint高亮
        LspInlayHint = { bg = "#3a3234", fg = "#969696" },

        -- fzf选择框背景色
        FzfLuaCursorLine = { bg = "#282828" },
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
