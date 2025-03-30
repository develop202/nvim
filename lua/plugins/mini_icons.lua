local suf = ""
if OwnUtil.sys.is_termux() then
  suf = " "
end
local default = {}
local directory = {}
local extension = {}
local file = {
  -- ui
  [".keep"] = { glyph = "󰊢" .. suf, hl = "MiniIconsGrey" },
  ["devcontainer.json"] = { glyph = "" .. suf, hl = "MiniIconsAzure" },

  -- Chezmoi
  [".chezmoiignore"] = { glyph = "" .. suf, hl = "MiniIconsGrey" },
  [".chezmoiremove"] = { glyph = "" .. suf, hl = "MiniIconsGrey" },
  [".chezmoiroot"] = { glyph = "" .. suf, hl = "MiniIconsGrey" },
  [".chezmoiversion"] = { glyph = "" .. suf, hl = "MiniIconsGrey" },
  ["bash.tmpl"] = { glyph = "" .. suf, hl = "MiniIconsGrey" },
  ["json.tmpl"] = { glyph = "" .. suf, hl = "MiniIconsGrey" },
  ["ps1.tmpl"] = { glyph = "󰨊" .. suf, hl = "MiniIconsGrey" },
  ["sh.tmpl"] = { glyph = "" .. suf, hl = "MiniIconsGrey" },
  ["toml.tmpl"] = { glyph = "" .. suf, hl = "MiniIconsGrey" },
  ["yaml.tmpl"] = { glyph = "" .. suf, hl = "MiniIconsGrey" },
  ["zsh.tmpl"] = { glyph = "" .. suf, hl = "MiniIconsGrey" },

  -- Typescript
  [".eslintrc.js"] = { glyph = "󰱺" .. suf, hl = "MiniIconsYellow" },
  [".node-version"] = { glyph = "󰎙" .. suf, hl = "MiniIconsGreen" },
  [".prettierrc"] = { glyph = "" .. suf, hl = "MiniIconsPurple" },
  [".yarnrc.yml"] = { glyph = "" .. suf, hl = "MiniIconsBlue" },
  ["eslint.config.js"] = { glyph = "󰱺" .. suf, hl = "MiniIconsYellow" },
  ["package.json"] = { glyph = "󰎙" .. suf, hl = "MiniIconsGreen" },
  ["tsconfig.json"] = { glyph = "" .. suf, hl = "MiniIconsAzure" },
  ["tsconfig.build.json"] = { glyph = "" .. suf, hl = "MiniIconsAzure" },
  ["yarn.lock"] = { glyph = "" .. suf, hl = "MiniIconsBlue" },

  -- go
  [".go-version"] = { glyph = "" .. suf, hl = "MiniIconsBlue" },

  -- maven
  ["pom.xml"] = { glyph = "" .. suf, hl = "MiniIconsRed" },

  -- spring
  ["application.properties"] = { glyph = "" .. suf, hl = "SpringBootIcon" },
  ["application.yml"] = { glyph = "" .. suf, hl = "SpringBootIcon" },
  ["bootstrap.properties"] = { glyph = "" .. suf, hl = "SpringBootIcon" },
  ["bootstrap.yml"] = { glyph = "" .. suf, hl = "SpringBootIcon" },
}

local filetype = {
  -- ui
  dotenv = { glyph = "" .. suf, hl = "MiniIconsYellow" },

  -- go
  gotmpl = { glyph = "󰟓" .. suf, hl = "MiniIconsGrey" },

  -- java
  jproperties = { glyph = "" .. suf, hl = "PropertiesIcon" },
}
local lsp = {}
local os = {}

default = vim.tbl_deep_extend("force", OwnUtil.mini_icons.default, default)

directory = vim.tbl_deep_extend("force", OwnUtil.mini_icons.directory, directory)

extension = vim.tbl_deep_extend("force", OwnUtil.mini_icons.extension, extension)

file = vim.tbl_deep_extend("force", OwnUtil.mini_icons.file, file)

filetype = vim.tbl_deep_extend("force", OwnUtil.mini_icons.filetype, filetype)

lsp = vim.tbl_deep_extend("force", OwnUtil.mini_icons.lsp, lsp)

os = vim.tbl_deep_extend("force", OwnUtil.mini_icons.os, os)
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
