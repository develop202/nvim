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
    opts = function(opts)
      opts = {
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
          -- LspReferenceWrite = { bg = "#900C3F" },
          -- LspReferenceRead = { bg = "#597266" },
          -- LspReferenceText = { bg = "#4c6280" },

          -- vscode的配色方案
          LspReferenceWrite = { bg = "#0d425f" },
          LspReferenceRead = { bg = "#4c4c4c" },
          LspReferenceText = { bg = "#4c4c4c" },

          IlluminatedLspReferenceRead = { bg = "#4a4a4a" },
          IlluminatedWordWrite = { bg = "#0b405d" },
          IlluminatedLspReferenceText = { bg = "#4a4a4a" },

          -- lsp inlayhint高亮
          LspInlayHint = { bg = "#3a3234", fg = "#969696" },
        },
      }

      if not vim.g.termux_italic then
        opts.italic = {
          -- termux上关闭斜体
          strings = vim.g.termux_italic,
          emphasis = vim.g.termux_italic,
          comments = vim.g.termux_italic,
          folds = vim.g.termux_italic,
        }
        -- 关闭neo-tree git斜体
        opts.overrides.NeoTreeMessage = { fg = "#625d51" }
        opts.overrides.NeoTreeRootName = { bold = true }
        opts.overrides.NeoTreeGitConflict = { bold = true, fg = "#ff8700" }
        opts.overrides.NeoTreeGitUntracked = { fg = "#ff8700" }
      end

      return opts
    end,
  },
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
