local default = {}
local directory = {}
local extension = {}
local file = {
  -- ui
  [".node-version"] = { glyph = "󰎙" },
  ["package.json"] = { glyph = "󰎙" },

  -- maven
  ["pom.xml"] = { glyph = "", hl = "MiniIconsRed" },

  -- spring
  ["application.properties"] = { glyph = "", hl = "SpringBootIcon" },
  ["application.yml"] = { glyph = "", hl = "SpringBootIcon" },
  ["bootstrap.properties"] = { glyph = "", hl = "SpringBootIcon" },
  ["bootstrap.yml"] = { glyph = "", hl = "SpringBootIcon" },
}

local filetype = {
  -- java
  jproperties = { glyph = "", hl = "PropertiesIcon" },
}
local lsp = {}
local os = {}

local lazygit_icons = "3"
-- lazygit
if OwnUtil.sys.is_termux() then
  lazygit_icons = ""
end

return {
  {
    "nvim-mini/mini.icons",
    opts = {
      default = default,
      directory = directory,
      extension = extension,
      file = file,
      filetype = filetype,
      lsp = lsp,
      os = os,
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      icons = {
        keys = {
          BS = "󰁮 ",
          F10 = "󱊴 ",
          F11 = "󱊵 ",
          F12 = "󱊶 ",
        },
      },
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        config = {
          gui = {
            -- 关闭图标字体
            nerdFontsVersion = lazygit_icons,
          },
        },
      },
      notifier = {
        margin = { top = 1, right = 1, bottom = 0 },
        icons = {
          -- 解决光标行图标显示问题
          error = " ",
          warn = " ",
          info = " ",
          debug = " ",
          trace = " ",
        },
      },
    },
  },
}
