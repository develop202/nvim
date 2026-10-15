if not OwnUtil.sys.is_termux() then
  vim.g.font_italic = true
end
local hl = OwnUtil.utils.hl
return {
  -- add gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    event = "UIEnter",
    opts = {
      overrides = {
        GruvboxRedSign = { fg = hl.get_hl("GruvboxRedSign").fg, bg = "NONE" },
        GruvboxGreenSign = { fg = hl.get_hl("GruvboxGreenSign").fg, bg = "NONE" },
        GruvboxBlueSign = { fg = hl.get_hl("GruvboxBlueSign").fg, bg = "NONE" },
        GruvboxYellowSign = { fg = hl.get_hl("GruvboxYellowSign").fg, bg = "NONE" },
        GruvboxAquaSign = { fg = hl.get_hl("GruvboxAquaSign").fg, bg = "NONE" },

        SignColumn = { bg = "NONE" },
        -- 去除光标所在行行号的背景颜色
        CursorLineNr = { fg = hl.get_hl("CursorLineNr").fg, bg = "NONE" },

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

        NeoTreeMessage = { fg = "#625d51", italic = vim.g.font_italic },
        NeoTreeRootName = { bold = true, italic = vim.g.font_italic },
        NeoTreeGitConflict = { bold = true, fg = "#ff8700", italic = vim.g.font_italic },
        NeoTreeGitUntracked = { fg = "#ff8700", italic = vim.g.font_italic },

        SpringBootIcon = { fg = "#57965c" },
        PropertiesIcon = { fg = "#ced0d6" },
      },
      italic = {
        -- termux上关闭斜体
        strings = vim.g.font_italic,
        emphasis = vim.g.font_italic,
        comments = vim.g.font_italic,
        folds = vim.g.font_italic,
      },
    },
  },
}
