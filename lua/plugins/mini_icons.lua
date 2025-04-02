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

return {
  {
    "echasnovski/mini.icons",
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
}
